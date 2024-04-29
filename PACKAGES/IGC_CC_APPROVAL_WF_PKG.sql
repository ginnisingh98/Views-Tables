--------------------------------------------------------
--  DDL for Package IGC_CC_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_APPROVAL_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCVAWFS.pls 120.4.12010000.2 2008/08/04 14:52:52 sasukuma ship $ */

PROCEDURE Start_Process
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_wf_version                IN       NUMBER   := 2,
  x_return_status             OUT NOCOPY      VARCHAR2 ,
  x_msg_count                 OUT NOCOPY      NUMBER   ,
  x_msg_data                  OUT NOCOPY      VARCHAR2 ,
  p_item_key                  IN       VARCHAR2 ,
  p_cc_header_id              IN       NUMBER   ,
  p_acct_date                 IN       DATE     ,
  p_note                      IN       VARCHAR2 := '',
  p_debug_mode                IN       VARCHAR2 := FND_API.G_FALSE

);

PROCEDURE Select_Approver
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

PROCEDURE Check_Authority
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

PROCEDURE Funds_Required
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

PROCEDURE Reject_Contract
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

PROCEDURE Approve_Contract

(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

PROCEDURE Failed_Process

(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

PROCEDURE BC_Failed

(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);


PROCEDURE Execute_BC

(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

END IGC_CC_APPROVAL_WF_PKG;


/
