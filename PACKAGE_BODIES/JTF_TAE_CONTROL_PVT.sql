--------------------------------------------------------
--  DDL for Package Body JTF_TAE_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TAE_CONTROL_PVT" AS
/* $Header: jtftaecb.pls 120.2 2006/06/23 21:25:32 solin ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_CONTROL
--    ---------------------------------------------------
--    PURPOSE
--
--      Control Packages for JTF_TERR_AE packages.
--          Replacement of TAP.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for public use
--
--    HISTORY
--      02/10/2002  EIHSU Edward Hsu Created.
--      02/12/2002  EIHSU           Add AE CONTROL
--                                  build_qual_rel_multiple
--      02/18/2002  EIHSU           Analyze_Territory Added
--                                  Cursor build control Added
--      02/19/2002  EIHSU           Index creation algorithm added
--                                  Set reduction algorithm added
--      02/19/2002  EIHSU           Modify Analyze_Territory to
--                                  analyze only terrs with rsc
--      02/19/2002  EIHSU           Edit Index creation
--      03/14/2002  EIHSU           Change Set Reduction To Default
--                                  to 'N' for all sets
--      03/15/2002  EIHSU           Add Exception handling in case
--                                  Index creation and Selectivity Calc Fails
--      03/18/2002  EIHSU           Fix Ordinal Subset Set reduction
--                                  algorithm
--      03/19/2002  EIHSU           Added phases description and pseudocode
--                                  for calling JTF_TAE_GEN, JTF_TAE%DYN
--      03/21/2002  EIHSU           relation product is different for
--                                  same territory with diff tx quals types
--      04/02/2002  EIHSU           terr analysis for set transactiontype
--      04/04/2002  EIHSU           parameterized input table
--      04/08/2002  EIHSU           renamed a lot of stuff
--      04/15/2002  SBEHERA         added source_id and tran_id to update
--                                  jtf_terr_denorm_rules_all
--      04/16/2002  SBEHERA         added source_id and tran_id to delete
--                                  jtf_tae_qual_prod_factors
--      05/03/2002  EIHSU           set build_index_flag to 'N' if the index
--                                  does not have any columns in it
--      03/08/2004  ACHANDA         Fix bug # 3373687
--      11/17/2004  ACHANDA         Fix bug # 4009495
--      06/23/2006  SOLIN           Bug 5355020
--
     g_pkg_name           CONSTANT VARCHAR2(30) := 'JTF_TAE_CONTROL_PVT';
     g_file_name          CONSTANT VARCHAR2(12) := 'jtftaecb.pls';

   --
   -- write_log procedure JDOCHERT: 4/21/02
			--
   PROCEDURE Write_Log(which number, mssg  varchar2 )
   IS

      l_mssg            VARCHAR2(32767);
      l_sub_mssg        VARCHAR2(255);
      l_begin           NUMBER := 1;
      l_mssg_length     NUMBER := 0;
      l_time            VARCHAR2(60) := TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss');

   BEGIN

     IF (JTF_TAE_CONTROL_PVT.G_DEBUG) Then

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
		      ** there is less than 250 characters left to be output
								*/
        l_sub_mssg := SUBSTR(l_mssg, l_begin);
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_sub_mssg);
	    --dbms_output.put_line('LOG: ' || l_mssg );

			  END IF;

   --
   END Write_Log;

------------------------------------------------------------------


--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    Procedure (Private): Classify_Territories
--    ---------------------------------------------------
--    PURPOSE
--      Implements Aggregate/Component Relation Key analysis of
--      territory/qualifier relations.
--
--    REQIRES / DEPENDENCIES
--      jtf_terr_denorm_rules_all
--      jtf_terr_qual_all
--
--    MODIFIES
--      Rows in JTF_TAE_QUAL_FACTORS/JTF_TAE_QUAL_PRODUCTS
--
--    EFFECTS
--      Allows TAP to run with select statements of terr-qual relation
--      combinations.
--

     PROCEDURE Classify_Territories
       (p_Api_Version_Number     IN  NUMBER,
        p_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
        p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
        p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

        x_Return_Status          OUT NOCOPY VARCHAR2,
        x_Msg_Count              OUT NOCOPY NUMBER,
        x_Msg_Data               OUT NOCOPY VARCHAR2,
        p_source_id              IN  NUMBER,
        p_trans_id               IN  NUMBER,
        ERRBUF                   OUT NOCOPY VARCHAR2,
        RETCODE                  OUT NOCOPY VARCHAR2 )
    IS

        l_return_status               VARCHAR2(1);
        l_api_name           CONSTANT VARCHAR2(30) := 'Analyze_Territories';
        l_api_version_number CONSTANT NUMBER := 1.0;

        l_source_id             NUMBER := p_source_id;
        l_trans_id              NUMBER := p_trans_id;

        l_terr_analyze_id       number;
        l_qual_factor_id        number;
        l_qual_product_id       number;
        l_qual_prod_factor_id   number;
        l_counter               number := 0;
        l_exist_qual_detail_count number;
        startime                date;
        looptime                date;
        l_terr_analyze_id_arr   DBMS_SQL.NUMBER_TABLE;
        l_qual_prod_counter     number;
        l_counter_qtype_offset  number;
        l_char_tx_id            varchar2(30);

        -- BUILD QUAL_RELATION_PRODUCT
        cursor qual_rel_facts(cl_source_id number, cl_qual_type_id number) is
            SELECT jqua.qual_usg_id, jqua.qual_relation_factor, jqua.org_id
            FROM jtf_qual_usgs_all jqua,
                 jtf_qual_type_usgs jqtu
                 , jtf_qual_type_denorm_v v
            WHERE qual_relation_factor IS NOT NULL
                 and jqua.org_id = -3113
                 and jqua.qual_type_usg_id  = jqtu.qual_type_usg_id
                 AND jqtu.source_id = cl_source_id ---1001
                 and jqtu.qual_type_id = v.related_id
                 AND v.qual_type_id = cl_qual_type_id -- -1002
                 AND EXISTS ( SELECT iq.qual_usg_id
                              FROM jtf_qual_usgs_all iq
                              WHERE enabled_flag = 'Y'
                                AND iq.qual_usg_id = jqua.qual_usg_id );

        /*  SELECT jqua.qual_usg_id, jqua.qual_relation_factor, jqua.org_id
            FROM jtf_qual_usgs_all jqua,
                 jtf_qual_type_usgs jqtu
            WHERE
                 jqua.qual_type_usg_id  = jqtu.qual_type_usg_id
                 and qual_relation_factor is not null
                 and jqua.org_id = -3113
                 and jqtu.qual_type_id in (SELECT related_id
                                           FROM jtf_qual_type_denorm_v
                                           WHERE qual_type_id = cl_qual_type_id);
        */
        -- POPULATION OF QUAL_PRODUCT/FACTOR TABLES
        -- ( CURSOR BUILD CONTROL )
        ll_counter              number := 0;
        total_terr_all_orgs     number := 0;

	/* ARPATEL: 01/06/2004 bug#3337382
	** now use qual_relation_product in jtf_terr_qtype_usgs_all
	*/
        cursor qual_rel_sets(cl_qual_type_id number) is
          SELECT count(*) total_count, jtqu.qual_relation_product
            FROM jtf_terr_denorm_rules_all jtdr
	        ,jtf_terr_qtype_usgs_all jtqu
		,jtf_qual_type_usgs_all jqtu
           WHERE 1=1
              --and org_id = -3113
			  /* JDOCHERT: 07/29/03: BUG#  :
			  ** JTF_TAE_QUAL_PRODUCTS NOT BEING CORRECTLY POPULATED SINCE
			  ** POPULATION OF jtdr.resource_exists_flag = 'Y' NOW TAKES
			  ** PLACE AT TOWARDS END OF GTP BEFORE MV REFRESH.
			  */
              --AND resource_exists_flag = 'Y'
        --
              AND jtdr.source_id = p_source_id
              AND jqtu.source_id = jtdr.source_id
              AND jqtu.qual_type_id = cl_qual_type_id
              AND jtdr.terr_id = jtqu.terr_id
              AND jtdr.terr_id = jtdr.related_terr_id
              AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id

         GROUP BY jtqu.qual_relation_product
         ORDER BY total_count DESC;

        cursor quals_used(qual_relation_product number) is
            select distinct qual_usg_id  -- distinct not really needed
            from jtf_qual_usgs_all jqua
            where mod(qual_relation_product, jqua.qual_relation_factor) = 0
              and org_id = -3113;

        cursor qual_details(cl_qual_usg_id number) is
            select * from jtf_qual_usgs_all
            where qual_usg_id = cl_qual_usg_id
            and org_id = -3113;

