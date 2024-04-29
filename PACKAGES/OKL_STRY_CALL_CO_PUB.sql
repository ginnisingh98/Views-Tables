--------------------------------------------------------
--  DDL for Package OKL_STRY_CALL_CO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STRY_CALL_CO_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPCWFS.pls 120.1 2005/07/18 06:21:02 asawanka noship $ */


wf_yes 		varchar2(1) := 'Y';
wf_no       varchar2(1) := 'N';



/**
  * send an email thru fulfilment
  * right now the okl fulfilment api supports email
  * only
 **/
procedure send_fulfilment(
                                 itemtype    in   varchar2,
                                 itemkey     in   varchar2,
                                 actid       in   number,
                                 funcmode    in   varchar2,
                                 result      out  nocopy varchar2);

/** send signal to the main work flow that the custom work flow is over and
 * also updates the work item
 **/

procedure wf_send_signal(
  itemtype    in   varchar2,
  itemkey     in   varchar2,
  actid       in   number,
  funcmode    in   varchar2,
  result      out  nocopy varchar2);

/**
get the most delinquent contract from a
case based on the no of days due
*/

PROCEDURE get_delinquent_contract(
     p_case_id		  IN NUMBER,
     x_contract_id OUT NOCOPY NUMBER,
     x_days        OUT NOCOPY NUMBER) ;


 /**
  checks if vendor approval is required to call customer
  **/
  PROCEDURE get_vendorapproval_flag(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    result       out nocopy varchar2);

/**
  checks for notification rule
  **/

  PROCEDURE get_notification_flag(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    result       out nocopy varchar2);
/**
  checks if no of days past due is greater than the
  the actual past due
  **/

  PROCEDURE check_days_past_due(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    result       out nocopy varchar2);
/*returns vendor information*/
  PROCEDURE get_vendor_info(p_case_number in varchar2,
                         x_vendor_id   out nocopy number,
                         x_vendor_name out nocopy varchar2,
                         x_vendor_email out nocopy varchar2,
                          x_return_status out nocopy varchar2);

  ---------------------------------------------------------------------------
  -- PROCEDURE Days to take notice of assignment for Syndicated Account?
  ---------------------------------------------------------------------------
  PROCEDURE check_days_for_syn_acct(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    result       out nocopy varchar2) ;


 ---------------------------------------------------------------------------
  -- PROCEDURE lessor_VISIT_FLAG -'Lessor allowed to visit customer?'
  ---------------------------------------------------------------------------
  PROCEDURE get_lessor_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2) ;
---------------------------------------------------------------------------
  -- PROCEDURE Customer_VISIT_FLAG -     'Vendor allowed to visit customer?'
  ---------------------------------------------------------------------------
  PROCEDURE get_Customer_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2);
  ---------------------------------------------------------------------------
  -- PROCEDURE Vendor_Customer_VISIT_FLAG -   'Vendor approval required to visit customer?'
  ---------------------------------------------------------------------------
  PROCEDURE get_Vendor_approval_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2);
  --------------------------------------------------------------------------
  -- PROCEDURE Vend_Cust_NOTIFY Vendor notification required prior to customer visit?
  ---------------------------------------------------------------------------
  PROCEDURE get_Vend_Cust_NOTIFY_flag(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2);





END OKL_STRY_CALL_CO_PUB;

 

/
