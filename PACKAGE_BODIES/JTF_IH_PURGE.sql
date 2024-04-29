--------------------------------------------------------
--  DDL for Package Body JTF_IH_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PURGE" AS
/* $Header: JTFIHPRB.pls 120.5 2006/01/24 21:03:28 nchouras ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_PURGE';

-- Program History
-- 09-OCT-2002  Igor Aleshin    Created.
-- 26-NOV-2002  Igor Aleshin    Added parameters O/R/R for Interactions and
--                              Activities.
-- 13-JAN-2003  Igor Aleshin    Added parameter p_Active
-- 07-MAY-2003  Igor Aleshin    Fixed bug# 2945880 - TST1159_DROP11: WHEN THE
--                              PURGE TYPE = ALL GETTING ORA-01006 BIND
--                              VARIABLE NOT E
-- 09-MAY-2003  Igor Aleshin    TST1159: THE PURGE PARAMETERS ARE CASE
--                              SENSITIVE AND DOES NOT COVERT THE LOWERCA
-- 24-OCT-2003  Igor Aleshin	Fixed bug# 3216639 - JTH.R:  CLEAN-UP DROP C
--                              ISSUES IN THE ACTIVITIES AND INTERACTIONS
--                              VIEWERS
-- 07-MAY-2004	Igor Aleshin	Fixed File.sql.35 issue
-- 25-MAY-2004	Igor Aleshin	Fixed bug# 3647806 - JTH.R: NEED TO CORRECT
--                              PERF. ISSUE WITH PARTY_TYPE VALIDATION IN
--                              PURGE PROGRAM
-- 04-NOV-2004  Venkatesh K     Bug fix 3999018 - Media Item Check for G_MISS
-- 29-DEC-2004  Neha Chourasia	Bug 4063673 fix for date range purge not working for Active set to Y
-- 25-FEB-2005  Neha Chourasia  ER 4007013 Added API PURGE_BY_OBJECT to purge interactions and
--                              activities related to the object passed.
-- 25-JAN-2006 Neha Chourasia   Bug 4965592 fix for hints for sqls as suggested
--                              by batch perf team

  PROCEDURE PURGE(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2,
    p_Party_IDs VARCHAR2,
    p_Party_Type VARCHAR2,
    p_Active VARCHAR2, -- Bug# 4063673 - changed position from last param to 3rd
    p_Start_Date DATE,
    p_End_Date DATE,
    p_SafeMode VARCHAR2,
    p_Purge_Type VARCHAR2,
    -- Added on 26-NOV-2002
    p_ActivityOutcome VARCHAR2,
    p_ActivityResult VARCHAR2,
    p_ActivityReason VARCHAR2,
    p_InterOutcome VARCHAR2,
    p_InterResult VARCHAR2,
    p_InterReason VARCHAR2
    --Added on 13-JAN-2003
    --p_Active VARCHAR2
  ) IS

    nCountInteraction NUMBER;       -- Count of Interactions for Purge
    nCountActivities NUMBER;        -- Count of Activities for Purge;
    nCntWrngInteraction NUMBER;     -- Count of Interactions for Purge which have an errors
    nCountMediaItems NUMBER;        -- Count of Related of Media Items
    nCountMediaItemLC NUMBER;       -- Count of Related of Media Item Lifecycle
    nCount NUMBER;
    nCountMedia NUMBER;
    sSql VARCHAR2(2000);
    nRowTrn NUMBER;
    nInteraction_Id JTF_IH_INTERACTIONS.INTERACTION_ID%TYPE;
    ErrNoPartyType EXCEPTION;
    ErrInteraction EXCEPTION;
    ErrStartEndDate EXCEPTION;
    ErrEndDateNull EXCEPTION;  -- Added for Bug# 4063673
    NoCriteriaSpecified EXCEPTION;
    ErrPatyIdsDescription EXCEPTION;
    ErrInvPartyType EXCEPTION;
    n_CursorId NUMBER;
    n_Res NUMBER;
    n_Media_Id NUMBER;
    l_msg_data VARCHAR2(2000);
    n_NLS_Format VARCHAR2(30);
    i_Dummy     NUMBER;
    l_SafeMode VARCHAR2(10);
    l_Active VARCHAR2(1);

  BEGIN
    l_SafeMode := NVL(p_SafeMode,'TRUE');
    l_Active := NVL(p_Active,'N');
    p_commit := NVL(p_commit,FND_API.G_TRUE);
    TranRows := NVL(TranRows,1000);
    -- Check range for purge. If you are going to purge all interactions
    -- then you should specify the p_Purge_Type = 'ALL'
    IF p_Start_Date IS NULL AND p_End_Date IS NULL
      AND (p_Purge_Type IS NULL OR UPPER(p_Purge_Type) <> 'ALL')
      AND p_Party_IDs IS NULL AND p_Party_Type IS NULL
      -- Added on 26-NOV-2002
      AND p_ActivityOutcome IS NULL AND p_ActivityResult IS NULL
      AND p_ActivityReason IS NULL AND p_InterOutcome IS NULL
      AND p_InterResult IS NULL AND p_InterReason IS NULL THEN

      RAISE NoCriteriaSpecified;
    END IF;

    IF UPPER(p_Purge_Type) <> 'ALL' OR p_Purge_Type IS NULL THEN

      -- Check p_Party_Type value, it it required.
      IF p_Party_Type IS NOT NULL AND UPPER(p_Party_Type) NOT IN('PERSON','ORGANIZATION','PARTY_RELATIONSHIP') THEN
        RAISE ErrInvPartyType;
      END IF;

      --  Now I'm going to build a dynamic sql statement based on input parameters.
      --
      IF p_ActivityOutcome IS NOT NULL OR p_ActivityResult IS NOT NULL OR p_ActivityReason IS NOT NULL THEN
        sSql := 'SELECT DISTINCT JTFI.INTERACTION_ID FROM JTF_IH_INTERACTIONS JTFI, JTF_IH_ACTIVITIES ACT ';
        -- If you've set up some value to p_Party_Type parameter, then include HZ_PARTIES table
        -- to major sql statement, based on JTF_IH_INTERACTION.Party_ID
        IF p_Party_Type IS NOT NULL THEN
          sSql := sSql || ', HZ_PARTIES HZ ';
        END IF;
        --sSql := sSql ||'WHERE JTFI.ACTIVE = '''||p_Active||''' AND ACT.INTERACTION_ID = JTFI.INTERACTION_ID ';
        sSql := sSql ||'WHERE JTFI.ACTIVE = :active AND ACT.INTERACTION_ID = JTFI.INTERACTION_ID ';

        IF p_Party_Type IS NOT NULL THEN
          sSql := sSql ||' AND JTFI.PARTY_ID=HZ.PARTY_ID ';
        END IF;

      ELSE

        sSql := 'SELECT INTERACTION_ID FROM JTF_IH_INTERACTIONS JTFI ';
        IF p_Party_Type IS NOT NULL THEN
          sSql := sSql ||', HZ_PARTIES HZ ';
        END IF;
        --sSql := sSql || 'WHERE JTFI.ACTIVE = '''||p_Active||'''';
        sSql := sSql || 'WHERE JTFI.ACTIVE = :active ';
        IF p_Party_Type IS NOT NULL THEN
          sSql := sSql || ' AND JTFI.PARTY_ID=HZ.PARTY_ID ';
        END IF;
      END IF;

      IF p_Party_Type IS NOT NULL THEN
        --sSql := sSql ||' AND PARTY_TYPE = UPPER('''||p_Party_Type||''') ';
        sSql := sSql ||' AND PARTY_TYPE = UPPER(:party_type) ';
      END IF;

      -- Compare p_End_Date and p_Start_Date. p_End_Date shouldn't be less then p_Start_Date
      -- This comparation I'll make if p_Active flag is 'N', otherwise let pass it.
      IF p_Start_Date IS NOT NULL AND p_End_Date IS NOT NULL AND l_Active = 'N' THEN
        BEGIN
          SELECT p_End_Date-p_Start_Date INTO n_Res FROM DUAL;
          IF n_Res < 0 THEN
            RAISE ErrStartEndDate;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE ErrStartEndDate;
        END;
      END IF;

      -- Add Party_IDs to major select statement if they are setup.
      IF p_Party_Ids IS NOT NULL THEN
        -- Make data validation for PartyIds
        BEGIN
          SELECT TO_NUMBER(REPLACE(REPLACE(p_Party_IDs,',',''),' ','')) INTO n_Res FROM DUAL;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE ErrPatyIdsDescription;
        END;
        sSql := sSql ||' AND JTFI.PARTY_ID IN ('||p_Party_IDs||') ';
      END IF;

      -- Fix for Bug# 4063673 - purge based only on START_DATE
      IF p_START_DATE IS NOT NULL THEN
        --IF l_Active = 'N' THEN
          sSql := sSql || ' AND TO_DATE(TO_CHAR(JTFI.START_DATE_TIME,''MM/DD/RRRR''),''MM/DD/RRRR'') >= TO_DATE(TO_CHAR(:start_date,''MM/DD/RRRR''),''MM/DD/RRRR'') ';
        --ELSE
        --  sSql := sSql || ' AND TO_DATE(TO_CHAR(JTFI.START_DATE_TIME,''MM/DD/RRRR''),''MM/DD/RRRR'') <= TO_DATE(TO_CHAR(:start_date,''MM/DD/RRRR''),''MM/DD/RRRR'') ';
        --END IF;
      END IF;

      -- If Interaction is Active and Start Date is not null then end date cannot be null
      -- else all active records after Start Date upto current date are deleted
      -- Fix for Bug# 4063673
      IF p_END_DATE IS NULL AND l_Active = 'Y' THEN
        RAISE ErrEndDateNull;
      END IF;

      -- Fix for Bug# 4063673 - purge based only on START_DATE
      --IF p_END_DATE IS NOT NULL AND l_Active = 'N' THEN
      IF p_END_DATE IS NOT NULL THEN
        sSql := sSql || ' AND TO_DATE(TO_CHAR(JTFI.START_DATE_TIME,''MM/DD/RRRR''),''MM/DD/RRRR'') <= TO_DATE(TO_CHAR(:end_date,''MM/DD/RRRR''),''MM/DD/RRRR'') ';
      END IF;

      -- Added on 26-NOV-2002
      --
      IF p_InterOutcome IS NOT NULL THEN
        sSql := sSql || ' AND JTFI.OUTCOME_ID IN ('||p_InterOutcome||') ';
      END IF;

      IF p_InterResult IS NOT NULL THEN
        sSql := sSql || ' AND JTFI.RESULT_ID IN ('||p_InterResult||') ';
      END IF;

      IF p_InterReason IS NOT NULL THEN
        sSql := sSql || ' AND JTFI.REASON_ID IN ('||p_InterReason||') ';
      END IF;

      IF p_ActivityOutcome IS NOT NULL THEN
        sSql := sSql || ' AND ACT.OUTCOME_ID IN ('||p_ActivityOutcome||') ';
      END IF;

      IF p_ActivityResult IS NOT NULL THEN
        sSql := sSql || ' AND ACT.RESULT_ID IN ('||p_ActivityResult||') ';
      END IF;

      IF p_ActivityReason IS NOT NULL THEN
        sSql := sSql || ' AND ACT.REASON_ID IN ('||p_ActivityReason||') ';
      END IF;

    ELSE
      sSql := 'SELECT INTERACTION_ID FROM JTF_IH_INTERACTIONS WHERE ACTIVE = :active ORDER BY INTERACTION_ID ';
    END IF;

    -- This piece of code need for debugging a sql statement
            /*
            if length(sSql) > 80 then
                dbms_output.put_line(substr(sSql,1,80));
                for i_Dummy in 1..round(length(sSql)/80) loop
                    dbms_output.put_line(substr(sSql,(i_Dummy*80)+1,80));
                end loop;
            else
                dbms_output.put_line(sSql);
            end if;*/

    n_CursorId := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE(n_CursorId, sSql, DBMS_SQL.NATIVE);
    --dbms_output.put_line('');
    DBMS_SQL.BIND_VARIABLE(n_CursorId,':active',l_Active);
    IF UPPER(p_Purge_Type) <> 'ALL' OR p_Purge_Type IS NULL THEN
      IF (p_Party_Type IS NOT NULL) THEN
        DBMS_SQL.BIND_VARIABLE(n_CursorId,':party_type',p_Party_Type);
      END IF;

      -- Bug# 2945880 - added expression for p_Purge_Type
      --

      -- Fix for Bug# 4063673
      --IF p_END_DATE IS NOT NULL AND l_Active = 'N' AND (RTRIM(p_Purge_Type) = '' OR p_Purge_Type IS NULL) THEN
      IF p_END_DATE IS NOT NULL AND (RTRIM(p_Purge_Type) = '' OR p_Purge_Type IS NULL) THEN
        DBMS_SQL.BIND_VARIABLE(n_CursorId,':end_date',p_End_Date);
      END IF;
      -- Bug# 2945880 - added expression for p_Purge_Type
      --
      IF p_START_DATE IS NOT NULL AND (RTRIM(p_Purge_Type) = '' OR p_Purge_Type IS NULL) THEN
        DBMS_SQL.BIND_VARIABLE(n_CursorId,':start_date',p_Start_Date);
      END IF;
    END IF;
    DBMS_SQL.DEFINE_COLUMN(n_CursorId, 1, nInteraction_Id);

    --FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    --FND_FILE.PUT_LINE(FND_FILE.LOG, sSql);

    n_Res := DBMS_SQL.EXECUTE(n_CursorId);

    nCount := 0;
    nRowTrn := 0;
    nCountInteraction := 0;
    nCountActivities := 0;
    nCountMediaItems := 0;
    nCountMediaItemLC := 0;

    LOOP
      IF DBMS_SQL.FETCH_ROWS(n_CursorId) = 0 THEN
        EXIT;
      END IF;
      DBMS_SQL.COLUMN_VALUE(n_CursorId,1,nInteraction_Id);
      -- If current interaction has any errors then skip it
      BEGIN
        IF l_SafeMode = 'FALSE' THEN
          BEGIN
            SAVEPOINT Activities;
            -- Clean Up an Activities
            FOR curActivity IN (SELECT ACTIVITY_ID FROM JTF_IH_ACTIVITIES
                                WHERE INTERACTION_ID = nInteraction_Id) LOOP
              DELETE FROM JTF_IH_ACTIVITIES
                WHERE ACTIVITY_ID = curActivity.ACTIVITY_ID
                RETURNING Media_ID INTO n_Media_Id;

              nCountActivities := nCountActivities + 1;
              IF ( (n_Media_Id IS NOT NULL) AND (n_Media_Id <> fnd_api.g_miss_num) ) THEN
                SELECT Count(*) INTO nCountMedia
                  FROM JTF_IH_ACTIVITIES WHERE MEDIA_ID = n_Media_Id;
                --
                -- Delete Media Item If they aren't
                -- related to other Activities.
                --
                IF nCountMedia = 0 THEN
                  DELETE FROM JTF_IH_MEDIA_ITEMS WHERE MEDIA_ID = n_Media_Id;
                  nCountMediaItems := nCountMediaItems + 1;
                  -- And Related to MediaID Media Item LifeCycle.
                  BEGIN
                    DELETE FROM JTF_IH_MEDIA_ITEM_LC_SEGS WHERE MEDIA_ID = n_Media_Id;
                    nCountMediaItemLC := nCountMediaItemLC + SQL%ROWCOUNT;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      NULL;
                  END;
                END IF;
              END IF;
            END LOOP;
            -- Clean Up Parent and All Child Interactions in the JTF_IH_INTERACTION_INTERS.
            DELETE FROM JTF_IH_INTERACTION_INTERS WHERE
              (INTERACT_INTERACTION_IDRELATES = nInteraction_Id)
               OR (INTERACT_INTERACTION_ID = nInteraction_Id);
            -- Clean Up current Intraction.
            DELETE FROM JTF_IH_INTERACTIONS WHERE INTERACTION_ID = nInteraction_Id;
          EXCEPTION
            WHEN OTHERS THEN
              --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: Interaction_ID = '||nInteraction_Id||' has an error:');
              --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: '||SQLERRM);
              --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: -----------------------------------------');
              FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_INTERACTION_ERROR');
              FND_MESSAGE.SET_TOKEN('INTERACTION', to_char(nInteraction_Id));
              FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              ROLLBACK TO SAVEPOINT Activities;
              RAISE ErrInteraction;
            END;
          ELSE
            SELECT nCountActivities + Count(*) INTO nCountActivities
              FROM JTF_IH_ACTIVITIES WHERE INTERACTION_ID = nInteraction_Id;

            SELECT nCountMediaItems + Count(*) INTO nCountMediaItems
              FROM JTF_IH_ACTIVITIES WHERE INTERACTION_ID = nInteraction_Id AND
              Media_ID IS NOT NULL;

          END IF;
          nCountInteraction := nCountInteraction + 1;
          nRowTrn := nRowTrn + 1;
          -- Make a commit for transactions only if SafeMode is False.
          IF nRowTrn = TranRows AND l_SafeMode = 'FALSE' THEN
            IF p_commit = FND_API.G_TRUE THEN
              COMMIT;
              nRowTrn := 0;
            END IF;
          END IF;
        EXCEPTION
          WHEN ErrInteraction THEN
            nCntWrngInteraction := nCntWrngInteraction + 1;
        END;
      END LOOP;

      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
        NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: Done :');
      FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_DONE');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

      IF nCountInteraction = 0 THEN
        --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: Interactions not found');
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_NO_INTERACTIONS');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      ELSE
        IF l_SafeMode = 'TRUE' THEN
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: You are going to delete :');
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Interactions....'||to_char(nCountInteraction));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Activities......'||to_char(nCountActivities));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Media Items.....'||to_char(nCountMediaItems));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: -----------------------------------------');
          FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_SAFEMODE_REPORT');
          FND_MESSAGE.SET_TOKEN('INTERACTIONS', to_char(nCountInteraction));
          FND_MESSAGE.SET_TOKEN('ACTIVITIES', to_char(nCountActivities));
          FND_MESSAGE.SET_TOKEN('MEDIAITEMS', to_char(nCountMediaItems));
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        ELSE
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: Deleted :');
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Interactions....'||to_char(nCountInteraction));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Activities......'||to_char(nCountActivities));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Media Items.....'||to_char(nCountMediaItems));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE:        Media Item LC...'||to_char(nCountMediaItemLC));
          --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: -----------------------------------------');
          FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_REPORT');
          FND_MESSAGE.SET_TOKEN('INTERACTIONS', to_char(nCountInteraction));
          FND_MESSAGE.SET_TOKEN('ACTIVITIES', to_char(nCountActivities));
          FND_MESSAGE.SET_TOKEN('MEDIAITEMS', to_char(nCountMediaItems));
          FND_MESSAGE.SET_TOKEN('MEDIAITEMLC', to_char(nCountMediaItemLC));
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        END IF;
      END IF;
      DBMS_SQL.CLOSE_CURSOR(n_CursorId);
    EXCEPTION
      WHEN ErrInvPartyType THEN
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_INV_PARTY_TYPE');
        FND_MESSAGE.SET_TOKEN('PARTYTYPE', p_Party_Type);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
      WHEN ErrNoPartyType THEN
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_NO_PARTY_TYPE');
        FND_MESSAGE.SET_TOKEN('PARTYTYPE', p_Party_Type);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
      WHEN ErrStartEndDate THEN
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_INVALID_DATE');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
      -- Added for Bug# 4063673
      WHEN ErrEndDateNull THEN
	FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_DATE_TO_NOTNULL');
	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
      WHEN NoCriteriaSpecified THEN
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_NO_CRITERIA');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
      WHEN ErrPatyIdsDescription THEN
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PURGE_WRONG_PARTY_IDS');
        FND_MESSAGE.SET_TOKEN('PARTYIDS', p_Party_IDs);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --DBMS_OUTPUT.PUT_LINE('JTF_IH_PURGE: '||SQLERRM);
    END PURGE;

    PROCEDURE P_DELETE_INTERACTIONS (
    p_api_version          IN NUMBER,
    p_init_msg_list        IN VARCHAR2,
    p_commit               IN VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_data             OUT  NOCOPY VARCHAR2,
    x_msg_count            OUT  NOCOPY NUMBER,
    p_processing_set_id    IN NUMBER,
    p_object_type          IN VARCHAR2
    )IS
      l_api_name        CONSTANT VARCHAR2(30) := 'P_DELETE_INTERACTIONS';
      l_api_version     CONSTANT NUMBER       := 1.1;
      l_api_name_full   CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
      l_return_status   VARCHAR2(1);
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(2000);
      l_fnd_log_msg     VARCHAR2(2000);

      -- cursor on stage global temp table
      -- to select object ids corresp. to which
      -- interactions and activities are to be purged

      CURSOR c_jtf_obj_purge_temp_success IS
      SELECT distinct object_id, null
      FROM   JTF_OBJECT_PURGE_PARAM_TMP
      WHERE  nvl(purge_status, 'S') <> 'E'
      AND    OBJECT_TYPE = p_object_type
      AND    PROCESSING_SET_ID = p_processing_set_id;

      TYPE table_incidents_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE table_media_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE table_int_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

      l_inter_int_ids			table_incidents_ids;
      l_activity_id			table_incidents_ids;
      l_incident_ids			table_incidents_ids;
      l_dummy_col			table_incidents_ids;
      l_media_ids			table_media_ids;
      lc_media_ids			table_media_ids;
      l_int_ids				table_int_ids;

      l_processing_set_id		NUMBER;
      l_obj_type_lookup			VARCHAR2(50);
      l_jtf_activity			VARCHAR2(50);
      l_jtf_interaction			VARCHAR2(50);

      ErrNoRecFound	  EXCEPTION;

    BEGIN


      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'P_DELETE_INTERACTIONS In parameters :'||
	      	                       'p_api_version       = '|| p_api_version ||
	      	                       'p_init_msg_list     = '|| p_init_msg_list ||
	      	                       'p_commit            = '|| p_commit||
	      	                       'p_processing_set_id = '|| p_processing_set_id ||
	      	                       'p_object_type       = '|| p_object_type;
        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
          'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.begin', l_fnd_log_msg);
      END IF;

      l_obj_type_lookup := CONCAT(p_object_type,'-%');

      -- Standard start of API savepoint
      SAVEPOINT delete_interactions_p;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_return_status := x_return_status;

      OPEN  c_jtf_obj_purge_temp_success;
      FETCH c_jtf_obj_purge_temp_success bulk collect
      INTO  l_incident_ids, l_dummy_col;
      CLOSE c_jtf_obj_purge_temp_success;

      --Select set of Activities related to object_type
      --to be deleted if the action item can be deleted
      --for this object type
      IF l_incident_ids.COUNT < 1 THEN
        RAISE ErrNoRecFound;
      END IF;

      FORALL i IN l_incident_ids.FIRST..l_incident_ids.LAST
      DELETE
      FROM   JTF_IH_ACTIVITIES
      WHERE  doc_id = l_incident_ids(i)
      AND    doc_ref = p_object_type
      AND    action_item_id
           IN (SELECT meaning
               FROM   FND_LOOKUP_VALUES
               WHERE  lookup_type = 'JTF_IH_PURGE_OBJ_AI_MAP'
               AND    lookup_code like l_obj_type_lookup
               AND    view_application_id = 0
               AND    security_group_id = 0
              )
      RETURNING media_id,interaction_id,activity_id  BULK COLLECT
      INTO      l_media_ids,l_int_ids,l_activity_id;


      --Logging after deleting activities
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'No. of Activities purged = '||SQL%ROWCOUNT;
        --dbms_output.put_line(l_fnd_log_msg);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.delete_activity',l_fnd_log_msg);
      END IF;


      -- Inserting the deleted activity ID into temp table
      -- with new Proc Set ID for Notes dependent object processing

      IF l_activity_id.COUNT > 0 THEN

        l_jtf_activity := 'JTF_ACTIVITY';

        SELECT	JTF_OBJECT_PURGE_PROC_SET_S.NEXTVAL
        INTO	l_processing_set_id
        FROM	dual
        WHERE	rownum = 1;


        FORALL i IN l_activity_id.FIRST..l_activity_id.LAST
        INSERT INTO JTF_OBJECT_PURGE_PARAM_TMP
          (
	  object_id,
          object_type,
          processing_set_id,
          purge_status,
          purge_error_message
          )
          values
          (
	   l_activity_id(i),
           l_jtf_activity,
           l_processing_set_id,
           null,
           null
          );


	--Logging after inserting activities
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  l_fnd_log_msg := 'No. of Activities Inserted into temp table = '||SQL%ROWCOUNT;
	  --dbms_output.put_line(l_fnd_log_msg);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
           'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.activity_tmp',l_fnd_log_msg);
        END IF;

        --Logging before calling Notes Purge API
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	        'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.begin.purge_notes', 'Calling Notes Purge API for Activities');
	END IF;

        --Delete Notes related to the activities being purged
	CAC_NOTE_PURGE_PUB.PURGE_NOTES
	(  p_api_version => 1.0,
	   p_init_msg_list => p_init_msg_list,
	   p_commit => p_commit,
	   x_return_status => l_return_status,
	   x_msg_data => l_msg_data,
	   x_msg_count => l_msg_count,
	   p_processing_set_id => l_processing_set_id,
	   p_object_type => 'JTF_ACTIVITY'
        );

        --Logging on return from Notes Purge API
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	     'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.end.purge_notes', 'After call to Notes Purge API for Activities');
	END IF;

	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	  RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;

      --Delinking activities from SR
      FORALL i IN l_incident_ids.FIRST..l_incident_ids.LAST
      UPDATE JTF_IH_ACTIVITIES
      SET    doc_id = l_dummy_col(i),
             doc_ref = l_dummy_col(i)
      WHERE  doc_id = l_incident_ids(i)
      AND    doc_ref = p_object_type;



      --Logging after delinking activities
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'No. of Activities Delinked = '||SQL%ROWCOUNT;
        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.delink_act',l_fnd_log_msg);
      END IF;

      --Deleting the associated Interactions

      IF l_int_ids.COUNT > 0 THEN
        FORALL j IN l_int_ids.FIRST..l_int_ids.LAST
        DELETE
        FROM   JTF_IH_INTERACTIONS
        WHERE  interaction_id = l_int_ids(j)
        AND
        NOT EXISTS (SELECT 1
                    FROM   JTF_IH_ACTIVITIES
                    WHERE  interaction_id = l_int_ids(j))
        RETURNING interaction_id BULK COLLECT INTO l_inter_int_ids;
      END IF;


      --Logging after deleting interactions
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'No. of Interactions purged = '||SQL%ROWCOUNT;
        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.del_inter',l_fnd_log_msg);
      END IF;

      -- Clean Up Parent and All Child Interactions
      --in the JTF_IH_INTERACTION_INTERS.
      IF l_inter_int_ids.COUNT > 0 THEN
        FORALL j IN l_inter_int_ids.FIRST..l_inter_int_ids.LAST
        DELETE
        FROM   JTF_IH_INTERACTION_INTERS
        WHERE  (INTERACT_INTERACTION_IDRELATES = l_inter_int_ids(j))
        OR     (INTERACT_INTERACTION_ID = l_inter_int_ids(j));
      END IF;



      --Logging after cleaning Interaction Relationships
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'No. of Interaction Relationships purged = '||SQL%ROWCOUNT;
        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.del_inter_inter',l_fnd_log_msg);
      END IF;

      -- Inserting the deleted interaction ID into temp table
      -- with new Proc Set ID for Notes dependent object processing

      IF l_inter_int_ids.COUNT > 0 THEN

        l_jtf_interaction := 'JTF_INTERACTION';

        SELECT    JTF_OBJECT_PURGE_PROC_SET_S.NEXTVAL
        INTO      l_processing_set_id
        FROM      dual
        WHERE     rownum = 1;


        FORALL i IN l_inter_int_ids.FIRST..l_inter_int_ids.LAST
        INSERT INTO JTF_OBJECT_PURGE_PARAM_TMP
        (
          object_id,
          object_type,
          processing_set_id,
          purge_status,
          purge_error_message
        )
        values
        (
           l_inter_int_ids(i),
           l_jtf_interaction,
           l_processing_set_id,
           null,
           null
        );



	--Logging after inserting interactions into temp table
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  l_fnd_log_msg := 'No. of Interactions inserted into temp table = '||SQL%ROWCOUNT;
	  --dbms_output.put_line(l_fnd_log_msg);
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	    'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.inter_tmp',l_fnd_log_msg);
        END IF;

        --Logging before calling Notes Purge API
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	       'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.begin.purge_notes', 'Calling Notes Purge API for Interactions');
	END IF;

        --Delete Notes related to the interactions being purged
	CAC_NOTE_PURGE_PUB.PURGE_NOTES
	(  p_api_version => 1.0,
	   p_init_msg_list => p_init_msg_list,
	   p_commit => p_commit,
	   x_return_status => l_return_status,
	   x_msg_data => l_msg_data,
	   x_msg_count => l_msg_count,
	   p_processing_set_id => l_processing_set_id,
	   p_object_type => 'JTF_INTERACTION'
        );
        --Logging on return from Notes Purge API
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	     'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.end.purge_notes', 'After call to Notes Purge API for Activities');
	END IF;
	IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	  RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;

      --
      -- Delete Media Item If they aren't
      -- related to other Activities.
      --
      IF l_media_ids.COUNT > 0 THEN
        FORALL j IN l_media_ids.FIRST..l_media_ids.LAST
        DELETE
        FROM   JTF_IH_MEDIA_ITEMS
        WHERE  media_id IS NOT NULL
        AND    media_id <> fnd_api.g_miss_num
        AND    media_id = l_media_ids(j)
        AND
        NOT EXISTS (SELECT 1
                    FROM   JTF_IH_ACTIVITIES
                    WHERE  MEDIA_ID = l_media_ids(j))
        RETURNING media_id BULK COLLECT INTO lc_media_ids;
      END IF;




      --Logging after deleting media items
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'No. of Media Items purged = '||SQL%ROWCOUNT;
        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.delete_MI',l_fnd_log_msg);
      END IF;

      -- And Related to MediaID Media Item LifeCycle.
      IF lc_media_ids.COUNT > 0 THEN
        FORALL j IN lc_media_ids.FIRST..lc_media_ids.LAST
        DELETE
        FROM   JTF_IH_MEDIA_ITEM_LC_SEGS
        WHERE  MEDIA_ID = lc_media_ids(j);
      END IF;

      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
      END IF;

      --Logging after deleting media life cycle segments
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'No. of Media Life-cycle segments purged = '||SQL%ROWCOUNT;
        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.delete_MLCS',l_fnd_log_msg);
      END IF;



      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'P_DELETE_INTERACTIONS Out parameters:' ||
	       	                       'x_return_status = '|| x_return_status ||
	       	                       'x_msg_data      = '||x_msg_data||
	       	                       'x_msg_count     ='||x_msg_count;

        --dbms_output.put_line(l_fnd_log_msg);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	 'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS.end', l_fnd_log_msg);
      END IF;

    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO delete_interactions_p;
        --dbms_output.put_line('FAILURE EXPECTED');
        x_return_status := fnd_api.g_ret_sts_error;
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
          x_msg_data:=FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
	  	             'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS', x_msg_data);
	END IF;

      WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO delete_interactions_p;
        --dbms_output.put_line('FAILURE UNEXPECTED');
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>x_msg_count, p_encoded=>'F');
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
	             'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS', x_msg_data);
	END IF;

      WHEN ErrNoRecFound THEN
        ROLLBACK TO delete_interactions_p;
        x_return_status := fnd_api.g_ret_sts_success;
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
          x_msg_data:=FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
	             'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS', x_msg_data);
	END IF;

      WHEN OTHERS THEN
        ROLLBACK TO delete_interactions_p;
        --dbms_output.put_line('FAILURE OTHERS');
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
          x_msg_data:=FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
	             'jtf.plsql.JTF_IH_PURGE.P_DELETE_INTERACTIONS', x_msg_data);
	END IF;

    END P_DELETE_INTERACTIONS;

END JTF_IH_PURGE;

/
