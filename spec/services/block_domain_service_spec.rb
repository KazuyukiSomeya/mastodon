require 'rails_helper'

RSpec.describe BlockDomainService do
  let(:bad_account) { Fabricate(:account, username: 'badguy666', domain: 'evil.org') }
  let(:bad_status1) { Fabricate(:status, account: bad_account, text: 'You suck') }
  let(:bad_status2) { Fabricate(:status, account: bad_account, text: 'Hahaha') }
  let(:bad_attachment) { Fabricate(:media_attachment, account: bad_account, status: bad_status2, file: attachment_fixture('attachment.jpg')) }

  subject { BlockDomainService.new }

  before do
    bad_account
    bad_status1
    bad_status2
    bad_attachment

    subject.call(DomainBlock.create!(domain: 'evil.org', severity: :suspend))
  end

  it 'creates a domain block' do
    expect(DomainBlock.blocked?('evil.org')).to be true
  end

  it 'removes remote accounts from that domain' do
    expect(Account.find_remote('badguy666', 'evil.org').suspended?).to be true
  end

  it 'removes the remote accounts\'s statuses and media attachments' do
    expect { bad_status1.reload }.to raise_exception ActiveRecord::RecordNotFound
    expect { bad_status2.reload }.to raise_exception ActiveRecord::RecordNotFound
    expect { bad_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
  end
end
