--------------------------------------------------------
--  DDL for Package WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_UTIL" AUTHID CURRENT_USER as
/* $Header: WFUTILS.pls 120.5 2005/10/28 11:25:15 dlam ship $ */
--------------------------------------------------------------------------
/*
** call_me_later - Executes your callback at the specified future date,
**                 passing in the specified parameter list.
**
**                 It does this by embedding the information into the
**                 standard oracle.apps.wf.callback.delay event and
**                 placing it on the deferred queue,
**
**                 The callback parameter must be fully described as
**                 <package>.<routine> and your routine must have the
**                 following spec:
**
**  PROCEDURE callback(p_parameters in wf_parameter_list_t default null);
**
**                 Include any parameters you think your callback will
**                 need to do its job.
*/
PROCEDURE call_me_later(p_callback   in varchar2,
                        p_when       in date,
                        p_parameters in wf_parameter_list_t default null);
--------------------------------------------------------------------------
/*
** call_me_later_rf - Implements the rule-function for the standard
**                    subscription on the oracle.apps.wf.callback.delay
**                    event.  This rule-function is responsibile for
**                    calling the callback, passing in your parameter info.
*/
FUNCTION call_me_later_rf(p_subscription_guid in raw,
                          p_event in out nocopy wf_event_t) return varchar2;
--------------------------------------------------------------------------
end WF_UTIL;

 

/
