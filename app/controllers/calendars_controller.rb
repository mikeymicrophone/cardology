class CalendarsController < ApplicationController
  def mine
    @birthday = current_member.birthday
    @transitions = @birthday.triples_for_year
    @transition_dates = @transitions.map &:first
  end
  
  def ours
    @birthday = current_member.birthday
    @transitions = @birthday.triples_for_year
    @friend_transitions = current_member.celestials_transitions
    
    @transition_dates = @transitions.map &:first
    @friend_transition_dates = @friend_transitions.map &:first
  end
  
  def last_year
    
  end
end
