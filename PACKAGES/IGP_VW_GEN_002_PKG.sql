--------------------------------------------------------
--  DDL for Package IGP_VW_GEN_002_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_VW_GEN_002_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPVWBS.pls 120.0 2005/06/01 20:29:20 appldev noship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGPVW01B.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |   support Business Events for Removing Portfolios from Access List    |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  DEPENDENCIES                                                         |
   |                                                                       |
   |  USAGE                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   |    04-APR-2001  ssawhney Created                                      |
   +=======================================================================+  */



-- create adhoc role for Career Center and assign
-- individual CC users from the static select for FND users holding that responsibility.
PROCEDURE  Create_CC_Role(
 itemtype  IN  VARCHAR2,
 itemkey   IN  VARCHAR2
) ;

-- write  HTML message into CLOB for notification to go to Career Centre
-- standard format from WF team.
PROCEDURE Write_CC_Message
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) ;

--called from WF linked with inform CC about the removal of access from viewer.
PROCEDURE Get_Inform_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

-- this raise the inform CC for Removal of Assignment BE.
PROCEDURE Raise_Removal_Event_CC(
 p_viewer_id	IN	varchar2,
 p_portfolio_ids IN     varchar2,
 p_CC_user_name IN varchar2
);


-- this raise the inform Author for Removal of Assignment BE.
PROCEDURE Raise_Inform_Author_Event
(
 p_viewer_id	IN	varchar2,
 p_portfolio_ids IN     varchar2,
 p_CC_user_name IN varchar2
);


-- called from WF linked with inform author for removal of Assignment BE.
PROCEDURE Get_Author_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);


--Procedure to check the action of the workflow.if it a removal workflow or an invalid assignment workflow.
    PROCEDURE chk_action (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

-- this raise the inform CC for invalid Assignments.
PROCEDURE Raise_invalid_assign_Event_CC(
 p_invalid_assignments	IN	varchar2
);

    PROCEDURE Get_invalid_assign_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

    PROCEDURE Write_CC_invalid_assign_Mes
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  );

   PROCEDURE chk_source (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

END IGP_VW_GEN_002_PKG;

 

/
