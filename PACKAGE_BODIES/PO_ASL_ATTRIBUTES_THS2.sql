--------------------------------------------------------
--  DDL for Package Body PO_ASL_ATTRIBUTES_THS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_ATTRIBUTES_THS2" as
/* $Header: POXA7LSB.pls 115.8 2003/08/21 09:42:49 tmanda ship $ */

/*=============================================================================

  PROCEDURE NAME:	lock_row()

===============================================================================*/
procedure lock_row(
	x_row_id		  	 	VARCHAR2,
	x_asl_id		  		NUMBER,
	x_using_organization_id   		NUMBER,
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
)  is


  cursor asl_row is	SELECT *
			FROM   po_asl_attributes
			WHERE  rowid = x_row_id
			FOR UPDATE of asl_id NOWAIT;

  recinfo asl_row%rowtype;

begin

  OPEN asl_row;
  FETCH asl_row INTO recinfo;
  if (asl_row%notfound) then
    CLOSE asl_row;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  CLOSE asl_row;

  if (
		(recinfo.asl_id = x_asl_id)
	AND	(recinfo.using_organization_id = x_using_organization_id)
	AND	((recinfo.document_sourcing_method = x_document_sourcing_method) OR
		 ((recinfo.document_sourcing_method is null) AND
		  (x_document_sourcing_method is null)))
	AND	((recinfo.release_generation_method = x_release_generation_method) OR
		 ((recinfo.release_generation_method is null) AND
		  (x_release_generation_method is null)))
	AND	((recinfo.purchasing_unit_of_measure = x_purchasing_unit_of_measure) OR
		 ((recinfo.purchasing_unit_of_measure is null) AND
		  (x_purchasing_unit_of_measure is null)))
	AND	((recinfo.enable_plan_schedule_flag = x_enable_plan_schedule_flag) OR
		 ((recinfo.enable_plan_schedule_flag is null) AND
		  (x_enable_plan_schedule_flag is null)))
	AND	((recinfo.enable_ship_schedule_flag = x_enable_ship_schedule_flag) OR
		 ((recinfo.enable_ship_schedule_flag is null) AND
		  (x_enable_ship_schedule_flag is null)))
	AND	((recinfo.plan_schedule_type = x_plan_schedule_type) OR
		 ((recinfo.plan_schedule_type is null) AND
		  (x_plan_schedule_type is null)))
	AND	((recinfo.ship_schedule_type = x_ship_schedule_type) OR
		 ((recinfo.ship_schedule_type is null) AND
		  (x_ship_schedule_type is null)))
	AND	((recinfo.plan_bucket_pattern_id = x_plan_bucket_pattern_id) OR
		 ((recinfo.plan_bucket_pattern_id is null) AND
		  (x_plan_bucket_pattern_id is null)))
	AND	((recinfo.ship_bucket_pattern_id = x_ship_bucket_pattern_id) OR
		 ((recinfo.ship_bucket_pattern_id is null) AND
		  (x_ship_bucket_pattern_id is null)))
	AND	((recinfo.enable_autoschedule_flag = x_enable_autoschedule_flag) OR
		 ((recinfo.enable_autoschedule_flag is null) AND
		  (x_enable_autoschedule_flag is null)))
	AND	((recinfo.scheduler_id = x_scheduler_id) OR
		 ((recinfo.scheduler_id is null) AND
		  (x_scheduler_id is null)))
	AND	((recinfo.enable_authorizations_flag = x_enable_authorizations_flag) OR
		 ((recinfo.enable_authorizations_flag is null) AND
		  (x_enable_authorizations_flag is null)))
	AND	((recinfo.vendor_id = x_vendor_id) OR
		 ((recinfo.vendor_id is null) AND
		  (x_vendor_id is null)))
	AND	((recinfo.vendor_site_id = x_vendor_site_id) OR
		 ((recinfo.vendor_site_id is null) AND
		  (x_vendor_site_id is null)))
	AND	((recinfo.item_id = x_item_id) OR
		 ((recinfo.item_id is null) AND
		  (x_item_id is null)))
	AND	((recinfo.category_id = x_category_id) OR
		 ((recinfo.category_id is null) AND
		  (x_category_id is null)))
	AND	((recinfo.attribute_category = x_attribute_category) OR
		 ((recinfo.attribute_category is null) AND
		  (x_attribute_category is null)))
	AND	((recinfo.attribute1 = x_attribute1) OR
		 ((recinfo.attribute1 is null) AND
		  (x_attribute1 is null)))
	AND	((recinfo.attribute2 = x_attribute2) OR
		 ((recinfo.attribute2 is null) AND
		  (x_attribute2 is null)))
	AND	((recinfo.attribute3 = x_attribute3) OR
		 ((recinfo.attribute3 is null) AND
		  (x_attribute3 is null)))
	AND	((recinfo.attribute4 = x_attribute4) OR
		 ((recinfo.attribute4 is null) AND
		  (x_attribute4 is null)))
	AND	((recinfo.attribute5 = x_attribute5) OR
		 ((recinfo.attribute5 is null) AND
		  (x_attribute5 is null)))
	AND	((recinfo.attribute6 = x_attribute6) OR
		 ((recinfo.attribute6 is null) AND
		  (x_attribute6 is null)))
	AND	((recinfo.attribute7 = x_attribute7) OR
		 ((recinfo.attribute7 is null) AND
		  (x_attribute7 is null)))
	AND	((recinfo.attribute8 = x_attribute8) OR
		 ((recinfo.attribute8 is null) AND
		  (x_attribute8 is null)))
	AND	((recinfo.attribute9 = x_attribute9) OR
		 ((recinfo.attribute9 is null) AND
		  (x_attribute9 is null)))
	AND	((recinfo.attribute10 = x_attribute10) OR
		 ((recinfo.attribute10 is null) AND
		  (x_attribute10 is null)))
	AND	((recinfo.attribute11 = x_attribute11) OR
		 ((recinfo.attribute11 is null) AND
		  (x_attribute11 is null)))
	AND	((recinfo.attribute12 = x_attribute12) OR
		 ((recinfo.attribute12 is null) AND
		  (x_attribute12 is null)))
	AND	((recinfo.attribute13 = x_attribute13) OR
		 ((recinfo.attribute13 is null) AND
		  (x_attribute13 is null)))
	AND	((recinfo.attribute14 = x_attribute14) OR
		 ((recinfo.attribute14 is null) AND
		  (x_attribute14 is null)))
	AND	((recinfo.attribute15 = x_attribute15) OR
		 ((recinfo.attribute15 is null) AND
		  (x_attribute15 is null)))
        AND     ((recinfo.price_update_tolerance = x_price_update_tolerance) OR
                 ((recinfo.price_update_tolerance is null) AND
                  (x_price_update_tolerance is null)))
        AND     ((recinfo.processing_lead_time = x_processing_lead_time) OR
                 ((recinfo.processing_lead_time is null) AND
                  (x_processing_lead_time is null)))
        AND     ((recinfo.delivery_calendar = x_delivery_calendar) OR
                 ((recinfo.delivery_calendar is null) AND
                  (x_delivery_calendar is null)))
        AND     ((recinfo.min_order_qty = x_min_order_qty) OR
                 ((recinfo.min_order_qty is null) AND
                  (x_min_order_qty is null)))
        AND     ((recinfo.fixed_lot_multiple = x_fixed_lot_multiple) OR
                 ((recinfo.fixed_lot_multiple is null) AND
                  (x_fixed_lot_multiple is null)))
        AND     ((recinfo.country_of_origin_code = x_country_of_origin_code) OR
                 ((recinfo.country_of_origin_code is null) AND
                  (x_country_of_origin_code is null)))
  /* VMI FPH START*/
        AND     ((recinfo.enable_vmi_flag = x_enable_vmi_flag) OR
                 ((recinfo.enable_vmi_flag is null) AND
                  (x_enable_vmi_flag is null)))
        AND     ((recinfo.vmi_min_qty = x_vmi_min_qty) OR
                 ((recinfo.vmi_min_qty is null) AND
                  (x_vmi_min_qty is null)))
        AND     ((recinfo.vmi_max_qty = x_vmi_max_qty) OR
                 ((recinfo.vmi_max_qty is null) AND
                  (x_vmi_max_qty is null)))
        AND     ((recinfo.enable_vmi_auto_replenish_flag = x_enable_vmi_auto_repl_flag) OR
                 ((recinfo.enable_vmi_auto_replenish_flag is null) AND
                  (x_enable_vmi_auto_repl_flag is null)))
        AND     ((recinfo.vmi_replenishment_approval = x_vmi_replenishment_approval) OR
                 ((recinfo.vmi_replenishment_approval is null) AND
                  (x_vmi_replenishment_approval is null)))
  /* VMI FPH END*/
  /* CONSSUP FPI START */

       AND     ((recinfo.consigned_from_supplier_flag = x_consigned_from_supplier_flag) OR
                 ((recinfo.consigned_from_supplier_flag is null) AND
                  (x_consigned_from_supplier_flag is null)))
       AND     ((recinfo.consigned_billing_cycle = x_consigned_billing_cycle ) OR
                 ((recinfo.consigned_billing_cycle is null) AND
                  (x_consigned_billing_cycle is null)))
       AND     ((TRUNC(recinfo.last_billing_date) = TRUNC(x_last_billing_date)) OR
                 ((recinfo.last_billing_date is null) AND
                  (x_last_billing_date is null)))
  /* CONSSUP FPI START */
  /*FPJ START */
       AND     ((recinfo.replenishment_method = x_replenishment_method) OR
                 ((recinfo.replenishment_method is null) AND
                  (x_replenishment_method is null)))
       AND     ((recinfo.vmi_min_days = x_vmi_min_days) OR
                 ((recinfo.vmi_min_days is null) AND
                  (x_vmi_min_days is null)))
       AND     ((recinfo.vmi_max_days = x_vmi_max_days) OR
                 ((recinfo.vmi_max_days is null) AND
                  (x_vmi_max_days is null)))
       AND     ((recinfo.fixed_order_quantity = x_fixed_order_quantity) OR
                 ((recinfo.fixed_order_quantity is null) AND
                  (x_fixed_order_quantity is null)))
       AND     ((recinfo.forecast_horizon = x_forecast_horizon) OR
                 ((recinfo.forecast_horizon is null) AND
                  (x_forecast_horizon is null)))
       AND     ((recinfo.consume_on_aging_flag = x_consume_on_aging_flag) OR
                 ((recinfo.consume_on_aging_flag is null) AND
                  (x_consume_on_aging_flag is null)))
       AND     ((recinfo.aging_period = x_aging_period) OR
                 ((recinfo.aging_period is null) AND
                  (x_aging_period is null)))

  ) then


    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end lock_row;

END PO_ASL_ATTRIBUTES_THS2;

/
