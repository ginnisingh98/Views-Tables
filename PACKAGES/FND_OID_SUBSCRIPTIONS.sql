--------------------------------------------------------
--  DDL for Package FND_OID_SUBSCRIPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OID_SUBSCRIPTIONS" AUTHID CURRENT_USER as
/* $Header: AFSCOSBS.pls 120.3.12010000.3 2015/09/01 22:25:14 ctilley ship $ */
--
/*****************************************************************************/
-- Start of Package Globals

-- End of Package Globals
--
--
/*
** Name      : entity_changes
** Type      : Public, FND Internal
** Desc      : This proc "queues" up the user change for OID. Also, detects
**   future dated changes and queues real events to pick them up when ready.
** Pre-Reqs   :
** Parameters  :
**   p_userguid -- User GUID as stored in OID.
**
** Notes     :
*/
function identity_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function identity_modify(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function identity_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function subscription_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function subscription_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function on_demand_user_create(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2;
--
-------------------------------------------------------------------------------
function event_error(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function event_resend(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function hz_identity_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2;
--
-------------------------------------------------------------------------------
function hz_identity_modify(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function hz_identity_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function hz_subscription_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2;
--
-------------------------------------------------------------------------------
function hz_subscription_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2;
--
-------------------------------------------------------------------------------
function synch_oid_to_tca(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2;
--
-------------------------------------------------------------------------------
procedure assign_default_resp(p_user_name in varchar2);
--
-------------------------------------------------------------------------------
procedure get_resp_app_id(p_resp_key in fnd_responsibility.responsibility_key%type
                        , x_responsibility_id out nocopy fnd_responsibility.responsibility_id%type
                        , x_application_id out nocopy fnd_responsibility.application_id%type);
--
-------------------------------------------------------------------------------
function assign_def_resp(
     p_subscription_guid in            raw
   , p_event             in out nocopy wf_event_t)
    return varchar2;
------------------------------------------------------------------------------


function set_password_external(
     p_subscription_guid in            raw
   , p_event             in out nocopy wf_event_t)
    return varchar2;
------------------------------------------------------------------------------


end fnd_oid_subscriptions;

/
