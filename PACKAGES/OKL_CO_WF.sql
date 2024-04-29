--------------------------------------------------------
--  DDL for Package OKL_CO_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CO_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRCOWS.pls 115.2 2002/12/18 06:16:24 spillaip noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP		      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_INVALID_VALUE	      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	      CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN	      CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN	      CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLCODE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		      CONSTANT VARCHAR2(200) := 'OKL_CO_WF';
  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  'OKL';

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

  /*checks for syndication*/
  PROCEDURE get_syndicate_flag(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

  /*checks if case can be sent to third party*/
  PROCEDURE get_sendtothirdparty_flag(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

  /*checks if vendor approval is required to send the case
  **to third party*/
  PROCEDURE get_vendorapproval_flag(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

  /*checks if vendor notification is required after sending the case
  **to third party*/
  PROCEDURE get_vendornotify_flag(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

  /*returns vendor information*/
  PROCEDURE get_vendor_info(p_case_number in varchar2,
                         x_vendor_id   out nocopy number,
                         x_vendor_name out nocopy varchar2,
                         x_vendor_email out nocopy varchar2,
                         x_return_status out nocopy varchar2);

  /*Send notification to customer about intent to report to credit bureau*/
  PROCEDURE notify_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*procedure to halt flow for a specific period of time*/
  PROCEDURE wait_before_report(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*report customer to the credit bureau*/
  PROCEDURE report_customer(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*sends email to obtain vendor approval*/
  PROCEDURE send_vendor_approval(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*transfers case to external agency*/
  PROCEDURE transfer_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*review case transfer*/
  PROCEDURE review_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*review case transfer*/
  PROCEDURE recall_case(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /*sends email to notify vendor about action taken against a case*/
  PROCEDURE send_vendor_notify(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);

  /** send signal to the main work flow that the custom work flow is over and
  * also updates the work item
  **/
  PROCEDURE wf_send_signal_cancelled(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out nocopy  varchar2);

  /** send signal to the main work flow that the custom work flow is over and
  * also updates the work item
  **/
  PROCEDURE wf_send_signal_complete(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out nocopy  varchar2);

  FUNCTION get_party_name(p_case_number in varchar2) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_party_name, WNDS);

  FUNCTION get_case_contracts(p_case_number in varchar2) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_case_contracts, WNDS);

  FUNCTION get_case_total_value(p_case_number in varchar2) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(get_case_total_value, TRUST);

  FUNCTION get_amt_overdue(p_case_number in varchar2) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(get_amt_overdue, WNDS);

  FUNCTION get_vendor_name(p_case_number in varchar2) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_vendor_name, WNDS);

  --PROCEDURE raise_report_cb_event(p_delinquency_id IN NUMBER);

END OKL_CO_WF;

 

/