--        cursor non_rsc_qual_types(cl_source_id number) is
--            select * from jtf_qual_type_usgs_all
--            where source_id = cl_source_id
--              and qual_type_id <> -1001;

    BEGIN

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call (
                  l_api_version_number,
                  p_api_version_number,
                  l_api_name,
                  g_pkg_name
               )
        THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        ---------------------------------------------------------------
        -- API BODY BEGINS
        ---------------------------------------------------------------
        --dbms_output.put_line('JTF_TERR_AE_CONTROL.Analyze_Territories: BEGIN ');

        BEGIN

        --dbms_output.put_line('    Initializing QUAL_RELATION_PRODUCT values... ');

          /* Initializing Relevant QUAL_RELATION_PRODUCT values
          ** added source and trans id sbehera 04/15/2002 */
	  /* ARPATEL: 12/09/2003 Bug#3307414 Sales denorm record no longer striped by TX type, qual_type_id = -1 */

	  /* ARPATEL: 01/06/2004 bug#3337382
      ** now use qual_relation_product in jtf_terr_qtype_usgs_all
	  */

          /* ACHANDA 03/08/04 Bug 3373687 : disable the trigger before update */
          BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

	  UPDATE jtf_terr_qtype_usgs_all jtqu
	     SET jtqu.QUAL_RELATION_PRODUCT = 1
	   WHERE jtqu.qual_type_usg_id = (
	                                 SELECT jqtu.qual_type_usg_id
	                                   FROM jtf_qual_type_usgs_all jqtu
					                  WHERE jqtu.source_id = p_source_id
					                    AND jqtu.qual_type_id = p_trans_id
					                  );

          /* ACHANDA 03/08/04 Bug 3373687 : enable the trigger after update */
          BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

	  --UPDATE jtf_terr_denorm_rules_all jtdr
          --   SET jtdr.QUAL_RELATION_PRODUCT = 1
          -- WHERE jtdr.terr_id = related_terr_id
          --   AND jtdr.source_id = p_source_id
          --   AND jtdr.qual_type_id = -1; --p_trans_id;


          NULL;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [1] NO_DATA_FOUND: ' ||
						'NO territories exist for this Usage/Transaction combination.';
			  JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
              RAISE	FND_API.G_EXC_ERROR;

           WHEN OTHERS THEN
	             ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [1] OTHERS: ' ||
						   SQLERRM;
			  JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
              RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
		END;


        --dbms_output.put_line('*** Rel Prod Init Complete - Time: ' || trunc((sysdate - startime) * 86400, 5) || ' seconds');

        -----------------------------------------------------------------
        -- Build QUAL_RELATION_PRODUCT per terr (Incls Inherited quals)
        -----------------------------------------------------------------
        --dbms_output.put_line('    Setting QUAL_RELATION_PRODUCT: (Incls Inherited quals) ');

        l_counter := 0;

        FOR qual_rel in qual_rel_facts(l_source_id, l_trans_id) LOOP

           l_counter := l_counter + 1;
           looptime := sysdate;
           --dbms_output.put_line('      ' || l_counter || '  qual_usg_id: ' || qual_rel.qual_usg_id || ' / qual_relation_factor: ' || qual_rel.qual_relation_factor);

           BEGIN

	     /* ARPATEL: 12/09/2003 Bug#3307414 Sales denorm record no longer striped by TX type, qual_type_id = -1 */

	     /* ARPATEL: 01/06/2004 bug#3337382
             ** now use qual_relation_product in jtf_terr_qtype_usgs_all
	     */
             /* ACHANDA 03/08/04 Bug 3373687 : disable the trigger before update */
             BEGIN
               EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
             EXCEPTION
               WHEN OTHERS THEN
                 NULL;
             END;

	     UPDATE jtf_terr_qtype_usgs_all jtqu
	        SET jtqu.QUAL_RELATION_PRODUCT =
                     jtqu.QUAL_RELATION_PRODUCT * qual_rel.qual_relation_factor
          WHERE jtqu.terr_id IN
                	         ( SELECT ijtdr.terr_id
                	           FROM jtf_terr_denorm_rules_all ijtdr
                                   ,jtf_terr_qtype_usgs_all ijtqu
                		           ,jtf_qual_type_usgs_all ijqtu
                	               ,jtf_terr_qual_all jtq
                	           WHERE ijtdr.source_id = l_source_id
                                 AND ijqtu.source_id = ijtdr.source_id
                		         AND ijqtu.qual_type_id = l_trans_id
                                 AND ijtdr.terr_id = ijtqu.terr_id
                		         AND ijtqu.qual_type_usg_id = ijqtu.qual_type_usg_id
                	             AND ijtdr.related_terr_id = jtq.terr_id
                	             AND jtq.qual_usg_id = qual_rel.qual_usg_id
                		      )
		    AND jtqu.qual_type_usg_id = (
					    SELECT jqtu.qual_type_usg_id
					      FROM jtf_qual_type_usgs_all jqtu
					     WHERE jqtu.source_id = l_source_id
					       AND jqtu.qual_type_id = l_trans_id
					     );

              /* ACHANDA 03/08/04 Bug 3373687 : enable the trigger after update */
              BEGIN
                EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

          /*
          UPDATE jtf_terr_denorm_rules_all jtdr
	     SET jtdr.QUAL_RELATION_PRODUCT =
        	     jtdr.QUAL_RELATION_PRODUCT * qual_rel.qual_relation_factor
             WHERE jtdr.terr_id IN
                ( SELECT ijtdr.terr_id
                  FROM jtf_terr_denorm_rules_all ijtdr,
                       jtf_terr_qual_all jtq
                  WHERE ijtdr.source_id = l_source_id
                    and ijtdr.qual_type_id = -1
                    and ijtdr.related_terr_id = jtq.terr_id
                    and jtq.qual_usg_id = qual_rel.qual_usg_id )
           */
				   /* JDOCHERT: 07/29/03: BUG#  :
				   ** JTF_TAE_QUAL_PRODUCTS NOT BEING CORRECTLY POPULATED SINCE
				   ** POPULATION OF jtdr.resource_exists_flag = 'Y' NOW TAKES
				   ** PLACE AT TOWARDS END OF GTP BEFORE MV REFRESH.
				   */
                   --AND jtdr.resource_exists_flag = 'Y'
				   --
                /*
                   and jtdr.related_terr_id = jtdr.terr_id
                   and jtdr.qual_type_id = -1 --l_trans_id
                   and jtdr.source_id = l_source_id;
                */

                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [2] NO_DATA_FOUND: ' ||
							    'UPDATE JTF_TERR_DENORM_RULES_ALL.QUAL_RELATION_PRODUCT.';
       			      JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                      RAISE	FND_API.G_EXC_ERROR;

                   WHEN OTHERS THEN
        	          ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [2] OTHERS: ' ||
							    SQLERRM;
			          JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                      RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
        		END;
                --dbms_output.put_line('   Update time: ' ||
				--trunc((sysdate - looptime) * 86400, 3) || ' seconds');

        END LOOP;


        --dbms_output.put_line('*** Set Qual Rel Product Complete - Total time: ' ||
		--trunc((sysdate - startime) * 86400, 3) || ' seconds');

        -----------------------------------------------------------------
        -- Create Combinations in Product and Factor Tables
        -----------------------------------------------------------------
        --dbms_output.put_line('    Populate Algorithm Tables - Cursor build control: BEGIN ');
        --startime := sysdate;


        SELECT JTF_TAE_ANALYZE_TERR_S.NEXTVAL
        INTO l_terr_analyze_id
        FROM dual;
        --dbms_output.put_line('   l_terr_analyze_id= ' || l_terr_analyze_id);

        BEGIN

	  -- CLEAR AGGREGATE/COMPONENT RELATION KEY ALGORITHM STORAGE TABLES
         DELETE FROM jtf_tae_qual_prod_factors
         where qual_product_id in
                          (select qual_product_id from jtf_tae_qual_products
                           where source_id = l_source_id
                             and trans_object_type_id = l_trans_id);

          delete from JTF_TAE_QUAL_products
          where source_id = l_source_id and trans_object_type_id = l_trans_id;

          --added sbehera 04/16/2002
          DELETE FROM jtf_tae_qual_factors o
          WHERE NOT EXISTS ( SELECT NULL
                     FROM jtf_tae_qual_products i
                     WHERE MOD(i.relation_product, o.relation_factor) = 0 );


        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [3] NO_DATA_FOUND: ' ||
			            'Clearing Qualifier Combination data.';
			  JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
              RAISE	FND_API.G_EXC_ERROR;

           WHEN OTHERS THEN
	          ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [3] OTHERS: ' ||
				   	    SQLERRM;
			  JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
              RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
		END;

        l_counter_qtype_offset := 0;
        l_counter := 0;

            for rel_set in qual_rel_sets(l_trans_id) loop
                l_counter := l_counter + 1;

                l_char_tx_id := ABS(l_trans_id);

                SELECT JTF_TAE_QUAL_PRODUCTS_S.NEXTVAL
                INTO l_qual_product_id
                FROM dual;

                --dbms_output.put_line('    CURSOR NUMBER ' || l_counter || '  total_terr_count: ' || rel_set.total_count || ' / qual_relation_product: ' || rel_set.qual_relation_product);
                total_terr_all_orgs := total_terr_all_orgs + rel_set.total_count;

                -- POPULATE PRODUCTS
                if rel_set.qual_relation_product <> 1 then

                BEGIN

                    INSERT INTO JTF_TAE_QUAL_products
                    (   QUAL_PRODUCT_ID,
                        RELATION_PRODUCT,
                        SOURCE_ID,
                        TRANS_OBJECT_TYPE_ID,
                        INDEX_NAME,
                        FIRST_CHAR_FLAG,
                        BUILD_INDEX_FLAG,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        TERR_ANALYZE_ID
                        )
                    VALUES
                    (   l_qual_product_id,                    --QUAL_PRODUCT_ID,
                        rel_set.qual_relation_product,		  --RELATION_PRODUCT,
                        l_source_id,                          --SOURCE_ID,
                        l_trans_id,               --TRANS_OBJECT_TYPE_ID,
                        'JTF_TAE_TN' || l_char_tx_id || '_DYN_N'|| TO_CHAR(l_counter),          --INDEX_NAME,
                        'N',                                   --FIRST_CHAR,
                        'Y',                                  --BUILD_INDEX_FLAG,
                        sysdate,                              --LAST_UPDATE_DATE,
                        1,                                    --LAST_UPDATED_BY,
                        sysdate,                              --CREATION_DATE,
                        1,                                    --CREATED_BY,
                        1,                                    --LAST_UPDATE_LOGIN)
                        l_terr_analyze_id                     --TERR_ANALYZE_ID,
                    );

        		EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [4] NO_DATA_FOUND: ' ||
                                'Populating JTF_TAE_QUAL_PRODUCTS table.';
			          JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                      RAISE	FND_API.G_EXC_ERROR;

                   WHEN OTHERS THEN
        	          ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [4] OTHERS: ' ||
                                SQLERRM;
			          JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                      RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
        		END;

                --dbms_output.put_line('     Qualifier used in this cursor: ');
                ll_counter := 0;
                l_qual_prod_counter := 0;

                for qual_name in quals_used(rel_set.qual_relation_product) loop
                    ll_counter := ll_counter + 1;
                    --dbms_output.put_line('     ' || ll_counter || '  qual_usg_id: ' || qual_name.qual_usg_id);

                    for q_detail in qual_details(qual_name.qual_usg_id) loop
                        -- there should only be one record here
                        l_qual_prod_counter := l_qual_prod_counter + 1;

                        select count(*) into l_exist_qual_detail_count
                        from JTF_TAE_QUAL_factors
                        where qual_usg_id = q_detail.qual_usg_id;

                        if l_exist_qual_detail_count = 0 then

                            BEGIN

                              SELECT JTF_TAE_QUAL_factors_s.NEXTVAL
                              INTO l_qual_factor_id
                              FROM dual;

                              INSERT INTO JTF_TAE_QUAL_factors
                                ( QUAL_FACTOR_ID           ,
                                  RELATION_FACTOR          ,
                                  QUAL_USG_ID              ,
                                  LAST_UPDATED_BY          ,
                                  LAST_UPDATE_DATE         ,
                                  CREATED_BY               ,
                                  CREATION_DATE            ,
                                  LAST_UPDATE_LOGIN        ,
                                  TERR_ANALYZE_ID          ,
                                  TAE_COL_MAP              ,
                                  TAE_REC_MAP              ,
                                  USE_TAE_COL_IN_INDEX_FLAG,
                                  UPDATE_SELECTIVITY_FLAG  ,
                                  INPUT_SELECTIVITY        ,
                                  INPUT_ORDINAL_SELECTIVITY,
                                  INPUT_DEVIATION          ,
                                  ORG_ID                   ,
                                  OBJECT_VERSION_NUMBER
                                )
                                VALUES
                                ( l_qual_factor_id,                   -- QUAL_FACTOR_ID
                                  q_detail.qual_relation_factor,       -- RELATION_FACTOR
                                  q_detail.qual_usg_id,               -- QUAL_USG_ID
                                  0,                                  -- LAST_UPDATED_BY
                                  sysdate,                            -- LAST_UPDATE_DATE
                                  0,                                  -- CREATED_BY
                                  sysdate,                            -- CREATION_DATE
                                  0,                                  -- LAST_UPDATE_LOGIN
                                  l_terr_analyze_id,                  -- TERR_ANALYZE_ID
                                  q_detail.qual_col1,                 -- TAE_COL_MAP
                                  q_detail.qual_col1_alias,           -- TAE_REC_MAP
                                  'Y',                                -- USE_TAE_COL_IN_INDEX_FLAG
                                  'Y',                                -- UPDATE_SELECTIVITY_FLAG
                                  null,                               -- INPUT_SELECTIVITY
                                  null,                               -- INPUT_ORDINAL_SELECTIVITY
                                  null,                               -- INPUT_DEVIATION
                                  null,                               -- ORG_ID
                                  null                                -- OBJECT_VERSION_NUMBER
                                );

								/* BUG#2990404: JDOCHERT: 09/02/03:
								** make records created in this session
								** immediately visible to other sessions
								*/
								COMMIT;

                    		EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                  ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [5] NO_DATA_FOUND: ' ||
                                            'Populating JTF_TAE_QUAL_FACTORS table.';
			                      JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                                  RAISE	FND_API.G_EXC_ERROR;

                               WHEN OTHERS THEN
                    	           ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [5] OTHERS: ' ||
                                            SQLERRM;
			                       JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                                   RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
                    		END;

                        end if;

                    end loop;  -- should only be one record: insert details to qual_factor table
                end loop;  -- factors in this product

                for qual_name in quals_used(rel_set.qual_relation_product) loop

                    BEGIN

			            /* BUG#2990404: JDOCHERT: 09/02/03:
						** add rownum restriction to avoid GTP failing
						*/
                        select qual_factor_id into l_qual_factor_id
                        from JTF_TAE_QUAL_factors
                        where qual_usg_id = qual_name.qual_usg_id
						  AND rownum < 2;

                        SELECT JTF_TAE_QUAL_PROD_FACTORS_S.NEXTVAL
                        INTO l_qual_prod_factor_id
                        FROM dual;

                        INSERT INTO JTF_TAE_QUAL_prod_factors
                          ( QUAL_PROD_FACTOR_ID,
                      		QUAL_PRODUCT_ID,
                      		QUAL_FACTOR_ID,
                      		LAST_UPDATE_DATE,
                      		LAST_UPDATED_BY,
                      		CREATION_DATE,
                      		CREATED_BY,
                      		LAST_UPDATE_LOGIN,
                      		TERR_ANALYZE_ID,
                      		ORG_ID,
                      		OBJECT_VERSION_NUMBER
                          )
                          VALUES
                          ( l_qual_prod_factor_id, --QUAL_PROD_FACTOR_ID,
                            l_qual_product_id,   --QUAL_PRODUCT_ID,
                            l_qual_factor_id,                   --QUAL_FACTOR_ID
                            sysdate,                  		    --LAST_UPDATE_DATE,
                            0,                           		--LAST_UPDATED_BY,
                            sysdate,                            --CREATION_DATE,
                            0,                                  --CREATED_BY,
                            0,                                  --LAST_UPDATE_LOGIN,
                            l_terr_analyze_id,                  --TERR_ANALYZE_ID,
                            null,                               --ORG_ID,
                            null                                --OBJECT_VERSION_NUMBER
                        	);

            		EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [6] NO_DATA_FOUND: ' ||
                                    'Populating JTF_TAE_QUAL_PROD_FACTORS table.';
			              JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                          RAISE	FND_API.G_EXC_ERROR;

                       WHEN OTHERS THEN
            	          ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [6] OTHERS: ' ||
                                    SQLERRM;
			              JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);
                          RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
            		END;

                end loop;  -- all factors per combination
                end if; -- product combination <> 1 (for srinibas)
            end loop;  -- all product combinations
            l_counter_qtype_offset := l_counter;
        --end loop; -- per transaction type

        --  completion:API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --dbms_output.put_line(' ');


   EXCEPTION

	     WHEN FND_API.G_EXC_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_ERROR;
           RETCODE := 1;

 		   JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
           RETCODE := 2;

		   JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);


      WHEN  utl_file.invalid_path OR
						      utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
												utl_file.invalid_operation OR
            utl_file.write_error  THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF := 'JTF_TAE_CONTROL.Classify_Territories: [END] UTL_FILE: ' ||
                     SQLERRM;

		   JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);


      WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_CONTROL.Classify_Territories: [END] OTHERS: ' ||
                      SQLERRM;

		   JTF_TAE_CONTROL_PVT.Write_Log(2, ERRBUF);


    END Classify_Territories;


