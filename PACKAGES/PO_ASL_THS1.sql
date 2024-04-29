--------------------------------------------------------
--  DDL for Package PO_ASL_THS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_THS1" AUTHID CURRENT_USER as
/* $Header: POXA3LSS.pls 120.0.12010000.1 2008/09/18 12:18:28 appldev noship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_ths1

  DESCRIPTION:		Table handlers for PO_APPROVED_SUPPLIER_LIST - part 2

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	update_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	update_row


  DESCRIPTION:     	Update table handler for PO_APPROVED_SUPPLIER_LIST


  CHANGE HISTORY:  	20-May-96	lbroadbe	Created

===============================================================================*/
procedure update_row(
	x_row_id		  	 	VARCHAR2,
	x_asl_id		 		NUMBER,
	x_using_organization_id   		NUMBER,
	x_owning_organization_id  		NUMBER,
	x_vendor_business_type	  		VARCHAR2,
	x_asl_status_id		  		NUMBER,
	x_last_update_date	  		DATE,
	x_last_updated_by	  		NUMBER,
	x_creation_date		  		DATE,
	x_created_by		  		NUMBER,
	x_manufacturer_id	  		NUMBER,
	x_vendor_id		  		NUMBER,
	x_item_id		  		NUMBER,
	x_category_id		  		NUMBER,
	x_vendor_site_id	  		NUMBER,
	x_primary_vendor_item  	  		VARCHAR2,
	x_manufacturer_asl_id     		NUMBER,
	x_comments				VARCHAR2,
	x_review_by_date			DATE,
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
        x_disable_flag                          VARCHAR2);

END PO_ASL_THS1;

/
