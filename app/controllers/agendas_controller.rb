class AgendasController < ApplicationController
  # before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end
  # アジェンダとチームidを中間にして、メンバーが紐づいている。has manyのメソッドを使う。
  # この中でeach doを使って実装する。
  def destroy
    @agenda = Agenda.find(params[:id])
    if current_user.id == @agenda.user_id || current_user.id == Team.find(@agenda.team_id).owner_id
      # binding.irb
      @contact = @agenda.team.members
      # 下記のコメントアウトしたコードだとリーダーのteam_idはとれないし、煩雑。membersメソッドについてはteamモデルのアソシエーションを参照。
      # @contact = User.where(keep_team_id: @agenda.team_id)
      @contact.each do |contact|
      ContactMailer.contact_mail(contact).deliver
      end
      @agenda.destroy
      redirect_to dashboard_path, notice:"削除しました"
    else
      redirect_to dashboard_path, notice:"削除できません"
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