--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    Procedure (Private): Reduce_TX_OIN_Index_Set
--    ---------------------------------------------------
--    PURPOSE (SET REDUCTION)
--      Determines what qualifier relation combinations need to
--      have corresponding index built, by reducing sets of combinations
--      to the smallest number collectively exhaustive sets that are
--      ordinal supersets of all sets reduced.
--
--
--    REQIRES / DEPENDENCIES
--      JTF_TAE_QUAL_FACTORS
--      JTF_TAE_QUAL_PRODUCTS
--
--    MODIFIES
--      Rows in JTF_TAE_QUAL_PRODUCTS
--      Sets value of BUILD_INDEX_FLAG
--      Sets value of FIRST_CHAR (A FLAG)  ## NOT YET COMPLETED
--
--    EFFECTS
--      Allows TAP to efficiently run by noting what indicies need
--      to be created.
--

     PROCEDURE Reduce_TX_OIN_Index_Set
       (p_Api_Version_Number     IN  NUMBER,
        p_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
        p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
        p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
        p_source_id              IN  NUMBER,
        p_trans_id               IN NUMBER,
        x_Return_Status          OUT NOCOPY VARCHAR2,
        x_Msg_Count              OUT NOCOPY NUMBER,
        x_Msg_Data               OUT NOCOPY VARCHAR2
        )
    IS

        l_counter number := 0;
        startime date;
        l_first_char_flag VARCHAR2(1) := 'N';
        l_first_char_flag_count number;
        l_trans_id NUMBER;

        Cursor all_sets is
            select p.trans_object_type_id, count(*) num_components, p.qual_product_id qual_product_id, p.relation_product
            from JTF_TAE_QUAL_products p,
                 JTF_TAE_QUAL_prod_factors pf,
                 JTF_TAE_QUAL_factors f
            where p.qual_product_id = pf.qual_product_id
              and pf.qual_factor_id = f.qual_factor_id
              and f.tae_col_map is not null
              and p.source_id = p_source_id
              and p.trans_object_type_id = p_trans_id
            group by p.trans_object_type_id, p.qual_product_id, p.relation_product
            order by p.relation_product;

