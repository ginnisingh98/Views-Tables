--------------------------------------------------------
--  DDL for Package Body JTF_TAE_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TAE_ASSIGN_PUB" AS
/* $Header: jtftaeab.pls 120.0 2005/06/02 18:21:08 appldev ship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_ASSIGN_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force applications territory manager public api's.
--      This package is a public API for getting winning territories
--      or territory resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--      Valid values for USE_TYPE:
--          TERRITORY - return only the distinct winning territories
--          RESOURCE  - return resources of all winning territories
--          LOOKUP    - return resource information as needed in territory Lookup
--
--          Program Flow:
--              Check usage to call proper API.
--                  set output to lx_win_rec
--              Process lx_win_rec for output depending on USE_TYPE
--
--
--      Terminology:    ---------------------------------------------------------
--
--          Variable Names
--                  use_type        variable Name
--                  -----------------------------------
--                  RESOURCE        <not needed - simply copy dyn ouput to API output>
--                  TERRITORY       lx_terr_win_rec
--                  LOOKUP          lx_lookup_bulk_winners_rec
--
--
--    HISTORY
--      03/22/2002  EIHSU       CREATED
--      03/22/2002  EIHSU       Number of Winners processing
--      04/03/2002  EIHSU       Striped by transaction type
--      04/08/2002  EIHSU       Additions after code review
--      04/11/2002  EIHSU       Delete index from mathes table in delete procedure
--      04/11/2002  EIHSU       Fix access type resource name issue.
--      07/22/2003  EIHSU       Multi variable num winners processing fix: add LX restriction
--      08/14/2003  EIHSU       Putting in Parallel processing for 11.5.10
--                              This was previously added on 6/12/2003 in ver 115.42
--      08/25/2003  EIHSU       Verified Multi-variable num winners proc in parallel
--      10/11/2004  ACHANDA     Bug 3920951 fix
--      11/09/2004  ACHANDA     Bug 3993227 fix
--      12/08/2004  ACHANDA     Bug 4048033 fix : added full table hint while inserting into %L1 tables
--      04/12/2005  ACHANDA     Bug 4307593 fix : remove the update to worker_id for new mode TAP
--      04/26/2005  ACHANDA     Bug 4329939 fix : remove the distinct clause in the sql statement which inserts data
--                                                into winners table and also reorder the tables in the level processing
--

--    End of Comments

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************

   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TAE_ASSIGN_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtftaeab.pls';

   G_NEW_LINE        VARCHAR2(02) := fnd_global.local_chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;

   NO_TAE_DATA_FOUND		EXCEPTION;

/******************* FYI: FND_API STUFF ********************************

--  API return status
--
--  G_RET_STS_SUCCESS means that the API was successful in performing
--  all the operation requested by its caller.
--
--  G_RET_STS_ERROR means that the API failed to perform one or more
--  of the operations requested by its caller.
--
--  G_RET_STS_UNEXP_ERROR means that the API was not able to perform
--  any of the operations requested by its callers because of an
--  unexpected error.
--
--G_RET_STS_SUCCESS   	CONSTANT    VARCHAR2(1)	:=  'S';
--G_RET_STS_ERROR	      	CONSTANT    VARCHAR2(1)	:=  'E';
--G_RET_STS_UNEXP_ERROR  	CONSTANT    VARCHAR2(1)	:=  'U';

--  API error exceptions.
--  G_EXC_ERROR :   Is used within API bodies to indicate an error,
--		    this exception should always be handled within the
--		    API body and p_return_status shoul;d be set to
--		    error. An API should never return this exception.
--  G_EXC_UNEXPECTED_ERROR :
--		    Is raised by APIs when encountering an unexpected
--		    error.
--
--G_EXC_ERROR		EXCEPTION;
--G_EXC_UNEXPECTED_ERROR 	EXCEPTION;

***************************************************/

--    ***************************************************
--    API Body Definitions
--    ***************************************************

PROCEDURE GET_NUM_ROWS( p_table_name     IN   VARCHAR2
                      , x_num_rows       OUT NOCOPY  NUMBER
                      , x_return_status  OUT NOCOPY  VARCHAR2 ) IS

    retcode          VARCHAR2(100);
    errbuf           varchar2(3000);
    v_statement      varchar2(800);

    l_status         VARCHAR2(30);
    l_industry       VARCHAR2(30);
    l_jtf_schema     VARCHAR2(30);

    L_SCHEMA_NOTFOUND  EXCEPTION;
BEGIN
    x_num_rows := 0;

    IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
      NULL;
    END IF;

    IF (l_jtf_schema IS NULL) THEN
      RAISE L_SCHEMA_NOTFOUND;
    END IF;

    SELECT num_rows
    INTO   x_num_rows
    FROM   all_tables
    WHERE  owner = l_jtf_schema
    AND    table_name = p_table_name;

    If JTF_TAE_CONTROL_PVT.G_DEBUG Then
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_NUM_ROWS: Number of rows for the table ' ||
           p_table_name || ' : ' || x_num_rows);
    End If;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RETCODE := 2;
     ERRBUF  := 'JTF_TAE_ASSIGN_PUB.GET_NUM_ROWS: [END] SCHEMA NAME FOUND CORRESPONDING TO JTF APPLICATION. ';

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

  WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RETCODE := 2;
     ERRBUF  := 'JTF_TAE_ASSIGN_PUB.GET_NUM_ROWS: [END] OTHERS: ' ||
                p_table_name || ': ' || SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;


