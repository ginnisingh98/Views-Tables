--------------------------------------------------------
--  DDL for Package ZPB_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_PUBLISH" AUTHID CURRENT_USER AS
/* $Header: ZPBPUBS.pls 120.0.12010.2 2005/12/23 06:03:07 appldev noship $ */
PROCEDURE startPublishTaskCP(
        itemtype    IN varchar2,
        itemkey     IN varchar2,
        actid       IN number,
        funcmode    IN varchar2,
        resultout   OUT nocopy varchar2
 );

   PROCEDURE getApprovalFlag(
        itemtype    IN varchar2,
        itemkey     IN varchar2,
        actid       IN number,
        funcmode    IN varchar2,
        resultout   OUT nocopy varchar2
 );

END ZPB_PUBLISH;

 

/
