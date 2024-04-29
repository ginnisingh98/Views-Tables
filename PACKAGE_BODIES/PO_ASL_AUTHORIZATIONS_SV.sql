--------------------------------------------------------
--  DDL for Package Body PO_ASL_AUTHORIZATIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_AUTHORIZATIONS_SV" as
/* $Header: POXACLSB.pls 120.0.12010000.1 2008/09/18 12:20:52 appldev noship $ */

/*=============================================================================

  FUNCTION NAME:	check_record_unique

=============================================================================*/
function check_record_unique(x_reference_id	   	number,
			     x_reference_type		varchar2,
			     x_authorization_code	varchar2,
			     x_authorization_sequence   number,
			     x_using_organization_id    number) return boolean is

    x_dummy_count	NUMBER := 0;

begin

    -- Check for duplicate sequence number for the current reference
    -- number and type.  Also check for duplicate authorization
    -- code.

    SELECT count(*)
    INTO   x_dummy_count
    FROM   CHV_AUTHORIZATIONS
    WHERE  x_reference_id = reference_id
    AND    x_reference_type = reference_type
    AND    x_using_organization_id = using_organization_id
    AND   (x_authorization_code = authorization_code
       OR  x_authorization_sequence = authorization_sequence);

    IF x_dummy_count > 0 THEN
	return(FALSE);
    ELSE
	return(TRUE);
    END IF;

exception
    when others then
        raise;
end;

END PO_ASL_AUTHORIZATIONS_SV;

/
