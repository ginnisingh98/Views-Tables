--------------------------------------------------------
--  DDL for Package PJI_PMV_DFLT_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_DFLT_PARAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: PJIRX03S.pls 120.1 2006/03/30 23:56:16 appldev noship $ */

PROCEDURE InitParameters (p_Report_Type VARCHAR2);
--Bug 5086074 Modified code for discoverer implementation
PROCEDURE InitEnvironment(p_Calling_Context VARCHAR2 DEFAULT NULL);

FUNCTION Derive_Organization_ID(p_Calling_Context VARCHAR2 DEFAULT NULL)        RETURN VARCHAR2;
FUNCTION Derive_Currency_ID							RETURN VARCHAR2;
FUNCTION Derive_Avail_Threshold							RETURN VARCHAR2;
FUNCTION Derive_Period_ID							RETURN VARCHAR2;
FUNCTION Derive_EntPeriod_ID   							RETURN VARCHAR2;
FUNCTION Derive_EntWeek_ID							RETURN VARCHAR2;

FUNCTION Derive_Ent_Quarter_ID_Value RETURN NUMBER;
FUNCTION Derive_Ent_Period_ID_Value  RETURN NUMBER;
FUNCTION Derive_Week_ID_Value        RETURN NUMBER;

FUNCTION Derive_Period_ID_Value RETURN VARCHAR2;


-- FUNCTION Derive_View_By                    RETURN VARCHAR2;
-- FUNCTION Derive_Operating_Unit             RETURN VARCHAR2;
-- FUNCTION Derive_Manager                    RETURN VARCHAR2;
-- FUNCTION Derive_Project_Classification     RETURN VARCHAR2;
-- FUNCTION Derive_Project_Class              RETURN VARCHAR2;

END PJI_PMV_DFLT_PARAMS_PVT;


 

/
