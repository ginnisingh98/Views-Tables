--------------------------------------------------------
--  DDL for Package Body PO_DAILY_CONVERSION_TYPES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DAILY_CONVERSION_TYPES_SV1" AS
/* $Header: POXPIRTB.pls 120.1.12010000.1 2008/09/18 12:20:49 appldev noship $ */

/*===============================================================

   FUNCTION NAME : val_rate_type_code()

================================================================*/
 FUNCTION val_rate_type_code( x_rate_type_code  IN VARCHAR2)

 RETURN BOOLEAN IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer;

 BEGIN
   x_progress  := '010';

   /* check to see if the given rate_type_code is a valid on in
      gl_daily_conversion_types_v view */

   SELECT count(*)
     INTO x_temp
     FROM gl_daily_conversion_types_v
    WHERE conversion_type = x_rate_type_code;

   IF x_temp = 0 THEN
      RETURN FALSE;    /* validation fails */
   ELSE
      RETURN TRUE;     /* validation succeeds */
   END IF;

EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_rate_type_code', x_progress, sqlcode);
        raise;
END val_rate_type_code;


/*====================================================================

    FUNCTION NAME : derive_rate_type_code()

====================================================================*/

FUNCTION  derive_rate_type_code(X_rate_type IN VARCHAR2)
return VARCHAR2 IS

   X_progress       varchar2(3)     := NULL;
   X_rate_type_v    varchar2(30)    := NULL;

BEGIN

   X_progress := '010';

   /* get the rate_type_code from gl_daily_conversion_types table
      based on the rate_type value provided from input parameter */

   SELECT	 conversion_type
   INTO		 X_rate_type_v
   FROM		 gl_daily_conversion_types
   WHERE	 user_conversion_type = X_rate_type;

   RETURN X_rate_type_v;

EXCEPTION

   WHEN no_data_found THEN
        RETURN NULL;
   WHEN others THEN
        po_message_s.sql_error('derive_rate_type_code',X_progress, sqlcode);
        raise;

END derive_rate_type_code;



END PO_DAILY_CONVERSION_TYPES_SV1;

/
