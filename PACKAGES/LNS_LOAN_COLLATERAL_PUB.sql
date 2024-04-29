--------------------------------------------------------
--  DDL for Package LNS_LOAN_COLLATERAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_LOAN_COLLATERAL_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_LNCOL_PUBP_S.pls 120.0 2005/05/31 18:45:07 appldev noship $ */

/*
 This procedure is used to end-date collaterals pledged to a loan
 upon certain status changes in the loan
 If the collateral is acquired for the loan in question, then the asset
 also gets end-dated
*/
procedure Release_Collaterals(p_loan_id NUMBER);

-- function used to check if any asset assignment exists for a specific asset
-- if so, disallow deletion of that asset
FUNCTION IS_EXIST_ASSET_ASSIGNMENT (
    p_asset_id			 NUMBER
) RETURN VARCHAR2;

END LNS_LOAN_COLLATERAL_PUB;

 

/
