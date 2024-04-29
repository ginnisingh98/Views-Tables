--------------------------------------------------------
--  DDL for Package WF_EVENT_PING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_PING_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVPNGS.pls 120.1 2005/07/02 03:14:37 appldev ship $ */
------------------------------------------------------------------------------
/*
** launch_processes - Loops through all external agents
**			creates  1 child process/external agent to ping
**
**
**
*/
procedure LAUNCH_PROCESSES (
  ITEMTYPE	in	varchar2,
  ITEMKEY	in	varchar2,
  ACTID		in	number,
  FUNCMODE	in	varchar2,
  RESULTOUT	out nocopy varchar2
);
------------------------------------------------------------------------------
/*
** acknowledge - Repackages payload to send event back to From Agent and to be
**		 of event type oracle.apps.wf.event.agent.ack
**
**
**
*/
function ACKNOWLEDGE (
 P_SUBSCRIPTION_GUID	in	raw,
 P_EVENT		in out nocopy wf_event_t
) return varchar2;
------------------------------------------------------------------------------
end WF_EVENT_PING_PKG;

 

/
