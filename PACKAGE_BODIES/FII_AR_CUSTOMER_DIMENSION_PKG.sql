--------------------------------------------------------
--  DDL for Package Body FII_AR_CUSTOMER_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_CUSTOMER_DIMENSION_PKG" AS
/* $Header: FIIARCUSTB.pls 120.14 2007/12/10 22:21:51 mmanasse ship $ */

g_debug_flag             VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_state                  VARCHAR2(500);
g_schema_name            VARCHAR2(120) := 'FII';

g_fii_user_id            NUMBER(15);
g_fii_login_id           NUMBER(15);

g_errbuf                 VARCHAR2(2000) := NULL;
g_retcode                VARCHAR2(200)  := NULL;
g_exception_msg          VARCHAR2(4000) := NULL;

G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;

g_hierarchy_type         VARCHAR2(30) := FND_PROFILE.VALUE('BIS_CUST_HIER_TYPE');
g_sysdate                DATE := sysdate;
g_last_load_date         DATE;

-- *******************************************************************
--   Initialize (get the master value set and the top node)
-- **************************************************************************

PROCEDURE Initialize  IS
     l_dir        VARCHAR2(160);

BEGIN

     g_state := 'Setting up log file location.';

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in case if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     if l_dir is NULL then
       l_dir := FII_UTIL.get_utl_file_dir;
     end if;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
     -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
     -- the log files and output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize('FII_AR_CUSTOMER_DIMENSION_PKG.log',
                         'FII_AR_CUSTOMER_DIMENSION_PKG.out', l_dir,
                         'FII_AR_CUSTOMER_DIMENSION_PKG');


     --Obtain FII schema name.
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     --Obtain user ID, login ID and initialize package variables.
     g_fii_user_id := FND_GLOBAL.USER_ID;
     g_fii_login_id := FND_GLOBAL.LOGIN_ID;


     IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
        RAISE G_LOGIN_INFO_NOT_AVABLE;
     END IF;

     if g_debug_flag = 'Y' then
        FII_UTIL.put_line('User ID: ' || g_fii_user_id || '  Login ID: ' || g_fii_login_id);
     end if;


EXCEPTION
   WHEN G_LOGIN_INFO_NOT_AVABLE THEN
        g_errbuf := 'Can not get User ID and Login ID, program exit';
        RAISE;
   WHEN OTHERS THEN
        FII_UTIL.put_line('Unexpected error when calling Initialize.');
        g_errbuf := 'Error Message: '|| substr(sqlerrm,1,180);
        RAISE;

END INITIALIZE;



-- **************************************************************************
-- This is the main procedure of CUSTOMER dimension program (initial populate).
-- **************************************************************************

PROCEDURE INIT_LOAD (errbuf  OUT NOCOPY VARCHAR2,
       	             retcode OUT NOCOPY VARCHAR2) IS
     l_max_cust_account_id NUMBER(15,0);
     l_max_batch_party_id  NUMBER(15,0);

BEGIN

     g_state := 'Inside the INIT_LOAD procedure.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     g_state := 'Calling BIS_COLLECTION_UTILITIES.setup';
     IF(NOT BIS_COLLECTION_UTILITIES.setup('FII_AR_CUST_DIM_INIT')) THEN
           raise_application_error(-20000, errbuf);
           return;
     END IF;

     g_state := 'Calling the INITIALIZE procedure to initialize global variables.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;


     INITIALIZE;


     g_state := 'Truncating customer dimension tables.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     --Truncate customer dimension tables.
     FII_UTIL.truncate_table('FII_CUSTOMER_HIERARCHIES', 'FII', g_retcode);
     FII_UTIL.truncate_table('FII_CUST_ACCOUNTS', 'FII', g_retcode);


     g_state := 'Inserting dummy record.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     --Insert dummy record required by the MVs.
     INSERT INTO FII_Customer_Hierarchies (
       Parent_Party_ID,
       Next_Level_Party_ID,
       Child_Party_ID,
       Next_Level_Is_Leaf_Flag,
       Is_Hierarchical_Flag,
       Parent_To_Next_Level,
       Next_To_Child_Level,
       Creation_Date,
       Created_By,
       Last_Update_Date,
       Last_Updated_By,
       Last_Update_Login)
     VALUES (
       -999,
       -2,
       -2,
       'Y',
       DECODE(g_hierarchy_type, NULL, 'N', 'Y'),
       1,
       0,
       sysdate,
       g_fii_user_id,
       sysdate,
       g_fii_user_id,
       g_fii_login_id);

     INSERT INTO FII_Cust_Accounts (Parent_Party_ID, Cust_Account_ID, Account_Owner_Party_ID, Creation_Date, Created_By, Last_Update_Date, Last_Updated_By, Last_Update_Login)
     VALUES (-2, -2, -2, sysdate, g_fii_user_id, sysdate, g_fii_user_id, g_fii_login_id);

     --Store the current maximum batch party id to be used in incremental loads.
     g_state := 'Storing the current maximum batch party id.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     SELECT nvl(MAX(Batch_Party_ID), -1) INTO l_max_batch_party_id
     FROM HZ_Merge_Party_History;

     UPDATE FII_Change_Log
     SET (Item_Value, Last_Update_Date, Last_Update_Login, Last_Updated_By)
         = (SELECT l_max_batch_party_id, sysdate, g_fii_login_id, g_fii_user_id FROM DUAL)
     WHERE log_item = 'MAX_BATCH_PARTY_ID';

     IF SQL%ROWCOUNT = 0 THEN
       INSERT INTO FII_Change_Log (Log_Item, Item_Value, Creation_Date, Created_By, Last_Update_Date, Last_Update_Login, Last_Updated_By)
       VALUES ('MAX_BATCH_PARTY_ID', l_max_batch_party_id, sysdate, g_fii_user_id, sysdate, g_fii_login_id, g_fii_user_id);
     END IF;

     --If a hierarchy_type is chosen, populate hierarchical parties:
     --1.  Populate intermediate tables FII_AR_Cust_LNodes_GT (Leaf Nodes) and
     --                                 FII_AR_Cust_Rlns_GT (Direct DBI Relationships).
     --2.  Populate FII_Customer_Hierarchies.


     IF g_hierarchy_type IS NOT NULL THEN

       g_state := 'Populating intermediate tables FII_AR_Cust_LNodes_GT and FII_AR_Cust_Rlns_GT.';
       if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_state);
         FII_UTIL.start_timer;
       end if;

