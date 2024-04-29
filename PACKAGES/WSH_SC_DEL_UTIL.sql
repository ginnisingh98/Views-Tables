--------------------------------------------------------
--  DDL for Package WSH_SC_DEL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_DEL_UTIL" AUTHID CURRENT_USER AS
/* $Header: WSHSDUTS.pls 115.1 99/07/16 08:21:40 porting ship $ */

-------------------------------------------------------------------
-- WSH_SC_DEL_UTIL
-- Purpose
--       Execute Mass Change
-- History
--      05-MAR-98 mgunawar Created
--
-------------------------------------------------------------------

PROCEDURE EXEC_MASS_CHANGE(statement in varchar2, records_updated in out number);
FUNCTION Request_Id return NUMBER;

END WSH_SC_DEL_UTIL;

 

/
