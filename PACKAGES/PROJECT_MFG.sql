--------------------------------------------------------
--  DDL for Package PROJECT_MFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PROJECT_MFG" AUTHID CURRENT_USER AS
/* $Header: CSTPJCMS.pls 115.3 2002/11/11 18:59:53 awwang ship $ */

FUNCTION matl_subelement (
	   I_ITEM_ID			IN 	NUMBER,
	   I_RATES_COST_TYPE_ID		IN	NUMBER,
	   I_ORG_ID			IN	NUMBER)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(matl_subelement,WNDS,WNPS);

END project_mfg;

 

/
