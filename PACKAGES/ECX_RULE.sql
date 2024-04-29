--------------------------------------------------------
--  DDL for Package ECX_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_RULE" AUTHID CURRENT_USER AS
-- $Header: ECXRULES.pls 120.1 2005/06/30 11:17:51 appldev ship $
null_trigger_id exception;
function outbound_rule
	(
	p_subscription_guid	in	raw,
	p_event			in out nocopy wf_event_t
	) return varchar2;

--
-- Inbound_Rule (PUBLIC)
--   Standard XML Gateway Subscription rule function
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
-- NOTE:
--
--   VS - lets discuss not sure why we need this?
-- Standard ecx rule function

function inbound_rule
	(
	p_subscription_guid	in	raw,
	p_event			in out nocopy wf_event_t
	)
	return varchar2;

-- Inbound_Rule2 (PUBLIC)
--   Another XML Gateway Subscription rule function (does no validation)
--      quick and dirty, useful for a2a.
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
--
-- Another inbound_rule function

function inbound_rule2 (p_subscription_guid  in      raw,
               p_event              in out nocopy wf_event_t) return varchar2;


function ReceiveTPMessage
  (
  p_subscription_guid in raw,
  p_event             in out nocopy wf_event_t
  )
  return varchar2;

function CreateTPMessage (
  p_subscription_guid  in      raw,
  p_event              in out nocopy wf_event_t
) return varchar2;

function isTPEnabled (
  p_transaction_type     in varchar2,
  p_transaction_subtype  in varchar2,
  p_standard_code        in varchar2,
  p_standard_type        in varchar2,
  p_party_site_id        in varchar2,
  x_queue_name           out nocopy varchar2,
  x_tp_header_id         out nocopy number)
return boolean;

function TPPreProcessing (
  p_subscription_guid  in      raw,
  p_event              in out nocopy wf_event_t
) return varchar2;


end ecx_rule;

 

/
