--------------------------------------------------------
--  DDL for Package Body PA_PAPWPRIREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAPWPRIREP_XMLP_PKG" AS
--  $Header: PAPWPREPB.pls 120.0.12010000.3 2010/03/02 12:36:37 jjgeorge noship $

FUNCTION GET_COMPANY_NAME RETURN VARCHAR2 IS
    COMPANY_NAME_HEADER VARCHAR2(50);
  BEGIN
    SELECT
      SUBSTR(GL.NAME,1,50)
    INTO COMPANY_NAME_HEADER
    FROM
      GL_SETS_OF_BOOKS GL,
      PA_IMPLEMENTATIONS PI
    WHERE GL.SET_OF_BOOKS_ID = PI.SET_OF_BOOKS_ID;

  RETURN COMPANY_NAME_HEADER;

  END GET_COMPANY_NAME;

/* This function  cleans up the table if the process is run in DRAFT mode*/

FUNCTION CLEANUP
RETURN BOOLEAN
IS
pb BOOLEAN  := TRUE;
BEGIN
If P_MODE = 'DRAFT' THEN

   BEGIN
      delete from  PA_PWP_RELEASE_REPORT where  request_id = P_REQUEST_ID ;
   EXCEPTION
     WHEN OTHERS THEN
	 null;
	END;

END IF;
RETURN pb;
END CLEANUP;


END PA_PAPWPRIREP_XMLP_PKG;

/