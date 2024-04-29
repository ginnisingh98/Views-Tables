--------------------------------------------------------
--  DDL for Package PON_REMINDER_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_REMINDER_NOTIFICATION_PKG" AUTHID CURRENT_USER AS
--$Header: PONSREMS.pls 120.2.12010000.1 2009/06/23 08:58:21 appldev noship $

TYPE t_number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 /*======================================================================
   PROCEDURE : send_notification_wrapper
   PARAMETERS: 1. p_send_when  - Which date to compare to send the notification i.e.
                  before close date, after open date, after preview date.
               2. p_days_values_number_table -Comma separated values of days.
                  For eg. 11,12,15

   COMMENT   : This procedure will convert the CSV varchar in numbers table and pass it to
               send_notification procudure.
               Also, it calls the purge procedure.
======================================================================*/



PROCEDURE send_notification_wrapper(
  ErrCode number,
  ErrMesg Varchar2,
  p_send_when IN VARCHAR2,
  p_days_values IN VARCHAR2
);


/*======================================================================
   PROCEDURE : send_notification
   PARAMETERS: 1. p_send_when  - Which date to compare to send the notification i.e.
                  before close date, after open date, after preview date.
               2. p_days_values_number_table - table of numbers containing values of days
                  at which the notifications need to be sent.

   COMMENT   : This procedure will check for the auctions to which the notifications needs to be
               sent and calls  call_wf_process_to_send_notif with the header_id
======================================================================*/
PROCEDURE send_notification (
   p_send_when IN VARCHAR2,
   p_days_values_number_table t_number_table_type

);

/*======================================================================
   PROCEDURE : call_wf_process_to_send_notif
   PARAMETERS: 1. p_send_when  - Which date to compare to send the notification i.e.
                  before close date, after open date, after preview date.
               2. p_days_values_number_table - table of numbers containing values of days
                  at which the notifications need to be sent.

   COMMENT   : This procedure will call the workflow for all the auctions in which notification needs to be send.
======================================================================*/

PROCEDURE call_wf_process_to_send_notif(
  p_auction_header_id IN NUMBER
);

/*======================================================================
   PROCEDURE : start_wf_process
   PARAMETERS:  1.p_auction_header_id - the auction header id of the auction
		2.p_trading_partner_contact_name - buyer's contact name
		3.p_trading_partner_name - buyer's company name
		4.p_auction_title - title of the auction
		5.p_reminder_date - date on which the notif is sent
		6.p_neg_preview_date - preview date of the neg
		7.p_neg_open_date - open date of the neg
		8.p_neg_close_date - close date of the neg
		9.p_supplier_name - supplier company name
		10.p_supplier_contact_name - supplier contact name
		11.p_supplier_role_name - role name on which the notif is to be sent
		12.p_supplier_site - supplier's site
		13.p_item_key - unique item key.
    14.p_notification_no - serial number of the notification.

   COMMENT   : This procedure will start the workflow to send the notification.
======================================================================*/
PROCEDURE start_wf_process(
p_auction_header_id IN NUMBER,
p_trading_partner_contact_name IN VARCHAR2,
p_trading_partner_name IN VARCHAR2,
p_auction_title IN VARCHAR2,
p_reminder_date IN DATE,
p_neg_preview_date IN DATE,
p_neg_open_date IN DATE,
p_neg_close_date IN DATE,
p_supplier_name IN VARCHAR2,
p_supplier_contact_name IN VARCHAR2,
p_supplier_role_name IN VARCHAR2,
p_supplier_site IN VARCHAR2,
p_item_key IN VARCHAR2,
p_notification_no IN NUMBER,
p_supplier_site_id IN NUMBER,
p_document_number IN VARCHAR2
);


PROCEDURE purge_notif_wf(
  p_start_purge IN BOOLEAN,
  p_purge_done OUT NOCOPY BOOLEAN
);

PROCEDURE log_message(
p_message  IN    VARCHAR2
);

END pon_reminder_notification_pkg;


/
