# rubocop:disable RSpec/MultipleExpectations

require 'spec_helper'

describe 'rundeck' do
  context 'supported operating systems' do
    %w(Debian RedHat).each do |osfamily|
      lsbdistid = 'debian' if osfamily.eql?('Debian')
      overrides = '/etc/sysconfig/rundeckd'

      let(:facts) do
        {
          osfamily: osfamily,
          lsbdistid: lsbdistid,
          serialnumber: 0,
          rundeck_version: '',
          puppetversion: '3.8.1'
        }
      end

      describe "rundeck::config class without any parameters on #{osfamily}" do
        it { is_expected.to contain_class('rundeck::config::global::framework') }
        it { is_expected.to contain_class('rundeck::config::global::project') }
        it { is_expected.to contain_class('rundeck::config::global::rundeck_config') }

        it { is_expected.to contain_file('/etc/rundeck').with('ensure' => 'directory') }

        it { is_expected.to contain_file('/etc/rundeck/jaas-auth.conf') }
        it 'generates valid content for jaas-auth.conf' do
          content = catalogue.resource('file', '/etc/rundeck/jaas-auth.conf')[:content]
          expect(content).to include('PropertyFileLoginModule')
          expect(content).to include('/etc/rundeck/realm.properties')
        end

        it { is_expected.to contain_file('/etc/rundeck/realm.properties') }
        it 'generates valid content for realm.properties' do
          content = catalogue.resource('file', '/etc/rundeck/realm.properties')[:content]
          expect(content).to include('admin:admin,user,admin,architect,deploy,build')
        end

        it { is_expected.to contain_file('/etc/rundeck/log4j.properties') }
        it 'generates valid content for log4j.propertiess' do
          content = catalogue.resource('file', '/etc/rundeck/log4j.properties')[:content]
          expect(content).to include('log4j.appender.server-logger.file=/var/log/rundeck/rundeck.log')
        end

        it { is_expected.not_to contain_file('/etc/rundeck/profile') }
        it { is_expected.to contain_file(overrides) }

        it 'generates valid content for the profile overrides file' do
          content = catalogue.resource('file', overrides)[:content]
          expect(content).to include('RDECK_BASE=/var/lib/rundeck')
          expect(content).to include('RDECK_CONFIG=/etc/rundeck')
          expect(content).to include('RDECK_INSTALL=/var/lib/rundeck')
          expect(content).to include('JAAS_CONF=$RDECK_CONFIG/jaas-auth.conf')
          expect(content).to include('LOGIN_MODULE=authentication')
          expect(content).to include('RDECK_JVM_SETTINGS="-Xmx1024m -Xms256m -server"')
        end

        it { is_expected.to contain_rundeck__config__aclpolicyfile('admin') }
        it { is_expected.to contain_rundeck__config__aclpolicyfile('apitoken') }
      end

      describe 'rundeck::config with rdeck_profile_template set' do
        template = 'rundeck/../spec/fixtures/files/profile.template'
        let(:params) { { rdeck_profile_template: template } }
        it { is_expected.to contain_file('/etc/rundeck/profile') }
      end

      describe 'rundeck::config with jvm_args set' do
        jvm_args = '-Dserver.http.port=8008 -Xms2048m -Xmx2048m -server'
        let(:facts) do
          {
            osfamily: 'RedHat',
            serialnumber: 0,
            rundeck_version: '',
            puppetversion: '3.8.1'
          }
        end
        let(:params) { { jvm_args: jvm_args } }
        it { is_expected.to contain_file(overrides) }
        it 'generates valid content for the profile overrides file' do
          content = catalogue.resource('file', overrides)[:content]
          expect(content).to include("RDECK_JVM_SETTINGS=\"#{jvm_args}\"")
        end
      end
    end
  end
end
