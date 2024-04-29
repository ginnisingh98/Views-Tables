--------------------------------------------------------
--  DDL for Package PJM_TRANSFER_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_TRANSFER_CHARGES_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMTFCGS.pls 120.1 2005/06/29 14:03:21 jxtang noship $ */

-- Start of comments
--	API name 	: Batch_Name
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Get the batch name for the batch process
--	Parameters	:
--	IN		: N/A
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

Function Batch_Name return varchar2;

-- Start of comments
--	API name 	: Get_Charges_Expenditure_Type
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Get the expenture type for IPV,ERV and special
--			: charges
--	Parameters	:
--      IN		: X_Type		VARCHAR2
--	IN		: X_Project_ID	        NUMBER
--      IN	        : X_Org_ID		NUMBER
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

Function get_charges_expenditure_type( X_Type IN VARCHAR2,
				  X_Project_Id  IN NUMBER,
                                  X_Org_Id      IN NUMBER) return varchar2;


-- Start of comments
--	API name 	: Transfer_Charges_To_PA
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Get the expenditure and costing data from invoice
--			: distributions which has amount for IPV, ERV and
--			: special charges, and the destination type is
--			: INVENTORY or SHOP FLOOR, then push data to PA
--	Parameters	:
--	IN		: X_Project_ID	        NUMBER
--      IN	        : X_Start_Date		DATE
--      IN 		: X_End_Date		DATE
--      IN 		: X_Submit_Trx_Import   VARCHAR2
--      IN 		: X_Trx_Status_Code	VARCHAR2
--      OUT		: ERRBUF	        NUMBER
--      OUT 		: RETCODE		NUMBER
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

PROCEDURE Transfer_Charges_to_PA
( ERRBUF              OUT NOCOPY VARCHAR2
, RETCODE             OUT NOCOPY NUMBER
, X_Project_Id        IN         NUMBER
, X_Start_Date        IN         VARCHAR2
, X_End_Date          IN         VARCHAR2
, X_Submit_Trx_Import IN         VARCHAR2
, X_Trx_Status_Code   IN         VARCHAR2
);

END PJM_TRANSFER_CHARGES_PKG;

 

/
