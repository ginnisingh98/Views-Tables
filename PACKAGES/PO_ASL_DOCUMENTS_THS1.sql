--------------------------------------------------------
--  DDL for Package PO_ASL_DOCUMENTS_THS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_DOCUMENTS_THS1" AUTHID CURRENT_USER as
/* $Header: POXAALSS.pls 115.0 99/07/17 01:34:46 porting ship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_documents_th1

  DESCRIPTION:		Table handlers for PO_ASL_DOCUMENTS - part 2

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	update_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	update_row


  DESCRIPTION:     	Update table handler for PO_ASL_DOCUMENTS


  CHANGE HISTORY:  	28-May-96	lbroadbe	Created

===============================================================================*/
procedure update_row(
	x_row_id		  		VARCHAR2,
	x_asl_id		  		NUMBER,
	x_using_organization_id   		NUMBER,
	x_sequence_num				NUMBER,
	x_document_type_code			VARCHAR2,
	x_document_header_id			NUMBER,
	x_document_line_id			NUMBER,
	x_last_update_date	  		DATE,
	x_last_updated_by	  		NUMBER,
	x_creation_date		  		DATE,
	x_created_by		  		NUMBER,
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
	x_last_update_login	  		NUMBER);

END PO_ASL_DOCUMENTS_THS1;

 

/
