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
  end
end
