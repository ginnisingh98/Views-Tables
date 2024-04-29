--------------------------------------------------------
--  DDL for Package PJM_MASS_TRANSFER_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_MASS_TRANSFER_WF" AUTHID CURRENT_USER AS
/* $Header: PJMWMXFS.pls 115.3 2002/10/29 20:14:34 alaw noship $ */
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
--  OUT           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Initialize
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Approval_Required_F
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if approval is required
--                  for the From Project
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Approval_Required_F
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Approval_Required_T
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if approval is required
--                  for the To Project
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Approval_Required_T
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Execute
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure executes the mass transfer by
--                  invoking the mass transfer process
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Execute
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


--
--  Name          : Transfer_Details
--  Pre-reqs      : Must be called from WF activity
--  Function      : This PL/SQL document procedure returns the transfer
--                  details for use in various notifications
--
--  Parameters    :
--  IN            : Document_ID ( ItemType:ItemKey )
--                  Display_Type
--                  Document_Type
--  OUT           : Document
--                  Document_Type
--
--  Returns       : None
--
PROCEDURE Transfer_Details
( Document_ID         IN             VARCHAR2
, Display_Type        IN             VARCHAR2
, Document            OUT NOCOPY     VARCHAR2
, Document_Type       IN OUT NOCOPY  VARCHAR2
);


--
--  Name          : Start_Process
--  Pre-reqs      : None
--  Function      : This PL/SQL procedure starts the specified WF process
--
--  Parameters    :
--  IN            : ItemType
--                  Process
--                  ItemKey
--  OUT           : None
--
--  Returns       : None
--
PROCEDURE Start_Process
( ItemType            IN      VARCHAR2
, Process             IN      VARCHAR2
, ItemKey             IN      VARCHAR2
);

END PJM_MASS_TRANSFER_WF;

 

/
