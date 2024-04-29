--------------------------------------------------------
--  DDL for Package PO_ASL_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_THS" AUTHID CURRENT_USER as
/* $Header: POXA2LSS.pls 115.3 2002/11/23 03:37:41 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_ths

  DESCRIPTION:		Table Handlers for PO_APPROVED_SUPPLIER_LIST - Part 1

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	insert_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	insert_row


  DESCRIPTION:     	Insert table handler for PO_APPROVED_SUPPLIER_LIST


  CHANGE HISTORY:  	20-May-96	lbroadbe	Created

===============================================================================*/
procedure insert_row(
	x_row_id		  IN OUT NOCOPY 	VARCHAR2,
	x_asl_id		  IN OUT	NOCOPY NUMBER,
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

END PO_ASL_THS;

 

/
