--------------------------------------------------------
--  DDL for Package Body PO_ASL_ATTRIBUTES_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_ATTRIBUTES_THS" as
/* $Header: POXA5LSB.pls 115.8 2003/08/21 09:39:01 tmanda ship $ */

/*=============================================================================

  PROCEDURE NAME:	insert_row()

===============================================================================*/
procedure insert_row(
	x_row_id		  IN OUT NOCOPY 	VARCHAR2,
	x_asl_id		  		NUMBER,
	x_using_organization_id   		NUMBER,
	x_last_update_date	  		DATE,
	x_last_updated_by	  		NUMBER,
	x_creation_date		  		DATE,
	x_created_by		  		NUMBER,
	x_document_sourcing_method		VARCHAR2,
	x_release_generation_method		VARCHAR2,
	x_purchasing_unit_of_measure		VARCHAR2,
	x_enable_plan_schedule_flag		VARCHAR2,
	x_enable_ship_schedule_flag		VARCHAR2,
	x_plan_schedule_type			VARCHAR2,
	x_ship_schedule_type			VARCHAR2,
	x_plan_bucket_pattern_id		NUMBER,
	x_ship_bucket_pattern_id		NUMBER,
	x_enable_autoschedule_flag		VARCHAR2,
	x_scheduler_id				NUMBER,
	x_enable_authorizations_flag		VARCHAR2,
	x_vendor_id				NUMBER,
	x_vendor_site_id			NUMBER,
	x_item_id				NUMBER,
	x_category_id				NUMBER,
	x_attribute_category	  		VARCHAR2,
	x_attribute1		  		VARCHAR2,
	x_attribute2		  		VARCHAR2,
	x_attribute3		  		VARCHAR2,
	x_attribute4		  		VARCHAR2,
	x_attribute5		  		VARCHAR2,
	x_attribute6		  		VARCHAR2,
	x_attribute7		  		VARCHAR2,
	x_attribute8		  		VARCHAR2,
	x_attribute9		  		VARCHAR2,
	x_attribute10		  		VARCHAR2,
	x_attribute11		  		VARCHAR2,
	x_attribute12		  		VARCHAR2,
	x_attribute13		  		VARCHAR2,
	x_attribute14		  		VARCHAR2,
	x_attribute15		  		VARCHAR2,
	x_last_update_login	  		NUMBER,
        x_price_update_tolerance                NUMBER,
        x_processing_lead_time                  NUMBER,
        x_delivery_calendar                     VARCHAR2,
        x_min_order_qty                         NUMBER,
        x_fixed_lot_multiple                    NUMBER,
        x_country_of_origin_code                VARCHAR2,
  /* VMI FPH START */
        x_enable_vmi_flag                       VARCHAR2,
        x_vmi_min_qty                           NUMBER,
        x_vmi_max_qty                           NUMBER,
        x_enable_vmi_auto_repl_flag             VARCHAR2,
        x_vmi_replenishment_approval            VARCHAR2,
  /* VMI FPH END */
  /* CONSSUP FPI START */
        x_consigned_from_supplier_flag          VARCHAR2,
        x_consigned_billing_cycle               NUMBER ,
        x_last_billing_date                     DATE,
  /* CONSSUP FPI END */
/*FPJ START*/
        x_replenishment_method                  NUMBER,
        x_vmi_min_days                          NUMBER,
        x_vmi_max_days                          NUMBER,
        x_fixed_order_quantity                  NUMBER,
        x_forecast_horizon                      NUMBER,
        x_consume_on_aging_flag                 VARCHAR2,
        x_aging_period                          NUMBER
/*FPJ END*/
) is



  cursor row_id is 	SELECT rowid
			FROM   PO_ASL_ATTRIBUTES
    		   	WHERE  x_asl_id = asl_id
			AND    x_using_organization_id = using_organization_id;

