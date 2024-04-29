--------------------------------------------------------
--  DDL for Package IEX_CO_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CO_WF" AUTHID CURRENT_USER AS
/* $Header: IEXRCOWS.pls 120.0 2004/01/24 03:15:18 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP		      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_INVALID_VALUE	      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	      CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN	      CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN	      CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'IEX_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLCODE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		      CONSTANT VARCHAR2(200) := 'IEX_CO_WF';
  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  'IEX';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  wf_yes      varchar2(1) := 'Y';
  wf_no       varchar2(1) := 'N';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  /*Send notification to customer about intent to report to credit bureau*/
  PROCEDURE notify_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);


  /*report customer to the credit bureau*/
  PROCEDURE report_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

  /*transfers case to external agency*/
  PROCEDURE transfer_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

  /*review case transfer*/
  PROCEDURE review_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

  /*review case transfer*/
  PROCEDURE recall_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

  /** send signal to the main work flow that the custom work flow is over and
  * also updates the work item
  **/
  PROCEDURE wf_send_signal_cancelled(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out NOCOPY  varchar2);

  /** send signal to the main work flow that the custom work flow is over and
  * also updates the work item
  **/
  PROCEDURE wf_send_signal_complete(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out NOCOPY  varchar2);


  --PROCEDURE raise_report_cb_event(p_delinquency_id IN NUMBER);

END IEX_CO_WF;

 

/
