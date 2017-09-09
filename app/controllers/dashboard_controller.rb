# frozen_string_literal: true

# Admin dashboard controller.
class DashboardController < ApplicationController
  def show
    head(:forbidden) unless admin?

    now = Time.zone.now
    last_day = (now - 24.hours)..now

    calculate_gend_image(last_day)

    @src_images_last_24h = SrcImage.where(created_at: last_day).count

    @new_users_last_24h = User.where(created_at: last_day).count

    @no_result_searches = NoResultSearch.last(20).reverse

    set_fields
  end

  private

  def calculate_gend_image(last_day)
    @gend_image_successes_last_24h = GendImage.where(
      error: nil, created_at: last_day
    ).count
    @gend_image_errors_last_24h = GendImage.where.not(error: nil).where(
      created_at: last_day
    ).count
    @gend_image_success_rate_last_24h = success_rate(
      @gend_image_successes_last_24h, @gend_image_errors_last_24h
    )
  end

  def success_rate(success_count, error_count)
    total = success_count + error_count
    return 100.00 if total <= 0
    (success_count / total.to_f * 100).round(2)
  end

  def set_fields
    set_jobs
    set_system
  end

  def set_jobs
    @jobs = Delayed::Job.where(attempts: 0).order(:created_at)
  end

  def set_system
    @system = {
      ruby: RUBY_DESCRIPTION
    }

    set_db_size
    set_gend_image_size
    set_src_image_size
    @system[:dedup_savings_bytes] = \
      dedup_savings(GendImage) + dedup_savings(SrcImage)
  end

  def set_db_size
    return unless ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
    db_name = ActiveRecord::Base.connection.current_database
    @system[:database_size_bytes] = ActiveRecord::Base.connection.execute(
      "SELECT pg_database_size('#{db_name}')"
    ).first['pg_database_size']
  end

  def set_gend_image_size
    @system.merge!(
      gend_image_db_size_bytes: GendImage.where(
        image_external_key: nil
      ).sum(:size),
      gend_image_external_size_bytes: GendImage.where.not(
        image_external_key: nil
      ).sum(:size)
    )
  end

  def set_src_image_size
    @system.merge!(
      src_image_db_size_bytes: SrcImage.where(
        image_external_key: nil
      ).sum(:size),
      src_image_external_size_bytes: SrcImage.where.not(
        image_external_key: nil
      ).sum(:size)
    )
  end

  def dedup_savings(klass)
    klass.where.not(image_external_key: nil).select(
      'image_external_key, size * (COUNT(image_external_key) - 1) AS saved'
    )
         .group(:image_external_key, :size).having(
           'COUNT(image_external_key) > ?', 1
         ).map(&:saved).reduce(:+).to_i
  end
end
