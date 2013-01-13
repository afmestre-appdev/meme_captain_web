require 'spec_helper'

describe GendThumbsController do

  describe "GET 'show'" do

    context 'when the id is found' do

      let(:gend_thumb) {
        mock_model(GendThumb)
      }

      it 'shows the thumbnail' do
        GendThumb.should_receive(:find).and_return(gend_thumb)

        get 'show', :id => 1

        expect(response).to be_success
      end

      it 'has the right content type' do
        gend_thumb.should_receive(:content_type).and_return('content type')
        GendThumb.should_receive(:find).and_return(gend_thumb)

        get 'show', :id => 1

        expect(response.content_type).to eq('content type')
      end

      it 'has the right content' do
        gend_thumb.should_receive(:image).and_return('image')
        GendThumb.should_receive(:find).and_return(gend_thumb)

        get 'show', :id => 1

        expect(response.body).to eq('image')
      end

    end

    context 'when the id is not found' do

      it 'raises record not found' do
        expect {
          get 'show', :id => 1
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

    end

  end

end