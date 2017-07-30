class RemoveSrcThumbIdFromSrcImages < ActiveRecord::Migration[5.0]
  def up
    remove_column :src_images, :src_thumb_id
  end

  def down
    add_column :src_images, :src_thumb_id, :integer
  end
end
