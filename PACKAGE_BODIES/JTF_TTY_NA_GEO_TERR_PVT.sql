--------------------------------------------------------
--  DDL for Package Body JTF_TTY_NA_GEO_TERR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_NA_GEO_TERR_PVT" AS
/* $Header: jtfvnatb.pls 120.0 2005/06/02 18:22:11 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    OLD PACKAGE NAME:   JTF_TERR_ENGINE_GEN_PVT
--    PACKAGE NAME:   JTF_TTY_NA_GEO_TERR_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This Package will create the physical territories for the
--      self-service named accounts and geography territories
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is not publicly available for use
--
--    HISTORY
--      08/09/03    JRADHAKR         Created by Moving the named account
--                                   procedure from JTF_TERR_ENGINE_GEN_PVT
--
--    End of Comments
--
--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------

-- Stores the org_id for use in package Names
   g_cached_org_append           VARCHAR2(15);
--
-- Identifies the Package associated a
-- a territory with child nodes
   g_terr_pkgspec                terr_pkgspec_tbl_type;

-- Stores the position with the table spec
   g_stack_pointer               NUMBER := 0;

-- Store the information passed as
-- Concurrent program parameters
-- Module that uses Territories
   g_source_id                   NUMBER := 0;

   g_abs_source_id               NUMBER := 0;

-- Type of transaction for which the
-- the package is being generated
   g_qualifier_type              VARCHAR2(60);

-- Id of the corresponding transaction type
   g_qual_type_id                NUMBER := 0;

   TYPE t_pkgname IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;

   g_pkgname_tbl                 t_pkgname;
   g_Pointer                     NUMBER   := 0;
   G_Debug                       BOOLEAN  := FALSE;
   g_ProgramStatus               NUMBER   := 0;

   /* Global System Variables */
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;
   G_SYSDATE         DATE         := SYSDATE;

 PROCEDURE  create_geography_territory
  ( p_terr_group_rec  IN  TERR_GRP_REC_TYPE
  , p_org_id          IN  NUMBER
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_error_message    OUT NOCOPY  VARCHAR2
  );


   --------------------------------------------------------------------
   --                  Logging PROCEDURE
   --
   --     which = 1. write to log
   --     which = 2, write to output
   --------------------------------------------------------------------
   --
   PROCEDURE Write_Log(which number, mssg  varchar2 )   IS

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
       If Which = 2 Then
             FND_FILE.PUT(1, mssg);
             FND_FILE.NEW_LINE(1, 1);
       End IF;

       l_sub_mssg := 'Time = ' || l_time;
       --FND_FILE.PUT_LINE(FND_FILE.LOG, l_sub_mssg);
      -- dbms_output.put_line('LOG: ' || l_sub_mssg);

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
		** there is less than 250 characters left to be output	*/
        l_sub_mssg := SUBSTR(l_mssg, l_begin);
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_sub_mssg);
	    --dbms_output.put_line('LOG: ' || l_mssg );
   --
   END Write_Log;


  /* (1) START: ENABLE/DISABLE TERRITORY TRIGGERS */
   PROCEDURE alter_triggers(p_status VARCHAR2)
   IS
   BEGIN

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
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_QTYPE_USGS_BIUD DISABLE';
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
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_QTYPE_USGS_BIUD ENABLE';
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

   END alter_triggers;


 /* (1) START: DELETE ALL EXISTING NAMED ACCOUNT TERRITORIES */
 PROCEDURE cleanup_na_territories ( p_mode VARCHAR2 )
 IS

    /* get all the Territories to DELETE */
    CURSOR delterr IS
    SELECT terr_id
    from jtf_terr_all
    where terr_group_flag = 'Y';

 BEGIN

   /* TOTAL mode => re-generate all NA territories */
   IF (p_mode = 'TOTAL') THEN

          --DELETE territory value records
          DELETE FROM jtf_terr_values_all jtv
		  WHERE jtv.terr_qual_id IN
          ( SELECT jtq.terr_qual_id
		    FROM jtf_terr_qual_all jtq, jtf_terr_all jt
			WHERE jtq.terr_id = jt.terr_id
			  AND jt.terr_group_flag = 'Y' );

		   COMMIT;

          --Delete Territory Qualifer records
          DELETE from JTF_TERR_QUAL_ALL jtq
		  WHERE jtq.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );

		   COMMIT;

          --Delete Territory qual type usgs
          DELETE from JTF_TERR_QTYPE_USGS_ALL jtqu
		  WHERE jtqu.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );

		   COMMIT;

          --Delete Territory usgs
          DELETE from JTF_TERR_USGS_ALL	jtu
		  WHERE jtu.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );

		   COMMIT;

          --Delete Territory Resource Access
          DELETE from JTF_TERR_RSC_ACCESS_ALL jtra
          WHERE jtra.terr_rsc_id IN
          ( SELECT jtr.terr_rsc_id
		    FROM jtf_terr_rsc_all jtr, jtf_terr_all jt
			WHERE jtr.terr_id = jt.terr_id
			  AND jt.terr_group_flag = 'Y' );

		   COMMIT;

          -- Delete the Territory Resource records
          DELETE from JTF_TERR_RSC_ALL	jtr
		  WHERE jtr.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );

		   COMMIT;

          --Delete Territory record
          DELETE from JTF_TERR_ALL jt
		  WHERE jt.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );

		   COMMIT;

   END IF;
   /* (1) END: DELETE ALL EXISTING NAMED ACCOUNT TERRITORIES */

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     NULL;

 END cleanup_na_territories;


/*----------------------------------------------------------
This procedure will create Named account and Overlay Territory
from the Named accounts.
----------------------------------------------------------*/

