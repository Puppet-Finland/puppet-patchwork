# frozen_string_literal: true

require 'spec_helper'

describe 'patchwork' do
  default_params = { 'secret_key'         => 'secret',
                     'default_from_email' => 'john.doe@example.org',
                     'admins'             => { 'admin' => 'secret' },
                     'db_password'        => 'secret',
                     'imap_server'        => 'imap.example.org',
                     'imap_port'          => 993,
                     'imap_username'      => 'john.doe',
                     'imap_password'      => 'secret',
                     'server_name'        => 'patchwork.example.org',
                     'revision'           => 'v3.0.5',
                     'in_rspec'           => true, }

  let(:pre_condition) do
    <<-EOL
    include ::stdlib
    EOL
  end

  on_supported_os.each do |os, os_facts|
    context "defaults on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params }

      it { is_expected.to compile }

      expected_params = { 'ensure'              => 'present',
                          'listen_port'         => 80,
                          'ssl'                 => false,
                          'ssl_cert'            => nil,
                          'ssl_key'             => nil,
                          'www_root'            => '/var/www',
                          'uwsgi'               => 'unix:/run/uwsgi/app/patchwork/socket' }

      it { is_expected.to contain_nginx__resource__server('patchwork.example.org').with(expected_params) }
    end

    context "no datasource on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge({ 'manage_datasource' => false }) }

      it { is_expected.to compile }
    end

    context "no getmail on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge({ 'manage_getmail' => false }) }

      it { is_expected.to compile }
    end

    context "no nginx on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge({ 'manage_nginx' => false }) }

      it { is_expected.to compile }
    end

    context "no uwsgi on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge({ 'manage_uwsgi' => false }) }

      it { is_expected.to compile }
    end

    context "valid ssl params on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        default_params.merge({ 'ssl'      => true,
                               'ssl_cert' => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
                               'ssl_key'  => '/etc/ssl/private/ssl-cert-snakeoil.key', })
      end

      it { is_expected.to compile }

      expected_params = { 'ensure'              => 'present',
                          'listen_port'         => 443,
                          'ssl'                 => true,
                          'ssl_cert'            => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
                          'ssl_key'             => '/etc/ssl/private/ssl-cert-snakeoil.key',
                          'www_root'            => '/var/www',
                          'uwsgi'               => 'unix:/run/uwsgi/app/patchwork/socket' }

      it { is_expected.to contain_nginx__resource__server('patchwork.example.org').with(expected_params) }
    end

    context "missing ssl_cert param on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        default_params.merge({ 'ssl'     => true,
                               'ssl_key' => '/etc/ssl/private/ssl-cert-snakeoil.key', })
      end

      it { is_expected.to compile.and_raise_error(%r{ERROR: must define \$ssl_cert and \$ssl_key when \$ssl = true}) }
    end

    context "missing ssl_key param on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        default_params.merge({ 'ssl'      => true,
                               'ssl_cert' => '/etc/ssl/certs/ssl-cert-snakeoil.pem', })
      end

      it { is_expected.to compile.and_raise_error(%r{ERROR: must define \$ssl_cert and \$ssl_key when \$ssl = true}) }
    end

    context "invalid ssl params on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge({ 'ssl' => true }) }

      it { is_expected.to compile.and_raise_error(%r{ERROR: must define \$ssl_cert and \$ssl_key when \$ssl = true}) }
    end

    context "invalid ssl params on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge({ 'ssl' => true }) }

      it { is_expected.to compile.and_raise_error(%r{ERROR: must define \$ssl_cert and \$ssl_key when \$ssl = true}) }
    end
  end
end
