--------------------------------------------------------
--  DDL for Package PO_ASL_DOCUMENTS_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_DOCUMENTS_THS" AUTHID CURRENT_USER as
/* $Header: POXA9LSS.pls 120.1 2007/12/12 09:03:26 irasoolm ship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_documents_ths

  DESCRIPTION:		Table Handlers for PO_ASL_DOCUMENTS - Part 1

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	insert_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	insert_row


  DESCRIPTION:     	Insert table handler for PO_ASL_DOCUMENTS


  CHANGE HISTORY:  	28-May-96	lbroadbe	Created

===============================================================================*/
procedure insert_row(
	x_row_id		  IN OUT NOCOPY 	VARCHAR2,
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
	x_last_update_login	  		NUMBER,
	x_record_status				VARCHAR2);  --bug 6504696

END PO_ASL_DOCUMENTS_THS;

/
