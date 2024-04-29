--------------------------------------------------------
--  DDL for Package IGP_VW_GEN_001_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_VW_GEN_001_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPVWAS.pls 120.0 2005/06/01 12:33:06 appldev noship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGPVW01B.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |   support user name generation WF                                     |
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

g_message_text VARCHAR2(32000);

-- create adhoc role for viewers and assign
-- individual viewers from the list p_viewer_ids
PROCEDURE  Create_Viewers_Role(
 itemtype  IN  VARCHAR2,
 itemkey   IN  VARCHAR2,
 p_viewer_ids	IN	varchar2,
 p_portfolio_ids IN     varchar2 ) ;

-- write viewer HTML message into CLOB for notification
-- standard format from WF team.
PROCEDURE Write_Viewer_Message
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) ;

--called from WF linked with inform viewer BE.
PROCEDURE Get_Viewer_Inform_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

-- this raise the inform Viewer for Assignment BE.
PROCEDURE Raise_Assign_Event(
 p_viewer_ids	IN	varchar2,
 p_portfolio_ids IN     varchar2,
 p_access_exp_date IN   varchar2
);

-- create static HTML for author.
PROCEDURE Create_Author_Message
(p_viewer_ids IN VARCHAR2,
 p_message_text OUT NOCOPY VARCHAR) ;

-- this raise the inform Author for Assignment BE.
PROCEDURE Raise_Inform_Author_Event
(
 p_viewer_ids	IN	varchar2,
 p_portfolio_ids IN     varchar2
);

-- write author HTML message into CLOB for notification
-- standard format from WF team.
PROCEDURE Write_Author_Message
(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) ;

-- called from WF linked with inform author BE.
PROCEDURE Get_Author_Det (
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);



END IGP_VW_GEN_001_PKG;

 

/
