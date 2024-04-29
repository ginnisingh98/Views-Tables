--------------------------------------------------------
--  DDL for Package Body PO_ASL_DOCUMENTS_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_DOCUMENTS_THS" as
/* $Header: POXA9LSB.pls 120.1 2007/12/12 09:05:26 irasoolm ship $ */

/*=============================================================================

  PROCEDURE NAME:	insert_row()

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
	x_record_status				VARCHAR2) is   --bug 6504696

  x_record_unique	boolean;

  cursor row_id is 	SELECT rowid
			FROM   PO_ASL_DOCUMENTS
    		   	WHERE  x_asl_id = asl_id
			AND    x_using_organization_id = using_organization_id
			AND    x_sequence_num = sequence_num;

begin

    -- Check for duplicate sequence numbers for this asl_id
    -- and using_organization_id.  The uniqueness constraint
    -- on document_header_id is enforced by a unique index.

    x_record_unique := po_asl_documents_sv.check_record_unique(x_asl_id,
			     x_using_organization_id,
			     x_sequence_num,
			     x_document_header_id,
			     x_record_status);  --bug 6504696

    IF NOT x_record_unique THEN

	fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX'); --<BUG 3486101>
        app_exception.raise_exception;

    END IF;

    INSERT INTO PO_ASL_DOCUMENTS(
	asl_id		  		,
	using_organization_id   	,
	sequence_num			,
	document_type_code		,
	document_header_id		,
	document_line_id		,
	last_update_date		,
	last_updated_by	  		,
	creation_date			,
	created_by			,
	attribute_category		,
	attribute1			,
	attribute2			,
	attribute3			,
	attribute4			,
	attribute5			,
	attribute6			,
	attribute7			,
	attribute8			,
	attribute9			,
	attribute10			,
	attribute11			,
	attribute12			,
	attribute13			,
	attribute14			,
	attribute15			,
	last_update_login
     )  VALUES 			(
	x_asl_id		  	,
	x_using_organization_id  	,
	x_sequence_num			,
	x_document_type_code		,
	x_document_header_id		,
	x_document_line_id		,
	x_last_update_date	  	,
	x_last_updated_by	 	,
	x_creation_date		  	,
	x_created_by		  	,
	x_attribute_category	  	,
	x_attribute1		  	,
	x_attribute2		  	,
	x_attribute3		  	,
	x_attribute4		  	,
	x_attribute5		  	,
	x_attribute6		  	,
	x_attribute7		  	,
	x_attribute8		  	,
	x_attribute9		  	,
	x_attribute10		  	,
	x_attribute11		  	,
	x_attribute12		  	,
	x_attribute13		  	,
	x_attribute14		  	,
	x_attribute15		  	,
	x_last_update_login
	);

  OPEN row_id;
  FETCH row_id INTO x_row_id;
  if (row_id%notfound) then
    CLOSE row_id;
    raise no_data_found;
  end if;
  CLOSE row_id;

end insert_row;

END PO_ASL_DOCUMENTS_THS;

/