/*            select count(*) num_components, p.qual_product_id qual_product_id, p.relation_product
            from JTF_TAE_QUAL_products p,
                 JTF_TAE_QUAL_prod_factors pf
            where p.qual_product_id = pf.qual_product_id
            group by p.qual_product_id, p.relation_product
            order by 1;
*/

        Cursor larger_or_eq_sets( cl_size NUMBER
		                        , cl_qual_product_id NUMBER
								, cl_relation_product NUMBER ) is
            select * from (
                select count(*) num_components, p.qual_product_id qual_product_id, p.relation_product
                from JTF_TAE_QUAL_products p,
                    JTF_TAE_QUAL_prod_factors pf
                where p.qual_product_id = pf.qual_product_id
                and p.source_id = p_source_id
              and p.trans_object_type_id = p_trans_id
                group by p.qual_product_id, p.relation_product
            )
            where num_components >= cl_size
              and relation_product > cl_relation_product
            order by 1 DESC, qual_product_id ASC;

        Cursor all_empty_column_indexes is
            select p.trans_object_type_id, p.qual_product_id, p.relation_product
            from JTF_TAE_QUAL_products p
            where not exists (select *
                          from JTF_TAE_QUAL_products ip,
                               JTF_TAE_QUAL_prod_factors ipf,
                               JTF_TAE_QUAL_factors ifc

                          where use_tae_col_in_index_flag = 'Y'
                            and ip.qual_product_id = ipf.qual_product_id
                            and ipf.qual_factor_id = ifc.qual_factor_id
                            and ip.qual_product_id = p.qual_product_id)
              and p.source_id = p_source_id
              and p.trans_object_type_id = p_trans_id;


        cl_count NUMBER := 0;
        S_element_ord_subset_L_count NUMBER := 0;
        S_subset_L  VARCHAR2(1) := 'N';
        L_current_product NUMBER;

        retcode          VARCHAR2(100);
        errbuf           varchar2(3000);

    BEGIN
    --dbms_output.put_line('    JTF_TERR_AE_CONTROL.Set_Input_Qual_Indices : BEGIN ');
        startime := sysdate;
        l_trans_id := p_trans_id;


            for cl_set_S in all_sets loop -- OK
                S_subset_L := 'N';
                --dbms_output.put_line('    SIZE ' || cl_set_S.num_components ||  ' set elements.  : ' || cl_set_S.qual_product_id);

                -- set REDUCTION (done on input column)

                FOR cl_set_L IN larger_or_eq_sets( cl_set_S.num_components
				                                 , cl_set_S.qual_product_id
												 , cl_set_S.relation_product ) LOOP

                    --dbms_output.put_line('         Larger set ' || cl_set_L.qual_product_id);

                    select COUNT(*) into S_element_ord_subset_L_count
                    from  (
                          select rownum row_count, tae_col_map, input_selectivity
                          from (
                                select distinct p.relation_product, f.tae_col_map, f.input_selectivity
                                from JTF_TAE_QUAL_products p,
                                     JTF_TAE_QUAL_prod_factors pf,
                                     JTF_TAE_QUAL_factors f
                                where f.qual_factor_id = pf.qual_factor_id
                                  and pf.qual_product_id = p.qual_product_id
                                  and p.relation_product = cl_set_S.relation_product
                                  and f.tae_col_map is not null
                                   and p.source_id = p_source_id
                                   and p.trans_object_type_id = p_trans_id
                                order by input_selectivity
                              )
                          ) S,
                          (
                          select rownum row_count, tae_col_map, input_selectivity
                          from (
                                select distinct p.relation_product, f.tae_col_map, f.input_selectivity
                                from JTF_TAE_QUAL_products p,
                                     JTF_TAE_QUAL_prod_factors pf,
                                     JTF_TAE_QUAL_factors f
                                where f.qual_factor_id = pf.qual_factor_id
                                  and pf.qual_product_id = p.qual_product_id
                                  and p.relation_product = cl_set_L.relation_product
                                  and f.tae_col_map is not null
                                  and p.source_id = p_source_id
                                  and p.trans_object_type_id = p_trans_id
                                order by input_selectivity
                               )
                          ) L
                    where S.tae_col_map = L.tae_col_map
                        and  S.row_count = L.row_count;

                    -- for info only
                    L_current_product := cl_set_L.relation_product;
                    --dbms_output.put_line('          S_element_ord_subset_L_count ' || S_element_ord_subset_L_count);
                    --dbms_output.put_line('          cl_set_S.num_components ' || cl_set_S.num_components);

                    if S_element_ord_subset_L_count = cl_set_S.num_components then
                        S_subset_L := 'Y';
                        exit;
                    else
                        S_subset_L := 'N';
                    end if;

                end loop;  -- all larger sets L

                -- set FIRST_CHAR_FLAG for created index
                select count(*) into l_first_char_flag_count
                from
                   (select qual_usg_id, tae_col_map, rownum row_count
                    from (  select f.qual_usg_id, f.relation_factor, f.tae_col_map
                            from JTF_TAE_QUAL_prod_factors pf,
                                 JTF_TAE_QUAL_factors f
                            where pf.qual_factor_id = f.qual_factor_id
                                  and pf.qual_product_id = cl_set_S.qual_product_id
                            order by f.input_selectivity
                         )
                    ) ilv1,
                   (select qual_usg_id, 1 row_count
                    from jtf_qual_usgs_all
                    where org_id = -3113
                      and seeded_qual_id = -1012
                    ) ilv2
                where ilv1.qual_usg_id = ilv2.qual_usg_id
                  and ilv1.row_count = ilv2.row_count;

                if l_first_char_flag_count >  0 then
                    l_first_char_flag := 'Y';
                else
                    l_first_char_flag := 'N';
                end if;

                if S_subset_L = 'Y' then
                    --dbms_output.put_line('            ' || cl_set_S.relation_product || '  IS ordinal subset of ' || L_current_product);
                    UPDATE  JTF_TAE_QUAL_PRODUCTS
                    SET     BUILD_INDEX_FLAG = 'N', FIRST_CHAR_FLAG = l_first_char_flag
                    WHERE   qual_product_id = cl_set_S.qual_product_id

					  /* JDOCHERT: 10/12/03: INDEX SHOULD ALWAYS BE BUILT
					  ** ON THESE COMBINATIONS: ASSUMES THAT IN PROCEDURE,
					  ** Classify_Territories, THAT JTF_QUAL_PRODUCTS.BUILD_INDEX_FLAG
					  ** IS ALWAYS INITIALIZED TO 'Y'.
					  */
					  AND RELATION_PRODUCT NOT IN (4841, 324347);

		    /* ARPATEL: 10/20, still need to make sure that first_char_flag is set for 4841 and 324347 */
		   UPDATE   JTF_TAE_QUAL_PRODUCTS
               	      SET   FIRST_CHAR_FLAG = l_first_char_flag
                    WHERE   qual_product_id = cl_set_S.qual_product_id
		      AND   RELATION_PRODUCT IN (4841, 324347);


                else
                    --dbms_output.put_line('            ' || cl_set_S.relation_product || ' NOT an ordinal subset');
                    UPDATE  JTF_TAE_QUAL_PRODUCTS
                    SET     BUILD_INDEX_FLAG = 'Y', FIRST_CHAR_FLAG = l_first_char_flag
                    WHERE   qual_product_id = cl_set_S.qual_product_id;

                end if;

                /* ARPATEL: 04/16/2004 For Qual_Relation_Product = 353393 (Cust Name Range Group + Postal Code + Country)
                **                     we need to set first_char_flag to 'Y' to ensure that reverse index
                **                     (JTF_TAE_TN1002_324347X_ND) for 324347
                **                     is created, regardless of whether 324347 territories exist.
                */
		        UPDATE   JTF_TAE_QUAL_PRODUCTS
               	   SET   FIRST_CHAR_FLAG = 'Y'
                 WHERE   qual_product_id = cl_set_S.qual_product_id
		           AND   RELATION_PRODUCT = 353393;

            end loop;  -- all sets S

            -- Set reduction complete
            -- Set build_index_flag = 'N' for all empty column indexes combinations
            --dbms_output.put_line('Set reduction code running ');
            for empty_column_index in all_empty_column_indexes loop
                --dbms_output.put_line('BUILD_INDEX_FLAG = ''N'' for product_id: ' || empty_column_index.qual_product_id);
                update JTF_TAE_QUAL_PRODUCTS p
                set BUILD_INDEX_FLAG = 'N'
                where p.qual_product_id = empty_column_index.qual_product_id;
            end loop;

	   COMMIT;

        --  completion:API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION

	     WHEN FND_API.G_EXC_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_ERROR;

           IF G_Debug THEN
             Write_Log(2, ERRBUF);
           END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

           IF G_Debug THEN
             Write_Log(2, ERRBUF);
           END IF;

      WHEN  utl_file.invalid_path OR
						      utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
												utl_file.invalid_operation OR
            utl_file.write_error  THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF := 'JTF_TAE_CONTROL.Reduce_TX_OIN_Index_Set: [END] UTL_FILE: ' ||
                     SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

      WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_CONTROL.Reduce_TX_OIN_Index_Set: [END] OTHERS: ' ||
                      SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

    end Reduce_TX_OIN_Index_Set;


