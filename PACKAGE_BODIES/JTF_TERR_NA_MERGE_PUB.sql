--------------------------------------------------------
--  DDL for Package Body JTF_TERR_NA_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_NA_MERGE_PUB" AS
/* $Header: jtftptnb.pls 120.5 2006/09/29 21:21:54 spai noship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_NA_MERGE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force named account territory manager public api's.
--      This package is a public API for party merge for named account
--      Territory
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      04/15/03    SGKUMAR     Created
--      08/24/06    JULOU       Forward porting 5071732
--                                1: Merge From Named Party To Named Party (Same Territory Group).
--                                2: Merge From Named Party To Named Party (Distinct Territory Region).
--                                3: Merge From Non-Named Party To Named Party (No Impact).
--                                4: Merge From Named Party To Non-Named Party (Non-Named Party becomes Named).

--    End of Comments

FUNCTION get_party_name(p_party_site_id NUMBER) RETURN VARCHAR2
AS
  p_party_name VARCHAR2(80);
BEGIN
  select hzp.party_name
  into   p_party_name
  from   hz_parties hzp, hz_party_sites hzps
  where  hzp.party_id = hzps.party_id
    and  hzps.party_site_id = p_party_site_id;

  return p_party_name;

  EXCEPTION
   WHEN OTHERS THEN
        p_party_name := null;
        return p_party_name;
END get_party_name;


PROCEDURE create_acct_mappings(p_acct_id IN NUMBER,
                               p_party_id   IN NUMBER,
                               p_party_site_id IN NUMBER,
                               p_user_id   IN NUMBER)
AS
   p_business_name VARCHAR2(360);
   p_trade_name    VARCHAR2(240);
   p_postal_code   VARCHAR2(60);
   p_party_count NUMBER;


BEGIN

   p_business_name := null;
   p_trade_name    := null;
   p_postal_code   := null;

   BEGIN

      SELECT H3.party_name,
             H3.known_as,
             H1.postal_code
      INTO   p_business_name,
             p_trade_name,
             p_postal_code
      FROM   HZ_PARTIES             H3,
             HZ_LOCATIONS           H1,
             HZ_PARTY_SITES         H2
      WHERE  h3.party_id = h2.party_id
      AND    h2.location_id = h1.location_id
      AND    h3.party_id = p_party_id
      AND    h2.party_site_id = p_party_site_id;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
   END;

   IF (p_business_name IS NOT NULL) THEN
   /* key name for business name */
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
        (
        SELECT jtf_tty_acct_qual_maps_s.NEXTVAL,
             1,
             p_acct_id,
             -1012,
             '=',
             UPPER(p_business_name),
             NULL,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE FROM dual);
    END IF;

   /* key name for trade name */
   IF (p_trade_name IS NOT NULL) THEN
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
         (SELECT  jtf_tty_acct_qual_maps_s.NEXTVAL,
             1,
             p_acct_id,
             -1012,
             '=',
             UPPER(p_trade_name),
             NULL,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE FROM dual);
 END IF;

   /* key name for postal code */
   IF (p_postal_code IS NOT NULL) THEN
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
        (SELECT jtf_tty_acct_qual_maps_s.NEXTVAL,
             1,
             p_acct_id,
             -1007,
             '=',
             p_postal_code,
             NULL,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE FROM dual);
  END IF;
END create_acct_mappings;

/* ---------------------------- PARTY MERGE ------------------------
** procedure to merge parties: create exception if the from to
** party or the source is a named account, otherwise do not do anything
** ----------------------------------------------------------------- */
PROCEDURE party_merge( p_entity_name                IN   VARCHAR2,
                       p_from_id                    IN   NUMBER,
                       x_to_id                      OUT  NOCOPY NUMBER,
             	       p_from_fk_id                 IN   NUMBER,
                       p_to_fk_id                   IN   NUMBER,
                       p_parent_entity_name         IN   VARCHAR2,
    	               p_batch_id                   IN   NUMBER,
	               p_batch_party_id             IN   NUMBER,
	               x_return_status              OUT  NOCOPY VARCHAR2 )
IS

BEGIN
       x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END party_merge;


/* ---------------------------- PARTY SITE MERGE ------------------------
** procedure to merge party sites
** ----------------------------------------------------------------- */
PROCEDURE party_site_merge( p_entity_name                IN   VARCHAR2,
                       p_from_id                    IN   NUMBER,
                       x_to_id                      OUT  NOCOPY NUMBER,
                       p_from_fk_id                 IN   NUMBER,
                       p_to_fk_id                   IN   NUMBER,
                       p_parent_entity_name         IN   VARCHAR2,
                       p_batch_id                   IN   NUMBER,
                       p_batch_party_id             IN   NUMBER,
                       x_return_status              OUT  NOCOPY VARCHAR2 )
