--------------------------------------------------------
--  DDL for Package Body JTF_TTY_MAINTAIN_NA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_MAINTAIN_NA_PVT" AS
/* $Header: jtftmnab.pls 120.17.12010000.2 2009/01/29 12:50:56 vpalle ship $ */
--    Start of Comments
--    PURPOSE
--      For handling Admin Excel Export functionalities like Add Org To
--      a territory group, update sales team, transfer
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      02/27/04   VXSRINIV     Created
--      03/09/04   SGKUMAR      Modified get_terr_grp_details to set the x_return
--                              _status appropriately.
--                              Modified assign_ua_acct_to_tgowners to use correct
--                              data type for role code.
--     03/12/04   SGKUMAR       if party number is missing, give error message
--     03/25/04   SGKUMAR       Bug 3532370 fixed in update sales team API
--     02/28/05   SHLI          GSST decom
--    End of Comments
/* procedure to log error messages
*
*/
PROCEDURE put_jty_log(p_text VARCHAR2, p_module_name VARCHAR2, p_severity NUMBER) IS
 l_len        number;
 l_start      number  := 1;
 l_end        number  := 1;
 last_reached boolean := false;
BEGIN
 if (p_text is null or p_text='' or FND_LOG.G_CURRENT_RUNTIME_LEVEL < FND_LOG.LEVEL_STATEMENT)
 then
   return;
 end if;

 l_len:=nvl(length(p_text),0);

 if l_len <= 0 then
   return;
 end if;

 while true loop
  l_end:=l_start+250;

  if l_end >= l_len then
   l_end:=l_len;
   last_reached:=true;
  end if;
  -- hard coding as it is giving GSCC warning
  -- for now it is ok as only unexpected errors are generated
  if( p_severity >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.STRING(p_severity, p_module_name, substr(p_text, l_start, 250));
  end if;
  l_start:=l_start+250;
  if last_reached then
   exit;
  end if;
 end loop;

END put_jty_log;

--This procedure retrieves the Territory_Group_Account_Id, Territory_Group_Id
--and Named_Account_Id after validating the party and the territory_group.
PROCEDURE GET_TERR_GRP_ACCT_DETAILS(
   P_API_VERSION_NUMBER           IN         NUMBER,
   P_INIT_MSG_LIST                IN         VARCHAR2,
   P_COMMIT                       IN         VARCHAR2,
   P_VALIDATION_LEVEL             IN         NUMBER,
   P_PARTY_NUMBER                 IN         VARCHAR2,
   P_PARTY_SITE_ID                IN         NUMBER,
   P_TERR_GRP_NAME                IN         VARCHAR2,
   P_ATTRIBUTE1					  IN	   VARCHAR2,
   P_ATTRIBUTE2					  IN	   VARCHAR2,
   P_ATTRIBUTE3					  IN	   VARCHAR2,
   P_ATTRIBUTE4					  IN	   VARCHAR2,
   P_ATTRIBUTE5					  IN	   VARCHAR2,
   P_ATTRIBUTE6					  IN	   VARCHAR2,
   P_ATTRIBUTE7					  IN	   VARCHAR2,
   P_ATTRIBUTE8					  IN	   VARCHAR2,
   P_ATTRIBUTE9					  IN	   VARCHAR2,
   P_ATTRIBUTE10				  IN	   VARCHAR2,
   P_ATTRIBUTE11				  IN	   VARCHAR2,
   P_ATTRIBUTE12				  IN	   VARCHAR2,
   P_ATTRIBUTE13				  IN	   VARCHAR2,
   P_ATTRIBUTE14				  IN	   VARCHAR2,
   P_ATTRIBUTE15				  IN	   VARCHAR2,
   P_START_DATE					  IN OUT NOCOPY DATE,
   P_END_DATE					  IN OUT NOCOPY DATE,
   X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                    OUT NOCOPY NUMBER,
   X_MSG_DATA                     OUT NOCOPY VARCHAR2,
   X_TERR_GRP_ID                  OUT NOCOPY NUMBER,
   X_TERR_GRP_ACCT_ID             OUT NOCOPY NUMBER,
   X_NAMED_ACCT_ID                OUT NOCOPY NUMBER) IS

   l_party_number   VARCHAR2(30);
   l_tg_name        VARCHAR2(150);
   l_party_id       NUMBER;
   l_tg_id          NUMBER;
   l_na_id          NUMBER;
   l_tga_id         NUMBER;
   l_error_msg      VARCHAR2(250);
   l_tg_start_date		date;
   l_tg_end_date		date;

   --Cursor to validate party based on  party number : Single Row
   CURSOR c_validate_party(l_party_number VARCHAR2, l_party_site_id NUMBER) IS
   SELECT hzp.party_id
   FROM   hz_parties hzp
      ,   hz_party_sites hzps
   WHERE  hzp.party_number = l_party_number
   AND    hzp.party_id = hzps.party_id
   and    hzps.party_site_id = l_party_site_id
   AND    hzp.status = 'A';
--   AND    hzp.party_type = 'ORGANIZATION';


   --Cursor to validate territory group based on TG name : Single Row
   --Note: Joining with jtf_terr to stripe data by org
   --Note: Possible to have multiple TGs with same name, hence using ROWNUM
   CURSOR c_validate_tg(l_tg_name VARCHAR2) IS
   SELECT a.terr_group_id,
          a.active_from_date,
		  NVL( a.active_to_date, ADD_MONTHS(a.active_from_date,120) ) active_to_date
   FROM   jtf_tty_terr_groups a, jtf_terr_all b
   WHERE  a.parent_terr_id = b.terr_id
   AND    upper(a.terr_group_name) = upper(l_tg_name)
--   and    b.org_id =  FND_PROFILE.VALUE('ORG_ID')
   AND    a.self_service_type = 'NAMED_ACCOUNT'
   AND    a.active_from_date <= sysdate
   AND    (a.active_to_date is null or a.active_to_date >= sysdate)
   AND    rownum < 2;

   --Cursor to get NA id and TGA id for specified party and terr group: Single Row
   CURSOR c_get_all_ids(l_party_id NUMBER, l_party_site_id NUMBER, l_tg_id NUMBER)  IS
   SELECT na.named_account_id, tga.terr_group_account_id
   FROM   jtf_tty_named_accts na, jtf_tty_terr_grp_accts tga
   WHERE  na.party_id = l_party_id
   AND    na.party_site_id = l_party_site_id
   AND    tga.named_account_id = na.named_account_id
   AND    tga.terr_group_id = l_tg_id;

BEGIN

   l_party_number := nvl(P_PARTY_NUMBER, -999);
   OPEN c_validate_party(l_party_number, p_party_site_id);
   FETCH c_validate_party INTO l_party_id;

   --If party is not valid then set message and return
   IF c_validate_party%NOTFOUND THEN
      CLOSE c_validate_party;
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_PARTY');
      return;
   END IF;
   CLOSE c_validate_party;

   l_tg_name := nvl(P_TERR_GRP_NAME, -999);
   OPEN c_validate_tg(l_tg_name);
   FETCH c_validate_tg INTO l_tg_id, l_tg_start_date, l_tg_end_date;

   --If TG is not valid then set message and return
   IF c_validate_tg%NOTFOUND THEN
      CLOSE c_validate_tg;
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_FROM_TG');
      return;
   END IF;
   CLOSE c_validate_tg;

   -- added 06/05/2006 bug 5246668, to validate and set date
   IF p_start_date is null THEN
     IF (TRUNC(SYSDATE) > l_tg_start_date) THEN
	   p_start_date := TRUNC(SYSDATE);
	 ELSE
	   p_start_date := l_tg_start_date;
	 END IF;
   ELSE
     IF (p_start_date < l_tg_start_date) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TERR_STARTDATE_NOT_VALID');
       return;
	 END IF;
   END IF;

   IF p_end_date is null THEN
     IF (ADD_MONTHS(NVL(P_START_DATE,TRUNC(SYSDATE)), 12) > l_tg_end_date) THEN
	   p_end_date := l_tg_end_date;
	 ELSE
	   p_end_date := ADD_MONTHS(NVL(P_START_DATE,TRUNC(SYSDATE)), 12);
	 END IF;
   ELSE
     IF (p_end_date < l_tg_start_date OR p_end_date > l_tg_end_date) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TERR_ENDDATE_NOT_VALID');
       return;
	 END IF;
   END IF;

   -- end for bug 5246668, by mhtran

   --If TG and Party are valid then get TGA and NA ids
   OPEN c_get_all_ids(l_party_id, p_party_site_id, l_tg_id);
   FETCH c_get_all_ids into l_na_id, l_tga_id;

   --If matching NA and TGA ids do not exist then set message and return
   IF c_get_all_ids%NOTFOUND THEN
      CLOSE c_get_all_ids;
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_NO_TGA_MATCH');
      return;
   END IF;
   CLOSE c_get_all_ids;

   -- added 06/05/2006 bug 5246668, update attributes and date

     update jtf_tty_terr_grp_accts
     set ATTRIBUTE1 = P_ATTRIBUTE1,
         ATTRIBUTE2 = P_ATTRIBUTE2,
         ATTRIBUTE3 = P_ATTRIBUTE3,
         ATTRIBUTE4 = P_ATTRIBUTE4,
         ATTRIBUTE5 = P_ATTRIBUTE5,
         ATTRIBUTE6 = P_ATTRIBUTE6,
         ATTRIBUTE7 = P_ATTRIBUTE7,
         ATTRIBUTE8 = P_ATTRIBUTE8,
         ATTRIBUTE9 = P_ATTRIBUTE9,
         ATTRIBUTE10 = P_ATTRIBUTE10,
         ATTRIBUTE11 = P_ATTRIBUTE11,
         ATTRIBUTE12 = P_ATTRIBUTE12,
         ATTRIBUTE13 = P_ATTRIBUTE13,
         ATTRIBUTE14 = P_ATTRIBUTE14,
         ATTRIBUTE15 = P_ATTRIBUTE15,
         START_DATE = p_start_date,
         END_DATE = p_end_date
     where terr_group_account_id = l_tga_id
       and terr_group_id = l_tg_id;

   x_terr_grp_id := l_tg_id;
   x_terr_grp_acct_id := l_tga_id;
   x_named_acct_id := l_na_id;
   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );
      put_jty_log('Error in GET_TERR_GRP_ACCT_DETAILS: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
      return;
END GET_TERR_GRP_ACCT_DETAILS;

--This procedure deletes a named account from a territory group
PROCEDURE DELETE_ACCT_FROM_TG(
   P_API_VERSION_NUMBER           IN         NUMBER,
   P_INIT_MSG_LIST                IN         VARCHAR2,
   P_COMMIT                       IN         VARCHAR2,
   P_VALIDATION_LEVEL             IN         NUMBER,
   P_TERR_GRP_ACCT_ID             IN         NUMBER,
   P_TERR_GRP_ID                  IN         NUMBER,
   P_NAMED_ACCT_ID                IN         NUMBER,
   X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                    OUT NOCOPY NUMBER,
   X_MSG_DATA                     OUT NOCOPY VARCHAR2) IS

   l_user_id        NUMBER;
   l_login_id       NUMBER;
   l_error_msg      VARCHAR2(250);

BEGIN

   --Delete resource assignment for the TG account
   DELETE from jtf_tty_named_acct_rsc
   WHERE  terr_group_account_id = p_terr_grp_acct_id;

   --Delete TG account
   DELETE from JTF_TTY_TERR_GRP_ACCTS
   WHERE  terr_group_account_id = p_terr_grp_acct_id;

    --Delete this named account if it has no other TG references

   DELETE from JTF_TTY_NAMED_ACCTS
   WHERE  named_account_id = P_NAMED_ACCT_ID
   AND NOT EXISTS (SELECT named_account_id
                   from JTF_TTY_TERR_GRP_ACCTS a
                   where a.named_account_id = P_NAMED_ACCT_ID);

   --Delete the NA mappings if an NA is deleted or no reference to it exists

   DELETE from JTF_TTY_ACCT_QUAL_MAPS
   WHERE  named_account_id = P_NAMED_ACCT_ID
   AND  NOT EXISTS (SELECT named_account_id
                    from JTF_TTY_NAMED_ACCTS a
                    where a.named_account_id = P_NAMED_ACCT_ID);    --Delete named account if it has no other TG references

   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

   /* shli GSST Decom */
   /*--Insert row to track changes for GTP
   INSERT INTO jtf_tty_named_acct_changes
                  (NAMED_ACCT_CHANGE_ID,
                   OBJECT_VERSION_NUMBER,
                   OBJECT_TYPE,
                   OBJECT_ID,
                   CHANGE_TYPE,
                   FROM_WHERE,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN)
           VALUES (JTF_TTY_NAMED_ACCT_CHANGES_S.NEXTVAL,
                   1,
                   'TGA',
                   p_terr_grp_acct_id,
                   'DELETE',
                   'DELETE NA',
                   l_user_id,
                   sysdate,
                   l_user_id,
                   sysdate,
                   l_login_id);
   */
   x_return_status := fnd_api.g_ret_sts_success;

   JTF_TTY_GEN_TERR_PVT.delete_TGA(
     p_terr_grp_acct_id =>p_terr_grp_acct_id,
     p_terr_group_id    =>p_terr_grp_id,
     p_catchall_terr_id =>-1,
     p_change_type      =>'SALES_TEAM_UPDATE'
   );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );
      put_jty_log('Error in DELETE_ACCT_FROM_TG: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
      return;
END DELETE_ACCT_FROM_TG;




--This function returns the site type code for a party
FUNCTION GET_SITE_TYPE_CODE( P_PARTY_ID NUMBER ) RETURN VARCHAR2 IS

   l_site_type_code  VARCHAR2(30);
   l_chk_done        VARCHAR2(1) := 'N' ;

BEGIN

   hz_common_pub.disable_cont_source_security;

   --Check for global ultimate
   BEGIN
      SELECT 'Y' INTO l_chk_done FROM DUAL
      WHERE EXISTS (SELECT 'Y'
                    FROM hz_relationships hzr
                    WHERE hzr.subject_table_name = 'HZ_PARTIES'
                    AND hzr.object_table_name = 'HZ_PARTIES'
                    AND hzr.relationship_type = 'GLOBAL_ULTIMATE'
                    AND hzr.relationship_code = 'GLOBAL_ULTIMATE_OF'
                    AND hzr.status = 'A'
                    AND sysdate between hzr.start_date and nvl(hzr.end_date, sysdate)
                    AND hzr.subject_id = p_party_id );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
   END;

   IF l_chk_done = 'Y' THEN
      l_site_type_code := 'GU' ;
      RETURN l_site_type_code;
   END IF;

   --Check for domestic ultimate
   BEGIN
      SELECT 'Y' INTO l_chk_done FROM DUAL
      WHERE EXISTS (SELECT 'Y'
                    FROM hz_relationships hzr
                    WHERE hzr.subject_table_name = 'HZ_PARTIES'
                    AND hzr.object_table_name = 'HZ_PARTIES'
                    AND hzr.relationship_type = 'DOMESTIC_ULTIMATE'
                    AND hzr.relationship_code = 'DOMESTIC_ULTIMATE_OF'
                    AND hzr.status = 'A'
                    AND sysdate between hzr.start_date and nvl(hzr.end_date, sysdate)
                    AND hzr.subject_id = p_party_id );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
   END;

   IF l_chk_done = 'Y' THEN
      l_site_type_code := 'DU' ;
      RETURN l_site_type_code;
   END IF;

   BEGIN
      SELECT lkp.lookup_code INTO l_site_type_code
      FROM fnd_lookups lkp, hz_parties hzp
      WHERE lkp.lookup_type = 'JTF_TTY_SITE_TYPE_CODE'
      AND hzp.hq_branch_ind = lkp.lookup_code
      AND hzp.party_id = p_party_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_site_type_code := 'UN';
   END;

   RETURN(l_site_type_code);

EXCEPTION
   WHEN OTHERS THEN
        put_jty_log('Error in GET_SITE_TYPE_CODE: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);

END GET_SITE_TYPE_CODE;

--This procedure creates qualifier mappings for a named account
PROCEDURE CREATE_ACCT_MAPPINGS(
   P_API_VERSION_NUMBER           IN         NUMBER,
   P_INIT_MSG_LIST                IN         VARCHAR2,
   P_COMMIT                       IN         VARCHAR2,
   P_VALIDATION_LEVEL             IN         NUMBER,
   P_ACCT_ID                      IN         NUMBER,
   P_PARTY_ID                     IN         NUMBER,
   P_PARTY_SITE_ID                IN         NUMBER,
   P_USER_ID                      IN         NUMBER,
   X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                    OUT NOCOPY NUMBER,
   X_MSG_DATA                     OUT NOCOPY VARCHAR2) IS

   l_business_name    VARCHAR2(360) DEFAULT NULL;
   l_trade_name       VARCHAR2(240) DEFAULT NULL;
   l_postal_code      VARCHAR2(60)  DEFAULT NULL;

BEGIN

   BEGIN
      SELECT H3.party_name,
             H3.known_as,
             H1.postal_code
      INTO   l_business_name,
             l_trade_name,
             l_postal_code
      FROM   HZ_PARTIES             H3,
             HZ_LOCATIONS           H1,
             HZ_PARTY_SITES         H2
      WHERE  h3.party_id = h2.party_id
      AND    h2.location_id = h1.location_id
      AND    h3.party_id = p_party_id
      AND    h2.party_site_id = p_party_site_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
   END;

   --Key name for business name
   IF (l_business_name is not null) THEN

       INSERT INTO jtf_tty_acct_qual_maps
                     (ACCOUNT_QUAL_MAP_ID,
                      OBJECT_VERSION_NUMBER,
                      NAMED_ACCOUNT_ID,
                      QUAL_USG_ID,
                      COMPARISON_OPERATOR,
                      VALUE1_CHAR,
                      VALUE2_CHAR,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE)
                     (SELECT jtf_tty_acct_qual_maps_s.nextval,
                             1,
                             p_acct_id,
                             -1012,
                             '=',
                             UPPER(l_business_name),
                             null,
                             p_user_id,
                             sysdate,
                             p_user_id,
                             sysdate
                      FROM DUAl);
    END IF;

    --Key name for trade name
    IF (l_trade_name is not null) THEN

       INSERT INTO jtf_tty_acct_qual_maps
                     (ACCOUNT_QUAL_MAP_ID,
                      OBJECT_VERSION_NUMBER,
                      NAMED_ACCOUNT_ID,
                      QUAL_USG_ID,
                      COMPARISON_OPERATOR,
                      VALUE1_CHAR,
                      VALUE2_CHAR,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE)
                     (SELECT  jtf_tty_acct_qual_maps_s.nextval,
                              1,
                              p_acct_id,
                              -1012,
                              '=',
                              UPPER(l_trade_name),
                              null,
                              p_user_id,
                              sysdate,
                              p_user_id,
                              sysdate
                      FROM DUAL);
   END IF;

   --Key name for postal code
   IF (l_postal_code is not null) THEN

      INSERT INTO jtf_tty_acct_qual_maps
                     (ACCOUNT_QUAL_MAP_ID,
                      OBJECT_VERSION_NUMBER,
                      NAMED_ACCOUNT_ID,
                      QUAL_USG_ID,
                      COMPARISON_OPERATOR,
                      VALUE1_CHAR,
                      VALUE2_CHAR,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE)
                     (SELECT jtf_tty_acct_qual_maps_s.nextval,
                             1,
                             p_acct_id,
                             -1007,
                             '=',
                             l_postal_code,
                             null,
                             p_user_id,
                             sysdate,
                             p_user_id,
                             sysdate
                      FROM DUAL);
   END IF;

END CREATE_ACCT_MAPPINGS;


--This procedure adds an organization to a TG
PROCEDURE ADD_ORG_TO_TG(
   P_API_VERSION_NUMBER           IN      NUMBER,
   P_INIT_MSG_LIST                IN      VARCHAR2,
   P_COMMIT                       IN      VARCHAR2,
   P_VALIDATION_LEVEL             IN      NUMBER,
   P_PARTY_NUMBER                 IN      VARCHAR2,
   P_PARTY_SITE_ID                IN      NUMBER,
   P_TERR_GRP_NAME                IN      VARCHAR2,
   P_ATTRIBUTE1					  IN	   VARCHAR2,
   P_ATTRIBUTE2					  IN	   VARCHAR2,
   P_ATTRIBUTE3					  IN	   VARCHAR2,
   P_ATTRIBUTE4					  IN	   VARCHAR2,
   P_ATTRIBUTE5					  IN	   VARCHAR2,
   P_ATTRIBUTE6					  IN	   VARCHAR2,
   P_ATTRIBUTE7					  IN	   VARCHAR2,
   P_ATTRIBUTE8					  IN	   VARCHAR2,
   P_ATTRIBUTE9					  IN	   VARCHAR2,
   P_ATTRIBUTE10				  IN	   VARCHAR2,
   P_ATTRIBUTE11				  IN	   VARCHAR2,
   P_ATTRIBUTE12				  IN	   VARCHAR2,
   P_ATTRIBUTE13				  IN	   VARCHAR2,
   P_ATTRIBUTE14				  IN	   VARCHAR2,
   P_ATTRIBUTE15				  IN	   VARCHAR2,
   P_START_DATE                   IN OUT NOCOPY      DATE,
   P_END_DATE                     IN OUT NOCOPY      DATE,
   X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                    OUT NOCOPY NUMBER,
   X_MSG_DATA                     OUT NOCOPY VARCHAR2,
   X_TERR_GRP_ID                  OUT NOCOPY NUMBER,
   X_TERR_GRP_ACCT_ID             OUT NOCOPY NUMBER,
   X_NAMED_ACCT_ID                OUT NOCOPY NUMBER) IS

   l_party_number   VARCHAR2(30);
   l_tg_name        VARCHAR2(150);
   l_party_id       NUMBER;
   l_tg_id          NUMBER;
   l_na_id          NUMBER;
   l_tga_id         NUMBER;
   l_site_type_code VARCHAR2(30);
   l_duns_number    VARCHAR2(30);
   l_match_rule_code VARCHAR2(30);
   l_mapping_flag   VARCHAR2(1)     := 'N';
   l_user_id        NUMBER;
   l_login_id       NUMBER;
   l_error_msg      VARCHAR2(250);
   l_tg_start_date	date;
   l_tg_end_date	date;

   --Cursor to validate party based on  party number : Single Row
   CURSOR c_validate_party(l_party_number VARCHAR2, l_party_site_id NUMBER) IS

   SELECT hzp.party_id, hzp.duns_number_c
   FROM   hz_parties hzp
      ,   hz_party_sites hzps
   WHERE  hzp.party_number = l_party_number
   AND    hzp.party_id = hzps.party_id
   and    hzps.party_site_id = l_party_site_id
   AND    hzp.status = 'A';
--   AND    hzp.party_type = 'ORGANIZATION';


   --Cursor to validate territory group based on TG name : Single Row
   --Note: Joining with jtf_terr to stripe data by org
   --Note: Possible to have multiple TGs with same name, hence using ROWNUM
   CURSOR c_validate_tg(l_tg_name VARCHAR2) IS
   SELECT a.terr_group_id, a.matching_rule_code,
   		  a.active_from_date,
		  NVL( a.active_to_date, ADD_MONTHS(a.active_from_date,120) ) active_to_date
   FROM   jtf_tty_terr_groups a, jtf_terr_all b
   WHERE  a.parent_terr_id = b.terr_id
   AND    upper(a.terr_group_name) like upper(l_tg_name)
   AND    a.self_service_type = 'NAMED_ACCOUNT'
   AND    a.active_from_date <= sysdate
   AND    (a.active_to_date is null or a.active_to_date >= sysdate)
   AND    rownum < 2;

   --Cursor to check if TGA already exists for specified party and terr group: Single Row
   CURSOR c_check_tga_exists(l_party_id NUMBER, l_party_site_id NUMBER, l_tg_id NUMBER)  IS
   SELECT na.named_account_id, tga.terr_group_account_id
   FROM   jtf_tty_named_accts na, jtf_tty_terr_grp_accts tga
   WHERE  na.party_id = l_party_id
   AND    na.party_site_id = l_party_site_id
   AND    tga.named_account_id = na.named_account_id
   AND    tga.terr_group_id = l_tg_id;

   --Cursor to check if given party is already a named account : Single Row
   CURSOR c_check_na_exists(l_party_id NUMBER, l_party_site_id NUMBER) IS
   SELECT named_account_id, mapping_complete_flag
   FROM   jtf_tty_named_accts
   WHERE  party_id = l_party_id
     and  party_site_id = l_party_site_id ;


BEGIN

   l_duns_number := null;
   -- dbms_output.put_line('Sandeep -  In AADD_ORGTO_TG :1'  );
   l_party_number := nvl(P_PARTY_NUMBER, -999);
   OPEN c_validate_party(l_party_number, p_party_site_id);
   FETCH c_validate_party INTO l_party_id, l_duns_number;

   --If party is not valid then set message and return
   IF c_validate_party%NOTFOUND THEN
      CLOSE c_validate_party;
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_PARTY');
      return;
   END IF;
   CLOSE c_validate_party;

   l_tg_name := nvl(P_TERR_GRP_NAME, -999);
     -- dbms_output.put_line('Sandeep -  In AADD_ORGTO_TG :1.5' ||  l_tg_name);
   OPEN c_validate_tg(l_tg_name);
   FETCH c_validate_tg INTO l_tg_id, l_match_rule_code, l_tg_start_date, l_tg_end_date;
  -- dbms_output.put_line('Sandeep -  In AADD_ORGTO_TG :2' ||  l_tg_id);

   --If TG is not valid then set message and return
   IF c_validate_tg%NOTFOUND THEN
      CLOSE c_validate_tg;
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_TO_TG');
      return;
   END IF;
   CLOSE c_validate_tg;

   IF (( l_match_rule_code = '3' ) AND ( l_duns_number is null ))  THEN
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_NO_DUNS_NUMBER');
      return;
   END IF;

   -- added 06/05/2006 bug 5246668, to validate and set date
   IF p_start_date is null THEN
     IF (TRUNC(SYSDATE) > l_tg_start_date) THEN
	   p_start_date := TRUNC(SYSDATE);
	 ELSE
	   p_start_date := l_tg_start_date;
	 END IF;
   ELSE
     IF (p_start_date < l_tg_start_date) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TERR_STARTDATE_NOT_VALID');
       return;
	 END IF;
   END IF;

   IF p_end_date is null THEN
     IF (ADD_MONTHS(NVL(P_START_DATE,TRUNC(SYSDATE)), 12) > l_tg_end_date) THEN
	   p_end_date := l_tg_end_date;
	 ELSE
	   p_end_date := ADD_MONTHS(NVL(P_START_DATE,TRUNC(SYSDATE)), 12);
	 END IF;
   ELSE
     IF (p_end_date < l_tg_start_date OR p_end_date > l_tg_end_date) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TERR_ENDDATE_NOT_VALID');
       return;
	 END IF;
   END IF;

   -- end for bug 5246668, by mhtran


  -- dbms_output.put_line('Sandeep -  In AADD_ORGTO_TG :3' ||  l_tg_id);
   OPEN c_check_tga_exists(l_party_id, p_party_site_id, l_tg_id);
   FETCH c_check_tga_exists INTO l_na_id, l_tga_id;

   --If TGA already exists then set message and return
   IF c_check_tga_exists%FOUND THEN
      CLOSE c_check_tga_exists;
      x_terr_grp_id := -999;
      x_terr_grp_acct_id := -999;
      x_named_acct_id  := -999;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_TGA_EXISTS');
      return;
   END IF;
   CLOSE c_check_tga_exists;

   --At this point it is clear that this is a valid party/NA which needs to be added to the TG
   OPEN c_check_na_exists(l_party_id, p_party_site_id);
   FETCH c_check_na_exists into l_na_id, l_mapping_flag;

   --Get site_type_code and user_id needed while creating NA and TGA
   l_site_type_code := JTF_TTY_MAINTAIN_NA_PVT.get_site_type_code(l_party_id);
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

   --If named account does not exist, then create a named account for the party
   IF c_check_na_exists%NOTFOUND THEN

      SELECT jtf_tty_named_accts_s.nextval INTO l_na_id FROM dual;
       -- dbms_output.put_line('Sandeep -  In AADD_ORGTO_TG :3'  );

      INSERT INTO jtf_tty_named_accts
                  (NAMED_ACCOUNT_ID,
                   OBJECT_VERSION_NUMBER,
                   PARTY_ID,
                   PARTY_SITE_ID,
                   MAPPING_COMPLETE_FLAG,
                   SITE_TYPE_CODE,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN)
             VALUES
                  (l_na_id,
                   2,
                   l_party_id,
                   p_party_site_id,
                   l_mapping_flag,
                   l_site_type_code,
                   l_user_id,
                   sysdate,
                   l_user_id,
                   sysdate,
                   l_login_id);

      IF l_match_rule_code = '1' THEN
            JTF_TTY_MAINTAIN_NA_PVT.create_acct_mappings
                                     (P_API_VERSION_NUMBER => 1.0,
                                      P_INIT_MSG_LIST      => fnd_api.g_false,
                                      P_COMMIT             => fnd_api.g_false,
                                      P_VALIDATION_LEVEL   => fnd_api.g_valid_level_full,
                                      P_ACCT_ID            => l_na_id,
                                      P_PARTY_ID           => l_party_id,
                                      P_PARTY_SITE_ID      => p_party_site_id,
                                      P_USER_ID            => l_user_id,
                                      X_RETURN_STATUS      => x_return_status,
                                      X_MSG_COUNT          => x_msg_count,
                                      X_MSG_DATA           => x_msg_data);
     END IF;
   END IF;

   --At this point either named account exists or it has been created
   --Add this named account to the TG
      -- dbms_output.put_line('Sandeep -  In AADD_ORGTO_TG :34'  );
   CLOSE c_check_na_exists;
   SELECT jtf_tty_terr_grp_accts_s.nextval INTO l_tga_id FROM dual;

   INSERT INTO jtf_tty_terr_grp_accts
                 (TERR_GROUP_ACCOUNT_ID,
                  OBJECT_VERSION_NUMBER,
                  TERR_GROUP_ID,
                  NAMED_ACCOUNT_ID,
                  DN_JNA_MAPPING_COMPLETE_FLAG,
                  DN_JNA_SITE_TYPE_CODE,
                  DN_JNR_ASSIGNED_FLAG,
			   	  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  START_DATE,
                  END_DATE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN)
          VALUES (l_tga_id,
                  2,
                  l_tg_id,
                  l_na_id,
                  l_mapping_flag,
                  l_site_type_code,
                  'N',
			   	  P_ATTRIBUTE1,
                  P_ATTRIBUTE2,
                  P_ATTRIBUTE3,
                  P_ATTRIBUTE4,
                  P_ATTRIBUTE5,
                  P_ATTRIBUTE6,
                  P_ATTRIBUTE7,
                  P_ATTRIBUTE8,
                  P_ATTRIBUTE9,
                  P_ATTRIBUTE10,
                  P_ATTRIBUTE11,
                  P_ATTRIBUTE12,
                  P_ATTRIBUTE13,
                  P_ATTRIBUTE14,
                  P_ATTRIBUTE15,
                  P_START_DATE,
				  P_END_DATE,
                  l_user_id,
                  sysdate,
                  l_user_id,
                  sysdate,
                  l_login_id);

   /* by shli, GSST Decom */
   /*--Insert row to track changes for GTP
   INSERT INTO jtf_tty_named_acct_changes
                  (NAMED_ACCT_CHANGE_ID,
                   OBJECT_VERSION_NUMBER,
                   OBJECT_TYPE,
                   OBJECT_ID,
                   CHANGE_TYPE,
                   FROM_WHERE,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN)
           VALUES (JTF_TTY_NAMED_ACCT_CHANGES_S.NEXTVAL,
                   1,
                   'TG',
                   l_tg_id,
                   'UPDATE',
                   'UPDATE TERRITORY GROUP',
                   l_user_id,
                   sysdate,
                   l_user_id,
                   sysdate,
                   l_login_id);
   */
   x_terr_grp_id := l_tg_id;
   x_terr_grp_acct_id := l_tga_id;
   x_named_acct_id := l_na_id;
   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );
      put_jty_log('Error in ADD_ORG_TO_TG: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
      return;
END ADD_ORG_TO_TG;

--This procedure assigns a named account to respective TG owner(s)
PROCEDURE ASSIGN_ACCT_TO_TG_OWNERS(
   P_API_VERSION_NUMBER           IN         NUMBER,
   P_INIT_MSG_LIST                IN         VARCHAR2,
   P_COMMIT                       IN         VARCHAR2,
   P_VALIDATION_LEVEL             IN         NUMBER,
   P_TERR_GRP_ACCT_ID             IN         NUMBER,
   P_TERR_GRP_ID                  IN         NUMBER,
   X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                    OUT NOCOPY NUMBER,
   X_MSG_DATA                     OUT NOCOPY VARCHAR2) IS

   l_rsc_group_id                NUMBER;
   l_resource_id                 NUMBER;
   l_rsc_role_code               VARCHAR2(60);
   l_rsc_resource_type           VARCHAR2(30);
   l_user_id                     NUMBER;
   l_error_msg      VARCHAR2(250);

   -- Cursor to get resource details for TG owner(s) : Multiple Rows
   CURSOR c_get_rsc_details(l_tg_id NUMBER) IS
   SELECT rsc_group_id, resource_id, rsc_role_code, rsc_resource_type
   FROM   jtf_tty_terr_grp_owners
   WHERE  terr_group_id = l_tg_id;

BEGIN

   OPEN c_get_rsc_details(p_terr_grp_id);
   LOOP
      FETCH c_get_rsc_details INTO l_rsc_group_id, l_resource_id, l_rsc_role_code, l_rsc_resource_type;
      EXIT WHEN c_get_rsc_details%NOTFOUND;
         l_user_id := fnd_global.user_id;
         INSERT INTO jtf_tty_named_acct_rsc
                        (ACCOUNT_RESOURCE_ID,
                         OBJECT_VERSION_NUMBER,
                         TERR_GROUP_ACCOUNT_ID,
                         RESOURCE_ID,
                         RSC_GROUP_ID,
                         RSC_ROLE_CODE,
                         ASSIGNED_FLAG,
                         RSC_RESOURCE_TYPE,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE)
                        (SELECT jtf_tty_named_acct_rsc_s.nextval,
                         1,
                         p_terr_grp_acct_id,
                         l_resource_id,
                         l_rsc_group_id,
                         l_rsc_role_code,
                         'N',
                         l_rsc_resource_type,
                         l_user_id,
                         sysdate,
                         l_user_id,
                         sysdate
                         FROM dual
                         WHERE NOT EXISTS (SELECT null FROM jtf_tty_named_acct_rsc rsc
                                           WHERE rsc.terr_group_account_id = p_terr_grp_acct_id
                                           AND   rsc.RESOURCE_ID = l_resource_id
                                           AND   rsc.RSC_ROLE_CODE = l_rsc_role_code
                                           AND   rsc.RSC_GROUP_ID = l_rsc_group_id
                                           AND   rsc.RSC_RESOURCE_TYPE = l_rsc_resource_type));


   END LOOP;
   CLOSE c_get_rsc_details;

EXCEPTION
   WHEN OTHERS THEN
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );
      put_jty_log('Error in ASSIGN_ACCT_TO_TG_OWNERS: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
      return;
END ASSIGN_ACCT_TO_TG_OWNERS;

--Procedure to validate resource, called by populate sales team
PROCEDURE VALIDATE_RESOURCE (
   P_API_VERSION_NUMBER          IN          NUMBER,
   P_INIT_MSG_LIST               IN          VARCHAR2   := FND_API.G_FALSE,
   P_COMMIT                      IN          VARCHAR2   := FND_API.G_FALSE,
   P_VALIDATION_LEVEL            IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                   OUT NOCOPY NUMBER,
   X_MSG_DATA                    OUT NOCOPY VARCHAR2,
   P_RESOURCE_NAME               IN         VARCHAR2,
   P_GROUP_NAME                  IN         VARCHAR2,
   P_ROLE_NAME                   IN         VARCHAR2,
   P_TERR_GROUP_ID               IN         NUMBER,
   X_RESOURCE_ID                 OUT NOCOPY NUMBER,
   X_GROUP_ID                    OUT NOCOPY NUMBER,
   X_ROLE_CODE                   OUT NOCOPY VARCHAR2,
   X_ERROR_CODE                  OUT NOCOPY NUMBER,
   X_STATUS                      OUT NOCOPY VARCHAR2) IS

   counter            NUMBER:=0;
   comb               NUMBER:=0;
   l_select           varchar2(10);
   l_user_id          NUMBER;
   found              NUMBER;
   l_num_valid_rsc_id NUMBER := 0;
   l_error_msg      VARCHAR2(250);

   TYPE NUMBER_TABLE_TYPE IS TABLE OF NUMBER;
   l_res_tbl NUMBER_TABLE_TYPE := NUMBER_TABLE_TYPE();

   CURSOR c_get_resource_id ( c_resource_name VARCHAR2 ) IS
   SELECT RESOURCE_id
   FROM jtf_rs_resource_extns_vl
   WHERE upper(resource_name) = upper(c_resource_name)
   AND category = 'EMPLOYEE'
   AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE+1);

   CURSOR c_get_group_id ( c_group_name VARCHAR2 ) IS
   SELECT group_id
   FROM jtf_rs_groups_vl
   WHERE upper(group_name) = upper(c_group_name)
   AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE+1);

   CURSOR c_get_role_code ( c_role_name VARCHAR2 ) IS
   SELECT rol.role_code
   FROM jtf_rs_roles_vl rol
   WHERE upper(rol.role_name) = upper(c_role_name)
   AND (rol.role_type_code = 'SALES' OR
        rol.role_type_code = 'TELESALES' OR
        rol.role_type_code = 'FIELDSALES')
   AND active_flag ='Y';

