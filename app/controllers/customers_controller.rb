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
class CustomersController < ApplicationController
  before_filter :authify, :except => [:render_label]
  before_filter :initialize_instance_variables, :except => [:render_label]
  before_filter :check_role, :except => [:crumble, :render_label]
  before_filter :crumble, :except => [:render_label]
  # GET /customers
  # GET /customers.xml
  def index
    @customers = Customer.scopied.page(GlobalData.params.page).per(GlobalData.conf.pagination)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new
    @customer.loyalty_card = LoyaltyCard.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
    if not @customer.loyalty_card then
      @customer.loyalty_card = LoyaltyCard.new
    end
    add_breadcrumb I18n.t("menu.customer") + ' ' + @customer.full_name,'edit_customer_path(@customer,:vendor_id => params[:vendor_id])'
  end

  # POST /customers
  # POST /customers.xml
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      if @customer.save
        @lc = LoyaltyCard.new params[:loyalty_card]
        @lc.customer_id = @customer.id
        @lc.save
        format.html { redirect_to(:action => 'index', :notice => I18n.t("views.notice.model_create", :model => Customer.human_name)) }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        @customer.loyalty_card.update_attributes params[:loyalty_card]
        format.html { redirect_to(:action => 'index', :notice => 'Customer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])
    @customer.loyalty_card.destroy
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end
  def render_label
    if params[:id]
      @customers = Customer.find_all_by_id params[:id]
    elsif params[:all]
      @customers = Customer.find_all_by_hidden :false
    elsif params[:skus]
      @customers = Customer.where :id => params[:ids].split("\r\n")
    end
    render :text => Printr.new.sane_template(params[:type],binding)
  end

  def labels
    if params[:id]
      @customers = Customer.find_all_by_id params[:id]
    elsif params[:all]
      @customers = Customer.find_all_by_hidden :false
    elsif params[:skus]
      @customers = Customer.where :id => params[:ids].split("\r\n")
    end
    vendor_id = GlobalData.salor_user.meta.vendor_id
    if vendor_id
      if params[:type] == 'lc_label'
        type = 'escpos'
      elsif params[:type] == 'lc_sticker'
        type = 'slcs'
      end
      printer = VendorPrinter.where( :vendor_id => vendor_id, :printer_type => type ).first
      Printr.new.send(printer.name.to_sym, params[:type], binding) if printer
    end
    render :nothing => true
  end

  def upload_optimalsoft
    if params[:file]
      lines = params[:file].read.split("\n")
      i, updated_items, created_items, created_categories, created_tax_profiles = FileUpload.new.type4(lines)
      redirect_to(:action => 'index')
    else
      redirect_to :controller => 'items', :action => 'upload'
    end
  end

  private 
  def crumble
    @vendor = salor_user.get_vendor(salor_user.meta.vendor_id)
    add_breadcrumb @vendor.name,'vendor_path(@vendor)'
    add_breadcrumb I18n.t("menu.customers"),'customers_path(:vendor_id => params[:vendor_id])'
  end
end
