--------------------------------------------------------
--  DDL for Package FND_OID_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OID_UTIL" AUTHID CURRENT_USER as
/* $Header: AFSCOUTS.pls 120.5.12010000.4 2012/04/05 00:00:41 jvalenti ship $ */
--
/*****************************************************************************/

type ldap_user_type is record (
    object_name                 varchar2(1024)
  , sn                          varchar2(4000)
  , cn                          varchar2(4000)
  , userPassword                varchar2(4000)
  , telephoneNumber             varchar2(4000)
  , street                      varchar2(4000)
  , postalCode                  varchar2(4000)
  , physicalDeliveryOfficeName  varchar2(4000)
  , st                          varchar2(4000)
  , l                           varchar2(4000)
  , displayName                 varchar2(4000)
  , givenName                   varchar2(4000)
  , homePhone                   varchar2(4000)
  , mail                        varchar2(4000)
  , c                           varchar2(4000)
  , facsimileTelephoneNumber    varchar2(4000)
  , description                 varchar2(4000)
  , orclisEnabled               varchar2(4000)
  , orclActiveStartDate         varchar2(4000)
  , orclActiveEndDate           varchar2(4000)
  , orclGUID                    varchar2(4000)
);

type ldap_message_type is record (
    object_name                 varchar2(1024)
  , sn                          varchar2(4000)
  , cn                          varchar2(4000)
  , userPassword                varchar2(4000)
  , telephoneNumber             varchar2(4000)
  , street                      varchar2(4000)
  , postalCode                  varchar2(4000)
  , physicalDeliveryOfficeName  varchar2(4000)
  , st                          varchar2(4000)
  , l                           varchar2(4000)
  , displayName                 varchar2(4000)
  , givenName                   varchar2(4000)
  , homePhone                   varchar2(4000)
  , mail                        varchar2(4000)
  , c                           varchar2(4000)
  , facsimileTelephoneNumber    varchar2(4000)
  , description                 varchar2(4000)
  , orclisEnabled               varchar2(4000)
  , orclActiveStartDate         varchar2(4000)
  , orclActiveEndDate           varchar2(4000)
  , orclGUID                    varchar2(4000)
);

type ldap_key_type is record(
    sn                          varchar2(4000)
  , cn                          varchar2(4000)
  , orclGUID                    varchar2(4000)
  , orclActiveStartDate         varchar2(4000)
  , orclActiveEndDate           varchar2(4000)
  , orclisEnabled               varchar2(4000)
);

type apps_sso_user_profiles_type is record (
    ldap_sync     varchar2(1)
  , local_login   varchar2(10)
  , auto_link     varchar2(20)
);

type apps_user_key_type is record (
    user_guid       fnd_user.user_guid%type
  , user_id         fnd_user.user_id%type
  , user_name       fnd_user.user_name%type
  , person_party_id fnd_user.person_party_id%type
);

type wf_entity_changes_rec_type is record (
    entity_type           wf_entity_changes.entity_type%type
  , entity_key_value      wf_entity_changes.entity_key_value%type
  , flavor                wf_entity_changes.flavor%type
  , change_date           wf_entity_changes.change_date%type
  , entity_id             wf_entity_changes.entity_id%type
  , change_date_in_char   varchar2(30)
);

type wf_attribute_cache_rec_type is record(
    entity_type         wf_attribute_cache.entity_type%type
  , entity_key_value    wf_attribute_cache.entity_key_value%type
  , attribute_name      wf_attribute_cache.attribute_name%type
  , attribute_value     wf_attribute_cache.attribute_value%type
  , last_update_date    wf_attribute_cache.last_update_date%type
  , change_number       wf_attribute_cache.change_number%type
  , security_group_id   wf_attribute_cache.security_group_id%type
);