--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    Procedure (Public): Decompose_Terr_Defns
--    ---------------------------------------------------
--    PURPOSE
--      Main package API Interface.  Calls all procedures of
--      JTF_TERR_AE packages needed for running JTF Terr Assignment Engine,
--      the productized replacement of TAP.
--
--    REQIRES / DEPENDENCIES
--      JTF_TERR_AE_CONTROL Private procedures.
--
--    MODIFIES
--      Rows in JTF_TAE_QUAL_FACTORS/JTF_TAE_QUAL_PRODUCTS
--
--    EFFECTS
--      Allows TAP to run with select statements of terr-qual relation
--      combinations.
--
    PROCEDURE Decompose_Terr_Defns
       (p_Api_Version_Number     IN  NUMBER,
        p_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
        p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
        p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
        x_Return_Status          OUT NOCOPY VARCHAR2,
        x_Msg_Count              OUT NOCOPY NUMBER,
        x_Msg_Data               OUT NOCOPY VARCHAR2,
        p_run_mode               IN  VARCHAR2     := 'FULL',
        p_classify_terr_comb     IN  VARCHAR2     := 'Y',
        p_process_tx_oin_sel     IN  VARCHAR2     := 'Y',
        p_generate_indexes       IN  VARCHAR2     := 'Y',
        p_source_id              IN  NUMBER,
        p_trans_id               IN  NUMBER,
        ERRBUF                   OUT NOCOPY VARCHAR2,
        RETCODE                  OUT NOCOPY VARCHAR2 )

    IS
        x_runtime VARCHAR2(30);
        l_return_status          VARCHAR2(1);
        l_start_time             date;
        l_run_time               varchar2(300);
        l_dummy     NUMBER;
        l_source_id NUMBER := p_source_id;
        l_trans_id NUMBER := p_trans_id;
        --l_run_time  date;
        l_selectivity_return_val NUMBER;
        l_build_index_return_val NUMBER;
        l_dyn_str                varchar2(32767);
        l_trans_input_target     VARCHAR2(30);
        l_trans_matches_target   VARCHAR2(30);

    BEGIN
        l_start_time    := sysdate;
        --dbms_output.put_line('JTF_TERR_AE_CONTROL.Run_Terr_Assign_Engine : BEGIN');


        IF (p_source_id = -1001) THEN
            --dbms_output.put_line(' p_source_id = -1001 ');

            IF    (p_trans_id = -1002) THEN
              --ARPATEL 09/12/2003 OIC requirement
              IF p_run_mode = 'OIC_TAP' THEN

                l_trans_input_target   := 'JTF_TAE_1001_SC_TRANS';
                l_trans_matches_target := 'JTF_TAE_1001_SC_MATCHES';

              ELSE

                IF p_run_mode = 'NEW_MODE_TAP' THEN
                    l_trans_input_target   := 'JTF_TAE_1001_ACCOUNT_NM_TRANS';
                ELSE
                    l_trans_input_target   := 'JTF_TAE_1001_ACCOUNT_TRANS';
                END IF;

                l_trans_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';

              END IF; --run_mode=OIC_TAP

            ELSIF (p_trans_id = -1003) THEN
                IF p_run_mode = 'NEW_MODE_TAP' THEN
                    l_trans_input_target   := 'JTF_TAE_1001_LEAD_NM_TRANS';
                ELSE
                l_trans_input_target   := 'JTF_TAE_1001_LEAD_TRANS';
                END IF;
                l_trans_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';

            ELSIF (p_trans_id = -1004) THEN
                IF p_run_mode = 'NEW_MODE_TAP' THEN
                    l_trans_input_target   := 'JTF_TAE_1001_OPPOR_NM_TRANS';
                ELSE
                l_trans_input_target   := 'JTF_TAE_1001_OPPOR_TRANS';
                END IF;
                l_trans_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';

            END IF;

        END IF;

        IF p_run_mode = 'TAE2' THEN
            l_trans_input_target := 'JTF_TAE_1001_ACCOUNT_TRANS';
        END IF;

        -- check if source_id is valid
        if (l_source_id <> -1001) then
            raise FND_API.G_EXC_ERROR;
        end if;

