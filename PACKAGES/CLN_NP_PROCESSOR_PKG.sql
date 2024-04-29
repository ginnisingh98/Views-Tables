--------------------------------------------------------
--  DDL for Package CLN_NP_PROCESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_NP_PROCESSOR_PKG" AUTHID CURRENT_USER AS
/* $Header: ECXNPNPS.pls 120.0 2005/08/25 04:47:51 nparihar noship $ */
--
--  Package
--    CLN_NP_PROCESSOR_PKG
--
--  Purpose
--    Spec of package CLN_NP_PROCESSOR_PKG
--    Based on the notification code, fetches the notification actions
--    and executes the actions that are defined by the user.
--    The actions can be one of the following : Raise Event, Start Workflow,
--    Notify Administartor, Notify Trading Pratner and Call user Procedure.
--    This package is triggered by Notification Message Map when a Notification BOD arraives,
--    XML Gateway Error Handling.
--  History
--    Mar-22-2001       Kodanda Ram         Created
--


-- Name
--    PROCESS_NOTIFICATION
-- Purpose
--    Based on the notification code, fetches the notification actions
--    and executes the actions that are defined by the user.
-- Arguments
--    p_tp_id                     Trading Partner ID
--    notification_code           Notification Code Received
--    p_reference                 Application Reference ID
--    p_statuslvl                 '00' for Sucess and '99' for Error
--    p_header_desc               Header description
--    p_reason_code               Comma seperated list of notification code
--    p_line_desc                 Line description
--    p_int_con_no                Internal Control Number
--    p_coll_point                Collaboration Point
--    p_doc_dir                   Document Direction
-- Notes
--    No specific notes

PROCEDURE PROCESS_NOTIFICATION(
   x_ret_code                           OUT NOCOPY VARCHAR2,
   x_ret_desc                           OUT NOCOPY VARCHAR2,
   p_tp_id                              IN  VARCHAR2,
   p_reference                          IN  VARCHAR2,
   p_statuslvl                          IN  VARCHAR2,
   p_header_desc                        IN  VARCHAR2,
   p_reason_code                        IN  VARCHAR2,
   p_line_desc                          IN  VARCHAR2,
   p_int_con_no                         IN  VARCHAR2,
   p_coll_point                         IN  VARCHAR2,
   p_doc_dir                            IN  VARCHAR2,
   p_coll_id                            IN  NUMBER,
   p_collaboration_standard             IN  VARCHAR2 DEFAULT NULL);


-- Name
--    TAKE_ACTIONS
-- Purpose
--    This procedure performs all the user defined actions for the specified
--    comma seperated list of notification codes
-- Arguments
--    p_notification_code           Comma seperated list of notification code
--    p_notification_desc           Comma seperated list of notification description
--    p_status                      SUCCESS/ERROR
--    p_tp_id                       Trading Partner ID
--    p_reference                   Application Reference ID
--    p_coll_point                  Collaboration Point
-- Notes
--    No specific notes

PROCEDURE TAKE_ACTIONS(
   x_ret_code                           OUT NOCOPY VARCHAR2,
   x_ret_desc                           OUT NOCOPY VARCHAR2,
   p_notification_code                  IN VARCHAR2,
   p_notification_desc                  IN VARCHAR2,
   p_status                             IN VARCHAR2,
   p_tp_id                              IN VARCHAR2,
   p_reference                          IN VARCHAR2,
   p_coll_point                         IN VARCHAR2,
   p_int_con_no                         IN VARCHAR2);

-- Name
--    GET_DELIMITER
-- Purpose
--    This function returns the delimiter character used to delimit a list of notification code/description
-- Arguments
--
-- Notes
--    No specific notes.

FUNCTION GET_DELIMITER RETURN VARCHAR2;

-- Name
--   GET_TRADING_PARTNER_DETAILS
-- Purpose
--   This procedure gets the trading partner id based on the internal control number
-- Arguments
--
-- Notes
--   No specific notes.

PROCEDURE GET_TRADING_PARTNER_DETAILS(
   x_return_status                      OUT NOCOPY VARCHAR2,
   x_msg_data                           OUT NOCOPY VARCHAR2,
   p_xmlg_internal_control_number       IN  NUMBER,
   p_tr_partner_id                      IN OUT NOCOPY VARCHAR2);

-- Name
--   NOTIFY_ADMINISTRATOR
-- Purpose
--   Sends a mail to the administrator
-- Arguments
--   Message to be send to the administrator
-- Notes
--   No specific notes.

PROCEDURE NOTIFY_ADMINISTRATOR(
   p_message                            IN VARCHAR2);



-- Name
--    PROCESS_NOTIF_ACTIONS_EVT
-- Purpose
--    This procedure handles a notification by executing all the actions defined by the user
--    for a given notification code.
--
-- Arguments
--
-- Notes
--    No specific notes

PROCEDURE PROCESS_NOTIF_ACTIONS_EVT(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_tr_partner_type                      IN  VARCHAR2,
         p_tr_partner_id                        IN  VARCHAR2,
         p_tr_partner_site                      IN  VARCHAR2,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_application_id                       IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2,
         p_unique2                              IN  VARCHAR2,
         p_unique3                              IN  VARCHAR2,
         p_unique4                              IN  VARCHAR2,
         p_unique5                              IN  VARCHAR2,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_collaboration_pt                     IN  VARCHAR2,
         p_notification_code                    IN  VARCHAR2,
         p_notification_desc                    IN  VARCHAR2,
         p_notification_status                  IN  VARCHAR2,
         p_notification_event                   IN  WF_EVENT_T DEFAULT NULL );


-- Name
--    PROCESS_NOTIF_BATCH_EVT
-- Purpose
--    This procedure handles a Batch notification request by executing all the actions
--    defined by the user for a given notification code.
--
-- Arguments
--
-- Notes
--    No specific notes

PROCEDURE PROCESS_NOTIF_BATCH_EVT(
      	  x_return_status                        OUT NOCOPY VARCHAR2,
      	  x_msg_data                             OUT NOCOPY VARCHAR2,
	  p_attribute_name			 IN  VARCHAR2,
	  p_attribute_value			 IN  VARCHAR2,
	  p_notification_receiver		 IN  VARCHAR2,
	  p_application_id                       IN  VARCHAR2,
	  p_collaboration_std  		         IN  VARCHAR2,
	  p_collaboration_type  		 IN  VARCHAR2,
	  p_collaboration_point  		 IN  VARCHAR2,
      	  p_notification_code                    IN  VARCHAR2,
      	  p_notification_msg                     IN  VARCHAR2,
      	  p_notification_status                  IN  VARCHAR2);



END CLN_NP_PROCESSOR_PKG;

 

/