BEGIN

   x_status := 'S';
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_user_id := fnd_global.user_id;

   IF (P_RESOURCE_NAME is not null AND P_GROUP_NAME is not null AND P_ROLE_NAME is not null) THEN

      --Validation against LOVs by terr group's owner resource_id allows a resource not owned by the logged in
      --user valid. The validation also blocks any resource outside the terr group.

      --Check group name AVP name
      BEGIN
         -- check group name
         counter :=0;
         FOR group_rec IN  c_get_group_id( c_group_name => p_group_name ) LOOP
            counter := counter +1;
            x_group_id := group_rec.group_id; -- group_id assigned
            IF counter=2 THEN
               x_status := 'E';
               x_return_status     := FND_API.G_RET_STS_ERROR ;
               fnd_message.clear;
               fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_GROUP_NAME');
               x_error_code := 1;
               RETURN;
            END IF;
         END LOOP;
         IF counter=0 THEN
            RAISE NO_DATA_FOUND;
         END IF;

         -- check role name
         counter :=0;
         FOR role_rec IN  c_get_role_code( c_role_name => p_role_name ) LOOP
            counter := counter +1;
            x_role_code := role_rec.role_code; -- role_code assigned
            IF counter=2 THEN
               x_status := 'E';
               x_return_status     := FND_API.G_RET_STS_ERROR ;
               fnd_message.clear;
               fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_ROLE_NAME');
               x_error_code := 1;
               RETURN;
            END IF;
         END LOOP;
         IF counter=0 THEN
            RAISE NO_DATA_FOUND;
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_status := 'E';
            x_return_status     := FND_API.G_RET_STS_ERROR ;
            fnd_message.clear;
            fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
            x_error_code := 1;
            RETURN;
      END; -- of check group name AVP name

      --Check resource, group and role combination
      BEGIN
         counter :=0;
         FOR res_rec IN c_get_resource_id( c_resource_name => p_resource_name ) LOOP
            l_res_tbl.EXTEND;
            counter := counter + 1;
            l_res_tbl(counter) :=  res_rec.resource_id;
         END LOOP;

         --No resource by this name
         IF counter = 0 THEN
            RAISE NO_DATA_FOUND;
         ELSE
            IF (l_res_tbl IS NOT NULL) AND ( l_res_tbl.COUNT > 0 ) THEN
               l_num_valid_rsc_id := 0;
               FOR i IN 1 .. l_res_tbl.COUNT LOOP
                    /* commenting out due to 3576571 bug */
                    /*
                  BEGIN
                     SELECT 'VALID' INTO l_select
                     FROM    jtf_tty_terr_grp_accts tga,
                             jtf_tty_named_acct_rsc nar,
                             jtf_tty_terr_groups    tg
                    WHERE  nar.terr_group_account_id = tga.terr_group_account_id
                     AND  nar.rsc_role_code    = X_ROLE_CODE
                     AND  tga.terr_group_id    = tg.terr_group_id
                     AND sysdate >= tg.active_from_date
                     AND (tg.active_to_date is null OR
                           sysdate <= tg.active_to_date)
                     AND  nar.resource_id      = l_res_tbl(i)
                     AND  nar.rsc_group_id     = X_GROUP_ID
                     AND  tga.named_account_id = P_NAMED_ACCOUNT_ID
                     AND  tga.terr_group_id    <>P_terr_group_id
                     AND  rownum < 2;

                     x_status := 'I';  -- it is in other TG, return with Ignore
                     RETURN;

                  EXCEPTION  -- go on
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;
                  */
                  BEGIN
                     SELECT 'VALID'
                     INTO l_select
                     FROM jtf_rs_group_members  mem, jtf_rs_roles_b rol, jtf_rs_role_relations rlt
                     WHERE rlt.role_resource_type = 'RS_GROUP_MEMBER'
                     AND rlt.delete_flag = 'N'
                     AND sysdate >= rlt.start_date_active
                     AND (rlt.end_date_active is null OR
                          sysdate <= rlt.end_date_active)
                     AND rlt.role_id = rol.role_id
                     AND rol.role_code = x_role_code
                     AND rlt.role_resource_id = mem.group_member_id
                     AND mem.delete_flag = 'N'
                     AND mem.group_id = x_group_id
                     AND mem.resource_id = l_res_tbl(i);

                     x_resource_id := l_res_tbl(i);
                     l_num_valid_rsc_id := l_num_valid_rsc_id + 1;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN TOO_MANY_ROWS THEN
                        RAISE TOO_MANY_ROWS; -- not common error.
                  END;
               END LOOP;

               IF l_num_valid_rsc_id  > 1 THEN
                  RAISE TOO_MANY_ROWS; -- duplicate combination, like two Lisa in the same resource group, same role
               ELSIF l_num_valid_rsc_id =0 THEN
                  RAISE NO_DATA_FOUND; -- the reps(by that name) are valid but not in the resource group with the role
               END IF;

            END IF; -- l_res_tbl > 0
         END IF; -- count

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_status := 'E';
            x_return_status     := FND_API.G_RET_STS_ERROR ;
            fnd_message.clear;
            fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
            x_error_code := 1;
            RETURN;
         WHEN TOO_MANY_ROWS THEN
            x_status := 'E';
            x_return_status     := FND_API.G_RET_STS_ERROR ;
            fnd_message.clear;
            fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_SALES_DATA');
            x_error_code := 1;
            RETURN;
         WHEN OTHERS THEN
            x_status := 'E';
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_error_code := 4;
            l_error_msg := substr(sqlerrm,1,200);
            fnd_message.clear;
            fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
            fnd_message.set_token('ERRMSG', l_error_msg );
            put_jty_log('Error in VALIDATE_RESOURCE: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
            RETURN;
      END;

      -- check the role code
      BEGIN
         SELECT 'Y'
         INTO l_select
         FROM jtf_tty_terr_grp_roles
         WHERE terr_group_id=P_terr_group_id
         AND role_code = X_ROLE_CODE;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_status := 'E';
            x_error_code := 2;
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.clear;
            fnd_message.set_name ('JTF', 'JTF_TTY_ROLE_NOT_IN_TG');
            RETURN;
      END;

   ELSE
      x_status := 'E';
      x_error_code := 3;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_SALES_MANDATORY');
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_status := 'E';
      x_error_code := 4;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );
      put_jty_log('Error in VALIDATE_RESOURCE: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
      RETURN;
END VALIDATE_RESOURCE;

/* Procedure which checks whether the user can add the given
sales person.*/

PROCEDURE CHECK_VALID_RESOURCE_ADD (
         p_Api_Version_Number          IN  NUMBER,
         p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
         p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
         p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
         X_Return_Status               OUT NOCOPY VARCHAR2,
         X_Msg_Count                   OUT NOCOPY NUMBER,
         X_Msg_Data                    OUT NOCOPY VARCHAR2,
         P_RESOURCE_id    in number,
         P_GROUP_ID       IN NUMBER,
         P_ROLE_CODE      in varchar2,
         P_user_id        in number,
         P_TG_ID          in number,
         x_owner_resource_id out NOCOPY NUMBER,
         x_owner_group_id  out NOCOPY NUMBER,
         x_owner_role_code OUT NOCOPY VARCHAR2,
         x_error_code     out NOCOPY number,
         x_status         out NOCOPY varchar2) is

  l_select varchar2(100);
  l_error_msg      VARCHAR2(250);

BEGIN
  -- x_status := 'S';
   x_return_status := FND_API.G_RET_STS_SUCCESS;
      /* check salesperson for the current TG */
   BEGIN
     /* find if the resource belongs to the saleshierarchy of the territory group owner(s) since when an
      admin is doing upload, he/she is doing as the owner of the TG */
   SELECT 'VALID'
   INTO l_select
   FROM jtf_tty_srch_my_resources_v /*jtf_tty_my_resources_v*/ grv,
        jtf_tty_terr_grp_owners jto,
        jtf_rs_resource_extns   res
   WHERE EXISTS
       ( SELECT NULL
         FROM jtf_rs_groups_denorm grpd
         WHERE /* part of Salesgroup hierarchy of Territory Group owner */
               grpd.parent_group_id = JTO.rsc_group_id
               /* groups I (logged-in user) am 'member' of */
           AND grpd.group_id = GRV.group_id
       )
     AND jto.terr_group_id   = P_TG_ID
     AND grv.ROLE_CODE       = P_ROLE_CODE
     AND grv.GROUP_ID        = P_GROUP_ID
     AND grv.resource_id     = P_RESOURCE_ID
     AND grv.CURRENT_USER_ID = res.USER_ID
     AND jto.resource_id     = res.resource_id
     AND ROWNUM < 2;


    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       -- x_status := 'E';
        x_error_code := 1;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
        RETURN;

    WHEN OTHERS THEN
      -- x_status := 'E';
       x_error_code := 4;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       put_jty_log('Error in CHECK_VALID_RESOURCE_ADD: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
       l_error_msg := substr(sqlerrm,1,200);
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
       fnd_message.set_token('ERRMSG', l_error_msg );
       RETURN;
    END;


END CHECK_VALID_RESOURCE_ADD;

/* Procedure which checks whether the user can add the given
sales person.*/

PROCEDURE GET_RESOURCE_OWNERS (
         p_Api_Version_Number          IN  NUMBER,
         p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
         p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
         p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
         X_Return_Status               OUT NOCOPY VARCHAR2,
         X_Msg_Count                   OUT NOCOPY NUMBER,
         X_Msg_Data                    OUT NOCOPY VARCHAR2,
         P_TERR_GP_ID                  in number,
         P_RESOURCES_TBL               IN SALESREP_RSC_TBL_TYPE,
         x_rscs_owners_tbl              OUT NOCOPY SALESREP_RSC_OWNERS_TBL_TYPE,
         x_error_code                  out NOCOPY number,
         x_status                      out NOCOPY varchar2) is

  l_select varchar2(100);
  j integer := 0;
  i integer := 0;
  p_group_id1 NUMBER DEFAULT NULL ;
  p_group_id2  NUMBER DEFAULT NULL ;
  p_group_id3 NUMBER DEFAULT NULL ;
  p_group_id4  NUMBER DEFAULT NULL ;
  p_group_id5 NUMBER DEFAULT NULL ;
  p_group_id6  NUMBER DEFAULT NULL ;
  p_group_id7 NUMBER DEFAULT NULL ;
  p_group_id8  NUMBER DEFAULT NULL ;
  p_group_id9 NUMBER DEFAULT NULL ;
  p_group_id10  NUMBER DEFAULT NULL ;
  p_group_id11 NUMBER DEFAULT NULL ;
  p_group_id12  NUMBER DEFAULT NULL ;
  p_group_id13 NUMBER DEFAULT NULL ;
  p_group_id14  NUMBER DEFAULT NULL ;
  p_group_id15 NUMBER DEFAULT NULL ;
  p_group_id16  NUMBER DEFAULT NULL ;
  p_group_id17 NUMBER DEFAULT NULL ;
  p_group_id18  NUMBER DEFAULT NULL ;
  p_group_id19 NUMBER DEFAULT NULL ;
  p_group_id20  NUMBER DEFAULT NULL ;
  p_group_id21 NUMBER DEFAULT NULL ;
  p_group_id22 NUMBER DEFAULT NULL ;
  p_group_id23  NUMBER DEFAULT NULL ;
  p_group_id24 NUMBER DEFAULT NULL ;
  p_group_id25  NUMBER DEFAULT NULL ;
  p_group_id26  NUMBER DEFAULT NULL ;
  p_group_id27 NUMBER DEFAULT NULL ;
  p_group_id28  NUMBER DEFAULT NULL ;
  p_group_id29 NUMBER DEFAULT NULL ;
  p_group_id30  NUMBER DEFAULT NULL ;
  l_get_owners varchar2(2000);
  l_rsc_groups varchar2(2000);
   l_cursor                     NUMBER;
   fdbk INTEGER;
   l_error_msg      VARCHAR2(250);

  cursor get_owners_c
  IS
  SELECT jto.resource_id, jto.rsc_group_id, jto.rsc_role_code, grpd.group_id
  FROM jtf_rs_grp_denorm_vl grpd, jtf_tty_terr_grp_owners jto
  WHERE grpd.parent_group_id = JTO.rsc_group_id
  AND jto.terr_group_id   = P_TERR_GP_ID
  AND grpd.group_id IN (p_group_id1, p_group_id2, p_group_id3, p_group_id4, p_group_id5,
                        p_group_id6, p_group_id7, p_group_id8, p_group_id9, p_group_id10,
                        p_group_id11, p_group_id12, p_group_id13, p_group_id14, p_group_id15,
                        p_group_id16, p_group_id17, p_group_id18, p_group_id19, p_group_id20,
                        p_group_id21, p_group_id22, p_group_id23, p_group_id24, p_group_id25,
                        p_group_id26, p_group_id27, p_group_id28, p_group_id29, p_group_id30);

BEGIN
  -- x_status := 'S';
  x_rscs_owners_tbl := SALESREP_RSC_OWNERS_TBL_TYPE();
   x_return_status := FND_API.G_RET_STS_SUCCESS;
      /* check salesperson for the current TG */
   j := 0;
   FOR i in P_RESOURCES_TBL.first.. P_RESOURCES_TBL.last LOOP
       if (i = 1) then
         p_group_id1:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 2) then
             p_group_id2:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 3) then
          p_group_id3:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 4) then
             p_group_id4:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 5) then
         p_group_id5:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 6) then
             p_group_id6:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 7) then
         p_group_id7:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 8) then
             p_group_id8:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 9) then
         p_group_id9:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 10) then
             p_group_id10:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 11) then
         p_group_id11:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 12) then
             p_group_id12:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 13) then
          p_group_id13:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 14) then
             p_group_id14:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 15) then
         p_group_id15:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 16) then
             p_group_id16:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 17) then
         p_group_id17:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 18) then
             p_group_id18:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 19) then
         p_group_id19:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 20) then
             p_group_id20:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 21) then
         p_group_id21:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 22) then
             p_group_id22:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 23) then
          p_group_id23:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 24) then
             p_group_id24:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 25) then
         p_group_id25:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 26) then
             p_group_id26:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 27) then
         p_group_id27:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 28) then
             p_group_id28:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 29) then
         p_group_id29:= P_RESOURCES_TBL(i).group_id;
       elsif (i = 30) then
             p_group_id30:= P_RESOURCES_TBL(i).group_id;
        end if;
  END LOOP;

   /* dynamic sql
   FOR i in P_RESOURCES_TBL.first.. P_RESOURCES_TBL.last LOOP
        if (i = 1) then
          l_rsc_groups := P_RESOURCES_TBL(i).group_id;
        else
          l_rsc_groups := l_rsc_groups || ',' || P_RESOURCES_TBL(i).group_id;
         end if;
   END LOOP;
   l_get_owners :=
   'SELECT jto.resource_id, jto.rsc_group_id, jto.rsc_role_code, grpd.group_id' ||
    ' FROM jtf_rs_grp_denorm_vl grpd, jtf_tty_terr_grp_owners jto ' ||
    ' WHERE grpd.parent_group_id = JTO.rsc_group_id' ||
    ' AND jto.terr_group_id   =  :P_TERR_GP_ID ' ||
     ' AND grpd.group_id IN (' || l_rsc_groups || ')';
   l_cursor := -- dbms_SQL.OPEN_CURSOR;
   -- dbms_SQL.PARSE ( l_Cursor, l_get_owners, -- dbms_SQL.NATIVE );
   -- dbms_SQL.BIND_VARIABLE (l_cursor, ':P_TERR_GP_ID', P_TERR_GP_ID );
   fdbk := -- dbms_SQL.EXECUTE(l_cursor);
   LOOP
      /* Fetch next row. Exit when done. */
      /*
      EXIT WHEN -- dbms_SQL.FETCH_ROWS (cur) = 0;
      -- dbms_SQL.COLUMN_VALUE (l_Cursor, 1, rec.employee_id);
      -- dbms_SQL.COLUMN_VALUE (l_Cursor, 2, rec.last_name);
      -- dbms_SQL.COLUMN_VALUE (l_Cursor, 3, rec.last_name);
      -- dbms_SQL.COLUMN_VALUE (l_Cursor, 4, rec.last_name);
      -- dbms_output.put_line (
         TO_CHAR (rec.employee_id) || '=' ||
         rec.last_name);
   END LOOP;

   -- dbms_SQL.CLOSE_CURSOR (cur);
* end of dynamic sql */
   FOR OWNERS IN get_owners_c LOOP
        j := j+1;
        x_rscs_owners_tbl.extend();
        x_rscs_owners_tbl(j).owner_resource_id := owners.resource_id;
        x_rscs_owners_tbl(j).owner_group_id    := owners.rsc_group_id;
        x_rscs_owners_tbl(j).owner_role_code   := owners.rsc_role_code;
        x_rscs_owners_tbl(j).group_id          := owners.group_id;
   END LOOP;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       -- x_status := 'E';
        x_error_code := 1;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
        RETURN;

    WHEN OTHERS THEN
      -- x_status := 'E';
       x_error_code := 4;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       l_error_msg := substr(sqlerrm,1,200);
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
       fnd_message.set_token('ERRMSG', l_error_msg );
       put_jty_log('Error in GET_RESOURCE_OWNERS: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
       RETURN;


END GET_RESOURCE_OWNERS;

/* If the account is not assigned to anyone in the tg owners hierarchy
   assign to the owner(s) */
PROCEDURE ASSIGN_UA_ACCT_TO_TGOWNERS(
               p_Api_Version_Number          IN  NUMBER,
               p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
               p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
               p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
               X_Return_Status               OUT NOCOPY VARCHAR2,
               X_Msg_Count                   OUT NOCOPY NUMBER,
               X_Msg_Data                    OUT NOCOPY VARCHAR2,
               P_TERR_GP_ACCT_ID IN NUMBER,
               P_TERR_GP_ID IN NUMBER)
AS
 cursor getTerrgpOwners(id IN NUMBER) is
 select resource_id,
        rsc_group_id,
        rsc_role_code
 from   jtf_tty_terr_grp_owners
 where  terr_group_id = id;

 p_owner_user_rsc_id NUMBER;
 p_owner_group_id NUMBER;
 p_owner_role_code VARCHAR2(60);
 p_exists_flag VARCHAR2(1);
 l_error_msg      VARCHAR2(250);

BEGIN
 -- dbms_output.put_line('Sandeep -  In ASSIGN_UA_ACCT_TO_TGOWNERS ' || P_TERR_GP_ACCT_ID  );
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR owners_c IN getTerrgpOwners(p_terr_gp_id) LOOP
       p_owner_user_rsc_id := owners_c.resource_id;
       p_owner_group_id := owners_c.rsc_group_id;
       p_owner_role_code :=owners_c.rsc_role_code;
       BEGIN
        SELECT     'X'
        INTO  p_exists_flag
        FROM jtf_tty_terr_grp_accts ga,
                 jtf_tty_my_resources_v repdn,
                 jtf_tty_named_acct_rsc narsc
        WHERE  ga.terr_group_account_id = narsc.terr_group_account_id
        AND  narsc.resource_id = repdn.resource_id
        AND  narsc.rsc_group_id = repdn.group_id
        AND  narsc.rsc_role_code = repdn.role_code
        AND  repdn.parent_group_id = p_owner_group_id
        AND  repdn.current_user_rsc_id = p_owner_user_rsc_id
        AND repdn.current_user_role_code = p_owner_role_code
        AND ga.terr_group_id = p_terr_gp_id
        AND  ga.terr_group_account_id = p_terr_gp_acct_id
        AND ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         -- dbms_output.put_line('Sandeep -  ASSIGN_UA_ACCT_TO_TGOWNERS: Doing insert ' || P_TERR_GP_ACCT_ID  );
        /* Assign tga to the owner p_owner_user_rsc_id, p_owner_group_id, p_owner_role_code */
          INSERT INTO jtf_tty_named_acct_rsc(
                      ACCOUNT_RESOURCE_ID,
                      OBJECT_VERSION_NUMBER,
                      TERR_GROUP_ACCOUNT_ID,
                     RESOURCE_ID,
                     RSC_GROUP_ID ,
                     RSC_ROLE_CODE ,
                     RSC_RESOURCE_TYPE ,
                     ASSIGNED_FLAG ,
                     CREATED_BY,
                     CREATION_DATE  ,
                     LAST_UPDATED_BY ,
                     LAST_UPDATE_DATE ,
                     LAST_UPDATE_LOGIN )
            VALUES(jtf_tty_named_acct_rsc_s.nextval,
                   1,
                   p_terr_gp_acct_id,
                   p_owner_user_rsc_id,
                   p_owner_group_id,
                   p_owner_role_code,
                   'RS_EMPLOYEE',
                   'N',
                   fnd_global.user_id,
                   sysdate,
                   fnd_global.user_id,
                   sysdate,
                   null);
      END;
    END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- dbms_output.put_line('Sandeep -  Error 2 In ASSIGN_UA_ACCT_TO_TGOWNERS ' || P_TERR_GP_ACCT_ID  );
       l_error_msg := substr(sqlerrm,1,200);
       fnd_message.clear;
       fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
       fnd_message.set_token('ERRMSG', l_error_msg );
       put_jty_log('Error in ASSIGN_UA_ACCT_TO_TGOWNERS: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
       RETURN;

END ASSIGN_UA_ACCT_TO_TGOWNERS;

--**************************************
-- PROCEDURE POPULATE_SALES_TEAM
--**************************************

--  input:
--      [list of] lp_resource_id, lp_group_id, lp_role_code
--      [list of] lp_party_id
--      FROM CALLING PAGE
--        lp_current_user_resource_id    NOTE THIS PARAMETER NO LONGER USED
--        p_user_attribute1 IS NOW USED INSTEAD, value is USER_ID
--        lp_territory_group_id

PROCEDURE POPULATE_SALES_TEAM(
      p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN         VARCHAR2,
      p_Debug_Flag            IN         VARCHAR2,
      x_return_status         OUT  NOCOPY       VARCHAR2,
      x_msg_count             OUT  NOCOPY       NUMBER,
      x_msg_data              OUT  NOCOPY       VARCHAR2,
      p_from_where            in   VARCHAR2,
      p_user_resource_id      IN          NUMBER,  -- NOTE THIS IS NOT USED, user_attr1 used for user_id instead.
      p_terr_group_id         IN          NUMBER,
      p_user_attribute1       IN          VARCHAR2,
      p_user_attribute2       IN          VARCHAR2,
      p_added_rscs_tbl        IN          SALESREP_RSC_TBL_TYPE,
      p_removed_rscs_tbl      IN          SALESREP_RSC_TBL_TYPE,
      p_affected_parties_tbl  IN          AFFECTED_PARTY_TBL_TYPE,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2
  )
IS

    l_user_id               NUMBER := p_user_attribute1;
    /*lp_user_resource_id     NUMBER := p_user_resource_id; */
    lp_user_resource_type   VARCHAR2(30) := 'RS_EMPLOYEE';
    lp_terr_group_id        NUMBER := p_terr_group_id;

    lp_resource_id          NUMBER;
    lp_group_id             NUMBER;
    lp_role_code            VARCHAR2(300);
    lp_mgr_resource_id          NUMBER;
    lp_mgr_group_id             NUMBER;
    lp_mgr_role_code            VARCHAR2(300);
    lp_resource_type        VARCHAR2(300);
    t_resource_id           NUMBER;
    t_resource_type         VARCHAR2(19);

    lp_named_account_id     NUMBER;

    l_role_code            VARCHAR2(300);
    l_terr_group_account_id NUMBER;
    l_directs_on_account    NUMBER := 0;
    l_assign_flag           VARCHAR2(1);
    l_resource_id_is_leaf   VARCHAR2(1);
    l_assigned_rsc_exists   NUMBER := 0;  -- 0 if no assigned rsc exists, 1 otherwise

    l_find_subs             VARCHAR2(1);        -- are we processing subsidiaries?
    l_master_pty_last       NUMBER;   -- last index of the master parties
    l_sub_pty_index         NUMBER;   -- index where the subsidiaries will be added
    l_acct_rsc_exist_count  NUMBER;   -- verify if existing rsc/group/role exists

    l_change_id             NUMBER;
    l_user                  number;
    l_login_id              number;
    l_error_msg      VARCHAR2(250);


    new_seq_acct_rsc_id             NUMBER;
    new_seq_acct_rsc_dn_id          NUMBER;
    new_seq_RESOURCE_ACCT_SUMM_ID   NUMBER;


    -- LIST OF ALL GROUPS A GIVEN RESOURCE OWNS IN THE CONTEXT OF A PARENT GRUOP
    cursor c_rsc_owned_grps(cl_parent_resource_id number, cl_group_id number) is
        SELECT mgr.resource_id, mgr.group_id
        FROM   jtf_rs_rep_managers mgr,
               jtf_rs_groups_denorm gd
        WHERE  mgr.hierarchy_type = 'MGR_TO_MGR'
        AND    mgr.resource_id = mgr.parent_resource_id
        AND    trunc(sysdate) BETWEEN mgr.start_date_active
                              AND NVL(mgr.end_date_active,trunc(sysdate))
        AND    mgr.group_id = gd.group_id
        AND    gd.parent_group_id = cl_group_id
        AND    mgr.resource_id = cl_parent_resource_id
        AND rownum < 2;


    -- LIST OF ALL DIRECTS TO REMOVE WHEN REMOVING A MANAGING RESOURCE
    -- FROM A NAMED ACCOUNT IN THE CONTEXT OF A GROUP
    cursor c_rsc_directs(cl_parent_resource_id number, cl_group_id number) is
        SELECT DISTINCT RESOURCE_ID
        FROM JTF_RS_REP_MANAGERS
        WHERE group_id = cl_group_id
          and resource_id <> cl_parent_resource_id
          and parent_resource_id = cl_parent_resource_id;


    -- ALL SUBSIDIARIES OF cl_party_id that is owned by lp_user_resource_id, p_terr_group_id
    -- QUERY MODIFIED FOR TERR_GROUP_ACCOUNT_ID IN/OUT
    cursor c_subsidiaries(cl_terr_group_account_id number) is
         select distinct gao.terr_group_account_id
         from hz_relationships hzr,
              jtf_tty_named_accts nai,
              jtf_tty_terr_grp_accts gai,
              jtf_tty_named_accts nao,
              jtf_tty_terr_grp_accts gao
         where gao.named_account_id = nao.named_account_id
           and nao.party_id = hzr.object_id  -- these are the subsidiary parties
           and hzr.subject_table_name = 'HZ_PARTIES'
           and hzr.object_table_name = 'HZ_PARTIES'
           and hzr.relationship_code IN ( 'GLOBAL_ULTIMATE_OF',  'HEADQUARTERS_OF',  'DOMESTIC_ULTIMATE_OF', 'PARENT_OF'  )
           and hzr.status = 'A'
           and sysdate between hzr.start_date and nvl( hzr.end_date, sysdate)
           and hzr.subject_id = nai.party_id  -- this is the parent party
           and nai.named_account_id = gai.named_account_id
           and gai.terr_group_account_id = cl_terr_group_account_id
           -- subsidiaries that are owned by user
           and exists( select 'Y'
                        from jtf_tty_named_acct_rsc narsc ,
                             jtf_tty_my_resources_v repdn
                           --  jtf_tty_named_accts na,
                           --  jtf_tty_terr_grp_accts ga
                      where narsc.terr_group_account_id = gao.terr_group_account_id
                         -- and ga.named_account_id = na.named_account_id
                          and narsc.resource_id = repdn.resource_id
                          and narsc.rsc_group_id = repdn.group_id
                          and repdn.current_user_id = l_user_id );



    /* this cursor return the managers details for the logged in person group with respect to the
       effected resource */

    cursor c_groups_manager(cl_current_user_id number, cl_eff_resource_id number ) is
    select grv.resource_id, grv.group_id,  grv.role_code
    from
          jtf_tty_my_resources_v grv
        , JTF_RS_GROUPS_DENORM grpd
        , jtf_rs_roles_b rol
     WHERE grpd.parent_group_id = grv.parent_group_id
       and grpd.group_id IN ( select grv1.group_id
                          from  jtf_rs_group_members grv1
                          where  grv1.resource_id = cl_eff_resource_id )
       and grv.CURRENT_USER_ID = cl_current_user_id
       and grv.group_id = grv.parent_group_id
       and grv.role_code = rol.role_code
       and rol.manager_flag = 'Y';



BEGIN

    /***********************************************************
    ****   PHASE 0: API INTERNAL OPTIMIZATIONS
    ****       Populate p_affected_parties_tbl with subsidiaries
    ****       if ASSIGN_SUBSIDIARIES has been selected for any resource
    ************************************************************/


    l_user     := fnd_global.USER_ID;
    l_login_id := fnd_global.LOGIN_ID;
     x_return_status := fnd_api.g_ret_sts_success;



    -- tag all incoming accounts as non-subsidiary record
    IF (p_affected_parties_tbl is not null) THEN
    IF (p_affected_parties_tbl.last > 0) THEN
        -- TAG the original inputs for affected parties
        FOR n in p_affected_parties_tbl.first.. p_affected_parties_tbl.last LOOP
          --  p_affected_parties_tbl(n).attribute1 := 'N';
          null;
        END LOOP;
    END IF;
    END IF;


    ---------------------------------------------
    -- REMOVING RESOURCES IN SALES TEAM
    ---------------------------------------------
    -- Delete resource being removed from account (ALONG WITH ALL HIS DIRECTS)
    IF ((p_affected_parties_tbl is not null) and (p_removed_rscs_tbl is not null)) THEN
    IF ((p_affected_parties_tbl.last > 0) and (p_removed_rscs_tbl.last > 0)) THEN

        FOR j in p_affected_parties_tbl.first.. p_affected_parties_tbl.last LOOP
            -- dbms_output.put_line('p_affected_parties_tbl ' || j || p_affected_parties_tbl(j).party_id);

            -- each named account exists in context of a territory group for resource
            l_terr_group_account_id      := p_affected_parties_tbl(j).terr_group_account_id;

            /* JRADHAKR: Inserting values to jtf_tty_named_acct_changes table for GTP
               to do an incremental and Total Mode */
            /* by shli, GSST Decom */
            /*
            select jtf_tty_named_acct_changes_s.nextval
              into l_change_id
              from sys.dual;

            insert into jtf_tty_named_acct_changes
            (   NAMED_ACCT_CHANGE_ID
              , OBJECT_VERSION_NUMBER
              , OBJECT_TYPE
              , OBJECT_ID
              , CHANGE_TYPE
              , FROM_WHERE
              , CREATED_BY
              , CREATION_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_DATE
              , LAST_UPDATE_LOGIN
            )
            VALUES (
              l_change_id
              , 1
              , 'TGA'
              , l_terr_group_account_id
              , 'UPDATE'
              , 'UPDATE SALES TEAM'
              , l_user
              , sysdate
              , l_user
              , sysdate
              , l_login_id
            );
            */

            FOR i in p_removed_rscs_tbl.first.. p_removed_rscs_tbl.last LOOP
                -- dbms_output.put_line('p_removed_rscs_tbl ' || i || p_removed_rscs_tbl(i).resource_id);

                IF ((p_removed_rscs_tbl(i).attribute1 = 'Y') OR
                    (p_removed_rscs_tbl(i).attribute1 = 'N' and p_affected_parties_tbl(j).attribute1 = 'N')
                   )
                THEN
                    lp_resource_id   := p_removed_rscs_tbl(i).resource_id;
                    lp_group_id      := p_removed_rscs_tbl(i).group_id;
                    lp_role_code     := p_removed_rscs_tbl(i).role_code;
                    lp_resource_type := p_removed_rscs_tbl(i).resource_type;
                    lp_mgr_resource_id   := p_removed_rscs_tbl(i).mgr_resource_id;

                    -- delete resource to be removed from sales team
                    -- dbms_output.put_line('DELETING FROM jtf_tty_named_acct_rsc ');
                    -- dbms_output.put_line(' ' ||
                    --    ' //l_terr_group_account_id=' || l_terr_group_account_id ||
                    --    ' //lp_resource_id=' ||      lp_resource_id      ||
                    --    ' //lp_group_id=' ||         lp_group_id           ||
                    --    ' //lp_role_code=' ||        lp_role_code          || '//');

                    delete from jtf_tty_named_acct_rsc
                    where rsc_group_id = lp_group_id
                      and rsc_role_code = lp_role_code
                      and terr_group_account_id = l_terr_group_account_id
                      and resource_id = lp_resource_id;



                    -- if no one in user's hierarhy is assigned to this account
                    -- after this delete, add user to this account

                    -- if no one in user's hierarhy is assigned to this account
                    -- after this delete, set assigned_to_direct_flag to 'N' for user's NA

                    -- ACHANDA : bug 3265188 : change the IN clause to EXISTS to improve performance

                if (p_from_where <> 'ADMIN') THEN
                    select count(*) INTO l_directs_on_account
                    from jtf_tty_named_acct_rsc ar
                    where ar.terr_group_account_id = l_terr_group_account_id
                    and exists (
                                 select 1
                                 from jtf_tty_my_resources_v grv
                                    , jtf_rs_groups_denorm grpd
                                 WHERE ar.resource_id = grv.resource_id
                                 and   grpd.parent_group_id = grv.parent_group_id
                                 and   exists (
                                                select 1
                                                from  jtf_rs_group_members grv1
                                                where  grpd.group_id = grv1.group_id
                                                and    grv1.resource_id = lp_resource_id )
                                 and grv.CURRENT_USER_ID = l_user_id )
                    and rownum < 2;

                    -- dbms_output.put_line('l_directs_on_account =  ' || l_directs_on_account);

                    IF l_directs_on_account = 0 THEN
                        select jtf_tty_named_acct_rsc_s.nextval into new_seq_acct_rsc_id
                        from dual;

                        lp_mgr_group_id      := p_removed_rscs_tbl(i).mgr_group_id;
                        lp_mgr_role_code     := p_removed_rscs_tbl(i).mgr_role_code;

                        -- assigned flag N because user did not assign himself.
                        -- It is an auto assign to user when none of his directs are assigned.
                        insert into jtf_tty_named_acct_rsc (
                            account_resource_id,
                            object_version_number,
                            terr_group_account_id,
                            resource_id,
                            rsc_group_id,
                            rsc_role_code,
                            assigned_flag,
                            rsc_resource_type,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date
                          )
                        VALUES (
                            new_seq_acct_rsc_id,     --account_resource_id,
                            2,                       --object_version_number
                            l_terr_group_account_id, --terr_group_account_id
                            lp_mgr_resource_id,      --resource_id,
                            lp_mgr_group_id,         --rsc_group_id,
                            lp_mgr_role_code,        --rsc_role_code,
                            'N',                     --assigned_flag,
                            lp_user_resource_type,   --rsc_resource_type
                            1,                       --created_by
                            sysdate,                 --creation_date
                            1,                       --last_updated_by
                            sysdate                  --last_update_date
                        );




                    END IF;  --l_directs_on_account = 0?
                  END IF; -- not for admin
                    -- LOOP THROUGH ALL SUBORDINATES OF THIS RESOURCE_ID
                    -- remove all directs of this rem_resource_id from account
                    -- this cursor does not include lp_resource_id itself.

                    --bug 2828011: do not remove directs if user removing self.
                    IF lp_mgr_resource_id <> lp_resource_id THEN
                       /* not required as we do not have denorm table */
                       /*
                        FOR crd IN c_rsc_directs(lp_resource_id, lp_group_id) LOOP
                            -- delete subordinates from JTF_TTY_NAMED_ACCT_RSC
                            DELETE FROM JTF_TTY_NAMED_ACCT_RSC
                            WHERE rsc_role_code = lp_role_code
                              AND terr_group_account_id = l_terr_group_account_id
                              AND resource_id = crd.resource_id;


                        END LOOP; -- c_rsc_directs
                        */
                       null;
                    END IF;  -- lp_user_resource_id <> lp_resource_id ?

                END IF;  -- process this? (subsidiary logic)

            END LOOP; -- p_removed_rscs_tbl

        END LOOP; -- p_affected_parties_tbl

    END IF; --  ((p_affected_parties_tbl.last > 0) and (p_removed_rscs_tbl.last > 0))
    END IF; --  ((p_affected_parties_tbl is not null) and (p_removed_rscs_tbl is not null))
    /***********************************************************
    ****   PHASE I: DATAMODEL MODIFICATIONS
    ****       Changes made only to JTF_TTY_NAMED_ACCT_RSC
    ****                            JTF_TTY_ACCT_RSC_DN
    ************************************************************/
    -- dbms_output.put_line('PHASE I ');

    ---------------------------------------------
    -- ADDING RESOURCES TO SALES TEAM
    ---------------------------------------------
    IF ((p_affected_parties_tbl is not null) and (p_added_rscs_tbl is not null)) THEN
    IF ((p_affected_parties_tbl.last > 0) and (p_added_rscs_tbl.last > 0)) THEN

        FOR j in p_affected_parties_tbl.first.. p_affected_parties_tbl.last LOOP
            -- dbms_output.put_line('Adding Resources to: p_affected_parties_tbl =' || j || p_affected_parties_tbl(j).party_id);

            -- each named account exists in context of a territory group for resource
            l_terr_group_account_id      := p_affected_parties_tbl(j).terr_group_account_id;

            FOR i in p_added_rscs_tbl.first.. p_added_rscs_tbl.last LOOP
                -- dbms_output.put_line('Resource being Added: p_added_rscs_tbl =' || i || p_added_rscs_tbl(i).resource_id);

                IF ((p_added_rscs_tbl(i).attribute1 = 'Y') OR
                    (p_added_rscs_tbl(i).attribute1 = 'N' and p_affected_parties_tbl(j).attribute1 = 'N')
                   )
                THEN

                    lp_resource_id   := p_added_rscs_tbl(i).resource_id;
                    lp_group_id      := p_added_rscs_tbl(i).group_id;
                    lp_role_code     := p_added_rscs_tbl(i).role_code;
                    lp_resource_type := p_added_rscs_tbl(i).resource_type;
                    lp_mgr_resource_id   := p_added_rscs_tbl(i).mgr_resource_id;

                    -- method of processing depends on whether resource is the user.  Bug: 2816957
                    if lp_mgr_resource_id = lp_resource_id then
                        -- DOES RECORD PROCESSED EXIST?  Bug: 2729383
                        select count(*) into l_acct_rsc_exist_count
                        from (
                                select account_resource_id
                                from jtf_tty_named_acct_rsc
                                where resource_id = lp_resource_id
                                  and rsc_group_id = lp_group_id
                                  and rsc_role_code = lp_role_code
                                  and terr_group_account_id = l_terr_group_account_id
                                  and assigned_flag = 'Y' -- still need a Y assign flag on NA/RSC to abort addition.
                                  and rownum < 2
                          );
                    else
                        -- DOES RECORD PROCESSED EXIST?  Bug: 2729383
                        select count(*) into l_acct_rsc_exist_count
                        from (
                                select account_resource_id
                                from jtf_tty_named_acct_rsc
                                where resource_id = lp_resource_id
                                  and rsc_group_id = lp_group_id
                                  and rsc_role_code = lp_role_code
                                  and terr_group_account_id = l_terr_group_account_id
                                  -- and assigned_flag = 'Y' bug 2803830
                                  and rownum < 2
                          );

                    end if;


                    -- DOES RECORD TO BE PROCESSED EXIST?
                    IF l_acct_rsc_exist_count = 0 THEN

                        --is user resource_id a leaf node in hierarchy?
                        l_resource_id_is_leaf := 'Y';
                        FOR crd IN c_rsc_owned_grps(lp_resource_id, lp_group_id) LOOP
                            l_resource_id_is_leaf := 'N';
                            EXIT;
                        END LOOP; -- c_rsc_directs

                        -- set l_assign_flag for account
                        IF (   (lp_resource_id = lp_mgr_resource_id)
                            OR (l_resource_id_is_leaf = 'Y'))
                        THEN l_assign_flag := 'Y';
                        ELSE l_assign_flag := 'N';
                        END IF;

                        -- test if record already exists for this rsc/grp/role with assign Y


                        -- insert into jtf_tty_named_acct_rsc
                        select jtf_tty_named_acct_rsc_s.nextval into new_seq_acct_rsc_id
                        from dual;

                        -- dbms_output.put_line('inserting to jtf_tty_named_acct_rsc ');
                        -- dbms_output.put_line(' ' || ' //new_seq_acct_rsc_id=' || new_seq_acct_rsc_id ||
                        --' //l_terr_group_account_id=' || l_terr_group_account_id ||' //lp_resource_id=' ||
                        --      lp_resource_id      ||' //lp_group_id=' ||         lp_group_id
                        --||       l_assign_flag        ||' //lp_resource_type=' ||    lp_resource_type );

                        -- assigned flag Y because user is assigning this individual, may be himself.
                        insert into jtf_tty_named_acct_rsc (
                            account_resource_id,
                            object_version_number,
                            terr_group_account_id,
                            resource_id,
                            rsc_group_id,
                            rsc_role_code,
                            assigned_flag,
                            rsc_resource_type,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
							attribute1,
							attribute2,
							attribute3,
							attribute4,
							attribute5,
                            START_DATE,
                            END_DATE
                          )
                        VALUES (
                            new_seq_acct_rsc_id,     --account_resource_id,
                            2,                       --object_version_number
                            l_terr_group_account_id, --terr_group_account_id
                            lp_resource_id,          --resource_id,
                            lp_group_id,             --rsc_group_id,
                            lp_role_code,            --rsc_role_code,
                            l_assign_flag,           --assigned_flag,
                            lp_resource_type,        --rsc_resource_type
                            1,                        --created_by
                            sysdate,                  --creation_date
                            1,                       --last_updated_by
                            sysdate                  --last_update_date
							,p_added_rscs_tbl(i).RESOURCE_ATT1
        					,p_added_rscs_tbl(i).RESOURCE_ATT2
							,p_added_rscs_tbl(i).RESOURCE_ATT3
							,p_added_rscs_tbl(i).RESOURCE_ATT4
							,p_added_rscs_tbl(i).RESOURCE_ATT5
                            ,p_added_rscs_tbl(i).RESOURCE_START_DATE
                            ,p_added_rscs_tbl(i).RESOURCE_END_DATE
                        );

                        -- if user exists as an account resource w/assign_flag = N then
                        -- delete user for this account from JTF_TTY_NAMED_ACCT_RSC
                        -- dbms_output.put_line('deleting from JTF_TTY_NAMED_ACCT_RSC:' || '//lp_group_id:'
                        --|| lp_group_id ||'//p_role_code:' ||lp_role_code ||'//l_terr_group_account_id:'
                        --||l_terr_group_account_id || '//lp_user_resource_id:' || lp_user_resource_id);
                        -- Bug: 2726632
                        -- Bug: 2732533

                        /* JRADHAKR: Inserting values to jtf_tty_named_acct_changes table for GTP
                           to do an incremental and Total Mode */
                        /* by shli, GSST Decom */
                        /* select jtf_tty_named_acct_changes_s.nextval
                          into l_change_id
                          from sys.dual;

                        insert into jtf_tty_named_acct_changes
                        (   NAMED_ACCT_CHANGE_ID
                          , OBJECT_VERSION_NUMBER
                          , OBJECT_TYPE
                          , OBJECT_ID
                          , CHANGE_TYPE
                          , FROM_WHERE
                          , CREATED_BY
                          , CREATION_DATE
                          , LAST_UPDATED_BY
                          , LAST_UPDATE_DATE
                          , LAST_UPDATE_LOGIN
                        )
                        VALUES (
                          l_change_id
                          , 1
                          , 'TGA'
                          , l_terr_group_account_id
                          , 'UPDATE'
                          , 'UPDATE SALES TEAM'
                          , l_user
                          , sysdate
                          , l_user
                          , sysdate
                          , l_login_id
                        );
                        */

                        delete from jtf_tty_named_acct_rsc
                        where 1=1
                          --and rsc_group_id = lp_group_id
                          --and rsc_role_code = lp_role_code
                          and terr_group_account_id = l_terr_group_account_id
                          and resource_id = lp_mgr_resource_id
                          and assigned_flag = 'N';

					 ELSE
					 -- add 06/05/2006 bug 5246668, update resource attributes
					   update jtf_tty_named_acct_rsc
					   set attribute1 = p_added_rscs_tbl(i).RESOURCE_ATT1,
					   	   attribute2 = p_added_rscs_tbl(i).RESOURCE_ATT2,
						   attribute3 = p_added_rscs_tbl(i).RESOURCE_ATT3,
						   attribute4 = p_added_rscs_tbl(i).RESOURCE_ATT4,
						   attribute5 = p_added_rscs_tbl(i).RESOURCE_ATT5,
						   start_date = p_added_rscs_tbl(i).RESOURCE_START_DATE,
						   end_date	  = p_added_rscs_tbl(i).RESOURCE_END_DATE
                       where resource_id = lp_resource_id
                         and rsc_group_id = lp_group_id
                         and rsc_role_code = lp_role_code
                         and terr_group_account_id = l_terr_group_account_id;

                     END IF; -- DOES RECORD TO BE PROCESSED EXIST?

                END IF; -- process this? (subsidiary logic)

            END LOOP;  -- p_added_rscs_tbl

        END LOOP;  -- LOOP p_affected_parties_tbl

    END IF; --((p_affected_parties_tbl.last > 0) and (p_added_rscs_tbl.last > 0))
    END IF; --((p_affected_parties_tbl is not null) and (p_added_rscs_tbl is not null))

 exception

      when others then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         l_error_msg := substr(sqlerrm,1,200);
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
         fnd_message.set_token('ERRMSG', l_error_msg );
         put_jty_log('Error in POPULATE_SALES_TEAM: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
         return;

END POPULATE_SALES_TEAM;

/* Procedure to check if all the salespersons provided in the excel document
*  are valid. It internally calls validate_resource to see if the salespersons
*  are valid from Resource Manager's data and are in TG's role access.
*/

PROCEDURE  VALIDATE_SALES_TEAM(
                     p_Api_Version_Number          IN  NUMBER,
                     p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
                     p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
                     p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
                     X_Return_Status               OUT NOCOPY VARCHAR2,
                     X_Msg_Count                   OUT NOCOPY NUMBER,
                     X_Msg_Data                    OUT NOCOPY VARCHAR2,
                     P_TERR_GP_ID                  IN  NUMBER,
					 P_START_DATE				   IN  DATE,
					 P_END_DATE					   IN  DATE,
                     l_excel_rscs_tbl              IN  EXCEL_SALESREP_RSC_TBLTYP,
                     x_added_rscs_tbl              OUT NOCOPY SALESREP_RSC_TBL_TYPE)
AS
 j integer := 0;
 p_resource_name varchar2(300);
 p_group_name varchar2(300);
 p_role_name varchar2(300);
 errbuf varchar2(2000);
 retcode number;
 X_RESOURCE_id  number;
 x_group_id number;
 x_role_code varchar2(30);
 x_error_code varchar2(2);
 x_status varchar2(3);
 l_error_msg      VARCHAR2(250);
 l_rsc_start_date date;
 l_rsc_end_date	  date;
BEGIN
   -- dbms_output.put_line('Sandeep - Begin update sales team: after validate resource');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_added_rscs_tbl := SALESREP_RSC_TBL_TYPE();
 if l_excel_rscs_tbl.FIRST is not null THEN
  FOR i in l_excel_rscs_tbl.first.. l_excel_rscs_tbl.last LOOP
    if l_excel_rscs_tbl(i).resource_name is not null
       or
       l_excel_rscs_tbl(i).group_name is not null
       or
       l_excel_rscs_tbl(i).role_name  is not null
    THEN
                 -- dbms_output.put_line('Sandeep - before validate resource: before validate resource');
               validate_resource (
                   P_Api_Version_Number   => P_Api_Version_Number,
                   p_Init_Msg_List        => p_Init_Msg_List,
                   p_Commit               => p_Commit,
                   p_validation_level     => p_validation_level,
                   X_Return_Status        => X_Return_Status,
                   X_Msg_Count            => X_Msg_Count,
                   X_Msg_Data             => X_Msg_Data,
                   P_RESOURCE_NAME        =>l_excel_rscs_tbl(i).resource_name ,
                   P_GROUP_NAME           =>l_excel_rscs_tbl(i).group_name ,
                   P_ROLE_NAME            =>l_excel_rscs_tbl(i).role_name ,
                   P_terr_group_id        =>P_TERR_GP_ID ,
                   X_RESOURCE_id          =>X_RESOURCE_id ,
                   x_group_id             =>x_group_id ,
                   x_role_code            =>x_role_code ,
                   x_error_code           =>x_error_code,
                   x_status               =>x_status );
  -- dbms_output.put_line('Sandeep - after validate resource: before validate resource ' || i || ' status ' ||x_status);
               if x_status = 'S' then
       --          -- dbms_output.put_line('Sandeep - Before inserting to x_added_rscs_tbl');
                 x_added_rscs_tbl.extend;
        --          -- dbms_output.put_line('Sandeep - After extending to x_added_rscs_tbl');
                 j:=j+1;
                 x_added_rscs_tbl(j).resource_id := X_RESOURCE_id;
                 x_added_rscs_tbl(j).group_id    := x_group_id;
                 x_added_rscs_tbl(j).role_code   := x_role_code;
                 x_added_rscs_tbl(j).resource_att1 := l_excel_rscs_tbl(i).resource_att1;
                 x_added_rscs_tbl(j).resource_att2 := l_excel_rscs_tbl(i).resource_att2;
                 x_added_rscs_tbl(j).resource_att3 := l_excel_rscs_tbl(i).resource_att3;
                 x_added_rscs_tbl(j).resource_att4 := l_excel_rscs_tbl(i).resource_att4;
                 x_added_rscs_tbl(j).resource_att5 := l_excel_rscs_tbl(i).resource_att5;
                 x_added_rscs_tbl(j).attribute1  := 'N';
                 x_added_rscs_tbl(j).attribute2  := i;

                 -- added 06/05/2006 bug 5246668, to validate and set date
                 IF l_excel_rscs_tbl(i).resource_start_date is null THEN
                   x_added_rscs_tbl(j).resource_start_date := P_START_DATE;
                 ELSE
                   IF (l_excel_rscs_tbl(i).resource_start_date < P_START_DATE) THEN
                     x_return_status := fnd_api.g_ret_sts_error;
                     fnd_message.clear;
                     fnd_message.set_name ('JTF', 'JTY_RSC_STARTDATE_NOT_VALID');
              	   	 FND_MESSAGE.Set_Token ('RES_NAME', i ||', '||l_excel_rscs_tbl(i).resource_name||',');
                     return;
              	   ELSE
              	     x_added_rscs_tbl(j).resource_start_date := l_excel_rscs_tbl(i).resource_start_date;
              	   END IF;
                 END IF;

                 IF l_excel_rscs_tbl(i).resource_end_date is null THEN
              	   x_added_rscs_tbl(j).resource_end_date := P_END_DATE;
                 ELSE
                   IF (l_excel_rscs_tbl(i).resource_end_date BETWEEN p_start_date and P_end_date) THEN
              	     x_added_rscs_tbl(j).resource_end_date := l_excel_rscs_tbl(i).resource_end_date;
              	   ELSE
                     x_return_status := fnd_api.g_ret_sts_error;
                     fnd_message.clear;
                     fnd_message.set_name ('JTF', 'JTY_RSC_ENDDATE_NOT_VALID');
              	   	 FND_MESSAGE.Set_Token ('RES_NAME', i ||', '||l_excel_rscs_tbl(i).resource_name||',');
                     return;
              	   END IF;
                 END IF;

                 -- end for bug 5246668, by mhtran

                 -- dbms_output.put_line('Sandeep - after inserting to x_added_rscs_tbl');
               elsif x_status = 'I' then NULL;
               else
                 x_return_status := fnd_api.g_ret_sts_error;
                 -- dbms_output.put_line('Sandeep - error in update sales team: after validate resource' );
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', i); end if;
                 return;
               end if;
      END IF;
  END LOOP;
 END IF;
    --  -- dbms_output.put_line('Sandeep - ');
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     -- dbms_output.put_line('Sandeep - ' || sqlerrm);
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );
      put_jty_log('Error in VALIDATE_SALES_TEAM: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
      return;
END VALIDATE_SALES_TEAM;

/* Procedure to update the sales team assignments for an account
*  It gets invoked by populate_admin_excel_data for update sales team
*  it validates the salespersons, checks if they can be added then
*  delete and addd salespersons, if needed and assign to owners of tg if
*  needed.
*/
PROCEDURE UPDATE_SALES_TEAM (
                   p_Api_Version_Number          IN  NUMBER,
                     p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
                     p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
                     p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
                     X_Return_Status               OUT NOCOPY VARCHAR2,
                     X_Msg_Count                   OUT NOCOPY NUMBER,
                     X_Msg_Data                    OUT NOCOPY VARCHAR2,
                     p_added_rscs_tbl              IN  SALESREP_RSC_TBL_TYPE,
                     P_TERR_GP_ID                  IN NUMBER ,
                     P_TERR_GP_ACCT_ID             IN NUMBER ,
                     P_NAMED_ACCT_ID               IN NUMBER,
					 P_SALES_GROUP				   IN NUMBER,
					 P_SALES_ROLE				   IN VARCHAR2)
AS
  i integer:=0;
 j integer :=0;
 k integer :=0;
 m integer :=0;
 n integer :=0;
 CURSOR c_res_list(l_terr_grp_acct_id IN number,
		 l_sales_group		IN number,
		 l_sales_role		IN varchar2)
 IS select RESOURCE_ID, RSC_GROUP_ID , RSC_ROLE_CODE
 from jtf_tty_named_acct_rsc
 where TERR_GROUP_ACCOUNT_ID = l_terr_grp_acct_id
   and (l_sales_group is null
   	    or RSC_GROUP_ID in
		(select group_id
		from jtf_rs_groups_denorm
		where parent_group_id = l_sales_group))
   and (l_sales_role is null
   	    or RSC_ROLE_CODE = l_sales_role);

 errbuf varchar2(2000);
 retcode number;
 X_RESOURCE_id  number;
 x_group_id number;
 x_role_code varchar2(30);
 x_error_code varchar2(2);
 x_status varchar2(3);

 l_added_rscs_tbl       SALESREP_RSC_TBL_TYPE;
 l_add_rscs_tbl         SALESREP_RSC_TBL_TYPE;
 l_directs_tbl          SALESREP_RSC_TBL_TYPE;
 l_removed_rscs_tbl     SALESREP_RSC_TBL_TYPE;
 l_rscs_owners_tbl     SALESREP_RSC_OWNERS_TBL_TYPE;
 l_owners_tbl OWNER_RSC_TBL_TYPE;

 l_affected_parties_tbl AFFECTED_PARTY_TBL_TYPE;
 l_user_id NUMBER;
 l_assign_flag varchar2(1);
 l_whether_exist varchar2(1);
 l_atleast_one_rep boolean := FALSE;
 l_valid_person_flag boolean := FALSE;
 l_add_count    NUMBER := 0;
 l_delete_count NUMBER := 0;
 i integer:=0;
 l_error_msg      VARCHAR2(250);

 l_res_found    BOOLEAN := FALSE;
 cursor get_owners_c(l_tg_id  NUMBER)
 IS
 select resource_id,
        rsc_group_id,
        rsc_role_code,
        'N' delete_flag
 from   jtf_tty_terr_grp_owners
 where  terr_group_id = l_tg_id;


BEGIN

     -- dbms_output.put_line('Sandeep - before update sales team');
     l_user_id := fnd_global.user_id;
     l_added_rscs_tbl := SALESREP_RSC_TBL_TYPE();
     l_added_rscs_tbl := p_added_rscs_tbl;
     l_affected_parties_tbl := AFFECTED_PARTY_TBL_TYPE();
     l_owners_tbl  := OWNER_RSC_TBL_TYPE();
    -- l_owners_tbl.extend;
     l_affected_parties_tbl.extend;
     l_affected_parties_tbl(1).terr_group_account_id := P_TERR_GP_ACCT_ID;
     l_affected_parties_tbl(1).attribute1 := 'N';
     /* get all the owners for this TG */
     X_Return_Status := FND_API.G_RET_STS_SUCCESS;
     for owners in get_owners_c(P_TERR_GP_ID) LOOP
        j := j+1;
        l_owners_tbl.extend();
        l_owners_tbl(j).resource_id := owners.resource_id;
        l_owners_tbl(j).group_id    := owners.rsc_group_id;
        l_owners_tbl(j).role_code   := owners.rsc_role_code;
        l_owners_tbl(j).delete_flag  := 'N';
      end loop;

       l_add_rscs_tbl := SALESREP_RSC_TBL_TYPE();
       l_removed_rscs_tbl := SALESREP_RSC_TBL_TYPE();
       /* get owners for all the salespersons coming from excel document */
       -- dbms_output.put_line('Sandeep - In update sales team: before gt resource owners' || l_added_rscs_tbl.count());
       if ( l_added_rscs_tbl.FIRST is not null) THEN
          GET_RESOURCE_OWNERS(
                         P_Api_Version_Number    => P_Api_Version_Number,
                         p_Init_Msg_List         => p_Init_Msg_List,
                         p_Commit                => p_Commit,
                         p_validation_level      => p_validation_level,
                         X_Return_Status         => X_Return_Status,
                         X_Msg_Count             => X_Msg_Count,
                         X_Msg_Data              => X_Msg_Data,
                         p_terr_gp_id            => P_TERR_GP_ID,
                         P_RESOURCES_TBL         => l_added_rscs_tbl,
                         x_rscs_owners_tbl        => l_rscs_owners_tbl
		              ,  x_error_code            => x_error_code
                      ,  x_status                => x_status );
      end if;
       -- dbms_output.put_line('Sandeep - In update sales team: after gt resource owners ' || X_Return_Status);
    IF ( l_added_rscs_tbl.FIRST is not null) THEN
     IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
       if l_added_rscs_tbl.FIRST is not null
        then
           -- dbms_output.put_line('Sandeep - In update sales team: data in added rscs table ');
           for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
           loop
             if l_rscs_owners_tbl.FIRST is not null THEN
               -- dbms_output.put_line('Sandeep - In update sales team: data in added rscs table ');
               for k in l_rscs_owners_tbl.FIRST..l_rscs_owners_tbl.LAST
               loop
                  if (l_added_rscs_tbl(j).group_id = l_rscs_owners_tbl(k).group_id) THEN
                         l_valid_person_flag := TRUE;
					-- dbms_output.put_line('In update sales team, valid person flag: true');
                         for m in l_owners_tbl.FIRST..l_owners_tbl.LAST  loop
                          if (l_owners_tbl(m).resource_id = l_rscs_owners_tbl(k).owner_resource_id
                              and
                              l_owners_tbl(m).group_id = l_rscs_owners_tbl(k).owner_group_id
                              and
                              l_owners_tbl(m).role_code = l_rscs_owners_tbl(k).owner_role_code) THEN
                              l_owners_tbl(m).delete_flag := 'Y';
                           end if;
                         end loop;
                   end if;
               end loop;
             else
               x_return_status := FND_API.G_RET_STS_ERROR;
               fnd_message.clear;
               fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
               FND_MESSAGE.Set_Token ('POSITION', l_added_rscs_tbl(j).attribute2);
               RETURN;
             end if;
             if (l_valid_person_flag = TRUE) THEN
               begin
                   l_valid_person_flag := FALSE;
                   select ASSIGNED_FLAG
                   into l_assign_flag
                   from jtf_tty_named_acct_rsc
                   where TERR_GROUP_ACCOUNT_ID = P_TERR_GP_ACCT_ID
                   and RESOURCE_ID           = l_added_rscs_tbl(j).Resource_id
                   and RSC_GROUP_ID          = l_added_rscs_tbl(j).group_id
                   and RSC_ROLE_CODE         = l_added_rscs_tbl(j).role_code
                   and RSC_RESOURCE_TYPE     = 'RS_EMPLOYEE';
-- dbms_output.put_line('Sandeep - In populate sales team: existing salesperson ' || l_added_rscs_tbl(j).Resource_id );
                   IF l_assign_flag = 'N' THEN
                         l_add_rscs_tbl.extend;
                         n := n + 1;
                         l_add_rscs_tbl(n).resource_id :=  l_added_rscs_tbl(j).Resource_id;
                         l_add_rscs_tbl(n).group_id    :=  l_added_rscs_tbl(j).group_id;
                         l_add_rscs_tbl(n).role_code   :=  l_added_rscs_tbl(j).role_code;
                         l_add_rscs_tbl(n).resource_att1 :=  l_added_rscs_tbl(j).resource_att1;
                         l_add_rscs_tbl(n).resource_att2 :=  l_added_rscs_tbl(j).resource_att2;
                         l_add_rscs_tbl(n).resource_att3 :=  l_added_rscs_tbl(j).resource_att3;
                         l_add_rscs_tbl(n).resource_att4 :=  l_added_rscs_tbl(j).resource_att4;
                         l_add_rscs_tbl(n).resource_att5 :=  l_added_rscs_tbl(j).resource_att5;
                         l_add_rscs_tbl(n).resource_start_date :=  l_added_rscs_tbl(j).resource_start_date;
                         l_add_rscs_tbl(n).resource_end_date :=  l_added_rscs_tbl(j).resource_end_date;
                         l_add_rscs_tbl(n).attribute1  :=  'N';
-- dbms_output.put_line('In update resource, attribute1: ' ||l_add_rscs_tbl(n).resource_att1);
                         /* for admin upload, the manager does not make sense as the administrator
                         *  is acting as territory group owners. This code should not be there for a RM Upload */
                         l_add_rscs_tbl(n).mgr_resource_id := -999;
                         l_add_rscs_tbl(n).mgr_group_id := -999;
                         l_add_rscs_tbl(n).mgr_role_code := '-999';
                         l_add_rscs_tbl(n).resource_type := 'RS_EMPLOYEE';
                   ELSE  --l_assign_flag = 'Y',ignore
                         NULL;
                   END IF;


               exception
                 when no_data_found then
                         l_add_rscs_tbl.extend;
                         n := n + 1;
                         l_add_rscs_tbl(n).resource_id :=  l_added_rscs_tbl(j).Resource_id;
                         l_add_rscs_tbl(n).group_id    :=  l_added_rscs_tbl(j).group_id;
                         l_add_rscs_tbl(n).role_code   :=  l_added_rscs_tbl(j).role_code;
						 l_add_rscs_tbl(n).resource_att1 :=  l_added_rscs_tbl(j).resource_att1;
						 l_add_rscs_tbl(n).resource_att2 :=  l_added_rscs_tbl(j).resource_att2;
						 l_add_rscs_tbl(n).resource_att3 :=  l_added_rscs_tbl(j).resource_att3;
						 l_add_rscs_tbl(n).resource_att4 :=  l_added_rscs_tbl(j).resource_att4;
						 l_add_rscs_tbl(n).resource_att5 :=  l_added_rscs_tbl(j).resource_att5;
                         l_add_rscs_tbl(n).resource_start_date :=  l_added_rscs_tbl(j).resource_start_date;
                         l_add_rscs_tbl(n).resource_end_date :=  l_added_rscs_tbl(j).resource_end_date;

-- dbms_output.put_line('update resource, attribute 1: '||l_add_rscs_tbl(n).resource_att1);
                         l_add_rscs_tbl(n).attribute1  :=  'N';
                         /* for admin upload, the manager does not make sense as the administrator
                         *  is acting as territory group owners. This code should not be there for a RM Upload */
                         l_add_rscs_tbl(n).mgr_resource_id := -999;
                         l_add_rscs_tbl(n).mgr_group_id := -999;
                         l_add_rscs_tbl(n).mgr_role_code := '-999';
                         l_add_rscs_tbl(n).resource_type := 'RS_EMPLOYEE';
               end;
              else
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    fnd_message.clear;
                    fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
                    FND_MESSAGE.Set_Token ('POSITION', l_added_rscs_tbl(j).attribute2);
                    RETURN;
              end if;
           end loop;
        end if;
   ELSE
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          -- dbms_output.put_line('Sandeep -  ERror 2 In populate sales team');
         l_error_msg := substr(sqlerrm,1,200);
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
         fnd_message.set_token('ERRMSG', l_error_msg );
         put_jty_log('Error in UPDATE_SALES_TEAM: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
         return;
   END IF;
 END IF;
 IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
    for i in l_owners_tbl.FIRST..l_owners_tbl.LAST  loop
      if (l_owners_tbl(i).delete_flag = 'N') THEN
-- dbms_output.put_line ('In owner tbl');
                l_add_rscs_tbl.extend;
                 n := n + 1;
                 l_add_rscs_tbl(n).resource_id :=  l_owners_tbl(i).Resource_id;
                 l_add_rscs_tbl(n).group_id    :=  l_owners_tbl(i).group_id;
                 l_add_rscs_tbl(n).role_code   :=  l_owners_tbl(i).role_code;
                 l_add_rscs_tbl(n).attribute1  :=  'N';
                 /* for admin upload, the manager does not make sense as the administrator
                 *  is acting as territory group owners. This code should not be there for a RM Upload */
                 l_add_rscs_tbl(n).mgr_resource_id := -999;
                 l_add_rscs_tbl(n).mgr_group_id := -999;
                 l_add_rscs_tbl(n).mgr_role_code := '-999';
                 l_add_rscs_tbl(n).resource_type := 'RS_EMPLOYEE';
      end if;
    end loop;
 END IF;

   for c_res in c_res_list(P_TERR_GP_ACCT_ID, P_SALES_GROUP, P_SALES_ROLE)
        loop
            l_res_found := FALSE;
            if l_added_rscs_tbl.FIRST is not null
            then
              for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
              loop
                if l_added_rscs_tbl(j).Resource_id = c_res.Resource_id
                  and l_added_rscs_tbl(j).group_id = c_res.RSC_GROUP_ID
                  and l_added_rscs_tbl(j).role_code = c_res.RSC_ROLE_CODE
                then
                   l_res_found := TRUE;
                   exit;
                END IF;
              end loop;
            end if;

            if l_res_found = FALSE THEN
            Begin
                 l_removed_rscs_tbl.extend;
                 l_delete_count := l_delete_count +1;
                 l_removed_rscs_tbl(l_delete_count).resource_id := c_res.Resource_id;
                 l_removed_rscs_tbl(l_delete_count).group_id    := c_res.RSC_GROUP_ID;
                 l_removed_rscs_tbl(l_delete_count).role_code   := c_res.RSC_ROLE_CODE;
                 l_removed_rscs_tbl(l_delete_count).attribute1  := 'N';

                l_removed_rscs_tbl(l_delete_count).mgr_resource_id := -999;
                l_removed_rscs_tbl(l_delete_count).mgr_group_id    := -999;
                l_removed_rscs_tbl(l_delete_count).mgr_role_code   := '-999';
                l_removed_rscs_tbl(l_delete_count).resource_type   := 'RS_EMPLOYEE';
            Exception
              when others then
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                -- dbms_output.put_line('Sandeep -  Error In populate sales team: removed sales persons processing');
                l_error_msg := substr(sqlerrm,1,200);
                fnd_message.clear;
                fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
                fnd_message.set_token('ERRMSG', l_error_msg );
                put_jty_log('Error in UPDATE_SALES_TEAM: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
                return;
            end;
            end if;  -- if l_res_found = FALSE
        end loop;  -- end of c_res loop

       -- dbms_output.put_line('Sandeep -  In populate sales team: Before doing update sales team ');
        /* for admin upload, the manager does not make sense as the administrator
                 *  is acting as territory group owners. This code should not be there for a RM Upload */
        -- now remove and add salespersons for this account
        POPULATE_SALES_TEAM(
                   p_api_version_number    => 1,
                   p_init_msg_list         => 'N',
                   p_SQL_Trace             => 'N',
                   p_Debug_Flag            => 'N',
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   p_from_where            => 'ADMIN',
                   p_user_resource_id      => null,
                   p_terr_group_id         => p_terr_gp_id,
                   p_user_attribute1       => fnd_global.user_id,
                   --p_user_attribute1       => 1069,
                   p_user_attribute2       => null,
                   p_added_rscs_tbl        => l_add_rscs_tbl,
                   p_removed_rscs_tbl      => l_removed_rscs_tbl,
                   p_affected_parties_tbl  => l_affected_parties_tbl,
                   ERRBUF                  => errbuf,
                   RETCODE                 => retcode
               );



   exception
      when no_data_found then
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_NA_NOT_ASSIGED');
         -- dbms_output.put_line('Sandeep -  ERror 1 In populate sales team');
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;

      when others then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          -- dbms_output.put_line('Sandeep -  ERror 2 In populate sales team');
         l_error_msg := substr(sqlerrm,1,200);
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
         fnd_message.set_token('ERRMSG', l_error_msg );
         put_jty_log('Error in UPDATE_SALES_TEAM: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
         return;

END UPDATE_SALES_TEAM;

/* Procedure called during Add to Org with Update Sales Team and Transfer to TG with Update Sales Team
*  It makes the sales team assignments for the accounts
*  APIs called: Populate Sales Team
*/
PROCEDURE ADD_SALES_TEAM (
                     p_Api_Version_Number          IN  NUMBER,
                     p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
                     p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
                     p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
                     X_Return_Status               OUT NOCOPY VARCHAR2,
                     X_Msg_Count                   OUT NOCOPY NUMBER,
                     X_Msg_Data                    OUT NOCOPY VARCHAR2,
                     p_added_rscs_tbl              IN  SALESREP_RSC_TBL_TYPE,
                     P_TERR_GP_ID                  IN NUMBER ,
                     P_TERR_GP_ACCT_ID             IN NUMBER ,
                     P_NAMED_ACCT_ID               IN NUMBER)
AS

 errbuf varchar2(2000);
 retcode number;
 X_OWNER_RESOURCE_id  number;
 x_owner_group_id number;
 x_owner_role_code varchar2(60);
 x_error_code varchar2(2);
 x_status varchar2(3);

 l_added_rscs_tbl       SALESREP_RSC_TBL_TYPE;
 l_rscs_owners_tbl      SALESREP_RSC_OWNERS_TBL_TYPE;
 l_add_rscs_tbl         SALESREP_RSC_TBL_TYPE;
 l_directs_tbl          SALESREP_RSC_TBL_TYPE;
 l_removed_rscs_tbl     SALESREP_RSC_TBL_TYPE;
 l_owners_tbl           OWNER_RSC_TBL_TYPE;
 l_affected_parties_tbl AFFECTED_PARTY_TBL_TYPE;

 l_user_id NUMBER;
 l_assign_flag varchar2(1);
 l_whether_exist varchar2(1);
 l_atleast_one_rep boolean := FALSE;
 l_add_count    NUMBER := 0;
 l_delete_count NUMBER := 0;
 l_valid_person_flag boolean := FALSE;
 i integer:=0;
 j integer :=0;
 k integer :=0;
 m integer :=0;
 n integer :=0;
 l_error_msg      VARCHAR2(250);



 l_res_found    BOOLEAN := FALSE;
 cursor get_owners_c(l_tg_id  NUMBER)
 IS
 select resource_id,
        rsc_group_id,
        rsc_role_code,
        'N' delete_flag
 from   jtf_tty_terr_grp_owners
 where  terr_group_id = l_tg_id;


BEGIN

     -- dbms_output.put_line('Sandeep - Start of Add sales team');
     l_user_id := fnd_global.user_id;
     l_added_rscs_tbl := SALESREP_RSC_TBL_TYPE();
     l_added_rscs_tbl := p_added_rscs_tbl;
     l_affected_parties_tbl := AFFECTED_PARTY_TBL_TYPE();
     l_owners_tbl  := OWNER_RSC_TBL_TYPE();
    -- l_owners_tbl.extend;
     l_affected_parties_tbl.extend;
     l_affected_parties_tbl(1).terr_group_account_id := P_TERR_GP_ACCT_ID;
     l_affected_parties_tbl(1).attribute1 := 'N';
     l_rscs_owners_tbl := SALESREP_RSC_OWNERS_TBL_TYPE();
     /* get all the owners for this TG into a PL/SQL table*/
          -- dbms_output.put_line('Sandeep - Start of Add sales team 1');
     for owners in get_owners_c(P_TERR_GP_ID) LOOP
        j := j+1;
        l_owners_tbl.extend();
        l_owners_tbl(j).resource_id := owners.resource_id;
        l_owners_tbl(j).group_id    := owners.rsc_group_id;
        l_owners_tbl(j).role_code   := owners.rsc_role_code;
        l_owners_tbl(j).delete_flag  := 'N';
      end loop;
  -- dbms_output.put_line('Sandeep - Start of Add sales team 2');
       l_add_rscs_tbl     := SALESREP_RSC_TBL_TYPE();
       l_removed_rscs_tbl := SALESREP_RSC_TBL_TYPE();
       /* get owners for all the salespersons coming from excel document */
       GET_RESOURCE_OWNERS(
                         P_Api_Version_Number    => P_Api_Version_Number,
                         p_Init_Msg_List         => p_Init_Msg_List,
                         p_Commit                => p_Commit,
                         p_validation_level      => p_validation_level,
                         X_Return_Status         => X_Return_Status,
                         X_Msg_Count             => X_Msg_Count,
                         X_Msg_Data              => X_Msg_Data,
                         p_terr_gp_id            => P_TERR_GP_ID,
                         P_RESOURCES_TBL         => l_added_rscs_tbl,
                         x_rscs_owners_tbl       => l_rscs_owners_tbl
		              ,  x_error_code            => x_error_code
                      ,  x_status                => x_status );
       -- dbms_output.put_line('Sandeep - Start of Add sales team status ' || X_Return_Status);
     IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
       if l_added_rscs_tbl.FIRST is not null
        then
           -- dbms_output.put_line('Sandeep - looping added resources table ');
           for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
           loop
                 -- dbms_output.put_line('Sandeep - before looping added resources owners table ');
             if l_rscs_owners_tbl.FIRST is not null THEN
               -- dbms_output.put_line('Sandeep - looping added resources owners table ');
               for k in l_rscs_owners_tbl.FIRST..l_rscs_owners_tbl.LAST

               loop
                   -- dbms_output.put_line('Sandeep - looping added resources owners table ');
                  if (l_added_rscs_tbl(j).group_id = l_rscs_owners_tbl(k).group_id) THEN
                         l_valid_person_flag := TRUE;
                         for m in l_owners_tbl.FIRST..l_owners_tbl.LAST  loop
                          if (l_owners_tbl(m).resource_id = l_rscs_owners_tbl(k).owner_resource_id
                              and
                              l_owners_tbl(m).group_id = l_rscs_owners_tbl(k).owner_group_id
                              and
                              l_owners_tbl(m).role_code = l_rscs_owners_tbl(k).owner_role_code) THEN
                              l_owners_tbl(m).delete_flag := 'Y';
                           end if;
                         end loop;
                   end if;
               end loop; /* end of looping resource's owners table */
             else
               x_return_status := FND_API.G_RET_STS_ERROR;
                -- dbms_output.put_line('Sandeep - No Owners found');
               fnd_message.clear;
               fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
               FND_MESSAGE.Set_Token ('POSITION', l_added_rscs_tbl(j).attribute2);
               RETURN;
             end if;
              -- dbms_output.put_line('Sandeep - 111');
             if (l_valid_person_flag = TRUE) /* add the salesperson to l_add_rsc_tbl */ THEN
                         l_valid_person_flag := FALSE;
                         l_add_rscs_tbl.extend;
                         n := n + 1;
                         l_add_rscs_tbl(n).resource_id :=  l_added_rscs_tbl(j).Resource_id;
                         l_add_rscs_tbl(n).group_id    :=  l_added_rscs_tbl(j).group_id;
                         l_add_rscs_tbl(n).role_code   :=  l_added_rscs_tbl(j).role_code;
						 l_add_rscs_tbl(n).resource_att1 :=  l_added_rscs_tbl(j).resource_att1;
						 l_add_rscs_tbl(n).resource_att2 :=  l_added_rscs_tbl(j).resource_att2;
						 l_add_rscs_tbl(n).resource_att3 :=  l_added_rscs_tbl(j).resource_att3;
						 l_add_rscs_tbl(n).resource_att4 :=  l_added_rscs_tbl(j).resource_att4;
						 l_add_rscs_tbl(n).resource_att5 :=  l_added_rscs_tbl(j).resource_att5;
                         l_add_rscs_tbl(n).resource_start_date :=  l_added_rscs_tbl(j).resource_start_date;
                         l_add_rscs_tbl(n).resource_end_date :=  l_added_rscs_tbl(j).resource_end_date;

-- dbms_output.put_line('add resource, attribute 1: '||l_add_rscs_tbl(n).resource_att1);
                         l_add_rscs_tbl(n).attribute1  :=  'N';
                         /* for admin upload, the manager does not make sense as the administrator
                         *  is acting as territory group owners. This code should not be there for a RM Upload */
                         l_add_rscs_tbl(n).mgr_resource_id := -999;
                         l_add_rscs_tbl(n).mgr_group_id := -999;
                         l_add_rscs_tbl(n).mgr_role_code := '-999';
                         l_add_rscs_tbl(n).resource_type := 'RS_EMPLOYEE';
              else
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    fnd_message.clear;
                    fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
                    FND_MESSAGE.Set_Token ('POSITION', l_added_rscs_tbl(j).attribute2);
                    RETURN;
              end if;
           end loop; /* end of looping l_added_rscs_tbl */
        end if; /* end of if l_added_rscs_tbl.first is not null */
   ELSE /* if GET_RESOURCE_OWNERS returned error */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          -- dbms_output.put_line('Sandeep -  ERror 2 In populate sales team');
         l_error_msg := substr(sqlerrm,1,200);
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
         fnd_message.set_token('ERRMSG', l_error_msg );
         return;
   END IF;
    -- dbms_output.put_line('Sandeep - 222');
  IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
    for i in l_owners_tbl.FIRST..l_owners_tbl.LAST  loop
      if (l_owners_tbl(i).delete_flag = 'N') THEN
                 l_add_rscs_tbl.extend;
                 n := n + 1;
                 l_add_rscs_tbl(n).resource_id :=  l_owners_tbl(i).Resource_id;
                 l_add_rscs_tbl(n).group_id    :=  l_owners_tbl(i).group_id;
                 l_add_rscs_tbl(n).role_code   :=  l_owners_tbl(i).role_code;
                 l_add_rscs_tbl(n).attribute1  :=  'N';
                 /* for admin upload, the manager does not make sense as the administrator
                 *  is acting as territory group owners. This code should not be there for a RM Upload */
                 l_add_rscs_tbl(n).mgr_resource_id := -999;
                 l_add_rscs_tbl(n).mgr_group_id := -999;
                 l_add_rscs_tbl(n).mgr_role_code := '-999';
                 l_add_rscs_tbl(n).resource_type := 'RS_EMPLOYEE';
        end if;
     end loop;
  END IF;


       -- dbms_output.put_line('Sandeep -  In populate sales team: Before doing update sales team ');
        /* for admin upload, the manager does not make sense as the administrator
                 *  is acting as territory group owners. This code should not be there for a RM Upload */
        -- now remove and add salespersons for this account
        POPULATE_SALES_TEAM(
                   p_api_version_number    => 1,
                   p_init_msg_list         => 'N',
                   p_SQL_Trace             => 'N',
                   p_Debug_Flag            => 'N',
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   p_from_where            => 'ADMIN',
                   p_user_resource_id      => null,
                   p_terr_group_id         => p_terr_gp_id,
                   p_user_attribute1       => fnd_global.user_id,
                   --p_user_attribute1       => 1069,
                   p_user_attribute2       => null,
                   p_added_rscs_tbl        => l_add_rscs_tbl,
                   p_removed_rscs_tbl      => l_removed_rscs_tbl,
                   p_affected_parties_tbl  => l_affected_parties_tbl,
                   ERRBUF                  => errbuf,
                   RETCODE                 => retcode
               );



   exception
      when no_data_found then
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_NA_NOT_ASSIGED');
         -- dbms_output.put_line('Sandeep -  ERror 1 In populate sales team');
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;

      when others then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- dbms_output.put_line('Sandeep  ' || SQLERRM);
          -- dbms_output.put_line('Sandeep -  ERror 2 In populate sales team');
         l_error_msg := substr(sqlerrm,1,200);
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
         fnd_message.set_token('ERRMSG', l_error_msg );
         put_jty_log('Error in ADD_SALES_TEAM: ' || SQLERRM, 'ORACLE.APPS.ORACLE.APPS.ORACLE.APPS.JTF.JTF_TTY_MAINTAIN_NA_PVT', FND_LOG.LEVEL_UNEXPECTED);
         return;

END ADD_SALES_TEAM;


--Procedure that is invoked for each updated row in Excel (WEB ADI)
--This procedure uploads the data from Excel to the database by calling various APIs.

PROCEDURE POPULATE_ADMIN_EXCEL_DATA(
   P_PARTY_NUMBER                 IN       VARCHAR2,
   P_NAMED_ACCOUNT                IN       VARCHAR2,
   P_SITE_TYPE                    IN       VARCHAR2,
   P_TRADE_NAME                   IN       VARCHAR2,
   P_DUNS                         IN       VARCHAR2,
   P_GU_DUNS                      IN       VARCHAR2,
   P_GU_NAME                      IN       VARCHAR2,
   P_DU_DUNS                      IN       VARCHAR2,
   P_DU_NAME                      IN       VARCHAR2,
   P_CITY                         IN       VARCHAR2,
   P_STATE                        IN       VARCHAR2,
   P_POSTAL_CODE                  IN       VARCHAR2,
   P_TERRITORY_GROUP              IN       VARCHAR2,
   P_TO_TERRITORY_GROUP           IN       VARCHAR2,
   P_DELETE_FLAG                  IN       VARCHAR2,
   P_RESOURCE1_NAME               IN       VARCHAR2,
   P_GROUP1_NAME                  IN       VARCHAR2,
   P_ROLE1_NAME                   IN       VARCHAR2,
   P_RESOURCE2_NAME               IN       VARCHAR2,
   P_GROUP2_NAME                  IN       VARCHAR2,
   P_ROLE2_NAME                   IN       VARCHAR2,
   P_RESOURCE3_NAME               IN       VARCHAR2,
   P_GROUP3_NAME                  IN       VARCHAR2,
   P_ROLE3_NAME                   IN       VARCHAR2,
   P_RESOURCE4_NAME               IN       VARCHAR2,
   P_GROUP4_NAME                  IN       VARCHAR2,
   P_ROLE4_NAME                   IN       VARCHAR2,
   P_RESOURCE5_NAME               IN       VARCHAR2,
   P_GROUP5_NAME                  IN       VARCHAR2,
   P_ROLE5_NAME                   IN       VARCHAR2,
   P_RESOURCE6_NAME               IN       VARCHAR2,
   P_GROUP6_NAME                  IN       VARCHAR2,
   P_ROLE6_NAME                   IN       VARCHAR2,
   P_RESOURCE7_NAME               IN       VARCHAR2,
   P_GROUP7_NAME                  IN       VARCHAR2,
   P_ROLE7_NAME                   IN       VARCHAR2,
   P_RESOURCE8_NAME               IN       VARCHAR2,
   P_GROUP8_NAME                  IN       VARCHAR2,
   P_ROLE8_NAME                   IN       VARCHAR2,
   P_RESOURCE9_NAME               IN       VARCHAR2,
   P_GROUP9_NAME                  IN       VARCHAR2,
   P_ROLE9_NAME                   IN       VARCHAR2,
   P_RESOURCE10_NAME              IN       VARCHAR2,
   P_GROUP10_NAME                 IN       VARCHAR2,
   P_ROLE10_NAME                  IN       VARCHAR2,
   P_RESOURCE11_NAME              IN       VARCHAR2,
   P_GROUP11_NAME                 IN       VARCHAR2,
   P_ROLE11_NAME                  IN       VARCHAR2,
   P_RESOURCE12_NAME              IN       VARCHAR2,
   P_GROUP12_NAME                 IN       VARCHAR2,
   P_ROLE12_NAME                  IN       VARCHAR2,
   P_RESOURCE13_NAME              IN       VARCHAR2,
   P_GROUP13_NAME                 IN       VARCHAR2,
   P_ROLE13_NAME                  IN       VARCHAR2,
   P_RESOURCE14_NAME              IN       VARCHAR2,
   P_GROUP14_NAME                 IN       VARCHAR2,
   P_ROLE14_NAME                  IN       VARCHAR2,
   P_RESOURCE15_NAME              IN       VARCHAR2,
   P_GROUP15_NAME                 IN       VARCHAR2,
   P_ROLE15_NAME                  IN       VARCHAR2,
   P_RESOURCE16_NAME              IN       VARCHAR2,
   P_GROUP16_NAME                 IN       VARCHAR2,
   P_ROLE16_NAME                  IN       VARCHAR2,
   P_RESOURCE17_NAME              IN       VARCHAR2,
   P_GROUP17_NAME                 IN       VARCHAR2,
   P_ROLE17_NAME                  IN       VARCHAR2,
   P_RESOURCE18_NAME              IN       VARCHAR2,
   P_GROUP18_NAME                 IN       VARCHAR2,
   P_ROLE18_NAME                  IN       VARCHAR2,
   P_RESOURCE19_NAME              IN       VARCHAR2,
   P_GROUP19_NAME                 IN       VARCHAR2,
   P_ROLE19_NAME                  IN       VARCHAR2,
   P_RESOURCE20_NAME              IN       VARCHAR2,
   P_GROUP20_NAME                 IN       VARCHAR2,
   P_ROLE20_NAME                  IN       VARCHAR2,
   P_RESOURCE21_NAME              IN       VARCHAR2,
   P_GROUP21_NAME                 IN       VARCHAR2,
   P_ROLE21_NAME                  IN       VARCHAR2,
   P_RESOURCE22_NAME              IN       VARCHAR2,
   P_GROUP22_NAME                 IN       VARCHAR2,
   P_ROLE22_NAME                  IN       VARCHAR2,
   P_RESOURCE23_NAME              IN       VARCHAR2,
   P_GROUP23_NAME                 IN       VARCHAR2,
   P_ROLE23_NAME                  IN       VARCHAR2,
   P_RESOURCE24_NAME              IN       VARCHAR2,
   P_GROUP24_NAME                 IN       VARCHAR2,
   P_ROLE24_NAME                  IN       VARCHAR2,
   P_RESOURCE25_NAME              IN       VARCHAR2,
   P_GROUP25_NAME                 IN       VARCHAR2,
   P_ROLE25_NAME                  IN       VARCHAR2,
   P_RESOURCE26_NAME              IN       VARCHAR2,
   P_GROUP26_NAME                 IN       VARCHAR2,
   P_ROLE26_NAME                  IN       VARCHAR2,
   P_RESOURCE27_NAME              IN       VARCHAR2,
   P_GROUP27_NAME                 IN       VARCHAR2,
   P_ROLE27_NAME                  IN       VARCHAR2,
   P_RESOURCE28_NAME              IN       VARCHAR2,
   P_GROUP28_NAME                 IN       VARCHAR2,
   P_ROLE28_NAME                  IN       VARCHAR2,
   P_RESOURCE29_NAME              IN       VARCHAR2,
   P_GROUP29_NAME                 IN       VARCHAR2,
   P_ROLE29_NAME                  IN       VARCHAR2,
   P_RESOURCE30_NAME              IN       VARCHAR2,
   P_GROUP30_NAME                 IN       VARCHAR2,
   P_ROLE30_NAME                  IN       VARCHAR2,
   P_PARTY_SITE_ID               IN       VARCHAR2,
   P_SALES_GROUP                  IN       VARCHAR2,
   P_SALES_ROLE                	  IN       VARCHAR2,
   P_PHONETIC_NAME                IN       VARCHAR2,
   P_IDENTIFYING_ADDRESS          IN       VARCHAR2,
   P_RES1_ATT1					  IN	   VARCHAR2,
   P_RES2_ATT1					  IN	   VARCHAR2,
   P_RES3_ATT1					  IN	   VARCHAR2,
   P_RES4_ATT1					  IN	   VARCHAR2,
   P_RES5_ATT1					  IN	   VARCHAR2,
   P_RES6_ATT1					  IN	   VARCHAR2,
   P_RES7_ATT1					  IN	   VARCHAR2,
   P_RES8_ATT1					  IN	   VARCHAR2,
   P_RES9_ATT1					  IN	   VARCHAR2,
   P_RES10_ATT1					  IN	   VARCHAR2,
   P_RES11_ATT1					  IN	   VARCHAR2,
   P_RES12_ATT1					  IN	   VARCHAR2,
   P_RES13_ATT1					  IN	   VARCHAR2,
   P_RES14_ATT1					  IN	   VARCHAR2,
   P_RES15_ATT1					  IN	   VARCHAR2,
   P_RES16_ATT1					  IN	   VARCHAR2,
   P_RES17_ATT1					  IN	   VARCHAR2,
   P_RES18_ATT1					  IN	   VARCHAR2,
   P_RES19_ATT1					  IN	   VARCHAR2,
   P_RES20_ATT1					  IN	   VARCHAR2,
   P_RES21_ATT1					  IN	   VARCHAR2,
   P_RES22_ATT1					  IN	   VARCHAR2,
   P_RES23_ATT1					  IN	   VARCHAR2,
   P_RES24_ATT1					  IN	   VARCHAR2,
   P_RES25_ATT1					  IN	   VARCHAR2,
   P_RES26_ATT1					  IN	   VARCHAR2,
   P_RES27_ATT1					  IN	   VARCHAR2,
   P_RES28_ATT1					  IN	   VARCHAR2,
   P_RES29_ATT1					  IN	   VARCHAR2,
   P_RES30_ATT1					  IN	   VARCHAR2,
   P_RES1_ATT2					  IN	   VARCHAR2,
   P_RES2_ATT2					  IN	   VARCHAR2,
   P_RES3_ATT2					  IN	   VARCHAR2,
   P_RES4_ATT2					  IN	   VARCHAR2,
   P_RES5_ATT2					  IN	   VARCHAR2,
   P_RES6_ATT2					  IN	   VARCHAR2,
   P_RES7_ATT2					  IN	   VARCHAR2,
   P_RES8_ATT2					  IN	   VARCHAR2,
   P_RES9_ATT2					  IN	   VARCHAR2,
   P_RES10_ATT2					  IN	   VARCHAR2,
   P_RES11_ATT2					  IN	   VARCHAR2,
   P_RES12_ATT2					  IN	   VARCHAR2,
   P_RES13_ATT2					  IN	   VARCHAR2,
   P_RES14_ATT2					  IN	   VARCHAR2,
   P_RES15_ATT2					  IN	   VARCHAR2,
   P_RES16_ATT2					  IN	   VARCHAR2,
   P_RES17_ATT2					  IN	   VARCHAR2,
   P_RES18_ATT2					  IN	   VARCHAR2,
   P_RES19_ATT2					  IN	   VARCHAR2,
   P_RES20_ATT2					  IN	   VARCHAR2,
   P_RES21_ATT2					  IN	   VARCHAR2,
   P_RES22_ATT2					  IN	   VARCHAR2,
   P_RES23_ATT2					  IN	   VARCHAR2,
   P_RES24_ATT2					  IN	   VARCHAR2,
   P_RES25_ATT2					  IN	   VARCHAR2,
   P_RES26_ATT2					  IN	   VARCHAR2,
   P_RES27_ATT2					  IN	   VARCHAR2,
   P_RES28_ATT2					  IN	   VARCHAR2,
   P_RES29_ATT2					  IN	   VARCHAR2,
   P_RES30_ATT2					  IN	   VARCHAR2,
   P_RES1_ATT3					  IN	   VARCHAR2,
   P_RES2_ATT3					  IN	   VARCHAR2,
   P_RES3_ATT3					  IN	   VARCHAR2,
   P_RES4_ATT3					  IN	   VARCHAR2,
   P_RES5_ATT3					  IN	   VARCHAR2,
   P_RES6_ATT3					  IN	   VARCHAR2,
   P_RES7_ATT3					  IN	   VARCHAR2,
   P_RES8_ATT3					  IN	   VARCHAR2,
   P_RES9_ATT3					  IN	   VARCHAR2,
   P_RES10_ATT3					  IN	   VARCHAR2,
   P_RES11_ATT3					  IN	   VARCHAR2,
   P_RES12_ATT3					  IN	   VARCHAR2,
   P_RES13_ATT3					  IN	   VARCHAR2,
   P_RES14_ATT3					  IN	   VARCHAR2,
   P_RES15_ATT3					  IN	   VARCHAR2,
   P_RES16_ATT3					  IN	   VARCHAR2,
   P_RES17_ATT3					  IN	   VARCHAR2,
   P_RES18_ATT3					  IN	   VARCHAR2,
   P_RES19_ATT3					  IN	   VARCHAR2,
   P_RES20_ATT3					  IN	   VARCHAR2,
   P_RES21_ATT3					  IN	   VARCHAR2,
   P_RES22_ATT3					  IN	   VARCHAR2,
   P_RES23_ATT3					  IN	   VARCHAR2,
   P_RES24_ATT3					  IN	   VARCHAR2,
   P_RES25_ATT3					  IN	   VARCHAR2,
   P_RES26_ATT3					  IN	   VARCHAR2,
   P_RES27_ATT3					  IN	   VARCHAR2,
   P_RES28_ATT3					  IN	   VARCHAR2,
   P_RES29_ATT3					  IN	   VARCHAR2,
   P_RES30_ATT3					  IN	   VARCHAR2,
   P_RES1_ATT4					  IN	   VARCHAR2,
   P_RES2_ATT4					  IN	   VARCHAR2,
   P_RES3_ATT4					  IN	   VARCHAR2,
   P_RES4_ATT4					  IN	   VARCHAR2,
   P_RES5_ATT4					  IN	   VARCHAR2,
   P_RES6_ATT4					  IN	   VARCHAR2,
   P_RES7_ATT4					  IN	   VARCHAR2,
   P_RES8_ATT4					  IN	   VARCHAR2,
   P_RES9_ATT4					  IN	   VARCHAR2,
   P_RES10_ATT4					  IN	   VARCHAR2,
   P_RES11_ATT4					  IN	   VARCHAR2,
   P_RES12_ATT4					  IN	   VARCHAR2,
   P_RES13_ATT4					  IN	   VARCHAR2,
   P_RES14_ATT4					  IN	   VARCHAR2,
   P_RES15_ATT4					  IN	   VARCHAR2,
   P_RES16_ATT4					  IN	   VARCHAR2,
   P_RES17_ATT4					  IN	   VARCHAR2,
   P_RES18_ATT4					  IN	   VARCHAR2,
   P_RES19_ATT4					  IN	   VARCHAR2,
   P_RES20_ATT4					  IN	   VARCHAR2,
   P_RES21_ATT4					  IN	   VARCHAR2,
   P_RES22_ATT4					  IN	   VARCHAR2,
   P_RES23_ATT4					  IN	   VARCHAR2,
   P_RES24_ATT4					  IN	   VARCHAR2,
   P_RES25_ATT4					  IN	   VARCHAR2,
   P_RES26_ATT4					  IN	   VARCHAR2,
   P_RES27_ATT4					  IN	   VARCHAR2,
   P_RES28_ATT4					  IN	   VARCHAR2,
   P_RES29_ATT4					  IN	   VARCHAR2,
   P_RES30_ATT4					  IN	   VARCHAR2,
   P_RES1_ATT5					  IN	   VARCHAR2,
   P_RES2_ATT5					  IN	   VARCHAR2,
   P_RES3_ATT5					  IN	   VARCHAR2,
   P_RES4_ATT5					  IN	   VARCHAR2,
   P_RES5_ATT5					  IN	   VARCHAR2,
   P_RES6_ATT5					  IN	   VARCHAR2,
   P_RES7_ATT5					  IN	   VARCHAR2,
   P_RES8_ATT5					  IN	   VARCHAR2,
   P_RES9_ATT5					  IN	   VARCHAR2,
   P_RES10_ATT5					  IN	   VARCHAR2,
   P_RES11_ATT5					  IN	   VARCHAR2,
   P_RES12_ATT5					  IN	   VARCHAR2,
   P_RES13_ATT5					  IN	   VARCHAR2,
   P_RES14_ATT5					  IN	   VARCHAR2,
   P_RES15_ATT5					  IN	   VARCHAR2,
   P_RES16_ATT5					  IN	   VARCHAR2,
   P_RES17_ATT5					  IN	   VARCHAR2,
   P_RES18_ATT5					  IN	   VARCHAR2,
   P_RES19_ATT5					  IN	   VARCHAR2,
   P_RES20_ATT5					  IN	   VARCHAR2,
   P_RES21_ATT5					  IN	   VARCHAR2,
   P_RES22_ATT5					  IN	   VARCHAR2,
   P_RES23_ATT5					  IN	   VARCHAR2,
   P_RES24_ATT5					  IN	   VARCHAR2,
   P_RES25_ATT5					  IN	   VARCHAR2,
   P_RES26_ATT5					  IN	   VARCHAR2,
   P_RES27_ATT5					  IN	   VARCHAR2,
   P_RES28_ATT5					  IN	   VARCHAR2,
   P_RES29_ATT5					  IN	   VARCHAR2,
   P_RES30_ATT5					  IN	   VARCHAR2,
   P_RES1_START_DATE			  IN	   DATE,
   P_RES2_START_DATE			  IN	   DATE,
   P_RES3_START_DATE			  IN	   DATE,
   P_RES4_START_DATE			  IN	   DATE,
   P_RES5_START_DATE			  IN	   DATE,
   P_RES6_START_DATE			  IN	   DATE,
   P_RES7_START_DATE			  IN	   DATE,
   P_RES8_START_DATE			  IN	   DATE,
   P_RES9_START_DATE			  IN	   DATE,
   P_RES10_START_DATE			  IN	   DATE,
   P_RES11_START_DATE			  IN	   DATE,
   P_RES12_START_DATE			  IN	   DATE,
   P_RES13_START_DATE			  IN	   DATE,
   P_RES14_START_DATE			  IN	   DATE,
   P_RES15_START_DATE			  IN	   DATE,
   P_RES16_START_DATE			  IN	   DATE,
   P_RES17_START_DATE			  IN	   DATE,
   P_RES18_START_DATE			  IN	   DATE,
   P_RES19_START_DATE			  IN	   DATE,
   P_RES20_START_DATE			  IN	   DATE,
   P_RES21_START_DATE			  IN	   DATE,
   P_RES22_START_DATE			  IN	   DATE,
   P_RES23_START_DATE			  IN	   DATE,
   P_RES24_START_DATE			  IN	   DATE,
   P_RES25_START_DATE			  IN	   DATE,
   P_RES26_START_DATE			  IN	   DATE,
   P_RES27_START_DATE			  IN	   DATE,
   P_RES28_START_DATE			  IN	   DATE,
   P_RES29_START_DATE			  IN	   DATE,
   P_RES30_START_DATE			  IN	   DATE,
   P_RES1_END_DATE			  IN	   DATE,
   P_RES2_END_DATE			  IN	   DATE,
   P_RES3_END_DATE			  IN	   DATE,
   P_RES4_END_DATE			  IN	   DATE,
   P_RES5_END_DATE			  IN	   DATE,
   P_RES6_END_DATE			  IN	   DATE,
   P_RES7_END_DATE			  IN	   DATE,
   P_RES8_END_DATE			  IN	   DATE,
   P_RES9_END_DATE			  IN	   DATE,
   P_RES10_END_DATE			  IN	   DATE,
   P_RES11_END_DATE			  IN	   DATE,
   P_RES12_END_DATE			  IN	   DATE,
   P_RES13_END_DATE			  IN	   DATE,
   P_RES14_END_DATE			  IN	   DATE,
   P_RES15_END_DATE			  IN	   DATE,
   P_RES16_END_DATE			  IN	   DATE,
   P_RES17_END_DATE			  IN	   DATE,
   P_RES18_END_DATE			  IN	   DATE,
   P_RES19_END_DATE			  IN	   DATE,
   P_RES20_END_DATE			  IN	   DATE,
   P_RES21_END_DATE			  IN	   DATE,
   P_RES22_END_DATE			  IN	   DATE,
   P_RES23_END_DATE			  IN	   DATE,
   P_RES24_END_DATE			  IN	   DATE,
   P_RES25_END_DATE			  IN	   DATE,
   P_RES26_END_DATE			  IN	   DATE,
   P_RES27_END_DATE			  IN	   DATE,
   P_RES28_END_DATE			  IN	   DATE,
   P_RES29_END_DATE			  IN	   DATE,
   P_RES30_END_DATE			  IN	   DATE,
   P_ATTRIBUTE1					  IN	   VARCHAR2,
   P_ATTRIBUTE2					  IN	   VARCHAR2,
   P_ATTRIBUTE3					  IN	   VARCHAR2,
   P_ATTRIBUTE4					  IN	   VARCHAR2,
   P_ATTRIBUTE5					  IN	   VARCHAR2,
   P_ATTRIBUTE6					  IN	   VARCHAR2,
   P_ATTRIBUTE7					  IN	   VARCHAR2,
   P_ATTRIBUTE8					  IN	   VARCHAR2,
   P_ATTRIBUTE9					  IN	   VARCHAR2,
   P_ATTRIBUTE10					  IN	   VARCHAR2,
   P_ATTRIBUTE11					  IN	   VARCHAR2,
   P_ATTRIBUTE12					  IN	   VARCHAR2,
   P_ATTRIBUTE13					  IN	   VARCHAR2,
   P_ATTRIBUTE14					  IN	   VARCHAR2,
   P_ATTRIBUTE15					  IN	   VARCHAR2,
   P_START_DATE						  IN	   DATE,
   P_END_DATE						  IN	   DATE
   )
AS
  p_salesperson_flag VARCHAR2(1):= 'Y'; -- flag for salespersons, empty or not
  x_status NUMBER;
  x_from_tg_id NUMBER;
  x_from_tg_acct_id NUMBER;
  x_named_acct_id NUMBER;
  x_new_named_acct_id NUMBER;
  x_to_tg_id NUMBER;
  x_to_tg_acct_id NUMBER;
  p_Api_Version_Number            NUMBER := 1.0;
  p_Init_Msg_List               VARCHAR2(1)                    := FND_API.G_FALSE;
  p_Commit                        VARCHAR2(1)                  := FND_API.G_FALSE;
  p_validation_level              NUMBER                     := FND_API.G_VALID_LEVEL_FULL;
  X_Return_Status                VARCHAR2(1);
  X_Msg_Count                    NUMBER;
  l_party_site_id                NUMBER;
  X_Msg_Data                    VARCHAR2(2000);
  l_matching_rule_code            VARCHAR2(30);


  p_from_tg JTF_TTY_TERR_GROUPS.TERR_GROUP_NAME%TYPE;
  p_to_tg   JTF_TTY_TERR_GROUPS.TERR_GROUP_NAME%TYPE;
  p_delete_flag_code VARCHAR2(1);
  l_excel_rscs_tbl       EXCEL_SALESREP_RSC_TBLTYP;
  l_added_rscs_tbl       SALESREP_RSC_TBL_TYPE;
  l_error_msg      VARCHAR2(250);
  i integer :=0;
  l_start_date date;
  l_end_date date;

BEGIN

   p_from_tg        := P_TERRITORY_GROUP;
   p_to_tg          := P_TO_TERRITORY_GROUP;
   l_excel_rscs_tbl := EXCEL_SALESREP_RSC_TBLTYP();
   l_added_rscs_tbl := SALESREP_RSC_TBL_TYPE();
   x_new_named_acct_id :=-999;

   -- set start and end date
   l_start_date := P_START_DATE;
   l_end_date	  := P_END_DATE;


  /* check if party number is missing */
    IF (p_party_number is null OR trim(p_party_number) is null) THEN
         fnd_message.clear;
         FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_PARTYNUM_MISSING');
         RETURN;
    END IF;

   /* check for invalid scenario */

    IF (p_from_tg is null AND p_to_tg is null) THEN
         fnd_message.clear;
         FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_INVALID_ACTION');
         RETURN;
    END IF;

   IF p_to_tg IS NOT NULL THEN

     BEGIN

       Select matching_rule_code
       into l_matching_rule_code
       from jtf_tty_terr_groups
       where terr_group_name = p_to_tg;

       if((p_party_site_id is null or trim(p_party_site_id) is null ) and (trim(l_matching_rule_code) = '1' or trim(l_matching_rule_code) = '2' or trim(l_matching_rule_code) = '5'))
       then
	        raise no_data_found;

      elsif     ((p_party_site_id is null or trim(p_party_site_id) is null ) and (trim(l_matching_rule_code) <> '1' or trim(l_matching_rule_code) <> '2' or trim(l_matching_rule_code) <> '5'))
          then

 	        select party_site_id into l_party_site_id
		from hz_party_sites party_site, hz_parties party
		where party.party_number = p_party_number
		and party.party_id = party_site.party_id
		and party_site.status = 'A'
		and party_site.identifying_address_flag = 'Y';

      else
	       SELECT PARTY_SITE_ID
	       INTO   l_party_site_id
	       FROM   hz_party_sites
	       WHERE  party_site_number = P_PARTY_SITE_ID;
       end if;


       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fnd_message.clear;
         FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_INV_PARTY_SITE_NUM');
         RETURN;
       WHEN OTHERS THEN
         l_error_msg := substr(sqlerrm,1,200);
         fnd_message.clear;
         fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
         fnd_message.set_token('ERRMSG', l_error_msg );
         return;
     END;
   END IF;



   /* check for invalid delete flag */
    BEGIN
      SELECT lookup_code
      INTO   p_delete_flag_code
      FROM   fnd_lookups
      WHERE  lookup_type = 'JTF_TERR_FLAGS'
      AND    upper(meaning)     = upper(p_delete_flag)
      AND    rownum < 2;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         fnd_message.clear;
         FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_INV_DELETE_FLAG');
         RETURN;
     WHEN OTHERS THEN
        l_error_msg := substr(sqlerrm,1,200);
        fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
        fnd_message.set_token('ERRMSG', l_error_msg );
        return;
   END;


   /* check for invalid scenario, white spaces */
    IF (trim(p_from_tg) is null AND trim(p_to_tg) is null) THEN
         fnd_message.clear;
         FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_INVALID_ACTION');
         RETURN;
    END IF;

    /* Retrieve the terr group account details if trying to delete a
       named account, transfer a named account or update sales team */
    IF (p_from_tg is not null and trim(p_from_tg) is not null) THEN
-- dbms_output.put_line('Sandeep - before GET_TERR_GRP_ACCT_DETAILS');
       GET_TERR_GRP_ACCT_DETAILS(
                   p_Api_Version_Number   =>     1.0    ,
                   p_Init_Msg_List        =>     FND_API.G_FALSE      ,
                   p_Commit               =>     FND_API.G_FALSE           ,
                   p_validation_level     =>     FND_API.G_VALID_LEVEL_FULL  ,
                   X_Return_Status        =>     X_Return_Status    ,
                   X_Msg_Count            =>     X_Msg_Count           ,
                   X_Msg_Data             =>     X_Msg_Data,
                   P_PARTY_NUMBER         =>     P_PARTY_NUMBER,
                   P_PARTY_SITE_ID        =>     l_party_site_id,
				   P_ATTRIBUTE1			  => 	 P_ATTRIBUTE1,
                   P_ATTRIBUTE2			  => 	 P_ATTRIBUTE2,
                   P_ATTRIBUTE3			  =>	 P_ATTRIBUTE3,
                   P_ATTRIBUTE4			  => 	 P_ATTRIBUTE4,
                   P_ATTRIBUTE5			  => 	 P_ATTRIBUTE5,
                   P_ATTRIBUTE6			  => 	 P_ATTRIBUTE6,
                   P_ATTRIBUTE7			  => 	 P_ATTRIBUTE7,
                   P_ATTRIBUTE8			  => 	 P_ATTRIBUTE8,
                   P_ATTRIBUTE9			  => 	 P_ATTRIBUTE9,
                   P_ATTRIBUTE10		  => 	 P_ATTRIBUTE10,
                   P_ATTRIBUTE11		  => 	 P_ATTRIBUTE11,
                   P_ATTRIBUTE12		  => 	 P_ATTRIBUTE12,
                   P_ATTRIBUTE13		  => 	 P_ATTRIBUTE13,
                   P_ATTRIBUTE14		  => 	 P_ATTRIBUTE14,
                   P_ATTRIBUTE15		  => 	 P_ATTRIBUTE15,
				   P_START_DATE			  => 	 l_start_date,
				   P_END_DATE			  => 	 l_end_date,
         	   	   P_TERR_GRP_NAME        =>     P_FROM_TG,
                   X_TERR_GRP_ID          =>     X_FROM_TG_ID,
                   X_TERR_GRP_ACCT_ID     =>     X_FROM_TG_ACCT_ID,
                   X_NAMED_ACCT_ID        =>     X_NAMED_ACCT_ID);

       IF (X_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
          RETURN; /* unable to get terr gp acct details due to wrong party number
                 --* wrong tg name or party not a na in the tg */
        END IF;

		JTF_TTY_GEN_TERR_PVT.update_terr_for_na(x_from_tg_acct_id, x_from_tg_id );

    END IF;

    IF (p_resource1_name is null and p_resource2_name is null
        and p_resource3_name is null and p_resource4_name is null
        and p_resource5_name is null and p_resource6_name is null
        and p_resource7_name is null and p_resource8_name is null
        and p_resource9_name is null and p_resource10_name is null
        and p_resource11_name is null and p_resource12_name is null
        and p_resource13_name is null and p_resource14_name is null
        and p_resource15_name is null and p_resource16_name is null
        and p_resource17_name is null and p_resource18_name is null
        and p_resource19_name is null and p_resource20_name is null
        and p_resource21_name is null and p_resource22_name is null
        and p_resource23_name is null and p_resource24_name is null
        and p_resource25_name is null and p_resource26_name is null
        and p_resource27_name is null and p_resource28_name is null
        and p_resource29_name is null and p_resource30_name is null) THEN

        p_salesperson_flag := 'N'; /* no sales persons entered*/
    ELSE /* populate pl/sql table with salespersons from excel document */
        -- dbms_output.put_line('Sandeep - before populating l_excel_rscs_tbl');
        WHILE (i < 30) LOOP
         i:= i + 1;
         l_excel_rscs_tbl.extend;
         if (i = 1) then
          l_excel_rscs_tbl(i).resource_name := p_resource1_name;
          l_excel_rscs_tbl(i).group_name    := p_group1_name;
          l_excel_rscs_tbl(i).role_name     := p_role1_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES1_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES1_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES1_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES1_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES1_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES1_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES1_END_DATE;

		  -- dbms_output.put_line('Attribute 1: '|| l_excel_rscs_tbl(i).RESOURCE_ATT1);
         end if;
         if (i = 2) then
          l_excel_rscs_tbl(i).resource_name := p_resource2_name;
          l_excel_rscs_tbl(i).group_name    := p_group2_name;
          l_excel_rscs_tbl(i).role_name     := p_role2_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES2_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES2_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES2_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES2_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES2_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES2_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES2_END_DATE;

         end if;
         if (i = 3) then
          l_excel_rscs_tbl(i).resource_name := p_resource3_name;
          l_excel_rscs_tbl(i).group_name    := p_group3_name;
          l_excel_rscs_tbl(i).role_name     := p_role3_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES3_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES3_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES3_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES3_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES3_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES3_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES3_END_DATE;

         end if;
         if (i = 4) then
          l_excel_rscs_tbl(i).resource_name := p_resource4_name;
          l_excel_rscs_tbl(i).group_name    := p_group4_name;
          l_excel_rscs_tbl(i).role_name     := p_role4_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES4_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES4_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES4_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES4_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES4_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES4_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES4_END_DATE;

         end if;
         if (i = 5) then
          l_excel_rscs_tbl(i).resource_name := p_resource5_name;
          l_excel_rscs_tbl(i).group_name    := p_group5_name;
          l_excel_rscs_tbl(i).role_name     := p_role5_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES5_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES5_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES5_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES5_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES5_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES5_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES5_END_DATE;

         end if;
         if (i = 6) then
          l_excel_rscs_tbl(i).resource_name := p_resource6_name;
          l_excel_rscs_tbl(i).group_name    := p_group6_name;
          l_excel_rscs_tbl(i).role_name     := p_role6_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES6_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES6_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES6_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES6_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES6_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES6_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES6_END_DATE;

         end if;
         if (i = 7) then
          l_excel_rscs_tbl(i).resource_name := p_resource7_name;
          l_excel_rscs_tbl(i).group_name    := p_group7_name;
          l_excel_rscs_tbl(i).role_name     := p_role7_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES7_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES7_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES7_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES7_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES7_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES7_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES7_END_DATE;

         end if;
         if (i = 8) then
          l_excel_rscs_tbl(i).resource_name := p_resource8_name;
          l_excel_rscs_tbl(i).group_name    := p_group8_name;
          l_excel_rscs_tbl(i).role_name     := p_role8_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES8_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES8_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES8_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES8_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES8_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES8_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES8_END_DATE;

         end if;
         if (i = 9) then
          l_excel_rscs_tbl(i).resource_name := p_resource9_name;
          l_excel_rscs_tbl(i).group_name    := p_group9_name;
          l_excel_rscs_tbl(i).role_name     := p_role9_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES9_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES9_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES9_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES9_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES9_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES9_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES9_END_DATE;

         end if;
         if (i = 10) then
          l_excel_rscs_tbl(i).resource_name := p_resource10_name;
          l_excel_rscs_tbl(i).group_name    := p_group10_name;
          l_excel_rscs_tbl(i).role_name     := p_role10_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES10_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES10_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES10_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES10_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES10_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES10_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES10_END_DATE;

         end if;
         if (i = 11) then
          l_excel_rscs_tbl(i).resource_name := p_resource11_name;
          l_excel_rscs_tbl(i).group_name    := p_group11_name;
          l_excel_rscs_tbl(i).role_name     := p_role11_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES11_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES11_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES11_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES11_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES11_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES11_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES11_END_DATE;

         end if;
         if (i = 12) then
          l_excel_rscs_tbl(i).resource_name := p_resource12_name;
          l_excel_rscs_tbl(i).group_name    := p_group12_name;
          l_excel_rscs_tbl(i).role_name     := p_role12_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES12_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES12_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES12_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES12_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES12_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES12_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES12_END_DATE;

         end if;
         if (i = 13) then
          l_excel_rscs_tbl(i).resource_name := p_resource13_name;
          l_excel_rscs_tbl(i).group_name    := p_group13_name;
          l_excel_rscs_tbl(i).role_name     := p_role13_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES13_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES13_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES13_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES13_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES13_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES13_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES13_END_DATE;

         end if;
         if (i = 14) then
          l_excel_rscs_tbl(i).resource_name := p_resource14_name;
          l_excel_rscs_tbl(i).group_name    := p_group14_name;
          l_excel_rscs_tbl(i).role_name     := p_role14_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES14_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES14_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES14_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES14_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES14_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES14_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES14_END_DATE;

         end if;
         if (i = 15) then
          l_excel_rscs_tbl(i).resource_name := p_resource15_name;
          l_excel_rscs_tbl(i).group_name    := p_group15_name;
          l_excel_rscs_tbl(i).role_name     := p_role15_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES15_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES15_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES15_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES15_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES15_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES15_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES15_END_DATE;

         end if;
         if (i = 16) then
          l_excel_rscs_tbl(i).resource_name := p_resource16_name;
          l_excel_rscs_tbl(i).group_name    := p_group16_name;
          l_excel_rscs_tbl(i).role_name     := p_role16_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES16_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES16_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES16_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES16_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES16_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES16_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES16_END_DATE;

         end if;
         if (i = 17) then
          l_excel_rscs_tbl(i).resource_name := p_resource17_name;
          l_excel_rscs_tbl(i).group_name    := p_group17_name;
          l_excel_rscs_tbl(i).role_name     := p_role17_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES17_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES17_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES17_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES17_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES17_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES17_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES17_END_DATE;

         end if;
         if (i = 18) then
          l_excel_rscs_tbl(i).resource_name := p_resource18_name;
          l_excel_rscs_tbl(i).group_name    := p_group18_name;
          l_excel_rscs_tbl(i).role_name     := p_role18_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES18_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES18_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES18_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES18_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES18_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES18_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES18_END_DATE;

         end if;
         if (i = 19) then
          l_excel_rscs_tbl(i).resource_name := p_resource19_name;
          l_excel_rscs_tbl(i).group_name    := p_group19_name;
          l_excel_rscs_tbl(i).role_name     := p_role19_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES19_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES19_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES19_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES19_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES19_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES19_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES19_END_DATE;

         end if;
         if (i = 20) then
          l_excel_rscs_tbl(i).resource_name := p_resource20_name;
          l_excel_rscs_tbl(i).group_name    := p_group20_name;
          l_excel_rscs_tbl(i).role_name     := p_role20_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES20_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES20_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES20_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES20_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES20_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES20_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES20_END_DATE;

         end if;
         if (i = 21) then
          l_excel_rscs_tbl(i).resource_name := p_resource21_name;
          l_excel_rscs_tbl(i).group_name    := p_group21_name;
          l_excel_rscs_tbl(i).role_name     := p_role21_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES21_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES21_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES21_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES21_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES21_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES21_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES21_END_DATE;

         end if;
         if (i = 22) then
          l_excel_rscs_tbl(i).resource_name := p_resource22_name;
          l_excel_rscs_tbl(i).group_name    := p_group22_name;
          l_excel_rscs_tbl(i).role_name     := p_role22_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES22_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES22_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES22_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES22_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES22_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES22_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES22_END_DATE;

         end if;
         if (i = 23) then
          l_excel_rscs_tbl(i).resource_name := p_resource23_name;
          l_excel_rscs_tbl(i).group_name    := p_group23_name;
          l_excel_rscs_tbl(i).role_name     := p_role23_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES23_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES23_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES23_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES23_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES23_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES23_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES23_END_DATE;

         end if;
         if (i = 24) then
          l_excel_rscs_tbl(i).resource_name := p_resource24_name;
          l_excel_rscs_tbl(i).group_name    := p_group24_name;
          l_excel_rscs_tbl(i).role_name     := p_role24_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES24_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES24_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES24_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES24_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES24_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES24_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES24_END_DATE;

         end if;
         if (i = 25) then
          l_excel_rscs_tbl(i).resource_name := p_resource25_name;
          l_excel_rscs_tbl(i).group_name    := p_group25_name;
          l_excel_rscs_tbl(i).role_name     := p_role25_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES25_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES25_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES25_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES25_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES25_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES25_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES25_END_DATE;

         end if;
         if (i = 26) then
          l_excel_rscs_tbl(i).resource_name := p_resource26_name;
          l_excel_rscs_tbl(i).group_name    := p_group26_name;
          l_excel_rscs_tbl(i).role_name     := p_role26_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES26_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES26_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES26_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES26_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES26_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES26_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES26_END_DATE;

         end if;
         if (i = 27) then
          l_excel_rscs_tbl(i).resource_name := p_resource27_name;
          l_excel_rscs_tbl(i).group_name    := p_group27_name;
          l_excel_rscs_tbl(i).role_name     := p_role27_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES27_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES27_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES27_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES27_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES27_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES27_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES27_END_DATE;

         end if;
         if (i = 28) then
          l_excel_rscs_tbl(i).resource_name := p_resource28_name;
          l_excel_rscs_tbl(i).group_name    := p_group28_name;
          l_excel_rscs_tbl(i).role_name     := p_role28_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES28_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES28_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES28_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES28_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES28_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES28_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES28_END_DATE;

         end if;
         if (i = 29) then
          l_excel_rscs_tbl(i).resource_name := p_resource29_name;
          l_excel_rscs_tbl(i).group_name    := p_group29_name;
          l_excel_rscs_tbl(i).role_name     := p_role29_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES29_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES29_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES29_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES29_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES29_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES29_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES29_END_DATE;

         end if;
         if (i = 30) then
          l_excel_rscs_tbl(i).resource_name := p_resource30_name;
          l_excel_rscs_tbl(i).group_name    := p_group30_name;
          l_excel_rscs_tbl(i).role_name     := p_role30_name;
          l_excel_rscs_tbl(i).RESOURCE_ATT1 := P_RES30_ATT1;
          l_excel_rscs_tbl(i).RESOURCE_ATT2 := P_RES30_ATT2;
          l_excel_rscs_tbl(i).RESOURCE_ATT3 := P_RES30_ATT3;
          l_excel_rscs_tbl(i).RESOURCE_ATT4 := P_RES30_ATT4;
          l_excel_rscs_tbl(i).RESOURCE_ATT5 := P_RES30_ATT5;
          l_excel_rscs_tbl(i).RESOURCE_START_DATE := P_RES30_START_DATE;
          l_excel_rscs_tbl(i).RESOURCE_END_DATE := P_RES30_END_DATE;

         end if;
        END LOOP;
    END IF;
-- dbms_output.put_line('Sandeep - Done with populating l_excel_rscs_tbl');
    IF (P_DELETE_FLAG_CODE = 'Y') THEN /* trying to delete from TG */
 	 /* check for invalid scenarios */
         IF (p_from_tg is null AND p_to_tg is not null) THEN
            fnd_message.clear;
            FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_INV_PROMOTE_DELETE');
            RETURN;
         ELSIF (p_from_tg is not null AND p_to_tg is not null) THEN
            fnd_message.clear;
            FND_MESSAGE.SET_NAME ('JTF', 'JTF_TTY_INV_TRANSFER_DELETE');
            RETURN;
         ELSE /* it is a valid delete from TG case */
         DELETE_ACCT_FROM_TG(P_TERR_GRP_ACCT_ID     => X_FROM_TG_ACCT_ID,
                            P_NAMED_ACCT_ID        => X_NAMED_ACCT_ID,
                            P_TERR_GRP_ID           => X_FROM_TG_ID,
                            P_Api_Version_Number   => P_Api_Version_Number,
                            p_Init_Msg_List        => p_Init_Msg_List,
                            p_Commit               => p_Commit,
                            p_validation_level     => p_validation_level,
                            X_Return_Status        => X_Return_Status,
                            X_Msg_Count            => X_Msg_Count,
                            X_Msg_Data             => X_Msg_Data) ;
         END IF;
    ELSE /* Not a delete from the territory group, can be a
            update sales team, Add to TG, Add to tg with update
             salesteam, Transfer, or transfer with update sales team */
       BEGIN
          IF (p_from_tg is not null AND p_to_tg is null) THEN
              /* i.e. update sales team */
               -- dbms_output.put_line('Sandeep - Before doing validate Sales Team');
              -- Check if all the salespersons are valid ones
              -- if valid x_return_status <>
              validate_sales_team(
                                P_Api_Version_Number          ,
                                p_Init_Msg_List               ,
                                p_Commit                      ,
                                p_validation_level            ,
                                X_Return_Status               ,
                                X_Msg_Count                   ,
                                X_Msg_Data                    ,
                                X_FROM_TG_ID                  ,
                       			L_START_DATE,
                      			L_END_DATE,
                                l_excel_rscs_tbl              ,
                                l_added_rscs_tbl);
              -- dbms_output.put_line('Sandeep - After doing validate Sales Team' || X_Return_Status);
              IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
                  UPDATE_SALES_TEAM(P_Api_Version_Number          ,
                                   p_Init_Msg_List               ,
                                   p_Commit                      ,
                                   p_validation_level            ,
                                   X_Return_Status               ,
                                   X_Msg_Count                   ,
                                   X_Msg_Data                    ,
                                   l_added_rscs_tbl              ,
                                   X_FROM_TG_ID      ,
                                   X_FROM_TG_ACCT_ID ,
                                   X_NAMED_ACCT_ID,
								   P_SALES_GROUP,
								   P_SALES_ROLE);
              ELSE
                  RETURN;
              END IF;
                 -- dbms_output.put_line('Sandeep - After doing Update Sales Team');

              JTF_TTY_GEN_TERR_PVT.update_terr_rscs_for_na(x_from_tg_acct_id, x_from_tg_id );

       ELSIF (p_from_tg is null AND p_to_tg is not null) THEN

         /* i.e. Add to Org or Add to Org with Update Sales Team */
         -- dbms_output.put_line('Sandeep - Add to Org/Add to Org with update sales Team -- Before Add Org to TG');
         ADD_ORG_TO_TG(P_Api_Version_Number   => P_Api_Version_Number,
                       p_Init_Msg_List        => p_Init_Msg_List,
                       p_Commit               => p_Commit,
                       p_validation_level     => p_validation_level,
                       X_Return_Status        => X_Return_Status,
                       X_Msg_Count            => X_Msg_Count,
                       X_Msg_Data             => X_Msg_Data,
                       p_party_number         => p_party_number,
                       p_party_site_id         => l_party_site_id,
		               p_terr_grp_name         => p_to_tg,
					   P_ATTRIBUTE1			   => P_ATTRIBUTE1,
                       P_ATTRIBUTE2			   => P_ATTRIBUTE2,
                       P_ATTRIBUTE3			   => P_ATTRIBUTE3,
                       P_ATTRIBUTE4			   => P_ATTRIBUTE4,
                       P_ATTRIBUTE5			   => P_ATTRIBUTE5,
                       P_ATTRIBUTE6			   => P_ATTRIBUTE6,
                       P_ATTRIBUTE7			   => P_ATTRIBUTE7,
                       P_ATTRIBUTE8			   => P_ATTRIBUTE8,
                       P_ATTRIBUTE9			   => P_ATTRIBUTE9,
                       P_ATTRIBUTE10		   => P_ATTRIBUTE10,
                       P_ATTRIBUTE11		   => P_ATTRIBUTE11,
                       P_ATTRIBUTE12		   => P_ATTRIBUTE12,
                       P_ATTRIBUTE13		   => P_ATTRIBUTE13,
                       P_ATTRIBUTE14		   => P_ATTRIBUTE14,
                       P_ATTRIBUTE15		   => P_ATTRIBUTE15,
                       P_START_DATE	    	   => L_START_DATE,
                       P_END_DATE		       => L_END_DATE,
                       x_terr_grp_acct_id      => x_to_tg_acct_id,
                       x_terr_grp_id           => x_to_tg_id,
                       x_named_acct_id        => x_named_acct_id);

          -- dbms_output.put_line('Sandeep - Add to Org/Add to Org with update sales Team -- After Add Org to TG: Status ' || X_Return_Status);
          IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN /* add of org is successful */
               if (p_salesperson_flag = 'N') THEN
                    /* Add Org to TG, assign the account to territory group owners*/

                    ASSIGN_ACCT_TO_TG_OWNERS(
                             P_Api_Version_Number   => P_Api_Version_Number,
                             p_Init_Msg_List        => p_Init_Msg_List,
                             p_Commit               => p_Commit,
                             p_validation_level     => p_validation_level,
                             X_Return_Status        => X_Return_Status,
                             X_Msg_Count            => X_Msg_Count,
                             X_Msg_Data             => X_Msg_Data,
                             p_terr_grp_acct_id     => x_to_tg_acct_id,
                             p_terr_grp_id          => x_to_tg_id);


               else /* Add Org to TG with update sales team */
                       -- Check if all the salespersons are valid ones
                     -- if valid x_return_status <>
                      -- dbms_output.put_line('Sandeep - Add Org to TG with update Sales Team Before doing validate Sales Team');
                     validate_sales_team(
                                P_Api_Version_Number          ,
                                p_Init_Msg_List               ,
                                p_Commit                      ,
                                p_validation_level            ,
                                X_Return_Status               ,
                                X_Msg_Count                   ,
                                X_Msg_Data                    ,
                                X_TO_TG_ID                  ,
								L_START_DATE,
					 			L_END_DATE,
                                l_excel_rscs_tbl              ,
                                l_added_rscs_tbl);
                          -- dbms_output.put_line('Sandeep - Add Org to TG with update Sales Team After doing validate Sales Team: Status ' || X_Return_Status);
                    IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
                       BEGIN
                        -- dbms_output.put_line('Sandeep - Add Org to TG with update Sales Team Before ADD_SALES_TEAM');
                        ADD_SALES_TEAM(P_Api_Version_Number          ,
                                   p_Init_Msg_List               ,
                                   p_Commit                      ,
                                   p_validation_level            ,
                                   X_Return_Status               ,
                                   X_Msg_Count                   ,
                                   X_Msg_Data                    ,
                                   l_added_rscs_tbl              ,
                                   X_TO_TG_ID      ,
                                   X_TO_TG_ACCT_ID ,
                                   X_NAMED_ACCT_ID);
                         -- dbms_output.put_line('Sandeep - Add Org to TG with update Sales Team After ADD_SALES_TEAM' || X_Return_Status);

                        END;
                    ELSE
                       RETURN;
                    END IF;
             END IF; /* end of update sales team */

             JTF_TTY_GEN_TERR_PVT.create_terr_for_na(x_to_tg_acct_id, x_to_tg_id );
         END IF; /* add of org successful */
      ELSE /* Transfer or Transfer with update Sales Team
            delete the account from the From TG */
        DELETE_ACCT_FROM_TG(P_TERR_GRP_ACCT_ID     => X_FROM_TG_ACCT_ID,
                            P_NAMED_ACCT_ID        => X_NAMED_ACCT_ID,
                            P_TERR_GRP_ID           => X_FROM_TG_ID,
                            P_Api_Version_Number   => P_Api_Version_Number,
                            p_Init_Msg_List        => p_Init_Msg_List,
                            p_Commit               => p_Commit,
                            p_validation_level     => p_validation_level,
                            X_Return_Status        => X_Return_Status,
                            X_Msg_Count            => X_Msg_Count,
                            X_Msg_Data             => X_Msg_Data) ;



        IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
                /* i.e. delete was successful, so move to add org to To Tg */
               ADD_ORG_TO_TG(P_Api_Version_Number   => P_Api_Version_Number,
                       p_Init_Msg_List        => p_Init_Msg_List,
                       p_Commit               => p_Commit,
                       p_validation_level     => p_validation_level,
                       X_Return_Status        => X_Return_Status,
                       X_Msg_Count            => X_Msg_Count,
                       X_Msg_Data             => X_Msg_Data,
                       p_party_number         => p_party_number,
                       p_party_site_id        => l_party_site_id,
		               p_terr_grp_name         => p_to_tg,
					   P_ATTRIBUTE1			   => P_ATTRIBUTE1,
                       P_ATTRIBUTE2			   => P_ATTRIBUTE2,
                       P_ATTRIBUTE3			   => P_ATTRIBUTE3,
                       P_ATTRIBUTE4			   => P_ATTRIBUTE4,
                       P_ATTRIBUTE5			   => P_ATTRIBUTE5,
                       P_ATTRIBUTE6			   => P_ATTRIBUTE6,
                       P_ATTRIBUTE7			   => P_ATTRIBUTE7,
                       P_ATTRIBUTE8			   => P_ATTRIBUTE8,
                       P_ATTRIBUTE9			   => P_ATTRIBUTE9,
                       P_ATTRIBUTE10			   => P_ATTRIBUTE10,
                       P_ATTRIBUTE11			   => P_ATTRIBUTE11,
                       P_ATTRIBUTE12			   => P_ATTRIBUTE12,
                       P_ATTRIBUTE13			   => P_ATTRIBUTE13,
                       P_ATTRIBUTE14			   => P_ATTRIBUTE14,
                       P_ATTRIBUTE15			   => P_ATTRIBUTE15,
                       P_START_DATE			   => L_START_DATE,
                       P_END_DATE			   => L_END_DATE,
                       x_terr_grp_acct_id      => x_to_tg_acct_id,
                       x_terr_grp_id           => x_to_tg_id,
                       x_named_acct_id        => x_new_named_acct_id);

              IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN /* add of org is successful */
                if (p_salesperson_flag = 'N') THEN
                   /* Transfer with no update sales team,
                   * assign the account to territory group owners*/
                    ASSIGN_ACCT_TO_TG_OWNERS(
                            P_Api_Version_Number   => P_Api_Version_Number,
                            p_Init_Msg_List        => p_Init_Msg_List,
                            p_Commit               => p_Commit,
                            p_validation_level     => p_validation_level,
                            X_Return_Status        => X_Return_Status,
                            X_Msg_Count            => X_Msg_Count,
                            X_Msg_Data             => X_Msg_Data,
                            p_terr_grp_acct_id      => x_to_tg_acct_id,
                            p_terr_grp_id           => x_to_tg_id);
                else /* Transfer to TG with update sales team */
                       validate_sales_team(
                                P_Api_Version_Number          ,
                                p_Init_Msg_List               ,
                                p_Commit                      ,
                                p_validation_level            ,
                                X_Return_Status               ,
                                X_Msg_Count                   ,
                                X_Msg_Data                    ,
                                X_TO_TG_ID                  ,
								L_START_DATE,
					 			L_END_DATE,
                                l_excel_rscs_tbl              ,
                                l_added_rscs_tbl);
                    IF (X_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
                       ADD_SALES_TEAM(P_Api_Version_Number          ,
                                   p_Init_Msg_List               ,
                                   p_Commit                      ,
                                   p_validation_level            ,
                                   X_Return_Status               ,
                                   X_Msg_Count                   ,
                                   X_Msg_Data                    ,
                                   l_added_rscs_tbl              ,
                                   X_TO_TG_ID      ,
                                   X_TO_TG_ACCT_ID ,
                                   X_new_NAMED_ACCT_ID);


                    ELSE
                       RETURN;
                    END IF;
          END IF; /* end of update sales team */
        END IF; /* add of org successful */

        JTF_TTY_GEN_TERR_PVT.create_terr_for_na(x_to_tg_acct_id, x_to_tg_id );
       END IF; /* end of delete of org from the from TG was successful */
     END IF;/* end of transfer or transfer with update sales team */

    END; /* of begin for not a delete form TG */
  END IF; /* not a delete form TG */

EXCEPTION
   WHEN OTHERS THEN
      l_error_msg := substr(sqlerrm,1,200);
      fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTF_TTY_ERROR');
      fnd_message.set_token('ERRMSG', l_error_msg );

    -- dbms_output.put_line ('error : '|| l_error_msg);
END POPULATE_ADMIN_EXCEL_DATA;
END JTF_TTY_MAINTAIN_NA_PVT;

/
