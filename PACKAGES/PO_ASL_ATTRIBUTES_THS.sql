--------------------------------------------------------
--  DDL for Package PO_ASL_ATTRIBUTES_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_ATTRIBUTES_THS" AUTHID CURRENT_USER as
/* $Header: POXA5LSS.pls 115.8 2003/08/21 09:38:45 tmanda ship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_attributes_ths

  DESCRIPTION:		Table Handlers for PO_ASL_ATTRIBUTES - Part 1

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	insert_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	insert_row


  DESCRIPTION:     	Insert table handler for PO_ASL_ATTRIBUTES


  CHANGE HISTORY:  	28-May-96	lbroadbe	Created

===============================================================================*/
procedure insert_row(
	x_row_id		  IN OUT NOCOPY 	VARCHAR2,
	x_asl_id				NUMBER,
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
);

END PO_ASL_ATTRIBUTES_THS;

 

/
