require 'spec_helper'

describe 'Logcheck::Patternsource' do
  it { is_expected.to allow_value([]) }
  it { is_expected.to allow_value('') }
  it { is_expected.to allow_value("^pattern1$\n^pattern2$\n") }
  it { is_expected.not_to allow_value('^pattern1$') }
end
