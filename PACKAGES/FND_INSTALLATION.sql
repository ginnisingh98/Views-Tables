--------------------------------------------------------
--  DDL for Package FND_INSTALLATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_INSTALLATION" AUTHID DEFINER AS
/* $Header: AFINSTLS.pls 120.2.12010000.3 2012/06/21 17:44:53 jvalenti ship $ */


    --
    --  The get() function no longer uses the appl_id argument
    --
    --  It calls private_get(), which gets the information for you
    --  based solely on the dep_appl_id and the current schema
    --
    --  get() may return different information with the same arguments
    --  if you connect to a different schema
    --
  FUNCTION get (appl_id     IN  INTEGER,
                dep_appl_id IN  INTEGER,
                status      OUT NOCOPY VARCHAR2,
                industry    OUT NOCOPY VARCHAR2)
  RETURN boolean;
  PRAGMA RESTRICT_REFERENCES (get, WNDS,WNPS);

    --
    -- get_app_info() may return different information if you call it
    -- from a different schema
    -- See notes on get() above
    --
  FUNCTION get_app_info  (application_short_name	in  varchar2,
  			status			out nocopy varchar2,
  			industry		out nocopy varchar2,
  			oracle_schema		out nocopy varchar2)
  RETURN boolean;
  PRAGMA RESTRICT_REFERENCES (get_app_info, WNDS,WNPS);

    --
    -- get_app_info_other() will return consistent information every time
    -- you call it, because it ignores the current schema and uses
    -- the target_schema argument instead
    --
  FUNCTION get_app_info_other  (application_short_name	in  varchar2,
  			target_schema		in  varchar2,
  			status			out nocopy varchar2,
  			industry		out nocopy varchar2,
  			oracle_schema		out nocopy varchar2)
  RETURN boolean;
  PRAGMA RESTRICT_REFERENCES (get_app_info_other, WNDS,WNPS);

END FND_INSTALLATION;

/

  GRANT EXECUTE ON "APPS"."FND_INSTALLATION" TO "AMV";
