# coding: utf-8

require 'spec_helper'

describe StringTools do
  describe '#sanitize' do
    it 'removes style tags from string' do
      sanitized_string = described_class.sanitize('test string<style>body { color: red; }</style>')
      expect(sanitized_string).to eq 'test string'
    end

    it 'removes javascript from string' do
      sanitized_string = described_class.sanitize('test string<javascript>alert("ALERT");</javascript>' )
      expect(sanitized_string).to eq 'test string'
    end

    it 'does not cut css properties in html' do
      origin_str = '<table><tr><td style="text-align: center;"></td></tr></table>'
      sanitized_string = described_class.sanitize(origin_str)
      expect(sanitized_string).to eq origin_str
    end

    it 'normalize unicode urls in img src attribute' do
      origin_str = '<img src="http://www.фермаежей.рф/images/foo.png">'
      sanitized_string = described_class.sanitize(origin_str)
      expect(sanitized_string).to eq '<img src="http://www.xn--80ajbaetq5a8a.xn--p1ai/images/foo.png">'
    end

    it 'normalize unicode urls in a href attribute' do
      origin_str = '<a href="http://www.фермаежей.рф/">www.фермаежей.рф</a>'
      sanitized_string = described_class.sanitize(origin_str)
      expect(sanitized_string).to eq '<a href="http://www.xn--80ajbaetq5a8a.xn--p1ai/">www.фермаежей.рф</a>'
    end

    it 'ignore ivalid links' do
      origin_str = '<img height="180" src="file://%5C%5Cab.ru%5Csharedfolders%5C%D0%9F%D0%A6%5CPRICES%5C%D0%9D%D0%B0%D0%B4%D0%BE%D0%BC%D0%BD%D0%B8%D0%BA%D0%B8%5C%D0%A1%D0%B8%D0%B4%D0%BE%D1%80%D0%BA%D0%B8%D0%BD%5C2015%5C113.%20%D0%9D%D0%B0%D1%83%D1%82%D0%B8%D0%BB%D0%B8%D1%83%D1%81%5C4.png" width="289">'
      sanitized_string = described_class.sanitize(origin_str)
      expect(sanitized_string).to eq origin_str
    end
  end

  describe '#strip_all_tags_and_entities' do
    subject(:strip_all_tags_and_entities) { described_class.strip_all_tags_and_entities(string) }

    context 'string with html tags' do
      let(:string) { '<a>foo</a><div>bar</div>' }

      it { expect(strip_all_tags_and_entities).to eq('foo bar ') }
    end

    context 'string with whitespaces and tabs' do
      let(:string) { "foo&#9;bar\t  foo" }

      it { expect(strip_all_tags_and_entities).to eq('foobarfoo') }
    end
  end

  describe '#strip_tags_leave_br' do
    subject(:strip_tags_leave_br) { described_class.strip_tags_leave_br(string) }

    context 'string with html list' do
      let(:string) { '<ul><li>foo</li></ul>' }

      it { expect(strip_tags_leave_br).to eq('<br />foo<br /><br />') }
    end

    context 'string with html paragraph' do
      let(:string) { '<p>bar</p>' }

      it { expect(strip_tags_leave_br).to eq('bar<br />') }
    end
  end

  describe '#add_params_to_url' do
    subject(:add_params_to_url) { described_class.add_params_to_url(url, params) }
    let(:url) { 'http://test.com' }
    let(:uri) { 'http://test.com/?param=test' }

    context 'when url with params' do
      let(:params) { {'param' => 'test'} }

      it { expect(add_params_to_url).to eq uri }
    end

    context 'when optional params not passed' do
      it { expect(described_class.add_params_to_url(url)).to eq 'http://test.com/' }
    end

    context 'when url not normalized' do
      let(:url) { 'http://TesT.com:80' }
      let(:params) { {'param' => 'test'} }

      it { expect(add_params_to_url).to eq uri }
    end

    context 'when url without scheme' do
      let(:url) { 'test.com' }
      let(:params) { {'param' => 'test'} }

      it { expect(add_params_to_url).to eq uri }
    end

    context 'when url scheme is https' do
      let(:url) { 'https://test.com' }
      let(:params) { {'param' => 'test'} }

      it { expect(add_params_to_url).to eq 'https://test.com/?param=test' }
    end

    context 'when key is a symbol with same value' do
      let(:url) { 'http://test.com/?a=b' }

      it { expect(described_class.add_params_to_url(url, a: 'c')).to eq 'http://test.com/?a=c' }
    end

    context 'when url invalid' do
      let(:url) { 'file://%5C%5Cab.ru%5Csharedfolders%5C%D0%9F%D0%A6%5CPRICES%5C%D0%9D%D0%B0%D0%B4%D0%BE%D0%BC%D0%BD%D0%B8%D0%BA%D0%B8%5C%D0%A1%D0%B8%D0%B4%D0%BE%D1%80%D0%BA%D0%B8%D0%BD%5C2015%5C113.%20%D0%9D%D0%B0%D1%83%D1%82%D0%B8%D0%BB%D0%B8%D1%83%D1%81%5C4.png' }

      it { expect(described_class.add_params_to_url(url, a: 'c')).to eq url }
    end
  end
end
