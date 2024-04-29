--------------------------------------------------------
--  DDL for Package Body JTF_TERR_ENGINE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_ENGINE_GEN_PVT" AS
/* $Header: jtfvtegb.pls 120.3.12010000.2 2008/11/27 07:00:43 gmarwah ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_ENGINE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This packe is used to generate the complete territory
--      Engine based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      01/27/00    VNEDUNGA         Created
--      02/24/00    VNEDUNGA         A New beginnig
--      03/20/00    VNEDUNGA         Replace ' in a char value to ''
--                                   Changing the add_terr_pkgspec to
--                                   a pointer to track pl/sql table
--                                   index
--      04/10/00    VNEDUNGA         Adding special processing for
--                                   qualifers that have master detail
--                                   relationship
--      04/14/00    VNEDUNGA         Changing the code to use the meta data
--                                   for special processing
--      05/01/00    VNEDUNGA         Adding currency convertion routine
--                                   for Currency Type Qualifier
--      05/17/00    VNEDUNGA         Fixed code in get_expression_char function
--                                   to eliminate extar space in the value
--                                   eg: '94089 '
--      07/05/00    jdochert         Removed hard-coded reference to APPS (Bug#1343904)
--                                   Added call to fnd_installation.get_app_info instead
--
--      09/17/00    JDOCHERT         BUG#1408610 FIX
--
--      04/24/03    JRADHAKR         BUG#2925153 FIX
--
--      05/28/03    JDOCHERT         DUNS# QUALIFIER SUPPORT
--
--      03/08/04    ACHANDA          BUG#3380047, 3378530 FIX
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

          --Delete Territory Qualifer records
          DELETE from JTF_TERR_QUAL_ALL jtq
		  WHERE jtq.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory qual type usgs
          DELETE from JTF_TERR_QTYPE_USGS_ALL jtqu
		  WHERE jtqu.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory usgs
          DELETE from JTF_TERR_USGS_ALL	jtu
		  WHERE jtu.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory Resource Access
          DELETE from JTF_TERR_RSC_ACCESS_ALL jtra
          WHERE jtra.terr_rsc_id IN
          ( SELECT jtr.terr_rsc_id
		    FROM jtf_terr_rsc_all jtr, jtf_terr_all jt
			WHERE jtr.terr_id = jt.terr_id
			  AND jt.terr_group_flag = 'Y' );


          -- Delete the Territory Resource records
          DELETE from JTF_TERR_RSC_ALL	jtr
		  WHERE jtr.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );


          --Delete Territory record
          DELETE from JTF_TERR_ALL jt
		  WHERE jt.terr_id IN
          ( SELECT jt.terr_id
		    FROM jtf_terr_all jt
			WHERE jt.terr_group_flag = 'Y' );


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

    l_terrqual_tbl		        terrqual_tbl_type;
    l_terrqual_empty_tbl		terrqual_tbl_type;

    l_overnon_role_tbl		    grp_role_tbl_type;
    l_overnon_role_empty_tbl    grp_role_tbl_type;

    l_terr_qual_id		NUMBER;
    l_id_used_flag		VARCHAR2(1);
    l_low_value_char_id	NUMBER;
    l_qual_usgs_id 	    NUMBER;
    l_terr_usg_id	    NUMBER;
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
           , B.ORG_ID
    FROM 	JTF_TTY_TERR_GROUPS A
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



      /* does Territory Group have at least 1 Named Account? */
      SELECT COUNT(*)
        INTO l_na_count
      from jtf_tty_terr_groups g
         , jtf_tty_terr_grp_accts ga
         , jtf_tty_named_accts a
      where g.terr_group_id     = ga.terr_group_id
        AND ga.named_account_id = a.named_account_id
        AND g.terr_group_id     = TERR_GROUP.TERR_GROUP_ID
        AND ROWNUM < 2;



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

    	   write_log(2,' NAMED ACCOUNT CATCH ALL TERRITORY CREATED: TERR_ID# '||x_terr_id);

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
                     write_log(2, x_msg_data);
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

              write_log(2,'  NA territory created = '||naterr.name);


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

                --write_log(2,'na '||naterr.named_account_id);
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

              write_log(2,'  NA territory created = '||naterr.name);


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


        end if;
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

     	      write_log(2,' OVERLAY Top level Territory Created,territory_id# '||x_terr_id);

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

              write_log(2,' Named Account OVERLAY territory created: '||l_terr_all_rec.NAME);


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



