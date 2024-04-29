--------------------------------------------------------
--  DDL for Package OKE_K_APPROVAL_WF2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_APPROVAL_WF2" AUTHID CURRENT_USER AS
/* $Header: OKEWKA2S.pls 120.1 2005/06/02 11:59:53 appldev  $ */
--
--  Name          : Contract_Number_Link
--  Pre-reqs      : Must be called from WF activity
--  Function      : This PL/SQL document procedure returns the contract
--                  number with a link to contract flowdown viewer
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
PROCEDURE Contract_Number_Link
( Document_ID         IN      VARCHAR2
, Display_Type        IN      VARCHAR2
, Document            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
, Document_Type       IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


--
--  Name          : Show_Approval_History
--  Pre-reqs      : Must be called from WF activity
--  Function      : This PL/SQL document procedure returns the approval
--                  history as maintained in SET_APPROVAL_HISTORY() for
--                  use in various notifications
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
PROCEDURE Show_Approval_History
( Document_ID         IN      VARCHAR2
, Display_Type        IN      VARCHAR2
, Document            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
, Document_Type       IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


END OKE_K_APPROVAL_WF2;

 

/
