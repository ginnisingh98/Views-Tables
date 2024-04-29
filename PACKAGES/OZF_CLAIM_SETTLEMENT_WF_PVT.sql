--------------------------------------------------------
--  DDL for Package OZF_CLAIM_SETTLEMENT_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_SETTLEMENT_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcwfs.pls 120.0 2006/02/08 03:06 jrajaman noship $ */

PROCEDURE Prepare_Docs(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
);


PROCEDURE Check_Adhoc_Setl_Automation(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

PROCEDURE Fetch_Adhoc_Setl_Doc(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);


END OZF_CLAIM_SETTLEMENT_WF_PVT;

 

/
