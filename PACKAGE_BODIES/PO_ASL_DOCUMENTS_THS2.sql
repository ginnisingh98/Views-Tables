--------------------------------------------------------
--  DDL for Package Body PO_ASL_DOCUMENTS_THS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_DOCUMENTS_THS2" as
/* $Header: POXABLSB.pls 115.2 2003/10/29 09:45:44 zxzhang ship $ */

/*=============================================================================

  PROCEDURE NAME:	lock_row()

===============================================================================*/
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
	x_attribute15		  		VARCHAR2) is

  cursor asl_row is	SELECT *
			FROM   po_asl_documents
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
	AND	(recinfo.sequence_num = x_sequence_num)
	AND	(recinfo.document_type_code = x_document_type_code)
	AND	(recinfo.document_header_id = x_document_header_id)
        -- <FPJ Advanced Price START>
	AND	((recinfo.document_line_id = x_document_line_id) OR
		 ((recinfo.document_line_id is null) AND
		  (x_document_line_id is null)))
        -- <FPJ Advanced Price END>
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
  ) then
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;


end lock_row;

END PO_ASL_DOCUMENTS_THS2;

/