END GET_NUM_ROWS;

  PROCEDURE get_winners
  (   p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN          VARCHAR2,
      p_Debug_Flag            IN          VARCHAR2,
      x_return_status         OUT NOCOPY         VARCHAR2,
      x_msg_count             OUT NOCOPY         NUMBER,
      x_msg_data              OUT NOCOPY         VARCHAR2,
      p_request_id            IN          NUMBER,
      p_source_id             IN          NUMBER,
      p_trans_object_type_id  IN          NUMBER,
      p_target_type           IN          VARCHAR2 := 'TAP',
      ERRBUF                  OUT NOCOPY         VARCHAR2,
      RETCODE                 OUT NOCOPY         VARCHAR2
  )
  AS

     l_api_name                   CONSTANT VARCHAR2(30) := 'Get_Winners';
     l_api_version_number         CONSTANT NUMBER       := 1.0;
     l_return_status              VARCHAR2(1);
     l_count1                     NUMBER := 0;
     l_count2                     NUMBER := 0;
     l_RscCounter                 NUMBER := 0;
     l_NumberOfWinners            NUMBER ;

     lp_sysdate                   DATE   := SYSDATE;
     l_rsc_counter                NUMBER := 0;
     l_dyn_str                    VARCHAR2(32767);
     num_of_terr                  NUMBER;
     num_of_trans                 NUMBER;
	 d_statement                  VARCHAR2(2000);

     l_trans_target               VARCHAR2(30);
     l_matches_target             VARCHAR2(30);
     l_winners_target             VARCHAR2(30);
     l_terr_L1_target             VARCHAR2(30);
     l_terr_L2_target             VARCHAR2(30);
     l_terr_L3_target             VARCHAR2(30);
     l_terr_L4_target             VARCHAR2(30);
     l_terr_L5_target             VARCHAR2(30);
     l_terr_WT_target             VARCHAR2(30);

     l_matches_idx                VARCHAR2(30);

     l_access_list                VARCHAR2(300);
     l_truncate_matches_rtn_val   NUMBER;
     l_create_idx_match_rtn_val   NUMBER;

     lX_Msg_Data         VARCHAR2(2000);
     lx_runtime          VARCHAR2(300);

     l_worker_id         NUMBER := 1;
   BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* If the debug flag is set, Then turn on the debug message logging */
     If UPPER( rtrim(p_Debug_Flag) ) = 'Y' Then
        JTF_TAE_CONTROL_PVT.G_DEBUG := TRUE;
     End If;

     /* ARPATEL: 12/15/2003: Bug#3305019 */
     --If UPPER(p_SQL_Trace) = 'Y' Then
     --   dbms_session.set_sql_trace(TRUE);
     --Else
     --   dbms_session.set_sql_trace(FALSE);
     --End If;

     -- 05/16/02: JDOCHERT
     -- Need COMMIT to avoid the following error:
     -- ORA-12841: Cannot alter the session parallel DML state within a transaction
     -- in the call to JTF_TAE_CONTROL_PVT.set_session_parameters below
     ---
     COMMIT;

     /* Standard call to check for call compatibility. */
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          G_PKG_NAME)  THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE. */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MEM_TASK_START');
        FND_MSG_PUB.Add;
     END IF;

     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, '/***************** BEGIN: TERRITORY ASSIGNMENT STATUS *********************/');
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS start....');
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'source_id            = ' || TO_CHAR(p_source_Id) );
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'trans_object_type_id = ' || TO_CHAR(p_trans_object_type_id) );

     /* JDOCHERT 05/05/02: Commented out settings in JTF_TAE_CONTROL
     ** since OSO TAP program has these paramaters
		   */
     --JTF_TAE_CONTROL_PVT.set_session_parameters
     --                 ( p_sort_area_size => 100000000
     --                 , p_hash_area_size => 200000000);

     -----------------------------------------------------------
     -- logic control to see which dyn package should be called
     -----------------------------------------------------------
     IF ( p_target_type = 'TAP' ) THEN

        IF ( p_source_id = -1001 ) THEN

           ------dbms_output.put_line(' p_source_id = -1001 ');

          IF (p_trans_object_type_id = -1002) THEN

              l_trans_target := 'JTF_TAE_1001_ACCOUNT_TRANS';
              l_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';
              l_winners_target := 'JTF_TAE_1001_ACCOUNT_WINNERS';

              l_terr_L1_target := 'JTF_TAE_1001_ACCOUNT_L1';
              l_terr_L2_target := 'JTF_TAE_1001_ACCOUNT_L2';
              l_terr_L3_target := 'JTF_TAE_1001_ACCOUNT_L3';
              l_terr_L4_target := 'JTF_TAE_1001_ACCOUNT_L4';
              l_terr_L5_target := 'JTF_TAE_1001_ACCOUNT_L5';
              l_terr_WT_target := 'JTF_TAE_1001_ACCOUNT_WT';

              l_access_list := ' ''ACCOUNT'' ';


          ELSIF (p_trans_object_type_id = -1003) THEN

              l_trans_target := 'JTF_TAE_1001_LEAD_TRANS';
              l_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';
              l_winners_target := 'JTF_TAE_1001_LEAD_WINNERS';

              l_terr_L1_target := 'JTF_TAE_1001_LEAD_L1';
              l_terr_L2_target := 'JTF_TAE_1001_LEAD_L2';
              l_terr_L3_target := 'JTF_TAE_1001_LEAD_L3';
              l_terr_L4_target := 'JTF_TAE_1001_LEAD_L4';
              l_terr_L5_target := 'JTF_TAE_1001_LEAD_L5';
              l_terr_WT_target := 'JTF_TAE_1001_LEAD_WT';

              l_access_list := ' ''LEAD'' ';

          ELSIF (p_trans_object_type_id = -1004) THEN

              l_trans_target := 'JTF_TAE_1001_OPPOR_TRANS';
              l_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';
              l_winners_target := 'JTF_TAE_1001_OPPOR_WINNERS';

              l_terr_L1_target := 'JTF_TAE_1001_OPPOR_L1';
              l_terr_L2_target := 'JTF_TAE_1001_OPPOR_L2';
              l_terr_L3_target := 'JTF_TAE_1001_OPPOR_L3';
              l_terr_L4_target := 'JTF_TAE_1001_OPPOR_L4';
              l_terr_L5_target := 'JTF_TAE_1001_OPPOR_L5';
              l_terr_WT_target := 'JTF_TAE_1001_OPPOR_WT';

              l_access_list := ' ''OPPOR'' ';

          END IF; -- what tx type

        END IF; -- what usage

        /* set NOLOGGING on JTF_TAE_..._MATCHES and JTF_TAE_..._WINNERS tables */
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_trans_target);

        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_matches_target);

        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L1_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L2_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L3_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L4_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L5_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_WT_target);

        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_winners_target);

        -----------
        --- [2] ---
      		-----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [1] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API BEGINS ' ||
                    					                'for ' ||	l_matches_target);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_matches_target
                            , x_return_status => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

          ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [1] Call to ' ||
                    'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
   					l_matches_target;

          RAISE	FND_API.G_EXC_ERROR;

        END IF;

        -----------
        --- [3] ---
		      -----------
	       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [2] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API BEGINS ' ||
								                                 'for ' ||	l_winners_target);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name    => l_winners_target
                            , x_return_status => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [2] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
					                l_winners_target;

           RAISE	FND_API.G_EXC_ERROR;

        END IF;

        -----------
        --- [3] ---
    	   -----------
        BEGIN

           -- Check for territories for this Usage/Transaction Type
           SELECT COUNT(*)
           INTO num_of_terr
           FROM    jtf_terr_qtype_usgs_all jtqu
                 , jtf_terr_usgs_all jtu
                 , jtf_terr_all jt1
                 , jtf_qual_type_usgs jqtu
           WHERE jtqu.terr_id = jt1.terr_id
             AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
             AND jqtu.qual_type_id = p_trans_object_type_id
             AND jtu.source_id = p_source_id
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
             AND jqtu.qual_type_id <> -1001;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              num_of_terr := 0;
        END;

	       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [3] Number of valid ' ||
                                          'Territories with Resources for this Transaction: ' ||
    				     		                           num_of_terr );

        -- 2357180: ERROR HANDLING FOR NO TERRITORY DATA:
        --          AFTER MATCHES AND WINNERS TABLES HAVE BEEN TRUNCATED
        IF (num_of_terr = 0) THEN

           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [3] There are NO Active Territories with Active ' ||
    							          'Resources existing for this Usage/Transaction combination, so no assignments ' ||
    									        'can take place.';

           RAISE	NO_TAE_DATA_FOUND;

        END IF;

        -----------
        --- [4] ---
    	   ----------
        BEGIN

           d_statement := ' SELECT COUNT(*) FROM ' ||
                          l_trans_target ||
                          ' WHERE rownum < 2 ';
           EXECUTE IMMEDIATE d_statement INTO num_of_trans;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              num_of_trans := 0;
        END;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [4] ' ||
    				    		         'There are valid Transaction Objects to be assigned.');

        IF (num_of_trans = 0) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [4] There are NO valid ' ||
                     'Transaction Objects to assign.';
           RAISE	NO_TAE_DATA_FOUND;
        END IF;

        -------------
        --- [4.1] --- BACKWARDS COMPATIBILITY FOR PARALLEL PROCESSING ARCHITECTURE
    	-------------
        /* If you called this procedure then you are not using parallel processing.
           Default worker number needs to be set.

           06/12/2003
           NOTE: UNDER NO CIRCUMSTANCES should this step behind phase 6, when Trans table
                 indexes actually created.

        */

        BEGIN

           d_statement := ' UPDATE ' || l_trans_target || ' SET worker_id = 1';
           EXECUTE IMMEDIATE d_statement;

        EXCEPTION
            WHEN OTHERS THEN
                JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
                JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [4.1] ' ||
             				    		         'Exception while setting worker_id to 1');

                ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [4.1] Exception while setting worker_id to 1.';
                RAISE NO_TAE_DATA_FOUND;
        END;

        -----------
        --- [5] ---
        -----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [5] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API BEGINS ' ||
								                                 'for ' ||	l_trans_target);

        -- Analyze _TRANS table
        -- JDOCHERT: 04/10/03: bug#2896552
        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_trans_target
                                  , p_percent       => 99
                                  , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [5] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' ||
                     l_trans_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        -----------
        --- [6] ---
      		-----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [6] Call to ' ||
                                         'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS API BEGINS...');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');

        JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns
            (p_Api_Version_Number     => 1.0,
             p_Init_Msg_List          => FND_API.G_FALSE,
             p_Commit                 => FND_API.G_FALSE,
             p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
             x_Return_Status          => x_return_status,
             x_Msg_Count              => x_msg_count,
             x_Msg_Data               => x_msg_data,
             p_run_mode               => 'FULL',
             p_classify_terr_comb     => 'N',
             p_process_tx_oin_sel     => 'Y',
             p_generate_indexes       => 'Y',
             p_source_id              => p_source_id,
             p_trans_id               => p_trans_object_type_id,
             errbuf                   => ERRBUF,
             retcode                  => RETCODE );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [6] Call to ' ||
                     'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS API has failed.';
           RAISE	FND_API.G_EXC_ERROR;
       END IF;

        -----------
        --- [7] ---
	    -----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [7] Call to ' ||
                                        'JTF_TAE_1001_..._DYN.SEARCH_TERR_RULES API BEGINS... ');

        -- Start MATCH processing
        IF (p_trans_object_type_id = -1002) THEN

           JTF_TAE_1001_ACCOUNT_DYN.Search_Terr_Rules(
                          p_source_id             => p_source_id ,
                          p_trans_object_type_id  => p_trans_object_type_id,
                          x_Return_Status         => x_return_status,
                          x_Msg_Count             => x_msg_count,
                          x_Msg_Data              => x_msg_data );

        ELSIF (p_trans_object_type_id = -1003) THEN

           JTF_TAE_1001_LEAD_DYN.Search_Terr_Rules(
                          p_source_id             => p_source_id ,
                          p_trans_object_type_id  => p_trans_object_type_id,
                          x_Return_Status         => x_return_status,
                          x_Msg_Count             => x_msg_count,
                          x_Msg_Data              => x_msg_data );

        ELSIF (p_trans_object_type_id = -1004) THEN

           JTF_TAE_1001_OPPOR_DYN.Search_Terr_Rules(
                          p_source_id             => p_source_id ,
                          p_trans_object_type_id  => p_trans_object_type_id,
                          x_Return_Status         => x_return_status,
                          x_Msg_Count             => x_msg_count,
                          x_Msg_Data              => x_msg_data );

        END IF; -- what tx type

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [7] Call to ' ||
                     'JTF_TAE_1001_..._DYN.SEARCH_TERR_RULES API has failed.';
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -----------
        --- [8] ---
      		-----------
        -- 05/16/02: JDOCHERT:
        -- With new NOWP processing using RANK() function,
        -- we no longer need INDEX on _MATCH table.

        -----------
        --- [9] ---
      		-----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [9] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API BEGINS ' ||
								                                 'for ' ||	l_matches_target);

        -- Analyze Matches table
        -- JDOCHERT: 04/10/03: bug#2896552
        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_matches_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [9] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' ||
                     l_matches_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -----------
        --- [10] ---
      		-----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10] Call to ' ||
                                         'MULTI-LEVEL TABLE CLEANUP BEGINS...');

        ----dbms_output.put_line('10.1: Truncate Level Winners Tables ');
        -- 10.1: Truncate Level Winners Tables
        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L1_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L1_target;
           RAISE	FND_API.G_EXC_ERROR;
         END IF;

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L2_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10.2] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L2_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L3_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10.3] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L3_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L4_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10.4] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L4_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L5_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10.5] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L5_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_WT_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [10.6] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_WT_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [11] Call to ' ||
                                         'MULTI-LEVEL NUMBER OF WINNERS PROCESSING BEGINS...');

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        --dbms_output.put_line('10.2: Process Level Winners ');
        -- 11: Process Level Winners
        --     NOTE: p_terr_PARENT_LEVEL_tbl arg ingnored here as we process top level
        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L1_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L1_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 1,
                                p_LOWER_LEVEL_FROM_ROOT  => 1,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => 1
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L1_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L1_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L2_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L1_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 1,
                                p_LOWER_LEVEL_FROM_ROOT  => 2,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => 1
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.2] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L2_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L2_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;
        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L3_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L2_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 2,
                                p_LOWER_LEVEL_FROM_ROOT  => 3,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => 1
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.3] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L3_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L3_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;
        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L4_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L3_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 3,
                                p_LOWER_LEVEL_FROM_ROOT  => 4,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => 1
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.4] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L4_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L4_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;
        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L5_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L4_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 4,
                                p_LOWER_LEVEL_FROM_ROOT  => 5,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => 1
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.5] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L5_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L5_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        Process_Final_Level_Winners (
                                p_terr_LEVEL_target_tbl  => l_terr_WT_target,
                                p_terr_L5_target_tbl     => l_terr_L5_target,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => 1
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.6] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_WT_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_WT_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [12] Call to ' ||
                                         'WINNING TERRITORY RESOURCE PROCESSING BEGINS...');

        --dbms_output.put_line('12: Fetch Winners and Resources ');
        -- 12.0: Fetch Winners and Resources

         /* 05/16/02: JDOCHERT:
         ** No longer create MATCHES INDEX, so INDEX hint is obsolete
         ** l_matches_idx := REPLACE(UPPER(l_matches_target), 'ES', NULL);
         */

        l_dyn_str :=
           ' INSERT INTO ' ||
           l_winners_target || ' i ' ||
           ' ( ' ||
           ' 	 TRANS_OBJECT_ID        ' ||
           ' 	,TRANS_DETAIL_OBJECT_ID ' ||
	   ' 	,WORKER_ID ' || /* ARPATEL 05/03/2004 Bug#3608474 */

           /*
           ** 07/17/03 JDOCHERT: NOT USED
           **' 	,HEADER_ID1             ' ||
           **' 	,HEADER_ID2             ' ||
           */

           ' 	,SOURCE_ID              ' ||
           ' 	,TRANS_OBJECT_TYPE_ID   ' ||
           ' 	,LAST_UPDATE_DATE       ' ||
           ' 	,LAST_UPDATED_BY        ' ||
           ' 	,CREATION_DATE          ' ||
           ' 	,CREATED_BY             ' ||
           '	 ,LAST_UPDATE_LOGIN      ' ||
           '	 ,REQUEST_ID             ' ||
           '	 ,PROGRAM_APPLICATION_ID ' ||
           '	 ,PROGRAM_ID             ' ||
           '	 ,PROGRAM_UPDATE_DATE    ' ||
           '	 ,TERR_ID                ' ||
           '	 ,ABSOLUTE_RANK          ' ||
           '	 ,TOP_LEVEL_TERR_ID      ' ||
           '	 ,RESOURCE_ID            ' ||
           '	 ,RESOURCE_TYPE          ' ||
           '	 ,GROUP_ID               ' ||
           '	 ,ROLE                   ' ||
           '	 ,PRIMARY_CONTACT_FLAG   ' ||
           '	 ,PERSON_ID              ' ||
           '	 ,ORG_ID                 ' ||
           '	 ,TERR_RSC_ID            ' ||
           '	 ,FULL_ACCESS_FLAG       ' ||
           ' ) ' ||
           ' ( ' ||

           --
           --  10/02/02: JDOCHERT: BUG#2594526 and BUG#2602646
           --
           --'   SELECT /*+   ' ||
           --'              INDEX (jtr JTF_TERR_RSC_N1) ' ||
           --'              INDEX (jtra JTF_TERR_RSC_ACCESS_N1) ' ||
           --'          */ ' ||
           --

           '     SELECT DISTINCT ' ||
           '          WINNERS.trans_object_id         ' ||
           '        , WINNERS.trans_detail_object_id  ' ||
           '        , 1  ' || /* ARPATEL 05/03/2004 Bug#3608474 Default value to 1 for non-parallel get_winners */

           /*
           ** 07/17/03 JDOCHERT: NOT USED
           **'        , 0 header_id1  ' ||  --  o_dttm.header_id1   ' ||
           **'        , 0 header_id2  ' ||  --  o_dttm.header_id2   ' ||
           */

           '        , :BV1_SOURCE_ID                 ' ||
           '        , :BV1_TRANS_OBJECT_TYPE_ID      ' ||
           '        , :BV1_LAST_UPDATE_DATE          ' ||
           '        , :BV1_LAST_UPDATED_BY           ' ||
           '        , :BV1_CREATION_DATE             ' ||
           '        , :BV1_CREATED_BY                ' ||
           '        , :BV1_LAST_UPDATE_LOGIN         ' ||
           '        , :BV1_REQUEST_ID                ' ||
           '        , :BV1_PROGRAM_APPLICATION_ID    ' ||
           '        , :BV1_PROGRAM_ID                ' ||
           '        , :BV1_PROGRAM_UPDATE_DATE       ' ||
           '        , WINNERS.WIN_terr_id            ' ||
           '        , null absolute_rank             ' ||  /*  o_dttm.absolute_rank     ' || */
           '        , null top_level_terr_id         ' ||  /*  o_dttm.top_level_terr_id ' || */
           '        , jtr.resource_id                ' ||
           '        , jtr.resource_type              ' ||
           '        , jtr.group_id                   ' ||
           '        , jtr.role                       ' ||
           '        , jtr.primary_contact_flag       ' ||
           '        , jtr.PERSON_ID                  ' ||
           '        , jtr.org_id                     ' ||
           '        , jtr.terr_rsc_id                ' ||
           '        , jtr.full_access_flag           ' ||
           '    FROM ( /* WINNERS ILV */ ' ||
           '           SELECT LX.trans_object_id ' ||
           '                , LX.trans_detail_object_id ' ||
           '                , LX.WIN_TERR_ID ' ||
           '           FROM ' || l_terr_L1_target || ' LX ' ||
           '              , ( SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , WIN_TERR_ID WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L1_target ||
           '                  MINUS ' ||
           '                  SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , ul_terr_id WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L2_target || '  ) ILV ' ||
           '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
           '                   LX.trans_detail_object_id IS NULL ) ' ||
           '             AND LX.trans_object_id = ILV.trans_object_id ' ||
           '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

           '           UNION ALL ' ||

           '           SELECT LX.trans_object_id ' ||
           '                , LX.trans_detail_object_id ' ||
           '                , LX.WIN_TERR_ID ' ||
           '           FROM ' || l_terr_L2_target || ' LX ' ||
           '              , ( SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , WIN_TERR_ID WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L2_target ||
           '                  MINUS ' ||
           '                  SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , ul_terr_id WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L3_target || '  ) ILV ' ||
           '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
           '                   LX.trans_detail_object_id IS NULL ) ' ||
           '             AND LX.trans_object_id = ILV.trans_object_id ' ||
           '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

           '           UNION ALL ' ||

           '           SELECT LX.trans_object_id ' ||
           '                , LX.trans_detail_object_id ' ||
           '                , LX.WIN_TERR_ID ' ||
           '           FROM ' || l_terr_L3_target || ' LX ' ||
           '              , ( SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , WIN_TERR_ID WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L3_target ||
           '                  MINUS ' ||
           '                  SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , ul_terr_id WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L4_target || '  ) ILV ' ||
           '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
           '                   LX.trans_detail_object_id IS NULL ) ' ||
           '             AND LX.trans_object_id = ILV.trans_object_id ' ||
           '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

           '           UNION ALL ' ||

           '           SELECT LX.trans_object_id ' ||
           '                , LX.trans_detail_object_id ' ||
           '                , LX.WIN_TERR_ID ' ||
           '           FROM ' || l_terr_L4_target || ' LX ' ||
           '              , ( SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , WIN_TERR_ID WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L4_target ||
           '                  MINUS ' ||
           '                  SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , ul_terr_id WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L5_target || '  ) ILV ' ||
           '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
           '                   LX.trans_detail_object_id IS NULL ) ' ||
           '             AND LX.trans_object_id = ILV.trans_object_id ' ||
           '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

           '           UNION ALL ' ||

           '           SELECT LX.trans_object_id ' ||
           '                , LX.trans_detail_object_id ' ||
           '                , LX.WIN_TERR_ID ' ||
           '           FROM ' || l_terr_L5_target || ' LX ' ||
           '              , ( SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , WIN_TERR_ID WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_L5_target ||
           '                  MINUS ' ||
           '                  SELECT trans_object_id ' ||
           '                       , trans_detail_object_id ' ||
           '                       , ul_terr_id WIN_TERR_ID ' ||
           '                  FROM ' || l_terr_WT_target || '  ) ILV ' ||
           '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
           '                   LX.trans_detail_object_id IS NULL ) ' ||
           '             AND LX.trans_object_id = ILV.trans_object_id ' ||
           '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

           '           UNION ALL ' ||

           '           SELECT trans_object_id ' ||
           '                , trans_detail_object_id ' ||
           '                , WIN_TERR_ID ' ||
           '           FROM ' || l_terr_WT_target ||
           '         ) WINNERS ' ||
           '         , jtf_terr_rsc_all jtr ' ||
           '         , jtf_terr_rsc_access_all jtra ' ||
           '    WHERE  WINNERS.WIN_terr_id = jtr.terr_id ' ||
           '      AND ( ( jtr.end_date_active IS NULL OR jtr.end_date_active >= :BV1_SYSDATE ) AND  ' ||
           '            ( jtr.start_date_active IS NULL OR jtr.start_date_active <= :BV2_SYSDATE )  ' ||
           '           ) ' ||
           '      AND jtr.terr_rsc_id = jtra.terr_rsc_id ' ||
           '      AND jtra.access_type = ' || l_access_list ||
           ' ) ';


        BEGIN

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

          EXECUTE IMMEDIATE l_dyn_str USING
              p_source_id              /* :BV1_SOURCE_ID */
            , p_trans_object_type_id   /* :BV1_TRANS_OBJECT_TYPE_ID */
            , lp_sysdate               /* :BV1_LAST_UPDATE_DATE */
            , G_USER_ID                /* :BV1_LAST_UPDATED_BY */
            , lp_sysdate               /* :BV1_CREATION_DATE */
            , G_USER_ID                /* :BV1_CREATED_BY */
            , G_LOGIN_ID               /* :BV1_LAST_UPDATE_LOGIN */
            , p_request_id              /* :BV1_REQUEST_ID */
            , G_APPL_ID                 /* :BV1_PROGRAM_APPLICATION_ID */
            , G_PROGRAM_ID              /* :BV1_PROGRAM_ID */
            , lp_sysdate                /* :BV1_PROGRAM_UPDATE_DATE */
            , lp_sysdate                /* :BV1_SYSDATE    */
            , lp_sysdate;               /* :BV2_SYSDATE    */


          COMMIT;  -- after modifying table in parallel

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL;
        END;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --dbms_output.put_line(' phase 10 complete ');

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Number of records inserted into ' || l_winners_target ||
                                         ' = ' || SQL%ROWCOUNT );
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [12] Call to ' ||
                                         'NUMBER OF WINNERS PROCESSING COMPLETE.');

        -----------
        --- [13] ---
        -----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [13] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_winners_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_winners_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [13] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_winners_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -----------
        --- [14] ---
      		-----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [14] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API BEGINS ' ||
                                         'for ' ||	l_winners_target);

        /* Analyze Winners table */
        /* JDOCHERT: 04/10/03: bug#2896552 */
        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_winners_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [14] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' ||
                     l_winners_target;
           RAISE	FND_API.G_EXC_ERROR;
         END IF;

     ELSIF p_target_type ='RPT' THEN
        NULL;
     END IF;  -- RPT OR TAP

     --------------------------------
     -- END API
     --------------------------------
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, '/***************** END: TERRITORY ASSIGNMENT STATUS *********************/');
     JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');

     /* Program completed successfully */
     ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: Successfully completed.';
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     RETCODE := 0;

  EXCEPTION

		WHEN NO_TAE_DATA_FOUND THEN

        x_return_status     := FND_API.G_RET_STS_SUCCESS;

        RETCODE := 1;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [END] NO_TAE_DATA_FOUND: ' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status     := FND_API.G_RET_STS_ERROR;

        RETCODE := 2;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [END] FND_API.G_EXC_ERROR: ' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

        RETCODE := 2;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: FND_API.G_EXC_UNEXPECTED_ERROR: ' ||
                  SQLERRM;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

     WHEN  utl_file.invalid_path OR
		         utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR
		         utl_file.invalid_operation OR
           utl_file.write_error  THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETCODE := 2;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [END] UTL_FILE: ' ||
                  SQLERRM;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

     WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETCODE := 2;
        ERRBUF  := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [END] OTHERS: ' ||
                   SQLERRM;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

  End  Get_Winners;

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Drop_TAE_TRANS_Indexes
    --    type           : public.
    --    function       : Drop_TX_Input_Indexes
    --    pre-reqs       :
    --    notes:
    --
    PROCEDURE Drop_TAE_TRANS_Indexes
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        x_return_status         OUT NOCOPY         VARCHAR2,
        p_source_id             IN          NUMBER,
        p_trans_object_type_id  IN          NUMBER,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    )
    AS
      l_trans_target             varchar2(30);
      l_matches_target           varchar2(30);
      l_winners_target           varchar2(30);
      l_source_id                number := p_source_id;
      l_trans_id                 number := p_trans_object_type_id;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

         /* Sales and Telesales/Account */
        IF (l_source_id = -1001) THEN

            IF (l_trans_id = -1002) THEN
                l_trans_target := 'JTF_TAE_1001_ACCOUNT_TRANS';
                l_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';
                l_winners_target := 'JTF_TAE_1001_ACCOUNT_WINNERS';

            ELSIF (l_trans_id = -1003) THEN
                l_trans_target := 'JTF_TAE_1001_LEAD_TRANS';
                l_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';
                l_winners_target := 'JTF_TAE_1001_LEAD_WINNERS';

            ELSIF (l_trans_id = -1004) THEN
                l_trans_target := 'JTF_TAE_1001_OPPOR_TRANS';
                l_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';
                l_winners_target := 'JTF_TAE_1001_OPPOR_WINNERS';

            END IF; -- what tx type

        END IF; -- what usage


        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES( p_table_name => l_trans_target
                                                     , x_return_status => x_return_status );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

           ERRBUF := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [1] Call to ' ||
				 	               'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' ||
               					 l_trans_target;

           RAISE	FND_API.G_EXC_ERROR;

         END IF;

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES( p_table_name => l_matches_target
                                                     , x_return_status => x_return_status );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN


           ERRBUF := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [2] Call to ' ||
				 	               'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' ||
               					 l_matches_target;

           RAISE	FND_API.G_EXC_ERROR;

         END IF;

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES( p_table_name => l_winners_target
                                                     , x_return_status => x_return_status );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN


           ERRBUF := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [3] Call to ' ||
				 	               'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' ||
					                l_winners_target;

           RAISE	FND_API.G_EXC_ERROR;

         END IF;

      /* Program completed successfully */
      ERRBUF := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: Successfully completed.';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETCODE := 0;

   EXCEPTION

	     WHEN FND_API.G_EXC_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_ERROR;

           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [END] ' ||
                      'FND_API.G_EXC_ERROR: ' ||
                      SQLERRM;
           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [END] ' ||
                      'FND_API.G_EXC_UNEXPECTED_ERROR: ' ||
                      SQLERRM;
           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

      WHEN  utl_file.invalid_path OR
         			utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
         			Utl_file.invalid_operation OR
            utl_file.write_error  THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RETCODE := 2;
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [END] UTL_FILE: ' ||
                     SQLERRM;

           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

      WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_ASSIGN_PUB.DROP_TAE_TRANS_INDEXES: [END] OTHERS: ' ||
                      SQLERRM;

           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

    end Drop_TAE_TRANS_Indexes;

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Get_SQL_For_Changes
    --    type           : public.
    --    function       : Get_SQL_For_Changes
    --    pre-reqs       :
    --    notes:
    --

    PROCEDURE Get_SQL_For_Changes (
        p_source_id            IN       NUMBER,
        p_trans_object_type_id IN       NUMBER,
        p_view_name            IN       VARCHAR2,
        x_return_status        OUT NOCOPY         VARCHAR2,
        p_sql                  OUT NOCOPY       JTF_TAE_GEN_PVT.terrsql_tbl_type,
        x_msg_count            OUT NOCOPY         NUMBER,
        x_msg_data             OUT NOCOPY         VARCHAR2,
        ERRBUF                 OUT NOCOPY         VARCHAR2,
        RETCODE                OUT NOCOPY         VARCHAR2
        )
    AS
        l_source_id           number := p_source_id;
        l_qual_type_id        number := p_trans_object_type_id;
        l_view_name           VARCHAR2(30) := p_view_name;
    BEGIN
        --dbms_output.put_line('    Get_SQL_For_Changes :BEGINS ');
        JTF_TAE_GEN_PVT.gen_details_for_terr_change(
            p_source_id           => l_source_id,    --IN       NUMBER,
            p_qual_type_id        => l_qual_type_id, --IN       NUMBER,
            p_view_name           => l_view_name,    --IN       VARCHAR2,
            p_sql                 => p_sql           --OUT  NOCOPY terrsql_tbl_type
            );
        --dbms_output.put_line('JTF_TAE_GEN_PVT.gen_details_for_terr_change returned');

			/* Program completed successfully */
      ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_SQL_FOR_CHANGES: Successfully completed.';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETCODE := 0;

    EXCEPTION
            WHEN OTHERS THEN
                x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
    END Get_SQL_For_Changes;




    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Clear_trans_data
    --    type           : public.
    --    function       : Truncate Trans Table, and Drop_TAE_TRANS_Indexes
    --    pre-reqs       :
    --    notes:
    --

    PROCEDURE Clear_Trans_Data
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        x_return_status         OUT NOCOPY         VARCHAR2,
        p_source_id             IN          NUMBER,
        p_trans_object_type_id  IN          NUMBER,
        p_target_type           IN          VARCHAR2 := 'TAP',
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    )
    AS
      l_api_name                   CONSTANT VARCHAR2(30) := 'CLEAR_TRANS_DATA';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_return_status              VARCHAR2(1);

      l_trans_target             varchar2(30);
      l_matches_target           varchar2(30);
      l_winners_target           varchar2(30);
      l_source_id                number := p_source_id;
      l_trans_id                 number := p_trans_object_type_id;
      l_execute_str               varchar2(360);

      l_terr_L1_target             VARCHAR2(30);
      l_terr_L2_target             VARCHAR2(30);
      l_terr_L3_target             VARCHAR2(30);
      l_terr_L4_target             VARCHAR2(30);
      l_terr_L5_target             VARCHAR2(30);
      l_terr_WT_target             VARCHAR2(30);

    BEGIN
        -- Process Parameters

        IF (l_source_id = -1001) THEN
            IF (p_trans_object_type_id = -1002) THEN
              --ARPATEL 09/12/2003 OIC requirements
              IF p_target_type = 'OIC_TAP' THEN
                l_trans_target   := 'JTF_TAE_1001_SC_TRANS';
                l_matches_target := 'JTF_TAE_1001_SC_MATCHES';
                l_winners_target := 'JTF_TAE_1001_SC_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_SC_L1';
                l_terr_L2_target := 'JTF_TAE_1001_SC_L2';
                l_terr_L3_target := 'JTF_TAE_1001_SC_L3';
                l_terr_L4_target := 'JTF_TAE_1001_SC_L4';
                l_terr_L5_target := 'JTF_TAE_1001_SC_L5';
                l_terr_WT_target := 'JTF_TAE_1001_SC_WT';
              ELSE
                l_trans_target := 'JTF_TAE_1001_ACCOUNT_TRANS';
                l_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';
                l_winners_target := 'JTF_TAE_1001_ACCOUNT_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_ACCOUNT_L1';
                l_terr_L2_target := 'JTF_TAE_1001_ACCOUNT_L2';
                l_terr_L3_target := 'JTF_TAE_1001_ACCOUNT_L3';
                l_terr_L4_target := 'JTF_TAE_1001_ACCOUNT_L4';
                l_terr_L5_target := 'JTF_TAE_1001_ACCOUNT_L5';
                l_terr_WT_target := 'JTF_TAE_1001_ACCOUNT_WT';

              END IF; --p_target_type = 'OIC_TAP'
            ELSIF (p_trans_object_type_id = -1003) THEN
                l_trans_target := 'JTF_TAE_1001_LEAD_TRANS';
                l_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';
                l_winners_target := 'JTF_TAE_1001_LEAD_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_LEAD_L1';
                l_terr_L2_target := 'JTF_TAE_1001_LEAD_L2';
                l_terr_L3_target := 'JTF_TAE_1001_LEAD_L3';
                l_terr_L4_target := 'JTF_TAE_1001_LEAD_L4';
                l_terr_L5_target := 'JTF_TAE_1001_LEAD_L5';
                l_terr_WT_target := 'JTF_TAE_1001_LEAD_WT';

            ELSIF (p_trans_object_type_id = -1004) THEN
                l_trans_target := 'JTF_TAE_1001_OPPOR_TRANS';
                l_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';
                l_winners_target := 'JTF_TAE_1001_OPPOR_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_OPPOR_L1';
                l_terr_L2_target := 'JTF_TAE_1001_OPPOR_L2';
                l_terr_L3_target := 'JTF_TAE_1001_OPPOR_L3';
                l_terr_L4_target := 'JTF_TAE_1001_OPPOR_L4';
                l_terr_L5_target := 'JTF_TAE_1001_OPPOR_L5';
                l_terr_WT_target := 'JTF_TAE_1001_OPPOR_WT';

            END IF; -- what tx type
        END IF; -- what usage

        -------------
        --- [P01] --- TRUNCATE TRANS
		-------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P01] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API BEGINS ' ||
                    					 'for ' ||	l_trans_target);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_trans_target
                            , x_return_status => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P01] Call to ' ||
                      'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
   					  l_trans_target;

            RAISE	FND_API.G_EXC_ERROR;
        END IF;


        -------------
        --- [P02] --- TRUNCATE MATCHES
		-------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P02] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API BEGINS ' ||
                    					 'for ' ||	l_matches_target);


        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_matches_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_matches_target
                            , x_return_status => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P02] Call to ' ||
                      'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
   					  l_matches_target;
            RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -------------
        --- [P03] --- TRUNCATE WINNERS
		-------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P03] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API BEGINS ' ||
                    					 'for ' ||	l_winners_target);

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_winners_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_winners_target
                            , x_return_status => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P03] Call to ' ||
                      'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
   					  l_winners_target;
            RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -------------
        --- [P03.1] -
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                                         'MULTI-LEVEL TABLE CLEANUP BEGINS...');

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L1_target
                                 , x_return_status => x_return_status);

        ----dbms_output.put_line('10.1: Truncate Level Winners Tables ');
        -- 10.1: Truncate Level Winners Tables
        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L1_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L1_target;
           RAISE	FND_API.G_EXC_ERROR;
         END IF;

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L2_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L2_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L2_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L3_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L3_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L3_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L4_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L4_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L4_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L5_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_L5_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_L5_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_WT_target
                                 , x_return_status => x_return_status);

        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                              p_table_name => l_terr_WT_target
                            , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' ||
                     l_terr_WT_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -------------
        --- [P04] --- DROP INDEXES for TRANS TABLE ONLY (WE KEEP INDEXES FOR MATCHES AND WINNERS )
		-------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P04] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API BEGINS ' ||
                    					 'for ' ||	l_trans_target);

        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES( p_table_name => l_trans_target
                                                     , x_return_status => x_return_status );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

            ERRBUF := 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [P04] Call to ' ||
            		  'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' ||
            		  l_trans_target;

            RAISE	FND_API.G_EXC_ERROR;

        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_ERROR;
           RETCODE := 2;
           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
           RETCODE := 2;
           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

        WHEN  utl_file.invalid_path OR
			utl_file.invalid_mode  OR
            utl_file.invalid_filehandle OR
			Utl_file.invalid_operation OR
            utl_file.write_error  THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RETCODE := 2;
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [END] UTL_FILE: ' ||
                     SQLERRM;
           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           RETCODE := 2;
           ERRBUF  := 'JTF_TAE_ASSIGN_PUB.CLEAR_TRANS_DATA: [END] OTHERS: ' ||
                      SQLERRM;
           JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

    END Clear_Trans_Data;


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : GET_WINNERS_PARALLEL_SETUP
    --    type           : public.
    --    function       :
    --    pre-reqs       :
    --    notes:
    --

    PROCEDURE get_winners_parallel_setup
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN          VARCHAR2,
      p_Debug_Flag            IN          VARCHAR2,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_request_id            IN          NUMBER,
      p_source_id             IN          NUMBER,
      p_trans_object_type_id  IN          NUMBER,
      p_target_type           IN          VARCHAR2 := 'TAP',
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2
    )
    AS

        l_api_name                   CONSTANT VARCHAR2(30) := 'GET_WINNERS_PARALLEL_SETUP';
        l_api_version_number         CONSTANT NUMBER       := 1.0;
        l_return_status              VARCHAR2(1);
        l_count1                     NUMBER := 0;
        l_count2                     NUMBER := 0;
        l_RscCounter                 NUMBER := 0;
        l_NumberOfWinners            NUMBER ;

        lp_sysdate                   DATE   := SYSDATE;
        l_rsc_counter                NUMBER := 0;
        l_dyn_str                    VARCHAR2(32767);
        num_of_terr                  NUMBER;
        num_of_trans                 NUMBER;
        d_statement                  VARCHAR2(2000);

        l_trans_target               VARCHAR2(30);
        l_matches_target             VARCHAR2(30);
        l_winners_target             VARCHAR2(30);

        l_terr_L1_target             VARCHAR2(30);
        l_terr_L2_target             VARCHAR2(30);
        l_terr_L3_target             VARCHAR2(30);
        l_terr_L4_target             VARCHAR2(30);
        l_terr_L5_target             VARCHAR2(30);
        l_terr_WT_target             VARCHAR2(30);

        l_matches_idx                VARCHAR2(30);

        l_access_list                VARCHAR2(300);
        l_truncate_matches_rtn_val   NUMBER;
        l_create_idx_match_rtn_val   NUMBER;

        lX_Msg_Data         VARCHAR2(2000);
        lx_runtime          VARCHAR2(300);

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* If the debug flag is set, Then turn on the debug message logging */
        If UPPER( rtrim(p_Debug_Flag) ) = 'Y' Then
          JTF_TAE_CONTROL_PVT.G_DEBUG := TRUE;
        End If;

        /* ARPATEL: 12/15/2003: Bug#3305019 */
        --If UPPER(p_SQL_Trace) = 'Y' Then
        --  dbms_session.set_sql_trace(TRUE);
        --End If;

        -- 05/16/02: JDOCHERT
        -- Need COMMIT to avoid the following error:
        -- ORA-12841: Cannot alter the session parallel DML state within a transaction
        -- in the call to JTF_TAE_CONTROL_PVT.set_session_parameters below
        COMMIT;

        /* Standard call to check for call compatibility. */
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)  THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        /* Initialize message list if p_init_msg_list is set to TRUE. */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_MEM_TASK_START');
          FND_MSG_PUB.Add;
        END IF;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, '/***************** BEGIN: TERRITORY ASSIGNMENT STATUS *********************/');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP start....');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'source_id            = ' || TO_CHAR(p_source_Id) );
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'trans_object_type_id = ' || TO_CHAR(p_trans_object_type_id) );

        /* JDOCHERT 05/05/02: Commented out settings in JTF_TAE_CONTROL
        ** since OSO TAP program has these paramaters
        		   */
        --JTF_TAE_CONTROL_PVT.set_session_parameters
        --                 ( p_sort_area_size => 100000000
        --                 , p_hash_area_size => 200000000);

        -----------------------------------------------------------
        -- logic control to see which dyn package should be called
        -----------------------------------------------------------

        IF ( p_source_id = -1001 ) THEN
             ----dbms_output.put_line(' p_source_id = -1001 ');

            IF (p_trans_object_type_id = -1002) THEN

              --ARPATEL 09/12/2003 OIC requirements
             IF ( p_target_type = 'OIC_TAP' ) THEN
                l_trans_target   := 'JTF_TAE_1001_SC_TRANS';
                l_matches_target := 'JTF_TAE_1001_SC_MATCHES';
                l_winners_target := 'JTF_TAE_1001_SC_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_SC_L1';
                l_terr_L2_target := 'JTF_TAE_1001_SC_L2';
                l_terr_L3_target := 'JTF_TAE_1001_SC_L3';
                l_terr_L4_target := 'JTF_TAE_1001_SC_L4';
                l_terr_L5_target := 'JTF_TAE_1001_SC_L5';
                l_terr_WT_target := 'JTF_TAE_1001_SC_WT';
                l_access_list := ' ''ACCOUNT'', 1, ''LEAD'', 1, ''OPPOR'', 1 ';
             ELSE
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    l_trans_target := 'JTF_TAE_1001_ACCOUNT_NM_TRANS';
                ELSE
                    l_trans_target := 'JTF_TAE_1001_ACCOUNT_TRANS';
                END IF;
                l_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';
                l_winners_target := 'JTF_TAE_1001_ACCOUNT_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_ACCOUNT_L1';
                l_terr_L2_target := 'JTF_TAE_1001_ACCOUNT_L2';
                l_terr_L3_target := 'JTF_TAE_1001_ACCOUNT_L3';
                l_terr_L4_target := 'JTF_TAE_1001_ACCOUNT_L4';
                l_terr_L5_target := 'JTF_TAE_1001_ACCOUNT_L5';
                l_terr_WT_target := 'JTF_TAE_1001_ACCOUNT_WT';

                l_access_list := ' ''ACCOUNT'', 1, ''LEAD'', 1, ''OPPOR'', 1 ';
             END IF; --p_target_type = 'OIC_TAP'

            ELSIF (p_trans_object_type_id = -1003) THEN
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    l_trans_target := 'JTF_TAE_1001_LEAD_NM_TRANS';
                ELSE
                    l_trans_target := 'JTF_TAE_1001_LEAD_TRANS';
                END IF;
                l_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';
                l_winners_target := 'JTF_TAE_1001_LEAD_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_LEAD_L1';
                l_terr_L2_target := 'JTF_TAE_1001_LEAD_L2';
                l_terr_L3_target := 'JTF_TAE_1001_LEAD_L3';
                l_terr_L4_target := 'JTF_TAE_1001_LEAD_L4';
                l_terr_L5_target := 'JTF_TAE_1001_LEAD_L5';
                l_terr_WT_target := 'JTF_TAE_1001_LEAD_WT';

                l_access_list := ' ''LEAD'', 1 ';

            ELSIF (p_trans_object_type_id = -1004) THEN
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    l_trans_target := 'JTF_TAE_1001_OPPOR_NM_TRANS';
                ELSE
                    l_trans_target := 'JTF_TAE_1001_OPPOR_TRANS';
                END IF;
                l_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';
                l_winners_target := 'JTF_TAE_1001_OPPOR_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_OPPOR_L1';
                l_terr_L2_target := 'JTF_TAE_1001_OPPOR_L2';
                l_terr_L3_target := 'JTF_TAE_1001_OPPOR_L3';
                l_terr_L4_target := 'JTF_TAE_1001_OPPOR_L4';
                l_terr_L5_target := 'JTF_TAE_1001_OPPOR_L5';
                l_terr_WT_target := 'JTF_TAE_1001_OPPOR_WT';

                l_access_list := ' ''OPPOR'', 1 ';

            END IF; -- what tx type
        END IF; -- what usage

        -- (-1 indentation)

        /* set NOLOGGING on JTF_TAE_..._MATCHES and JTF_TAE_..._WINNERS tables */
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_trans_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_matches_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_winners_target);

        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L1_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L2_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L3_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L4_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_L5_target);
        JTF_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_terr_WT_target);

        -------------
        --- [P00] ---
        -------------
        BEGIN

           /* Check for territories for this Usage/Transaction Type */
           SELECT COUNT(*)
           INTO num_of_terr
           FROM    jtf_terr_qtype_usgs_all jtqu
                 , jtf_terr_usgs_all jtu
                 , jtf_terr_all jt1
                 , jtf_qual_type_usgs jqtu
           WHERE jtqu.terr_id = jt1.terr_id
             AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
             AND jqtu.qual_type_id = p_trans_object_type_id
             AND jtu.source_id = p_source_id
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
             AND jqtu.qual_type_id <> -1001;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                num_of_terr := 0;
        END;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P00] Number of valid ' ||
                                          'Territories with Resources for this Transaction: ' ||
    				     		                           num_of_terr );

        /* 2357180: ERROR HANDLING FOR NO TERRITORY DATA:
        **          AFTER MATCHES AND WINNERS TABLES HAVE BEEN TRUNCATED */
        IF (num_of_terr = 0) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P00] There are NO Active Territories with Active ' ||
    							          'Resources existing for this Usage/Transaction combination, so no assignments ' ||
    									        'can take place.';

           RAISE	NO_TAE_DATA_FOUND;

        END IF;

        -------------
        --- [P01] ---
        -------------
        BEGIN
           d_statement := ' SELECT COUNT(*) FROM ' ||
                          l_trans_target ||
                          ' WHERE rownum < 2 ';
           EXECUTE IMMEDIATE d_statement INTO num_of_trans;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              num_of_trans := 0;
        END;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P01] ' ||
    				    		         'There are valid Transaction Objects to be assigned.');

        IF (num_of_trans = 0) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P01] There are NO valid Transaction Objects to assign.';
           RAISE	NO_TAE_DATA_FOUND;
        END IF;

        -------------
        --- [P02] ---
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P02] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API BEGINS ' ||
      								         'for ' ||	l_trans_target);

        /* Analyze _TRANS table */
        /* JDOCHERT: 04/10/03: bug#2896552 */
        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_trans_target
                                  , p_percent       => 99
                                  , x_return_status => x_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P02] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' ||
                     l_trans_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -------------
        --- [P03] ---
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03] Call to ' ||
                                         'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS API BEGINS...');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');

        JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns
            (p_Api_Version_Number     => 1.0,
             p_Init_Msg_List          => FND_API.G_FALSE,
             p_Commit                 => FND_API.G_FALSE,
             p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
             x_Return_Status          => x_return_status,
             x_Msg_Count              => x_msg_count,
             x_Msg_Data               => x_msg_data,
             p_run_mode               => p_target_type,
             p_classify_terr_comb     => 'N',
             p_process_tx_oin_sel     => 'Y',
             p_generate_indexes       => 'Y',
             p_source_id              => p_source_id,
             p_trans_id               => p_trans_object_type_id,
             errbuf                   => ERRBUF,
             retcode                  => RETCODE );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [P03] Call to ' ||
                      'JTF_TAE_CONTROL_PVT.DECOMPOSE_TERR_DEFNS API has failed.';
            RAISE	FND_API.G_EXC_ERROR;
        END IF;


        -----------
        --- [P04.1] ---
        -----------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.1] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_matches_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_matches_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_matches_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.2] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_winners_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_winners_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.2] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_winners_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.3] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_terr_L1_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_terr_L1_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.3] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_terr_L1_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.4] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_terr_L2_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_terr_L2_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.4] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_terr_L2_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;



        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.5] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_terr_L3_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_terr_L3_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.5] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_terr_L3_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;



        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.6] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_terr_L4_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_terr_L4_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.6] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_terr_L4_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.7] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_terr_L5_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_terr_L5_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.7] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_terr_L5_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.8] Call to ' ||
                                         'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API BEGINS ' ||
                                         'for ' ||	l_terr_WT_target);

        /* Build Index on Winners table */
        JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX( l_terr_WT_target
                                               , p_trans_object_type_id
                                               , p_source_id
                                               , l_return_status
					       , p_target_type );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P04.8] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' ||
                     l_terr_WT_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;


    EXCEPTION
		WHEN NO_TAE_DATA_FOUND THEN
            x_return_status     := FND_API.G_RET_STS_SUCCESS;
            RETCODE := 1;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status     := FND_API.G_RET_STS_ERROR;
            RETCODE := 2;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
            RETCODE := 2;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

        WHEN  utl_file.invalid_path OR
   		      utl_file.invalid_mode  OR
              utl_file.invalid_filehandle OR
		      utl_file.invalid_operation OR
              utl_file.write_error  THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETCODE := 2;
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [END] UTL_FILE: ' ||
                      SQLERRM;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            RETCODE := 2;
            ERRBUF  := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: [END] OTHERS: ' ||
                       SQLERRM;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

    END get_winners_parallel_setup;


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : GET_WINNERS_PARALLEL
    --    type           : public.
    --    function       :
    --    pre-reqs       :
    --    notes:  API designed to be called from multiple sessions
    --            to parallel process assignment of transactions to territories
    --

    PROCEDURE GET_WINNERS_PARALLEL
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN          VARCHAR2,
      p_Debug_Flag            IN          VARCHAR2,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_request_id            IN          NUMBER,
      p_source_id             IN          NUMBER,
      p_trans_object_type_id  IN          NUMBER,
      p_target_type           IN          VARCHAR2 := 'TAP',
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_worker_id             IN          NUMBER := 1,
      p_total_workers         IN          NUMBER
    )
    AS

        l_api_name                   CONSTANT VARCHAR2(30) := 'GET_WINNERS_PARALLEL';
        l_api_version_number         CONSTANT NUMBER       := 1.0;
        l_return_status              VARCHAR2(1);
        l_count1                     NUMBER := 0;
        l_count2                     NUMBER := 0;
        l_RscCounter                 NUMBER := 0;
        l_NumberOfWinners            NUMBER ;

        lp_sysdate                   DATE   := SYSDATE;
        l_rsc_counter                NUMBER := 0;
        l_dyn_str                    VARCHAR2(32767);
        num_of_terr                  NUMBER;
        num_of_trans                 NUMBER;
        l_num_of_trans                 NUMBER;
        d_statement                  VARCHAR2(2000);
        l_trans_count_sql            VARCHAR2(2000);

        l_trans_target               VARCHAR2(30);
        l_matches_target             VARCHAR2(30);
        l_winners_target             VARCHAR2(30);
     l_terr_L1_target             VARCHAR2(30);
     l_terr_L2_target             VARCHAR2(30);
     l_terr_L3_target             VARCHAR2(30);
     l_terr_L4_target             VARCHAR2(30);
     l_terr_L5_target             VARCHAR2(30);
     l_terr_WT_target             VARCHAR2(30);


        l_matches_idx                VARCHAR2(30);

        l_access_list                VARCHAR2(300);
        l_truncate_matches_rtn_val   NUMBER;
        l_create_idx_match_rtn_val   NUMBER;

        lX_Msg_Data         VARCHAR2(2000);
        lx_runtime          VARCHAR2(300);

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* If the debug flag is set, Then turn on the debug message logging */
        If UPPER( rtrim(p_Debug_Flag) ) = 'Y' Then
          JTF_TAE_CONTROL_PVT.G_DEBUG := TRUE;
        End If;

        /* ARPATEL: 12/15/2003: Bug#3305019 */
        --If UPPER(p_SQL_Trace) = 'Y' Then
        --  dbms_session.set_sql_trace(TRUE);
        --ARPATEL: 10/02/03: removed this for performance team
        --Else
        --  dbms_session.set_sql_trace(FALSE);
        -- End If;

        IF ( p_source_id = -1001 ) THEN
            IF (p_trans_object_type_id = -1002) THEN

              --ARPATEL 09/12/2003 OIC requirements
             IF ( p_target_type = 'OIC_TAP' ) THEN
                l_trans_target   := 'JTF_TAE_1001_SC_TRANS';
                l_matches_target := 'JTF_TAE_1001_SC_MATCHES';
                l_winners_target := 'JTF_TAE_1001_SC_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_SC_L1';
                l_terr_L2_target := 'JTF_TAE_1001_SC_L2';
                l_terr_L3_target := 'JTF_TAE_1001_SC_L3';
                l_terr_L4_target := 'JTF_TAE_1001_SC_L4';
                l_terr_L5_target := 'JTF_TAE_1001_SC_L5';
                l_terr_WT_target := 'JTF_TAE_1001_SC_WT';
                l_access_list := ' ''ACCOUNT'' ';
             ELSE
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    l_trans_target := 'JTF_TAE_1001_ACCOUNT_NM_TRANS';
                ELSE
                    l_trans_target := 'JTF_TAE_1001_ACCOUNT_TRANS';
                END IF;
                l_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';
                l_winners_target := 'JTF_TAE_1001_ACCOUNT_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_ACCOUNT_L1';
                l_terr_L2_target := 'JTF_TAE_1001_ACCOUNT_L2';
                l_terr_L3_target := 'JTF_TAE_1001_ACCOUNT_L3';
                l_terr_L4_target := 'JTF_TAE_1001_ACCOUNT_L4';
                l_terr_L5_target := 'JTF_TAE_1001_ACCOUNT_L5';
                l_terr_WT_target := 'JTF_TAE_1001_ACCOUNT_WT';

                l_access_list := ' ''ACCOUNT'' ';

             END IF; --p_target_type = 'OIC_TAP'

            ELSIF (p_trans_object_type_id = -1003) THEN
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    l_trans_target := 'JTF_TAE_1001_LEAD_NM_TRANS';
                ELSE
                    l_trans_target := 'JTF_TAE_1001_LEAD_TRANS';
                END IF;
                l_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';
                l_winners_target := 'JTF_TAE_1001_LEAD_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_LEAD_L1';
                l_terr_L2_target := 'JTF_TAE_1001_LEAD_L2';
                l_terr_L3_target := 'JTF_TAE_1001_LEAD_L3';
                l_terr_L4_target := 'JTF_TAE_1001_LEAD_L4';
                l_terr_L5_target := 'JTF_TAE_1001_LEAD_L5';
                l_terr_WT_target := 'JTF_TAE_1001_LEAD_WT';

                l_access_list := ' ''LEAD'' ';

            ELSIF (p_trans_object_type_id = -1004) THEN
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    l_trans_target := 'JTF_TAE_1001_OPPOR_NM_TRANS';
                ELSE
                    l_trans_target := 'JTF_TAE_1001_OPPOR_TRANS';
                END IF;
                l_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';
                l_winners_target := 'JTF_TAE_1001_OPPOR_WINNERS';

                l_terr_L1_target := 'JTF_TAE_1001_OPPOR_L1';
                l_terr_L2_target := 'JTF_TAE_1001_OPPOR_L2';
                l_terr_L3_target := 'JTF_TAE_1001_OPPOR_L3';
                l_terr_L4_target := 'JTF_TAE_1001_OPPOR_L4';
                l_terr_L5_target := 'JTF_TAE_1001_OPPOR_L5';
                l_terr_WT_target := 'JTF_TAE_1001_OPPOR_WT';

                l_access_list := ' ''OPPOR'' ';

            END IF; -- what tx type
        END IF; -- what usage