IS

   l_api_name CONSTANT VARCHAR2(30) :=  'TERR_NA_PARTY_SITE_MERGE';
   p_from_party    VARCHAR2(80);
   p_to_party      VARCHAR2(80);
   l_dist_terr_region  VARCHAR2(1);
   l_cust_name_used_to    VARCHAR2(1);
   p_from_na_flag  VARCHAR2(1);
   p_to_na_flag    VARCHAR2(1);
   p_to_na_id      NUMBER;
   p_from_na_id    NUMBER;
   p_user_id       NUMBER;
   l_from_party_id NUMBER;
   l_to_party_id   NUMBER;
   l_to_party_na_exists VARCHAR2(1);
   l_to_na_exists       VARCHAR2(1);
   l_acct_qual_maps_exist  VARCHAR2(1);
   l_terr_group_id      NUMBER;

   CURSOR c_from_na_id(p_party_id NUMBER) IS
   SELECT named_account_id na_id
   FROM   jtf_tty_named_accts
   WHERE  party_id = p_party_id;

   CURSOR c_to_na_id(p_party_id NUMBER) IS
   SELECT named_account_id na_id
   FROM   jtf_tty_named_accts
   WHERE  party_id = p_party_id;

   CURSOR c_get_tga_details (p_na_id NUMBER) IS
   SELECT tga.terr_group_account_id, tga.terr_group_id, tg.matching_rule_code
     FROM jtf_tty_terr_grp_accts tga, jtf_tty_terr_groups tg
    WHERE tga.terr_group_id = tg.terr_group_id
     AND  tga.named_account_id = p_na_id;