begin

    INSERT INTO PO_ASL_ATTRIBUTES(
	asl_id		  		,
	using_organization_id   	,
	last_update_date		,
	last_updated_by	  		,
	creation_date			,
	created_by			,
	document_sourcing_method	,
	release_generation_method	,
	purchasing_unit_of_measure	,
	enable_plan_schedule_flag	,
	enable_ship_schedule_flag	,
	plan_schedule_type		,
	ship_schedule_type		,
	plan_bucket_pattern_id		,
	ship_bucket_pattern_id		,
	enable_autoschedule_flag	,
	scheduler_id			,
	enable_authorizations_flag	,
	vendor_id			,
	vendor_site_id			,
	item_id				,
	category_id			,
	attribute_category		,
	attribute1			,
	attribute2			,
	attribute3			,
	attribute4			,
	attribute5			,
	attribute6			,
	attribute7			,
	attribute8			,
	attribute9			,
	attribute10			,
	attribute11			,
	attribute12			,
	attribute13			,
	attribute14			,
	attribute15			,
	last_update_login               ,
        price_update_tolerance          ,
        processing_lead_time            ,
        delivery_calendar               ,
        min_order_qty                   ,
        fixed_lot_multiple              ,
        country_of_origin_code          ,
  /* VMI FPH START */
        enable_vmi_flag                 ,
        vmi_min_qty                     ,
        vmi_max_qty                     ,
        enable_vmi_auto_replenish_flag  ,
        vmi_replenishment_approval      ,
 /* VMI FPH END */
 /* CONSSUP FPI START */
        consigned_from_supplier_flag    ,
        consigned_billing_cycle         ,
        last_billing_date               ,
/* CONSSUP FPI END */
/*FPJ START */
        replenishment_method            ,
        vmi_min_days                    ,
        vmi_max_days                    ,
        fixed_order_quantity            ,
        forecast_horizon                ,
        consume_on_aging_flag           ,
        aging_period
/*FPJ END*/
     )  VALUES 			(
	x_asl_id		  	,
	x_using_organization_id  	,
	x_last_update_date	  	,
	x_last_updated_by	 	,
	x_creation_date		  	,
	x_created_by		  	,
	x_document_sourcing_method	,
	x_release_generation_method	,
	x_purchasing_unit_of_measure	,
	x_enable_plan_schedule_flag	,
	x_enable_ship_schedule_flag	,
	x_plan_schedule_type	  	,
	x_ship_schedule_type	  	,
	x_plan_bucket_pattern_id  	,
	x_ship_bucket_pattern_id  	,
	x_enable_autoschedule_flag	,
	x_scheduler_id		  	,
	x_enable_authorizations_flag	,
	x_vendor_id			,
	x_vendor_site_id		,
	x_item_id			,
	x_category_id			,
	x_attribute_category	  	,
	x_attribute1		  	,
	x_attribute2		  	,
	x_attribute3		  	,
	x_attribute4		  	,
	x_attribute5		  	,
	x_attribute6		  	,
	x_attribute7		  	,
	x_attribute8		  	,
	x_attribute9		  	,
	x_attribute10		  	,
	x_attribute11		  	,
	x_attribute12		  	,
	x_attribute13		  	,
	x_attribute14		  	,
	x_attribute15		  	,
	x_last_update_login	        ,
        x_price_update_tolerance        ,
        x_processing_lead_time          ,
        x_delivery_calendar             ,
        x_min_order_qty                 ,
        x_fixed_lot_multiple            ,
        x_country_of_origin_code        ,
/* VMI FPH START */
        x_enable_vmi_flag               ,
        x_vmi_min_qty                   ,
        x_vmi_max_qty                   ,
        x_enable_vmi_auto_repl_flag     ,
        x_vmi_replenishment_approval    ,
/* VMI FPH END */
/* CONSSUP FPI START */
        x_consigned_from_supplier_flag  ,
        x_consigned_billing_cycle       ,
        x_last_billing_date             ,
/* CONSSUP FPI END */
/*FPJ START*/
        x_replenishment_method          ,
        x_vmi_min_days                  ,
        x_vmi_max_days                  ,
        x_fixed_order_quantity          ,
        x_forecast_horizon              ,
        x_consume_on_aging_flag         ,
        x_aging_period
/*FPJ END*/
	);


  OPEN row_id;
  FETCH row_id INTO x_row_id;
  if (row_id%notfound) then
    CLOSE row_id;
    raise no_data_found;
  end if;
  CLOSE row_id;

end insert_row;

END PO_ASL_ATTRIBUTES_THS;

/
