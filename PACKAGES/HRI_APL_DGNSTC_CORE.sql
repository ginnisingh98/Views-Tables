--------------------------------------------------------
--  DDL for Package HRI_APL_DGNSTC_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_DGNSTC_CORE" AUTHID CURRENT_USER AS
/* $Header: hriadgcr.pkh 120.1 2005/10/28 07:41:00 jtitmas noship $ */

FUNCTION get_ff_check_sql
     RETURN VARCHAR2;

FUNCTION get_ff_check_all_sql
     RETURN VARCHAR2;

FUNCTION get_alert_sql
     RETURN VARCHAR2;

END hri_apl_dgnstc_core;

 

/