--dbms_output.put_line('GET_WINNERS_PARALLEL l_trans_target = ' || l_trans_target);

        -------------
        --- [P00] ---  DO ANY TRANSACTIONS EXIST FOR THIS WORKER?
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                      p_worker_id ||
                                      ' [P00] Check if accounts exist for this worker... ');
        BEGIN

            l_trans_count_sql := 'SELECT COUNT(*) FROM ' || l_trans_target ||
                                 ' where worker_id = ' || p_worker_id || ' and rownum < 2 ';
            EXECUTE IMMEDIATE l_trans_count_sql INTO l_num_of_trans;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_num_of_trans := 0;
        END;

        IF (l_num_of_trans = 0) THEN
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                      p_worker_id ||
                                      ' [P00] NO TRANSACTIONS EXIST FOR THIS WORKER...Quitting.');
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL_SETUP: worker_id= ' || p_worker_id ||
                     '  [P00] There are NO valid Transaction Objects to assign.';
            RAISE	NO_TAE_DATA_FOUND;
        END IF;

        -------------
        --- [P01] --- CALL DYN PACKAGE
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                      p_worker_id ||
                                      ' [P01] Call to ' ||
                                      'JTF_TAE_1001_..._DYN.SEARCH_TERR_RULES API BEGINS... ');

        /* Start MATCH processing */
        IF ( p_source_id = -1001 ) THEN
            IF (p_trans_object_type_id = -1002) THEN
                --ARPATEL 09/12/2003 OIC requirements
                IF ( p_target_type = 'OIC_TAP' ) THEN
                    --dbms_output.put_line('GET_WINNERS_PARALLEL Calling JTF_TAE_1001_ACCOUNT_NM_DYN');
                    JTF_TAE_1001_SCREDIT_DYN.Search_Terr_Rules(
                              p_source_id             => p_source_id ,
                              p_trans_object_type_id  => p_trans_object_type_id,
                              x_Return_Status         => x_return_status,
                              x_Msg_Count             => x_msg_count,
                              x_Msg_Data              => x_msg_data,
                              p_worker_id             => p_worker_id);

                ELSIF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    --dbms_output.put_line('GET_WINNERS_PARALLEL Calling JTF_TAE_1001_ACCOUNT_NM_DYN');
                    JTF_TAE_1001_ACCOUNT_NM_DYN.Search_Terr_Rules(
                              p_source_id             => p_source_id ,
                              p_trans_object_type_id  => p_trans_object_type_id,
                              x_Return_Status         => x_return_status,
                              x_Msg_Count             => x_msg_count,
                              x_Msg_Data              => x_msg_data,
                              p_worker_id             => p_worker_id);

                ELSE
                    --dbms_output.put_line('GET_WINNERS_PARALLEL Calling JTF_TAE_1001_ACCOUNT_DYN');
                    JTF_TAE_1001_ACCOUNT_DYN.Search_Terr_Rules(
                              p_source_id             => p_source_id ,
                              p_trans_object_type_id  => p_trans_object_type_id,
                              x_Return_Status         => x_return_status,
                              x_Msg_Count             => x_msg_count,
                              x_Msg_Data              => x_msg_data,
                              p_worker_id             => p_worker_id);
                END IF;

            ELSIF (p_trans_object_type_id = -1003) THEN
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    JTF_TAE_1001_LEAD_NM_DYN.Search_Terr_Rules(
                              p_source_id             => p_source_id ,
                              p_trans_object_type_id  => p_trans_object_type_id,
                              x_Return_Status         => x_return_status,
                              x_Msg_Count             => x_msg_count,
                              x_Msg_Data              => x_msg_data,
                              p_worker_id             => p_worker_id);

                ELSE
                    JTF_TAE_1001_LEAD_DYN.Search_Terr_Rules(
                              p_source_id             => p_source_id ,
                              p_trans_object_type_id  => p_trans_object_type_id,
                              x_Return_Status         => x_return_status,
                              x_Msg_Count             => x_msg_count,
                              x_Msg_Data              => x_msg_data,
                              p_worker_id             => p_worker_id);
                END IF;

            ELSIF (p_trans_object_type_id = -1004) THEN
                IF ( p_target_type = 'NEW_MODE_TAP' ) THEN
                    JTF_TAE_1001_OPPOR_NM_DYN.Search_Terr_Rules(
                                  p_source_id             => p_source_id ,
                                  p_trans_object_type_id  => p_trans_object_type_id,
                                  x_Return_Status         => x_return_status,
                                  x_Msg_Count             => x_msg_count,
                                  x_Msg_Data              => x_msg_data,
                                  p_worker_id             => p_worker_id);
                ELSE
                    JTF_TAE_1001_OPPOR_DYN.Search_Terr_Rules(
                                  p_source_id             => p_source_id ,
                                  p_trans_object_type_id  => p_trans_object_type_id,
                                  x_Return_Status         => x_return_status,
                                  x_Msg_Count             => x_msg_count,
                                  x_Msg_Data              => x_msg_data,
                                  p_worker_id             => p_worker_id);
                END IF;
            END IF; -- what tx type
        END IF; -- what source
        --dbms_output.put_line('GET_WINNERS_PARALLEL x_return_status of DYN PACKAGE: ' || x_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                       p_worker_id ||
                      '[P01] Call to ' ||
                      'JTF_TAE_1001_..._DYN.SEARCH_TERR_RULES API has failed.';
            RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -------------
        --- [P02] --- ANALYZE MATCHES TABLE
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                      p_worker_id ||
                                      '[P02] Call to ' ||
                                      'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API BEGINS ' ||
                                      'for ' ||	l_matches_target);
        /* Analyze Matches table */
        /* JDOCHERT: 04/10/03: bug#2896552 */
        --dbms_output.put_line('GET_WINNERS_PARALLEL ANALYZING MATCHES TABLE ');

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_matches_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );
        --dbms_output.put_line('GET_WINNERS_PARALLEL ANALYZING MATCHES TABLE ... COMPLETE ');

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                      p_worker_id || '[P02] Call to ' ||
                      'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' ||
                      l_matches_target;
            RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -------------
        --- [P03] --- PARALLEL MULTI_VARIABLE NUMBER OF WINNERS PROCESSING
        -------------

	--ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [P03] Call to ' ||
                                         'PARALLEL MULTI_VARIABLE NUMBER OF WINNERS PROCESSING BEGINS...');

        --dbms_output.put_line('10.2: Process Level Winners ');
        -- 11: Process Level Winners
        --     NOTE: p_terr_PARENT_LEVEL_tbl arg ingnored here as we process top level
        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L1_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L1_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 1,
                                p_LOWER_LEVEL_FROM_ROOT  => 1,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => p_worker_id
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.1] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L1_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	--ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L1_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L2_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L1_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 1,
                                p_LOWER_LEVEL_FROM_ROOT  => 2,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => p_worker_id
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.2] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L2_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	--ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L2_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L3_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L2_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 2,
                                p_LOWER_LEVEL_FROM_ROOT  => 3,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => p_worker_id
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [P03] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L3_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	--ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L3_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L4_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L3_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 3,
                                p_LOWER_LEVEL_FROM_ROOT  => 4,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => p_worker_id
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.4] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L4_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

	--ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L4_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        Process_Level_Winners ( p_terr_LEVEL_target_tbl  => l_terr_L5_target,
                                p_terr_PARENT_LEVEL_tbl  => l_terr_L4_target,
                                p_UPPER_LEVEL_FROM_ROOT  => 4,
                                p_LOWER_LEVEL_FROM_ROOT  => 5,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => p_worker_id
                               );


        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.5] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_L5_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_L5_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        Process_Final_Level_Winners (
                                p_terr_LEVEL_target_tbl  => l_terr_WT_target,
                                p_terr_L5_target_tbl     => l_terr_L5_target,
                                p_matches_target         => l_matches_target,
                                p_source_id              => p_source_id,
                                p_qual_type_id           => p_trans_object_type_id,
                                x_return_status          => l_return_status,
                                p_worker_id              => p_worker_id
                                );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: [11.6] Call to ' ||
                     'JTF_TAE_INDEX_CREATION_PVT.Process_Level_Winners API has failed for ' ||
                     l_terr_WT_target;
           RAISE	FND_API.G_EXC_ERROR;
        END IF;

        --ARPATEL 09/22/03 add commit to avoid large rollback segments
        COMMIT;

        JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                    p_table_name    => l_terr_WT_target
                                  , p_percent       => 20
                                  , x_return_status => x_return_status );

        -------------
        --- [P03] --- MULTI-LEVEL NUMBER OF WINNERS PROCESSING
        -------------
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                      p_worker_id ||
                                      '[P03] Call to ' ||
                                      'NUMBER OF WINNERS PROCESSING BEGINS...');

            --dbms_output.put_line('12: Fetch Winners and Resources ');
            -- 12.0: Fetch Winners and Resources

             /* 05/16/02: JDOCHERT:
             ** No longer create MATCHES INDEX, so INDEX hint is obsolete
             ** l_matches_idx := REPLACE(UPPER(l_matches_target), 'ES', NULL);
             */

            l_dyn_str :=
               ' INSERT INTO ' ||
               l_winners_target || ' i ' ||
               ' ( ' ||
               ' 	 TRANS_OBJECT_ID        ' ||
               ' 	,TRANS_DETAIL_OBJECT_ID ' ||
               ' 	,WORKER_ID ' ||

               /*
               ** 07/17/03 JDOCHERT: NOT USED
               **' 	,HEADER_ID1             ' ||
               **' 	,HEADER_ID2             ' ||
               */

               ' 	,SOURCE_ID              ' ||
               ' 	,TRANS_OBJECT_TYPE_ID   ' ||
               ' 	,LAST_UPDATE_DATE       ' ||
               ' 	,LAST_UPDATED_BY        ' ||
               ' 	,CREATION_DATE          ' ||
               ' 	,CREATED_BY             ' ||
               '	 ,LAST_UPDATE_LOGIN      ' ||
               '	 ,REQUEST_ID             ' ||
               '	 ,PROGRAM_APPLICATION_ID ' ||
               '	 ,PROGRAM_ID             ' ||
               '	 ,PROGRAM_UPDATE_DATE    ' ||
               '	 ,TERR_ID                ' ||
               '	 ,ABSOLUTE_RANK          ' ||
               '	 ,TOP_LEVEL_TERR_ID      ' ||
               '	 ,RESOURCE_ID            ' ||
               '	 ,RESOURCE_TYPE          ' ||
               '	 ,GROUP_ID               ' ||
               '	 ,ROLE                   ' ||
               '	 ,PRIMARY_CONTACT_FLAG   ' ||
               '	 ,PERSON_ID              ' ||
               '	 ,ORG_ID                 ' ||
               '	 ,TERR_RSC_ID            ' ||
               '	 ,FULL_ACCESS_FLAG       ' ||
               ' ) ' ||
               ' ( ' ||

               --
               --  10/02/02: JDOCHERT: BUG#2594526 and BUG#2602646
               --
               --'   SELECT /*+   ' ||
               --'              INDEX (jtr JTF_TERR_RSC_N1) ' ||
               --'              INDEX (jtra JTF_TERR_RSC_ACCESS_N1) ' ||
               --'          */ ' ||
               --

               /* remove the distinct clause as suggested by appsperf : bug 4322586 */
               '     SELECT ' ||  -- DISTINCT ' ||
               '          WINNERS.trans_object_id         ' ||
               '        , WINNERS.trans_detail_object_id  ' ||
               '        , :bv_worker_id ' || --p_worker_id ||
               /*
               ** 07/17/03 JDOCHERT: NOT USED
               **'        , 0 header_id1  ' ||  --  o_dttm.header_id1   ' ||
               **'        , 0 header_id2  ' ||  --  o_dttm.header_id2   ' ||
               */

               '        , :BV1_SOURCE_ID                 ' ||
               '        , :BV1_TRANS_OBJECT_TYPE_ID      ' ||
               '        , :BV1_LAST_UPDATE_DATE          ' ||
               '        , :BV1_LAST_UPDATED_BY           ' ||
               '        , :BV1_CREATION_DATE             ' ||
               '        , :BV1_CREATED_BY                ' ||
               '        , :BV1_LAST_UPDATE_LOGIN         ' ||
               '        , :BV1_REQUEST_ID                ' ||
               '        , :BV1_PROGRAM_APPLICATION_ID    ' ||
               '        , :BV1_PROGRAM_ID                ' ||
               '        , :BV1_PROGRAM_UPDATE_DATE       ' ||
               '        , WINNERS.WIN_terr_id            ' ||
               '        , null absolute_rank             ' ||  /*  o_dttm.absolute_rank     ' || */
               '        , null top_level_terr_id         ' ||  /*  o_dttm.top_level_terr_id ' || */
               '        , jtr.resource_id                ' ||
               '        , jtr.resource_type              ' ||
               '        , jtr.group_id                   ' ||
               '        , jtr.role                       ' ||
               '        , jtr.primary_contact_flag       ' ||
               '        , jtr.PERSON_ID                  ' ||
               '        , jtr.org_id                     ' ||
               '        , jtr.terr_rsc_id                ' ||
               '        , jtr.full_access_flag           ' ||
               '    FROM ( /* WINNERS ILV */ ' ||
               '           SELECT LX.trans_object_id ' ||
               '                , LX.trans_detail_object_id ' ||
               '                , LX.WIN_TERR_ID ' ||
               '           FROM ' || l_terr_L1_target || ' LX ' ||
               '              , ( SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , WIN_TERR_ID WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L1_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                  MINUS ' ||
               '                  SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , ul_terr_id WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L2_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                                                  ) ILV ' ||
               '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
               '                   LX.trans_detail_object_id IS NULL ) ' ||
               '             AND LX.trans_object_id = ILV.trans_object_id ' ||
               '             AND LX.WORKER_ID = :bv_worker_id ' ||
               '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

               '           UNION ALL ' ||

               '           SELECT LX.trans_object_id ' ||
               '                , LX.trans_detail_object_id ' ||
               '                , LX.WIN_TERR_ID ' ||
               '           FROM ' || l_terr_L2_target || ' LX ' ||
               '              , ( SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , WIN_TERR_ID WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L2_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                  MINUS ' ||
               '                  SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , ul_terr_id WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L3_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                                                  ) ILV ' ||
               '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
               '                   LX.trans_detail_object_id IS NULL ) ' ||
               '             AND LX.trans_object_id = ILV.trans_object_id ' ||
               '             AND LX.WORKER_ID = :bv_worker_id ' ||
               '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

               '           UNION ALL ' ||

               '           SELECT LX.trans_object_id ' ||
               '                , LX.trans_detail_object_id ' ||
               '                , LX.WIN_TERR_ID ' ||
               '           FROM ' || l_terr_L3_target || ' LX ' ||
               '              , ( SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , WIN_TERR_ID WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L3_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                  MINUS ' ||
               '                  SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , ul_terr_id WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L4_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                                                  ) ILV ' ||
               '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
               '                   LX.trans_detail_object_id IS NULL ) ' ||
               '             AND LX.trans_object_id = ILV.trans_object_id ' ||
               '             AND LX.WORKER_ID = :bv_worker_id ' ||
               '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

               '           UNION ALL ' ||

               '           SELECT LX.trans_object_id ' ||
               '                , LX.trans_detail_object_id ' ||
               '                , LX.WIN_TERR_ID ' ||
               '           FROM ' || l_terr_L4_target || ' LX ' ||
               '              , ( SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , WIN_TERR_ID WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L4_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                  MINUS ' ||
               '                  SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , ul_terr_id WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L5_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                                              ) ILV ' ||
               '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
               '                   LX.trans_detail_object_id IS NULL ) ' ||
               '             AND LX.trans_object_id = ILV.trans_object_id ' ||
               '             AND LX.WORKER_ID = :bv_worker_id ' ||
               '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

               '           UNION ALL ' ||

               '           SELECT LX.trans_object_id ' ||
               '                , LX.trans_detail_object_id ' ||
               '                , LX.WIN_TERR_ID ' ||
               '           FROM ' || l_terr_L5_target || ' LX ' ||
               '              , ( SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , WIN_TERR_ID WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_L5_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                  MINUS ' ||
               '                  SELECT trans_object_id ' ||
               '                       , trans_detail_object_id ' ||
               '                       , ul_terr_id WIN_TERR_ID ' ||
               '                  FROM ' || l_terr_WT_target ||
               '                  WHERE WORKER_ID = :bv_worker_id ' ||
               '                                                ) ILV ' ||
               '           WHERE ( LX.trans_detail_object_id = ILV.trans_detail_object_id OR ' ||
               '                   LX.trans_detail_object_id IS NULL ) ' ||
               '             AND LX.trans_object_id = ILV.trans_object_id ' ||
               '             AND LX.WORKER_ID = :bv_worker_id ' ||
               '             AND LX.WIN_TERR_ID = ILV.WIN_TERR_ID ' ||

               '           UNION ALL ' ||

               '           SELECT trans_object_id ' ||
               '                , trans_detail_object_id ' ||
               '                , WIN_TERR_ID ' ||
               '           FROM ' || l_terr_WT_target ||
               '           WHERE WORKER_ID = :bv_worker_id ' ||
               '         ) WINNERS ' ||
               '         , jtf_terr_rsc_all jtr ' ||
               '         , jtf_terr_rsc_access_all jtra ' ||
               '    WHERE  WINNERS.WIN_terr_id = jtr.terr_id ' ||
               '      AND ( ( jtr.end_date_active IS NULL OR jtr.end_date_active >= :BV1_SYSDATE ) AND  ' ||
               '            ( jtr.start_date_active IS NULL OR jtr.start_date_active <= :BV2_SYSDATE )  ' ||
               '           ) ' ||
               '      AND jtr.terr_rsc_id = jtra.terr_rsc_id ' ||
               '      AND jtra.access_type = ' || l_access_list ||
               ' ) ';


            BEGIN

              EXECUTE IMMEDIATE l_dyn_str USING
                  p_worker_id               /* :bv_worker_id */
                , p_source_id              /* :BV1_SOURCE_ID */
                , p_trans_object_type_id   /* :BV1_TRANS_OBJECT_TYPE_ID */
                , lp_sysdate               /* :BV1_LAST_UPDATE_DATE */
                , G_USER_ID                /* :BV1_LAST_UPDATED_BY */
                , lp_sysdate               /* :BV1_CREATION_DATE */
                , G_USER_ID                /* :BV1_CREATED_BY */
                , G_LOGIN_ID               /* :BV1_LAST_UPDATE_LOGIN */
                , p_request_id              /* :BV1_REQUEST_ID */
                , G_APPL_ID                 /* :BV1_PROGRAM_APPLICATION_ID */
                , G_PROGRAM_ID              /* :BV1_PROGRAM_ID */
                , lp_sysdate                /* :BV1_PROGRAM_UPDATE_DATE */
                , p_worker_id               /* :bv_worker_id */ --1
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */ --5
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */ --10
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */
                , p_worker_id               /* :bv_worker_id */ --15
                , p_worker_id               /* :bv_worker_id */
                , lp_sysdate                /* :BV1_SYSDATE    */
                , lp_sysdate;               /* :BV2_SYSDATE    */

              COMMIT;  -- after modifying table in parallel

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                           p_worker_id ||
                                           'Number of records inserted into ' || l_winners_target ||
                                           ' = ' || SQL%ROWCOUNT );
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: worker_id= ' ||
                                           p_worker_id || '[P03] Call to ' ||
                                           'NUMBER OF WINNERS PROCESSING COMPLETE.');


          -------------
          --- [P04] --- ANALYZE WINNERS TABLE
          -------------
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: [P05] Call to ' ||
                                           'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API BEGINS ' ||
                                           'for ' ||	l_winners_target);

          /* Analyze Winners table */
          /* JDOCHERT: 04/10/03: bug#2896552 */
          JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                      p_table_name    => l_winners_target
                                    , p_percent       => 20
                                    , x_return_status => x_return_status );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: [P05] Call to ' ||
                       'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' ||
                       l_winners_target;
             RAISE	FND_API.G_EXC_ERROR;
           END IF;

       --------------------------------
       -- END API
       --------------------------------
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, '/***************** END: TERRITORY ASSIGNMENT STATUS *********************/');
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');

       /* Program completed successfully */
       ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: Successfully completed.';
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       RETCODE := 0;

    EXCEPTION

		WHEN NO_TAE_DATA_FOUND THEN
            x_return_status     := FND_API.G_RET_STS_SUCCESS;
            RETCODE := 1;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status     := FND_API.G_RET_STS_ERROR;
            RETCODE := 2;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
            RETCODE := 2;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

        WHEN  utl_file.invalid_path OR
              utl_file.invalid_mode  OR
              utl_file.invalid_filehandle OR
              utl_file.invalid_operation OR
              utl_file.write_error  THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETCODE := 2;
            ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: [END] UTL_FILE: ' ||
                      SQLERRM;
            JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

        WHEN OTHERS THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          RETCODE := 2;
          ERRBUF  := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS_PARALLEL: [END] OTHERS: ' ||
                     SQLERRM;

          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

    END GET_WINNERS_PARALLEL;

  -- ***************************************************
  --    API Specifications
  -- ***************************************************
  PROCEDURE Process_Level_Winners (
      p_terr_LEVEL_target_tbl  IN       VARCHAR2,
      p_terr_PARENT_LEVEL_tbl  IN       VARCHAR2,
      p_UPPER_LEVEL_FROM_ROOT  IN       NUMBER,
      p_LOWER_LEVEL_FROM_ROOT  IN       NUMBER,
      p_matches_target         IN       VARCHAR2,
      p_source_id              IN       NUMBER,
      p_qual_type_id           IN       NUMBER,
      x_return_status          OUT NOCOPY         VARCHAR2,
      p_worker_id              IN       NUMBER := 1
      )
  AS

   l_dyn_str                    VARCHAR2(32767);
   errbuf                       VARCHAR2(2000);
   l_qual_type_id               NUMBER;

  l_level_num_rows              NUMBER;
  l_matches_num_rows            NUMBER;
  l_denorm_num_rows             NUMBER;

  BEGIN

    /* ARPATEL: 12/09/2003, For Oracle Sales denorm records are no longer striped by transaction type */
    IF p_source_id = -1001
    THEN
       l_qual_type_id := -1;
    ELSE
       l_qual_type_id := p_qual_type_id;
    END IF;

    l_level_num_rows   := 0;
    l_matches_num_rows := 0;
    l_denorm_num_rows  := 0;

    IF ( p_UPPER_LEVEL_FROM_ROOT = 1 AND p_LOWER_LEVEL_FROM_ROOT = 1) THEN

        l_dyn_str := ' ' ||
            'INSERT INTO ' || p_terr_LEVEL_target_tbl ||
            ' ( ' ||
            '    trans_object_id ' ||
            '  , trans_detail_object_id ' ||
            '  , WIN_TERR_ID ' ||
            '  , UL_TERR_ID ' ||
            '  , LL_TERR_ID ' ||
            '  , LL_NUM_WINNERS ' ||
            '  , WORKER_ID ' ||
            ' ) ' ||
            ' (  SELECT ' ||
            '    TL.trans_object_id  ' ||
            '  , TL.trans_detail_object_id  ' ||
            '  , TL.CL_WIN_TERR_ID ' ||
            '  , TL.UL_terr_id  ' ||
            '  , TL.LL_terr_id  ' ||
            '  , TL.LL_num_winners  ' ||
            '  , :B_WORKER_ID ' || --p_worker_id || bug#3391453
            '  FROM (  ' ||
            '         SELECT ';

	/* JDOCHERT: 10/26/03: bug#3209968
	** LEADING hint helps batch TAE as it makes
	** the CBO drive from the JTF_TERR_DENORM_RULES_ALL (JTDR)
	** table since there will be many more records in the TAE
	** tables than JTDR. However, this causes very bad performance
	** in the rea-time API so we switch it off there
	*/
        IF (p_matches_target LIKE 'JTF_TAE%') THEN

           /* Batch TAE */
           --l_dyn_str := l_dyn_str || ' /*+ LEADING(LL) */ '; Bug#3373462
           l_dyn_str := l_dyn_str || ' /*+ FULL(M) */ ';
           NULL;

        ELSE

           /* Real-time TAE */
           l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';

        END IF;

        l_dyn_str := l_dyn_str ||
	    '         DISTINCT ' ||
            '          m.trans_object_id  ' ||
            '        , m.trans_detail_object_id  ' ||
            '        , LL.RELATED_TERR_ID     CL_WIN_TERR_ID ' ||
            '        , UL.related_terr_id     UL_TERR_ID  ' ||

            /* JDOCHERT: 10/26/03: bug#3207099
            ** Following NVL supports backward compatibilty of
            ** Sales territories where the number of winners
            ** has not been set at the Top-Level Territory
            */
            '        , NVL(UL.num_winners, 1) UL_NUM_WINNERS  ' ||
            '        , LL.related_terr_id     LL_TERR_ID  ' ||

            /* JDOCHERT: 10/26/03: bug#3207099
            ** Following NVL supports backward compatibilty of
            ** Sales territories where the number of winners
            ** has not been set at the Top-Level Territory
            */
            '        , NVL(LL.num_winners, 1) LL_NUM_WINNERS  ' ||

            '        , DENSE_RANK() OVER ( PARTITION BY  ' ||
            '                              m.trans_object_id  ' ||
            '                            , m.trans_detail_object_id  ' ||
            '                            , UL.related_terr_id  ' ||
            '                            ORDER BY LL.absolute_rank DESC ' ||
            '                                   , LL.related_terr_id ) ' ||
            '          AS LL_TERR_RANK  ' ||
            '       FROM ' || p_matches_target || ' M  ' ||
            '          , jtf_terr_denorm_rules_all UL  ' ||
            '          , jtf_terr_denorm_rules_all LL  ' ||
            '       WHERE UL.level_from_root = :b1_UPPER_LEVEL +1 ' || /* UPPER level territory */
            '         AND UL.source_id = :b1_source_id ' ||
            '         AND UL.qual_type_id = :b1_qual_type_id ' ||
            '         AND UL.terr_id = M.TERR_ID    ' ||
            '         AND LL.level_from_root = :b1_LOWER_LEVEL +1 ' || /* LOWER level territory */
            '         AND LL.source_id = :b2_source_id ' ||
            '         AND LL.qual_type_id = :b2_qual_type_id ' ||
            '         AND LL.terr_id = M.TERR_ID    ' ||

            /* BEGIN PARALLEL WORKERS SUPPORT */
            /* JDOCHERT: 09/21/03 */
            '          AND M.worker_id = :B_WORKER_ID ' ||
            /* END PARALLEL WORKERS SUPPORT */

            '  ) TL  ' ||
            '  WHERE TL.LL_TERR_RANK <= TL.UL_num_winners  ' ||
            ' ) ';

          BEGIN

              EXECUTE IMMEDIATE l_dyn_str USING
                            p_worker_id
                          , p_UPPER_LEVEL_FROM_ROOT
                          , p_source_id
                          , l_qual_type_id
                          , p_LOWER_LEVEL_FROM_ROOT
                          , p_source_id
                          , l_qual_type_id
                          , p_worker_id;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  NULL;
          END;

    ELSE

       /* for batch TAE get the number of rows for matches , level and denorm tables */
       /* so that the winning sql can have the appropiate ordered hint               */
       IF (p_matches_target LIKE 'JTF_TAE%') THEN

         GET_NUM_ROWS( p_table_name    => p_matches_target
                     , x_num_rows      => l_matches_num_rows
                     , x_return_status => x_return_status );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE	FND_API.G_EXC_ERROR;
         END IF;

         GET_NUM_ROWS( p_table_name    => p_terr_PARENT_LEVEL_tbl
                     , x_num_rows      => l_level_num_rows
                     , x_return_status => x_return_status );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE	FND_API.G_EXC_ERROR;
         END IF;

         GET_NUM_ROWS( p_table_name    => 'JTF_TERR_DENORM_RULES_ALL'
                     , x_num_rows      => l_denorm_num_rows
                     , x_return_status => x_return_status );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE	FND_API.G_EXC_ERROR;
         END IF;

      END IF;


       l_dyn_str := ' ' ||
            'INSERT INTO ' || p_terr_LEVEL_target_tbl ||
            ' ( ' ||
            '    trans_object_id ' ||
            '  , trans_detail_object_id ' ||
            '  , WIN_TERR_ID ' ||
            '  , UL_TERR_ID ' ||
            '  , LL_TERR_ID ' ||
            '  , LL_NUM_WINNERS ' ||
            '  , WORKER_ID ' ||
            ' ) ' ||
            ' (  SELECT  ' ||
            '       TL.trans_object_id  ' ||
            '     , TL.trans_detail_object_id  ' ||
            '     , TL.CL_WIN_TERR_ID ' ||
            '     , TL.UL_terr_id  ' ||
            '     , TL.LL_terr_id  ' ||
            '     , TL.LL_num_winners  ' ||
            '     , :B_WORKER_ID ' || --p_worker_id || bug#3391453
            '    FROM (                 ' || /* NL */
            '          SELECT  ' ||
            '             CL.trans_object_id  ' ||
            '           , CL.trans_detail_object_id  ' ||
            '           , CL.CL_WIN_TERR_ID ' ||
            --'           , CL.CL_ABS_RANK ' ||
            '           , CL.UL_terr_id  ';

       /* JDOCHERT: 10/26/03: bug#3207099
       ** Following supports backward compatibilty of Sales territories
       ** number of winners has not been set at the Top-Level Territory
       */
       IF ( p_UPPER_LEVEL_FROM_ROOT = 1 AND p_LOWER_LEVEL_FROM_ROOT = 2) THEN

          l_dyn_str := l_dyn_str ||
             '           , NVL(CL.UL_NUM_WINNERS, 1) UL_NUM_WINNERS ';

       ELSE

          l_dyn_str := l_dyn_str ||
             '           , CL.UL_NUM_WINNERS UL_NUM_WINNERS ';

       END IF;

       l_dyn_str := l_dyn_str ||
            '           , CL.LL_TERR_ID  ' ||
            '           , CL.LL_NUM_WINNERS ' ||
            '           , DENSE_RANK() OVER ( PARTITION BY ' ||
            '                                 CL.trans_object_id ' ||
            '                               , CL.trans_detail_object_id ' ||
            '                               , CL.UL_TERR_ID ' ||
            '                               ORDER BY ' ||
            --'                                        CL.CL_ABS_RANK DESC ' ||
            '                                        CL.M_ABS_RANK DESC ' ||
            '                                      , CL.CL_WIN_TERR_ID ) ' ||
            '             AS LL_TERR_RANK ' ||  /* CL */
            '          FROM (  ' ||
            '               SELECT ';

       /* JDOCHERT: 10/26/03: bug#3209968
       ** LEADING hint helps batch TAE as it makes
       ** the CBO drive from the JTF_TERR_DENORM_RULES_ALL (JTDR)
       ** table since there will be many more records in the TAE
       ** tables than JTDR. However, this causes very bad performance
       ** in the rea-time API so we switch it off there
       */
       IF (p_matches_target LIKE 'JTF_TAE%') THEN

           /* Batch TAE */
           IF (p_qual_type_id = -1002) THEN
             l_dyn_str := l_dyn_str || ' /*+ USE_HASH(ML) USE_HASH(LL) USE_HASH(UL) USE_HASH(M) ORDERED */ ';
           ELSE
             l_dyn_str := l_dyn_str || ' /*+ ORDERED USE_HASH(ML) USE_HASH(M) USE_HASH(UL) USE_HASH(LL) */ ';
           END IF;
        ELSE

           /* Real-time TAE */
           l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';

       END IF;

        l_dyn_str := l_dyn_str ||
	        --'               DISTINCT ' ||
            '                  m.trans_object_id  ' ||
            '                , m.trans_detail_object_id  ' ||
            --'                , m.terr_id              M_WIN_TERR_ID ' ||
            '                , LL.related_terr_id     CL_WIN_TERR_ID ' ||
            --'                , XX.absolute_rank       CL_ABS_RANK    ' ||
            '                , UL.related_terr_id     UL_TERR_ID  ' ||
            '                , UL.num_winners         UL_NUM_WINNERS  ' ||
            '                , LL.related_terr_id     LL_TERR_ID  ' ||
            '                , LL.num_winners         LL_NUM_WINNERS  ' ||
            '                , max(m.absolute_rank)     M_ABS_RANK ' ||
            '               FROM  ';

        IF (p_matches_target LIKE 'JTF_TAE%') THEN
          IF (((l_level_num_rows <= l_matches_num_rows) AND (l_matches_num_rows <= l_denorm_num_rows)) OR
             ((l_level_num_rows <= l_denorm_num_rows) AND (l_denorm_num_rows <= l_matches_num_rows))) THEN
            l_dyn_str := l_dyn_str ||
              '                    ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
              '                  , ' || p_matches_target || ' M  ' ||
              '                  , jtf_terr_denorm_rules_all UL  ' ||
              '                  , jtf_terr_denorm_rules_all LL  ';
          ELSIF (((l_matches_num_rows <= l_level_num_rows) AND (l_level_num_rows <= l_denorm_num_rows)) OR
                 ((l_matches_num_rows <= l_denorm_num_rows) AND (l_denorm_num_rows <= l_level_num_rows))) THEN
            l_dyn_str := l_dyn_str ||
              '                    ' || p_matches_target || ' M  ' ||
              '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
              '                  , jtf_terr_denorm_rules_all UL  ' ||
              '                  , jtf_terr_denorm_rules_all LL  ';
          ELSIF (((l_denorm_num_rows <= l_level_num_rows) AND (l_level_num_rows <= l_matches_num_rows)) OR
                 ((l_denorm_num_rows <= l_matches_num_rows) AND (l_matches_num_rows <= l_level_num_rows))) THEN
            l_dyn_str := l_dyn_str ||
              '                    jtf_terr_denorm_rules_all UL  ' ||
              '                  , ' || p_matches_target || ' M  ' ||
              '                  , jtf_terr_denorm_rules_all LL  ' ||
              '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML ';
          END IF;
        ELSE
          l_dyn_str := l_dyn_str ||
            '                    jtf_terr_denorm_rules_all LL  ' ||
            '                  , ' || p_matches_target || ' M  ' ||
            '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
            '                  , jtf_terr_denorm_rules_all UL  ';
        END IF;
          l_dyn_str := l_dyn_str ||
            '               WHERE UL.level_from_root = :b1_UPPER_LEVEL +1 ' || /* UPPER level territory */
            '                 AND UL.source_id = :b2_source_id ' ||
            '                 AND UL.qual_type_id = :b3_qual_type_id ' ||
            '                 AND UL.terr_id = M.TERR_ID    ' ||
            '                 AND UL.related_terr_id = ML.LL_terr_id  ' ||
            '                 AND ( M.trans_detail_object_id = ML.trans_detail_object_id OR ' ||
            '                       M.trans_detail_object_id IS NULL ) ' ||
            '                 AND M.trans_object_id = ML.trans_object_id  ' ||

            /* BEGIN PARALLEL WORKERS SUPPORT */
            /* JDOCHERT: 09/21/03 */
            '                 AND M.worker_id = ML.WORKER_ID' ||
            '                 AND M.worker_id = :B_WORKER_ID ' ||
            '                 AND ML.worker_id = :B_WORKER_ID ' ||
            /* END PARALLEL WORKERS SUPPORT */

            '                 AND LL.level_from_root = :b4_LOWER_LEVEL +1 ' || /* LOWER level territory */
            '                 AND LL.source_id = :b5_source_id ' ||
            '                 AND LL.qual_type_id = :b6_qual_type_id ' ||
            --'                 AND XX.terr_id = LL.related_terr_id ' ||
            --'                 AND XX.related_terr_id = LL.related_terr_id ' ||
            --'                 AND XX.source_id = :b7_source_id ' ||
            --'                 AND XX.qual_type_id = :b8_qual_type_id ' ||
            '                 AND ML.LL_NUM_WINNERS IS NOT NULL ' ||
            '                 AND LL.NUM_WINNERS IS NOT NULL ' ||
            '                 AND LL.terr_id = M.TERR_ID    ' ||
            '                 GROUP BY  ' ||
            '                  m.trans_object_id  ' ||
            '                , m.trans_detail_object_id  ' ||
            '                , LL.related_terr_id     ' ||
            '                , UL.related_terr_id     ' ||
            '                , UL.num_winners         ' ||
            '                , LL.related_terr_id     ' ||
            '                , LL.num_winners         ' ||

            '               UNION ALL ' ||

            '               SELECT ';

       /* JDOCHERT: 10/26/03: bug#3209968
       ** LEADING hint helps batch TAE as it makes
       ** the CBO drive from the JTF_TERR_DENORM_RULES_ALL (JTDR)
       ** table since there will be many more records in the TAE
       ** tables than JTDR. However, this causes very bad performance
       ** in the rea-time API so we switch it off there
       */
       IF (p_matches_target LIKE 'JTF_TAE%') THEN

           /* Batch TAE */
           l_dyn_str := l_dyn_str || ' /*+ ORDERED USE_HASH(ML) USE_HASH(M) USE_HASH(UL) USE_HASH(LL) */ ';

        ELSE

           /* Real-time TAE */
           l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';

       END IF;

        l_dyn_str := l_dyn_str ||
	    '               DISTINCT ' ||
            '                  m.trans_object_id  ' ||
            '                , m.trans_detail_object_id  ' ||
            --'                , m.terr_id              M_WIN_TERR_ID ' ||
            '                , m.terr_id              CL_WIN_TERR_ID ' ||
            --'                , m.absolute_rank        CL_ABS_RANK    ' ||
            '                , UL.related_terr_id     UL_TERR_ID  ' ||
            '                , UL.num_winners         UL_NUM_WINNERS  ' ||
            '                , LL.related_terr_id     LL_TERR_ID  ' ||
            '                , LL.num_winners         LL_NUM_WINNERS  ' ||
            '                , m.absolute_rank        M_ABS_RANK ' ||
            '               FROM ';

        IF (p_matches_target LIKE 'JTF_TAE%') THEN
          IF (((l_level_num_rows <= l_matches_num_rows) AND (l_matches_num_rows <= l_denorm_num_rows)) OR
             ((l_level_num_rows <= l_denorm_num_rows) AND (l_denorm_num_rows <= l_matches_num_rows))) THEN
            l_dyn_str := l_dyn_str ||
              '                    ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
              '                  , ' || p_matches_target || ' M  ' ||
              '                  , jtf_terr_denorm_rules_all UL  ' ||
              '                  , jtf_terr_denorm_rules_all LL  ';
          ELSIF (((l_matches_num_rows <= l_level_num_rows) AND (l_level_num_rows <= l_denorm_num_rows)) OR
                 ((l_matches_num_rows <= l_denorm_num_rows) AND (l_denorm_num_rows <= l_level_num_rows))) THEN
            l_dyn_str := l_dyn_str ||
              '                    ' || p_matches_target || ' M  ' ||
              '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
              '                  , jtf_terr_denorm_rules_all UL  ' ||
              '                  , jtf_terr_denorm_rules_all LL  ';
          ELSIF (((l_denorm_num_rows <= l_level_num_rows) AND (l_level_num_rows <= l_matches_num_rows)) OR
                 ((l_denorm_num_rows <= l_matches_num_rows) AND (l_matches_num_rows <= l_level_num_rows))) THEN
            l_dyn_str := l_dyn_str ||
              '                    jtf_terr_denorm_rules_all UL  ' ||
              '                  , ' || p_matches_target || ' M  ' ||
              '                  , jtf_terr_denorm_rules_all LL  ' ||
              '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML ';
          END IF;
        ELSE
          l_dyn_str := l_dyn_str ||
            '                    jtf_terr_denorm_rules_all LL  ' ||
            '                  , ' || p_matches_target || ' M  ' ||
            '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
            '                  , jtf_terr_denorm_rules_all UL  ';
        END IF;

          l_dyn_str := l_dyn_str ||
            '               WHERE UL.level_from_root = :b9_UPPER_LEVEL +1 ' || /* UPPER level territory */
            '                 AND UL.source_id = :b10_source_id ' ||
            '                 AND UL.qual_type_id = :b11_qual_type_id ' ||
            '                 AND UL.terr_id = M.TERR_ID    ' ||
            '                 AND UL.related_terr_id = ML.LL_terr_id  ' ||
            '                 AND ( M.trans_detail_object_id = ML.trans_detail_object_id OR ' ||
            '                       M.trans_detail_object_id IS NULL ) ' ||
            '                 AND M.trans_object_id = ML.trans_object_id  ' ||

            /* BEGIN PARALLEL WORKERS SUPPORT */
            /* JDOCHERT: 09/21/03 */
            '                 AND M.worker_id = ML.WORKER_ID' ||
            '                 AND M.worker_id = :B_WORKER_ID ' ||
            '                 AND ML.worker_id = :B_WORKER_ID ' ||
            /* END PARALLEL WORKERS SUPPORT */

            '                 AND LL.level_from_root = :b12_LOWER_LEVEL +1 ' || /* LOWER level territory */
            '                 AND LL.source_id = :b13_source_id ' ||
            '                 AND LL.qual_type_id = :b14_qual_type_id ' ||

            '                 AND ML.LL_NUM_WINNERS IS NOT NULL ' ||
            '                 AND LL.NUM_WINNERS IS NULL     ' ||

            '                 AND LL.terr_id = M.TERR_ID    ' ||

            '          ) CL ' ||
            '    ) TL  ' ||
            '    WHERE TL.LL_TERR_RANK <= TL.UL_num_winners  ' ||
            ' ) ';

        BEGIN

            EXECUTE IMMEDIATE l_dyn_str USING
                          p_worker_id
                        , p_UPPER_LEVEL_FROM_ROOT
                        , p_source_id
                        , l_qual_type_id
                        , p_worker_id
                        , p_worker_id
                        , p_LOWER_LEVEL_FROM_ROOT
                        , p_source_id
                        , l_qual_type_id
                        , p_UPPER_LEVEL_FROM_ROOT
                        , p_source_id
                        , l_qual_type_id
                        , p_worker_id
                        , p_worker_id
                        , p_LOWER_LEVEL_FROM_ROOT
                        , p_source_id
                        , l_qual_type_id ;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    END IF;

    /* Program completed successfully */
    ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: ' ||
              'UPPER LEVEL = ' || p_UPPER_LEVEL_FROM_ROOT || ' ' ||
              'Successfully completed.';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status     := FND_API.G_RET_STS_ERROR;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: ' ||
                  '[END] FND_API.G_RET_STS_ERROR: ' ||
                  'UPPER LEVEL = ' || p_UPPER_LEVEL_FROM_ROOT || ' ' ||
                  'LOWER LEVEL = ' || p_LOWER_LEVEL_FROM_ROOT || ' :' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Level_Winners: ' ||
                  '[END] FND_API.G_EXC_UNEXPECTED_ERROR: ' ||
                  'UPPER LEVEL = ' || p_UPPER_LEVEL_FROM_ROOT || ' ' ||
                  'LOWER LEVEL = ' || p_LOWER_LEVEL_FROM_ROOT || ' :' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

     WHEN  utl_file.invalid_path OR
  		       utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR
  		       utl_file.invalid_operation OR
           utl_file.write_error  THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ERRBUF := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [END] UTL_FILE: ' ||
                  'UPPER LEVEL = ' || p_UPPER_LEVEL_FROM_ROOT || ' ' ||
                  'LOWER LEVEL = ' || p_LOWER_LEVEL_FROM_ROOT || ' :' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

     WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ERRBUF  := 'JTF_TAE_ASSIGN_PUB.GET_WINNERS: [END] OTHERS: ' ||
                  'UPPER LEVEL = ' || p_UPPER_LEVEL_FROM_ROOT || ' ' ||
                  'LOWER LEVEL = ' || p_LOWER_LEVEL_FROM_ROOT || ' :' ||
                   SQLERRM;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

  END Process_Level_Winners;



