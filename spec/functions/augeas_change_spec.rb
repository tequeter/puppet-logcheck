require 'spec_helper'

describe 'logcheck::augeas_change' do
  it { is_expected.to run.with_params('NAME', 'Value').and_return("set NAME '\"Value\"'") }
  it { is_expected.to run.with_params('NAME', 'Val"ue').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('NAME', 42).and_return("set NAME '\"42\"'") }
  it { is_expected.to run.with_params('NAME', true).and_return("set NAME '1'") }
  it { is_expected.to run.with_params('NAME', :undef).and_return('rm NAME') }
end
