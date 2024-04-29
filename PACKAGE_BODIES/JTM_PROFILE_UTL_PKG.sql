--------------------------------------------------------
--  DDL for Package Body JTM_PROFILE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_PROFILE_UTL_PKG" AS
/* $Header: jtmpfutb.pls 120.1 2005/08/24 02:17:17 saradhak noship $ */

G_PKG_NAME             CONSTANT VARCHAR2(30):='JTM_PROFILE_UTL_PKG';
G_APP_EABLE_PROF_NAME  CONSTANT VARCHAR2(30):='JTM_MOB_APPS_ENABLED';

FUNCTION Get_app_level_profile_value(
          p_profile_name in varchar2,
          p_app_short_name in varchar2) return varchar2
IS
     Cursor c_get_app_id is
     select application_id
     from fnd_application
     where application_short_name = p_app_short_name;

     l_app_id number;
     l_profile_value varchar2(200);

BEGIN
     open c_get_app_id;
     fetch c_get_app_id into l_app_id;
     if (c_get_app_id%notfound) then
        close c_get_app_id;
        return null;
     end if;
     close c_get_app_id;

     l_profile_value := fnd_profile.VALUE_SPECIFIC(
          Name => p_profile_name, APPLICATION_ID => l_app_id);
     return l_profile_value;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_app_level_profile_value;


FUNCTION Get_app_enable_flag( p_app_short_name IN varchar2 )
    return varchar2 IS

   l_api_name             CONSTANT VARCHAR2(30) := 'GET_APPL_ENABLE_FLAG';
   l_api_version          CONSTANT NUMBER := 1.0;
   l_app_enable_flag      varchar2(20);
BEGIN
     /* get the JTM profile value */
     l_app_enable_flag := Get_app_level_profile_value(
            G_APP_EABLE_PROF_NAME,'JTM' );

     if ( p_app_short_name = 'JTM' ) then
         return l_app_enable_flag;
     end if;

    /* If JTM profile is trun off, it also turns off other mobile appl profile*/
     if ( l_app_enable_flag IS NULL OR l_app_enable_flag <> 'Y' ) then
         return l_app_enable_flag;
     end if;

     /* now profile value for JTM is Y. Get the requested value.*/
     l_app_enable_flag := Get_app_level_profile_value(
             G_APP_EABLE_PROF_NAME,
             p_app_short_name );
     return l_app_enable_flag;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_app_enable_flag;


FUNCTION Get_app_enable_flag(p_resp_id in number, p_app_id in number)
return varchar2 IS
     l_app_enable_flag varchar2(20);
BEGIN
     /* get the JTM profile value */
     l_app_enable_flag := Get_app_level_profile_value(
            G_APP_EABLE_PROF_NAME,'JTM' );

     /* If JTM profile is trun off, it also turns off other mobile appl profile*/
     if ( l_app_enable_flag IS NULL OR l_app_enable_flag <> 'Y' ) then
         return l_app_enable_flag;
     end if;

     /* profile value for JTM is Y*/
     l_app_enable_flag := fnd_profile.VALUE_SPECIFIC(
         Name => G_APP_EABLE_PROF_NAME
         ,APPLICATION_ID => p_app_id
         ,RESPONSIBILITY_ID => p_resp_id);

     return l_app_enable_flag;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_app_enable_flag;


FUNCTION Get_enable_flag_at_resp(
    p_resp_id in number,
    p_app_short_name IN varchar2)
RETURN varchar2 IS
     Cursor c_get_app_id is
     select application_id
     from fnd_application
     where application_short_name = p_app_short_name;

     l_app_id number;
     l_resp_id number := null;
     l_app_enable_flag varchar2(20);
BEGIN
     l_app_enable_flag := Get_app_level_profile_value(
            G_APP_EABLE_PROF_NAME, 'JTM' );

     /* If JTM profile is trun off, it also turn off other mobile appl profile*/
     if ( l_app_enable_flag IS NULL OR l_app_enable_flag <> 'Y' ) then
         return l_app_enable_flag;
     end if;

     /* now profile value for JTM is Y*/
     open c_get_app_id;
     fetch c_get_app_id into l_app_id;
     if (c_get_app_id%notfound) then
        close c_get_app_id;
        return null;
     end if;
     close c_get_app_id;

     if (p_resp_id = fnd_api.g_miss_num) then
        if (p_app_short_name = 'CSL' ) then
           l_resp_id := 22916;
        --elsif (p_app_short_name = 'CSM' ) then
        --   l_resp_id := ?;
        else /* for other applications */
           l_resp_id := null;
        end if;
     else
        l_resp_id := p_resp_id;
     end if;

     l_app_enable_flag := fnd_profile.VALUE_SPECIFIC(
         Name => G_APP_EABLE_PROF_NAME
         ,APPLICATION_ID => l_app_id
         ,RESPONSIBILITY_ID => l_resp_id);
     return l_app_enable_flag;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_enable_flag_at_resp;

FUNCTION Get_enable_flag_at_resp(
    p_resp_key in VARCHAR2,
    p_app_short_name IN varchar2) return varchar2
IS
     Cursor c_get_resp_id (p_resp_key in varchar2) is
     select responsibility_id
     from fnd_responsibility
     where responsibility_key = p_resp_key;

     l_resp_id number := null;
     l_resp_key varchar2(80);
     l_app_enable_flag varchar2(20);
BEGIN
     if (p_resp_key IS NULL) then
        if (p_app_short_name = 'CSL' ) then
           l_resp_key := 'CSL_IMOBILE';
        elsif ( p_app_short_name = 'CSM' ) then
           l_resp_key := 'OMFS_PALM';
        else /* for other applications */
           l_resp_key := null;
        end if;
     else
        l_resp_key := p_resp_key;
     end if;

     open c_get_resp_id(l_resp_key);
     fetch c_get_resp_id into l_resp_id;
     if (c_get_resp_id%notfound) then
        close c_get_resp_id;
        --return null;
     end if;
     close c_get_resp_id;

     l_app_enable_flag := Get_enable_flag_at_resp
           (l_resp_id, p_app_short_name);
     return l_app_enable_flag;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_enable_flag_at_resp;


FUNCTION Get_enable_flag_at_resp(
    p_app_short_name IN varchar2) return varchar2
IS
     Cursor c_get_resp_id (p_resp_key in varchar2) is
     select responsibility_id
     from fnd_responsibility
     where responsibility_key = p_resp_key;

     l_resp_id number := null;
     l_resp_key varchar2(80);
     l_app_enable_flag varchar2(20);
BEGIN
     if (p_app_short_name = 'CSL' ) then
        l_resp_key := 'CSL_IMOBILE';
     elsif ( p_app_short_name = 'CSM' ) then
        l_resp_key := 'OMFS_PALM';
     else /* for other applications */
        l_resp_key := null;
     end if;

     open c_get_resp_id(l_resp_key);
     fetch c_get_resp_id into l_resp_id;
     if (c_get_resp_id%notfound) then
        close c_get_resp_id;
        --return null;
     end if;
     close c_get_resp_id;

     l_app_enable_flag := Get_enable_flag_at_resp
           (l_resp_id, p_app_short_name);
     return l_app_enable_flag;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_enable_flag_at_resp;


END JTM_PROFILE_UTL_PKG;

/
