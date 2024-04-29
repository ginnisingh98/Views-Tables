--------------------------------------------------------
--  DDL for Package PJM_TRANSFER_IPV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_TRANSFER_IPV_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMTIPVS.pls 115.13 2004/08/18 04:18:53 yliou ship $ */

Function Batch_Name return varchar2;

Function get_ipv_expenditure_type(X_Project_Id  IN NUMBER,
                                  X_Org_Id      IN NUMBER) return varchar2;

Function get_erv_expenditure_type(X_Project_Id  IN NUMBER,
                                  X_Org_Id      IN NUMBER) return varchar2;


---------------------------------------------------------------------------
-- PUBLIC PROCEDURE
--   Transfer_IPV_to_PA
--
-- DESCRIPTION
--   This procedure will get the expenditure and costing data from Invoice
--   Distributions which has IPV amount and the destination type is
--   INVENTORY. And then push these data to PA_TRANSACTION_INTERFACES.
--
-- PARAMETERS
--   X_Project_Id		IN
--   X_Start_Date               IN
--   X_End_Date                 IN
--   ERRBUF			OUT
--   RETCODE			OUT
--
---------------------------------------------------------------------------

PROCEDURE Transfer_IPV_to_PA
( ERRBUF              OUT NOCOPY VARCHAR2
, RETCODE             OUT NOCOPY NUMBER
, X_Project_Id        IN         NUMBER
, X_Start_Date        IN         VARCHAR2
, X_End_Date          IN         VARCHAR2
, X_Submit_Trx_Import IN         VARCHAR2
, X_Trx_Status_Code   IN         VARCHAR2
);

END PJM_TRANSFER_IPV_PKG;

 

/
