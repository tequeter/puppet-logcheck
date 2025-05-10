test: init syntax lint unit acceptance

init:
	bundle install
	bundle exec rake spec_prep

syntax:
	bundle exec rake syntax

lint:
	bundle exec rake lint

unit:
	bundle exec rake spec_standalone

acceptance:
	$(MAKE) acceptance-cleanup-podman
	podman run --name=puppet_logcheck_debian13 -d debvox:13
	podman exec puppet_logcheck_debian13 apt-get update
	bundle exec rake litmus:install_module
	bundle exec rake litmus:acceptance:puppet_logcheck_debian13
	$(MAKE) acceptance-cleanup-podman

acceptance-cleanup-podman:
	podman rm -f puppet_logcheck_debian13

clean:
	rm -rf pkg vendor spec/fixtures/m*
	$(MAKE) acceptance-cleanup-podman

.PHONY: syntax lint unit acceptance acceptance-cleanup-podman clean