/*     With one scan of HZ_Hierarchy_Nodes, this sql populates 2 intermediate
       tables to be used later:

       FII_AR_CUST_LNODES_GT is populated with leaf node parties.  The only
       way to detect leaf nodes is using the Leaf_Child_Flag column of
       HZ_Hierarchy_Nodes for self-records.  This table will later be used
       to populate Next_Level_Is_Leaf_Flag in FII_Customer_Hierarchies.

       FII_AR_CUST_RLNS_GT is populated with all direct relationships in the
       DBI hierarchy.  The DBI hierarchy differs from the TCA hierarchy
       because of the pseudo top node, -999.  So additional records must be
       inserted from -999 to any top node party.  Party pairs in this table
       will be used to populate Parent_Party_ID and Next_Level_Party_ID in
       FII_Customer_Hierarchies, not including self-records.  */


       INSERT ALL
       WHEN (Leaf_Child_Flag = 'Y')
       THEN INTO FII_AR_Cust_LNodes_GT(
               Leaf_Node_ID)
       VALUES (Parent_ID)
       WHEN (Top_Parent_Flag = 'Y' OR Level_Number = 1)
       THEN INTO FII_AR_Cust_Rlns_GT(
               Parent_ID,
               Next_ID)
       VALUES (CASE WHEN Level_Number = 0 THEN -999
                    ELSE Parent_ID END,
               CASE WHEN Level_Number = 0 THEN Parent_ID
                    ELSE Child_ID END)
       SELECT  Parent_ID,
               Child_ID,
               Level_Number,
               Top_Parent_Flag,
               Leaf_Child_Flag
       FROM  HZ_HIERARCHY_NODES
       WHERE Hierarchy_Type = g_hierarchy_type
       AND ( Level_Number = 1 OR
            (Level_Number = 0 AND (Top_Parent_Flag = 'Y' OR Leaf_Child_Flag = 'Y')) )
       AND g_sysdate BETWEEN Effective_Start_Date AND Effective_End_Date;

       if g_debug_flag = 'Y' then
         FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Cust_LNodes_GT and FII_AR_Cust_Rlns_GT');
         FII_UTIL.stop_timer;
         FII_UTIL.print_timer('Duration');
       end if;

       g_state := 'Populating FII_Customer_Hierarchies with hierarchical parties.';
       if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_state);
         FII_UTIL.start_timer;
       end if;

       INSERT INTO FII_Customer_Hierarchies(
               Parent_Party_ID,
               Next_Level_Party_ID,
               Child_Party_ID,
               Next_Level_Is_Leaf_Flag,
               Is_Hierarchical_Flag,
               Parent_To_Next_Level,
               Next_To_Child_Level,
               Creation_Date,
               Created_By,
               Last_Update_Date,
               Last_Updated_By,
               Last_Update_Login)
       SELECT  CASE WHEN Temp.ID = 1 THEN PTN.Parent_ID
                    ELSE PTN.Next_ID END Parent_Party_ID,
               PTN.Next_ID Next_Level_Party_ID,
               HN.Child_ID Child_Party_ID,
               DECODE(Leaf.Leaf_Node_ID, NULL, 'N', 'Y') Next_Level_Is_Leaf_Flag,
               'Y' Is_Hierarchical_Flag,
               CASE WHEN Temp.ID = 1 THEN 1
                    ELSE 0 END Parent_To_Next_Level,
               HN.Level_Number Next_To_Child_Level,
               sysdate,
               g_fii_user_id,
               sysdate,
               g_fii_user_id,
               g_fii_login_id
       FROM FII_AR_Cust_Rlns_GT PTN,
            HZ_Hierarchy_Nodes HN,
           (SELECT 1 ID FROM Dual UNION
            SELECT 2 ID FROM Dual) Temp,
            FII_AR_Cust_LNodes_GT Leaf
       WHERE PTN.Next_ID = HN.Parent_ID
       AND (Temp.ID = 1 OR HN.Parent_ID = HN.Child_ID)
       AND  HN.Hierarchy_Type = g_hierarchy_type
       AND  g_sysdate BETWEEN HN.Effective_Start_Date AND HN.Effective_End_Date
       AND  PTN.Next_ID = Leaf.Leaf_Node_ID (+);

       if g_debug_flag = 'Y' then
         FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_Customer_Hierarchies');
         FII_UTIL.stop_timer;
         FII_UTIL.print_timer('Duration');
       end if;

     END IF; --IF g_hierarchy_type IS NOT NULL

     --Store the current maximum customer account id to be used in incremental loads.
     g_state := 'Storing the current maximum customer account id.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     SELECT nvl(MAX(Cust_Account_ID),-1) INTO l_max_cust_account_id
     FROM HZ_Cust_Accounts;

     UPDATE FII_Change_Log
     SET (Item_Value, Last_Update_Date, Last_Update_Login, Last_Updated_By)
         = (SELECT l_max_cust_account_id, sysdate, g_fii_login_id, g_fii_user_id FROM DUAL)
     WHERE log_item = 'MAX_CUST_ACCOUNT_ID';

     IF SQL%ROWCOUNT = 0 THEN
       INSERT INTO FII_Change_Log (Log_Item, Item_Value, Creation_Date, Created_By, Last_Update_Date, Last_Update_Login, Last_Updated_By)
       VALUES ('MAX_CUST_ACCOUNT_ID', l_max_cust_account_id, sysdate, g_fii_user_id, sysdate, g_fii_login_id, g_fii_user_id);
     END IF;

     --From HZ_Cust_Accounts, outer join to FII_Customer_Hierarchies to:
     --1.  Populate FII_Customer_Hierarchies with non-hierarchical customers.  Use
     --    the first account from each unique party in HZ_Cust_Accounts.
     --2.  Populate FII_Cust_Accounts with hierarchical and non-hierarchical customers.

     g_state := 'Populating FII_Customer_Hierarchies with non-hierarchical customers and FII_Cust_Accounts with all customers.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT ALL
     WHEN (Parent_Party_ID IS NOT NULL AND Parent_Party_ID <> -999)
     THEN INTO FII_Cust_Accounts(
             Parent_Party_ID,
             Cust_Account_ID,
             Account_Owner_Party_ID,
             Account_Number,
             Creation_Date,
             Created_By,
             Last_Update_Date,
             Last_Updated_By,
             Last_Update_Login)
     VALUES (Parent_Party_ID,
             Cust_Account_ID,
             Party_ID,
             Account_Number,
             sysdate,
             g_fii_user_id,
             sysdate,
             g_fii_user_id,
             g_fii_login_id)
     WHEN (Parent_Party_ID IS NULL)
     THEN INTO FII_Cust_Accounts(
             Parent_Party_ID,
             Cust_Account_ID,
             Account_Owner_Party_ID,
             Account_Number,
             Creation_Date,
             Created_By,
             Last_Update_Date,
             Last_Updated_By,
             Last_Update_Login)
     VALUES (Party_ID,
             Cust_Account_ID,
             Party_ID,
             Account_Number,
             sysdate,
             g_fii_user_id,
             sysdate,
             g_fii_user_id,
             g_fii_login_id)
     WHEN (Parent_Party_ID IS NULL AND SRLID = 1)
     THEN INTO FII_Customer_Hierarchies(
             Parent_Party_ID,
             Next_Level_Party_ID,
             Child_Party_ID,
             Next_Level_Is_Leaf_Flag,
             Is_Hierarchical_Flag,
             Parent_To_Next_Level,
             Next_To_Child_Level,
             Creation_Date,
             Created_By,
             Last_Update_Date,
             Last_Updated_By,
             Last_Update_Login)
     VALUES (-999,
             Party_ID,
             Party_ID,
             'Y',
             DECODE(g_hierarchy_type, NULL, 'N', 'Y'),
             1,
             0,
             sysdate,
             g_fii_user_id,
             sysdate,
             g_fii_user_id,
             g_fii_login_id)
     WHEN (Parent_Party_ID IS NULL AND SRLID = 1)
     THEN INTO FII_Customer_Hierarchies(
             Parent_Party_ID,
             Next_Level_Party_ID,
             Child_Party_ID,
             Next_Level_Is_Leaf_Flag,
             Is_Hierarchical_Flag,
             Parent_To_Next_Level,
             Next_To_Child_Level,
             Creation_Date,
             Created_By,
             Last_Update_Date,
             Last_Updated_By,
             Last_Update_Login)
     VALUES (Party_ID,
             Party_ID,
             Party_ID,
             'Y',
             DECODE(g_hierarchy_type, NULL, 'N', 'Y'),
             0,
             0,
             sysdate,
             g_fii_user_id,
             sysdate,
             g_fii_user_id,
             g_fii_login_id)
     SELECT  /*+ parallel(CA) */ Hier.Parent_Party_ID,
             CA.Party_ID,
             CA.Cust_Account_ID,
             CA.Account_Number,
             ROW_NUMBER () OVER (
                PARTITION BY CA.Party_ID
                ORDER BY CA.Party_ID NULLS LAST) SRLID
     FROM HZ_Cust_Accounts CA,
          FII_Customer_Hierarchies Hier
     WHERE CA.Party_ID = Hier.Child_Party_ID (+)
     AND CA.Cust_Account_ID <= l_max_cust_account_id;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_Customer_Hierarchies');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;


     g_state := 'Calling BIS_COLLECTION_UTILITIES.wrapup';
     BIS_COLLECTION_UTILITIES.wrapup(
       p_status => TRUE,
       p_period_from => BIS_COMMON_PARAMETERS.Get_Global_Start_Date,
       p_period_to => g_sysdate);


