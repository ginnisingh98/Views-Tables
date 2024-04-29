--------------------------------------------------------
--  DDL for Package MSC_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_RULE" AUTHID CURRENT_USER AS
-- $Header: MSCRULES.pls 120.1 2005/06/20 23:53:33 appldev ship $

--
-- Inbound_Rule (PUBLIC)
--   Standard MSC Subscription rule function
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
-- NOTE:
--
--   VS - lets discuss not sure why we need this?
-- Standard msc rule function
function inbound_rule
	(
	p_subscription_guid	in	raw,
	p_event			in out nocopy	wf_event_t
	)
	return varchar2;

end msc_rule;

 

/
