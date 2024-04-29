--------------------------------------------------------
--  DDL for Package PO_ASL_THS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_THS2" AUTHID CURRENT_USER as
/* $Header: POXA4LSS.pls 115.1 99/07/17 01:33:57 porting sh $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_ths2

  DESCRIPTION:		Table handlers for PO_APPROVED_SUPPLIER_LIST - part 3

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	lock_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	lock_row


  DESCRIPTION:     	Lock table handler for PO_APPROVED_SUPPLIER_LIST


  CHANGE HISTORY:  	20-May-96	lbroadbe	Created

===============================================================================*/
procedure lock_row(
	x_row_id		  	 	VARCHAR2,
	x_asl_id		 		NUMBER,
	x_using_organization_id   		NUMBER,
	x_owning_organization_id  		NUMBER,
	x_vendor_business_type	  		VARCHAR2,
	x_asl_status_id		  		NUMBER,
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
        x_disable_flag                          VARCHAR2);

END PO_ASL_THS2;

 

/
