# KiMoSys - web-based platform for Kinetic Models of biological Systems.
# Copyright (C) 2013-2013 Rafael Costa

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2
# of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of

# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software


# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

class Emailer < ActionMailer::Base
  default from: "kimosys@kdbio.inesc-id.pt"
  
  def notification_new_organism(to,organism)
    @organism_mail = organism
    mail(:to => "Kimosys user <#{to.email}>", :subject => "[KiMoSys] New information")
  end
  
  def notification_new_associated_model(to,associated_model,organism)
    @associated_model_mail = associated_model
    @organism_mail = organism
    mail(:to => "Kimosys user <#{to.email}>", :subject => "[KiMoSys] New information")
  end
  
  def notification_invite_user_to_associated_model(to,associated_model,user,added_by,organism)
    @associated_model_mail = associated_model
    @organism_mail = organism
    @user = user
    @added_by = added_by
    mail(:to => "Kimosys user <#{to.email}>", :subject => "[KiMoSys] You have been added to model")
  end
  
  def notification_invite_user_to_organism(to,organism,user,added_by)
    @organism_mail = organism
    @user = user
    @added_by = added_by
    mail(:to => "Kimosys user <#{to.email}>", :subject => "[KiMoSys] You have been added to data")
  end
  
  def notification_quick_submit(to,quick)
    @quick_mail = quick
    mail(:to => "Kimosys user <#{to.email}>", :subject => "[KiMoSys] New information")
  end
  
end