PROCEDURE generate_named_overlay_terr(p_mode VARCHAR2)
IS


    TYPE terrqual_type IS RECORD(
    	terr_qual_id		NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE terrqual_tbl_type IS TABLE OF terrqual_type
    	INDEX BY BINARY_INTEGER;


    TYPE seeded_qual_type IS RECORD(
    	seeded_qualifier_id	NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE seeded_qual_tbl_type IS TABLE OF seeded_qual_type
    	INDEX BY BINARY_INTEGER;

    TYPE role_typ IS RECORD(
    	grp_role_id	NUMBER:=FND_API.G_MISS_NUM
    );

    TYPE grp_role_tbl_type IS TABLE OF role_typ
    	INDEX BY BINARY_INTEGER;

    l_terrqual_tbl		terrqual_tbl_type;
    l_terrqual_empty_tbl	terrqual_tbl_type;

    l_terr_group_rec		JTF_TTY_NA_GEO_TERR_PVT.TERR_GRP_REC_TYPE;

    l_overnon_role_tbl		grp_role_tbl_type;
    l_overnon_role_empty_tbl    grp_role_tbl_type;

    l_terr_qual_id		NUMBER;
    l_id_used_flag		VARCHAR2(1);
    l_low_value_char_id	NUMBER;
    l_qual_usgs_id 	NUMBER;
    l_terr_usg_id	NUMBER;
    l_qual_type_usg_id 	NUMBER;
    l_terr_qtype_usg_id	NUMBER;
    l_terr_type_usg_id  NUMBER;
    l_type_qtype_usg_id	NUMBER;
    l_terr_rsc_id		NUMBER;
    l_terr_rsc_access_id	NUMBER;
    l_access_type		VARCHAR2(30);

    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_init_msg_list         varchar2(1);
    l_commit                varchar2(1);
    x_return_status         varchar2(1);
    x_msg_count             number;
    x_msg_data              varchar2(2000);

    l_return_status         varchar2(30);
    l_error_message         varchar2(255);

    i	NUMBER;
    j	NUMBER;
    k	NUMBER;
    l	NUMBER;
    a	NUMBER;

    l_prev_seedqual		number;
    l_prev_terr_id		number;

    l_qualifier		    NUMBER;

    x_terr_id           NUMBER;

    l_terr_all_rec		          JTF_TERRITORY_PVT.terr_all_rec_type;
    l_terr_usgs_tbl               JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_tbl               JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl             JTF_TERRITORY_PVT.terr_values_tbl_type;

	/* Customer Name Range + Postal Code Qualifier Support */
    l_terr_qual_tbl_mc1           JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl_mc1         JTF_TERRITORY_PVT.terr_values_tbl_type;
	/* DUNS# Qualifier Support */
    l_terr_qual_tbl_mc2           JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl_mc2         JTF_TERRITORY_PVT.terr_values_tbl_type;

    l_terr_usgs_empty_tbl         JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_empty_tbl JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_empty_tbl         JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_empty_tbl       JTF_TERRITORY_PVT.terr_values_tbl_type;

    x_terr_usgs_out_tbl	  	      JTF_TERRITORY_PVT.terr_usgs_out_tbl_type;
    x_terr_qualtypeusgs_out_tbl	  JTF_TERRITORY_PVT.terr_qualtypeusgs_out_tbl_type;
    x_terr_qual_out_tbl       	  JTF_TERRITORY_PVT.terr_qual_out_tbl_type;
    x_terr_values_out_tbl		  JTF_TERRITORY_PVT.terr_values_out_tbl_type;

    l_TerrRsc_Tbl                 JTF_TERRITORY_RESOURCE_PVT.TerrResource_tbl_type;
    l_TerrRsc_Access_Tbl          JTF_TERRITORY_RESOURCE_PVT.TerrRsc_Access_tbl_type ;
    l_TerrRsc_empty_Tbl           JTF_TERRITORY_RESOURCE_PVT.TerrResource_tbl_type;
    l_TerrRsc_Access_empty_Tbl    JTF_TERRITORY_RESOURCE_PVT.TerrRsc_Access_tbl_type ;
    x_TerrRsc_Out_Tbl             JTF_TERRITORY_RESOURCE_PVT.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      JTF_TERRITORY_RESOURCE_PVT.TerrRsc_Access_out_tbl_type;

    l_commitcount                 NUMBER := 1000;
    l_row_inserted                NUMBER := 0;
    l_pi_count                    NUMBER := 0;
    l_prev_qual_usg_id            NUMBER;
    l_na_catchall_flag            VARCHAR2(1);
    l_overlap_catchall_flag       VARCHAR2(1);

	l_role_counter                NUMBER := 0;


    /* Active Territory Groups with
    ** Active Top-Level Territories */
    /* bug#2933116: JDOCHERT: 05/27/03: support for DUNS# Qualifier */

    CURSOR grp IS
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
	   , A.NUM_WINNERS  /* JDOCHERT: 07/29/03: BUG#3072230 */
           , A.SELF_SERVICE_TYPE
           , B.ORG_ID
    FROM    JTF_TTY_TERR_GROUPS A
          , JTF_TERR_ALL B
    WHERE A.parent_terr_id      = b.terr_id
      AND ( a.active_to_date >= SYSDATE OR a.active_to_date IS NULL )
      AND a.active_from_date <= SYSDATE;

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
         AND nar.rsc_role_code = tgr.role_code
         AND ra.terr_group_role_id = tgr.terr_group_role_id
         AND NOT EXISTS (
            SELECT NULL
            FROM jtf_tty_role_prod_int rpi
            WHERE rpi.terr_group_role_id = tgr.terr_group_role_id );


    /* Access Types for a Territory Group */
    CURSOR na_access(l_terr_group_id number) IS
    SELECT distinct a.access_type
    from jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = l_terr_group_id;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR NON_OVLY_role_access( lp_terr_group_id number
	                           , lp_role varchar2) IS
    SELECT distinct a.access_type
    from jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = lp_terr_group_id
      and b.role_code          = lp_role
	  AND NOT EXISTS (
	       /* Product Interest does not exist for this role */
	       SELECT NULL
		   FROM jtf_tty_role_prod_int rpi
		   WHERE rpi.terr_group_role_id = B.TERR_GROUP_ROLE_ID )
    order by a.access_type  ;


    /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id number,l_role varchar2) IS
    SELECT distinct a.access_type
    from jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = l_terr_group_id
      and b.role_code          = l_role
    order by a.access_type  ;

    /* Roles WITHOUT a Product Iterest defined */
    CURSOR role_interest_nonpi(l_terr_group_id number) IS
    SELECT  b.role_code role_code
           --,a.interest_type_id
           ,b.terr_group_id
    from jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id(+) = b.terr_group_role_id
      and b.terr_group_id         = l_terr_group_id
      and a.terr_group_role_id is  null
    order by b.role_code;

    /* Roles WITH a Product Iterest defined */
    CURSOR role_pi( lp_terr_group_id         NUMBER
	              , lp_terr_group_account_id NUMBER) IS
    SELECT distinct
	       b.role_code role_code
	     , r.role_name role_name
    from jtf_rs_roles_vl r
       , jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    where r.role_code = b.role_code
      and a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = lp_terr_group_id
	  AND EXISTS (
	         /* Named Account exists with Salesperson with this role */
	         SELECT NULL
			 FROM jtf_tty_named_acct_rsc nar, jtf_tty_terr_grp_accts tga
			 WHERE tga.terr_group_account_id = nar.terr_group_account_id
			   AND nar.terr_group_account_id = lp_terr_group_account_id
			   AND tga.terr_group_id = b.terr_group_id
			   AND nar.rsc_role_code = b.role_code );

    /* Product Interest for a Role */
    CURSOR role_pi_interest(l_terr_group_id number,l_role varchar2) IS
    SELECT  a.interest_type_id
    from jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = l_terr_group_id
      and b.role_code          = l_role;

    /* Named Account Catch-All Customer Keyname values */
    CURSOR catchall_cust(l_terr_group_id number) IS
    SELECT distinct b.comparison_operator
          ,b.value1_char
    from jtf_tty_terr_grp_accts a
       , jtf_tty_acct_qual_maps b
    where a.named_account_id = b.named_account_id
      and a.terr_group_id    = l_terr_group_id
      and b.qual_usg_id      = -1012
    order by b.comparison_operator,b.value1_char;

   /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id
   since the resource is specific for a terr_group_account */
    CURSOR resource_grp(l_terr_group_acct_id number,l_role varchar2) IS
    SELECT distinct b.resource_id
         , b.rsc_group_id
         , b.rsc_resource_type
    from jtf_tty_terr_grp_accts a
       , jtf_tty_named_acct_rsc b
    where a.terr_group_account_id = l_terr_group_acct_id
      and a.terr_group_account_id = b.terr_group_account_id
      and b.rsc_role_code = l_role;

    /* Should Unassigned NAs go to Sales Manager or NA Catch-All? */
    -- WHERE c.dn_jnr_assigned_flag = 'Y';


    /* get the DUNS# for the Named Account:
    ** used for NAMED ACCOUNT territory creation */
    CURSOR get_party_duns(LP_terr_group_id number) IS
    SELECT substr(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
		 , a.duns_number_c
    from hz_parties a
	   , jtf_tty_named_accts b
	   , jtf_tty_terr_grp_accts c
    where c.terr_group_id = LP_terr_group_id
      and b.named_account_id = c.named_account_id
      and a.party_id = b.party_id
      and a.status = 'A'
	  AND a.DUNS_NUMBER_C IS NOT NULL
	  AND EXISTS (
	        /* Salesperson exists for this Named Account */
	        SELECT NULL
			FROM jtf_tty_named_acct_rsc nar
			WHERE nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );


    /* get the PARTY_NAME + POSTAL_CODE for the Named Account:
    ** used for NAMED ACCOUNT territory creation */
    CURSOR get_party_name(LP_terr_group_id number) IS
    SELECT substr(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
		 , a.duns_number_c
    from hz_parties a
	   , jtf_tty_named_accts b
	   , jtf_tty_terr_grp_accts c
    where c.terr_group_id = LP_terr_group_id
      and b.named_account_id = c.named_account_id
      and a.party_id = b.party_id
      and a.status = 'A'
      and exists (
	         /* Named Account has at least 1 Mapping Rule */
	         SELECT 1
             from jtf_tty_acct_qual_maps d
             where d.named_account_id = c.named_account_id )
	  AND EXISTS (
	        /* Salesperson exists for this Named Account */
	        SELECT NULL
			FROM jtf_tty_named_acct_rsc nar
			WHERE nar.terr_group_account_id = C.TERR_GROUP_ACCOUNT_ID );


    /* get the DUNS# for the Named Account:
    ** used for OVERLAY territory creation */
    CURSOR get_OVLY_party_duns(LP_terr_group_id number) IS
    SELECT substr(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
		 , a.duns_number_c
    from hz_parties a
	   , jtf_tty_named_accts b
	   , jtf_tty_terr_grp_accts c
    where c.terr_group_id = LP_terr_group_id
      and b.named_account_id = c.named_account_id
      and a.party_id = b.party_id
      and a.status = 'A'
	  AND a.DUNS_NUMBER_C IS NOT NULL
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
    CURSOR get_OVLY_party_name(LP_terr_group_id number) IS
    SELECT substr(a.party_name, 1, 45) || ': ' || a.postal_code name
         , b.named_account_id
         , c.terr_group_account_id
		 , a.duns_number_c
    from hz_parties a
	   , jtf_tty_named_accts b
	   , jtf_tty_terr_grp_accts c
    where c.terr_group_id = LP_terr_group_id
      and b.named_account_id = c.named_account_id
      and a.party_id = b.party_id
      and a.status = 'A'
      and exists (
	         /* Named Account has at least 1 Mapping Rule */
	         SELECT 1
             from jtf_tty_acct_qual_maps d
             where d.named_account_id = c.named_account_id )
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


    /* Should Unassigned NAs go to Sales Manager or NA Catch-All? */
    -- WHERE c.dn_jnr_assigned_flag = 'Y';

    /* get Customer Keynames and Postal Code mappings
    ** for the Named Account  */
    /* bug#2925153: JRADHAKR: Added value2_char */
    CURSOR match_rule1( l_na_id number) IS
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
    CURSOR match_rule3(l_na_id number) IS
    SELECT -1120 qual_usg_id
         , '=' comparison_operator
         , hzp.duns_number_c value1_char
    FROM hz_parties hzp, jtf_tty_named_accts na
    where hzp.status = 'A'
	  AND hzp.party_id = na.party_id
	  AND na.named_account_id = l_na_id;


    /* Get Top-Level Parent Territory details */
    CURSOR topterr(l_terr number) IS
    SELECT name
         , description
         , rank
         , parent_territory_id
	 , terr_id
    from jtf_terr_all
    where terr_id = l_terr;

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
    CURSOR role_no_pi(l_terr_group_id number) IS
    SELECT distinct b.role_code
    from jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
       , jtf_tty_role_prod_int c
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = l_terr_group_id
      and a.access_type        = 'ACCOUNT'
      and c.terr_group_role_id = b.terr_group_role_id
      and not exists ( SELECT  1
                     from jtf_tty_role_prod_int e
                        , jtf_tty_terr_grp_roles d
                     where e.terr_group_role_id (+) = d.terr_group_role_id
                       and d.terr_group_id          = b.terr_group_id
                       and d.role_code              = b.role_code
                       and e.interest_type_id is  null);



    l_overlay_top  number;
    l_overlay      number;
    l_nacat        number;
    l_id           number;
    l_ovnon_flag   varchar2(1):='N';

    l_na_count     number;

	l_terr_exists NUMBER;

BEGIN

   /* JDOCHERT: 07/09/03:
   ** START: Disable triggers in
   ** TOTAL mode */
   IF (p_mode = 'TOTAL') THEN
      alter_triggers(p_status => 'DISABLE');
   END IF;

   /* (1) JDOCHERT: 07/01/03:
   ** START: DELETE ALL EXISTING NAMED ACCOUNT TERRITORIES
   ** INCREMENTAL or TOTAL mode */
   cleanup_na_territories(p_mode => p_mode);

  /* Set Global Application Short Name */
  IF G_APP_SHORT_NAME IS NULL THEN
    G_APP_SHORT_NAME := 'JTF';
  END IF;

  /* (2) START: CREATE NAMED ACCOUNT TERRITORY CREATION
  ** FOR EACH TERRITORY GROUP */
  for terr_group in grp LOOP

     write_log(2, '');
     write_log(2, '----------------------------------------------------------');
     write_log(2, 'BEGIN: Territory Creation for Territory Group: ' ||
                  terr_group.terr_group_id || ' : ' ||
                  terr_group.terr_group_name );

     /* reset these processing values for the Territory Group */
     l_na_catchall_flag      := 'N';
     l_overlap_catchall_flag := 'N';
     l_ovnon_flag            := 'N';
     l_overnon_role_tbl      := l_overnon_role_empty_tbl;


	 /** Roles with No Product Interest */
     i:=0;
     for overlayandnon in role_no_pi(terr_group.terr_group_id) loop

        l_ovnon_flag:='Y';
        i :=i +1;

        SELECT  JTF_TTY_TERR_GRP_ROLES_S.nextval
        	into l_id
        FROM DUAL;

        l_overnon_role_tbl(i).grp_role_id:= l_id;
        --

        INSERT into JTF_TTY_TERR_GRP_ROLES(
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
              , terr_group.terr_group_id
              , overlayandnon.role_code
              , G_USER_ID
              , sysdate
              , G_USER_ID
              , sysdate
              , G_LOGIN_ID);
          INSERT into JTF_TTY_ROLE_ACCESS(
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
                JTF_TTY_ROLE_ACCESS_S.nextval
                , 1
                , l_overnon_role_tbl(i).grp_role_id
                , 'ACCOUNT'
                , G_USER_ID
                , sysdate
                , G_USER_ID
                , sysdate
                , G_LOGIN_ID);

      end loop; /* for overlayandnon in role_no_pi */



        if TERR_GROUP.self_service_type = 'NAMED_ACCOUNT' then
            /* does Territory Group have at least 1 Named Account ? */
            SELECT COUNT(*)
              INTO l_na_count
            from jtf_tty_terr_groups g
               , jtf_tty_terr_grp_accts ga
               , jtf_tty_named_accts a
            where g.terr_group_id     = ga.terr_group_id
              AND ga.named_account_id = a.named_account_id
              AND g.terr_group_id     = TERR_GROUP.TERR_GROUP_ID
              AND ROWNUM < 2;
         else
            /* Fix for the bug 3135657. Added jtf_tty_geo_grp_values */

            /* does Territory Group have at least 1 Geo Territory ? */
            SELECT COUNT(*)
              INTO l_na_count
            from jtf_tty_terr_groups tgrp
               , jtf_tty_geo_grp_values gterr
            where tgrp.terr_group_id     = gterr.terr_group_id
              AND ROWNUM < 2;

         end if;

	  /*********************************************************************/
	  /*********************************************************************/
	  /************** NON-OVERLAY TERRITORY CREATION ***********************/
	  /*********************************************************************/
	  /*********************************************************************/

      /* BEGIN: if Territory Group exists with Named Accounts
      ** then auto-create territory definitions */

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
    	  L_TERR_ALL_REC.TERR_ID           := terr_group.terr_group_id;
    	  L_TERR_ALL_REC.LAST_UPDATE_DATE  := TERR_GROUP.LAST_UPDATE_DATE;
     	  L_TERR_ALL_REC.LAST_UPDATED_BY   := G_USER_ID;
     	  L_TERR_ALL_REC.CREATION_DATE     := TERR_GROUP.CREATION_DATE;
     	  L_TERR_ALL_REC.CREATED_BY        := G_USER_ID ;
     	  L_TERR_ALL_REC.LAST_UPDATE_LOGIN     := G_LOGIN_ID;
     	  L_TERR_ALL_REC.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
     	  L_TERR_ALL_REC.NAME                  := TERR_GROUP.TERR_GROUP_NAME;
     	  L_TERR_ALL_REC.START_DATE_ACTIVE     := TERR_GROUP.ACTIVE_FROM_DATE ;
     	  L_TERR_ALL_REC.END_DATE_ACTIVE       := TERR_GROUP.ACTIVE_TO_DATE;
     	  L_TERR_ALL_REC.PARENT_TERRITORY_ID   := TERR_GROUP.PARENT_TERR_ID;
     	  L_TERR_ALL_REC.RANK                  := TERR_GROUP.RANK;
     	  L_TERR_ALL_REC.TEMPLATE_TERRITORY_ID := NULL;
     	  L_TERR_ALL_REC.TEMPLATE_FLAG         := 'N';
     	  L_TERR_ALL_REC.ESCALATION_TERRITORY_ID   := NULL;
     	  L_TERR_ALL_REC.ESCALATION_TERRITORY_FLAG := 'N';
     	  L_TERR_ALL_REC.OVERLAP_ALLOWED_FLAG      := NULL;
     	  L_TERR_ALL_REC.DESCRIPTION               := TERR_GROUP.TERR_GROUP_NAME;
     	  L_TERR_ALL_REC.UPDATE_FLAG               := 'N';
     	  L_TERR_ALL_REC.AUTO_ASSIGN_RESOURCES_FLAG:= NULL;
     	  L_TERR_ALL_REC.NUM_WINNERS               := NULL ;

          /* ORG_ID IS SET TO SAME VALUE AS TERRITORY
          ** GROUP's Top-Level Parent Territory */
          l_terr_all_rec.ORG_ID := terr_group.ORG_ID;


          /* ORACLE SALES AND TELESALES USAGE */
          SELECT JTF_TERR_USGS_S.nextval
    	  INTO l_terr_usg_id
    	  FROM DUAL;

          l_terr_usgs_tbl(1).SOURCE_ID        := -1001;
    	  l_terr_usgs_tbl(1).TERR_USG_ID      := l_terr_usg_id;
          l_terr_usgs_tbl(1).LAST_UPDATE_DATE := terr_group.LAST_UPDATE_DATE;
      	  l_terr_usgs_tbl(1).LAST_UPDATED_BY  := G_USER_ID;
      	  l_terr_usgs_tbl(1).CREATION_DATE    := terr_group.CREATION_DATE;
	  l_terr_usgs_tbl(1).CREATED_BY       := G_USER_ID;
	  l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:= G_LOGIN_ID;
	  l_terr_usgs_tbl(1).TERR_ID          := null;
	  l_terr_usgs_tbl(1).ORG_ID           := terr_group.ORG_ID;


          /* ACCOUNT TRANSACTION TYPE */
          SELECT JTF_TERR_QTYPE_USGS_S.nextval
            into l_terr_qtype_usg_id
          FROM DUAL;

          l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID      := -1001;
	  l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
       	  l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE      := terr_group.LAST_UPDATE_DATE;
       	  l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY       := G_USER_ID;
       	  l_terr_qualtypeusgs_tbl(1).CREATION_DATE         := terr_group.CREATION_DATE;
	  l_terr_qualtypeusgs_tbl(1).CREATED_BY            := G_USER_ID;
	  l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
	  l_terr_qualtypeusgs_tbl(1).TERR_ID               := null;
	  l_terr_qualtypeusgs_tbl(1).ORG_ID                := terr_group.ORG_ID;

          /* LEAD TRANSACTION TYPE */
          SELECT JTF_TERR_QTYPE_USGS_S.nextval
       	  into l_terr_qtype_usg_id
          FROM DUAL;

	  l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID      := -1002;
     	  l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
     	  l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE      := terr_group.LAST_UPDATE_DATE;
     	  l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY       := G_USER_ID;
     	  l_terr_qualtypeusgs_tbl(2).CREATION_DATE         := terr_group.CREATION_DATE;
	  l_terr_qualtypeusgs_tbl(2).CREATED_BY            := G_USER_ID;
	  l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
	  l_terr_qualtypeusgs_tbl(2).TERR_ID               := null;
	  l_terr_qualtypeusgs_tbl(2).ORG_ID                := terr_group.ORG_ID;

          /* OPPORTUNITY TRANSACTION TYPE */
          SELECT JTF_TERR_QTYPE_USGS_S.nextval
       	  into l_terr_qtype_usg_id
          FROM DUAL;

	  l_terr_qualtypeusgs_tbl(3).QUAL_TYPE_USG_ID      := -1003;
     	  l_terr_qualtypeusgs_tbl(3).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
          l_terr_qualtypeusgs_tbl(3).LAST_UPDATE_DATE      := terr_group.LAST_UPDATE_DATE;
     	  l_terr_qualtypeusgs_tbl(3).LAST_UPDATED_BY       := G_USER_ID;
     	  l_terr_qualtypeusgs_tbl(3).CREATION_DATE         := terr_group.CREATION_DATE;
	  l_terr_qualtypeusgs_tbl(3).CREATED_BY            := G_USER_ID;
	  l_terr_qualtypeusgs_tbl(3).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
	  l_terr_qualtypeusgs_tbl(3).TERR_ID               := null;
	  l_terr_qualtypeusgs_tbl(3).ORG_ID                := terr_group.ORG_ID;

          l_init_msg_list  := FND_API.G_TRUE;


          /* set org context using ORG_ID of Territory
          ** Group'S TOP-LEVEL PARENT TERRITORY */
		  -- 07/08/03: JDOCHERT: bug#3023653
		  --
          --MO_GLOBAL.SET_ORG_CONTEXT(TERR_GROUP.ORG_ID, NULL);
		  --

          /* CALL CREATE TERRITORY API */
           jtf_territory_pvt.create_territory (
              p_api_version_number         => l_api_version_number,
              p_init_msg_list              => l_init_msg_list,
              p_commit                     => l_commit,
              p_validation_level           => fnd_api.g_valid_level_NONE,
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
                , TERR_GROUP_ID = TERR_GROUP.TERR_GROUP_ID
				, NUM_WINNERS = TERR_GROUP.NUM_WINNERS
              WHERE TERR_ID = X_TERR_ID;

              L_NACAT := X_TERR_ID;

              WRITE_LOG(2,' Top level Named Account territory created: TERR_ID# '||X_TERR_ID);

          ELSE
               WRITE_LOG(2,'ERROR: PLACEHOLDER TERRITORY CREATION FAILED ' ||
			               'FOR TERRITORY_GROUP_ID# ' ||TERR_GROUP.TERR_GROUP_ID);
               X_MSG_DATA :=  FND_MSG_PUB.GET(1, FND_API.G_FALSE);
               WRITE_LOG(2,X_MSG_DATA);

          END IF;
		  /* END: SUCCESSFUL TERRITORY CREATION? */
          /*************************************************************/
          /* (3) END: CREATE PLACEHOLDER TERRITORY FOR TERRITORY GROUP */
          /*************************************************************/

        if TERR_GROUP.self_service_type = 'NAMED_ACCOUNT' then

          /****************************************************************/
          /* (4) START: CREATE NA CATCH-ALL TERRITORY FOR TERRITORY GROUP */
          /****************************************************************/

	  IF ( terr_group.matching_rule_code IN ('1', '2') AND
		       terr_group.generate_catchall_flag = 'Y' ) THEN

	     /* RESET TABLES */
             L_TERR_USGS_TBL         := L_TERR_USGS_EMPTY_TBL;
	     L_TERR_QUALTYPEUSGS_TBL := L_TERR_QUALTYPEUSGS_EMPTY_TBL;
	     L_TERR_QUAL_TBL         := L_TERR_QUAL_EMPTY_TBL;
             L_TERR_VALUES_TBL       := L_TERR_VALUES_EMPTY_TBL;
             L_TERRRSC_TBL           := L_TERRRSC_EMPTY_TBL;
             L_TERRRSC_ACCESS_TBL    := L_TERRRSC_ACCESS_EMPTY_TBL;


	     /* TERRITORY HEADER */
	     /* Ensure static TERR_ID to benefit TAP Performance */
             L_TERR_ALL_REC.TERR_ID                := terr_group.terr_group_id * -1;
             L_TERR_ALL_REC.LAST_UPDATE_DATE       := TERR_GROUP.LAST_UPDATE_DATE;
	     L_TERR_ALL_REC.LAST_UPDATED_BY        := G_USER_ID;
	     L_TERR_ALL_REC.CREATION_DATE          := TERR_GROUP.CREATION_DATE;
	     L_TERR_ALL_REC.CREATED_BY             := G_USER_ID;
	     L_TERR_ALL_REC.LAST_UPDATE_LOGIN      := G_LOGIN_ID;
	     L_TERR_ALL_REC.APPLICATION_SHORT_NAME := G_APP_SHORT_NAME;
	     L_TERR_ALL_REC.NAME                   := TERR_GROUP.TERR_GROUP_NAME ||' (CATCH-ALL)';
	     L_TERR_ALL_REC.START_DATE_ACTIVE      := TERR_GROUP.ACTIVE_FROM_DATE ;
	     L_TERR_ALL_REC.END_DATE_ACTIVE        := TERR_GROUP.ACTIVE_TO_DATE;
	     L_TERR_ALL_REC.PARENT_TERRITORY_ID    :=  X_TERR_ID;

             --
             -- 01/20/03: JDOCHERT: CHANGE RANK OF CATCH-ALL
             -- TO BE LESS THAT NAMED ACCOUNT TERRITORIES
             --
             L_TERR_ALL_REC.RANK := TERR_GROUP.RANK + 100;
             --

             L_TERR_ALL_REC.TEMPLATE_TERRITORY_ID      := NULL;
	     L_TERR_ALL_REC.TEMPLATE_FLAG              := 'N';
	     L_TERR_ALL_REC.ESCALATION_TERRITORY_ID    := NULL;
	     L_TERR_ALL_REC.ESCALATION_TERRITORY_FLAG  := 'N';
	     L_TERR_ALL_REC.OVERLAP_ALLOWED_FLAG       := NULL;
	     L_TERR_ALL_REC.DESCRIPTION                := TERR_GROUP.TERR_GROUP_NAME||' (CATCH-ALL)';
	     L_TERR_ALL_REC.UPDATE_FLAG                := 'N';
	     L_TERR_ALL_REC.AUTO_ASSIGN_RESOURCES_FLAG := NULL;

	     /* ORG_ID IS SET TO SAME VALUE AS TERRITORY
             ** GROUP's Top-Level Parent Territory */
             l_terr_all_rec.ORG_ID                     := terr_group.ORG_ID;
	     l_terr_all_rec.NUM_WINNERS                := null ;


	     /* Oracle Sales and Telesales Usage */
             SELECT   JTF_TERR_USGS_S.nextval
   	         into l_terr_usg_id
      	     FROM DUAL;

    	    l_terr_usgs_tbl(1).TERR_USG_ID       := l_terr_usg_id;
     	    l_terr_usgs_tbl(1).LAST_UPDATE_DATE  := terr_group.LAST_UPDATE_DATE;
            l_terr_usgs_tbl(1).LAST_UPDATED_BY   := G_USER_ID;
            l_terr_usgs_tbl(1).CREATION_DATE     := terr_group.CREATION_DATE;
	    l_terr_usgs_tbl(1).CREATED_BY        := G_USER_ID;
	    l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN := G_LOGIN_ID;
	    l_terr_usgs_tbl(1).TERR_ID           := null;
	    l_terr_usgs_tbl(1).SOURCE_ID         := -1001;
	    l_terr_usgs_tbl(1).ORG_ID            := terr_group.ORG_ID;


            i:=0;
            FOR actype in na_access(terr_group.terr_group_id) LOOP

             i:=i+1;
             if actype.access_type='ACCOUNT' then

               /* ACCOUNT TRANSACTION TYPE */
                SELECT JTF_TERR_QTYPE_USGS_S.nextval
      	        into l_terr_qtype_usg_id
                FROM DUAL;

         	l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID := l_terr_qtype_usg_id;
      		l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE      := terr_group.LAST_UPDATE_DATE;
      		l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY       := G_USER_ID;
      		l_terr_qualtypeusgs_tbl(i).CREATION_DATE         := terr_group.CREATION_DATE;
		l_terr_qualtypeusgs_tbl(i).CREATED_BY            := G_USER_ID;
		l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN     := G_LOGIN_ID;
		l_terr_qualtypeusgs_tbl(i).TERR_ID               := null;
		l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID      := -1001;
		l_terr_qualtypeusgs_tbl(i).ORG_ID                := terr_group.ORG_ID;

             elsif actype.access_type='LEAD' then

		/* LEAD TRANSACTION TYPE */
                SELECT JTF_TERR_QTYPE_USGS_S.nextval
         	    INTO l_terr_qtype_usg_id
                FROM   DUAL;

        	l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
      	        l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
      		l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
      		l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
		l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
		l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
		l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
		l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1002;
		l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

             elsif actype.access_type='OPPORTUNITY' then

                /* OPPORTUNITY TRANSACTION TYPE */
                SELECT   JTF_TERR_QTYPE_USGS_S.nextval
      	        into l_terr_qtype_usg_id
                FROM DUAL;

       		l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
      		l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
      		l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
      		l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
		l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
		l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
		l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
		l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
		l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

             end if;
           end loop;



	  /*
	  ** Customer Name Range Qualifier -1012 */
          SELECT JTF_TERR_QUAL_S.nextval
   	      into l_terr_qual_id
      	  FROM DUAL;

      	  l_terr_qual_tbl(1).TERR_QUAL_ID :=l_terr_qual_id;
      	  l_terr_qual_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
	  l_terr_qual_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
	  l_terr_qual_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
	  l_terr_qual_tbl(1).CREATED_BY := terr_group.CREATED_BY;
	  l_terr_qual_tbl(1).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
	  l_terr_qual_tbl(1).TERR_ID:=null;
	  l_terr_qual_tbl(1).QUAL_USG_ID :=-1012;
	  l_terr_qual_tbl(1).QUALIFIER_MODE:=NULL;
	  l_terr_qual_tbl(1).OVERLAP_ALLOWED_FLAG:='N';
	  l_terr_qual_tbl(1).USE_TO_NAME_FLAG:=NULL;
	  l_terr_qual_tbl(1).GENERATE_FLAG:=NULL;
	  l_terr_qual_tbl(1).ORG_ID:=terr_group.ORG_ID;

	  /*
	  ** VARCHAR2 data value */
          l_id_used_flag :='N' ;

	  /*
	  ** get all the Customer Name Range Values for all the Named Accounts
	  ** that belong to this Territory Group */
          k:=0;

	  FOR cust_value in catchall_cust(terr_group.TERR_GROUP_ID) LOOP

	     k:=k+1;

             l_terr_values_tbl(k).TERR_VALUE_ID:=null;

	     l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
	     l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
	     l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
	     l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
	     l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
	     l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
	     l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
	     l_terr_values_tbl(k).COMPARISON_OPERATOR := cust_value.COMPARISON_OPERATOR;
	     l_terr_values_tbl(k).LOW_VALUE_CHAR:= cust_value.value1_char;

	     l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
	     l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
	     l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
	     l_terr_values_tbl(k).VALUE_SET :=NULL;
	     l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
	     l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
	     l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
	     l_terr_values_tbl(k).CURRENCY_CODE :=null;
	     l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
	     l_terr_values_tbl(k).ID_USED_FLAG :=l_id_used_flag;
	     l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

	     l_terr_values_tbl(k).qualifier_tbl_index := 1;

	  end loop;

	  l_init_msg_list := FND_API.G_TRUE;

	  -- 07/08/03: JDOCHERT: bug#3023653
	  -- mo_global.set_org_context(terr_group.ORG_ID,null);
	  --
          jtf_territory_pvt.create_territory (
              p_api_version_number         => l_api_version_number,
              p_init_msg_list              => l_init_msg_list,
              p_commit                     => l_commit,
              p_validation_level           => fnd_api.g_valid_level_NONE,
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

              /* JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG */
              UPDATE JTF_TERR_ALL
              set TERR_GROUP_FLAG = 'Y'
                , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                , CATCH_ALL_FLAG = 'Y'
              where terr_id = x_terr_id;

              l_init_msg_list :=FND_API.G_TRUE;

              SELECT   JTF_TERR_RSC_S.nextval
         	  into l_terr_rsc_id
              FROM DUAL;

              l_TerrRsc_Tbl(1).terr_id := x_terr_id;
              l_TerrRsc_Tbl(1).TERR_RSC_ID :=l_terr_rsc_id;
              l_TerrRsc_Tbl(1).LAST_UPDATE_DATE:=terr_group.LAST_UPDATE_DATE;
      	      l_TerrRsc_Tbl(1).LAST_UPDATED_BY:=terr_group.LAST_UPDATED_BY;
      	      l_TerrRsc_Tbl(1).CREATION_DATE:=terr_group.CREATION_DATE;
	      l_TerrRsc_Tbl(1).CREATED_BY:=terr_group.CREATED_BY;
	      l_TerrRsc_Tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
	      l_TerrRsc_Tbl(1).RESOURCE_ID:=terr_group.catch_all_resource_id;
	      l_TerrRsc_Tbl(1).RESOURCE_TYPE:=terr_group.catch_all_resource_type;

	      --l_TerrRsc_Tbl(1).ROLE:=tran_type.role_code;
              l_TerrRsc_Tbl(1).ROLE:='SALES_ADMIN';
	      l_TerrRsc_Tbl(1).PRIMARY_CONTACT_FLAG:='N';
	      l_TerrRsc_Tbl(1).START_DATE_ACTIVE:=terr_group.active_from_date ;
	      l_TerrRsc_Tbl(1).END_DATE_ACTIVE:=terr_group.active_to_date ;
	      l_TerrRsc_Tbl(1).ORG_ID:=terr_group.ORG_ID;
	      l_TerrRsc_Tbl(1).FULL_ACCESS_FLAG:='Y';
	      l_TerrRsc_Tbl(1).GROUP_ID:=-999;

              a:=0;
              --
              FOR rsc_acc in na_access(terr_group.terr_group_id) LOOP

                 a := a+1;

		 /* ACCOUNT ACCESS TYPE */
                 IF rsc_acc.access_type= 'ACCOUNT' then

                    SELECT   JTF_TERR_RSC_ACCESS_S.nextval
      	            INTO l_terr_rsc_access_id
                    FROM DUAL;

                    l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
      		    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
      		    l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
      		    l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
		    l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
		    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
		    l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
		    l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'ACCOUNT';
		    l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
		    l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= 1;

		 /* OPPORTUNITY ACCESS TYPE */
                 ELSIF rsc_acc.access_type= 'OPPORTUNITY' then

                    SELECT   JTF_TERR_RSC_ACCESS_S.nextval
      	            into l_terr_rsc_access_id
                    FROM DUAL;

      		    l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
      		    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
      		    l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
      		    l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
		    l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
		    l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
		    l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
		    l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
		    l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
		    l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= 1;

		 /* LEAD ACCESS TYPE */
                 elsif rsc_acc.access_type= 'LEAD' then

                       SELECT   JTF_TERR_RSC_ACCESS_S.nextval
      	               into l_terr_rsc_access_id
                       FROM DUAL;

         	       l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
      		       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
      		       l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
      		       l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
		       l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
		       l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
		       l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
		       l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
		       l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
   		       l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:=1;

                 end if;
               end loop;   /* End of rsc_acc */

               l_init_msg_list := FND_API.G_TRUE;

   	   		    -- 07/08/03: JDOCHERT: bug#3023653
                jtf_territory_resource_pvt.create_terrresource (
                   p_api_version_number      => l_Api_Version_Number,
                   p_init_msg_list           => l_Init_Msg_List,
                   p_commit                  => l_Commit,
                   p_validation_level        => fnd_api.g_valid_level_NONE,
                   x_return_status           => x_Return_Status,
                   x_msg_count               => x_Msg_Count,
                   x_msg_data                => x_msg_data,
                   p_terrrsc_tbl             => l_TerrRsc_tbl,
                   p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                   x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                   x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                );

               if x_Return_Status='S' then
                     write_log( 2,'     RESOURCE CREATED FOR NAMED ACCOUNT CATCH ALL TERRITORY ' ||
   				           x_terr_id);
               else
                     write_log( 2,'     FAILED IN RESOURCE CREATION FOR NAMED ACCOUNT CATCH ALL TERRITORY' ||
		   			           x_terr_id);
                   x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
               end if;

             /* else of -if the catch all territory creation failed */
             else
                  x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
                  write_log(2,x_msg_data);
                  WRITE_LOG(2,'ERROR: NA CATCH-ALL TERRITORY CREATION FAILED ' ||
			                  'FOR TERRITORY_GROUP_ID# ' ||TERR_GROUP.TERR_GROUP_ID);
	      end if;

	  END IF; /* ( terr_group.matching_rule_code IN ('1', '2') AND
		               terr_group.generate_catchall_flag = 'Y' ) THEN */

	  /* END: Successful Territory creation? */
          /**************************************************************/
          /* (4) END: CREATE NA CATCH-ALL TERRITORY FOR TERRITORY GROUP */
          /**************************************************************/


         /***************************************************************/
         /* (5) START: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING DUNS# QUALIFIER                                   */
         /***************************************************************/
	 IF ( terr_group.matching_rule_code IN ('2', '3') ) THEN

           FOR naterr in get_party_duns(terr_group.terr_group_id) LOOP

                --write_log(2,'na '||naterr.named_account_id);

   	        l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;

	        l_terr_qual_tbl := l_terr_qual_empty_tbl;
                l_terr_values_tbl := l_terr_values_empty_tbl;

		l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
                l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

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


                  l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
                      l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                      l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
                      l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
                      l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

                      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
                      l_terr_all_rec.NAME:= naterr.name || ' (DUNS#)';
                      l_terr_all_rec.start_date_active := terr_group.active_from_date ;
                      l_terr_all_rec.end_date_active   := terr_group.active_to_date;
                      l_terr_all_rec.PARENT_TERRITORY_ID:=  l_nacat;
                      l_terr_all_rec.RANK := terr_group.RANK + 10;
                      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
                      l_terr_all_rec.TEMPLATE_FLAG := 'N';
                      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
                      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
                      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
                      l_terr_all_rec.DESCRIPTION:= naterr.name || ' (DUNS#)';
                      l_terr_all_rec.UPDATE_FLAG :='N';
                      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

                      l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
                      l_terr_all_rec.NUM_WINNERS :=null ;


                          /* Oracle Sales and Telesales Usage */
                      SELECT   JTF_TERR_USGS_S.nextval
                into l_terr_usg_id
                  FROM DUAL;

                  l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
                  l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
                  l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                  l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
                      l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
                      l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
                      l_terr_usgs_tbl(1).TERR_ID:= null;
                      l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
                      l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;

                 i:=0;

		  /* BEGIN: For each Access Type defined for the Territory Group */

              for acctype in get_NON_OVLY_na_trans(naterr.terr_group_account_id) LOOP

                 i:=i+1;

				 /* ACCOUNT TRANSACTION TYPE */
                 if acctype.access_type='ACCOUNT' then

                    SELECT JTF_TERR_QTYPE_USGS_S.nextval
        	          into l_terr_qtype_usg_id
                    FROM DUAL;
           		    l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		    l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
 		            l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1001;
 		            l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

				 /* LEAD TRANSACTION TYPE */
                 elsif acctype.access_type='LEAD' then

                    SELECT JTF_TERR_QTYPE_USGS_S.nextval
        	          into l_terr_qtype_usg_id
                    FROM DUAL;
           		    l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		    l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
 		            l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1002;
 		            l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

				 /* OPPORTUNITY TRANSACTION TYPE */
                 elsif acctype.access_type='OPPORTUNITY' then

                    SELECT JTF_TERR_QTYPE_USGS_S.nextval
        	          into l_terr_qtype_usg_id
                    FROM DUAL;
           		    l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		    l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
 		            l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
 		            l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

                 end if;

              end loop;
			  /* END: For each Access Type defined for the Territory Group */


			  /*
			  ** get Named Account Customer Keyname and Postal Code Mapping
			  ** rules, to use as territory definition qualifier values
			  */
              j:=0;
		      K:=0;
              l_prev_qual_usg_id:=1;
              FOR qval IN match_rule3( naterr.named_account_id ) LOOP

			     /* new qualifier, i.e., if there is a qualifier in
				 ** Addition to DUNS# */
		         IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                    j:=j+1;

        	        SELECT JTF_TERR_QUAL_S.nextval
        	          into l_terr_qual_id
        	        FROM DUAL;

                    l_terr_qual_tbl(j).TERR_QUAL_ID :=l_terr_qual_id;
        	        l_terr_qual_tbl(j).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		            l_terr_qual_tbl(j).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		            l_terr_qual_tbl(j).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qual_tbl(j).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qual_tbl(j).TERR_ID:=null;
 		            l_terr_qual_tbl(j).QUAL_USG_ID :=qval.qual_usg_id;
 		            l_terr_qual_tbl(j).QUALIFIER_MODE:=NULL;
 		            l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='N';
 		            l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 		            l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 		            l_terr_qual_tbl(j).ORG_ID:=terr_group.ORG_ID;
		            l_prev_qual_usg_id:= qval.qual_usg_id;

	  	         END IF;

   	     	     k:=k+1;

       		     l_terr_values_tbl(k).TERR_VALUE_ID:=null;
 		         l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
 		         l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
 		         l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
 		         l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
 		         l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
 		         l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
 		         l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		         l_terr_values_tbl(k).COMPARISON_OPERATOR := qval.COMPARISON_OPERATOR;
 		         l_terr_values_tbl(k).LOW_VALUE_CHAR:= qval.value1_char;
 		         l_terr_values_tbl(k).HIGH_VALUE_CHAR:= NULL;
 		         l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 		         l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
 		         l_terr_values_tbl(k).VALUE_SET :=NULL;
 		         l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
 		         l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		         l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 		         l_terr_values_tbl(k).CURRENCY_CODE :=null;
 		         l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
 		         l_terr_values_tbl(k).ID_USED_FLAG :='N';
 		         l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

         		 l_terr_values_tbl(k).qualifier_tbl_index := j;

  		      end loop; /* qval IN pqual */


		      l_init_msg_list :=FND_API.G_TRUE;

 		      -- 07/08/03: JDOCHERT: bug#3023653
			  --mo_global.set_org_context(terr_group.ORG_ID,null);
			  --

              jtf_territory_pvt.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => fnd_api.g_valid_level_NONE,
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
	          if x_return_status = 'S' then

                 -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG
                 -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                 UPDATE JTF_TERR_ALL
                 set TERR_GROUP_FLAG = 'Y'
                   , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                   , CATCH_ALL_FLAG = 'N'
                   , NAMED_ACCOUNT_FLAG = 'Y'
                   , TERR_GROUP_ACCOUNT_ID = naterr.terr_group_account_id
                 where terr_id = x_terr_id;

                 l_init_msg_list :=FND_API.G_TRUE;
                 i := 0;
                 a := 0;

                 FOR tran_type in role_interest_nonpi(terr_group.Terr_gROUP_ID)
                 LOOP
                    --dbms_output.put_line('tran_type.role_code   '||tran_type.role_code);

                    /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
             	    FOR rsc in resource_grp(naterr.terr_group_account_id,tran_type.role_code)
                    loop
                       i:=i+1;

                       SELECT JTF_TERR_RSC_S.nextval
        	             into l_terr_rsc_id
        	           FROM DUAL;

                       l_TerrRsc_Tbl(i).terr_id := x_terr_id;
                       l_TerrRsc_Tbl(i).TERR_RSC_ID :=l_terr_rsc_id;
                       l_TerrRsc_Tbl(i).LAST_UPDATE_DATE:=terr_group.LAST_UPDATE_DATE;
                       l_TerrRsc_Tbl(i).LAST_UPDATED_BY:=terr_group.LAST_UPDATED_BY;
                       l_TerrRsc_Tbl(i).CREATION_DATE:=terr_group.CREATION_DATE;
 	                   l_TerrRsc_Tbl(i).CREATED_BY:=terr_group.CREATED_BY;
 	                   l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
 	                   --l_TerrRsc_Tbl(i).TERR_ID:=terr_group.TERRITORY_ID;
 	                   l_TerrRsc_Tbl(i).RESOURCE_ID:=rsc.resource_id;
 	                   l_TerrRsc_Tbl(i).RESOURCE_TYPE:=rsc.rsc_resource_type;
 	                   l_TerrRsc_Tbl(i).ROLE:=tran_type.role_code;
                       --l_TerrRsc_Tbl(i).ROLE:=l_role;
 	                   l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG:='N';
 	                   l_TerrRsc_Tbl(i).START_DATE_ACTIVE:=terr_group.active_from_date ;
 	                   l_TerrRsc_Tbl(i).END_DATE_ACTIVE:=terr_group.active_to_date ;
 	                   l_TerrRsc_Tbl(i).ORG_ID:=terr_group.ORG_ID;
 	                   l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG:='Y';
 	                   l_TerrRsc_Tbl(i).GROUP_ID:=rsc.rsc_group_id;
                       --dbms_output.put_line('rsc.resource_id   '||rsc.resource_id);


                       FOR rsc_acc in NON_OVLY_role_access(terr_group.terr_group_id,tran_type.role_code) LOOP
                          --dbms_output.put_line('rsc_acc.access_type   '||rsc_acc.access_type);
                          a := a+1;

		                  /* ACCOUNT ACCESS TYPE */
                          IF (rsc_acc.access_type= 'ACCOUNT') THEN

                             SELECT JTF_TERR_RSC_ACCESS_S.nextval
        	                   into l_terr_rsc_access_id
                             FROM DUAL;
            		         l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		             l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
 		                     l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
 		                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
 		                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'ACCOUNT';
 		                     l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
 		                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

						  /* OPPORTUNITY ACCESS TYPE */
						  elsif rsc_acc.access_type= 'OPPORTUNITY' then

                             SELECT JTF_TERR_RSC_ACCESS_S.nextval
        	                 into l_terr_rsc_access_id
                             FROM DUAL;
        		             l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		             l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
 		                     l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
 		                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
 		                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
 		                     l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
 		                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;


						  /* LEAD ACCESS TYPE */
                          elsif rsc_acc.access_type= 'LEAD' then

                             SELECT   JTF_TERR_RSC_ACCESS_S.nextval
        	                 into l_terr_rsc_access_id
                             FROM DUAL;
        		             l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		             l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
 		                     l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
 		                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
 		                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
 		                     l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
 		                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;
                          end if;
                       end loop; /* FOR rsc_acc in NON_OVLY_role_access */

                    end loop; /* FOR rsc in resource_grp */

                 end loop;/* FOR tran_type in role_interest_nonpi */

                 l_init_msg_list :=FND_API.G_TRUE;

			     -- 07/08/03: JDOCHERT: bug#3023653
                 jtf_territory_resource_pvt.create_terrresource (
                    p_api_version_number      => l_Api_Version_Number,
                    p_init_msg_list           => l_Init_Msg_List,
                    p_commit                  => l_Commit,
                    p_validation_level        => fnd_api.g_valid_level_NONE,
                    x_return_status           => x_Return_Status,
                    x_msg_count               => x_Msg_Count,
                    x_msg_data                => x_msg_data,
                    p_terrrsc_tbl             => l_TerrRsc_tbl,
                    p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                    x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                    x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                 );

                 if x_Return_Status='S' then
      	         	write_log(2,'     Resource created for NA territory # ' ||x_terr_id);
                 else
                    x_msg_data := substr(fnd_msg_pub.get(1, fnd_api.g_false),1,254);
                    write_log(2,x_msg_data);
                    write_log(2, '     Failed in resource creation for NA territory # ' ||
					             x_terr_id);
                 end if;

              else
                 x_msg_data :=  substr(fnd_msg_pub.get(1, fnd_api.g_false),1,254);
                 write_log(2,substr(x_msg_data,1,254));
               WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' ||
			               'FOR NAMED_ACCOUNT_ID# ' || naterr.named_account_id );
   	          end if; /* END: Successful Territory creation? */

           end loop; /* naterr in get_party_duns */
		 END IF; /* ( terr_group.matching_rule_code IN ('3') THEN */
         /*************************************************************/
         /* (5) END: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING DUNS# QUALIFIER                                 */
         /*************************************************************/

         /* dbms_output.put_line('terr_group.terr_group_name='||
		                          terr_group.terr_group_name);
            dbms_output.put_line('terr_group.matching_rule_code='||
			                     terr_group.matching_rule_code);*/

         /***************************************************************/
         /* (6) START: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
		 /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
         /***************************************************************/
	     IF ( terr_group.matching_rule_code IN ('1', '2') ) THEN
           FOR naterr in get_party_name(terr_group.terr_group_id) LOOP

                l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
   	            l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;

	            l_terr_qual_tbl := l_terr_qual_empty_tbl;
                l_terr_values_tbl := l_terr_values_empty_tbl;


			  l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

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

 	      	  l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
 	  	      l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		      l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
 		      l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

 		      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
 		      l_terr_all_rec.NAME:= naterr.name;
 		      l_terr_all_rec.start_date_active := terr_group.active_from_date ;
 		      l_terr_all_rec.end_date_active   := terr_group.active_to_date;
 		      l_terr_all_rec.PARENT_TERRITORY_ID:=  l_nacat;
 		      l_terr_all_rec.RANK := terr_group.RANK + 20;
 		      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		      l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 		      l_terr_all_rec.DESCRIPTION:= naterr.name;
 		      l_terr_all_rec.UPDATE_FLAG :='N';
 		      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

 		      l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
 		      l_terr_all_rec.NUM_WINNERS :=null ;


			  /* Oracle Sales and Telesales Usage */
 		      SELECT   JTF_TERR_USGS_S.nextval
            	into l_terr_usg_id
        	  FROM DUAL;

         	  l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
        	  l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        	  l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        	  l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
 		      l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
 		      l_terr_usgs_tbl(1).TERR_ID:= null;
 		      l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
 		      l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;
              i:=0;

			  /* BEGIN: For each Access Type defined for the Territory Group */
              for acctype in get_NON_OVLY_na_trans(naterr.terr_group_account_id) LOOP

                 i:=i+1;

				 /* ACCOUNT TRANSACTION TYPE */
                 if acctype.access_type='ACCOUNT' then

                    SELECT JTF_TERR_QTYPE_USGS_S.nextval
        	          into l_terr_qtype_usg_id
                    FROM DUAL;
           		    l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		    l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
 		            l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1001;
 		            l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

				 /* LEAD TRANSACTION TYPE */
                 elsif acctype.access_type='LEAD' then

                    SELECT JTF_TERR_QTYPE_USGS_S.nextval
        	          into l_terr_qtype_usg_id
                    FROM DUAL;
           		    l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		    l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
 		            l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1002;
 		            l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

				 /* OPPORTUNITY TRANSACTION TYPE */
                 elsif acctype.access_type='OPPORTUNITY' then

                    SELECT JTF_TERR_QTYPE_USGS_S.nextval
        	          into l_terr_qtype_usg_id
                    FROM DUAL;
           		    l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
        		    l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		    l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
 		            l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
 		            l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

                 end if;

              end loop;
			  /* END: For each Access Type defined for the Territory Group */


			  /*
			  ** get Named Account Customer Keyname and Postal Code Mapping
			  ** rules, to use as territory definition qualifier values
			  */
              j:=0;
		      K:=0;
              l_prev_qual_usg_id:=1;
              FOR qval IN match_rule1( naterr.named_account_id ) LOOP

			     /* new qualifier, i.e., Customer Name Range or Postal Code:
				 ** driven by ORDER BY on p_qual */
		         IF l_prev_qual_usg_id <> qval.qual_usg_id THEN

                    j:=j+1;

        	        SELECT JTF_TERR_QUAL_S.nextval
        	          into l_terr_qual_id
        	        FROM DUAL;

                    l_terr_qual_tbl(j).TERR_QUAL_ID :=l_terr_qual_id;
        	        l_terr_qual_tbl(j).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		            l_terr_qual_tbl(j).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		            l_terr_qual_tbl(j).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qual_tbl(j).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qual_tbl(j).TERR_ID:=null;
 		            l_terr_qual_tbl(j).QUAL_USG_ID :=qval.qual_usg_id;
 		            l_terr_qual_tbl(j).QUALIFIER_MODE:=NULL;
 		            l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='N';
 		            l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 		            l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 		            l_terr_qual_tbl(j).ORG_ID:=terr_group.ORG_ID;
		            l_prev_qual_usg_id:= qval.qual_usg_id;

	  	         END IF;

   	     	     k:=k+1;

       		     l_terr_values_tbl(k).TERR_VALUE_ID:=null;
 		         l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
 		         l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
 		         l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
 		         l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
 		         l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
 		         l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
 		         l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		         l_terr_values_tbl(k).COMPARISON_OPERATOR := qval.COMPARISON_OPERATOR;
 		         l_terr_values_tbl(k).LOW_VALUE_CHAR:= qval.value1_char;
 		         l_terr_values_tbl(k).HIGH_VALUE_CHAR:=qval.value2_char;
 		         l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 		         l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
 		         l_terr_values_tbl(k).VALUE_SET :=NULL;
 		         l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
 		         l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		         l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 		         l_terr_values_tbl(k).CURRENCY_CODE :=null;
 		         l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
 		         l_terr_values_tbl(k).ID_USED_FLAG :='N';
 		         l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

         		 l_terr_values_tbl(k).qualifier_tbl_index := j;

  		      end loop; /* qval IN pqual */


		      l_init_msg_list :=FND_API.G_TRUE;

 		      -- 07/08/03: JDOCHERT: bug#3023653
			  --mo_global.set_org_context(terr_group.ORG_ID,null);
			  --

              jtf_territory_pvt.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => fnd_api.g_valid_level_NONE,
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
	          if x_return_status = 'S' then

                 -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID and CATCH_ALL_FLAG
                 -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                 UPDATE JTF_TERR_ALL
                 set TERR_GROUP_FLAG = 'Y'
                   , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                   , CATCH_ALL_FLAG = 'N'
                   , NAMED_ACCOUNT_FLAG = 'Y'
                   , TERR_GROUP_ACCOUNT_ID = naterr.terr_group_account_id
                 where terr_id = x_terr_id;

                 --write_log(2,terr_group.terr_group_id);
                 --write_log(2,tran_type.role_code);
                 l_init_msg_list :=FND_API.G_TRUE;
                 i := 0;
                 a := 0;

                 FOR tran_type in role_interest_nonpi(terr_group.Terr_gROUP_ID)
                 LOOP
                    --dbms_output.put_line('tran_type.role_code   '||tran_type.role_code);

                    /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
             	    FOR rsc in resource_grp(naterr.terr_group_account_id,tran_type.role_code)
                    loop
                       i:=i+1;

                       SELECT JTF_TERR_RSC_S.nextval
        	             into l_terr_rsc_id
        	           FROM DUAL;

                       l_TerrRsc_Tbl(i).terr_id := x_terr_id;
                       l_TerrRsc_Tbl(i).TERR_RSC_ID :=l_terr_rsc_id;
                       l_TerrRsc_Tbl(i).LAST_UPDATE_DATE:=terr_group.LAST_UPDATE_DATE;
                       l_TerrRsc_Tbl(i).LAST_UPDATED_BY:=terr_group.LAST_UPDATED_BY;
                       l_TerrRsc_Tbl(i).CREATION_DATE:=terr_group.CREATION_DATE;
 	                   l_TerrRsc_Tbl(i).CREATED_BY:=terr_group.CREATED_BY;
 	                   l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
 	                   --l_TerrRsc_Tbl(i).TERR_ID:=terr_group.TERRITORY_ID;
 	                   l_TerrRsc_Tbl(i).RESOURCE_ID:=rsc.resource_id;
 	                   l_TerrRsc_Tbl(i).RESOURCE_TYPE:=rsc.rsc_resource_type;
 	                   l_TerrRsc_Tbl(i).ROLE:=tran_type.role_code;
                       --l_TerrRsc_Tbl(i).ROLE:=l_role;
 	                   l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG:='N';
 	                   l_TerrRsc_Tbl(i).START_DATE_ACTIVE:=terr_group.active_from_date ;
 	                   l_TerrRsc_Tbl(i).END_DATE_ACTIVE:=terr_group.active_to_date ;
 	                   l_TerrRsc_Tbl(i).ORG_ID:=terr_group.ORG_ID;
 	                   l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG:='Y';
 	                   l_TerrRsc_Tbl(i).GROUP_ID:=rsc.rsc_group_id;
                       --dbms_output.put_line('rsc.resource_id   '||rsc.resource_id);


                       FOR rsc_acc in NON_OVLY_role_access(terr_group.terr_group_id,tran_type.role_code) LOOP
                          --dbms_output.put_line('rsc_acc.access_type   '||rsc_acc.access_type);
                          a := a+1;

		                  /* ACCOUNT ACCESS TYPE */
                          IF (rsc_acc.access_type= 'ACCOUNT') THEN

                             SELECT JTF_TERR_RSC_ACCESS_S.nextval
        	                   into l_terr_rsc_access_id
                             FROM DUAL;
            		         l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		             l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
 		                     l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
 		                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
 		                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'ACCOUNT';
 		                     l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
 		                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

						  /* OPPORTUNITY ACCESS TYPE */
						  elsif rsc_acc.access_type= 'OPPORTUNITY' then

                             SELECT JTF_TERR_RSC_ACCESS_S.nextval
        	                 into l_terr_rsc_access_id
                             FROM DUAL;
        		             l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		             l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
 		                     l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
 		                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
 		                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
 		                     l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
 		                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;


						  /* LEAD ACCESS TYPE */
                          elsif rsc_acc.access_type= 'LEAD' then

                             SELECT   JTF_TERR_RSC_ACCESS_S.nextval
        	                 into l_terr_rsc_access_id
                             FROM DUAL;
        		             l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
        		             l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
        		             l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
 		                     l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
 		                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
 		                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
 		                     l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
 		                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;
                          end if;
                       end loop; /* FOR rsc_acc in NON_OVLY_role_access */

                    end loop; /* FOR rsc in resource_grp */

                 end loop;/* FOR tran_type in role_interest_nonpi */

                 l_init_msg_list :=FND_API.G_TRUE;

			     -- 07/08/03: JDOCHERT: bug#3023653
                 jtf_territory_resource_pvt.create_terrresource (
                    p_api_version_number      => l_Api_Version_Number,
                    p_init_msg_list           => l_Init_Msg_List,
                    p_commit                  => l_Commit,
                    p_validation_level        => fnd_api.g_valid_level_NONE,
                    x_return_status           => x_Return_Status,
                    x_msg_count               => x_Msg_Count,
                    x_msg_data                => x_msg_data,
                    p_terrrsc_tbl             => l_TerrRsc_tbl,
                    p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                    x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                    x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                 );

                 if x_Return_Status='S' then
      	         	write_log(2,'     Resource created for NA territory # ' ||x_terr_id);
                 else
                    x_msg_data := substr(fnd_msg_pub.get(1, fnd_api.g_false),1,254);
                    write_log(2,x_msg_data);
                    write_log(2, '     Failed in resource creation for NA territory # ' ||
					             x_terr_id);
                 end if;

              else
                 x_msg_data :=  substr(fnd_msg_pub.get(1, fnd_api.g_false),1,254);
                 write_log(2,substr(x_msg_data,1,254));
               WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' ||
			               'FOR NAMED_ACCOUNT_ID# ' || naterr.named_account_id );
   	          end if; /* END: Successful Territory creation? */

           end loop; /* naterr in get_party_name */
		 END IF; /* terr_group.matching_rule_code IN ('1', '2') THEN */
         /*************************************************************/
         /* (6) END: CREATE NA TERRITORIES FOR NAs IN TERRITORY GROUP */
         /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS  */
         /*************************************************************/

           /********************************************************/
           /* delete the role and access */
           /********************************************************/
		   if l_ovnon_flag = 'Y' then

              for i in l_overnon_role_tbl.first.. l_overnon_role_tbl.last
              loop
                 delete from jtf_tty_terr_grp_roles
                 where TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
                 --dbms_output.put_line('deleted');
                 delete from jtf_tty_role_access
                 where TERR_GROUP_ROLE_ID=l_overnon_role_tbl(i).grp_role_id;
              end loop;
           end if;


--        end if;
		/* END: if Territory Group exists with Named Accounts
        ** then auto-create territory definitions */



	/*********************************************************************/
	/*********************************************************************/
        /************** OVERLAY TERRITORY CREATION ***************************/
	/*********************************************************************/
	/*********************************************************************/

        /* if any role with PI and Account access and no non pi role exist */
        /* we need to create a new branch with Named Account */
        /* OVERLAY BRANCH */

	BEGIN

           SELECT COUNT( DISTINCT b.role_code )
	       into l_pi_count
           from jtf_rs_roles_vl r
              , jtf_tty_role_prod_int a
              , jtf_tty_terr_grp_roles b
           where r.role_code = b.role_code
             and a.terr_group_role_id = b.terr_group_role_id
             and b.terr_group_id      = TERR_GROUP.TERR_GROUP_ID
        	 AND EXISTS (
			       /* Named Account exists with Salesperson with this role */
	               SELECT NULL
			       FROM jtf_tty_named_acct_rsc nar, jtf_tty_terr_grp_accts tga
			       WHERE tga.terr_group_account_id = nar.terr_group_account_id
			         AND tga.terr_group_id = b.terr_group_id
			         AND nar.rsc_role_code = b.role_code )
			 AND ROWNUM < 2;

	    EXCEPTION
		   WHEN OTHERS THEN
		      NUll;
	END;


		/* are there overlay roles, i.e., are there roles with Product
		** Interests defined for this Territory Group */
        if l_pi_count > 0 then

          /***************************************************************/
          /* (7) START: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF */
		  /*    TERRITORY GROUP                                          */
          /***************************************************************/
           FOR topt in topterr(terr_group.PARENT_TERR_ID) LOOP

              l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	          l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
	          l_terr_qual_tbl:=l_terr_qual_empty_tbl;
              l_terr_values_tbl:=l_terr_values_empty_tbl;
              l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

              l_terr_all_rec.TERR_ID := null;
 	     	  l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
 		      l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		      l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
 		      l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

 		      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
              l_terr_all_rec.NAME:= terr_group.terr_group_name || ' (OVERLAY)';
 		      l_terr_all_rec.start_date_active := terr_group.active_from_date ;
 		      l_terr_all_rec.end_date_active   := terr_group.active_to_date;
 		      l_terr_all_rec.PARENT_TERRITORY_ID:=  topt.PARENT_TERRITORY_ID;
 		      l_terr_all_rec.RANK := topt.RANK;
 		      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		      l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 		      l_terr_all_rec.DESCRIPTION:= topt.DESCRIPTION;
 		      l_terr_all_rec.UPDATE_FLAG :='N';
 		      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

 		      l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
 		      l_terr_all_rec.NUM_WINNERS :=l_pi_count ;

			  /* ORACLE SALES AND TELESALES USAGE */
    		  SELECT JTF_TERR_USGS_S.nextval
                into l_terr_usg_id
              FROM DUAL;

              l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
              l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
              l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
              l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
              l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
              l_terr_usgs_tbl(1).TERR_ID:= null;
              l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
              l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;


			  /* LEAD TRANSACTION TYPE */
              SELECT JTF_TERR_QTYPE_USGS_S.nextval
                into l_terr_qtype_usg_id
              FROM DUAL;

      		  l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		      l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		      l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		      l_terr_qualtypeusgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(1).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID:=-1002;
              l_terr_qualtypeusgs_tbl(1).ORG_ID:=terr_group.ORG_ID;

			  /* OPPORTUNITY TRANSACTION TYPE */
			  SELECT JTF_TERR_QTYPE_USGS_S.nextval
       	        into l_terr_qtype_usg_id
              FROM DUAL;

        	  l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		      l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		      l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		      l_terr_qualtypeusgs_tbl(2).CREATION_DATE:= terr_group.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(2).CREATED_BY := terr_group.CREATED_BY;
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(2).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID:=-1003;
 		      l_terr_qualtypeusgs_tbl(2).ORG_ID:=terr_group.ORG_ID;


			  /*
			  ** get Top-Level Parent's Qualifier and values and
			  ** aad them to Overlay branch top-level territory
			  */
              j:=0;
		      k:=0;
              l_prev_qual_usg_id:=1;
              FOR csr_qual IN csr_get_qual ( topt.terr_id ) LOOP

                 j:=j+1;

        	     SELECT JTF_TERR_QUAL_S.nextval
        	     INTO l_terr_qual_id
        	     FROM DUAL;

                 l_terr_qual_tbl(j).TERR_QUAL_ID := l_terr_qual_id;
        	     l_terr_qual_tbl(j).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		         l_terr_qual_tbl(j).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		         l_terr_qual_tbl(j).CREATION_DATE:= terr_group.CREATION_DATE;
 		         l_terr_qual_tbl(j).CREATED_BY := terr_group.CREATED_BY;
 		         l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		         l_terr_qual_tbl(j).TERR_ID:= null;

				 /* Top_level Parent's Qualifier */
 		         l_terr_qual_tbl(j).QUAL_USG_ID := csr_qual.qual_usg_id;

 		         l_terr_qual_tbl(j).QUALIFIER_MODE:= NULL;
 		         l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='Y';
 		         l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 		         l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 		         l_terr_qual_tbl(j).ORG_ID:=terr_group.ORG_ID;


				 FOR csr_qual_val IN csr_get_qual_val (csr_qual.terr_qual_id) LOOP

				    k:=k+1;

				    l_terr_values_tbl(k).TERR_VALUE_ID := NULL;
 		            l_terr_values_tbl(k).LAST_UPDATED_BY := G_USER_ID;
 		            l_terr_values_tbl(k).LAST_UPDATE_DATE:= G_SYSDATE;
 		            l_terr_values_tbl(k).CREATED_BY  := G_USER_ID;
 		            l_terr_values_tbl(k).CREATION_DATE:= G_SYSDATE;
 		            l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= G_LOGIN_ID;

 		            l_terr_values_tbl(k).TERR_QUAL_ID := l_terr_qual_id ;

 		            l_terr_values_tbl(k).INCLUDE_FLAG         := csr_qual_val.INCLUDE_FLAG;
 		            l_terr_values_tbl(k).COMPARISON_OPERATOR  := csr_qual_val.COMPARISON_OPERATOR;
 		            l_terr_values_tbl(k).LOW_VALUE_CHAR       := csr_qual_val.LOW_VALUE_CHAR;
 		            l_terr_values_tbl(k).HIGH_VALUE_CHAR      := csr_qual_val.HIGH_VALUE_CHAR;
 		            l_terr_values_tbl(k).LOW_VALUE_NUMBER     := csr_qual_val.LOW_VALUE_NUMBER;
 		            l_terr_values_tbl(k).HIGH_VALUE_NUMBER    := csr_qual_val.HIGH_VALUE_NUMBER;
 		            l_terr_values_tbl(k).VALUE_SET            := csr_qual_val.VALUE_SET;
 		            l_terr_values_tbl(k).INTEREST_TYPE_ID     := csr_qual_val.INTEREST_TYPE_ID;
 		            l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := csr_qual_val.PRIMARY_INTEREST_CODE_ID;
 		            l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := csr_qual_val.SECONDARY_INTEREST_CODE_ID;
 		            l_terr_values_tbl(k).CURRENCY_CODE        := csr_qual_val.CURRENCY_CODE;
 		            l_terr_values_tbl(k).ID_USED_FLAG         := csr_qual_val.ID_USED_FLAG;
 		            l_terr_values_tbl(k).LOW_VALUE_CHAR_ID    := csr_qual_val.LOW_VALUE_CHAR_ID;

 		            l_terr_values_tbl(k).ORG_ID               := terr_group.org_id;

					/* What Qualifier Values relate to Qualifier */
					l_terr_values_tbl(k).qualifier_tbl_index := j;


				 END LOOP;	/* csr_qual_val IN csr_get_qual_val */
  		      end loop; /* csr_qual IN csr_get_qual */


              l_init_msg_list :=FND_API.G_TRUE;

 	     	  -- 07/08/03: JDOCHERT: bug#3023653
			  --mo_global.set_org_context(terr_group.ORG_ID,null);
			  --
              jtf_territory_pvt.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => fnd_api.g_valid_level_NONE,
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


              if x_return_status = 'S' then

                 -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                 UPDATE JTF_TERR_ALL
                    set TERR_GROUP_FLAG = 'Y'
                      , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                  where terr_id = x_terr_id;

              end if;

              l_overlay_top :=x_terr_id;

           end loop;/* top level territory */
          /***************************************************************/
          /* (7) END: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF   */
		  /*    TERRITORY GROUP                                          */
          /***************************************************************/


         /***************************************************************/
          /* (8) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
         /*     USING DUNS# QUALIFIER                                   */
         /***************************************************************/
	     IF ( terr_group.matching_rule_code IN ('2', '3') ) THEN

           FOR overlayterr in get_OVLY_party_duns(terr_group.terr_group_id) LOOP

              l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	          l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
     	      l_terr_qual_tbl:=l_terr_qual_empty_tbl;
              l_terr_values_tbl:=l_terr_values_empty_tbl;
              l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

              l_terr_all_rec.TERR_ID := null;
 		      l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
 		      l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		      l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
 		      l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

 		      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
 		      l_terr_all_rec.NAME:= overlayterr.name || ' (OVERLAY DUNS#)';
 		      l_terr_all_rec.start_date_active := terr_group.active_from_date ;
 		      l_terr_all_rec.end_date_active   := terr_group.active_to_date;
 		      l_terr_all_rec.PARENT_TERRITORY_ID:=  l_overlay_top;
 		      l_terr_all_rec.RANK := terr_group.RANK + 10;
 		      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		      l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 		      l_terr_all_rec.DESCRIPTION:= overlayterr.name || ' (OVERLAY_DUNS#)';
 		      l_terr_all_rec.UPDATE_FLAG :='N';
 		      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

     		  l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
 		      l_terr_all_rec.NUM_WINNERS :=null ;


 		      SELECT JTF_TERR_USGS_S.nextval
                into l_terr_usg_id
              FROM DUAL;

              l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
              l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
              l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
              l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
              l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
              l_terr_usgs_tbl(1).TERR_ID:= null;
              l_terr_usgs_tbl(1).SOURCE_ID := -1001;
              l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;

              SELECT   JTF_TERR_QTYPE_USGS_S.nextval
                into l_terr_qtype_usg_id
              FROM DUAL;

      		  l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		      l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		      l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		      l_terr_qualtypeusgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(1).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID:=-1002;
              l_terr_qualtypeusgs_tbl(1).ORG_ID:=terr_group.ORG_ID;

              SELECT   JTF_TERR_QTYPE_USGS_S.nextval
       	        into l_terr_qtype_usg_id
              FROM DUAL;

   		      l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		      l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		      l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		      l_terr_qualtypeusgs_tbl(2).CREATION_DATE:= terr_group.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(2).CREATED_BY := terr_group.CREATED_BY;
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(2).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID:=-1003;
 		      l_terr_qualtypeusgs_tbl(2).ORG_ID:=terr_group.ORG_ID;

              SELECT JTF_TERR_QUAL_S.nextval
      	        into l_terr_qual_id
       	      FROM DUAL;

	          j:=0;
		      K:=0;
              l_prev_qual_usg_id:=1;

		      for qval in match_rule3(overlayterr.named_account_id)
              loop

      		     if l_prev_qual_usg_id <> qval.qual_usg_id then

                    j:=j+1;
        	        SELECT   JTF_TERR_QUAL_S.nextval
        	          into l_terr_qual_id
        	        FROM DUAL;

        	        l_terr_qual_tbl(j).TERR_QUAL_ID :=l_terr_qual_id;
        	        l_terr_qual_tbl(j).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		            l_terr_qual_tbl(j).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		            l_terr_qual_tbl(j).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qual_tbl(j).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qual_tbl(j).TERR_ID:=null;
 		            l_terr_qual_tbl(j).QUAL_USG_ID :=qval.qual_usg_id;
 		            l_terr_qual_tbl(j).QUALIFIER_MODE:=NULL;
 		            l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='N';
 		            l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 		            l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 		            l_terr_qual_tbl(j).ORG_ID:=terr_group.ORG_ID;
		            l_prev_qual_usg_id:= qval.qual_usg_id;
	  	        end if;

   	     	    k:=k+1;

	           	l_terr_values_tbl(k).TERR_VALUE_ID:=null;

           		l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
        		l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
 	         	l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
 	          	l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
        		l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
 	          	l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
        		l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		        l_terr_values_tbl(k).COMPARISON_OPERATOR := qval.COMPARISON_OPERATOR;
         		l_terr_values_tbl(k).LOW_VALUE_CHAR:= qval.value1_char;
 	           	l_terr_values_tbl(k).HIGH_VALUE_CHAR:= NULL;
           		l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 	          	l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
           		l_terr_values_tbl(k).VALUE_SET :=NULL;
        		l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
 	          	l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		        l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 	          	l_terr_values_tbl(k).CURRENCY_CODE :=null;
 	          	l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
         		l_terr_values_tbl(k).ID_USED_FLAG :='N';
        		l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;


         		l_terr_values_tbl(k).qualifier_tbl_index := j;

     		 end loop;

             l_init_msg_list :=FND_API.G_TRUE;

             -- 07/08/03: JDOCHERT: bug#3023653
 		     --mo_global.set_org_context(terr_group.ORG_ID,null);
			 --

             jtf_territory_pvt.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => fnd_api.g_valid_level_NONE,
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


              if x_return_status = 'S' then

                 -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                 -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                 UPDATE JTF_TERR_ALL
                    set TERR_GROUP_FLAG = 'Y'
                      , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                      , NAMED_ACCOUNT_FLAG = 'Y'
                      , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                 where terr_id = x_terr_id;

                 l_overlay:=x_terr_id;

                 for pit in role_pi(terr_group.terr_group_id, overlayterr.terr_group_account_id) loop


                    l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	                l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
	                l_terr_qual_tbl:=l_terr_qual_empty_tbl;
                    l_terr_values_tbl:=l_terr_values_empty_tbl;
                    l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
                    l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

				    l_role_counter := l_role_counter + 1;

                    l_terr_all_rec.TERR_ID := overlayterr.terr_group_account_id * -30 * l_role_counter;
 		            l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
 		            l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		            l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
 		            l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

 	  	            l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;

 		            l_terr_all_rec.NAME:= overlayterr.name || ': ' ||
					                      pit.role_name || ' (OVERLAY DUNS#)';

 		            l_terr_all_rec.start_date_active := terr_group.active_from_date ;
 		            l_terr_all_rec.end_date_active   := terr_group.active_to_date;
 		            l_terr_all_rec.PARENT_TERRITORY_ID:= l_overlay;
 		            l_terr_all_rec.RANK := terr_group.RANK+10;
 		            l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		            l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		            l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		            l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		            l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;

 		            l_terr_all_rec.DESCRIPTION:= overlayterr.name || ': ' ||
					                             pit.role_name || ' (OVERLAY DUNS#)';

 		            l_terr_all_rec.UPDATE_FLAG :='N';
 		            l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

 		            l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
 		            l_terr_all_rec.NUM_WINNERS :=null ;

 		            SELECT   JTF_TERR_USGS_S.nextval
                      into l_terr_usg_id
                    FROM DUAL;

    	            l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
                    l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
                    l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
                    l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
                    l_terr_usgs_tbl(1).TERR_ID:= null;
                    l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
                    l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;

                    i := 0;
                    K:= 0;
                    for acc_type in role_access(terr_group.terr_group_id,pit.role_code) loop
                    --i:=i+1;
                    --dbms_output.put_line('acc type  '||acc_type.access_type);
                    if acc_type.access_type= 'OPPORTUNITY' then
                       i:=i+1;
                       SELECT   JTF_TERR_QTYPE_USGS_S.nextval
       	                 into l_terr_qtype_usg_id
                       FROM DUAL;

      		           l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		               l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
                       l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
                       l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
                       l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
                       l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
 		               l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       SELECT JTF_TERR_QUAL_S.nextval
      	                 into l_terr_qual_id
       	               FROM DUAL;
                       /* opp expected purchase */

           	           l_terr_qual_tbl(i).TERR_QUAL_ID :=l_terr_qual_id;
            	       l_terr_qual_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 	          	       l_terr_qual_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 	          	       l_terr_qual_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		               l_terr_qual_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		               l_terr_qual_tbl(i).TERR_ID:=null;
 		               l_terr_qual_tbl(i).QUAL_USG_ID :=-1023;
 		               l_terr_qual_tbl(i).QUALIFIER_MODE:=NULL;
 		               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG:='N';
 		               l_terr_qual_tbl(i).USE_TO_NAME_FLAG:=NULL;
 		               l_terr_qual_tbl(i).GENERATE_FLAG:=NULL;
 		               l_terr_qual_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       for qval in role_pi_interest(terr_group.terr_group_id,pit.role_code) loop
		                  k:=k+1;

  		                  l_terr_values_tbl(k).TERR_VALUE_ID:=null;

 		                  l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
 		                  l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
 		                  l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
 		                  l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
 		                  l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
 		                  l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
 		                  l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		                  l_terr_values_tbl(k).COMPARISON_OPERATOR :='=';
 		                  l_terr_values_tbl(k).LOW_VALUE_CHAR:= null;
 		                  l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
 		                  l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 		                  l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
 		                  l_terr_values_tbl(k).VALUE_SET :=NULL;
 		                  l_terr_values_tbl(k).INTEREST_TYPE_ID :=qval.interest_type_id;
 		                  l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		                  l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 		                  l_terr_values_tbl(k).CURRENCY_CODE :=null;
 		                  l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
 		                  l_terr_values_tbl(k).ID_USED_FLAG :='N';
 		                  l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

 		                  l_terr_values_tbl(k).qualifier_tbl_index := i;

  		               end loop;

                    elsif acc_type.access_type= 'LEAD' then

                       i:=i+1;
                       SELECT   JTF_TERR_QTYPE_USGS_S.nextval
                         into l_terr_qtype_usg_id
                       FROM DUAL;

        		       l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		               l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
                       l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
                       l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
                       l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
                       l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1002;
                       l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       SELECT   JTF_TERR_QUAL_S.nextval
      	                 into l_terr_qual_id
       	               FROM DUAL;

                       /* lead expected purchase */
       	               l_terr_qual_tbl(i).TERR_QUAL_ID :=l_terr_qual_id;
       	               l_terr_qual_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		               l_terr_qual_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		               l_terr_qual_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		               l_terr_qual_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		               l_terr_qual_tbl(i).TERR_ID:=null;
 		               l_terr_qual_tbl(i).QUAL_USG_ID :=-1018;
 		               l_terr_qual_tbl(i).QUALIFIER_MODE:=NULL;
 		               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG:='N';
 		               l_terr_qual_tbl(i).USE_TO_NAME_FLAG:=NULL;
 		               l_terr_qual_tbl(i).GENERATE_FLAG:=NULL;
 		               l_terr_qual_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       for qval in role_pi_interest(terr_group.terr_group_id,pit.role_code) loop

                          k:=k+1;

            		      l_terr_values_tbl(k).TERR_VALUE_ID:=null;

                  	      l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
              		      l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
             		      l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
             		      l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
             		      l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
             		      l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
             		      l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
             		      l_terr_values_tbl(k).COMPARISON_OPERATOR :='=';
             		      l_terr_values_tbl(k).LOW_VALUE_CHAR:= null;
             		      l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
             		      l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
             		      l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
             		      l_terr_values_tbl(k).VALUE_SET :=NULL;
             		      l_terr_values_tbl(k).INTEREST_TYPE_ID := qval.interest_type_id;
             		      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
             		      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
             		      l_terr_values_tbl(k).CURRENCY_CODE :=null;
             		      l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
             		      l_terr_values_tbl(k).ID_USED_FLAG :='N';
             		      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;


             		      l_terr_values_tbl(k).qualifier_tbl_index := i;

		               end loop;

                    else
                       write_log(2,' OVERLAY and NON_OVERLAY role exist for '||terr_group.terr_group_id);
                       --l_terr_qualtypeusgs_tbl(1).ORG_ID:=terr_group.ORG_ID;
                    end if;

                 end loop;

                 l_init_msg_list :=FND_API.G_TRUE;

          	     -- 07/08/03: JDOCHERT: bug#3023653
				 --mo_global.set_org_context(terr_group.ORG_ID,null);
				 --

                 jtf_territory_pvt.create_territory (
                   p_api_version_number         => l_api_version_number,
                   p_init_msg_list              => l_init_msg_list,
                   p_commit                     => l_commit,
                   p_validation_level           => fnd_api.g_valid_level_NONE,
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

                 if (x_return_status = 'S')  then

                     -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                     -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                     UPDATE JTF_TERR_ALL
                     set TERR_GROUP_FLAG = 'Y'
                       , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                       , NAMED_ACCOUNT_FLAG = 'Y'
                       , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                     where terr_id = x_terr_id;


                     write_log(2,' OVERLAY PI Territory Created = '||l_terr_all_rec.NAME);

                 else
                     x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
                     write_log(2,x_msg_data);
                     write_log(2, 'Failed in OVERLAY PI Territory Creation for TERR_GROUP_ACCOUNT_ID#'||
					              overlayterr.terr_group_account_id);

    	         end if;


                 --dbms_output.put_line('pit.role '||pit.role_code);
                 i:=0;

                 /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
           	     for rsc in resource_grp(overlayterr.terr_group_account_id,pit.role_code) loop

                    i:=i+1;

                    SELECT   JTF_TERR_RSC_S.nextval
                	into l_terr_rsc_id
                	FROM DUAL;

                    l_TerrRsc_Tbl(i).terr_id := x_terr_id;
                    l_TerrRsc_Tbl(i).TERR_RSC_ID :=l_terr_rsc_id;
                	l_TerrRsc_Tbl(i).LAST_UPDATE_DATE:=terr_group.LAST_UPDATE_DATE;
                	l_TerrRsc_Tbl(i).LAST_UPDATED_BY:=terr_group.LAST_UPDATED_BY;
                	l_TerrRsc_Tbl(i).CREATION_DATE:=terr_group.CREATION_DATE;
         		    l_TerrRsc_Tbl(i).CREATED_BY:=terr_group.CREATED_BY;
         		    l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
         		    --l_TerrRsc_Tbl(i).TERR_ID:=terr_group.TERRITORY_ID;
         		    l_TerrRsc_Tbl(i).RESOURCE_ID:=rsc.resource_id;
         		    l_TerrRsc_Tbl(i).RESOURCE_TYPE:=rsc.rsc_resource_type;
         		    l_TerrRsc_Tbl(i).ROLE:=pit.role_code;
                    --l_TerrRsc_Tbl(i).ROLE:=l_role;
         		    l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG:='N';
         		    l_TerrRsc_Tbl(i).START_DATE_ACTIVE:=terr_group.active_from_date ;
         		    l_TerrRsc_Tbl(i).END_DATE_ACTIVE:=terr_group.active_to_date ;
         		    l_TerrRsc_Tbl(i).ORG_ID:=terr_group.ORG_ID;
         		    l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG:='Y';
         		    l_TerrRsc_Tbl(i).GROUP_ID:=rsc.rsc_group_id;


                    a := 0;

                    for rsc_acc in role_access(terr_group.terr_group_id,pit.role_code) loop

						/**
						 a := a+1; -- JDOCHERT: 05/28/03: put a := a+1; inside 2*IF statements
						           -- that follow: ACCOUNT access should not be given for
								   -- Product Overlay territories
								   --
                        if rsc_acc.access_type= 'ACCOUNT' then

                            SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	       into l_terr_rsc_access_id
                            FROM DUAL;
                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'ACCOUNT';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                        els
						**/

						if rsc_acc.access_type= 'OPPORTUNITY' then

						    a := a+1;

                            SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	       into l_terr_rsc_access_id
                            FROM DUAL;

                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                        elsif rsc_acc.access_type= 'LEAD' then

						     a := a+1;

                            SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	       into l_terr_rsc_access_id
                            FROM DUAL;

                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;
                        end if;
                    end loop; /* rsc_acc in role_access */

                    l_init_msg_list :=FND_API.G_TRUE;

			        -- 07/08/03: JDOCHERT: bug#3023653
                    jtf_territory_resource_pvt.create_terrresource (
                       p_api_version_number      => l_Api_Version_Number,
                       p_init_msg_list           => l_Init_Msg_List,
                       p_commit                  => l_Commit,
                       p_validation_level        => fnd_api.g_valid_level_NONE,
                       x_return_status           => x_Return_Status,
                       x_msg_count               => x_Msg_Count,
                       x_msg_data                => x_msg_data,
                       p_terrrsc_tbl             => l_TerrRsc_tbl,
                       p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                       x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                       x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                    );

                    if x_Return_Status='S' then
          	           write_log(2,'Resource created for Product Interest OVERLAY Territory '||l_terr_all_rec.NAME);
                    else
                       write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '||
					               x_terr_id);
                    end if;

                 end loop; /* rsc in resource_grp */

              end loop;

           else
              x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
              write_log(2,x_msg_data);
              write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' ||
                  terr_group.terr_group_id || ' : ' ||
                  terr_group.terr_group_name );
  	       end if; /* if (x_return_status = 'S' */
         end loop; /* overlayterr in get_OVLY_party_duns */
	     END IF; /* ( terr_group.matching_rule_code IN ('2','3') THEN */
		 /***************************************************************/
         /* (8) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
		 /*     USING DUNS# QUALIFIER                                   */
         /***************************************************************/


          /***************************************************************/
          /* (9) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
		  /*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
          /***************************************************************/
	     IF ( terr_group.matching_rule_code IN ('1', '2') ) THEN

	       for overlayterr in get_OVLY_party_name(terr_group.terr_group_id) loop

              l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	          l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
     	      l_terr_qual_tbl:=l_terr_qual_empty_tbl;
              l_terr_values_tbl:=l_terr_values_empty_tbl;
              l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

              l_terr_all_rec.TERR_ID := null;
 		      l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
 		      l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		      l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
 		      l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

 		      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
 		      l_terr_all_rec.NAME:= overlayterr.name || ' (OVERLAY)';
 		      l_terr_all_rec.start_date_active := terr_group.active_from_date ;
 		      l_terr_all_rec.end_date_active   := terr_group.active_to_date;
 		      l_terr_all_rec.PARENT_TERRITORY_ID:=  l_overlay_top;
 		      l_terr_all_rec.RANK := terr_group.RANK + 20;
 		      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		      l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 		      l_terr_all_rec.DESCRIPTION:= overlayterr.name || ' (OVERLAY)';
 		      l_terr_all_rec.UPDATE_FLAG :='N';
 		      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

     		  l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
 		      l_terr_all_rec.NUM_WINNERS :=null ;


 		      SELECT JTF_TERR_USGS_S.nextval
                into l_terr_usg_id
              FROM DUAL;

              l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
              l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
              l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
              l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
 		      l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
              l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
              l_terr_usgs_tbl(1).TERR_ID:= null;
              l_terr_usgs_tbl(1).SOURCE_ID := -1001;
              l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;

              SELECT   JTF_TERR_QTYPE_USGS_S.nextval
                into l_terr_qtype_usg_id
              FROM DUAL;

      		  l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		      l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		      l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		      l_terr_qualtypeusgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(1).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID:=-1002;
              l_terr_qualtypeusgs_tbl(1).ORG_ID:=terr_group.ORG_ID;

              SELECT   JTF_TERR_QTYPE_USGS_S.nextval
       	        into l_terr_qtype_usg_id
              FROM DUAL;

   		      l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		      l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		      l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		      l_terr_qualtypeusgs_tbl(2).CREATION_DATE:= terr_group.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(2).CREATED_BY := terr_group.CREATED_BY;
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(2).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID:=-1003;
 		      l_terr_qualtypeusgs_tbl(2).ORG_ID:=terr_group.ORG_ID;

              SELECT JTF_TERR_QUAL_S.nextval
      	        into l_terr_qual_id
       	      FROM DUAL;

	          j:=0;
		      K:=0;
              l_prev_qual_usg_id:=1;

		      for qval in match_rule1(overlayterr.named_account_id)
              loop

      		     if l_prev_qual_usg_id <> qval.qual_usg_id then

                    j:=j+1;
        	        SELECT   JTF_TERR_QUAL_S.nextval
        	          into l_terr_qual_id
        	        FROM DUAL;

        	        l_terr_qual_tbl(j).TERR_QUAL_ID :=l_terr_qual_id;
        	        l_terr_qual_tbl(j).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		            l_terr_qual_tbl(j).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		            l_terr_qual_tbl(j).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_qual_tbl(j).CREATED_BY := terr_group.CREATED_BY;
 		            l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		            l_terr_qual_tbl(j).TERR_ID:=null;
 		            l_terr_qual_tbl(j).QUAL_USG_ID :=qval.qual_usg_id;
 		            l_terr_qual_tbl(j).QUALIFIER_MODE:=NULL;
 		            l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='N';
 		            l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 		            l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 		            l_terr_qual_tbl(j).ORG_ID:=terr_group.ORG_ID;
		            l_prev_qual_usg_id:= qval.qual_usg_id;
	  	        end if;

   	     	    k:=k+1;

	           	l_terr_values_tbl(k).TERR_VALUE_ID:=null;

           		l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
        		l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
 	         	l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
 	          	l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
        		l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
 	          	l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
        		l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		        l_terr_values_tbl(k).COMPARISON_OPERATOR := qval.COMPARISON_OPERATOR;
         		l_terr_values_tbl(k).LOW_VALUE_CHAR:= qval.value1_char;
 	           	l_terr_values_tbl(k).HIGH_VALUE_CHAR:= qval.value2_char;
           		l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 	          	l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
           		l_terr_values_tbl(k).VALUE_SET :=NULL;
        		l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
 	          	l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		        l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 	          	l_terr_values_tbl(k).CURRENCY_CODE :=null;
 	          	l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
         		l_terr_values_tbl(k).ID_USED_FLAG :='N';
        		l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;


         		l_terr_values_tbl(k).qualifier_tbl_index := j;

     		 end loop;

             l_init_msg_list :=FND_API.G_TRUE;

 		     -- 07/08/03: JDOCHERT: bug#3023653
			 --mo_global.set_org_context(terr_group.ORG_ID,null);
			 --

             jtf_territory_pvt.create_territory (
                   p_api_version_number         => l_api_version_number,
                   p_init_msg_list              => l_init_msg_list,
                   p_commit                     => l_commit,
                   p_validation_level           => fnd_api.g_valid_level_NONE,
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

              write_log(2,' OVERLAY Territory Created,territory_id# '||x_terr_id);


              if x_return_status = 'S' then

                 -- JDOCHERT: 01/08/03: Added TERR_GROUP_ID
                 -- and NAMED_ACCOUNT_FLAG and TERR_GROUP_ACCOUNT_ID
                 UPDATE JTF_TERR_ALL
                    set TERR_GROUP_FLAG = 'Y'
                      , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                      , NAMED_ACCOUNT_FLAG = 'Y'
                      , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                 where terr_id = x_terr_id;

                 l_overlay:=x_terr_id;

                 for pit in role_pi( terr_group.terr_group_id
				                   , overlayterr.terr_group_account_id) LOOP

                    l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	                l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
	                l_terr_qual_tbl:=l_terr_qual_empty_tbl;
                    l_terr_values_tbl:=l_terr_values_empty_tbl;
                    l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
                    l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

					l_role_counter := l_role_counter + 1;

                    l_terr_all_rec.TERR_ID := overlayterr.terr_group_account_id * -40 * l_role_counter;
 		            l_terr_all_rec.LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
 		            l_terr_all_rec.LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		            l_terr_all_rec.CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_all_rec.CREATED_BY := terr_group.CREATED_BY ;
 		            l_terr_all_rec.LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;

 	  	            l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;

 		            l_terr_all_rec.NAME:= overlayterr.name || ' ' || pit.role_name || ' (OVERLAY)';

 		            l_terr_all_rec.start_date_active := terr_group.active_from_date ;
 		            l_terr_all_rec.end_date_active   := terr_group.active_to_date;
 		            l_terr_all_rec.PARENT_TERRITORY_ID:= l_overlay;
 		            l_terr_all_rec.RANK := terr_group.RANK+10;
 		            l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		            l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		            l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		            l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		            l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 		            l_terr_all_rec.DESCRIPTION:= pit.role_code||' '||overlayterr.name||' (OVERLAY)';
 		            l_terr_all_rec.UPDATE_FLAG :='N';
 		            l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

 		            l_terr_all_rec.ORG_ID :=terr_group.ORG_ID ;
 		            l_terr_all_rec.NUM_WINNERS :=null ;

 		            SELECT   JTF_TERR_USGS_S.nextval
                      into l_terr_usg_id
                    FROM DUAL;

    	            l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
                    l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
                    l_terr_usgs_tbl(1).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    l_terr_usgs_tbl(1).CREATION_DATE:= terr_group.CREATION_DATE;
 		            l_terr_usgs_tbl(1).CREATED_BY := terr_group.CREATED_BY;
                    l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
                    l_terr_usgs_tbl(1).TERR_ID:= null;
                    l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
                    l_terr_usgs_tbl(1).ORG_ID:= terr_group.ORG_ID;

                    i := 0;
                    K:= 0;
                    for acc_type in role_access(terr_group.terr_group_id,pit.role_code) loop
                    --i:=i+1;
                    --dbms_output.put_line('acc type  '||acc_type.access_type);
                    if acc_type.access_type= 'OPPORTUNITY' then
                       i:=i+1;
                       SELECT   JTF_TERR_QTYPE_USGS_S.nextval
       	                 into l_terr_qtype_usg_id
                       FROM DUAL;

      		           l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		               l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
                       l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
                       l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
                       l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
                       l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
 		               l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       SELECT JTF_TERR_QUAL_S.nextval
      	                 into l_terr_qual_id
       	               FROM DUAL;
                       /* opp expected purchase */

           	           l_terr_qual_tbl(i).TERR_QUAL_ID :=l_terr_qual_id;
            	       l_terr_qual_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 	          	       l_terr_qual_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 	          	       l_terr_qual_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		               l_terr_qual_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		               l_terr_qual_tbl(i).TERR_ID:=null;
 		               l_terr_qual_tbl(i).QUAL_USG_ID :=-1023;
 		               l_terr_qual_tbl(i).QUALIFIER_MODE:=NULL;
 		               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG:='N';
 		               l_terr_qual_tbl(i).USE_TO_NAME_FLAG:=NULL;
 		               l_terr_qual_tbl(i).GENERATE_FLAG:=NULL;
 		               l_terr_qual_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       for qval in role_pi_interest(terr_group.terr_group_id,pit.role_code) loop
		                  k:=k+1;

  		                  l_terr_values_tbl(k).TERR_VALUE_ID:=null;

 		                  l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
 		                  l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
 		                  l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
 		                  l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
 		                  l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
 		                  l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
 		                  l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		                  l_terr_values_tbl(k).COMPARISON_OPERATOR :='=';
 		                  l_terr_values_tbl(k).LOW_VALUE_CHAR:= null;
 		                  l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
 		                  l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 		                  l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
 		                  l_terr_values_tbl(k).VALUE_SET :=NULL;
 		                  l_terr_values_tbl(k).INTEREST_TYPE_ID :=qval.interest_type_id;
 		                  l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		                  l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 		                  l_terr_values_tbl(k).CURRENCY_CODE :=null;
 		                  l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
 		                  l_terr_values_tbl(k).ID_USED_FLAG :='N';
 		                  l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

 		                  l_terr_values_tbl(k).qualifier_tbl_index := i;

  		               end loop;

                    elsif acc_type.access_type= 'LEAD' then

                       i:=i+1;
                       SELECT   JTF_TERR_QTYPE_USGS_S.nextval
                         into l_terr_qtype_usg_id
                       FROM DUAL;

        		       l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE;
   		               l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
   		               l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
                       l_terr_qualtypeusgs_tbl(i).CREATED_BY := terr_group.CREATED_BY;
                       l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
                       l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
                       l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1002;
                       l_terr_qualtypeusgs_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       SELECT   JTF_TERR_QUAL_S.nextval
      	                 into l_terr_qual_id
       	               FROM DUAL;

                       /* lead expected purchase */
       	               l_terr_qual_tbl(i).TERR_QUAL_ID :=l_terr_qual_id;
       	               l_terr_qual_tbl(i).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
 		               l_terr_qual_tbl(i).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
 		               l_terr_qual_tbl(i).CREATION_DATE:= terr_group.CREATION_DATE;
 		               l_terr_qual_tbl(i).CREATED_BY := terr_group.CREATED_BY;
 		               l_terr_qual_tbl(i).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
 		               l_terr_qual_tbl(i).TERR_ID:=null;
 		               l_terr_qual_tbl(i).QUAL_USG_ID :=-1018;
 		               l_terr_qual_tbl(i).QUALIFIER_MODE:=NULL;
 		               l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG:='N';
 		               l_terr_qual_tbl(i).USE_TO_NAME_FLAG:=NULL;
 		               l_terr_qual_tbl(i).GENERATE_FLAG:=NULL;
 		               l_terr_qual_tbl(i).ORG_ID:=terr_group.ORG_ID;

                       for qval in role_pi_interest(terr_group.terr_group_id,pit.role_code) loop

                          k:=k+1;

            		      l_terr_values_tbl(k).TERR_VALUE_ID:=null;

                  	      l_terr_values_tbl(k).LAST_UPDATED_BY := terr_group.last_UPDATED_BY;
              		      l_terr_values_tbl(k).LAST_UPDATE_DATE:= terr_group.last_UPDATE_DATE;
             		      l_terr_values_tbl(k).CREATED_BY  := terr_group.CREATED_BY;
             		      l_terr_values_tbl(k).CREATION_DATE:= terr_group.CREATION_DATE;
             		      l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= terr_group.last_UPDATE_LOGIN;
             		      l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
             		      l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
             		      l_terr_values_tbl(k).COMPARISON_OPERATOR :='=';
             		      l_terr_values_tbl(k).LOW_VALUE_CHAR:= null;
             		      l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
             		      l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
             		      l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
             		      l_terr_values_tbl(k).VALUE_SET :=NULL;
             		      l_terr_values_tbl(k).INTEREST_TYPE_ID := qval.interest_type_id;
             		      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
             		      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
             		      l_terr_values_tbl(k).CURRENCY_CODE :=null;
             		      l_terr_values_tbl(k).ORG_ID :=terr_group.ORG_ID;
             		      l_terr_values_tbl(k).ID_USED_FLAG :='N';
             		      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;


             		      l_terr_values_tbl(k).qualifier_tbl_index := i;

		               end loop;

                    else
                       write_log(2,' OVERLAY and NON_OVERLAY role exist for '||terr_group.terr_group_id);
                       --l_terr_qualtypeusgs_tbl(1).ORG_ID:=terr_group.ORG_ID;
                    end if;

                 end loop;

                 l_init_msg_list :=FND_API.G_TRUE;

          	     -- 07/08/03: JDOCHERT: bug#3023653
				 --mo_global.set_org_context(terr_group.ORG_ID,null);
				 --

                    --mo_global.set_org_context(204,null);
         		 --AS_UTILITY_PVT.file_debug(' winners # '||terr_group.NUM_WINNERS);
         		 --AS_UTILITY_PVT.file_debug(' migration of territory_group # '||terr_group.TERRITORY_GROUP_ID);
                 jtf_territory_pvt.create_territory (
                   p_api_version_number         => l_api_version_number,
                   p_init_msg_list              => l_init_msg_list,
                   p_commit                     => l_commit,
                   p_validation_level           => fnd_api.g_valid_level_NONE,
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
                     set TERR_GROUP_FLAG = 'Y'
                       , TERR_GROUP_ID = terr_group.TERR_GROUP_ID
                       , NAMED_ACCOUNT_FLAG = 'Y'
                       , TERR_GROUP_ACCOUNT_ID = overlayterr.terr_group_account_id
                     where terr_id = x_terr_id;


                     write_log(2,' OVERLAY CNR territory created:' || l_terr_all_rec.NAME);

                 else
                     x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
                     write_log(2,x_msg_data);
                     write_log(2,'Failed in OVERLAY CNR territory treation for ' ||
					             'TERR_GROUP_ACCOUNT_ID = ' ||
								 overlayterr.terr_group_account_id );

    	         end if; /* IF (x_return_status = 'S') */


                 --dbms_output.put_line('pit.role '||pit.role_code);
                 i:=0;

                 /* JRADHAKR changed the parameter from l_terr_group_id to l_terr_group_acct_id */
           	     for rsc in resource_grp( overlayterr.terr_group_account_id
				                        , pit.role_code) loop

                    i:=i+1;

                    SELECT   JTF_TERR_RSC_S.nextval
                	into l_terr_rsc_id
                	FROM DUAL;

                    l_TerrRsc_Tbl(i).terr_id := x_terr_id;
                    l_TerrRsc_Tbl(i).TERR_RSC_ID :=l_terr_rsc_id;
                	l_TerrRsc_Tbl(i).LAST_UPDATE_DATE:=terr_group.LAST_UPDATE_DATE;
                	l_TerrRsc_Tbl(i).LAST_UPDATED_BY:=terr_group.LAST_UPDATED_BY;
                	l_TerrRsc_Tbl(i).CREATION_DATE:=terr_group.CREATION_DATE;
         		    l_TerrRsc_Tbl(i).CREATED_BY:=terr_group.CREATED_BY;
         		    l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN:=terr_group.LAST_UPDATE_LOGIN;
         		    --l_TerrRsc_Tbl(i).TERR_ID:=terr_group.TERRITORY_ID;
         		    l_TerrRsc_Tbl(i).RESOURCE_ID:=rsc.resource_id;
         		    l_TerrRsc_Tbl(i).RESOURCE_TYPE:=rsc.rsc_resource_type;
         		    l_TerrRsc_Tbl(i).ROLE:=pit.role_code;
                    --l_TerrRsc_Tbl(i).ROLE:=l_role;
         		    l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG:='N';
         		    l_TerrRsc_Tbl(i).START_DATE_ACTIVE:=terr_group.active_from_date ;
         		    l_TerrRsc_Tbl(i).END_DATE_ACTIVE:=terr_group.active_to_date ;
         		    l_TerrRsc_Tbl(i).ORG_ID:=terr_group.ORG_ID;
         		    l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG:='Y';
         		    l_TerrRsc_Tbl(i).GROUP_ID:=rsc.rsc_group_id;


                    a := 0;

                    for rsc_acc in role_access(terr_group.terr_group_id,pit.role_code) loop

                        /**
						 a := a+1; -- JDOCHERT: 05/28/03: put a := a+1; inside 2*IF statements
						           -- that follow: ACCOUNT access should not be given for
								   -- Product Overlay territories
								   --
						if rsc_acc.access_type= 'ACCOUNT' then

                            SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	       into l_terr_rsc_access_id
                            FROM DUAL;
                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'ACCOUNT';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                        els
						**/

						if rsc_acc.access_type= 'OPPORTUNITY' then

						    a := a+1;

                            SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	       into l_terr_rsc_access_id
                            FROM DUAL;

                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                        elsif rsc_acc.access_type= 'LEAD' then

						    a := a+1;

                            SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	       into l_terr_rsc_access_id
                            FROM DUAL;

                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= terr_group.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= terr_group.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= terr_group.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := terr_group.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= terr_group.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= terr_group.ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;
                        end if;
                    end loop; /* rsc_acc in role_access */

                    l_init_msg_list :=FND_API.G_TRUE;

			        -- 07/08/03: JDOCHERT: bug#3023653
                    jtf_territory_resource_pvt.create_terrresource (
                       p_api_version_number      => l_Api_Version_Number,
                       p_init_msg_list           => l_Init_Msg_List,
                       p_commit                  => l_Commit,
                       p_validation_level        => fnd_api.g_valid_level_NONE,
                       x_return_status           => x_Return_Status,
                       x_msg_count               => x_Msg_Count,
                       x_msg_data                => x_msg_data,
                       p_terrrsc_tbl             => l_TerrRsc_tbl,
                       p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                       x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                       x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                    );

                    if x_Return_Status='S' then
          	           write_log(2,'Resource created for Product Interest OVERLAY Territory# '||
					               x_terr_id);
                    else
                       write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '||
					               x_terr_id);
                    end if;

                 end loop; /* rsc in resource_grp */

              end loop;

           else
              x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
              write_log(2,x_msg_data);
              write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' ||
                  terr_group.terr_group_id || ' : ' ||
                  terr_group.terr_group_name );
  	       end if;

        end loop;  /* for overlayterr in get_OVLY_party_name */
		END IF;    /* IF ( terr_group.matching_rule_code IN ('1', '2') ) THEN */
		/***************************************************************/
        /* (9) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
		/*     USING CUSTOMER NAME RANGE AND POSTAL CODE QUALIFIERS    */
        /***************************************************************/




     end if; /* l_pi_count*/

   else              ---if TERR_GROUP.self_service_type = 'GEOGRAPHY' then

        l_terr_group_rec.TERR_GROUP_ID           :=  terr_group.TERR_GROUP_ID;
        l_terr_group_rec.TERR_GROUP_NAME         :=  terr_group.TERR_GROUP_NAME;
        l_terr_group_rec.RANK                    :=  terr_group.RANK;
        l_terr_group_rec.ACTIVE_FROM_DATE        :=  terr_group.ACTIVE_FROM_DATE;
        l_terr_group_rec.ACTIVE_TO_DATE          :=  terr_group.ACTIVE_TO_DATE;
        l_terr_group_rec.PARENT_TERR_ID          :=  L_NACAT;
        l_terr_group_rec.MATCHING_RULE_CODE      :=  terr_group.MATCHING_RULE_CODE;
        l_terr_group_rec.CREATED_BY              :=  terr_group.CREATED_BY;
        l_terr_group_rec.CREATION_DATE           :=  terr_group.CREATION_DATE;
        l_terr_group_rec.LAST_UPDATED_BY         :=  terr_group.LAST_UPDATED_BY;
        l_terr_group_rec.LAST_UPDATE_DATE        :=  terr_group.LAST_UPDATE_DATE;
        l_terr_group_rec.LAST_UPDATE_LOGIN       :=  terr_group.LAST_UPDATE_LOGIN;
--        l_terr_group_rec.Catch_all_resource_id   :=  terr_group.Catch_all_resource_id;
--        l_terr_group_rec.catch_all_resource_type :=  terr_group.catch_all_resource_type;
        l_terr_group_rec.generate_catchall_flag  :=  terr_group.generate_catchall_flag;
        l_terr_group_rec.NUM_WINNERS             :=  terr_group.NUM_WINNERS;

        create_geography_territory
          ( p_terr_group_rec        => l_terr_group_rec
          , p_org_id                => terr_group.org_id
          , x_return_status         => l_return_status
          , x_error_message         => l_error_message
          );

   end if; /* self_service_type */
  end if;

     commit;

     write_log(2, '');
     write_log(2,'END: Territory Creation for Territory Group: ' ||
                    terr_group.terr_group_id || ' : ' ||
                    terr_group.terr_group_name );
     write_log(2, '');
     write_log(2, '----------------------------------------------------------');

  END LOOP;
  /****************************************************
  ** (2) END: CREATE NAMED ACCOUNT TERRITORY CREATION
  ** FOR EACH TERRITORY GROUP
  *****************************************************/

     /* JDOCHERT: 07/09/03:
   ** START: Disable triggers in
   ** TOTAL mode */
   IF (p_mode = 'TOTAL') THEN
      alter_triggers(p_status => 'ENABLE');
   END IF;

END generate_named_overlay_terr;


PROCEDURE  create_geography_territory
  ( p_terr_group_rec  IN  TERR_GRP_REC_TYPE
  , p_org_id          IN  NUMBER
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_error_message    OUT NOCOPY  VARCHAR2
  ) IS

    l_terr_all_rec                JTF_TERRITORY_PVT.terr_all_rec_type;
    l_terr_usgs_tbl               JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_tbl       JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_tbl               JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_tbl             JTF_TERRITORY_PVT.terr_values_tbl_type;

    l_TerrRsc_Tbl                 JTF_TERRITORY_RESOURCE_PVT.TerrResource_tbl_type;
    l_TerrRsc_Access_Tbl          JTF_TERRITORY_RESOURCE_PVT.TerrRsc_Access_tbl_type ;
    l_TerrRsc_empty_Tbl           JTF_TERRITORY_RESOURCE_PVT.TerrResource_tbl_type;
    l_TerrRsc_Access_empty_Tbl    JTF_TERRITORY_RESOURCE_PVT.TerrRsc_Access_tbl_type ;

    l_terr_usgs_empty_tbl         JTF_TERRITORY_PVT.terr_usgs_tbl_type;
    l_terr_qualtypeusgs_empty_tbl JTF_TERRITORY_PVT.terr_qualtypeusgs_tbl_type;
    l_terr_qual_empty_tbl         JTF_TERRITORY_PVT.terr_qual_tbl_type;
    l_terr_values_empty_tbl       JTF_TERRITORY_PVT.terr_values_tbl_type;


    i   NUMBER;
    j   NUMBER;
    k   NUMBER;
    a   NUMBER;

    l_terr_qual_id              NUMBER;
    l_id_used_flag              VARCHAR2(1);
    l_low_value_char_id NUMBER;
    l_qual_usgs_id      NUMBER;
    l_terr_usg_id       NUMBER;
    l_qual_type_usg_id  NUMBER;
    l_terr_qtype_usg_id NUMBER;
    l_terr_type_usg_id  NUMBER;
    l_type_qtype_usg_id NUMBER;
    l_terr_rsc_id               NUMBER;
    l_terr_rsc_access_id        NUMBER;
    l_access_type               VARCHAR2(30);
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_init_msg_list         varchar2(1);
    l_commit                varchar2(1);

    l_overlay_top  number;
    l_overlay      number;
    l_role_counter                NUMBER := 0;

    l_pi_count                    NUMBER := 0;
    l_prev_qual_usg_id            NUMBER;

    x_terr_usgs_out_tbl           JTF_TERRITORY_PVT.terr_usgs_out_tbl_type;
    x_terr_qualtypeusgs_out_tbl   JTF_TERRITORY_PVT.terr_qualtypeusgs_out_tbl_type;
    x_terr_qual_out_tbl           JTF_TERRITORY_PVT.terr_qual_out_tbl_type;
    x_terr_values_out_tbl         JTF_TERRITORY_PVT.terr_values_out_tbl_type;
    x_TerrRsc_Out_Tbl             JTF_TERRITORY_RESOURCE_PVT.TerrResource_out_tbl_type;
    x_TerrRsc_Access_Out_Tbl      JTF_TERRITORY_RESOURCE_PVT.TerrRsc_Access_out_tbl_type;

    x_terr_id           NUMBER;
    x_msg_count         number;
    x_msg_data          varchar2(2000);


    /* get all the geographies for a given territory group id
    */

    CURSOR geo_territories( l_terr_group_id number) IS
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
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_territory_id
         AND grsc.rsc_role_code = tgr.role_code
         AND ra.terr_group_role_id = tgr.terr_group_role_id
         AND ra.access_type IN ('ACCOUNT')
       UNION
       SELECT ra.access_type
       FROM
         JTF_TTY_GEO_TERR_RSC grsc
       , jtf_tty_terr_grp_roles tgr
       , jtf_tty_role_access ra
       WHERE grsc.GEO_TERRITORY_ID = l_geo_territory_id
         AND grsc.rsc_role_code = tgr.role_code
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

    CURSOR geo_values(l_geo_territory_id number) IS
           SELECT -1007 qual_usg_id
                 , '=' comparison_operator
                 , main.postal_code value1_char
                 , main.geo_territory_id
     from(
    /* postal code */
    select g.postal_code       postal_code,
           g.geo_id            geo_id
          , terr.geo_territory_id
      from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g   --postal_code level
    where  terr.terr_group_id      = tg.terr_group_id
           and terr.terr_group_id      = grpv.terr_group_id
           and terr.owner_resource_id  < 0
           and terr.parent_geo_terr_id < 0 -- default terr
           and ( (
                    grpv.geo_type = 'POSTAL_CODE'
                    and grpv.comparison_operator = '='
                    and g.geo_id = grpv.geo_id_from
                    and g.geo_type = 'POSTAL_CODE'
                  )
                  or
                  (
                    grpv.geo_type = 'POSTAL_CODE'
                    and grpv.comparison_operator = 'BETWEEN'
                    and g.geo_type = 'POSTAL_CODE'
                    and g.geo_id between grpv.geo_id_from and grpv.geo_id_to
                  )
               )
    union
    select  g.postal_code       postal_code,
            g.geo_id            geo_id
          , terr.geo_territory_id
    from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g,
           jtf_tty_geographies     g1
    where  terr.terr_group_id      = tg.terr_group_id
           and terr.terr_group_id      = grpv.terr_group_id
           and terr.owner_resource_id  < 0
           and terr.parent_geo_terr_id < 0 -- default terr
           and (
                  (
                    grpv.geo_type = 'STATE'
                    and g1.geo_id = grpv.geo_id_from
                    and g.STATE_CODE = g1.state_Code
                    and g.country_code = g1.country_Code
                    and g.geo_type = 'POSTAL_CODE'
                  )
                  or
                  ( grpv.geo_type = 'CITY'
                    AND  g.geo_type = 'POSTAL_CODE'
                    AND  g.country_code = g1.country_code
                    AND (
                           (g.state_code = g1.state_code AND g1.province_code is null)
                            or
                           (g1.province_code = g.province_code AND g1.state_code is null)
                         )
                    AND    (g1.county_code is null or g.county_code = g1.county_code)
                    AND    g.city_code = g1.city_code
                    AND    grpv.geo_id_from = g1.geo_id
                  )
                  or
                  (
                           grpv.geo_type = 'COUNTRY'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
                  )
                  or
                  (
                           grpv.geo_type = 'PROVINCE'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
                    AND    g.province_code = g1.province_code
                  )
                )
    union
    select g.postal_code    postal_code,
           g.geo_id         geo_id
          , terr.geo_territory_id
    from   jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geographies     g,
           jtf_tty_geo_terr_values tv
    where  terr.terr_group_id      = tg.terr_group_id
           and terr.owner_resource_id  >= 0
           and terr.parent_geo_terr_id >= 0 -- not default terr
           and tv.geo_territory_id     = terr.geo_territory_id
           and g.geo_id                = tv.geo_id
 ) main
 where  main.geo_id not in -- the terr the user owners
 (
    select tv.geo_id geo_id
    from   jtf_tty_geo_terr    terr,
           jtf_tty_geo_terr_values tv
    where
           tv.geo_territory_id = terr.geo_territory_id
         and main.geo_territory_id = terr.parent_geo_terr_id
  )
  and geo_territory_id = l_geo_territory_id;

    /* Access Types for a particular Role within a Territory Group */
    CURSOR NON_OVLY_role_access( lp_terr_group_id number
                                   , lp_role varchar2) IS
    SELECT distinct a.access_type
    from jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = lp_terr_group_id
      and b.role_code          = lp_role
          AND NOT EXISTS (
               /* Product Interest does not exist for this role */
               SELECT NULL
                   FROM jtf_tty_role_prod_int rpi
                   WHERE rpi.terr_group_role_id = B.TERR_GROUP_ROLE_ID )
    order by a.access_type  ;

    /* Roles WITHOUT a Product Iterest defined */
    CURSOR role_interest_nonpi(l_terr_group_id number) IS
    SELECT  b.role_code role_code
           --,a.interest_type_id
           ,b.terr_group_id
    from jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id(+) = b.terr_group_role_id
      and b.terr_group_id         = l_terr_group_id
      and a.terr_group_role_id is  null
    order by b.role_code;

    CURSOR terr_resource (l_geo_territory_id number,l_role varchar2) IS
    SELECT distinct a.resource_id
         , a.rsc_group_id
         , nvl(a.rsc_resource_type,'RS_EMPLOYEE') rsc_resource_type
    from jtf_tty_geo_terr_rsc a
       , jtf_tty_geo_terr b
    where a.geo_territory_id = b.geo_territory_id
      and b.geo_territory_id = l_geo_territory_id
      and a.rsc_role_code = l_role;

    /* Get Top-Level Parent Territory details */
    CURSOR topterr(l_terr number) IS
    SELECT name
         , description
         , rank
         , parent_territory_id
         , terr_id
    from jtf_terr_all
    where terr_id = l_terr;

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

    CURSOR get_OVLY_geographies(LP_terr_group_id number) IS
    SELECT gterr.geo_territory_id
         , gterr.geo_terr_name
    FROM jtf_tty_geo_terr gterr
    WHERE gterr.terr_group_id = lp_terr_group_id
      AND EXISTS (
	        /* Salesperson, with Role that has a Product
			** Interest defined, exists for this Named Account */
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
    SELECT distinct
           b.role_code role_code
	 , r.role_name role_name
    from jtf_rs_roles_vl r
       , jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    where r.role_code = b.role_code
      and a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = lp_terr_group_id
	  AND EXISTS (
	         /* Named Account exists with Salesperson with this role */
	         SELECT NULL
			 FROM jtf_tty_geo_terr_rsc grsc, jtf_tty_geo_terr gterr
			 WHERE gterr.geo_territory_id = grsc.geo_territory_id
			   AND grsc.geo_territory_id = lp_geo_territory_id
			   AND gterr.terr_group_id = b.terr_group_id
			   AND grsc.rsc_role_code = b.role_code );


   /* Access Types for a particular Role within a Territory Group */
    CURSOR role_access(l_terr_group_id number,l_role varchar2) IS
    SELECT distinct a.access_type
    from jtf_tty_role_access a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = l_terr_group_id
      and b.role_code          = l_role
    order by a.access_type  ;

    /* Product Interest for a Role */
    CURSOR role_pi_interest(l_terr_group_id number,l_role varchar2) IS
    SELECT  a.interest_type_id
    from jtf_tty_role_prod_int a
       , jtf_tty_terr_grp_roles b
    where a.terr_group_role_id = b.terr_group_role_id
      and b.terr_group_id      = l_terr_group_id
      and b.role_code          = l_role;


Begin

   for geo_terr in geo_territories(p_terr_group_rec.terr_group_id) loop


       l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
       l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
       l_terr_qual_tbl:=l_terr_qual_empty_tbl;
       l_terr_values_tbl:=l_terr_values_empty_tbl;
       l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
       l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;


       l_terr_all_rec.LAST_UPDATE_DATE  := p_terr_group_rec.LAST_UPDATE_DATE;
       l_terr_all_rec.LAST_UPDATED_BY   := p_terr_group_rec.LAST_UPDATED_BY;
       l_terr_all_rec.CREATION_DATE     := p_terr_group_rec.CREATION_DATE;
       l_terr_all_rec.CREATED_BY        := p_terr_group_rec.CREATED_BY ;
       l_terr_all_rec.LAST_UPDATE_LOGIN := p_terr_group_rec.LAST_UPDATE_LOGIN;

       l_terr_all_rec.APPLICATION_SHORT_NAME := G_APP_SHORT_NAME;

       l_terr_all_rec.NAME              := geo_terr.geo_terr_name || ' ' || geo_terr.geo_territory_id;
       l_terr_all_rec.start_date_active := p_terr_group_rec.active_from_date ;
       l_terr_all_rec.end_date_active   := p_terr_group_rec.active_to_date;
       l_terr_all_rec.PARENT_TERRITORY_ID    :=  p_terr_group_rec.parent_terr_id;
       l_terr_all_rec.RANK                   := p_terr_group_rec.RANK + 10;
       l_terr_all_rec.TEMPLATE_TERRITORY_ID  := NULL;
       l_terr_all_rec.TEMPLATE_FLAG          := 'N';
       l_terr_all_rec.ESCALATION_TERRITORY_ID:= NULL;
       l_terr_all_rec.ESCALATION_TERRITORY_FLAG  := 'N';
       l_terr_all_rec.OVERLAP_ALLOWED_FLAG       := NULL;
       l_terr_all_rec.DESCRIPTION                := geo_terr.geo_terr_name;
       l_terr_all_rec.UPDATE_FLAG                := 'N';
       l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG := NULL;

       l_terr_all_rec.ORG_ID                     := p_org_id;
       l_terr_all_rec.NUM_WINNERS                := null ;

       /* Oracle Sales and Telesales Usage */

       SELECT   JTF_TERR_USGS_S.nextval
         into l_terr_usg_id
       FROM DUAL;

       l_terr_usgs_tbl(1).TERR_USG_ID        := l_terr_usg_id;
       l_terr_usgs_tbl(1).LAST_UPDATE_DATE   := p_terr_group_rec.LAST_UPDATE_DATE;
       l_terr_usgs_tbl(1).LAST_UPDATED_BY    := p_terr_group_rec.LAST_UPDATED_BY;
       l_terr_usgs_tbl(1).CREATION_DATE      := p_terr_group_rec.CREATION_DATE;
       l_terr_usgs_tbl(1).CREATED_BY         := p_terr_group_rec.CREATED_BY;
       l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN  := p_terr_group_rec.LAST_UPDATE_LOGIN;
       l_terr_usgs_tbl(1).TERR_ID            := null;
       l_terr_usgs_tbl(1).SOURCE_ID          := -1001;
       l_terr_usgs_tbl(1).ORG_ID             := p_org_id;

       i:=0;

       /* BEGIN: For each Access Type defined for the Territory Group */

       for acctype in get_NON_OVLY_geo_trans( geo_terr.geo_territory_id ) LOOP

          i:=i+1;

          /* ACCOUNT TRANSACTION TYPE */

          if acctype.access_type='ACCOUNT' then

             SELECT JTF_TERR_QTYPE_USGS_S.nextval
               into l_terr_qtype_usg_id
               FROM DUAL;

             l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_terr_group_rec.LAST_UPDATE_DATE;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_terr_group_rec.LAST_UPDATED_BY;
             l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_terr_group_rec.CREATION_DATE;
             l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_terr_group_rec.CREATED_BY;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_terr_group_rec.LAST_UPDATE_LOGIN;
             l_terr_qualtypeusgs_tbl(i).TERR_ID                 := null;
             l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1001;
             l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id;

          /* LEAD TRANSACTION TYPE */
          elsif acctype.access_type='LEAD' then

             SELECT JTF_TERR_QTYPE_USGS_S.nextval
               into l_terr_qtype_usg_id
               FROM DUAL;
             l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID   := l_terr_qtype_usg_id;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE        := p_terr_group_rec.LAST_UPDATE_DATE;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY         := p_terr_group_rec.LAST_UPDATED_BY;
             l_terr_qualtypeusgs_tbl(i).CREATION_DATE           := p_terr_group_rec.CREATION_DATE;
             l_terr_qualtypeusgs_tbl(i).CREATED_BY              := p_terr_group_rec.CREATED_BY;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN       := p_terr_group_rec.LAST_UPDATE_LOGIN;
             l_terr_qualtypeusgs_tbl(i).TERR_ID                 := null;
             l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID        := -1002;
             l_terr_qualtypeusgs_tbl(i).ORG_ID                  := p_org_id;

          /* OPPORTUNITY TRANSACTION TYPE */
          elsif acctype.access_type='OPPORTUNITY' then

             SELECT JTF_TERR_QTYPE_USGS_S.nextval
               into l_terr_qtype_usg_id
             FROM DUAL;
             l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
             l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
             l_terr_qualtypeusgs_tbl(i).CREATED_BY := p_terr_group_rec.CREATED_BY;
             l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
             l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
             l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
             l_terr_qualtypeusgs_tbl(i).ORG_ID:=p_org_id;

          end if;

       end loop;


       /*
       ** get Named Account Customer Keyname and Postal Code Mapping
       ** rules, to use as territory definition qualifier values
       */

       j := 0;
       K := 0;

       l_prev_qual_usg_id:=1;


       FOR gval IN geo_values( geo_terr.geo_territory_id ) LOOP

          /* new qualifier, i.e., if there is a qualifier in
          ** Addition to DUNS# */

          IF l_prev_qual_usg_id <> gval.qual_usg_id THEN

             j:=j+1;

             SELECT JTF_TERR_QUAL_S.nextval
              into l_terr_qual_id
              FROM DUAL;

             l_terr_qual_tbl(j).TERR_QUAL_ID :=l_terr_qual_id;
             l_terr_qual_tbl(j).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
             l_terr_qual_tbl(j).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
             l_terr_qual_tbl(j).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
             l_terr_qual_tbl(j).CREATED_BY := p_terr_group_rec.CREATED_BY;
             l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
             l_terr_qual_tbl(j).TERR_ID:=null;
             l_terr_qual_tbl(j).QUAL_USG_ID :=gval.qual_usg_id;
             l_terr_qual_tbl(j).QUALIFIER_MODE:=NULL;
             l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='N';
             l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
             l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
             l_terr_qual_tbl(j).ORG_ID:=p_org_id;
             l_prev_qual_usg_id:= gval.qual_usg_id;

         END IF;

         k:=k+1;

         l_terr_values_tbl(k).TERR_VALUE_ID:=null;
         l_terr_values_tbl(k).LAST_UPDATED_BY := p_terr_group_rec.last_UPDATED_BY;
         l_terr_values_tbl(k).LAST_UPDATE_DATE:= p_terr_group_rec.last_UPDATE_DATE;
         l_terr_values_tbl(k).CREATED_BY  := p_terr_group_rec.CREATED_BY;
         l_terr_values_tbl(k).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
         l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= p_terr_group_rec.last_UPDATE_LOGIN;
         l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
         l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
         l_terr_values_tbl(k).COMPARISON_OPERATOR := gval.COMPARISON_OPERATOR;
         l_terr_values_tbl(k).LOW_VALUE_CHAR:= gval.value1_char;
         l_terr_values_tbl(k).HIGH_VALUE_CHAR:= NULL;
         l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
         l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
         l_terr_values_tbl(k).VALUE_SET :=NULL;
         l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
         l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
         l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
         l_terr_values_tbl(k).CURRENCY_CODE :=null;
         l_terr_values_tbl(k).ORG_ID :=p_org_id;
         l_terr_values_tbl(k).ID_USED_FLAG :='N';
         l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;
         l_terr_values_tbl(k).qualifier_tbl_index := j;

      end loop; /* qval IN pqual */

      l_init_msg_list :=FND_API.G_TRUE;

      if l_prev_qual_usg_id <> 1 then    --  geography territory values are there if this condition is true
      jtf_territory_pvt.create_territory (
         p_api_version_number         => l_api_version_number,
         p_init_msg_list              => l_init_msg_list,
         p_commit=> l_commit,
         p_validation_level           => fnd_api.g_valid_level_NONE,
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

       if x_return_status = 'S' then

          -- JDOCHERT: 01/08/03: Added p_terr_group_rec_ID and CATCH_ALL_FLAG
          -- and NAMED_ACCOUNT_FLAG and p_terr_group_rec_ACCOUNT_ID

          UPDATE JTF_TERR_ALL
             set TERR_GROUP_FLAG = 'Y'
               , TERR_GROUP_ID = p_terr_group_rec.TERR_GROUP_ID
           where terr_id = x_terr_id;

          --write_log(2,p_terr_group_rec.terr_group_id);
          --write_log(2,tran_type.role_code);

          l_init_msg_list :=FND_API.G_TRUE;
          i := 0;
          a := 0;

          FOR tran_type in role_interest_nonpi(p_terr_group_rec.Terr_gROUP_ID)
          LOOP


             FOR rsc in terr_resource(geo_terr.geo_territory_id,tran_type.role_code)
             loop

                i := i+1;

                SELECT JTF_TERR_RSC_S.nextval
                  into l_terr_rsc_id
                  FROM DUAL;

                l_TerrRsc_Tbl(i).terr_id := x_terr_id;
                l_TerrRsc_Tbl(i).TERR_RSC_ID :=l_terr_rsc_id;
                l_TerrRsc_Tbl(i).LAST_UPDATE_DATE:=p_terr_group_rec.LAST_UPDATE_DATE;
                l_TerrRsc_Tbl(i).LAST_UPDATED_BY:=p_terr_group_rec.LAST_UPDATED_BY;
                l_TerrRsc_Tbl(i).CREATION_DATE:=p_terr_group_rec.CREATION_DATE;
                l_TerrRsc_Tbl(i).CREATED_BY:=p_terr_group_rec.CREATED_BY;
                l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN:=p_terr_group_rec.LAST_UPDATE_LOGIN;
                l_TerrRsc_Tbl(i).RESOURCE_ID:=rsc.resource_id;
                l_TerrRsc_Tbl(i).RESOURCE_TYPE:=rsc.rsc_resource_type;
                l_TerrRsc_Tbl(i).ROLE:=tran_type.role_code;
                l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG:='N';
                l_TerrRsc_Tbl(i).START_DATE_ACTIVE:=p_terr_group_rec.active_from_date ;
                l_TerrRsc_Tbl(i).END_DATE_ACTIVE:=p_terr_group_rec.active_to_date ;
                l_TerrRsc_Tbl(i).ORG_ID:=p_org_id;
                l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG:='Y';
                l_TerrRsc_Tbl(i).GROUP_ID:=rsc.rsc_group_id;

                FOR rsc_acc in NON_OVLY_role_access(p_terr_group_rec.terr_group_id,tran_type.role_code) LOOP
                   --dbms_output.put_line('rsc_acc.access_type   '||rsc_acc.access_type);
                   a := a+1;

                   /* ACCOUNT ACCESS TYPE */
                   IF (rsc_acc.access_type= 'ACCOUNT') THEN

                     SELECT JTF_TERR_RSC_ACCESS_S.nextval
                         into l_terr_rsc_access_id
                     FROM DUAL;
                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
                     l_TerrRsc_Access_Tbl(a).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
                     l_TerrRsc_Access_Tbl(a).CREATED_BY := p_terr_group_rec.CREATED_BY;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'ACCOUNT';
                     l_TerrRsc_Access_Tbl(a).ORG_ID:= p_org_id;
                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                   /* OPPORTUNITY ACCESS TYPE */
                   elsif rsc_acc.access_type= 'OPPORTUNITY' then

                     SELECT JTF_TERR_RSC_ACCESS_S.nextval
                     into l_terr_rsc_access_id
                     FROM DUAL;

                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
                     l_TerrRsc_Access_Tbl(a).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
                     l_TerrRsc_Access_Tbl(a).CREATED_BY := p_terr_group_rec.CREATED_BY;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
                     l_TerrRsc_Access_Tbl(a).ORG_ID:= p_org_id;
                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                   /* LEAD ACCESS TYPE */
                   elsif rsc_acc.access_type= 'LEAD' then

                     SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                        into l_terr_rsc_access_id
                     FROM DUAL;
                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
                     l_TerrRsc_Access_Tbl(a).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
                     l_TerrRsc_Access_Tbl(a).CREATED_BY := p_terr_group_rec.CREATED_BY;
                     l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
                     l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
                     l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
                     l_TerrRsc_Access_Tbl(a).ORG_ID:= p_org_id;
                     l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;
                   end if;
                end loop; /* FOR rsc_acc in NON_OVLY_role_access */

             end loop; /* FOR rsc in resource_grp */

          end loop;/* FOR tran_type in role_interest_nonpi */

          l_init_msg_list :=FND_API.G_TRUE;

          jtf_territory_resource_pvt.create_terrresource (
             p_api_version_number      => l_Api_Version_Number,
             p_init_msg_list           => l_Init_Msg_List,
             p_commit                  => l_Commit,
             p_validation_level        => fnd_api.g_valid_level_NONE,
             x_return_status           => x_Return_Status,
             x_msg_count               => x_Msg_Count,
             x_msg_data                => x_msg_data,
             p_terrrsc_tbl             => l_TerrRsc_tbl,
             p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
             x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
             x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
          );

          if x_Return_Status='S' then
             write_log(2,'Resource created for Geo territory # ' ||x_terr_id);
          else
             x_msg_data := substr(fnd_msg_pub.get(1, fnd_api.g_false),1,254);
             write_log(2,x_msg_data);
             write_log(2, '     Failed in resource creation for Geo territory # ' ||
                         x_terr_id);
          end if;

       else
          x_msg_data :=  substr(fnd_msg_pub.get(1, fnd_api.g_false),1,254);
          write_log(2,substr(x_msg_data,1,254));
          WRITE_LOG(2,'ERROR: NA TERRITORY CREATION FAILED ' ||
                'FOR NAMED_ACCOUNT_ID# ' );
       end if; /* END: Successful Territory creation? */
       end if;
     end loop;
	/*********************************************************************/
	/*********************************************************************/
        /************** OVERLAY TERRITORY CREATION ***************************/
	/*********************************************************************/
	/*********************************************************************/

        /* if any role with PI and Account access and no non pi role exist */
        /* we need to create a new branch with Named Account */
        /* OVERLAY BRANCH */

	BEGIN

           SELECT COUNT( DISTINCT b.role_code )
               into l_pi_count
           from jtf_rs_roles_vl r
              , jtf_tty_role_prod_int a
              , jtf_tty_terr_grp_roles b
           where r.role_code = b.role_code
             and a.terr_group_role_id = b.terr_group_role_id
             and b.terr_group_id      = p_terr_group_rec.TERR_GROUP_ID
                 AND EXISTS (
                               /* Named Account exists with Salesperson with this role */
                       SELECT NULL
                               FROM jtf_tty_geo_terr_rsc grsc, jtf_tty_geo_terr gterr
                               WHERE grsc.geo_territory_id = gterr.geo_territory_id
                                 AND gterr.terr_group_id = b.terr_group_id
                                 AND grsc.rsc_role_code = b.role_code )
                         AND ROWNUM < 2;

	  EXCEPTION
	   WHEN OTHERS THEN
	      NUll;
	END;


	/* are there overlay roles, i.e., are there roles with Product
	** Interests defined for this Territory Group */

        if l_pi_count > 0 then

           /***************************************************************/
           /* (7) START: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF */
	   /*    TERRITORY GROUP                                          */
           /***************************************************************/
           FOR topt in topterr(p_terr_group_rec.PARENT_TERR_ID) LOOP

              l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	      l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
	      l_terr_qual_tbl:=l_terr_qual_empty_tbl;
              l_terr_values_tbl:=l_terr_values_empty_tbl;
              l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

              l_terr_all_rec.TERR_ID := null;
 	      l_terr_all_rec.LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
 	      l_terr_all_rec.LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 	      l_terr_all_rec.CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 	      l_terr_all_rec.CREATED_BY := p_terr_group_rec.CREATED_BY ;
 	      l_terr_all_rec.LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;

 	      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
              l_terr_all_rec.NAME:= p_terr_group_rec.terr_group_name || ' (OVERLAY)';
 	      l_terr_all_rec.start_date_active := p_terr_group_rec.active_from_date ;
 	      l_terr_all_rec.end_date_active   := p_terr_group_rec.active_to_date;
 	      l_terr_all_rec.PARENT_TERRITORY_ID:=  topt.PARENT_TERRITORY_ID;
 	      l_terr_all_rec.RANK := topt.RANK;
 	      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 	      l_terr_all_rec.TEMPLATE_FLAG := 'N';
 	      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 	      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 	      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 	      l_terr_all_rec.DESCRIPTION:= topt.DESCRIPTION;
 	      l_terr_all_rec.UPDATE_FLAG :='N';
 	      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

 	      l_terr_all_rec.ORG_ID :=p_ORG_ID ;
 	      l_terr_all_rec.NUM_WINNERS :=l_pi_count ;

	      /* ORACLE SALES AND TELESALES USAGE */

    	      SELECT JTF_TERR_USGS_S.nextval
                into l_terr_usg_id
              FROM DUAL;

              l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
              l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
              l_terr_usgs_tbl(1).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
              l_terr_usgs_tbl(1).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 	      l_terr_usgs_tbl(1).CREATED_BY := p_terr_group_rec.CREATED_BY;
              l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=p_terr_group_rec.LAST_UPDATE_LOGIN;
              l_terr_usgs_tbl(1).TERR_ID:= null;
              l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
              l_terr_usgs_tbl(1).ORG_ID:= p_ORG_ID;


	      /* LEAD TRANSACTION TYPE */
              SELECT JTF_TERR_QTYPE_USGS_S.nextval
                into l_terr_qtype_usg_id
              FROM DUAL;

      	      l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   	      l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
   	      l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
   	      l_terr_qualtypeusgs_tbl(1).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(1).CREATED_BY := p_terr_group_rec.CREATED_BY;
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(1).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID:=-1002;
              l_terr_qualtypeusgs_tbl(1).ORG_ID:=p_ORG_ID;

	      /* OPPORTUNITY TRANSACTION TYPE */
	      SELECT JTF_TERR_QTYPE_USGS_S.nextval
       	        into l_terr_qtype_usg_id
              FROM DUAL;

              l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   	      l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
   	      l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
   	      l_terr_qualtypeusgs_tbl(2).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(2).CREATED_BY := p_terr_group_rec.CREATED_BY;
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(2).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID:=-1003;
 	      l_terr_qualtypeusgs_tbl(2).ORG_ID:=p_ORG_ID;


	      /*
	      ** get Top-Level Parent's Qualifier and values and
	      ** aad them to Overlay branch top-level territory
	      */

              j:=0;
	      k:=0;

              l_prev_qual_usg_id:=1;

              FOR csr_qual IN csr_get_qual ( topt.terr_id ) LOOP

                 j:=j+1;

        	 SELECT JTF_TERR_QUAL_S.nextval
        	   INTO l_terr_qual_id
        	 FROM DUAL;

                 l_terr_qual_tbl(j).TERR_QUAL_ID := l_terr_qual_id;
        	 l_terr_qual_tbl(j).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
 		 l_terr_qual_tbl(j).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 		 l_terr_qual_tbl(j).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		 l_terr_qual_tbl(j).CREATED_BY := p_terr_group_rec.CREATED_BY;
 		 l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
 		 l_terr_qual_tbl(j).TERR_ID:= null;

		 /* Top_level Parent's Qualifier */

	         l_terr_qual_tbl(j).QUAL_USG_ID := csr_qual.qual_usg_id;

 	         l_terr_qual_tbl(j).QUALIFIER_MODE:= NULL;
 	         l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='Y';
 	         l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 	         l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 	         l_terr_qual_tbl(j).ORG_ID:=p_ORG_ID;


		 FOR csr_qual_val IN csr_get_qual_val (csr_qual.terr_qual_id) LOOP

		    k:=k+1;

		    l_terr_values_tbl(k).TERR_VALUE_ID := NULL;
 	            l_terr_values_tbl(k).LAST_UPDATED_BY := G_USER_ID;
 	            l_terr_values_tbl(k).LAST_UPDATE_DATE:= G_SYSDATE;
 	            l_terr_values_tbl(k).CREATED_BY  := G_USER_ID;
 	            l_terr_values_tbl(k).CREATION_DATE:= G_SYSDATE;
 	            l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= G_LOGIN_ID;

 	            l_terr_values_tbl(k).TERR_QUAL_ID := l_terr_qual_id ;

 	            l_terr_values_tbl(k).INCLUDE_FLAG         := csr_qual_val.INCLUDE_FLAG;
 	            l_terr_values_tbl(k).COMPARISON_OPERATOR  := csr_qual_val.COMPARISON_OPERATOR;
 	            l_terr_values_tbl(k).LOW_VALUE_CHAR       := csr_qual_val.LOW_VALUE_CHAR;
 	            l_terr_values_tbl(k).HIGH_VALUE_CHAR      := csr_qual_val.HIGH_VALUE_CHAR;
 	            l_terr_values_tbl(k).LOW_VALUE_NUMBER     := csr_qual_val.LOW_VALUE_NUMBER;
 	            l_terr_values_tbl(k).HIGH_VALUE_NUMBER    := csr_qual_val.HIGH_VALUE_NUMBER;
 	            l_terr_values_tbl(k).VALUE_SET            := csr_qual_val.VALUE_SET;
 	            l_terr_values_tbl(k).INTEREST_TYPE_ID     := csr_qual_val.INTEREST_TYPE_ID;
 	            l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID   := csr_qual_val.PRIMARY_INTEREST_CODE_ID;
 	            l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID := csr_qual_val.SECONDARY_INTEREST_CODE_ID;
 	            l_terr_values_tbl(k).CURRENCY_CODE        := csr_qual_val.CURRENCY_CODE;
 	            l_terr_values_tbl(k).ID_USED_FLAG         := csr_qual_val.ID_USED_FLAG;
 	            l_terr_values_tbl(k).LOW_VALUE_CHAR_ID    := csr_qual_val.LOW_VALUE_CHAR_ID;

 	            l_terr_values_tbl(k).ORG_ID               := p_org_id;

   		    /* What Qualifier Values relate to Qualifier */
		    l_terr_values_tbl(k).qualifier_tbl_index := j;


		 END LOOP;	/* csr_qual_val IN csr_get_qual_val */

  	     end loop; /* csr_qual IN csr_get_qual */


             l_init_msg_list :=FND_API.G_TRUE;

             -- 07/08/03: JDOCHERT: bug#3023653
	     --mo_global.set_org_context(p_terr_group_rec.ORG_ID,null);
	     --

             jtf_territory_pvt.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => fnd_api.g_valid_level_NONE,
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


              if x_return_status = 'S' then

                 -- JDOCHERT: 01/08/03: Added p_terr_group_rec.ID
                 UPDATE JTF_TERR_ALL
                    set terr_group_FLAG = 'Y'
                      , terr_group_ID = p_terr_group_rec.TERR_GROUP_ID
                  where terr_id = x_terr_id;

              end if;

              l_overlay_top :=x_terr_id;

           end loop;/*  topt top level territory */

          /***************************************************************/
          /* (7) END: CREATE TOP-LEVEL TERRITORY FOR OVERLAY BRANCH OF   */
	  /*    TERRITORY GROUP                                          */
          /***************************************************************/


         /***************************************************************/
         /* (8) START: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP   */
         /*     USING DUNS# QUALIFIER                                   */
         /***************************************************************/

           FOR overlayterr in get_OVLY_geographies(p_terr_group_rec.terr_group_id) LOOP

              l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	      l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
     	      l_terr_qual_tbl:=l_terr_qual_empty_tbl;
              l_terr_values_tbl:=l_terr_values_empty_tbl;
              l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
              l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

              l_terr_all_rec.TERR_ID := null;
 	      l_terr_all_rec.LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
 	      l_terr_all_rec.LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 	      l_terr_all_rec.CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 	      l_terr_all_rec.CREATED_BY := p_terr_group_rec.CREATED_BY ;
 	      l_terr_all_rec.LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;

 	      l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;
 	      l_terr_all_rec.NAME:= overlayterr.geo_terr_name || ' (OVERLAY)';
 	      l_terr_all_rec.start_date_active := p_terr_group_rec.active_from_date ;
 	      l_terr_all_rec.end_date_active   := p_terr_group_rec.active_to_date;
 	      l_terr_all_rec.PARENT_TERRITORY_ID:=  l_overlay_top;
 	      l_terr_all_rec.RANK := p_terr_group_rec.RANK + 10;
 	      l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 	      l_terr_all_rec.TEMPLATE_FLAG := 'N';
 	      l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 	      l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 	      l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;
 	      l_terr_all_rec.DESCRIPTION:= overlayterr.geo_terr_name || ' (OVERLAY_DUNS#)';
 	      l_terr_all_rec.UPDATE_FLAG :='N';
 	      l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

     	      l_terr_all_rec.ORG_ID :=p_ORG_ID ;
 	      l_terr_all_rec.NUM_WINNERS :=null ;


 	      SELECT JTF_TERR_USGS_S.nextval
                into l_terr_usg_id
              FROM DUAL;

              l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
              l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
              l_terr_usgs_tbl(1).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
              l_terr_usgs_tbl(1).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 	      l_terr_usgs_tbl(1).CREATED_BY := p_terr_group_rec.CREATED_BY;
              l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=p_terr_group_rec.LAST_UPDATE_LOGIN;
              l_terr_usgs_tbl(1).TERR_ID:= null;
              l_terr_usgs_tbl(1).SOURCE_ID := -1001;
              l_terr_usgs_tbl(1).ORG_ID:= p_ORG_ID;

              SELECT   JTF_TERR_QTYPE_USGS_S.nextval
                into l_terr_qtype_usg_id
              FROM DUAL;

      	      l_terr_qualtypeusgs_tbl(1).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   	      l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
   	      l_terr_qualtypeusgs_tbl(1).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
   	      l_terr_qualtypeusgs_tbl(1).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(1).CREATED_BY := p_terr_group_rec.CREATED_BY;
              l_terr_qualtypeusgs_tbl(1).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(1).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(1).QUAL_TYPE_USG_ID:=-1002;
              l_terr_qualtypeusgs_tbl(1).ORG_ID:=p_ORG_ID;

              SELECT   JTF_TERR_QTYPE_USGS_S.nextval
       	        into l_terr_qtype_usg_id
              FROM DUAL;

   	      l_terr_qualtypeusgs_tbl(2).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   	      l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
   	      l_terr_qualtypeusgs_tbl(2).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
   	      l_terr_qualtypeusgs_tbl(2).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
              l_terr_qualtypeusgs_tbl(2).CREATED_BY := p_terr_group_rec.CREATED_BY;
              l_terr_qualtypeusgs_tbl(2).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
              l_terr_qualtypeusgs_tbl(2).TERR_ID:= null;
              l_terr_qualtypeusgs_tbl(2).QUAL_TYPE_USG_ID:=-1003;
 	      l_terr_qualtypeusgs_tbl(2).ORG_ID:=p_ORG_ID;

              SELECT JTF_TERR_QUAL_S.nextval
      	        into l_terr_qual_id
       	      FROM DUAL;

	      j:=0;
	      K:=0;
              l_prev_qual_usg_id:=1;

              FOR gval IN geo_values(overlayterr.geo_territory_id ) LOOP

      	         if l_prev_qual_usg_id <> gval.qual_usg_id then

                    j:=j+1;
        	    SELECT   JTF_TERR_QUAL_S.nextval
        	      into l_terr_qual_id
        	    FROM DUAL;

        	    l_terr_qual_tbl(j).TERR_QUAL_ID :=l_terr_qual_id;
        	    l_terr_qual_tbl(j).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
 		    l_terr_qual_tbl(j).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 		    l_terr_qual_tbl(j).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		    l_terr_qual_tbl(j).CREATED_BY := p_terr_group_rec.CREATED_BY;
 		    l_terr_qual_tbl(j).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
 		    l_terr_qual_tbl(j).TERR_ID:=null;
 		    l_terr_qual_tbl(j).QUAL_USG_ID :=gval.qual_usg_id;
 		    l_terr_qual_tbl(j).QUALIFIER_MODE:=NULL;
 		    l_terr_qual_tbl(j).OVERLAP_ALLOWED_FLAG:='N';
 		    l_terr_qual_tbl(j).USE_TO_NAME_FLAG:=NULL;
 		    l_terr_qual_tbl(j).GENERATE_FLAG:=NULL;
 		    l_terr_qual_tbl(j).ORG_ID:=p_ORG_ID;
		    l_prev_qual_usg_id:= gval.qual_usg_id;
	  	  end if;  /* l_prev_qual_usg_id */

   	     	  k:=k+1;

	          l_terr_values_tbl(k).TERR_VALUE_ID:=null;

           	  l_terr_values_tbl(k).LAST_UPDATED_BY := p_terr_group_rec.last_UPDATED_BY;
        	  l_terr_values_tbl(k).LAST_UPDATE_DATE:= p_terr_group_rec.last_UPDATE_DATE;
 	       	  l_terr_values_tbl(k).CREATED_BY  := p_terr_group_rec.CREATED_BY;
 	          l_terr_values_tbl(k).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
        	  l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= p_terr_group_rec.last_UPDATE_LOGIN;
 	          l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
        	  l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		  l_terr_values_tbl(k).COMPARISON_OPERATOR := gval.COMPARISON_OPERATOR;
         	  l_terr_values_tbl(k).LOW_VALUE_CHAR:= gval.value1_char;
 	          l_terr_values_tbl(k).HIGH_VALUE_CHAR:= NULL;
           	  l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 	          l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
           	  l_terr_values_tbl(k).VALUE_SET :=NULL;
        	  l_terr_values_tbl(k).INTEREST_TYPE_ID :=null;
 	          l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		  l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 	          l_terr_values_tbl(k).CURRENCY_CODE :=null;
 	          l_terr_values_tbl(k).ORG_ID :=p_ORG_ID;
         	  l_terr_values_tbl(k).ID_USED_FLAG :='N';
        	  l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

         	  l_terr_values_tbl(k).qualifier_tbl_index := j;

     	     end loop; /* gval */

             l_init_msg_list :=FND_API.G_TRUE;


             jtf_territory_pvt.create_territory (
                p_api_version_number         => l_api_version_number,
                p_init_msg_list              => l_init_msg_list,
                p_commit                     => l_commit,
                p_validation_level           => fnd_api.g_valid_level_NONE,
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


              if x_return_status = 'S' then


                 UPDATE JTF_TERR_ALL
                  set TERR_GROUP_FLAG = 'Y'
                    , TERR_GROUP_ID = p_terr_group_rec.TERR_GROUP_ID
                 where terr_id = x_terr_id;

                 l_overlay:=x_terr_id;

                 for pit in role_pi(p_terr_group_rec.terr_group_id, overlayterr.geo_territory_id) loop


                    l_terr_usgs_tbl:=l_terr_usgs_empty_tbl;
	            l_terr_qualtypeusgs_tbl:=l_terr_qualtypeusgs_empty_tbl;
	            l_terr_qual_tbl:=l_terr_qual_empty_tbl;
                    l_terr_values_tbl:=l_terr_values_empty_tbl;
                    l_TerrRsc_Tbl := l_TerrRsc_empty_Tbl;
                    l_TerrRsc_Access_Tbl := l_TerrRsc_Access_empty_Tbl;

		    l_role_counter := l_role_counter + 1;

                    l_terr_all_rec.TERR_ID := overlayterr.geo_territory_id * -30 * l_role_counter;
 		    l_terr_all_rec.LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
 		    l_terr_all_rec.LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 		    l_terr_all_rec.CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		    l_terr_all_rec.CREATED_BY := p_terr_group_rec.CREATED_BY ;
 		    l_terr_all_rec.LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;

 	  	    l_terr_all_rec.APPLICATION_SHORT_NAME:= G_APP_SHORT_NAME;

 		    l_terr_all_rec.NAME:= overlayterr.geo_terr_name || ': ' ||
			                      pit.role_name || ' (OVERLAY)';

 		    l_terr_all_rec.start_date_active := p_terr_group_rec.active_from_date ;
 		    l_terr_all_rec.end_date_active   := p_terr_group_rec.active_to_date;
 		    l_terr_all_rec.PARENT_TERRITORY_ID:= l_overlay;
 		    l_terr_all_rec.RANK := p_terr_group_rec.RANK+10;
 		    l_terr_all_rec.TEMPLATE_TERRITORY_ID:= NULL;
 		    l_terr_all_rec.TEMPLATE_FLAG := 'N';
 		    l_terr_all_rec.ESCALATION_TERRITORY_ID := NULL;
 		    l_terr_all_rec.ESCALATION_TERRITORY_FLAG := 'N';
 		    l_terr_all_rec.OVERLAP_ALLOWED_FLAG := NULL;

 		    l_terr_all_rec.DESCRIPTION:= overlayterr.geo_terr_name || ': ' ||
			                             pit.role_name || ' (OVERLAY DUNS#)';

 		    l_terr_all_rec.UPDATE_FLAG :='N';
 		    l_terr_all_rec.AUTO_ASSIGN_RESOURCES_FLAG :=NULL;

 		    l_terr_all_rec.ORG_ID :=p_ORG_ID ;
 		    l_terr_all_rec.NUM_WINNERS :=null ;

 		    SELECT   JTF_TERR_USGS_S.nextval
                      into l_terr_usg_id
                    FROM DUAL;

    	            l_terr_usgs_tbl(1).TERR_USG_ID := l_terr_usg_id;
                    l_terr_usgs_tbl(1).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
                    l_terr_usgs_tbl(1).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
                    l_terr_usgs_tbl(1).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		    l_terr_usgs_tbl(1).CREATED_BY := p_terr_group_rec.CREATED_BY;
                    l_terr_usgs_tbl(1).LAST_UPDATE_LOGIN:=p_terr_group_rec.LAST_UPDATE_LOGIN;
                    l_terr_usgs_tbl(1).TERR_ID:= null;
                    l_terr_usgs_tbl(1).SOURCE_ID:=-1001;
                    l_terr_usgs_tbl(1).ORG_ID:= p_ORG_ID;

                    i := 0;
                    K:= 0;

                    for acc_type in role_access(p_terr_group_rec.terr_group_id,pit.role_code) loop
                       --i:=i+1;
                       --dbms_output.put_line('acc type  '||acc_type.access_type);
                       if acc_type.access_type= 'OPPORTUNITY' then
                          i:=i+1;
                          SELECT   JTF_TERR_QTYPE_USGS_S.nextval
       	                    into l_terr_qtype_usg_id
                          FROM DUAL;

      		          l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		          l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
   		          l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
   		          l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
                          l_terr_qualtypeusgs_tbl(i).CREATED_BY := p_terr_group_rec.CREATED_BY;
                          l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
                          l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
                          l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1003;
 		          l_terr_qualtypeusgs_tbl(i).ORG_ID:=p_ORG_ID;

                          SELECT JTF_TERR_QUAL_S.nextval
      	                    into l_terr_qual_id
       	                  FROM DUAL;
                          /* opp expected purchase */

           	          l_terr_qual_tbl(i).TERR_QUAL_ID :=l_terr_qual_id;
            	          l_terr_qual_tbl(i).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
 	          	  l_terr_qual_tbl(i).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 	          	  l_terr_qual_tbl(i).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		          l_terr_qual_tbl(i).CREATED_BY := p_terr_group_rec.CREATED_BY;
 		          l_terr_qual_tbl(i).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
 		          l_terr_qual_tbl(i).TERR_ID:=null;
 		          l_terr_qual_tbl(i).QUAL_USG_ID :=-1023;
 		          l_terr_qual_tbl(i).QUALIFIER_MODE:=NULL;
 		          l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG:='N';
 		          l_terr_qual_tbl(i).USE_TO_NAME_FLAG:=NULL;
 		          l_terr_qual_tbl(i).GENERATE_FLAG:=NULL;
 		          l_terr_qual_tbl(i).ORG_ID:=p_ORG_ID;

                          for qval in role_pi_interest(p_terr_group_rec.terr_group_id,pit.role_code) loop

		              k:=k+1;
  		              l_terr_values_tbl(k).TERR_VALUE_ID:=null;

 		              l_terr_values_tbl(k).LAST_UPDATED_BY := p_terr_group_rec.last_UPDATED_BY;
 		              l_terr_values_tbl(k).LAST_UPDATE_DATE:= p_terr_group_rec.last_UPDATE_DATE;
 		              l_terr_values_tbl(k).CREATED_BY  := p_terr_group_rec.CREATED_BY;
 		              l_terr_values_tbl(k).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		              l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= p_terr_group_rec.last_UPDATE_LOGIN;
 		              l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
 		              l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
 		              l_terr_values_tbl(k).COMPARISON_OPERATOR :='=';
 		              l_terr_values_tbl(k).LOW_VALUE_CHAR:= null;
 		              l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
 		              l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
 		              l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
 		              l_terr_values_tbl(k).VALUE_SET :=NULL;
 		              l_terr_values_tbl(k).INTEREST_TYPE_ID :=qval.interest_type_id;
 		              l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
 		              l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
 		              l_terr_values_tbl(k).CURRENCY_CODE :=null;
 		              l_terr_values_tbl(k).ORG_ID :=p_ORG_ID;
 		              l_terr_values_tbl(k).ID_USED_FLAG :='N';
 		              l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;

 		              l_terr_values_tbl(k).qualifier_tbl_index := i;

  		           end loop;   /* qval */

                        elsif acc_type.access_type= 'LEAD' then

                           i:=i+1;
                           SELECT   JTF_TERR_QTYPE_USGS_S.nextval
                             into l_terr_qtype_usg_id
                             FROM DUAL;

        		   l_terr_qualtypeusgs_tbl(i).TERR_QUAL_TYPE_USG_ID:= l_terr_qtype_usg_id;
   		           l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE;
   		           l_terr_qualtypeusgs_tbl(i).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
   		           l_terr_qualtypeusgs_tbl(i).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
                           l_terr_qualtypeusgs_tbl(i).CREATED_BY := p_terr_group_rec.CREATED_BY;
                           l_terr_qualtypeusgs_tbl(i).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
                           l_terr_qualtypeusgs_tbl(i).TERR_ID:= null;
                           l_terr_qualtypeusgs_tbl(i).QUAL_TYPE_USG_ID:=-1002;
                           l_terr_qualtypeusgs_tbl(i).ORG_ID:=p_ORG_ID;

                           SELECT   JTF_TERR_QUAL_S.nextval
      	                     into l_terr_qual_id
       	                   FROM DUAL;

                           /* lead expected purchase */
       	                   l_terr_qual_tbl(i).TERR_QUAL_ID :=l_terr_qual_id;
       	                   l_terr_qual_tbl(i).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
 		           l_terr_qual_tbl(i).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
 		           l_terr_qual_tbl(i).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
 		           l_terr_qual_tbl(i).CREATED_BY := p_terr_group_rec.CREATED_BY;
 		           l_terr_qual_tbl(i).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
 		           l_terr_qual_tbl(i).TERR_ID:=null;
 		           l_terr_qual_tbl(i).QUAL_USG_ID :=-1018;
 		           l_terr_qual_tbl(i).QUALIFIER_MODE:=NULL;
 		           l_terr_qual_tbl(i).OVERLAP_ALLOWED_FLAG:='N';
 		           l_terr_qual_tbl(i).USE_TO_NAME_FLAG:=NULL;
 		           l_terr_qual_tbl(i).GENERATE_FLAG:=NULL;
 		           l_terr_qual_tbl(i).ORG_ID:=p_ORG_ID;

                           for qval in role_pi_interest(p_terr_group_rec.terr_group_id,pit.role_code) loop

                              k:=k+1;

            		      l_terr_values_tbl(k).TERR_VALUE_ID:=null;

                  	      l_terr_values_tbl(k).LAST_UPDATED_BY := p_terr_group_rec.last_UPDATED_BY;
              		      l_terr_values_tbl(k).LAST_UPDATE_DATE:= p_terr_group_rec.last_UPDATE_DATE;
             		      l_terr_values_tbl(k).CREATED_BY  := p_terr_group_rec.CREATED_BY;
             		      l_terr_values_tbl(k).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
             		      l_terr_values_tbl(k).LAST_UPDATE_LOGIN:= p_terr_group_rec.last_UPDATE_LOGIN;
             		      l_terr_values_tbl(k).TERR_QUAL_ID :=l_terr_qual_id ;
             		      l_terr_values_tbl(k).INCLUDE_FLAG :=NULL;
             		      l_terr_values_tbl(k).COMPARISON_OPERATOR :='=';
             		      l_terr_values_tbl(k).LOW_VALUE_CHAR:= null;
             		      l_terr_values_tbl(k).HIGH_VALUE_CHAR:=null;
             		      l_terr_values_tbl(k).LOW_VALUE_NUMBER :=null;
             		      l_terr_values_tbl(k).HIGH_VALUE_NUMBER :=null;
             		      l_terr_values_tbl(k).VALUE_SET :=NULL;
             		      l_terr_values_tbl(k).INTEREST_TYPE_ID := qval.interest_type_id;
             		      l_terr_values_tbl(k).PRIMARY_INTEREST_CODE_ID:=null;
             		      l_terr_values_tbl(k).SECONDARY_INTEREST_CODE_ID:=null;
             		      l_terr_values_tbl(k).CURRENCY_CODE :=null;
             		      l_terr_values_tbl(k).ORG_ID :=p_ORG_ID;
             		      l_terr_values_tbl(k).ID_USED_FLAG :='N';
             		      l_terr_values_tbl(k).LOW_VALUE_CHAR_ID  :=null;


             		      l_terr_values_tbl(k).qualifier_tbl_index := i;

		           end loop; /* qval */

                        else
                           write_log(2,' OVERLAY and NON_OVERLAY role exist for '||p_terr_group_rec.terr_group_id);
                           --l_terr_qualtypeusgs_tbl(1).ORG_ID:=p_ORG_ID;
                        end if;

                 end loop; /* acc_type */

                 l_init_msg_list :=FND_API.G_TRUE;

                 jtf_territory_pvt.create_territory (
                   p_api_version_number         => l_api_version_number,
                   p_init_msg_list              => l_init_msg_list,
                   p_commit                     => l_commit,
                   p_validation_level           => fnd_api.g_valid_level_NONE,
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

                 if (x_return_status = 'S')  then

                 UPDATE JTF_TERR_ALL
                  set TERR_GROUP_FLAG = 'Y'
                    , TERR_GROUP_ID = p_terr_group_rec.TERR_GROUP_ID
                     where terr_id = x_terr_id;


                     write_log(2,' OVERLAY PI Territory Created = '||l_terr_all_rec.NAME);

                 else
                     x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
                     write_log(2,x_msg_data);
                     write_log(2, 'Failed in OVERLAY PI Territory Creation for p_terr_group_rec.ACCOUNT_ID#');

    	         end if;  /* x_return_status */


                 --dbms_output.put_line('pit.role '||pit.role_code);
                 i:=0;

             FOR rsc in terr_resource(overlayterr.geo_territory_id, pit.role_code)
             loop

                 i:=i+1;

                 SELECT JTF_TERR_RSC_S.nextval
                   into l_terr_rsc_id
               	   FROM DUAL;

                 l_TerrRsc_Tbl(i).terr_id := x_terr_id;
                 l_TerrRsc_Tbl(i).TERR_RSC_ID :=l_terr_rsc_id;
                 l_TerrRsc_Tbl(i).LAST_UPDATE_DATE:=p_terr_group_rec.LAST_UPDATE_DATE;
                 l_TerrRsc_Tbl(i).LAST_UPDATED_BY:=p_terr_group_rec.LAST_UPDATED_BY;
                 l_TerrRsc_Tbl(i).CREATION_DATE:=p_terr_group_rec.CREATION_DATE;
         	 l_TerrRsc_Tbl(i).CREATED_BY:=p_terr_group_rec.CREATED_BY;
         	 l_TerrRsc_Tbl(i).LAST_UPDATE_LOGIN:=p_terr_group_rec.LAST_UPDATE_LOGIN;
         	 --l_TerrRsc_Tbl(i).TERR_ID:=p_terr_group_rec.TERRITORY_ID;
         	 l_TerrRsc_Tbl(i).RESOURCE_ID:=rsc.resource_id;
         	 l_TerrRsc_Tbl(i).RESOURCE_TYPE:=rsc.rsc_resource_type;
         	 l_TerrRsc_Tbl(i).ROLE:=pit.role_code;
                 --l_TerrRsc_Tbl(i).ROLE:=l_role;
         	 l_TerrRsc_Tbl(i).PRIMARY_CONTACT_FLAG:='N';
         	 l_TerrRsc_Tbl(i).START_DATE_ACTIVE:=p_terr_group_rec.active_from_date ;
         	 l_TerrRsc_Tbl(i).END_DATE_ACTIVE:=p_terr_group_rec.active_to_date ;
         	 l_TerrRsc_Tbl(i).ORG_ID:=p_ORG_ID;
         	 l_TerrRsc_Tbl(i).FULL_ACCESS_FLAG:='Y';
         	 l_TerrRsc_Tbl(i).GROUP_ID:=rsc.rsc_group_id;



                 a := 0;

                 for rsc_acc in role_access(p_terr_group_rec.terr_group_id,pit.role_code) loop

		     if rsc_acc.access_type= 'OPPORTUNITY' then

			        a := a+1;

                                SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	           into l_terr_rsc_access_id
                                FROM DUAL;

                    	        l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                            	l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
                            	l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
                            	l_TerrRsc_Access_Tbl(a).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
             	        	l_TerrRsc_Access_Tbl(a).CREATED_BY := p_terr_group_rec.CREATED_BY;
             	        	l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'OPPOR';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= p_ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;

                        elsif rsc_acc.access_type= 'LEAD' then

			        a := a+1;

                                SELECT   JTF_TERR_RSC_ACCESS_S.nextval
                    	           into l_terr_rsc_access_id
                                FROM DUAL;

                    		l_TerrRsc_Access_Tbl(a).TERR_RSC_ACCESS_ID:= l_terr_rsc_access_id;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATE_DATE:= p_terr_group_rec.LAST_UPDATE_DATE ;
                    		l_TerrRsc_Access_Tbl(a).LAST_UPDATED_BY:= p_terr_group_rec.LAST_UPDATED_BY;
                    		l_TerrRsc_Access_Tbl(a).CREATION_DATE:= p_terr_group_rec.CREATION_DATE;
             		        l_TerrRsc_Access_Tbl(a).CREATED_BY := p_terr_group_rec.CREATED_BY;
             		        l_TerrRsc_Access_Tbl(a).LAST_UPDATE_LOGIN:= p_terr_group_rec.LAST_UPDATE_LOGIN;
             		        l_TerrRsc_Access_Tbl(a).TERR_RSC_ID:= l_terr_rsc_id ;
             		        l_TerrRsc_Access_Tbl(a).ACCESS_TYPE:= 'LEAD';
             		        l_TerrRsc_Access_Tbl(a).ORG_ID:= p_ORG_ID;
             		        l_TerrRsc_Access_Tbl(a).qualifier_tbl_index:= i;
                     end if;

                    end loop; /* rsc_acc in role_access */

                 end loop; /* rsc in resource_grp */

                    l_init_msg_list :=FND_API.G_TRUE;

                    jtf_territory_resource_pvt.create_terrresource (
                       p_api_version_number      => l_Api_Version_Number,
                       p_init_msg_list           => l_Init_Msg_List,
                       p_commit                  => l_Commit,
                       p_validation_level        => fnd_api.g_valid_level_NONE,
                       x_return_status           => x_Return_Status,
                       x_msg_count               => x_Msg_Count,
                       x_msg_data                => x_msg_data,
                       p_terrrsc_tbl             => l_TerrRsc_tbl,
                       p_terrrsc_access_tbl      => l_terrRsc_access_tbl,
                       x_terrrsc_out_tbl         => x_TerrRsc_Out_Tbl,
                       x_terrrsc_access_out_tbl  => x_TerrRsc_Access_Out_Tbl
                    );

                    if x_Return_Status='S' then
                       write_log(2,'Resource created for Product Interest OVERLAY Territory '||
                                                       l_terr_all_rec.NAME);
                    else
                       write_log(2,'Failed in Resource creation for Product Interest OVERLAY Territory# '||
					               x_terr_id);
                       write_log(2,'Message_data '|| x_msg_data);
                    end if;



              end loop;  /* pit */

           else
              x_msg_data :=  fnd_msg_pub.get(1, fnd_api.g_false);
              write_log(2,x_msg_data);
              write_log(2,'Failed in OVERLAY Territory Creation for Territory Group: ' ||
                  p_terr_group_rec.terr_group_id || ' : ' ||
                  p_terr_group_rec.terr_group_name );
           end if; /* if (x_return_status = 'S' */

         end loop; /* overlayterr in get_OVLY_geographies */
	 /***************************************************************/
         /* (8) END: CREATE OVERLAY TERRITORIES FOR TERRITORY GROUP     */
	 /*     USING DUNS# QUALIFIER                                   */
         /***************************************************************/


     end if; /* l_pi_count*/


  EXCEPTION
   when FND_API.G_EXC_ERROR then
     -- JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log (' Error in Synchronizing the SUMM table' || SQLERRM );
     RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     -- JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log (' Error in Synchronizing the SUMM table' || SQLERRM );
     RETURN;
   when others then
    -- JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log (' Error in Synchronizing the SUMM table' || SQLERRM );
     RETURN;

END create_geography_territory;


END JTF_TTY_NA_GEO_TERR_PVT;

/