-- ***************************************************
--    API Specifications
-- ***************************************************
PROCEDURE Process_Final_Level_Winners (
    p_terr_LEVEL_target_tbl  IN       VARCHAR2,
    p_terr_L5_target_tbl     IN       VARCHAR2,
    p_matches_target         IN       VARCHAR2,
    p_source_id              IN       NUMBER,
    p_qual_type_id           IN       NUMBER,
    x_return_status          OUT NOCOPY         VARCHAR2,
    p_worker_id              IN       NUMBER := 1
    )
AS

 l_dyn_str                    VARCHAR2(32767);
 errbuf                       VARCHAR2(2000);
 l_qual_type_id               NUMBER;

BEGIN

    /* ARPATEL: 12/09/2003, For Oracle Sales denorm records are no longer striped by transaction type */
    IF p_source_id = -1001
    THEN
       l_qual_type_id := -1;
    ELSE
       l_qual_type_id := p_qual_type_id;
    END IF;

    l_dyn_str := ' ' ||
        'INSERT INTO ' || p_terr_LEVEL_target_tbl ||
        ' ( ' ||
        '    trans_object_id ' ||
        '  , trans_detail_object_id ' ||
        '  , WIN_TERR_ID ' ||
        '  , UL_TERR_ID ' ||
        '  , LL_TERR_ID ' ||
        '  , worker_id ' ||
        ' ) ' ||
        ' (  SELECT ' ||
        '      TL.trans_object_id ' ||
        '    , TL.trans_detail_object_id ' ||
        '    , TL.WIN_TERR_ID ' ||
        '    , TL.UL_terr_id ' ||
        '    , TL.terr_id ' ||
        '    , :B_WORKER_ID ' || --p_worker_id ||
        '    FROM (  ' ||
        '         SELECT ';

    /* JDOCHERT: 10/26/03: bug#3209968
    ** LEADING hint helps batch TAE as it makes
    ** the CBO drive from the JTF_TERR_DENORM_RULES_ALL (JTDR)
    ** table since there will be many more records in the TAE
    ** tables than JTDR. However, this causes very bad performance
    ** in the rea-time API so we switch it off there
    */
    IF (p_matches_target LIKE 'JTF_TAE%') THEN

       /* Batch TAE */
       --l_dyn_str := l_dyn_str || ' /*+ LEADING(LL) */ ';
       NULL;

    ELSE

       /* Real-time TAE */
       l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';

    END IF;

    l_dyn_str := l_dyn_str ||
	'         DISTINCT ' ||
        '          m.trans_object_id  ' ||
        '        , m.trans_detail_object_id  ' ||
        '        , M.TERR_ID            WIN_TERR_ID ' ||
        '        , UL.related_terr_id   UL_TERR_ID ' ||
        '        , UL.num_winners       UL_NUM_WINNERS ' ||
        '        , M.terr_id            TERR_ID ' ||
        '        , DENSE_RANK() OVER ( PARTITION BY ' ||
        '                          m.trans_object_id ' ||
        '                        , m.trans_detail_object_id ' ||
        '                        , UL.related_terr_id ' ||
        '                        ORDER BY M.absolute_rank DESC, M.TERR_ID ) AS LL_TERR_RANK ' ||
        '       FROM ' || p_matches_target || ' M  ' ||
        '          , jtf_terr_denorm_rules_all UL ' ||
        '          , ' || p_terr_L5_target_tbl || ' ML ' || /* FINAL LEVEL TABLE */
        '          , jtf_terr_all jt ' ||
        '          , jtf_terr_denorm_rules_all LL ' ||
        '       WHERE UL.level_from_root = 6  ' || /* UPPER level */
        '         AND UL.source_id = :b1_source_id ' ||
        '         AND UL.qual_type_id = :b1_qual_type_id ' ||
        '         AND UL.terr_id = M.TERR_ID ' ||
        '         AND UL.related_terr_id = ML.LL_terr_id ' ||
        '         AND ( M.trans_detail_object_id = ML.trans_detail_object_id OR ' ||
        '               M.trans_detail_object_id IS NULL ) ' ||
        '         AND M.trans_object_id = ML.trans_object_id ' ||

        /* BEGIN PARALLEL WORKERS SUPPORT */
        /* JDOCHERT: 09/21/03 */
        '     AND M.worker_id = ML.WORKER_ID' ||
        '     AND M.worker_id = :B_WORKER_ID ' ||
        '     AND ML.worker_id = :B_WORKER_ID ' ||
        /* END PARALLEL WORKERS SUPPORT */

        '         AND jt.terr_id = LL.related_terr_id ' ||
        '         AND LL.level_from_root >= 6 ' || /* FINAL LEVEL(S) */
        '         AND LL.source_id = :b2_source_id ' ||
        '         AND LL.qual_type_id = :b2_qual_type_id ' ||
        '         AND LL.terr_id = M.TERR_ID ' ||
        '  ) TL ' ||
        '  WHERE TL.LL_TERR_RANK <= TL.UL_num_winners  ' ||
        ' ) ';


    BEGIN


       EXECUTE IMMEDIATE l_dyn_str USING
                         p_worker_id
                       , p_source_id
                       , l_qual_type_id
                       , p_worker_id
                       , p_worker_id
                       , p_source_id
                       , l_qual_type_id ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;

    END;

    /* Program completed successfully */
    ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Final_Level_Winners: ' ||
              'Successfully completed.';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

       x_return_status     := FND_API.G_RET_STS_ERROR;
       ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Final_Level_Winners: ' ||
                 '[END] FND_API.G_RET_STS_ERROR: ' ||
                 SQLERRM;
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

	 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
       ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Final_Level_Winners: ' ||
                 '[END] FND_API.G_EXC_UNEXPECTED_ERROR: ' ||
                 SQLERRM;
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

 WHEN  utl_file.invalid_path OR
		     utl_file.invalid_mode  OR
       utl_file.invalid_filehandle OR
		     utl_file.invalid_operation OR
       utl_file.write_error  THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ERRBUF := 'JTF_TAE_ASSIGN_PUB.Process_Final_Level_Winners: [END] UTL_FILE: ' ||
                 SQLERRM;
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

 WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       ERRBUF  := 'JTF_TAE_ASSIGN_PUB.Process_Final_Level_Winners: [END] OTHERS: ' ||
                  SQLERRM;
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);

