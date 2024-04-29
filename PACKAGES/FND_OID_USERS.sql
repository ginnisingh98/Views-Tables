--------------------------------------------------------
--  DDL for Package FND_OID_USERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OID_USERS" AUTHID CURRENT_USER as
/* $Header: AFSCOURS.pls 120.3 2005/11/03 16:11:33 ssallaka noship $ */
--
/*****************************************************************************/
-- Start of Package Globals

  G_PERSON                          constant varchar2(6) := 'PERSON';
  G_LOCATION                        constant varchar2(8) := 'LOCATION';
  G_BUSINESS                        constant varchar2(8) := 'BUSINESS';
  G_PERSONAL                        constant varchar2(8) := 'PERSONAL';
  G_GEN                             constant varchar2(3) := 'GEN';
  G_PHONE                           constant varchar2(5) := 'PHONE';
  G_EMAIL                           constant varchar2(5) := 'EMAIL';

  G_HZ_GENERATE_PARTY_NUMBER        constant varchar2(24) := 'HZ_GENERATE_PARTY_NUMBER';
  G_HZ_GENERATE_PS_NUMBER           constant varchar2(29) := 'HZ_GENERATE_PARTY_SITE_NUMBER';
  G_FND_OID_SYNCH                   constant varchar2(13) := 'FND_OID_SYNCH';
  G_HZ_PARTIES                      constant varchar2(10) := 'HZ_PARTIES';
  G_HZ_CONTACT_POINTS               constant varchar2(17) := 'HZ_CONTACT_POINTS';
  G_HZ_PARTY_SITES                  constant varchar2(14) := 'HZ_PARTY_SITES';

  G_ACTIVE                          constant varchar2(1) := 'A';
  G_INACTIVE                        constant varchar2(1) := 'I';
  G_YES                             constant varchar2(1) := 'Y';
  G_NO                              constant varchar2(1) := 'N';
  G_UPDATE                          constant varchar2(6) := 'UPDATE';
  G_CREATE                          constant varchar2(6) := 'CREATE';
  G_UNKNOWN			    constant varchar2(10) := '*UNKNOWN*';

-- End of Package Globals
--
--
/*
** Name        : hz_create
** Type        : Public, FND Internal
** Desc        : Creates TCA entitites to reflect an OID user
** Pre-Reqs    :
** Parameters  :
**    p_ldap_msg -- Contains LDAP attributes
** Notes       :
*/
procedure hz_create(
        p_ldap_message in fnd_oid_util.ldap_message_type,
        x_return_status out nocopy varchar2);
--
--
/*
** Name       : create_party
** Type       : Public, FND Internal
** Desc       : Creates a person
** Pre-Reqs   :
** Parameters :
**    p_ldap_msg -- Contains LDAP attributes
** Notes      :
*/
procedure create_party(
     p_ldap_message	   in fnd_oid_util.ldap_message_type,
     x_return_status   out nocopy varchar2);

--
--
/*
** Name       : create_phone_contact_point
** Type       : Public, FND Internal
** Desc       : Creates a contact point of type 'PHONE'
** Pre-Reqs   :
** Parameters :
**    p_ldap_msg -- Contains LDAP attributes
**    p_contact_point_purose -- BUSINESS or PERSONAL
** Notes      :
*/
procedure create_phone_contact_point(
     p_ldap_message	          in fnd_oid_util.ldap_message_type,
     p_contact_point_purpose  in varchar2,
     x_return_status          out nocopy varchar2);
--
--
procedure create_email_contact_point(
     p_ldap_message	        in fnd_oid_util.ldap_message_type,
     x_return_status          out nocopy varchar2);
--
--
procedure create_location(
     p_ldap_message     in fnd_oid_util.ldap_message_type,
     x_return_status    out nocopy varchar2);
--
--
procedure create_party_site(
     p_ldap_message     in fnd_oid_util.ldap_message_type,
     p_location_id      in number,
     x_return_status    out nocopy varchar2);
--
--
procedure hz_update(
     p_ldap_message     in fnd_oid_util.ldap_message_type,
     x_return_status    out nocopy varchar2);
--
--
procedure update_party(
     p_ldap_message     in fnd_oid_util.ldap_message_type,
     x_return_status    out  nocopy varchar2);
--
--
procedure update_phone_contact_point(
     p_ldap_message           in fnd_oid_util.ldap_message_type,
     p_contact_point_purpose  in varchar2,
     x_return_status          out  nocopy varchar2);
--
--
procedure update_email_contact_point(
     p_ldap_message     in fnd_oid_util.ldap_message_type,
     x_return_status    out  nocopy varchar2);
--
--
procedure update_party_site(
     p_ldap_message     in fnd_oid_util.ldap_message_type,
     x_return_status    out  nocopy varchar2);
--
--
procedure get_person_rec(
     p_ldap_message	    in fnd_oid_util.ldap_message_type,
     p_action_type      in varchar2,
     x_person_rec	      out nocopy hz_party_v2pub.person_rec_type,
     x_return_status    out  nocopy varchar2);
--
--
procedure get_contact_point_rec(
     p_ldap_message           in fnd_oid_util.ldap_message_type,
     p_contact_point_type     in varchar2,
     p_contact_point_purpose  in varchar2,
     p_action_type            in varchar2,
     x_contact_point_rec      out nocopy
     hz_contact_point_v2pub.contact_point_rec_type,
     x_return_status          out  nocopy varchar2);
--
--
procedure get_location_rec(
     p_ldap_message	    in fnd_oid_util.ldap_message_type,
     x_location_rec	    out nocopy hz_location_v2pub.location_rec_type);
--
--
procedure get_party_site_rec(
     p_ldap_message	    in fnd_oid_util.ldap_message_type,
     p_action_type      in varchar2,
     x_party_site_rec	  out nocopy hz_party_site_v2pub.party_site_rec_type,
     x_return_status    out  nocopy varchar2);
--
--
procedure get_orig_system_ref(
     p_ldap_message	    in fnd_oid_util.ldap_message_type,
     p_tag	            in varchar2,
     x_reference        out  nocopy varchar2);
--
--
procedure create_orig_system_reference(
     p_ldap_message	    in fnd_oid_util.ldap_message_type,
     p_tag              in varchar2,
     p_owner_table_name in varchar2,
     p_owner_table_id   in number,
     p_status           in varchar2,
     x_return_status    out  nocopy varchar2);
--
--
procedure update_orig_system_reference(
     p_ldap_message	    in fnd_oid_util.ldap_message_type,
     p_tag              in varchar2,
     p_owner_table_name in varchar2,
     p_owner_table_id   in number default null,
     p_status           in varchar2,
     x_return_status    out  nocopy varchar2);
--
--
procedure test;
--
--
end fnd_oid_users;

 

/