-- Start of Package Globals

  G_LDAP_MESSAGE_ATTR     ldap_message_type;

  G_USERPASSWORD          constant varchar2(30) := 'USERPASSWORD';
  G_ORCLISENABLED         constant varchar2(30) := 'ORCLISENABLED';
  G_OBJECTCLASS           constant varchar2(30) := 'OBJECTCLASS';
  G_ORCLGUID              constant varchar2(30) := 'ORCLGUID';
  G_SN                    constant varchar2(30) := 'SN';
  G_CN                    constant varchar2(30) := 'CN';
  G_ORCLACTIVESTARTDATE   constant varchar2(30) := 'ORCLACTIVESTARTDATE';
  G_ORCLACTIVEENDDATE     constant varchar2(30) := 'ORCLACTIVEENDDATE';
  G_MAIL                  constant varchar2(30) := 'MAIL';

  G_APPS_SSO_LDAP_SYNC      constant varchar2(30) := 'APPS_SSO_LDAP_SYNC';
  G_APPS_SSO_LOCAL_LOGIN    constant varchar2(30) := 'APPS_SSO_LOCAL_LOGIN';
  G_APPS_SSO_AUTO_LINK_USER constant varchar2(30) := 'APPS_SSO_AUTO_LINK_USER';

  G_Y               constant varchar2(1) := 'Y';
  G_N               constant varchar2(1) := 'N';
  G_YES             constant varchar2(3) := 'YES';
  G_NO              constant varchar2(3) := 'NO';


  G_LOCAL           constant varchar2(5) := 'LOCAL';
  G_BOTH            constant varchar2(5) := 'BOTH';
  G_SSO             constant varchar2(5) := 'SSO';

  G_USER            constant varchar2(4) := 'USER';
  G_OID             constant varchar2(3) := 'OID';
  G_DELETE          constant varchar2(6) := 'DELETE';
  G_LOAD            constant varchar2(4) := 'LOAD';

  G_CACHE_CHANGED   constant varchar2(30) := 'CACHE_CHANGED';
  G_EXTERNAL        constant varchar2(30) := 'EXTERNAL';

  G_NULL            constant varchar2(30) := '*NULL*';
  G_DATE_FORMAT     constant varchar2(30) := 'YYYYMMDDHH24MISS';

  G_INVALID         constant varchar2(30) := 'INVALID';
  G_DISABLED        constant varchar2(30) := 'DISABLED';

  G_EBIZ            constant varchar2(30) := 'EBIZ';
  G_ENABLED         constant varchar2(30) := 'ENABLED';

  G_YYYYMMDDHH24MISS  constant varchar2(30) := 'YYYYMMDDHH24MISS';
  G_NOT_FOR_IMPORT    constant varchar2(80) :='NOT required for Import';

  G_SUBSCRIPTION_DOT_ADD    constant varchar2(30) := 'subscription.add';
  G_SUBSCRIPTION_DOT_DELETE constant varchar2(30) := 'subscription.delete';

  G_ORACLE_APPS_GLOBAL  constant varchar2(80) := 'oracle.apps.fnd.';
  G_CHANGE_SOURCE       constant varchar2(30) := 'CHANGE_SOURCE';

  G_SUCCESS             constant  varchar2(30) := 'SUCCESS';

  G_CUST            constant  varchar2(4) := 'CUST';

  event_not_found_exp   exception;
  user_name_null_exp exception;
  user_guid_null_exp exception;
  user_subs_data_corrupt_exp exception;

