--------------------------------------------------------
--  DDL for Package Body PA_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IMP" AS
/* $Header: PAIMPB.pls 115.0 99/07/16 15:07:10 porting ship $ */
    /*
    NAME
      pa_implemented
    DESCRIPTION
      Returns TRUE if PA is implemented.
  */
  --
  FUNCTION pa_implemented RETURN BOOLEAN IS
  BEGIN
	DECLARE
		result number default 0;
	BEGIN

		SELECT 1
		  INTO result
		  FROM pa_implementations;

		IF (result = 1) THEN
		   RETURN (TRUE);
		ELSE
		   RETURN (FALSE);
		END IF;

		EXCEPTION
		   WHEN OTHERS THEN
		     RETURN (FALSE);
	END;
  END pa_implemented;

  FUNCTION pa_implemented_all RETURN BOOLEAN IS
  BEGIN
	DECLARE
		result number default 0;
	BEGIN

		SELECT 1
	        INTO result
	        FROM pa_implementations_all
                WHERE rownum=1;

		IF (result = 1) THEN
		   RETURN (TRUE);
		ELSE
		   RETURN (FALSE);
		END IF;

		EXCEPTION
		   WHEN OTHERS THEN
		     RETURN (FALSE);
	END;
  END pa_implemented_all;
END pa_imp;

/
