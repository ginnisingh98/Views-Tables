--------------------------------------------------------
--  DDL for Package FND_LDAP_MAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LDAP_MAPPER" AUTHID CURRENT_USER as
/* $Header: AFSCOLMS.pls 120.2.12000000.1 2007/01/18 13:26:45 appldev ship $ */
/*
** This package provides utility APIs  for mapping to and from
** LDAP attributes to other systems.
**
**  @rep:scope private
**  @rep:product FND
**  @rep:displayname FND _LDAP MAPPER
**  @rep:category BUSINESS_ENTITY FND_SSO_MANAGER
**
*/

function map_sso_user_profiles(p_user_name in varchar2)
  return fnd_oid_util.apps_sso_user_profiles_type;
--
---------------------------------------------------------------------------------
/*
** Name      : map_wf_entity_changes_rec
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure map_entity_changes_rec(
  p_entity_changes_rec  in out  nocopy  fnd_oid_util.wf_entity_changes_rec_type
);
--
-------------------------------------------------------------------------------
/*
** Name      : map_ldap_attr_list
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure map_ldap_attr_list(
    p_entity_type       in            wf_attribute_cache.entity_type%type
  , p_entity_key_value  in            wf_attribute_cache.entity_key_value%type
  , p_ldap_key          in out nocopy fnd_oid_util.ldap_key_type
  , p_ldap_attr_list    out    nocopy ldap_attr_list
);
--
-------------------------------------------------------------------------------
/*
** Name      : map_ldap_message
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure map_ldap_message(
    p_wf_event      in wf_event_t
  , p_event_type    in varchar2
  , p_ldap_message  in out nocopy fnd_oid_util.ldap_message_type
);
--
-------------------------------------------------------------------------------
/*
** Name      : map_ldap_message
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure map_ldap_message(
    p_user_name     in  fnd_user.user_name%type
  , p_ldap_attr_list   in ldap_attr_list
  , p_ldap_message  in out nocopy fnd_oid_util.ldap_message_type
);
--
-------------------------------------------------------------------------------
/*
** Name      : map_oid_event
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure map_oid_event(
    p_ldap_key            in          fnd_oid_util.ldap_key_type
  , p_entity_changes_rec  in          fnd_oid_util.wf_entity_changes_rec_type
  , p_ldap_attr_list      in          ldap_attr_list
  , p_event               out nocopy  ldap_event
);

-----------------------------------------------------------------------------
end fnd_ldap_mapper;

 

/
