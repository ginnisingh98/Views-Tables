--------------------------------------------------------
--  DDL for Package Body PJI_AK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_AK" AS
-- $Header: PJIRX18B.pls 115.0 2004/07/27 18:49:00 vliubcen noship $

FUNCTION GetLabel( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL
                            , p_Label_Code         VARCHAR2    DEFAULT NULL
                            , p_Bit_Mode           VARCHAR2    DEFAULT '1')
RETURN VARCHAR2 IS
BEGIN
	RETURN PJI_PMV_UTIL.GetTimeLevelLabel(p_page_parameter_tbl, p_Label_Code, p_Bit_Mode);
END GetLabel;

FUNCTION GetPriorLbl( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
RETURN VARCHAR2 IS
BEGIN
	RETURN PJI_PMV_UTIL.GetPriorLabel(p_page_parameter_tbl);
END GetPriorLbl;

END PJI_AK;

/
