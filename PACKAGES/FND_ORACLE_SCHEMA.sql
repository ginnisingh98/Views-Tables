--------------------------------------------------------
--  DDL for Package FND_ORACLE_SCHEMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ORACLE_SCHEMA" AUTHID CURRENT_USER AS
/* $Header: AFSCSHMS.pls 120.1 2005/07/02 04:16:41 appldev ship $ */



function GetOuValue (
  x_lookup_code in varchar2
) return varchar2;

function GetOpValue (
  schema_name in varchar2,
  applsyspwd in varchar2
) return varchar2;

END FND_ORACLE_SCHEMA;

 

/

  GRANT EXECUTE ON "APPS"."FND_ORACLE_SCHEMA" TO "EM_OAM_MONITOR_ROLE";
