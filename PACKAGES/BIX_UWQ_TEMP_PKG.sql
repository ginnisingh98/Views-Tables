--------------------------------------------------------
--  DDL for Package BIX_UWQ_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_UWQ_TEMP_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxuwts.pls 115.5 2003/01/10 00:14:11 achanda ship $ */

PROCEDURE get_param_values(p_context IN VARCHAR2 DEFAULT NULL);
PROCEDURE populate_bin (p_context IN VARCHAR2 DEFAULT NULL);
PROCEDURE populate_logins_report(p_context IN VARCHAR2 DEFAULT NULL);
PROCEDURE populate_durations_report(p_context IN VARCHAR2 DEFAULT NULL);

END BIX_UWQ_TEMP_PKG;

 

/
