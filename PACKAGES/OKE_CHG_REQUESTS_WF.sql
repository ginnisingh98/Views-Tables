--------------------------------------------------------
--  DDL for Package OKE_CHG_REQUESTS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CHG_REQUESTS_WF" AUTHID CURRENT_USER AS
/* $Header: OKEWCRQS.pls 115.4 2002/11/21 23:11:06 ybchen ship $ */
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
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Select_Next_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the next approver for
--                  the change request.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Select_Next_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Select_Next_Informed
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the next recipient of
--                  workflow notifications.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Select_Next_Informed
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Rej_Note_Filled
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure verifies that the note is filled if
--                  the change request was rejected.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Rej_Note_Filled
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Impact_Funding
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure checks whether the change request
--                  impacts funding or not.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Impact_Funding
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Set_Approved_Status
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure sets the status of the change request
--                  to Approved.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Set_Approved_Status
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Set_Rejected_Status
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure sets the status of the change request
--                  to Rejected.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Set_Rejected_Status
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


END OKE_CHG_REQUESTS_WF;

 

/
