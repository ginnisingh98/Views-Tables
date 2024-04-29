--------------------------------------------------------
--  DDL for Package Body PO_ASL_DOCUMENTS_THS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_DOCUMENTS_THS1" as
/* $Header: POXAALSB.pls 115.0 99/07/17 01:34:42 porting ship $ */

/*=============================================================================

  PROCEDURE NAME:	update_row()

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
	x_last_update_login	  		NUMBER) is
begin


    UPDATE PO_ASL_DOCUMENTS
    SET
	asl_id			   = x_asl_id				,
	using_organization_id      = x_using_organization_id		,
	sequence_num		   = x_sequence_num			,
	document_type_code	   = x_document_type_code		,
	document_header_id	   = x_document_header_id		,
	document_line_id	   = x_document_line_id			,
	last_update_date	   = x_last_update_date			,
	last_updated_by	  	   = x_last_updated_by			,
	creation_date		   = x_creation_date			,
	created_by		   = x_created_by			,
	attribute_category	   = x_attribute_category		,
	attribute1		   = x_attribute1			,
	attribute2		   = x_attribute2			,
	attribute3		   = x_attribute3			,
	attribute4		   = x_attribute4			,
	attribute5		   = x_attribute5			,
	attribute6		   = x_attribute6			,
	attribute7		   = x_attribute7			,
	attribute8		   = x_attribute8			,
	attribute9		   = x_attribute9			,
	attribute10		   = x_attribute10			,
	attribute11		   = x_attribute11			,
	attribute12		   = x_attribute12			,
	attribute13		   = x_attribute13			,
	attribute14		   = x_attribute14			,
	attribute15		   = x_attribute15			,
	last_update_login	   = x_last_update_login
     WHERE rowid = x_row_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end update_row;

END PO_ASL_DOCUMENTS_THS1;

/