EXCEPTION
  WHEN OTHERS THEN
      g_retcode := -1;
      retcode := g_retcode;

      g_exception_msg  := g_retcode || ':' || sqlerrm;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);


END INIT_LOAD;


-- *****************************************************************
-- This is the main procedure of CUSTOMER dimension program (incremental update).
-- *****************************************************************

PROCEDURE INCRE_UPDATE (errbuf  OUT NOCOPY VARCHAR2,
	 	        retcode	OUT NOCOPY VARCHAR2) IS
     l_start_date      DATE;
     l_end_date        DATE;
     l_period_from     DATE;
     l_period_to       DATE;
     l_start_date_temp DATE;

     CURSOR Party_Delta IS
     SELECT Party_ID
     FROM FII_AR_Parties_Level1_GT GROUP BY Party_ID;

     l_max_batch_party_id       NUMBER(15,0);
     l_prev_max_batch_party_id  NUMBER(15,0);
     l_max_cust_account_id      NUMBER(15,0);
     l_prev_max_cust_account_id NUMBER(15,0);

     TYPE Customer_Hierarchies_Type IS TABLE OF FII_CUSTOMER_HIERARCHIES%ROWTYPE
       INDEX BY BINARY_INTEGER;

     TYPE Cust_Hier_Tmp_Type IS TABLE OF FII_AR_CUST_HIER_TMP_GT%ROWTYPE
       INDEX BY BINARY_INTEGER;

     TYPE Cust_Account_Denorm_Type IS TABLE OF FII_CUST_ACCOUNTS%ROWTYPE
       INDEX BY BINARY_INTEGER;

     TYPE CAcct_Denorm_Tmp_Type IS TABLE OF FII_AR_CACCTS_TMP_GT%ROWTYPE
       INDEX BY BINARY_INTEGER;

     TYPE Cust_Hier_UI_Type IS TABLE OF FII_AR_CUST_HIER_UI_GT%ROWTYPE
       INDEX BY BINARY_INTEGER;

     TYPE Cust_Hier_D_Type IS TABLE OF FII_AR_CUST_HIER_D_GT%ROWTYPE
       INDEX BY BINARY_INTEGER;

     TYPE CAcct_Denorm_D_Type IS TABLE OF FII_AR_CACCTS_D_GT%ROWTYPE
       INDEX BY BINARY_INTEGER;

     FII_Cust_Hier_Old_MS       Customer_Hierarchies_Type;
     FII_Cust_Hier_New_MS       Cust_Hier_Tmp_Type;
     FII_Cust_Hier_UI_MS        Cust_Hier_UI_Type;
     FII_Cust_Hier_D_MS         Cust_Hier_D_Type;
     FII_CAcct_Denorm_Old_MS    Cust_Account_Denorm_Type;
     FII_CAcct_Denorm_New_MS    CAcct_Denorm_Tmp_Type;
     FII_CAcct_Denorm_I_MS      Cust_Account_Denorm_Type;
     FII_CAcct_Denorm_D_MS      CAcct_Denorm_D_Type;

     l_cust_hier_old_marker     BINARY_INTEGER;
     l_cust_hier_new_marker     BINARY_INTEGER;
     l_cacct_denorm_old_marker  BINARY_INTEGER;
     l_cacct_denorm_new_marker  BINARY_INTEGER;

     l_old_ch                   FII_CUSTOMER_HIERARCHIES%ROWTYPE;
     l_new_ch                   FII_AR_CUST_HIER_TMP_GT%ROWTYPE;
     l_ui_ch                    FII_AR_CUST_HIER_UI_GT%ROWTYPE;
     l_d_ch                     FII_AR_CUST_HIER_D_GT%ROWTYPE;
     l_old_cad                  FII_CUST_ACCOUNTS%ROWTYPE;
     l_new_cad                  FII_AR_CACCTS_TMP_GT%ROWTYPE;
     l_i_cad                    FII_CUST_ACCOUNTS%ROWTYPE;
     l_d_cad                    FII_AR_CACCTS_D_GT%ROWTYPE;

