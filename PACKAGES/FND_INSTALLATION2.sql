--------------------------------------------------------
--  DDL for Package FND_INSTALLATION2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_INSTALLATION2" AUTHID CURRENT_USER AS
/* $Header: AFINST2S.pls 115.1 99/07/16 23:23:01 porting sh $ */

  FUNCTION get (appl_id     IN  INTEGER,
                dep_appl_id IN  INTEGER,
                status      OUT VARCHAR2,
                industry    OUT VARCHAR2)
  RETURN varchar2;
  PRAGMA RESTRICT_REFERENCES (get, WNDS,WNPS);

--
-- GET() returns the varchar2 version of either 'TRUE' or 'FALSE' now,
-- instead of boolean TRUE or FALSE (fix to bug 568525)
--

  FUNCTION get_app_info  (application_short_name	in  varchar2,
  			status			out varchar2,
  			industry		out varchar2,
  			oracle_schema		out varchar2)
  RETURN boolean;
  PRAGMA RESTRICT_REFERENCES (get_app_info, WNDS,WNPS);

  FUNCTION get_app_info_other  (application_short_name	in  varchar2,
  			target_schema		in  varchar2,
  			status			out varchar2,
  			industry		out varchar2,
  			oracle_schema		out varchar2)
  RETURN boolean;
  PRAGMA RESTRICT_REFERENCES (get_app_info_other, WNDS,WNPS);

END FND_INSTALLATION2;

 

/
