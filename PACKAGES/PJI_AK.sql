--------------------------------------------------------
--  DDL for Package PJI_AK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_AK" AUTHID CURRENT_USER AS
-- $Header: PJIRX18S.pls 115.0 2004/07/27 18:48:47 vliubcen noship $

FUNCTION GetLabel( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL
                            , p_Label_Code         VARCHAR2    DEFAULT NULL
                            , p_Bit_Mode           VARCHAR2    DEFAULT '1')
RETURN VARCHAR2;

FUNCTION GetPriorLbl( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
RETURN VARCHAR2;

END PJI_AK;

 

/
