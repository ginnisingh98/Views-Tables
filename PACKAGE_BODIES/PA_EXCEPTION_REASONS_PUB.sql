--------------------------------------------------------
--  DDL for Package Body PA_EXCEPTION_REASONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXCEPTION_REASONS_PUB" AS
/* $Header: PAXEXPRB.pls 115.0 99/07/16 15:24:06 porting ship $ */

FUNCTION get_exception_text
     (x_exception_type		IN	VARCHAR2,
      x_exception_code		IN	VARCHAR2,
      x_exception_reason	IN	VARCHAR2,
      x_return_type		IN	VARCHAR2)
      RETURN VARCHAR2 IS

ls_exception_text	VARCHAR2(200);
BEGIN

--  If a reason is already there in the table (the reason text is there and not a code)
--  and if a reason is being requested, then nothing has to be done

	IF x_return_type = 'R' and x_exception_reason is not null
	THEN
		return x_exception_reason;
	END IF;

-- If a reason is there, join to get the corrective action.  If the reason is not
-- there, then join with the code to get a corrective action.  If both are not
-- specified, then return undefined

		SELECT decode(x_return_type, 'R', exception_reason, corrective_action)
		  INTO ls_exception_text
		  FROM pa_exception_reasons
		 WHERE decode(x_exception_reason, null, x_exception_code, x_exception_reason) =
		       decode(x_exception_reason, null, exception_code, exception_reason)
		   AND x_exception_type = pa_exception_reasons.exception_category;

		return ls_exception_text;

	  EXCEPTION
		WHEN NO_DATA_FOUND
		THEN
			SELECT decode(x_return_type, 'R', exception_reason, corrective_action)
			 INTO  ls_exception_text
			 FROM  pa_exception_reasons
			WHERE  exception_category = 'UNDEFINED'
			  AND  exception_code 	  = 'UNDEFINED';
		 return ls_exception_text;

END get_exception_text;

END PA_EXCEPTION_REASONS_PUB;

/
