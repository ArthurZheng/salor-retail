# coding: UTF-8
# ------------------- Salor Point of Sale ----------------------- 
# An innovative multi-user, multi-store application for managing
# small to medium sized retail stores.
# Copyright (C) 2011-2012  Jason Martin <jason@jolierouge.net>
# Visit us on the web at http://salorpos.com
# 
# This program is commercial software (All provided plugins, source code, 
# compiled bytecode and configuration files, hereby referred to as the software). 
# You may not in any way modify the software, nor use any part of it in a 
# derivative work.
# 
# You are hereby granted the permission to use this software only on the system 
# (the particular hardware configuration including monitor, server, and all hardware 
# peripherals, hereby referred to as the system) which it was installed upon by a duly 
# appointed representative of Salor, or on the system whose ownership was lawfully 
# transferred to you by a legal owner (a person, company, or legal entity who is licensed 
# to own this system and software as per this license). 
#
# You are hereby granted the permission to interface with this software and
# interact with the user data (Contents of the Database) contained in this software.
#
# You are hereby granted permission to export the user data contained in this software,
# and use that data any way that you see fit.
#
# You are hereby granted the right to resell this software only when all of these conditions are met:
#   1. You have not modified the source code, or compiled code in any way, nor induced, encouraged, 
#      or compensated a third party to modify the source code, or compiled code.
#   2. You have purchased this system from a legal owner.
#   3. You are selling the hardware system and peripherals along with the software. They may not be sold
#      separately under any circumstances.
#   4. You have not copied the software, and maintain no sourcecode backups or copies.
#   5. You did not install, or induce, encourage, or compensate a third party not permitted to install 
#      this software on the device being sold.
#   6. You have obtained written permission from Salor to transfer ownership of the software and system.
#
# YOU MAY NOT, UNDER ANY CIRCUMSTANCES
#   1. Transmit any part of the software via any telecommunications medium to another system.
#   2. Transmit any part of the software via a hardware peripheral, such as, but not limited to,
#      USB Pendrive, or external storage medium, Bluetooth, or SSD device.
#   3. Provide the software, in whole, or in part, to any thrid party unless you are exercising your
#      rights to resell a lawfully purchased system as detailed above.
#
# All other rights are reserved, and may be granted only with direct written permission from Salor. By using
# this software, you agree to adhere to the rights, terms, and stipulations as detailed above in this license, 
# and you further agree to seek to clarify any right not directly spelled out herein. Any right, not directly 
# covered by this license is assumed to be reserved by Salor, and you agree to contact an official Salor repre-
# sentative to clarify any rights that you infer from this license or believe you will need for the proper 
# functioning of your business.
class TaxProfilesController < ApplicationController
   before_filter :authify
   before_filter :initialize_instance_variables
   before_filter :check_role, :except => [:crumble]
   before_filter :crumble
   
  # GET /tax_profiles
  # GET /tax_profiles.xml
  def index
    @tax_profiles = salor_user.get_tax_profiles

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tax_profiles }
    end
  end

  # GET /tax_profiles/1
  # GET /tax_profiles/1.xml
  def show
    @tax_profile = salor_user.get_tax_profile(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tax_profile }
    end
  end

  # GET /tax_profiles/new
  # GET /tax_profiles/new.xml
  def new
    @tax_profile = TaxProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tax_profile }
    end
  end

  # GET /tax_profiles/1/edit
  def edit
    @tax_profile = salor_user.get_tax_profile(params[:id])
    add_breadcrumb @tax_profile.name,'edit_tax_profile_path(@tax_profile)'
  end

  # POST /tax_profiles
  # POST /tax_profiles.xml
  def create
    @tax_profile = TaxProfile.new(params[:tax_profile])

    respond_to do |format|
      if @tax_profile.save
        format.html { redirect_to(:action => 'new', :notice => I18n.t("views.notice.model_create", :model => TaxProfile.human_name)) }
        format.xml  { render :xml => @tax_profile, :status => :created, :location => @tax_profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tax_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tax_profiles/1
  # PUT /tax_profiles/1.xml
  def update
    @tax_profile = salor_user.get_tax_profile(params[:id])
    
    respond_to do |format|
      if @tax_profile.update_attributes(params[:tax_profile]) and not @tax_profile.order_items.any?
        format.html { render :action => 'edit', :notice => I18n.t("views.notice.model_edit", :model => TaxProfile.human_name) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit",:notice => I18n.t("system.errors.no_longer_editable", :model => TaxProfile.human_name) }
        format.xml  { render :xml => @tax_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_profiles/1
  # DELETE /tax_profiles/1.xml
  def destroy
    @tax_profile = salor_user.get_tax_profile(params[:id])
    if @tax_profile.order_items.any? then
      @tax_profile.update_attribute(:hidden,1)
    else
      @tax_profile.destroy
    end

    respond_to do |format|
      format.html { redirect_to(tax_profiles_url) }
      format.xml  { head :ok }
    end
  end
  private
  def crumble
    add_breadcrumb I18n.t("menu.tax_profiles"),'tax_profiles_path()'
  end
end
