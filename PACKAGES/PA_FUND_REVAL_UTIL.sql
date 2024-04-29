--------------------------------------------------------
--  DDL for Package PA_FUND_REVAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUND_REVAL_UTIL" AUTHID CURRENT_USER AS
--$Header: PAXFRUTS.pls 115.2 2002/08/21 22:31:03 jpaulraj noship $

-- Package Variables

PROCEDURE log_message(p_message IN VARCHAR2);

-- Function   :  Valid_Include_Gains_Losses
-- Parameters :  Org_Id
-- Purpose    :  Function to check  whether user can modify
--		 include gains and losses option or not
--		 If the function returns Y then user should not able to
--               Modify it.
--		 This should be called only when disable the option

FUNCTION Valid_Include_Gains_Losses(p_org_id IN NUMBER)
    RETURN VARCHAR2;

-- Function   :  Is_Ou_Include_Gains_Losses
-- Parameters :  Org_Id
-- Purpose    :  Function to check  whether Implementations level
--		 include gains and losses option is enabled or not

FUNCTION Is_OU_Include_Gains_Losses(p_org_id IN NUMBER)
    RETURN VARCHAR2;

-- Function   :  Is_PT_Include_Gains_Losses
-- Parameters :  Org_Id, project_type
-- Purpose    :  Function to check  whether Project type level
--		 include gains and losses option is enabled or not

FUNCTION Is_PT_Include_Gains_Losses(p_org_id IN NUMBER,
				      p_project_type IN VARCHAR2)
    RETURN VARCHAR2;

-- Function   :  Is_Ar_Installed
-- Parameters :  None

FUNCTION Is_AR_Installed RETURN VARCHAR2;
-- Function   :  Get_Ar_Application_Id
-- Parameters :  None

FUNCTION Get_AR_Application_Id RETURN NUMBER;

END PA_FUND_REVAL_UTIL;

 

/
