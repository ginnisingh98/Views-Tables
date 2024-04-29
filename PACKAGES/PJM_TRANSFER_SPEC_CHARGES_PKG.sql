--------------------------------------------------------
--  DDL for Package PJM_TRANSFER_SPEC_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_TRANSFER_SPEC_CHARGES_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMTSPCS.pls 115.7 2004/08/18 04:28:24 yliou ship $ */


---------------------------------------------------------------------------
-- PUBLIC PROCEDURE
--   Transfer_Spec_Charges_to_PA
--
-- DESCRIPTION
--   This procedure will get the expenditure and costing data for
--   Freight, Tax, and other special chargs from AP invoices with
--   destination type of INVENTORY or SHOP FLOOR, and push these
--   data to PA_TRANSACTION_INTERFACES.
--
-- PARAMETERS
--   X_Project_Id                IN
--   X_Start_Date                IN
--   X_End_Date                  IN
--   ERRBUF                      OUT
--   RETCODE                     OUT
--
---------------------------------------------------------------------------

PROCEDURE Transfer_Spec_Charges_to_PA
( ERRBUF              OUT NOCOPY VARCHAR2
, RETCODE             OUT NOCOPY NUMBER
, X_Project_Id        IN         NUMBER
, X_Start_Date        IN         VARCHAR2
, X_End_Date          IN         VARCHAR2
, X_Submit_Trx_Import IN         VARCHAR2
, X_Trx_Status_Code   IN         VARCHAR2
);

END PJM_TRANSFER_SPEC_CHARGES_PKG;


 

/
