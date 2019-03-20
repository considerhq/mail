# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Mail::ReceivedField do

  it "should initialize" do
    expect { Mail::ReceivedField.new("from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)") }.not_to raise_error
  end

  it "should be able to tell the time" do
    expect(Mail::ReceivedField.new("from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)").date_time.class).to eq DateTime
  end

  it "should accept a string without the field name" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)')
    expect(t.name).to eq 'Received'
    expect(t.value).to eq 'from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)'
    expect(t.info).to eq 'from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>'
    expect(t.date_time).to eq ::DateTime.parse('10 May 2005 17:26:50 +0000 (GMT)')
  end

  it "should provide an encoded value" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)')
    expect(t.encoded).to eq "Received: from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000\r\n"
  end

  it "should provide an encoded value with correct timezone" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 -0500 (EST)')
    expect(t.encoded).to eq "Received: from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 -0500\r\n"
  end

  it "should provide an decoded value" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)')
    expect(t.decoded).to eq 'from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000'
  end

  it "should handle empty name-value lists with a comment only (qmail style)" do
    t = Mail::ReceivedField.new('(qmail 24365 invoked by uid 99); 25 Jan 2011 12:31:11 -0000')
    expect(t.info).to eq '(qmail 24365 invoked by uid 99)'
  end

  it "should handle a blank value" do
    t = Mail::ReceivedField.new('')
    expect(t.decoded).to eq ''
    expect(t.encoded).to eq "Received: \r\n"
  end

  it "should handle invalid date" do
    t = Mail::ReceivedField.new("mail.example.com (192.168.1.1) by mail.example.com with (esmtp) id (qid)  for <foo@example.com>; Mon, 29 Jul 2013 25:12:46 +0900")

    expect(t.name).to eq "Received"
    expect(t.value).to eq "mail.example.com (192.168.1.1) by mail.example.com with (esmtp) id (qid)  for <foo@example.com>; Mon, 29 Jul 2013 25:12:46 +0900"
    expect(t.info).to eq "mail.example.com (192.168.1.1) by mail.example.com with (esmtp) id (qid)  for <foo@example.com>"
    expect(t.date_time).to eq nil
    expect(t.formatted_date).to eq nil
  end

  it "should handle an invalid value (with colons)" do
    t = Mail::ReceivedField.new("by 2002:a05:7000:108d:0:0:0:0 with SMTP id y13csp23744073wrw;\nWed, 13 Mar 2019 14:50:05 -0700 (PDT)")

    expect(t.name).to eq "Received"
    expect(t.value).to eq "by 2002:a05:7000:108d:0:0:0:0 with SMTP id y13csp23744073wrw;\nWed, 13 Mar 2019 14:50:05 -0700 (PDT)"
    expect(t.info).to eq ""
    expect(t.date_time.class).to eq DateTime
    expect(t.formatted_date).to eq "Wed, 13 Mar 2019 00:00:00 +0000"
  end

  it "should handle an invalid value (with angular brackets)" do
    t = Mail::ReceivedField.new("from [192.168.1.186] ([206.248.139.39]) by mx.google.com with ESMTPSA id m10sm4741360qae.12.2013.08.06.07.40.15 for <multiple recipients> (version=TLSv1 cipher=RC4-SHA bits=128/128); Tue, 06 Aug 2013 07:40:18 -0700 (PDT)'")

    expect(t.name).to eq "Received"
    expect(t.value).to eq "from [192.168.1.186] ([206.248.139.39]) by mx.google.com with ESMTPSA id m10sm4741360qae.12.2013.08.06.07.40.15 for <multiple recipients> (version=TLSv1 cipher=RC4-SHA bits=128/128); Tue, 06 Aug 2013 07:40:18 -0700 (PDT)'"
    expect(t.info).to eq ""
    expect(t.date_time.class).to eq DateTime
    expect(t.formatted_date).to eq "Tue, 06 Aug 2013 00:00:00 +0000"
  end
end
