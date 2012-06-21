# Guardamos en el log los atributos de un objeto si este es borrado o modificado
ActiveRecord::Base.class_eval do
  def after_validation_on_update
    model_logger
    after_validation_on_update_logger
  end

  def before_destroy
    self.write_attribute(:deleted, true)
    model_logger
    before_destroy_logger
  end

  def after_validation_on_update_logger
  end

  def before_destroy_logger
  end

  private

    def model_logger
      if self.changed? and self.errors.full_messages.blank?
        if self.changes.include? 'deleted'
          text = "deleted at #{Time.now}. Attributes:\n#{self.attributes.delete_if{ |k,v| [ 'id', 'deleted' ].include? k }.inspect}"
        else
          text = "changes at #{Time.now}:\n#{self.changes.inspect}"
        end
        Rails.logger.info "==========\n#{self.class}->#{self.id} object #{text}\n==========\n"
      end
    end
end