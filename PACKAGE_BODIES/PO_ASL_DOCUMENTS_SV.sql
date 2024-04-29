--------------------------------------------------------
--  DDL for Package Body PO_ASL_DOCUMENTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_DOCUMENTS_SV" as
/* $Header: POXA8LSB.pls 120.1 2007/12/12 09:00:45 irasoolm noship $ */

/*=============================================================================

  FUNCTION NAME:	check_record_unique

=============================================================================*/
function check_record_unique(x_asl_id	   		number,
			     x_using_organization_id	number,
			     x_sequence_num             number,
			     x_document_header_id	number,
			     x_record_status 		varchar2) return boolean is --bug 6504696

    x_dummy_count	NUMBER := 0;

begin

    -- Check for duplicate sequence numbers for this asl_id
    -- and using_organization_id.  The uniqueness constraint
    -- on document_header_id is enforced by a unique index.

    SELECT count(1)
    INTO   x_dummy_count
    FROM   PO_ASL_DOCUMENTS
    WHERE  x_asl_id = asl_id
    AND    x_using_organization_id = using_organization_id
    AND   (x_sequence_num = sequence_num
        OR x_document_header_id = document_header_id);

    -- IF x_dummy_count > 0 THEN
    -- bug 6504696
    -- Modified the below if statement such that to return false if existing records get modified with duplicated values
    -- or new records with the duplicated values
    IF (x_dummy_count > 0 AND x_record_status = 'INSERT') OR (x_dummy_count > 1 AND x_record_status <> 'INSERT') THEN
	return(FALSE);
    ELSE
	return(TRUE);
    END IF;

exception
    when others then
        raise;
end;

END PO_ASL_DOCUMENTS_SV;

/