/*
        --dbms_output.put_line('p_classify_terr_comb =  ' || p_classify_terr_comb);
        --dbms_output.put_line('p_process_tx_oin_sel = ' || p_process_tx_oin_sel);
        --dbms_output.put_line('p_generate_indexes = ' || p_generate_indexes);
*/

        -- ANALYSIS OF TERRITORY DEFINITION FOR DYN PACKAGE GENERATION
        if p_classify_terr_comb = 'Y' then

            -- must do this for all qual_types
            -- Classify_Territories
            Classify_Territories
               (p_Api_Version_Number =>    1.0,
                p_Init_Msg_List      =>    FND_API.G_FALSE,
                p_Commit             =>    FND_API.G_FALSE,
                p_validation_level   =>    FND_API.G_VALID_LEVEL_FULL,
                x_Return_Status      =>    l_return_status,
                x_Msg_Count          =>    x_msg_count,
                x_Msg_Data           =>    x_msg_data,
                p_source_id          =>    l_source_id,
                p_trans_id           =>    l_trans_id,
                errbuf               =>    ERRBUF,
                retcode              =>    RETCODE
                );

             --dbms_output.put_line('JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns: l_return_status= ' || l_return_status);
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

               ERRBUF := 'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS: [1]' ||
                         'CALL to JTF_TAE_CONTROL.Classify_Territories API has failed.';
               RAISE	FND_API.G_EXC_ERROR;

             END IF;

            update JTF_TAE_QUAL_factors
            set UPDATE_SELECTIVITY_FLAG = 'N', USE_TAE_COL_IN_INDEX_FLAG = 'N'
            where TAE_COL_MAP is null;

        end if;  -- p_classify_terr_comb?

        -- OPTIMIZATION OF DATABASE OBJECTS
        if p_process_tx_oin_sel = 'Y' or p_process_tx_oin_sel = 'R' then
            if p_process_tx_oin_sel = 'Y' then
                -- Analyze Selectivity and Get ordinals
                --dbms_output.put_line('    Analyze Selectivity and Get ordinals ');
                l_selectivity_return_val := jtf_tae_index_creation_pvt.selectivity(l_trans_input_target);

                IF l_selectivity_return_val <> 1 THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            end if;

            --dbms_output.put_line('    Reducing Sets ');
            -- Reduce Sets
            Reduce_TX_OIN_Index_Set
               (p_Api_Version_Number =>    1.0,
                p_Init_Msg_List      =>    FND_API.G_FALSE,
                p_Commit             =>    FND_API.G_FALSE,
                p_validation_level   =>    FND_API.G_VALID_LEVEL_FULL,
                p_source_id          =>    l_source_id,
                p_trans_id           =>    l_trans_id,
                x_Return_Status      =>    l_return_status,
                x_Msg_Count          =>    x_msg_count,
                x_Msg_Data           =>    x_msg_data
                );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

               ERRBUF := 'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS: [2]' ||
               'CALL to JTF_TAE_CONTROL.Reduce_TX_OIN_Index_Set API has failed.';
               RAISE	FND_API.G_EXC_ERROR;

             END IF;

        end if;  -- p_process_tx_oin_sel?

        if p_generate_indexes = 'Y' then
            --dbms_output.put_line('Dropping and Generating Indexes');
            -- Drop Indexes
            jtf_tae_index_creation_pvt.drop_table_indexes(
                                       p_table_name => l_trans_input_target
                                     , x_return_status => l_return_status);

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

               ERRBUF := 'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS: [3]' ||
                         'CALL to JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES ' ||
                         'API has failed.';
               RAISE	FND_API.G_EXC_ERROR;

             END IF;

             -- Build Indexes
             jtf_tae_index_creation_pvt.create_index(
                                       p_table_name           => l_trans_input_target
                                     , p_trans_object_type_id => l_trans_id
                                     , p_source_id            => l_source_id
                                     , x_Return_Status        => l_return_status
                                     , p_run_mode             => p_run_mode );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

               ERRBUF := 'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS: [4]' ||
                         'CALL to JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX ' ||
                         'API has failed.';
               RAISE	FND_API.G_EXC_ERROR;

             END IF;

            -- Analyze Trans Input Target
            /* JDOCHERT: 04/10/03: bug#2896552 */
            --JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
            --                           p_table_name    => l_trans_input_target
            --                         , p_percent       => 5
            --                         , x_Return_Status => l_return_status );
            -- IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            --   ERRBUF := 'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS: [5]' ||
            --             'CALL to JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX ' ||
            --             'API has failed.';
            --   RAISE	FND_API.G_EXC_ERROR;
            -- END IF;
            --


        END IF;

        --dbms_output.put_line('Decompose_Terr_Defns ran to completion');
        x_return_status := l_return_status;

   EXCEPTION

	     WHEN FND_API.G_EXC_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_ERROR;

           RETCODE := 2;

           IF G_Debug THEN
             Write_Log(2, ERRBUF);
           END IF;

      WHEN  utl_file.invalid_path OR
			utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
			utl_file.invalid_operation OR
            utl_file.write_error  THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RETCODE := 2;
           ERRBUF := 'JTF_TAE_CONTROL.Decompose_Terr_Defns: [END] UTL_FILE: ' ||
                     SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

      WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_CONTROL.Decompose_Terr_Defns: [END] OTHERS: ' ||
                      SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

    END Decompose_Terr_Defns;


 --    ---------------------------------------------------
 --    Start of Comments
 --    ---------------------------------------------------
 --    Procedure (Public): set_session_parameters
 --    ---------------------------------------------------
 --    PURPOSE
 --
 --    REQIRES / DEPENDENCIES
 --
 --    MODIFIES
 --
 --    EFFECTS
 --
 PROCEDURE set_session_parameters ( p_sort_area_size     NUMBER
                                  , p_hash_area_size     NUMBER ) AS

    l_dyn_csr        NUMBER;
    l_result         NUMBER;

    retcode          VARCHAR2(100);
    errbuf           varchar2(3000);

  BEGIN

				/*****

				-- Commented out since OSO TAP
				-- sets these parameters

    l_dyn_csr := dbms_sql.open_cursor;
    dbms_sql.parse( l_dyn_csr
                  , 'ALTER SESSION SET sort_area_size=' || TO_CHAR(p_sort_area_size)
                  , dbms_sql.native );
    l_result := dbms_sql.execute(l_dyn_csr);
    dbms_sql.close_cursor(l_dyn_csr);

    l_dyn_csr := dbms_sql.open_cursor;
    dbms_sql.parse( l_dyn_csr
                  , 'ALTER SESSION SET hash_area_size=' || TO_CHAR(p_hash_area_size)
                  , dbms_sql.native);
    l_result := dbms_sql.execute(l_dyn_csr);
    dbms_sql.close_cursor(l_dyn_csr);

    l_dyn_csr := dbms_sql.open_cursor;
    dbms_sql.parse( l_dyn_csr
                  , 'ALTER SESSION ENABLE PARALLEL DML'
                  , dbms_sql.native);
    l_result := dbms_sql.execute(l_dyn_csr);
    dbms_sql.close_cursor(l_dyn_csr);

				*****/

    NULL;

   EXCEPTION

      WHEN  utl_file.invalid_path OR
						      utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
												utl_file.invalid_operation OR
            utl_file.write_error  THEN

           RETCODE := 2;
           ERRBUF := 'JTF_TAE_CONTROL_PVT.set_session_parameters: [END] UTL_FILE: ' ||
                     SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

           RAISE;

      WHEN OTHERS THEN

           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_CONTROL_PVT.set_session_parameters: [END] OTHERS: ' ||
                      SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

           RAISE;

  END set_session_parameters;


