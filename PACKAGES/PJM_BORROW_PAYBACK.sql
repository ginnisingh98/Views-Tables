--------------------------------------------------------
--  DDL for Package PJM_BORROW_PAYBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_BORROW_PAYBACK" AUTHID CURRENT_USER AS
/* $Header: PJMBWPYS.pls 115.9 2002/10/29 20:13:43 alaw ship $ */

--
--  Name          : Set_Bucket_Size
--  Pre-reqs      : None
--  Function      : This procedure sets the global variable
--                  G_Bucket_Size
--
--
--  Parameters    :
--  IN            : X_Bucket_Size                   NUMBER
--
--  Returns       : None
--
PROCEDURE Set_Bucket_Size
( X_Bucket_Size                    IN     NUMBER
);


--
--  Name          : Bucket_Size
--  Pre-reqs      : None
--  Function      : This procedure gets the value in global variable
--                  G_Bucket_Size
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : VARCHAR2
--
FUNCTION Bucket_Size
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (Bucket_Size, WNDS, WNPS);


--
--  Name          : Validate_Trx
--  Pre-reqs      : None
--  Function      : This function validates a transaction in the context of
--                  borrow/payback and project transfer
--
--
--  Parameters    :
--  IN            : X_trx_type_id                   NUMBER
--                  X_trx_action_id                 NUMBER
--                  X_organization_id               NUMBER
--                  X_item_id                       NUMBER
--                  X_from_subinventory             VARCHAR2
--                  X_from_locator_id               NUMBER
--                  X_to_subinventory               VARCHAR2
--                  X_to_locator_id                 NUMBER
--                  X_primary_quantity              NUMBER
--                  X_transaction_date              DATE
--                  X_payback_date                  DATE
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Number
--
FUNCTION VALIDATE_TRX(X_Transaction_Type_Id     IN NUMBER,
                      X_Transaction_Action_Id   IN NUMBER,
                      X_Organization_Id         IN NUMBER,
                      X_From_SubInventory       IN VARCHAR2,
                      X_From_Locator_Id         IN NUMBER,
                      X_To_Subinventory         IN VARCHAR2,
                      X_To_Locator_Id           IN NUMBER,
                      X_Inventory_Item_Id       IN NUMBER,
                      X_Revision                IN VARCHAR2,
                      X_Primary_Quantity        IN NUMBER,
                      X_Transaction_Date        IN DATE,
                      X_Payback_Date            IN DATE,
                      X_Error_Code              OUT NOCOPY VARCHAR2) RETURN NUMBER;

--
--  Name          : Trx_Callback
--  Pre-reqs      : Non
--  Function      : This function performs the following tasks:
--                  1) for a borrow transaction, it inserts a record
--                     into PJM_BORROW_TRANSACTIONS
--
--                  2) for a payback transaction, it allocates the
--                     payback quantity to borrow transactions and
--                     insert the results in PJM_BORROW_PAYBACKS
--
--
--  Parameters    :
--  IN            : X_transaction_id                NUMBER
--                  X_transaction_temp_id           NUMBER
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Trx_Callback
( X_transaction_id                 IN          NUMBER
, X_transaction_temp_id            IN          NUMBER
, X_error_code                     OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;


END;

 

/
