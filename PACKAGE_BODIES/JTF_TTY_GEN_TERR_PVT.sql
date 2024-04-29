--------------------------------------------------------
--  DDL for Package Body JTF_TTY_GEN_TERR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_GEN_TERR_PVT" AS
/* $Header: jtftsstb.pls 120.22 2006/09/29 07:30:35 spai ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_GEN_TERR_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to generate the territories
--      based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      11/19/03    ACHANDA          Created
--
--      03/04/04    ACHANDA          Bug# 3426946 : Uptake of party number matching rule
--      05/24/04    ACHANDA          Fix Bug# 3645451
--
--    End of Comments
--
--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------

   /* Global System Variables */
   G_Debug           BOOLEAN      := FALSE;
   G_APPL_ID         NUMBER       := FND_GLOBAL.prog_appl_id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.conc_login_id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.conc_program_id;
   G_USER_ID         NUMBER       := FND_GLOBAL.user_id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.conc_request_id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.application_short_name;
   G_SYSDATE         DATE         := SYSDATE;
   G_JTF_SCHEMA      VARCHAR2(20) := 'JTF';
   G_CUTOFF_TIME     DATE;
   G_COMMIT_CHUNK_SIZE  NUMBER    := 50000;
   g_prod_cat_enabled   BOOLEAN;
   g_opp_qual_usg_id    NUMBER;
   g_lead_qual_usg_id   NUMBER;


   TYPE g_terr_group_id_tab IS TABLE OF jtf_tty_terr_groups.terr_group_id%TYPE;
   TYPE g_terr_group_name_tab IS TABLE OF jtf_tty_terr_groups.terr_group_name%TYPE;
   TYPE g_rank_tab IS TABLE OF jtf_tty_terr_groups.rank%TYPE;
   TYPE g_active_from_date_tab IS TABLE OF jtf_tty_terr_groups.active_from_date%TYPE;
   TYPE g_active_to_date_tab IS TABLE OF jtf_tty_terr_groups.active_to_date%TYPE;
   TYPE g_parent_terr_id_tab IS TABLE OF jtf_tty_terr_groups.parent_terr_id%TYPE;
   TYPE g_matching_rule_code_tab IS TABLE OF jtf_tty_terr_groups.matching_rule_code%TYPE;
   TYPE g_created_by_tab IS TABLE OF jtf_tty_terr_groups.created_by%TYPE;
   TYPE g_creation_date_tab IS TABLE OF jtf_tty_terr_groups.creation_date%TYPE;
   TYPE g_last_updated_by_tab IS TABLE OF jtf_tty_terr_groups.last_updated_by%TYPE;
   TYPE g_last_update_date_tab IS TABLE OF jtf_tty_terr_groups.last_update_date%TYPE;
   TYPE g_last_update_login_tab IS TABLE OF jtf_tty_terr_groups.last_update_login%TYPE;
   TYPE g_catch_all_resource_id_tab IS TABLE OF jtf_tty_terr_groups.catch_all_resource_id%TYPE;
   TYPE g_catch_all_resource_type_tab IS TABLE OF jtf_tty_terr_groups.catch_all_resource_type%TYPE;
   TYPE g_generate_catchall_flag_tab IS TABLE OF jtf_tty_terr_groups.generate_catchall_flag%TYPE;
   TYPE g_num_winners_tab IS TABLE OF jtf_tty_terr_groups.num_winners%TYPE;
   TYPE g_org_id_tab IS TABLE OF jtf_terr_all.org_id%TYPE;
   TYPE g_change_type_tab IS TABLE OF jtf_tty_named_acct_changes.change_type%TYPE;
   TYPE g_from_where_tab IS TABLE OF jtf_tty_named_acct_changes.from_where%TYPE;
   TYPE g_terr_group_account_id_tab IS TABLE OF jtf_tty_terr_grp_accts.terr_group_account_id%TYPE;
   TYPE g_terr_id_tab IS TABLE OF jtf_terr_all.terr_id%TYPE;
   TYPE g_geo_territory_id_tab IS TABLE OF jtf_tty_geo_terr.geo_territory_id%TYPE;
   TYPE g_geo_terr_name_tab IS TABLE OF jtf_tty_geo_terr.geo_terr_name%TYPE;
   TYPE g_terr_attribute_tab IS TABLE OF jtf_tty_terr_grp_accts.attribute1%TYPE;
   TYPE g_terr_attr_cat_tab IS TABLE OF jtf_terr_all.attribute_category%TYPE;
   -- TYPE g_terr_created_id_tab IS TABLE OF jtf_terr_all.terr_id%TYPE;
   -- TYPE g_terr_creation_flag_tab IS TABLE OF VARCHAR2(1);


--------------------------------------------------------------------
--                  Logging PROCEDURE
--
--     which = 1. write to log
--     which = 2, write to output
--------------------------------------------------------------------
--
PROCEDURE Write_Log(which NUMBER, mssg  VARCHAR2 )   IS

        l_mssg            VARCHAR2(4000);
        l_sub_mssg        VARCHAR2(255);
        l_begin           NUMBER := 1;
        l_mssg_length     NUMBER := 0;
        l_time            VARCHAR2(60) := TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss');

BEGIN
   --
       l_mssg := mssg;

       /* If the output message and if debug flag is set then also write
       ** to the log file
       */
       IF which = 2 THEN
             FND_FILE.PUT(1, mssg);
             FND_FILE.NEW_LINE(1, 1);
       END IF;

       l_sub_mssg := 'Time = ' || l_time;
       --FND_FILE.PUT_LINE(FND_FILE.LOG, l_sub_mssg);
       --dbms_output.put_line('LOG: ' || l_sub_mssg);

       l_mssg := l_sub_mssg || ' => ' || l_mssg;

       /* get total message length */
       l_mssg_length := LENGTH(l_mssg);

       /* Output message in 250 maximum character lines */
       WHILE ( l_mssg_length > 250 ) LOOP

            /* get message substring */
            l_sub_mssg := SUBSTR(l_mssg, l_begin, 250);

            /* write message to log file */
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_sub_mssg);
            --dbms_output.put_line('LOG: ' || l_mssg );

            /* Increment message start position to output from */
            l_begin := l_begin + 250;

            /* Decrement message length to be output */
            l_mssg_length := l_mssg_length - 250;

       END LOOP;

       /* get last remaining part of message, i.e, when
        ** there is less than 250 characters left to be output*/
       l_sub_mssg := SUBSTR(l_mssg, l_begin);
       FND_FIlE.PUT_LINE(FND_FILE.LOG, l_sub_mssg);
       --dbms_output.put_line('LOG: ' || l_mssg );
EXCEPTION
  WHEN OTHERS THEN
      RAISE;
END Write_Log;


/* (1) START: ENABLE/DISABLE TERRITORY TRIGGERS */
PROCEDURE alter_triggers(p_status VARCHAR2)
IS
BEGIN
      IF G_Debug THEN
          Write_Log(2, 'Start enabling/disabling the triggers');
      END IF;

      IF (p_status = 'DISABLE') THEN

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD DISABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_RSC_BIUD DISABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_VALUES_BIUD DISABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_RSC_ACCESS_BIUD DISABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

      ELSIF (p_status = 'ENABLE') THEN

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD ENABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_RSC_BIUD ENABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_VALUES_BIUD ENABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_RSC_ACCESS_BIUD ENABLE';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

      END IF;

      IF G_Debug THEN
          Write_Log(2, 'Start enabling/disabling the triggers');
      END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure alter_triggers');
      END IF;
      RAISE;
END alter_triggers;


/* (1) START: DELETE ALL EXISTING NAMED ACCOUNT AND GEOGRAPHY TERRITORIES */
PROCEDURE cleanup_na_territories ( p_mode VARCHAR2 )
IS
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Start deleting all the territories');
    END IF;

    /* TOTAL mode => re-generate all NA and GEO territories */
    IF (p_mode = 'TOTAL') THEN

          --DELETE territory value records
          DELETE FROM jtf_terr_values_all jtv
          WHERE jtv.terr_qual_id IN
              ( SELECT jtq.terr_qual_id
                FROM jtf_terr_qual_all jtq, jtf_terr_all jt
                WHERE jtq.terr_id = jt.terr_id
                AND jt.terr_group_flag = 'Y' );

          --Delete Territory Qualifer records
          DELETE FROM JTF_TERR_QUAL_ALL jtq
          WHERE jtq.terr_id IN
              ( SELECT jt.terr_id
                FROM jtf_terr_all jt
                WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory qual type usgs
          DELETE FROM JTF_TERR_QTYPE_USGS_ALL jtqu
          WHERE jtqu.terr_id IN
              ( SELECT jt.terr_id
                FROM jtf_terr_all jt
                WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory usgs
          DELETE FROM JTF_TERR_USGS_ALL jtu
          WHERE jtu.terr_id IN
              ( SELECT jt.terr_id
                FROM jtf_terr_all jt
                WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory Resource Access
          DELETE FROM JTF_TERR_RSC_ACCESS_ALL jtra
          WHERE jtra.terr_rsc_id IN
              ( SELECT jtr.terr_rsc_id
                FROM jtf_terr_rsc_all jtr, jtf_terr_all jt
                WHERE jtr.terr_id = jt.terr_id
                AND jt.terr_group_flag = 'Y' );


          -- Delete the Territory Resource records
          DELETE FROM JTF_TERR_RSC_ALL jtr
          WHERE jtr.terr_id IN
              ( SELECT jt.terr_id
                FROM jtf_terr_all jt
                WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory record
          DELETE FROM JTF_TERR_ALL jt
          WHERE jt.terr_id IN
              ( SELECT jt.terr_id
                FROM jtf_terr_all jt
                WHERE jt.terr_group_flag = 'Y' );


    END IF;
    /* (1) END: DELETE ALL EXISTING NAMED ACCOUNT AND GEOGRAPHY TERRITORIES */

    IF G_Debug THEN
        Write_Log(2, 'Finish deleting all the territories');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure cleanup_na_territories');
      END IF;
      RAISE;
END cleanup_na_territories;

/*---------------------------------------------------------------------------------------------------
This procedure will delete territories corresponding to a particulat self service geography territory
----------------------------------------------------------------------------------------------------*/
PROCEDURE delete_geo_terr(p_geo_territory_id  IN NUMBER)
IS
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Start deleting the territories corresponding to the self-service geography territory : ' || p_geo_territory_id);
    END IF;

    --Delete Territory Values
    DELETE FROM JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID IN
        ( SELECT TERR_QUAL_ID
          FROM JTF_TERR_QUAL_ALL A
              ,JTF_TERR_ALL B
          WHERE B.GEO_TERRITORY_ID = p_geo_territory_id
          AND   B.TERR_ID = A.TERR_ID );

    --Delete Territory Qualifer records
    DELETE FROM JTF_TERR_QUAL_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE GEO_TERRITORY_ID = p_geo_territory_id );

    --Delete Territory qual type usgs
    DELETE FROM JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE GEO_TERRITORY_ID = p_geo_territory_id );

    --Delete Territory usgs
    DELETE FROM JTF_TERR_USGS_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE GEO_TERRITORY_ID = p_geo_territory_id );

    --Delete Territory Resource Access
    DELETE FROM JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
        ( SELECT TERR_RSC_ID
          FROM JTF_TERR_RSC_ALL A
              ,JTF_TERR_ALL     B
          WHERE B.GEO_TERRITORY_ID = p_geo_territory_id
          AND   B.TERR_ID = A.TERR_ID );

    -- Delete the Territory Resource records
    DELETE FROM JTF_TERR_RSC_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE GEO_TERRITORY_ID = p_geo_territory_id );

    --Delete Territory records corresponding to the territory group
    DELETE FROM JTF_TERR_ALL WHERE GEO_TERRITORY_ID = p_geo_territory_id;

    IF G_Debug THEN
        Write_Log(2, 'End deleting the territories corresponding to the self-service geography territory : ' || p_geo_territory_id);
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure delete_geo_terr');
      END IF;
      RAISE;
END delete_geo_terr;


/*------------------------------------------------------------------------------------------
This procedure will delete territories corresponding to a particulat territory group account
-------------------------------------------------------------------------------------------*/
PROCEDURE delete_TGA(p_terr_grp_acct_id  IN NUMBER
                    ,p_terr_group_id     IN NUMBER
                    ,p_catchall_terr_id  IN NUMBER
                    ,p_change_type       IN VARCHAR2)
IS
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Start deleting the territories corresponding to the territory group account : ' || p_terr_grp_acct_id);
    END IF;

    --Delete Territory Values
    DELETE FROM JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID IN
        ( SELECT TERR_QUAL_ID
          FROM JTF_TERR_QUAL_ALL A
              ,JTF_TERR_ALL B
          WHERE B.TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id
          AND   B.TERR_ID = A.TERR_ID );

    --Delete Territory Qualifer records
    DELETE FROM JTF_TERR_QUAL_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id );

    --Delete Territory qual type usgs
    DELETE FROM JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id );

    --Delete Territory usgs
    DELETE FROM JTF_TERR_USGS_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id );

    --Delete Territory Resource Access
    DELETE FROM JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
        ( SELECT TERR_RSC_ID
          FROM JTF_TERR_RSC_ALL A
              ,JTF_TERR_ALL     B
          WHERE B.TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id
          AND   B.TERR_ID = A.TERR_ID );

    -- Delete the Territory Resource records
    DELETE FROM JTF_TERR_RSC_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id );

    --Delete Territory records corresponding to the territory group
    DELETE FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id;
    /* if the user has deleted the TGA or update the mapping             */
    /* then delete the customer key name values from jtf_terr_values_all */
    /* corresponding to the catch-all territory which are not present    */
    /* in jtf_tty_acct_qual_maps for the territory group                 */
    /* but we do not need to do this if only sales team has been updated */
    IF (p_change_type <> 'SALES_TEAM_UPDATE') THEN
        DELETE FROM jtf_terr_values_all jtv
        WHERE  NOT EXISTS
            (SELECT 1
             FROM jtf_tty_terr_grp_accts A
                 ,jtf_tty_acct_qual_maps B
             WHERE A.named_account_id = B.named_account_id
             AND   A.terr_group_id = p_terr_group_id
             AND   B.qual_usg_id = -1012
             AND   B.COMPARISON_OPERATOR = jtv.COMPARISON_OPERATOR
             AND   B.VALUE1_CHAR = jtv.LOW_VALUE_CHAR)
        AND terr_qual_id =
            (SELECT terr_qual_id FROM jtf_terr_qual_all WHERE terr_id = p_catchall_terr_id);
    END IF;

    IF G_Debug THEN
        Write_Log(2, 'End deleting the territories corresponding to the territory group account : ' || p_terr_grp_acct_id);
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure delete_TGA');
      END IF;
      RAISE;
END delete_TGA;

/*----------------------------------------------------------
This procedure will delete territories from the JTF_TERR...
tables for the specified Terr Group Account Ids.
----------------------------------------------------------*/
PROCEDURE delete_bulk_TGA(p_terrGrpId_tbl IN jtf_terr_number_list,
                          p_grpAcctId_tbl IN jtf_terr_number_list,
                          p_change_type IN VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2)
IS

idx integer;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA',
                   'Start of the procedure JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA',
                   'Deleting from JTF_TERR... tables');
  END IF;

    --Delete Territory Values
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID IN
        ( SELECT TERR_QUAL_ID
          FROM JTF_TERR_QUAL_ALL A
              ,JTF_TERR_ALL B
          WHERE B.TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx)
          AND   B.TERR_ID = A.TERR_ID );

    --Delete Territory Qualifer records
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_QUAL_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx) );

    --Delete Territory qual type usgs
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx) );

    --Delete Territory usgs
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_USGS_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx) );

    --Delete Territory Resource Access
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
        ( SELECT TERR_RSC_ID
          FROM JTF_TERR_RSC_ALL A
              ,JTF_TERR_ALL     B
          WHERE B.TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx)
          AND   B.TERR_ID = A.TERR_ID );

    -- Delete the Territory Resource records
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_RSC_ALL Where TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx) );

    --Delete Territory records corresponding to the territory group
    forall idx in p_grpAcctId_tbl.FIRST .. p_grpAcctId_tbl.LAST
    DELETE from JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_grpAcctId_tbl(idx);

    /* if the user has deleted the TGA or update the mapping             */
    /* then delete the customer key name values from jtf_terr_values_all */
    /* corresponding to the catch-all territory which are not present    */
    /* in jtf_tty_acct_qual_maps for the territory group                 */
    /* but we do not need to do this if only sales team has been updated */

    IF (p_change_type <> 'SALES_TEAM_UPDATE') THEN
        forall idx in p_terrGrpId_tbl.FIRST .. p_terrGrpId_tbl.LAST
        DELETE from jtf_terr_values_all jtv
        WHERE  NOT EXISTS
            (SELECT 1
             FROM jtf_tty_terr_grp_accts A
                 ,jtf_tty_acct_qual_maps B
             WHERE A.named_account_id = B.named_account_id
             AND   A.terr_group_id = p_terrGrpId_tbl(idx)
             AND   B.qual_usg_id = -1012
             AND   B.COMPARISON_OPERATOR = jtv.COMPARISON_OPERATOR
             AND   B.VALUE1_CHAR = jtv.LOW_VALUE_CHAR)
        AND terr_qual_id =
               ( SELECT terr_qual_id
                   FROM jtf_terr_qual_all tqa,
                        jtf_terr_all ta
                  WHERE tqa.terr_id = ta.terr_id
                    AND ta.catch_all_flag='Y'
                    AND enabled_flag='Y'
                    AND SYSDATE BETWEEN ta.start_date_active AND NVL(ta.end_date_active, SYSDATE+1)
                    AND ta.terr_group_id = p_terrGrpId_tbl(idx)
               );
    END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA',
                   'End of the procedure JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA.OTHERS',
                     substr(x_msg_data, 1, 4000));
    END IF;
    RAISE;
END delete_bulk_TGA;


/*---------------------------------------------------------------------------------------------------------
This procedure will delete territories corresponding to the territory group accounts that have been deleted
----------------------------------------------------------------------------------------------------------*/
PROCEDURE process_TGA_delete
IS

    /* Territory Group Accounts that are deleted */
    CURSOR terr_grp_acct_delete(l_date DATE) IS
    SELECT  DISTINCT A.object_id
           ,B.terr_group_id
    FROM    jtf_tty_named_acct_changes A
           ,jtf_terr_all B
    WHERE   A.creation_date <= l_date
    AND     A.change_type = 'DELETE'
    AND     A.object_type = 'TGA'
    AND     A.object_id = B.terr_group_account_id
    /* no need to process the deleted TGA if the corresponding TG has been updated */
    AND   NOT EXISTS (
            SELECT 1
            FROM   jtf_tty_named_acct_changes F
            WHERE  F.object_type = 'TG'
            AND    F.object_id = B.terr_group_id
            AND    F.creation_date <= l_date);

   l_terr_group_account_id   g_terr_group_account_id_tab;
   l_terr_group_id           g_terr_group_id_tab;

   l_no_of_records  NUMBER;
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'open the cursor terr_grp_acct_delete');
    END IF;

    -- open the cursor
    OPEN terr_grp_acct_delete(g_cutoff_time);

    -- loop till all the TGAs that have been deleted are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGAs');
      END IF;

      /* Bulk collect TGA information and process them row by row */
      FETCH terr_grp_acct_delete BULK COLLECT INTO
          l_terr_group_account_id
         ,l_terr_group_id
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_account_id.COUNT;

      /* process the return set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

          FOR i IN l_terr_group_account_id.FIRST .. l_terr_group_account_id.LAST LOOP

              IF G_Debug THEN
                Write_Log(2, 'START: delete_TGA');
              END IF;

              delete_TGA(l_terr_group_account_id(i)
                        ,l_terr_group_id(i)
                        ,l_terr_group_id(i) * -1
                        ,'DELETE_TGA');

              IF G_Debug THEN
                Write_Log(2, 'END: delete_TGA');
                Write_Log(2, 'All the territories corresponding to the territory group account ' || l_terr_group_account_id(i) ||
                                ' have been deleted successfully.');
              END IF;
          END LOOP;

          /* trim the pl/sql tables to free up memory */
          l_terr_group_account_id.TRIM(l_no_of_records);
          l_terr_group_id.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of TGs');
      END IF;

      EXIT WHEN terr_grp_acct_delete%NOTFOUND;

    END LOOP;

    CLOSE terr_grp_acct_delete;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure process_TGA_delete');
      END IF;
      IF (terr_grp_acct_delete%ISOPEN) THEN
        CLOSE terr_grp_acct_delete;
      END IF;
      RAISE;
END process_TGA_delete;

/*----------------------------------------------------------------------------------
This procedure will delete territories corresponding to a particulat territory group
-----------------------------------------------------------------------------------*/
PROCEDURE delete_TG( p_terr_grp_id        IN NUMBER,
                     p_terr_id            IN VARCHAR2,
		     p_terr_creation_flag IN VARCHAR2)
IS
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Start deleting the territories for the territory group : ' || p_terr_grp_id);
    END IF;

		IF p_terr_creation_flag IS NULL THEN
         --Delete Territory Values
         DELETE FROM JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID IN
             ( SELECT TERR_QUAL_ID
               FROM JTF_TERR_QUAL_ALL A
                   ,JTF_TERR_ALL B
               WHERE B.TERR_GROUP_ID = p_terr_grp_id
               AND   B.TERR_ID = A.TERR_ID );

         --Delete Territory Qualifer records
         DELETE FROM JTF_TERR_QUAL_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ID = p_terr_grp_id );

         --Delete Territory qual type usgs
         DELETE FROM JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ID = p_terr_grp_id );

         --Delete Territory usgs
         DELETE FROM JTF_TERR_USGS_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ID = p_terr_grp_id );

         --Delete Territory Resource Access
         DELETE FROM JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
             ( SELECT TERR_RSC_ID
               FROM JTF_TERR_RSC_ALL A
                   ,JTF_TERR_ALL     B
               WHERE B.TERR_GROUP_ID = p_terr_grp_id
               AND   B.TERR_ID = A.TERR_ID );

         -- Delete the Territory Resource records
         DELETE FROM JTF_TERR_RSC_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ID = p_terr_grp_id );

         --Delete Territory records corresponding to the territory group

         DELETE FROM JTF_TERR_ALL WHERE TERR_GROUP_ID = p_terr_grp_id;

		ELSE
		--Delete Territory Values
         DELETE FROM JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID IN
             ( SELECT TERR_QUAL_ID
               FROM JTF_TERR_QUAL_ALL A
                   ,JTF_TERR_ALL B
               WHERE B.TERR_GROUP_ID = p_terr_grp_id
               AND   B.TERR_ID = A.TERR_ID
               AND B.TERR_ID <> p_terr_id );

         --Delete Territory Qualifer records
         DELETE FROM JTF_TERR_QUAL_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL
				   WHERE TERR_GROUP_ID = p_terr_grp_id
                                    AND TERR_ID <> p_terr_id
			     );

         --Delete Territory qual type usgs
         DELETE FROM JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL
				   WHERE TERR_GROUP_ID = p_terr_grp_id
				 );

         --Delete Territory usgs
         DELETE FROM JTF_TERR_USGS_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL
				   WHERE TERR_GROUP_ID = p_terr_grp_id
                                   --  AND TERR_ID <> p_terr_id
				 );

         --Delete Territory Resource Access
         DELETE FROM JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
             ( SELECT TERR_RSC_ID
               FROM JTF_TERR_RSC_ALL A
                   ,JTF_TERR_ALL     B
               WHERE B.TERR_GROUP_ID = p_terr_grp_id
               AND   B.TERR_ID = A.TERR_ID
				 );

         -- Delete the Territory Resource records
         DELETE FROM JTF_TERR_RSC_ALL WHERE TERR_ID IN
             ( SELECT TERR_ID FROM JTF_TERR_ALL
				   WHERE TERR_GROUP_ID = p_terr_grp_id
				 );

         --Delete Territory records corresponding to the territory group

         DELETE FROM JTF_TERR_ALL
			 WHERE TERR_GROUP_ID = p_terr_grp_id
			   AND TERR_ID <> p_terr_id;
		END IF;

    IF G_Debug THEN
        Write_Log(2, 'Finish deleting the territories for the territory group : ' || p_terr_grp_id);
    END IF;
    COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'delete_TG : Error in procedure delete_TG');
      END IF;
      RAISE;
END delete_TG;

/*-------------------------------------------------------------------------------------------------
This procedure will delete territories corresponding to the territory groups that have been deleted
--------------------------------------------------------------------------------------------------*/
PROCEDURE process_TG_delete
IS

    /* Territory Groups that are deleted */
    CURSOR terr_grp_delete(l_date DATE) IS
    /* Get the territory groups that have been physically deleted */
    SELECT  A.object_id
    FROM    jtf_tty_named_acct_changes A
    WHERE   A.creation_date <= l_date
    AND     A.change_type = 'DELETE'
    AND     A.object_type = 'TG'
    UNION
    /* Get the territory groups which has expired as end_date_active < sysdate */
    SELECT  DISTINCT A.terr_group_id
    FROM    jtf_terr_all A
    WHERE   A.terr_group_flag = 'Y'
    AND     A.end_date_active < l_date;

   TYPE l_object_id_tab IS TABLE OF jtf_tty_named_acct_changes.object_id%TYPE;

   l_object_id      l_object_id_tab;
   l_no_of_records  NUMBER;
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Open the cursor terr_grp_delete');
    END IF;

    -- open the cursor
    OPEN terr_grp_delete(g_cutoff_time);

    -- loop till all the TGs that have been deleted are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGs');
      END IF;

      /* Bulk collect TG information and process them row by row */
      FETCH terr_grp_delete BULK COLLECT INTO
         l_object_id
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_object_id.COUNT;

      /* process the return set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

          FOR i IN l_object_id.FIRST .. l_object_id.LAST LOOP

            IF G_Debug THEN
              Write_Log(2, 'START: delete_TG');
            END IF;

            delete_TG(l_object_id(i), NULL, NULL);

            IF G_Debug THEN
              Write_Log(2, 'END: delete_TG');
              Write_Log(2, 'All the territories corresponding to the territory group ' || l_object_id(i) ||
                                     ' have been deleted successfully.');
            END IF;
          END LOOP;

          /* trim the pl/sql tables to free up memory */
          l_object_id.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of TGs');
      END IF;

      EXIT WHEN terr_grp_delete%NOTFOUND;

    END LOOP;

    CLOSE terr_grp_delete;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
        Write_Log(2, 'Error in procedure process_TG_delete');
      END IF;
      IF (terr_grp_delete%ISOPEN) THEN
        CLOSE terr_grp_delete;
      END IF;
      RAISE;
END process_TG_delete;

/*-------------------------------------------------------------------------------------------------
This procedure will create Geography and Overlay Territory for a self-service geography territory .
--------------------------------------------------------------------------------------------------*/
PROCEDURE create_geo_terr_for_GT(p_geo_territory_id        IN g_geo_territory_id_tab
                                ,p_geo_terr_name           IN g_geo_terr_name_tab
                                ,p_terr_group_id           IN g_terr_group_id_tab
                                ,p_rank                    IN g_rank_tab
                                ,p_active_from_date        IN g_active_from_date_tab
                                ,p_active_to_date          IN g_active_to_date_tab
                                ,p_created_by              IN g_created_by_tab
                                ,p_creation_date           IN g_creation_date_tab
                                ,p_last_updated_by         IN g_last_updated_by_tab
                                ,p_last_update_date        IN g_last_update_date_tab
                                ,p_last_update_login       IN g_last_update_login_tab
                                ,p_org_id                  IN g_org_id_tab
                                ,p_terr_id                 IN g_terr_id_tab
                                ,p_overlay_top             IN g_terr_id_tab)
IS

    l_terr_all_rec                JTF_TERRITORY_PVT.terr_all_rec_type;
    l_terr_usgs_tbl               JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_tbl               JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl             JTF_TERRITORY_PVT.terr_values_tbl_type;
    l_TerrRsc_Tbl                 Jtf_Territory_Resource_Pvt.TerrResource_tbl_type;
    l_TerrRsc_Access_Tbl          Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    l_TerrRsc_empty_Tbl           Jtf_Territory_Resource_Pvt.TerrResource_tbl_type;
    l_TerrRsc_Access_empty_Tbl    Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;
    l_terr_usgs_empty_tbl         JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_empty_tbl JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_empty_tbl         JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_empty_tbl       JTF_TERRITORY_PVT.terr_values_tbl_type;

    TYPE role_typ IS RECORD(
    grp_role_id NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE grp_role_tbl_type IS TABLE OF role_typ
    INDEX BY BINARY_INTEGER;

    l_overnon_role_tbl          grp_role_tbl_type;
    l_overnon_role_empty_tbl    grp_role_tbl_type;

    i   NUMBER;
    j   NUMBER;
    k   NUMBER;
    a   NUMBER;
    x   NUMBER;

    l_terr_qual_id              NUMBER;
    l_terr_usg_id               NUMBER;
    l_terr_qtype_usg_id         NUMBER;
    l_terr_rsc_id               NUMBER;
    l_terr_rsc_access_id        NUMBER;
    l_api_version_number        CONSTANT NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(1);
    l_commit                    VARCHAR2(1);

    l_ovnon_flag                VARCHAR2(1):='N';
    l_overlay_top               NUMBER;
    l_overlay                   NUMBER;
    l_role_counter              NUMBER := 0;
    l_id                        NUMBER;
    l_nacat                     NUMBER;
    l_geo_count                 NUMBER;

    l_pi_count                  NUMBER := 0;
    l_prev_qual_usg_id          NUMBER;
    l_na_count                  NUMBER;

    x_terr_usgs_out_tbl           JTF_TERRITORY_PVT.terr_usgs_out_tbl_type;
    x_terr_qualtypeusgs_out_tbl   JTF_TERRITORY_PVT.terr_qualtypeusgs_out_tbl_type;
    x_terr_qual_out_tbl           JTF_TERRITORY_PVT.terr_qual_out_tbl_type;
    x_terr_values_out_tbl         JTF_TERRITORY_PVT.terr_values_out_tbl_type;
    x_TerrRsc_Out_Tbl             Jtf_Territory_Resource_Pvt.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      Jtf_Territory_Resource_Pvt.TerrRsc_Access_out_tbl_type;

    x_terr_id           NUMBER;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_return_status     VARCHAR2(1);


    /* get all the geographies for a given territory group id */
    CURSOR geo_territories( l_terr_group_id NUMBER) IS
    SELECT gterr.geo_territory_id
         , gterr.geo_terr_name
    FROM jtf_tty_geo_terr gterr
    WHERE gterr.terr_group_id = l_terr_group_id;

    /** Transaction Types for a NON-OVERLAY territory are
    ** determined by all salesteam members on this geography territories
    ** having Roles without Product Interests defined
    ** so there is no Overlay Territories to assign
    ** Leads and Opportunities. If all Roles have Product Interests
    ** then only ACCOUNT transaction type should
    ** be used in Non-Overlay Named Account definition
    */
    CURSOR get_NON_OVLY_geo_trans(l_geo_territory_id NUMBER) IS
       SELECT ra.access_type
       FROM
         JTF_TTY_GEO_TERR_RSC grsc
       , jtf_tty_geo_terr gtr
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_territory_id
       AND gtr.geo_territory_id = grsc.geo_territory_id
       AND grsc.rsc_role_code = tgr.role_code
       AND tgr.terr_group_id = gtr.terr_group_id
       AND ra.terr_group_role_id = tgr.terr_group_role_id
       AND ra.access_type IN ('ACCOUNT')
       UNION
       SELECT ra.access_type
       FROM
         JTF_TTY_GEO_TERR_RSC grsc
       , jtf_tty_geo_terr gtr
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_territory_id
       AND gtr.geo_territory_id = grsc.geo_territory_id
       AND grsc.rsc_role_code = tgr.role_code
       AND tgr.terr_group_id = gtr.terr_group_id
       AND ra.terr_group_role_id = tgr.terr_group_role_id
       AND NOT EXISTS (
            SELECT NULL
            FROM jtf_tty_role_prod_int rpi
            WHERE rpi.terr_group_role_id = tgr.terr_group_role_id );

    /* same sql used in geography download to Excel
       This query will find out all the postal codes
       for a given geography territoy.
       Also if the geography territory is for a territory
       group it will find out the postal codes
       looking at country, state, city or posta code
       associated with the territory group */
    CURSOR geo_values(l_geo_territory_id NUMBER) IS
           SELECT -1007 qual_usg_id
                 , '=' comparison_operator
                 , main.postal_code value1_char
                 , main.geo_territory_id
    FROM (
      /* postal code */
      SELECT g.postal_code         postal_code
            ,g.geo_id              geo_id
            ,terr.geo_territory_id geo_territory_id
      FROM jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g   --postal_code level
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.terr_group_id      = grpv.terr_group_id
      AND terr.owner_resource_id  < 0
      AND terr.parent_geo_terr_id < 0 -- default terr
      AND grpv.geo_type = 'POSTAL_CODE'
      AND grpv.comparison_operator = '='
      AND g.geo_id = grpv.geo_id_from
      AND g.geo_type = 'POSTAL_CODE'
       UNION
      /* postal code range */
      SELECT g.postal_code         postal_code
            ,g.geo_id              geo_id
            ,terr.geo_territory_id geo_territory_id
      FROM jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g,   --postal_code level
           jtf_tty_geographies g1,
           jtf_tty_geographies g2
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.terr_group_id      = grpv.terr_group_id
      AND terr.owner_resource_id  < 0
      AND terr.parent_geo_terr_id < 0 -- default terr
      AND    grpv.geo_type = 'POSTAL_CODE'
      AND    grpv.comparison_operator = 'BETWEEN'
      AND    g1.geo_id = grpv.geo_id_from
      AND    g2.geo_id =  grpv.geo_id_to
      AND    g.geo_name BETWEEN g1.geo_name AND g2.geo_name
      UNION
      SELECT  g.postal_code         postal_code
             ,g.geo_id              geo_id
             ,terr.geo_territory_id geo_territory_id
      FROM   jtf_tty_geo_grp_values  grpv,
             jtf_tty_terr_groups     tg,
             jtf_tty_geo_terr        terr,
             jtf_tty_geographies     g,
             jtf_tty_geographies     g1
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.terr_group_id      = grpv.terr_group_id
      AND terr.owner_resource_id  < 0
      AND terr.parent_geo_terr_id < 0 -- default terr
      AND (
            (
                    grpv.geo_type = 'STATE'
                    AND g1.geo_id = grpv.geo_id_from
                    AND g.STATE_CODE = g1.state_Code
                    AND g.country_code = g1.country_Code
                    AND g.geo_type = 'POSTAL_CODE'
            )
            OR
            (
                    grpv.geo_type = 'CITY'
                    AND  g.geo_type = 'POSTAL_CODE'
                    AND  g.country_code = g1.country_code
                    AND (
                           (g.state_code = g1.state_code AND g1.province_code IS NULL)
                            OR
                           (g1.province_code = g.province_code AND g1.state_code IS NULL)
                         )
                    AND    (g1.county_code IS NULL OR g.county_code = g1.county_code)
                    AND    g.city_code = g1.city_code
                    AND    grpv.geo_id_from = g1.geo_id
            )
            OR
            (
                           grpv.geo_type = 'COUNTRY'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
            )
            OR
            (
                           grpv.geo_type = 'PROVINCE'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
                    AND    g.province_code = g1.province_code
            )
          )
      UNION
      SELECT  g.postal_code         postal_code
             ,g.geo_id              geo_id
             ,terr.geo_territory_id geo_territory_id
      FROM   jtf_tty_terr_groups     tg,
             jtf_tty_geo_terr        terr,
             jtf_tty_geographies     g,
             jtf_tty_geo_terr_values tv
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.owner_resource_id  >= 0
      AND terr.parent_geo_terr_id >= 0 -- not default terr
      AND tv.geo_territory_id     = terr.geo_territory_id
      AND g.geo_id                = tv.geo_id
    ) main
    WHERE  main.geo_id NOT IN -- the terr the user owners
    (
      SELECT tv.geo_id geo_id
      FROM   jtf_tty_geo_terr    terr,
             jtf_tty_geo_terr_values tv
      WHERE tv.geo_territory_id = terr.geo_territory_id
      AND main.geo_territory_id = terr.parent_geo_terr_id
    )
    AND geo_territory_id = l_geo_territory_id;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR NON_OVLY_role_access( lp_terr_group_id NUMBER
                               , lp_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND b.role_code          = lp_role
    AND NOT EXISTS (
               /* Product Interest does not exist for this role */
               SELECT NULL
               FROM jtf_tty_role_prod_int rpi
               WHERE rpi.terr_group_role_id = B.TERR_GROUP_ROLE_ID )
    ORDER BY a.access_type  ;

    /* Roles WITHOUT a Product Iterest defined */
    CURSOR role_interest_nonpi(l_terr_group_id NUMBER) IS
    SELECT  b.role_code role_code
           --,a.interest_type_id
           ,b.terr_group_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id(+) = b.terr_group_role_id
    AND b.terr_group_id         = l_terr_group_id
    AND a.terr_group_role_id IS  NULL
    ORDER BY b.role_code;

    CURSOR terr_resource (l_geo_territory_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.resource_id
         , a.rsc_group_id
         , NVL(a.rsc_resource_type,'RS_EMPLOYEE') rsc_resource_type
    FROM jtf_tty_geo_terr_rsc a
       , jtf_tty_geo_terr b
    WHERE a.geo_territory_id = b.geo_territory_id
    AND b.geo_territory_id = l_geo_territory_id
    AND a.rsc_role_code = l_role;

    /* Get Top-Level Parent Territory details */
    CURSOR topterr(l_terr NUMBER) IS
    SELECT name
         , description
         , rank
         , parent_territory_id
         , terr_id
    FROM jtf_terr_all
    WHERE terr_id = l_terr;

    /* get Qualifiers used in a territory */
    CURSOR csr_get_qual( lp_terr_id NUMBER) IS
    SELECT jtq.terr_qual_id
         , jtq.qual_usg_id
    FROM jtf_terr_qual_all jtq
    WHERE jtq.terr_id = lp_terr_id;

    /* get Values used in a territory qualifier */
    CURSOR csr_get_qual_val ( lp_terr_qual_id NUMBER ) IS
    SELECT jtv.TERR_VALUE_ID
         , jtv.INCLUDE_FLAG
         , jtv.COMPARISON_OPERATOR
         , jtv.LOW_VALUE_CHAR
         , jtv.HIGH_VALUE_CHAR
         , jtv.LOW_VALUE_NUMBER
         , jtv.HIGH_VALUE_NUMBER
         , jtv.VALUE_SET
         , jtv.INTEREST_TYPE_ID
         , jtv.PRIMARY_INTEREST_CODE_ID
         , jtv.SECONDARY_INTEREST_CODE_ID
         , jtv.CURRENCY_CODE
         , jtv.ORG_ID
         , jtv.ID_USED_FLAG
         , jtv.LOW_VALUE_CHAR_ID
    FROM jtf_terr_values_all jtv
    WHERE jtv.terr_qual_id = lp_terr_qual_id;

    /* get the geographies
    ** used for OVERLAY territory creation */
    CURSOR get_OVLY_geographies(LP_terr_group_id NUMBER) IS
    SELECT gterr.geo_territory_id
         , gterr.geo_terr_name
    FROM jtf_tty_geo_terr gterr
    WHERE gterr.terr_group_id = lp_terr_group_id
    AND EXISTS (
        /* Salesperson, with Role that has a Product Interest defined, exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_geo_terr_rsc grsc
           , jtf_tty_role_prod_int rpi
           , jtf_tty_terr_grp_roles tgr
        WHERE rpi.terr_group_role_id = tgr.terr_group_role_id
        AND tgr.terr_group_id = gterr.TERR_GROUP_ID
        AND tgr.role_code = grsc.rsc_role_code
        AND grsc.geo_territory_id = gterr.geo_territory_id );


    /* Roles WITH a Product Iterest defined */
    CURSOR role_pi( lp_terr_group_id         NUMBER
                  , lp_geo_territory_id NUMBER) IS
    SELECT DISTINCT
           b.role_code role_code
         , r.role_name role_name
    FROM jtf_rs_roles_vl r
       , jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE r.role_code = b.role_code
    AND a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND EXISTS (
         /* Named Account exists with Salesperson with this role */
         SELECT NULL
         FROM jtf_tty_geo_terr_rsc grsc, jtf_tty_geo_terr gterr
         WHERE gterr.geo_territory_id = grsc.geo_territory_id
         AND grsc.geo_territory_id = lp_geo_territory_id
         AND gterr.terr_group_id = b.terr_group_id
         AND grsc.rsc_role_code = b.role_code );


    /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND b.role_code          = l_role
    ORDER BY a.access_type  ;

    /* Product Interest for a Role */
    CURSOR role_pi_interest(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT  a.interest_type_id
           ,a.product_category_id
           ,a.product_category_set_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND b.role_code          = l_role;

    /* get those roles for a territory Group that
    ** do not have Product Interest defined */
    CURSOR role_no_pi(l_terr_group_id NUMBER) IS
    SELECT DISTINCT b.role_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
       , jtf_tty_role_prod_int c
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND a.access_type        = 'ACCOUNT'
    AND c.terr_group_role_id = b.terr_group_role_id
    AND NOT EXISTS ( SELECT  1
                     FROM jtf_tty_role_prod_int e
                        , jtf_tty_terr_grp_roles d
                     WHERE e.terr_group_role_id (+) = d.terr_group_role_id
                     AND d.terr_group_id          = b.terr_group_id
                     AND d.role_code              = b.role_code
                     AND e.interest_type_id IS  NULL);


BEGIN
  FOR x IN p_geo_territory_id.FIRST .. p_geo_territory_id.LAST LOOP

     -- delete the territories corresponding to the TGA before creating the new ones
     delete_geo_terr(p_geo_territory_id(x));

     IF G_Debug THEN
       write_log(2, '');
       write_log(2, '----------------------------------------------------------');
       write_log(2, 'BEGIN: Territory Creation for SS Geography territory : ' || p_geo_territory_id(x));
     END IF;

     /* reset these processing values for the Territory Group */
     l_ovnon_flag            := 'N';
     l_overnon_role_tbl      := l_overnon_role_empty_tbl;

     /** Roles with No Product Interest */
     i:=0;
     FOR overlayandnon IN role_no_pi(p_terr_group_id(x)) LOOP

        l_ovnon_flag:='Y';
        i :=i +1;

        SELECT  JTF_TTY_TERR_GRP_ROLES_S.NEXTVAL
        INTO l_id
        FROM DUAL;

        l_overnon_role_tbl(i).grp_role_id:= l_id;

        INSERT INTO JTF_TTY_TERR_GRP_ROLES(
             TERR_GROUP_ROLE_ID
           , OBJECT_VERSION_NUMBER
           , TERR_GROUP_ID
           , ROLE_CODE
           , CREATED_BY
           , CREATION_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATE_LOGIN)
         VALUES(
                l_overnon_role_tbl(i).grp_role_id
              , 1
              , p_terr_group_id(x)
              , overlayandnon.role_code
              , G_USER_ID
              , SYSDATE
              , G_USER_ID
              , SYSDATE
              , G_LOGIN_ID);

         INSERT INTO JTF_TTY_ROLE_ACCESS(
                  TERR_GROUP_ROLE_ACCESS_ID
                , OBJECT_VERSION_NUMBER
                , TERR_GROUP_ROLE_ID
                , ACCESS_TYPE
                , CREATED_BY
                , CREATION_DATE
                , LAST_UPDATED_BY
                , LAST_UPDATE_DATE
                , LAST_UPDATE_LOGIN)
         VALUES(
                JTF_TTY_ROLE_ACCESS_S.NEXTVAL
                , 1
                , l_overnon_role_tbl(i).grp_role_id
                , 'ACCOUNT'
                , G_USER_ID
                , SYSDATE
                , G_USER_ID
                , SYSDATE
                , G_LOGIN_ID);

     END LOOP; /* for overlayandnon in role_no_pi */


     /*********************************************************************/
     /*********************************************************************/
     /************** NON-OVERLAY TERRITORY CREATION ***********************/
     /*********************************************************************/
     /*********************************************************************/

     /****************************************************************/
     /* (4) START: CREATE Territories for geo territory              */
     /****************************************************************/

    /* Check to see if the self service territory has at least one geography assigend to it */
    /* or it must be the default geography territory                                        */
    BEGIN
      SELECT 1
      INTO   l_geo_count
      FROM jtf_tty_geo_terr gterr
      WHERE gterr.geo_territory_id = p_geo_territory_id(x)
      AND (   gterr.parent_geo_terr_id < 0
           OR EXISTS (
               SELECT 1
               FROM   jtf_tty_geo_terr_values gtval
               WHERE  gterr.geo_territory_id = gtval.geo_territory_id));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_geo_count := 0;
     END;

     IF (l_geo_count > 0) THEN

     l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
     l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
     l_terr_qual_tbl:=l_terr_qual_empty_tbl;
     l_terr_values_tbl:=l_terr_values_empty_tbl;
     l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
     l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

     l_terr_all_rec.terr_id                    := NULL;
     l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
     l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
     l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
     l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
     l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
     l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
     l_terr_all_rec.NAME                       := p_geo_terr_name(x) || ' ' || p_geo_territory_id(x);
     l_terr_all_rec.start_date_active          := p_active_from_date(x);
     l_terr_all_rec.end_date_active            := p_active_to_date(x);
     l_terr_all_rec.PARENT_TERRITORY_ID        := p_terr_id(x);
     l_terr_all_rec.RANK                       := p_RANK(x) + 10;
     l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
     l_terr_all_rec.TEMPLATE_FLAG              := 'N';
     l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
     l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
     l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
     l_terr_all_rec.DESCRIPTION                := p_geo_terr_name(x);
     l_terr_all_rec.UPDATE_FLAG                := 'N';
     l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
     l_terr_all_rec.ORG_ID                     := p_org_id(x);
     l_terr_all_rec.NUM_WINNERS                := NULL ;

     /* Oracle Sales and Telesales Usage */
     SELECT   JTF_TERR_USGS_S.NEXTVAL
     INTO l_terr_usg_id
     FROM DUAL;

     l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
     l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
     l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
     l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
     l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
     l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
     l_terr_usgs_tbl(1).TERR_ID            := NULL;
     l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
     l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

     i:=0;

     /* BEGIN: For each Access Type defined for the Territory Group */

     FOR acctype IN get_NON_OVLY_geo_trans( p_geo_territory_id(x) ) LOOP

       i:=i+1;

       /* ACCOUNT TRANSACTION TYPE */

       IF acctype.access_type='ACCOUNT' THEN

         SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
         INTO l_terr_qtype_usg_id
         FROM DUAL;

         l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
         l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
         l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
         l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
         l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1001;
         l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

       /* LEAD TRANSACTION TYPE */
       ELSIF acctype.access_type='LEAD' THEN

         SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
         INTO l_terr_qtype_usg_id
         FROM DUAL;

         l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
         l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
         l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
         l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
         l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1002;
         l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

       /* OPPORTUNITY TRANSACTION TYPE */
       ELSIF acctype.access_type='OPPORTUNITY' THEN

         SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
         INTO l_terr_qtype_usg_id
         FROM DUAL;

         l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
         l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
         l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
         l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
         l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
         l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1003;
         l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

       END IF;

     END LOOP; /* end for acctype in get_NON_OVLY_geo_trans */

     /*
     ** get Postal Code Mapping rules, to use as territory definition qualifier values
     */

     j := 0;
     K := 0;

     l_prev_qual_usg_id:=1;

     FOR gval IN geo_values( p_geo_territory_id(x) ) LOOP

       IF l_prev_qual_usg_id <> gval.qual_usg_id THEN

         j:=j+1;

         SELECT JTF_TERR_QUAL_S.NEXTVAL
         INTO l_terr_qual_id
         FROM DUAL;

         l_terr_qual_tbl(j).TERR_QUAL_ID          := l_terr_qual_id;
         l_terr_qual_tbl(j).LAST_UPDATE_DATE      := p_LAST_UPDATE_DATE(x);
         l_terr_qual_tbl(j).LAST_UPDATED_BY       := p_LAST_UPDATED_BY(x);
         l_terr_qual_tbl(j).CREATION_DATE         := p_CREATION_DATE(x);
         l_terr_qual_tbl(j).CREATED_BY            := p_CREATED_BY(x);
         l_terr_qual_tbl(j).LAST_UPDATE_LOGIN     := p_LAST_UPDATE_LOGIN(x);
         l_terr_qual_tbl(j).TERR_ID               := NULL;
         l_terr_qual_tbl(j).QUAL_USG_ID           := gval.qual_usg_id;
         l_terr_qual_tbl(j).QUALIFIER_MODE        := NULL;
         l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG  := 'N';
         l_terr_qual_tbl(j).USE_TO_NAME_FLAG      := NULL;
         l_terr_qual_tbl(j).GENERATE_FLAG         := NULL;
         l_terr_qual_tbl(j).ORG_ID                := p_org_id(x);
         l_prev_qual_usg_id                       := gval.qual_usg_id;

       END IF;

       k:=k+1;

       l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
       l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_UPDATED_BY(x);
       l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_UPDATE_DATE(x);
       l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
       l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
       l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_UPDATE_LOGIN(x);
       l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
       l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
       l_terr_values_tbl(k).COMPARISON_OPERATOR        := gval.COMPARISON_OPERATOR;
       l_terr_values_tbl(k).LOW_VALUE_CHAR             := gval.value1_char;
       l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
       l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
       l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
       l_terr_values_tbl(k).VALUE_SET                  := NULL;
       l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
       l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
       l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
       l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
       l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
       l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
       l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
       l_terr_values_tbl(k).qualifier_tbl_index        := j;

     END LOOP; /* end FOR gval IN geo_values */

     l_init_msg_list := FND_API.G_TRUE;

     IF l_prev_qual_usg_id <> 1 THEN    --  geography territory values are there if this condition is true
         JTF_TERRITORY_PVT.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => FND_API.g_valid_level_NONE,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_terr_all_rec               => l_terr_all_rec,
                p_terr_usgs_tbl              => l_terr_usgs_tbl,
                p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                p_terr_qual_tbl              => l_terr_qual_tbl,
                p_terr_values_tbl            => l_terr_values_tbl,
                x_terr_id                    => x_terr_id,
                x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                x_terr_values_out_tbl        => x_terr_values_out_tbl

         );

         /* BEGIN: Successful Territory creation? */
         IF x_return_status = 'S' THEN

           UPDATE JTF_TERR_ALL
           SET TERR_GROUP_FLAG = 'Y'
             , TERR_GROUP_ID = p_terr_group_id(x)
             , CATCH_ALL_FLAG = 'N'
             , GEO_TERR_FLAG = 'Y'
             , GEO_TERRITORY_ID = p_geo_territory_id(x)
           WHERE terr_id = x_terr_id;

           l_init_msg_list :=FND_API.G_TRUE;
           i := 0;
           a := 0;

           FOR tran_type IN role_interest_nonpi(p_Terr_gROUP_ID(x)) LOOP

             FOR rsc IN terr_resource(p_geo_territory_id(x),tran_type.role_code) LOOP

               i := i+1;

               SELECT JTF_TERR_RSC_S.NEXTVAL
               INTO l_terr_rsc_id
               FROM DUAL;

               l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
               l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
               l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
               l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
               l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
               l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
               l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
               l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
               l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
               l_TerrRsc_Tbl(i).ROLE                 := tran_type.role_code;
               l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
               l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
               l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
               l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;

               FOR rsc_acc IN NON_OVLY_role_access(p_terr_group_id(x), tran_type.role_code) LOOP
                 a := a+1;

                 /* ACCOUNT ACCESS TYPE */
                 IF (rsc_acc.access_type= 'ACCOUNT') THEN

                   SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                   INTO l_terr_rsc_access_id
                   FROM DUAL;

                   l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                   l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                   l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                   l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                   l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'ACCOUNT';
                   l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                   l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                 /* OPPORTUNITY ACCESS TYPE */
                 ELSIF rsc_acc.access_type= 'OPPORTUNITY' THEN

                   SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                   INTO l_terr_rsc_access_id
                   FROM DUAL;

                   l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                   l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                   l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                   l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                   l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                   l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                   l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                 /* LEAD ACCESS TYPE */
                 ELSIF rsc_acc.access_type= 'LEAD' THEN

                   SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                   INTO l_terr_rsc_access_id
                   FROM DUAL;

                   l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                   l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                   l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                   l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                   l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                   l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                   l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                   l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                 END IF;
               END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

             END LOOP; /* FOR rsc in resource_grp */

           END LOOP;/* FOR tran_type in role_interest_nonpi */

           l_init_msg_list :=FND_API.G_TRUE;

           Jtf_Territory_Resource_Pvt.create_terrresource (
                     p_api_version_number      => l_Api_Version_Number,
                     p_init_msg_list           => l_Init_Msg_List,
                     p_commit                  => l_Commit,
                     p_validation_level        => FND_API.g_valid_level_NONE,
                     x_return_status           => x_Return_Status,
                     x_msg_count               => x_Msg_Count,
                     x_msg_data                => x_msg_data,
                     p_terrrsc_tbl             => l_TerrRsc_tbl,
                     p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                     x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                     x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
           );

           IF x_Return_Status='S' THEN
             IF G_Debug THEN
               write_log(2,'Resource created for Geo territory # ' ||x_terr_id);
             END IF;
           ELSE
             IF G_Debug THEN
               x_msg_data := SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
               write_log(2,x_msg_data);
               write_log(2, '     Failed in resource creation for Geo territory # ' || x_terr_id);
             END IF;
           END IF;

         ELSE
           IF G_Debug THEN
             x_msg_data :=  SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
             write_log(2,SUBSTR(x_msg_data,1,254));
           END IF;
         END IF; /* END: Successful Territory creation? */
     END IF; /* end if l_prev_qual_usg_id <> 1 */
     END IF; /* end if l_geo_count > 0 */

     /********************************************************/
     /* delete the role and access */
     /********************************************************/
     IF l_ovnon_flag = 'Y' THEN
       FOR i IN l_overnon_role_tbl.first.. l_overnon_role_tbl.last LOOP
              DELETE FROM jtf_tty_terr_grp_roles
              WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;

              DELETE FROM jtf_tty_role_access
              WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
       END LOOP;
     END IF;

     /*********************************************************************/
     /*********************************************************************/
     /************** OVERLAY TERRITORY CREATION ***************************/
     /*********************************************************************/
     /*********************************************************************/

     /* if any role with PI and Account access and no non pi role exist */
     /* we need to create a new branch with geography territory         */
     /* OVERLAY BRANCH */

     BEGIN

           SELECT COUNT( DISTINCT b.role_code )
           INTO l_pi_count
           FROM jtf_rs_roles_vl r
              , jtf_tty_role_prod_int a
              , jtf_tty_terr_grp_roles b
           WHERE r.role_code = b.role_code
           AND a.terr_group_role_id = b.terr_group_role_id
           AND b.terr_group_id      = p_TERR_GROUP_ID(x)
                 AND EXISTS (
                       /* Geography Territory exists with Salesperson with this role */
                       SELECT NULL
                       FROM jtf_tty_geo_terr_rsc grsc, jtf_tty_geo_terr gterr
                       WHERE grsc.geo_territory_id = gterr.geo_territory_id
                       AND gterr.terr_group_id = b.terr_group_id
                       AND grsc.rsc_role_code = b.role_code )
           AND ROWNUM < 2;

     EXCEPTION
       WHEN OTHERS THEN NULL;
     END;


     /* are there overlay roles, i.e., are there roles with Product
     ** Interests defined for this Territory Group */

     IF l_pi_count > 0 THEN

       /*****************************************************************/
       /* (8) START: CREATE OVERLAY TERRITORIES FOR GEOGRAPHY TERRITORY */
       /*****************************************************************/

       l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
       l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
       l_terr_qual_tbl:=l_terr_qual_empty_tbl;
       l_terr_values_tbl:=l_terr_values_empty_tbl;
       l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
       l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

       l_terr_all_rec.TERR_ID                    := NULL;
       l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
       l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
       l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
       l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
       l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
       l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
       l_terr_all_rec.NAME                       := p_geo_terr_name(x) || ' (OVERLAY)';
       l_terr_all_rec.start_date_active          := p_active_from_date(x);
       l_terr_all_rec.end_date_active            := p_active_to_date(x);
       l_terr_all_rec.PARENT_TERRITORY_ID        := p_overlay_top(x);
       l_terr_all_rec.RANK                       := p_RANK(x) + 10;
       l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
       l_terr_all_rec.TEMPLATE_FLAG              := 'N';
       l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
       l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
       l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
       l_terr_all_rec.DESCRIPTION                := p_geo_terr_name(x) || ' (OVERLAY)';
       l_terr_all_rec.UPDATE_FLAG                := 'N';
       l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
       l_terr_all_rec.ORG_ID                     := p_ORG_ID(x);
       l_terr_all_rec.NUM_WINNERS                := NULL ;


       SELECT JTF_TERR_USGS_S.NEXTVAL
       INTO l_terr_usg_id
       FROM DUAL;

       l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
       l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
       l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
       l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
       l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
       l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
       l_terr_usgs_tbl(1).TERR_ID            := NULL;
       l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
       l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

       SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
       INTO l_terr_qtype_usg_id
       FROM DUAL;

       l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
       l_terr_qualtypeusgs_tbl(1).CREATION_DATE           := p_CREATION_DATE(x);
       l_terr_qualtypeusgs_tbl(1).CREATED_BY              := p_CREATED_BY(x);
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
       l_terr_qualtypeusgs_tbl(1).TERR_ID                 := NULL;
       l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID        := -1002;
       l_terr_qualtypeusgs_tbl(1).ORG_ID                  := p_org_id(x);

       SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
       INTO l_terr_qtype_usg_id
       FROM DUAL;

       l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
       l_terr_qualtypeusgs_tbl(2).CREATION_DATE           := p_CREATION_DATE(x);
       l_terr_qualtypeusgs_tbl(2).CREATED_BY              := p_CREATED_BY(x);
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
       l_terr_qualtypeusgs_tbl(2).TERR_ID                 := NULL;
       l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID        := -1003;
       l_terr_qualtypeusgs_tbl(2).ORG_ID                  := p_org_id(x);

       SELECT JTF_TERR_QUAL_S.NEXTVAL
       INTO l_terr_qual_id
       FROM DUAL;

       j:=0;
       K:=0;
       l_prev_qual_usg_id:=1;

       FOR gval IN geo_values(p_geo_territory_id(x) ) LOOP

         IF l_prev_qual_usg_id <> gval.qual_usg_id THEN

           j:=j+1;
           SELECT   JTF_TERR_QUAL_S.NEXTVAL
           INTO l_terr_qual_id
           FROM DUAL;

           l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
           l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
           l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
           l_terr_qual_tbl(j).CREATION_DATE        := p_CREATION_DATE(x);
           l_terr_qual_tbl(j).CREATED_BY           := p_CREATED_BY(x);
           l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
           l_terr_qual_tbl(j).TERR_ID              := NULL;
           l_terr_qual_tbl(j).QUAL_USG_ID          := gval.qual_usg_id;
           l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
           l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
           l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
           l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
           l_terr_qual_tbl(j).ORG_ID               := p_ORG_ID(x);
           l_prev_qual_usg_id                      := gval.qual_usg_id;
         END IF;  /* l_prev_qual_usg_id */

         k:=k+1;

         l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
         l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
         l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
         l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
         l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
         l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
         l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
         l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
         l_terr_values_tbl(k).COMPARISON_OPERATOR        := gval.COMPARISON_OPERATOR;
         l_terr_values_tbl(k).LOW_VALUE_CHAR             := gval.value1_char;
         l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
         l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
         l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
         l_terr_values_tbl(k).VALUE_SET                  := NULL;
         l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
         l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
         l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
         l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
         l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
         l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
         l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
         l_terr_values_tbl(k).qualifier_tbl_index        := j;

       END LOOP; /* gval */

       l_init_msg_list :=FND_API.G_TRUE;

       JTF_TERRITORY_PVT.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => FND_API.g_valid_level_NONE,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_terr_all_rec               => l_terr_all_rec,
                p_terr_usgs_tbl              => l_terr_usgs_tbl,
                p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                p_terr_qual_tbl              => l_terr_qual_tbl,
                p_terr_values_tbl            => l_terr_values_tbl,
                x_terr_id                    => x_terr_id,
                x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                x_terr_values_out_tbl        => x_terr_values_out_tbl

       );

       IF x_return_status = 'S' THEN

         UPDATE JTF_TERR_ALL
         SET TERR_GROUP_FLAG = 'Y'
           , TERR_GROUP_ID = p_terr_group_id(x)
           , CATCH_ALL_FLAG = 'N'
           , GEO_TERR_FLAG = 'Y'
           , GEO_TERRITORY_ID = p_geo_territory_id(x)
         WHERE terr_id = x_terr_id;

         l_overlay:=x_terr_id;

         FOR pit IN role_pi(p_terr_group_id(x), p_geo_territory_id(x)) LOOP

           l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
           l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
           l_terr_qual_tbl:=l_terr_qual_empty_tbl;
           l_terr_values_tbl:=l_terr_values_empty_tbl;
           l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
           l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

           l_role_counter := l_role_counter + 1;

           l_terr_all_rec.TERR_ID                    := p_geo_territory_id(x) * -30 * l_role_counter;
           l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
           l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
           l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
           l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
           l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
           l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
           l_terr_all_rec.NAME                       := p_geo_terr_name(x) || ': ' || pit.role_name || ' (OVERLAY)';
           l_terr_all_rec.start_date_active          := p_active_from_date(x);
           l_terr_all_rec.end_date_active            := p_active_to_date(x);
           l_terr_all_rec.PARENT_TERRITORY_ID        := l_overlay;
           l_terr_all_rec.RANK                       := p_RANK(x)+10;
           l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
           l_terr_all_rec.TEMPLATE_FLAG              := 'N';
           l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
           l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
           l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
           l_terr_all_rec.DESCRIPTION                := p_geo_terr_name(x) || ': ' || pit.role_name || ' (OVERLAY)';
           l_terr_all_rec.UPDATE_FLAG                := 'N';
           l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
           l_terr_all_rec.ORG_ID                     := p_ORG_ID(x);
           l_terr_all_rec.NUM_WINNERS                := NULL ;

           SELECT   JTF_TERR_USGS_S.NEXTVAL
           INTO l_terr_usg_id
           FROM DUAL;

           l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
           l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
           l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
           l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
           l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
           l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
           l_terr_usgs_tbl(1).TERR_ID            := NULL;
           l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
           l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

           i := 0;
           K:= 0;

           FOR acc_type IN role_access(p_terr_group_id(x),pit.role_code) LOOP

             IF acc_type.access_type= 'OPPORTUNITY' THEN
               i:=i+1;

               SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
               INTO l_terr_qtype_usg_id
               FROM DUAL;

               l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
               l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
               l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
               l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1003;
               l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

               SELECT JTF_TERR_QUAL_S.NEXTVAL
               INTO l_terr_qual_id
               FROM DUAL;

               /* opp expected purchase */

               l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
               l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
               l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
               l_terr_qual_tbl(i).CREATION_DATE        := p_CREATION_DATE(x);
               l_terr_qual_tbl(i).CREATED_BY           := p_CREATED_BY(x);
               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
               l_terr_qual_tbl(i).TERR_ID              := NULL;
               l_terr_qual_tbl(i).QUAL_USG_ID          := g_opp_qual_usg_id;
               l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
               l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
               l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
               l_terr_qual_tbl(i).ORG_ID               := p_ORG_ID(x);

               FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                 k:=k+1;
                 l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                 l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
                 l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
                 l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
                 l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
                 l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
                 l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                 l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                 l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                 l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                 l_terr_values_tbl(k).VALUE_SET                  := NULL;
                 l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                 l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                 l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                 l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                 l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                 l_terr_values_tbl(k).qualifier_tbl_index        := i;

                 IF (g_prod_cat_enabled) THEN
                   l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                   l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                 ELSE
                   l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                 END IF;

               END LOOP;   /* qval */

             ELSIF acc_type.access_type= 'LEAD' THEN

               i:=i+1;
               SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
               INTO l_terr_qtype_usg_id
               FROM DUAL;

               l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
               l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
               l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
               l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1002;
               l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

               SELECT   JTF_TERR_QUAL_S.NEXTVAL
               INTO l_terr_qual_id
               FROM DUAL;

               /* lead expected purchase */
               l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
               l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
               l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
               l_terr_qual_tbl(i).CREATION_DATE        := p_CREATION_DATE(x);
               l_terr_qual_tbl(i).CREATED_BY           := p_CREATED_BY(x);
               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
               l_terr_qual_tbl(i).TERR_ID              := NULL;
               l_terr_qual_tbl(i).QUAL_USG_ID          := g_lead_qual_usg_id;
               l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
               l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
               l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
               l_terr_qual_tbl(i).ORG_ID               := p_ORG_ID(x);

               FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                 k:=k+1;

                 l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                 l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
                 l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
                 l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
                 l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
                 l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
                 l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                 l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                 l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                 l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                 l_terr_values_tbl(k).VALUE_SET                  := NULL;
                 l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                 l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                 l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                 l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                 l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                 l_terr_values_tbl(k).qualifier_tbl_index        := i;

                 IF (g_prod_cat_enabled) THEN
                   l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                   l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                 ELSE
                   l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                 END IF;

               END LOOP; /* qval */

             ELSE
               IF G_Debug THEN
                 write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_id(x));
               END IF;
             END IF;

           END LOOP; /* end for acc_type in role_access */

           l_init_msg_list :=FND_API.G_TRUE;

           JTF_TERRITORY_PVT.create_territory (
                   p_api_version_number         => l_api_version_number,
                   p_init_msg_list              => l_init_msg_list,
                   p_commit                     => l_commit,
                   p_validation_level           => FND_API.g_valid_level_NONE,
                   x_return_status              => x_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data,
                   p_terr_all_rec               => l_terr_all_rec,
                   p_terr_usgs_tbl              => l_terr_usgs_tbl,
                   p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                   p_terr_qual_tbl              => l_terr_qual_tbl,
                   p_terr_values_tbl            => l_terr_values_tbl,
                   x_terr_id                    => x_terr_id,
                   x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                   x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                   x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                   x_terr_values_out_tbl        => x_terr_values_out_tbl

           );

           IF (x_return_status = 'S')  THEN

             UPDATE JTF_TERR_ALL
             SET TERR_GROUP_FLAG = 'Y'
               , TERR_GROUP_ID = p_terr_group_id(x)
               , CATCH_ALL_FLAG = 'N'
               , GEO_TERR_FLAG = 'Y'
               , GEO_TERRITORY_ID = p_geo_territory_id(x)
             WHERE terr_id = x_terr_id;

             IF G_Debug THEN
               write_log(2,' OVERLAY PI Territory Created = '||l_terr_all_rec.NAME);
             END IF;

           ELSE
             IF G_Debug THEN
               x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
               write_log(2,x_msg_data);
             END IF;

           END IF;  /* x_return_status */

           i:=0;

           FOR rsc IN terr_resource(p_geo_territory_id(x), pit.role_code) LOOP

             i:=i+1;

             SELECT JTF_TERR_RSC_S.NEXTVAL
             INTO l_terr_rsc_id
             FROM DUAL;

             l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
             l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
             l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
             l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
             l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
             l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
             l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
             l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
             l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
             l_TerrRsc_Tbl(i).ROLE                 := pit.role_code;
             l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
             l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
             l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
             l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
             l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
             l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;

             a := 0;

             FOR rsc_acc IN role_access(p_terr_group_id(x),pit.role_code) LOOP

               IF rsc_acc.access_type= 'OPPORTUNITY' THEN

                 a := a+1;

                 SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                 INTO l_terr_rsc_access_id
                 FROM DUAL;

                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                 l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                 l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                 l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                 l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                 l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

               ELSIF rsc_acc.access_type= 'LEAD' THEN

                 a := a+1;

                 SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                 INTO l_terr_rsc_access_id
                 FROM DUAL;

                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                 l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                 l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                 l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                 l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                 l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
               END IF;

             END LOOP; /* rsc_acc in role_access */

           END LOOP; /* rsc in resource_grp */

           l_init_msg_list :=FND_API.G_TRUE;

           Jtf_Territory_Resource_Pvt.create_terrresource (
                       p_api_version_number      => l_Api_Version_Number,
                       p_init_msg_list           => l_Init_Msg_List,
                       p_commit                  => l_Commit,
                       p_validation_level        => FND_API.g_valid_level_NONE,
                       x_return_status           => x_Return_Status,
                       x_msg_count               => x_Msg_Count,
                       x_msg_data                => x_msg_data,
                       p_terrrsc_tbl             => l_TerrRsc_tbl,
                       p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                       x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                       x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
           );

           IF x_Return_Status='S' THEN
             IF G_Debug THEN
               write_log(2,'Resource created for Product Interest OVERLAY Territory '|| l_terr_all_rec.NAME);
             END IF;
           ELSE
             IF G_Debug THEN
               write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '|| x_terr_id);
               write_log(2,'Message_data '|| x_msg_data);
             END IF;
           END IF;

         END LOOP;  /* end for pit in role_pi */

       ELSE
         IF G_Debug THEN
           x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
           write_log(2,x_msg_data);
           write_log(2,'Failed in OVERLAY Territory Creation for Territory : ' ||
                  p_geo_territory_id(x) || ' : ' ||
                  p_geo_terr_name(x) );
         END IF;
       END IF; /* if (x_return_status = 'S' */

     /***************************************************************/
     /* (8) END: CREATE OVERLAY TERRITORIES FOR GEOGRAPHY TERRITORY */
     /***************************************************************/

     END IF; /* l_pi_count*/

  END LOOP; /* end FOR x in p_geo_terr_id */


EXCEPTION
   WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure create_geo_terr_for_GT');
      END IF;
      IF (geo_territories%ISOPEN) THEN
        CLOSE geo_territories;
      END IF;
      IF (get_NON_OVLY_geo_trans%ISOPEN) THEN
        CLOSE get_NON_OVLY_geo_trans;
      END IF;
      IF (geo_values%ISOPEN) THEN
        CLOSE geo_values;
      END IF;
      IF (NON_OVLY_role_access%ISOPEN) THEN
        CLOSE NON_OVLY_role_access;
      END IF;
      IF (role_interest_nonpi%ISOPEN) THEN
        CLOSE role_interest_nonpi;
      END IF;
      IF (terr_resource%ISOPEN) THEN
        CLOSE terr_resource;
      END IF;
      IF (topterr%ISOPEN) THEN
        CLOSE topterr;
      END IF;
      IF (csr_get_qual%ISOPEN) THEN
        CLOSE csr_get_qual;
      END IF;
      IF (csr_get_qual_val%ISOPEN) THEN
        CLOSE csr_get_qual_val;
      END IF;
      IF (get_OVLY_geographies%ISOPEN) THEN
        CLOSE get_OVLY_geographies;
      END IF;
      IF (role_pi%ISOPEN) THEN
        CLOSE role_pi;
      END IF;
      IF (role_access%ISOPEN) THEN
        CLOSE role_access;
      END IF;
      IF (role_pi_interest%ISOPEN) THEN
        CLOSE role_pi_interest;
      END IF;
      IF (role_no_pi%ISOPEN) THEN
        CLOSE role_no_pi;
      END IF;

      RAISE;

END create_geo_terr_for_GT;

/*----------------------------------------------------------------------------------------
This procedure will create Geography and Overlay Territory for geography territory group .
-----------------------------------------------------------------------------------------*/
PROCEDURE create_geo_terr_for_TG(p_terr_group_id           IN g_terr_group_id_tab
                                ,p_terr_group_name         IN g_terr_group_name_tab
                                ,p_rank                    IN g_rank_tab
                                ,p_active_from_date        IN g_active_from_date_tab
                                ,p_active_to_date          IN g_active_to_date_tab
                                ,p_parent_terr_id          IN g_parent_terr_id_tab
                                ,p_created_by              IN g_created_by_tab
                                ,p_creation_date           IN g_creation_date_tab
                                ,p_last_updated_by         IN g_last_updated_by_tab
                                ,p_last_update_date        IN g_last_update_date_tab
                                ,p_last_update_login       IN g_last_update_login_tab
                                ,p_num_winners             IN g_num_winners_tab
                                ,p_org_id                  IN g_org_id_tab
                                ,p_change_type             IN g_change_type_tab)
IS

    l_terr_all_rec                JTF_TERRITORY_PVT.terr_all_rec_type;
    l_terr_usgs_tbl               JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_tbl               JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl             JTF_TERRITORY_PVT.terr_values_tbl_type;
    l_TerrRsc_Tbl                 Jtf_Territory_Resource_Pvt.TerrResource_tbl_type;
    l_TerrRsc_Access_Tbl          Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    l_TerrRsc_empty_Tbl           Jtf_Territory_Resource_Pvt.TerrResource_tbl_type;
    l_TerrRsc_Access_empty_Tbl    Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;
    l_terr_usgs_empty_tbl         JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_empty_tbl JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_empty_tbl         JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_empty_tbl       JTF_TERRITORY_PVT.terr_values_tbl_type;

    TYPE role_typ IS RECORD(
    grp_role_id NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE grp_role_tbl_type IS TABLE OF role_typ
    INDEX BY BINARY_INTEGER;

    l_overnon_role_tbl          grp_role_tbl_type;
    l_overnon_role_empty_tbl    grp_role_tbl_type;

    i   NUMBER;
    j   NUMBER;
    k   NUMBER;
    a   NUMBER;
    x   NUMBER;

    l_terr_qual_id              NUMBER;
    l_terr_usg_id               NUMBER;
    l_terr_qtype_usg_id         NUMBER;
    l_terr_rsc_id               NUMBER;
    l_terr_rsc_access_id        NUMBER;
    l_api_version_number        CONSTANT NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(1);
    l_commit                    VARCHAR2(1);

    l_ovnon_flag                VARCHAR2(1):='N';
    l_overlay_top               NUMBER;
    l_overlay                   NUMBER;
    l_role_counter              NUMBER := 0;
    l_id                        NUMBER;
    l_nacat                     NUMBER;

    l_pi_count                  NUMBER := 0;
    l_prev_qual_usg_id          NUMBER;
    l_na_count                  NUMBER;

    x_terr_usgs_out_tbl           JTF_TERRITORY_PVT.terr_usgs_out_tbl_type;
    x_terr_qualtypeusgs_out_tbl   JTF_TERRITORY_PVT.terr_qualtypeusgs_out_tbl_type;
    x_terr_qual_out_tbl           JTF_TERRITORY_PVT.terr_qual_out_tbl_type;
    x_terr_values_out_tbl         JTF_TERRITORY_PVT.terr_values_out_tbl_type;
    x_TerrRsc_Out_Tbl             Jtf_Territory_Resource_Pvt.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      Jtf_Territory_Resource_Pvt.TerrRsc_Access_out_tbl_type;

    x_terr_id           NUMBER;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_return_status     VARCHAR2(1);


    /* get all the geographies for a given territory group id */
    CURSOR geo_territories( l_terr_group_id NUMBER) IS
    SELECT gterr.geo_territory_id
         , gterr.geo_terr_name
    FROM jtf_tty_geo_terr gterr
    WHERE gterr.terr_group_id = l_terr_group_id
    AND (   gterr.parent_geo_terr_id < 0
         OR EXISTS (
             SELECT 1
             FROM   jtf_tty_geo_terr_values gtval
             WHERE  gterr.geo_territory_id = gtval.geo_territory_id));

    /** Transaction Types for a NON-OVERLAY territory are
    ** determined by all salesteam members on this geography territories
    ** having Roles without Product Interests defined
    ** so there is no Overlay Territories to assign
    ** Leads and Opportunities. If all Roles have Product Interests
    ** then only ACCOUNT transaction type should
    ** be used in Non-Overlay Named Account definition
    */
    CURSOR get_NON_OVLY_geo_trans(l_geo_territory_id NUMBER) IS
       SELECT ra.access_type
       FROM
         JTF_TTY_GEO_TERR_RSC grsc
       , jtf_tty_geo_terr gtr
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_territory_id
       AND gtr.geo_territory_id = grsc.geo_territory_id
       AND grsc.rsc_role_code = tgr.role_code
       AND tgr.terr_group_id = gtr.terr_group_id
       AND ra.terr_group_role_id = tgr.terr_group_role_id
       AND ra.access_type IN ('ACCOUNT')
       UNION
       SELECT ra.access_type
       FROM
         JTF_TTY_GEO_TERR_RSC grsc
       , jtf_tty_geo_terr gtr
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_territory_id
       AND gtr.geo_territory_id = grsc.geo_territory_id
       AND grsc.rsc_role_code = tgr.role_code
       AND tgr.terr_group_id = gtr.terr_group_id
       AND ra.terr_group_role_id = tgr.terr_group_role_id
       AND NOT EXISTS (
            SELECT NULL
            FROM jtf_tty_role_prod_int rpi
            WHERE rpi.terr_group_role_id = tgr.terr_group_role_id );

    /* same sql used in geography download to Excel
       This query will find out all the postal codes
       for a given geography territoy.
       Also if the geography territory is for a territory
       group it will find out the postal codes
       looking at country, state, city or posta code
       associated with the territory group */
    CURSOR geo_values(l_geo_territory_id NUMBER) IS
           SELECT -1007 qual_usg_id
                 , '=' comparison_operator
                 , main.postal_code value1_char
                 , main.geo_territory_id
    FROM (
      /* postal code */
      SELECT g.postal_code         postal_code
            ,g.geo_id              geo_id
            ,terr.geo_territory_id geo_territory_id
      FROM jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g   --postal_code level
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.terr_group_id      = grpv.terr_group_id
      AND terr.owner_resource_id  < 0
      AND terr.parent_geo_terr_id < 0 -- default terr
      AND grpv.geo_type = 'POSTAL_CODE'
      AND grpv.comparison_operator = '='
      AND g.geo_id = grpv.geo_id_from
      AND g.geo_type = 'POSTAL_CODE'
      UNION
      /* postal code range */
      SELECT g.postal_code         postal_code
            ,g.geo_id              geo_id
            ,terr.geo_territory_id geo_territory_id
      FROM jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g,   --postal_code level
           jtf_tty_geographies g1,
           jtf_tty_geographies g2
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.terr_group_id      = grpv.terr_group_id
      AND terr.owner_resource_id  < 0
      AND terr.parent_geo_terr_id < 0 -- default terr
      AND    grpv.geo_type = 'POSTAL_CODE'
      AND    grpv.comparison_operator = 'BETWEEN'
      AND    g1.geo_id = grpv.geo_id_from
      AND    g2.geo_id =  grpv.geo_id_to
      AND    g.geo_name BETWEEN g1.geo_name AND g2.geo_name
      UNION
      SELECT  g.postal_code         postal_code
             ,g.geo_id              geo_id
             ,terr.geo_territory_id geo_territory_id
      FROM   jtf_tty_geo_grp_values  grpv,
             jtf_tty_terr_groups     tg,
             jtf_tty_geo_terr        terr,
             jtf_tty_geographies     g,
             jtf_tty_geographies     g1
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.terr_group_id      = grpv.terr_group_id
      AND terr.owner_resource_id  < 0
      AND terr.parent_geo_terr_id < 0 -- default terr
      AND (
            (
                    grpv.geo_type = 'STATE'
                    AND g1.geo_id = grpv.geo_id_from
                    AND g.STATE_CODE = g1.state_Code
                    AND g.country_code = g1.country_Code
                    AND g.geo_type = 'POSTAL_CODE'
            )
            OR
            (
                    grpv.geo_type = 'CITY'
                    AND  g.geo_type = 'POSTAL_CODE'
                    AND  g.country_code = g1.country_code
                    AND (
                           (g.state_code = g1.state_code AND g1.province_code IS NULL)
                            OR
                           (g1.province_code = g.province_code AND g1.state_code IS NULL)
                         )
                    AND    (g1.county_code IS NULL OR g.county_code = g1.county_code)
                    AND    g.city_code = g1.city_code
                    AND    grpv.geo_id_from = g1.geo_id
            )
            OR
            (
                           grpv.geo_type = 'COUNTRY'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
            )
            OR
            (
                           grpv.geo_type = 'PROVINCE'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
                    AND    g.province_code = g1.province_code
            )
          )
      UNION
      SELECT  g.postal_code         postal_code
             ,g.geo_id              geo_id
             ,terr.geo_territory_id geo_territory_id
      FROM   jtf_tty_terr_groups     tg,
             jtf_tty_geo_terr        terr,
             jtf_tty_geographies     g,
             jtf_tty_geo_terr_values tv
      WHERE  terr.terr_group_id      = tg.terr_group_id
      AND terr.owner_resource_id  >= 0
      AND terr.parent_geo_terr_id >= 0 -- not default terr
      AND tv.geo_territory_id     = terr.geo_territory_id
      AND g.geo_id                = tv.geo_id
    ) main
    WHERE  main.geo_id NOT IN -- the terr the user owners
    (
      SELECT tv.geo_id geo_id
      FROM   jtf_tty_geo_terr    terr,
             jtf_tty_geo_terr_values tv
      WHERE tv.geo_territory_id = terr.geo_territory_id
      AND main.geo_territory_id = terr.parent_geo_terr_id
    )
    AND geo_territory_id = l_geo_territory_id;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR NON_OVLY_role_access( lp_terr_group_id NUMBER
                               , lp_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND b.role_code          = lp_role
    AND NOT EXISTS (
               /* Product Interest does not exist for this role */
               SELECT NULL
               FROM jtf_tty_role_prod_int rpi
               WHERE rpi.terr_group_role_id = B.TERR_GROUP_ROLE_ID )
    ORDER BY a.access_type  ;

    /* Roles WITHOUT a Product Iterest defined */
    CURSOR role_interest_nonpi(l_terr_group_id NUMBER) IS
    SELECT  b.role_code role_code
           --,a.interest_type_id
           ,b.terr_group_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id(+) = b.terr_group_role_id
    AND b.terr_group_id         = l_terr_group_id
    AND a.terr_group_role_id IS  NULL
    ORDER BY b.role_code;

    CURSOR terr_resource (l_geo_territory_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.resource_id
         , a.rsc_group_id
         , NVL(a.rsc_resource_type,'RS_EMPLOYEE') rsc_resource_type
    FROM jtf_tty_geo_terr_rsc a
       , jtf_tty_geo_terr b
    WHERE a.geo_territory_id = b.geo_territory_id
    AND b.geo_territory_id = l_geo_territory_id
    AND a.rsc_role_code = l_role;

    /* Get Top-Level Parent Territory details */
    CURSOR topterr(l_terr NUMBER) IS
    SELECT name
         , description
         , rank
         , parent_territory_id
         , terr_id
    FROM jtf_terr_all
    WHERE terr_id = l_terr;

    /* get Qualifiers used in a territory */
    CURSOR csr_get_qual( lp_terr_id NUMBER) IS
    SELECT jtq.terr_qual_id
         , jtq.qual_usg_id
    FROM jtf_terr_qual_all jtq
    WHERE jtq.terr_id = lp_terr_id;

    /* get Values used in a territory qualifier */
    CURSOR csr_get_qual_val ( lp_terr_qual_id NUMBER ) IS
    SELECT jtv.TERR_VALUE_ID
         , jtv.INCLUDE_FLAG
         , jtv.COMPARISON_OPERATOR
         , jtv.LOW_VALUE_CHAR
         , jtv.HIGH_VALUE_CHAR
         , jtv.LOW_VALUE_NUMBER
         , jtv.HIGH_VALUE_NUMBER
         , jtv.VALUE_SET
         , jtv.INTEREST_TYPE_ID
         , jtv.PRIMARY_INTEREST_CODE_ID
         , jtv.SECONDARY_INTEREST_CODE_ID
         , jtv.CURRENCY_CODE
         , jtv.ORG_ID
         , jtv.ID_USED_FLAG
         , jtv.LOW_VALUE_CHAR_ID
    FROM jtf_terr_values_all jtv
    WHERE jtv.terr_qual_id = lp_terr_qual_id;

    /* get the geographies
    ** used for OVERLAY territory creation */
    CURSOR get_OVLY_geographies(LP_terr_group_id NUMBER) IS
    SELECT gterr.geo_territory_id
         , gterr.geo_terr_name
    FROM jtf_tty_geo_terr gterr
    WHERE gterr.terr_group_id = lp_terr_group_id
    AND EXISTS (
        /* Salesperson, with Role that has a Product Interest defined, exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_geo_terr_rsc grsc
           , jtf_tty_role_prod_int rpi
           , jtf_tty_terr_grp_roles tgr
        WHERE rpi.terr_group_role_id = tgr.terr_group_role_id
        AND tgr.terr_group_id = gterr.TERR_GROUP_ID
        AND tgr.role_code = grsc.rsc_role_code
        AND grsc.geo_territory_id = gterr.geo_territory_id );


    /* Roles WITH a Product Iterest defined */
    CURSOR role_pi( lp_terr_group_id         NUMBER
                  , lp_geo_territory_id NUMBER) IS
    SELECT DISTINCT
           b.role_code role_code
         , r.role_name role_name
    FROM jtf_rs_roles_vl r
       , jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE r.role_code = b.role_code
    AND a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND EXISTS (
         /* Named Account exists with Salesperson with this role */
         SELECT NULL
         FROM jtf_tty_geo_terr_rsc grsc, jtf_tty_geo_terr gterr
         WHERE gterr.geo_territory_id = grsc.geo_territory_id
         AND grsc.geo_territory_id = lp_geo_territory_id
         AND gterr.terr_group_id = b.terr_group_id
         AND grsc.rsc_role_code = b.role_code );


    /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND b.role_code          = l_role
    ORDER BY a.access_type  ;

    /* Product Interest for a Role */
    CURSOR role_pi_interest(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT  a.interest_type_id
           ,a.product_category_id
           ,a.product_category_set_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND b.role_code          = l_role;

    /* get those roles for a territory Group that
    ** do not have Product Interest defined */
    CURSOR role_no_pi(l_terr_group_id NUMBER) IS
    SELECT DISTINCT b.role_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
       , jtf_tty_role_prod_int c
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND a.access_type        = 'ACCOUNT'
    AND c.terr_group_role_id = b.terr_group_role_id
    AND NOT EXISTS ( SELECT  1
                     FROM jtf_tty_role_prod_int e
                        , jtf_tty_terr_grp_roles d
                     WHERE e.terr_group_role_id (+) = d.terr_group_role_id
                     AND d.terr_group_id          = b.terr_group_id
                     AND d.role_code              = b.role_code
                     AND e.interest_type_id IS  NULL);


BEGIN
  FOR x IN p_terr_group_id.FIRST .. p_terr_group_id.LAST LOOP

     -- if the territory group has been updated , delete it before recreating the corresponding territories
     IF (p_change_type(x) = 'UPDATE') THEN
            IF G_Debug THEN
              Write_Log(2, 'create_geo_terr_for_TG : START: delete_TG');
            END IF;

            delete_TG(p_terr_group_id(x), NULL, NULL);

            IF G_Debug THEN
              Write_Log(2, 'create_geo_terr_for_TG : END: delete_TG');
              Write_Log(2, 'create_geo_terr_for_TG : All the territories corresponding to the territory group ' || p_terr_group_id(x)
||
                              ' have been deleted successfully.');
            END IF;
     END IF;

     IF G_Debug THEN
       write_log(2, '');
       write_log(2, '----------------------------------------------------------');
       write_log(2, 'create_geo_terr_for_TG : BEGIN: Territory Creation for Territory Group: ' ||
                                                 p_terr_group_id(x) || ' : ' || p_terr_group_name(x) );
     END IF;

     /* reset these processing values for the Territory Group */
     l_ovnon_flag            := 'N';
     l_overnon_role_tbl      := l_overnon_role_empty_tbl;

     /** Roles with No Product Interest */
     i:=0;
     FOR overlayandnon IN role_no_pi(p_terr_group_id(x)) LOOP

        l_ovnon_flag:='Y';
        i :=i +1;

        SELECT  JTF_TTY_TERR_GRP_ROLES_S.NEXTVAL
        INTO l_id
        FROM DUAL;

        l_overnon_role_tbl(i).grp_role_id:= l_id;

        INSERT INTO JTF_TTY_TERR_GRP_ROLES(
             TERR_GROUP_ROLE_ID
           , OBJECT_VERSION_NUMBER
           , TERR_GROUP_ID
           , ROLE_CODE
           , CREATED_BY
           , CREATION_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATE_LOGIN)
         VALUES(
                l_overnon_role_tbl(i).grp_role_id
              , 1
              , p_terr_group_id(x)
              , overlayandnon.role_code
              , G_USER_ID
              , SYSDATE
              , G_USER_ID
              , SYSDATE
              , G_LOGIN_ID);

         INSERT INTO JTF_TTY_ROLE_ACCESS(
                  TERR_GROUP_ROLE_ACCESS_ID
                , OBJECT_VERSION_NUMBER
                , TERR_GROUP_ROLE_ID
                , ACCESS_TYPE
                , CREATED_BY
                , CREATION_DATE
                , LAST_UPDATED_BY
                , LAST_UPDATE_DATE
                , LAST_UPDATE_LOGIN)
         VALUES(
                JTF_TTY_ROLE_ACCESS_S.NEXTVAL
                , 1
                , l_overnon_role_tbl(i).grp_role_id
                , 'ACCOUNT'
                , G_USER_ID
                , SYSDATE
                , G_USER_ID
                , SYSDATE
                , G_LOGIN_ID);

     END LOOP; /* for overlayandnon in role_no_pi */


     /* does Territory Group have at least 1 Geo Territory ? */
     SELECT COUNT(*)
     INTO l_na_count
     FROM jtf_tty_terr_groups tgrp
        , jtf_tty_geo_grp_values gterr
     WHERE tgrp.terr_group_id = gterr.terr_group_id
     AND   tgrp.terr_group_id = p_terr_group_id(x)
     AND ROWNUM < 2;

     /*********************************************************************/
     /*********************************************************************/
     /************** NON-OVERLAY TERRITORY CREATION ***********************/
     /*********************************************************************/
     /*********************************************************************/

     /* BEGIN: if Territory Group exists with Geo Territory then auto-create territory definitions */

     IF (l_na_count > 0) THEN

          /***************************************************************/
          /* (3) START: CREATE PLACEHOLDER TERRITORY FOR TERRITORY GROUP */
          /***************************************************************/
          L_TERR_USGS_TBL         := L_TERR_USGS_EMPTY_TBL;
          L_TERR_QUALTYPEUSGS_TBL := L_TERR_QUALTYPEUSGS_EMPTY_TBL;
          L_TERR_QUAL_TBL         := L_TERR_QUAL_EMPTY_TBL;
          L_TERR_VALUES_TBL       := L_TERR_VALUES_EMPTY_TBL;
          L_TERRRSC_TBL           := L_TERRRSC_EMPTY_TBL;
          L_TERRRSC_ACCESS_TBL    := L_TERRRSC_ACCESS_EMPTY_TBL;

          /* TERRITORY HEADER */
          L_TERR_ALL_REC.TERR_ID                   := -1 * p_terr_group_id(x);
          L_TERR_ALL_REC.LAST_UPDATE_DATE          := p_LAST_UPDATE_DATE(x);
          L_TERR_ALL_REC.LAST_UPDATED_BY           := G_USER_ID;
          L_TERR_ALL_REC.CREATION_DATE             := p_CREATION_DATE(x);
          L_TERR_ALL_REC.CREATED_BY                := G_USER_ID ;
          L_TERR_ALL_REC.LAST_UPDATE_LOGIN         := G_LOGIN_ID;
          L_TERR_ALL_REC.APPLICATION_SHORT_NAME    := G_APP_SHORT_NAME;
          L_TERR_ALL_REC.NAME                      := p_TERR_GROUP_NAME(x);
          L_TERR_ALL_REC.START_DATE_ACTIVE         := p_ACTIVE_FROM_DATE(x);
          L_TERR_ALL_REC.END_DATE_ACTIVE           := p_ACTIVE_TO_DATE(x);
          L_TERR_ALL_REC.PARENT_TERRITORY_ID       := p_PARENT_TERR_ID(x);
          L_TERR_ALL_REC.RANK                      := p_RANK(x);
          L_TERR_ALL_REC.TEMPLATE_TERRITORY_ID     := NULL;
          L_TERR_ALL_REC.TEMPLATE_FLAG             := 'N';
          L_TERR_ALL_REC.ESCALATION_TERRITORY_ID   := NULL;
          L_TERR_ALL_REC.ESCALATION_TERRITORY_FLAG := 'N';
          L_TERR_ALL_REC.OVERLAP_ALLOWED_FLAG      := NULL;
          L_TERR_ALL_REC.DESCRIPTION               := p_TERR_GROUP_NAME(x);
          L_TERR_ALL_REC.UPDATE_FLAG               := 'N';
          L_TERR_ALL_REC.AUTO_ASSIGN_RESOURCES_FLAG:= NULL;
          L_TERR_ALL_REC.NUM_WINNERS               := NULL ;
          l_terr_all_rec.ORG_ID                    := p_ORG_ID(x);


          /* ORACLE SALES AND TELESALES USAGE */
          SELECT JTF_TERR_USGS_S.NEXTVAL
          INTO l_terr_usg_id
          FROM DUAL;

          l_terr_usgs_tbl(1).SOURCE_ID        := -1001;
          l_terr_usgs_tbl(1).TERR_USG_ID      := l_terr_usg_id;
          l_terr_usgs_tbl(1).LAST_UPDATE_DATE := p_LAST_UPDATE_DATE(x);
          l_terr_usgs_tbl(1).LAST_UPDATED_BY  := G_USER_ID;
          l_terr_usgs_tbl(1).CREATION_DATE    := p_CREATION_DATE(x);
          l_terr_usgs_tbl(1).CREATED_BY       := G_USER_ID;
          l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:= G_LOGIN_ID;
          l_terr_usgs_tbl(1).TERR_ID          := NULL;
          l_terr_usgs_tbl(1).ORG_ID           := p_ORG_ID(x);

          /* ACCOUNT TRANSACTION TYPE */
          SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
          INTO l_terr_qtype_usg_id
          FROM DUAL;

          l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1001;
          l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
          l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := p_LAST_UPDATE_DATE(x);
          l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := G_USER_ID;
          l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := p_CREATION_DATE(x);
          l_terr_qualtypeusgs_tbl(1).CREATED_BY            := G_USER_ID;
          l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
          l_terr_qualtypeusgs_tbl(1).TERR_ID               := NULL;
          l_terr_qualtypeusgs_tbl(1).ORG_ID                := p_ORG_ID(x);

          /* LEAD TRANSACTION TYPE */
          SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
          INTO l_terr_qtype_usg_id
          FROM DUAL;

          l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1002;
          l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
          l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := p_LAST_UPDATE_DATE(x);
          l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := G_USER_ID;
          l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := p_CREATION_DATE(x);
          l_terr_qualtypeusgs_tbl(2).CREATED_BY            := G_USER_ID;
          l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
          l_terr_qualtypeusgs_tbl(2).TERR_ID               := NULL;
          l_terr_qualtypeusgs_tbl(2).ORG_ID                := p_ORG_ID(x);

          /* OPPORTUNITY TRANSACTION TYPE */
          SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
          INTO l_terr_qtype_usg_id
          FROM DUAL;

          l_terr_qualtypeusgs_tbl(3).QUAL_TYPE_USG_ID      := -1003;
          l_terr_qualtypeusgs_tbl(3).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
          l_terr_qualtypeusgs_tbl(3).LAST_UPDATE_DATE      := p_LAST_UPDATE_DATE(x);
          l_terr_qualtypeusgs_tbl(3).LAST_UPDATED_BY       := G_USER_ID;
          l_terr_qualtypeusgs_tbl(3).CREATION_DATE         := p_CREATION_DATE(x);
          l_terr_qualtypeusgs_tbl(3).CREATED_BY            := G_USER_ID;
          l_terr_qualtypeusgs_tbl(3).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
          l_terr_qualtypeusgs_tbl(3).TERR_ID               := NULL;
          l_terr_qualtypeusgs_tbl(3).ORG_ID                := p_ORG_ID(x);

          l_init_msg_list  := FND_API.G_TRUE;

          /* CALL CREATE TERRITORY API */
          JTF_TERRITORY_PVT.create_territory (
              p_api_version_number         => l_api_version_number,
              p_init_msg_list              => l_init_msg_list,
              p_commit                     => l_commit,
              p_validation_level           => FND_API.g_valid_level_NONE,
              x_return_status              => x_return_status,
              x_msg_count                  => x_msg_count,
              x_msg_data                   => x_msg_data,
              p_terr_all_rec               => l_terr_all_rec,
              p_terr_usgs_tbl              => l_terr_usgs_tbl,
              p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
              p_terr_qual_tbl              => l_terr_qual_tbl,
              p_terr_values_tbl            => l_terr_values_tbl,
              x_terr_id                    => x_terr_id,
              x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
              x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
              x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
              x_terr_values_out_tbl        => x_terr_values_out_tbl

          );

          /* BEGIN: SUCCESSFUL TERRITORY CREATION? */
          IF X_RETURN_STATUS = 'S'  THEN

              /* JDOCHERT: 01/08/03: ADDED TERR_GROUP_ID */
              UPDATE JTF_TERR_ALL
              SET TERR_GROUP_FLAG = 'Y'
                , CATCH_ALL_FLAG = 'N'
                , TERR_GROUP_ID = p_TERR_GROUP_ID(x)
                , NUM_WINNERS = p_NUM_WINNERS(x)
              WHERE TERR_ID = X_TERR_ID;

              L_NACAT := X_TERR_ID;

              IF G_Debug THEN
                WRITE_LOG(2,' Top level Geography territory created: TERR_ID# '||X_TERR_ID);
              END IF;

          ELSE
               IF G_Debug THEN
                 WRITE_LOG(2,'ERROR: PLACEHOLDER TERRITORY CREATION FAILED ' ||
                 'FOR TERRITORY_GROUP_ID# ' || p_TERR_GROUP_ID(x));
                 X_MSG_DATA :=  FND_MSG_PUB.GET(1, FND_API.G_FALSE);
                 WRITE_LOG(2,X_MSG_DATA);
               END IF;

          END IF;
          /* END: SUCCESSFUL TERRITORY CREATION? */

          /****************************************************************/
          /* (4) START: CREATE Territories for all geo territory          */
          /****************************************************************/

          FOR geo_terr IN geo_territories(p_terr_group_id(x)) LOOP

            l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
            l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
            l_terr_qual_tbl:=l_terr_qual_empty_tbl;
            l_terr_values_tbl:=l_terr_values_empty_tbl;
            l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
            l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

            L_TERR_ALL_REC.TERR_ID                    := NULL;
            l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
            l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
            l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
            l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
            l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
            l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
            l_terr_all_rec.NAME                       := geo_terr.geo_terr_name || ' ' || geo_terr.geo_territory_id;
            l_terr_all_rec.start_date_active          := p_active_from_date(x);
            l_terr_all_rec.end_date_active            := p_active_to_date(x);
            l_terr_all_rec.PARENT_TERRITORY_ID        := l_nacat;
            l_terr_all_rec.RANK                       := p_RANK(x) + 10;
            l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
            l_terr_all_rec.TEMPLATE_FLAG              := 'N';
            l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
            l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
            l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
            l_terr_all_rec.DESCRIPTION                := geo_terr.geo_terr_name;
            l_terr_all_rec.UPDATE_FLAG                := 'N';
            l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
            l_terr_all_rec.ORG_ID                     := p_org_id(x);
            l_terr_all_rec.NUM_WINNERS                := NULL ;

            /* Oracle Sales and Telesales Usage */

            SELECT   JTF_TERR_USGS_S.NEXTVAL
            INTO l_terr_usg_id
            FROM DUAL;

            l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
            l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
            l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
            l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
            l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
            l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
            l_terr_usgs_tbl(1).TERR_ID            := NULL;
            l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
            l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

            i:=0;

            /* BEGIN: For each Access Type defined for the Territory Group */

            FOR acctype IN get_NON_OVLY_geo_trans( geo_terr.geo_territory_id ) LOOP

              i:=i+1;

              /* ACCOUNT TRANSACTION TYPE */

              IF acctype.access_type='ACCOUNT' THEN

                SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
                l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
                l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
                l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1001;
                l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

              /* LEAD TRANSACTION TYPE */
              ELSIF acctype.access_type='LEAD' THEN

                SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
                l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
                l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
                l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1002;
                l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

              /* OPPORTUNITY TRANSACTION TYPE */
              ELSIF acctype.access_type='OPPORTUNITY' THEN

                SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
                l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
                l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
                l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1003;
                l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

              END IF;

            END LOOP; /* end for acctype in get_NON_OVLY_geo_trans */

            /*
            ** get Postal Code Mapping rules, to use as territory definition qualifier values
            */

            j := 0;
            K := 0;

            l_prev_qual_usg_id:=1;

            FOR gval IN geo_values( geo_terr.geo_territory_id ) LOOP

              IF l_prev_qual_usg_id <> gval.qual_usg_id THEN

                j:=j+1;

                SELECT JTF_TERR_QUAL_S.NEXTVAL
                INTO l_terr_qual_id
                FROM DUAL;

                l_terr_qual_tbl(j).TERR_QUAL_ID          := l_terr_qual_id;
                l_terr_qual_tbl(j).LAST_UPDATE_DATE      := p_LAST_UPDATE_DATE(x);
                l_terr_qual_tbl(j).LAST_UPDATED_BY       := p_LAST_UPDATED_BY(x);
                l_terr_qual_tbl(j).CREATION_DATE         := p_CREATION_DATE(x);
                l_terr_qual_tbl(j).CREATED_BY            := p_CREATED_BY(x);
                l_terr_qual_tbl(j).LAST_UPDATE_LOGIN     := p_LAST_UPDATE_LOGIN(x);
                l_terr_qual_tbl(j).TERR_ID               := NULL;
                l_terr_qual_tbl(j).QUAL_USG_ID           := gval.qual_usg_id;
                l_terr_qual_tbl(j).QUALIFIER_MODE        := NULL;
                l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG  := 'N';
                l_terr_qual_tbl(j).USE_TO_NAME_FLAG      := NULL;
                l_terr_qual_tbl(j).GENERATE_FLAG         := NULL;
                l_terr_qual_tbl(j).ORG_ID                := p_org_id(x);
                l_prev_qual_usg_id                       := gval.qual_usg_id;

              END IF;

              k:=k+1;

              l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
              l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_UPDATED_BY(x);
              l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_UPDATE_DATE(x);
              l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
              l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
              l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_UPDATE_LOGIN(x);
              l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
              l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
              l_terr_values_tbl(k).COMPARISON_OPERATOR        := gval.COMPARISON_OPERATOR;
              l_terr_values_tbl(k).LOW_VALUE_CHAR             := gval.value1_char;
              l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
              l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
              l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
              l_terr_values_tbl(k).VALUE_SET                  := NULL;
              l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
              l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
              l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
              l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
              l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
              l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
              l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
              l_terr_values_tbl(k).qualifier_tbl_index        := j;

            END LOOP; /* end FOR gval IN geo_values */

            l_init_msg_list := FND_API.G_TRUE;

            IF l_prev_qual_usg_id <> 1 THEN    --  geography territory values are there if this condition is true
              JTF_TERRITORY_PVT.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => FND_API.g_valid_level_NONE,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_terr_all_rec               => l_terr_all_rec,
                p_terr_usgs_tbl              => l_terr_usgs_tbl,
                p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                p_terr_qual_tbl              => l_terr_qual_tbl,
                p_terr_values_tbl            => l_terr_values_tbl,
                x_terr_id                    => x_terr_id,
                x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                x_terr_values_out_tbl        => x_terr_values_out_tbl

              );

              /* BEGIN: Successful Territory creation? */
              IF x_return_status = 'S' THEN

                -- JDOCHERT: 01/08/03: Added p_terr_group_rec_ID and CATCH_ALL_FLAG
                -- and NAMED_ACCOUNT_FLAG and p_terr_group_rec_ACCOUNT_ID

                   UPDATE JTF_TERR_ALL
                   SET TERR_GROUP_FLAG = 'Y'
                     , TERR_GROUP_ID = p_terr_group_id(x)
                     , CATCH_ALL_FLAG = 'N'
                     , GEO_TERR_FLAG = 'Y'
                     , GEO_TERRITORY_ID = geo_terr.geo_territory_id
                   WHERE terr_id = x_terr_id;

                   l_init_msg_list :=FND_API.G_TRUE;
                   i := 0;
                   a := 0;

                   FOR tran_type IN role_interest_nonpi(p_Terr_gROUP_ID(x)) LOOP

                     FOR rsc IN terr_resource(geo_terr.geo_territory_id,tran_type.role_code) LOOP

                       i := i+1;

                       SELECT JTF_TERR_RSC_S.NEXTVAL
                       INTO l_terr_rsc_id
                       FROM DUAL;

                       l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                       l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                       l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                       l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                       l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                       l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                       l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                       l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                       l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                       l_TerrRsc_Tbl(i).ROLE                 := tran_type.role_code;
                       l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
                       l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                       l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                       l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                       l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                       l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;

                       FOR rsc_acc IN NON_OVLY_role_access(p_terr_group_id(x), tran_type.role_code) LOOP
                         a := a+1;

                         /* ACCOUNT ACCESS TYPE */
                         IF (rsc_acc.access_type= 'ACCOUNT') THEN

                           SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                           INTO l_terr_rsc_access_id
                           FROM DUAL;

                           l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                           l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                           l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                           l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                           l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'ACCOUNT';
                           l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                           l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                         /* OPPORTUNITY ACCESS TYPE */
                         ELSIF rsc_acc.access_type= 'OPPORTUNITY' THEN

                           SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                           INTO l_terr_rsc_access_id
                           FROM DUAL;

                           l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                           l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                           l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                           l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                           l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                           l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                           l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                         /* LEAD ACCESS TYPE */
                         ELSIF rsc_acc.access_type= 'LEAD' THEN

                           SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                           INTO l_terr_rsc_access_id
                           FROM DUAL;

                           l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                           l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                           l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                           l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                           l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                           l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                           l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                           l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                         END IF;
                       END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

                     END LOOP; /* FOR rsc in resource_grp */

                   END LOOP;/* FOR tran_type in role_interest_nonpi */

                   l_init_msg_list :=FND_API.G_TRUE;

                   Jtf_Territory_Resource_Pvt.create_terrresource (
                     p_api_version_number      => l_Api_Version_Number,
                     p_init_msg_list           => l_Init_Msg_List,
                     p_commit                  => l_Commit,
                     p_validation_level        => FND_API.g_valid_level_NONE,
                     x_return_status           => x_Return_Status,
                     x_msg_count               => x_Msg_Count,
                     x_msg_data                => x_msg_data,
                     p_terrrsc_tbl             => l_TerrRsc_tbl,
                     p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                     x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                     x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                   );

                   IF x_Return_Status='S' THEN
                     IF G_Debug THEN
                       write_log(2,'Resource created for Geo territory # ' ||x_terr_id);
                     END IF;
                   ELSE
                     IF G_Debug THEN
                       x_msg_data := SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                       write_log(2,x_msg_data);
                       write_log(2, '     Failed in resource creation for Geo territory # ' || x_terr_id);
                     END IF;
                   END IF;

              ELSE
                IF G_Debug THEN
                  x_msg_data :=  SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                  write_log(2,SUBSTR(x_msg_data,1,254));
                END IF;
              END IF; /* END: Successful Territory creation? */
            END IF; /* end if l_prev_qual_usg_id <> 1 */

          END LOOP; /* end for geo_terr in geo_territories */

     END IF; /* end IF (l_na_count > 0) */

     /********************************************************/
     /* delete the role and access */
     /********************************************************/

     IF l_ovnon_flag = 'Y' THEN
       FOR i IN l_overnon_role_tbl.first.. l_overnon_role_tbl.last LOOP
              DELETE FROM jtf_tty_terr_grp_roles
              WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;

              DELETE FROM jtf_tty_role_access
              WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
       END LOOP;
     END IF;

     /*********************************************************************/
     /*********************************************************************/
     /************** OVERLAY TERRITORY CREATION ***************************/
     /*********************************************************************/
     /*********************************************************************/

     /* if any role with PI and Account access and no non pi role exist */
     /* we need to create a new branch with geography territory         */
     /* OVERLAY BRANCH */

     BEGIN

           SELECT COUNT( DISTINCT b.role_code )
           INTO l_pi_count
           FROM jtf_rs_roles_vl r
              , jtf_tty_role_prod_int a
              , jtf_tty_terr_grp_roles b
           WHERE r.role_code = b.role_code
           AND a.terr_group_role_id = b.terr_group_role_id
           AND b.terr_group_id      = p_TERR_GROUP_ID(x)
                 AND EXISTS (
                       /* Geography territory exists with Salesperson with this role */
                       SELECT NULL
                       FROM jtf_tty_geo_terr_rsc grsc, jtf_tty_geo_terr gterr
                       WHERE grsc.geo_territory_id = gterr.geo_territory_id
                       AND gterr.terr_group_id = b.terr_group_id
                       AND grsc.rsc_role_code = b.role_code )
           AND ROWNUM < 2;

     EXCEPTION
       WHEN OTHERS THEN NULL;
     END;


     /* are there overlay roles, i.e., are there roles with Product
     ** Interests defined for this Territory Group */

     IF l_pi_count > 0 THEN

     /***************************************************************/
     /* (7) START: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF */
     /*    TERRITORY GROUP                                          */
     /***************************************************************/
     FOR topt IN topterr(p_PARENT_TERR_ID(x)) LOOP

       l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
       l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
       l_terr_qual_tbl:=l_terr_qual_empty_tbl;
       l_terr_values_tbl:=l_terr_values_empty_tbl;
       l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
       l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

       l_terr_all_rec.TERR_ID                    := NULL;
       l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
       l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
       l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
       l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
       l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
       l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
       l_terr_all_rec.NAME                       := p_terr_group_name(x) || ' (OVERLAY)';
       l_terr_all_rec.start_date_active          := p_active_from_date(x);
       l_terr_all_rec.end_date_active            := p_active_to_date(x);
       l_terr_all_rec.PARENT_TERRITORY_ID        := topt.PARENT_TERRITORY_ID;
       l_terr_all_rec.RANK                       := topt.RANK;
       l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
       l_terr_all_rec.TEMPLATE_FLAG              := 'N';
       l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
       l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
       l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
       l_terr_all_rec.DESCRIPTION                := topt.DESCRIPTION;
       l_terr_all_rec.UPDATE_FLAG                := 'N';
       l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
       l_terr_all_rec.ORG_ID                     := p_ORG_ID(x);
       l_terr_all_rec.NUM_WINNERS                := l_pi_count ;

       /* ORACLE SALES AND TELESALES USAGE */

       SELECT JTF_TERR_USGS_S.NEXTVAL
       INTO l_terr_usg_id
       FROM DUAL;

       l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
       l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
       l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
       l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
       l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
       l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
       l_terr_usgs_tbl(1).TERR_ID            := NULL;
       l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
       l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

       /* LEAD TRANSACTION TYPE */
       SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
       INTO l_terr_qtype_usg_id
       FROM DUAL;

       l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
       l_terr_qualtypeusgs_tbl(1).CREATION_DATE           := p_CREATION_DATE(x);
       l_terr_qualtypeusgs_tbl(1).CREATED_BY              := p_CREATED_BY(x);
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
       l_terr_qualtypeusgs_tbl(1).TERR_ID                 := NULL;
       l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID        := -1002;
       l_terr_qualtypeusgs_tbl(1).ORG_ID                  := p_org_id(x);

       /* OPPORTUNITY TRANSACTION TYPE */
       SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
       INTO l_terr_qtype_usg_id
       FROM DUAL;

       l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
       l_terr_qualtypeusgs_tbl(2).CREATION_DATE           := p_CREATION_DATE(x);
       l_terr_qualtypeusgs_tbl(2).CREATED_BY              := p_CREATED_BY(x);
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
       l_terr_qualtypeusgs_tbl(2).TERR_ID                 := NULL;
       l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID        := -1003;
       l_terr_qualtypeusgs_tbl(2).ORG_ID                  := p_org_id(x);

       /*
       ** get Top-Level Parent's Qualifier and values and
       ** aad them to Overlay branch top-level territory
       */

       j:=0;
       k:=0;

       l_prev_qual_usg_id:=1;

       FOR csr_qual IN csr_get_qual ( topt.terr_id ) LOOP

         j:=j+1;

         SELECT JTF_TERR_QUAL_S.NEXTVAL
           INTO l_terr_qual_id
         FROM DUAL;

         /* Top_level Parent's Qualifier */
         l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
         l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
         l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
         l_terr_qual_tbl(j).CREATION_DATE        := p_CREATION_DATE(x);
         l_terr_qual_tbl(j).CREATED_BY           := p_CREATED_BY(x);
         l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
         l_terr_qual_tbl(j).TERR_ID              := NULL;
         l_terr_qual_tbl(j).QUAL_USG_ID          := csr_qual.qual_usg_id;
         l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
         l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'Y';
         l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
         l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
         l_terr_qual_tbl(j).ORG_ID               := p_ORG_ID(x);

         FOR csr_qual_val IN csr_get_qual_val (csr_qual.terr_qual_id) LOOP

           k:=k+1;

           l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
           l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
           l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
           l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
           l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
           l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
           l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
           l_terr_values_tbl(k).INCLUDE_FLAG               := csr_qual_val.INCLUDE_FLAG;
           l_terr_values_tbl(k).COMPARISON_OPERATOR        := csr_qual_val.COMPARISON_OPERATOR;
           l_terr_values_tbl(k).LOW_VALUE_CHAR             := csr_qual_val.LOW_VALUE_CHAR;
           l_terr_values_tbl(k).HIGH_VALUE_CHAR            := csr_qual_val.HIGH_VALUE_CHAR;
           l_terr_values_tbl(k).LOW_VALUE_NUMBER           := csr_qual_val.LOW_VALUE_NUMBER;
           l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := csr_qual_val.HIGH_VALUE_NUMBER;
           l_terr_values_tbl(k).VALUE_SET                  := csr_qual_val.VALUE_SET;
           l_terr_values_tbl(k).INTEREST_TYPE_ID           := csr_qual_val.INTEREST_TYPE_ID;
           l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := csr_qual_val.PRIMARY_INTEREST_CODE_ID;
           l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := csr_qual_val.SECONDARY_INTEREST_CODE_ID;
           l_terr_values_tbl(k).CURRENCY_CODE              := csr_qual_val.CURRENCY_CODE;
           l_terr_values_tbl(k).ID_USED_FLAG               := csr_qual_val.ID_USED_FLAG;
           l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := csr_qual_val.LOW_VALUE_CHAR_ID;
           l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
           l_terr_values_tbl(k).qualifier_tbl_index        := j;

         END LOOP;/* csr_qual_val IN csr_get_qual_val */

       END LOOP; /* csr_qual IN csr_get_qual */

       l_init_msg_list :=FND_API.G_TRUE;

       JTF_TERRITORY_PVT.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => FND_API.g_valid_level_NONE,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_terr_all_rec               => l_terr_all_rec,
                p_terr_usgs_tbl              => l_terr_usgs_tbl,
                p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                p_terr_qual_tbl              => l_terr_qual_tbl,
                p_terr_values_tbl            => l_terr_values_tbl,
                x_terr_id                    => x_terr_id,
                x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                x_terr_values_out_tbl        => x_terr_values_out_tbl

       );

       IF x_return_status = 'S' THEN

         -- JDOCHERT: 01/08/03: Added p_terr_group_rec.ID
         UPDATE JTF_TERR_ALL
         SET terr_group_FLAG = 'Y'
           , terr_group_ID = p_TERR_GROUP_ID(x)
         WHERE terr_id = x_terr_id;

       END IF;

       l_overlay_top :=x_terr_id;

     END LOOP;/* end FOR topt in topterr */

     /***************************************************************/
     /* (7) END: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF   */
     /*    TERRITORY GROUP                                          */
     /***************************************************************/

     /***************************************************************/
     /* (8) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
     /***************************************************************/

     FOR overlayterr IN get_OVLY_geographies(p_terr_group_id(x)) LOOP

       l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
       l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
       l_terr_qual_tbl:=l_terr_qual_empty_tbl;
       l_terr_values_tbl:=l_terr_values_empty_tbl;
       l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
       l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

       l_terr_all_rec.TERR_ID                    := NULL;
       l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
       l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
       l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
       l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
       l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
       l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
       l_terr_all_rec.NAME                       := overlayterr.geo_terr_name || ' (OVERLAY)';
       l_terr_all_rec.start_date_active          := p_active_from_date(x);
       l_terr_all_rec.end_date_active            := p_active_to_date(x);
       l_terr_all_rec.PARENT_TERRITORY_ID        := l_overlay_top;
       l_terr_all_rec.RANK                       := p_RANK(x) + 10;
       l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
       l_terr_all_rec.TEMPLATE_FLAG              := 'N';
       l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
       l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
       l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
       l_terr_all_rec.DESCRIPTION                := overlayterr.geo_terr_name || ' (OVERLAY)';
       l_terr_all_rec.UPDATE_FLAG                := 'N';
       l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
       l_terr_all_rec.ORG_ID                     := p_ORG_ID(x);
       l_terr_all_rec.NUM_WINNERS                := NULL ;


       SELECT JTF_TERR_USGS_S.NEXTVAL
       INTO l_terr_usg_id
       FROM DUAL;

       l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
       l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
       l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
       l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
       l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
       l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
       l_terr_usgs_tbl(1).TERR_ID            := NULL;
       l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
       l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

       SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
       INTO l_terr_qtype_usg_id
       FROM DUAL;

       l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
       l_terr_qualtypeusgs_tbl(1).CREATION_DATE           := p_CREATION_DATE(x);
       l_terr_qualtypeusgs_tbl(1).CREATED_BY              := p_CREATED_BY(x);
       l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
       l_terr_qualtypeusgs_tbl(1).TERR_ID                 := NULL;
       l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID        := -1002;
       l_terr_qualtypeusgs_tbl(1).ORG_ID                  := p_org_id(x);

       SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
       INTO l_terr_qtype_usg_id
       FROM DUAL;

       l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
       l_terr_qualtypeusgs_tbl(2).CREATION_DATE           := p_CREATION_DATE(x);
       l_terr_qualtypeusgs_tbl(2).CREATED_BY              := p_CREATED_BY(x);
       l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
       l_terr_qualtypeusgs_tbl(2).TERR_ID                 := NULL;
       l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID        := -1003;
       l_terr_qualtypeusgs_tbl(2).ORG_ID                  := p_org_id(x);

       SELECT JTF_TERR_QUAL_S.NEXTVAL
       INTO l_terr_qual_id
       FROM DUAL;

       j:=0;
       K:=0;
       l_prev_qual_usg_id:=1;

       FOR gval IN geo_values(overlayterr.geo_territory_id ) LOOP

         IF l_prev_qual_usg_id <> gval.qual_usg_id THEN

           j:=j+1;
           SELECT   JTF_TERR_QUAL_S.NEXTVAL
           INTO l_terr_qual_id
           FROM DUAL;

           l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
           l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
           l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
           l_terr_qual_tbl(j).CREATION_DATE        := p_CREATION_DATE(x);
           l_terr_qual_tbl(j).CREATED_BY           := p_CREATED_BY(x);
           l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
           l_terr_qual_tbl(j).TERR_ID              := NULL;
           l_terr_qual_tbl(j).QUAL_USG_ID          := gval.qual_usg_id;
           l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
           l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
           l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
           l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
           l_terr_qual_tbl(j).ORG_ID               := p_ORG_ID(x);
           l_prev_qual_usg_id                      := gval.qual_usg_id;
         END IF;  /* l_prev_qual_usg_id */

         k:=k+1;

         l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
         l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
         l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
         l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
         l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
         l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
         l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
         l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
         l_terr_values_tbl(k).COMPARISON_OPERATOR        := gval.COMPARISON_OPERATOR;
         l_terr_values_tbl(k).LOW_VALUE_CHAR             := gval.value1_char;
         l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
         l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
         l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
         l_terr_values_tbl(k).VALUE_SET                  := NULL;
         l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
         l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
         l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
         l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
         l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
         l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
         l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
         l_terr_values_tbl(k).qualifier_tbl_index        := j;

       END LOOP; /* gval */

       l_init_msg_list :=FND_API.G_TRUE;

       JTF_TERRITORY_PVT.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => FND_API.g_valid_level_NONE,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_terr_all_rec               => l_terr_all_rec,
                p_terr_usgs_tbl              => l_terr_usgs_tbl,
                p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                p_terr_qual_tbl              => l_terr_qual_tbl,
                p_terr_values_tbl            => l_terr_values_tbl,
                x_terr_id                    => x_terr_id,
                x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                x_terr_values_out_tbl        => x_terr_values_out_tbl

       );

       IF x_return_status = 'S' THEN

         UPDATE JTF_TERR_ALL
         SET TERR_GROUP_FLAG = 'Y'
           , TERR_GROUP_ID = p_terr_group_id(x)
           , CATCH_ALL_FLAG = 'N'
           , GEO_TERR_FLAG = 'Y'
           , GEO_TERRITORY_ID = overlayterr.geo_territory_id
         WHERE terr_id = x_terr_id;

         l_overlay:=x_terr_id;

         FOR pit IN role_pi(p_terr_group_id(x), overlayterr.geo_territory_id) LOOP

           l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
           l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
           l_terr_qual_tbl:=l_terr_qual_empty_tbl;
           l_terr_values_tbl:=l_terr_values_empty_tbl;
           l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
           l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

           l_role_counter := l_role_counter + 1;

           l_terr_all_rec.TERR_ID                    := overlayterr.geo_territory_id * -30 * l_role_counter;
           l_terr_all_rec.LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
           l_terr_all_rec.LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
           l_terr_all_rec.CREATION_DATE              := p_CREATION_DATE(x);
           l_terr_all_rec.CREATED_BY                 := p_CREATED_BY(x);
           l_terr_all_rec.LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
           l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
           l_terr_all_rec.NAME                       := overlayterr.geo_terr_name || ': ' || pit.role_name || ' (OVERLAY)';
           l_terr_all_rec.start_date_active          := p_active_from_date(x);
           l_terr_all_rec.end_date_active            := p_active_to_date(x);
           l_terr_all_rec.PARENT_TERRITORY_ID        := l_overlay;
           l_terr_all_rec.RANK                       := p_RANK(x)+10;
           l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
           l_terr_all_rec.TEMPLATE_FLAG              := 'N';
           l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
           l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
           l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
           l_terr_all_rec.DESCRIPTION                := overlayterr.geo_terr_name || ': ' || pit.role_name || ' (OVERLAY)';
           l_terr_all_rec.UPDATE_FLAG                := 'N';
           l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
           l_terr_all_rec.ORG_ID                     := p_ORG_ID(x);
           l_terr_all_rec.NUM_WINNERS                := NULL ;

           SELECT   JTF_TERR_USGS_S.NEXTVAL
           INTO l_terr_usg_id
           FROM DUAL;

           l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
           l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_LAST_UPDATE_DATE(x);
           l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_LAST_UPDATED_BY(x);
           l_terr_usgs_tbl(1).CREATION_DATE      := p_CREATION_DATE(x);
           l_terr_usgs_tbl(1).CREATED_BY         := p_CREATED_BY(x);
           l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_LAST_UPDATE_LOGIN(x);
           l_terr_usgs_tbl(1).TERR_ID            := NULL;
           l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
           l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

           i := 0;
           K:= 0;

           FOR acc_type IN role_access(p_terr_group_id(x),pit.role_code) LOOP

             IF acc_type.access_type= 'OPPORTUNITY' THEN
               i:=i+1;

               SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
               INTO l_terr_qtype_usg_id
               FROM DUAL;

               l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
               l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
               l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
               l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1003;
               l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

               SELECT JTF_TERR_QUAL_S.NEXTVAL
               INTO l_terr_qual_id
               FROM DUAL;

               /* opp expected purchase */

               l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
               l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
               l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
               l_terr_qual_tbl(i).CREATION_DATE        := p_CREATION_DATE(x);
               l_terr_qual_tbl(i).CREATED_BY           := p_CREATED_BY(x);
               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
               l_terr_qual_tbl(i).TERR_ID              := NULL;
               l_terr_qual_tbl(i).QUAL_USG_ID          := g_opp_qual_usg_id;
               l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
               l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
               l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
               l_terr_qual_tbl(i).ORG_ID               := p_ORG_ID(x);

               FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                 k:=k+1;
                 l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                 l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
                 l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
                 l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
                 l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
                 l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
                 l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                 l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                 l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                 l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                 l_terr_values_tbl(k).VALUE_SET                  := NULL;
                 l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                 l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                 l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                 l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                 l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                 l_terr_values_tbl(k).qualifier_tbl_index        := i;

                 IF (g_prod_cat_enabled) THEN
                   l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                   l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                 ELSE
                   l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                 END IF;

               END LOOP;   /* qval */

             ELSIF acc_type.access_type= 'LEAD' THEN

               i:=i+1;
               SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
               INTO l_terr_qtype_usg_id
               FROM DUAL;

               l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_LAST_UPDATE_DATE(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_LAST_UPDATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_CREATION_DATE(x);
               l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_CREATED_BY(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_LAST_UPDATE_LOGIN(x);
               l_terr_qualtypeusgs_tbl(i).TERR_ID                 := NULL;
               l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1002;
               l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id(x);

               SELECT   JTF_TERR_QUAL_S.NEXTVAL
               INTO l_terr_qual_id
               FROM DUAL;

               /* lead expected purchase */
               l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
               l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_LAST_UPDATE_DATE(x);
               l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_LAST_UPDATED_BY(x);
               l_terr_qual_tbl(i).CREATION_DATE        := p_CREATION_DATE(x);
               l_terr_qual_tbl(i).CREATED_BY           := p_CREATED_BY(x);
               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_LAST_UPDATE_LOGIN(x);
               l_terr_qual_tbl(i).TERR_ID              := NULL;
               l_terr_qual_tbl(i).QUAL_USG_ID          := g_lead_qual_usg_id;
               l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
               l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
               l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
               l_terr_qual_tbl(i).ORG_ID               := p_ORG_ID(x);

               FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                 k:=k+1;

                 l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                 l_terr_values_tbl(k).LAST_UPDATED_BY            := p_LAST_UPDATED_BY(x);
                 l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_LAST_UPDATE_DATE(x);
                 l_terr_values_tbl(k).CREATED_BY                 := p_CREATED_BY(x);
                 l_terr_values_tbl(k).CREATION_DATE              := p_CREATION_DATE(x);
                 l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_LAST_UPDATE_LOGIN(x);
                 l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                 l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                 l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                 l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                 l_terr_values_tbl(k).VALUE_SET                  := NULL;
                 l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                 l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                 l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                 l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                 l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                 l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                 l_terr_values_tbl(k).qualifier_tbl_index        := i;

                 IF (g_prod_cat_enabled) THEN
                   l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                   l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                 ELSE
                   l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                 END IF;

               END LOOP; /* qval */

             ELSE
               IF G_Debug THEN
                 write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_id(x));
               END IF;
             END IF;

           END LOOP; /* end for acc_type in role_access */

           l_init_msg_list :=FND_API.G_TRUE;

           JTF_TERRITORY_PVT.create_territory (
                   p_api_version_number         => l_api_version_number,
                   p_init_msg_list              => l_init_msg_list,
                   p_commit                     => l_commit,
                   p_validation_level           => FND_API.g_valid_level_NONE,
                   x_return_status              => x_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data,
                   p_terr_all_rec               => l_terr_all_rec,
                   p_terr_usgs_tbl              => l_terr_usgs_tbl,
                   p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                   p_terr_qual_tbl              => l_terr_qual_tbl,
                   p_terr_values_tbl            => l_terr_values_tbl,
                   x_terr_id                    => x_terr_id,
                   x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                   x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                   x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                   x_terr_values_out_tbl        => x_terr_values_out_tbl

           );

           IF (x_return_status = 'S')  THEN

             UPDATE JTF_TERR_ALL
             SET TERR_GROUP_FLAG = 'Y'
               , TERR_GROUP_ID = p_terr_group_id(x)
               , CATCH_ALL_FLAG = 'N'
               , GEO_TERR_FLAG = 'Y'
               , GEO_TERRITORY_ID = overlayterr.geo_territory_id
             WHERE terr_id = x_terr_id;

             IF G_Debug THEN
               write_log(2,' OVERLAY PI Territory Created = '||l_terr_all_rec.NAME);
             END IF;

           ELSE
             IF G_Debug THEN
               x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
               write_log(2,x_msg_data);
             END IF;

           END IF;  /* x_return_status */

           i:=0;

           FOR rsc IN terr_resource(overlayterr.geo_territory_id, pit.role_code) LOOP

             i:=i+1;

             SELECT JTF_TERR_RSC_S.NEXTVAL
             INTO l_terr_rsc_id
             FROM DUAL;

             l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
             l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
             l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
             l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
             l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
             l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
             l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
             l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
             l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
             l_TerrRsc_Tbl(i).ROLE                 := pit.role_code;
             l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
             l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
             l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
             l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
             l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
             l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;

             a := 0;

             FOR rsc_acc IN role_access(p_terr_group_id(x),pit.role_code) LOOP

               IF rsc_acc.access_type= 'OPPORTUNITY' THEN

                 a := a+1;

                 SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                 INTO l_terr_rsc_access_id
                 FROM DUAL;

                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                 l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                 l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                 l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                 l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                 l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

               ELSIF rsc_acc.access_type= 'LEAD' THEN

                 a := a+1;

                 SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                 INTO l_terr_rsc_access_id
                 FROM DUAL;

                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                 l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                 l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                 l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                 l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                 l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
               END IF;

             END LOOP; /* rsc_acc in role_access */

           END LOOP; /* rsc in resource_grp */

           l_init_msg_list :=FND_API.G_TRUE;

           Jtf_Territory_Resource_Pvt.create_terrresource (
                       p_api_version_number      => l_Api_Version_Number,
                       p_init_msg_list           => l_Init_Msg_List,
                       p_commit                  => l_Commit,
                       p_validation_level        => FND_API.g_valid_level_NONE,
                       x_return_status           => x_Return_Status,
                       x_msg_count               => x_Msg_Count,
                       x_msg_data                => x_msg_data,
                       p_terrrsc_tbl             => l_TerrRsc_tbl,
                       p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                       x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                       x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
           );

           IF x_Return_Status='S' THEN
             IF G_Debug THEN
               write_log(2,'Resource created for Product Interest OVERLAY Territory '|| l_terr_all_rec.NAME);
             END IF;
           ELSE
             IF G_Debug THEN
               write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '|| x_terr_id);
               write_log(2,'Message_data '|| x_msg_data);
             END IF;
           END IF;

         END LOOP;  /* end for pit in role_pi */

       ELSE
         IF G_Debug THEN
              x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
              write_log(2,x_msg_data);
              write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' ||
                  p_terr_group_id(x) || ' : ' ||
                  p_terr_group_name(x) );
         END IF;
       END IF; /* if (x_return_status = 'S' */

     END LOOP; /* overlayterr in get_OVLY_geographies */

     /***************************************************************/
     /* (8) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
     /***************************************************************/

     END IF; /* l_pi_count*/

  END LOOP; /* end FOR x in p_terr_group_id */


EXCEPTION
   WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure create_geo_terr_for_TG');
      END IF;
      IF (geo_territories%ISOPEN) THEN
        CLOSE geo_territories;
      END IF;
      IF (get_NON_OVLY_geo_trans%ISOPEN) THEN
        CLOSE get_NON_OVLY_geo_trans;
      END IF;
      IF (geo_values%ISOPEN) THEN
        CLOSE geo_values;
      END IF;
      IF (NON_OVLY_role_access%ISOPEN) THEN
        CLOSE NON_OVLY_role_access;
      END IF;
      IF (role_interest_nonpi%ISOPEN) THEN
        CLOSE role_interest_nonpi;
      END IF;
      IF (terr_resource%ISOPEN) THEN
        CLOSE terr_resource;
      END IF;
      IF (topterr%ISOPEN) THEN
        CLOSE topterr;
      END IF;
      IF (csr_get_qual%ISOPEN) THEN
        CLOSE csr_get_qual;
      END IF;
      IF (csr_get_qual_val%ISOPEN) THEN
        CLOSE csr_get_qual_val;
      END IF;
      IF (get_OVLY_geographies%ISOPEN) THEN
        CLOSE get_OVLY_geographies;
      END IF;
      IF (role_pi%ISOPEN) THEN
        CLOSE role_pi;
      END IF;
      IF (role_access%ISOPEN) THEN
        CLOSE role_access;
      END IF;
      IF (role_pi_interest%ISOPEN) THEN
        CLOSE role_pi_interest;
      END IF;
      IF (role_no_pi%ISOPEN) THEN
        CLOSE role_no_pi;
      END IF;

      RAISE;


END create_geo_terr_for_TG;

/*----------------------------------------------------------
This procedure will create Named account and Overlay Territory
for territory group account .
----------------------------------------------------------*/
PROCEDURE create_na_terr_for_TGA(p_terr_grp_acct_id        IN g_terr_group_account_id_tab
                                ,p_terr_group_id           IN g_terr_group_id_tab
                                ,p_rank                    IN g_rank_tab
                                ,p_active_from_date        IN g_active_from_date_tab
                                ,p_active_to_date          IN g_active_to_date_tab
                                ,p_matching_rule_code      IN g_matching_rule_code_tab
                                ,p_generate_catchall_flag  IN g_generate_catchall_flag_tab
                                ,p_created_by              IN g_created_by_tab
                                ,p_creation_date           IN g_creation_date_tab
                                ,p_last_updated_by         IN g_last_updated_by_tab
                                ,p_last_update_date        IN g_last_update_date_tab
                                ,p_last_update_login       IN g_last_update_login_tab
                                ,p_org_id                  IN g_org_id_tab
                                ,p_terr_id                 IN g_terr_id_tab
                                ,p_overlay_top             IN g_terr_id_tab
                                ,p_catchall_terr_id        IN g_terr_id_tab
                                ,p_change_type             IN g_change_type_tab
                                ,p_terr_attr_cat           IN g_terr_attr_cat_tab
                                ,p_terr_attribute1         IN g_terr_attribute_tab
                                ,p_terr_attribute2         IN g_terr_attribute_tab
                                ,p_terr_attribute3         IN g_terr_attribute_tab
                                ,p_terr_attribute4         IN g_terr_attribute_tab
                                ,p_terr_attribute5         IN g_terr_attribute_tab
                                ,p_terr_attribute6         IN g_terr_attribute_tab
                                ,p_terr_attribute7         IN g_terr_attribute_tab
                                ,p_terr_attribute8         IN g_terr_attribute_tab
                                ,p_terr_attribute9         IN g_terr_attribute_tab
                                ,p_terr_attribute10        IN g_terr_attribute_tab
                                ,p_terr_attribute11        IN g_terr_attribute_tab
                                ,p_terr_attribute12        IN g_terr_attribute_tab
                                ,p_terr_attribute13        IN g_terr_attribute_tab
                                ,p_terr_attribute14        IN g_terr_attribute_tab
                                ,p_terr_attribute15        IN g_terr_attribute_tab)
IS

    TYPE role_typ IS RECORD(
    grp_role_id NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE grp_role_tbl_type IS TABLE OF role_typ
    INDEX BY BINARY_INTEGER;

    l_overnon_role_tbl          grp_role_tbl_type;
    l_overnon_role_empty_tbl    grp_role_tbl_type;

    l_terr_qual_id              NUMBER;
    l_terr_usg_id               NUMBER;
    l_terr_qtype_usg_id         NUMBER;
    l_qual_type_usg_id          NUMBER;
    l_qual_type                 VARCHAR2(20);
    l_terr_rsc_id               NUMBER;
    l_terr_rsc_access_id        NUMBER;
    l_api_version_number        CONSTANT NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(1);
    l_commit                    VARCHAR2(1);
    l_pi_count                  NUMBER := 0;
    l_prev_qual_usg_id          NUMBER;
    l_role_counter              NUMBER := 0;
    l_overlay                   NUMBER;
    l_id                        NUMBER;
    l_ovnon_flag                VARCHAR2(1):='N';
    l_na_count                  NUMBER;
    l_terr_exists               NUMBER;
    l_cust_count                NUMBER;

    x_return_status             VARCHAR2(1);
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(2000);
    x_terr_id                   NUMBER;
    l_error_msg                 VARCHAR2(200);

    i  NUMBER;
    j  NUMBER;
    k  NUMBER;
    l  NUMBER;
    a  NUMBER;

    l_terr_all_rec                JTF_TERRITORY_PVT.terr_all_rec_type;
    l_terr_usgs_tbl               JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_tbl               JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl             JTF_TERRITORY_PVT.terr_values_tbl_type;

    l_terr_usgs_empty_tbl         JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_empty_tbl JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_empty_tbl         JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_empty_tbl       JTF_TERRITORY_PVT.terr_values_tbl_type;

    x_terr_usgs_out_tbl           JTF_TERRITORY_PVT.terr_usgs_out_tbl_type;
    x_terr_qualtypeusgs_out_tbl   JTF_TERRITORY_PVT.terr_qualtypeusgs_out_tbl_type;
    x_terr_qual_out_tbl           JTF_TERRITORY_PVT.terr_qual_out_tbl_type;
    x_terr_values_out_tbl         JTF_TERRITORY_PVT.terr_values_out_tbl_type;

    l_TerrRsc_Tbl                 Jtf_Territory_Resource_Pvt.TerrResource_tbl_type_wflex;
    l_TerrRsc_Access_Tbl          Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    l_TerrRsc_empty_Tbl           Jtf_Territory_Resource_Pvt.TerrResource_tbl_type_wflex;
    l_TerrRsc_Access_empty_Tbl    Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    x_TerrRsc_Out_Tbl             Jtf_Territory_Resource_Pvt.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      Jtf_Territory_Resource_Pvt.TerrRsc_Access_out_tbl_type;


    /* JDOCHERT: /05/29/03:
    ** Transaction Types for a NON-OVERLAY territory are
    ** determined by all salesteam members on this Named Account
    ** having Roles without Product Interests defined
    ** so there is no Overlay Territories to assign
    ** Leads and Opportunities. If all Roles have Product Interests
    ** then only ACCOUNT transaction type should
    ** be used in Non-Overlay Named Account definition
    */
    CURSOR get_NON_OVLY_na_trans(LP_terr_group_account_id NUMBER) IS
       SELECT ra.access_type
       FROM
         jtf_tty_named_acct_rsc nar
       , jtf_tty_terr_grp_accts tga
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE tga.terr_group_account_id = nar.terr_group_account_id
         AND nar.terr_group_account_id = LP_terr_group_account_id
         AND tga.terr_group_id = tgr.terr_group_id
         AND nar.rsc_role_code = tgr.role_code
         AND ra.terr_group_role_id = tgr.terr_group_role_id
         AND ra.access_type IN ('ACCOUNT')
       UNION
       SELECT ra.access_type
       FROM
         jtf_tty_named_acct_rsc nar
       , jtf_tty_terr_grp_accts tga
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE tga.terr_group_account_id = nar.terr_group_account_id
         AND nar.terr_group_account_id = LP_terr_group_account_id
         AND tga.terr_group_id = tgr.terr_group_id
         AND nar.rsc_role_code = tgr.role_code
         AND ra.terr_group_role_id = tgr.terr_group_role_id
         AND NOT EXISTS (
            SELECT NULL
            FROM jtf_tty_role_prod_int rpi
            WHERE rpi.terr_group_role_id = tgr.terr_group_role_id );


    /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id
      AND b.role_code          = l_role
    ORDER BY a.access_type  ;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR NON_OVLY_role_access( lp_terr_group_id NUMBER
                               , lp_role VARCHAR2) IS
    SELECT DISTINCT a.access_type, a.trans_access_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND b.role_code          = lp_role
    AND NOT EXISTS (
       /* Product Interest does not exist for this role */
       SELECT NULL
       FROM jtf_tty_role_prod_int rpi
       WHERE rpi.terr_group_role_id = B.TERR_GROUP_ROLE_ID )
    ORDER BY a.access_type  ;

    /* Roles WITHOUT a Product Iterest defined */
    CURSOR role_interest_nonpi(l_terr_group_id NUMBER) IS
    SELECT  b.role_code role_code
            --,a.interest_type_id
           ,b.terr_group_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id(+) = b.terr_group_role_id
      AND b.terr_group_id         = l_terr_group_id
      AND a.terr_group_role_id IS  NULL
    ORDER BY b.role_code;

    /* Roles WITH a Product Iterest defined */
    CURSOR role_pi( lp_terr_group_id         NUMBER
                  , lp_terr_group_account_id NUMBER) IS
    SELECT DISTINCT
       b.role_code role_code
     , r.role_name role_name
    FROM jtf_rs_roles_vl r
       , jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE r.role_code = b.role_code
    AND a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND EXISTS (
         /* Named Account exists with Salesperson with this role */
         SELECT NULL
         FROM jtf_tty_named_acct_rsc nar, jtf_tty_terr_grp_accts tga
         WHERE tga.terr_group_account_id = nar.terr_group_account_id
         AND nar.terr_group_account_id = lp_terr_group_account_id
         AND tga.terr_group_id = b.terr_group_id
         AND nar.rsc_role_code = b.role_code );

    /* Product Interest for a Role */
    CURSOR role_pi_interest(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT  a.interest_type_id
           ,a.product_category_id
           ,a.product_category_set_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id
      AND b.role_code          = l_role;

    CURSOR resource_grp(l_terr_group_acct_id NUMBER, l_role VARCHAR2) IS
    SELECT DISTINCT b.resource_id
         , b.rsc_group_id
         , b.rsc_resource_type
         , b.start_date
         , b.end_date
         , to_char(null) attribute_category
         , b.attribute1  attribute1
         , b.attribute2  attribute2
         , b.attribute3  attribute3
         , b.attribute4  attribute4
         , b.attribute5  attribute5
         , to_char(null) attribute6
         , to_char(null) attribute7
         , to_char(null) attribute8
         , to_char(null) attribute9
         , to_char(null) attribute10
         , to_char(null) attribute11
         , to_char(null) attribute12
         , to_char(null) attribute13
         , to_char(null) attribute14
         , to_char(null) attribute15
    FROM jtf_tty_terr_grp_accts a
       , jtf_tty_named_acct_rsc b
    WHERE a.terr_group_account_id = l_terr_group_acct_id
    AND a.terr_group_account_id = b.terr_group_account_id
    AND b.rsc_role_code = l_role;

    /* Should Unassigned NAs go to Sales Manager or NA Catch-All? */
    -- WHERE c.dn_jnr_assigned_flag = 'Y';


    /* used for NAMED ACCOUNT territory creation for duns# and party# qualifier */
    CURSOR get_party_info(LP_terr_group_acct_id NUMBER, l_matching_rule_code VARCHAR2) IS
    SELECT SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , c.start_date
         , c.end_date
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_account_id = LP_terr_group_acct_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    -- AND (a.DUNS_NUMBER_C IS NOT NULL OR l_matching_rule_code = '4' OR l_matching_rule_code = '5')
    AND EXISTS (
        /* Salesperson exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_named_acct_rsc nar
        WHERE nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* get the PARTY_NAME + POSTAL_CODE for the Named Account:
    ** used for NAMED ACCOUNT territory creation */
    CURSOR get_party_name(LP_terr_group_acct_id NUMBER) IS
    SELECT /*+ index(b JTF_TTY_NAMED_ACCTS_U1) */ SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , a.duns_number_c
         , c.start_date
         , c.end_date
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_account_id = LP_terr_group_acct_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    AND EXISTS (
         /* Named Account has at least 1 Mapping Rule */
         SELECT 1
         FROM jtf_tty_acct_qual_maps d
         WHERE d.named_account_id = c.named_account_id )
    AND EXISTS (
         /* Salesperson exists for this Named Account */
         SELECT NULL
         FROM jtf_tty_named_acct_rsc nar
         WHERE nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* Should Unassigned NAs go to Sales Manager or NA Catch-All? */
    -- WHERE c.dn_jnr_assigned_flag = 'Y';

    /* used for OVERLAY territory creation for duns# and party# qualifier */
    CURSOR get_OVLY_party_info(LP_terr_group_acct_id NUMBER, lp_matching_rule_code VARCHAR2) IS
    SELECT SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_account_id = LP_terr_group_acct_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    AND (a.DUNS_NUMBER_C IS NOT NULL OR lp_matching_rule_code = '4' OR lp_matching_rule_code = '5')
    AND EXISTS (
        /* Salesperson, with Role that has a Product
        ** Interest defined, exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_named_acct_rsc nar
           , jtf_tty_role_prod_int rpi
           , jtf_tty_terr_grp_roles tgr
        WHERE rpi.terr_group_role_id = tgr.terr_group_role_id
        AND tgr.terr_group_id = C.TERR_GROUP_ID
        AND tgr.role_code = nar.rsc_role_code
        AND nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* get the PARTY_NAME + POSTAL_CODE for the Named Account
    ** used for OVERLAY territory creation */
    CURSOR get_OVLY_party_name(LP_terr_group_acct_id NUMBER) IS
    SELECT SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , a.duns_number_c
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_account_id = LP_terr_group_acct_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    AND EXISTS (
         /* Named Account has at least 1 Mapping Rule */
         SELECT 1
         FROM jtf_tty_acct_qual_maps d
         WHERE d.named_account_id = c.named_account_id )
    AND EXISTS (
        /* Salesperson, with Role that has a Product
        ** Interest defined, exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_named_acct_rsc nar
           , jtf_tty_role_prod_int rpi
           , jtf_tty_terr_grp_roles tgr
        WHERE rpi.terr_group_role_id = tgr.terr_group_role_id
        AND tgr.terr_group_id = C.TERR_GROUP_ID
        AND tgr.role_code = nar.rsc_role_code
        AND nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* get Customer Keynames and Postal Code mappings
    ** for the Named Account  */
    /* bug#2925153: JRADHAKR: Added value2_char */
    CURSOR match_rule1( l_na_id NUMBER) IS
    SELECT b.qual_usg_id
         , b.comparison_operator
         , b.value1_char
         , b.value2_char
    FROM jtf_tty_acct_qual_maps b
    WHERE b.qual_usg_id IN (-1007, -1012)
    AND b.named_account_id = l_na_id
    ORDER BY b.qual_usg_id;

    /* get DUNS# or PARTY# for the Named Account  */
    /* bug#2933116: JDOCHERT: 05/27/03: support for DUNS# Qualifier */
    /* bug#3426946: ACHANDA : 03/08/04: support for PARTY# Qualifier */
    /* JRADHAKR: Added support for Party site id and hierarchy */
    CURSOR match_rule3(l_na_id NUMBER, l_matching_rule_code VARCHAR2) IS
    SELECT DECODE(l_matching_rule_code, '4', -1129, '2', -1120, '3', -1120, '5',-1005, -1001) qual_usg_id
         , '=' comparison_operator
         , DECODE(l_matching_rule_code, '4', hzp.party_number, '2', hzp.duns_number_c, '3', hzp.duns_number_c) value1_char
         , DECODE(l_matching_rule_code, '5', na.party_site_id, hzp.party_id) value1_num
    FROM hz_parties hzp, jtf_tty_named_accts na
    WHERE hzp.status = 'A'
    AND hzp.party_id = na.party_id
    AND na.named_account_id = l_na_id;

    /* Access Types for a Territory Group */
    CURSOR na_access(l_terr_group_id NUMBER) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id;

    /* get those roles for a territory Group that
    ** do not have Product Interest defined */
    CURSOR role_no_pi(l_terr_group_id NUMBER) IS
    SELECT DISTINCT b.role_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
       , jtf_tty_role_prod_int c
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND a.access_type        = 'ACCOUNT'
    AND c.terr_group_role_id = b.terr_group_role_id
    AND NOT EXISTS ( SELECT  1
                     FROM jtf_tty_role_prod_int e
                        , jtf_tty_terr_grp_roles d
                     WHERE e.terr_group_role_id (+) = d.terr_group_role_id
                     AND d.terr_group_id          = b.terr_group_id
                     AND d.role_code              = b.role_code
                     AND e.interest_type_id IS  NULL);

    /* Named Account Catch-All Customer Keyname values */
    CURSOR catchall_cust(l_terr_group_acct_id NUMBER) IS
    SELECT DISTINCT b.comparison_operator
          ,b.value1_char
    FROM jtf_tty_terr_grp_accts a
       , jtf_tty_acct_qual_maps b
    WHERE a.named_account_id = b.named_account_id
      AND a.terr_group_account_id    = l_terr_group_acct_id
      AND b.qual_usg_id      = -1012
    ORDER BY b.comparison_operator,b.value1_char;

BEGIN

  /* (2) START: CREATE NAMED ACCOUNT TERRITORY CREATION
  ** FOR EACH TERRITORY GROUP ACCOUNT */
  FOR x IN p_terr_grp_acct_id.FIRST .. p_terr_grp_acct_id.LAST LOOP

     -- delete the territories corresponding to the TGA before creating the new ones
     delete_TGA(p_terr_grp_acct_id(x)
               ,p_terr_group_id(x)
               ,p_catchall_terr_id(x)
               ,p_change_type(x));
     IF G_Debug THEN
       write_log(2, '');
       write_log(2, '----------------------------------------------------------');
       write_log(2, 'BEGIN: Territory Creation for Territory Group Account : ' || p_terr_grp_acct_id(x));
     END IF;

     /* reset these processing values for the Territory Group */
     l_ovnon_flag            := 'N';
     l_overnon_role_tbl      := l_overnon_role_empty_tbl;


     /** Roles with No Product Interest */
     i:=0;
     FOR overlayandnon IN role_no_pi(p_terr_group_id(x)) LOOP

        l_ovnon_flag := 'Y';
        i := i + 1;

        SELECT  JTF_TTY_TERR_GRP_ROLES_S.NEXTVAL
        INTO    l_id
        FROM    DUAL;

        l_overnon_role_tbl(i).grp_role_id:= l_id;

        INSERT INTO JTF_TTY_TERR_GRP_ROLES(
             TERR_GROUP_ROLE_ID
           , OBJECT_VERSION_NUMBER
           , TERR_GROUP_ID
           , ROLE_CODE
           , CREATED_BY
           , CREATION_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATE_LOGIN)
         VALUES(
                l_overnon_role_tbl(i).grp_role_id
              , 1
              , p_terr_group_id(x)
              , overlayandnon.role_code
              , G_USER_ID
              , SYSDATE
              , G_USER_ID
              , SYSDATE
              , G_LOGIN_ID);

          INSERT INTO JTF_TTY_ROLE_ACCESS(
               TERR_GROUP_ROLE_ACCESS_ID
             , OBJECT_VERSION_NUMBER
             , TERR_GROUP_ROLE_ID
             , ACCESS_TYPE
             , CREATED_BY
             , CREATION_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATE_LOGIN)
           VALUES(
                  JTF_TTY_ROLE_ACCESS_S.NEXTVAL
                , 1
                , l_overnon_role_tbl(i).grp_role_id
                , 'ACCOUNT'
                , G_USER_ID
                , SYSDATE
                , G_USER_ID
                , SYSDATE
                , G_LOGIN_ID);

     END LOOP; /* for overlayandnon in role_no_pi */


      /*********************************************************************/
      /*********************************************************************/
      /************** NON-OVERLAY TERRITORY CREATION ***********************/
      /*********************************************************************/
      /*********************************************************************/

      /* does Territory Group Account have at least 1 Named Account? */
      SELECT COUNT(*)
      INTO   l_na_count
      FROM  jtf_tty_terr_grp_accts ga
          , jtf_tty_named_accts a
      WHERE ga.named_account_id = a.named_account_id
      AND ga.terr_group_account_id = p_terr_grp_acct_id(x)
      AND ROWNUM < 2;

      /* BEGIN: if Territory Group exists with Named Accounts
      ** then auto-create territory definitions */
      IF (l_na_count > 0) THEN

         /***************************************************************/
         /* (4) START: CREATE CUSTOMER KEY NAME VALUES FOR CATCH_ALL    */
         /* TERRITORY IN TABLE JTF_TERR_VALUES_ALL                      */
         /***************************************************************/

         IF ( p_matching_rule_code(x) IN ('1', '2') AND
                     p_generate_catchall_flag(x) = 'Y' ) THEN
             k := 0;
             l_terr_values_tbl := l_terr_values_empty_tbl;

             BEGIN
                 SELECT terr_qual_id
                 INTO   l_terr_qual_id
                 FROM   jtf_terr_qual_all
                 WHERE  terr_id = p_catchall_terr_id(x)
                 AND    qual_usg_id = -1012;

                 FOR catchall IN catchall_cust(p_terr_grp_acct_id(x)) LOOP
                     -- check to see if the customer key name and comparision operator exist for the catchall territory
                     SELECT COUNT(*)
                     INTO   l_cust_count
                     FROM   jtf_terr_values_all
                     WHERE  comparison_operator = catchall.comparison_operator
                     AND    low_value_char = catchall.value1_char
                     AND    terr_qual_id = l_terr_qual_id;

                     -- if the record does not exist , insert a record in jtf_terr_values_all
                     IF (l_cust_count = 0) THEN

                            k := k + 1;
                            l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                            l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                            l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                            l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                            l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                            l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                            l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                            l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                            l_terr_values_tbl(k).COMPARISON_OPERATOR        := catchall.comparison_operator;
                            l_terr_values_tbl(k).LOW_VALUE_CHAR             := catchall.value1_char;
                            l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                            l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                            l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                            l_terr_values_tbl(k).VALUE_SET                  := NULL;
                            l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                            l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                            l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                            l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                            l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                            l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                            l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                            l_terr_values_tbl(k).qualifier_tbl_index        := 1;
                     END IF;
                 END LOOP;


                 JTF_TERRITORY_PVT.Create_Terr_Value(
                            P_Api_Version_Number  =>  l_Api_Version_Number,
                            P_Init_Msg_List       =>  l_Init_Msg_List,
                            P_Commit              =>  l_Commit,
                            p_validation_level    =>  FND_API.g_valid_level_NONE,
                            P_Terr_Id             =>  p_catchall_terr_id(x),
                            p_terr_qual_id        =>  l_Terr_Qual_Id,
                            P_Terr_Value_Tbl      =>  l_Terr_Values_Tbl,
                            X_Return_Status       =>  x_Return_Status,
                            X_Msg_Count           =>  x_Msg_Count,
                            X_Msg_Data            =>  x_Msg_Data,
                            X_Terr_Value_Out_Tbl  =>  x_Terr_Values_Out_Tbl);

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 NULL;
               WHEN OTHERS THEN
                 RAISE;
             END;
         END IF;

         /***************************************************************/
         /* (4) END: CREATE CUSTOMER KEY NAME VALUES FOR CATCH_ALL    */
         /* TERRITORY IN TABLE JTF_TERR_VALUES_ALL                      */
         /***************************************************************/

         /***************************************************************/
         /* (5) START: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING DUNS# , PARTY# PARTY_SITE_ID, ACOUNT HIERARCHY QULIFIER                        */
         /***************************************************************/
         IF ( p_matching_rule_code(x)  NOT IN ('1')) THEN       --  IN ('2', '3', '4') ) THEN
           /* if matching rule code is 2 or 3 create territories for duns# qualifier else for party number qualifier */
           FOR naterr IN get_party_info(p_terr_grp_acct_id(x), p_matching_rule_code(x)) LOOP

               l_terr_usgs_tbl          := l_terr_usgs_empty_tbl;
               l_terr_qualtypeusgs_tbl  := l_terr_qualtypeusgs_empty_tbl;
               l_terr_qual_tbl          := l_terr_qual_empty_tbl;
               l_terr_values_tbl        := l_terr_values_empty_tbl;
               l_TerrRsc_Tbl            := l_TerrRsc_empty_Tbl;
               l_TerrRsc_Access_Tbl     := l_TerrRsc_Access_empty_Tbl;

               /* TERRITORY HEADER */
               /* Ensure static TERR_ID to benefit TAP Performance */
               BEGIN

                   l_terr_exists := 0;

                   SELECT COUNT(*)
                   INTO l_terr_exists
                   FROM jtf_terr_all jt
                   WHERE jt.terr_id = naterr.terr_group_account_id * -100;

                   IF (l_terr_exists = 0) THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -100;
                   ELSE
                       l_terr_all_rec.TERR_ID := NULL;
                   END IF;

               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -100;
               END;

               l_terr_all_rec.LAST_UPDATE_DATE             := p_last_update_date(x);
               l_terr_all_rec.LAST_UPDATED_BY              := p_last_updated_by(x);
               l_terr_all_rec.CREATION_DATE                := p_creation_date(x);
               l_terr_all_rec.CREATED_BY                   := p_created_by(x);
               l_terr_all_rec.LAST_UPDATE_LOGIN            := p_last_update_login(x);
               l_terr_all_rec.APPLICATION_SHORT_NAME       := G_APP_SHORT_NAME;

               IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                 l_terr_all_rec.NAME                         := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('4')) THEN
                 l_terr_all_rec.NAME                         := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('5')) THEN
                 l_terr_all_rec.NAME                         := naterr.name ;
               ELSE
                 l_terr_all_rec.NAME                         := naterr.name ;
               END IF;

               IF naterr.start_date IS NULL THEN
                   l_terr_all_rec.start_date_active          := p_active_from_date(x);
               ELSE
                   l_terr_all_rec.start_date_active          := naterr.start_date;
               END IF;

               IF naterr.end_date IS NULL THEN
                   l_terr_all_rec.end_date_active            := p_active_to_date(x);
               ELSE
                   l_terr_all_rec.end_date_active            := naterr.end_date;
               END IF;

               l_terr_all_rec.PARENT_TERRITORY_ID          := p_terr_id(x);
               l_terr_all_rec.RANK                         := p_rank(x) + 10;
               l_terr_all_rec.TEMPLATE_TERRITORY_ID        := NULL;
               l_terr_all_rec.TEMPLATE_FLAG                := 'N';
               l_terr_all_rec.ESCALATION_TERRITORY_ID      := NULL;
               l_terr_all_rec.ESCALATION_TERRITORY_FLAG    := 'N';
               l_terr_all_rec.OVERLAP_ALLOWED_FLAG         := NULL;
               l_terr_all_rec.TERRITORY_TYPE_ID            := -1;

               IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                 l_terr_all_rec.DESCRIPTION                  := naterr.name;
               ELSIF ( p_matching_rule_code(x) IN ('4')) THEN
                 l_terr_all_rec.DESCRIPTION                  := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('5')) THEN
                 l_terr_all_rec.DESCRIPTION                  := naterr.name ;
               ELSE
                 l_terr_all_rec.DESCRIPTION                  := naterr.name;
               END IF;

               l_terr_all_rec.UPDATE_FLAG                  := 'N';
               l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG   := NULL;
               l_terr_all_rec.ORG_ID                       := p_org_id(x);
               l_terr_all_rec.NUM_WINNERS                  := NULL ;
               l_terr_all_rec.attribute_category           := p_terr_attr_cat(x);
               l_terr_all_rec.attribute1                   := p_terr_attribute1(x);
               l_terr_all_rec.attribute2                   := p_terr_attribute2(x);
               l_terr_all_rec.attribute3                   := p_terr_attribute3(x);
               l_terr_all_rec.attribute4                   := p_terr_attribute4(x);
               l_terr_all_rec.attribute5                   := p_terr_attribute5(x);
               l_terr_all_rec.attribute6                   := p_terr_attribute6(x);
               l_terr_all_rec.attribute7                   := p_terr_attribute7(x);
               l_terr_all_rec.attribute8                   := p_terr_attribute8(x);
               l_terr_all_rec.attribute9                   := p_terr_attribute9(x);
               l_terr_all_rec.attribute10                  := p_terr_attribute10(x);
               l_terr_all_rec.attribute11                  := p_terr_attribute11(x);
               l_terr_all_rec.attribute12                  := p_terr_attribute12(x);
               l_terr_all_rec.attribute13                  := p_terr_attribute13(x);
               l_terr_all_rec.attribute14                  := p_terr_attribute14(x);
               l_terr_all_rec.attribute15                  := p_terr_attribute15(x);

               /* Oracle Sales and Telesales Usage */
               SELECT   JTF_TERR_USGS_S.NEXTVAL
               INTO l_terr_usg_id
               FROM DUAL;

               l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
               l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_last_update_date(x);
               l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_last_updated_by(x);
               l_terr_usgs_tbl(1).CREATION_DATE      := p_creation_date(x);
               l_terr_usgs_tbl(1).CREATED_BY         := p_created_by(x);
               l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_last_update_login(x);
               l_terr_usgs_tbl(1).TERR_ID            := NULL;
               l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
               l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

               i:=0;

               /* BEGIN: For each Access Type defined for the Territory Group */
               FOR acctype IN get_NON_OVLY_na_trans(naterr.terr_group_account_id)
               LOOP

                   i:=i+1;

                   SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                     INTO l_terr_qtype_usg_id
                      FROM DUAL;

                   IF ( acctype.access_type = 'ACCOUNT' ) THEN
                      l_qual_type_usg_id := -1001;
                   ELSIF ( acctype.access_type = 'LEAD' ) THEN
                       l_qual_type_usg_id := -1002;
                   ELSIF ( acctype.access_type = 'OPPORTUNITY' ) THEN
                      l_qual_type_usg_id := -1003;
                   ELSIF ( acctype.access_type = 'QUOTE' ) THEN
                      l_qual_type_usg_id := -1105;
                   ELSIF ( acctype.access_type = 'PROPOSAL' ) THEN
                      l_qual_type_usg_id := -1106;
                   END IF;

                   l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                   l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                   l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                   l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                   l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                   l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                   l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                   l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := l_qual_type_usg_id;
                   l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

               END LOOP; /* END: For each Access Type defined for the Territory Group */


               /*
               ** get Named Account Customer Keyname and Postal Code Mapping
               ** rules, to use as territory definition qualifier values
               */
               j:=0;
               K:=0;
               l_prev_qual_usg_id:=1;

               FOR qval IN match_rule3( naterr.named_account_id, p_matching_rule_code(x) ) LOOP

                   /* new qualifier, i.e., if there is a qualifier in
                   ** Addition to DUNS# or PARTY# */
                   IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                       j:=j+1;

                       SELECT JTF_TERR_QUAL_S.NEXTVAL
                       INTO l_terr_qual_id
                       FROM DUAL;

                       l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                       l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                       l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                       l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                       l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                       l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                       l_terr_qual_tbl(j).TERR_ID              := NULL;
                       l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                       l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                       l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                       l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                       l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                       l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                       l_prev_qual_usg_id                      := qval.qual_usg_id;

                   END IF;

                   k:=k+1;

                   l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                   l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                   l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                   l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                   l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                   l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                   l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                   l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                   l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;

                   l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                   l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                   l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                   l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                   l_terr_values_tbl(k).VALUE_SET                  := NULL;
                   l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                   l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                   l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                   l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                   l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                   l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                   l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                   l_terr_values_tbl(k).qualifier_tbl_index        := j;

                   /* JRADHAKR: Added support for Party site id and hierarchy */

                   IF ( p_matching_rule_code(x) IN ('2', '3', '4')) THEN
                      l_terr_values_tbl(k).LOW_VALUE_CHAR          := qval.value1_char;
                   ELSIF ( p_matching_rule_code(x) IN ('5')) THEN
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID       := qval.value1_num;
                   ELSE
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID       := qval.value1_num;
                      l_terr_values_tbl(k).LOW_VALUE_CHAR          := p_matching_rule_code(x);
                   END IF;

               END LOOP; /* qval IN pqual */

               l_init_msg_list :=FND_API.G_TRUE;

               JTF_TERRITORY_PVT.create_territory (
                  p_api_version_number         => l_api_version_number,
                  p_init_msg_list              => l_init_msg_list,
                  p_commit                     => l_commit,
                  p_validation_level           => FND_API.g_valid_level_NONE,
                  x_return_status              => x_return_status,
                  x_msg_count                  => x_msg_count,
                  x_msg_data                   => x_msg_data,
                  p_terr_all_rec               => l_terr_all_rec,
                  p_terr_usgs_tbl              => l_terr_usgs_tbl,
                  p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                  p_terr_qual_tbl              => l_terr_qual_tbl,
                  p_terr_values_tbl            => l_terr_values_tbl,
                  x_terr_id                    => x_terr_id,
                  x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                  x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                  x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                  x_terr_values_out_tbl        => x_terr_values_out_tbl

               );

               IF G_Debug THEN
                   write_log(2,'  NA territory created = '||naterr.name);
               END IF;

               /* BEGIN: Successful Territory creation? */
               IF x_return_status = 'S' THEN

                   -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG
                   -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                   UPDATE JTF_TERR_ALL
                   SET TERR_GROUP_FLAG = 'Y'
                     , TERR_GROUP_ID = p_terr_group_id(x)
                     , CATCH_ALL_FLAG = 'N'
                     , NAMED_ACCOUNT_FLAG = 'Y'
                     , TERR_GROUP_ACCOUNT_ID = naterr.terr_group_account_id
                   WHERE terr_id = x_terr_id;

                   l_init_msg_list :=FND_API.G_TRUE;
                   i := 0;
                   a := 0;

                   FOR tran_type IN role_interest_nonpi(p_terr_group_id(x)) LOOP

                       /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                       FOR rsc IN resource_grp(naterr.terr_group_account_id, tran_type.role_code) LOOP
                           i:=i+1;

                           SELECT JTF_TERR_RSC_S.NEXTVAL
                           INTO l_terr_rsc_id
                           FROM DUAL;

                           l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                           l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                           l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                           l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                           l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                           l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                           l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                           l_TerrRsc_Tbl(i).ROLE                 := tran_type.role_code;
                           l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';

                           IF rsc.start_date IS NULL THEN
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := rsc.start_date;
                           END IF;

                           IF rsc.end_date IS NULL THEN
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := rsc.end_date;
                           END IF;

                           l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                           l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                           l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                           l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                           l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                           l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                           l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                           l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                           l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                           l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                           l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                           l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                           l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                           l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                           l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                           l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                           l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                           l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                           l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;


                           FOR rsc_acc IN NON_OVLY_role_access(p_terr_group_id(x),tran_type.role_code)
                           LOOP
                               --dbms_output.put_line('rsc_acc.access_type   '||rsc_acc.access_type);
                               a := a+1;

                               IF ( rsc_acc.access_type='OPPORTUNITY' ) THEN
                                    l_qual_type := 'OPPOR';
                               ELSE
                                    l_qual_type := rsc_acc.access_type;
                               END IF;

                               SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                 INTO l_terr_rsc_access_id
                                 FROM DUAL;

                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                               l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                               l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                               l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := l_qual_type;
                               l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                               l_TerrRsc_Access_Tbl(a).TRANS_ACCESS_CODE   := rsc_acc.trans_access_code;
                               l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                           END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

                       END LOOP; /* FOR rsc in resource_grp */

                   END LOOP;/* FOR tran_type in role_interest_nonpi */

                   l_init_msg_list :=FND_API.G_TRUE;


                   -- 07/08/03: JDOCHERT: bug#3023653
                   Jtf_Territory_Resource_Pvt.create_terrresource (
                      p_api_version_number      => l_Api_Version_Number,
                      p_init_msg_list           => l_Init_Msg_List,
                      p_commit                  => l_Commit,
                      p_validation_level        => FND_API.g_valid_level_NONE,
                      x_return_status           => x_Return_Status,
                      x_msg_count               => x_Msg_Count,
                      x_msg_data                => x_msg_data,
                      p_terrrsc_tbl             => l_TerrRsc_tbl,
                      p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                      x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                      x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                   );


                   IF x_Return_Status='S' THEN
                       IF G_Debug THEN
                           write_log(2,'     Resource created for NA territory # ' ||x_terr_id);
                       END IF;
                   ELSE
                       x_msg_data := SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                       IF G_Debug THEN
                         write_log(2,x_msg_data);
                         write_log(2, '     Failed in resource creation for NA territory # ' || x_terr_id);
                       END IF;
                   END IF;

               ELSE
                   x_msg_data :=  SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                   IF G_Debug THEN
                       write_log(2,SUBSTR(x_msg_data,1,254));
                       WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' || 'FOR NAMED_ACCOUNT_ID# ' || naterr.named_account_id );
                   END IF;
               END IF; /* END: Successful Territory creation? */

           END LOOP; /* naterr in get_party_info */
         END IF; /* ( p_matching_rule_code(x) IN ('3') THEN */
         /*************************************************************/

         /* (5) END: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING DUNS# OR PARTY# QUALIFIER                       */
         /*************************************************************/

         /***************************************************************/
         /* (6) START: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
         /***************************************************************/

         IF ( p_matching_rule_code(x) IN ('1', '2') ) THEN
           FOR naterr IN get_party_name(p_terr_grp_acct_id(x)) LOOP

               --write_log(2,'na '||naterr.named_account_id);
               l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
               l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
               l_terr_qual_tbl         := l_terr_qual_empty_tbl;
               l_terr_values_tbl       := l_terr_values_empty_tbl;
               l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
               l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

               /* TERRITORY HEADER */
               /* Ensure static TERR_ID to benefit TAP Performance */
               BEGIN

                   l_terr_exists := 0;

                   SELECT COUNT(*)
                   INTO l_terr_exists
                   FROM jtf_terr_all jt
                   WHERE jt.terr_id = naterr.terr_group_account_id * -10000;

                   IF (l_terr_exists = 0) THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -10000;
                   ELSE
                       l_terr_all_rec.TERR_ID := NULL;
                   END IF;

               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -10000;
               END;

               l_terr_all_rec.LAST_UPDATE_DATE             := p_last_update_date(x);
               l_terr_all_rec.LAST_UPDATED_BY              := p_last_updated_by(x);
               l_terr_all_rec.CREATION_DATE                := p_creation_date(x);
               l_terr_all_rec.CREATED_BY                   := p_created_by(x);
               l_terr_all_rec.LAST_UPDATE_LOGIN            := p_last_update_login(x);
               l_terr_all_rec.APPLICATION_SHORT_NAME       := G_APP_SHORT_NAME;
               l_terr_all_rec.NAME                         := naterr.name;

               IF naterr.start_date IS NULL THEN
                   l_terr_all_rec.start_date_active          := p_active_from_date(x);
               ELSE
                   l_terr_all_rec.start_date_active          := naterr.start_date;
               END IF;

               IF naterr.end_date IS NULL THEN
                   l_terr_all_rec.end_date_active            := p_active_to_date(x);
               ELSE
                   l_terr_all_rec.end_date_active            := naterr.end_date;
               END IF;

               l_terr_all_rec.PARENT_TERRITORY_ID          := p_terr_id(x);
               l_terr_all_rec.RANK                         := p_rank(x) + 20;
               l_terr_all_rec.TEMPLATE_TERRITORY_ID        := NULL;
               l_terr_all_rec.TEMPLATE_FLAG                := 'N';
               l_terr_all_rec.ESCALATION_TERRITORY_ID      := NULL;
               l_terr_all_rec.ESCALATION_TERRITORY_FLAG    := 'N';
               l_terr_all_rec.OVERLAP_ALLOWED_FLAG         := NULL;
               l_terr_all_rec.DESCRIPTION                  := naterr.name;
               l_terr_all_rec.UPDATE_FLAG                  := 'N';
               l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG   := NULL;
               l_terr_all_rec.ORG_ID                       := p_org_id(x);
               l_terr_all_rec.NUM_WINNERS                  := NULL ;
               l_terr_all_rec.TERRITORY_TYPE_ID            := -1;
               l_terr_all_rec.attribute_category           := p_terr_attr_cat(x);
               l_terr_all_rec.attribute1                   := p_terr_attribute1(x);
               l_terr_all_rec.attribute2                   := p_terr_attribute2(x);
               l_terr_all_rec.attribute3                   := p_terr_attribute3(x);
               l_terr_all_rec.attribute4                   := p_terr_attribute4(x);
               l_terr_all_rec.attribute5                   := p_terr_attribute5(x);
               l_terr_all_rec.attribute6                   := p_terr_attribute6(x);
               l_terr_all_rec.attribute7                   := p_terr_attribute7(x);
               l_terr_all_rec.attribute8                   := p_terr_attribute8(x);
               l_terr_all_rec.attribute9                   := p_terr_attribute9(x);
               l_terr_all_rec.attribute10                  := p_terr_attribute10(x);
               l_terr_all_rec.attribute11                  := p_terr_attribute11(x);
               l_terr_all_rec.attribute12                  := p_terr_attribute12(x);
               l_terr_all_rec.attribute13                  := p_terr_attribute13(x);
               l_terr_all_rec.attribute14                  := p_terr_attribute14(x);
               l_terr_all_rec.attribute15                  := p_terr_attribute15(x);

               /* Oracle Sales and Telesales Usage */
               SELECT JTF_TERR_USGS_S.NEXTVAL
               INTO l_terr_usg_id
               FROM DUAL;

               l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
               l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_last_update_date(x);
               l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_last_updated_by(x);
               l_terr_usgs_tbl(1).CREATION_DATE      := p_creation_date(x);
               l_terr_usgs_tbl(1).CREATED_BY         := p_created_by(x);
               l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_last_update_login(x);
               l_terr_usgs_tbl(1).TERR_ID            := NULL;
               l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
               l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

               i:=0;

               /* BEGIN: For each Access Type defined for the Territory Group */
               FOR acctype IN get_NON_OVLY_na_trans(naterr.terr_group_account_id)
               LOOP

                  i:=i+1;

                  IF ( acctype.access_type = 'ACCOUNT' ) THEN
                     l_qual_type_usg_id := -1001;
                  ELSIF ( acctype.access_type = 'LEAD' ) THEN
                     l_qual_type_usg_id := -1002;
                  ELSIF ( acctype.access_type = 'OPPORTUNITY' ) THEN
                     l_qual_type_usg_id := -1003;
                  ELSIF ( acctype.access_type = 'QUOTE' ) THEN
                     l_qual_type_usg_id := -1105;
                  ELSIF ( acctype.access_type = 'PROPOSAL' ) THEN
                     l_qual_type_usg_id := -1106;
                  END IF;

                  SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                    INTO l_terr_qtype_usg_id
                    FROM DUAL;

                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := l_qual_type_usg_id;
                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

               END LOOP;
               /* END: For each Access Type defined for the Territory Group */

               /*
               ** get Named Account Customer Keyname and Postal Code Mapping
               ** rules, to use as territory definition qualifier values
               */
               j:=0;
               K:=0;
               l_prev_qual_usg_id:=1;
               FOR qval IN match_rule1( naterr.named_account_id ) LOOP

                   /* new qualifier, i.e., Customer Name Range or Postal Code: ** driven by ORDER BY on p_qual */
                   IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                       j:=j+1;

                       SELECT JTF_TERR_QUAL_S.NEXTVAL
                       INTO l_terr_qual_id
                       FROM DUAL;

                       l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                       l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                       l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                       l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                       l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                       l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                       l_terr_qual_tbl(j).TERR_ID              := NULL;
                       l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                       l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                       l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                       l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                       l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                       l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                       l_prev_qual_usg_id                      := qval.qual_usg_id;
                   END IF;

                   k:=k+1;

                   l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                   l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                   l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                   l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                   l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                   l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                   l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                   l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                   l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;
                   l_terr_values_tbl(k).LOW_VALUE_CHAR             := qval.value1_char;
                   l_terr_values_tbl(k).HIGH_VALUE_CHAR            := qval.value2_char;
                   l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                   l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                   l_terr_values_tbl(k).VALUE_SET                  := NULL;
                   l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                   l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                   l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                   l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                   l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                   l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                   l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                   l_terr_values_tbl(k).qualifier_tbl_index        := j;

               END LOOP; /* qval IN pqual */

               l_init_msg_list :=FND_API.G_TRUE;

               JTF_TERRITORY_PVT.create_territory (
                  p_api_version_number         => l_api_version_number,
                  p_init_msg_list              => l_init_msg_list,
                  p_commit                     => l_commit,
                  p_validation_level           => FND_API.g_valid_level_NONE,
                  x_return_status              => x_return_status,
                  x_msg_count                  => x_msg_count,
                  x_msg_data                   => x_msg_data,
                  p_terr_all_rec               => l_terr_all_rec,
                  p_terr_usgs_tbl              => l_terr_usgs_tbl,
                  p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                  p_terr_qual_tbl              => l_terr_qual_tbl,
                  p_terr_values_tbl            => l_terr_values_tbl,
                  x_terr_id                    => x_terr_id,
                  x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                  x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                  x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                  x_terr_values_out_tbl        => x_terr_values_out_tbl

               );


               IF G_Debug THEN
                   write_log(2,'  NA territory created = '||naterr.name);
               END IF;

               /* BEGIN: Successful Territory creation? */
               IF x_return_status = 'S' THEN

                   -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG
                   -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                   UPDATE JTF_TERR_ALL
                   SET TERR_GROUP_FLAG = 'Y'
                     , TERR_GROUP_ID = p_terr_group_id(x)
                     , CATCH_ALL_FLAG = 'N'
                     , NAMED_ACCOUNT_FLAG = 'Y'
                     , TERR_GROUP_ACCOUNT_ID = naterr.terr_group_account_id
                   WHERE terr_id = x_terr_id;

                   l_init_msg_list :=FND_API.G_TRUE;
                   i := 0;
                   a := 0;

                   FOR tran_type IN role_interest_nonpi(p_terr_group_id(x)) LOOP

                       /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                       FOR rsc IN resource_grp(naterr.terr_group_account_id, tran_type.role_code) LOOP
                           i:=i+1;

                           SELECT JTF_TERR_RSC_S.NEXTVAL
                           INTO l_terr_rsc_id
                           FROM DUAL;

                           l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                           l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                           l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                           l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                           l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                           l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                           l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                           l_TerrRsc_Tbl(i).ROLE                 := tran_type.role_code;
                           l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';

                           IF rsc.start_date IS NULL THEN
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := rsc.start_date;
                           END IF;

                           IF rsc.end_date IS NULL THEN
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := rsc.end_date;
                           END IF;

                           l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                           l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                           l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                           l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                           l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                           l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                           l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                           l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                           l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                           l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                           l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                           l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                           l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                           l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                           l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                           l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                           l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                           l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                           l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;

                           FOR rsc_acc IN NON_OVLY_role_access(p_terr_group_id(x), tran_type.role_code)
                           LOOP
                               a := a+1;

                               IF ( rsc_acc.access_type='OPPORTUNITY' ) THEN
                                    l_qual_type := 'OPPOR';
                               ELSE
                                    l_qual_type := rsc_acc.access_type;
                               END IF;

                               SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                 INTO l_terr_rsc_access_id
                                 FROM DUAL;

                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                               l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                               l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                               l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := l_qual_type;
                               l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                               l_TerrRsc_Access_Tbl(a).TRANS_ACCESS_CODE   := rsc_acc.trans_access_code;
                               l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                           END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

                       END LOOP; /* FOR rsc in resource_grp */

                   END LOOP;/* FOR tran_type in role_interest_nonpi */

                   l_init_msg_list :=FND_API.G_TRUE;

                   Jtf_Territory_Resource_Pvt.create_terrresource (
                      p_api_version_number      => l_Api_Version_Number,
                      p_init_msg_list           => l_Init_Msg_List,
                      p_commit                  => l_Commit,
                      p_validation_level        => FND_API.g_valid_level_NONE,
                      x_return_status           => x_Return_Status,
                      x_msg_count               => x_Msg_Count,
                      x_msg_data                => x_msg_data,
                      p_terrrsc_tbl             => l_TerrRsc_tbl,
                      p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                      x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                      x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                   );


                   IF x_Return_Status='S' THEN
                       IF G_Debug THEN
                           write_log(2,'     Resource created for NA territory # ' ||x_terr_id);
                       END IF;
                   ELSE
                       x_msg_data := SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                       IF G_Debug THEN
                           write_log(2,x_msg_data);
                           write_log(2, '     Failed in resource creation for NA territory # ' || x_terr_id);
                       END IF;
                   END IF;

               ELSE
                   x_msg_data :=  SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                   IF G_Debug THEN
                       write_log(2,SUBSTR(x_msg_data,1,254));
                       WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' || 'FOR NAMED_ACCOUNT_ID# ' || naterr.named_account_id );
                   END IF;
               END IF; /* END: Successful Territory creation? */

           END LOOP; /* naterr in get_party_name */
         END IF; /* p_matching_rule_code(x) IN ('1', '2') THEN */

         /*************************************************************/
         /* (6) END: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS  */
         /*************************************************************/

         /********************************************************/
         /* delete the role and access */
         /********************************************************/
         IF l_ovnon_flag = 'Y' THEN

              FOR i IN l_overnon_role_tbl.first.. l_overnon_role_tbl.last
              LOOP
                 DELETE FROM jtf_tty_terr_grp_roles
                 WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
                 --dbms_output.put_line('deleted');
                 DELETE FROM jtf_tty_role_access
                 WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
              END LOOP;
         END IF;

      END IF;
      /* END: if Territory Group exists with Named Accounts then auto-create territory definitions */



      /*********************************************************************/
      /*********************************************************************/
      /************** OVERLAY TERRITORY CREATION ***************************/
      /*********************************************************************/
      /*********************************************************************/

      /* if any role with PI and Account access and no non pi role exist */
      /* we need to create a new branch with Named Account               */

      /* OVERLAY BRANCH */
      BEGIN

          SELECT COUNT( DISTINCT b.role_code )
          INTO l_pi_count
          FROM jtf_rs_roles_vl r
              , jtf_tty_role_prod_int a
              , jtf_tty_terr_grp_roles b
          WHERE r.role_code = b.role_code
          AND a.terr_group_role_id = b.terr_group_role_id
          AND b.terr_group_id      = p_terr_group_id(x)
          AND EXISTS (
               /* Named Account exists with Salesperson with this role */
               SELECT NULL
               FROM jtf_tty_named_acct_rsc nar, jtf_tty_terr_grp_accts tga
               WHERE tga.terr_group_account_id = nar.terr_group_account_id
               AND tga.terr_group_id = b.terr_group_id
               AND nar.rsc_role_code = b.role_code )
          AND ROWNUM < 2;

      EXCEPTION
          WHEN OTHERS THEN NULL;
      END;

      /* are there overlay roles, i.e., are there roles with Product
      ** Interests defined for this Territory Group */
      IF l_pi_count > 0 THEN

          /***************************************************************/
          /* (8) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
          /*     USING DUNS# AND PARTY# QUALIFIER                        */
          /***************************************************************/
          IF ( p_matching_rule_code(x) IN ('2', '3', '4') ) THEN
              FOR overlayterr IN get_OVLY_party_info(p_terr_grp_acct_id(x), p_matching_rule_code(x)) LOOP

                  l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                  l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                  l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                  l_terr_values_tbl       := l_terr_values_empty_tbl;
                  l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                  l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                  l_terr_all_rec.TERR_ID                     := NULL;
                  l_terr_all_rec.LAST_UPDATE_DATE            := p_last_update_date(x);
                  l_terr_all_rec.LAST_UPDATED_BY             := p_last_updated_by(x);
                  l_terr_all_rec.CREATION_DATE               := p_creation_date(x);
                  l_terr_all_rec.CREATED_BY                  := p_created_by(x);
                  l_terr_all_rec.LAST_UPDATE_LOGIN           := p_last_update_login(x);
                  l_terr_all_rec.APPLICATION_SHORT_NAME      := G_APP_SHORT_NAME;

                  IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                    l_terr_all_rec.NAME                        := overlayterr.name || ' (OVERLAY DUNS#)';
                  ELSE
                    l_terr_all_rec.NAME                        := overlayterr.name || ' (OVERLAY Registry ID)';
                  END IF;

                  l_terr_all_rec.start_date_active           := p_active_from_date(x);
                  l_terr_all_rec.end_date_active             := p_active_to_date(x);
                  l_terr_all_rec.PARENT_TERRITORY_ID         := p_overlay_top(x);
                  l_terr_all_rec.RANK                        := p_rank(x)+ 10;
                  l_terr_all_rec.TEMPLATE_TERRITORY_ID       := NULL;
                  l_terr_all_rec.TEMPLATE_FLAG               := 'N';
                  l_terr_all_rec.ESCALATION_TERRITORY_ID     := NULL;
                  l_terr_all_rec.ESCALATION_TERRITORY_FLAG   := 'N';
                  l_terr_all_rec.OVERLAP_ALLOWED_FLAG        := NULL;

                  IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                    l_terr_all_rec.DESCRIPTION                 := overlayterr.name || ' (OVERLAY DUNS#)';
                  ELSE
                    l_terr_all_rec.DESCRIPTION                 := overlayterr.name || ' (OVERLAY Registry ID)';
                  END IF;

                  l_terr_all_rec.UPDATE_FLAG                 := 'N';
                  l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG  := NULL;
                  l_terr_all_rec.ORG_ID                      := p_org_id(x);
                  l_terr_all_rec.NUM_WINNERS                 := NULL ;

                  SELECT JTF_TERR_USGS_S.NEXTVAL
                  INTO l_terr_usg_id
                  FROM DUAL;

                  l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                  l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                  l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                  l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                  l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                  l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                  l_terr_usgs_tbl(1).TERR_ID           := NULL;
                  l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
                  l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                  SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                  INTO l_terr_qtype_usg_id
                  FROM DUAL;

                  l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(1).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(1).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1002;
                  l_terr_qualtypeusgs_tbl(1).ORG_ID                := p_org_id(x);

                  SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                  INTO l_terr_qtype_usg_id
                  FROM DUAL;

                  l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(2).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(2).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1003;
                  l_terr_qualtypeusgs_tbl(2).ORG_ID                := p_org_id(x);

                  SELECT JTF_TERR_QUAL_S.NEXTVAL
                  INTO l_terr_qual_id
                  FROM DUAL;

                  j:=0;
                  K:=0;
                  l_prev_qual_usg_id:=1;

                  FOR qval IN match_rule3(overlayterr.named_account_id, p_matching_rule_code(x)) LOOP

                      IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                          j:=j+1;

                          SELECT   JTF_TERR_QUAL_S.NEXTVAL
                          INTO l_terr_qual_id
                          FROM DUAL;

                          l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                          l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                          l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                          l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                          l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                          l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                          l_terr_qual_tbl(j).TERR_ID              := NULL;
                          l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                          l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                          l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                          l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                          l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                          l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                          l_prev_qual_usg_id                      := qval.qual_usg_id;

                      END IF;

                      k:=k+1;

                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                      l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;
                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := qval.value1_char;
                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                      l_terr_values_tbl(k).VALUE_SET                  := NULL;
                      l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                      l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                      l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                      l_terr_values_tbl(k).qualifier_tbl_index        := j;

                  END LOOP;

                  l_init_msg_list :=FND_API.G_TRUE;

                  JTF_TERRITORY_PVT.create_territory (
                             p_api_version_number         => l_api_version_number,
                             p_init_msg_list              => l_init_msg_list,
                             p_commit                     => l_commit,
                             p_validation_level           => FND_API.g_valid_level_NONE,
                             x_return_status              => x_return_status,
                             x_msg_count                  => x_msg_count,
                             x_msg_data                   => x_msg_data,
                             p_terr_all_rec               => l_terr_all_rec,
                             p_terr_usgs_tbl              => l_terr_usgs_tbl,
                             p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                             p_terr_qual_tbl              => l_terr_qual_tbl,
                             p_terr_values_tbl            => l_terr_values_tbl,
                             x_terr_id                    => x_terr_id,
                             x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                             x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                             x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                             x_terr_values_out_tbl        => x_terr_values_out_tbl

                  );

                  IF G_Debug THEN
                      write_log(2,' Named Account OVERLAY territory created: '||l_terr_all_rec.NAME);
                  END IF;

                  IF x_return_status = 'S' THEN

                      -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                      -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                      UPDATE JTF_TERR_ALL
                      SET TERR_GROUP_FLAG = 'Y'
                        , TERR_GROUP_ID = p_TERR_GROUP_ID(x)
                        , NAMED_ACCOUNT_FLAG = 'Y'
                        , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                      WHERE terr_id = x_terr_id;

                      l_overlay:=x_terr_id;

                      FOR pit IN role_pi(p_terr_group_id(x), overlayterr.terr_group_account_id) LOOP

                          l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                          l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                          l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                          l_terr_values_tbl       := l_terr_values_empty_tbl;
                          l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                          l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                          l_role_counter := l_role_counter + 1;

                          l_terr_all_rec.TERR_ID                    := overlayterr.terr_group_account_id * -30 * l_role_counter;
                          l_terr_all_rec.LAST_UPDATE_DATE           := p_last_update_date(x);
                          l_terr_all_rec.LAST_UPDATED_BY            := p_last_updated_by(x);
                          l_terr_all_rec.CREATION_DATE              := p_creation_date(x);
                          l_terr_all_rec.CREATED_BY                 := p_created_by(x);
                          l_terr_all_rec.LAST_UPDATE_LOGIN          := p_last_update_login(x);
                          l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;

                          IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                            l_terr_all_rec.NAME                     := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY
DUNS#)';
                          ELSE
                            l_terr_all_rec.NAME                     := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY
Registry ID)';
                          END IF;

                          l_terr_all_rec.start_date_active          := p_active_from_date(x);
                          l_terr_all_rec.end_date_active            := p_active_to_date(x);
                          l_terr_all_rec.PARENT_TERRITORY_ID        := l_overlay;
                          l_terr_all_rec.RANK                       := p_rank(x) + 10;
                          l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
                          l_terr_all_rec.TEMPLATE_FLAG              := 'N';
                          l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
                          l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
                          l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;

                          IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                            l_terr_all_rec.DESCRIPTION              := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY
DUNS#)';
                          ELSE
                            l_terr_all_rec.DESCRIPTION              := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY
Registry ID)';
                          END IF;

                          l_terr_all_rec.UPDATE_FLAG                := 'N';
                          l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
                          l_terr_all_rec.ORG_ID                     := p_org_id(x);
                          l_terr_all_rec.NUM_WINNERS                := NULL ;
                          l_terr_all_rec.attribute_category         := p_terr_attr_cat(x);
                          l_terr_all_rec.attribute1                 := p_terr_attribute1(x);
                          l_terr_all_rec.attribute2                 := p_terr_attribute2(x);
                          l_terr_all_rec.attribute3                 := p_terr_attribute3(x);
                          l_terr_all_rec.attribute4                 := p_terr_attribute4(x);
                          l_terr_all_rec.attribute5                 := p_terr_attribute5(x);
                          l_terr_all_rec.attribute6                 := p_terr_attribute6(x);
                          l_terr_all_rec.attribute7                 := p_terr_attribute7(x);
                          l_terr_all_rec.attribute8                 := p_terr_attribute8(x);
                          l_terr_all_rec.attribute9                 := p_terr_attribute9(x);
                          l_terr_all_rec.attribute10                := p_terr_attribute10(x);
                          l_terr_all_rec.attribute11                := p_terr_attribute11(x);
                          l_terr_all_rec.attribute12                := p_terr_attribute12(x);
                          l_terr_all_rec.attribute13                := p_terr_attribute13(x);
                          l_terr_all_rec.attribute14                := p_terr_attribute14(x);
                          l_terr_all_rec.attribute15                := p_terr_attribute15(x);

                          SELECT   JTF_TERR_USGS_S.NEXTVAL
                          INTO l_terr_usg_id
                          FROM DUAL;

                          l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                          l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                          l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                          l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                          l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                          l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                          l_terr_usgs_tbl(1).TERR_ID           := NULL;
                          l_terr_usgs_tbl(1).SOURCE_ID         :=-1001;
                          l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                          i := 0;
                          K:= 0;
                          FOR acc_type IN role_access(p_terr_group_id(x),pit.role_code) LOOP
                              --i:=i+1;
                              --dbms_output.put_line('acc type  '||acc_type.access_type);
                              IF acc_type.access_type= 'OPPORTUNITY' THEN
                                  i:=i+1;
                                  SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                  INTO l_terr_qtype_usg_id
                                  FROM DUAL;

                                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1003;
                                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                  SELECT JTF_TERR_QUAL_S.NEXTVAL
                                  INTO l_terr_qual_id
                                  FROM DUAL;

                                  /* opp expected purchase */
                                  l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                  l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                  l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                  l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                  l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                  l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                  l_terr_qual_tbl(i).TERR_ID              := NULL;
                                  l_terr_qual_tbl(i).QUAL_USG_ID          := g_opp_qual_usg_id;
                                  l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                  l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                  l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                  l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                  l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                  FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP
                                      k:=k+1;

                                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                      l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                      l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                      l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                      l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                      l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                      IF (g_prod_cat_enabled) THEN
                                        l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                        l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                      ELSE
                                        l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                      END IF;

                                  END LOOP;

                              ELSIF acc_type.access_type= 'LEAD' THEN

                                  i:=i+1;
                                  SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                  INTO l_terr_qtype_usg_id
                                  FROM DUAL;

                                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1002;
                                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                  SELECT   JTF_TERR_QUAL_S.NEXTVAL
                                  INTO l_terr_qual_id
                                  FROM DUAL;

                                  /* lead expected purchase */
                                  l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                  l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                  l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                  l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                  l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                  l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                  l_terr_qual_tbl(i).TERR_ID              := NULL;
                                  l_terr_qual_tbl(i).QUAL_USG_ID          := g_lead_qual_usg_id;
                                  l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                  l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                  l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                  l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                  l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                  FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                                      k:=k+1;

                                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                      l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                      l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                      l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                      l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                      l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                      IF (g_prod_cat_enabled) THEN
                                        l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                        l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                      ELSE
                                        l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                      END IF;

                                  END LOOP;

                              ELSE
                                  IF G_Debug THEN
                                      write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_id(x));
                                  END IF;
                              END IF;

                          END LOOP;

                          l_init_msg_list :=FND_API.G_TRUE;

                          JTF_TERRITORY_PVT.create_territory (
                                     p_api_version_number         => l_api_version_number,
                                     p_init_msg_list              => l_init_msg_list,
                                     p_commit                     => l_commit,
                                     p_validation_level           => FND_API.g_valid_level_NONE,
                                     x_return_status              => x_return_status,
                                     x_msg_count                  => x_msg_count,
                                     x_msg_data                   => x_msg_data,
                                     p_terr_all_rec               => l_terr_all_rec,
                                     p_terr_usgs_tbl              => l_terr_usgs_tbl,
                                     p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                                     p_terr_qual_tbl              => l_terr_qual_tbl,
                                     p_terr_values_tbl            => l_terr_values_tbl,
                                     x_terr_id                    => x_terr_id,
                                     x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                                     x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                                     x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                                     x_terr_values_out_tbl        => x_terr_values_out_tbl

                          );

                          IF (x_return_status = 'S')  THEN

                              -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                              -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                              UPDATE JTF_TERR_ALL
                              SET TERR_GROUP_FLAG = 'Y'
                                , TERR_GROUP_ID = p_terr_group_id(x)
                                , NAMED_ACCOUNT_FLAG = 'Y'
                                , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                              WHERE terr_id = x_terr_id;

                              IF G_Debug THEN
                                  write_log(2,' OVERLAY PI Territory Created = '||l_terr_all_rec.NAME);
                              END IF;

                          ELSE
                              x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                              IF G_Debug THEN
                                  write_log(2,x_msg_data);
                                  write_log(2, 'Failed in OVERLAY PI Territory Creation for TERR_GROUP_ACCOUNT_ID#'||
                                                    overlayterr.terr_group_account_id);
                              END IF;

                          END IF;

                          --dbms_output.put_line('pit.role '||pit.role_code);
                          i:=0;

                          /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                          FOR rsc IN resource_grp(overlayterr.terr_group_account_id,pit.role_code) LOOP

                              i:=i+1;

                              SELECT JTF_TERR_RSC_S.NEXTVAL
                              INTO l_terr_rsc_id
                              FROM DUAL;

                              l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                              l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                              l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                              l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                              l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                              l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                              l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                              l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                              l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                              l_TerrRsc_Tbl(i).ROLE                 := pit.role_code;
                              l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
                              l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                              l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                              l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                              l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                              l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                              l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                              l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                              l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                              l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                              l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                              l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                              l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                              l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                              l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                              l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                              l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                              l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                              l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                              l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                              l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                              l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;

                              a := 0;

                              FOR rsc_acc IN role_access(p_terr_group_id(x),pit.role_code) LOOP

                                  IF rsc_acc.access_type= 'OPPORTUNITY' THEN

                                      a := a+1;

                                      SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                      INTO l_terr_rsc_access_id
                                      FROM DUAL;

                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                      l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                      l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                      l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                                      l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                      l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                                  ELSIF rsc_acc.access_type= 'LEAD' THEN

                                      a := a+1;

                                      SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                      INTO l_terr_rsc_access_id
                                      FROM DUAL;

                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                      l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                      l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                      l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                                      l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                      l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                                  END IF;
                              END LOOP; /* rsc_acc in role_access */

                              l_init_msg_list :=FND_API.G_TRUE;

                              -- 07/08/03: JDOCHERT: bug#3023653
                              Jtf_Territory_Resource_Pvt.create_terrresource (
                                         p_api_version_number      => l_Api_Version_Number,
                                         p_init_msg_list           => l_Init_Msg_List,
                                         p_commit                  => l_Commit,
                                         p_validation_level        => FND_API.g_valid_level_NONE,
                                         x_return_status           => x_Return_Status,
                                         x_msg_count               => x_Msg_Count,
                                         x_msg_data                => x_msg_data,
                                         p_terrrsc_tbl             => l_TerrRsc_tbl,
                                         p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                                         x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                                         x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                              );

                              IF x_Return_Status='S' THEN
                                   IF G_Debug THEN
                                       write_log(2,'Resource created for Product Interest OVERLAY Territory '||l_terr_all_rec.NAME);
                                   END IF;
                              ELSE
                                   IF G_Debug THEN
                                       write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '||
x_terr_id);
                                   END IF;
                              END IF;

                          END LOOP; /* rsc in resource_grp */

                      END LOOP;

                  ELSE
                       x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                       IF G_Debug THEN
                           write_log(2,x_msg_data);
                           write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' || p_terr_group_id(x));
                       END IF;
                  END IF; /* if (x_return_status = 'S' */
              END LOOP; /* overlayterr in get_OVLY_party_info */
          END IF; /* ( p_matching_rule_code(x) IN ('2','3') THEN */
          /***************************************************************/
          /* (8) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
          /*     USING DUNS# PARTY# QUALIFIER                            */
          /***************************************************************/


          /***************************************************************/
          /* (9) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
          /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
          /***************************************************************/
          IF ( p_matching_rule_code(x) IN ('1', '2') ) THEN
            FOR overlayterr IN get_OVLY_party_name(p_terr_grp_acct_id(x)) LOOP

                l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                l_terr_values_tbl       := l_terr_values_empty_tbl;
                l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                l_terr_all_rec.TERR_ID                    := NULL;
                l_terr_all_rec.LAST_UPDATE_DATE           := p_last_update_date(x);
                l_terr_all_rec.LAST_UPDATED_BY            := p_last_updated_by(x);
                l_terr_all_rec.CREATION_DATE              := p_creation_date(x);
                l_terr_all_rec.CREATED_BY                 := p_created_by(x);
                l_terr_all_rec.LAST_UPDATE_LOGIN          := p_last_update_login(x);
                l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
                l_terr_all_rec.NAME                       := overlayterr.name || ' (OVERLAY)';
                l_terr_all_rec.start_date_active          := p_active_from_date(x);
                l_terr_all_rec.end_date_active            := p_active_to_date(x);
                l_terr_all_rec.PARENT_TERRITORY_ID        := p_overlay_top(x);
                l_terr_all_rec.RANK                       := p_rank(x) + 20;
                l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
                l_terr_all_rec.TEMPLATE_FLAG              := 'N';
                l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
                l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
                l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
                l_terr_all_rec.DESCRIPTION                := overlayterr.name || ' (OVERLAY)';
                l_terr_all_rec.UPDATE_FLAG                := 'N';
                l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
                l_terr_all_rec.ORG_ID                     := p_org_id(x);
                l_terr_all_rec.NUM_WINNERS                := NULL ;


                SELECT JTF_TERR_USGS_S.NEXTVAL
                INTO l_terr_usg_id
                FROM DUAL;

                l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                l_terr_usgs_tbl(1).TERR_ID           := NULL;
                l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
                l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := p_last_update_date(x);
                l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := p_last_updated_by(x);
                l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := p_creation_date(x);
                l_terr_qualtypeusgs_tbl(1).CREATED_BY            := p_created_by(x);
                l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                l_terr_qualtypeusgs_tbl(1).TERR_ID               := NULL;
                l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1002;
                l_terr_qualtypeusgs_tbl(1).ORG_ID                := p_org_id(x);

                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := p_last_update_date(x);
                l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := p_last_updated_by(x);
                l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := p_creation_date(x);
                l_terr_qualtypeusgs_tbl(2).CREATED_BY            := p_created_by(x);
                l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                l_terr_qualtypeusgs_tbl(2).TERR_ID               := NULL;
                l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1003;
                l_terr_qualtypeusgs_tbl(2).ORG_ID                := p_org_id(x);

                SELECT JTF_TERR_QUAL_S.NEXTVAL
                INTO l_terr_qual_id
                FROM DUAL;

                j:=0;
                K:=0;
                l_prev_qual_usg_id:=1;

                FOR qval IN match_rule1(overlayterr.named_account_id) LOOP

                    IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                        j:=j+1;
                        SELECT   JTF_TERR_QUAL_S.NEXTVAL
                        INTO l_terr_qual_id
                        FROM DUAL;

                        l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                        l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                        l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                        l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                        l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                        l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                        l_terr_qual_tbl(j).TERR_ID              := NULL;
                        l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                        l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                        l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                        l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                        l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                        l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                        l_prev_qual_usg_id                      := qval.qual_usg_id;

                    END IF;

                    k:=k+1;

                    l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                    l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                    l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                    l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                    l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                    l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                    l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                    l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                    l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;
                    l_terr_values_tbl(k).LOW_VALUE_CHAR             := qval.value1_char;
                    l_terr_values_tbl(k).HIGH_VALUE_CHAR            := qval.value2_char;
                    l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                    l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                    l_terr_values_tbl(k).VALUE_SET                  := NULL;
                    l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                    l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                    l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                    l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                    l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                    l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                    l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                    l_terr_values_tbl(k).qualifier_tbl_index        := j;

                END LOOP;

                l_init_msg_list :=FND_API.G_TRUE;

                JTF_TERRITORY_PVT.create_territory (
                    p_api_version_number         => l_api_version_number,
                    p_init_msg_list              => l_init_msg_list,
                    p_commit                     => l_commit,
                    p_validation_level           => FND_API.g_valid_level_NONE,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data,
                    p_terr_all_rec               => l_terr_all_rec,
                    p_terr_usgs_tbl              => l_terr_usgs_tbl,
                    p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                    p_terr_qual_tbl              => l_terr_qual_tbl,
                    p_terr_values_tbl            => l_terr_values_tbl,
                    x_terr_id                    => x_terr_id,
                    x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                    x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                    x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                    x_terr_values_out_tbl        => x_terr_values_out_tbl

                );

                IF G_Debug THEN
                    write_log(2,' OVERLAY Territory Created,territory_id# '||x_terr_id);
                END IF;

                IF x_return_status = 'S' THEN

                    -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                    -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                    UPDATE JTF_TERR_ALL
                    SET TERR_GROUP_FLAG = 'Y'
                      , TERR_GROUP_ID = p_terr_group_id(x)
                      , NAMED_ACCOUNT_FLAG = 'Y'
                      , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                    WHERE terr_id = x_terr_id;

                    l_overlay:=x_terr_id;

                    FOR pit IN role_pi( p_terr_group_id(x) , overlayterr.terr_group_account_id) LOOP

                        l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                        l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                        l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                        l_terr_values_tbl       := l_terr_values_empty_tbl;
                        l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                        l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                        l_role_counter := l_role_counter + 1;

                        l_terr_all_rec.TERR_ID                     := overlayterr.terr_group_account_id * -40 * l_role_counter;
                        l_terr_all_rec.LAST_UPDATE_DATE            := p_last_update_date(x);
                        l_terr_all_rec.LAST_UPDATED_BY             := p_last_updated_by(x);
                        l_terr_all_rec.CREATION_DATE               := p_creation_date(x);
                        l_terr_all_rec.CREATED_BY                  := p_created_by(x);
                        l_terr_all_rec.LAST_UPDATE_LOGIN           := p_last_update_login(x);
                        l_terr_all_rec.APPLICATION_SHORT_NAME      := G_APP_SHORT_NAME;
                        l_terr_all_rec.NAME                        := overlayterr.name || ' ' || pit.role_name || ' (OVERLAY)';
                        l_terr_all_rec.start_date_active           := p_active_from_date(x);
                        l_terr_all_rec.end_date_active             := p_active_to_date(x);
                        l_terr_all_rec.PARENT_TERRITORY_ID         := l_overlay;
                        l_terr_all_rec.RANK                        := p_rank(x)+10;
                        l_terr_all_rec.TEMPLATE_TERRITORY_ID       := NULL;
                        l_terr_all_rec.TEMPLATE_FLAG               := 'N';
                        l_terr_all_rec.ESCALATION_TERRITORY_ID     := NULL;
                        l_terr_all_rec.ESCALATION_TERRITORY_FLAG   := 'N';
                        l_terr_all_rec.OVERLAP_ALLOWED_FLAG        := NULL;
                        l_terr_all_rec.DESCRIPTION                 := pit.role_code||' '||overlayterr.name||' (OVERLAY)';
                        l_terr_all_rec.UPDATE_FLAG                 := 'N';
                        l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG  := NULL;
                        l_terr_all_rec.ORG_ID                      := p_org_id(x);
                        l_terr_all_rec.NUM_WINNERS                 := NULL ;
                        l_terr_all_rec.attribute_category          := p_terr_attr_cat(x);
                        l_terr_all_rec.attribute1                  := p_terr_attribute1(x);
                        l_terr_all_rec.attribute2                  := p_terr_attribute2(x);
                        l_terr_all_rec.attribute3                  := p_terr_attribute3(x);
                        l_terr_all_rec.attribute4                  := p_terr_attribute4(x);
                        l_terr_all_rec.attribute5                  := p_terr_attribute5(x);
                        l_terr_all_rec.attribute6                  := p_terr_attribute6(x);
                        l_terr_all_rec.attribute7                  := p_terr_attribute7(x);
                        l_terr_all_rec.attribute8                  := p_terr_attribute8(x);
                        l_terr_all_rec.attribute9                  := p_terr_attribute9(x);
                        l_terr_all_rec.attribute10                 := p_terr_attribute10(x);
                        l_terr_all_rec.attribute11                 := p_terr_attribute11(x);
                        l_terr_all_rec.attribute12                 := p_terr_attribute12(x);
                        l_terr_all_rec.attribute13                 := p_terr_attribute13(x);
                        l_terr_all_rec.attribute14                 := p_terr_attribute14(x);
                        l_terr_all_rec.attribute15                 := p_terr_attribute15(x);

                        SELECT   JTF_TERR_USGS_S.NEXTVAL
                        INTO l_terr_usg_id
                        FROM DUAL;

                        l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                        l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                        l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                        l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                        l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                        l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                        l_terr_usgs_tbl(1).TERR_ID           := NULL;
                        l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
                        l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                        i := 0;
                        K:= 0;
                        FOR acc_type IN role_access(p_terr_group_id(x),pit.role_code) LOOP
                            --i:=i+1;
                            --dbms_output.put_line('acc type  '||acc_type.access_type);
                            IF acc_type.access_type= 'OPPORTUNITY' THEN
                                i:=i+1;
                                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                INTO l_terr_qtype_usg_id
                                FROM DUAL;

                                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1003;
                                l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                SELECT JTF_TERR_QUAL_S.NEXTVAL
                                INTO l_terr_qual_id
                                FROM DUAL;

                                /* opp expected purchase */
                                l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                l_terr_qual_tbl(i).TERR_ID              := NULL;
                                l_terr_qual_tbl(i).QUAL_USG_ID          := g_opp_qual_usg_id;
                                l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP
                                    k:=k+1;

                                    l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                    l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                    l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                    l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                    l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                    l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                    l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                    l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                    l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                    l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                    l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                    l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                    l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                    l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                    l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                    IF (g_prod_cat_enabled) THEN
                                      l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                      l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                    ELSE
                                      l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                    END IF;

                                END LOOP;

                            ELSIF acc_type.access_type= 'LEAD' THEN

                                i:=i+1;
                                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                INTO l_terr_qtype_usg_id
                                FROM DUAL;

                                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1002;
                                l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                SELECT   JTF_TERR_QUAL_S.NEXTVAL
                                INTO l_terr_qual_id
                                FROM DUAL;

                                /* lead expected purchase */
                                l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                l_terr_qual_tbl(i).TERR_ID              := NULL;
                                l_terr_qual_tbl(i).QUAL_USG_ID          := g_lead_qual_usg_id;
                                l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                                    k:=k+1;
                                    l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                    l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                    l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                    l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                    l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                    l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                    l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                    l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                    l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                    l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                    l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                    l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                    l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                    l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                    l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                    IF (g_prod_cat_enabled) THEN
                                      l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                      l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                    ELSE
                                      l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                    END IF;

                                END LOOP;

                            ELSE
                                IF G_DEBUG THEN
                                    write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_id(x));
                                END IF;
                                --l_terr_qualtypeusgs_tbl(1).ORG_ID:=p_ORG_ID(x);
                            END IF;

                        END LOOP;

                        l_init_msg_list :=FND_API.G_TRUE;

                        JTF_TERRITORY_PVT.create_territory (
                            p_api_version_number         => l_api_version_number,
                            p_init_msg_list              => l_init_msg_list,
                            p_commit                     => l_commit,
                            p_validation_level           => FND_API.g_valid_level_NONE,
                            x_return_status              => x_return_status,
                            x_msg_count                  => x_msg_count,
                            x_msg_data                   => x_msg_data,
                            p_terr_all_rec               => l_terr_all_rec,
                            p_terr_usgs_tbl              => l_terr_usgs_tbl,
                            p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                            p_terr_qual_tbl              => l_terr_qual_tbl,
                            p_terr_values_tbl            => l_terr_values_tbl,
                            x_terr_id                    => x_terr_id,
                            x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                            x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                            x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                            x_terr_values_out_tbl        => x_terr_values_out_tbl

                        );

                        IF (x_return_status = 'S') THEN

                            -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                            -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                            UPDATE JTF_TERR_ALL
                            SET TERR_GROUP_FLAG = 'Y'
                              , TERR_GROUP_ID = p_TERR_GROUP_ID(x)
                              , NAMED_ACCOUNT_FLAG = 'Y'
                              , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                            WHERE terr_id = x_terr_id;

                            IF G_Debug THEN
                                write_log(2,' OVERLAY CNR territory created:' || l_terr_all_rec.NAME);
                            END IF;

                        ELSE
                            x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                            IF G_Debug THEN
                                write_log(2,x_msg_data);
                                write_log(2,'Failed in OVERLAY CNR territory treation for ' || 'TERR_GROUP_ACCOUNT_ID = ' ||
                                            overlayterr.terr_group_account_id );
                            END IF;

                        END IF; /* IF (x_return_status = 'S') */

                        --dbms_output.put_line('pit.role '||pit.role_code);
                        i:=0;

                        /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                        FOR rsc IN resource_grp( overlayterr.terr_group_account_id , pit.role_code) LOOP

                            i:=i+1;

                            SELECT   JTF_TERR_RSC_S.NEXTVAL
                            INTO l_terr_rsc_id
                            FROM DUAL;

                            l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                            l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                            l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                            l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                            l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                            l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                            l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                            l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                            l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                            l_TerrRsc_Tbl(i).ROLE                 := pit.role_code;
                            l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
                            l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                            l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                            l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                            l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                            l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                            l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                            l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                            l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                            l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                            l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                            l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                            l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                            l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                            l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                            l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                            l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                            l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                            l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                            l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                            l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                            l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;

                            a := 0;

                            FOR rsc_acc IN role_access(p_terr_group_id(x),pit.role_code) LOOP

                                IF rsc_acc.access_type= 'OPPORTUNITY' THEN

                                    a := a+1;

                                    SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                    INTO l_terr_rsc_access_id
                                    FROM DUAL;

                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                    l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                    l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                    l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                                    l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                    l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                                ELSIF rsc_acc.access_type= 'LEAD' THEN

                                    a := a+1;

                                    SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                    INTO l_terr_rsc_access_id
                                    FROM DUAL;

                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                    l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                    l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                    l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                                    l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                    l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                                END IF;
                            END LOOP; /* rsc_acc in role_access */

                            l_init_msg_list :=FND_API.G_TRUE;

                            -- 07/08/03: JDOCHERT: bug#3023653
                            Jtf_Territory_Resource_Pvt.create_terrresource (
                              p_api_version_number      => l_Api_Version_Number,
                              p_init_msg_list           => l_Init_Msg_List,
                              p_commit                  => l_Commit,
                              p_validation_level        => FND_API.g_valid_level_NONE,
                              x_return_status           => x_Return_Status,
                              x_msg_count               => x_Msg_Count,
                              x_msg_data                => x_msg_data,
                              p_terrrsc_tbl             => l_TerrRsc_tbl,
                              p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                              x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                              x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                            );

                            IF x_Return_Status='S' THEN
                                IF G_Debug THEN
                                    write_log(2,'Resource created for Product Interest OVERLAY Territory# '|| x_terr_id);
                                END IF;
                            ELSE
                                IF G_Debug THEN
                                    write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '|| x_terr_id);
                                END IF;
                            END IF;

                        END LOOP; /* rsc in resource_grp */

                    END LOOP;

                ELSE
                    x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                    IF G_Debug THEN
                        write_log(2,x_msg_data);
                        write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' || p_terr_group_id(x));
                    END IF;
                END IF;

            END LOOP;  /* for overlayterr in get_OVLY_party_name */
          END IF;    /* IF ( p_matching_rule_code(x) IN ('1', '2') ) THEN */
          /***************************************************************/
          /* (9) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
          /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
          /***************************************************************/

      END IF; /* l_pi_count*/

      IF G_Debug THEN
          write_log(2, '');
          write_log(2,'END: Territory Creation for Territory Group: ' || p_terr_group_id(x));
          write_log(2, '');
          write_log(2, '----------------------------------------------------------');
      END IF;

  END LOOP;
  /****************************************************
  ** (2) END: CREATE NAMED ACCOUNT TERRITORY CREATION
  ** FOR EACH TERRITORY GROUP
  *****************************************************/

EXCEPTION
  WHEN OTHERS THEN

      IF G_Debug THEN
          Write_Log(2, 'Error in procedure create_na_terr_for_TGA');
      END IF;
      IF (get_NON_OVLY_na_trans%ISOPEN) THEN
        CLOSE get_NON_OVLY_na_trans;
      END IF;
      IF (role_access%ISOPEN) THEN
        CLOSE role_access;
      END IF;
      IF (NON_OVLY_role_access%ISOPEN) THEN
        CLOSE NON_OVLY_role_access;
      END IF;
      IF (role_interest_nonpi%ISOPEN) THEN
        CLOSE role_interest_nonpi;
      END IF;
      IF (role_pi%ISOPEN) THEN
        CLOSE role_pi;
      END IF;
      IF (role_pi_interest%ISOPEN) THEN
        CLOSE role_pi_interest;
      END IF;
      IF (resource_grp%ISOPEN) THEN
        CLOSE resource_grp;
      END IF;
      IF (get_party_info%ISOPEN) THEN
        CLOSE get_party_info;
      END IF;
      IF (get_party_name%ISOPEN) THEN
        CLOSE get_party_name;
      END IF;
      IF (get_OVLY_party_info%ISOPEN) THEN
        CLOSE get_OVLY_party_info;
      END IF;
      IF (get_OVLY_party_name%ISOPEN) THEN
        CLOSE get_OVLY_party_name;
      END IF;
      IF (match_rule1%ISOPEN) THEN
        CLOSE match_rule1;
      END IF;
      IF (match_rule3%ISOPEN) THEN
        CLOSE match_rule3;
      END IF;
      IF (na_access%ISOPEN) THEN
        CLOSE na_access;
      END IF;
      IF (catchall_cust%ISOPEN) THEN
        CLOSE catchall_cust;
      END IF;
      IF (role_no_pi%ISOPEN) THEN
        CLOSE role_no_pi;
      END IF;

      RAISE;
END create_na_terr_for_TGA;

/*----------------------------------------------------------
This procedure will create Named account and Overlay Territory
from the Named accounts.
****
----------------------------------------------------------*/

PROCEDURE create_na_terr_for_TG(p_terr_group_id           IN g_terr_group_id_tab
                               ,p_terr_group_name         IN g_terr_group_name_tab
                               ,p_rank                    IN g_rank_tab
                               ,p_active_from_date        IN g_active_from_date_tab
                               ,p_active_to_date          IN g_active_to_date_tab
                               ,p_parent_terr_id          IN g_parent_terr_id_tab
                               ,p_matching_rule_code      IN g_matching_rule_code_tab
                               ,p_created_by              IN g_created_by_tab
                               ,p_creation_date           IN g_creation_date_tab
                               ,p_last_updated_by         IN g_last_updated_by_tab
                               ,p_last_update_date        IN g_last_update_date_tab
                               ,p_last_update_login       IN g_last_update_login_tab
                               ,p_catch_all_resource_id   IN g_catch_all_resource_id_tab
                               ,p_catch_all_resource_type IN g_catch_all_resource_type_tab
                               ,p_generate_catchall_flag  IN g_generate_catchall_flag_tab
                               ,p_num_winners             IN g_num_winners_tab
                               ,p_org_id                  IN g_org_id_tab
                               ,p_change_type             IN g_change_type_tab
                               ,p_terr_type_id            IN VARCHAR2
			                   ,p_terr_id                 IN VARCHAR2
			                   ,p_terr_creation_flag      IN VARCHAR2
					           )
IS

    TYPE role_typ IS RECORD(
    grp_role_id NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE grp_role_tbl_type IS TABLE OF role_typ
    INDEX BY BINARY_INTEGER;

    l_overnon_role_tbl          grp_role_tbl_type;
    l_overnon_role_empty_tbl    grp_role_tbl_type;
    l_terr_id			VARCHAR2(30);
    l_terr_qual_id              NUMBER;
    l_id_used_flag              VARCHAR2(1);
    l_terr_usg_id               NUMBER;
    l_terr_qtype_usg_id         NUMBER;
    l_qual_type_usg_id          NUMBER;
    l_qual_type                 VARCHAR2(20);
    l_terr_rsc_id               NUMBER;
    l_terr_rsc_access_id        NUMBER;
    l_api_version_number        CONSTANT NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(1);
    l_commit                    VARCHAR2(1);
    l_pi_count                  NUMBER := 0;
    l_prev_qual_usg_id          NUMBER;
    l_na_catchall_flag          VARCHAR2(1);
    l_overlap_catchall_flag     VARCHAR2(1);
    l_role_counter              NUMBER := 0;
    l_overlay_top               NUMBER;
    l_overlay                   NUMBER;
    l_nacat                     NUMBER;
    l_id                        NUMBER;
    l_ovnon_flag                VARCHAR2(1):='N';
    l_na_count                  NUMBER;
    l_terr_exists               NUMBER;

    x_return_status             VARCHAR2(1);
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(2000);
    x_terr_id                   NUMBER;

    i  NUMBER;
    j  NUMBER;
    k  NUMBER;
    l  NUMBER;
    a  NUMBER;

    l_terr_all_rec                JTF_TERRITORY_PVT.terr_all_rec_type;
    l_terr_usgs_tbl               JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_tbl               JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl             JTF_TERRITORY_PVT.terr_values_tbl_type;

    l_terr_usgs_empty_tbl         JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_empty_tbl JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_empty_tbl         JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_empty_tbl       JTF_TERRITORY_PVT.terr_values_tbl_type;

    x_terr_usgs_out_tbl           JTF_TERRITORY_PVT.terr_usgs_out_tbl_type;
    x_terr_qualtypeusgs_out_tbl   JTF_TERRITORY_PVT.terr_qualtypeusgs_out_tbl_type;
    x_terr_qual_out_tbl           JTF_TERRITORY_PVT.terr_qual_out_tbl_type;
    x_terr_values_out_tbl         JTF_TERRITORY_PVT.terr_values_out_tbl_type;

    l_TerrRsc_Tbl                 Jtf_Territory_Resource_Pvt.TerrResource_tbl_type_wflex;
    l_TerrRsc_Access_Tbl          Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    l_TerrRsc_empty_Tbl           Jtf_Territory_Resource_Pvt.TerrResource_tbl_type_wflex;
    l_TerrRsc_Access_empty_Tbl    Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    x_TerrRsc_Out_Tbl             Jtf_Territory_Resource_Pvt.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      Jtf_Territory_Resource_Pvt.TerrRsc_Access_out_tbl_type;


    /* JDOCHERT: /05/29/03:
    ** Transaction Types for a NON-OVERLAY territory are
    ** determined by all salesteam members on this Named Account
    ** having Roles without Product Interests defined
    ** so there is no Overlay Territories to assign
    ** Leads and Opportunities. If all Roles have Product Interests
    ** then only ACCOUNT transaction type should
    ** be used in Non-Overlay Named Account definition
    */
    CURSOR get_NON_OVLY_na_trans(LP_terr_group_account_id NUMBER) IS
       SELECT ra.access_type
       FROM
         jtf_tty_named_acct_rsc nar
       , jtf_tty_terr_grp_accts tga
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE tga.terr_group_account_id = nar.terr_group_account_id
       AND nar.terr_group_account_id = LP_terr_group_account_id
       AND tga.terr_group_id = tgr.terr_group_id
       AND nar.rsc_role_code = tgr.role_code
       AND ra.terr_group_role_id = tgr.terr_group_role_id
       AND ra.access_type IN ('ACCOUNT')
       UNION
       SELECT ra.access_type
       FROM
         jtf_tty_named_acct_rsc nar
       , jtf_tty_terr_grp_accts tga
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE tga.terr_group_account_id = nar.terr_group_account_id
       AND nar.terr_group_account_id = LP_terr_group_account_id
       AND tga.terr_group_id = tgr.terr_group_id
       AND nar.rsc_role_code = tgr.role_code
       AND ra.terr_group_role_id = tgr.terr_group_role_id
       AND NOT EXISTS (
            SELECT NULL
            FROM jtf_tty_role_prod_int rpi
            WHERE rpi.terr_group_role_id = tgr.terr_group_role_id );


    /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id
      AND b.role_code          = l_role
    ORDER BY a.access_type  ;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR NON_OVLY_role_access( lp_terr_group_id NUMBER
                               , lp_role VARCHAR2) IS
    SELECT DISTINCT a.access_type, a.trans_access_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND b.role_code          = lp_role
    AND NOT EXISTS (
       /* Product Interest does not exist for this role */
       SELECT NULL
       FROM jtf_tty_role_prod_int rpi
       WHERE rpi.terr_group_role_id = B.TERR_GROUP_ROLE_ID )
    ORDER BY a.access_type  ;

    /* Roles WITHOUT a Product Iterest defined */
    CURSOR role_interest_nonpi(l_terr_group_id NUMBER) IS
    SELECT  b.role_code role_code
            --,a.interest_type_id
           ,b.terr_group_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id(+) = b.terr_group_role_id
      AND b.terr_group_id         = l_terr_group_id
      AND a.terr_group_role_id IS  NULL
    ORDER BY b.role_code;

    /* Roles WITH a Product Iterest defined */
    CURSOR role_pi( lp_terr_group_id         NUMBER
                  , lp_terr_group_account_id NUMBER) IS
    SELECT DISTINCT
       b.role_code role_code
     , r.role_name role_name
    FROM jtf_rs_roles_vl r
       , jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE r.role_code = b.role_code
    AND a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = lp_terr_group_id
    AND EXISTS (
         /* Named Account exists with Salesperson with this role */
         SELECT NULL
         FROM jtf_tty_named_acct_rsc nar, jtf_tty_terr_grp_accts tga
         WHERE tga.terr_group_account_id = nar.terr_group_account_id
         AND nar.terr_group_account_id = lp_terr_group_account_id
         AND tga.terr_group_id = b.terr_group_id
         AND nar.rsc_role_code = b.role_code );

    /* Product Interest for a Role */
    CURSOR role_pi_interest(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT  a.interest_type_id
           ,a.product_category_id
           ,a.product_category_set_id
    FROM jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id
      AND b.role_code          = l_role;

    CURSOR resource_grp(l_terr_group_acct_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT b.resource_id
         , b.rsc_group_id
         , b.rsc_resource_type
         , b.start_date
         , b.end_date
         , to_char(null) attribute_category
         , b.attribute1  attribute1
         , b.attribute2  attribute2
         , b.attribute3  attribute3
         , b.attribute4  attribute4
         , b.attribute5  attribute5
         , to_char(null) attribute6
         , to_char(null) attribute7
         , to_char(null) attribute8
         , to_char(null) attribute9
         , to_char(null) attribute10
         , to_char(null) attribute11
         , to_char(null) attribute12
         , to_char(null) attribute13
         , to_char(null) attribute14
         , to_char(null) attribute15
    FROM jtf_tty_terr_grp_accts a
       , jtf_tty_named_acct_rsc b
    WHERE a.terr_group_account_id = l_terr_group_acct_id
    AND a.terr_group_account_id = b.terr_group_account_id
    AND b.rsc_role_code = l_role;

    /* used for NAMED ACCOUNT territory creation for duns# and party# qualifier */
    CURSOR get_party_info(LP_terr_group_id NUMBER, l_matching_rule_code VARCHAR2) IS
    SELECT SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , c.start_date
         , c.end_date
         , to_char(null) attribute_category
         , c.attribute1
         , c.attribute2
         , c.attribute3
         , c.attribute4
         , c.attribute5
         , c.attribute6
         , c.attribute7
         , c.attribute8
         , c.attribute9
         , c.attribute10
         , c.attribute11
         , c.attribute12
         , c.attribute13
         , c.attribute14
         , c.attribute15
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_id = LP_terr_group_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    -- AND (a.DUNS_NUMBER_C IS NOT NULL OR l_matching_rule_code = '4')
    AND EXISTS (
        /* Salesperson exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_named_acct_rsc nar
        WHERE nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* get the PARTY_NAME + POSTAL_CODE for the Named Account:
    ** used for NAMED ACCOUNT territory creation */
    CURSOR get_party_name(LP_terr_group_id NUMBER) IS
    SELECT /*+ index(b JTF_TTY_NAMED_ACCTS_U1) */ SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , a.duns_number_c
         , c.start_date
         , c.end_date
         , to_char(null) attribute_category
         , c.attribute1
         , c.attribute2
         , c.attribute3
         , c.attribute4
         , c.attribute5
         , c.attribute6
         , c.attribute7
         , c.attribute8
         , c.attribute9
         , c.attribute10
         , c.attribute11
         , c.attribute12
         , c.attribute13
         , c.attribute14
         , c.attribute15
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_id = LP_terr_group_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    AND EXISTS (
         /* Named Account has at least 1 Mapping Rule */
         SELECT 1
         FROM jtf_tty_acct_qual_maps d
         WHERE d.named_account_id = c.named_account_id )
    AND EXISTS (
         /* Salesperson exists for this Named Account */
         SELECT NULL
         FROM jtf_tty_named_acct_rsc nar
         WHERE nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* used for OVERLAY territory creation for DUNS# and Party Number qualifier */
    CURSOR get_OVLY_party_info(LP_terr_group_id NUMBER, l_matching_rule_code VARCHAR2) IS
    SELECT SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , to_char(null) attribute_category
         , c.attribute1
         , c.attribute2
         , c.attribute3
         , c.attribute4
         , c.attribute5
         , c.attribute6
         , c.attribute7
         , c.attribute8
         , c.attribute9
         , c.attribute10
         , c.attribute11
         , c.attribute12
         , c.attribute13
         , c.attribute14
         , c.attribute15
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_id = LP_terr_group_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    AND (a.DUNS_NUMBER_C IS NOT NULL OR l_matching_rule_code = '4')
    AND EXISTS (
        /* Salesperson, with Role that has a Product
        ** Interest defined, exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_named_acct_rsc nar
           , jtf_tty_role_prod_int rpi
           , jtf_tty_terr_grp_roles tgr
        WHERE rpi.terr_group_role_id = tgr.terr_group_role_id
        AND tgr.terr_group_id = C.TERR_GROUP_ID
        AND tgr.role_code = nar.rsc_role_code
        AND nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* get the PARTY_NAME + POSTAL_CODE for the Named Account
    ** used for OVERLAY territory creation */
    CURSOR get_OVLY_party_name(LP_terr_group_id NUMBER) IS
    SELECT SUBSTR(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
         , a.duns_number_c
         , to_char(null) attribute_category
         , c.attribute1
         , c.attribute2
         , c.attribute3
         , c.attribute4
         , c.attribute5
         , c.attribute6
         , c.attribute7
         , c.attribute8
         , c.attribute9
         , c.attribute10
         , c.attribute11
         , c.attribute12
         , c.attribute13
         , c.attribute14
         , c.attribute15
    FROM hz_parties a
       , jtf_tty_named_accts b
       , jtf_tty_terr_grp_accts c
    WHERE c.terr_group_id = LP_terr_group_id
    AND b.named_account_id = c.named_account_id
    AND a.party_id = b.party_id
    AND a.status = 'A'
    AND EXISTS (
         /* Named Account has at least 1 Mapping Rule */
         SELECT 1
         FROM jtf_tty_acct_qual_maps d
         WHERE d.named_account_id = c.named_account_id )
    AND EXISTS (
        /* Salesperson, with Role that has a Product
        ** Interest defined, exists for this Named Account */
        SELECT NULL
        FROM jtf_tty_named_acct_rsc nar
           , jtf_tty_role_prod_int rpi
           , jtf_tty_terr_grp_roles tgr
        WHERE rpi.terr_group_role_id = tgr.terr_group_role_id
        AND tgr.terr_group_id = C.TERR_GROUP_ID
        AND tgr.role_code = nar.rsc_role_code
        AND nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );

    /* get Customer Keynames and Postal Code mappings
    ** for the Named Account  */
    /* bug#2925153: JRADHAKR: Added value2_char */
    CURSOR match_rule1( l_na_id NUMBER) IS
    SELECT b.qual_usg_id
         , b.comparison_operator
         , b.value1_char
         , b.value2_char
    FROM jtf_tty_acct_qual_maps b
    WHERE b.qual_usg_id IN (-1007, -1012)
    AND b.named_account_id = l_na_id
    ORDER BY b.qual_usg_id;

    /* get DUNS# for the Named Account  */
    /* bug#2933116: JDOCHERT: 05/27/03: support for DUNS# Qualifier */
    /* get party number for the Named Account  */
    /* bug#3426946: ACHANDA: 03/04/04: support for party number Qualifier */
    /* JRADHAKR: Added support for Party site id and hierarchy */
    CURSOR match_rule3(l_na_id NUMBER, l_matching_rule_code VARCHAR2) IS
    SELECT DECODE(l_matching_rule_code, '4', -1129, '2', -1120, '3', -1120, '5',-1005, -1001) qual_usg_id
         , '=' comparison_operator
         , DECODE(l_matching_rule_code, '4', hzp.party_number, '2', hzp.duns_number_c, '3', hzp.duns_number_c) value1_char
         , DECODE(l_matching_rule_code, '5', na.party_site_id, hzp.party_id) value1_num
    FROM hz_parties hzp, jtf_tty_named_accts na
    WHERE hzp.status = 'A'
    AND hzp.party_id = na.party_id
    AND na.named_account_id = l_na_id;


    /* Access Types for a Territory Group */
    CURSOR na_access(l_terr_group_id NUMBER) IS
    SELECT DISTINCT a.access_type
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id;

    /* Named Account Catch-All Customer Keyname values */
    CURSOR catchall_cust(l_terr_group_id NUMBER) IS
    SELECT DISTINCT b.comparison_operator
          ,b.value1_char
    FROM jtf_tty_terr_grp_accts a
       , jtf_tty_acct_qual_maps b
    WHERE a.named_account_id = b.named_account_id
      AND a.terr_group_id    = l_terr_group_id
      AND b.qual_usg_id      = -1012
    ORDER BY b.comparison_operator,b.value1_char;

    /* Get Top-Level Parent Territory details */
    CURSOR topterr(l_terr NUMBER) IS
    SELECT name
         , description
         , rank
         , parent_territory_id
         , terr_id
    FROM jtf_terr_all
    WHERE terr_id = l_terr;

    /* get Qualifiers used in a territory */
    CURSOR csr_get_qual( lp_terr_id NUMBER) IS
    SELECT jtq.terr_qual_id
           , jtq.qual_usg_id
    FROM jtf_terr_qual_all jtq
    WHERE jtq.terr_id = lp_terr_id;

    /* get Values used in a territory qualifier */
    CURSOR csr_get_qual_val ( lp_terr_qual_id NUMBER ) IS
    SELECT jtv.TERR_VALUE_ID
         , jtv.INCLUDE_FLAG
         , jtv.COMPARISON_OPERATOR
         , jtv.LOW_VALUE_CHAR
         , jtv.HIGH_VALUE_CHAR
         , jtv.LOW_VALUE_NUMBER
         , jtv.HIGH_VALUE_NUMBER
         , jtv.VALUE_SET
         , jtv.INTEREST_TYPE_ID
         , jtv.PRIMARY_INTEREST_CODE_ID
         , jtv.SECONDARY_INTEREST_CODE_ID
         , jtv.CURRENCY_CODE
         , jtv.ORG_ID
         , jtv.ID_USED_FLAG
         , jtv.LOW_VALUE_CHAR_ID
    FROM jtf_terr_values_all jtv
    WHERE jtv.terr_qual_id = lp_terr_qual_id;

    /* get those roles for a territory Group that
    ** do not have Product Interest defined */
    CURSOR role_no_pi(l_terr_group_id NUMBER) IS
    SELECT DISTINCT b.role_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
       , jtf_tty_role_prod_int c
    WHERE a.terr_group_role_id = b.terr_group_role_id
    AND b.terr_group_id      = l_terr_group_id
    AND a.access_type        = 'ACCOUNT'
    AND c.terr_group_role_id = b.terr_group_role_id
    AND NOT EXISTS ( SELECT  1
                     FROM jtf_tty_role_prod_int e
                        , jtf_tty_terr_grp_roles d
                     WHERE e.terr_group_role_id (+) = d.terr_group_role_id
                     AND d.terr_group_id          = b.terr_group_id
                     AND d.role_code              = b.role_code
                     AND e.interest_type_id IS  NULL);

BEGIN

  /* (2) START: CREATE NAMED ACCOUNT TERRITORY CREATION
  ** FOR EACH TERRITORY GROUP */
  FOR x IN p_terr_group_id.FIRST .. p_terr_group_id.LAST LOOP
     -- if the territory group has been updated , delete it before recreating the corresponding territories
     IF (p_change_type(x) = 'UPDATE') THEN
            IF G_Debug THEN
              Write_Log(2, 'create_na_terr_for_TG : START: delete_TG');
            END IF;

            delete_TG(p_terr_group_id(x), p_terr_id ,p_terr_creation_flag );

            IF G_Debug THEN
              Write_Log(2, 'create_na_terr_for_TG : END: delete_TG');
              Write_Log(2, 'create_na_terr_for_TG : All the territories corresponding to the territory group ' || p_terr_group_id(x)
||
                              ' have been deleted successfully.');
            END IF;
     END IF;

     IF G_Debug THEN
       write_log(2, '');
       write_log(2, '----------------------------------------------------------');
       write_log(2, 'create_na_terr_for_TG : BEGIN: Territory Creation for Territory Group: ' ||
                                                 p_terr_group_id(x) || ' : ' || p_terr_group_name(x) );
     END IF;

     /* reset these processing values for the Territory Group */
     l_na_catchall_flag      := 'N';
     l_overlap_catchall_flag := 'N';
     l_ovnon_flag            := 'N';
     l_overnon_role_tbl      := l_overnon_role_empty_tbl;


     /** Roles with No Product Interest */
     i:=0;
     FOR overlayandnon IN role_no_pi(p_terr_group_id(x)) LOOP

        l_ovnon_flag := 'Y';
        i := i + 1;

        SELECT  JTF_TTY_TERR_GRP_ROLES_S.NEXTVAL
        INTO    l_id
        FROM    DUAL;

        l_overnon_role_tbl(i).grp_role_id:= l_id;

        INSERT INTO JTF_TTY_TERR_GRP_ROLES(
             TERR_GROUP_ROLE_ID
           , OBJECT_VERSION_NUMBER
           , TERR_GROUP_ID
           , ROLE_CODE
           , CREATED_BY
           , CREATION_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATE_LOGIN)
        VALUES(
                l_overnon_role_tbl(i).grp_role_id
              , 1
              , p_terr_group_id(x)
              , overlayandnon.role_code
              , G_USER_ID
              , SYSDATE
              , G_USER_ID
              , SYSDATE
              , G_LOGIN_ID);

        INSERT INTO JTF_TTY_ROLE_ACCESS(
               TERR_GROUP_ROLE_ACCESS_ID
             , OBJECT_VERSION_NUMBER
             , TERR_GROUP_ROLE_ID
             , ACCESS_TYPE
             , CREATED_BY
             , CREATION_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATE_LOGIN)
        VALUES(
                  JTF_TTY_ROLE_ACCESS_S.NEXTVAL
                , 1
                , l_overnon_role_tbl(i).grp_role_id
                , 'ACCOUNT'
                , G_USER_ID
                , SYSDATE
                , G_USER_ID
                , SYSDATE
                , G_LOGIN_ID);

      END LOOP; /* for overlayandnon in role_no_pi */


      /* does Territory Group have at least 1 Named Account? */
      /*SELECT COUNT(*)
      INTO   l_na_count
      FROM  jtf_tty_terr_groups g
          , jtf_tty_terr_grp_accts ga
          , jtf_tty_named_accts a
      WHERE g.terr_group_id   = ga.terr_group_id
      AND ga.named_account_id = a.named_account_id
      AND g.terr_group_id     = p_terr_group_id(x)
      AND ROWNUM < 2;*/

		  l_na_count :=0;


      /*********************************************************************/
      /*********************************************************************/
      /************** NON-OVERLAY TERRITORY CREATION ***********************/
      /*********************************************************************/
      /*********************************************************************/

      /* BEGIN: if Territory Group exists with Named Accounts then auto-create territory definitions */
      ---- R12: territory is always created no matter how many NA
      IF (l_na_count >= 0) THEN


          /***************************************************************/
          /* (3) START: CREATE PLACEHOLDER TERRITORY FOR TERRITORY GROUP */
          /***************************************************************/
          L_TERR_USGS_TBL         := L_TERR_USGS_EMPTY_TBL;
          L_TERR_QUALTYPEUSGS_TBL := L_TERR_QUALTYPEUSGS_EMPTY_TBL;
          L_TERR_QUAL_TBL         := L_TERR_QUAL_EMPTY_TBL;
          L_TERR_VALUES_TBL       := L_TERR_VALUES_EMPTY_TBL;
          L_TERRRSC_TBL           := L_TERRRSC_EMPTY_TBL;
          L_TERRRSC_ACCESS_TBL    := L_TERRRSC_ACCESS_EMPTY_TBL;

          /* TERRITORY HEADER */
		      L_TERR_ALL_REC.LAST_UPDATE_DATE           := p_last_update_date(x);
          L_TERR_ALL_REC.LAST_UPDATED_BY            := G_USER_ID;
          L_TERR_ALL_REC.CREATION_DATE              := p_creation_date(x);
          L_TERR_ALL_REC.CREATED_BY                 := G_USER_ID ;
          L_TERR_ALL_REC.LAST_UPDATE_LOGIN          := G_LOGIN_ID;
          L_TERR_ALL_REC.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
          L_TERR_ALL_REC.NAME                       := p_terr_group_name(x);
          L_TERR_ALL_REC.START_DATE_ACTIVE          := p_active_from_date(x);
          L_TERR_ALL_REC.END_DATE_ACTIVE            := p_active_to_date(x);
          L_TERR_ALL_REC.PARENT_TERRITORY_ID        := p_parent_terr_id(x);
          L_TERR_ALL_REC.RANK                       := p_rank(x);
          L_TERR_ALL_REC.TEMPLATE_TERRITORY_ID      := NULL;
          L_TERR_ALL_REC.TEMPLATE_FLAG              := 'N';
          L_TERR_ALL_REC.ESCALATION_TERRITORY_ID    := NULL;
          L_TERR_ALL_REC.ESCALATION_TERRITORY_FLAG  := 'N';
          L_TERR_ALL_REC.OVERLAP_ALLOWED_FLAG       := NULL;
          L_TERR_ALL_REC.DESCRIPTION                := p_terr_group_name(x);
          L_TERR_ALL_REC.UPDATE_FLAG                := 'N';
          L_TERR_ALL_REC.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
          L_TERR_ALL_REC.NUM_WINNERS                := NULL ;

          L_TERR_ALL_REC.TERRITORY_TYPE_ID          := p_terr_type_id;
          L_TERR_ALL_REC.TERR_CREATION_FLAG         := 'Y';
          L_TERR_ALL_REC.TERRITORY_GROUP_ID         := p_terr_group_id(x);
          L_TERR_ALL_REC.TERR_ID                    := NULL;
		  IF p_terr_id IS NOT NULL AND
			     p_terr_creation_flag IS NOT NULL THEN
             L_TERR_ALL_REC.TERR_ID := p_terr_id;
		  END IF;

          /* ORG_ID IS SET TO SAME VALUE AS TERRITORY GROUP's Top-Level Parent Territory */
          l_terr_all_rec.ORG_ID := p_org_id(x);

          /* ORACLE SALES AND TELESALES USAGE */
          SELECT JTF_TERR_USGS_S.NEXTVAL
          INTO   l_terr_usg_id
          FROM   DUAL;

          l_terr_usgs_tbl(1).SOURCE_ID        := -1001;
          l_terr_usgs_tbl(1).TERR_USG_ID      := l_terr_usg_id;
          l_terr_usgs_tbl(1).LAST_UPDATE_DATE := p_last_update_date(x);
          l_terr_usgs_tbl(1).LAST_UPDATED_BY  := G_USER_ID;
          l_terr_usgs_tbl(1).CREATION_DATE    := p_creation_date(x);
          l_terr_usgs_tbl(1).CREATED_BY       := G_USER_ID;
          l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:= G_LOGIN_ID;
          l_terr_usgs_tbl(1).TERR_ID          := L_TERR_ALL_REC.TERR_ID; --NULL;
          l_terr_usgs_tbl(1).ORG_ID           := p_org_id(x);

          i := 0;
          FOR actype IN na_access(p_terr_group_id(x))
          LOOP
               i := i+1;

               SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                 INTO l_terr_qtype_usg_id
                 FROM DUAL;

               IF ( actype.access_type = 'ACCOUNT' ) THEN
                  l_qual_type_usg_id := -1001;
               ELSIF ( actype.access_type = 'LEAD' ) THEN
                  l_qual_type_usg_id := -1002;
               ELSIF ( actype.access_type = 'OPPORTUNITY' ) THEN
                  l_qual_type_usg_id := -1003;
               ELSIF ( actype.access_type = 'QUOTE' ) THEN
                  l_qual_type_usg_id := -1105;
               ELSIF ( actype.access_type = 'PROPOSAL' ) THEN
                  l_qual_type_usg_id := -1106;
               END IF;


               l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
               l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
               l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
               l_terr_qualtypeusgs_tbl(i).TERR_ID               := L_TERR_ALL_REC.TERR_ID;
               l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := l_qual_type_usg_id;
               l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

          END LOOP;
          IF (na_access%ISOPEN) THEN
              CLOSE na_access;
          END IF;

          l_init_msg_list  := FND_API.G_TRUE;
             /* CALL CREATE TERRITORY API */
             JTF_TERRITORY_PVT.create_territory (
               p_api_version_number         => l_api_version_number,
               p_init_msg_list              => l_init_msg_list,
               p_commit                     => l_commit,
               p_validation_level           => FND_API.g_valid_level_NONE,
               x_return_status              => x_return_status,
               x_msg_count                  => x_msg_count,
               x_msg_data                   => x_msg_data,
               p_terr_all_rec               => l_terr_all_rec,
               p_terr_usgs_tbl              => l_terr_usgs_tbl,
               p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
               p_terr_qual_tbl              => l_terr_qual_tbl,
               p_terr_values_tbl            => l_terr_values_tbl,
               x_terr_id                    => x_terr_id,
               x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
               x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
               x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
               x_terr_values_out_tbl        => x_terr_values_out_tbl
              );

              /* BEGIN: SUCCESSFUL TERRITORY CREATION? */
              IF X_RETURN_STATUS = 'S'  THEN
                 /* JDOCHERT: 01/08/03: ADDED TERR_GROUP_ID */
                 UPDATE JTF_TERR_ALL
                 SET TERR_GROUP_FLAG = 'Y'
                   , CATCH_ALL_FLAG = 'N'
                   , TERR_GROUP_ID = p_terr_group_id(x)
                   , NUM_WINNERS = p_num_winners(x)
                 WHERE TERR_ID = X_TERR_ID;

                 L_NACAT := X_TERR_ID;

                 IF G_Debug THEN
                   WRITE_LOG(2,'create_na_terr_for_TG : Top level Named Account territory created: TERR_ID# '||X_TERR_ID);
                 END IF;

              ELSE
                 IF G_Debug THEN
                   WRITE_LOG(2,'ERROR: PLACEHOLDER TERRITORY CREATION FAILED ' ||
                       'FOR TERRITORY_GROUP_ID# ' ||p_terr_group_id(x));
                   X_MSG_DATA :=  FND_MSG_PUB.GET(1, FND_API.G_FALSE);
                   WRITE_LOG(2,X_MSG_DATA);
                 END IF;
              END IF;

          /*************************************************************/
          /* (3) END: CREATE PLACEHOLDER TERRITORY FOR TERRITORY GROUP */
          /*************************************************************/


          /****************************************************************/
          /* (4) START: CREATE NA CATCH-ALL TERRITORY FOR TERRITORY GROUP */
          /****************************************************************/


          IF ( p_matching_rule_code(x) IN ('1', '2') AND
                     p_generate_catchall_flag(x) = 'Y' ) THEN

             /* RESET TABLES */
             L_TERR_USGS_TBL         := L_TERR_USGS_EMPTY_TBL;
             L_TERR_QUALTYPEUSGS_TBL := L_TERR_QUALTYPEUSGS_EMPTY_TBL;
             L_TERR_QUAL_TBL         := L_TERR_QUAL_EMPTY_TBL;
             L_TERR_VALUES_TBL       := L_TERR_VALUES_EMPTY_TBL;
             L_TERRRSC_TBL           := L_TERRRSC_EMPTY_TBL;
             L_TERRRSC_ACCESS_TBL    := L_TERRRSC_ACCESS_EMPTY_TBL;


             /* TERRITORY HEADER */
             /* Ensure static TERR_ID to benefit TAP Performance */
             L_TERR_ALL_REC.TERR_ID                := p_terr_group_id(x) * -1;

             L_TERR_ALL_REC.LAST_UPDATE_DATE       := p_last_update_date(x);
             L_TERR_ALL_REC.LAST_UPDATED_BY        := G_USER_ID;
             L_TERR_ALL_REC.CREATION_DATE          := p_creation_date(x);
             L_TERR_ALL_REC.CREATED_BY             := G_USER_ID;
             L_TERR_ALL_REC.LAST_UPDATE_LOGIN      := G_LOGIN_ID;
             L_TERR_ALL_REC.APPLICATION_SHORT_NAME := G_APP_SHORT_NAME;
             L_TERR_ALL_REC.NAME                   := p_terr_group_name(x) ||' (CATCH-ALL)';
             L_TERR_ALL_REC.START_DATE_ACTIVE      := p_active_from_date(x) ;
             L_TERR_ALL_REC.END_DATE_ACTIVE        := p_active_to_date(x);
             L_TERR_ALL_REC.PARENT_TERRITORY_ID    := X_TERR_ID;
             L_TERR_ALL_REC.TERRITORY_TYPE_ID      := p_terr_type_id;
	     L_TERR_ALL_REC.TERR_CREATION_FLAG     := NULL;

             --
             -- 01/20/03: JDOCHERT: CHANGE RANK OF CATCH-ALL
             -- TO BE LESS THAT NAMED ACCOUNT TERRITORIES
             --
             L_TERR_ALL_REC.RANK := p_rank(x) + 100;
             --

             L_TERR_ALL_REC.TEMPLATE_TERRITORY_ID      := NULL;
             L_TERR_ALL_REC.TEMPLATE_FLAG              := 'N';
             L_TERR_ALL_REC.ESCALATION_TERRITORY_ID    := NULL;
             L_TERR_ALL_REC.ESCALATION_TERRITORY_FLAG  := 'N';
             L_TERR_ALL_REC.OVERLAP_ALLOWED_FLAG       := NULL;
             L_TERR_ALL_REC.DESCRIPTION                := p_terr_group_name(x) ||' (CATCH-ALL)';
             L_TERR_ALL_REC.UPDATE_FLAG                := 'N';
             L_TERR_ALL_REC.AUTO_ASSIGN_RESOURCES_FLAG := NULL;


             /* ORG_ID IS SET TO SAME VALUE AS TERRITORY
             ** GROUP's Top-Level Parent Territory */
             l_terr_all_rec.ORG_ID                     := p_org_id(x);
             l_terr_all_rec.NUM_WINNERS                := NULL ;

             /* Oracle Sales and Telesales Usage */
             SELECT   JTF_TERR_USGS_S.NEXTVAL
               INTO l_terr_usg_id
             FROM DUAL;

             l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
             l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
             l_terr_usgs_tbl(1).LAST_UPDATED_BY   := G_USER_ID;
             l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
             l_terr_usgs_tbl(1).CREATED_BY        := G_USER_ID;
             l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := G_LOGIN_ID;
             l_terr_usgs_tbl(1).TERR_ID           := NULL;
             l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
             l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

             i := 0;
             FOR actype IN na_access(p_terr_group_id(x))
             LOOP

               i:=i+1;

               SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                 INTO l_terr_qtype_usg_id
                 FROM DUAL;

               IF ( actype.access_type = 'ACCOUNT' ) THEN
                  l_qual_type_usg_id := -1001;
               ELSIF ( actype.access_type = 'LEAD' ) THEN
                  l_qual_type_usg_id := -1002;
               ELSIF ( actype.access_type = 'OPPORTUNITY' ) THEN
                  l_qual_type_usg_id := -1003;
               ELSIF ( actype.access_type = 'QUOTE' ) THEN
                  l_qual_type_usg_id := -1105;
               ELSIF ( actype.access_type = 'PROPOSAL' ) THEN
                  l_qual_type_usg_id := -1106;
               END IF;

               l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
               l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
               l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
               l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
               l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := l_qual_type_usg_id;
               l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

             END LOOP;

             /*
              ** Customer Name Range Qualifier -1012 */
             SELECT JTF_TERR_QUAL_S.NEXTVAL
             INTO l_terr_qual_id
             FROM DUAL;

             l_terr_qual_tbl(1).TERR_QUAL_ID          := l_terr_qual_id;
             l_terr_qual_tbl(1).LAST_UPDATE_DATE      := p_last_update_date(x);
             l_terr_qual_tbl(1).LAST_UPDATED_BY       := p_last_updated_by(x);
             l_terr_qual_tbl(1).CREATION_DATE         := p_creation_date(x);
             l_terr_qual_tbl(1).CREATED_BY            := p_created_by(x);
             l_terr_qual_tbl(1).LAST_UPDATE_LOGIN     := p_last_update_login(x);
             l_terr_qual_tbl(1).TERR_ID               := NULL;
             l_terr_qual_tbl(1).QUAL_USG_ID           := -1012;
             l_terr_qual_tbl(1).QUALIFIER_MODE        := NULL;
             l_terr_qual_tbl(1).OVERLAP_ALLOWED_FLAG  := 'N';
             l_terr_qual_tbl(1).USE_TO_NAME_FLAG      := NULL;
             l_terr_qual_tbl(1).GENERATE_FLAG         := NULL;
             l_terr_qual_tbl(1).ORG_ID                := p_org_id(x);
             l_id_used_flag                           := 'N' ;

             /*
              ** get all the Customer Name Range Values for all the Named Accounts
              ** that belong to this Territory Group */
             k:=0;
             FOR cust_value IN catchall_cust(p_terr_group_id(x)) LOOP

                 k:=k+1;

                 l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                 l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                 l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                 l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                 l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                 l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                 l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                 l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                 l_terr_values_tbl(k).COMPARISON_OPERATOR        := cust_value.comparison_operator;
                 l_terr_values_tbl(k).LOW_VALUE_CHAR             := cust_value.value1_char;
                 l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                 l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                 l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                 l_terr_values_tbl(k).VALUE_SET                  := NULL;
                 l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                 l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                 l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                 l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                 l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                 l_terr_values_tbl(k).ID_USED_FLAG               := l_id_used_flag;
                 l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                 l_terr_values_tbl(k).qualifier_tbl_index        := 1;

             END LOOP;

             l_init_msg_list := FND_API.G_TRUE;

             JTF_TERRITORY_PVT.create_territory (
               p_api_version_number         => l_api_version_number,
               p_init_msg_list              => l_init_msg_list,
               p_commit                     => l_commit,
               p_validation_level           => FND_API.g_valid_level_NONE,
               x_return_status              => x_return_status,
               x_msg_count                  => x_msg_count,
               x_msg_data                   => x_msg_data,
               p_terr_all_rec               => l_terr_all_rec,
               p_terr_usgs_tbl              => l_terr_usgs_tbl,
               p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
               p_terr_qual_tbl              => l_terr_qual_tbl,
               p_terr_values_tbl            => l_terr_values_tbl,
               x_terr_id                    => x_terr_id,
               x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
               x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
               x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
               x_terr_values_out_tbl        => x_terr_values_out_tbl

             );

             IF G_Debug THEN
               write_log(2,' NAMED ACCOUNT CATCH ALL TERRITORY CREATED: TERR_ID# '||x_terr_id);
             END IF;

             /* BEGIN: Successful Territory creation? */
             IF x_return_status = 'S' THEN

                /* JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG */
                UPDATE JTF_TERR_ALL
                SET TERR_GROUP_FLAG = 'Y'
                  , TERR_GROUP_ID = p_terr_group_id(x)
                  , CATCH_ALL_FLAG = 'Y'
                WHERE terr_id = x_terr_id;

                l_init_msg_list :=FND_API.G_TRUE;

             /* The resources for catch ALL territory will be created through a seperate
                procedure call in UI : JTF_TTY_GEN_TERR_PVT.create_catchall_terr_rsc.

                SELECT   JTF_TERR_RSC_S.NEXTVAL
                INTO l_terr_rsc_id
                FROM DUAL;

                l_TerrRsc_Tbl(1).terr_id              := x_terr_id;
                l_TerrRsc_Tbl(1).TERR_RSC_ID          := l_terr_rsc_id;
                l_TerrRsc_Tbl(1).LAST_UPDATE_DATE     := p_last_update_date(x);
                l_TerrRsc_Tbl(1).LAST_UPDATED_BY      := p_last_updated_by(x);
                l_TerrRsc_Tbl(1).CREATION_DATE        := p_creation_date(x);
                l_TerrRsc_Tbl(1).CREATED_BY           := p_created_by(x);
                l_TerrRsc_Tbl(1).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                l_TerrRsc_Tbl(1).RESOURCE_ID          := p_catch_all_resource_id(x);
                l_TerrRsc_Tbl(1).RESOURCE_TYPE        := p_catch_all_resource_type(x);
                l_TerrRsc_Tbl(1).ROLE                 := 'SALES_ADMIN';
                l_TerrRsc_Tbl(1).PRIMARY_CONTACT_FLAG := 'N';
                l_TerrRsc_Tbl(1).START_DATE_ACTIVE    := p_active_from_date(x);
                l_TerrRsc_Tbl(1).END_DATE_ACTIVE      := p_active_to_date(x);
                l_TerrRsc_Tbl(1).ORG_ID               := p_org_id(x);
                l_TerrRsc_Tbl(1).FULL_ACCESS_FLAG     := 'Y';
                l_TerrRsc_Tbl(1).GROUP_ID             := -999;

                a:=0;
                FOR rsc_acc IN na_access(p_terr_group_id(x)) LOOP

                   a := a+1;

                   IF rsc_acc.access_type= 'ACCOUNT' THEN

                       SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                       INTO l_terr_rsc_access_id
                       FROM DUAL;

                       l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                       l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                       l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                       l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                       l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'ACCOUNT';
                       l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                       l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := 1;

                   ELSIF rsc_acc.access_type= 'OPPORTUNITY' THEN

                       SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                       INTO l_terr_rsc_access_id
                       FROM DUAL;

                       l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                       l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                       l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                       l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                       l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                       l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                       l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := 1;

                   ELSIF rsc_acc.access_type= 'LEAD' THEN

                       SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                       INTO l_terr_rsc_access_id
                       FROM DUAL;

                       l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                       l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                       l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                       l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                       l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                       l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                       l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := 1;

                   END IF;
                END LOOP;

                l_init_msg_list := FND_API.G_TRUE;

                Jtf_Territory_Resource_Pvt.create_terrresource (
                   p_api_version_number      => l_Api_Version_Number,
                   p_init_msg_list           => l_Init_Msg_List,
                   p_commit                  => l_Commit,
                   p_validation_level        => FND_API.g_valid_level_NONE,
                   x_return_status           => x_Return_Status,
                   x_msg_count               => x_Msg_Count,
                   x_msg_data                => x_msg_data,
                   p_terrrsc_tbl             => l_TerrRsc_tbl,
                   p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                   x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                   x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                );

                IF x_Return_Status='S' THEN
                     IF G_Debug THEN
                       write_log( 2,'     RESOURCE CREATED FOR NAMED ACCOUNT CATCH ALL TERRITORY ' || x_terr_id);
                     END IF;
                ELSE
                     IF G_Debug THEN
                         write_log( 2,'     FAILED IN RESOURCE CREATION FOR NAMED ACCOUNT CATCH ALL TERRITORY' || x_terr_id);
                         x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                         write_log(2, x_msg_data);
                     END IF;
                END IF;

             */

             /* else of -if the catch all territory creation failed */
             ELSE
                  x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                  IF G_Debug THEN
                      write_log(2,x_msg_data);
                      WRITE_LOG(2,'ERROR: NA CATCH-ALL TERRITORY CREATION FAILED ' || 'FOR TERRITORY_GROUP_ID# '
||p_terr_group_id(x));
                  END IF;
             END IF;

          END IF; /* ( p_matching_rule_code(x) IN ('1', '2') AND p_generate_catchall_flag(x) = 'Y' ) THEN */

          /**************************************************************/
          /* (4) END: CREATE NA CATCH-ALL TERRITORY FOR TERRITORY GROUP */
          /**************************************************************/


         /***************************************************************/
         /* (5) START: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING DUNS# , PARTY# PARTY_SITE_ID, ACOUNT HIERARCHY QULIFIER                        */
         /***************************************************************/

         IF ( p_matching_rule_code(x)  NOT IN ('1')) THEN       --  IN ('2', '3', '4') ) THEN

           /* if matching rule code is 2 or 3 create territories for duns qualifier else for party number qualifier */
           FOR naterr IN get_party_info(p_terr_group_id(x), p_matching_rule_code(x)) LOOP

               l_terr_usgs_tbl          := l_terr_usgs_empty_tbl;
               l_terr_qualtypeusgs_tbl  := l_terr_qualtypeusgs_empty_tbl;
               l_terr_qual_tbl          := l_terr_qual_empty_tbl;
               l_terr_values_tbl        := l_terr_values_empty_tbl;
               l_TerrRsc_Tbl            := l_TerrRsc_empty_Tbl;
               l_TerrRsc_Access_Tbl     := l_TerrRsc_Access_empty_Tbl;

               /* TERRITORY HEADER */
               /* Ensure static TERR_ID to benefit TAP Performance */
               BEGIN

                   l_terr_exists := 0;

                   SELECT COUNT(*)
                   INTO l_terr_exists
                   FROM jtf_terr_all jt
                   WHERE jt.terr_id = naterr.terr_group_account_id * -100;

                   IF (l_terr_exists = 0) THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -100;
                   ELSE
                       l_terr_all_rec.TERR_ID := NULL;
                   END IF;

               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -100;
               END;

               l_terr_all_rec.LAST_UPDATE_DATE             := p_last_update_date(x);
               l_terr_all_rec.LAST_UPDATED_BY              := p_last_updated_by(x);
               l_terr_all_rec.CREATION_DATE                := p_creation_date(x);
               l_terr_all_rec.CREATED_BY                   := p_created_by(x);
               l_terr_all_rec.LAST_UPDATE_LOGIN            := p_last_update_login(x);
               l_terr_all_rec.APPLICATION_SHORT_NAME       := G_APP_SHORT_NAME;

               IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                 l_terr_all_rec.NAME                         := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('4')) THEN
                 l_terr_all_rec.NAME                         := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('5')) THEN
                 l_terr_all_rec.NAME                         := naterr.name ;
               ELSE
                 l_terr_all_rec.NAME                         := naterr.name ;
               END IF;


               IF naterr.start_date IS NULL THEN
                   l_terr_all_rec.start_date_active          := p_active_from_date(x);
               ELSE
                   l_terr_all_rec.start_date_active          := naterr.start_date;
               END IF;

               IF naterr.end_date IS NULL THEN
                   l_terr_all_rec.end_date_active            := p_active_to_date(x);
               ELSE
                   l_terr_all_rec.end_date_active            := naterr.end_date;
               END IF;

               l_terr_all_rec.PARENT_TERRITORY_ID          := l_nacat;
               l_terr_all_rec.RANK                         := p_rank(x) + 10;
               l_terr_all_rec.TEMPLATE_TERRITORY_ID        := NULL;
               l_terr_all_rec.TEMPLATE_FLAG                := 'N';
               l_terr_all_rec.ESCALATION_TERRITORY_ID      := NULL;
               l_terr_all_rec.ESCALATION_TERRITORY_FLAG    := 'N';
               l_terr_all_rec.OVERLAP_ALLOWED_FLAG         := NULL;

               IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                 l_terr_all_rec.DESCRIPTION                  := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('4')) THEN
                 l_terr_all_rec.DESCRIPTION                  := naterr.name ;
               ELSIF ( p_matching_rule_code(x) IN ('5')) THEN
                 l_terr_all_rec.DESCRIPTION                  := naterr.name ;
               ELSE
                 l_terr_all_rec.DESCRIPTION                  := naterr.name ;
               END IF;

               l_terr_all_rec.UPDATE_FLAG                  := 'N';
               l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG   := NULL;
               l_terr_all_rec.ORG_ID                       := p_org_id(x);
               l_terr_all_rec.NUM_WINNERS                  := NULL ;
               l_terr_all_rec.terr_creation_flag           := NULL;
               l_terr_all_rec.TERRITORY_TYPE_ID            := -1;
               l_terr_all_rec.attribute_category           := naterr.attribute_category;
               l_terr_all_rec.attribute1                   := naterr.attribute1;
               l_terr_all_rec.attribute2                   := naterr.attribute2;
               l_terr_all_rec.attribute3                   := naterr.attribute3;
               l_terr_all_rec.attribute4                   := naterr.attribute4;
               l_terr_all_rec.attribute5                   := naterr.attribute5;
               l_terr_all_rec.attribute6                   := naterr.attribute6;
               l_terr_all_rec.attribute7                   := naterr.attribute7;
               l_terr_all_rec.attribute8                   := naterr.attribute8;
               l_terr_all_rec.attribute9                   := naterr.attribute9;
               l_terr_all_rec.attribute10                  := naterr.attribute10;
               l_terr_all_rec.attribute11                  := naterr.attribute11;
               l_terr_all_rec.attribute12                  := naterr.attribute12;
               l_terr_all_rec.attribute13                  := naterr.attribute13;
               l_terr_all_rec.attribute14                  := naterr.attribute14;
               l_terr_all_rec.attribute15                  := naterr.attribute15;

               /* Oracle Sales and Telesales Usage */
               SELECT   JTF_TERR_USGS_S.NEXTVAL
               INTO l_terr_usg_id
               FROM DUAL;

               l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
               l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_last_update_date(x);
               l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_last_updated_by(x);
               l_terr_usgs_tbl(1).CREATION_DATE      := p_creation_date(x);
               l_terr_usgs_tbl(1).CREATED_BY         := p_created_by(x);
               l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_last_update_login(x);
               l_terr_usgs_tbl(1).TERR_ID            := NULL;
               l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
               l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

               i:=0;

               /* BEGIN: For each Access Type defined for the Territory Group */
               FOR acctype IN get_NON_OVLY_na_trans(naterr.terr_group_account_id)
               LOOP

                   i:=i+1;

                  IF ( acctype.access_type = 'ACCOUNT' ) THEN
                     l_qual_type_usg_id := -1001;
                  ELSIF ( acctype.access_type = 'LEAD' ) THEN
                     l_qual_type_usg_id := -1002;
                  ELSIF ( acctype.access_type = 'OPPORTUNITY' ) THEN
                     l_qual_type_usg_id := -1003;
                  ELSIF ( acctype.access_type = 'QUOTE' ) THEN
                     l_qual_type_usg_id := -1105;
                  ELSIF ( acctype.access_type = 'PROPOSAL' ) THEN
                     l_qual_type_usg_id := -1106;
                  END IF;

                  SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                    INTO l_terr_qtype_usg_id
                    FROM DUAL;

                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := l_qual_type_usg_id;
                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

               END LOOP; /* END: For each Access Type defined for the Territory Group */

               /*
               ** get Named Account Customer Keyname and Postal Code Mapping
               ** rules, to use as territory definition qualifier values
               */
               j:=0;
               K:=0;
               l_prev_qual_usg_id:=1;

               FOR qval IN match_rule3( naterr.named_account_id , p_matching_rule_code(x) ) LOOP

                   /* new qualifier, i.e., if there is a qualifier in
                   ** Addition to DUNS# or party number */
                   IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                       j:=j+1;

                       SELECT JTF_TERR_QUAL_S.NEXTVAL
                       INTO l_terr_qual_id
                       FROM DUAL;

                       l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                       l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                       l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                       l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                       l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                       l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                       l_terr_qual_tbl(j).TERR_ID              := NULL;
                       l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                       l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                       l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                       l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                       l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                       l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                       l_prev_qual_usg_id                      := qval.qual_usg_id;

                   END IF;

                   k:=k+1;

                   l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                   l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                   l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                   l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                   l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                   l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                   l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                   l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                   l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;

                   l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                   l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                   l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                   l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                   l_terr_values_tbl(k).VALUE_SET                  := NULL;
                   l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                   l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                   l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                   l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                   l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                   l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                   l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                   l_terr_values_tbl(k).qualifier_tbl_index        := j;

                   /* JRADHAKR: Added support for Party site id and hierarchy */

                   IF ( p_matching_rule_code(x) IN ('2', '3', '4')) THEN
                      l_terr_values_tbl(k).LOW_VALUE_CHAR          := qval.value1_char;
                   ELSIF ( p_matching_rule_code(x) IN ('5')) THEN
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID       := qval.value1_num;
                   ELSE
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID       := qval.value1_num;
                      l_terr_values_tbl(k).LOW_VALUE_CHAR          := p_matching_rule_code(x);
                   END IF;

               END LOOP; /* qval IN pqual */

               l_init_msg_list :=FND_API.G_TRUE;

               JTF_TERRITORY_PVT.create_territory (
                  p_api_version_number         => l_api_version_number,
                  p_init_msg_list              => l_init_msg_list,
                  p_commit                     => l_commit,
                  p_validation_level           => FND_API.g_valid_level_NONE,
                  x_return_status              => x_return_status,
                  x_msg_count                  => x_msg_count,
                  x_msg_data                   => x_msg_data,
                  p_terr_all_rec               => l_terr_all_rec,
                  p_terr_usgs_tbl              => l_terr_usgs_tbl,
                  p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                  p_terr_qual_tbl              => l_terr_qual_tbl,
                  p_terr_values_tbl            => l_terr_values_tbl,
                  x_terr_id                    => x_terr_id,
                  x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                  x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                  x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                  x_terr_values_out_tbl        => x_terr_values_out_tbl

               );


               IF G_Debug THEN
                   write_log(2,'  NA territory created = '||naterr.name);
               END IF;

               /* BEGIN: Successful Territory creation? */
               IF x_return_status = 'S' THEN

                   -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG
                   -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                   UPDATE JTF_TERR_ALL
                   SET TERR_GROUP_FLAG = 'Y'
                     , TERR_GROUP_ID = p_terr_group_id(x)
                     , CATCH_ALL_FLAG = 'N'
                     , NAMED_ACCOUNT_FLAG = 'Y'
                     , TERR_GROUP_ACCOUNT_ID = naterr.terr_group_account_id
                   WHERE terr_id = x_terr_id;

                   l_init_msg_list :=FND_API.G_TRUE;
                   i := 0;
                   a := 0;

                   FOR tran_type IN role_interest_nonpi(p_Terr_gROUP_ID(x)) LOOP

                       /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                       FOR rsc IN resource_grp(naterr.terr_group_account_id,tran_type.role_code) LOOP
                           i:=i+1;

                           SELECT JTF_TERR_RSC_S.NEXTVAL
                           INTO l_terr_rsc_id
                           FROM DUAL;

                           l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                           l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                           l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                           l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                           l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                           l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                           l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                           l_TerrRsc_Tbl(i).ROLE                 := tran_type.role_code;
                           l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';

                           IF rsc.start_date IS NULL THEN
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := rsc.start_date;
                           END IF;

                           IF rsc.end_date IS NULL THEN
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := rsc.end_date;
                           END IF;

                           l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                           l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                           l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                           l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                           l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                           l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                           l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                           l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                           l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                           l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                           l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                           l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                           l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                           l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                           l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                           l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                           l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                           l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                           l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;


                           FOR rsc_acc IN NON_OVLY_role_access(p_terr_group_id(x),tran_type.role_code)
                           LOOP
                               a := a+1;

                               IF ( rsc_acc.access_type='OPPORTUNITY' ) THEN
                                    l_qual_type := 'OPPOR';
                               ELSE
                                    l_qual_type := rsc_acc.access_type;
                               END IF;

                               SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                 INTO l_terr_rsc_access_id
                                 FROM DUAL;

                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                               l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                               l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                               l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := l_qual_type;
                               l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                               l_TerrRsc_Access_Tbl(a).TRANS_ACCESS_CODE   := rsc_acc.trans_access_code;
                               l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                           END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

                       END LOOP; /* FOR rsc in resource_grp */

                   END LOOP;/* FOR tran_type in role_interest_nonpi */

                   l_init_msg_list :=FND_API.G_TRUE;

                   -- 07/08/03: JDOCHERT: bug#3023653
                   Jtf_Territory_Resource_Pvt.create_terrresource (
                      p_api_version_number      => l_Api_Version_Number,
                      p_init_msg_list           => l_Init_Msg_List,
                      p_commit                  => l_Commit,
                      p_validation_level        => FND_API.g_valid_level_NONE,
                      x_return_status           => x_Return_Status,
                      x_msg_count               => x_Msg_Count,
                      x_msg_data                => x_msg_data,
                      p_terrrsc_tbl             => l_TerrRsc_tbl,
                      p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                      x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                      x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                   );

                   IF x_Return_Status='S' THEN
                       IF G_Debug THEN
                         write_log(2,'     Resource created for NA territory # ' ||x_terr_id);
                       END IF;
                   ELSE
                       IF G_Debug THEN
                           x_msg_data := SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                           write_log(2,x_msg_data);
                           write_log(2, '     Failed in resource creation for NA territory # ' || x_terr_id);
                       END IF;
                   END IF;

               ELSE
                   IF G_Debug THEN
                       x_msg_data :=  SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                       write_log(2,SUBSTR(x_msg_data,1,254));
                       WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' || 'FOR NAMED_ACCOUNT_ID# ' || naterr.named_account_id );
                   END IF;
               END IF; /* END: Successful Territory creation? */

           END LOOP; /* naterr in get_party_info */
         END IF; /* ( p_matching_rule_code(x) IN ('3') THEN */
         /*************************************************************/

         /* (5) END: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING DUNS# OR PARTY NUMBER QUALIFIER                 */
         /*************************************************************/

         /***************************************************************/
         /* (6) START: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
         /***************************************************************/

         IF ( p_matching_rule_code(x) IN ('1', '2') ) THEN
           FOR naterr IN get_party_name(p_terr_group_id(x)) LOOP

               --write_log(2,'na '||naterr.named_account_id);
               l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
               l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
               l_terr_qual_tbl         := l_terr_qual_empty_tbl;
               l_terr_values_tbl       := l_terr_values_empty_tbl;
               l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
               l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

               /* TERRITORY HEADER */
               /* Ensure static TERR_ID to benefit TAP Performance */
               BEGIN

                   l_terr_exists := 0;

                   SELECT COUNT(*)
                   INTO l_terr_exists
                   FROM jtf_terr_all jt
                   WHERE jt.terr_id = naterr.terr_group_account_id * -10000;

                   IF (l_terr_exists = 0) THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -10000;
                   ELSE
                       l_terr_all_rec.TERR_ID := NULL;
                   END IF;

               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       l_terr_all_rec.TERR_ID := naterr.terr_group_account_id * -10000;
               END;

               l_terr_all_rec.LAST_UPDATE_DATE             := p_last_update_date(x);
               l_terr_all_rec.LAST_UPDATED_BY              := p_last_updated_by(x);
               l_terr_all_rec.CREATION_DATE                := p_creation_date(x);
               l_terr_all_rec.CREATED_BY                   := p_created_by(x);
               l_terr_all_rec.LAST_UPDATE_LOGIN            := p_last_update_login(x);
               l_terr_all_rec.APPLICATION_SHORT_NAME       := G_APP_SHORT_NAME;
               l_terr_all_rec.NAME                         := naterr.name;

               IF naterr.start_date IS NULL THEN
                   l_terr_all_rec.start_date_active          := p_active_from_date(x);
               ELSE
                   l_terr_all_rec.start_date_active          := naterr.start_date;
               END IF;

               IF naterr.end_date IS NULL THEN
                   l_terr_all_rec.end_date_active            := p_active_to_date(x);
               ELSE
                   l_terr_all_rec.end_date_active            := naterr.end_date;
               END IF;

               l_terr_all_rec.PARENT_TERRITORY_ID          := l_nacat;
               l_terr_all_rec.RANK                         := p_rank(x) + 20;
               l_terr_all_rec.TEMPLATE_TERRITORY_ID        := NULL;
               l_terr_all_rec.TEMPLATE_FLAG                := 'N';
               l_terr_all_rec.ESCALATION_TERRITORY_ID      := NULL;
               l_terr_all_rec.ESCALATION_TERRITORY_FLAG    := 'N';
               l_terr_all_rec.OVERLAP_ALLOWED_FLAG         := NULL;
               l_terr_all_rec.DESCRIPTION                  := naterr.name;
               l_terr_all_rec.UPDATE_FLAG                  := 'N';
               l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG   := NULL;
               l_terr_all_rec.ORG_ID                       := p_org_id(x);
               l_terr_all_rec.NUM_WINNERS                  := NULL ;
               l_terr_all_rec.terr_creation_flag           := NULL;
               l_terr_all_rec.TERRITORY_TYPE_ID            := -1;
               l_terr_all_rec.attribute_category           := naterr.attribute_category;
               l_terr_all_rec.attribute1                   := naterr.attribute1;
               l_terr_all_rec.attribute2                   := naterr.attribute2;
               l_terr_all_rec.attribute3                   := naterr.attribute3;
               l_terr_all_rec.attribute4                   := naterr.attribute4;
               l_terr_all_rec.attribute5                   := naterr.attribute5;
               l_terr_all_rec.attribute6                   := naterr.attribute6;
               l_terr_all_rec.attribute7                   := naterr.attribute7;
               l_terr_all_rec.attribute8                   := naterr.attribute8;
               l_terr_all_rec.attribute9                   := naterr.attribute9;
               l_terr_all_rec.attribute10                  := naterr.attribute10;
               l_terr_all_rec.attribute11                  := naterr.attribute11;
               l_terr_all_rec.attribute12                  := naterr.attribute12;
               l_terr_all_rec.attribute13                  := naterr.attribute13;
               l_terr_all_rec.attribute14                  := naterr.attribute14;
               l_terr_all_rec.attribute15                  := naterr.attribute15;

               /* Oracle Sales and Telesales Usage */
               SELECT   JTF_TERR_USGS_S.NEXTVAL
               INTO l_terr_usg_id
               FROM DUAL;

               l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
               l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_last_update_date(x);
               l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_last_updated_by(x);
               l_terr_usgs_tbl(1).CREATION_DATE      := p_creation_date(x);
               l_terr_usgs_tbl(1).CREATED_BY         := p_created_by(x);
               l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_last_update_login(x);
               l_terr_usgs_tbl(1).TERR_ID            := NULL;
               l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
               l_terr_usgs_tbl(1).ORG_ID             := p_org_id(x);

               i:=0;

               /* BEGIN: For each Access Type defined for the Territory Group */
               FOR acctype IN get_NON_OVLY_na_trans(naterr.terr_group_account_id)
               LOOP

                   i:=i+1;

                  IF ( acctype.access_type='ACCOUNT' ) THEN
                     l_qual_type_usg_id := -1001;
                  ELSIF ( acctype.access_type='LEAD' ) THEN
                     l_qual_type_usg_id := -1002;
                  ELSIF ( acctype.access_type='OPPORTUNITY' ) THEN
                     l_qual_type_usg_id := -1003;
                  ELSIF ( acctype.access_type='QUOTE' ) THEN
                     l_qual_type_usg_id := -1105;
                  ELSIF ( acctype.access_type='PROPOSAL' ) THEN
                     l_qual_type_usg_id := -1106;
                  END IF;

                  SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                    INTO l_terr_qtype_usg_id
                    FROM DUAL;

                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := l_qual_type_usg_id;
                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

               END LOOP;
               /* END: For each Access Type defined for the Territory Group */

               /*
               ** get Named Account Customer Keyname and Postal Code Mapping
               ** rules, to use as territory definition qualifier values
               */
               j:=0;
               K:=0;
               l_prev_qual_usg_id:=1;
               FOR qval IN match_rule1( naterr.named_account_id ) LOOP

                   /* new qualifier, i.e., Customer Name Range or Postal Code: ** driven by ORDER BY on p_qual */
                   IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                       j:=j+1;

                       SELECT JTF_TERR_QUAL_S.NEXTVAL
                       INTO l_terr_qual_id
                       FROM DUAL;

                       l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                       l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                       l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                       l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                       l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                       l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                       l_terr_qual_tbl(j).TERR_ID              := NULL;
                       l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                       l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                       l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                       l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                       l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                       l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                       l_prev_qual_usg_id                      := qval.qual_usg_id;
                   END IF;

                   k:=k+1;

                   l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                   l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                   l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                   l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                   l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                   l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                   l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                   l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                   l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;
                   l_terr_values_tbl(k).LOW_VALUE_CHAR             := qval.value1_char;
                   l_terr_values_tbl(k).HIGH_VALUE_CHAR            := qval.value2_char;
                   l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                   l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                   l_terr_values_tbl(k).VALUE_SET                  := NULL;
                   l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                   l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                   l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                   l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                   l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                   l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                   l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                   l_terr_values_tbl(k).qualifier_tbl_index        := j;

               END LOOP; /* qval IN pqual */

               l_init_msg_list :=FND_API.G_TRUE;

               JTF_TERRITORY_PVT.create_territory (
                  p_api_version_number         => l_api_version_number,
                  p_init_msg_list              => l_init_msg_list,
                  p_commit                     => l_commit,
                  p_validation_level           => FND_API.g_valid_level_NONE,
                  x_return_status              => x_return_status,
                  x_msg_count                  => x_msg_count,
                  x_msg_data                   => x_msg_data,
                  p_terr_all_rec               => l_terr_all_rec,
                  p_terr_usgs_tbl              => l_terr_usgs_tbl,
                  p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                  p_terr_qual_tbl              => l_terr_qual_tbl,
                  p_terr_values_tbl            => l_terr_values_tbl,
                  x_terr_id                    => x_terr_id,
                  x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                  x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                  x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                  x_terr_values_out_tbl        => x_terr_values_out_tbl

               );

               IF G_Debug THEN
                 write_log(2,'  NA territory created = '||naterr.name);
               END IF;

               /* BEGIN: Successful Territory creation? */
               IF x_return_status = 'S' THEN

                   -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG
                   -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                   UPDATE JTF_TERR_ALL
                   SET TERR_GROUP_FLAG = 'Y'
                     , TERR_GROUP_ID = p_terr_group_id(x)
                     , CATCH_ALL_FLAG = 'N'
                     , NAMED_ACCOUNT_FLAG = 'Y'
                     , TERR_GROUP_ACCOUNT_ID = naterr.terr_group_account_id
                   WHERE terr_id = x_terr_id;

                   l_init_msg_list :=FND_API.G_TRUE;
                   i := 0;
                   a := 0;

                   FOR tran_type IN role_interest_nonpi(p_Terr_gROUP_ID(x)) LOOP

                       /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                       FOR rsc IN resource_grp(naterr.terr_group_account_id,tran_type.role_code) LOOP
                           i:=i+1;

                           SELECT JTF_TERR_RSC_S.NEXTVAL
                           INTO l_terr_rsc_id
                           FROM DUAL;

                           l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                           l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                           l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                           l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                           l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                           l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                           l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                           l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                           l_TerrRsc_Tbl(i).ROLE                 := tran_type.role_code;
                           l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';

                           IF rsc.start_date IS NULL THEN
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := rsc.start_date;
                           END IF;

                           IF rsc.end_date IS NULL THEN
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                           ELSE
                               l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := rsc.end_date;
                           END IF;

                           l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                           l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                           l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                           l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                           l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                           l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                           l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                           l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                           l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                           l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                           l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                           l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                           l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                           l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                           l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                           l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                           l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                           l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                           l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;

                           FOR rsc_acc IN NON_OVLY_role_access(p_terr_group_id(x),tran_type.role_code)
                           LOOP
                               a := a+1;

                               IF ( rsc_acc.access_type='OPPORTUNITY' ) THEN
                                    l_qual_type := 'OPPOR';
                               ELSE
                                    l_qual_type := rsc_acc.access_type;
                               END IF;

                               SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                 INTO l_terr_rsc_access_id
                                 FROM DUAL;

                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                               l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                               l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                               l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                               l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                               l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := l_qual_type;
                               l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                               l_TerrRsc_Access_Tbl(a).TRANS_ACCESS_CODE   := rsc_acc.trans_access_code;
                               l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                           END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

                       END LOOP; /* FOR rsc in resource_grp */

                   END LOOP;/* FOR tran_type in role_interest_nonpi */

                   l_init_msg_list :=FND_API.G_TRUE;

                   Jtf_Territory_Resource_Pvt.create_terrresource (
                      p_api_version_number      => l_Api_Version_Number,
                      p_init_msg_list           => l_Init_Msg_List,
                      p_commit                  => l_Commit,
                      p_validation_level        => FND_API.g_valid_level_NONE,
                      x_return_status           => x_Return_Status,
                      x_msg_count               => x_Msg_Count,
                      x_msg_data                => x_msg_data,
                      p_terrrsc_tbl             => l_TerrRsc_tbl,
                      p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                      x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                      x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                   );

                   IF x_Return_Status='S' THEN
                       IF G_Debug THEN
                         write_log(2,'     Resource created for NA territory # ' ||x_terr_id);
                       END IF;
                   ELSE
                       IF G_Debug THEN
                           x_msg_data := SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                           write_log(2,x_msg_data);
                           write_log(2, '     Failed in resource creation for NA territory # ' || x_terr_id);
                       END IF;
                   END IF;

               ELSE
                   IF G_Debug THEN
                       x_msg_data :=  SUBSTR(FND_MSG_PUB.get(1, FND_API.g_false),1,254);
                       write_log(2,SUBSTR(x_msg_data,1,254));
                       WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' || 'FOR NAMED_ACCOUNT_ID# ' || naterr.named_account_id );
                   END IF;
               END IF; /* END: Successful Territory creation? */

           END LOOP; /* naterr in get_party_name */
         END IF; /* p_matching_rule_code(x) IN ('1', '2') THEN */

         /*************************************************************/
         /* (6) END: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS  */
         /*************************************************************/

         /********************************************************/
         /* delete the role and access */
         /********************************************************/
         IF l_ovnon_flag = 'Y' THEN

              FOR i IN l_overnon_role_tbl.first.. l_overnon_role_tbl.last
              LOOP
                 DELETE FROM jtf_tty_terr_grp_roles
                 WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
                 --dbms_output.put_line('deleted');
                 DELETE FROM jtf_tty_role_access
                 WHERE TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
              END LOOP;
         END IF;

      END IF;
      /* END: if Territory Group exists with Named Accounts then auto-create territory definitions */



      /*********************************************************************/
      /*********************************************************************/
      /************** OVERLAY TERRITORY CREATION ***************************/
      /*********************************************************************/
      /*********************************************************************/

      /* if any role with PI and Account access and no non pi role exist */
      /* we need to create a new branch with Named Account               */

      /* OVERLAY BRANCH */

      BEGIN

          SELECT COUNT( DISTINCT b.role_code )
          INTO l_pi_count
          FROM jtf_rs_roles_vl r
              , jtf_tty_role_prod_int a
              , jtf_tty_terr_grp_roles b
          WHERE r.role_code = b.role_code
          AND a.terr_group_role_id = b.terr_group_role_id
          AND b.terr_group_id      = p_terr_group_id(x)
          AND EXISTS (
               /* Named Account exists with Salesperson with this role */
               SELECT NULL
               FROM jtf_tty_named_acct_rsc nar, jtf_tty_terr_grp_accts tga
               WHERE tga.terr_group_account_id = nar.terr_group_account_id
               AND tga.terr_group_id = b.terr_group_id
               AND nar.rsc_role_code = b.role_code )
          AND ROWNUM < 2;

      EXCEPTION
          WHEN OTHERS THEN NULL;
      END;

      /* are there overlay roles, i.e., are there roles with Product
      ** Interests defined for this Territory Group */
      IF l_pi_count > 0 THEN

          /***************************************************************/
          /* (7) START: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF */
          /*    TERRITORY GROUP                                          */
          /***************************************************************/
          FOR topt IN topterr(p_parent_terr_id(x)) LOOP

              l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
              l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
              l_terr_qual_tbl         := l_terr_qual_empty_tbl;
              l_terr_values_tbl       := l_terr_values_empty_tbl;
              l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

              l_terr_all_rec.TERR_ID                    := NULL;
              l_terr_all_rec.LAST_UPDATE_DATE           := p_last_update_date(x);
              l_terr_all_rec.LAST_UPDATED_BY            := p_last_updated_by(x);
              l_terr_all_rec.CREATION_DATE              := p_creation_date(x);
              l_terr_all_rec.CREATED_BY                 := p_created_by(x);
              l_terr_all_rec.LAST_UPDATE_LOGIN          := p_last_update_login(x);
              l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
              l_terr_all_rec.NAME                       := p_terr_group_name(x) || ' (OVERLAY)';
              l_terr_all_rec.start_date_active          := p_active_from_date(x);
              l_terr_all_rec.end_date_active            := p_active_to_date(x);
              l_terr_all_rec.PARENT_TERRITORY_ID        := topt.PARENT_TERRITORY_ID;
              l_terr_all_rec.RANK                       := topt.RANK;
              l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
              l_terr_all_rec.TEMPLATE_FLAG              := 'N';
              l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
              l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
              l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
              l_terr_all_rec.DESCRIPTION                := topt.DESCRIPTION;
              l_terr_all_rec.UPDATE_FLAG                := 'N';
              l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
              l_terr_all_rec.ORG_ID                     := p_org_id(x);
              l_terr_all_rec.NUM_WINNERS                := l_pi_count ;

              /* ORACLE SALES AND TELESALES USAGE */
              SELECT JTF_TERR_USGS_S.NEXTVAL
                INTO l_terr_usg_id
              FROM DUAL;

              l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
              l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
              l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
              l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
              l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
              l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
              l_terr_usgs_tbl(1).TERR_ID           := NULL;
              l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
              l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

              /* LEAD TRANSACTION TYPE */
              SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
              INTO l_terr_qtype_usg_id
              FROM DUAL;

              l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := p_last_update_date(x);
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := p_last_updated_by(x);
              l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := p_creation_date(x);
              l_terr_qualtypeusgs_tbl(1).CREATED_BY            := p_created_by(x);
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := p_last_update_login(x);
              l_terr_qualtypeusgs_tbl(1).TERR_ID               := NULL;
              l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1002;
              l_terr_qualtypeusgs_tbl(1).ORG_ID                := p_org_id(x);

              /* OPPORTUNITY TRANSACTION TYPE */
              SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
              INTO l_terr_qtype_usg_id
              FROM DUAL;

              l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := p_last_update_date(x);
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := p_last_updated_by(x);
              l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := p_creation_date(x);
              l_terr_qualtypeusgs_tbl(2).CREATED_BY            := p_created_by(x);
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := p_last_update_login(x);
              l_terr_qualtypeusgs_tbl(2).TERR_ID               := NULL;
              l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1003;
              l_terr_qualtypeusgs_tbl(2).ORG_ID                := p_org_id(x);

              /*
              ** get Top-Level Parent's Qualifier and values and
              ** aad them to Overlay branch top-level territory
              */
              j:=0;
              k:=0;
              l_prev_qual_usg_id:=1;
              FOR csr_qual IN csr_get_qual ( topt.terr_id ) LOOP

                  j:=j+1;

                  SELECT JTF_TERR_QUAL_S.NEXTVAL
                  INTO l_terr_qual_id
                  FROM DUAL;

                  l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                  l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                  l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                  l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                  l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                  l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                  l_terr_qual_tbl(j).TERR_ID              := NULL;
                  l_terr_qual_tbl(j).QUAL_USG_ID          := csr_qual.qual_usg_id;
                  l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                  l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'Y';
                  l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                  l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                  l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);

                  FOR csr_qual_val IN csr_get_qual_val (csr_qual.terr_qual_id) LOOP

                      k:=k+1;

                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                      l_terr_values_tbl(k).INCLUDE_FLAG               := csr_qual_val.INCLUDE_FLAG;
                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := csr_qual_val.COMPARISON_OPERATOR;
                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := csr_qual_val.LOW_VALUE_CHAR;
                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := csr_qual_val.HIGH_VALUE_CHAR;
                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := csr_qual_val.LOW_VALUE_NUMBER;
                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := csr_qual_val.HIGH_VALUE_NUMBER;
                      l_terr_values_tbl(k).VALUE_SET                  := csr_qual_val.VALUE_SET;
                      l_terr_values_tbl(k).INTEREST_TYPE_ID           := csr_qual_val.INTEREST_TYPE_ID;
                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := csr_qual_val.PRIMARY_INTEREST_CODE_ID;
                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := csr_qual_val.SECONDARY_INTEREST_CODE_ID;
                      l_terr_values_tbl(k).CURRENCY_CODE              := csr_qual_val.CURRENCY_CODE;
                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                      l_terr_values_tbl(k).ID_USED_FLAG               := csr_qual_val.ID_USED_FLAG;
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := csr_qual_val.LOW_VALUE_CHAR_ID;
                      l_terr_values_tbl(k).qualifier_tbl_index        := j;

                  END LOOP;/* csr_qual_val IN csr_get_qual_val */
              END LOOP; /* csr_qual IN csr_get_qual */

              l_init_msg_list :=FND_API.G_TRUE;

              JTF_TERRITORY_PVT.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => FND_API.g_valid_level_NONE,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_terr_all_rec               => l_terr_all_rec,
                p_terr_usgs_tbl              => l_terr_usgs_tbl,
                p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                p_terr_qual_tbl              => l_terr_qual_tbl,
                p_terr_values_tbl            => l_terr_values_tbl,
                x_terr_id                    => x_terr_id,
                x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
				x_terr_values_out_tbl        => x_terr_values_out_tbl

              );

              IF G_Debug THEN
                write_log(2,' OVERLAY Top level Territory Created,territory_id# '||x_terr_id);
              END IF;

              IF x_return_status = 'S' THEN

                 -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                 UPDATE JTF_TERR_ALL
                    SET TERR_GROUP_FLAG = 'Y'
                      , TERR_GROUP_ID = p_TERR_GROUP_ID(x)
                 WHERE terr_id = x_terr_id;

              END IF;

              l_overlay_top :=x_terr_id;

          END LOOP;/* top level territory */
          /***************************************************************/
          /* (7) END: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF   */
          /*    TERRITORY GROUP                                          */
          /***************************************************************/


          /***************************************************************/
          /* (8) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
          /*     USING DUNS# OR PARTY NUMBER QUALIFIER                   */
          /***************************************************************/
          IF ( p_matching_rule_code(x) IN ('2', '3', '4') ) THEN
              FOR overlayterr IN get_OVLY_party_info(p_terr_group_id(x), p_matching_rule_code(x)) LOOP

                  l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                  l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                  l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                  l_terr_values_tbl       := l_terr_values_empty_tbl;
                  l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                  l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                  l_terr_all_rec.TERR_ID                     := NULL;
                  l_terr_all_rec.LAST_UPDATE_DATE            := p_last_update_date(x);
                  l_terr_all_rec.LAST_UPDATED_BY             := p_last_updated_by(x);
                  l_terr_all_rec.CREATION_DATE               := p_creation_date(x);
                  l_terr_all_rec.CREATED_BY                  := p_created_by(x);
                  l_terr_all_rec.LAST_UPDATE_LOGIN           := p_last_update_login(x);
                  l_terr_all_rec.APPLICATION_SHORT_NAME      := G_APP_SHORT_NAME;

                  IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                    l_terr_all_rec.NAME                        := overlayterr.name || ' (OVERLAY DUNS#)';
                  ELSE
                    l_terr_all_rec.NAME                        := overlayterr.name || ' (OVERLAY Registry ID)';
                  END IF;

                  l_terr_all_rec.start_date_active           := p_active_from_date(x);
                  l_terr_all_rec.end_date_active             := p_active_to_date(x);
                  l_terr_all_rec.PARENT_TERRITORY_ID         := l_overlay_top;
                  l_terr_all_rec.RANK                        := p_rank(x)+ 10;
                  l_terr_all_rec.TEMPLATE_TERRITORY_ID       := NULL;
                  l_terr_all_rec.TEMPLATE_FLAG               := 'N';
                  l_terr_all_rec.ESCALATION_TERRITORY_ID     := NULL;
                  l_terr_all_rec.ESCALATION_TERRITORY_FLAG   := 'N';
                  l_terr_all_rec.OVERLAP_ALLOWED_FLAG        := NULL;

                  IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                    l_terr_all_rec.DESCRIPTION                 := overlayterr.name || ' (OVERLAY DUNS#)';
                  ELSE
                    l_terr_all_rec.DESCRIPTION                 := overlayterr.name || ' (OVERLAY Registry ID)';
                  END IF;

                  l_terr_all_rec.UPDATE_FLAG                 := 'N';
                  l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG  := NULL;
                  l_terr_all_rec.ORG_ID                      := p_org_id(x);
                  l_terr_all_rec.NUM_WINNERS                 := NULL ;

                  SELECT JTF_TERR_USGS_S.NEXTVAL
                  INTO l_terr_usg_id
                  FROM DUAL;

                  l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                  l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                  l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                  l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                  l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                  l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                  l_terr_usgs_tbl(1).TERR_ID           := NULL;
                  l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
                  l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                  SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                  INTO l_terr_qtype_usg_id
                  FROM DUAL;

                  l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(1).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(1).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1002;
                  l_terr_qualtypeusgs_tbl(1).ORG_ID                := p_org_id(x);

                  SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                  INTO l_terr_qtype_usg_id
                  FROM DUAL;

                  l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                  l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := p_last_update_date(x);
                  l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := p_last_updated_by(x);
                  l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := p_creation_date(x);
                  l_terr_qualtypeusgs_tbl(2).CREATED_BY            := p_created_by(x);
                  l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                  l_terr_qualtypeusgs_tbl(2).TERR_ID               := NULL;
                  l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1003;
                  l_terr_qualtypeusgs_tbl(2).ORG_ID                := p_org_id(x);

                  SELECT JTF_TERR_QUAL_S.NEXTVAL
                  INTO l_terr_qual_id
                  FROM DUAL;

                  j:=0;
                  K:=0;
                  l_prev_qual_usg_id:=1;

                  FOR qval IN match_rule3(overlayterr.named_account_id, p_matching_rule_code(x)) LOOP

                      IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                          j:=j+1;

                          SELECT   JTF_TERR_QUAL_S.NEXTVAL
                          INTO l_terr_qual_id
                          FROM DUAL;

                          l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                          l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                          l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                          l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                          l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                          l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                          l_terr_qual_tbl(j).TERR_ID              := NULL;
                          l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                          l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                          l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                          l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                          l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                          l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                          l_prev_qual_usg_id                      := qval.qual_usg_id;

                      END IF;

                      k:=k+1;

                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                      l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;
                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := qval.value1_char;
                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                      l_terr_values_tbl(k).VALUE_SET                  := NULL;
                      l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                      l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                      l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                      l_terr_values_tbl(k).qualifier_tbl_index        := j;

                  END LOOP;

                  l_init_msg_list :=FND_API.G_TRUE;

                  JTF_TERRITORY_PVT.create_territory (
                             p_api_version_number         => l_api_version_number,
                             p_init_msg_list              => l_init_msg_list,
                             p_commit                     => l_commit,
                             p_validation_level           => FND_API.g_valid_level_NONE,
                             x_return_status              => x_return_status,
                             x_msg_count                  => x_msg_count,
                             x_msg_data                   => x_msg_data,
                             p_terr_all_rec               => l_terr_all_rec,
                             p_terr_usgs_tbl              => l_terr_usgs_tbl,
                             p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                             p_terr_qual_tbl              => l_terr_qual_tbl,
                             p_terr_values_tbl            => l_terr_values_tbl,
                             x_terr_id                    => x_terr_id,
                             x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                             x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                             x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                             x_terr_values_out_tbl        => x_terr_values_out_tbl

                  );

                  IF G_Debug THEN
                    write_log(2,' Named Account OVERLAY territory created: '||l_terr_all_rec.NAME);
                  END IF;

                  IF x_return_status = 'S' THEN

                      -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                      -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                      UPDATE JTF_TERR_ALL
                      SET TERR_GROUP_FLAG = 'Y'
                        , TERR_GROUP_ID = p_TERR_GROUP_ID(x)
                        , NAMED_ACCOUNT_FLAG = 'Y'
                        , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                      WHERE terr_id = x_terr_id;

                      l_overlay:=x_terr_id;

                      FOR pit IN role_pi(p_terr_group_id(x), overlayterr.terr_group_account_id) LOOP

                          l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                          l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                          l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                          l_terr_values_tbl       := l_terr_values_empty_tbl;
                          l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                          l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                          l_role_counter := l_role_counter + 1;

                          l_terr_all_rec.TERR_ID                    := overlayterr.terr_group_account_id * -30 * l_role_counter;
                          l_terr_all_rec.LAST_UPDATE_DATE           := p_last_update_date(x);
                          l_terr_all_rec.LAST_UPDATED_BY            := p_last_updated_by(x);
                          l_terr_all_rec.CREATION_DATE              := p_creation_date(x);
                          l_terr_all_rec.CREATED_BY                 := p_created_by(x);
                          l_terr_all_rec.LAST_UPDATE_LOGIN          := p_last_update_login(x);
                          l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;

                          IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                            l_terr_all_rec.NAME := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY DUNS#)';
                          ELSE
                            l_terr_all_rec.NAME := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY Registry ID)';
                          END IF;

                          l_terr_all_rec.start_date_active          := p_active_from_date(x);
                          l_terr_all_rec.end_date_active            := p_active_to_date(x);
                          l_terr_all_rec.PARENT_TERRITORY_ID        := l_overlay;
                          l_terr_all_rec.RANK                       := p_rank(x) + 10;
                          l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
                          l_terr_all_rec.TEMPLATE_FLAG              := 'N';
                          l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
                          l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
                          l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;

                          IF ( p_matching_rule_code(x) IN ('2', '3')) THEN
                            l_terr_all_rec.DESCRIPTION := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY DUNS#)';
                          ELSE
                            l_terr_all_rec.DESCRIPTION := overlayterr.name || ': ' || pit.role_name || ' (OVERLAY Registry ID)';
                          END IF;

                          l_terr_all_rec.UPDATE_FLAG                := 'N';
                          l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
                          l_terr_all_rec.ORG_ID                     := p_org_id(x);
                          l_terr_all_rec.NUM_WINNERS                := NULL ;
                          l_terr_all_rec.attribute_category         := overlayterr.attribute_category;
                          l_terr_all_rec.attribute1                 := overlayterr.attribute1;
                          l_terr_all_rec.attribute2                 := overlayterr.attribute2;
                          l_terr_all_rec.attribute3                 := overlayterr.attribute3;
                          l_terr_all_rec.attribute4                 := overlayterr.attribute4;
                          l_terr_all_rec.attribute5                 := overlayterr.attribute5;
                          l_terr_all_rec.attribute6                 := overlayterr.attribute6;
                          l_terr_all_rec.attribute7                 := overlayterr.attribute7;
                          l_terr_all_rec.attribute8                 := overlayterr.attribute8;
                          l_terr_all_rec.attribute9                 := overlayterr.attribute9;
                          l_terr_all_rec.attribute10                := overlayterr.attribute10;
                          l_terr_all_rec.attribute11                := overlayterr.attribute11;
                          l_terr_all_rec.attribute12                := overlayterr.attribute12;
                          l_terr_all_rec.attribute13                := overlayterr.attribute13;
                          l_terr_all_rec.attribute14                := overlayterr.attribute14;
                          l_terr_all_rec.attribute15                := overlayterr.attribute15;

                          SELECT   JTF_TERR_USGS_S.NEXTVAL
                          INTO l_terr_usg_id
                          FROM DUAL;

                          l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                          l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                          l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                          l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                          l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                          l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                          l_terr_usgs_tbl(1).TERR_ID           := NULL;
                          l_terr_usgs_tbl(1).SOURCE_ID         :=-1001;
                          l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                          i := 0;
                          K:= 0;
                          FOR acc_type IN role_access(p_terr_group_id(x),pit.role_code) LOOP
                              --i:=i+1;
                              --dbms_output.put_line('acc type  '||acc_type.access_type);
                              IF acc_type.access_type= 'OPPORTUNITY' THEN
                                  i:=i+1;
                                  SELECT JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                  INTO l_terr_qtype_usg_id
                                  FROM DUAL;

                                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1003;
                                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                  SELECT JTF_TERR_QUAL_S.NEXTVAL
                                  INTO l_terr_qual_id
                                  FROM DUAL;

                                  /* opp expected purchase */
                                  l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                  l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                  l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                  l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                  l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                  l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                  l_terr_qual_tbl(i).TERR_ID              := NULL;
                                  l_terr_qual_tbl(i).QUAL_USG_ID          := g_opp_qual_usg_id;
                                  l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                  l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                  l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                  l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                  l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                  FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP
                                      k:=k+1;

                                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                      l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                      l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                      l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                      l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                      l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                      IF (g_prod_cat_enabled) THEN
                                        l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                        l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                      ELSE
                                        l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                      END IF;

                                  END LOOP;

                              ELSIF acc_type.access_type= 'LEAD' THEN

                                  i:=i+1;
                                  SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                  INTO l_terr_qtype_usg_id
                                  FROM DUAL;

                                  l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                  l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                  l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                  l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                  l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1002;
                                  l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                  SELECT   JTF_TERR_QUAL_S.NEXTVAL
                                  INTO l_terr_qual_id
                                  FROM DUAL;

                                  /* lead expected purchase */
                                  l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                  l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                  l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                  l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                  l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                  l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                  l_terr_qual_tbl(i).TERR_ID              := NULL;
                                  l_terr_qual_tbl(i).QUAL_USG_ID          := g_lead_qual_usg_id;
                                  l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                  l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                  l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                  l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                  l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                  FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                                      k:=k+1;

                                      l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                      l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                      l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                      l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                      l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                      l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                      l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                      l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                      l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                      l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                      l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                      l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                      l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                      l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                      l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                      IF (g_prod_cat_enabled) THEN
                                        l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                        l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                      ELSE
                                        l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                      END IF;

                                  END LOOP;

                              ELSE
                                  IF G_Debug THEN
                                      write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_id(x));
                                  END IF;
                              END IF;

                          END LOOP;

                          l_init_msg_list :=FND_API.G_TRUE;

                          JTF_TERRITORY_PVT.create_territory (
                                     p_api_version_number         => l_api_version_number,
                                     p_init_msg_list              => l_init_msg_list,
                                     p_commit                     => l_commit,
                                     p_validation_level           => FND_API.g_valid_level_NONE,
                                     x_return_status              => x_return_status,
                                     x_msg_count                  => x_msg_count,
                                     x_msg_data                   => x_msg_data,
                                     p_terr_all_rec               => l_terr_all_rec,
                                     p_terr_usgs_tbl              => l_terr_usgs_tbl,
                                     p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                                     p_terr_qual_tbl              => l_terr_qual_tbl,
                                     p_terr_values_tbl            => l_terr_values_tbl,
                                     x_terr_id                    => x_terr_id,
                                     x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                                     x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                                     x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                                     x_terr_values_out_tbl        => x_terr_values_out_tbl

                          );

                          IF (x_return_status = 'S')  THEN

                              -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                              -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                              UPDATE JTF_TERR_ALL
                              SET TERR_GROUP_FLAG = 'Y'
                                , TERR_GROUP_ID = p_terr_group_id(x)
                                , NAMED_ACCOUNT_FLAG = 'Y'
                                , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                              WHERE terr_id = x_terr_id;


                              IF G_Debug THEN
                                  write_log(2,' OVERLAY PI Territory Created = '||l_terr_all_rec.NAME);
                              END IF;

                          ELSE
                              IF G_Debug THEN
                                  x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                                  write_log(2,x_msg_data);
                                  write_log(2, 'Failed in OVERLAY PI Territory Creation for TERR_GROUP_ACCOUNT_ID#'||
                                                        overlayterr.terr_group_account_id);
                              END IF;

                          END IF;

                          --dbms_output.put_line('pit.role '||pit.role_code);
                          i:=0;

                          /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                          FOR rsc IN resource_grp(overlayterr.terr_group_account_id,pit.role_code) LOOP

                              i:=i+1;

                              SELECT JTF_TERR_RSC_S.NEXTVAL
                              INTO l_terr_rsc_id
                              FROM DUAL;

                              l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                              l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                              l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                              l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                              l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                              l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                              l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                              l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                              l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                              l_TerrRsc_Tbl(i).ROLE                 := pit.role_code;
                              l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
                              l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                              l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                              l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                              l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                              l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                              l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                              l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                              l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                              l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                              l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                              l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                              l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                              l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                              l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                              l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                              l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                              l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                              l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                              l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                              l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                              l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;

                              a := 0;

                              FOR rsc_acc IN role_access(p_terr_group_id(x),pit.role_code) LOOP

                                  IF rsc_acc.access_type= 'OPPORTUNITY' THEN

                                      a := a+1;

                                      SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                      INTO l_terr_rsc_access_id
                                      FROM DUAL;

                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                      l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                      l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                      l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                                      l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                      l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                                  ELSIF rsc_acc.access_type= 'LEAD' THEN

                                      a := a+1;

                                      SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                      INTO l_terr_rsc_access_id
                                      FROM DUAL;

                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                      l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                      l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                      l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                      l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                      l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                                      l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                      l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                                  END IF;
                              END LOOP; /* rsc_acc in role_access */

                              l_init_msg_list :=FND_API.G_TRUE;

                              -- 07/08/03: JDOCHERT: bug#3023653
                              Jtf_Territory_Resource_Pvt.create_terrresource (
                                         p_api_version_number      => l_Api_Version_Number,
                                         p_init_msg_list           => l_Init_Msg_List,
                                         p_commit                  => l_Commit,
                                         p_validation_level        => FND_API.g_valid_level_NONE,
                                         x_return_status           => x_Return_Status,
                                         x_msg_count               => x_Msg_Count,
                                         x_msg_data                => x_msg_data,
                                         p_terrrsc_tbl             => l_TerrRsc_tbl,
                                         p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                                         x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                                         x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                              );

                              IF x_Return_Status='S' THEN
                                   IF G_Debug THEN
                                     write_log(2,'Resource created for Product Interest OVERLAY Territory '||l_terr_all_rec.NAME);
                                   END IF;
                              ELSE
                                   IF G_Debug THEN
                                       write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '||
x_terr_id);
                                   END IF;
                              END IF;

                          END LOOP; /* rsc in resource_grp */

                      END LOOP;

                  ELSE
                       IF G_Debug THEN
                           x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                           write_log(2,x_msg_data);
                           write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' ||
                                           p_terr_group_id(x) || ' : ' ||
                                           p_terr_group_name(x) );
                       END IF;
                  END IF; /* if (x_return_status = 'S' */
              END LOOP; /* overlayterr in get_OVLY_party_info */
          END IF; /* ( p_matching_rule_code(x) IN ('2','3') THEN */
          /***************************************************************/
          /* (8) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
          /*     USING DUNS# OR PARTY NUMBER QUALIFIER                   */
          /***************************************************************/


          /***************************************************************/
          /* (9) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
          /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
          /***************************************************************/
          IF ( p_matching_rule_code(x) IN ('1', '2') ) THEN
            FOR overlayterr IN get_OVLY_party_name(p_terr_group_id(x)) LOOP

                l_terr_usgs_tbl         := l_terr_usgs_empty_tbl;
                l_terr_qualtypeusgs_tbl := l_terr_qualtypeusgs_empty_tbl;
                l_terr_qual_tbl         := l_terr_qual_empty_tbl;
                l_terr_values_tbl       := l_terr_values_empty_tbl;
                l_TerrRsc_Tbl           := l_TerrRsc_empty_Tbl;
                l_TerrRsc_Access_Tbl    := l_TerrRsc_Access_empty_Tbl;

                l_terr_all_rec.TERR_ID                    := NULL;
                l_terr_all_rec.LAST_UPDATE_DATE           := p_last_update_date(x);
                l_terr_all_rec.LAST_UPDATED_BY            := p_last_updated_by(x);
                l_terr_all_rec.CREATION_DATE              := p_creation_date(x);
                l_terr_all_rec.CREATED_BY                 := p_created_by(x);
                l_terr_all_rec.LAST_UPDATE_LOGIN          := p_last_update_login(x);
                l_terr_all_rec.APPLICATION_SHORT_NAME     := G_APP_SHORT_NAME;
                l_terr_all_rec.NAME                       := overlayterr.name || ' (OVERLAY)';
                l_terr_all_rec.start_date_active          := p_active_from_date(x);
                l_terr_all_rec.end_date_active            := p_active_to_date(x);
                l_terr_all_rec.PARENT_TERRITORY_ID        := l_overlay_top;
                l_terr_all_rec.RANK                       := p_rank(x) + 20;
                l_terr_all_rec.TEMPLATE_TERRITORY_ID      := NULL;
                l_terr_all_rec.TEMPLATE_FLAG              := 'N';
                l_terr_all_rec.ESCALATION_TERRITORY_ID    := NULL;
                l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
                l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
                l_terr_all_rec.DESCRIPTION                := overlayterr.name || ' (OVERLAY)';
                l_terr_all_rec.UPDATE_FLAG                := 'N';
                l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;
                l_terr_all_rec.ORG_ID                     := p_org_id(x);
                l_terr_all_rec.NUM_WINNERS                := NULL ;


                SELECT JTF_TERR_USGS_S.NEXTVAL
                INTO l_terr_usg_id
                FROM DUAL;

                l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                l_terr_usgs_tbl(1).TERR_ID           := NULL;
                l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
                l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := p_last_update_date(x);
                l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := p_last_updated_by(x);
                l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := p_creation_date(x);
                l_terr_qualtypeusgs_tbl(1).CREATED_BY            := p_created_by(x);
                l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                l_terr_qualtypeusgs_tbl(1).TERR_ID               := NULL;
                l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1002;
                l_terr_qualtypeusgs_tbl(1).ORG_ID                := p_org_id(x);

                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                INTO l_terr_qtype_usg_id
                FROM DUAL;

                l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := p_last_update_date(x);
                l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := p_last_updated_by(x);
                l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := p_creation_date(x);
                l_terr_qualtypeusgs_tbl(2).CREATED_BY            := p_created_by(x);
                l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                l_terr_qualtypeusgs_tbl(2).TERR_ID               := NULL;
                l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1003;
                l_terr_qualtypeusgs_tbl(2).ORG_ID                := p_org_id(x);

                SELECT JTF_TERR_QUAL_S.NEXTVAL
                INTO l_terr_qual_id
                FROM DUAL;

                j:=0;
                K:=0;
                l_prev_qual_usg_id:=1;

                FOR qval IN match_rule1(overlayterr.named_account_id) LOOP

                    IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                        j:=j+1;
                        SELECT   JTF_TERR_QUAL_S.NEXTVAL
                        INTO l_terr_qual_id
                        FROM DUAL;

                        l_terr_qual_tbl(j).TERR_QUAL_ID         := l_terr_qual_id;
                        l_terr_qual_tbl(j).LAST_UPDATE_DATE     := p_last_update_date(x);
                        l_terr_qual_tbl(j).LAST_UPDATED_BY      := p_last_updated_by(x);
                        l_terr_qual_tbl(j).CREATION_DATE        := p_creation_date(x);
                        l_terr_qual_tbl(j).CREATED_BY           := p_created_by(x);
                        l_terr_qual_tbl(j).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                        l_terr_qual_tbl(j).TERR_ID              := NULL;
                        l_terr_qual_tbl(j).QUAL_USG_ID          := qval.qual_usg_id;
                        l_terr_qual_tbl(j).QUALIFIER_MODE       := NULL;
                        l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG := 'N';
                        l_terr_qual_tbl(j).USE_TO_NAME_FLAG     := NULL;
                        l_terr_qual_tbl(j).GENERATE_FLAG        := NULL;
                        l_terr_qual_tbl(j).ORG_ID               := p_org_id(x);
                        l_prev_qual_usg_id                      := qval.qual_usg_id;

                    END IF;

                    k:=k+1;

                    l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                    l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                    l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                    l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                    l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                    l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                    l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                    l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                    l_terr_values_tbl(k).COMPARISON_OPERATOR        := qval.COMPARISON_OPERATOR;
                    l_terr_values_tbl(k).LOW_VALUE_CHAR             := qval.value1_char;
                    l_terr_values_tbl(k).HIGH_VALUE_CHAR            := qval.value2_char;
                    l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                    l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                    l_terr_values_tbl(k).VALUE_SET                  := NULL;
                    l_terr_values_tbl(k).INTEREST_TYPE_ID           := NULL;
                    l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                    l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                    l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                    l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                    l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                    l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                    l_terr_values_tbl(k).qualifier_tbl_index        := j;

                END LOOP;

                l_init_msg_list :=FND_API.G_TRUE;

                JTF_TERRITORY_PVT.create_territory (
                    p_api_version_number         => l_api_version_number,
                    p_init_msg_list              => l_init_msg_list,
                    p_commit                     => l_commit,
                    p_validation_level           => FND_API.g_valid_level_NONE,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data,
                    p_terr_all_rec               => l_terr_all_rec,
                    p_terr_usgs_tbl              => l_terr_usgs_tbl,
                    p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                    p_terr_qual_tbl              => l_terr_qual_tbl,
                    p_terr_values_tbl            => l_terr_values_tbl,
                    x_terr_id                    => x_terr_id,
                    x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                    x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                    x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                    x_terr_values_out_tbl        => x_terr_values_out_tbl

                );

                IF G_Debug THEN
                    write_log(2,' OVERLAY Territory Created,territory_id# '||x_terr_id);
                END IF;

                IF x_return_status = 'S' THEN

                    -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                    -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                    UPDATE JTF_TERR_ALL
                    SET TERR_GROUP_FLAG = 'Y'
                      , TERR_GROUP_ID = p_terr_group_id(x)
                      , NAMED_ACCOUNT_FLAG = 'Y'
                      , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                    WHERE terr_id = x_terr_id;

                    l_overlay:=x_terr_id;

                    FOR pit IN role_pi( p_terr_group_id(x) , overlayterr.terr_group_account_id) LOOP

                        l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
                        l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
                        l_terr_qual_tbl:=l_terr_qual_empty_tbl;
                        l_terr_values_tbl:=l_terr_values_empty_tbl;
                        l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
                        l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

                        l_role_counter := l_role_counter + 1;

                        l_terr_all_rec.TERR_ID                     := overlayterr.terr_group_account_id * -40 * l_role_counter;
                        l_terr_all_rec.LAST_UPDATE_DATE            := p_last_update_date(x);
                        l_terr_all_rec.LAST_UPDATED_BY             := p_last_updated_by(x);
                        l_terr_all_rec.CREATION_DATE               := p_creation_date(x);
                        l_terr_all_rec.CREATED_BY                  := p_created_by(x);
                        l_terr_all_rec.LAST_UPDATE_LOGIN           := p_last_update_login(x);
                        l_terr_all_rec.APPLICATION_SHORT_NAME      := G_APP_SHORT_NAME;
                        l_terr_all_rec.NAME                        := overlayterr.name || ' ' || pit.role_name || ' (OVERLAY)';
                        l_terr_all_rec.start_date_active           := p_active_from_date(x);
                        l_terr_all_rec.end_date_active             := p_active_to_date(x);
                        l_terr_all_rec.PARENT_TERRITORY_ID         := l_overlay;
                        l_terr_all_rec.RANK                        := p_rank(x)+10;
                        l_terr_all_rec.TEMPLATE_TERRITORY_ID       := NULL;
                        l_terr_all_rec.TEMPLATE_FLAG               := 'N';
                        l_terr_all_rec.ESCALATION_TERRITORY_ID     := NULL;
                        l_terr_all_rec.ESCALATION_TERRITORY_FLAG   := 'N';
                        l_terr_all_rec.OVERLAP_ALLOWED_FLAG        := NULL;
                        l_terr_all_rec.DESCRIPTION                 := pit.role_code||' '||overlayterr.name||' (OVERLAY)';
                        l_terr_all_rec.UPDATE_FLAG                 := 'N';
                        l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG  := NULL;
                        l_terr_all_rec.ORG_ID                      := p_org_id(x);
                        l_terr_all_rec.NUM_WINNERS                 := NULL ;
                        l_terr_all_rec.attribute_category          := overlayterr.attribute_category;
                        l_terr_all_rec.attribute1                  := overlayterr.attribute1;
                        l_terr_all_rec.attribute2                  := overlayterr.attribute2;
                        l_terr_all_rec.attribute3                  := overlayterr.attribute3;
                        l_terr_all_rec.attribute4                  := overlayterr.attribute4;
                        l_terr_all_rec.attribute5                  := overlayterr.attribute5;
                        l_terr_all_rec.attribute6                  := overlayterr.attribute6;
                        l_terr_all_rec.attribute7                  := overlayterr.attribute7;
                        l_terr_all_rec.attribute8                  := overlayterr.attribute8;
                        l_terr_all_rec.attribute9                  := overlayterr.attribute9;
                        l_terr_all_rec.attribute10                 := overlayterr.attribute10;
                        l_terr_all_rec.attribute11                 := overlayterr.attribute11;
                        l_terr_all_rec.attribute12                 := overlayterr.attribute12;
                        l_terr_all_rec.attribute13                 := overlayterr.attribute13;
                        l_terr_all_rec.attribute14                 := overlayterr.attribute14;
                        l_terr_all_rec.attribute15                 := overlayterr.attribute15;

                        SELECT   JTF_TERR_USGS_S.NEXTVAL
                        INTO l_terr_usg_id
                        FROM DUAL;

                        l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
                        l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := p_last_update_date(x);
                        l_terr_usgs_tbl(1).LAST_UPDATED_BY   := p_last_updated_by(x);
                        l_terr_usgs_tbl(1).CREATION_DATE     := p_creation_date(x);
                        l_terr_usgs_tbl(1).CREATED_BY        := p_created_by(x);
                        l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := p_last_update_login(x);
                        l_terr_usgs_tbl(1).TERR_ID           := NULL;
                        l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
                        l_terr_usgs_tbl(1).ORG_ID            := p_org_id(x);

                        i := 0;
                        K:= 0;
                        FOR acc_type IN role_access(p_terr_group_id(x),pit.role_code) LOOP
                            --i:=i+1;
                            --dbms_output.put_line('acc type  '||acc_type.access_type);
                            IF acc_type.access_type= 'OPPORTUNITY' THEN
                                i:=i+1;
                                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                INTO l_terr_qtype_usg_id
                                FROM DUAL;

                                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1003;
                                l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                SELECT JTF_TERR_QUAL_S.NEXTVAL
                                INTO l_terr_qual_id
                                FROM DUAL;

                                /* opp expected purchase */
                                l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                l_terr_qual_tbl(i).TERR_ID              := NULL;
                                l_terr_qual_tbl(i).QUAL_USG_ID          := g_opp_qual_usg_id;
                                l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP
                                    k:=k+1;

                                    l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                    l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                    l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                    l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                    l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                    l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                    l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                    l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                    l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                    l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                    l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                    l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                    l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                    l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                    l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                    IF (g_prod_cat_enabled) THEN
                                      l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                      l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                    ELSE
                                      l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                    END IF;

                                END LOOP;

                            ELSIF acc_type.access_type= 'LEAD' THEN

                                i:=i+1;
                                SELECT   JTF_TERR_QTYPE_USGS_S.NEXTVAL
                                INTO l_terr_qtype_usg_id
                                FROM DUAL;

                                l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := p_last_update_date(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := p_last_updated_by(x);
                                l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := p_creation_date(x);
                                l_terr_qualtypeusgs_tbl(i).CREATED_BY            := p_created_by(x);
                                l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := p_last_update_login(x);
                                l_terr_qualtypeusgs_tbl(i).TERR_ID               := NULL;
                                l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1002;
                                l_terr_qualtypeusgs_tbl(i).ORG_ID                := p_org_id(x);

                                SELECT   JTF_TERR_QUAL_S.NEXTVAL
                                INTO l_terr_qual_id
                                FROM DUAL;

                                /* lead expected purchase */
                                l_terr_qual_tbl(i).TERR_QUAL_ID         := l_terr_qual_id;
                                l_terr_qual_tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                                l_terr_qual_tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                                l_terr_qual_tbl(i).CREATION_DATE        := p_creation_date(x);
                                l_terr_qual_tbl(i).CREATED_BY           := p_created_by(x);
                                l_terr_qual_tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                                l_terr_qual_tbl(i).TERR_ID              := NULL;
                                l_terr_qual_tbl(i).QUAL_USG_ID          := g_lead_qual_usg_id;
                                l_terr_qual_tbl(i).QUALIFIER_MODE       := NULL;
                                l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG := 'N';
                                l_terr_qual_tbl(i).USE_TO_NAME_FLAG     := NULL;
                                l_terr_qual_tbl(i).GENERATE_FLAG        := NULL;
                                l_terr_qual_tbl(i).ORG_ID               := p_org_id(x);

                                FOR qval IN role_pi_interest(p_terr_group_id(x),pit.role_code) LOOP

                                    k:=k+1;
                                    l_terr_values_tbl(k).TERR_VALUE_ID              := NULL;
                                    l_terr_values_tbl(k).LAST_UPDATED_BY            := p_last_updated_by(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_DATE           := p_last_update_date(x);
                                    l_terr_values_tbl(k).CREATED_BY                 := p_created_by(x);
                                    l_terr_values_tbl(k).CREATION_DATE              := p_creation_date(x);
                                    l_terr_values_tbl(k).LAST_UPDATE_LOGIN          := p_last_update_login(x);
                                    l_terr_values_tbl(k).TERR_QUAL_ID               := l_terr_qual_id ;
                                    l_terr_values_tbl(k).INCLUDE_FLAG               := NULL;
                                    l_terr_values_tbl(k).COMPARISON_OPERATOR        := '=';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR             := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_CHAR            := NULL;
                                    l_terr_values_tbl(k).LOW_VALUE_NUMBER           := NULL;
                                    l_terr_values_tbl(k).HIGH_VALUE_NUMBER          := NULL;
                                    l_terr_values_tbl(k).VALUE_SET                  := NULL;
                                    l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := NULL;
                                    l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := NULL;
                                    l_terr_values_tbl(k).CURRENCY_CODE              := NULL;
                                    l_terr_values_tbl(k).ORG_ID                     := p_org_id(x);
                                    l_terr_values_tbl(k).ID_USED_FLAG               := 'N';
                                    l_terr_values_tbl(k).LOW_VALUE_CHAR_ID          := NULL;
                                    l_terr_values_tbl(k).qualifier_tbl_index        := i;

                                    IF (g_prod_cat_enabled) THEN
                                      l_terr_values_tbl(k).value1_id                := qval.product_category_id;
                                      l_terr_values_tbl(k).value2_id                := qval.product_category_set_id;
                                    ELSE
                                      l_terr_values_tbl(k).INTEREST_TYPE_ID         := qval.interest_type_id;
                                    END IF;

                                END LOOP;

                            ELSE
                                IF G_Debug THEN
                                    write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_id(x));
                                END IF;
                                --l_terr_qualtypeusgs_tbl(1).ORG_ID:=p_ORG_ID(x);
                            END IF;

                        END LOOP;

                        l_init_msg_list :=FND_API.G_TRUE;

                        JTF_TERRITORY_PVT.create_territory (
                            p_api_version_number         => l_api_version_number,
                            p_init_msg_list              => l_init_msg_list,
                            p_commit                     => l_commit,
                            p_validation_level           => FND_API.g_valid_level_NONE,
                            x_return_status              => x_return_status,
                            x_msg_count                  => x_msg_count,
                            x_msg_data                   => x_msg_data,
                            p_terr_all_rec               => l_terr_all_rec,
                            p_terr_usgs_tbl              => l_terr_usgs_tbl,
                            p_terr_qualtypeusgs_tbl      => l_terr_qualtypeusgs_tbl,
                            p_terr_qual_tbl              => l_terr_qual_tbl,
                            p_terr_values_tbl            => l_terr_values_tbl,
                            x_terr_id                    => x_terr_id,
                            x_terr_usgs_out_tbl          => x_terr_usgs_out_tbl,
                            x_terr_qualtypeusgs_out_tbl  => x_terr_qualtypeusgs_out_tbl,
                            x_terr_qual_out_tbl          => x_terr_qual_out_tbl,
                            x_terr_values_out_tbl        => x_terr_values_out_tbl

                        );

                        IF (x_return_status = 'S') THEN

                            -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                            -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                            UPDATE JTF_TERR_ALL
                            SET TERR_GROUP_FLAG = 'Y'
                              , TERR_GROUP_ID = p_TERR_GROUP_ID(x)
                              , NAMED_ACCOUNT_FLAG = 'Y'
                              , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                            WHERE terr_id = x_terr_id;

                            IF G_Debug THEN
                              write_log(2,' OVERLAY CNR territory created:' || l_terr_all_rec.NAME);
                            END IF;

                        ELSE
                            x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                            IF G_Debug THEN
                                write_log(2,x_msg_data);
                                write_log(2,'Failed in OVERLAY CNR territory treation for ' || 'TERR_GROUP_ACCOUNT_ID = ' ||
                                                overlayterr.terr_group_account_id );
                            END IF;

                        END IF; /* IF (x_return_status = 'S') */

                        --dbms_output.put_line('pit.role '||pit.role_code);
                        i:=0;

                        /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
                        FOR rsc IN resource_grp( overlayterr.terr_group_account_id , pit.role_code) LOOP

                            i:=i+1;

                            SELECT   JTF_TERR_RSC_S.NEXTVAL
                            INTO l_terr_rsc_id
                            FROM DUAL;

                            l_TerrRsc_Tbl(i).terr_id              := x_terr_id;
                            l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
                            l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := p_last_update_date(x);
                            l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := p_last_updated_by(x);
                            l_TerrRsc_Tbl(i).CREATION_DATE        := p_creation_date(x);
                            l_TerrRsc_Tbl(i).CREATED_BY           := p_created_by(x);
                            l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := p_last_update_login(x);
                            l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
                            l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
                            l_TerrRsc_Tbl(i).ROLE                 := pit.role_code;
                            l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
                            l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := p_active_from_date(x);
                            l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := p_active_to_date(x);
                            l_TerrRsc_Tbl(i).ORG_ID               := p_org_id(x);
                            l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
                            l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
                            l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
                            l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
                            l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
                            l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
                            l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
                            l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
                            l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
                            l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
                            l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
                            l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
                            l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
                            l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
                            l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
                            l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
                            l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
                            l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;

                            a := 0;

                            FOR rsc_acc IN role_access(p_terr_group_id(x),pit.role_code) LOOP

                                IF rsc_acc.access_type= 'OPPORTUNITY' THEN

                                    a := a+1;

                                    SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                    INTO l_terr_rsc_access_id
                                    FROM DUAL;

                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                    l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                    l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                    l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'OPPOR';
                                    l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                    l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

                                ELSIF rsc_acc.access_type= 'LEAD' THEN

                                    a := a+1;

                                    SELECT   JTF_TERR_RSC_ACCESS_S.NEXTVAL
                                    INTO l_terr_rsc_access_id
                                    FROM DUAL;

                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := p_last_update_date(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := p_last_updated_by(x);
                                    l_TerrRsc_Access_Tbl(a).CREATION_DATE       := p_creation_date(x);
                                    l_TerrRsc_Access_Tbl(a).CREATED_BY          := p_created_by(x);
                                    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := p_last_update_login(x);
                                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                                    l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := 'LEAD';
                                    l_TerrRsc_Access_Tbl(a).ORG_ID              := p_org_id(x);
                                    l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;
                                END IF;
                            END LOOP; /* rsc_acc in role_access */

                            l_init_msg_list :=FND_API.G_TRUE;

                            -- 07/08/03: JDOCHERT: bug#3023653
                            Jtf_Territory_Resource_Pvt.create_terrresource (
                              p_api_version_number      => l_Api_Version_Number,
                              p_init_msg_list           => l_Init_Msg_List,
                              p_commit                  => l_Commit,
                              p_validation_level        => FND_API.g_valid_level_NONE,
                              x_return_status           => x_Return_Status,
                              x_msg_count               => x_Msg_Count,
                              x_msg_data                => x_msg_data,
                              p_terrrsc_tbl             => l_TerrRsc_tbl,
                              p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                              x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                              x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                            );

                            IF x_Return_Status='S' THEN
                                IF G_Debug THEN
                                    write_log(2,'Resource created for Product Interest OVERLAY Territory# '|| x_terr_id);
                                END IF;
                            ELSE
                                IF G_Debug THEN
                                    write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '|| x_terr_id);
                                END IF;
                            END IF;

                        END LOOP; /* rsc in resource_grp */

                    END LOOP;

                ELSE
                    IF G_Debug THEN
                        x_msg_data :=  FND_MSG_PUB.get(1, FND_API.g_false);
                        write_log(2,x_msg_data);
                        write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' || p_terr_group_id(x) || ' : ' ||
                                           p_terr_group_name(x) );
                    END IF;
                END IF;

            END LOOP;  /* for overlayterr in get_OVLY_party_name */
          END IF;    /* IF ( p_matching_rule_code(x) IN ('1', '2') ) THEN */
          /***************************************************************/
          /* (9) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
          /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
          /***************************************************************/

      END IF; /* l_pi_count*/

      IF G_Debug THEN
          write_log(2, '');
          write_log(2,'END: Territory Creation for Territory Group: ' || p_terr_group_id(x) || ' : ' ||
                        p_terr_group_name(x) );
          write_log(2, '');
          write_log(2, '----------------------------------------------------------');
      END IF;

  END LOOP;
  /****************************************************
  ** (2) END: CREATE NAMED ACCOUNT TERRITORY CREATION
  ** FOR EACH TERRITORY GROUP
  *****************************************************/

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure create_na_terr_for_TG');
      END IF;
      IF (get_NON_OVLY_na_trans%ISOPEN) THEN
        CLOSE get_NON_OVLY_na_trans;
      END IF;
      IF (role_access%ISOPEN) THEN
        CLOSE role_access;
      END IF;
      IF (NON_OVLY_role_access%ISOPEN) THEN
        CLOSE NON_OVLY_role_access;
      END IF;
      IF (role_interest_nonpi%ISOPEN) THEN
        CLOSE role_interest_nonpi;
      END IF;
      IF (role_pi%ISOPEN) THEN
        CLOSE role_pi;
      END IF;
      IF (role_pi_interest%ISOPEN) THEN
        CLOSE role_pi_interest;
      END IF;
      IF (resource_grp%ISOPEN) THEN
        CLOSE resource_grp;
      END IF;
      IF (get_party_info%ISOPEN) THEN
        CLOSE get_party_info;
      END IF;
      IF (get_party_name%ISOPEN) THEN
        CLOSE get_party_name;
      END IF;
      IF (get_OVLY_party_info%ISOPEN) THEN
        CLOSE get_OVLY_party_info;
      END IF;
      IF (get_OVLY_party_name%ISOPEN) THEN
        CLOSE get_OVLY_party_name;
      END IF;
      IF (match_rule1%ISOPEN) THEN
        CLOSE match_rule1;
      END IF;
      IF (match_rule3%ISOPEN) THEN
        CLOSE match_rule3;
      END IF;
      IF (na_access%ISOPEN) THEN
        CLOSE na_access;
      END IF;
      IF (catchall_cust%ISOPEN) THEN
        CLOSE catchall_cust;
      END IF;
      IF (topterr%ISOPEN) THEN
        CLOSE topterr;
      END IF;
      IF (csr_get_qual%ISOPEN) THEN
        CLOSE csr_get_qual;
      END IF;
      IF (csr_get_qual_val%ISOPEN) THEN
        CLOSE csr_get_qual_val;
      END IF;
      IF (role_no_pi%ISOPEN) THEN
        CLOSE role_no_pi;
      END IF;

      RAISE;
END create_na_terr_for_TG;

/*------------------------------------------------------------------------------------------
This procedure will delete and recreate the deafult territory corresponding to geo territory
-------------------------------------------------------------------------------------------*/
PROCEDURE process_parent_geo_terr(p_geo_territory_id IN NUMBER)
IS
    CURSOR geo_default_terr(l_geo_territory_id NUMBER) IS
    SELECT  B.geo_territory_id
           ,B.geo_terr_name
           ,B.terr_group_id
           ,C.rank
           ,C.active_from_date
           ,C.active_to_date
           ,C.created_by
           ,C.creation_date
           ,C.last_updated_by
           ,C.last_update_date
           ,C.last_update_login
           ,D.org_id
           ,-1 * B.terr_group_id
           ,E.terr_id
    FROM    jtf_tty_geo_terr B
           ,jtf_tty_terr_groups C
           ,jtf_terr_all D
           ,jtf_terr_all E  -- to get the terr_id of the top level territory of overlay branch
    WHERE   B.geo_territory_id = l_geo_territory_id
    AND     B.terr_group_id = C.terr_group_id
    AND     C.parent_terr_id = D.terr_id
    AND     E.terr_group_id(+) = C.terr_group_id  -- outer-join is necessary as overlay branch may not exist
    AND     E.name(+) = C.terr_group_name || ' (OVERLAY)'
    AND     E.terr_group_flag(+) = 'Y';

   l_geo_territory_id            g_geo_territory_id_tab;
   l_geo_terr_name               g_geo_terr_name_tab;
   l_terr_group_id               g_terr_group_id_tab;
   l_rank                        g_rank_tab;
   l_active_from_date            g_active_from_date_tab;
   l_active_to_date              g_active_to_date_tab;
   l_created_by                  g_created_by_tab;
   l_creation_date               g_creation_date_tab;
   l_last_updated_by             g_last_updated_by_tab;
   l_last_update_date            g_last_update_date_tab;
   l_last_update_login           g_last_update_login_tab;
   l_org_id                      g_ORG_ID_tab;
   l_terr_id                     g_terr_id_tab;
   l_overlay_top                 g_terr_id_tab;

   l_no_of_records  NUMBER;
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Inside process_parent_geo_terr : open the cursor geo_default_terr');
    END IF;

    -- open the cursor
    OPEN geo_default_terr(p_geo_territory_id);

    -- loop till all the geo territories that have been created/updated are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of territories');
      END IF;

      /* Bulk collect geo territories information and process them row by row */
      FETCH geo_default_terr BULK COLLECT INTO
         l_geo_territory_id
        ,l_geo_terr_name
        ,l_terr_group_id
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_org_id
        ,l_terr_id
        ,l_overlay_top
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_geo_territory_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

              IF G_Debug THEN
                  Write_Log(2, 'Start : create_geo_terr_for_GT');
              END IF;

              create_geo_terr_for_GT(
                  l_geo_territory_id
                 ,l_geo_terr_name
                 ,l_terr_group_id
                 ,l_rank
                 ,l_active_from_date
                 ,l_active_to_date
                 ,l_created_by
                 ,l_creation_date
                 ,l_last_updated_by
                 ,l_last_update_date
                 ,l_last_update_login
                 ,l_org_id
                 ,l_terr_id
                 ,l_overlay_top);

              IF G_Debug THEN
                  Write_Log(2, 'End : create_geo_terr_for_GT');
              END IF;

              /* trim the pl/sql tables to free up memory */
              l_geo_territory_id.TRIM(l_no_of_records);
              l_geo_terr_name.TRIM(l_no_of_records);
              l_terr_group_id.TRIM(l_no_of_records);
              l_rank.TRIM(l_no_of_records);
              l_active_from_date.TRIM(l_no_of_records);
              l_active_to_date.TRIM(l_no_of_records);
              l_created_by.TRIM(l_no_of_records);
              l_creation_date.TRIM(l_no_of_records);
              l_last_updated_by.TRIM(l_no_of_records);
              l_last_update_date.TRIM(l_no_of_records);
              l_last_update_login.TRIM(l_no_of_records);
              l_ORG_ID.TRIM(l_no_of_records);
              l_terr_id.TRIM(l_no_of_records);
              l_overlay_top.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of geo territories');
      END IF;

      EXIT WHEN geo_default_terr%NOTFOUND;

    END LOOP;

    CLOSE geo_default_terr;

    IF G_Debug THEN
        Write_Log(2, 'Finish process_parent_geo_terr');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'process_parent_geo_terr : Error in procedure process_parent_geo_terr');
      END IF;
      RAISE;
      IF (geo_default_terr%ISOPEN) THEN
        CLOSE geo_default_terr;
      END IF;
END process_parent_geo_terr;

PROCEDURE Initialize
IS
  l_status   VARCHAR2(30);
  l_industry VARCHAR2(30);
  l_flag     VARCHAR2(1);
BEGIN
     G_DEBUG := FALSE;
      /* Set Global Application Short Name */
      IF G_APP_SHORT_NAME IS NULL THEN
        G_APP_SHORT_NAME := 'JTF';
      END IF;

      -- Get the schema name for JTF
      IF(Fnd_Installation.GET_APP_INFO('JTF', l_status, l_industry, g_jtf_schema)) THEN
         NULL;
      END IF;

     IF (Fnd_Profile.DEFINED('JTF_TTY_PROD_CAT_ENABLED')) THEN
        l_flag := NVL(Fnd_Profile.VALUE('JTF_TTY_PROD_CAT_ENABLED'), 'N');
        IF (l_flag = 'N') THEN
          g_prod_cat_enabled := FALSE;
        ELSE
          g_prod_cat_enabled := TRUE;
        END IF;
      ELSE
        g_prod_cat_enabled := FALSE;
      END IF;
      IF (g_prod_cat_enabled) THEN
        g_opp_qual_usg_id := -1142;
        g_lead_qual_usg_id := -1131;
      ELSE
        g_opp_qual_usg_id := -1023;
        g_lead_qual_usg_id := -1018;
      END IF;
END Initialize;
/*------------------------------------------------------------
This procedure will create/update territories corresponding to
the geography territories that have been updated
-------------------------------------------------------------*/
PROCEDURE create_terr_for_gt(p_geo_terr_id IN NUMBER,
                             p_from_where  IN VARCHAR2)
IS
    CURSOR geo_terr_update(l_geo_terr_id NUMBER) IS
    SELECT  p_from_where from_where
           ,p_geo_terr_id geo_territory_id
           ,B.geo_terr_name
           ,B.terr_group_id
           ,C.rank
           ,C.active_from_date
           ,C.active_to_date
           ,C.created_by
           ,C.creation_date
           ,C.last_updated_by
           ,C.last_update_date
           ,C.last_update_login
           ,D.org_id
           ,-1 * B.terr_group_id
           ,E.terr_id
    FROM    jtf_tty_geo_terr B
           ,jtf_tty_terr_groups C
           ,jtf_terr_all D
           ,jtf_terr_all E  -- to get the terr_id of the top level territory of overlay branch
    WHERE   B.geo_territory_id = l_geo_terr_id
    AND     B.terr_group_id = C.terr_group_id
    AND     C.parent_terr_id = D.terr_id
    AND     E.terr_group_id(+) = C.terr_group_id  -- outer-join is necessary as overlay branch may not exist
    AND     E.name(+) = C.terr_group_name || ' (OVERLAY)'
    AND     E.terr_group_flag(+) = 'Y';

    /* All the child territories of the territories that have been updated */
    CURSOR child_terr(l_geo_terr_id NUMBER) IS
    SELECT geo_territory_id
    FROM JTF_TTY_GEO_TERR
    WHERE geo_territory_id <> l_geo_terr_id
    START WITH geo_territory_id = l_geo_terr_id
    CONNECT BY PRIOR geo_territory_id = parent_geo_terr_id;

   l_geo_territory_id            g_geo_territory_id_tab;
   l_geo_terr_name               g_geo_terr_name_tab;
   l_terr_group_id               g_terr_group_id_tab;
   l_rank                        g_rank_tab;
   l_active_from_date            g_active_from_date_tab;
   l_active_to_date              g_active_to_date_tab;
   l_created_by                  g_created_by_tab;
   l_creation_date               g_creation_date_tab;
   l_last_updated_by             g_last_updated_by_tab;
   l_last_update_date            g_last_update_date_tab;
   l_last_update_login           g_last_update_login_tab;
   l_org_id                      g_ORG_ID_tab;
   l_terr_id                     g_terr_id_tab;
   l_overlay_top                 g_terr_id_tab;
   l_from_where                  g_from_where_tab;
   l_child_geo_terr_id           g_geo_territory_id_tab;

   l_no_of_records  NUMBER;
   l_no_of_records1 NUMBER;
   l_parent_geo_terr_id NUMBER;
BEGIN
    Initialize;
    IF G_Debug THEN
        Write_Log(2, 'Open the cursor geo_terr_update');
    END IF;

    -- open the cursor
    OPEN geo_terr_update(p_geo_terr_id);

    -- loop till all the GTs that have been created/updated are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of GTs');
      END IF;

      /* Bulk collect GT information and process them row by row */
      FETCH geo_terr_update BULK COLLECT INTO
         l_from_where
        ,l_geo_territory_id
        ,l_geo_terr_name
        ,l_terr_group_id
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_org_id
        ,l_terr_id
        ,l_overlay_top
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_geo_territory_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

              IF G_Debug THEN
                  Write_Log(2, 'Start : create_geo_terr_for_GT');
              END IF;

              create_geo_terr_for_GT(
                  l_geo_territory_id
                 ,l_geo_terr_name
                 ,l_terr_group_id
                 ,l_rank
                 ,l_active_from_date
                 ,l_active_to_date
                 ,l_created_by
                 ,l_creation_date
                 ,l_last_updated_by
                 ,l_last_update_date
                 ,l_last_update_login
                 ,l_org_id
                 ,l_terr_id
                 ,l_overlay_top);

              IF G_Debug THEN
                  Write_Log(2, 'End : create_geo_terr_for_GT');
              END IF;

              FOR i IN l_geo_territory_id.FIRST .. l_geo_territory_id.LAST LOOP

                IF (l_from_where(i) = 'Update Mapping') THEN
                  BEGIN
                    /* Get the parent territory id and recreate it */
                    SELECT A.parent_geo_terr_id
                    INTO   l_parent_geo_terr_id
                    FROM   jtf_tty_geo_terr A
                    WHERE  A.geo_territory_id = l_geo_territory_id(i);

                    IF G_Debug THEN
                        Write_Log(2, 'Start : process_parent_geo_terr');
                    END IF;

                    process_parent_geo_terr(l_parent_geo_terr_id);

                    IF G_Debug THEN
                        Write_Log(2, 'End : process_parent_geo_terr');
                    END IF;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                  END;

                  /* Get all the child territories and recreate it */
                  -- open the cursor
                  OPEN child_terr(l_geo_territory_id(i));

                  LOOP

                    /* Bulk collect TGA information and process them row by row */
                    FETCH child_terr BULK COLLECT INTO
                       l_child_geo_terr_id
                    LIMIT g_commit_chunk_size;

                    /* Get the number of rows returned by the fetch */
                    l_no_of_records1 := l_child_geo_terr_id.COUNT;

                    IF (l_no_of_records1 > 0) THEN
                      FOR j IN l_child_geo_terr_id.FIRST .. l_child_geo_terr_id.LAST LOOP
                        process_parent_geo_terr(l_child_geo_terr_id(j));
                      END LOOP;

                      /* trim the pl/sql tables to free up memory */
                      l_child_geo_terr_id.TRIM(l_no_of_records1);

                    END IF;

                    EXIT WHEN child_terr%NOTFOUND;

                  END LOOP;

                  CLOSE child_terr;

                END IF; /* end if l_from_where(i) = 'Update Mapping' */

              END LOOP;

              /* trim the pl/sql tables to free up memory */
              l_geo_territory_id.TRIM(l_no_of_records);
              l_geo_terr_name.TRIM(l_no_of_records);
              l_terr_group_id.TRIM(l_no_of_records);
              l_rank.TRIM(l_no_of_records);
              l_active_from_date.TRIM(l_no_of_records);
              l_active_to_date.TRIM(l_no_of_records);
              l_created_by.TRIM(l_no_of_records);
              l_creation_date.TRIM(l_no_of_records);
              l_last_updated_by.TRIM(l_no_of_records);
              l_last_update_date.TRIM(l_no_of_records);
              l_last_update_login.TRIM(l_no_of_records);
              l_ORG_ID.TRIM(l_no_of_records);
              l_terr_id.TRIM(l_no_of_records);
              l_overlay_top.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of GTs');
      END IF;

      EXIT WHEN geo_terr_update%NOTFOUND;

    END LOOP;

    CLOSE geo_terr_update;
    -- No commit required if updating geography territory
    -- from web adi excel document
    IF (p_from_where = 'Update Geography Territory Sales Team') THEN
       COMMIT;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure process_GT_update');
      END IF;
      IF (geo_terr_update%ISOPEN) THEN
        CLOSE geo_terr_update;
      END IF;
      IF (child_terr%ISOPEN) THEN
        CLOSE child_terr;
      END IF;
      RAISE;
END create_terr_for_gt;

/*------------------------------------------------------------
This procedure will create/update territories corresponding to
the territory group account that have been updated
-------------------------------------------------------------*/
PROCEDURE process_TGA_update
IS

    /* Territory groups that are created/updated */
    CURSOR terr_grp_acct(l_date DATE) IS
    SELECT A.terr_group_account_id
          ,C.terr_group_id
          ,C.rank
          ,C.active_from_date
          ,C.active_to_date
          ,C.matching_rule_code
          ,C.generate_catchall_flag
          ,C.created_by
          ,C.creation_date
          ,C.last_updated_by
          ,C.last_update_date
          ,C.last_update_login
          ,D.ORG_ID
          ,F.terr_id  --  placeholder territory for non-overlay branch
          ,E.terr_id  -- placeholder territory for overlay branch
          ,C.terr_group_id * -1  -- catch-all territory id
          -- if the change type is both sales team update and mapping update , we need to process only mapping update
          ,MIN(A.change_type) change_type
          ,to_char(null) -- attribute_category
          ,B.attribute1
          ,B.attribute2
          ,B.attribute3
          ,B.attribute4
          ,B.attribute5
          ,B.attribute6
          ,B.attribute7
          ,B.attribute8
          ,B.attribute9
          ,B.attribute10
          ,B.attribute11
          ,B.attribute12
          ,B.attribute13
          ,B.attribute14
          ,B.attribute15
    FROM (
      /* Get the territory group account for which the sales team has been updated */
      SELECT A.OBJECT_ID          terr_group_account_id
            ,'SALES_TEAM_UPDATE'  change_type
      FROM JTF_TTY_NAMED_ACCT_CHANGES A
      WHERE A.creation_date   <= l_date
      AND   A.change_type = 'UPDATE'
      AND   A.object_type = 'TGA'
      AND NOT EXISTS
            /* if the territory group account is already deleted , no need to process the insert/update */
            ( SELECT 1
              FROM   jtf_tty_named_acct_changes B
              WHERE  A.object_id = B.object_id
              AND    B.object_type = 'TGA'
              AND    B.change_type = 'DELETE')
      UNION
      /* Get the territory group account for which the mapping **
      ** of the corresponding named account has been updated   */
      SELECT B.terr_group_account_id  terr_group_account_id
            ,'MAPPING_UPDATE'          change_type
      FROM   jtf_tty_named_acct_changes A
            ,jtf_tty_terr_grp_accts  B
      WHERE A.creation_date   <= l_date
      AND   A.change_type = 'UPDATE'
      AND   A.object_type = 'NA'
      AND   A.object_id = B.named_account_id) A
     ,jtf_tty_terr_grp_accts B
     ,jtf_tty_terr_groups C
     ,jtf_terr_all D  -- to get the org_id of the parent territory
     ,jtf_terr_all E  -- to get the terr_id of the top level territory of overlay branch
     ,jtf_terr_all F  -- to get the terr_id for the placeholder territory of non-overlay branch
    WHERE A.terr_group_account_id = B.terr_group_account_id
    AND   B.terr_group_id = C.terr_group_id
    AND   C.parent_terr_id = D.terr_id
    AND   E.terr_group_id(+) = C.terr_group_id  -- outer-join is necessary as overlay branch may not exist
    AND   E.name(+) = C.terr_group_name || ' (OVERLAY)'
    AND   E.terr_group_flag(+) = 'Y'
    AND   F.terr_group_id = C.terr_group_id  -- outer-join is necessary as overlay branch may not exist
    AND   F.name = C.terr_group_name
    AND   F.terr_group_flag = 'Y'
    AND   NVL(F.named_account_flag ,'N') <> 'Y'
    /* no need to process the TGA if it is part of the TG that has been updated */
    AND   NOT EXISTS (
            SELECT 1
            FROM   jtf_tty_named_acct_changes F
            WHERE  F.object_type = 'TG'
            AND    F.object_id = C.terr_group_id
            AND    F.creation_date <= l_date)
    GROUP BY
           A.terr_group_account_id
          ,C.terr_group_id
          ,C.rank
          ,C.active_from_date
          ,C.active_to_date
          ,C.matching_rule_code
          ,C.generate_catchall_flag
          ,C.created_by
          ,C.creation_date
          ,C.last_updated_by
          ,C.last_update_date
          ,C.last_update_login
          ,D.ORG_ID
          ,F.terr_id
          ,E.terr_id
          ,C.terr_group_id * -1
          ,B.attribute1
          ,B.attribute2
          ,B.attribute3
          ,B.attribute4
          ,B.attribute5
          ,B.attribute6
          ,B.attribute7
          ,B.attribute8
          ,B.attribute9
          ,B.attribute10
          ,B.attribute11
          ,B.attribute12
          ,B.attribute13
          ,B.attribute14
          ,B.attribute15;

   l_terr_group_account_id       g_terr_group_account_id_tab;
   l_terr_group_id               g_terr_group_id_tab;
   l_rank                        g_rank_tab;
   l_active_from_date            g_active_from_date_tab;
   l_active_to_date              g_active_to_date_tab;
   l_matching_rule_code          g_matching_rule_code_tab;
   l_generate_catchall_flag      g_generate_catchall_flag_tab;
   l_created_by                  g_created_by_tab;
   l_creation_date               g_creation_date_tab;
   l_last_updated_by             g_last_updated_by_tab;
   l_last_update_date            g_last_update_date_tab;
   l_last_update_login           g_last_update_login_tab;
   l_org_id                      g_ORG_ID_tab;
   l_terr_id                     g_terr_id_tab;
   l_overlay_top                 g_terr_id_tab;
   l_catchall_terr_id            g_terr_id_tab;
   l_change_type                 g_change_type_tab;
   l_terr_attr_cat               g_terr_attr_cat_tab;
   l_terr_attribute1             g_terr_attribute_tab;
   l_terr_attribute2             g_terr_attribute_tab;
   l_terr_attribute3             g_terr_attribute_tab;
   l_terr_attribute4             g_terr_attribute_tab;
   l_terr_attribute5             g_terr_attribute_tab;
   l_terr_attribute6             g_terr_attribute_tab;
   l_terr_attribute7             g_terr_attribute_tab;
   l_terr_attribute8             g_terr_attribute_tab;
   l_terr_attribute9             g_terr_attribute_tab;
   l_terr_attribute10            g_terr_attribute_tab;
   l_terr_attribute11            g_terr_attribute_tab;
   l_terr_attribute12            g_terr_attribute_tab;
   l_terr_attribute13            g_terr_attribute_tab;
   l_terr_attribute14            g_terr_attribute_tab;
   l_terr_attribute15            g_terr_attribute_tab;

   l_no_of_records  NUMBER;
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Open the cursor terr_grp_acct');
    END IF;

    -- open the cursor
    OPEN terr_grp_acct(g_cutoff_time);

    -- loop till all the TGAs that have been created/updated are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGAs');
      END IF;

      /* Bulk collect TGA information and process them row by row */
      FETCH terr_grp_acct BULK COLLECT INTO
         l_terr_group_account_id
        ,l_terr_group_id
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_matching_rule_code
        ,l_generate_catchall_flag
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_ORG_ID
        ,l_terr_id
        ,l_overlay_top
        ,l_catchall_terr_id
        ,l_change_type
        ,l_terr_attr_cat
        ,l_terr_attribute1
        ,l_terr_attribute2
        ,l_terr_attribute3
        ,l_terr_attribute4
        ,l_terr_attribute5
        ,l_terr_attribute6
        ,l_terr_attribute7
        ,l_terr_attribute8
        ,l_terr_attribute9
        ,l_terr_attribute10
        ,l_terr_attribute11
        ,l_terr_attribute12
        ,l_terr_attribute13
        ,l_terr_attribute14
        ,l_terr_attribute15
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_account_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

              IF G_Debug THEN
                  Write_Log(2, 'Start : create_na_terr_for_TGA');
              END IF;

              -- create territories for the territory group account
              create_na_terr_for_TGA(
                  l_terr_group_account_id
                 ,l_terr_group_id
                 ,l_rank
                 ,l_active_from_date
                 ,l_active_to_date
                 ,l_matching_rule_code
                 ,l_generate_catchall_flag
                 ,l_created_by
                 ,l_creation_date
                 ,l_last_updated_by
                 ,l_last_update_date
                 ,l_last_update_login
                 ,l_ORG_ID
                 ,l_terr_id
                 ,l_overlay_top
                 ,l_catchall_terr_id
                 ,l_change_type
                 ,l_terr_attr_cat
                 ,l_terr_attribute1
                 ,l_terr_attribute2
                 ,l_terr_attribute3
                 ,l_terr_attribute4
                 ,l_terr_attribute5
                 ,l_terr_attribute6
                 ,l_terr_attribute7
                 ,l_terr_attribute8
                 ,l_terr_attribute9
                 ,l_terr_attribute10
                 ,l_terr_attribute11
                 ,l_terr_attribute12
                 ,l_terr_attribute13
                 ,l_terr_attribute14
                 ,l_terr_attribute15);

              IF G_Debug THEN
                  Write_Log(2, 'End : create_na_terr_for_TGA');
              END IF;

              /* trim the pl/sql tables to free up memory */
              l_terr_group_account_id.TRIM(l_no_of_records);
              l_terr_group_id.TRIM(l_no_of_records);
              l_rank.TRIM(l_no_of_records);
              l_active_from_date.TRIM(l_no_of_records);
              l_active_to_date.TRIM(l_no_of_records);
              l_matching_rule_code.TRIM(l_no_of_records);
              l_generate_catchall_flag.TRIM(l_no_of_records);
              l_created_by.TRIM(l_no_of_records);
              l_creation_date.TRIM(l_no_of_records);
              l_last_updated_by.TRIM(l_no_of_records);
              l_last_update_date.TRIM(l_no_of_records);
              l_last_update_login.TRIM(l_no_of_records);
              l_ORG_ID.TRIM(l_no_of_records);
              l_terr_id.TRIM(l_no_of_records);
              l_overlay_top.TRIM(l_no_of_records);
              l_catchall_terr_id.TRIM(l_no_of_records);
              l_change_type.TRIM(l_no_of_records);
              l_terr_attr_cat.TRIM(l_no_of_records);
              l_terr_attribute1.TRIM(l_no_of_records);
              l_terr_attribute2.TRIM(l_no_of_records);
              l_terr_attribute3.TRIM(l_no_of_records);
              l_terr_attribute4.TRIM(l_no_of_records);
              l_terr_attribute5.TRIM(l_no_of_records);
              l_terr_attribute6.TRIM(l_no_of_records);
              l_terr_attribute7.TRIM(l_no_of_records);
              l_terr_attribute8.TRIM(l_no_of_records);
              l_terr_attribute9.TRIM(l_no_of_records);
              l_terr_attribute10.TRIM(l_no_of_records);
              l_terr_attribute11.TRIM(l_no_of_records);
              l_terr_attribute12.TRIM(l_no_of_records);
              l_terr_attribute13.TRIM(l_no_of_records);
              l_terr_attribute14.TRIM(l_no_of_records);
              l_terr_attribute15.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of TGAs');
      END IF;

      EXIT WHEN terr_grp_acct%NOTFOUND;

    END LOOP;

    CLOSE terr_grp_acct;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure process_TGA_update');
      END IF;
      IF (terr_grp_acct%ISOPEN) THEN
        CLOSE terr_grp_acct;
      END IF;
      RAISE;
END process_TGA_update;

/*----------------------------------------------------------
This procedure will create/update territories corresponding to
the territory groups that have been created or updated
----------------------------------------------------------*/
PROCEDURE process_TG_update
IS

    /* Named Account Territory groups that are created/updated */
    CURSOR na_terr_grp(l_date DATE) IS
    SELECT   A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.MATCHING_RULE_CODE
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.Catch_all_resource_id
           , A.catch_all_resource_type
           , A.generate_catchall_flag
           , A.NUM_WINNERS
           , B.ORG_ID
           , MIN(C.change_type) change_type
           -- if there is both insert and update to a territory group , we need to process only the insert
    FROM JTF_TTY_TERR_GROUPS A
        ,JTF_TERR_ALL B
        ,JTF_TTY_NAMED_ACCT_CHANGES C
    WHERE C.creation_date   <= l_date
    AND   C.change_type IN ('INSERT', 'UPDATE')
    AND   C.object_type = 'TG'
    AND   C.object_id = A.terr_group_id
    AND   A.parent_terr_id = B.terr_id
    AND   A.self_service_type = 'NAMED_ACCOUNT'
    AND NOT EXISTS
          /* if the territory group is already deleted , no need to process the insert/update */
          ( SELECT 1
            FROM   jtf_tty_named_acct_changes D
            WHERE  D.object_id = C.object_id
            AND    D.object_type = 'TG'
            AND    D.change_type = 'DELETE')
    GROUP BY
             A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.MATCHING_RULE_CODE
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.Catch_all_resource_id
           , A.catch_all_resource_type
           , A.generate_catchall_flag
           , A.NUM_WINNERS
           , B.ORG_ID;

    /* Geography Territory groups that are created/updated */
    CURSOR geo_terr_grp(l_date DATE) IS
    SELECT   A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.NUM_WINNERS
           , B.ORG_ID
           , MIN(C.change_type) change_type
           -- if there is both insert and update to a territory group , we need to process only the insert
    FROM JTF_TTY_TERR_GROUPS A
        ,JTF_TERR_ALL B
        ,JTF_TTY_NAMED_ACCT_CHANGES C
    WHERE C.creation_date   <= l_date
    AND   C.change_type IN ('INSERT', 'UPDATE')
    AND   C.object_type = 'TG'
    AND   C.object_id = A.terr_group_id
    AND   A.parent_terr_id = B.terr_id
    AND   A.self_service_type = 'GEOGRAPHY'
    AND NOT EXISTS
          /* if the territory group is already deleted , no need to process the insert/update */
          ( SELECT 1
            FROM   jtf_tty_named_acct_changes D
            WHERE  D.object_id = C.object_id
            AND    D.object_type = 'TG'
            AND    D.change_type = 'DELETE')
    GROUP BY
             A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.MATCHING_RULE_CODE
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.Catch_all_resource_id
           , A.catch_all_resource_type
           , A.generate_catchall_flag
           , A.NUM_WINNERS
           , B.ORG_ID;

   l_terr_group_id             g_terr_group_id_tab;
   l_terr_group_name           g_terr_group_name_tab;
   l_rank                      g_rank_tab;
   l_active_from_date          g_active_from_date_tab;
   l_active_to_date            g_active_to_date_tab;
   l_parent_terr_id            g_parent_terr_id_tab;
   l_matching_rule_code        g_matching_rule_code_tab;
   l_created_by                g_created_by_tab;
   l_creation_date             g_creation_date_tab;
   l_last_updated_by           g_last_updated_by_tab;
   l_last_update_date          g_last_update_date_tab;
   l_last_update_login         g_last_update_login_tab;
   l_catch_all_resource_id     g_catch_all_resource_id_tab;
   l_catch_all_resource_type   g_catch_all_resource_type_tab;
   l_generate_catchall_flag    g_generate_catchall_flag_tab;
   l_num_winners               g_num_winners_tab;
   l_org_id                    g_org_id_tab;
   l_change_type               g_change_type_tab;

   l_no_of_records             NUMBER;
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'Opening the cursor na_terr_grp');
    END IF;

    /* Process the named account territory groups */
    -- open the cursor
    OPEN na_terr_grp(g_cutoff_time);

    -- loop till all the TGs that have been created/updated are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGs');
      END IF;

      /* Bulk collect TG information and process them row by row */
      FETCH na_terr_grp BULK COLLECT INTO
         l_terr_group_id
        ,l_terr_group_name
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_parent_terr_id
        ,l_matching_rule_code
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_catch_all_resource_id
        ,l_catch_all_resource_type
        ,l_generate_catchall_flag
        ,l_num_winners
        ,l_org_id
        ,l_change_type
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

          IF G_Debug THEN
            Write_Log(2, 'START: create_na_terr_for_TG');
          END IF;

          create_na_terr_for_TG (
              l_terr_group_id
             ,l_terr_group_name
             ,l_rank
             ,l_active_from_date
             ,l_active_to_date
             ,l_parent_terr_id
             ,l_matching_rule_code
             ,l_created_by
             ,l_creation_date
             ,l_last_updated_by
             ,l_last_update_date
             ,l_last_update_login
             ,l_catch_all_resource_id
             ,l_catch_all_resource_type
             ,l_generate_catchall_flag
             ,l_num_winners
             ,l_org_id
             ,l_change_type
             ,NULL
				 ,NULL
				 ,NULL);

          IF G_Debug THEN
            Write_Log(2, 'END: create_na_terr_for_TG');
          END IF;

          /* trim the pl/sql tables to free up memory */
          l_terr_group_id.TRIM(l_no_of_records);
          l_terr_group_name.TRIM(l_no_of_records);
          l_rank.TRIM(l_no_of_records);
          l_active_from_date.TRIM(l_no_of_records);
          l_active_to_date.TRIM(l_no_of_records);
          l_parent_terr_id.TRIM(l_no_of_records);
          l_matching_rule_code.TRIM(l_no_of_records);
          l_created_by.TRIM(l_no_of_records);
          l_creation_date.TRIM(l_no_of_records);
          l_last_updated_by.TRIM(l_no_of_records);
          l_last_update_date.TRIM(l_no_of_records);
          l_last_update_login.TRIM(l_no_of_records);
          l_catch_all_resource_id.TRIM(l_no_of_records);
          l_catch_all_resource_type.TRIM(l_no_of_records);
          l_generate_catchall_flag.TRIM(l_no_of_records);
          l_num_winners.TRIM(l_no_of_records);
          l_org_id.TRIM(l_no_of_records);
          l_change_type.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of TGs');
      END IF;

      EXIT WHEN na_terr_grp%NOTFOUND;

    END LOOP;

    CLOSE na_terr_grp;
    /* End process named account territory groups */

    /* Process the geography territory groups */
    -- open the cursor
    OPEN geo_terr_grp(g_cutoff_time);

    -- loop till all the TGs that have been created/updated are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGs');
      END IF;

      /* Bulk collect TG information and process them row by row */
      FETCH geo_terr_grp BULK COLLECT INTO
         l_terr_group_id
        ,l_terr_group_name
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_parent_terr_id
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_num_winners
        ,l_org_id
        ,l_change_type
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

          IF G_Debug THEN
            Write_Log(2, 'START: create_geo_terr_for_TG');
          END IF;

          create_geo_terr_for_TG (
              l_terr_group_id
             ,l_terr_group_name
             ,l_rank
             ,l_active_from_date
             ,l_active_to_date
             ,l_parent_terr_id
             ,l_created_by
             ,l_creation_date
             ,l_last_updated_by
             ,l_last_update_date
             ,l_last_update_login
             ,l_num_winners
             ,l_org_id
             ,l_change_type);

          IF G_Debug THEN
            Write_Log(2, 'END: create_geo_terr_for_TG');
          END IF;

          /* trim the pl/sql tables to free up memory */
          l_terr_group_id.TRIM(l_no_of_records);
          l_terr_group_name.TRIM(l_no_of_records);
          l_rank.TRIM(l_no_of_records);
          l_active_from_date.TRIM(l_no_of_records);
          l_active_to_date.TRIM(l_no_of_records);
          l_parent_terr_id.TRIM(l_no_of_records);
          l_created_by.TRIM(l_no_of_records);
          l_creation_date.TRIM(l_no_of_records);
          l_last_updated_by.TRIM(l_no_of_records);
          l_last_update_date.TRIM(l_no_of_records);
          l_last_update_login.TRIM(l_no_of_records);
          l_num_winners.TRIM(l_no_of_records);
          l_org_id.TRIM(l_no_of_records);
          l_change_type.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of TGs');
      END IF;

      EXIT WHEN geo_terr_grp%NOTFOUND;

    END LOOP;

    CLOSE geo_terr_grp;
    /* End process geography territory groups */

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure process_TG_update');
      END IF;
      IF (na_terr_grp%ISOPEN) THEN
        CLOSE na_terr_grp;
      END IF;
      IF (geo_terr_grp%ISOPEN) THEN
        CLOSE geo_terr_grp;
      END IF;
      RAISE;
END process_TG_update;

/*----------------------------------------------------------
This procedure will delete territories corresponding to the
geography territories that have been deleted
----------------------------------------------------------*/
PROCEDURE process_GT_delete
IS

    /* Geography territories that are deleted */
    CURSOR geo_terr_delete(l_date DATE) IS
    SELECT  DISTINCT A.object_id
    FROM    jtf_tty_named_acct_changes A
           ,jtf_terr_all B
    WHERE   A.creation_date <= l_date
    AND     A.change_type = 'DELETE'
    AND     A.object_type = 'GT'
    AND     A.object_id = B.geo_territory_id
    /* no need to process the deleted GT if the corresponding TG has been updated */
    AND   NOT EXISTS (
            SELECT 1
            FROM   jtf_tty_named_acct_changes F
            WHERE  F.object_type = 'TG'
            AND    F.object_id = B.terr_group_id
            AND    F.creation_date <= l_date);

    /* Parent of the geography territories that are deleted */
    CURSOR geo_terr_parent_delete(l_date DATE) IS
    SELECT  DISTINCT A.object_id
    FROM    jtf_tty_named_acct_changes A
           ,jtf_terr_all B
    WHERE   A.creation_date <= l_date
    AND     A.change_type = 'DELETE PARENT'
    AND     A.object_type = 'GT'
    AND     A.object_id = B.geo_territory_id
    /* no need to process the GT if the corresponding TG has been updated */
    AND   NOT EXISTS (
            SELECT 1
            FROM   jtf_tty_named_acct_changes F
            WHERE  F.object_type = 'TG'
            AND    F.object_id = B.terr_group_id
            AND    F.creation_date <= l_date);

   l_geo_territory_id       g_geo_territory_id_tab;

   l_no_of_records  NUMBER;
BEGIN
    IF G_Debug THEN
        Write_Log(2, 'open the cursor geo_terr_delete');
    END IF;

    -- open the cursor
    OPEN geo_terr_delete(g_cutoff_time);

    -- loop till all the GTs that have been deleted are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of GTs');
      END IF;

      /* Bulk collect GT information and process them row by row */
      FETCH geo_terr_delete BULK COLLECT INTO
          l_geo_territory_id
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_geo_territory_id.COUNT;

      /* process the return set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

          FOR i IN l_geo_territory_id.FIRST .. l_geo_territory_id.LAST LOOP

              IF G_Debug THEN
                Write_Log(2, 'START: delete_geo_terr');
              END IF;

              delete_geo_terr(l_geo_territory_id(i));

              IF G_Debug THEN
                Write_Log(2, 'END: delete_geo_terr');
                Write_Log(2, 'All the territories corresponding to the geography territory ' || l_geo_territory_id(i) ||
                                ' have been deleted successfully.');
              END IF;

          END LOOP;

          /* trim the pl/sql tables to free up memory */
          l_geo_territory_id.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of GTs');
      END IF;

      EXIT WHEN geo_terr_delete%NOTFOUND;

    END LOOP;

    CLOSE geo_terr_delete;

    IF G_Debug THEN
        Write_Log(2, 'open the cursor geo_terr_parent_delete');
    END IF;

    -- open the cursor
    OPEN geo_terr_parent_delete(g_cutoff_time);

    -- loop till all the GTs that have been deleted are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of GTs');
      END IF;

      /* Bulk collect GT information and process them row by row */
      FETCH geo_terr_parent_delete BULK COLLECT INTO
          l_geo_territory_id
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_geo_territory_id.COUNT;

      /* process the return set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

          FOR i IN l_geo_territory_id.FIRST .. l_geo_territory_id.LAST LOOP

              IF G_Debug THEN
                Write_Log(2, 'START: process_parent_geo_terr');
              END IF;

              /* Delete and recreate the default geography territory */
              process_parent_geo_terr(l_geo_territory_id(i));

              IF G_Debug THEN
                Write_Log(2, 'END: process_parent_geo_terr');
              END IF;
          END LOOP;

          /* trim the pl/sql tables to free up memory */
          l_geo_territory_id.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of GTs');
      END IF;

      EXIT WHEN geo_terr_parent_delete%NOTFOUND;

    END LOOP;

    CLOSE geo_terr_parent_delete;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure process_GT_delete');
      END IF;
      IF (geo_terr_delete%ISOPEN) THEN
        CLOSE geo_terr_delete;
      END IF;
      IF (geo_terr_parent_delete%ISOPEN) THEN
        CLOSE geo_terr_parent_delete;
      END IF;
      RAISE;
END process_GT_delete;

/*----------------------------------------------------------
This procedure will create territories in incremental mode
----------------------------------------------------------*/
PROCEDURE terr_incr_refresh
IS

BEGIN
    IF G_Debug THEN
       Write_Log(2, 'Start altering triggers and determine the cut-off time');
    END IF;

    -- disable all the triggers
    alter_triggers(p_status => 'DISABLE');

    -- set the cut-off time to sysdate ; any changes made to territory group after this will not be processed in this run
    g_cutoff_time := SYSDATE;

    IF G_Debug THEN
       Write_Log(2, 'Finished altering triggers and determining the cut-off time');
       Write_Log(2, 'START: process_TG_delete');
    END IF;

    -- call the procedure process_TG_delete to handle the TGs that have been deleted
    process_TG_delete;

    IF G_Debug THEN
       Write_Log(2, 'END: process_TG_delete');
       Write_Log(2, 'START: process_TG_update');
    END IF;

    -- call the procedure process_TG_update to handle the TGs that have been created or updated
    process_TG_update;

    IF G_Debug THEN
       Write_Log(2, 'END: process_TG_update');
       Write_Log(2, 'START: process_TGA_delete');
    END IF;

    -- call the procedure process_TGA_delete to handle the TGAs that have been deleted
    process_TGA_delete;

    IF G_Debug THEN
       Write_Log(2, 'END: process_TGA_delete');
       Write_Log(2, 'START: process_GT_delete');
    END IF;

    -- call the procedure process_GT_delete to handle the GTs that have been deleted
    process_GT_delete;

    IF G_Debug THEN
       Write_Log(2, 'END: process_GT_delete');
       Write_Log(2, 'START: process_TGA_update');
    END IF;

    -- call the procedure process_TGA_update to handle the TGAs that have been updated
    process_TGA_update;

    IF G_Debug THEN
       Write_Log(2, 'END: process_TGA_update');
       Write_Log(2, 'START: process_GT_update');
    END IF;

    -- call the procedure process_GT_update to handle the GTs that have been updated

    IF G_Debug THEN
       Write_Log(2, 'END: process_GT_update');
    END IF;

    -- enable all the triggers
    alter_triggers(p_status => 'ENABLE');

    -- delete the records from jtf_tty_named_acct_changes which have been processed
    DELETE jtf_tty_named_acct_changes
    WHERE  creation_date <= g_cutoff_time;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure terr_incr_refresh');
      END IF;
      RAISE;
END terr_incr_refresh;

/*----------------------------------------------------------
This procedure will delete all the territories and recreate
the territories for all the territory groups in total mode
----------------------------------------------------------*/
PROCEDURE terr_initial_load
IS
    /* Active Named Account Territory Groups with active Top-Level Territories */
    CURSOR na_terr_grp IS
    SELECT   A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.MATCHING_RULE_CODE
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.Catch_all_resource_id
           , A.catch_all_resource_type
           , A.generate_catchall_flag
           , A.NUM_WINNERS
           , B.ORG_ID
           , 'INSERT'
    FROM JTF_TTY_TERR_GROUPS A
          , JTF_TERR_ALL B
    WHERE a.parent_terr_id =  b.terr_id
    AND ( a.active_to_date >= SYSDATE OR a.active_to_date IS NULL )
    AND a.active_from_date <= SYSDATE
    AND a.self_service_type = 'NAMED_ACCOUNT';

    /* Active Geography Territory Groups with active Top-Level Territories */
    CURSOR geo_terr_grp IS
    SELECT   A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.NUM_WINNERS
           , B.ORG_ID
           , 'INSERT'
    FROM JTF_TTY_TERR_GROUPS A
          , JTF_TERR_ALL B
    WHERE a.parent_terr_id =  b.terr_id
    AND ( a.active_to_date >= SYSDATE OR a.active_to_date IS NULL )
    AND a.active_from_date <= SYSDATE
    AND a.self_service_type = 'GEOGRAPHY';

   l_terr_group_id             g_terr_group_id_tab;
   l_terr_group_name           g_terr_group_name_tab;
   l_rank                      g_rank_tab;
   l_active_from_date          g_active_from_date_tab;
   l_active_to_date            g_active_to_date_tab;
   l_parent_terr_id            g_parent_terr_id_tab;
   l_matching_rule_code        g_matching_rule_code_tab;
   l_created_by                g_created_by_tab;
   l_creation_date             g_creation_date_tab;
   l_last_updated_by           g_last_updated_by_tab;
   l_last_update_date          g_last_update_date_tab;
   l_last_update_login         g_last_update_login_tab;
   l_catch_all_resource_id     g_catch_all_resource_id_tab;
   l_catch_all_resource_type   g_catch_all_resource_type_tab;
   l_generate_catchall_flag    g_generate_catchall_flag_tab;
   l_num_winners               g_num_winners_tab;
   l_org_id                    g_org_id_tab;
   l_change_type               g_change_type_tab;

   l_no_of_records  NUMBER;
   l_stmt           VARCHAR2(300);

BEGIN
    IF G_Debug THEN
       Write_Log(2, 'Start altering triggers and deleting existing territories');
    END IF;

    -- disable all the triggers
    alter_triggers(p_status => 'DISABLE');

    -- delete all existing territories
    cleanup_na_territories(p_mode => 'TOTAL');

    IF G_Debug THEN
       Write_Log(2, 'End altering triggers and deleting existing territories');
    END IF;

    /* Process the named account territory groups */
    -- open the cursor
    OPEN na_terr_grp;

    -- loop till all the TGs are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGs');
      END IF;

      /* Bulk collect TG information and process them row by row */
      FETCH na_terr_grp BULK COLLECT INTO
         l_terr_group_id
        ,l_terr_group_name
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_parent_terr_id
        ,l_matching_rule_code
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_catch_all_resource_id
        ,l_catch_all_resource_type
        ,l_generate_catchall_flag
        ,l_num_winners
        ,l_org_id
        ,l_change_type
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN
          IF G_Debug THEN
            Write_Log(2, 'START: create_na_terr_for_TG');
          END IF;

          create_na_terr_for_TG (
              l_terr_group_id
             ,l_terr_group_name
             ,l_rank
             ,l_active_from_date
             ,l_active_to_date
             ,l_parent_terr_id
             ,l_matching_rule_code
             ,l_created_by
             ,l_creation_date
             ,l_last_updated_by
             ,l_last_update_date
             ,l_last_update_login
             ,l_catch_all_resource_id
             ,l_catch_all_resource_type
             ,l_generate_catchall_flag
             ,l_num_winners
             ,l_org_id
             ,l_change_type
             ,NULL
				 ,NULL
				 ,NULL);

          IF G_Debug THEN
            Write_Log(2, 'END: create_na_terr_for_TG');
          END IF;

          /* trim the pl/sql tables to free up memory */
          l_terr_group_id.TRIM(l_no_of_records);
          l_terr_group_name.TRIM(l_no_of_records);
          l_rank.TRIM(l_no_of_records);
          l_active_from_date.TRIM(l_no_of_records);
          l_active_to_date.TRIM(l_no_of_records);
          l_parent_terr_id.TRIM(l_no_of_records);
          l_matching_rule_code.TRIM(l_no_of_records);
          l_created_by.TRIM(l_no_of_records);
          l_creation_date.TRIM(l_no_of_records);
          l_last_updated_by.TRIM(l_no_of_records);
          l_last_update_date.TRIM(l_no_of_records);
          l_last_update_login.TRIM(l_no_of_records);
          l_catch_all_resource_id.TRIM(l_no_of_records);
          l_catch_all_resource_type.TRIM(l_no_of_records);
          l_generate_catchall_flag.TRIM(l_no_of_records);
          l_num_winners.TRIM(l_no_of_records);
          l_org_id.TRIM(l_no_of_records);
          l_change_type.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished processing the current set of TGs');
      END IF;

      EXIT WHEN na_terr_grp%NOTFOUND;

    END LOOP;

    CLOSE na_terr_grp;

    /* End process the named account territory groups */

    /* Process the geography territory groups */
    -- open the cursor
    OPEN geo_terr_grp;

    -- loop till all the TGs are processed
    LOOP

      IF G_Debug THEN
          Write_Log(2, 'fetching the next set of TGs');
      END IF;

      /* Bulk collect TG information and process them row by row */
      FETCH geo_terr_grp BULK COLLECT INTO
         l_terr_group_id
        ,l_terr_group_name
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_parent_terr_id
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_num_winners
        ,l_org_id
        ,l_change_type
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN
          IF G_Debug THEN
            Write_Log(2, 'START: create_geo_terr_for_TG');
          END IF;

          create_geo_terr_for_TG (
              l_terr_group_id
             ,l_terr_group_name
             ,l_rank
             ,l_active_from_date
             ,l_active_to_date
             ,l_parent_terr_id
             ,l_created_by
             ,l_creation_date
             ,l_last_updated_by
             ,l_last_update_date
             ,l_last_update_login
             ,l_num_winners
             ,l_org_id
             ,l_change_type);

          IF G_Debug THEN
            Write_Log(2, 'END: create_geo_terr_for_TG');
          END IF;

          /* trim the pl/sql tables to free up memory */
          l_terr_group_id.TRIM(l_no_of_records);
          l_terr_group_name.TRIM(l_no_of_records);
          l_rank.TRIM(l_no_of_records);
          l_active_from_date.TRIM(l_no_of_records);
          l_active_to_date.TRIM(l_no_of_records);
          l_parent_terr_id.TRIM(l_no_of_records);
          l_created_by.TRIM(l_no_of_records);
          l_creation_date.TRIM(l_no_of_records);
          l_last_updated_by.TRIM(l_no_of_records);
          l_last_update_date.TRIM(l_no_of_records);
          l_last_update_login.TRIM(l_no_of_records);
          l_num_winners.TRIM(l_no_of_records);
          l_org_id.TRIM(l_no_of_records);
          l_change_type.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished processing the current set of TGs');
      END IF;

      EXIT WHEN geo_terr_grp%NOTFOUND;

    END LOOP;

    CLOSE geo_terr_grp;

    /* End process the named account territory groups */

    -- enable all the triggers
    alter_triggers(p_status => 'ENABLE');

    -- truncate the table jtf_tty_named_accts so that next incremental runs donot process the rows processed in total mode
    l_stmt := 'truncate table '||g_jtf_schema||'.'|| 'jtf_tty_named_acct_changes';
    EXECUTE IMMEDIATE l_stmt;

EXCEPTION
  WHEN OTHERS THEN
      IF G_Debug THEN
          Write_Log(2, 'Error in procedure terr_initial_load');
      END IF;
      IF (na_terr_grp%ISOPEN) THEN
        CLOSE na_terr_grp;
      END IF;
      IF (geo_terr_grp%ISOPEN) THEN
        CLOSE geo_terr_grp;
      END IF;
      RAISE;
END terr_initial_load;

PROCEDURE generate_terr (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      p_mode                IN              VARCHAR2,
      p_number_of_workers   IN              NUMBER,
      p_debug_flag          IN              VARCHAR2,
      p_sql_trace           IN              VARCHAR2
   )
   AS

  l_status   VARCHAR2(30);
  l_industry VARCHAR2(30);
  l_flag     VARCHAR2(1);

   BEGIN
      -- Initialize Global variables
      G_Debug := FALSE;

      /* Set Global Application Short Name */
      IF G_APP_SHORT_NAME IS NULL THEN
        G_APP_SHORT_NAME := 'JTF';
      END IF;

      -- Get the schema name for JTF
      IF(Fnd_Installation.GET_APP_INFO('JTF', l_status, l_industry, g_jtf_schema)) THEN
         NULL;
      END IF;

      -- If the SQL trace flag is turned on, then turn on the trace
      IF UPPER(p_sql_trace) = 'Y' THEN
         dbms_session.set_sql_trace(TRUE);
      END IF;

      -- If the debug flag is set, Then turn on the debug message logging
      IF UPPER( RTRIM(p_debug_flag) ) = 'Y' THEN
         G_Debug := TRUE;
      END IF;

      /* Depending on uptake of product category set the opportunity/lead qualifier usage */
      IF (Fnd_Profile.DEFINED('JTF_TTY_PROD_CAT_ENABLED')) THEN
        l_flag := NVL(Fnd_Profile.VALUE('JTF_TTY_PROD_CAT_ENABLED'), 'N');
        IF (l_flag = 'N') THEN
          g_prod_cat_enabled := FALSE;
        ELSE
          g_prod_cat_enabled := TRUE;
        END IF;
      ELSE
        g_prod_cat_enabled := FALSE;
      END IF;
      IF (g_prod_cat_enabled) THEN
        g_opp_qual_usg_id := -1142;
        g_lead_qual_usg_id := -1131;
      ELSE
        g_opp_qual_usg_id := -1023;
        g_lead_qual_usg_id := -1018;
      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Inside generate_terr');
      END IF;

      IF p_mode = 'TOTAL' THEN

         IF G_Debug THEN
            Write_Log(2, 'START: terr_initial_load');
         END IF;

         -- call the procedure terr_initial_load for total refresh of territories
         terr_initial_load;

         IF G_Debug THEN
            Write_Log(2, 'END: terr_initial_load');
         END IF;

      ELSIF p_mode = 'INCR' THEN

         IF G_Debug THEN
            Write_Log(2, 'START: terr_incr_refresh');
         END IF;

         -- call the procedure terr_incr_refresh for incremental refresh of territories
         terr_incr_refresh;

         IF G_Debug THEN
            Write_Log(2, 'END: terr_incr_refresh');
         END IF;

      ELSE
         IF G_Debug THEN
             write_log(2, 'Invalid run mode : valid values are total and incremental refresh');
         END IF;
         ERRBUF  := 'Program terminated with invalid run mode';
         RETCODE := 2;
      END IF;

EXCEPTION
    WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error THEN
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

    WHEN OTHERS THEN
           ROLLBACK;
           IF G_Debug THEN
              Write_Log(1,'Program terminated with OTHERS exception.');
              Write_Log(1,'SQLCODE : ' || SQLCODE);
              Write_Log(1,'SQLERRM : ' || SQLERRM);
           END IF;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;
END generate_terr;


/*----------------------------------------------------------
This procedure will create territory when a named account
is changes e.g. from Map Named Account page
----------------------------------------------------------*/

PROCEDURE create_terr_for_na(p_terr_grp_acct_id        IN NUMBER,
                             p_terr_grp_id             IN NUMBER)
IS
      /* Territory groups that are created/updated */
    CURSOR terr_grp_acct(l_terr_grp_acct_id NUMBER)
    IS
    SELECT B.terr_group_account_id
          ,C.terr_group_id
          ,C.rank
          ,C.active_from_date
          ,C.active_to_date
          ,C.matching_rule_code
          ,C.generate_catchall_flag
          ,C.created_by
          ,C.creation_date
          ,C.last_updated_by
          ,C.last_update_date
          ,C.last_update_login
          ,D.ORG_ID
          ,F.terr_id  --  placeholder territory for non-overlay branch
          ,E.terr_id  -- placeholder territory for overlay branch
          ,C.terr_group_id * -1  -- catch-all territory id
          ,'MAPPING_UPDATE' change_type
          ,to_char(null) -- attribute_category
          ,B.attribute1
          ,B.attribute2
          ,B.attribute3
          ,B.attribute4
          ,B.attribute5
          ,B.attribute6
          ,B.attribute7
          ,B.attribute8
          ,B.attribute9
          ,B.attribute10
          ,B.attribute11
          ,B.attribute12
          ,B.attribute13
          ,B.attribute14
          ,B.attribute15
    FROM
      jtf_tty_terr_grp_accts B
     ,jtf_tty_terr_groups C
     ,jtf_terr_all D  -- to get the org_id of the parent territory
     ,jtf_terr_all E  -- to get the terr_id of the top level territory of overlay branch
     ,jtf_terr_all F  -- to get the terr_id for the placeholder territory of non-overlay branch
    WHERE B.terr_group_account_id = l_terr_grp_acct_id
    AND   B.terr_group_id = C.terr_group_id
    AND   C.terr_group_id = D.terr_group_id
    AND   D.terr_group_flag = 'Y'
    AND   D.catch_all_flag = 'N'
    AND   nvl(D.named_account_flag,'N') = 'N'
    AND   E.terr_group_id(+) = C.terr_group_id  -- outer-join is necessary as overlay branch may not exist
    AND   E.name(+) = C.terr_group_name || ' (OVERLAY)'
    AND   E.terr_group_flag(+) = 'Y'
    AND   F.terr_group_id = C.terr_group_id  -- outer-join is necessary as overlay branch may not exist
    AND   F.name = C.terr_group_name
    AND   F.terr_group_flag = 'Y'
    AND   NVL(F.named_account_flag ,'N') <> 'Y';

   l_terr_group_account_id       g_terr_group_account_id_tab;
   l_terr_group_id               g_terr_group_id_tab;
   l_rank                        g_rank_tab;
   l_active_from_date            g_active_from_date_tab;
   l_active_to_date              g_active_to_date_tab;
   l_matching_rule_code          g_matching_rule_code_tab;
   l_generate_catchall_flag      g_generate_catchall_flag_tab;
   l_created_by                  g_created_by_tab;
   l_creation_date               g_creation_date_tab;
   l_last_updated_by             g_last_updated_by_tab;
   l_last_update_date            g_last_update_date_tab;
   l_last_update_login           g_last_update_login_tab;
   l_org_id                      g_ORG_ID_tab;
   l_terr_id                     g_terr_id_tab;
   l_overlay_top                 g_terr_id_tab;
   l_catchall_terr_id            g_terr_id_tab;
   l_change_type                 g_change_type_tab;
   l_terr_attr_cat               g_terr_attr_cat_tab;
   l_terr_attribute1             g_terr_attribute_tab;
   l_terr_attribute2             g_terr_attribute_tab;
   l_terr_attribute3             g_terr_attribute_tab;
   l_terr_attribute4             g_terr_attribute_tab;
   l_terr_attribute5             g_terr_attribute_tab;
   l_terr_attribute6             g_terr_attribute_tab;
   l_terr_attribute7             g_terr_attribute_tab;
   l_terr_attribute8             g_terr_attribute_tab;
   l_terr_attribute9             g_terr_attribute_tab;
   l_terr_attribute10            g_terr_attribute_tab;
   l_terr_attribute11            g_terr_attribute_tab;
   l_terr_attribute12            g_terr_attribute_tab;
   l_terr_attribute13            g_terr_attribute_tab;
   l_terr_attribute14            g_terr_attribute_tab;
   l_terr_attribute15            g_terr_attribute_tab;

   l_no_of_records  NUMBER;
BEGIN
    Initialize;
    -- open the cursor
    OPEN terr_grp_acct(p_terr_grp_acct_id);

    -- loop till all the TGAs that have been created/updated are processed
    LOOP

      /* Bulk collect TGA information and process them row by row */
      FETCH terr_grp_acct BULK COLLECT INTO
         l_terr_group_account_id
        ,l_terr_group_id
        ,l_rank
        ,l_active_from_date
        ,l_active_to_date
        ,l_matching_rule_code
        ,l_generate_catchall_flag
        ,l_created_by
        ,l_creation_date
        ,l_last_updated_by
        ,l_last_update_date
        ,l_last_update_login
        ,l_ORG_ID
        ,l_terr_id
        ,l_overlay_top
        ,l_catchall_terr_id
        ,l_change_type
        ,l_terr_attr_cat
        ,l_terr_attribute1
        ,l_terr_attribute2
        ,l_terr_attribute3
        ,l_terr_attribute4
        ,l_terr_attribute5
        ,l_terr_attribute6
        ,l_terr_attribute7
        ,l_terr_attribute8
        ,l_terr_attribute9
        ,l_terr_attribute10
        ,l_terr_attribute11
        ,l_terr_attribute12
        ,l_terr_attribute13
        ,l_terr_attribute14
        ,l_terr_attribute15
      LIMIT g_commit_chunk_size;

      /* Get the number of rows returned by the fetch */
      l_no_of_records := l_terr_group_account_id.COUNT;

      /* process the result set if the fetch has returned at least 1 row */
      IF (l_no_of_records > 0) THEN

              IF G_Debug THEN
                  Write_Log(2, 'Start : create_na_terr_for_TGA');
              END IF;
              -- create territories for the territory group account
              create_na_terr_for_TGA(
                  l_terr_group_account_id
                 ,l_terr_group_id
                 ,l_rank
                 ,l_active_from_date
                 ,l_active_to_date
                 ,l_matching_rule_code
                 ,l_generate_catchall_flag
                 ,l_created_by
                 ,l_creation_date
                 ,l_last_updated_by
                 ,l_last_update_date
                 ,l_last_update_login
                 ,l_ORG_ID
                 ,l_terr_id
                 ,l_overlay_top
                 ,l_catchall_terr_id
                 ,l_change_type
                 ,l_terr_attr_cat
                 ,l_terr_attribute1
                 ,l_terr_attribute2
                 ,l_terr_attribute3
                 ,l_terr_attribute4
                 ,l_terr_attribute5
                 ,l_terr_attribute6
                 ,l_terr_attribute7
                 ,l_terr_attribute8
                 ,l_terr_attribute9
                 ,l_terr_attribute10
                 ,l_terr_attribute11
                 ,l_terr_attribute12
                 ,l_terr_attribute13
                 ,l_terr_attribute14
                 ,l_terr_attribute15);
              IF G_Debug THEN
                  Write_Log(2, 'End : create_na_terr_for_TGA');
              END IF;

              /* trim the pl/sql tables to free up memory */
              l_terr_group_account_id.TRIM(l_no_of_records);
              l_terr_group_id.TRIM(l_no_of_records);
              l_rank.TRIM(l_no_of_records);
              l_active_from_date.TRIM(l_no_of_records);
              l_active_to_date.TRIM(l_no_of_records);
              l_matching_rule_code.TRIM(l_no_of_records);
              l_generate_catchall_flag.TRIM(l_no_of_records);
              l_created_by.TRIM(l_no_of_records);
              l_creation_date.TRIM(l_no_of_records);
              l_last_updated_by.TRIM(l_no_of_records);
              l_last_update_date.TRIM(l_no_of_records);
              l_last_update_login.TRIM(l_no_of_records);
              l_ORG_ID.TRIM(l_no_of_records);
              l_terr_id.TRIM(l_no_of_records);
              l_overlay_top.TRIM(l_no_of_records);
              l_catchall_terr_id.TRIM(l_no_of_records);
              l_change_type.TRIM(l_no_of_records);
              l_terr_attr_cat.TRIM(l_no_of_records);
              l_terr_attribute1.TRIM(l_no_of_records);
              l_terr_attribute2.TRIM(l_no_of_records);
              l_terr_attribute3.TRIM(l_no_of_records);
              l_terr_attribute4.TRIM(l_no_of_records);
              l_terr_attribute5.TRIM(l_no_of_records);
              l_terr_attribute6.TRIM(l_no_of_records);
              l_terr_attribute7.TRIM(l_no_of_records);
              l_terr_attribute8.TRIM(l_no_of_records);
              l_terr_attribute9.TRIM(l_no_of_records);
              l_terr_attribute10.TRIM(l_no_of_records);
              l_terr_attribute11.TRIM(l_no_of_records);
              l_terr_attribute12.TRIM(l_no_of_records);
              l_terr_attribute13.TRIM(l_no_of_records);
              l_terr_attribute14.TRIM(l_no_of_records);
              l_terr_attribute15.TRIM(l_no_of_records);

      END IF;

      IF G_Debug THEN
         Write_Log(2, 'Finished process the current set of TGAs');
      END IF;

      EXIT WHEN terr_grp_acct%NOTFOUND;

    END LOOP;

    CLOSE terr_grp_acct;
    -- COMMIT;
END create_terr_for_na;

/*----------------------------------------------------------
This procedure will create Named account and Overlay Territory
and geography territory for update or created named account TG
or geography territory group.
----------------------------------------------------------*/
PROCEDURE create_terr_for_TG( p_terr_group_id          IN NUMBER
                             ,p_territory_type         IN VARCHAR2
                             ,p_change_type            IN VARCHAR2
                             ,p_terr_type_id           IN VARCHAR2
                             ,p_terr_id                IN VARCHAR2
			     ,p_terr_creation_flag     IN VARCHAR2
                            )
IS

    /* Named Account Territory groups that are created/updated */
    CURSOR na_terr_grp(l_terr_group_id NUMBER) IS
    SELECT   A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.MATCHING_RULE_CODE
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.Catch_all_resource_id
           , A.catch_all_resource_type
           , A.generate_catchall_flag
           , A.NUM_WINNERS
           , B.ORG_ID
           , p_change_type change_type
    FROM JTF_TTY_TERR_GROUPS A
        ,JTF_TERR_ALL B
        ,JTF_TERR_ALL C
    WHERE   A.parent_terr_id = B.terr_id
    AND     B.terr_id = C.parent_territory_id
    AND     B.org_id  = C.org_id
    AND     C.terr_id  =  p_terr_id
    AND     A.terr_group_id = l_terr_group_id
    AND   A.self_service_type = 'NAMED_ACCOUNT';

    /* Geography Territory groups that are created/updated */
    CURSOR geo_terr_grp(l_terr_group_id NUMBER) IS
    SELECT   A.TERR_GROUP_ID
           , A.TERR_GROUP_NAME
           , A.RANK
           , A.ACTIVE_FROM_DATE
           , A.ACTIVE_TO_DATE
           , A.PARENT_TERR_ID
           , A.CREATED_BY
           , A.CREATION_DATE
           , A.LAST_UPDATED_BY
           , A.LAST_UPDATE_DATE
           , A.LAST_UPDATE_LOGIN
           , A.NUM_WINNERS
           , B.ORG_ID
           , p_change_type change_type
    FROM JTF_TTY_TERR_GROUPS A
        ,JTF_TERR_ALL B
    WHERE A.terr_group_id = l_terr_group_id
    AND   A.parent_terr_id = B.terr_id
    AND   A.self_service_type = 'GEOGRAPHY';


   l_terr_group_id             g_terr_group_id_tab := g_terr_group_id_tab();
   l_terr_group_name           g_terr_group_name_tab := g_terr_group_name_tab();
   l_rank                      g_rank_tab := g_rank_tab();
   l_active_from_date          g_active_from_date_tab := g_active_from_date_tab();
   l_active_to_date            g_active_to_date_tab := g_active_to_date_tab();
   l_parent_terr_id            g_parent_terr_id_tab := g_parent_terr_id_tab();
   l_matching_rule_code        g_matching_rule_code_tab := g_matching_rule_code_tab();
   l_created_by                g_created_by_tab := g_created_by_tab();
   l_creation_date             g_creation_date_tab := g_creation_date_tab();
   l_last_updated_by           g_last_updated_by_tab := g_last_updated_by_tab();
   l_last_update_date          g_last_update_date_tab := g_last_update_date_tab();
   l_last_update_login         g_last_update_login_tab := g_last_update_login_tab();
   l_catch_all_resource_id     g_catch_all_resource_id_tab := g_catch_all_resource_id_tab();
   l_catch_all_resource_type   g_catch_all_resource_type_tab := g_catch_all_resource_type_tab();
   l_generate_catchall_flag    g_generate_catchall_flag_tab := g_generate_catchall_flag_tab();
   l_num_winners               g_num_winners_tab := g_num_winners_tab();
   l_org_id                    g_org_id_tab := g_org_id_tab();
   l_change_type               g_change_type_tab := g_change_type_tab();
   -- l_terr_created_id           g_terr_created_id_tab := g_terr_created_id_tab();
   -- l_terr_creation_flag        g_terr_creation_flag_tab:=g__terr_creation_flag_tab();

   l_no_of_records             NUMBER;
   l_status   VARCHAR2(30);
   l_industry VARCHAR2(30);
   l_flag     VARCHAR2(1);

BEGIN
  -- Initialize

   Initialize;
   l_terr_group_id.extend;
   l_terr_group_name.extend;
   l_rank.extend;
   l_active_from_date.extend     ;
   l_active_to_date.extend       ;
   l_parent_terr_id.extend       ;
   l_matching_rule_code.extend   ;
   l_created_by.extend           ;
   l_creation_date.extend        ;
   l_last_updated_by.extend      ;
   l_last_update_date.extend     ;
   l_last_update_login.extend    ;
   l_catch_all_resource_id.extend;
   l_catch_all_resource_type.extend;
   l_generate_catchall_flag.extend;
   l_num_winners.extend;
   l_org_id.extend;
   l_change_type.extend;

   -- l_terr_created_id.extend;
   -- l_terr_creation_flag.extend;


  IF (p_territory_type = 'NAMED_ACCOUNT') THEN
   OPEN na_terr_grp(p_terr_group_id);
   LOOP
    FETCH na_terr_grp INTO
         l_terr_group_id(1)
        ,l_terr_group_name(1)
        ,l_rank(1)
        ,l_active_from_date(1)
        ,l_active_to_date(1)
        ,l_parent_terr_id(1)
        ,l_matching_rule_code(1)
        ,l_created_by(1)
        ,l_creation_date(1)
        ,l_last_updated_by(1)
        ,l_last_update_date(1)
        ,l_last_update_login(1)
        ,l_catch_all_resource_id(1)
        ,l_catch_all_resource_type(1)
        ,l_generate_catchall_flag(1)
        ,l_num_winners(1)
        ,l_org_id(1)
        ,l_change_type(1);
    EXIT WHEN na_terr_grp%NOTFOUND;
   END LOOP;
   CLOSE na_terr_grp;
   create_na_terr_for_TG (
              l_terr_group_id
             ,l_terr_group_name
             ,l_rank
             ,l_active_from_date
             ,l_active_to_date
             ,l_parent_terr_id
             ,l_matching_rule_code
             ,l_created_by
             ,l_creation_date
             ,l_last_updated_by
             ,l_last_update_date
             ,l_last_update_login
             ,l_catch_all_resource_id
             ,l_catch_all_resource_type
             ,l_generate_catchall_flag
             ,l_num_winners
             ,l_org_id
             ,l_change_type
             ,p_terr_type_id
			 ,p_terr_id
			 ,p_terr_creation_flag);
  ELSIF (p_territory_type = 'GEOGRAPHY') THEN
    OPEN geo_terr_grp(p_terr_group_id);
    LOOP
     FETCH geo_terr_grp INTO
         l_terr_group_id(1)
        ,l_terr_group_name(1)
        ,l_rank(1)
        ,l_active_from_date(1)
        ,l_active_to_date(1)
        ,l_parent_terr_id(1)
        ,l_created_by(1)
        ,l_creation_date(1)
        ,l_last_updated_by(1)
        ,l_last_update_date(1)
        ,l_last_update_login(1)
        ,l_num_winners(1)
        ,l_org_id(1)
        ,l_change_type(1);
    EXIT WHEN geo_terr_grp%NOTFOUND;
    END LOOP;
    CLOSE geo_terr_grp;
    create_geo_terr_for_TG (
              l_terr_group_id
             ,l_terr_group_name
             ,l_rank
             ,l_active_from_date
             ,l_active_to_date
             ,l_parent_terr_id
             ,l_created_by
             ,l_creation_date
             ,l_last_updated_by
             ,l_last_update_date
             ,l_last_update_login
             ,l_num_winners
             ,l_org_id
             ,l_change_type);
  END IF;
  COMMIT;
END create_terr_for_TG;

PROCEDURE delete_catch_all_terr_for_TG(p_terr_group_id IN NUMBER)
IS

l_catchall_terr_id NUMBER;

CURSOR c_get_terr_id (l_terr_grp_id NUMBER)
IS
SELECT terr_id
 FROM JTF_TERR_ALL
WHERE CATCH_ALL_FLAG='Y'
 AND TERR_GROUP_ID = l_terr_grp_id;

BEGIN

   l_catchall_terr_id := -999;

   OPEN c_get_terr_id ( p_terr_group_id);
   FETCH c_get_terr_id INTO l_catchall_terr_id;
   CLOSE c_get_terr_id;

   IF ( l_catchall_terr_id <> -999 ) THEN
     BEGIN
          DELETE FROM JTF_TERR_RSC_ACCESS_ALL A
          WHERE A.TERR_RSC_ID IN ( SELECT B.TERR_RSC_ID
                                   FROM JTF_TERR_RSC_ALL B
                                   WHERE B.terr_id = l_catchall_terr_id );

	  DELETE FROM JTF_TERR_RSC_ALL
	  WHERE TERR_ID = l_catchall_terr_id;

	  DELETE FROM JTF_TERR_ALL
	  WHERE TERR_ID = l_catchall_terr_id;

	  COMMIT;
      EXCEPTION
	  WHEN OTHERS THEN NULL;
      END;
   END IF;
EXCEPTION
    WHEN OTHERS THEN
         RAISE;
END delete_catch_all_terr_for_TG;

PROCEDURE delete_catchall_terrrsc_for_TG(p_terr_group_id IN NUMBER)
IS
l_catchall_terr_id NUMBER;

CURSOR c_get_terr_id (l_terr_grp_id NUMBER)
IS
SELECT terr_id
 FROM JTF_TERR_ALL
WHERE CATCH_ALL_FLAG='Y'
 AND TERR_GROUP_ID = l_terr_grp_id;

BEGIN

   l_catchall_terr_id := -999;

   OPEN c_get_terr_id ( p_terr_group_id);
   FETCH c_get_terr_id INTO l_catchall_terr_id;
   CLOSE c_get_terr_id;

   IF ( l_catchall_terr_id <> -999 ) THEN
     BEGIN

          DELETE FROM JTF_TERR_RSC_ACCESS_ALL A
          WHERE A.TERR_RSC_ID IN ( SELECT B.TERR_RSC_ID
                                   FROM JTF_TERR_RSC_ALL B
                                   WHERE B.terr_id = l_catchall_terr_id );

	  DELETE FROM JTF_TERR_RSC_ALL
	  WHERE TERR_ID IN
	     ( SELECT terr_id
	       FROM JTF_TERR_ALL
	       WHERE CATCH_ALL_FLAG='Y'
	       AND TERR_GROUP_ID = p_terr_group_id
		  );

          COMMIT;

      EXCEPTION
	  WHEN OTHERS THEN NULL;
      END;
    END IF;
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END delete_catchall_terrrsc_for_TG;


PROCEDURE create_catchall_terr_rsc(p_terr_group_id IN NUMBER
                                  ,p_org_id IN VARCHAR2
                                  ,p_resource_id IN NUMBER
                                  ,p_role_code IN VARCHAR2
                                  ,p_group_id IN NUMBER
			          ,p_user_id IN NUMBER)
IS
      l_catchall_terr_id NUMBER;
      l_terr_rsc_id      NUMBER;
      l_terr_rsc_access_id  NUMBER;
      l_qual_type     VARCHAR2(20);
      l_trans_access_code   VARCHAR2(20);

    /* Access Types for a particular Role within a Territory Group */
     CURSOR role_access(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.access_type, a.trans_access_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id
      AND b.role_code          = l_role
    ORDER BY a.access_type  ;

BEGIN

   l_terr_rsc_id := 0;
   l_terr_rsc_access_id := 0;
   SELECT jtf_terr_rsc_s.NEXTVAL
     INTO l_terr_rsc_id
     FROM DUAL;

   SELECT terr_id INTO l_catchall_terr_id
	  FROM JTF_TERR_ALL
	  WHERE CATCH_ALL_FLAG='Y'
	    AND TERR_GROUP_ID = p_terr_group_id;

   INSERT INTO jtf_terr_rsc_all
	  (
	    TERR_RSC_ID,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 TERR_ID,
		 RESOURCE_ID,
		 RESOURCE_TYPE,
		 ROLE,
		 START_DATE_ACTIVE,
		 ORG_ID,
		 FULL_ACCESS_FLAG,
		 GROUP_ID
	  )
	  VALUES
	  (
	        l_terr_rsc_id,
		 SYSDATE,
		 p_user_id,
		 SYSDATE,
		 p_user_id,
		 l_catchall_terr_id,
		 p_resource_id,
		 'RS_EMPLOYEE',
		 p_role_code,
		 SYSDATE,
		 p_org_id,
		 'Y',
		 p_group_id
		);

    FOR rsc_acc IN role_access(p_terr_group_id, p_role_code)
    LOOP
       IF ( rsc_acc.access_type='OPPORTUNITY' ) THEN
            l_qual_type := 'OPPOR';
       ELSE
            l_qual_type := rsc_acc.access_type;
       END IF;

       l_trans_access_code := rsc_acc.trans_access_code;

       SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
         INTO l_terr_rsc_access_id
         FROM DUAL;

       INSERT INTO jtf_terr_rsc_access_all
	         ( TERR_RSC_ACCESS_ID,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   CREATION_DATE,
		   CREATED_BY,
		   TERR_RSC_ID,
                   ACCESS_TYPE,
                   ORG_ID,
                   OBJECT_VERSION_NUMBER,
                   TRANS_ACCESS_CODE
	         )
	         VALUES
	        (
	           l_terr_rsc_access_id,
		    SYSDATE,
		    p_user_id,
		    SYSDATE,
		    p_user_id,
		    l_terr_rsc_id,
		    l_qual_type,
		    p_org_id,
		    0,
		    l_trans_access_code
		);

     END LOOP; /* FOR rsc_acc in role_access */

     COMMIT;

  EXCEPTION
	  WHEN OTHERS THEN NULL;
END;


PROCEDURE Delete_Territory_or_tg(p_terr_Id IN VARCHAR2) IS

l_tg_id NUMBER;
l_s VARCHAR2(30);
l_ss VARCHAR2(300);
l_n NUMBER;

Cursor NATG_TERR IS
         SELECT terr_id,
                TERR_GROUP_ID
         FROM jtf_terr_all
         CONNECT BY  parent_territory_id = PRIOR terr_id
         AND TERR_ID <> 1
         AND CATCH_ALL_FLAG <> 'Y'
	 AND NAMED_ACCOUNT_FLAG <> 'Y'
         AND TERR_GROUP_FLAG = 'Y'
         START WITH terr_id = to_number(p_terr_Id);

BEGIN
        FOR c in NATG_TERR LOOP
           JTF_TTY_NA_TERRGP.delete_terrgp(c.TERR_GROUP_ID);
        END LOOP;


	    JTF_TERRITORY_PVT.Delete_Territory
            ( 1.0,
              NULL,
              'T',
              0,
              l_s,
              l_n,
              l_s,
              p_terr_id
			);


      COMMIT;

      EXCEPTION
	  WHEN OTHERS THEN NULL;

END;



/*----------------------------------------------------------
This procedure will update the sales team for a named account in
a territory group
----------------------------------------------------------*/
PROCEDURE update_terr_rscs_for_na(p_terr_grp_acct_id        IN NUMBER,
                                  p_terr_group_id           IN NUMBER)
IS

    TYPE role_typ IS RECORD(
    grp_role_id NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE grp_role_tbl_type IS TABLE OF role_typ
    INDEX BY BINARY_INTEGER;

    l_qual_type                 VARCHAR2(20);
    l_terr_rsc_id               NUMBER;
    l_terr_rsc_access_id        NUMBER;
    l_api_version_number        CONSTANT NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(1);
    l_commit                    VARCHAR2(1);

    x_return_status             VARCHAR2(1);
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(2000);
    x_terr_id                   NUMBER;
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;
    l_terr_id                   NUMBER;
    l_org_id                    NUMBER;
    l_start_date                DATE;
    l_end_date                  DATE;

    i  NUMBER;
    a  NUMBER;

    --l_TerrRsc_Tbl                 Jtf_Territory_Resource_Pvt.TerrResource_tbl_type;
	l_TerrRsc_Tbl                 Jtf_Territory_Resource_Pvt.TerrResource_tbl_type_wflex;
    l_TerrRsc_Access_Tbl          Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    x_TerrRsc_Out_Tbl             Jtf_Territory_Resource_Pvt.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      Jtf_Territory_Resource_Pvt.TerrRsc_Access_out_tbl_type;

    --l_TerrRsc_empty_Tbl           Jtf_Territory_Resource_Pvt.TerrResource_tbl_type;
	l_TerrRsc_empty_Tbl           Jtf_Territory_Resource_Pvt.TerrResource_tbl_type_wflex;
    l_TerrRsc_Access_empty_Tbl    Jtf_Territory_Resource_Pvt.TerrRsc_Access_tbl_type ;

    /* Roles defined for the TG */
    CURSOR roles_for_TG(l_terr_group_id NUMBER) IS
    SELECT  b.role_code role_code
           ,b.terr_group_id
    FROM jtf_tty_terr_grp_roles b
    WHERE b.terr_group_id         = l_terr_group_id
    ORDER BY b.role_code;

    CURSOR resource_grp(l_terr_group_acct_id NUMBER, l_role VARCHAR2) IS
    SELECT DISTINCT b.resource_id
         , b.rsc_group_id
         , b.rsc_resource_type
         , b.start_date
         , b.end_date
         , to_char(null) attribute_category
         , b.attribute1  attribute1
         , b.attribute2  attribute2
         , b.attribute3  attribute3
         , b.attribute4  attribute4
         , b.attribute5  attribute5
         , to_char(null) attribute6
         , to_char(null) attribute7
         , to_char(null) attribute8
         , to_char(null) attribute9
         , to_char(null) attribute10
         , to_char(null) attribute11
         , to_char(null) attribute12
         , to_char(null) attribute13
         , to_char(null) attribute14
         , to_char(null) attribute15
    FROM jtf_tty_terr_grp_accts a
       , jtf_tty_named_acct_rsc b
    WHERE a.terr_group_account_id = l_terr_group_acct_id
    AND a.terr_group_account_id = b.terr_group_account_id
    AND b.rsc_role_code = l_role;

    CURSOR c_get_terr_dtls ( l_terr_grp_acct_id  NUMBER)
    IS
    SELECT terr_id, org_id, trunc(start_date_active), trunc(end_date_active)
      FROM jtf_terr_all
     WHERE terr_group_account_id = l_terr_grp_acct_id;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id NUMBER,l_role VARCHAR2) IS
    SELECT DISTINCT a.access_type, a.trans_access_code
    FROM jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    WHERE a.terr_group_role_id = b.terr_group_role_id
      AND b.terr_group_id      = l_terr_group_id
      AND b.role_code          = l_role
    ORDER BY a.access_type  ;

BEGIN

    --Delete Territory Resource Access
    DELETE FROM JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
        ( SELECT TERR_RSC_ID
          FROM JTF_TERR_RSC_ALL A
              ,JTF_TERR_ALL     B
          WHERE B.TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id
          AND   B.TERR_ID = A.TERR_ID );

    -- Delete the Territory Resource records
    DELETE FROM JTF_TERR_RSC_ALL WHERE TERR_ID IN
        ( SELECT TERR_ID FROM JTF_TERR_ALL WHERE TERR_GROUP_ACCOUNT_ID = p_terr_grp_acct_id );

    l_init_msg_list :=FND_API.G_TRUE;
    i := 0;
    a := 0;
    l_user_id := fnd_global.user_id;
    l_login_id := fnd_global.login_id;

    OPEN c_get_terr_dtls (p_terr_grp_acct_id);
    FETCH c_get_terr_dtls INTO l_terr_id, l_org_id, l_start_date, l_end_date;
    CLOSE c_get_terr_dtls;

    IF ( l_terr_id <> 0 ) THEN

      l_TerrRsc_Tbl            := l_TerrRsc_empty_Tbl;
      l_TerrRsc_Access_Tbl     := l_TerrRsc_Access_empty_Tbl;
      FOR role_type IN roles_for_TG(p_terr_group_id)
      LOOP

        FOR rsc IN resource_grp(p_terr_grp_acct_id, role_type.role_code)
        LOOP
            i:=i+1;

            SELECT JTF_TERR_RSC_S.NEXTVAL
              INTO l_terr_rsc_id
              FROM DUAL;

            l_TerrRsc_Tbl(i).terr_id              := l_terr_id;
            l_TerrRsc_Tbl(i).TERR_RSC_ID          := l_terr_rsc_id;
            l_TerrRsc_Tbl(i).LAST_UPDATE_DATE     := sysdate;
            l_TerrRsc_Tbl(i).LAST_UPDATED_BY      := l_user_id;
            l_TerrRsc_Tbl(i).CREATION_DATE        := sysdate;
            l_TerrRsc_Tbl(i).CREATED_BY           := l_user_id;
            l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN    := l_login_id;
            l_TerrRsc_Tbl(i).RESOURCE_ID          := rsc.resource_id;
            l_TerrRsc_Tbl(i).RESOURCE_TYPE        := rsc.rsc_resource_type;
            l_TerrRsc_Tbl(i).ROLE                 := role_type.role_code;
            l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG := 'N';
/*
  commented out 07/11/2006, bug 5375964, replaced with below
            l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := l_start_date;
            l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := l_end_date;
            l_TerrRsc_Tbl(i).ORG_ID               := l_org_id;
            l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
            l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
*/
            IF rsc.start_date IS NULL THEN
                l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := l_start_date;
            ELSE
                l_TerrRsc_Tbl(i).START_DATE_ACTIVE    := rsc.start_date;
            END IF;

            IF rsc.end_date IS NULL THEN
                l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := l_end_date;
            ELSE
                l_TerrRsc_Tbl(i).END_DATE_ACTIVE      := rsc.end_date;
            END IF;

            l_TerrRsc_Tbl(i).ORG_ID               := l_org_id;
            l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG     := 'Y';
            l_TerrRsc_Tbl(i).GROUP_ID             := rsc.rsc_group_id;
            l_TerrRsc_Tbl(i).ATTRIBUTE_CATEGORY   := rsc.attribute_category;
            l_TerrRsc_Tbl(i).ATTRIBUTE1           := rsc.attribute1;
            l_TerrRsc_Tbl(i).ATTRIBUTE2           := rsc.attribute2;
            l_TerrRsc_Tbl(i).ATTRIBUTE3           := rsc.attribute3;
            l_TerrRsc_Tbl(i).ATTRIBUTE4           := rsc.attribute4;
            l_TerrRsc_Tbl(i).ATTRIBUTE5           := rsc.attribute5;
            l_TerrRsc_Tbl(i).ATTRIBUTE6           := rsc.attribute6;
            l_TerrRsc_Tbl(i).ATTRIBUTE7           := rsc.attribute7;
            l_TerrRsc_Tbl(i).ATTRIBUTE8           := rsc.attribute8;
            l_TerrRsc_Tbl(i).ATTRIBUTE9           := rsc.attribute9;
            l_TerrRsc_Tbl(i).ATTRIBUTE10          := rsc.attribute10;
            l_TerrRsc_Tbl(i).ATTRIBUTE11          := rsc.attribute11;
            l_TerrRsc_Tbl(i).ATTRIBUTE12          := rsc.attribute12;
            l_TerrRsc_Tbl(i).ATTRIBUTE13          := rsc.attribute13;
            l_TerrRsc_Tbl(i).ATTRIBUTE14          := rsc.attribute14;
            l_TerrRsc_Tbl(i).ATTRIBUTE15          := rsc.attribute15;


            FOR rsc_acc IN role_access(p_terr_group_id, role_type.role_code)
            LOOP
                 --dbms_output.put_line('rsc_acc.access_type   '||rsc_acc.access_type);
                 a := a+1;

                 IF ( rsc_acc.access_type='OPPORTUNITY' ) THEN
                     l_qual_type := 'OPPOR';
                 ELSE
                     l_qual_type := rsc_acc.access_type;
                 END IF;

                 SELECT JTF_TERR_RSC_ACCESS_S.NEXTVAL
                   INTO l_terr_rsc_access_id
                   FROM DUAL;

                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID  := l_terr_rsc_access_id;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE    := sysdate;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY     := l_user_id;
                 l_TerrRsc_Access_Tbl(a).CREATION_DATE       := sysdate;
                 l_TerrRsc_Access_Tbl(a).CREATED_BY          := l_user_id;
                 l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN   := l_login_id;
                 l_TerrRsc_Access_Tbl(a).TERR_RSC_ID         := l_terr_rsc_id ;
                 l_TerrRsc_Access_Tbl(a).ACCESS_TYPE         := l_qual_type;
                 l_TerrRsc_Access_Tbl(a).ORG_ID              := l_org_id;
                 l_TerrRsc_Access_Tbl(a).TRANS_ACCESS_CODE   := rsc_acc.trans_access_code;
                 l_TerrRsc_Access_Tbl(a).qualifier_tbl_index := i;

             END LOOP; /* FOR rsc_acc in NON_OVLY_role_access */

         END LOOP; /* FOR rsc in resource_grp */

    END LOOP;/* FOR role_type in role_interest_nonpi */

    l_init_msg_list :=FND_API.G_TRUE;

    Jtf_Territory_Resource_Pvt.create_terrresource (
                      p_api_version_number      => l_Api_Version_Number,
                      p_init_msg_list           => l_Init_Msg_List,
                      p_commit                  => l_Commit,
                      p_validation_level        => FND_API.g_valid_level_NONE,
                      x_return_status           => x_Return_Status,
                      x_msg_count               => x_Msg_Count,
                      x_msg_data                => x_msg_data,
                      p_terrrsc_tbl             => l_TerrRsc_tbl,
                      p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                      x_terrrsc_out_tbl         => x_TerrRsc_out_Tbl,
                      x_terrrsc_access_out_tbl  => x_TerrRsc_Access_out_Tbl
                   );
  END IF;

EXCEPTION
  WHEN OTHERS THEN

      IF G_Debug THEN
          Write_Log(2, 'Error in procedure update_terr_rscs_for_na');
      END IF;

      IF (role_access%ISOPEN) THEN
        CLOSE role_access;
      END IF;

      IF (resource_grp%ISOPEN) THEN
        CLOSE resource_grp;
      END IF;

      IF (roles_for_TG%ISOPEN) THEN
        CLOSE roles_for_TG;
      END IF;

      RAISE;
END update_terr_rscs_for_na;

/*----------------------------------------------------------
This procedure will update the attribute and date for a
named account in a territory group
----------------------------------------------------------*/
PROCEDURE update_terr_for_na( p_terr_grp_acct_id        IN NUMBER,
                              p_terr_group_id           IN NUMBER)
IS

BEGIN

    UPDATE jtf_terr_all jta
	set (jta.ATTRIBUTE1, jta.ATTRIBUTE2, jta.ATTRIBUTE3,
         jta.ATTRIBUTE4, jta.ATTRIBUTE5, jta.ATTRIBUTE6,
         jta.ATTRIBUTE7, jta.ATTRIBUTE8, jta.ATTRIBUTE9,
         jta.ATTRIBUTE10, jta.ATTRIBUTE11, jta.ATTRIBUTE12,
         jta.ATTRIBUTE13, jta.ATTRIBUTE14, jta.ATTRIBUTE15,
         jta.START_DATE_ACTIVE, jta.END_DATE_ACTIVE ) = (SELECT tty.ATTRIBUTE1, tty.ATTRIBUTE2, tty.ATTRIBUTE3,
                                   tty.ATTRIBUTE4, tty.ATTRIBUTE5, tty.ATTRIBUTE6,
                                   tty.ATTRIBUTE7, tty.ATTRIBUTE8, tty.ATTRIBUTE9,
                                   tty.ATTRIBUTE10, tty.ATTRIBUTE11, tty.ATTRIBUTE12,
                                   tty.ATTRIBUTE13, tty.ATTRIBUTE14, tty.ATTRIBUTE15,
                                   NVL( tty.START_DATE, TRUNC(jta.start_date_active) ),
								   NVL( tty.END_DATE, TRUNC(jta.end_date_active) )
                                   FROM jtf_tty_terr_grp_accts tty
                                   WHERE tty.terr_group_account_id = jta.terr_group_account_id
                                   AND tty.terr_group_id = jta.terr_group_id)
    WHERE jta.terr_group_account_id = p_terr_grp_acct_id
      AND jta.terr_group_id = p_terr_group_id;

END update_terr_for_na;

END JTF_TTY_GEN_TERR_PVT;

/
