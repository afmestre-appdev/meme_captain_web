# encoding: UTF-8

require 'rails_helper'

describe GendImage do

  it { should validate_uniqueness_of :id_hash }

  it { should belong_to :src_image }

  it { should belong_to :user }

  it { should have_one :gend_thumb }

  it { should have_many :captions }

  it { should_not validate_presence_of :user }

  it 'should generate a unique id hash' do
    gend_image = FactoryGirl.create(:gend_image)
    expect(gend_image.id_hash).to_not be_nil
  end

  context 'setting fields derived from the image' do

    context 'when the image is not animated' do
      subject(:gend_image) do
        gend_image = GendImage.new(FactoryGirl.attributes_for(:gend_image))
        gend_image.valid?
        gend_image
      end

      specify { expect(gend_image.content_type).to eq('image/jpeg') }
      specify { expect(gend_image.height).to eq(399) }
      specify { expect(gend_image.width).to eq(399) }
      specify { expect(gend_image.size).to eq(9141) }
      specify { expect(gend_image.is_animated).to eq(false) }
    end

    context 'when the image is animated' do
      subject(:gend_image) do
        gend_image = GendImage.new(
            FactoryGirl.attributes_for(
                :gend_image,
                image: File.read(
                    Rails.root + 'spec/fixtures/files/omgcat.gif')))
        gend_image.valid?
        gend_image
      end

      specify { expect(gend_image.is_animated).to eq(true) }
    end

  end

  it 'generates a thumbnail'
  # figure out how to use run a delayed job in spec

  describe '#ext' do

    let(:image) { File.read(Rails.root + 'spec/fixtures/files/ti_duck.jpg') }

    subject(:gend_image) do
      gend_image = GendImage.new(
          FactoryGirl.attributes_for(:gend_image, image: image))
      gend_image.valid?
      gend_image
    end

    context 'jpg' do
      specify { expect(gend_image.format).to eq(:jpg) }
    end

    context 'gif' do
      let(:image) { File.read(Rails.root + 'spec/fixtures/files/omgcat.gif') }

      specify { expect(gend_image.format).to eq(:gif) }
    end

    context 'png' do
      let(:image) { File.read(Rails.root + 'spec/fixtures/files/ti_duck.png') }

      specify { expect(gend_image.format).to eq(:png) }
    end

    context 'other' do

      it 'returns nil for extension' do
        subject.content_type = 'foo/bar'
        expect(subject.format).to be_nil
      end

    end

  end

  describe '#email' do
    let(:gend_image) { FactoryGirl.create(:gend_image) }

    it 'passes validation when email is nil' do
      gend_image.email = nil
      expect(gend_image).to be_valid
    end

    it 'passes validation when email is the empty string' do
      gend_image.email = ''
      expect(gend_image).to be_valid
    end

    it 'fails validation when email is set' do
      gend_image.email = 'bot@bots.com'
      expect(gend_image).to_not be_valid
    end
  end

  describe '.caption_matches' do
    let(:caption1) { FactoryGirl.create(:caption, text: 'abc') }
    let(:caption2) { FactoryGirl.create(:caption, text: 'def') }
    before do
      @gend_image = FactoryGirl.create(
          :gend_image, captions: [caption1, caption2])
    end

    context "when one of the image's captions matches" do
      it 'returns the matching image' do
        expect(GendImage.caption_matches('b')).to eq([@gend_image])
      end
    end

    context "when one of the image's captions matches case insensitive" do
      it 'returns the matching image' do
        expect(GendImage.caption_matches('C')).to eq([@gend_image])
      end
    end

    context "when none of the image's captions matches" do
      it 'returns no matches' do
        expect(GendImage.caption_matches('g')).to eq([])
      end
    end

  end
end