END Process_Final_Level_Winners;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : TRUNCATE_DROP_TABLE_INDEX
--    type           : public.
--    function       : TRUNCATE_DROP_TABLE_INDEX
--    pre-reqs       :
--    notes          :
--

PROCEDURE NM_TABLE_TRUNCATE_DROP_INDEX
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        p_table_name            IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    )
AS
    l_source_id                      NUMBER;
    l_trans_object_type_id           NUMBER;
    l_matches_target             VARCHAR2(30);
    l_winners_target             VARCHAR2(30);
    l_terr_L1_target             VARCHAR2(30);
    l_terr_L2_target             VARCHAR2(30);
    l_terr_L3_target             VARCHAR2(30);
    l_terr_L4_target             VARCHAR2(30);
    l_terr_L5_target             VARCHAR2(30);
    l_terr_WT_target             VARCHAR2(30);
BEGIN

    IF UPPER(p_table_name) LIKE 'JTF_TAE%NM_TRANS' THEN
        JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE( p_table_name => p_table_name
                                             , x_return_status => x_return_status);
        JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES( p_table_name => p_table_name
                                                 , x_return_status => x_return_status);
    END IF;

    l_source_id := -1001;

    IF UPPER(p_table_name) LIKE 'JTF_TAE_1001_ACCOUNT%' THEN
        l_trans_object_type_id := -1002;
    ELSIF UPPER(p_table_name) LIKE 'JTF_TAE_1001_LEAD%' THEN
        l_trans_object_type_id := -1003;
    ELSIF UPPER(p_table_name) LIKE 'JTF_TAE_1001_OPPOR%' THEN
        l_trans_object_type_id := -1004;
    END IF;


    IF (l_source_id = -1001) THEN
        IF (l_trans_object_type_id = -1002) THEN
            l_matches_target := 'JTF_TAE_1001_ACCOUNT_MATCHES';
            l_winners_target := 'JTF_TAE_1001_ACCOUNT_WINNERS';

            l_terr_L1_target := 'JTF_TAE_1001_ACCOUNT_L1';
            l_terr_L2_target := 'JTF_TAE_1001_ACCOUNT_L2';
            l_terr_L3_target := 'JTF_TAE_1001_ACCOUNT_L3';
            l_terr_L4_target := 'JTF_TAE_1001_ACCOUNT_L4';
            l_terr_L5_target := 'JTF_TAE_1001_ACCOUNT_L5';
            l_terr_WT_target := 'JTF_TAE_1001_ACCOUNT_WT';

        ELSIF (l_trans_object_type_id = -1003) THEN
            l_matches_target := 'JTF_TAE_1001_LEAD_MATCHES';
            l_winners_target := 'JTF_TAE_1001_LEAD_WINNERS';

            l_terr_L1_target := 'JTF_TAE_1001_LEAD_L1';
            l_terr_L2_target := 'JTF_TAE_1001_LEAD_L2';
            l_terr_L3_target := 'JTF_TAE_1001_LEAD_L3';
            l_terr_L4_target := 'JTF_TAE_1001_LEAD_L4';
            l_terr_L5_target := 'JTF_TAE_1001_LEAD_L5';
            l_terr_WT_target := 'JTF_TAE_1001_LEAD_WT';

        ELSIF (l_trans_object_type_id = -1004) THEN
            l_matches_target := 'JTF_TAE_1001_OPPOR_MATCHES';
            l_winners_target := 'JTF_TAE_1001_OPPOR_WINNERS';

            l_terr_L1_target := 'JTF_TAE_1001_OPPOR_L1';
            l_terr_L2_target := 'JTF_TAE_1001_OPPOR_L2';
            l_terr_L3_target := 'JTF_TAE_1001_OPPOR_L3';
            l_terr_L4_target := 'JTF_TAE_1001_OPPOR_L4';
            l_terr_L5_target := 'JTF_TAE_1001_OPPOR_L5';
            l_terr_WT_target := 'JTF_TAE_1001_OPPOR_WT';

        END IF; -- what tx type
    END IF; -- what usage

    -------------
    ---  TRUNCATE MATCHES
    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_matches_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_matches_target
                                 , x_return_status => x_return_status);
    -------------
    --- TRUNCATE WINNERS
    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_winners_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_winners_target
                                 , x_return_status => x_return_status);
    -------------
    --- Level Tables
    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_terr_L1_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L1_target
                                 , x_return_status => x_return_status);

    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_terr_L2_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L2_target
                                 , x_return_status => x_return_status);

    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_terr_L3_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L3_target
                                 , x_return_status => x_return_status);

    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_terr_L4_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L4_target
                                 , x_return_status => x_return_status);

    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_terr_L5_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_L5_target
                                 , x_return_status => x_return_status);

    JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
                          p_table_name => l_terr_WT_target
                        , x_return_status => x_return_status );

    JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
                                   p_table_name => l_terr_WT_target
                                 , x_return_status => x_return_status);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ERRBUF  := 'JTF_TAE_ASSIGN_PUB.TABLE_TRUNCATE_DROP_INDEX: [END] OTHERS: ' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
