--------------------------------------------------------
--  DDL for Package AP_WEB_CC_VALIDATION_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CC_VALIDATION_WF_PKG" AUTHID CURRENT_USER as
  /* $Header: apwfvals.pls 115.2 2004/01/05 22:02:57 kmizuta noship $ */

  --
  -- Raises the Workflow business event
  --   oracle.apps.ap.oie.creditcard.transaction.error
  function raise_validation_event(p_request_id in number default null,
                                  p_card_program_id in number default null,
                                  p_start_date in date default null,
                                  p_end_date in date default null) return number;

  /*
  --
  -- Counts the number of invalid credit card transactions
  -- for the give Request ID, Card Program ID, and start/end dates
  procedure count_invalid(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);
  */

  --
  -- Returns the URL for the Credit Card Transactions page
  procedure get_search_page_url(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2);

  --
  -- Raises the Workflow business event
  --   oracle.apps.ap.oie.creditcard.account.create
  function raise_new_cc_event(p_request_id in number default null,
                            p_card_program_id in number default null,
                            p_start_date in date default null,
                            p_end_date in date default null)
  return number;

  --
  -- Find employee matches
  procedure card_employee_match(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);

  --
  -- Assigns employees to credit cards if only one employee
  -- candidate was found - thereby activating the credit card.
  procedure assign_emp_if_unique(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);

  --
  -- Checks to see if new credit cards were created by
  -- a given request id
  procedure new_cards_exist(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);

  --
  -- Checks to see if inactive credit cards were created by
  -- a given request id
  procedure inactive_cards_exist(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);

  --
  -- Checks to see if invalid credit card trx were created by
  -- a given request id
  procedure invalid_cctrx_exist(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);

  --
  -- Counts the number of new credit cards that were created by
  -- a given Request ID
  procedure count_new_cards(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2);

  --
  -- Returns the URL to the New Card Search page.
  procedure get_new_card_page_url(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2);

  --
  -- Returns the name of the user who initiated the workflow.
  -- If the workflow is initiated through by a concurrent program,
  -- the current user would be the user who initiated the
  -- concurrent program.
  procedure whoami(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);

  --
  -- Returns the name of the system administrator role for
  -- the card program.
  procedure get_card_sysadmin(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);

  --
  -- Returns the name of the Card Program
  procedure get_card_program_name(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);

  --
  -- Returns the value of RETURN_ATTRIBUTE_NAME
  procedure get_attribute_value(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);

  --
  -- Returns the activity value of RETURN_ATTRIBUTE_NAME
  procedure get_act_attribute_value(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);


  PROCEDURE get_instructions(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2);
end ap_web_cc_validation_wf_pkg;

 

/