--    ---------------------------------------------------
 --    Start of Comments
 --    ---------------------------------------------------
 --    Procedure (Public): set_table_nologging
 --    ---------------------------------------------------
 --    PURPOSE
 --
 --    REQIRES / DEPENDENCIES
 --
 --    MODIFIES
 --
 --    EFFECTS
 --
 PROCEDURE set_table_nologging( p_table_name VARCHAR2 ) AS

    l_dyn_csr             NUMBER;
    l_result              NUMBER;

				l_schema_name         VARCHAR2(30) := 'JTF';

    retcode               VARCHAR2(100);
    errbuf                varchar2(3000);

  BEGIN

    l_dyn_csr := dbms_sql.open_cursor;
    dbms_sql.parse( l_dyn_csr
                  , 'ALTER TABLE ' || l_schema_name || '.' || p_table_name || ' NOLOGGING '
                  , dbms_sql.native );
    l_result := dbms_sql.execute(l_dyn_csr);
    dbms_sql.close_cursor(l_dyn_csr);

   EXCEPTION

      WHEN  utl_file.invalid_path OR
						      utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
												utl_file.invalid_operation OR
            utl_file.write_error  THEN

           RETCODE := 2;
           ERRBUF := 'JTF_TAE_CONTROL_PVT.set_table_nologging: [END] UTL_FILE: ' ||
                     SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

           RAISE;

      WHEN OTHERS THEN

           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_CONTROL_PVT.set_table_nologging: [END] OTHERS: ' ||
                      SQLERRM;

           If G_Debug Then
              Write_Log(2, ERRBUF);
           End If;

           RAISE;

  END set_table_nologging;

END JTF_TAE_CONTROL_PVT;

/