END NM_TABLE_TRUNCATE_DROP_INDEX;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : FETCH_REPROCESSED_TRANSACTIONS
--    type           : public.
--    function       : FETCH_NM_REASSIGN_TRANS
--    pre-reqs       :
--    notes          :
--

PROCEDURE FETCH_NM_REASSIGN_TRANS
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        p_destination_table     IN          VARCHAR2,
        p_source_id             IN       NUMBER,
        p_qual_type_id          IN       NUMBER,
        p_request_id            IN       NUMBER,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    )
AS
BEGIN

       --dbms_output.put_line('JTF_TAE_ASSIGN_PUB.FETCH_NM_REASSIGN_TRANS START');
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ' ');
       JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'JTF_TAE_ASSIGN_PUB.FETCH_NM_REASSIGN_TRANS: Begins... ');


        -- Clear Matches, Winners, and Level tables

        -- Start MATCH processing
        IF (p_qual_type_id = -1002) THEN

	   -- ARPATEL: bug#3180665
       /* Bug 4213107 : commented out as this is taking too long to complete
	   UPDATE JTF_TAE_1001_ACCOUNT_TRANS
              SET WORKER_ID = 1
            WHERE WORKER_ID <> 1;
      */

           JTF_TAE_1001_ACCOUNT_NMC_DYN.Search_Terr_Rules(
                          p_source_id             => p_source_id ,
                          p_trans_object_type_id  => p_qual_type_id,
                          x_Return_Status         => x_return_status,
                          x_Msg_Count             => x_msg_count,
                          x_Msg_Data              => x_msg_data,
                          p_worker_id             => 1 );

        ELSIF (p_qual_type_id = -1003) THEN

       /* Bug 4213107 : commented out as this is taking too long to complete
	   UPDATE JTF_TAE_1001_LEAD_TRANS
              SET WORKER_ID = 1
            WHERE WORKER_ID <> 1;
      */

           JTF_TAE_1001_LEAD_NMC_DYN.Search_Terr_Rules(
                          p_source_id             => p_source_id ,
                          p_trans_object_type_id  => p_qual_type_id,
                          x_Return_Status         => x_return_status,
                          x_Msg_Count             => x_msg_count,
                          x_Msg_Data              => x_msg_data,
                          p_worker_id             => 1 );

        ELSIF (p_qual_type_id = -1004) THEN

       /* Bug 4213107 : commented out as this is taking too long to complete
	   UPDATE JTF_TAE_1001_OPPOR_TRANS
              SET WORKER_ID = 1
            WHERE WORKER_ID <> 1;
      */

           JTF_TAE_1001_OPPOR_NMC_DYN.Search_Terr_Rules(
                          p_source_id             => p_source_id ,
                          p_trans_object_type_id  => p_qual_type_id,
                          x_Return_Status         => x_return_status,
                          x_Msg_Count             => x_msg_count,
                          x_Msg_Data              => x_msg_data,
                          p_worker_id             => 1 );

        END IF; -- what tx type

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --dbms_output.put_line('JTF_TAE_ASSIGN_PUB.FETCH_NM_REASSIGN_TRANS END');