PROCEDURE generate_api (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      p_source_id           IN       NUMBER,
      p_qualifier_type_id   IN       NUMBER,
	  --p_mode                IN       VARCHAR2,
      p_record_limit        IN       NUMBER DEFAULT 100,
      p_debug_flag          IN       VARCHAR2,
      p_sql_trace           IN       VARCHAR2
   )
   AS

    --
    -- 05/01/01 JDOCHERT: PART OF BUG#1714243 bug FIX
    --
    CURSOR csr_get_terr ( lp_source_id     NUMBER
                        , lp_qual_type_id  NUMBER
                        , lp_sysdate       DATE ) IS
      SELECT 'TRUE'
      FROM    jtf_terr_qtype_usgs_all jtqu
            , jtf_terr_usgs_all jtu
            , jtf_terr_all jt1
            , jtf_qual_type_usgs jqtu
      WHERE jtqu.terr_id = jt1.terr_id
        AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
        AND jqtu.qual_type_id = lp_qual_type_id
        AND jtu.source_id = lp_source_id
        AND jtu.terr_id = jt1.terr_id
        AND NVL(jt1.end_date_active, lp_sysdate) >= lp_sysdate
        AND jt1.start_date_active <= lp_sysdate
        AND EXISTS (
            SELECT jtrs.terr_rsc_id
            FROM jtf_terr_rsc_all jtrs
            WHERE NVL(jtrs.end_date_active, lp_sysdate) >= lp_sysdate
              AND NVL(jtrs.start_date_active, lp_sysdate) <= lp_sysdate
              AND jtrs.terr_id = jt1.terr_id )
        AND NOT EXISTS (
          SELECT jt.terr_id
          FROM jtf_terr_all jt
          WHERE  NVL(jt.end_date_active, lp_sysdate + 1) < lp_sysdate
          CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
          START WITH jt.terr_id = jt1.terr_id)
        AND jqtu.qual_type_id <> -1001
        AND jtu.source_id <> -1003
        AND rownum < 2;

     /* all the possible winning territories
     ** in the system
     */
     CURSOR csr_get_denorm_terr ( lp_source_id  NUMBER
                                , lp_qual_type_id NUMBER) IS
       SELECT  jtdr.terr_id
       FROM    jtf_terr_denorm_rules_all jtdr
       WHERE jtdr.terr_id = jtdr.related_terr_id
         AND jtdr.source_id = lp_source_id
         AND jtdr.qual_type_id = lp_qual_type_id;

	/* ARPATEL: 12/08/2003 Cursor used to update num_qual in jtf_terr_qtype_usgs_all for Oracle Sales  */
	CURSOR csr_get_terr_num_qual ( lp_source_id       NUMBER
                                     , lp_qual_type_id    NUMBER ) IS
        SELECT jtqu.terr_id
             , jtqu.terr_qtype_usg_id
          FROM jtf_terr_qtype_usgs_all jtqu
             , jtf_terr_denorm_rules_all jtdr
             , jtf_qual_type_usgs jqtu
         WHERE jqtu.qual_type_id = LP_qual_type_id
           AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
           AND jtqu.terr_id = jtdr.terr_id
           AND jtdr.resource_exists_flag = 'Y'
           AND jtdr.terr_id = jtdr.related_terr_id
           AND jtdr.source_id = LP_source_id;

      CURSOR csr_get_RSC_denorm_terr ( lp_source_id  NUMBER
                                , lp_qual_type_id NUMBER) IS
       SELECT  jtdr.terr_id
       FROM    jtf_terr_denorm_rules_all jtdr
       WHERE jtdr.terr_id = jtdr.related_terr_id
         AND jtdr.source_id = lp_source_id
         AND jtdr.qual_type_id = lp_qual_type_id
	 AND jtdr.resource_exists_flag = 'Y';

      /* ARPATEL: 12/03/2003: Oracle Sales only has one record per territory in terr_denorm_rules_all (no longer strpied by TX type) */
      CURSOR csr_get_SALES_denorm_terr ( lp_source_id  NUMBER ) IS
       SELECT  jtdr.terr_id
       FROM    jtf_terr_denorm_rules_all jtdr
       WHERE jtdr.terr_id = jtdr.related_terr_id
         AND jtdr.source_id = lp_source_id;

      CURSOR csr_get_transactions(lp_source_id NUMBER) IS
        SELECT jqt.qual_type_id
        FROM jtf_qual_type_usgs jqtu, jtf_qual_types jqt
        WHERE jqtu.qual_type_id = jqt.qual_type_id
          AND jqt.qual_type_id <> -1001
          AND jqtu.source_id = lp_source_id;

      dummy                         NUMBER(15);
      x_terr_count                  NUMBER(15);
      x_package_max                 NUMBER(15);
      x_package_count               NUMBER(15);
      package_name                  VARCHAR2(30);
      package_desc                  VARCHAR2(100);
      l_index                       NUMBER;
      l_terr_id                     NUMBER;

      l_status                      VARCHAR(10);

      lp_qual_type_id               NUMBER;

      l_mv1_count                   NUMBER;
      l_mv2_count                   NUMBER;
      l_mv3_count                   NUMBER;
      l_mv4_count                   NUMBER;
      l_mv5_count                   NUMBER;
      l_mv6_count                   NUMBER;

      l_denorm_count                NUMBER;

   BEGIN
      -- Initialize Global variables
      g_terr_pkgspec.DELETE;
      g_pkgname_tbl.Delete;
      g_Pointer  := 0;
      G_Debug    := FALSE;
      g_stack_pointer := 0;
      g_source_id := p_source_id;
      g_abs_source_id := ABS(p_source_id);
      g_qual_type_id := p_qualifier_type_id;

      --g_cached_org_append := '_' || fnd_profile.value('ORG_ID');

      -- Initialize
      --SELECT name g_qualifier_type
      --  INTO g_qualifier_type
      --  FROM jtf_qual_types
      -- WHERE qual_type_id = p_qualifier_type_id;

      --
      --If the SQL trace flag is turned on, then turm on the trace
      /* ARPATEL: 12/15/2003 Bug#3305019 */
      --If upper(p_SQL_Trace) = 'Y' Then
      --   dbms_session.set_sql_trace(TRUE);
      --Else
      --   dbms_session.set_sql_trace(FALSE);
      --End If;

      -- If the debug flag is set, Then turn on the debug message logging
      If upper( rtrim(p_Debug_Flag) ) = 'Y' Then
         G_Debug := TRUE;
      End If;

      If G_Debug Then
         Write_Log(2, 'Inside Generate_API initialize');
         Write_Log(2, 'source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, 'qualifier_type_id - ' || TO_CHAR(p_qualifier_type_id) );
      End If;

      -- 01/15/03: JDOCHERT:
      -- Only for Oracle Sales and Telesales
      /* ACHANDA : Commented out as the territory creation is removed to the package JTF_TTY_GEN_TERR_PVT */
      /*
      IF (p_source_id = -1001) THEN

              -- 12/31/02 sbehera added call to
              -- generate territory for NA and OVERLAY
              If G_Debug Then
                 Write_Log(2, 'START: generate_named_overlay_terr');
              End If;

	       --
               -- 1159NA: Territory Creation
               --ARPATEL 09/16 1159 branch fix: removed ref to JTF_TTY_NA_GEO_TERR_PVT
               -- ACHANDA : Bug # 3233322 : the following line is commented out as the territory
               -- creation is removed to a package JTF_TTY_GEN_TERR_PVT
               --generate_named_overlay_terr(p_mode => 'TOTAL');
	       --

              If G_Debug Then
                 Write_Log(2, 'END: generate_named_overlay_terr');
              End If;

      END IF;
      */

      -- 1159: Transaction Type is optional: GTP will
      -- run for all the valid transaction types for a Usage
      IF ( p_source_id IS NOT NULL AND p_qualifier_type_id IS NULL ) THEN

          --ARPATEL: 12/03/2003 call denorm package only once for Oracle Sales.
          IF (p_source_id = -1001) THEN

               --dbms_output.put_line('GEN: B4 JTF_TERR_DENORM_RULES_PVT.Populate_API');
               JTF_TERR_DENORM_RULES_PVT.Populate_API( P_ERROR_CODE => retcode
                                                        , P_ERROR_MSG => errbuf
                                                        , P_SOURCE_ID => p_source_id
                                                        , p_qual_type_id => lp_qual_type_id );
               --dbms_output.put_line('AFTER: B4 JTF_TERR_DENORM_RULES_PVT.Populate_API');


               /* populate resource_exists_flag and absolute rank for Oracle Sales */
	       UPDATE jtf_terr_denorm_rules_all j
               SET j.resource_exists_flag = 'Y'
               WHERE EXISTS
                     ( SELECT jtr.terr_id
                       FROM jtf_terr_rsc_all jtr
                       WHERE (jtr.end_date_active IS NULL OR jtr.end_date_active >= SYSDATE)
                       AND (jtr.start_date_active IS NULL OR jtr.start_date_active <= SYSDATE)
                       AND jtr.terr_id = j.terr_id
                     )
                  AND j.terr_id = j.related_terr_id
                  AND j.source_id = p_source_id;


               --dbms_output.put_line('UPDATE jtf_terr_denorm_rules_all, SET jtdr.resource_exists_flag  ');
               FOR csr_dnm IN csr_get_SALES_denorm_terr( p_source_id ) LOOP

	          UPDATE  jtf_terr_denorm_rules_all jtdr
                  SET jtdr.ABSOLUTE_RANK = (
                              SELECT SUM(jt1.relative_rank)
                              FROM jtf_terr_denorm_rules_all jt1
                              WHERE jt1.related_terr_id = jt1.terr_id

                                /* JDOCHERT: 12/09/03: records in JTF_TERR_DENORM_RULES_ALL
				** are no longer striped by QUAL_TYPE_ID, so commenting out the
				** the following lines
				*/
				--ARPATEL: 11/12/03 Bug#3254575 */
                                --AND jt1.qual_type_id = lp_qual_type_id
				--
				--

                                AND jt1.terr_id IN
                              ( SELECT jt.terr_id
                                FROM jtf_terr_all jt
                                CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                                 START WITH jt.terr_id = csr_dnm.terr_id )
                          )
                   WHERE jtdr.source_id = p_source_id

                     --
                     -- JDOCHERT: 10/25/03: Following line was commented out
                     -- as real-time APIs depend on ABSOLUTE_RANK being set for
                     -- them to return results correctly
                     --
                     --AND jtdr.related_terr_id = jtdr.terr_id
                     --

                     AND jtdr.terr_id = CSR_DNM.terr_id;

               END LOOP;

               --dbms_output.put_line('GEN: AFTER: UPDATE jtf_terr_denorm_rules_all, SET jtdr.resource_exists_flag  ');

          END IF;


          OPEN csr_get_transactions (p_source_id);
          LOOP
             FETCH csr_get_transactions INTO lp_qual_type_id;
             EXIT WHEN csr_get_transactions%NOTFOUND;

                 --dbms_output.put_line('Value of lp_qual_type_id='||TO_CHAR(lp_qual_type_id));

                  -- Oracle Sales => new architecture
                  /* JTF_TERR_<SOURCE_ID>_<TRANS>_DYN API architecture */
		  --
                  JTF_TERR_ENGINE_GEN2_PVT.Generate_API(
                                            ERRBUF  => errbuf,
                                            RETCODE => retcode,
                                            p_Source_Id => p_source_id, --Source Name
                                            p_qualifier_type_id => lp_qual_type_id,
                                            p_Debug_Flag  => p_debug_flag,
                                            p_SQL_Trace   => p_sql_trace  );

                  /* ACHANDA 03/08/2004 : Bug 3380047 : Program should terminate with error */
                  /* if one of the dynamically created packages are in invalid status       */
                  If (RETCODE = 2) Then
                    g_ProgramStatus := 2;
                  End If;

                  --dbms_output.put_line(' ');
                  --dbms_output.put_line('Calling denorm API for ' || p_source_id ||
                  --'/' || p_qualifier_type_id);
                  --dbms_output.put_line(' ');


                  /* build denormalised territory hierarchy table */
		  -- ARPATEL: 12/03/2003
		  -- Only process denorm records for each transaction type
		  -- IF THE USAGE IS NOT ORACLE SALES
		  --
                  IF ( p_source_id <> -1001 ) THEN

                     JTF_TERR_DENORM_RULES_PVT.Populate_API( P_ERROR_CODE => retcode
                                                           , P_ERROR_MSG => errbuf
                                                           , P_SOURCE_ID => p_source_id
                                                           , p_qual_type_id => lp_qual_type_id );

                     /* Setting resource_exists flag */
                     BEGIN

                       /* get all territories that have resources attached */
                         UPDATE jtf_terr_denorm_rules_all j
                            SET j.resource_exists_flag = 'Y'
                          WHERE EXISTS
                             ( SELECT jtr.terr_id
                               FROM jtf_terr_rsc_all jtr
                               WHERE (jtr.end_date_active IS NULL OR jtr.end_date_active >= SYSDATE)
                                 AND (jtr.start_date_active IS NULL OR jtr.start_date_active <= SYSDATE)
                                 AND jtr.terr_id = j.terr_id
                             )
                           AND j.terr_id = j.related_terr_id
              	  	   AND j.source_id = p_source_id
                           AND j.qual_type_id = lp_qual_type_id;


                     EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                     END;


                     /* Setting Absolute Rank */
                     BEGIN

                       FOR csr_dnm IN csr_get_denorm_terr( p_source_id
                                                     , lp_qual_type_id) LOOP

                          UPDATE  jtf_terr_denorm_rules_all jtdr
                          SET jtdr.ABSOLUTE_RANK = (
                              SELECT SUM(jt1.relative_rank)
                              FROM jtf_terr_denorm_rules_all jt1
                              WHERE jt1.related_terr_id = jt1.terr_id

                                /* ARPATEL: 11/12/03 Bug#3254575 */
                                AND jt1.qual_type_id = lp_qual_type_id

                                AND jt1.terr_id IN
                              ( SELECT jt.terr_id
                                FROM jtf_terr_all jt
                                CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                                 START WITH jt.terr_id = csr_dnm.terr_id )
                          )
                          WHERE jtdr.source_id = p_source_id
                            AND jtdr.qual_type_id = lp_qual_type_id

                            --
                            -- JDOCHERT: 10/25/03: Following line was commented out
                            -- as real-time APIs depend on ABSOLUTE_RANK being set for
                            -- to return results correctly
                            --
                            --AND jtdr.related_terr_id = jtdr.terr_id
                            --

                            AND jtdr.terr_id = CSR_DNM.terr_id;

                       END LOOP;


                     EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                     END;

		  END IF; --p_source_id <> -1001


		  /* ONLY FOR ORACLE SALES */
                  IF ( p_source_id = -1001 ) THEN

	             If G_Debug Then
                        Write_Log(2, 'START: UPDATE jtf_terr_qtype_usgs_all ');
                     End If;

                     /* ACHANDA 02/03/04 Bug 3373687 : disable the trigger before update */
                     BEGIN
                       EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
                     EXCEPTION
                       WHEN OTHERS THEN
                         NULL;
                     END;

                     /* ARPATEL: 12/03/2003 populate
	             ** jtf_terr_qtype_usgs_all.num_qual column ONLY
	             ** for Oracle Sales (-1001) */
                     FOR csr_dnm IN csr_get_terr_num_qual( p_source_id
                                                     , lp_qual_type_id) LOOP

                        --dbms_output.put_line('GEN: UPDATE jtf_terr_qtype_usgs_all '||lp_qual_type_id);

                        UPDATE jtf_terr_qtype_usgs_all qua
                        SET qua.num_qual = (
			                SELECT COUNT(*)
                                        FROM jtf_terr_qual_all jtq
                                           , jtf_qual_usgs_all jqu
                                           , jtf_qual_type_usgs jqtu
                                           , jtf_qual_type_denorm_v v
                                        WHERE jtq.qual_usg_id = jqu.qual_usg_id
                                          /* ACHANDA 03/08/2004 : Bug 3378530 : change the where clause to use index more selectively */
                                          AND jqu.org_id = -3113
                                          /*
                                          AND ( (jtq.org_id = jqu.org_id) OR
                                                (jtq.org_id IS NULL AND jqu.org_ID IS NULL)
                                              )
                                          */
                                          AND jqu.qual_type_usg_id = jqtu.qual_type_usg_id
                                          AND jqtu.qual_type_id <> -1001
                                          AND jqtu.source_id = p_source_id
                                          AND jqtu.qual_type_id = v.related_id
                                          AND v.qual_type_id = lp_qual_type_id
                                          AND jtq.terr_id IN
                                        ( SELECT jt.terr_id
                                          FROM jtf_terr_all jt
                                          CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                                           START WITH jt.terr_id = csr_dnm.terr_id )
                                         )
                        WHERE qua.terr_qtype_usg_id = csr_dnm.terr_qtype_usg_id;

                     --dbms_output.put_line('AFTER: GEN: UPDATE jtf_terr_qtype_usgs_all '||lp_qual_type_id);

	             END LOOP;

                     /* ACHANDA 02/03/04 Bug 3373687 : enable the trigger after update */
                     BEGIN
                       EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
                     EXCEPTION
                       WHEN OTHERS THEN
                         NULL;
                     END;

                     If G_Debug Then
                        Write_Log(2, 'END: UPDATE jtf_terr_qtype_usgs_all ');
                     End If;

	          END IF; -- end of p_source_id = -1001

		  -- 01/26/03: JDOCHERT:
                  -- Only for Oracle Sales and Telesales
		  --
                  /* JTF_TAE_<SOURCE_ID>_<TRANS>_DYN API architecture */
		  --
		  -- This is required since currently we only support TAE for
		  -- Accounts, Leads, and Opportunities
		  --
                  IF ( lp_qual_type_id IN (-1002, -1003, -1004) ) THEN

                    /* New TAE architecture */
                    JTF_TAE_GEN_PVT.Generate_API( ERRBUF  => errbuf,
                                                  RETCODE => retcode,
                                                  p_Source_Id => p_source_id,
                                                  p_Trans_Object_Type_Id => lp_qual_type_id,
                                                  p_target_type => 'TAP',
                                                  p_Debug_Flag  => p_debug_flag,
                                                  p_SQL_Trace   => p_sql_trace );

                    /* ACHANDA 03/08/2004 : Bug 3380047 : Program should terminate with error */
                    /* if one of the dynamically created packages are in invalid status       */
                    If (RETCODE = 2) Then
                      g_ProgramStatus := 2;
                    End If;

                  END IF;



          END LOOP;
          CLOSE csr_get_transactions;


      ELSIF ( p_source_id IS NOT NULL AND
              p_qualifier_type_id IS NOT NULL ) THEN


         LP_QUAL_TYPE_ID := p_qualifier_type_id;

            /* Real Time API architecture */
            JTF_TERR_ENGINE_GEN2_PVT.Generate_API(
                                              ERRBUF  => errbuf,
                                              RETCODE => retcode,
                                              p_Source_Id => p_source_id,
                                              p_qualifier_type_id => LP_QUAL_TYPE_ID,
                                              p_Debug_Flag  => p_debug_flag,
                                              p_SQL_Trace   => p_sql_trace  );

            /* ACHANDA 03/08/2004 : Bug 3380047 : Program should terminate with error */
            /* if one of the dynamically created packages are in invalid status       */
            If (RETCODE = 2) Then
              g_ProgramStatus := 2;
            End If;

            --dbms_output.put_line(' ');
            --dbms_output.put_line('Calling denorm API for ' || p_source_id ||
            --'/' || p_qualifier_type_id);
            --dbms_output.put_line(' ');

            /* build denormalised territory hierarchy table */
            JTF_TERR_DENORM_RULES_PVT.Populate_API( P_ERROR_CODE => retcode
                                                  , P_ERROR_MSG => errbuf
                                                  , P_SOURCE_ID => p_source_id
                                                  , p_qual_type_id => LP_QUAL_TYPE_ID );


		  /* ARPATEL: 12/04 Special handling for Oracle Sales, records
		  ** in denorm_rules all no longer striped by transaction type
		  */
		  IF ( p_source_id = -1001 ) THEN

		    BEGIN
                       /* get all territories that have resources attached */
                       UPDATE jtf_terr_denorm_rules_all j
                         SET j.resource_exists_flag = 'Y'
                       WHERE EXISTS
                          ( SELECT jtr.terr_id
                            FROM jtf_terr_rsc_all jtr
                            WHERE (jtr.end_date_active IS NULL OR jtr.end_date_active >= SYSDATE)
                              AND (jtr.start_date_active IS NULL OR jtr.start_date_active <= SYSDATE)
                              AND jtr.terr_id = j.terr_id
                          )
                         AND j.terr_id = j.related_terr_id
              	  	 AND j.source_id = p_source_id;

                     EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                     END;

		     BEGIN

                       FOR csr_dnm IN csr_get_SALES_denorm_terr( p_source_id ) LOOP

                          UPDATE  jtf_terr_denorm_rules_all jtdr
                          SET jtdr.ABSOLUTE_RANK = (
                              SELECT SUM(jt1.relative_rank)
                              FROM jtf_terr_denorm_rules_all jt1
                              WHERE jt1.related_terr_id = jt1.terr_id


                                /* JDOCHERT: 12/09/03: records in JTF_TERR_DENORM_RULES_ALL
				** are no longer striped by QUAL_TYPE_ID, so commenting out the
				** the following lines
				*/
                                /* ARPATEL: 11/12/03 Bug#3254575 */
                                --AND jt1.qual_type_id = p_qualifier_type_id
				--

                                AND jt1.terr_id IN
                              ( SELECT jt.terr_id
                                FROM jtf_terr_all jt
                                CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                                 START WITH jt.terr_id = csr_dnm.terr_id )
                          )
                          WHERE jtdr.source_id = p_source_id
                            AND jtdr.terr_id = CSR_DNM.terr_id;

                       END LOOP;

                     EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                     END;


		  ELSE --p_source_id <> -1001

                    /* moved from jtf_terr_denorm_rules_pvt */
                    BEGIN
                       /* get all territories that have resources attached */
                       UPDATE jtf_terr_denorm_rules_all j
                         SET j.resource_exists_flag = 'Y'
                       WHERE EXISTS
                          ( SELECT jtr.terr_id
                            FROM jtf_terr_rsc_all jtr
                            WHERE (jtr.end_date_active IS NULL OR jtr.end_date_active >= SYSDATE)
                              AND (jtr.start_date_active IS NULL OR jtr.start_date_active <= SYSDATE)
                              AND jtr.terr_id = j.terr_id
                          )
                         AND j.terr_id = j.related_terr_id
              	  	         AND j.source_id = p_source_id
                             AND j.qual_type_id = LP_QUAL_TYPE_ID;
                     EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                     END;


                    BEGIN

                       FOR csr_dnm IN csr_get_denorm_terr( p_source_id
                                                     , LP_QUAL_TYPE_ID ) LOOP

                          UPDATE  jtf_terr_denorm_rules_all jtdr
                          SET jtdr.ABSOLUTE_RANK = (
                              SELECT SUM(jt1.relative_rank)
                              FROM jtf_terr_denorm_rules_all jt1
                              WHERE jt1.related_terr_id = jt1.terr_id
                                /* ARPATEL: 11/12/03 Bug#3254575 */
                                AND jt1.qual_type_id = p_qualifier_type_id
                                AND jt1.terr_id IN
                              ( SELECT jt.terr_id
                                FROM jtf_terr_all jt
                                CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                                 START WITH jt.terr_id = csr_dnm.terr_id )
                          )
                          WHERE jtdr.source_id = p_source_id
                            AND jtdr.qual_type_id = LP_QUAL_TYPE_ID

                            --
                            -- JDOCHERT: 10/25/03: Following line was commented out
                            -- as real-time APIs depend on ABSOLUTE_RANK being set for
                            -- to return results correctly
                            --
                            --AND jtdr.related_terr_id = jtdr.terr_id
                            --

                            AND jtdr.terr_id = CSR_DNM.terr_id;


                       END LOOP;

                     EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                     END;

            end if; --p_source_id = -1001

	    IF ( p_source_id = -1001 ) THEN

	      If G_Debug Then
                 Write_Log(2, 'START: UPDATE jtf_terr_qtype_usgs_all ');
              End If;

              /* ACHANDA 02/03/04 Bug 3373687 : disable the trigger before update */
              BEGIN
                EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

              /* ARPATEL: 12/03/2003 populate num_qual column ONLY for Oracle Sales (-1001) */
              FOR csr_dnm IN csr_get_terr_num_qual( p_source_id
                                           , LP_QUAL_TYPE_ID ) LOOP

                 --dbms_output.put_line('GEN: UPDATE jtf_terr_qtype_usgs_all '||lp_qual_type_id);
                 UPDATE jtf_terr_qtype_usgs_all qua
                 SET qua.num_qual = ( SELECT count(*)
                                        FROM jtf_terr_qual_all jtq
                                           , jtf_qual_usgs_all jqu
                                           , jtf_qual_type_usgs jqtu
                                           , jtf_qual_type_denorm_v v
                                        WHERE jtq.qual_usg_id = jqu.qual_usg_id
                                          /* ACHANDA 02/03/2004 : Bug 3378530 : change the where clause to use index more selectively */
                                          AND jqu.org_id = -3113
                                          /*
                                          AND ( (jtq.org_id = jqu.org_id) OR
                                                (jtq.org_id IS NULL AND jqu.org_ID IS NULL)
                                              )
                                          */
                                          AND jqu.qual_type_usg_id = jqtu.qual_type_usg_id
                                          AND jqtu.qual_type_id <> -1001
                                          AND jqtu.source_id = p_source_id
                                          AND jqtu.qual_type_id = v.related_id
                                          AND v.qual_type_id = p_qualifier_type_id
                                          AND jtq.terr_id IN
                                        ( SELECT jt.terr_id
                                          FROM jtf_terr_all jt
                                          CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                                           START WITH jt.terr_id = csr_dnm.terr_id )
                                         )
                  WHERE qua.terr_qtype_usg_id = csr_dnm.terr_qtype_usg_id;

                --dbms_output.put_line('AFTER: GEN: UPDATE jtf_terr_qtype_usgs_all '||lp_qual_type_id);

	      END LOOP;

              /* ACHANDA 02/03/04 Bug 3373687 : enable the trigger after update */
              BEGIN
                EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

              If G_Debug Then
                 Write_Log(2, 'END: UPDATE jtf_terr_qtype_usgs_all ');
              End If;

	    END IF; -- end of p_source_id = -1001


            -- 01/26/03: JDOCHERT:
            -- Only for Oracle Sales and Telesales
            IF ( p_source_id = -1001 AND
		 p_qualifier_type_id IN (-1002, -1003, -1004) ) THEN

              /* New TAE Batch architecture */
              JTF_TAE_GEN_PVT.Generate_API( ERRBUF  => errbuf,
                                            RETCODE => retcode,
                                            p_Source_Id => p_source_id,
                                            p_Trans_Object_Type_Id => p_qualifier_type_id,
                                            p_target_type => 'TAP',
                                            p_Debug_Flag  => p_debug_flag,
                                            p_SQL_Trace   => p_sql_trace );

              /* ACHANDA 03/08/2004 : Bug 3380047 : Program should terminate with error */
              /* if one of the dynamically created packages are in invalid status       */
              If (RETCODE = 2) Then
                g_ProgramStatus := 2;
              End If;


            END IF;

      END IF;

       /* Oracle Sales and Telesales */
       IF (p_source_id = -1001) THEN

          BEGIN

             /* JDOCHERT: 05/07/03: BUG#2947497 FIX */
             BEGIN
                EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_RSC_BIUD DISABLE';
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;


             /* PERSON_ID required for OSO TAP */
             UPDATE jtf_terr_rsc_all jtr
               SET jtr.person_id =
                ( SELECT jrrev.source_id
                  FROM jtf_rs_resource_extns_vl jrrev
                  WHERE jrrev.category = 'EMPLOYEE'
                    AND jrrev.resource_id = jtr.resource_id )
             WHERE jtr.resource_type= 'RS_EMPLOYEE'
               AND jtr.terr_id IN
                  ( SELECT jtu.terr_id
                    FROM jtf_terr_usgs_all jtu
                    WHERE jtu.source_id = p_source_id )
               AND EXISTS
                  ( SELECT jrrev.resource_id
                    FROM jtf_rs_resource_extns_vl jrrev
                    WHERE jrrev.resource_id = jtr.resource_id );


             /* JDOCHERT: 05/07/03: BUG#2947497 FIX */
             BEGIN
                EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_RSC_BIUD ENABLE';
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;

           EXCEPTION
              WHEN OTHERS THEN
                 --dbms_output.put_line('UPDATING JTF_TERR_RSC_ALL.PERSON_ID: ERROR = ' || sqlerrm);
                 NULL;
           END;

	   /* JDOCHERT: 12/09/03: bug#3307414
	   ** since records in JTF_TERR_DENORM_RULES_ALL
	   ** are no longer striped by QUAL_TYPE_ID for
	   ** ORACLE SALES, the records in JTF_TERR_DENORM_ALL
	   ** are no longer required
	   **/
	   --
           --DELETE jtf_terr_denorm_all
           --WHERE source_id = p_source_id;
           --
           --INSERT INTO jtf_terr_denorm_all (
           --     source_id
           --   , terr_id
           --   , absolute_rank
           --   , related_terr_id
           --   , top_level_terr_id
           --   , num_winners       )
           --SELECT DISTINCT
           --       j.source_id
           --     , j.terr_id
           --     , j.absolute_rank
           --     , j.related_terr_id
           --     , j.top_level_terr_id
           --     , j.num_winners
           --FROM jtf_terr_denorm_rules_all j
           --WHERE j.source_id = -1001;
	   --

      END IF;


      /* analyse table */
      BEGIN

              /* JDOCHERT: 06/17/03: bug#2991180 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'JTF',
                          tabname     => 'JTF_TERR_DENORM_RULES_ALL',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );


	      /* JDOCHERT: 12/09/03: bug#3307414
	      ** since records in JTF_TERR_DENORM_RULES_ALL
	      ** are no longer striped by QUAL_TYPE_ID for
	      ** ORACLE SALES, the records in JTF_TERR_DENORM_ALL
	      ** are no longer required
	      **/
              --   /* JDOCHERT: 06/17/03: bug#2991180 */
              --   FND_STATS.GATHER_TABLE_STATS(
              --               ownname     => 'JTF',
              --               tabname     => 'JTF_TERR_DENORM_ALL',
              --               percent     => 20,
              --               degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
              --               partname    => NULL,
              --               backup_flag => 'NOBACKUP',
              --               cascade     => TRUE,
              --               granularity => 'DEFAULT'
              --               );
	      --


              /* JDOCHERT: 06/17/03: bug#2991180 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'JTF',
                          tabname     => 'JTF_TERR_QUAL_ALL',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

              /* JDOCHERT: 06/17/03: bug#2991180 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'JTF',
                          tabname     => 'JTF_TERR_VALUES_ALL',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                               );

      EXCEPTION
         WHEN OTHERS THEN

            If G_Debug Then
               Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
            End If;

            g_ProgramStatus := 1;

      END;

      IF (G_Debug) THEN

             SELECT count(*)
             INTO l_denorm_count
             FROM jtf_terr_denorm_rules_all j
             WHERE j.source_id = p_source_id
               AND ( ( j.qual_type_id = p_qualifier_type_id )
	              OR
		    ( p_source_id = -1001 AND p_qualifier_type_id IS NULL )
		   );

             Write_Log(2, ' ');
             Write_Log(2, '/***************** BEGIN: DENORM STATUS *********************/');
             Write_Log(2, 'Populating denorm table - JTF_TERR_DENORM_RULES_ALL ');
             Write_Log(2, 'Inserted ' || l_denorm_count || ' rows into JTF_TERR_DENORM_RULES_ALL ');


	     /* JDOCHERT: 12/09/03: bug#3307414
	     ** since records in JTF_TERR_DENORM_RULES_ALL
	     ** are no longer striped by QUAL_TYPE_ID for
	     ** ORACLE SALES, the records in JTF_TERR_DENORM_ALL
	     ** are no longer required
	     **/
	     --
             --SELECT count(*)
             --INTO l_denorm_count
             --FROM jtf_terr_denorm_all j
             --WHERE j.source_id = p_source_id;
	     --
             --Write_Log(2, 'Populating denorm table - JTF_TERR_DENORM_ALL ');
             --Write_Log(2, 'Inserted ' || l_denorm_count || ' rows into JTF_TERR_DENORM_ALL ');
	     --

             Write_Log(2, ' ');
             Write_Log(2, '/***************** END: DENORM STATUS ***********************/');


      END IF;

      /* commit work so that Materialized view can be refreshed */
      COMMIT;


      /* Oracle Sales and Telesale ONLY: Refresh MVs */
      IF (p_source_id = -1001) THEN

            /* Refresh Materialized view */
          -- Commented the refresh statement as these materialized views are no more used in R12.
          --  DBMS_MVIEW.REFRESH('JTF_TERR_QUAL_RULES_MV', 'C', '', TRUE, FALSE, 0,4,0, TRUE);

            /* analyse Materialized view */
            BEGIN

              /* JDOCHERT: 05/07/03: bug#2948883 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'APPS',
                          tabname     => 'JTF_TERR_QUAL_RULES_MV',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

            EXCEPTION
               WHEN OTHERS THEN

               If G_Debug Then
                  Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
               End If;

               g_ProgramStatus := 1;
            END;

            /* Refresh Materialized view */
           -- Commented the refresh statement as these materialized views are no more used in R12.
           -- DBMS_MVIEW.REFRESH('JTF_TERR_CNR_QUAL_LIKE_MV', 'C', '', TRUE, FALSE, 0,4,0, TRUE);

            /* analyse Materialized view */
            BEGIN

              /* JDOCHERT: 05/07/03: bug#2948883 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'APPS',
                          tabname     => 'JTF_TERR_CNR_QUAL_LIKE_MV',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

            EXCEPTION
               WHEN OTHERS THEN

               If G_Debug Then
                  Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
               End If;

               g_ProgramStatus := 1;
            END;

            /* Refresh Materialized view */
            -- Commented the refresh statement as these materialized views  are no more used in R12.
            --DBMS_MVIEW.REFRESH('JTF_TERR_CNR_QUAL_BTWN_MV', 'C', '', TRUE, FALSE, 0,4,0, TRUE);

            /* analyse Materialized view */
            BEGIN

              /* JDOCHERT: 05/07/03: bug#2948883 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'APPS',
                          tabname     => 'JTF_TERR_CNR_QUAL_BTWN_MV',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

            EXCEPTION
               WHEN OTHERS THEN

               If G_Debug Then
                  Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
               End If;

               g_ProgramStatus := 1;
            END;

            /* Refresh Materialized view */
           -- Commented the refresh statement as these materialized views are no more used in R12.
           -- DBMS_MVIEW.REFRESH('JTF_TERR_CNRG_EQUAL_MV', 'C', '', TRUE, FALSE, 0,4,0, TRUE);

            /* analyse Materialized view */
            BEGIN

              /* JDOCHERT: 05/07/03: bug#2948883 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'APPS',
                          tabname     => 'JTF_TERR_CNRG_EQUAL_MV',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

            EXCEPTION
               WHEN OTHERS THEN

               If G_Debug Then
                  Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
               End If;

               g_ProgramStatus := 1;
            END;

            /* Refresh Materialized view */
           -- Commented the refresh statement as these materialized views are no more used in R12.
           -- DBMS_MVIEW.REFRESH('JTF_TERR_CNRG_LIKE_MV', 'C', '', TRUE, FALSE, 0,4,0, TRUE);

            /* analyse Materialized view */
            BEGIN

              /* JDOCHERT: 05/07/03: bug#2948883 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'APPS',
                          tabname     => 'JTF_TERR_CNRG_LIKE_MV',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

            EXCEPTION
               WHEN OTHERS THEN

               If G_Debug Then
                  Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
               End If;

               g_ProgramStatus := 1;
            END;

            /* Refresh Materialized view */
            -- Commented the refresh statement as these materialized views are no more used in R12.
            --DBMS_MVIEW.REFRESH('JTF_TERR_CNRG_BTWN_MV', 'C', '', TRUE, FALSE, 0,4,0, TRUE);

            /* analyse Materialized view */
            BEGIN

              /* JDOCHERT: 05/07/03: bug#2948883 */
              FND_STATS.GATHER_TABLE_STATS(
                          ownname     => 'APPS',
                          tabname     => 'JTF_TERR_CNRG_BTWN_MV',
                          percent     => 20,
                          degree      => NULL, /* JDOCHERT: 04/10/03: bug#2896552 */
                          partname    => NULL,
                          backup_flag => 'NOBACKUP',
                          cascade     => TRUE,
                          granularity => 'DEFAULT',
                          hmode => 'FULL'
                          );

            EXCEPTION
               WHEN OTHERS THEN

               If G_Debug Then
                  Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
               End If;

               g_ProgramStatus := 1;
            END;


   -- Commented the following script as the materialized views reffered are no more used
   -- and stubbed in R12.
     /*
           IF (G_Debug) THEN

                   SELECT count(*)
                   INTO l_mv1_count
                   FROM jtf_terr_qual_rules_mv j;

                   SELECT count(*)
                   INTO l_mv2_count
                   FROM jtf_terr_cnr_qual_like_mv j;

                   SELECT count(*)
                   INTO l_mv3_count
                   FROM jtf_terr_cnr_qual_btwn_mv j;


                   SELECT count(*)
                   INTO l_mv4_count
                   FROM jtf_terr_cnrg_equal_mv j;

                   SELECT count(*)
                   INTO l_mv5_count
                   FROM jtf_terr_cnrg_like_mv j;

                   SELECT count(*)
                   INTO l_mv6_count
                   FROM jtf_terr_cnrg_btwn_mv j;

                   Write_Log(2, ' ');
                   Write_Log(2, '/ ***************** BEGIN: MV STATUS ********************* /');
                   Write_Log(2, ' ');
                   Write_Log(2, 'Refreshing materialized view - JTF_TERR_QUAL_RULES_MV ');
                   Write_Log(2, 'Inserted ' || l_mv1_count || ' rows into JTF_TERR_QUAL_RULES_MV ');
                   Write_Log(2, ' ');
                   Write_Log(2, 'Refreshing materialized view - JTF_TERR_CNR_QUAL_LIKE_MV ');
                   Write_Log(2, 'Inserted ' || l_mv2_count || ' rows into JTF_TERR_CNR_QUAL_LIKE_MV ');
                   Write_Log(2, ' ');
                   Write_Log(2, 'Refreshing materialized view - JTF_TERR_CNR_QUAL_BTWN_MV ');
                   Write_Log(2, 'Inserted ' || l_mv3_count || ' rows into JTF_TERR_CNR_QUAL_BTWN_MV ');
                   Write_Log(2, ' ');
                   Write_Log(2, 'Refreshing materialized view - JTF_TERR_CNRG_EQUAL_MV ');
                   Write_Log(2, 'Inserted ' || l_mv4_count || ' rows into JTF_TERR_CNRG_EQUAL_MV ');
                   Write_Log(2, ' ');
                   Write_Log(2, 'Refreshing materialized view - JTF_TERR_CNRG_LIKE_MV ');
                   Write_Log(2, 'Inserted ' || l_mv5_count || ' rows into JTF_TERR_CNRG_LIKE_MV ');
                   Write_Log(2, ' ');
                   Write_Log(2, 'Refreshing materialized view - JTF_TERR_CNRG_LIKE_MV ');
                   Write_Log(2, 'Inserted ' || l_mv6_count || ' rows into JTF_TERR_CNRG_LIKE_MV ');
                   Write_Log(2, ' ');
                   Write_Log(2, '/ ***************** END: MV STATUS *********************** /');
                   Write_Log(2, ' ');

            END IF;
     */
      END IF; /* (p_source_id = -1001) */


      /* ACHANDA 03/08/2004 : Bug 3380047 : Added to force the program error out if the */
      /* dynamically created packages are in invalid status                             */
      IF (g_ProgramStatus = 2) THEN
          ERRBUF := 'One or more of the dynamically created packages are in invalid status : see log for details.';
          RETCODE := 2;
      ELSIF (g_ProgramStatus = 1 OR retcode = 1) THEN
          ERRBUF := 'Program Completed with exceptions';
          RetCODE := 1;
      ElSIF (g_ProgramStatus = 0 OR retcode = 0) THEN
          ERRBUF := 'Program completed successfully.';
          RetCode := 0;
      End If;

      Write_Log(2,ERRBUF);

   EXCEPTION
      WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error Then
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
           If G_Debug Then
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
           End If;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;
   END generate_api;



-- 01/15/01: JDOCHERT: STUBBED OUT - ARCHITECTURE: OBSOLETE SINCE 11.5.4
-- tHIS FUNCTION WILL BUILD THE RULE EXPRESSION
   FUNCTION build_rule_expression (
      p_terr_id      IN   NUMBER,
      p_start_date   IN   DATE,
      p_end_date     IN   DATE
      )
      RETURN BOOLEAN
   AS
   BEGIN
      NULL;
   END build_rule_expression;



END JTF_TERR_ENGINE_GEN_PVT;


/
