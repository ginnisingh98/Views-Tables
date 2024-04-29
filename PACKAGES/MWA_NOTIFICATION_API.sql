--------------------------------------------------------
--  DDL for Package MWA_NOTIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MWA_NOTIFICATION_API" AUTHID CURRENT_USER as
/* $Header: MWANOTS.pls 120.1 2005/06/10 11:50:37 appldev  $ */

-- The following constant indicates how many chars we must escape.

NUM_RECORDS constant NUMBER := 33;

------------------------------------------------------------------------
-- Record type for url char replacement
------------------------------------------------------------------------
  TYPE escapeRec IS RECORD (
    replace_char VARCHAR(1),
    replacement_char VARCHAR(3));

  TYPE t_chars IS TABLE OF escapeRec
    INDEX BY binary_integer;

  escapeRecord t_chars;

  requestFailed exception;


------------------------------------------------------------------------------
-- Function
--   mwaNotify
--
-- Description
--  Called by workflow when a notification event is raised by a workflow
--
-- Input Paramters
--   p_subscription_guidr       Information called by workflow
--
--   p_event                    The actual event raised by a workflow that
--				wants to send a notification.
-- Returns
--   varchar2			Message indicating success or error.
------------------------------------------------------------------------------

function mwaNotify (
	p_subscription_guid  	IN   raw,
        p_event 		IN   OUT nocopy WF_EVENT_T)

	return varchar2 ;

------------------------------------------------------------------------------
-- Function
--   raiseNotification
--
-- Description
--  Called by a developer in the middle of a workflow if a notification event
--  should be sent to a mobile device.
--
-- Input Paramters
--   username   		The apps username to send the notifiation too
--
--   subject			The subject of the message
--
--   content			The body of the message.
------------------------------------------------------------------------------

procedure raiseNotification (username IN varchar2,
                             subject IN varchar2,
                             content IN varchar2) ;



function calculateLength (str IN varchar2) return varchar2 ;

function decodedLength (str in varchar2) return number ;

procedure fireNotification (subject IN varchar2,
                            username IN varchar2,
                            type in varchar2,
                            content in varchar2);


END MWA_NOTIFICATION_API;

 

/
