--------------------------------------------------------
--  DDL for Package PJI_PMV_PREDICATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_PREDICATE" AUTHID CURRENT_USER AS
/* $Header: PJIRX05S.pls 120.1 2005/11/17 16:21:03 appldev noship $ */

FUNCTION Show_Class_Code(p_Class_Code IN VARCHAR2
						, p_Class_Category IN VARCHAR2
						, p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION Show_Currency_Type(p_Currency_Code IN VARCHAR2
						, p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION Show_Project(p_Project_ID IN NUMBER
						, p_Organization_ID IN VARCHAR2
						, p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION Show_Project_Type(p_Project_ID IN NUMBER
			, p_Organization_ID IN VARCHAR2
			, p_Project_Type IN VARCHAR2
			, p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION Show_Operating_Unit(p_Org_ID IN VARCHAR2)
RETURN NUMBER;

END PJI_PMV_PREDICATE;

 

/