-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : get_oid_user_name
** Type      : Public, FND Internal
** Desc      : This function returns OID user name for given GUID
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function get_oid_nickname(p_user_guid in fnd_user.user_guid%type)
return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : unbind
** Type      : Public, FND Internal
** Desc      : This function unbinds an ldap_session
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function unbind(p_session in out nocopy dbms_ldap.session) return pls_integer;
--
-------------------------------------------------------------------------------
/*
** Name      : get_orclappname
** Type      : Public, FND Internal
** Desc      : This function returns orclAppName from Workflow
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function get_orclappname return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : entity_changes
** Type      : Public, FND Internal
** Desc      : This proc "queues" up the user change for OID. Also, detects
**   future dated changes and queues real events to pick them up when ready.
** Pre-Reqs   :
** Parameters  :
**   p_userguid -- User GUID as stored in OID.
** Notes     : Originally WF_OID.entchanges(p_username in varchar2)
*/
procedure entity_changes(p_username in varchar2);
--
-------------------------------------------------------------------------------
/*
** Name        : synch_user_from_LDAP
** Type        : Public, FND Internal
** Desc        : This procedure takes a fnd_user username as input. It retrieves
**               the user information from OID and tries to create a new TCA record. If
**               one already exists then it simply updates the existing record.
**               Refer to 4325421
** Pre-Reqs    :
** Parameters  :
**  p_user_name: user whose attributes need to be synchronized with TCA
**  p_result : result of the operation
*/
procedure synch_user_from_LDAP( p_user_name   in  fnd_user.user_name%type,
                                p_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name        : synch_user_from_LDAP
** Type        : Public, FND Internal
** Desc        : This procedure takes a fnd_user username as input. It retrieves
**               the user information from OID and tries to create a new TCA record. If
**               one already exists then it simply updates the existing record. This procedure
**               performs the above in the same transaction.
**               Refer to 4325421, 4576676
** Pre-Reqs    :
** Parameters  :
**  p_user_name: user whose attributes need to be synchronized with TCA
**  p_result : result of the operation
*/
procedure synch_user_from_LDAP_NO_AUTO( p_user_name   in  fnd_user.user_name%type,
                                p_result out nocopy pls_integer);

--
-------------------------------------------------------------------------------
/*
** Name        : on_demand_user_create
** Type        : Public, FND Internal
** Desc        : This procedure creates a user in fnd_user by invoking the
**               fnd_user_pkg api and then raises a business event.
**               This procedure is called from the apps success url for creation
**               apps user on demand. Refer to 4097060
** Pre-Reqs    :
** Parameters  :
**  p_user_name: user who has to created in apps
**   p_userguid: -- User GUID as stored in OID.
*/
procedure on_demand_user_create(p_user_name in varchar2, p_user_guid in varchar2);
--
-------------------------------------------------------------------------------
/*
** Name      : get_user_attributes
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
**  p_userguid  --  User GUID as stored in OID.
**  p_user_name --  The UID of the user that will be saved as the user_name
**    in table fnd_user
** Notes     : Originally
**   WF_OID.getUserAtts(p_userguid in varchar2) return ldap_attr_list
*/
function get_user_attributes(
    p_userguid  in          varchar2
  , p_user_name out nocopy  varchar2
) return ldap_attr_list;
--
-------------------------------------------------------------------------------
/*
** Name      : get_ldap_event_str
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
** Notes     : Originally procedure
**   WF_OID.DumpEventHeader(event in ldap_event)
*/
function get_ldap_event_str(p_ldap_event in ldap_event)
  return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_ldap_attr_str
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
** Notes     : Originally procedure
**   WF_OID.DumpAttribute(attr in ldap_attr)
*/
function get_ldap_attr_str(p_ldap_attr in ldap_attr)
  return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_ldap_event_status_str
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_ldap_event_status_str(p_ldap_event_status in ldap_event_status)
  return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : process_identity_add
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure process_identity_add(p_event in ldap_event);
--
-------------------------------------------------------------------------------
/*
** Name      : process_identity_modify
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure process_identity_modify(p_event in ldap_event);
--
-------------------------------------------------------------------------------
/*
** Name      : process_identity_delete
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure process_identity_delete(p_event in ldap_event);
--
-------------------------------------------------------------------------------
/*
** Name      : process_subscription_add
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure process_subscription_add(p_event in ldap_event);
--
-------------------------------------------------------------------------------
/*
** Name      : process_subscription_delete
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure process_subscription_delete(p_event in ldap_event);
--
-------------------------------------------------------------------------------
/*
** Name      : process_no_success_event
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure process_no_success_event(p_event_status in ldap_event_status);
--
-------------------------------------------------------------------------------
/*
** Name      : save_to_cache
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure save_to_cache(
    p_ldap_attr_list    in  ldap_attr_list
  , p_entity_type       in  varchar2
  , p_entity_key_value  in  varchar2
);
--
-------------------------------------------------------------------------------
/*
** Name      : get_entity_key_value
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure get_entity_key_value(
    p_event_id          in          wf_entity_changes.entity_id%type
  , p_entity_key_value  out nocopy  wf_entity_changes.entity_key_value%type
);
--
-------------------------------------------------------------------------------
/*
** Name      : get_key
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_key return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_oid_session
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_oid_session
  return dbms_ldap.session;

--
-------------------------------------------------------------------------------
/*
** Name      : get_entity_changes_rec_str
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_entity_changes_rec_str(
  p_entity_changes_rec in wf_entity_changes_rec_type)
  return varchar2;

--
-------------------------------------------------------------------------------
/*
** Name      : get_fnd_user
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_fnd_user(p_user_guid in varchar2)
  return apps_user_key_type;
--
-------------------------------------------------------------------------------
/*
** Name      : person_party_exists
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function person_party_exists(p_user_name in varchar2)
  return boolean;
--
-------------------------------------------------------------------------------
/*
** Name      : get_fnd_user
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_fnd_user(p_user_name in varchar2)
  return apps_user_key_type;
--
-------------------------------------------------------------------------------
/* Name   :  send_subscription_add_to_OID
** Type   : Public FND Internal
** Parameters : p_user_name
*/
procedure send_subscription_add_to_OID
(p_orcl_guid    fnd_user.user_guid%type);
--
-------------------------------------------------------------------------------
/*
** Name      : isUserEnabled
** Type      : Public, FND Internal
** Desc      : Determines whether OID user is enabled
** Pre-Reqs  :
** Parameters : p_ldap_attr_list - attribute list for the user
*/
function isUserEnabled(p_ldap_attr_list in ldap_attr_list)
  return boolean;
--
-------------------------------------------------------------------------------
/*
** Name      : add_user_to_OID_sub_list
** Type      : Public, FND Internal
** Desc      : Synchronously adds user to the subscription list in OID
** Pre-Reqs   :
** Parameters : p_orclguid - GUID of the user
**		x_result - fnd_ldap_util.G_SUCCESS if success
**			 - fnd_ldap_util.G_FAILURE otherwise
*/
procedure add_user_to_OID_sub_list(p_orclguid in fnd_user.user_guid%type,
  x_result out nocopy pls_integer);

/*
 * ** Name      : isTCAenabled
 * ** Type      : Public, FND Internal
 * ** Desc      : Determines whether the TCA event is enabled
 * ** Pre-Reqs   :
 * ** Parameters : p_action - Event action - ADD,MODIFY,DELETE
 * **              result -   TRUE/FALSE
 * */
function isTCAenabled (p_action in varchar2) return boolean;
--
-------------------------------------------------------------------------------
end fnd_oid_util;

/
