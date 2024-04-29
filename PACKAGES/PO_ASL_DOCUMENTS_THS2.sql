--------------------------------------------------------
--  DDL for Package PO_ASL_DOCUMENTS_THS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_DOCUMENTS_THS2" AUTHID CURRENT_USER as
/* $Header: POXABLSS.pls 120.0.12010000.1 2008/09/18 12:20:41 appldev noship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_documents_ths2

  DESCRIPTION:		Table handlers for PO_ASL_DOCUMENTS - part 3

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	lock_row()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	lock_row


  DESCRIPTION:     	Lock table handler for PO_ASL_DOCUMENTS


  CHANGE HISTORY:  	28-May-96	lbroadbe	Created

=============================================================================*/
procedure lock_row(
	x_row_id		  		VARCHAR2,
	x_asl_id		  		NUMBER,
	x_using_organization_id   		NUMBER,
	x_sequence_num				NUMBER,
	x_document_type_code			VARCHAR2,
	x_document_header_id			NUMBER,
	x_document_line_id			NUMBER,
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
	x_attribute15		  		VARCHAR2);

END PO_ASL_DOCUMENTS_THS2;

/
