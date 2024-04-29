--------------------------------------------------------
--  DDL for Package EDR_PSIG_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_PSIG_RULE" AUTHID CURRENT_USER AS
/* $Header: EDRRULES.pls 120.0.12000000.1 2007/01/18 05:55:00 appldev ship $

/* Signature Rule function
   IN:
   p_subscription_guid  GUID of Subscription to be processed
   p_event              Event to be processes
*/

function PSIG_RULE
	(
	p_subscription_guid	in	raw,
	p_event			in out NOCOPY wf_event_t
	) return varchar2;



end EDR_PSIG_rule;

 

/
