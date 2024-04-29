--------------------------------------------------------
--  DDL for Package AMW_SECURITY_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SECURITY_UTILS_PVT" AUTHID CURRENT_USER AS
/*$Header: amwsutls.pls 120.0 2005/06/15 18:02:42 appldev noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_SECURITY_UTILS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwsutls.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

G_API_VERSION CONSTANT NUMBER := 1.0;


procedure give_dependant_grants (p_grant_guid in raw,
                                 p_parent_obj_name in varchar2,
                                 p_parent_role in varchar2,
                                 p_parent_pk1 in varchar2,
                                 p_parent_pk2 in varchar2,
                                 p_parent_pk3 in varchar2,
                                 p_parent_pk4 in varchar2,
                                 p_parent_pk5 in varchar2,
                                 p_grantee_type in varchar2,
                                 p_grantee_key in varchar2,
                                 p_start_date in date,
                                 p_end_date in date,
                                 x_success  OUT NOCOPY VARCHAR, /* Boolean */
                                 x_errorcode OUT NOCOPY NUMBER);


procedure update_dependant_grants(p_grant_guid in raw,
                                  p_new_start_date in date,
                                  p_new_end_date in date,
                                  x_success  OUT NOCOPY VARCHAR /* Boolean */);

procedure revoke_dependant_grants(p_grant_guid in raw,
                                  x_success        OUT NOCOPY VARCHAR2, /* Boolean */
                                  x_errorcode      OUT NOCOPY NUMBER);


FUNCTION get_party_id return number;


FUNCTION check_function
  (
   p_function            IN  VARCHAR2,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2,
   p_instance_pk3_value  IN  VARCHAR2,
   p_instance_pk4_value  IN  VARCHAR2,
   p_instance_pk5_value  IN  VARCHAR2
 )
 RETURN VARCHAR2;

END AMW_SECURITY_UTILS_PVT;

 

/