EXCEPTION
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ERRBUF  := 'JTF_TAE_ASSIGN_PUB.FETCH_NM_REASSIGN_TRANS: [END] OTHERS: ' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);


END FETCH_NM_REASSIGN_TRANS;




-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : DELETE_CHANGED_TERR_RECS
--    type           : public.
--    function       : DELETE_CHANGED_TERR_RECS
--    pre-reqs       :
--    notes          : Deletes all records in JTF_CHANGED_TERR_ALL
--                     for given request_id.
--

PROCEDURE DELETE_CHANGED_TERR_RECS
        (    p_api_version_number    IN          NUMBER,
             p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
             p_SQL_Trace             IN          VARCHAR2,
             p_Debug_Flag            IN          VARCHAR2,
             p_request_id            IN          VARCHAR2,
             x_return_status         OUT NOCOPY  VARCHAR2,
             x_msg_count             OUT NOCOPY         NUMBER,
             x_msg_data              OUT NOCOPY         VARCHAR2,
             ERRBUF                  OUT NOCOPY         VARCHAR2,
             RETCODE                 OUT NOCOPY         VARCHAR2
         )
AS
BEGIN

    DELETE FROM JTF_CHANGED_TERR_ALL
    WHERE REQUEST_ID = p_request_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ERRBUF  := 'JTF_TAE_ASSIGN_PUB.DELETE_CHANGED_TERR_RECS: [END] OTHERS: ' ||
                  SQLERRM;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
END DELETE_CHANGED_TERR_RECS;

END JTF_TAE_ASSIGN_PUB;


/
