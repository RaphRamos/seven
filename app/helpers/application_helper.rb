module ApplicationHelper

  def render_cancer_campaign(event)
    return '' unless event.payment.present?

    tag.div class: 'row' do
      tag.div class: 'cancer-campaign', style: 'margin: 10px 0px 15px 25px;' do
        tag.a href: 'https://www.ceodaretocure.org.au/my-fundraising/85/ana-carusi', target: '_blank' do
          image_tag('/images/cancer_team_mackenzie.png')
        end
      end
    end
  end

  def offshore_user?
    request.location.country != 'AU'
  end

  def agent_languages
    @agent_languages ||= Agent.languages.sort
  end

  def office_locations
    @office_locations ||= Location.all.pluck(:name)
  end
end
