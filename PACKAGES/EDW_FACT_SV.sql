--------------------------------------------------------
--  DDL for Package EDW_FACT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_FACT_SV" AUTHID DEFINER AS
/* $Header: EDWVFCTS.pls 115.6 2002/12/05 00:35:00 jianyan ship $ */

g_log boolean := false;

Procedure generateViewForFact(fact_name IN VARCHAR2);
FUNCTION getDecodeClauseForFlexFK( pFactName IN VARCHAR2, pAttributeName IN VARCHAR2) RETURN  VARCHAR2;

END EDW_FACT_SV;

 

/