BEGIN

    SAVEPOINT TERR_NA_PARTY_SITE_MERGE_PUB;

    l_dist_terr_region := 'N';
    l_cust_name_used_to  := 'N';
    p_from_na_flag  := 'N';
    p_to_na_flag   := 'N';
    l_to_na_exists := 'N';
    l_to_party_na_exists := 'N';
    l_acct_qual_maps_exist := 'N';
    l_terr_group_id := -1;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'JTY PARTY SITE MERGE BEGIN: '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
    p_user_id := fnd_global.user_id;

    /* If from and To party sites are the same then do nothing.
    We will not merge named accounts */
    IF p_from_fk_id = p_to_fk_id THEN
        x_to_id := p_from_id;
        RETURN;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    IF ( p_entity_name <> 'JTF_TTY_NAMED_ACCTS' OR p_parent_entity_name <> 'HZ_PARTY_SITES' ) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'     Entity error');
               fnd_message.set_name ('JTF', 'JTF_TERR_ENTITY_NAME_ERR');
               fnd_message.set_token('P_ENTITY',p_entity_name);
               fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
               FND_MSG_PUB.add;

               x_return_status := fnd_api.g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
    END IF;

   -- dbms_output.put_line (' Inside Party Site Merge ');

    /* Check the from party is a Named Account */
    BEGIN
         FND_FILE.PUT_LINE(FND_FILE.LOG,' Check if merged FROM party site is a named account');

         select 'Y', named_account_id
         into   p_from_na_flag, p_from_na_id
         from   jtf_tty_named_accts
         where  party_site_id = p_from_fk_id
         and rownum < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_from_na_flag := 'N';
    -- dbms_output.put_line (' No Data Found : p_from_na_flag ' || p_from_fk_id);
    END;

   -- dbms_output.put_line (' p_from_na_flag ' || p_from_na_flag);

    /* Check the To party is a Named Account */

    BEGIN
         FND_FILE.PUT_LINE(FND_FILE.LOG,' Check if merged to party is a named account');
         select 'Y', named_account_id
         into   p_to_na_flag, p_to_na_id
         from   jtf_tty_named_accts
         where  party_site_id = p_to_fk_id
         and rownum < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_to_na_flag := 'N';
    END;

    IF (p_from_na_flag = 'Y' ) then

      p_from_party := get_party_name(p_from_fk_id);

      SELECT hzps.party_id
        INTO l_from_party_id
        FROM hz_party_sites hzps
       WHERE hzps.party_site_id = p_from_fk_id
         AND rownum < 2;

   END IF;

   IF (p_to_na_flag = 'Y' ) then

      p_to_party   := get_party_name(p_to_fk_id);

      SELECT hzps.party_id
      INTO   l_to_party_id
      FROM   hz_party_sites hzps
      WHERE  hzps.party_site_id = p_to_fk_id
        AND  rownum < 2;

    END IF;

   -- dbms_output.put_line (' p_to_na_flag ' || p_to_na_flag);

    IF (p_from_na_flag = 'Y' and p_to_na_flag = 'Y' ) then

          /* Find all TGs that from Named Account belongs to */

          FOR tga_rec IN  c_get_tga_details( p_na_id  => p_from_na_id )
          LOOP

              l_terr_group_id := tga_rec.terr_group_id;

              /* find out whether any non-overlapping Territory groups exist for the from and to parties  */
              BEGIN
                  select 'N'
                    into l_dist_terr_region
                    from jtf_tty_terr_grp_accts jtga_outer
                   where jtga_outer.named_account_id = p_to_na_id
                     and jtga_outer.terr_group_id = tga_rec.terr_group_id
                     and rownum < 2;

               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_dist_terr_region := 'Y';
               END;

               /*  S1: Merge From Named Party To Named Party (Same Territory Group). */
               IF ( l_dist_terr_region = 'N' ) then

                     FND_FILE.PUT_LINE(FND_FILE.LOG,' S1: Merge From Named Account To Named Account (Same Territory Group)');
                     FND_FILE.PUT_LINE(FND_FILE.LOG,' S1: territory group id : ' || to_char(l_terr_group_id));

                    /* Delete records from JTF_TERR_... tables corresponding to the named account */
                     JTF_TTY_GEN_TERR_PVT.delete_TGA(
                       p_terr_grp_acct_id => tga_rec.terr_group_account_id,
                       p_terr_group_id    => tga_rec.terr_group_id,
                       p_catchall_terr_id =>-1,
                       p_change_type      =>'SALES_TEAM_UPDATE'
                     );

                    /* Delete the named account resources for the from party */
                    DELETE FROM jtf_tty_named_acct_rsc
                    WHERE  terr_group_account_id = tga_rec.terr_group_account_id;

                   /* Delete the terr_group accounts for the from party */
                   DELETE FROM jtf_tty_terr_grp_accts
                   WHERE  terr_group_account_id = tga_rec.terr_group_account_id;

                   if ( tga_rec.matching_rule_code = '1' ) then
                      UPDATE jtf_tty_acct_qual_maps
                         SET named_account_id = p_to_na_id
                       WHERE named_account_id = p_from_na_id;
                   end if;

               ELSE

                  /*   S2: Merge From Named Party To Named Party (Distinct Territory Region). */

                 FND_FILE.PUT_LINE(FND_FILE.LOG,' S2: Merge From Named Account To Named Account (Distinct Territory Region) ');
                 FND_FILE.PUT_LINE(FND_FILE.LOG,' S2: territory group id : ' || to_char(l_terr_group_id));

                 /* point the non-overlapping FROM named account to the TO named account */
                 UPDATE jtf_tty_terr_grp_accts jtga
                 SET    jtga.named_account_id = p_to_na_id
                 WHERE  jtga.terr_group_account_id = tga_rec.terr_group_account_id;

                 l_acct_qual_maps_exist := 'N';

                 BEGIN
                   SELECT 'Y'
                   INTO   l_acct_qual_maps_exist
                   FROM   jtf_tty_acct_qual_maps
                   WHERE  named_account_id = p_to_na_id
                     AND  rownum < 2;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       l_acct_qual_maps_exist := 'N';
                 END;

                 /* if to_named_acct has no values in acct qual maps */
                 if ((tga_rec.matching_rule_code = '1') and
                    ( l_acct_qual_maps_exist = 'N' )) then
                    create_acct_mappings(p_to_na_id, l_to_party_id, p_to_fk_id, p_user_id );
                 end if;

                 if ( tga_rec.matching_rule_code = '1' ) then
                      UPDATE jtf_tty_acct_qual_maps
                         SET named_account_id = p_to_na_id
                       WHERE named_account_id = p_from_na_id;
                 end if;

                /* Recreate the from-NA territory as it needs new qualifier values */
                JTF_TTY_GEN_TERR_PVT.create_terr_for_na(tga_rec.terr_group_account_id, tga_rec.terr_group_id );

              END IF; /* Same or different TG */

         END LOOP;  /* Processed all TGs */

         /* Do delete from jtf_tty_named_accts and acct_qual_maps after all processing is done */

         DELETE FROM jtf_tty_acct_qual_maps
          WHERE named_account_id = p_from_na_id;

         DELETE FROM jtf_tty_named_accts
         WHERE party_id = l_from_party_id
           AND party_site_id = p_from_fk_id;

   END IF;  /* both Named accounts */

   /* S3: Merge From Non-Named Party To Named Party (No Impact). */

   IF (p_from_na_flag = 'N' and p_to_na_flag = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,' S3: Merge From Non-Named Account To Named Account (No Impact)');
   END IF;

   /* S4: Merge From Named Account To Non-Named Account (Non-Named Account becomes Named Account). */

   IF (p_from_na_flag = 'Y' and p_to_na_flag = 'N') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: Merge From Named Account To Non-Named Account (Non-Named Account becomes Named)');

        BEGIN
            SELECT hzps.party_id
            INTO   l_to_party_id
            FROM   hz_party_sites hzps
            WHERE  hzps.party_site_id = p_to_fk_id
              AND  rownum < 2;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                null;
        END;


        FOR tga_rec IN  c_get_tga_details( p_na_id  => p_from_na_id )
        LOOP

           l_terr_group_id := tga_rec.terr_group_id;

           IF (tga_rec.matching_rule_code IN ( '3', '4')) then

              l_to_party_na_exists := 'N';
              BEGIN
                 SELECT 'Y'
                 INTO   l_to_party_na_exists
                 FROM   jtf_tty_terr_grp_accts tga,
                       jtf_tty_named_accts jna
                 WHERE  jna.named_account_id = tga.named_account_id
                   AND  jna.party_id = l_to_party_id
                   AND  tga.terr_group_id = tga_rec.terr_group_id
                   AND  rownum < 2;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       l_to_party_na_exists := 'N';
              END;


              IF ( l_to_party_na_exists = 'Y' ) then

                 FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: territory group id :' || to_char(l_terr_group_id) );
                 FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: Party Matching Rule of above TG is either Registry Id or DUNS' );
                 FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: The Party corresponding to To Party Site is a NA in the above TG' );

                 /* Delete records from JTF_TERR_... tables corresponding to the from named account */
                 JTF_TTY_GEN_TERR_PVT.delete_TGA(
                       p_terr_grp_acct_id => tga_rec.terr_group_account_id,
                       p_terr_group_id    => tga_rec.terr_group_id,
                       p_catchall_terr_id =>-1,
                       p_change_type      =>'SALES_TEAM_UPDATE'
                     );


                 /* Delete the named account resources for the from party */
                 DELETE FROM jtf_tty_named_acct_rsc
                  WHERE  terr_group_account_id = tga_rec.terr_group_account_id;

                  /* Delete the terr_group accounts for the from party */
                  DELETE FROM jtf_tty_terr_grp_accts
                  WHERE  terr_group_account_id = tga_rec.terr_group_account_id;

                  /*
                   DELETE FROM jtf_tty_acct_qual_maps
                   WHERE named_account_id = p_from_na_id;
                  */

              END IF; /* l_to_party_na_exists = 'N' */
           END IF; /* l_matching_rule_code = 3 or 4 */


           IF ( ( tga_rec.matching_rule_code NOT IN ( '3', '4' ))
              OR ( l_to_party_na_exists = 'N' ) ) then

              FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: territory group id :' || to_char(l_terr_group_id) );
              FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: Party Matching Rule of above TG is neither Registry Id nor DUNS' );
              FND_FILE.PUT_LINE(FND_FILE.LOG,' S4: The Party corresponding to To Party Site is not a NA in the above TG' );

              l_to_na_exists := 'N';

              /*
              DELETE FROM jtf_tty_acct_qual_maps
              WHERE named_account_id = p_from_na_id;
              */

              BEGIN
                 SELECT 'Y'
                 INTO   l_to_na_exists
                 FROM   jtf_tty_named_accts
                 WHERE  party_id = l_to_party_id
                   AND  party_site_id = p_to_fk_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_to_na_exists := 'N';
               END;

               IF ( l_to_na_exists = 'N' ) then

                 UPDATE jtf_tty_named_accts
                    SET party_id = l_to_party_id,
                        party_site_id = p_to_fk_id
                  WHERE party_id = l_from_party_id
                    AND party_site_id = p_from_fk_id;

                 /* l_cust_name_used_to is 'N' if p_to_na_flag = 'N' */
                 if ( tga_rec.matching_rule_code = '1'  ) then

                    create_acct_mappings(p_from_na_id, l_to_party_id, p_to_fk_id, p_user_id );
                 end if;

               END IF;

               /* Recreate the from-NA territory as it needs new qualifier values */
               JTF_TTY_GEN_TERR_PVT.create_terr_for_na(tga_rec.terr_group_account_id, tga_rec.terr_group_id );

            END IF;
        END LOOP;

        /* Do delete from jtf_tty_named_accts and acct_qual_maps after all processing is done */

        DELETE FROM jtf_tty_named_accts
         WHERE party_id = l_from_party_id
           AND party_site_id = p_from_fk_id;

   END IF; -- end from_na_flag = 'Y'

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'JTY PARTY SITE MERGE END: '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      -- ROLLBACK TO TERR_NA_PARTY_MERGE_PUB;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'JTY PARTY SITE MERGE END: '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
      RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('P_SQLCODE', SQLCODE);
      fnd_message.set_token('P_SQLERRM', SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      -- ROLLBACK TO TERR_NA_PARTY_MERGE_PUB;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'JTY PARTY SITE MERGE END: '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
      RAISE;
END party_site_merge;

END JTF_TERR_NA_MERGE_PUB;

/