BEGIN

     g_state := 'Inside the INCRE_UPDATE procedure.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     g_state := 'Calling BIS API to get last refresh dates.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AR_CUST_DIM_INIT',
                                                   l_start_date, l_end_date,
                                                   l_period_from, l_period_to);


     BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AR_CUST_DIM_INC',
                                                   l_start_date_temp, l_end_date,
                                                   l_period_from, l_period_to);


     g_last_load_date := GREATEST(NVL(l_start_date, BIS_COMMON_PARAMETERS.Get_Global_Start_Date),
                           NVL(l_start_date_temp, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Incremental load will collect data from ' || to_char(g_last_load_date, 'YYYY/MM/DD HH24:MI:SS') || ' to ' || to_char(g_sysdate, 'YYYY/MM/DD HH24:MI:SS') || '.');
     end if;

     g_state := 'Calling BIS_COLLECTION_UTILITIES.setup';
     IF(NOT BIS_COLLECTION_UTILITIES.setup('FII_AR_CUST_DIM_INC')) THEN
           raise_application_error(-20000, errbuf);
           return;
     END IF;

     g_state := 'Calling the INITIALIZE procedure to initialize global variables.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;
     INITIALIZE;

     g_state := 'Storing previous maximum batch party id.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     SELECT item_value
     INTO l_prev_max_batch_party_id
     FROM fii_change_log
     WHERE log_item = 'MAX_BATCH_PARTY_ID';

     g_state := 'Storing the current maximum batch party id.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     SELECT nvl(MAX(Batch_Party_ID), -1) INTO l_max_batch_party_id
     FROM HZ_Merge_Party_History
     WHERE Batch_Party_ID >= l_prev_max_batch_party_id;

     IF l_max_batch_party_id > l_prev_max_batch_party_id THEN

       UPDATE FII_Change_Log
       SET (Item_Value, Last_Update_Date, Last_Update_Login, Last_Updated_By)
           = (SELECT l_max_batch_party_id, sysdate, g_fii_login_id, g_fii_user_id FROM DUAL)
       WHERE log_item = 'MAX_BATCH_PARTY_ID';

       g_state := 'Populate FII_AR_Parties_Delta_GT with parties that have been merged.';
       if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_state);
         FII_UTIL.start_timer;
       end if;

       INSERT ALL
       WHEN (1=1)
       THEN INTO FII_AR_Parties_Delta_GT(Party_ID, Type_ID)
       VALUES (From_Entity_ID, 5)
       WHEN (1=1)
       THEN INTO FII_AR_Parties_Delta_GT(Party_ID, Type_ID)
       VALUES (To_Entity_ID, 6)
       SELECT From_Entity_ID, To_Entity_ID
       FROM  HZ_Merge_Party_History M,
             HZ_Merge_Dictionary D
       WHERE M.merge_dict_id = D.merge_dict_id
       AND   M.batch_party_id > l_prev_max_batch_party_id
       AND   M.batch_party_id <= l_max_batch_party_id
       AND   D.entity_name = 'HZ_PARTIES';

       if g_debug_flag = 'Y' then
         FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Parties_Delta_GT');
         FII_UTIL.stop_timer;
         FII_UTIL.print_timer('Duration');
       end if;

     END IF;

     IF g_hierarchy_type IS NOT NULL THEN

     g_state := 'Populate FII_AR_Parties_Delta_GT with potentially deleted parties and FII_AR_Parties_Level1_GT with potentially new or updated parent parties.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT ALL
     WHEN (Level_Number = 0)
     THEN INTO FII_AR_Parties_Delta_GT (
             Party_ID,
             Type_ID)
     VALUES (Child_ID,
             DECODE(Top_Parent_Flag, 'Y',
                    CASE WHEN g_sysdate BETWEEN Effective_Start_Date AND Effective_End_Date
                         THEN 4 ELSE 3 END,
                    3))
     WHEN (Effective_End_Date BETWEEN g_last_load_date AND g_sysdate
           AND Level_Number = 1)
     THEN INTO FII_AR_Parties_Delta_GT (
             Party_ID,
             Type_ID,
             Level_Number)
     VALUES (Child_ID, 2, 0)
     WHEN (Effective_End_Date NOT BETWEEN g_last_load_date AND g_sysdate
           AND Level_Number = 1)
     THEN INTO FII_AR_Parties_Level1_GT (
             Party_ID)
     VALUES (Child_ID)
     SELECT Child_ID,
            Level_Number,
            Top_Parent_Flag,
            Effective_End_Date,
            Effective_Start_Date,
            Last_Update_Date
     FROM HZ_Hierarchy_Nodes
     WHERE Hierarchy_Type = g_hierarchy_type
     AND (Level_Number = 0 OR Level_Number = 1)
     AND (Effective_End_Date BETWEEN g_last_load_date AND g_sysdate
     OR Effective_Start_Date BETWEEN g_last_load_date AND g_sysdate
     OR Last_Update_Date BETWEEN g_last_load_date AND g_sysdate);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Parties_Delta_GT and FII_AR_Parties_Level1_GT');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate FII_AR_Parties_Level2_GT while looping through FII_AR_Parties_Level1_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

    FOR Party_Record IN Party_Delta
     LOOP

       INSERT ALL
       WHEN  (SRLID=1)
       THEN INTO FII_AR_Parties_Level2_GT(
              Party_ID)
       VALUES(Child_ID)
       WHEN  (SRLID=1)
       THEN INTO FII_AR_Top_To_Source_GT(
              Top_Node_ID,
              Source_Node_ID,
              Level_Number)
       VALUES(Parent_ID,
              Party_Record.Party_ID,
              Level_Number)
       SELECT Parent_ID,
              Child_ID,
              Level Level_Number,
              ROW_NUMBER () OVER (ORDER BY Level DESC) SRLID
       FROM (SELECT * FROM HZ_Hierarchy_Nodes
             WHERE Level_Number = 1
             AND Hierarchy_Type = g_hierarchy_type
             AND g_sysdate BETWEEN Effective_Start_Date AND Effective_End_Date)
       START WITH Child_ID = Party_Record.Party_ID
       CONNECT BY PRIOR Parent_ID = Child_ID;

       IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO FII_AR_Parties_Delta_GT(
                Party_ID,
                Type_ID,
                Level_Number)
         VALUES(Party_Record.Party_ID,
                2,
                0);
       END IF;

     END LOOP;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed population of FII_AR_Parties_Level2_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate FII_AR_Parties_Delta_GT with descendants of parties in FII_AR_Parties_Level2_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT INTO FII_AR_Parties_Delta_GT(Party_ID, Type_ID)
     SELECT HN.Child_ID, 1
     FROM FII_AR_Parties_Level2_GT Log,
          HZ_Hierarchy_Nodes HN
     WHERE Log.Party_ID = HN.Parent_ID
     AND HN.Hierarchy_Type = g_hierarchy_type
     AND g_sysdate BETWEEN HN.Effective_Start_Date AND HN.Effective_End_Date;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Parties_Delta_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate FII_AR_Top_To_Source_GT with descendants of parties already in FII_AR_Top_To_Source_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT INTO FII_AR_Top_To_Source_GT(
       Top_Node_ID,
       Source_Node_ID,
       Level_Number)
     SELECT GT.Top_Node_ID,
            HN.Child_ID,
            GT.Level_Number + HN.Level_Number Level_Number
     FROM FII_AR_Top_To_Source_GT GT,
          HZ_Hierarchy_Nodes HN
     WHERE GT.Source_Node_ID = HN.Parent_ID
     AND HN.Hierarchy_Type = g_hierarchy_type
     AND g_sysdate BETWEEN HN.Effective_Start_Date AND HN.Effective_End_Date
     AND HN.Level_Number > 0;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Top_To_Source_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate FII_AR_Parties_Delta_GT with descendants of deleted relationships.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT INTO FII_AR_Parties_Delta_GT(
       Party_ID,
       Type_ID,
       Level_Number)
     SELECT  HN.Child_ID,
             2,
             HN.Level_Number
     FROM FII_AR_Parties_Delta_GT GT,
          HZ_Hierarchy_Nodes HN
     WHERE GT.Party_ID = HN.Parent_ID
     AND GT.Type_ID = 2
     AND HN.Hierarchy_Type = g_hierarchy_type
     AND g_sysdate BETWEEN HN.Effective_Start_Date AND HN.Effective_End_Date
     AND HN.Level_Number > 0;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Parties_Delta_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;


     g_state := 'Populate FII_AR_Cust_LNodes_GT and FII_AR_Cust_Rlns_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT ALL
     WHEN (Leaf_Child_Flag = 'Y')
     THEN INTO FII_AR_Cust_LNodes_GT(
             Leaf_Node_ID)
     VALUES (Parent_ID)
     WHEN (Top_Parent_Flag = 'Y' OR Level_Number = 1)
     THEN INTO FII_AR_Cust_Rlns_GT(
             Parent_ID,
             Next_ID)
     VALUES (CASE WHEN Level_Number = 0 THEN -999
                  ELSE Parent_ID END,
             CASE WHEN Level_Number = 0 THEN Parent_ID
                  ELSE Child_ID END)
     SELECT  Parent_ID,
             Child_ID,
             Level_Number,
             Top_Parent_Flag,
             Leaf_Child_Flag
     FROM  HZ_HIERARCHY_NODES HN
     WHERE EXISTS (SELECT 1 FROM FII_AR_Parties_Delta_GT Log
                   WHERE Log.Party_ID = HN.Child_ID)
     AND Hierarchy_Type = g_hierarchy_type
     AND ( Level_Number = 1 OR
          (Level_Number = 0 AND (Top_Parent_Flag = 'Y' OR Leaf_Child_Flag = 'Y')) )
     AND g_sysdate BETWEEN Effective_Start_Date AND Effective_End_Date;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Cust_LNodes_GT and FII_AR_Cust_Rlns_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate FII_AR_Cust_Hier_Tmp_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT INTO FII_AR_Cust_Hier_Tmp_GT(
            Parent_Party_ID,
            Next_Level_Party_ID,
            Child_Party_ID,
            Next_Level_Is_Leaf_Flag,
            Is_Hierarchical_Flag,
            Parent_To_Next_Level,
            Next_To_Child_Level)
     SELECT CASE WHEN Temp.ID = 1 THEN PTN.Parent_ID
                 ELSE PTN.Next_ID END Parent_Party_ID,
            PTN.Next_ID Next_Level_Party_ID,
            HN.Child_ID Child_Party_ID,
            DECODE(Leaf.Leaf_Node_ID, NULL, 'N', 'Y') Next_Level_Is_Leaf_Flag,
            DECODE(g_hierarchy_type, NULL, 'N', 'Y') Is_Hierarchical_Flag,
            CASE WHEN Temp.ID = 1 THEN 1
                 ELSE 0 END Parent_To_Next_Level,
            HN.Level_Number Next_To_Child_Level
     FROM FII_AR_Cust_Rlns_GT PTN,
          HZ_Hierarchy_Nodes HN,
         (SELECT 1 ID FROM Dual UNION
          SELECT 2 ID FROM Dual) Temp,
          FII_AR_Cust_LNodes_GT Leaf
     WHERE PTN.Next_ID = HN.Parent_ID
     AND (Temp.ID = 1 OR HN.Parent_ID = HN.Child_ID)
     AND  HN.Hierarchy_Type = g_hierarchy_type
     AND  g_sysdate BETWEEN HN.Effective_Start_Date AND HN.Effective_End_Date
     AND  PTN.Next_ID = Leaf.Leaf_Node_ID (+);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Cust_Hier_Tmp_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     END IF; --IF g_hierarchy_type IS NOT NULL

     g_state := 'Storing previous maximum customer account id.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     SELECT item_value
     INTO l_prev_max_cust_account_id
     FROM fii_change_log
     WHERE log_item = 'MAX_CUST_ACCOUNT_ID';

     g_state := 'Storing the current maximum customer account id.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
     end if;

     SELECT nvl(MAX(Cust_Account_ID),-1) INTO l_max_cust_account_id
     FROM HZ_Cust_Accounts
     WHERE Cust_Account_ID >= l_prev_max_cust_account_id;

     UPDATE FII_Change_Log
     SET (Item_Value, Last_Update_Date, Last_Update_Login, Last_Updated_By)
         = (SELECT NVL(l_max_cust_account_id, l_prev_max_cust_account_id), sysdate, g_fii_login_id, g_fii_user_id FROM DUAL)
     WHERE log_item = 'MAX_CUST_ACCOUNT_ID';

     g_state := 'Populate FII_AR_CAccts_Delta_GT with customer accounts that are new or in an updated hierarchy.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT INTO FII_AR_Caccts_Delta_GT(Cust_Account_ID, Party_ID, Account_Number)
     SELECT Cust_Account_ID, Party_ID, Account_Number
     FROM HZ_Cust_Accounts CA
     WHERE EXISTS (SELECT 1 FROM FII_AR_Parties_Delta_GT Log
                   WHERE Log.Party_ID = CA.Party_ID)
     OR (Cust_Account_ID > l_prev_max_cust_account_id
         AND Cust_Account_ID <= l_max_cust_account_id);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_CAccts_Delta_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populating FII_AR_Cust_Hier_Tmp_GT with new non-hierarchical customers and FII_AR_CAccts_Tmp_GT with all new customers.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     INSERT ALL
     WHEN (Parent_Party_ID IS NOT NULL AND Parent_Party_ID <> -999)
     THEN INTO FII_AR_Caccts_Tmp_GT(
             Parent_Party_ID,
             Cust_Account_ID,
             Account_Party_ID,
             Account_Number)
     VALUES (Parent_Party_ID,
             Cust_Account_ID,
             Party_ID,
             Account_Number)
     WHEN (Parent_Party_ID IS NULL)
     THEN INTO FII_AR_Caccts_Tmp_GT(
             Parent_Party_ID,
             Cust_Account_ID,
             Account_Party_ID,
             Account_Number)
     VALUES (Party_ID,
             Cust_Account_ID,
             Party_ID,
             Account_Number)
     WHEN (Parent_Party_ID IS NULL AND SRLID = 1)
     THEN INTO FII_AR_Cust_Hier_Tmp_GT(
             Parent_Party_ID,
             Next_Level_Party_ID,
             Child_Party_ID,
             Next_Level_Is_Leaf_Flag,
             Is_Hierarchical_Flag,
             Parent_To_Next_Level,
             Next_To_Child_Level)
     VALUES (-999,
             Party_ID,
             Party_ID,
             'Y',
             DECODE(g_hierarchy_type, NULL, 'N', 'Y'),
             1,
             0)
     WHEN (Parent_Party_ID IS NULL AND SRLID = 1)
     THEN INTO FII_AR_Cust_Hier_Tmp_GT(
             Parent_Party_ID,
             Next_Level_Party_ID,
             Child_Party_ID,
             Next_Level_Is_Leaf_Flag,
             Is_Hierarchical_Flag,
             Parent_To_Next_Level,
             Next_To_Child_Level)
     VALUES (Party_ID,
             Party_ID,
             Party_ID,
             'Y',
             DECODE(g_hierarchy_type, NULL, 'N', 'Y'),
             0,
             0)
     SELECT  Hier.Parent_ID Parent_Party_ID,
             CA.Party_ID Party_ID,
             CA.Cust_Account_ID,
             CA.Account_Number,
             ROW_NUMBER () OVER (
                PARTITION BY CA.Party_ID
                ORDER BY CA.Party_ID NULLS LAST) SRLID
     FROM FII_AR_Caccts_Delta_GT CA,
          (SELECT Parent_ID, Child_ID
           FROM HZ_Hierarchy_Nodes
           WHERE Hierarchy_Type = g_hierarchy_type
           AND g_sysdate BETWEEN Effective_Start_Date AND Effective_End_Date) Hier
     WHERE CA.Party_ID = Hier.Child_ID (+);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AR_Cust_Hier_Tmp_GT and FII_AR_CAccts_Tmp_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Merging records in FII_Customer_Hierarchies using FII_AR_Top_To_Source_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     MERGE INTO FII_Customer_Hierarchies CH
     USING (SELECT DISTINCT Top_Node_ID, Source_Node_ID, Level_Number
            FROM FII_AR_Top_To_Source_GT) GT
     ON (CH.Parent_Party_ID = -999 AND
         CH.Child_Party_ID = GT.Source_Node_ID)
     WHEN MATCHED THEN
       UPDATE SET CH.Next_Level_Party_ID = GT.Top_Node_ID,
                  CH.Next_Level_Is_Leaf_Flag = 'N',
                  CH.Next_To_Child_Level = GT.Level_Number,
                  CH.Last_Update_Date = sysdate,
                  CH.Last_Updated_By = g_fii_user_id,
                  CH.Last_Update_Login = g_fii_login_id
     WHEN NOT MATCHED THEN
       INSERT (CH.Parent_Party_ID,
               CH.Next_Level_Party_ID,
               CH.Child_Party_ID,
               CH.Next_Level_Is_Leaf_Flag,
               CH.Is_Hierarchical_Flag,
               CH.Parent_To_Next_Level,
               CH.Next_To_Child_Level,
               CH.Creation_Date,
               CH.Created_By,
               CH.Last_Update_Date,
               CH.Last_Updated_By,
               CH.Last_Update_Login)
       VALUES (-999,
               GT.Top_Node_ID,
               GT.Source_Node_ID,
               'N',
               DECODE(g_hierarchy_type, NULL, 'N', 'Y'),
               1,
               GT.Level_Number,
               sysdate,
               g_fii_user_id,
               sysdate,
               g_fii_user_id,
               g_fii_login_id);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Merged ' || SQL%ROWCOUNT || ' records in FII_Customer_Hierarchies.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     --Compare old and new data in memory before update/insert/delete.
     --1.  Bulk collect new data into memory structures.
     --2.  Bulk collect old data into memory structures.
     --3.  Loop through new and old memory structures to populate an update/insert
     --    memory structure and a delete memory structure for each customer dimension table.
     --4.  Bulk insert from update/insert and delete memory structures into tables.
     --5.  Use update/insert and delete tables to merge and delete customer dimension tables.

     g_state := 'Populate memory structure FII_Cust_Hier_New_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     SELECT *
     BULK COLLECT INTO FII_Cust_Hier_New_MS
     FROM FII_AR_Cust_Hier_Tmp_GT CH
     ORDER BY Parent_Party_ID, Next_Level_Party_ID, Child_Party_ID;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || FII_Cust_Hier_New_MS.COUNT || ' records into FII_Cust_Hier_New_MS.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate memory structure FII_CAcct_Denorm_New_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     SELECT *
     BULK COLLECT INTO FII_CAcct_Denorm_New_MS
     FROM FII_AR_CAccts_Tmp_GT CH
     ORDER BY Parent_Party_ID, Cust_Account_ID;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || FII_CAcct_Denorm_New_MS.COUNT || ' records into FII_CAcct_Denorm_New_MS.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate memory structure FII_Cust_Hier_Old_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     SELECT *
     BULK COLLECT INTO FII_Cust_Hier_Old_MS
     FROM FII_Customer_Hierarchies CH
     WHERE EXISTS (SELECT 1 FROM FII_AR_Parties_Delta_GT Log
                   WHERE Log.Party_ID = CH.Child_Party_ID
                   AND ((Log.Type_ID = 1 AND CH.Parent_Party_ID <> -999)
                        OR (Log.Type_ID = 2
                            AND CH.Parent_To_Next_Level + CH.Next_To_Child_Level > Log.Level_Number)
                        OR (Log.Type_ID = 3
                            AND (CH.Parent_To_Next_Level + CH.Next_To_Child_Level = 0))
                        OR (Log.Type_ID = 4
                            AND (CH.Parent_To_Next_Level + CH.Next_To_Child_Level = 0
                                 OR CH.Parent_Party_ID = -999))
                        OR Log.Type_ID = 5))
     ORDER BY Parent_Party_ID, Next_Level_Party_ID, Child_Party_ID;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || FII_Cust_Hier_Old_MS.COUNT || ' records into FII_Cust_Hier_Old_MS.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Populate memory structure FII_CAcct_Denorm_Old_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     SELECT *
     BULK COLLECT INTO FII_CAcct_Denorm_Old_MS
     FROM FII_Cust_Accounts CAD
     WHERE EXISTS (SELECT 1 FROM FII_AR_Caccts_Delta_GT Log
                   WHERE Log.Cust_Account_ID = CAD.Cust_Account_ID)
     ORDER BY Parent_Party_ID, Cust_Account_ID;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Inserted ' || FII_CAcct_Denorm_Old_MS.COUNT || ' records into FII_CAcct_Denorm_Old_MS.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Looping through FII_Cust_Hier_New_MS and FII_Cust_Hier_Old_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     l_cust_hier_old_marker := FII_Cust_Hier_Old_MS.FIRST;
     l_cust_hier_new_marker := FII_Cust_Hier_New_MS.FIRST;

     WHILE l_cust_hier_old_marker IS NOT NULL
     AND l_cust_hier_new_marker IS NOT NULL LOOP

       l_old_ch := FII_Cust_Hier_Old_MS(l_cust_hier_old_marker);
       l_new_ch := FII_Cust_Hier_New_MS(l_cust_hier_new_marker);

       IF l_old_ch.Parent_Party_ID = l_new_ch.Parent_Party_ID
       AND l_old_ch.Next_Level_Party_ID = l_new_ch.Next_Level_Party_ID
       AND l_old_ch.Child_Party_ID = l_new_ch.Child_Party_ID THEN

         --Check if the record has been updated.  To avoid unnecessary updates, only
         --insert into FII_AR_Cust_Hier_UI_GT if a column has changed.

         IF (l_old_ch.Next_Level_Is_Leaf_Flag <> l_new_ch.Next_Level_Is_Leaf_Flag
            OR l_old_ch.Parent_To_Next_Level <> l_new_ch.Parent_To_Next_Level
            OR l_old_ch.Next_To_Child_Level <> l_new_ch.Next_To_Child_Level) THEN
            l_ui_ch.Parent_Party_ID := l_new_ch.Parent_Party_ID;
            l_ui_ch.Next_Level_Party_ID := l_new_ch.Next_Level_Party_ID;
            l_ui_ch.Child_Party_ID := l_new_ch.Child_Party_ID;
            l_ui_ch.Next_Level_Is_Leaf_Flag := l_new_ch.Next_Level_Is_Leaf_Flag;
            l_ui_ch.Is_Hierarchical_Flag := l_new_ch.Is_Hierarchical_Flag;
            l_ui_ch.Parent_To_Next_Level := l_new_ch.Parent_To_Next_Level;
            l_ui_ch.Next_To_Child_Level := l_new_ch.Next_To_Child_Level;

            FII_Cust_Hier_UI_MS(FII_Cust_Hier_UI_MS.Count+1) := l_ui_ch;

         END IF;

         l_cust_hier_old_marker := FII_Cust_Hier_Old_MS.Next(l_cust_hier_old_marker);
         l_cust_hier_new_marker := FII_Cust_Hier_New_MS.Next(l_cust_hier_new_marker);

       ELSIF (l_old_ch.Parent_Party_ID < l_new_ch.Parent_Party_ID
              OR (l_old_ch.Parent_Party_ID = l_new_ch.Parent_Party_ID
                  AND l_old_ch.Next_Level_Party_ID < l_new_ch.Next_Level_Party_ID)
              OR (l_old_ch.Parent_Party_ID = l_new_ch.Parent_Party_ID
                  AND l_old_ch.Next_Level_Party_ID = l_new_ch.Next_Level_Party_ID
                  AND l_old_ch.Child_Party_ID < l_new_ch.Child_Party_ID)) THEN

         --This is a deleted record so insert into FII_Cust_Hier_D_MS.
         l_d_ch.Parent_Party_ID := l_old_ch.Parent_Party_ID;
         l_d_ch.Next_Level_Party_ID := l_old_ch.Next_Level_Party_ID;
         l_d_ch.Child_Party_ID := l_old_ch.Child_Party_ID;

         FII_Cust_Hier_D_MS (FII_Cust_Hier_D_MS.Count+1) := l_d_ch;

         l_cust_hier_old_marker := FII_Cust_Hier_Old_MS.Next(l_cust_hier_old_marker);

       ELSE
         --This is a new record so insert into FII_Cust_Hier_UI_MS,
         l_ui_ch.Parent_Party_ID := l_new_ch.Parent_Party_ID;
         l_ui_ch.Next_Level_Party_ID := l_new_ch.Next_Level_Party_ID;
         l_ui_ch.Child_Party_ID := l_new_ch.Child_Party_ID;
         l_ui_ch.Next_Level_Is_Leaf_Flag := l_new_ch.Next_Level_Is_Leaf_Flag;
         l_ui_ch.Is_Hierarchical_Flag := l_new_ch.Is_Hierarchical_Flag;
         l_ui_ch.Parent_To_Next_Level := l_new_ch.Parent_To_Next_Level;
         l_ui_ch.Next_To_Child_Level := l_new_ch.Next_To_Child_Level;

         FII_Cust_Hier_UI_MS (FII_Cust_Hier_UI_MS.Count+1) := l_ui_ch;

         l_cust_hier_new_marker := FII_Cust_Hier_New_MS.Next(l_cust_hier_new_marker);

       END IF;

     END LOOP;


     WHILE l_cust_hier_old_marker IS NOT NULL LOOP

       l_old_ch := FII_Cust_Hier_Old_MS(l_cust_hier_old_marker);

       l_d_ch.Parent_Party_ID := l_old_ch.Parent_Party_ID;
       l_d_ch.Next_Level_Party_ID := l_old_ch.Next_Level_Party_ID;
       l_d_ch.Child_Party_ID := l_old_ch.Child_Party_ID;

       FII_Cust_Hier_D_MS (FII_Cust_Hier_D_MS.Count+1) := l_d_ch;

       l_cust_hier_old_marker := FII_Cust_Hier_Old_MS.Next(l_cust_hier_old_marker);
     END LOOP;


     WHILE l_cust_hier_new_marker IS NOT NULL LOOP

       l_new_ch := FII_Cust_Hier_New_MS(l_cust_hier_new_marker);

       l_ui_ch.Parent_Party_ID := l_new_ch.Parent_Party_ID;
       l_ui_ch.Next_Level_Party_ID := l_new_ch.Next_Level_Party_ID;
       l_ui_ch.Child_Party_ID := l_new_ch.Child_Party_ID;
       l_ui_ch.Next_Level_Is_Leaf_Flag := l_new_ch.Next_Level_Is_Leaf_Flag;
       l_ui_ch.Is_Hierarchical_Flag := l_new_ch.Is_Hierarchical_Flag;
       l_ui_ch.Parent_To_Next_Level := l_new_ch.Parent_To_Next_Level;
       l_ui_ch.Next_To_Child_Level := l_new_ch.Next_To_Child_Level;

       FII_Cust_Hier_UI_MS (FII_Cust_Hier_UI_MS.Count+1) := l_ui_ch;

       l_cust_hier_new_marker := FII_Cust_Hier_New_MS.Next(l_cust_hier_new_marker);
     END LOOP;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed looping through FII_Cust_Hier_New_MS and FII_Cust_Hier_Old_MS.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Looping through FII_CAcct_Denorm_New_MS and FII_CAcct_Denorm_Old_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     l_cacct_denorm_old_marker := FII_CAcct_Denorm_Old_MS.FIRST;
     l_cacct_denorm_new_marker := FII_CAcct_Denorm_New_MS.FIRST;

     WHILE l_cacct_denorm_old_marker IS NOT NULL
     AND l_cacct_denorm_new_marker IS NOT NULL LOOP
       l_old_cad := FII_CAcct_Denorm_Old_MS(l_cacct_denorm_old_marker);
       l_new_cad := FII_CAcct_Denorm_New_MS(l_cacct_denorm_new_marker);

       IF l_old_cad.Parent_Party_ID = l_new_cad.Parent_Party_ID
       AND l_old_cad.Cust_Account_ID = l_new_cad.Cust_Account_ID THEN

         --To avoid unnecessary updates, ignore unchanged record.
         --Only update occurs if party merge changes account party id.  In this case, delete then insert.

         IF l_old_cad.Account_Owner_Party_ID <> l_new_cad.Account_Party_ID THEN
           --Delete old record.
           l_d_cad.Parent_Party_ID := l_old_cad.Parent_Party_ID;
           l_d_cad.Cust_Account_ID := l_old_cad.Cust_Account_ID;

           FII_CAcct_Denorm_D_MS (FII_CAcct_Denorm_D_MS.Count+1) := l_d_cad;

           --Insert new record.
           l_i_cad.Parent_Party_ID := l_new_cad.Parent_Party_ID;
           l_i_cad.Cust_Account_ID := l_new_cad.Cust_Account_ID;
           l_i_cad.Account_Owner_Party_ID := l_new_cad.Account_Party_ID;
           l_i_cad.Account_Number := l_new_cad.Account_Number;
           l_i_cad.Creation_Date := sysdate;
           l_i_cad.Created_By := g_fii_user_id;
           l_i_cad.Last_Update_Date := sysdate;
           l_i_cad.Last_Updated_By := g_fii_user_id;
           l_i_cad.Last_Update_Login := g_fii_login_id;

           FII_CAcct_Denorm_I_MS (FII_CAcct_Denorm_I_MS.Count+1) := l_i_cad;

         END IF;

         l_cacct_denorm_old_marker := FII_CAcct_Denorm_Old_MS.Next(l_cacct_denorm_old_marker);
         l_cacct_denorm_new_marker := FII_CAcct_Denorm_New_MS.Next(l_cacct_denorm_new_marker);

       ELSIF (l_old_cad.Parent_Party_ID < l_new_cad.Parent_Party_ID
              OR (l_old_cad.Parent_Party_ID = l_new_cad.Parent_Party_ID
                  AND l_old_cad.Cust_Account_ID < l_new_cad.Cust_Account_ID)) THEN
         --This is a deleted record so insert into FII_CAcct_Denorm_D_MS.
         l_d_cad.Parent_Party_ID := l_old_cad.Parent_Party_ID;
         l_d_cad.Cust_Account_ID := l_old_cad.Cust_Account_ID;

         FII_CAcct_Denorm_D_MS (FII_CAcct_Denorm_D_MS.Count+1) := l_d_cad;


         l_cacct_denorm_old_marker := FII_CAcct_Denorm_Old_MS.Next(l_cacct_denorm_old_marker);

       ELSE
           --This is a new record so insert into FII_CAcct_Denorm_I_MS,
           l_i_cad.Parent_Party_ID := l_new_cad.Parent_Party_ID;
           l_i_cad.Cust_Account_ID := l_new_cad.Cust_Account_ID;
           l_i_cad.Account_Owner_Party_ID := l_new_cad.Account_Party_ID;
           l_i_cad.Account_Number := l_new_cad.Account_Number;
           l_i_cad.Creation_Date := sysdate;
           l_i_cad.Created_By := g_fii_user_id;
           l_i_cad.Last_Update_Date := sysdate;
           l_i_cad.Last_Updated_By := g_fii_user_id;
           l_i_cad.Last_Update_Login := g_fii_login_id;

           FII_CAcct_Denorm_I_MS (FII_CAcct_Denorm_I_MS.Count+1) := l_i_cad;

           l_cacct_denorm_new_marker := FII_CAcct_Denorm_New_MS.Next(l_cacct_denorm_new_marker);

       END IF;

     END LOOP;


     WHILE l_cacct_denorm_old_marker IS NOT NULL LOOP
       l_old_cad := FII_CAcct_Denorm_Old_MS(l_cacct_denorm_old_marker);

       l_d_cad.Parent_Party_ID := l_old_cad.Parent_Party_ID;
       l_d_cad.Cust_Account_ID := l_old_cad.Cust_Account_ID;

       FII_CAcct_Denorm_D_MS (FII_CAcct_Denorm_D_MS.Count+1) := l_d_cad;

       l_cacct_denorm_old_marker := FII_CAcct_Denorm_Old_MS.Next(l_cacct_denorm_old_marker);
     END LOOP;


     WHILE l_cacct_denorm_new_marker IS NOT NULL LOOP
       l_new_cad := FII_CAcct_Denorm_New_MS(l_cacct_denorm_new_marker);

       l_i_cad.Parent_Party_ID := l_new_cad.Parent_Party_ID;
       l_i_cad.Cust_Account_ID := l_new_cad.Cust_Account_ID;
       l_i_cad.Account_Owner_Party_ID := l_new_cad.Account_Party_ID;
       l_i_cad.Account_Number := l_new_cad.Account_Number;
       l_i_cad.Creation_Date := sysdate;
       l_i_cad.Created_By := g_fii_user_id;
       l_i_cad.Last_Update_Date := sysdate;
       l_i_cad.Last_Updated_By := g_fii_user_id;
       l_i_cad.Last_Update_Login := g_fii_login_id;

       FII_CAcct_Denorm_I_MS (FII_CAcct_Denorm_I_MS.Count+1) := l_i_cad;

       l_cacct_denorm_new_marker := FII_CAcct_Denorm_New_MS.Next(l_cacct_denorm_new_marker);
     END LOOP;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed looping through FII_CAcct_Denorm_New_MS and FII_CAcct_Denorm_Old_MS.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Bulk inserting into FII_AR_Cust_Hier_UI_GT from FII_Cust_Hier_UI_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     IF FII_Cust_Hier_UI_MS.Count > 0 THEN
       FORALL i IN FII_Cust_Hier_UI_MS.First..FII_Cust_Hier_UI_MS.Last
        INSERT INTO FII_AR_Cust_Hier_UI_GT VALUES FII_Cust_Hier_UI_MS(i);
     END IF;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed populating FII_AR_Cust_Hier_UI_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Bulk inserting into FII_AR_Cust_Hier_D_GT from FII_Cust_Hier_D_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     IF FII_Cust_Hier_D_MS.Count > 0 THEN
       FORALL i IN FII_Cust_Hier_D_MS.First..FII_Cust_Hier_D_MS.Last
        INSERT INTO FII_AR_Cust_Hier_D_GT VALUES FII_Cust_Hier_D_MS(i);
     END IF;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed populating FII_AR_Cust_Hier_D_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Bulk inserting into FII_AR_CAccts_D_GT from FII_CAcct_Denorm_D_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     IF FII_CAcct_Denorm_D_MS.Count > 0 THEN
       FORALL i IN FII_CAcct_Denorm_D_MS.First..FII_CAcct_Denorm_D_MS.Last
        INSERT INTO FII_AR_CAccts_D_GT VALUES FII_CAcct_Denorm_D_MS(i);
     END IF;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed populating FII_AR_CAccts_D_GT.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Deleting records from FII_Customer_Hierarchies using FII_AR_Cust_Hier_D_GT';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     DELETE FROM FII_Customer_Hierarchies CH
     WHERE EXISTS (SELECT 1
                   FROM FII_AR_Cust_Hier_D_GT D
                   WHERE D.Parent_Party_ID = CH.Parent_Party_ID
                   AND D.Next_Level_Party_ID = CH.Next_Level_Party_ID
                   AND D.Child_Party_ID = CH.Child_Party_ID);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Deleted ' || SQL%ROWCOUNT || ' records from FII_Customer_Hierarchies.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;


     g_state := 'Merging records into FII_Customer_Hierarchies using FII_AR_Cust_Hier_UI_GT.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     MERGE INTO FII_Customer_Hierarchies CH
     USING FII_AR_Cust_Hier_UI_GT UI
     ON (CH.Parent_Party_ID = UI.Parent_Party_ID AND
         CH.Child_Party_ID = UI.Child_Party_ID)
     WHEN MATCHED THEN
       UPDATE SET CH.Next_Level_Party_ID = UI.Next_Level_Party_ID,
                  CH.Next_Level_Is_Leaf_Flag = UI.Next_Level_Is_Leaf_Flag,
                  CH.Parent_To_Next_Level = UI.Parent_To_Next_Level,
                  CH.Next_To_Child_Level = UI.Next_To_Child_Level,
                  CH.Last_Update_Date = sysdate,
                  CH.Last_Updated_By = g_fii_user_id,
                  CH.Last_Update_Login = g_fii_login_id
     WHEN NOT MATCHED THEN
       INSERT (CH.Parent_Party_ID,
               CH.Next_Level_Party_ID,
               CH.Child_Party_ID,
               CH.Next_Level_Is_Leaf_Flag,
               CH.Is_Hierarchical_Flag,
               CH.Parent_To_Next_Level,
               CH.Next_To_Child_Level,
               CH.Creation_Date,
               CH.Created_By,
               CH.Last_Update_Date,
               CH.Last_Updated_By,
               CH.Last_Update_Login)
       VALUES (UI.Parent_Party_ID,
               UI.Next_Level_Party_ID,
               UI.Child_Party_ID,
               UI.Next_Level_Is_Leaf_Flag,
               UI.Is_Hierarchical_Flag,
               UI.Parent_To_Next_Level,
               UI.Next_To_Child_Level,
               sysdate,
               g_fii_user_id,
               sysdate,
               g_fii_user_id,
               g_fii_login_id);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Merged ' || SQL%ROWCOUNT || ' records into FII_Customer_Hierarchies.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Deleting records from FII_Cust_Accounts using FII_AR_CAccts_D_GT';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     DELETE FROM FII_Cust_Accounts CAD
     WHERE EXISTS (SELECT 1
                   FROM FII_AR_CAccts_D_GT D
                   WHERE D.Parent_Party_ID = CAD.Parent_Party_ID
                   AND D.Cust_Account_ID = CAD.Cust_Account_ID);

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Deleted ' || SQL%ROWCOUNT || ' records from FII_Cust_Accounts.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Bulk inserting into FII_Cust_Accounts from FII_CAcct_Denorm_I_MS.';
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line(g_state);
       FII_UTIL.start_timer;
     end if;

     IF FII_CAcct_Denorm_I_MS.Count > 0 THEN
       FORALL i IN FII_CAcct_Denorm_I_MS.First..FII_CAcct_Denorm_I_MS.Last
        INSERT INTO FII_Cust_Accounts VALUES FII_CAcct_Denorm_I_MS(i);
     END IF;

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Completed populating FII_Cust_Accounts.');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
     end if;

     g_state := 'Calling BIS_COLLECTION_UTILITIES.wrapup';
     BIS_COLLECTION_UTILITIES.wrapup(
       p_status => TRUE,
       p_period_from => g_last_load_date,
       p_period_to => g_sysdate);


EXCEPTION
  WHEN OTHERS THEN
      g_retcode := -1;
      retcode := g_retcode;

      g_exception_msg  := g_retcode || ':' || sqlerrm;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);


END INCRE_UPDATE;


END FII_AR_CUSTOMER_DIMENSION_PKG;

/
