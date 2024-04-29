--------------------------------------------------------
--  DDL for Package OKE_K_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_APPROVAL_WF" AUTHID CURRENT_USER AS
/* $Header: OKEWKAPS.pls 120.1.12000000.2 2007/02/27 18:46:00 nnadahal ship $ */
--
--  Name          : Initialize
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure initializes the remaining of the item
--                  attributes not set during launch
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_BOA_Approved
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the master agreement
--                  has been approved or not.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_BOA_Approved
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_Doc_Approved
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the contract document
--                  has already been approved or not.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Doc_Approved
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_Doc_Delv_Order
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the contract document
--                  is a delivery order.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Doc_Delv_Order
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_Doc_Inactive
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the contract document
--                  is currently inactive (Canceled, Expired, Terminated)
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Doc_Inactive
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_Final_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the last approver
--                  is the final approver based to the approval
--                  hierarchy.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Final_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_Requestor_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure checks wheter the approver happens
--                  to be also the requestor.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Requestor_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Is_Signature_Required
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure checks whether signature is required
--                  based on the approval hierarchy
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Signature_Required
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Rej_Note_Filled
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure verifies that the note is filled if
--                  the contract was rejected.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Rej_Note_Filled
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Select_Next_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the next approver for
--                  the contract based on the approval hierarchy.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_BOOLEAN )
--
--  Returns       : None
--
PROCEDURE Select_Next_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Select_Signatory
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the signatory for
--                  the contract based on the approval hierarchy
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( WFSTD_BOOLEAN )
--
--  Returns       : None
--
PROCEDURE Select_Signatory
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Set_Approval_History
--  Pre-reqs      : Must be called from WF activity
--  Function      : This post-notification procedure records the approval
--                  history based on the notification response
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Set_Approval_History
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


--
--  Name          : Validate_Approval_Path
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure validates the approval hierarchy
--                  associated with the contract document type.
--
--  Parameters    :
--  IN            : Document_ID ( ItemType:ItemKey )
--                  Display_Type
--                  Document_Type
--  OUT NOCOPY /* file.sql.39 change */           : Document
--                  Document_Type
--
--  Returns       : None
--
PROCEDURE Validate_Approval_Path
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

--bug#5846706
--
--  Name          : Erase_Approved
--  Pre-reqs      : Must be called from WF activity
--  Function      : It erases approved date when signatory rejects the contract
--
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Erase_Approved
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


END OKE_K_APPROVAL_WF;

 

/
