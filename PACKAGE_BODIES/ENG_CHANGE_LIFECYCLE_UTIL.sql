--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_LIFECYCLE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_LIFECYCLE_UTIL" AS
/* $Header: ENGULCMB.pls 120.28.12010000.3 2010/04/12 09:50:14 qyou ship $ */

  -- ---------------------------------------------------------------------------
  -- Global variables and constants
  -- ---------------------------------------------------------------------------
  G_PKG_NAME                VARCHAR2(30) := 'ENG_CHANGE_LIFECYCLE_UTIL';

  -- For Debug
  g_debug_flag            BOOLEAN       := FALSE ;
  g_output_dir            VARCHAR2(240) := NULL ;
  g_debug_filename        VARCHAR2(200) := NULL ;
  g_debug_errmesg         VARCHAR2(240);
  G_BO_IDENTIFIER         VARCHAR2(30) := 'ENG_CHANGE_LC_UTIL';
  G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);
  g_profile_debug_option  VARCHAR2(10) ;
  g_profile_debug_level   VARCHAR2(10) ;


  -- ---------------------------------------------------------------------------
  -- Global cursors
  -- ---------------------------------------------------------------------------


  /********************************************************************
  * Debug APIs    : Open_Debug_Session, Close_Debug_Session,
  *                 Write_Debug
  * Parameters IN :
  * Parameters OUT:
  * Purpose       : These procedures are for test and debug
  *********************************************************************/

  ----------------------------------------------------------
  -- Internal procedure to open Debug Session.            --
  ----------------------------------------------------------
  -- Open_Debug_Session
  PROCEDURE Open_Debug_Session
  (  p_output_dir IN VARCHAR2 := NULL
  ,  p_file_name  IN VARCHAR2 := NULL
  )
  IS

    CURSOR c_get_utl_file_dir IS
       SELECT VALUE
        FROM V$PARAMETER
        WHERE NAME = 'utl_file_dir';

    --local variables
    l_found                NUMBER;

    l_log_output_dir       VARCHAR2(512);
    l_log_return_status    VARCHAR2(99);
    l_errbuff              VARCHAR2(2000);

  BEGIN


    -- Ignore open_debug_session call if package debugging mode is already ON
    IF ( g_debug_flag AND Error_Handler.Get_Debug = 'Y' ) THEN
      RETURN ;
    END IF ;

    l_found := 0 ;
    Error_Handler.initialize();
    Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);

    ---------------------------------------------------------------------------------
    -- Open_Debug_Session should set the value
    -- appropriately, so that when the Debug Session is successfully opened :
    -- will return Error_Handler.Get_Debug = 'Y', else Error_Handler.Get_Debug = 'N'
    ---------------------------------------------------------------------------------

    IF p_output_dir IS NOT NULL THEN
        g_output_dir := p_output_dir ;
    END IF;

    IF p_file_name IS NOT NULL THEN
        g_debug_filename := p_file_name ;
    END IF;

    OPEN c_get_utl_file_dir;
    FETCH c_get_utl_file_dir INTO l_log_output_dir;

    IF c_get_utl_file_dir%FOUND THEN

      IF g_output_dir IS NOT NULL
      THEN
         l_found := INSTR(l_log_output_dir, g_output_dir);
         IF l_found = 0
         THEN
             g_output_dir := NULL ;
         END IF;
      END IF;

      ------------------------------------------------------
      -- Trim to get only the first directory in the list --
      ------------------------------------------------------
      IF INSTR(l_log_output_dir,',') <> 0 THEN
        l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
      END IF;


      IF g_output_dir IS NULL
      THEN
         g_output_dir := l_log_output_dir ;
      END IF ;


      IF g_debug_filename IS NULL
      THEN
          g_debug_filename := G_BO_IDENTIFIER ||'_' || to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.log';
      END IF ;

      -----------------------------------------------------------------------
      -- To open the Debug Session to write the Debug Log.                 --
      -- This sets Debug value so that Error_Handler.Get_Debug returns 'Y' --
      -----------------------------------------------------------------------
      Error_Handler.Open_Debug_Session(
        p_debug_filename   => g_debug_filename
       ,p_output_dir       => g_output_dir
       ,x_return_status    => l_log_return_status
       ,x_error_mesg       => l_errbuff
       );

      FND_FILE.put_line(FND_FILE.LOG, 'Log file location --> '||l_log_output_dir||'/'||g_debug_filename ||' created with status '|| l_log_return_status);

      IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         FND_FILE.put_line(FND_FILE.LOG, 'Unable to open error log file. Error => '||l_errbuff) ;
      END IF;

    END IF; --IF c_get_utl_file_dir%FOUND THEN
    -- Bug : 4099546
    CLOSE c_get_utl_file_dir;

    -- Set Global Debug Flag

    g_debug_flag := TRUE ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Open_Debug_Session LOGGING SQL ERROR => '||g_debug_errmesg);
         g_debug_flag := FALSE;
  END Open_Debug_Session ;


   -----------------------------------------------------------
   -- Open the Debug Session, conditionally if the profile: --
   -- INV Debug Trace is set to TRUE                        --
   -----------------------------------------------------------
  PROCEDURE Check_And_Open_Debug_Session
  (  p_debug_flag IN VARCHAR2
  ,  p_output_dir IN VARCHAR2 := NULL
  ,  p_file_name  IN VARCHAR2 := NULL
  )
  IS


  BEGIN
    ----------------------------------------------------------------
    -- Open the Debug Log Session, p_debug_flag is TRUE or
    -- if Profile is set to TRUE: INV_DEBUG_TRACE Yes, INV_DEBUG_LEVEL 20
    ----------------------------------------------------------------
    g_profile_debug_option := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), TO_CHAR(0));
    g_profile_debug_level := NVL(FND_PROFILE.VALUE('INV_DEBUG_LEVEL'), TO_CHAR(0));

    IF (g_profile_debug_option = '1' AND TO_NUMBER(g_profile_debug_level) >= 20)
       OR FND_API.to_Boolean(p_debug_flag)
    THEN

       ----------------------------------------------------------------------------------
       -- Opens Error_Handler debug session, only if Debug session is not already open.
       -- Suggested by RFAROOK, so that multiple debug sessions are not open PER
       -- Concurrent Request.
       ----------------------------------------------------------------------------------
       IF (Error_Handler.Get_Debug <> 'Y') THEN

FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Error_Handler.Get_Debug is not Y, calling Open_Debug_Session  ');
         Open_Debug_Session(p_output_dir => p_output_dir, p_file_name => p_file_name) ;
       END IF;

    END IF;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Check_And_Open_Debug_Session LOGGING SQL ERROR => '||g_debug_errmesg);
         g_debug_flag := FALSE;
  END Check_And_Open_Debug_Session;

  -- Close Debug_Session
  PROCEDURE Close_Debug_Session
  IS
  BEGIN

       -----------------------------------------------------------------------------
       -- Close Error_Handler debug session, only if Debug session is already open.
       -----------------------------------------------------------------------------
       IF (Error_Handler.Get_Debug = 'Y') THEN

FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Error_Handler.Get_Debug is not Y, calling Close_Debug_Session  ');
         Error_Handler.Close_Debug_Session;

       END IF;

       g_debug_flag := FALSE;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Close_Debug_Session LOGGING SQL ERROR => '||g_debug_errmesg);
         g_debug_flag := FALSE;

  END Close_Debug_Session;

  -- Test Debug
  PROCEDURE Write_Debug
  (  p_debug_message      IN  VARCHAR2 )
  IS
  BEGIN
      -- Sometimes Error_Handler.Write_Debug would not write
      -- the debug message properly
      -- So as workaround, I added special developer debug mode here
      -- to write debug message forcedly
      IF (TO_NUMBER(g_profile_debug_level) = 999)
      THEN
        FND_FILE.put_line(FND_FILE.LOG
                        , G_PKG_NAME
                          || '['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '
                          || p_debug_message
                         );

      END IF ;

      Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_debug_message);

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Write_Debug LOGGING SQL ERROR => '||g_debug_errmesg);
         g_debug_flag := FALSE;
  END Write_Debug;


  PROCEDURE Get_Debug_Mode
  (   p_item_type         IN  VARCHAR2
   ,  p_item_key          IN  VARCHAR2
   ,  x_debug_flag        OUT NOCOPY BOOLEAN
   ,  x_output_dir        OUT NOCOPY VARCHAR2
   ,  x_debug_filename    OUT NOCOPY VARCHAR2
  )
  IS

      l_debug_flag VARCHAR2(1) ;

  BEGIN

      -- Get Debug Flag
      l_debug_flag := WF_ENGINE.GetItemAttrText
                              (  p_item_type
                               , p_item_key
                               , '.DEBUG_FLAG'
                               );

      IF FND_API.to_Boolean( l_debug_flag ) THEN
         x_debug_flag := TRUE ;
      END IF;

      -- Get Debug Output Directory
      x_output_dir  := WF_ENGINE.GetItemAttrText
                              (  p_item_type
                               , p_item_key
                               , '.DEBUG_OUTPUT_DIR'
                               );

      -- Get Debug File Name
      x_debug_filename := WF_ENGINE.GetItemAttrText
                              (  p_item_type
                               , p_item_key
                               , '.DEBUG_FILE_NAME'
                               );

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;


  END Get_Debug_Mode ;


  /********************************************************************
  * API Type      : Local APIs
  *********************************************************************/
  FUNCTION CheckChangeObjApplication
  ( p_change_id         IN     NUMBER
  , p_appl_id           IN     NUMBER
  )
  RETURN NUMBER
  IS
      l_change_obj_appl_id  NUMBER ;

      CURSOR  c_change_appl_rec (p_change_id NUMBER
                                ,p_appl_id   NUMBER)
      IS
         SELECT eec.change_id,
                eec.change_mgmt_type_code ,
                changecategory.base_change_mgmt_type_code,
                type_appl.application_id
          FROM ENG_ENGINEERING_CHANGES eec,
               ENG_CHANGE_ORDER_TYPES ChangeCategory,
               ENG_CHANGE_TYPE_APPLICATIONS type_appl
          WHERE type_appl.change_type_id = ChangeCategory.change_order_type_id
          and type_appl.application_id = p_appl_id
          AND ChangeCategory.type_classification = 'CATEGORY'
          AND ChangeCategory.change_mgmt_type_code = eec.change_mgmt_type_code
          AND eec.change_id = p_change_id  ;

  BEGIN

      FOR l_rec IN c_change_appl_rec (p_change_id => p_change_id ,
                                      p_appl_id => p_appl_id)
      LOOP
          l_change_obj_appl_id :=  l_rec.application_id  ;
      END LOOP ;

      RETURN l_change_obj_appl_id ;

  END CheckChangeObjApplication ;



  -- Internal utility procedure to check if the header is CO and on its last
  -- implement phase
  PROCEDURE Is_CO_On_Last_Imp_Phase
  (
    p_change_id                 IN   NUMBER
   ,p_api_caller                IN   VARCHAR2
   ,x_is_co_last_phase          OUT  NOCOPY  VARCHAR2
   --,x_curr_status_code          OUT  NOCOPY  NUMBER
   --,x_last_status_code          OUT  NOCOPY  NUMBER
   ,x_auto_demote_status        OUT  NOCOPY  NUMBER
  )
  IS

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_cm_type_code       eng_engineering_changes.CHANGE_MGMT_TYPE_CODE%TYPE;
    l_base_cm_type_code  eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;

    l_next_status_code   NUMBER;

    --l_curr_status_code   NUMBER;

    l_last_status_code   NUMBER;
    l_max_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;

    l_last_imp_flag      VARCHAR2(1) := 'N';


  BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT  Is_CO_On_Last_Imp_Phase;

    -- Default return value
    x_is_co_last_phase := 'F';
    --x_last_status_code := NULL;
    --x_curr_status_code := NULL;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Is_CO_On_Last_Imp_Phase log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------

    -- Get the change header's cm type, and promote_status_code
    SELECT eec.change_mgmt_type_code, eec.promote_status_code, --eec.status_code
           ecot.base_change_mgmt_type_code
      INTO l_cm_type_code, l_next_status_code, --l_curr_status_code
           l_base_cm_type_code
      FROM eng_engineering_changes eec,
           eng_change_order_types ecot
      WHERE eec.change_id = p_change_id
        AND ecot.change_order_type_id = eec.change_order_type_id;

    --x_curr_status_code := l_curr_status_code;

    -- If the change header is of type ECO and the current running phase
    -- is the last implement phase, return true, otherwise false
    IF (l_base_cm_type_code = G_ENG_ECO OR l_next_status_code IS NOT NULL) THEN

      IF g_debug_flag THEN
        Write_Debug('Info: change category is CO, and header promote_status_code is not null' );
      END IF;

      -- Get the sequence_number of the last phase
      -- Note that only phase of IMPLEMENT type can be the last phase
      SELECT max(sequence_number)
        INTO l_max_phase_sn
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y';

      -- Get the sequence number of the last phase
      SELECT status_code
        INTO l_last_status_code
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y'
          AND sequence_number = l_max_phase_sn;
      /*
      x_last_status_code := l_last_status_code;
      */

      IF ( l_next_status_code = l_last_status_code ) THEN
        x_is_co_last_phase := 'T';
      END IF;

    END IF;


    -- Standard ending code ------------------------------------------------
    IF g_debug_flag THEN
      Write_Debug('x_is_co_last_phase        : ' || x_is_co_last_phase );
      --Write_Debug('x_curr_status_code        : ' || x_curr_status_code );
      --Write_Debug('x_last_status_code        : ' || x_last_status_code );
      Write_Debug('x_auto_demote_status      : ' || x_auto_demote_status );
      Write_Debug('Finish. End Of procedure: Is_CO_On_Last_Imp_Phase') ;
    END IF;

  END Is_CO_On_Last_Imp_Phase;


  -- Internal utility procedure to check if the header is CO and its last
  -- implement phase has been used
  PROCEDURE Is_CO_Last_Imp_Phase_Used
  (
    p_change_id                 IN   NUMBER
   ,x_is_used                   OUT  NOCOPY  VARCHAR2
   ,x_last_status_type          OUT  NOCOPY  NUMBER
   ,x_last_status_code          OUT  NOCOPY  NUMBER
  )
  IS
    l_cm_type_code       eng_engineering_changes.CHANGE_MGMT_TYPE_CODE%TYPE;
    l_base_cm_type_code  eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;
    l_max_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;
    l_start_date         eng_lifecycle_statuses.start_date%TYPE;
  BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT  Is_CO_Last_Imp_Phase_Used;

    -- Default return value
    x_is_used := 'F';
    x_last_status_type := NULL;
    x_last_status_code := NULL;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Is_CO_Last_Imp_Phase_Used log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Real code starts here -----------------------------------------------

    -- Get the change header's cm type, and promote_status_code
    SELECT eec.change_mgmt_type_code, ecot.base_change_mgmt_type_code
      INTO l_cm_type_code, l_base_cm_type_code
      FROM eng_engineering_changes eec,
           eng_change_order_types ecot
      WHERE eec.change_id = p_change_id
        AND ecot.change_order_type_id = eec.change_order_type_id;

    IF (l_base_cm_type_code = G_ENG_ECO) THEN

      -- Get the sequence_number of the last phase
      -- Note that only phase of IMPLEMENT type can be the last phase
      SELECT max(sequence_number)
        INTO l_max_phase_sn
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y';

      -- Get the start_date of the last phase (to see if it's been used)
      SELECT status_code, start_date
        INTO x_last_status_code, l_start_date
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y'
          AND sequence_number = l_max_phase_sn
          AND rownum = 1;

      IF ( l_start_date IS NOT NULL ) THEN
        x_is_used := 'T';
      END IF;

      -- Get the status_type of the last phase
      SELECT status_type
        INTO x_last_status_type
        FROM eng_change_statuses
        WHERE status_code = x_last_status_code;

    END IF;


    -- Standard ending code ------------------------------------------------
    IF g_debug_flag THEN
      Write_Debug('x_is_used            : ' || x_is_used );
      Write_Debug('x_last_status_type   : ' || x_last_status_type );
      Write_Debug('x_last_status_code   : ' || x_last_status_code );
      Write_Debug('Finish. End Of procedure: Is_CO_Last_Imp_Phase_Used') ;
    END IF;

  END Is_CO_Last_Imp_Phase_Used;



  -- Internal procedure to return if a co has active revised items
  -- active revised items are defined as those with status other than
  -- 5(cancelled) or 6(implemented)
  PROCEDURE Has_Active_RevItem
  (
    p_change_id                 IN   NUMBER
   ,x_found                     OUT  NOCOPY VARCHAR2
  )
  IS
    l_rev_item_seq_id    NUMBER;
    CURSOR c_activeRevItem IS
      SELECT revised_item_sequence_id
        FROM eng_revised_items eri
        WHERE eri.change_id = p_change_id
          AND eri.status_type NOT IN (G_ENG_CANCELLED, G_ENG_IMPLEMENTED);
  BEGIN
    OPEN c_activeRevItem;
      LOOP
        FETCH c_activeRevItem INTO l_rev_item_seq_id;
        IF (c_activeRevItem%FOUND)
        THEN
          x_found := 'Y';
        ELSE
          x_found := 'N';
        END IF;
        EXIT;
      END LOOP;
    CLOSE c_activeRevItem;

  END Has_Active_RevItem;

  -- Internal utility procedure to update header approval status
  -- together with launching associated workflow
  PROCEDURE Update_Header_Appr_Status
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER
   ,p_appr_status               IN   NUMBER                             -- header approval status
   ,p_route_status              IN   VARCHAR2                           -- workflow routing status (for document types)
   ,p_api_caller                IN   VARCHAR2 := 'UI'                   -- must
   ,p_bypass                    IN   VARCHAR2 := 'N'                    -- flag to bypass phase type check
   ,x_sfa_line_items_exists     OUT  NOCOPY  VARCHAR2
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Header_Appr_Status';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_updated            BOOLEAN      := FALSE ;

    l_phase_sn           eng_lifecycle_statuses.sequence_number%TYPE;
    l_max_appr_phase_sn  eng_lifecycle_statuses.sequence_number%TYPE;

    l_status_type        eng_engineering_changes.status_type%TYPE;

    l_wf_item_key        wf_item_activity_statuses.item_key%TYPE := NULL;

    l_cm_type_code       eng_engineering_changes.change_mgmt_type_code%TYPE;
    l_base_cm_type_code  eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;

    l_param_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

    l_appl_id            NUMBER ;


    l_doc_lc_object_flag BOOLEAN := FALSE ;

  BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT  Update_Header_Appr_Status;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Update_Header_Appr_Status log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_appr_status       : ' || p_appr_status );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('p_bypass            : ' || p_bypass );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;


    -- Real code starts here -----------------------------------------------

    -- get phase type
    SELECT status_type
      INTO l_status_type
      FROM eng_change_statuses
      WHERE status_code = p_status_code;

     -- Select cm type and base type code for upcoming API calls
        SELECT eec.change_mgmt_type_code, ecot.base_change_mgmt_type_code
          INTO l_cm_type_code, l_base_cm_type_code
          FROM eng_engineering_changes eec,
               eng_change_order_types ecot
          WHERE eec.change_id = p_change_id
          AND ecot.change_order_type_id = eec.change_order_type_id;

    l_doc_lc_object_flag := ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle
                               ( p_change_id => p_change_id
                               , p_base_change_mgmt_type_code => l_base_cm_type_code
                               )  ;
    -- update header approval status only for phase of type APPROVAL or REVIEW for Doc
    IF ( l_status_type = G_ENG_APPROVED OR p_bypass = 'Y'
         OR (l_doc_lc_object_flag AND l_status_type = G_ENG_REVIEWED)) THEN
      IF g_debug_flag THEN
         Write_Debug('Phase type is APPROVAL or p_bypass = ''Y'' (for NIR)');
      END IF;

      -- update header approval status
      IF (p_appr_status = G_ENG_APPR_REQUESTED ) THEN
        UPDATE eng_engineering_changes
          SET approval_status_type = p_appr_status,
              approval_request_date = sysdate,
              approval_date = null,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;
        l_updated := TRUE;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_engineering_changes.approval_* columns.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;
        IF g_debug_flag THEN
           Write_Debug('After: updating header approval columns FOR APPROVAL REQUESTED');
        END IF;

      ELSIF (p_appr_status = G_ENG_APPR_APPROVED) THEN
        -- Update header to approved only for the last phase of type APPROVAL

        -- Get the current phase's sequence number
        SELECT sequence_number
          INTO l_phase_sn
          FROM eng_lifecycle_statuses
          WHERE entity_name = G_ENG_CHANGE
            AND entity_id1 = p_change_id
            AND status_code = p_status_code
            AND active_flag = 'Y'
            AND rownum = 1;

        -- Get the sequence number of the last phase of type APPROVAL
        SELECT max(lcs.sequence_number)
          INTO l_max_appr_phase_sn
          FROM eng_lifecycle_statuses lcs,
               eng_change_statuses chs
          WHERE lcs.entity_name = G_ENG_CHANGE
            AND lcs.entity_id1 = p_change_id
            AND lcs.active_flag = 'Y'
            AND chs.status_code = lcs.status_code
            AND chs.status_type = G_ENG_APPROVED;

        -- Check if the specified phase is the last phase of type APPROVAL
        -- Update header approval status if so
        -- Note for case: p_api_caller is null: previous if condition
        -- garrantees l_status_type = G_ENG_APPROVED
        IF ( l_phase_sn = l_max_appr_phase_sn OR (p_api_caller IS NULL) ) THEN
          IF g_debug_flag THEN
            Write_Debug('Current phase is the last of such type');
          END IF;

          UPDATE eng_engineering_changes
            SET approval_status_type = p_appr_status,
                approval_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = l_fnd_user_id,
                last_update_login = l_fnd_login_id
            WHERE change_id = p_change_id;
            l_updated := TRUE;
          IF g_debug_flag THEN
            Write_Debug('After updating eng_engineering_changes.approval_* columns.');
            Write_Debug('  Row count = ' || SQL%ROWCOUNT);
          END IF;
          IF g_debug_flag THEN
             Write_Debug('After: updating header approval columns FOR APPROVED');
          END IF;
        END IF;

      ELSIF (   p_appr_status = G_ENG_APPR_REJECTED
             OR p_appr_status = G_ENG_APPR_PROC_ERR
             OR p_appr_status = G_ENG_APPR_TIME_OUT)
      THEN
        UPDATE eng_engineering_changes
          SET approval_status_type = p_appr_status,
              approval_date = null,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;
        l_updated := TRUE;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_engineering_changes.approval_* columns.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;
        IF g_debug_flag THEN
           Write_Debug('After: updating header approval columns FOR REJECTED, PROC_ERR, TIME_OUT');
        END IF;

       ELSIF  (l_doc_lc_object_flag AND l_status_type = G_ENG_REVIEWED)
       THEN
        l_updated := TRUE;
	ELSE
        UPDATE eng_engineering_changes
          SET approval_status_type = p_appr_status,
              approval_request_date = null,
              approval_date = null,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;
        l_updated := TRUE;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_engineering_changes.approval_* columns.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;
        IF g_debug_flag THEN
           Write_Debug('After: updating header approval columns FOR other approval types');
        END IF;
      END IF;

      -- Since in some cases header approval status won't be updated
      -- using l_updated flag to skip follow-up code here
      IF (l_updated = TRUE)
      THEN
        -- Select cm type and base type code for upcoming API calls
        /*SELECT eec.change_mgmt_type_code, ecot.base_change_mgmt_type_code
          INTO l_cm_type_code, l_base_cm_type_code
          FROM eng_engineering_changes eec,
               eng_change_order_types ecot
          WHERE eec.change_id = p_change_id
          AND ecot.change_order_type_id = eec.change_order_type_id;*/


        --
        -- R12B
        -- Document Lifecycle Support
        -- Check if this change object is Document LC Change Object
        --
       /* l_doc_lc_object_flag := ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle
                               ( p_change_id => p_change_id
                               , p_base_change_mgmt_type_code => l_base_cm_type_code
                               )  ;*/

        -- In case of Document LC Change Object, the Approval Status change and
        -- the event should not be raised
        IF (NOT l_doc_lc_object_flag)
        THEN
            IF g_debug_flag THEN
               Write_Debug('Before: Approval Status Change WF and Event');
            END IF;


            -- Skip workflow notification if approval status is set back to not_submitted
            IF (p_appr_status <> G_ENG_NOT_SUBMITTED)
            THEN


              -- Launch header approval status change workflow
              IF g_debug_flag THEN
                 Write_Debug('Before: Launch header approval status change workflow');
              END IF;

              Eng_Workflow_Util.StartWorkflow
              (  p_api_version       => 1.0
              ,  p_init_msg_list     => FND_API.G_FALSE
              ,  p_commit            => FND_API.G_FALSE
              ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
              ,  x_return_status     => l_return_status
              ,  x_msg_count         => l_msg_count
              ,  x_msg_data          => l_msg_data
              ,  p_item_type         => Eng_Workflow_Util.G_CHANGE_ACTION_ITEM_TYPE
              ,  x_item_key          => l_wf_item_key
              ,  p_process_name      => Eng_Workflow_Util.G_APPROVAL_STATUS_CHANGE_PROC
              ,  p_change_id         => p_change_id
              ,  p_wf_user_id        => l_fnd_user_id
              ,  p_route_id          => 0 --l_wf_route_id
              ,  p_debug             => p_debug --FND_API.G_FALSE
              ,  p_output_dir        => p_output_dir
              ,  p_debug_filename    => NULL  --p_debug_filename
              ) ;

              IF g_debug_flag THEN
                 Write_Debug('After: Launch header approval status change workflow: ' || l_return_status );
              END IF;

              IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
              THEN
                x_return_status := l_return_status;
                x_msg_count := l_msg_count;
                x_msg_data := l_msg_data;
                --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
                --#FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              l_wf_item_key := NULL;
              IF g_debug_flag THEN
                 Write_Debug('Successful: Launch header approval status change workflow');
              END IF;
            END IF;


            -- Raise the approval status change business event
            -- Adding event parameters to the list
            ENG_CHANGE_BES_UTIL.Raise_Appr_Status_Change_Event
            ( p_change_id         => p_change_id
             ,p_appr_status       => p_appr_status
             ,p_wf_route_status   => p_route_status
             );


        END IF ; -- Check IF (NOT l_doc_lc_object_flag)

     --   R12C Enhancement
     --   When the NIR is demoted to Approval status from a later phase or when the workflow in the Approval phase is aborted
     --   The Line items have to go through the Item Approval process again
     --   All the Rejected line items have to be reset to Submitted for Approval / Open
     --   Approved Items can anyhow be rejected later if required by other workflow assignees
     IF p_appr_status <> G_ENG_APPR_APPROVED AND p_appr_status <> G_ENG_APPR_REJECTED THEN
          ENG_NIR_UTIL_PKG.Update_Line_Items_App_St(p_change_id, 3, x_sfa_line_items_exists); -- Reset it to SFA
     END IF;

        -- Other calls and updates triggered by the header approval status update
        -- call item part request API if applicable
         IF (l_base_cm_type_code = G_ENG_NEW_ITEM_REQ
		AND p_appr_status in (G_ENG_APPR_REJECTED, G_ENG_APPR_TIME_OUT) ) THEN
          IF g_debug_flag THEN
             Write_Debug('Before: calling new item request API');
             Write_Debug('  p_change_id =   ' || p_change_id);
             Write_Debug('  p_appr_status = ' || p_appr_status);
          END IF;
         ENG_NIR_UTIL_PKG.set_nir_item_approval_status
          ( p_change_id          => p_change_id
           ,p_approval_status    => p_appr_status
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           );

          IF g_debug_flag THEN
             Write_Debug('After: calling new item request API: ' || l_return_status) ;
          END IF;

          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_NIR_UTIL_PKG.set_nir_item_approval_status');
            --#FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_wf_item_key := NULL;
          IF g_debug_flag THEN
             Write_Debug('Successful: calling new item request API');
          END IF;
        END IF;

        -- Update attachment approval if needed
        IF g_debug_flag THEN
          Write_Debug('Before: calling update DM attachment approval/review API');
        END IF;

        -- obsolete for bug 3429353 fix
        -- IF ( p_appr_status <> G_ENG_APPR_APPROVED
        --    AND (l_base_cm_type_code = G_ENG_ATTACHMENT_APPR
        --         OR l_base_cm_type_code = G_ENG_ATTACHMENT_REVW)
        --    )
        --

        -- Added condition to call DM attachment approval/review API
        -- if approval status is REJECTED for Bug4187851
        -- in order to support
        -- 6. Document status will get changed to Rejected as soon as the first
        -- rejection happens in any of the approval workflow in the lifecycle.
        -- then we will leave the final approval update to
        -- Update_Lifecycle_States procedure final implement phase handling
        -- Note:
        -- This call will be moved to BES Subscription in future release
        -- In the meantime, we put the call to minimize the code impact

        IF (   l_base_cm_type_code = G_ENG_ATTACHMENT_APPR
            OR l_base_cm_type_code = G_ENG_ATTACHMENT_REVW )
           AND p_appr_status = G_ENG_APPR_REJECTED
        THEN
          IF g_debug_flag THEN
            Write_Debug('In: calling DM attachment approval/review API');
            Write_Debug('p_workflow_status : ' || p_status_code );
            Write_Debug('p_approval_status : ' || p_appr_status );
          END IF;
          ENG_ATTACHMENT_IMPLEMENTATION.Update_Attachment_Status
          (
            p_api_version         => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,p_commit              => FND_API.G_FALSE
           ,p_validation_level    => p_validation_level
           ,p_debug               => p_debug --FND_API.G_FALSE
           ,p_output_dir          => p_output_dir
           ,p_debug_filename      => NULL  --p_debug_filename
           ,x_return_status       => l_return_status
           ,x_msg_count           => l_msg_count
           ,x_msg_data            => l_msg_data
           ,p_change_id           => p_change_id
           ,p_workflow_status     => p_route_status
           ,p_approval_status     => p_appr_status
           ,p_api_caller          => p_api_caller
          );

          IF g_debug_flag THEN
              Write_Debug('After: calling update DM attachment approval/review API: ' || l_return_status) ;
          END IF;


          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ATTACHMENT_IMPLEMENTATION.Update_Attachment_Status');
            --#FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;


        -- AMW/ICM Application to Application integration calls
        -- triggered by the header approval status update
        -- call ENG_ICMDB_APIS_UTIL.Update_Approval_Status if applicable

        l_appl_id := CheckChangeObjApplication( p_change_id => p_change_id ,
                                                p_appl_id => 242 -- AMW Applciation ID
                                              )  ;

        IF  (l_appl_id IS NOT NULL)
        THEN
          IF g_debug_flag THEN
             Write_Debug('Before: calling ENG_ICMDB_APIS_UTIL.Update_Approval_Status');
             Write_Debug('  p_change_id =   ' || p_change_id);
             Write_Debug('  p_base_change_mgmt_type_code =   ' || l_base_cm_type_code);
             Write_Debug('  p_appr_status = ' || p_appr_status);
             Write_Debug('  p_workflow_status_code =   ' || p_route_status);
          END IF;

          ENG_ICMDB_APIS_UTIL.Update_Approval_Status
          ( p_change_id => p_change_id
           ,p_base_change_mgmt_type_code => l_base_cm_type_code
           ,p_new_approval_status_cde  => p_appr_status
           ,p_workflow_status_code => p_route_status
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           );

          IF g_debug_flag THEN
             Write_Debug('After: calling ENG_ICMDB_APIS_UTIL.Update_Approval_Status: ' || l_return_status) ;
          END IF;

          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_NIR_UTIL_PKG.set_nir_item_approval_status');
            --#FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF g_debug_flag THEN
             Write_Debug('Successful: ENG_ICMDB_APIS_UTIL.Update_Approval_Status');
          END IF;

        END IF; -- if ( Change Object is AMW Appl)

        IF g_debug_flag THEN
          Write_Debug('After: calling update DM attachment approval/review API');
        END IF;


        --
        -- R12B
        -- Document Lifecycle Support
        -- triggered by the header approval status update
        -- call ENG_DOCUMENT_UTIL.Update_Approval_Status if applicable

        IF ( l_doc_lc_object_flag)
        THEN
            IF g_debug_flag THEN
               Write_Debug('Before: calling ENG_DOCUMENT_UTIL.Update_Approval_Status');
               Write_Debug('  p_change_id =   ' || p_change_id);
               Write_Debug('  p_base_change_mgmt_type_code =   ' || l_base_cm_type_code);
               Write_Debug('  p_appr_status = ' || p_appr_status);
               Write_Debug('  p_workflow_status_code =   ' || p_route_status);
            END IF;


            ENG_DOCUMENT_UTIL.Update_Approval_Status
            ( p_api_version         => 1.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_debug               => FND_API.G_FALSE
             ,p_output_dir          => p_output_dir
             ,p_debug_filename      => p_debug_filename
             ,x_return_status       => l_return_status     --
             ,x_msg_count           => l_msg_count         --
             ,x_msg_data            => l_msg_data          --
             ,p_change_id           => p_change_id         -- header's change_id
             ,p_approval_status     => p_appr_status       -- header approval status
             ,p_wf_route_status     => p_route_status      -- workflow routing status (for document types)
             ,p_api_caller          => p_api_caller        -- Optionnal for future use
            );

            IF g_debug_flag THEN
               Write_Debug('After: calling ENG_DOCUMENT_UTIL.Update_Approval_Status: ' || l_return_status) ;
            END IF;

            IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
            THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF g_debug_flag THEN
               Write_Debug('Successful: ENG_DOCUMENT_UTIL.Update_Approval_Status');
            END IF;

        END IF; -- if ( Change Object is Documet LC Object)


      END IF; -- if (l_updated = true)

    END IF; -- if (p_status_code's phase type is APPROVAL



    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Update_Header_Appr_Status') ;
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Update_Header_Appr_Status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Update_Header_Appr_Status;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Update_Header_Appr_Status;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Update_Header_Appr_Status;

  PROCEDURE Update_Header_Appr_Status
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER
   ,p_appr_status               IN   NUMBER                             -- header approval status
   ,p_route_status              IN   VARCHAR2                           -- workflow routing status (for document types)
   ,p_api_caller                IN   VARCHAR2 := 'UI'                   -- must
   ,p_bypass                    IN   VARCHAR2 := 'N'                    -- flag to bypass phase type check
  )
  IS
     l_sfa_line_items_exists VARCHAR2(1);
  BEGIN
      Update_Header_Appr_Status
      (
        p_api_version               =>  p_api_version
       ,p_init_msg_list             =>  p_init_msg_list
       ,p_commit                    =>  p_commit
       ,p_validation_level          =>  p_validation_level
       ,p_debug                     =>  p_debug
       ,p_output_dir                =>  p_output_dir
       ,p_debug_filename            =>  p_debug_filename
       ,x_return_status             =>  x_return_status
       ,x_msg_count                 =>  x_msg_count
       ,x_msg_data                  =>  x_msg_data
       ,p_change_id                 =>  p_change_id
       ,p_status_code               =>  p_status_code
       ,p_appr_status               =>  p_appr_status
       ,p_route_status              =>  p_route_status
       ,p_api_caller                =>  p_api_caller
       ,p_bypass                    =>  p_bypass
       ,x_sfa_line_items_exists     => l_sfa_line_items_exists
      );
  END Update_Header_Appr_Status;


  -- R12B
  -- Internal procedure to automatically launch line 'Not Started' workflow if necessary
  -- when line workflow is defined and Start After Status is specified phase.
  --
  PROCEDURE Start_Line_Workflow
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_new_status_code           IN   NUMBER                             -- new status code to be promoted to
   ,p_cur_status_code           IN   NUMBER                             -- curre status code
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF', or other internal procedure names
   ,p_action_type               IN   VARCHAR2 := NULL                   -- or PROMOTE, DEMOTE
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Start_Line_Workflow';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_api_caller         VARCHAR2(2) := NULL;
    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));


    l_change_line_id     NUMBER ;
    l_line_wf_route_id   NUMBER ;
    l_line_wf_item_key   wf_item_activity_statuses.item_key%TYPE := NULL;


    -- Select Line Workflow to be started for the passed status_code
    CURSOR c_line_wf ( c_change_id       IN NUMBER
                     , c_new_status_code IN NUMBER
                     , c_cur_status_code IN NUMBER
                     )
    IS
        SELECT DISTINCT route.route_id wf_route_id
             , line.change_line_id
        FROM eng_change_routes route,
             eng_change_statuses s,
             eng_change_lines line,
             eng_lifecycle_statuses line_start_after,
             eng_lifecycle_statuses new_status,
             eng_lifecycle_statuses cur_status
        WHERE route.status_code = Eng_Workflow_Util.G_RT_NOT_STARTED
        AND route.route_id = line.route_id
        AND s.status_type <> G_ENG_COMPLETED
        AND s.status_type <> G_ENG_IMPLEMENTED
        AND s.status_type <> G_ENG_CANCELLED
        AND s.status_code = line.status_code
        AND line.start_after_status_code = c_new_status_code
        AND line.change_id = c_change_id
        AND line_start_after.sequence_number <= new_status.sequence_number
        AND line_start_after.sequence_number > cur_status.sequence_number
        AND line_start_after.entity_name = G_ENG_CHANGE
        AND line_start_after.entity_id1 = c_change_id
        AND line_start_after.status_code = line.start_after_status_code
        AND line_start_after.active_flag = 'Y'
        AND new_status.entity_name =  G_ENG_CHANGE
        AND new_status.entity_id1 = c_change_id
        AND new_status.status_code = c_new_status_code
        AND new_status.active_flag = 'Y'
        AND cur_status.entity_name = G_ENG_CHANGE
        AND cur_status.entity_id1 = c_change_id
        AND cur_status.status_code = c_cur_status_code
        AND cur_status.active_flag = 'Y' ;

  BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT Start_Line_Workflow;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Start_Line_Workflow log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_new_status_code       : ' || p_new_status_code );
       Write_Debug('p_cur_status_code       : ' || p_cur_status_code);
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------

    -- Start phase workflow only for PROMOTE action
    -- (When demoting to a new phase, do not auto-start new phase workflow)
    IF g_debug_flag THEN
       Write_Debug('Before: handling new phase workflow');
    END IF;

    IF (p_action_type = G_ENG_DEMOTE) THEN
      IF g_debug_flag THEN
         Write_Debug('  Branch: p_action_type = DEMOTE, do nothing');
      END IF;

    ELSE  --G_ENG_PROMOTE

      IF g_debug_flag THEN
         Write_Debug('  Branch: p_action_type is not DEMOTE, check if Line workflow auto-start is needed');
      END IF;


      FOR l_rec IN c_line_wf (c_change_id => p_change_id ,
                              c_new_status_code => p_new_status_code ,
                              c_cur_status_code => p_cur_status_code
                              )
      LOOP

        l_change_line_id     := l_rec.change_line_id  ;
        l_line_wf_route_id   := l_rec.wf_route_id  ;
        l_line_wf_item_key   := NULL;

        IF g_debug_flag THEN
          Write_Debug('calling Eng_Workflow_Util.StartWorkflow API for Line') ;
          Write_Debug('l_change_line_id: '  || TO_CHAR(l_change_line_id) ) ;
          Write_Debug('l_line_wf_route_id: '  || TO_CHAR(l_line_wf_route_id) ) ;
        END IF;

        -- start phase-level workflow
        Eng_Workflow_Util.StartWorkflow
        (  p_api_version       => 1.0
        ,  p_init_msg_list     => FND_API.G_FALSE
        ,  p_commit            => FND_API.G_FALSE
        ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status     => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data          => l_msg_data
        ,  p_item_type         => Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE
        ,  x_item_key          => l_line_wf_item_key
        ,  p_process_name      => Eng_Workflow_Util.G_ROUTE_AGENT_PROC
        ,  p_change_id         => p_change_id
        ,  p_change_line_id    => l_change_line_id
        ,  p_wf_user_id        => l_fnd_user_id
        ,  p_route_id          => l_line_wf_route_id
        ,  p_debug             => p_debug --FND_API.G_FALSE
        ,  p_output_dir        => p_output_dir
        ,  p_debug_filename    => NULL
        ) ;

        IF g_debug_flag THEN
          Write_Debug('After: calling Eng_Workflow_Util.StartWorkflow API for ' || TO_CHAR(l_change_line_id) || l_return_status) ;
          Write_Debug('l_line_wf_item_key: '  || l_line_wf_item_key) ;
        END IF;

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
        ELSE
          IF g_debug_flag THEN
             Write_Debug('Successful: calling workflow routing agent');
          END IF;
        END IF;

      END LOOP ; -- c_line_wf loop

    END IF; -- if (action = PROMOTE)

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Start_Line_Workflow');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Start_Line_Workflow;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Start_Line_Workflow;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Start_Line_Workflow;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Start_Line_Workflow ;




  -- Internal procedure to automatically launch workflow if necessary
  -- (i.e., when workflow is defined) for the specified phase
  -- Note that this procedure may also submit the concurrent program for
  -- implementing ECO as well!!!
  PROCEDURE Start_WF_OnlyIf_Necessary
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_status_type               IN   NUMBER                             -- new phase type
   ,p_sequence_number           IN   NUMBER                             -- new phase sequence number
   ,p_imp_eco_flag              IN   VARCHAR2 := 'N'                    -- flag for implementECO
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF', or other internal procedure names
   ,p_action_type               IN   VARCHAR2 := NULL                   -- or PROMOTE, DEMOTE
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
   ,p_skip_wf                   IN   VARCHAR2 := 'N'                    -- used for eco's last implement phase
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Start_WF_OnlyIf_Necessary';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_api_caller         VARCHAR2(2) := NULL;
    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_action_id          eng_change_actions.action_id%TYPE;

    l_wf_route_id        eng_lifecycle_statuses.change_wf_route_id%TYPE;
    l_wf_route_temp_id   eng_lifecycle_statuses.change_wf_route_template_id%TYPE;
    l_wf_item_key        wf_item_activity_statuses.item_key%TYPE := NULL;

    l_chg_notice         eng_engineering_changes.change_notice%TYPE;
    l_org_id             eng_engineering_changes.organization_id%TYPE;
    l_request_id         NUMBER;

    l_min_appr_sn        eng_lifecycle_statuses.sequence_number%TYPE;
    l_doc_lc_object_flag BOOLEAN := FALSE ;


  BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT Start_WF_OnlyIf_Necessary;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Start_WF_OnlyIf_Necessary log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------

    -- Log action log only for calls not coming from the UI
    -- (implying automatic promotion/demotion),
    -- but not from Init_Lifecycle procedure
    -- Also: skip logging action and status change workflow in case of special
    -- ECO implement phase
    IF (    (p_api_caller IS NULL OR p_api_caller <> 'UI')
         AND p_action_type IS NOT NULL
         AND(p_imp_eco_flag IS NULL OR p_imp_eco_flag <> 'Y')
         )
    THEN

      IF g_debug_flag THEN
         Write_Debug('Before: saving action log');
      END IF;
      l_action_id := 0;
      -- create new action log
      ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
      ( p_api_version           => 1.0
      , p_init_msg_list         => FND_API.G_FALSE        --
      , p_commit                => FND_API.G_FALSE        --
      , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
      , p_debug                 => p_debug --FND_API.G_FALSE
      , p_output_dir            => p_output_dir
      , p_debug_filename        => NULL
      , x_return_status         => l_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      , p_action_type           => p_action_type
      , p_object_name           => G_ENG_CHANGE
      , p_object_id1            => p_change_id
      , p_object_id2            => NULL
      , p_object_id3            => NULL
      , p_object_id4            => NULL
      , p_object_id5            => NULL
      , p_parent_action_id      => -1
      , p_status_code           => p_status_code
      , p_action_date           => SYSDATE
      , p_change_description    => NULL
      , p_user_id               => l_fnd_user_id
      , p_api_caller            => p_api_caller
      , x_change_action_id      => l_action_id
      );
      IF g_debug_flag THEN
         Write_Debug('After: saving action log: ' || l_return_status) ;
         Write_Debug('l_action_id       : ' || l_action_id );
      END IF;
      IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
      THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
        --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
        --#FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF g_debug_flag THEN
         Write_Debug('Successful: saving action log');
      END IF;


      -- R12B
      -- In case of Document LC Change Object
      -- We don't need to start workflow and riase event
      l_doc_lc_object_flag := ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle
                             ( p_change_id => p_change_id
                             , p_base_change_mgmt_type_code => NULL
                             )  ;

      IF (NOT l_doc_lc_object_flag)
      THEN

          ENG_CHANGE_BES_UTIL.Raise_Status_Change_Event
          ( p_change_id         => p_change_id
           ,p_status_code       => p_status_code
           ,p_action_type       => p_action_type
           ,p_action_id         => l_action_id
           );


          -- Force commit to make sure workflow picks up the latest phase
          COMMIT WORK;

          -- launch the standard action workflow for new action if needed
          IF g_debug_flag THEN
            Write_Debug('Before: calling status change workflow API');
          END IF;

          Eng_Workflow_Util.StartWorkflow
          (  p_api_version       => 1.0
          ,  p_init_msg_list     => FND_API.G_FALSE
          ,  p_commit            => FND_API.G_FALSE
          ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
          ,  x_return_status     => l_return_status
          ,  x_msg_count         => l_msg_count
          ,  x_msg_data          => l_msg_data
          ,  p_item_type         => Eng_Workflow_Util.G_CHANGE_ACTION_ITEM_TYPE
          ,  x_item_key          => l_wf_item_key
          ,  p_process_name      => Eng_Workflow_Util.G_STATUS_CHANGE_PROC
          ,  p_change_id         => p_change_id
          ,  p_action_id         => l_action_id
          ,  p_wf_user_id        => l_fnd_user_id
          ,  p_route_id          => 0 --l_wf_route_id
          ,  p_debug             => p_debug --FND_API.G_FALSE
          ,  p_output_dir        => p_output_dir
          ,  p_debug_filename    => NULL
          ) ;
          -- note that the returned wf item_key won't be saved on the ENG side
          IF g_debug_flag THEN
            Write_Debug('After: calling status change workflow API: ' || l_return_status) ;
          END IF;

          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
            --#FND_MSG_PUB.Add;
            --#RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_wf_item_key := NULL;

          IF g_debug_flag THEN
            Write_Debug('Successful: calling status change workflow API');
          END IF;

       END IF ;   -- IF (NOT l_doc_lc_object_flag)

    END IF; -- if (not calling from UI)

    -- Start phase workflow only for PROMOTE action
    -- (When demoting to a new phase, do not auto-start new phase workflow)
    IF g_debug_flag THEN
       Write_Debug('Before: handling new phase workflow');
    END IF;

    IF (p_action_type = G_ENG_DEMOTE) THEN
      IF g_debug_flag THEN
         Write_Debug('  Branch: p_action_type = DEMOTE, do nothing');
      END IF;

    ELSE  --G_ENG_PROMOTE
      IF g_debug_flag THEN
         Write_Debug('  Branch: p_action_type is not DEMOTE, check if workflow auto-start is needed');
      END IF;
      -- Check if automatic wf start is needed
      SELECT change_wf_route_id, change_wf_route_template_id
        INTO l_wf_route_id, l_wf_route_temp_id
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = p_status_code
          AND active_flag = 'Y'
          AND rownum = 1;


      IF (p_skip_wf <> 'Y'   -- fix for bug 3479509 design change of launching wf after concurrent program
          AND l_wf_route_id IS NOT NULL )
      THEN
        IF g_debug_flag THEN
           Write_Debug('Auto-starting workflow is needed, calling workflow routing agent');
        END IF;

        -- start phase-level workflow
        Eng_Workflow_Util.StartWorkflow
        (  p_api_version       => 1.0
        ,  p_init_msg_list     => FND_API.G_FALSE
        ,  p_commit            => FND_API.G_FALSE
        ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status     => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data          => l_msg_data
        ,  p_item_type         => Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE
        ,  x_item_key          => l_wf_item_key
        ,  p_process_name      => Eng_Workflow_Util.G_ROUTE_AGENT_PROC
        ,  p_change_id         => p_change_id
        ,  p_wf_user_id        => l_fnd_user_id
        ,  p_route_id          => l_wf_route_id
        ,  p_debug             => p_debug --FND_API.G_FALSE
        ,  p_output_dir        => p_output_dir
        ,  p_debug_filename    => NULL
        ) ;

        IF g_debug_flag THEN
          Write_Debug('After: calling Eng_Workflow_Util.StartWorkflow API: ' || l_return_status) ;
        END IF;


        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
          --#FND_MSG_PUB.Add;
          --#RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF g_debug_flag THEN
             Write_Debug('Successful: calling workflow routing agent');
          END IF;
        END IF;
        l_wf_item_key := NULL;

      -- If phase workflow is defined by wf template id, but wf instance id
      -- has not been populated, do nothing
      ELSIF (p_skip_wf <> 'Y'   -- fix for bug 3479509 design change of launching wf after concurrent program
             AND l_wf_Route_id IS NULL AND l_wf_route_temp_id IS NOT NULL ) THEN
        IF g_debug_flag THEN
           Write_Debug('Only phase workflow template id is defined,');
           Write_Debug('Workflow instance id needs to be populated before the phase workflow can be started');
        END IF;

      -- If p_skip_wf is true, or there is no workflow defined for the phase at all
      ELSE
        IF g_debug_flag THEN
           Write_Debug('Auto-starting workflow is not needed, do post workflow update right away');
        END IF;

        -- determine API caller - 'UI' should be used only once in case promotion/demote recursion occurs
        IF (p_api_caller = 'WF' OR p_api_caller = 'CP') THEN
          l_api_caller := p_api_caller;
        ELSE
          l_api_caller := NULL;
        END IF;

        -- Do post workflow update right away
        Update_Lifecycle_States
        (
          p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_api_caller         => l_api_caller
         ,p_wf_route_id        => NULL
         ,p_route_status       => NULL
         ,p_comment            => p_comment
        );

        IF g_debug_flag THEN
          Write_Debug('After: calling Update_Lifecycle_States API: ' || l_return_status) ;
        END IF;


        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Update_Lifecycle_States');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- if (phase workflow instance id and workflow template id)

    END IF; -- if (action = PROMOTE)

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Start_WF_OnlyIf_Necessary');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Start_WF_OnlyIf_Necessary;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Start_WF_OnlyIf_Necessary;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Start_WF_OnlyIf_Necessary;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Start_WF_OnlyIf_Necessary;


  -- Internal procedure for promotion of change header (inc. revItems)
  PROCEDURE Promote_Header
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Promote_Header';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_is_imp_phase_used  VARCHAR2(1) := 'F';

    l_last_status_type   NUMBER;
    l_last_status_code   NUMBER;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_curr_status_code   eng_engineering_changes.status_code%TYPE;

    l_curr_phase_sn      eng_lifecycle_statuses.sequence_number%TYPE;
    l_new_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;
    l_max_sn             eng_lifecycle_statuses.sequence_number%TYPE;
    l_phase_sn           eng_lifecycle_statuses.sequence_number%TYPE;

    l_new_status_type    eng_change_statuses.status_type%TYPE;
    l_ri_status_type     eng_change_statuses.status_type%TYPE;

    l_skip_promotion     VARCHAR2(1) := 'N';

    -- Select status_type of all lines of the header
    CURSOR c_lines IS
      SELECT s.status_type,
             l.complete_before_status_code,
             l.required_flag,
             l.change_type_id ,
             route.status_code wf_status_code
        FROM eng_change_routes route,
             eng_change_statuses s,
             eng_change_lines l
        WHERE s.status_code = l.status_code
        AND route.route_id(+) = l.route_id
        AND l.change_id = p_change_id ;

    l_line_status_type   eng_change_statuses.status_type%TYPE;
    l_status_code        eng_change_lines.complete_before_status_code%TYPE;
    l_required_flag      eng_change_lines.required_flag%TYPE := NULL;
    l_change_type_id     NUMBER ;
    l_wf_status_code     eng_change_routes.status_code%TYPE;

    -- Select all revised items
    CURSOR c_revItems IS
      SELECT status_code
        FROM eng_revised_items
        WHERE change_id = p_change_id
      FOR UPDATE;


    l_ri_status_code      eng_change_lines.status_code%TYPE;
    -- revItem's status_code's sequence_number
    l_ri_phase_sn         eng_lifecycle_statuses.sequence_number%TYPE;

    l_last_imp_flag       VARCHAR2(1) := 'N';
    l_cm_type_code        eng_engineering_changes.CHANGE_MGMT_TYPE_CODE%TYPE;
    l_base_cm_type_code   eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;
    l_imp_eco_flag        VARCHAR2(1) := 'N';

    --l_co_type_id          eng_engineering_changes.CHANGE_ORDER_TYPE_ID%TYPE;
    l_auto_prop_flag      eng_type_org_properties.AUTO_PROPAGATE_FLAG%TYPE;
    l_change_notice       eng_engineering_changes.change_notice%TYPE;
    l_hierarchy_name      per_organization_structures.name%TYPE;
    l_org_name            org_organization_definitions.organization_name%TYPE;
    l_row_cnt             NUMBER := 0;

    l_doc_lc_object_flag  BOOLEAN := FALSE ;


    CURSOR c_orgProp IS
      SELECT op.auto_propagate_flag,
             ec.change_notice,
             pos.name,
             ood.name organization_name
        FROM eng_type_org_properties op,
             eng_engineering_changes ec,
             per_organization_structures pos,
             hr_all_organization_units_tl ood
        WHERE ec.change_id = p_change_id
          --AND ec.PLM_OR_ERP_CHANGE = 'PLM'
          AND op.change_type_id = ec.change_order_type_id
          AND op.organization_id = ec.organization_id
          AND op.propagation_status_code = p_status_code
          AND ec.hierarchy_id IS NOT NULL
          AND ec.organization_id IS NOT NULL
          AND pos.organization_structure_id(+) = ec.hierarchy_id
          AND ood.organization_id(+) = ec.organization_id
          AND ood.LANGUAGE = USERENV('LANG')
          -- R12 UT: Added where clause to not autopropagated if propagation has
          -- been initiated to any of the organizations manually or by the
          -- TTM process.
          AND NOT EXISTS (SELECT 1
                            FROM eng_change_obj_relationships
                           WHERE change_id = ec.change_id
                             AND object_to_name = 'ENG_CHANGE'
                             AND relationship_code = 'PROPAGATED_TO');

    --Bug No: 4767315
    --returns Y if there exists no revised items which are not cancelled for the CO
    CURSOR c_no_revisedItem IS
      SELECT 'Y'
      FROM DUAL
      WHERE not exists (SELECT 1
                        FROM eng_revised_items
                        WHERE change_id=p_change_id
                        AND status_code <> 5
                        );

    l_request_id          NUMBER := 0;

    l_action_id           eng_change_actions.action_id%TYPE;

    l_wf_status           eng_lifecycle_statuses.workflow_status%TYPE;
    l_wf_route_id         eng_lifecycle_statuses.change_wf_route_id%TYPE;
    l_new_route_id        eng_lifecycle_statuses.change_wf_route_id%TYPE;

    l_found_rev_item      VARCHAR2(1) := 'N';

    l_skip_wf             VARCHAR2(1) := 'N';

    l_skip        VARCHAR2(1) := 'N';

    l_eco_approval_status VARCHAR2(1); -- Bug 3769329

    -- bug 6695079 start
    l_temp_flag           VARCHAR2(1) := 'Y';
    l_obj_id1		  NUMBER := 0;

		CURSOR c_lifecyc IS
		   SELECT change_wf_route_id
		   FROM eng_lifecycle_statuses
		   WHERE entity_name = G_ENG_CHANGE
		    AND entity_id1 = p_change_id
		    AND active_flag = 'Y'
		    and change_wf_route_id is not null;
		-- bug 6695079 end


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Promote_Header;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;



    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Promote_Header log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------
		-- bug 6695079 start
		For lifecyc in c_lifecyc
		loop
				select template_flag, object_id1
				into l_temp_flag, l_obj_id1
				from eng_change_routes
				where route_id = lifecyc.change_wf_route_id;

			if ((l_temp_flag = 'N' or l_temp_flag = 'H') and l_obj_id1 = 0) then
			      FND_MESSAGE.Set_Name('ENG','ENG_ROUTE_APPLY_NO_TEMP');
			      FND_MSG_PUB.Add;
			      RAISE FND_API.G_EXC_ERROR;
			end if;
		end loop;
		-- bug 6695079 end


    -- First check if the header is CO and last implement phase has been used
    Is_CO_Last_Imp_Phase_Used
    ( p_change_id          => p_change_id
     ,x_is_used            => l_is_imp_phase_used
     ,x_last_status_type   => l_last_status_type
     ,x_last_status_code   => l_last_status_code
     );

    -- If so, refresh the last implement phase before promotion
    IF ( l_is_imp_phase_used = 'T' ) THEN

      -- Refresh workflow id and its status if applicable
      IF g_debug_flag THEN
        Write_Debug('Before: calling Refresh_WF_Route procedure ');
      END IF;
      Refresh_WF_Route
      ( p_api_version         => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE        --
       ,p_validation_level    => p_validation_level
       ,p_debug               => FND_API.G_FALSE
       ,p_output_dir          => p_output_dir
       ,p_debug_filename      => p_debug_filename
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data
       ,p_change_id           => p_change_id
       ,p_status_code         => l_last_status_code
       ,p_wf_route_id         => NULL
       ,p_api_caller          => p_api_caller
       );
      IF g_debug_flag THEN
        Write_Debug('After: calling Refresh_WF_Route procedure: ' || l_return_status) ;
      END IF;

      -- Update the remaining columns of the phase row
      UPDATE eng_lifecycle_statuses
        SET start_date = null,
            completion_date = null,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_last_status_code
          AND active_flag = 'Y'
          AND rownum = 1;

    END IF;
    -- Finished checking and refreshing the ECO final implement phase

    -- Get the sequence number for the current phase of the change header
    SELECT sequence_number, status_code
      INTO l_curr_phase_sn, l_curr_status_code
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = ( SELECT status_code
                              FROM eng_engineering_changes
                              WHERE change_id = p_change_id)
        AND active_flag = 'Y'
        AND rownum = 1;

    -- Get the sequence number for the new phase of the change header
    SELECT sequence_number
      INTO l_new_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = p_status_code
        AND active_flag = 'Y'
        AND rownum = 1;

    -- Get the status_type of the new phase
    SELECT status_type
      INTO l_new_status_type
      FROM eng_change_statuses
      WHERE status_code = p_status_code
        AND rownum = 1;

    -- Get the max sequence number in the lifecycle
    SELECT max(sequence_number)
      INTO l_max_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y';

    IF g_debug_flag THEN
       Write_Debug('Before comparing l_new_phase_sn = l_curr_phase_sn');
       Write_Debug('l_new_phase_sn      : ' || l_new_phase_sn );
       Write_Debug('l_curr_phase_sn     : ' || l_curr_phase_sn );
    END IF;

    -- Sanity check to make sure the new phase is after the current phase
    IF l_new_phase_sn <= l_curr_phase_sn THEN
      FND_MESSAGE.Set_Name('ENG','ENG_OBJ_STATE_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    --
    -- Check for all open line/tasks complete_before_status_code
    -- R12B Change Line will support complete_before_status_code
    -- without required_flag
    --
    IF g_debug_flag THEN
       Write_Debug('Before checking open line/tasks'' complete_before_status_code');
    END IF;
    OPEN c_lines;
      LOOP
        FETCH c_lines
          INTO l_line_status_type,
               l_status_code,  -- line's complete_before_status_code
               l_required_flag,
               l_change_type_id,
               l_wf_status_code ;

        EXIT WHEN c_lines%NOTFOUND;


        -- R12B, In case of Line, assuming Required Flag is always NULL
        IF ( ( l_required_flag IS NULL OR l_required_flag = 'Y' )
             AND l_status_code IS NOT NULL
             AND l_line_status_type <> G_ENG_COMPLETED
             AND l_line_status_type <> G_ENG_IMPLEMENTED
             AND l_line_status_type <> G_ENG_CANCELLED )
        THEN

          IF g_debug_flag THEN
            Write_Debug('Found one open line or mandatory task... ');
            Write_Debug('  line status type = ' || l_line_status_type );
            Write_Debug('  l_wf_status_code = ' || l_wf_status_code );
            Write_Debug('  l_change_type_id = ' || l_change_type_id );

            IF ( l_required_flag IS NULL OR l_required_flag = 'Y' ) THEN
              Write_Debug('  line/task required flag is NULL or Y ');
            END IF;

          END IF;


          --
          -- R12B
          -- There is no additional logic required so far for the Line Status check
          --
          -- Get the sequence_number for line/task's complete_before_status_code
          SELECT sequence_number
            INTO l_phase_sn
            FROM eng_lifecycle_statuses
            WHERE entity_name = G_ENG_CHANGE
              AND entity_id1 = p_change_id
              AND status_code = l_status_code
              AND active_flag = 'Y'
              AND rownum = 1;

          -- If open line's complete_before_status_code is behind the new phase's
          -- status_code, raise error
          IF (l_phase_sn <= l_new_phase_sn ) THEN
            FND_MESSAGE.Set_Name('ENG','ENG_EXIST_LINE_COMP_BF');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;
      END LOOP;
    CLOSE c_lines;


    IF g_debug_flag THEN
       Write_Debug('After checking open line/tasks'' complete_before_status_code');
    END IF;


    -- Removing last sequence check on implement phase for bug 3446436
    -- Replacing it by simple implement phase type check
    IF (l_new_status_type = G_ENG_IMPLEMENTED) THEN
      -- New phase type is implementation
      IF g_debug_flag THEN
         Write_Debug('Branch: New phase type is implementation.');
      END IF;

      -- Check if the new phase is the last in the lifecycle definition
      -- and set the flag if so
      IF g_debug_flag THEN
         Write_Debug('Before comparing l_new_phase_sn = l_max_sn');
      END IF;
      IF (l_new_phase_sn = l_max_sn) THEN
        -- New phase is the last lifecycle phase
        IF g_debug_flag THEN
           Write_Debug('Branch: New phase is the last implement phase');
        END IF;
        -- Set the flag
        l_last_imp_flag := 'Y';
      END IF;

    -- Fix for bug 3731977
    -- Get the change header's cm type and base cm type
    SELECT eec.change_mgmt_type_code, ecot.base_change_mgmt_type_code, eec.approval_status_type
      INTO l_cm_type_code, l_base_cm_type_code, l_eco_approval_status
      FROM eng_engineering_changes eec,
           eng_change_order_types ecot
      WHERE eec.change_id = p_change_id
        AND ecot.change_order_type_id = eec.change_order_type_id;

      -- If there are still open lines or mandatory tasks, raise error message
      OPEN c_lines;
        LOOP
          FETCH c_lines INTO l_line_status_type,
                             l_status_code,
                             l_required_flag,
                             l_change_type_id,
                             l_wf_status_code ;

          EXIT WHEN c_lines%NOTFOUND;
          IF ( (l_required_flag IS NULL OR l_required_flag = 'Y')
               -- line: NULL; task: 'Y'
               AND l_line_status_type <> G_LINE_COMPLETED
               AND l_line_status_type <> G_ENG_IMPLEMENTED
               AND l_line_status_type <> G_LINE_CANCELLED
               --   R12.C Enhancement : Added following condition because NIRs can have different line statuses
               AND l_base_cm_type_code <> G_ENG_NEW_ITEM_REQ)
          THEN

            IF g_debug_flag THEN
              Write_Debug('Found one mandatory open line/task... ');
              Write_Debug('  line status type = ' || l_line_status_type );
              IF ( l_required_flag IS NULL OR l_required_flag = 'Y' ) THEN
                Write_Debug('  line required flag is NULL or Y' );
              END IF;
            END IF;

            --
            -- R12B
            -- There is no additional logic required so far for the Line Status check
            --
            -- In case of the wf triggered session
            IF ( p_api_caller = 'WF' ) THEN
              l_skip_promotion := 'Y';
            ELSE
              -- Stop and return error message
              FND_MESSAGE.Set_Name('ENG','ENG_EXIST_ACTIVE_LINES');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;
        END LOOP;
      CLOSE c_lines;
      IF g_debug_flag THEN
         Write_Debug('After open mandatory lines check');
      END IF;

    END IF; -- end of if (phase type = implementation)


    --Bug No:4767315
    --Skip implementation if no active or implemented revised items exist for a change order.
    open c_no_revisedItem;
    fetch c_no_revisedItem into l_skip;
    close c_no_revisedItem;



    -- Skip promoting CO to implement phase w/o active revised item
    IF (l_base_cm_type_code = G_ENG_ECO
        AND l_last_imp_flag = 'Y'
        AND l_skip = 'Y'
        )
    THEN
      -- Do not promote CO to implement phase in order to comply with the ERP behavior
      l_skip_promotion := 'Y';
      IF g_debug_flag THEN
        Write_Debug('Do not promote CO to implement phase to comply with ERP');
      END IF;
      -- Raise error message to the caller
      FND_MESSAGE.Set_Name('ENG','ENG_IMP_STOP_WO_ACT_REV_ITEM');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

    END IF;


    -- Fix for bug 4767315 - end
    -- Fix for Bug 3769329
    IF (l_base_cm_type_code = G_ENG_ECO
        AND l_last_imp_flag = 'Y'
        AND l_eco_approval_status = Eng_Workflow_Util.G_REJECTED
        )
    THEN
      -- Do not promote CO to implement phase in order to comply with the ERP approval status validation
      l_skip_promotion := 'Y';
      IF g_debug_flag THEN
        Write_Debug('Do not promote CO to implement phase to comply with ERP approval status validation');
      END IF;
      -- Raise error message to the caller
      FND_MESSAGE.Set_Name('ENG','ENG_IMP_STOP_APPR_REJECTED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

    END IF;
    -- End of fix for 3769329

    IF (l_skip_promotion = 'Y') THEN
      IF g_debug_flag THEN
         Write_Debug('Branch: skipping auto promotion');
      END IF;
    ELSE

      -- If the change header is of type ECO and the new phase is of type IMPLEMENTED,
      -- then do not update change header and revised items' status_code (phase)
      -- only save the new phase into the header's promote_status_code column
      -- actual promotion will be taken care of later in the concurrent program
      -- as a special case
      IF (l_base_cm_type_code = G_ENG_ECO AND l_last_imp_flag = 'Y') THEN
        l_imp_eco_flag := 'Y';
        l_skip_wf := 'Y';   -- fix for bug 3479509 design change of launching wf after concurrent program

        -- save new phase into header's promote_status_code column
        UPDATE eng_engineering_changes
          SET promote_status_code = p_status_code,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;

        IF g_debug_flag THEN
           Write_Debug('Skipped: Updating header and revised items to the new phase');
           Write_Debug('But: last <implement> phase saved into promote_status_code column');
        END IF;
        -- Fix for 3479509 by commenting out code
        -- Behavior changed to leaving completion_date of previous phase and
        -- start_date of implement phase blank in case of CO promotion to
        -- implement phase
        /*
        -- Update start_date of the implement phase
        UPDATE eng_lifecycle_statuses
          SET start_date = sysdate,
              completion_date = null,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE entity_name = G_ENG_CHANGE
            AND entity_id1 = p_change_id
            AND status_code = p_status_code
            AND active_flag = 'Y';
        */
        -- Fix for 3479509 - end

        -- If the CO's last implement type phase is already used, refresh its workflow id and status
        SELECT workflow_status, change_wf_route_id
        INTO l_wf_status, l_wf_route_id
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = p_status_code
        AND active_flag = 'Y'
        AND rownum = 1;


        IF (l_wf_route_id IS NOT NULL AND l_wf_status <> Eng_Workflow_Util.G_RT_NOT_STARTED)
        THEN

          -- Get a new workflow route_id
          Eng_Change_Route_Util.REFRESH_ROUTE
          ( X_NEW_ROUTE_ID   => l_new_route_id,
            P_ROUTE_ID       => l_wf_route_id,
            P_USER_ID        => l_fnd_user_id,
            P_API_CALLER     => p_api_caller
          );

          -- refresh imp phase row
          UPDATE eng_lifecycle_statuses
            SET change_wf_route_id = l_new_route_id,
                workflow_status = Eng_Workflow_Util.G_RT_NOT_STARTED,
                last_update_date = sysdate,
                last_updated_by = l_fnd_user_id,
                last_update_login = l_fnd_login_id
            WHERE entity_name = G_ENG_CHANGE
              AND entity_id1 = p_change_id
              AND status_code = p_status_code
              AND active_flag = 'Y';

        END IF;

        --
        -- Bug 4967289 Fix
        -- Call ENG_ATTACHMENT_IMPLEMENTATION.Validate_floating_version
        --Removed this code from here as it is not required here Attachment impl is taking care of it.
       /* IF g_debug_flag THEN
            Write_Debug('Calling ENG_ATTACHMENT_IMPLEMENTATION.Validate_floating_version ');
        END IF;

        ENG_ATTACHMENT_IMPLEMENTATION.Validate_floating_version
        ( p_api_version          => 1.0
         ,x_return_status        =>    l_return_status
         ,x_msg_count            =>    l_msg_count
         ,x_msg_data             =>    l_msg_data
         ,p_change_id            =>    p_change_id
         ,p_rev_item_seq_id      =>    NULL
        );

        IF g_debug_flag THEN
            Write_Debug('After: calling ENG_ATTACHMENT_IMPLEMENTATION.Validate_floating_version API: ' || l_return_status) ;
        END IF;*/

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ECO_UTIL.Propagate_ECO');
            --#FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- End of Bug4967289 Fix

      ELSE
        -- Normal phase promotion
        -- Complete the current phase
        UPDATE eng_lifecycle_statuses
          SET completion_date = sysdate,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE entity_name = G_ENG_CHANGE
            AND entity_id1 = p_change_id
            AND status_code = l_curr_status_code
            AND active_flag = 'Y';
        IF g_debug_flag THEN
          Write_Debug('After updating eng_lifecycle_statuses.completion_date.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;
        -- Sanity check, only one record can qualify the condition
        IF SQL%ROWCOUNT <> 1 THEN
          FND_MESSAGE.Set_Name('ENG','ENG_NOT_EXACTLY_ONE_RECORD');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF g_debug_flag THEN
           Write_Debug('After: Completing the current phase and promote to the next phase');
        END IF;

        -- Promote change header to the new phase
        UPDATE eng_engineering_changes
          SET status_code = p_status_code,
              promote_status_code = null,
              status_type = l_new_status_type,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_engineering_changes.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;

        IF g_debug_flag THEN
          Write_Debug('Before updateing revised items.');
        END IF;
        IF ( p_update_ri_flag = 'Y' ) THEN
          IF g_debug_flag THEN
            Write_Debug('In updateing revised items.');
          END IF;

          -- Promote revised items to the new phase
          OPEN c_revItems;
          LOOP
            FETCH c_revItems INTO l_ri_status_code;
            EXIT WHEN c_revItems%NOTFOUND;

            IF g_debug_flag THEN
              Write_Debug('In Cursor c_revItems to update revised items.');
            END IF;

            -- Get the status_type of the revised item phase
            SELECT status_type
              INTO l_ri_status_type
              FROM eng_change_statuses
              WHERE status_code = l_ri_status_code
                AND rownum = 1;

            -- Update only those which are open
            -- and whose phase is behind the new promoting phase
            IF (l_ri_status_type <> G_ENG_IMPLEMENTED
                AND l_ri_status_type <> G_ENG_CANCELLED) THEN

              -- Get the sequence_number of the revised item phase
              -- Note: moved this query inside this IF block because cancel
              --       status is not in the regular lifecycle phase definitions
              SELECT sequence_number
                INTO l_ri_phase_sn
                FROM eng_lifecycle_statuses
                WHERE entity_name = G_ENG_CHANGE
                  AND entity_id1 = p_change_id
                  AND status_code = l_ri_status_code
                  AND active_flag = 'Y'
                  AND rownum = 1;

              -- Only promote those revised items whose phase are lower than
              -- the new header promotion phase
              IF (l_ri_phase_sn < l_new_phase_sn) THEN
                UPDATE eng_revised_items
                  SET status_code = p_status_code,
                      status_type = l_new_status_type,
                      last_update_date = sysdate,
                      last_updated_by = l_fnd_user_id,
                      last_update_login = l_fnd_login_id
                  WHERE CURRENT OF c_revItems;
                IF g_debug_flag THEN
                  Write_Debug('After updating eng_revised_items.');
                  Write_Debug('  Row count = ' || SQL%ROWCOUNT);
                END IF;
              END IF; -- ri_phase < new_header_phase
            END IF; -- not imp or cancelled

          END LOOP;
          CLOSE c_revItems;
        END IF; -- p_update_ri_flag = 'Y'

        IF g_debug_flag THEN
           Write_Debug('Done: Updating header and revised items to the new phase');
        END IF;

        -- Update the new phase's start_date
        UPDATE eng_lifecycle_statuses
          SET start_date = sysdate,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE entity_name = G_ENG_CHANGE
            AND entity_id1 = p_change_id
            AND status_code = p_status_code
            AND active_flag = 'Y';
        IF g_debug_flag THEN
          Write_Debug('After updating eng_lifecycle_statuses.start_date.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;

      END IF;


      -- auto propagate if necessary
      l_row_cnt := 0;
      OPEN c_orgProp;
        LOOP
          FETCH c_orgProp
            INTO l_auto_prop_flag,
                 l_change_notice,
                 l_hierarchy_name,
                 l_org_name;
          EXIT WHEN c_orgProp%NOTFOUND;

          l_row_cnt := l_row_cnt + 1;
          -- verify the uniqueness of the record
          IF (l_row_cnt > 1) THEN
            IF g_debug_flag THEN
              Write_Debug('Error: more than one propagation policy is found');
            END IF;
          END IF;

          IF g_debug_flag THEN
            Write_Debug('one record for propagation policy is found');
            Write_Debug('l_auto_prop_flag         : ' || l_auto_prop_flag );
            Write_Debug('l_change_notice          : ' || l_change_notice );
            Write_Debug('l_hierarchy_name         : ' || l_hierarchy_name );
            Write_Debug('l_org_name               : ' || l_org_name );
          END IF;

          IF ( l_auto_prop_flag = 'Y') THEN
            IF g_debug_flag THEN
              Write_Debug('which needs auto propagation');
            END IF;

            ENG_ECO_UTIL.Propagate_ECO
            (
              p_api_version          =>    1.0
             ,p_init_msg_list        =>    FND_API.G_FALSE
             ,p_commit               =>    FND_API.G_FALSE
             ,p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL
             ,p_debug                =>    p_debug --FND_API.G_FALSE
             ,p_output_dir           =>    p_output_dir
             ,p_debug_filename       =>    NULL  --p_debug_filename
             ,x_return_status        =>    l_return_status
             ,x_msg_count            =>    l_msg_count
             ,x_msg_data             =>    l_msg_data
             ,p_change_id            =>    p_change_id
             ,p_change_notice        =>    l_change_notice
             ,p_hierarchy_name       =>    l_hierarchy_name
             ,p_org_name             =>    l_org_name
             ,x_request_id           =>    l_request_id
            );

            IF g_debug_flag THEN
              Write_Debug('After: calling propagate_eco API: ' || l_return_status) ;
            END IF;

            IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
              --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ECO_UTIL.Propagate_ECO');
              --#FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF g_debug_flag THEN
              Write_Debug('Successful: calling propagate_eco API');
              Write_Debug('l_request_id       : ' || l_request_id );
            END IF;

            IF g_debug_flag THEN
               Write_Debug('Before: saving action log');
            END IF;
            l_action_id := 0;
            -- create new action log
            -- Bug Fix: 3547844
            -- In case of Auto-Propgation Action Log
            -- Who column is Workflow
            ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
            ( p_api_version           => 1.0
            , p_init_msg_list         => FND_API.G_FALSE        --
            , p_commit                => FND_API.G_FALSE        --
            , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
            , p_debug                 => p_debug --FND_API.G_FALSE
            , p_output_dir            => p_output_dir
            , p_debug_filename        => NULL
            , x_return_status         => l_return_status
            , x_msg_count             => l_msg_count
            , x_msg_data              => l_msg_data
            , p_action_type           => ENG_CHANGE_ACTIONS_UTIL.G_ACT_PROPAGATE
            , p_object_name           => G_ENG_CHANGE
            , p_object_id1            => p_change_id
            , p_object_id2            => NULL
            , p_object_id3            => NULL
            , p_object_id4            => NULL
            , p_object_id5            => NULL
            , p_parent_action_id      => -1
            , p_status_code           => NULL
            , p_action_date           => SYSDATE
            , p_change_description    => NULL
            , p_user_id               => G_ENG_WF_USER_ID
            , p_api_caller            => 'WF'
            , x_change_action_id      => l_action_id
            );


            IF g_debug_flag THEN
               Write_Debug('After: saving action log: ' || l_return_status) ;
               Write_Debug('l_action_id       : ' || l_action_id );
            END IF;

            IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
            THEN
              x_return_status := l_return_status;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
              --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
              --#FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF g_debug_flag THEN
               Write_Debug('Successful: saving action log');
            END IF;

          ELSE
            IF g_debug_flag THEN
              Write_Debug('which does not need auto propagation');
            END IF;
          END IF;

        END LOOP;
      CLOSE c_orgProp;
      IF g_debug_flag THEN
         Write_Debug('After checking propagation policy');
      END IF;


      -- R12B
      -- In case of Document LC Change Object, call ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase
      -- to validate and sync Document LC Phase
      l_doc_lc_object_flag := ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle
                             ( p_change_id => p_change_id
                             , p_base_change_mgmt_type_code => l_base_cm_type_code
                             ) ;

      IF (l_doc_lc_object_flag)
      THEN
          IF g_debug_flag THEN
             Write_Debug('Before: calling ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase');
             Write_Debug('  p_change_id =   ' || p_change_id);
             Write_Debug('  p_status_code = ' || p_status_code);
             Write_Debug('  p_action_type =   ' || G_ENG_PROMOTE);
          END IF;

          ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase
          ( p_api_version         => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,p_commit              => FND_API.G_FALSE
           ,p_validation_level    => p_validation_level
           ,p_debug               => FND_API.G_FALSE
           ,p_output_dir          => p_output_dir
           ,p_debug_filename      => p_debug_filename
           ,x_return_status       => l_return_status
           ,x_msg_count           => l_msg_count
           ,x_msg_data            => l_msg_data
           ,p_change_id           => p_change_id
           ,p_lc_phase_code       => p_status_code
           ,p_action_type         =>  G_ENG_PROMOTE
           ,p_api_caller          => p_api_caller
          ) ;


          IF g_debug_flag THEN
             Write_Debug('After: calling ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase: ' || l_return_status) ;
          END IF;

          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF g_debug_flag THEN
             Write_Debug('Successful: ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase');
          END IF;

      END IF ; -- if ( Change Object is Documet LC Object)
      --
      -- End of R12B Document LC Change Object Enh Change
      --



      -- Start workflow for new phase if necessary
      Start_WF_OnlyIf_Necessary
      ( p_api_version       => 1.0
       ,p_init_msg_list     => FND_API.G_FALSE
       ,p_commit            => FND_API.G_FALSE
       ,p_validation_level  => p_validation_level
       ,p_debug             => FND_API.G_FALSE
       ,p_output_dir        => p_output_dir
       ,p_debug_filename    => p_debug_filename
       ,x_return_status     => l_return_status
       ,x_msg_count         => l_msg_count
       ,x_msg_data          => l_msg_data
       ,p_change_id         => p_change_id
       ,p_status_code       => p_status_code
       ,p_status_type       => l_new_status_type
       ,p_sequence_number   => l_new_phase_sn
       ,p_imp_eco_flag      => l_imp_eco_flag
       ,p_api_caller        => p_api_caller
       ,p_action_type       => G_ENG_PROMOTE
       ,p_comment           => p_comment        -- only used for co promote-to-implement action
       ,p_skip_wf           => l_skip_wf        -- fix for bug 3479509 design change of launching wf after concurrent program
      );

      IF g_debug_flag THEN
         Write_Debug('After call to procedure Start_WF_OnlyIf_Necessary');
      END IF;

      IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
        --#FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      --
      -- R12B
      -- Change Line and Line Workflow Enhancement
      -- Kick off Change Line Workflow if Start After Status is defined in
      -- Change Line and the Change Line has a Workflow "Not Started"
      --
      --
      -- The associated Line Workflow will be automatically started once
      -- the Header Workflow Status reaches the status specified in 'Start After Status'
      -- if the Line Workflow is still Not Started.
      --
      -- Start workflow for new phase if necessary
      IF (NOT l_doc_lc_object_flag AND l_skip_wf <> 'Y')
      THEN

          IF g_debug_flag THEN
             Write_Debug('calling procedure Start_Line_Workflow');
          END IF;

          Start_Line_Workflow
          ( p_api_version           => 1.0
           ,p_init_msg_list         => FND_API.G_FALSE
           ,p_commit                => FND_API.G_FALSE
           ,p_validation_level      => p_validation_level
           ,p_debug                 => FND_API.G_FALSE
           ,p_output_dir            => p_output_dir
           ,p_debug_filename        => p_debug_filename
           ,x_return_status         => l_return_status
           ,x_msg_count             => l_msg_count
           ,x_msg_data              => l_msg_data
           ,p_change_id             => p_change_id
           ,p_new_status_code       => p_status_code
           ,p_cur_status_code       => l_curr_status_code
           ,p_api_caller            => p_api_caller
           ,p_action_type           => G_ENG_PROMOTE
          );

          IF g_debug_flag THEN
             Write_Debug('After call to procedure Start_Line_Workflow');
          END IF;

          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF ;
      --
      -- End of R12B Change Line and Line Workflow Enhancement
      --

    END IF; -- if (p_skip_promotion='Y')


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Promote_Header');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Promote_Header;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Promote_Header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Promote_Header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Promote_Header;

  -- Internal procedure for demotion of change header (inc. revItems)
  -- Note that even though this procedure shares the same argument list
  -- as Promote_Header procedure, the internal logic is quite different,
  -- so it is written as a seperate procedure for easier understanding.
  PROCEDURE Demote_Header
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
   ,x_sfa_line_items_exists     OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Demote_Header';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_curr_appr_status   eng_engineering_changes.approval_status_type%TYPE;

    l_is_imp_phase_used  VARCHAR2(1) := 'F';

    l_last_status_type   NUMBER;
    l_last_status_code   NUMBER;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_curr_phase_sn      eng_lifecycle_statuses.sequence_number%TYPE;
    l_new_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;

    l_new_status_type    eng_change_statuses.status_type%TYPE;

    l_change_mgmt_type_code eng_engineering_changes.change_mgmt_type_code%TYPE;

    -- Cursor to get all lifecycle phases between (inclusive) [demotionStatus, currentStatus]
    CURSOR c_lcStatuses IS
      SELECT *
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y'
          AND sequence_number >= l_new_phase_sn
          AND sequence_number <= l_curr_phase_sn
      FOR UPDATE;

    l_temp_status_type   NUMBER;
    l_has_approval_phase VARCHAR2(1) := 'F';  -- in between curr and demotion phases

    -- Cursor to get all lifecycle phases between (inclusive) [demotionStatus, maxStatus]
    CURSOR c_lcStatusesToMax IS
      SELECT *
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y'
          AND sequence_number >= l_new_phase_sn
      FOR UPDATE;
    l_lcStatuses_row     eng_lifecycle_statuses%ROWTYPE;
    l_old_iter_num       eng_lifecycle_statuses.iteration_number%TYPE := -1;
    l_old_row_id         NUMBER;
    l_new_row_id         NUMBER;
    l_new_route_id       NUMBER;

    CURSOR c_statusProp IS
      SELECT *
        FROM eng_status_properties
        WHERE change_lifecycle_status_id = l_old_row_id
      FOR UPDATE;
    l_status_prop_row   eng_status_properties%ROWTYPE;

    CURSOR c_revItems IS
      SELECT status_code
        FROM eng_revised_items
        WHERE change_id = p_change_id
      FOR UPDATE;
    l_ri_status_code      eng_change_lines.status_code%TYPE;
    -- revItem's status_code's sequence_number
    l_ri_phase_sn         eng_lifecycle_statuses.sequence_number%TYPE;
    l_ri_status_type     eng_change_statuses.status_type%TYPE;


    l_base_cm_type_code  VARCHAR2(30) ;
    l_doc_lc_object_flag BOOLEAN := FALSE ;
    l_old_status_code NUMBER;
    l_old_status_type NUMBER;

    -- Bug 6695079 Start
    l_temp_flag           VARCHAR2(1) := 'Y';
    l_obj_id1		  NUMBER := 0;

    	CURSOR c_lifecyc IS
	   SELECT change_wf_route_id
	   FROM eng_lifecycle_statuses
	   WHERE entity_name = G_ENG_CHANGE
	    AND entity_id1 = p_change_id
	    AND active_flag = 'Y'
	    and change_wf_route_id is not null;
    -- Bug 6695079 End

  BEGIN
select status_type, status_code into l_old_status_code, l_old_status_type from eng_engineering_changes where change_id = p_change_id;
    -- Standard Start of API savepoint
    SAVEPOINT Demote_Header;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Demote_Header log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------
		-- Bug 6695079 Start
		For lifecyc in c_lifecyc
		loop
				select template_flag, object_id1
				into l_temp_flag, l_obj_id1
				from eng_change_routes
				where route_id = lifecyc.change_wf_route_id;

			if ((l_temp_flag = 'N' or l_temp_flag = 'H') and l_obj_id1 = 0) then
			      FND_MESSAGE.Set_Name('ENG','ENG_ROUTE_APPLY_NO_TEMP');
			      FND_MSG_PUB.Add;
			      RAISE FND_API.G_EXC_ERROR;
			end if;
		end loop;
	 -- Bug 6695079 end
    -- Get the current header approval status
    SELECT approval_status_type
      INTO l_curr_appr_status
      FROM eng_engineering_changes
      where change_id = p_change_id;

    -- First check if the header is CO and last implement phase has been used
    Is_CO_Last_Imp_Phase_Used
    ( p_change_id          => p_change_id
     ,x_is_used            => l_is_imp_phase_used
     ,x_last_status_type   => l_last_status_type
     ,x_last_status_code   => l_last_status_code
     );

    -- If so, adjust header phase to implemented phase before demotion
    IF ( l_is_imp_phase_used = 'T' ) THEN
      UPDATE eng_engineering_changes
        SET status_type = l_last_status_type,
            status_code = l_last_status_code,
            promote_status_code = NULL
        WHERE change_id = p_change_id;

    END IF;

    -- Get the sequence number for the current phase of the change header
    SELECT sequence_number
      INTO l_curr_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND status_code = ( SELECT status_code
                              FROM eng_engineering_changes
                              WHERE change_id = p_change_id)
        AND rownum = 1;

    -- Get the sequence number for the new phase of the change header
    SELECT sequence_number
      INTO l_new_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = p_status_code
        AND active_flag = 'Y'
        AND rownum = 1;

    IF g_debug_flag THEN
       Write_Debug('Before comparing l_new_phase_sn >= l_curr_phase_sn');
    END IF;

    -- Sanity check to make sure the new phase is after the current phase
    IF ( l_new_phase_sn >= l_curr_phase_sn ) THEN
      FND_MESSAGE.Set_Name('ENG','ENG_OBJ_STATE_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Finish the current phase before demotion
    UPDATE eng_lifecycle_statuses
      SET completion_date = sysdate,
          last_update_date = sysdate,
          last_updated_by = l_fnd_user_id,
          last_update_login = l_fnd_login_id
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND status_code = ( SELECT status_code
                              FROM eng_engineering_changes
                              WHERE change_id = p_change_id)
        AND sequence_number = l_curr_phase_sn
        AND rownum = 1;
    IF g_debug_flag THEN
      Write_Debug('After updating eng_lifecycle_statuses.completion_date.');
      Write_Debug('  Row count = ' || SQL%ROWCOUNT);
    END IF;


    -- obsolete all the lifecycle phases in the range of [demotionStatus, currStatus]
    OPEN c_lcStatuses;
      LOOP
        FETCH c_lcStatuses INTO l_lcStatuses_row;
        EXIT WHEN c_lcStatuses%NOTFOUND;

        -- l_old_iter_num initialization and sanity check
        /*
        IF (l_old_iter_num = -1) THEN
          -- make sure the original iteration number is not null
          IF (l_lcStatuses_row.iteration_number IS NULL) THEN
            FND_MESSAGE.Set_Name('ENG','ENG_OBJECT_CANT_BE_NULL');
            FND_MESSAGE.Set_Token('OBJECT_NAME', 'ITERATION_NUMBER');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_old_iter_num := l_lcStatuses_row.iteration_number;
        ELSE
          IF ( l_lcStatuses_row.iteration_number <> l_old_iter_num ) THEN
            -- Stop and return error message
            IF g_debug_flag THEN
              Write_Debug('Error: inconsistent lifecycle phase sequence numbers');
              Write_Debug('l_lcStatuses_row.iteration_number : '|| l_lcStatuses_row.iteration_number);
              Write_Debug('l_old_iter_num     : ' || l_old_iter_num );
            END IF;
            FND_MESSAGE.Set_Name('ENG','ENG_SN_INCONSISTENT');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
        */

        -- Check existence of approval phase between curr and demotion phase
        SELECT status_type
          INTO l_temp_status_type
          FROM eng_change_statuses
          WHERE status_code = l_lcStatuses_row.STATUS_CODE;
        IF (l_temp_status_type = G_ENG_APPROVED)
        THEN
          l_has_approval_phase := 'T';
        END IF;

        -- Obsolete (but not delete) the old phase row
        UPDATE eng_lifecycle_statuses
          SET active_flag = 'N',
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE CURRENT OF c_lcStatuses;

        -- First get the new unique index id value for the new row (also save the old id)
        l_old_row_id := l_lcStatuses_row.change_lifecycle_status_id;
        SELECT eng_lifecycle_statuses_s.nextval
          INTO l_new_row_id
          FROM DUAL;

        -- Secondly get the new wf_route_id if needed
        IF (l_lcStatuses_row.change_wf_route_id IS NULL) THEN
          l_new_route_id := NULL;
        ELSE
          -- Get a new workflow route_id
          Eng_Change_Route_Util.REFRESH_ROUTE
          ( X_NEW_ROUTE_ID   => l_new_route_id,
            P_ROUTE_ID       => l_lcStatuses_row.change_wf_route_id,
            P_USER_ID        => l_fnd_user_id,
            P_API_CALLER     => p_api_caller
          );
        END IF;

        -- Prepare for the new phase row
        l_lcStatuses_row.change_lifecycle_status_id := l_new_row_id;
        l_lcStatuses_row.change_wf_route_id := l_new_route_id;
        l_lcStatuses_row.active_flag := 'Y';
        l_lcStatuses_row.creation_date := sysdate;
        l_lcStatuses_row.created_by := l_fnd_user_id;
        l_lcStatuses_row.last_update_date := sysdate;
        l_lcStatuses_row.last_updated_by := l_fnd_user_id;
        l_lcStatuses_row.last_update_login := l_fnd_login_id;
        -- populate wf_status based upon wf availibility of the phase
        IF ( l_lcStatuses_row.change_wf_route_id IS NULL ) THEN
          l_lcStatuses_row.workflow_status := null;
        ELSE
          l_lcStatuses_row.workflow_status := Eng_Workflow_Util.G_RT_NOT_STARTED;
        END IF;
        -- populate start_date only if it is the newly demoted phase
        IF ( l_lcStatuses_row.status_code = p_status_code ) THEN
          l_lcStatuses_row.start_date := sysdate;
        ELSE
        l_lcStatuses_row.start_date := null;
        END IF;
        -- populate completion_date to null for all new phase rows
        l_lcStatuses_row.completion_date := null;


        -- Before insertion, update all the corresponding rows in eng_status_properties table
        OPEN c_statusProp;
          LOOP
            FETCH c_statusProp INTO l_status_prop_row;
            EXIT WHEN c_statusProp%NOTFOUND;
              UPDATE eng_status_properties
                SET change_lifecycle_status_id = l_new_row_id,
                    last_update_date = sysdate,
                    last_updated_by = l_fnd_user_id,
                    last_update_login = l_fnd_login_id
                WHERE current of c_statusProp;
            END LOOP;
        CLOSE c_statusProp;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_status_properties row''s change_lifecycle_status_id');
        END IF;

        -- Insert the new phase row
        /* Only Oracle 9.2+ supports this directly row insertion feature
        INSERT INTO eng_lifecycle_statuses
          VALUES l_lcStatuses_row;
        */
        INSERT INTO eng_lifecycle_statuses
                    ( CHANGE_LIFECYCLE_STATUS_ID,
                      ENTITY_NAME,
                      ENTITY_ID1,
                      ENTITY_ID2,
                      ENTITY_ID3,
                      ENTITY_ID4,
                      ENTITY_ID5,
                      SEQUENCE_NUMBER,
                      STATUS_CODE,
                      START_DATE,
                      COMPLETION_DATE,
                      CHANGE_WF_ROUTE_ID,
                      CHANGE_WF_ROUTE_TEMPLATE_ID,
                      AUTO_PROMOTE_STATUS,
                      AUTO_DEMOTE_STATUS,
                      WORKFLOW_STATUS,
                      CHANGE_EDITABLE_FLAG,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      ITERATION_NUMBER,
                      ACTIVE_FLAG,
                      WF_SIG_POLICY )
          VALUES
                    ( l_lcStatuses_row.CHANGE_LIFECYCLE_STATUS_ID,
                      l_lcStatuses_row.ENTITY_NAME,
                      l_lcStatuses_row.ENTITY_ID1,
                      l_lcStatuses_row.ENTITY_ID2,
                      l_lcStatuses_row.ENTITY_ID3,
                      l_lcStatuses_row.ENTITY_ID4,
                      l_lcStatuses_row.ENTITY_ID5,
                      l_lcStatuses_row.SEQUENCE_NUMBER,
                      l_lcStatuses_row.STATUS_CODE,
                      l_lcStatuses_row.START_DATE,
                      l_lcStatuses_row.COMPLETION_DATE,
                      l_lcStatuses_row.CHANGE_WF_ROUTE_ID,
                      l_lcStatuses_row.CHANGE_WF_ROUTE_TEMPLATE_ID,
                      l_lcStatuses_row.AUTO_PROMOTE_STATUS,
                      l_lcStatuses_row.AUTO_DEMOTE_STATUS,
                      l_lcStatuses_row.WORKFLOW_STATUS,
                      l_lcStatuses_row.CHANGE_EDITABLE_FLAG,
                      l_lcStatuses_row.CREATION_DATE,
                      l_lcStatuses_row.CREATED_BY,
                      l_lcStatuses_row.LAST_UPDATE_DATE,
                      l_lcStatuses_row.LAST_UPDATED_BY,
                      l_lcStatuses_row.LAST_UPDATE_LOGIN,
                      l_lcStatuses_row.ITERATION_NUMBER,
                      l_lcStatuses_row.ACTIVE_FLAG,
                      l_lcStatuses_row.WF_SIG_POLICY );

      END LOOP;
    CLOSE c_lcStatuses;

    -- Update all phase rows from the demotion phase all the way to the last phase
    OPEN c_lcStatusesToMax;
      LOOP
        FETCH c_lcStatusesToMax INTO l_lcStatuses_row;
        EXIT WHEN c_lcStatusesToMax%NOTFOUND;

        -- make sure the original iteration number is not null
        IF (l_lcStatuses_row.iteration_number IS NULL) THEN
          FND_MESSAGE.Set_Name('ENG','ENG_OBJECT_CANT_BE_NULL');
          FND_MESSAGE.Set_Token('OBJECT_NAME', 'ITERATION_NUMBER');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_old_iter_num := l_lcStatuses_row.iteration_number;

        -- Increment sequence number of the active phases
        UPDATE eng_lifecycle_statuses
          SET iteration_number = l_old_iter_num + 1,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE CURRENT OF c_lcStatusesToMax;

      END LOOP;
    CLOSE c_lcStatusesToMax;

    -- Get the status_type of the new phase
    SELECT status_type
      INTO l_new_status_type
      FROM eng_change_statuses
      WHERE status_code = p_status_code;

    -- Demote change header record
    UPDATE eng_engineering_changes
      SET status_code = p_status_code,
          promote_status_code = null,
          status_type = l_new_status_type,
          last_update_date = sysdate,
          last_updated_by = l_fnd_user_id,
          last_update_login = l_fnd_login_id
      WHERE change_id = p_change_id;
    IF g_debug_flag THEN
      Write_Debug('After updating eng_engineering_changes.');
      Write_Debug('  Row count = ' || SQL%ROWCOUNT);
    END IF;

    -- Fix for bug 3775865: Reset header approval status
    IF (l_has_approval_phase = 'T' AND l_curr_appr_status <> G_ENG_NOT_SUBMITTED)
    THEN

      IF g_debug_flag THEN
        Write_Debug('Before: calling Update_Header_Appr_Status');
      END IF;

      -- Update change header approval status
      -- Launch header approval status change workflow
      Update_Header_Appr_Status
      (
        p_api_version               =>  1.0
       ,p_init_msg_list             =>  FND_API.G_FALSE
       ,p_commit                    =>  FND_API.G_FALSE
       ,p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL
       ,p_debug                     =>  FND_API.G_FALSE
       ,p_output_dir                =>  p_output_dir
       ,p_debug_filename            =>  p_debug_filename
       ,x_return_status             =>  l_return_status
       ,x_msg_count                 =>  l_msg_count
       ,x_msg_data                  =>  l_msg_data
       ,p_change_id                 =>  p_change_id
       ,p_status_code               =>  p_status_code
       ,p_appr_status               =>  G_ENG_NOT_SUBMITTED
       ,p_route_status              =>  NULL
       ,p_api_caller                =>  p_api_caller
       ,p_bypass                    =>  'Y'
       ,x_sfa_line_items_exists     => x_sfa_line_items_exists
      );

      IF g_debug_flag THEN
        Write_Debug('After: calling Update_Header_Appr_Status: ' || l_return_status) ;
      END IF;


      IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
      THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF g_debug_flag THEN
        Write_Debug('After: calling Update_Header_Appr_Status');
      END IF;

    END IF;
    -- Fix for bug 3775865 - end

    IF ( p_update_ri_flag = 'Y' ) THEN
      -- Demote revised items to the new phase
      OPEN c_revItems;
      LOOP
        FETCH c_revItems INTO l_ri_status_code;
        EXIT WHEN c_revItems%NOTFOUND;

        IF g_debug_flag THEN
          Write_Debug('In Cursor c_revItems to update revised items.');
        END IF;

        -- Get the status_type of the revised item phase
        SELECT status_type
          INTO l_ri_status_type
          FROM eng_change_statuses
          WHERE status_code = l_ri_status_code
            AND rownum = 1;

        IF (l_ri_status_type <> G_ENG_IMPLEMENTED
            AND l_ri_status_type <> G_ENG_CANCELLED) THEN

          -- Get the sequence_number of the revised item phase
          -- Note: moved this query inside this IF block because cancel
          --       status is not in the regular lifecycle phase definitions
          SELECT sequence_number
            INTO l_ri_phase_sn
            FROM eng_lifecycle_statuses
            WHERE entity_name = G_ENG_CHANGE
              AND entity_id1 = p_change_id
              AND status_code = l_ri_status_code
              AND active_flag = 'Y'
              AND rownum = 1;

          -- Update only those which are active
          -- and whose phase is ahead of the new demotion phase
          IF (l_ri_phase_sn > l_new_phase_sn) THEN
            UPDATE eng_revised_items
              SET status_code = p_status_code,
                  status_type = l_new_status_type,
                  last_update_date = sysdate,
                  last_updated_by = l_fnd_user_id,
                  last_update_login = l_fnd_login_id
              WHERE CURRENT OF c_revItems;
          END IF;
        END IF; -- revItem not implmented or cancelled
      END LOOP;
      CLOSE c_revItems;
    END IF; -- p_update_ri_flag = 'Y'


    -- R12B
    -- In case of Document LC Change Object, call ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase
    -- to validate and sync Document LC Phase
    l_doc_lc_object_flag := ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle
                           ( p_change_id => p_change_id
                           , p_base_change_mgmt_type_code => l_base_cm_type_code
                           )  ;

    IF (l_doc_lc_object_flag)
    THEN
        IF g_debug_flag THEN
           Write_Debug('Before: calling ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase');
           Write_Debug('  p_change_id =   ' || p_change_id);
           Write_Debug('  p_base_change_mgmt_type_code =   ' || l_base_cm_type_code);
           Write_Debug('  p_status_code = ' || p_status_code);
           Write_Debug('  p_action_type =   ' || G_ENG_DEMOTE);
        END IF;

        ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase
        ( p_api_version         => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => p_validation_level
         ,p_debug               => FND_API.G_FALSE
         ,p_output_dir          => p_output_dir
         ,p_debug_filename      => p_debug_filename
         ,x_return_status       => l_return_status
         ,x_msg_count           => l_msg_count
         ,x_msg_data            => l_msg_data
         ,p_change_id           => p_change_id
         ,p_lc_phase_code       => p_status_code
         ,p_action_type         => G_ENG_DEMOTE
         ,p_api_caller          => p_api_caller
        ) ;


        IF g_debug_flag THEN
           Write_Debug('After: calling ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase: ' || l_return_status) ;
        END IF;

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF g_debug_flag THEN
           Write_Debug('Successful: ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase');
        END IF;

    END IF ; -- if ( Change Object is Documet LC Object)



    -- Start workflow for new phase if necessary
    Start_WF_OnlyIf_Necessary
    ( p_api_version       => 1.0
     ,p_init_msg_list     => FND_API.G_FALSE
     ,p_commit            => FND_API.G_FALSE
     ,p_validation_level  => p_validation_level
     ,p_debug             => FND_API.G_FALSE
     ,p_output_dir        => p_output_dir
     ,p_debug_filename    => p_debug_filename
     ,x_return_status     => l_return_status
     ,x_msg_count         => l_msg_count
     ,x_msg_data          => l_msg_data
     ,p_change_id         => p_change_id
     ,p_status_code       => p_status_code
     ,p_status_type       => l_new_status_type
     ,p_sequence_number   => l_new_phase_sn
     --,p_imp_eco_flag      => 'N'
     ,p_api_caller        => p_api_caller
     ,p_action_type       => G_ENG_DEMOTE
    );


      IF g_debug_flag THEN
        Write_Debug('After: calling Start_WF_OnlyIf_Necessary: ' || l_return_status) ;
      END IF;


    IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
      --#FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Demote_Header');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Demote_Header;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Demote_Header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Demote_Header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Demote_Header;

  PROCEDURE Demote_Header
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  )
  IS
     l_sfa_line_items_exists VARCHAR2(1);
  BEGIN
     Demote_Header
             ( p_api_version        => p_api_version
              ,p_init_msg_list      => p_init_msg_list
              ,p_commit             => p_commit
              ,p_validation_level   => p_validation_level
              ,p_debug              => p_debug
              ,p_output_dir         => p_output_dir
              ,p_debug_filename     => p_debug_filename
              ,x_return_status      => x_return_status
              ,x_msg_count          => x_msg_count
              ,x_msg_data           => x_msg_data
              ,p_change_id          => p_change_id
              ,p_status_code        => p_status_code
              ,p_update_ri_flag     => p_update_ri_flag
              ,p_api_caller         => p_api_caller
              ,x_sfa_line_items_exists => l_sfa_line_items_exists
             );
  END Demote_Header;

  -- Internal procedure for promotion of a revised item
  PROCEDURE Promote_Revised_Item
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER                             -- revised item sequence id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Promote_Revised_Item';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_ri_phase_sn        eng_lifecycle_statuses.sequence_number%TYPE;
    l_new_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;
    l_max_sn             eng_lifecycle_statuses.sequence_number%TYPE;
    l_phase_sn           eng_lifecycle_statuses.sequence_number%TYPE;

    l_last_imp_flag       VARCHAR2(1) := 'N';

    l_new_status_type    eng_change_statuses.status_type%TYPE;
    l_ri_status_code     eng_change_lines.status_code%TYPE;
    l_ri_status_type     eng_change_statuses.status_type%TYPE;

    l_chg_notice         eng_engineering_changes.change_notice%TYPE;
    l_org_id             eng_engineering_changes.organization_id%TYPE;
    l_request_id         NUMBER;

    l_row_cnt            NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Promote_Revised_Item;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Promote_Revised_Item log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_object_id2        : ' || p_object_id2 );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------

    -- Get the sequence number for the current phase of the revised item
    SELECT sequence_number, status_code
      INTO l_ri_phase_sn, l_ri_status_code
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = ( SELECT status_code
                              FROM eng_revised_items
                              WHERE revised_item_sequence_id = p_object_id2)
        AND active_flag = 'Y'
        AND rownum = 1;

    -- Get the sequence number for the new phase of the revised item
    SELECT sequence_number
      INTO l_new_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = p_status_code
        AND active_flag = 'Y'
        AND rownum = 1;

    -- Get the status_type of the new phase
    SELECT status_type
      INTO l_new_status_type
      FROM eng_change_statuses
      WHERE status_code = p_status_code
        AND rownum = 1;

    -- Get the max sequence number in the lifecycle
    SELECT max(sequence_number)
      INTO l_max_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y';

    IF g_debug_flag THEN
       Write_Debug('Before comparing l_new_phase_sn = l_ri_phase_sn');
       Write_Debug('l_new_phase_sn      : ' || l_new_phase_sn );
       Write_Debug('l_ri_phase_sn       : ' || l_ri_phase_sn );
    END IF;

    -- Sanity check to make sure the new phase is after the current phase
    IF l_new_phase_sn <= l_ri_phase_sn THEN
      FND_MESSAGE.Set_Name('ENG','ENG_OBJ_STATE_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_flag THEN
       Write_Debug('Before comparing l_new_phase_sn = l_max_sn');
    END IF;

    -- Check if the new phase is the last in the lifecycle definition
    IF (l_new_phase_sn = l_max_sn) THEN
      -- New phase is the last lifecycle phase
      IF g_debug_flag THEN
         Write_Debug('Branch: New phase is the last lifecycle phase');
      END IF;

      -- Sanity check: the new phase must be of status_type = 'IMPLEMENTED'
      IF (l_new_status_type <> G_ENG_IMPLEMENTED) THEN
        FND_MESSAGE.Set_Name('ENG','ENG_LAST_PHASE_NOT_IMP');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Set the flag
      l_last_imp_flag := 'Y';

    ELSE
      -- New phase is not the last lifecycle phase
      IF g_debug_flag THEN
         Write_Debug('Branch: New phase is not the last lifecycle phase');
      END IF;
    END IF;

    -- Make sure the revised item is not implemented or cancelled
    -- Get the status_type of the revised item phase
    SELECT status_type
      INTO l_ri_status_type
      FROM eng_change_statuses
      WHERE status_code = l_ri_status_code
        AND rownum = 1;

    -- Update only those which are still active
    IF (l_ri_status_type = G_ENG_IMPLEMENTED
        OR l_ri_status_type = G_ENG_CANCELLED)
    THEN
      FND_MESSAGE.Set_Name('ENG','ENG_REVITEM_IMP_OR_CNCL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      -- Case: promoting revised item to the last implement phase
      IF ( l_last_imp_flag = 'Y' ) THEN


        SELECT change_notice, organization_id
          INTO l_chg_notice, l_org_id
          FROM eng_engineering_changes
          WHERE change_id = p_change_id;
        -- If so, submit concurrent program to implement the eco and all its revised items
        -- as the lifecycle has already reach the last phase for implementation
        IF g_debug_flag THEN
          Write_Debug('Before: calling ENG_ECO_UTIL.Implement_ECO (for revised item)');
          Write_Debug('  l_chg_notice = ' || l_chg_notice);
          Write_Debug('  l_org_id     = ' || l_org_id);
        END IF;

        -- Call concurrent program to implement revised item
        ENG_ECO_UTIL.Implement_ECO
        ( p_api_version          =>    1.0
         ,p_init_msg_list        =>    FND_API.G_FALSE
         ,p_commit               =>    FND_API.G_FALSE
         ,p_validation_level     =>    p_validation_level
         ,p_debug                =>    p_debug --FND_API.G_FALSE
         ,p_output_dir           =>    p_output_dir
         ,p_debug_filename       =>    NULL --p_debug_filename
         ,x_return_status        =>    l_return_status
         ,x_msg_count            =>    l_msg_count
         ,x_msg_data             =>    l_msg_data
         ,p_change_id            =>    p_change_id
         ,p_change_notice        =>    l_chg_notice
         ,p_rev_item_seq_id      =>    p_object_id2
         ,p_org_id               =>    l_org_id
         ,x_request_id           =>    l_request_id
        );

        IF g_debug_flag THEN
          Write_Debug('After: calling ENG_ECO_UTIL.Implement_ECO (for revised item): ' || l_return_status);
        END IF;

        IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_IMP_ECO');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

        ELSIF (l_request_id = 0) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CONCURRENT_PRGM');
          FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ECO_UTIL.Implement_ECO(for revised item)');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF g_debug_flag THEN
          Write_Debug('Successful: calling ENG_ECO_UTIL.Implement_ECO (for revised item)');
          Write_Debug('l_request_id       : ' || l_request_id );
        END IF;

        -- update parent revised item
        UPDATE eng_revised_items
          SET status_type = G_ENG_IMP_IN_PROGRESS,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id,
              Implementation_req_id = l_request_id
          WHERE revised_item_sequence_id = p_object_id2;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_revised_items (parent level).');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;

        -- update active children revised items
        UPDATE eng_revised_items
          SET status_type = G_ENG_IMP_IN_PROGRESS,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id,
              Implementation_req_id = l_request_id
          WHERE parent_revised_item_seq_id = p_object_id2
            AND status_type NOT IN (G_ENG_IMPLEMENTED, G_ENG_CANCELLED);
        IF g_debug_flag THEN
          Write_Debug('After updating eng_revised_items (child level).');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;

      -- Case: promoting revised item to a phase that's not the last implement phase
      ELSE
        -- update parent revised item
        UPDATE eng_revised_items
          SET status_code = p_status_code,
              status_type = l_new_status_type,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE revised_item_sequence_id = p_object_id2;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_revised_items (parent level).');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;

        -- update active children revised items
     /*   UPDATE eng_revised_items
          SET status_code = p_status_code,
              status_type = l_new_status_type,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE parent_revised_item_seq_id = p_object_id2
            AND status_type NOT IN (G_ENG_IMPLEMENTED, G_ENG_CANCELLED);*/
        IF g_debug_flag THEN
          Write_Debug('After updating eng_revised_items (child level).');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;
      END IF;

    END IF;

    IF g_debug_flag THEN
       Write_Debug('Done: Updating revised items to the new phase');
    END IF;


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Promote_Revised_Item');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Promote_Revised_Item;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Promote_Revised_Item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Promote_Revised_Item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Promote_Revised_Item;


  -- Internal procedure for demotion of change header (inc. revItems)
  PROCEDURE Demote_Revised_Item
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER                             -- revised item sequence id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Demote_Revised_Item';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_api_caller         VARCHAR2(2) := NULL;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_new_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;

    l_new_status_type    eng_change_statuses.status_type%TYPE;

    l_ri_status_code      eng_change_lines.status_code%TYPE;
    -- revItem's status_code's sequence_number
    l_ri_phase_sn         eng_lifecycle_statuses.sequence_number%TYPE;
    l_ri_status_type     eng_change_statuses.status_type%TYPE;

    l_curr_phase_sn      eng_lifecycle_statuses.sequence_number%TYPE;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Demote_Revised_Item;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Demote_Revised_Item log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_object_id2        : ' || p_object_id2 );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------
    -- Get the sequence number for the current phase of the change header
    SELECT sequence_number, status_code
      INTO l_ri_phase_sn, l_ri_status_code
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND status_code = ( SELECT status_code
                              FROM eng_revised_items
                              WHERE revised_item_sequence_id = p_object_id2)
        AND rownum = 1;

    -- Get the sequence number for the new phase of the change header
    SELECT sequence_number
      INTO l_new_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = p_status_code
        AND active_flag = 'Y'
        AND rownum = 1;

    IF g_debug_flag THEN
       Write_Debug('Before comparing l_new_phase_sn >= l_ri_phase_sn');
    END IF;

    -- Sanity check to make sure the new phase is after the current phase
    IF l_new_phase_sn >= l_ri_phase_sn THEN
      FND_MESSAGE.Set_Name('ENG','ENG_OBJ_STATE_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Get the status_type of the new phase
    SELECT status_type
      INTO l_new_status_type
      FROM eng_change_statuses
      WHERE status_code = p_status_code;

    -- Make sure the revised item is not implemented or cancelled
    -- Get the status_type of the revised item phase
    SELECT status_type
      INTO l_ri_status_type
      FROM eng_change_statuses
      WHERE status_code = l_ri_status_code
        AND rownum = 1;

    -- Update only those which are still active
    IF (l_ri_status_type = G_ENG_IMPLEMENTED
        OR l_ri_status_type = G_ENG_CANCELLED)
    THEN
      FND_MESSAGE.Set_Name('ENG','ENG_REVITEM_IMP_OR_CNCL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      -- update parent revised item
      UPDATE eng_revised_items
        SET status_code = p_status_code,
            status_type = l_new_status_type,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE revised_item_sequence_id = p_object_id2;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_revised_items (parent level).');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

      -- update active children revised items
      UPDATE eng_revised_items
        SET status_code = p_status_code,
            status_type = l_new_status_type,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE parent_revised_item_seq_id = p_object_id2
          AND status_type NOT IN (G_ENG_IMPLEMENTED, G_ENG_CANCELLED);
      IF g_debug_flag THEN
        Write_Debug('After updating eng_revised_items (child level).');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;


      -- Get the sequence number for the current phase of the change header
      SELECT sequence_number
        INTO l_curr_phase_sn
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND active_flag = 'Y'
          AND status_code = ( SELECT status_code
                                FROM eng_engineering_changes
                                WHERE change_id = p_change_id)
          AND rownum = 1;

      IF g_debug_flag THEN
         Write_Debug('After: getting header phase sequence number');
         Write_Debug('l_curr_phase_sn       : ' || l_curr_phase_sn );
      END IF;
      -- if the header's current phase is higher than the revised item's new phase
      -- demotion of revised item will also trigger demotion of header
      IF ( l_new_phase_sn < l_curr_phase_sn ) THEN
        IF g_debug_flag THEN
           Write_Debug('Demoting header is needed ');
           Write_Debug('Before: calling Demote_Header procedure');
        END IF;

        -- determine API caller - 'UI' should be used only once
        IF (p_api_caller = 'WF' OR p_api_caller = 'CP') THEN
          l_api_caller := p_api_caller;
        ELSE
          l_api_caller := NULL;
        END IF;

        Demote_Header
        ( p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_status_code        => p_status_code
         ,p_update_ri_flag     => 'N'
         ,p_api_caller         => l_api_caller
        );

        IF g_debug_flag THEN
           Write_Debug('After: calling Demote_Header procedure: ' || l_return_status);
        END IF;

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Demote_Header');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF g_debug_flag THEN
           Write_Debug('Successful: calling Demote_Header procedure');
        END IF;
      END IF;

    END IF;

    IF g_debug_flag THEN
       Write_Debug('Done: Updating revised items to the new phase');
    END IF;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Demote_Revised_Item');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Demote_Revised_Item;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Demote_Revised_Item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Demote_Revised_Item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Demote_Revised_Item;


  -- Interface procedure for combining promotion/demotion procedures
  -- Note that this procedure can ONLY be called directly from UI
  PROCEDURE Change_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_object_name               IN   VARCHAR2 := 'ENG_CHANGE'
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER   := NULL                   -- revised item seq id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := 'UI'
   ,p_action_type               IN   VARCHAR2 := G_ENG_PROMOTE          -- promote/demote
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
   ,x_sfa_line_items_exists     OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Change_Phase';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_curr_status_code   eng_engineering_changes.status_code%TYPE;
    l_curr_status_type   eng_engineering_changes.status_type%TYPE;
    l_wf_route_id        eng_lifecycle_statuses.change_wf_route_id%TYPE;
    l_wf_status          eng_lifecycle_statuses.workflow_status%TYPE;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Change_Phase;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_object_name       : ' || p_object_name );
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_object_id2        : ' || p_object_id2 );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('p_action_type       : ' || p_action_type );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here -----------------------------------------------
    IF (p_object_name = G_ENG_CHANGE) THEN
      -- Get the current phase of the change header
      SELECT status_code, status_type
        INTO l_curr_status_code, l_curr_status_type
        FROM eng_engineering_changes
        WHERE change_id = p_change_id;

      -- Get the workflow route id and status for the current phase
      SELECT change_wf_route_id, workflow_status
        INTO l_wf_route_id, l_wf_status
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_curr_status_code
          AND active_flag = 'Y'
          AND rownum = 1;

      -- (x If the current phase is of type APPROVAL x), and the
      -- workflow is available on the current phase but it is still running,
      -- raise error message.
      IF (--l_curr_status_type = G_ENG_APPROVED AND
          l_wf_route_id IS NOT NULL
          AND l_wf_status = Eng_Workflow_Util.G_RT_IN_PROGRESS)
      THEN
        FND_MESSAGE.Set_Name('ENG','ENG_OBJ_STATE_CHANGED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( p_action_type = G_ENG_PROMOTE ) THEN
        Promote_Header
        ( p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_status_code        => p_status_code
         ,p_update_ri_flag     => p_update_ri_flag
         ,p_api_caller         => p_api_caller
         ,p_comment            => p_comment
        );

        IF g_debug_flag THEN
           Write_Debug('After: calling Promote_Header procedure: ' || l_return_status);
        END IF;



        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Promote_Header');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF ( p_action_type = G_ENG_DEMOTE ) THEN

        Demote_Header
        ( p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_status_code        => p_status_code
         ,p_api_caller         => p_api_caller
         ,x_sfa_line_items_exists => x_sfa_line_items_exists
        );


        IF g_debug_flag THEN
           Write_Debug('After: calling Demote_Header procedure: ' || l_return_status);
        END IF;


        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Demote_Header');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        IF g_debug_flag THEN
          Write_Debug('Error: action is neither promotion nor demotion') ;
        END IF;
      END IF;
    -- revised item
    ELSIF (p_object_name = G_ENG_REVISED_ITEM) THEN

      IF ( p_action_type = G_ENG_PROMOTE ) THEN
        Promote_Revised_Item
        ( p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_object_id2         => p_object_id2
         ,p_status_code        => p_status_code
         ,p_api_caller         => p_api_caller
        );


        IF g_debug_flag THEN
           Write_Debug('After: calling Promote_Revised_Item procedure: ' || l_return_status);
        END IF;



        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Promote_Revised_Item');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSIF ( p_action_type = G_ENG_DEMOTE ) THEN
        Demote_Revised_Item
        ( p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_object_id2         => p_object_id2
         ,p_status_code        => p_status_code
         ,p_api_caller         => p_api_caller
        );

        IF g_debug_flag THEN
           Write_Debug('After: calling Demote_Revised_Item procedure: ' || l_return_status);
        END IF;


        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Demote_Revised_Item');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        IF g_debug_flag THEN
          Write_Debug('Error: action is neither promotion nor demotion') ;
        END IF;
      END IF;
    ELSE
      IF g_debug_flag THEN
        Write_Debug('Error: p_object_name is neither ENG_CHANGE nor ENG_REVISED_ITEM') ;
      END IF;
    END IF;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Change_Phase');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Change_Phase;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Change_Phase;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Change_Phase;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Change_Phase;

  PROCEDURE Change_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_object_name               IN   VARCHAR2 := 'ENG_CHANGE'
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER   := NULL                   -- revised item seq id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := 'UI'
   ,p_action_type               IN   VARCHAR2 := G_ENG_PROMOTE          -- promote/demote
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
  )
  IS
     l_sfa_line_items_exists VARCHAR2(1);
  BEGIN
          Change_Phase
          (
            p_api_version       => p_api_version
            ,p_init_msg_list     => p_init_msg_list
            ,p_commit            => p_commit
            ,p_validation_level  => p_validation_level
            ,p_debug             => p_debug
            ,p_output_dir        => p_output_dir
            ,p_debug_filename    => p_debug_filename
            ,x_return_status     => x_return_status
            ,x_msg_count         => x_msg_count
            ,x_msg_data          => x_msg_data
            ,p_object_name       => p_object_name
            ,p_change_id         => p_change_id
            ,p_object_id2        => p_object_id2
            ,p_status_code       => p_status_code
            ,p_update_ri_flag    => p_update_ri_flag
            ,p_api_caller        => p_api_caller
            ,p_action_type       => p_action_type
            ,p_comment           => p_comment
            ,x_sfa_line_items_exists => l_sfa_line_items_exists
          );
  END Change_Phase;




  -- Procedure to be called by WF to update lifecycle states of the change header,
  -- revised items, tasks and lines lifecycle states
  PROCEDURE Update_Lifecycle_States
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER
   ,p_status_code               IN   NUMBER   := NULL -- passed only by WF call for p_route_status = IN_PROGRESS or CP for imp failure
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- or 'WF'
   ,p_wf_route_id               IN   NUMBER
   ,p_route_status              IN   VARCHAR2
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Lifecycle_States';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_api_caller         VARCHAR2(2) := NULL;

    l_action_id          eng_change_actions.action_id%TYPE;

    l_chg_appr_status    eng_engineering_changes.approval_status_type%TYPE;
    l_curr_appr_status   eng_engineering_changes.approval_status_type%TYPE;

    l_cm_type_code       eng_engineering_changes.change_mgmt_type_code%TYPE;
    l_base_cm_type_code   eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;

    l_curr_status_code   NUMBER;
    l_curr_status_type   NUMBER;
    l_next_status_code   NUMBER;
    l_last_status_code   NUMBER;

    l_status_type        NUMBER; -- status_type for p_status_code as incoming parameter
    l_min_appr_sn        eng_lifecycle_statuses.sequence_number%TYPE;

    l_last_wf_route_id   eng_lifecycle_statuses.change_wf_route_id%TYPE;

    l_curr_phase_sn      eng_lifecycle_statuses.sequence_number%TYPE;
    l_max_appr_phase_sn  eng_lifecycle_statuses.sequence_number%TYPE;
    l_max_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;

    l_nir_update_flag    VARCHAR2(1) := 'F';

    CURSOR c_lines IS
      SELECT s.status_type
        FROM eng_change_lines l,
             eng_change_statuses s
        WHERE l.change_id = p_change_id
          AND s.status_code = l.status_code;
    l_line_status_type   eng_change_statuses.status_type%TYPE;

    l_chg_notice         eng_engineering_changes.change_notice%TYPE;
    l_org_id             eng_engineering_changes.organization_id%TYPE;
    l_request_id         NUMBER;

    l_imp_eco_flag       VARCHAR2(1) := 'N';

    l_is_co_last_phase   VARCHAR2(1);
    l_auto_demote_status eng_lifecycle_statuses.status_code%TYPE;

    l_flag_imp_failed    VARCHAR2(1) := 'N';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Lifecycle_States;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Update_Lifecycle_States log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_status_code       : ' || p_status_code );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('p_wf_route_id       : ' || p_wf_route_id );
       Write_Debug('p_route_status      : ' || p_route_status );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------

    -- Translate workflow route statuses to change workflow status types
    IF (   p_route_status = Eng_Workflow_Util.G_RT_APPROVED
        OR p_route_status = Eng_Workflow_Util.G_RT_COMPLETED
        OR p_route_status = Eng_Workflow_Util.G_RT_REPLIED)
    THEN
      l_chg_appr_status := G_ENG_APPR_APPROVED;
    ELSIF (p_route_status = Eng_Workflow_Util.G_RT_REJECTED)
    THEN
      l_chg_appr_status := G_ENG_APPR_REJECTED;
    ELSIF (p_route_status = Eng_Workflow_Util.G_RT_TIME_OUT)
    THEN
      l_chg_appr_status := G_ENG_APPR_TIME_OUT;
    ELSIF (   p_route_status = Eng_Workflow_Util.G_RT_ABORTED
           OR p_route_status = Eng_Workflow_Util.G_RT_NOT_STARTED)
    THEN
      l_chg_appr_status := G_ENG_NOT_SUBMITTED;
    ELSIF (p_route_status = Eng_Workflow_Util.G_RT_IN_PROGRESS)
    THEN
      l_chg_appr_status := G_ENG_APPR_REQUESTED;
    END IF;
    IF g_debug_flag THEN
       Write_Debug('After: workflow status >> header approval status translation');
       Write_Debug('l_chg_appr_status   : ' || l_chg_appr_status );
    END IF;


    -- Query the required parameters
    -- Get the current phase, promote_phase and cm type of the change header
    SELECT eec.status_code, eec.promote_status_code, eec.change_mgmt_type_code,
           ecot.base_change_mgmt_type_code
      INTO l_curr_status_code, l_next_status_code, l_cm_type_code,
           l_base_cm_type_code
      FROM eng_engineering_changes eec,
           eng_change_order_types ecot
      WHERE eec.change_id = p_change_id
        AND ecot.change_order_type_id = eec.change_order_type_id;

    -- Get the current phase status_type
    SELECT status_type
      INTO l_curr_status_type
      FROM eng_change_statuses
      WHERE status_code = l_curr_status_code;

    -- Get the current phase's sequence number
    SELECT sequence_number
      INTO l_curr_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = l_curr_status_code
        AND active_flag = 'Y'
        AND rownum = 1;

    -- Get the sequence_number of the last phase
    -- Note that only phase of IMPLEMENT type can be the last phase
    SELECT max(sequence_number)
      INTO l_max_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y';

    -- Get the sequence number of the last phase
    SELECT status_code, change_wf_route_id
      INTO l_last_status_code, l_last_wf_route_id
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND sequence_number = l_max_phase_sn;


    -- Case: (special 1) last implement phase of ECO: workflow completion
    -- Special branch of code to handle post <implement> promotion for ECO
    -- (invoked by eco last implement phase workflow call)
    IF (    (p_api_caller IS NULL OR p_api_caller <> 'CP')
         AND l_base_cm_type_code = G_ENG_ECO
         AND l_next_status_code = l_last_status_code
         AND p_wf_route_id = l_last_wf_route_id
        )
    THEN
      IF g_debug_flag THEN
        Write_Debug('In block: case (special) last implement phase of ECO: workflow completion.');
      END IF;

      -- Update the current phase's workflow status
      UPDATE eng_lifecycle_statuses
        SET workflow_status = p_route_status,
            completion_date = sysdate,    -- newly added for 3479509 fix (launch wf after implementation)
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_next_status_code
          AND active_flag = 'Y'
          AND rownum = 1;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_lifecycle_statuses.workflow_status.');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

    -- Case: (special 2) last implement phase of ECO direct promotion w/o wf
    -- Special branch of code to handle post <implement> promotion for ECO
    -- (invoked by Start_WF_OnlyIf_Necessary w/o wf or with p_skip_wf=Y, which
    --  can be recognized by the null p_wf_route_id)
    ELSIF (    (p_api_caller IS NULL OR p_api_caller <> 'CP')
            AND l_base_cm_type_code = G_ENG_ECO
            AND l_next_status_code = l_last_status_code
            AND p_wf_route_id IS NULL
           )
    THEN
      IF g_debug_flag THEN
        Write_Debug('In block: case (special) last implement phase of ECO');
      END IF;

      -- Get the required parameters before calling concurrent program for implementing ECO
      SELECT change_notice, organization_id
        INTO l_chg_notice, l_org_id
        FROM eng_engineering_changes
        WHERE change_id = p_change_id;

      -- If so, submit concurrent program to implement the eco and all its revised items
      -- as the lifecycle has already reach the last phase for implementation
      IF g_debug_flag THEN
        Write_Debug('Before: calling ENG_ECO_UTIL.Implement_ECO');
        Write_Debug('  l_chg_notice = ' || l_chg_notice);
        Write_Debug('  l_org_id     = ' || l_org_id);
      END IF;
      ENG_ECO_UTIL.Implement_ECO
      ( p_api_version          =>    1.0
       ,p_init_msg_list        =>    FND_API.G_FALSE
       ,p_commit               =>    FND_API.G_FALSE
       ,p_validation_level     =>    p_validation_level
       ,p_debug                =>    p_debug --FND_API.G_FALSE
       ,p_output_dir           =>    p_output_dir
       ,p_debug_filename       =>    'engact.impECO.log' --p_debug_filename
       ,x_return_status        =>    l_return_status
       ,x_msg_count            =>    l_msg_count
       ,x_msg_data             =>    l_msg_data
       ,p_change_id            =>    p_change_id
       ,p_change_notice        =>    l_chg_notice
       ,p_org_id               =>    l_org_id
       ,x_request_id           =>    l_request_id
      );

      IF g_debug_flag THEN
         Write_Debug('After: calling ENG_ECO_UTIL.Implement_ECO: ' || l_return_status);
      END IF;


      IF (l_request_id IS NULL) THEN
        IF g_debug_flag THEN
          Write_Debug('l_request_id = NULL');
        END IF;
      ELSE
        IF g_debug_flag THEN
          Write_Debug('l_request_id = ' || l_request_id);
        END IF;

        -- ATG Project
        -- Putting the request id flag in the implementation_req_id field
        UPDATE eng_engineering_changes
        SET implementation_req_id = l_request_id
        WHERE change_id = p_change_id;
      END IF;

      IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS
          OR l_request_id IS NULL
          OR l_request_id = 0 )
      THEN
        l_flag_imp_failed := 'Y';

        IF (p_api_caller = 'WF') THEN
          -- Log implementation failure message
          UPDATE eng_engineering_changes
            SET status_type = G_ENG_IMP_FAILED,
                last_update_date = sysdate,
                last_updated_by = l_fnd_user_id,
                last_update_login = l_fnd_login_id
            WHERE change_id = p_change_id;

          IF g_debug_flag THEN
             Write_Debug('Before: saving action log');
          END IF;
          l_action_id := 0;
          -- create new action log
          ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
          ( p_api_version           => 1.0
          , p_init_msg_list         => FND_API.G_FALSE        --
          , p_commit                => FND_API.G_FALSE        --
          , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
          , p_debug                 => p_debug --FND_API.G_FALSE
          , p_output_dir            => p_output_dir
          , p_debug_filename        => NULL
          , x_return_status         => l_return_status
          , x_msg_count             => l_msg_count
          , x_msg_data              => l_msg_data
          , p_action_type           => ENG_CHANGE_ACTIONS_UTIL.G_ACT_IMP_FAILED
          , p_object_name           => G_ENG_CHANGE
          , p_object_id1            => p_change_id
          , p_object_id2            => NULL
          , p_object_id3            => NULL
          , p_object_id4            => NULL
          , p_object_id5            => NULL
          , p_parent_action_id      => -1
          , p_status_code           => NULL
          , p_action_date           => SYSDATE
          , p_change_description    => NULL
          , p_user_id               => l_fnd_user_id
          , p_api_caller            => p_api_caller
          , x_change_action_id      => l_action_id
          );

          IF g_debug_flag THEN
             Write_Debug('After: saving action log: ' || l_return_status);
             Write_Debug('l_action_id       : ' || l_action_id );
          END IF;


          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
            --#FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF g_debug_flag THEN
             Write_Debug('Successful: saving action log');
          END IF;
        ELSE -- otherwise generate and return error message to UI
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CONCURRENT_PRGM');
          FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ECO_UTIL.Implement_ECO');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      IF (l_flag_imp_failed = 'N') THEN
        -- Concurrent program has been set successfully, Set the flag
        -- for later code NOT to call PROMOTE_HEADER procedure in order to
        -- prevent an infinite loop
        l_imp_eco_flag := 'Y';
        IF g_debug_flag THEN
          Write_Debug('Successful: calling ENG_ECO_UTIL.Implement_ECO');
          Write_Debug('l_request_id       : ' || l_request_id );
        END IF;

        -- Update change header status_type
        UPDATE eng_engineering_changes
          SET status_type = G_ENG_IMP_IN_PROGRESS,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;

        -- Log action for implementation_in_progress
        IF g_debug_flag THEN
          Write_Debug('Before: saving action log');
        END IF;
        l_action_id := 0;
        -- create new action log
        ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
        ( p_api_version           => 1.0
        , p_init_msg_list         => FND_API.G_FALSE        --
        , p_commit                => FND_API.G_FALSE        --
        , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
        , p_debug                 => p_debug --FND_API.G_FALSE
        , p_output_dir            => p_output_dir
        , p_debug_filename        => NULL
        , x_return_status         => l_return_status
        , x_msg_count             => l_msg_count
        , x_msg_data              => l_msg_data
        , p_action_type           => ENG_CHANGE_ACTIONS_UTIL.G_ACT_IMP_IN_PROGRESS
        , p_object_name           => G_ENG_CHANGE
        , p_object_id1            => p_change_id
        , p_object_id2            => NULL
        , p_object_id3            => NULL
        , p_object_id4            => NULL
        , p_object_id5            => NULL
        , p_parent_action_id      => -1
        , p_status_code           => NULL
        , p_action_date           => SYSDATE
        , p_change_description    => p_comment
        , p_user_id               => l_fnd_user_id
        , p_api_caller            => p_api_caller
        , x_change_action_id      => l_action_id
        );

        IF g_debug_flag THEN
           Write_Debug('After: saving action log: ' || l_return_status );
           Write_Debug('l_action_id       : ' || l_action_id );
        END IF;

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF g_debug_flag THEN
           Write_Debug('Successful: saving action log');
        END IF;

      END IF; -- if (l_flag_imp_failed)

      IF g_debug_flag THEN
        Write_Debug('End block: case (special) last implement phase of ECO');
      END IF;

    -- Case 1: no workflow associated with the current phase
    --         or the workflow is successfully approved
    ELSIF (   (   (p_api_caller IS NULL OR p_api_caller <> 'CP')
               AND p_route_status IS NULL )
           OR l_chg_appr_status = G_ENG_APPR_APPROVED )
    THEN
      IF g_debug_flag THEN
        Write_Debug('Case 1: no workflow or workflow is approved');
      END IF;

      -- Update the current phase's workflow status
      UPDATE eng_lifecycle_statuses
        SET workflow_status = p_route_status,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_curr_status_code
          AND active_flag = 'Y'
          AND rownum = 1;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_lifecycle_statuses.workflow_status.');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

      -- IF the current phase is the last one, also update its completion date
      -- Otherwise leave it for promote_header and demote_header procedures
      -- to set the completion_date
      IF (l_curr_phase_sn = l_max_phase_sn) THEN
        UPDATE eng_lifecycle_statuses
          SET completion_date = sysdate,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE entity_name = G_ENG_CHANGE
            AND entity_id1 = p_change_id
            AND status_code = l_curr_status_code
            AND active_flag = 'Y'
            AND rownum = 1;
        IF g_debug_flag THEN
          Write_Debug('After updating eng_lifecycle_statuses.completion_date.');
          Write_Debug('  Row count = ' || SQL%ROWCOUNT);
        END IF;
      END IF;

      IF g_debug_flag THEN
        Write_Debug('Current phase row updated');
      END IF;

      -- Force commit to prevent stucking on a phase in case of auto-promotion
      -- or auto-demotion failure triggered by workflow background engine
      IF (p_api_caller = 'WF' AND l_chg_appr_status = G_ENG_APPR_APPROVED)
      THEN
        COMMIT WORK;
      END IF;



      -- Update header and NIR approval status if needed

      -- Check if the change category is NIR, phase is on last implement phase
      -- and header approval status has not been set to APPROVED
      SELECT approval_status_type
        INTO l_curr_appr_status
        FROM eng_engineering_changes
        where change_id = p_change_id;

      IF ( l_base_cm_type_code = G_ENG_NEW_ITEM_REQ
           AND l_curr_phase_sn = l_max_phase_sn
           AND l_curr_appr_status <> G_ENG_APPR_APPROVED
           )
      THEN
        l_nir_update_flag := 'Y';
        l_chg_appr_status := G_ENG_APPR_APPROVED;
        IF g_debug_flag THEN
          Write_Debug('Current phase is last phase of NIR, and force setting of header approval status is needed');
        END IF;
      END IF;


      -- Check if the current phase is of type REVIEW/APPROVAL,
      -- and if it is the last such phase in the lifecycle of the change header
      --
      IF (    (l_curr_status_type = G_ENG_APPROVED OR l_nir_update_flag = 'Y')
           AND l_chg_appr_status IS NOT NULL
          )
      THEN
        IF g_debug_flag THEN
          Write_Debug('Current phase is of type APPROVAL, or last NIR phase needs to force header approval status to APPROVED');
        END IF;

        -- Get the sequence number of the last phase of type REVIEW/APPROVAL
        SELECT max(lcs.sequence_number)
          INTO l_max_appr_phase_sn
          FROM eng_lifecycle_statuses lcs,
               eng_change_statuses chs
          WHERE lcs.entity_name = G_ENG_CHANGE
            AND lcs.entity_id1 = p_change_id
            AND lcs.active_flag = 'Y'
            AND chs.status_code = lcs.status_code
            AND chs.status_type = G_ENG_APPROVED;


        IF g_debug_flag THEN
          Write_Debug('Check if the current phase is the last phase of type APPROVAL');
        END IF;


        -- Check if the current phase is the last phase of type REVIEW/APPROVAL
        -- Update header approval status if so
        IF ( l_curr_phase_sn = l_max_appr_phase_sn
             OR (p_api_caller IS NULL)
             OR l_nir_update_flag = 'Y'
             )
        THEN
          IF g_debug_flag THEN
            Write_Debug('Current phase is the last of such type');
          END IF;

          IF g_debug_flag THEN
            Write_Debug('Before: calling Update_Header_Appr_Status');
          END IF;


          -- Update change header approval status
          -- Launch header approval status change workflow
          Update_Header_Appr_Status
          (
            p_api_version               =>  1.0
           ,p_init_msg_list             =>  FND_API.G_FALSE
           ,p_commit                    =>  FND_API.G_FALSE
           ,p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL
           ,p_debug                     =>  FND_API.G_FALSE
           ,p_output_dir                =>  p_output_dir
           ,p_debug_filename            =>  p_debug_filename
           ,x_return_status             =>  l_return_status
           ,x_msg_count                 =>  l_msg_count
           ,x_msg_data                  =>  l_msg_data
           ,p_change_id                 =>  p_change_id
           ,p_status_code               =>  l_curr_status_code
           ,p_appr_status               =>  l_chg_appr_status
           ,p_route_status              =>  p_route_status
           ,p_api_caller                =>  p_api_caller
           ,p_bypass                    =>  l_nir_update_flag
          );


          IF g_debug_flag THEN
            Write_Debug('After: Update_Header_Appr_Status: ' || l_return_status );
          END IF;


          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF g_debug_flag THEN
            Write_Debug('After: calling Update_Header_Appr_Status');
          END IF;

        END IF;
      END IF;
       IF ( l_base_cm_type_code = G_ENG_NEW_ITEM_REQ
           AND l_curr_phase_sn = l_max_phase_sn) then
	ENG_NIR_UTIL_PKG.set_nir_item_approval_status
          ( p_change_id          => p_change_id
           ,p_approval_status    => G_ENG_APPR_APPROVED
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           );
	END IF;

      -- Check if the current phase is the last of type IMPLEMENT (COMPLETE)
      -- Note that this code block is only used by non CO header types
      IF ( l_curr_status_type = G_ENG_IMPLEMENTED AND l_curr_phase_sn = l_max_phase_sn )
      THEN
        IF g_debug_flag THEN
          Write_Debug('Current phase is the last of type IMPLEMENTED');
        END IF;
        -- If there are still active lines, raise error message
        OPEN c_lines;
          LOOP
            FETCH c_lines INTO l_line_status_type;
            EXIT WHEN c_lines%NOTFOUND;
            IF ( l_line_status_type <> G_ENG_COMPLETED
                 AND l_line_status_type <> G_ENG_IMPLEMENTED
                 AND l_line_status_type <> G_ENG_CANCELLED
                    --   R12.C Enhancement : Added following condition because NIRs can have different line statuses
                 AND l_base_cm_type_code <> G_ENG_NEW_ITEM_REQ) THEN
              -- Stop and return error message
              IF g_debug_flag THEN
                Write_Debug('Branch: Exists non completed/implemented/cancelled lines');
              END IF;
              FND_MESSAGE.Set_Name('ENG','ENG_EXIST_ACTIVE_LINES');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END LOOP;
        CLOSE c_lines;

        IF g_debug_flag THEN
          Write_Debug('Finished checking open lines');
        END IF;

        -- If we can reach this line, it means there are no active lines
        -- Get the cm type for the change header
        SELECT eec.change_mgmt_type_code, eec.change_notice, eec.organization_id,
               ecot.base_change_mgmt_type_code
          INTO l_cm_type_code, l_chg_notice, l_org_id,
               l_base_cm_type_code
          FROM eng_engineering_changes eec,
               eng_change_order_types ecot
          WHERE eec.change_id = p_change_id
            AND ecot.change_order_type_id = eec.change_order_type_id;

        -- Complete attachment approval if needed
        IF g_debug_flag THEN
          Write_Debug('Before: calling DM attachment approval API');
        END IF;
        IF (   l_base_cm_type_code = G_ENG_ATTACHMENT_APPR
            OR l_base_cm_type_code = G_ENG_ATTACHMENT_REVW )
        THEN

          IF g_debug_flag THEN
            Write_Debug('In: calling DM attachment approval/review API');
            Write_Debug('p_workflow_status : ' || p_status_code );
            Write_Debug('p_approval_status : ' || l_chg_appr_status );
          END IF;

          ENG_ATTACHMENT_IMPLEMENTATION.Update_Attachment_Status
          (
            p_api_version         => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,p_commit              => FND_API.G_FALSE
           ,p_validation_level    => p_validation_level
           ,p_debug               => p_debug --FND_API.G_FALSE
           ,p_output_dir          => p_output_dir
           ,p_debug_filename      => NULL --p_debug_filename
           ,x_return_status       => l_return_status
           ,x_msg_count           => l_msg_count
           ,x_msg_data            => l_msg_data
           ,p_change_id           => p_change_id
           ,p_workflow_status     => p_status_code
           ,p_approval_status     => G_ENG_APPR_APPROVED --l_chg_appr_status
           ,p_api_caller          => p_api_caller
          );

          IF g_debug_flag THEN
            Write_Debug('After: ENG_ATTACHMENT_IMPLEMENTATION.Update_Attachment_Status: ' || l_return_status );
          END IF;




          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
            --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ATTACHMENT_IMPLEMENTATION.Update_Attachment_Status');
            --#FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
        IF g_debug_flag THEN
          Write_Debug('After: calling DM attachment approval/review API');
        END IF;

        -- moved impECO block to Update_Lifecycle_States procedure
      END IF;  -- current phase is the last of type IMPLEMENT?


      IF g_debug_flag THEN
        Write_Debug('Finished checking all conditions prior to promotion, ready to promote if needed');
      END IF;
      -- Finished checking all the conditions for promotion, ready to promote (if needed)
      -- Find the promotion phase in the order of the following priority
      -- 1. promote_status_code in the change header (saved by promote action)
      SELECT promote_status_code
        INTO l_next_status_code
        FROM eng_engineering_changes
        WHERE change_id = p_change_id;

      -- 2. auto_promote_status in the lifecycle table
      IF ( l_next_status_code IS NULL ) THEN
        IF g_debug_flag THEN
          Write_Debug('promote_status_code is NULL');
        END IF;
        SELECT auto_promote_status
          INTO l_next_status_code
          FROM eng_lifecycle_statuses
          WHERE entity_name = G_ENG_CHANGE
            AND entity_id1 = p_change_id
            AND status_code = l_curr_status_code
            AND active_flag = 'Y'
            AND rownum = 1;
      END IF;

      IF ( l_next_status_code IS NOT NULL AND l_imp_eco_flag = 'N' )
      THEN
        IF g_debug_flag THEN
          Write_Debug('l_next_status_code IS NOT NULL AND l_imp_eco_flag = N, call PROMOTE_HEADER');
        END IF;

        -- determine API caller
        IF (p_api_caller = 'WF' OR p_api_caller = 'CP') THEN
          l_api_caller := p_api_caller;
        ELSE
          l_api_caller := NULL;
        END IF;

        Promote_Header
        (
          p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_status_code        => l_next_status_code
         ,p_api_caller         => l_api_caller
        );

        IF g_debug_flag THEN
          Write_Debug('After: Promote_Header: ' || l_return_status );
        END IF;


        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Promote_Header');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF g_debug_flag THEN
          Write_Debug('After: calling PROMOTE_HEADER');
        END IF;

      ELSE
        -- No manual or auto promotion is set, do nothing
        NULL;
        IF g_debug_flag THEN
          Write_Debug('No manual or auto promotion is set, do nothing');
        END IF;

      END IF;


    -- Case 2: workflow is rejected
    ELSIF ( p_route_status = Eng_Workflow_Util.G_RT_REJECTED )
    THEN
      IF g_debug_flag THEN
        Write_Debug('Case 2: workflow is rejected');
      END IF;

      -- Update lifecycle table
      UPDATE eng_lifecycle_statuses
        SET workflow_status = p_route_status,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_curr_status_code
          AND active_flag = 'Y'
          AND rownum = 1;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_lifecycle_statuses.workflow_status.');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

      IF g_debug_flag THEN
        Write_Debug('After updating current phase row');
      END IF;

      -- Get the auto demotion phase for the current phase of the change header
      SELECT auto_demote_status
        INTO l_next_status_code
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_curr_status_code
          AND active_flag = 'Y'
          AND rownum = 1;

      -- Reset promotion_status_code for the change header
      UPDATE eng_engineering_changes
        SET promote_status_code = NULL,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE change_id = p_change_id;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_engineering_changes.');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

      IF g_debug_flag THEN
        Write_Debug('After getting AUTO_PROMOTE_STATUS in phase table and resetting PROMOTE_STATUS_CODE in change header table');
      END IF;

      -- update header approval status to "rejected" if the p_status_code passed
      -- by workflow is phase of type "approval"

      -- get phase type
      SELECT status_type
        INTO l_status_type
        FROM eng_change_statuses
        WHERE status_code = p_status_code;
      -- check if the phase type is APPROVAL
      IF ( l_status_type = G_ENG_APPROVED ) THEN
        IF g_debug_flag THEN
           Write_Debug('Phase type is APPROVAL');
        END IF;

        -- Update change header approval status
        -- Launch header approval status change workflow
        IF g_debug_flag THEN
           Write_Debug('Before: calling Update_Header_Appr_Status');
        END IF;
        Update_Header_Appr_Status
        (
          p_api_version               =>  1.0
         ,p_init_msg_list             =>  FND_API.G_FALSE
         ,p_commit                    =>  FND_API.G_FALSE
         ,p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL
         ,p_debug                     =>  FND_API.G_FALSE
         ,p_output_dir                =>  p_output_dir
         ,p_debug_filename            =>  p_debug_filename
         ,x_return_status             =>  l_return_status
         ,x_msg_count                 =>  l_msg_count
         ,x_msg_data                  =>  l_msg_data
         ,p_change_id                 =>  p_change_id
         ,p_status_code               =>  p_status_code
         ,p_appr_status               =>  l_chg_appr_status
         ,p_route_status              =>  p_route_status
         ,p_api_caller                =>  p_api_caller
        );

        IF g_debug_flag THEN
          Write_Debug('After: calling Update_Header_Appr_Status: ' || l_return_status);
        END IF;

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF g_debug_flag THEN
            Write_Debug('Successful: calling Update_Header_Appr_Status');
          END IF;
        END IF;

      END IF; -- IF ( p_status_type = G_ENG_APPROVED )

      IF g_debug_flag THEN
        Write_Debug('Before if condition for calling DEMOTE_HEADER procedure');
      END IF;
      -- Call demotion procedure if necessary
      IF ( l_next_status_code IS NOT NULL ) THEN
        IF g_debug_flag THEN
          Write_Debug('l_next_status_code IS NOT NULL.');
          Write_Debug('Before: calling DEMOTE_HEADER procedure');
        END IF;

        -- determine API caller - 'UI' should be used only once
        IF (p_api_caller = 'WF' OR p_api_caller = 'CP') THEN
          l_api_caller := p_api_caller;
        ELSE
          l_api_caller := NULL;
        END IF;

        Demote_Header
        (
          p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_status_code        => l_next_status_code
         ,p_api_caller         => l_api_caller
        );
        IF g_debug_flag THEN
          Write_Debug('After: calling DEMOTE_HEADER procedure: ' || l_return_status);
        END IF;
        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Demote_Header');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF g_debug_flag THEN
           Write_Debug('Successful: calling Demote_Header procedure');
        END IF;

      END IF;  -- if (next status_code is null)


    -- Case 3: workflow fails due to unexpected problems
    ELSIF (    p_route_status = Eng_Workflow_Util.G_RT_ABORTED
            OR p_route_status = Eng_Workflow_Util.G_RT_TIME_OUT
            OR p_route_status = Eng_Workflow_Util.G_RT_NOT_STARTED )
    THEN
      IF g_debug_flag THEN
        Write_Debug('Case 3: workflow ends with unexpected status');
      END IF;

      -- Update lifecycle table
      UPDATE eng_lifecycle_statuses
        SET workflow_status = p_route_status,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = l_curr_status_code
          AND active_flag = 'Y'
          AND rownum = 1;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_lifecycle_statuses.workflow_status.');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;


      IF g_debug_flag THEN
        Write_Debug('After updating the current phase');
      END IF;

      -- Reset promotion_status_code for the change header
      UPDATE eng_engineering_changes
        SET promote_status_code = NULL,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE change_id = p_change_id;
      IF g_debug_flag THEN
        Write_Debug('After updating eng_lifecycle_statuses.promote_status_code.');
        Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

      IF g_debug_flag THEN
        Write_Debug('After resetting promote_status_code in change header table');
      END IF;


      -- Update change header approval status
      -- Launch header approval status change workflow
      Update_Header_Appr_Status
      (
        p_api_version               =>  1.0
       ,p_init_msg_list             =>  FND_API.G_FALSE
       ,p_commit                    =>  FND_API.G_FALSE
       ,p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL
       ,p_debug                     =>  FND_API.G_FALSE
       ,p_output_dir                =>  p_output_dir
       ,p_debug_filename            =>  p_debug_filename
       ,x_return_status             =>  l_return_status
       ,x_msg_count                 =>  l_msg_count
       ,x_msg_data                  =>  l_msg_data
       ,p_change_id                 =>  p_change_id
       ,p_status_code               =>  p_status_code
       ,p_appr_status               =>  l_chg_appr_status
       ,p_route_status              =>  p_route_status
       ,p_api_caller                =>  p_api_caller
      );

      IF g_debug_flag THEN
         Write_Debug('After: calling Update_Header_Appr_Status: ' || l_return_status);
      END IF;

      IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
      THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF g_debug_flag THEN
        Write_Debug('After: calling Update_Header_Appr_Status');
      END IF;

    -- Case 4: workflow calls to update phase of p_status_code
    -- (may not be current header status_code in case of last ECO implement phase)
    -- to IN_PROGRESS
    ELSIF (p_route_status = Eng_Workflow_Util.G_RT_IN_PROGRESS) THEN
      -- sanity check: workflow must pass p_status_code for the workflow p_route_id
      IF (p_status_code IS NULL) THEN
        FND_MESSAGE.Set_Name('ENG','ENG_OBJECT_CANT_BE_NULL');
        FND_MESSAGE.Set_Token('OBJECT_NAME', 'p_status_code passed by workflow');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- update phase workflow status
      UPDATE eng_lifecycle_statuses
        SET workflow_status = p_route_status,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = p_status_code
          AND active_flag = 'Y';
      IF g_debug_flag THEN
         Write_Debug('After updating eng_lifecycle_statuses.workflow_status.');
         Write_Debug('  Row count = ' || SQL%ROWCOUNT);
      END IF;

      -- update header approval status to "submitted" if the p_status_code passed
      -- by workflow is phase of type "approval"

      -- get phase type
      SELECT status_type
        INTO l_status_type
        FROM eng_change_statuses
        WHERE status_code = p_status_code;
      -- check if the phase type is APPROVAL
      IF ( l_status_type = G_ENG_APPROVED ) THEN
        IF g_debug_flag THEN
           Write_Debug('Phase type is APPROVAL');
        END IF;

        -- Update change header approval status
        -- Launch header approval status change workflow
        IF g_debug_flag THEN
           Write_Debug('Before: calling Update_Header_Appr_Status');
        END IF;
        Update_Header_Appr_Status
        (
          p_api_version               =>  1.0
         ,p_init_msg_list             =>  FND_API.G_FALSE
         ,p_commit                    =>  FND_API.G_FALSE
         ,p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL
         ,p_debug                     =>  FND_API.G_FALSE
         ,p_output_dir                =>  p_output_dir
         ,p_debug_filename            =>  p_debug_filename
         ,x_return_status             =>  l_return_status
         ,x_msg_count                 =>  l_msg_count
         ,x_msg_data                  =>  l_msg_data
         ,p_change_id                 =>  p_change_id
         ,p_status_code               =>  p_status_code
         ,p_appr_status               =>  G_ENG_APPR_REQUESTED
         ,p_route_status              =>  p_route_status
         ,p_api_caller                =>  p_api_caller
        );

        IF g_debug_flag THEN
          Write_Debug('After: calling Update_Header_Appr_Status: ' || l_return_status);
        END IF;


        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF g_debug_flag THEN
            Write_Debug('Successful: calling Update_Header_Appr_Status');
          END IF;
        END IF;

      END IF; -- IF ( p_status_type = G_ENG_APPROVED )

    -- Case 6: concurrent program for implementation failure
    ELSIF ( p_api_caller = 'CP' AND p_status_code = G_ENG_IMP_FAILED )
    THEN
      IF g_debug_flag THEN
        Write_Debug('Case 6: Concurrent Program Failure');
      END IF;

      -- Log implementation failure message
      UPDATE eng_engineering_changes
        SET status_type = G_ENG_IMP_FAILED,
            promote_status_code = NULL,
            last_update_date = sysdate,
            last_updated_by = l_fnd_user_id,
            last_update_login = l_fnd_login_id
        WHERE change_id = p_change_id;

      IF g_debug_flag THEN
         Write_Debug('Before: saving action log');
      END IF;
      l_action_id := 0;
      -- create new action log
      ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
      ( p_api_version           => 1.0
      , p_init_msg_list         => FND_API.G_FALSE        --
      , p_commit                => FND_API.G_FALSE        --
      , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
      , p_debug                 => p_debug --FND_API.G_FALSE
      , p_output_dir            => p_output_dir
      , p_debug_filename        => NULL
      , x_return_status         => l_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      , p_action_type           => ENG_CHANGE_ACTIONS_UTIL.G_ACT_IMP_FAILED
      , p_object_name           => G_ENG_CHANGE
      , p_object_id1            => p_change_id
      , p_object_id2            => NULL
      , p_object_id3            => NULL
      , p_object_id4            => NULL
      , p_object_id5            => NULL
      , p_parent_action_id      => -1
      , p_status_code           => NULL
      , p_action_date           => SYSDATE
      , p_change_description    => NULL
      , p_user_id               => l_fnd_user_id
      , p_api_caller            => p_api_caller
      , x_change_action_id      => l_action_id
      );

      IF g_debug_flag THEN
         Write_Debug('After: saving action log: ' || l_return_status);
         Write_Debug('l_action_id       : ' || l_action_id );
      END IF;
      IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
      THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
        --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
        --#FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF g_debug_flag THEN
         Write_Debug('Successful: saving action log');
      END IF;

      -- Commit anyway to make sure implementation failure action message is logged
      -- Note that since this branch is not invoked by workflow, no addtional check
      -- on p_api_caller = WF is needed, and commit is allowed
      COMMIT WORK;

      -- Check whether the header category is CO and it's on last implement phase
      Is_CO_On_Last_Imp_Phase
      (
        p_change_id                 => p_change_id
       ,p_api_caller                => p_api_caller
       ,x_is_co_last_phase          => l_is_co_last_phase
       ,x_auto_demote_status        => l_auto_demote_status
      );
      IF g_debug_flag THEN
        Write_Debug('After: calling procedure Is_CO_On_Last_Imp_Phase.');
        Write_Debug('  l_is_co_last_phase =   ' || l_is_co_last_phase);
        Write_Debug('  l_auto_demote_status = ' || l_auto_demote_status);
        Write_Debug('  l_last_status_code =   ' || l_last_status_code);
        Write_Debug('  l_auto_demote_status = ' || l_auto_demote_status);
      END IF;


      -- If header is CO and is on last phase,
      -- set header phase to last phase before demotion

      -- If auto demotion phase is defined, set demotion status
      -- If auto demotion phase is not defined, demote to the previous phase
      IF ( l_auto_demote_status IS NOT NULL) THEN
        l_next_status_code := l_auto_demote_status;

        -- must set header phase to last implement phase before demotion
        -- just to make the CO implement phase demotion as a normal demotion
        UPDATE eng_engineering_changes
          SET status_type = G_ENG_IMPLEMENTED,
              status_code = l_last_status_code,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;
        l_curr_status_code := l_last_status_code;

        -- demote
        IF g_debug_flag THEN
           Write_Debug('Demoting header is needed ');
           Write_Debug('Before: calling Demote_Header procedure');
        END IF;

        Demote_Header
        ( p_api_version        => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => p_validation_level
         ,p_debug              => FND_API.G_FALSE
         ,p_output_dir         => p_output_dir
         ,p_debug_filename     => p_debug_filename
         ,x_return_status      => l_return_status
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data
         ,p_change_id          => p_change_id
         ,p_status_code        => l_auto_demote_status
         ,p_api_caller         => p_api_caller
        );
        IF g_debug_flag THEN
           Write_Debug('After: calling Demote_Header procedure: ' || l_return_status);
        END IF;
        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'Demote_Header');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF g_debug_flag THEN
          Write_Debug('Successful: calling DEMOTE_HEADER procedure ');
        END IF;

      ELSE -- no auto demotion for implement phase, set to previous phase

        NULL;
        /*
        UPDATE eng_engineering_changes
          SET status_type = p_status_code, --G_ENG_IMP_FAILED
              promote_status_code = NULL,
              last_update_date = sysdate,
              last_updated_by = l_fnd_user_id,
              last_update_login = l_fnd_login_id
          WHERE change_id = p_change_id;
        l_curr_status_code := l_last_status_code;

        -- no demotion, but refresh the implement phase workflow route if needed
        IF g_debug_flag THEN
          Write_Debug('Before: calling Refresh_WF_Route procedure ');
        END IF;
        Refresh_WF_Route
        ( p_api_version         => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE        --
         ,p_validation_level    => p_validation_level
         ,p_debug               => FND_API.G_FALSE
         ,p_output_dir          => p_output_dir
         ,p_debug_filename      => p_debug_filename
         ,x_return_status       => l_return_status
         ,x_msg_count           => l_msg_count
         ,x_msg_data            => l_msg_data
         ,p_change_id           => p_change_id
         ,p_status_code         => l_last_status_code
         ,p_wf_route_id         => NULL
         ,p_api_caller          => p_api_caller
         );
        IF g_debug_flag THEN
          Write_Debug('After: calling Refresh_WF_Route procedure: ' || l_return_status);
        END IF;
        */

      END IF;

    ELSE
      NULL; -- IMPOSSIBLE TO REACH THIS BLOCK, THEORETICALLY SPEAKING
      IF g_debug_flag THEN
        Write_Debug('Case x: this branch should never be reached! ') ;
      END IF;
    END IF;
     IF (      (p_api_caller IS NULL OR p_api_caller <> 'CP')
               AND p_route_status IS NOT NULL
               AND l_curr_status_type =12)
     THEN
          ENG_DOCUMENT_UTIL.Update_Approval_Status
            ( p_api_version         => 1.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_debug               => FND_API.G_FALSE
             ,p_output_dir          => p_output_dir
             ,p_debug_filename      => p_debug_filename
             ,x_return_status       => l_return_status     --
             ,x_msg_count           => l_msg_count         --
             ,x_msg_data            => l_msg_data          --
             ,p_change_id           => p_change_id         -- header's change_id
             ,p_approval_status     => l_chg_appr_status       -- header approval status
             ,p_wf_route_status     => p_route_status      -- workflow routing status (for document types)
             ,p_api_caller          => p_api_caller        -- Optionnal for future use
            );

elsif ( l_curr_status_type = 12 AND  p_route_status IS null)
    then


        ENG_DOCUMENT_UTIL.Update_Approval_Status
            ( p_api_version         => 1.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_debug               => FND_API.G_FALSE
             ,p_output_dir          => p_output_dir
             ,p_debug_filename      => p_debug_filename
             ,x_return_status       => l_return_status     --
             ,x_msg_count           => l_msg_count         --
             ,x_msg_data            => l_msg_data          --
             ,p_change_id           => p_change_id         -- header's change_id
             ,p_approval_status     => l_chg_appr_status       -- header approval status
             ,p_wf_route_status     => p_route_status      -- workflow routing status (for document types)
             ,p_api_caller          => p_api_caller        -- Optionnal for future use
            );
  END IF;
       -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Update_Lifecycle_States');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Update_Lifecycle_States;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Update_Lifecycle_States;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Update_Lifecycle_States;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
  END Update_Lifecycle_States;


  -- Procedure to refresh the route_id of the currently active phase of a particular
  -- change header, called by WF only
  PROCEDURE Refresh_WF_Route
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER
   ,p_status_code               IN   NUMBER
   ,p_wf_route_id               IN   NUMBER
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- or 'WF'
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Refresh_WF_Route';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    CURSOR c_currPhase IS
      SELECT *
        FROM eng_lifecycle_statuses
        WHERE entity_name = G_ENG_CHANGE
          AND entity_id1 = p_change_id
          AND status_code = p_status_code
          AND active_flag = 'Y'
      FOR UPDATE;
    l_row_counter        NUMBER := 0;
    l_phase_row          eng_lifecycle_statuses%ROWTYPE;
    l_wf_route_id        eng_lifecycle_statuses.change_wf_route_id%TYPE;
    l_wf_route_id_new    eng_lifecycle_statuses.change_wf_route_id%TYPE;
    l_wf_status          eng_lifecycle_statuses.workflow_status%TYPE;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Refresh_WF_Route;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
      Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Refresh_WF_Route log');
      Write_Debug('-----------------------------------------------------');
      Write_Debug('p_change_id         : ' || p_change_id );
      Write_Debug('p_status_code       : ' || p_status_code );
      IF (p_wf_route_id IS NULL)
      THEN
        Write_Debug('p_wf_route_id       : null' );
      ELSE
        Write_Debug('p_wf_route_id       : ' || p_wf_route_id );
      END IF;
      Write_Debug('p_api_caller        : ' || p_api_caller );
      Write_Debug('-----------------------------------------------------');
      Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------
    OPEN c_currPhase;
      LOOP
        FETCH c_currPhase
          INTO l_phase_row;
        EXIT WHEN c_currPhase%NOTFOUND;
        l_row_counter := l_row_counter + 1;

        l_wf_route_id := l_phase_row.change_wf_route_id;
        l_wf_status   := l_phase_row.workflow_status;

        /*
        -- Make sure a workflow is already associated with the current phase
        IF (l_wf_route_id IS NULL) THEN
          FND_MESSAGE.Set_Name('ENG','ENG_WF_NOT_DEFINED_ON_PHASE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        */

        -- if passed wf route id is null, it means to generate new id
        -- from the old id that's stored in the table, so we need to make sure
        -- first that the old id is not null
        IF (p_wf_route_id IS NULL)
        THEN
          IF g_debug_flag THEN
            Write_Debug('Branch: p_route_id is null') ;
          END IF;
          -- if the old wf route id doesn't exist then do nothing; otherwise refresh it
          IF (l_wf_route_id IS NOT NULL) THEN
            -- Get a new workflow route_id
            Eng_Change_Route_Util.REFRESH_ROUTE
            ( X_NEW_ROUTE_ID   => l_wf_route_id_new,
              P_ROUTE_ID       => l_wf_route_id,
              P_USER_ID        => l_fnd_user_id,
              P_API_CALLER     => p_api_caller
            );
            -- Replace the old id with the new id
            UPDATE eng_lifecycle_statuses
              SET change_wf_route_id = l_wf_route_id_new,
                  workflow_status = ENG_WORKFLOW_UTIL.G_RT_NOT_STARTED,
                  last_update_date = sysdate,
                  last_updated_by = l_fnd_user_id,
                  last_update_login = l_fnd_login_id
              WHERE CURRENT OF c_currPhase;
            IF g_debug_flag THEN
              Write_Debug('Updated route_id') ;
            END IF;
          END IF;

        -- else it is the regular case where wf route id is passed as not null
        ELSE
          IF g_debug_flag THEN
            Write_Debug('Branch: p_route_id is not null') ;
          END IF;
          UPDATE eng_lifecycle_statuses
            SET change_wf_route_id = p_wf_route_id,
                workflow_status = ENG_WORKFLOW_UTIL.G_RT_NOT_STARTED,
                last_update_date = sysdate,
                last_updated_by = l_fnd_user_id,
                last_update_login = l_fnd_login_id
            WHERE CURRENT OF c_currPhase;
          IF g_debug_flag THEN
            Write_Debug('Updated route_id') ;
          END IF;
        END IF;

    END LOOP;
    CLOSE c_currPhase;

    -- One and only one record should be found with the cursor
    IF (l_row_counter <> 1) THEN
      FND_MESSAGE.Set_Name('ENG','ENG_NOT_EXACTLY_ONE_RECORD');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Refresh_WF_Route') ;
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Refresh_WF_Route;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Refresh_WF_Route;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Refresh_WF_Route;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Refresh_WF_Route;



  -- Procedure to automatically initialize lifecycles for a new change header
  -- It also takes care of automatically launching the workflow if needed
  -- Note that this procedure can ONLY be called directly from UI
  -- In R12, Added p_init_status_code to speicify the initialized status code
  -- In R12, Added p_init_option  'WF_ONLY'  Start Only WF
  PROCEDURE Init_Lifecycle
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_api_caller                IN   VARCHAR2 := 'UI'
   ,p_init_status_code          IN   NUMBER   := NULL                   -- R12
   ,p_init_option               IN   VARCHAR2 := NULL                   -- R12
  )
  IS

    l_api_name           CONSTANT VARCHAR2(30)  := 'Init_Lifecycle';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_cm_type_code       eng_engineering_changes.change_mgmt_type_code%TYPE;
    l_base_cm_type_code  eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;
    l_bug_number         NUMBER := 0;

    l_initial_phase_sn   eng_lifecycle_statuses.sequence_number%TYPE;

    l_status_code        eng_lifecycle_statuses.status_code%TYPE;
    l_status_type        eng_engineering_changes.status_type%TYPE;
    l_sequence_number    eng_lifecycle_statuses.sequence_number%TYPE;
    l_wf_route_id        eng_lifecycle_statuses.change_wf_route_id%TYPE;

    l_pls_block          VARCHAR2(5000);

    -- for auto-propagation if it's defined for first phase
    l_auto_prop_flag     eng_type_org_properties.AUTO_PROPAGATE_FLAG%TYPE;
    l_change_notice      eng_engineering_changes.change_notice%TYPE;
    l_hierarchy_name     per_organization_structures.name%TYPE;
    l_org_name           org_organization_definitions.organization_name%TYPE;
    l_row_cnt            NUMBER := 0;
    CURSOR c_orgProp IS
      SELECT op.auto_propagate_flag,
             ec.change_notice,
             pos.name,
             ood.name organization_name
        FROM eng_type_org_properties op,
             eng_engineering_changes ec,
             per_organization_structures pos,
             hr_all_organization_units_tl ood
        WHERE ec.change_id = p_change_id
          --AND ec.PLM_OR_ERP_CHANGE = 'PLM'
          AND op.change_type_id = ec.change_order_type_id
          AND op.organization_id = ec.organization_id
          AND op.propagation_status_code = l_status_code
          AND ec.hierarchy_id IS NOT NULL
          AND ec.organization_id IS NOT NULL
          AND pos.organization_structure_id(+) = ec.hierarchy_id
          AND ood.organization_id(+) = ec.organization_id
          AND ood.LANGUAGE = USERENV('LANG');

    l_request_id         NUMBER := 0;

    l_action_id          eng_change_actions.action_id%TYPE;
    l_param_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_wf_only_flag       BOOLEAN ;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Init_Lifecycle;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Init_Lifecycle log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_init_status_code  : ' || p_init_status_code );
       Write_Debug('p_init_option       : ' || p_init_option );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------


    -- Get the first phase from the change header's lifecycle definition
    -- In R12, added p_init_status_code condition here
    SELECT min(sequence_number)
      INTO l_initial_phase_sn
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND (status_code = p_init_status_code  OR p_init_status_code IS NULL) ;

    -- bug 9036674, add the filter for status to avoid promote the completed
    -- initial stage, it can avoid the later check throw exception
    begin
      SELECT lcs.status_code, ecs.status_type
        INTO l_status_code, l_status_type
        FROM eng_lifecycle_statuses lcs,
             eng_change_statuses ecs
        WHERE lcs.entity_name = G_ENG_CHANGE
          AND lcs.entity_id1 = p_change_id
          AND lcs.active_flag = 'Y'
          AND lcs.sequence_number = l_initial_phase_sn
          AND ecs.status_code = lcs.status_code
          AND NVL(lcs.workflow_status, 'xxx') <> Eng_Workflow_Util.G_RT_COMPLETED -- for 9036674
          AND rownum = 1;
    exception
      when NO_DATA_FOUND then
        IF g_debug_flag THEN
           Write_Debug('The initial stage was promoted, exit Init_Lifecycle');
        END IF;
        return ;
    end;

    IF g_debug_flag THEN
       Write_Debug('After: getting first phase from lifecycle definitions');
    END IF;

    -- and set it in the eng_engineering_changes table
    UPDATE eng_engineering_changes
      SET status_code = l_status_code,
          status_type = l_status_type,
          initiation_date = sysdate
      WHERE change_id = p_change_id;

    IF g_debug_flag THEN
       Write_Debug('After: settting status_type and status_code of header to first phase');
    END IF;

    /*
    -- Get the current phase from change header
    SELECT status_code, status_type
      INTO l_status_code, l_status_type
      FROM eng_engineering_changes
      WHERE change_id = p_change_id;

    IF g_debug_flag THEN
       Write_Debug('After: getting current phase from change header');
    END IF;
    */

    -- Get the sequence number for the current phase
    SELECT sequence_number, change_wf_route_id
      INTO l_sequence_number, l_wf_route_id
      FROM eng_lifecycle_statuses
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND status_code = l_status_code;

    IF g_debug_flag THEN
       Write_Debug('After: getting lifecycle definitions for the current phase');
    END IF;

    /*
    -- Sanity check
    IF (l_sequence_number <> l_initial_phase_sn) THEN
      FND_MESSAGE.Set_Name('ENG','ENG_CURR_PHASE_NOT_FIRST');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF g_debug_flag THEN
      Write_Debug('After: sanity check of the current phase as the first phase');
    END IF;
    */

    -- Sanity check on workflow
    IF (l_wf_route_id IS NOT NULL) THEN
      IF g_debug_flag THEN
        Write_Debug('Initial phase has workflow.');
      END IF;
    END IF;

    -- Initialize workflow_status for all phases that have workflows
    UPDATE eng_lifecycle_statuses
      SET workflow_status = Eng_Workflow_Util.G_RT_NOT_STARTED,
          last_update_date = sysdate,
          last_updated_by = l_fnd_user_id,
          last_update_login = l_fnd_login_id
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND active_flag = 'Y'
        AND change_wf_route_id IS NOT NULL;
    IF g_debug_flag THEN
      Write_Debug('After updating eng_lifecycle_statuses.workflow_status.');
      Write_Debug('  Row count = ' || SQL%ROWCOUNT);
    END IF;

    IF g_debug_flag THEN
      Write_Debug('After: Initialize workflow_status for all phases that have workflows');
    END IF;

    -- Update current phase row
    UPDATE eng_lifecycle_statuses
      SET start_date = sysdate,
          last_update_date = sysdate,
          last_updated_by = l_fnd_user_id,
          last_update_login = l_fnd_login_id
      WHERE entity_name = G_ENG_CHANGE
        AND entity_id1 = p_change_id
        AND status_code = l_status_code
        AND active_flag = 'Y';

    IF g_debug_flag THEN
      Write_Debug('After updating eng_lifecycle_statuses.start_date.');
      Write_Debug('  Row count = ' || SQL%ROWCOUNT);
    END IF;

    IF g_debug_flag THEN
      Write_Debug('After: updating the current phase row');
    END IF;


    l_wf_only_flag := FALSE ;
    IF (p_init_option = 'WF_ONLY')
    THEN

IF g_debug_flag THEN
    Write_Debug('WF Only Flag is TRUE. . .');
END IF;

        l_wf_only_flag := TRUE ;

    END IF ;

    IF (NOT l_wf_only_flag)
    THEN


IF g_debug_flag THEN
    Write_Debug('Before: saving action log');
END IF;
        -- Record SUBMIT action log and raise submit business event
        l_action_id := 0;
        -- create new action log
        ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
        ( p_api_version           => 1.0
        , p_init_msg_list         => FND_API.G_FALSE        --
        , p_commit                => FND_API.G_FALSE        --
        , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
        , p_debug                 => p_debug --FND_API.G_FALSE
        , p_output_dir            => p_output_dir
        , p_debug_filename        => 'engact.CreateAction.log'
        , x_return_status         => l_return_status
        , x_msg_count             => l_msg_count
        , x_msg_data              => l_msg_data
        , p_action_type           => ENG_CHANGE_ACTIONS_UTIL.G_ACT_SUBMIT
        , p_object_name           => G_ENG_CHANGE
        , p_object_id1            => p_change_id
        , p_object_id2            => NULL
        , p_object_id3            => NULL
        , p_object_id4            => NULL
        , p_object_id5            => NULL
        , p_parent_action_id      => -1
        , p_status_code           => NULL
        , p_action_date           => SYSDATE
        , p_change_description    => NULL
        , p_user_id               => l_fnd_user_id
        , p_api_caller            => p_api_caller
        , x_change_action_id      => l_action_id
        );
        IF g_debug_flag THEN
           Write_Debug('After: saving action log: ' || l_return_status);
           Write_Debug('l_action_id       : ' || l_action_id );
        END IF;
        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
          x_return_status := l_return_status;
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
          --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
          --#FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF g_debug_flag THEN
           Write_Debug('Successful: saving action log');
        END IF;

        -- raise business event for SUBMIT action
        -- Select cm type and base type code for upcoming API calls
        SELECT eec.change_mgmt_type_code, ecot.base_change_mgmt_type_code
          INTO l_cm_type_code, l_base_cm_type_code
          FROM eng_engineering_changes eec,
               eng_change_order_types ecot
          WHERE eec.change_id = p_change_id
            AND ecot.change_order_type_id = eec.change_order_type_id;

     -- for nir set all included item approval status to submitted for approval
	IF (l_base_cm_type_code = 'NEW_ITEM_REQUEST') THEN
	   ENG_NIR_UTIL_PKG.set_nir_item_approval_status (p_change_id,
							  Eng_Workflow_Util.G_REQUESTED,
							  x_return_status => l_return_status,
							  x_msg_count => l_msg_count,
							  x_msg_data => l_msg_data);
	END IF;

        -- Raise the approval status change business event
        -- Adding event parameters to the list
        WF_EVENT.AddParameterToList
        ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
         ,p_value         => to_char(p_change_id)
         ,p_parameterList => l_param_list
         );
        WF_EVENT.AddParameterToList
        ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
         ,p_value         => l_base_cm_type_code
         ,p_parameterList => l_param_list
         );

        -- Raise event
        WF_EVENT.RAISE
        ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_SUBMIT
         ,p_event_key     => p_change_id
         ,p_parameters    => l_param_list
         );
        l_param_list.DELETE;


        -- auto propagate if necessary
        l_row_cnt := 0;
        OPEN c_orgProp;
          LOOP
            FETCH c_orgProp
              INTO l_auto_prop_flag,
                   l_change_notice,
                   l_hierarchy_name,
                   l_org_name;
            EXIT WHEN c_orgProp%NOTFOUND;

            l_row_cnt := l_row_cnt + 1;
            -- verify the uniqueness of the record
            IF (l_row_cnt > 1) THEN
              IF g_debug_flag THEN
                Write_Debug('Error: more than one propagation policy is found');
              END IF;
            END IF;

            IF g_debug_flag THEN
              Write_Debug('one record for propagation policy is found');
              Write_Debug('l_auto_prop_flag         : ' || l_auto_prop_flag );
              Write_Debug('l_change_notice          : ' || l_change_notice );
              Write_Debug('l_hierarchy_name         : ' || l_hierarchy_name );
              Write_Debug('l_org_name               : ' || l_org_name );
            END IF;

            IF ( l_auto_prop_flag = 'Y') THEN
              IF g_debug_flag THEN
                Write_Debug('which needs auto propagation');
              END IF;

              ENG_ECO_UTIL.Propagate_ECO
              (
                p_api_version          =>    1.0
               ,p_init_msg_list        =>    FND_API.G_FALSE
               ,p_commit               =>    FND_API.G_FALSE
               ,p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL
               ,p_debug                =>    p_debug --FND_API.G_FALSE
               ,p_output_dir           =>    p_output_dir
               ,p_debug_filename       =>    NULL --p_debug_filename
               ,x_return_status        =>    l_return_status
               ,x_msg_count            =>    l_msg_count
               ,x_msg_data             =>    l_msg_data
               ,p_change_id            =>    p_change_id
               ,p_change_notice        =>    l_change_notice
               ,p_hierarchy_name       =>    l_hierarchy_name
               ,p_org_name             =>    l_org_name
               ,x_request_id           =>    l_request_id
              );

              IF g_debug_flag THEN
                Write_Debug('After: calling propagate_eco API: ' || l_return_status);
              END IF;

              IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
                x_return_status := l_return_status;
                x_msg_count := l_msg_count;
                x_msg_data := l_msg_data;
                --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
                --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_ECO_UTIL.Propagate_ECO');
                --#FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF g_debug_flag THEN
                Write_Debug('Successful: calling propagate_eco API');
                Write_Debug('l_request_id       : ' || l_request_id );
              END IF;

              IF g_debug_flag THEN
                 Write_Debug('Before: saving action log');
              END IF;
              l_action_id := 0;
              -- create new action log
              -- Bug Fix: 3547844
              -- In case of Auto-Propgation Action Log
              -- Who column is Workflow
              ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
              ( p_api_version           => 1.0
              , p_init_msg_list         => FND_API.G_FALSE        --
              , p_commit                => FND_API.G_FALSE        --
              , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
              , p_debug                 => p_debug --FND_API.G_FALSE
              , p_output_dir            => p_output_dir
              , p_debug_filename        => NULL
              , x_return_status         => l_return_status
              , x_msg_count             => l_msg_count
              , x_msg_data              => l_msg_data
              , p_action_type           => ENG_CHANGE_ACTIONS_UTIL.G_ACT_PROPAGATE
              , p_object_name           => G_ENG_CHANGE
              , p_object_id1            => p_change_id
              , p_object_id2            => NULL
              , p_object_id3            => NULL
              , p_object_id4            => NULL
              , p_object_id5            => NULL
              , p_parent_action_id      => -1
              , p_status_code           => NULL
              , p_action_date           => SYSDATE
              , p_change_description    => NULL
              , p_user_id               => G_ENG_WF_USER_ID
              , p_api_caller            => 'WF'
              , x_change_action_id      => l_action_id
              );

              IF g_debug_flag THEN
                 Write_Debug('After: saving action log: ' || l_return_status);
                 Write_Debug('l_action_id       : ' || l_action_id );
              END IF;

              IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
              THEN
                x_return_status := l_return_status;
                x_msg_count := l_msg_count;
                x_msg_data := l_msg_data;
                --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
                --#FND_MESSAGE.Set_Token('OBJECT_NAME', 'ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action');
                --#FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF g_debug_flag THEN
                 Write_Debug('Successful: saving action log');
              END IF;

            ELSE
              IF g_debug_flag THEN
                Write_Debug('which does not need auto propagation');
              END IF;
            END IF;

          END LOOP;
        CLOSE c_orgProp;
        IF g_debug_flag THEN
           Write_Debug('After checking propagation policy');
        END IF;

    END IF ; -- (NOT l_wf_only_flag)


    -- Start workflow for new phase if necessary
    Start_WF_OnlyIf_Necessary
    ( p_api_version       => 1.0
     ,p_init_msg_list     => FND_API.G_FALSE
     ,p_commit            => FND_API.G_FALSE
     ,p_validation_level  => p_validation_level
     ,p_debug             => FND_API.G_FALSE
     ,p_output_dir        => p_output_dir
     ,p_debug_filename    => p_debug_filename
     ,x_return_status     => l_return_status
     ,x_msg_count         => l_msg_count
     ,x_msg_data          => l_msg_data
     ,p_change_id         => p_change_id
     ,p_status_code       => l_status_code
     ,p_status_type       => l_status_type
     ,p_sequence_number   => l_sequence_number
     --,p_imp_eco_flag      => 'N'
     ,p_api_caller        => p_api_caller
     ,p_action_type       => NULL
    );

    IF g_debug_flag THEN
       Write_Debug('After call to procedure Start_WF_OnlyIf_Necessary: ' || l_return_status);
    END IF;

    IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
      --#FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Init_Lifecycle') ;
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     --ROLLBACK TO Init_Lifecycle;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Init_Lifecycle;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Init_Lifecycle;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Init_Lifecycle;




  -- Procedure to be called by revised item implementation concurrent
  -- program to set its status_type
  PROCEDURE Update_RevItem_Lifecycle
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_rev_item_seq_id           IN   NUMBER
   ,p_status_type               IN   NUMBER                             -- say 10 for imp_failed
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- 'CP'
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Update_RevItem_Lifecycle';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

  BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT  Update_RevItem_Lifecycle;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Update_RevItem_Lifecycle log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_rev_item_seq_id   : ' || p_rev_item_seq_id );
       Write_Debug('p_status_type       : ' || p_status_type );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;


    -- Real code starts here -----------------------------------------------
    UPDATE eng_revised_items
      SET status_type = p_status_type,
          last_update_date = sysdate,
          last_updated_by = l_fnd_user_id,
          last_update_login = l_fnd_login_id
      WHERE revised_item_sequence_id = p_rev_item_seq_id;


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Update_RevItem_Lifecycle') ;
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO Update_RevItem_Lifecycle;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Update_RevItem_Lifecycle;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;
    WHEN OTHERS THEN
      --ROLLBACK TO Update_RevItem_Lifecycle;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Update_RevItem_Lifecycle;



  -- R12B Reset Phase
  -- Reset Phase
  -- R12B
  -- Called when Reset Workflow button pressed in Workflow UI
  -- to reset Dcoument Status
  -- If Change Object is Document LC Object, Call Document API to reset the phase
  PROCEDURE Reset_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER   := NULL                   -- reset phase/status code
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  )
  IS

    l_api_name           CONSTANT VARCHAR2(30)  := 'Reset_Phase';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_doc_lc_object_flag  BOOLEAN := FALSE ;

    l_cm_type_code       eng_engineering_changes.CHANGE_MGMT_TYPE_CODE%TYPE;
    l_base_cm_type_code  eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;

    l_next_status_code   NUMBER;
    l_reset_status_code  NUMBER;
    l_last_status_code   NUMBER;
    l_max_phase_sn       eng_lifecycle_statuses.sequence_number%TYPE;
    l_curr_status_type   eng_engineering_changes.status_type%TYPE;

    -- l_last_imp_flag      VARCHAR2(1) := 'N';


    -- Query the required parameters for current status
    -- Get the current phase, promote_phase and cm type of the change header
    CURSOR  c_cur_status (c_change_id NUMBER )
    IS
        SELECT eec.status_code
             , eec.promote_status_code
             , eec.change_mgmt_type_code
             , ecot.base_change_mgmt_type_code
          FROM eng_engineering_changes eec,
               eng_change_order_types ecot
          WHERE eec.change_id = c_change_id
            AND ecot.change_order_type_id = eec.change_order_type_id ;


    recinfo c_cur_status%rowtype;


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Reset_Phase ;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;


    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Reset_Phase log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || to_char(p_change_id) );
       Write_Debug('p_status_code       : ' || to_char(p_status_code) );
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------


IF g_debug_flag THEN
    Write_Debug('Get the current status code to be reset ');
END IF;

    OPEN c_cur_status(c_change_id => p_change_id) ;
    FETCH c_cur_status into recinfo ;
    IF (c_cur_status%notfound) THEN
       CLOSE c_cur_status;
       RAISE no_data_found;
    END IF;

    IF (c_cur_status%ISOPEN) THEN
       CLOSE c_cur_status ;
    END IF ;

    l_reset_status_code := recinfo.status_code ;
    l_next_status_code  := recinfo.promote_status_code ;
    l_cm_type_code      := recinfo.change_mgmt_type_code ;
    l_base_cm_type_code := recinfo.base_change_mgmt_type_code ;

    IF g_debug_flag THEN
        Write_Debug('Got current status code : ' || to_char(l_reset_status_code) );
    END IF;

    IF l_reset_status_code IS NULL THEN
        -- This should not happen
        FND_MESSAGE.SET_NAME('ENG', 'ENG_STATUS_CODE_NULL') ;
        FND_MSG_PUB.Add ;
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;

    IF (p_status_code IS NOT NULL AND l_reset_status_code <> p_status_code )
    THEN

        -- This should not happen
        FND_MESSAGE.SET_NAME('ENG', 'ENG_RESET_STATUS_NOT_CUR') ;
        FND_MSG_PUB.Add ;
        RAISE FND_API.G_EXC_ERROR ;

    END IF ;

    -- Get the current phase status_type
    SELECT status_type
      INTO l_curr_status_type
      FROM eng_change_statuses
      WHERE status_code = l_reset_status_code;

    --
    -- Get the current phase's sequence number
    -- SELECT sequence_number
    --   INTO l_curr_phase_sn
    --   FROM eng_lifecycle_statuses
    --   WHERE entity_name = G_ENG_CHANGE
    --     AND entity_id1 = p_change_id
    --     AND status_code = l_reset_status_code
    --     AND active_flag = 'Y'
    --     AND rownum = 1;
    --

    -- Check if the current phase is of type APPROVAL,
    -- and if it is the last such phase in the lifecycle of the change header
    --
    IF (l_curr_status_type in (G_ENG_APPROVED ,G_ENG_REVIEWED))
    THEN

IF g_debug_flag THEN
    Write_Debug('Current phase is of type APPROVAL...');
END IF;
        -- if l_curr_status_type <> 12
         --THEN
          -- Update change header approval status
          -- Launch header approval status change workflow
          Update_Header_Appr_Status
          (
            p_api_version               =>  1.0
           ,p_init_msg_list             =>  FND_API.G_FALSE
           ,p_commit                    =>  FND_API.G_FALSE
           ,p_validation_level          =>  FND_API.G_VALID_LEVEL_FULL
           ,p_debug                     =>  FND_API.G_FALSE
           ,p_output_dir                =>  p_output_dir
           ,p_debug_filename            =>  p_debug_filename
           ,x_return_status             =>  l_return_status
           ,x_msg_count                 =>  l_msg_count
           ,x_msg_data                  =>  l_msg_data
           ,p_change_id                 =>  p_change_id
           ,p_status_code               =>  l_reset_status_code
           ,p_appr_status               =>  G_ENG_APPR_REQUESTED
           ,p_route_status              =>  Eng_Workflow_Util.G_RT_NOT_STARTED
           ,p_api_caller                =>  p_api_caller
           ,p_bypass                    =>  'N'
          );
      /* ELSE


        ENG_DOCUMENT_UTIL.Update_Approval_Status
            ( p_api_version         => 1.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_debug               => FND_API.G_FALSE
             ,p_output_dir          => p_output_dir
             ,p_debug_filename      => p_debug_filename
             ,x_return_status       => l_return_status     --
             ,x_msg_count           => l_msg_count         --
             ,x_msg_data            => l_msg_data          --
             ,p_change_id           => p_change_id         -- header's change_id
             ,p_approval_status     => G_ENG_APPR_REQUESTED-- header approval status
             ,p_wf_route_status     => Eng_Workflow_Util.G_RT_NOT_STARTED      -- workflow routing status (for document types)
             ,p_api_caller          => p_api_caller        -- Optionnal for future use
            );
      END IF;*/


IF g_debug_flag THEN
    Write_Debug('After: Update_Header_Appr_Status: ' || l_return_status );
END IF;


          IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
          THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF g_debug_flag THEN
            Write_Debug('After: calling Update_Header_Appr_Status');
          END IF;

    END IF; -- current status type is  G_ENG_APPROVED

    -- R12B
    -- In case of Document LC Change Object, call ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase
    -- to validate and sync Document LC Phase
    l_doc_lc_object_flag := ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle
                               ( p_change_id => p_change_id
                               , p_base_change_mgmt_type_code => l_base_cm_type_code
                               )  ;

    IF (l_doc_lc_object_flag)
    THEN
        IF l_reset_status_code IS NULL
        THEN

            IF g_debug_flag THEN
                 Write_Debug('param p_status_code is null, get the current status code to be reset ');
            END IF;

            OPEN c_cur_status(c_change_id => p_change_id) ;
            FETCH c_cur_status into recinfo;
            IF (c_cur_status%notfound) THEN
                CLOSE c_cur_status;
                RAISE no_data_found;

            END IF;

            IF (c_cur_status%ISOPEN) THEN
                CLOSE c_cur_status ;
            END IF ;

            l_reset_status_code := recinfo.status_code ;

            IF g_debug_flag THEN
                 Write_Debug('Got current status code : ' || to_char(l_reset_status_code) );
            END IF;

            IF l_reset_status_code IS NULL THEN
                -- This should not happen
                FND_MESSAGE.SET_NAME('ENG', 'ENG_STATUS_CODE_NULL') ;
                FND_MSG_PUB.Add ;
                RAISE FND_API.G_EXC_ERROR ;
            END IF ;

        END IF ;

        IF g_debug_flag THEN
             Write_Debug('Before: calling ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase');
             Write_Debug('  Status Code= ' || to_char(l_reset_status_code));
        END IF;

        ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase
        ( p_api_version         => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => p_validation_level
         ,p_debug               => FND_API.G_FALSE
         ,p_output_dir          => p_output_dir
         ,p_debug_filename      => p_debug_filename
         ,x_return_status       => l_return_status
         ,x_msg_count           => l_msg_count
         ,x_msg_data            => l_msg_data
         ,p_change_id           => p_change_id
         ,p_lc_phase_code       => l_reset_status_code
         ,p_action_type         => G_ENG_PROMOTE
         ,p_api_caller          => p_api_caller
        ) ;

        IF g_debug_flag THEN
            Write_Debug('After: calling ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase: ' || l_return_status) ;
        END IF;

        IF ( l_return_status <>  FND_API.G_RET_STS_SUCCESS )
        THEN
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF g_debug_flag THEN
             Write_Debug('Successful: ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase');
        END IF;

    END IF ; -- if ( Change Object is Documet LC Object)


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: Promote_Header');
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
          ROLLBACK TO Reset_Phase ;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

      IF g_debug_flag THEN
        Write_Debug('Finish with expected error.') ;
      END IF;

      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
          ROLLBACK TO Reset_Phase ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;


      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;


    WHEN OTHERS THEN

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
          ROLLBACK TO Reset_Phase ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );


      IF g_debug_flag THEN
        Write_Debug('Finish with other error.') ;
      END IF;

      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Reset_Phase ;


  --
  -- R12B Sync Workflow Statuses/Lifecycle Phases
  -- If a phase is added or removed in an existing lifecycle setup which is already being used by
  -- some change objects including document lc change objects  then the lifecycles of the change object
  --  would be affected as below:
  --
  --   1. Adding a Phase: For all Change Objects the lifecycle that is being updated,
  --      would get this newly added Phase, if they have not already gone past that phase.
  --      For Change Objects that are already past the phase, these will not be affected.
  --
  --   2. Removing a Phase: Similar to the addition, the removal of the phase would also happen only for those
  --      change objects that have not reached the Phase being removed.
  --      For Change Objects already past the Phase, will not be affected for history purposes.
  --      If a Change Object is in a Phase that is being removed, then it should not be affected.
  --
  --   3. Updating a Phase Property: Phase Property update will not be affected.
  --
  -- This API will support the above syncronization and be called when the user update the LC Phase Setup and
  -- confirm to go ahead with  reflecting the changes to existing lifecycles of the change object.
  --
  PROCEDURE Sync_LC_Phase_Setup
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_type_id            IN   NUMBER                             -- header's change_type_id
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Future Use
  )
  IS

    l_api_name           CONSTANT VARCHAR2(30)  := 'Sync_LC_Phase_Setup';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    -- Cursor to Fetch all the life cycle Statuses for corresponding Type.
    CURSOR  c_lc_phase_setup (c_change_type_id NUMBER )
    IS
       SELECT CHANGE_LIFECYCLE_STATUS_ID
            , SEQUENCE_NUMBER
            , STATUS_CODE
            , AUTO_PROMOTE_STATUS
            , AUTO_DEMOTE_STATUS
            , CHANGE_EDITABLE_FLAG
            , CHANGE_WF_ROUTE_ID
            , ENTITY_ID1 CHANGE_TYPE_ID
      FROM eng_lifecycle_statuses
      WHERE entity_name = 'ENG_CHANGE_TYPE'
      AND entity_id1 = c_change_type_id
      ORDER BY SEQUENCE_NUMBER ASC ;

    l_return_status       VARCHAR2(1);
    l_err_text            VARCHAR2(2000) ;
    l_Mesg_Token_Tbl      Error_Handler.Mesg_Token_Tbl_Type ;


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Sync_LC_Phase_Setup ;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Sync_LC_Phase_Setup log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_type_id    : ' || to_char(p_change_type_id));
       Write_Debug('p_api_caller        : ' || p_api_caller );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF p_api_caller = 'WF' THEN
      l_fnd_user_id := G_ENG_WF_USER_ID;
      l_fnd_login_id := G_ENG_WF_LOGIN_ID;
    ELSIF p_api_caller = 'CP' THEN
      l_fnd_user_id := G_ENG_CP_USER_ID;
      l_fnd_login_id := G_ENG_CP_LOGIN_ID;
    END IF;

    -- Real code starts here -----------------------------------------------

    -------------------------------------------------------------------------------------------
    --   1. Adding a Phase: For all Change Objects the lifecycle that is being updated,
    --      would get this newly added Phase, if they have not already gone past that phase.
    --      For Change Objects that are already past the phase, these will not be affected.
    -------------------------------------------------------------------------------------------


IF g_debug_flag THEN
   Write_Debug(' Add LC Phase for submitted Change Objects . . .') ;
END IF ;

        -- Insert the statuses data if it does not exists in change objects that have not gone past the phase
        -- and the phase does not exist in lifecycle of the change objects
        INSERT INTO ENG_LIFECYCLE_STATUSES
        (   CHANGE_LIFECYCLE_STATUS_ID
          , ENTITY_NAME
          , ENTITY_ID1
          , ENTITY_ID2
          , ENTITY_ID3
          , ENTITY_ID4
          , ENTITY_ID5
          , SEQUENCE_NUMBER
          , STATUS_CODE
          , START_DATE
          , COMPLETION_DATE
          , CHANGE_WF_ROUTE_ID
          , AUTO_PROMOTE_STATUS
          , AUTO_DEMOTE_STATUS
          , WORKFLOW_STATUS
          , CHANGE_EDITABLE_FLAG
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , LAST_UPDATE_LOGIN
          , ITERATION_NUMBER
          , ACTIVE_FLAG
          , CHANGE_WF_ROUTE_TEMPLATE_ID
        )
        SELECT
            ENG_LIFECYCLE_STATUSES_S.NEXTVAL
          , G_ENG_CHANGE
          , ch.CHANGE_ID
          , NULL -- ENTITY_ID2
          , NULL -- ENTITY_ID3
          , NULL -- ENTITY_ID4
          , NULL -- ENTITY_ID5
          , change_type.SEQUENCE_NUMBER
          , change_type.STATUS_CODE
          , NULL -- START_DATE
          , NULL -- COMPLETION_DATE
          , NULL -- CHANGE_WF_ROUTE_ID
          , change_type.AUTO_PROMOTE_STATUS
          , change_type.AUTO_DEMOTE_STATUS
          , NULL -- WORKFLOW_STATUS
          , change_type.CHANGE_EDITABLE_FLAG
          , SYSDATE
          , l_fnd_user_id
          , SYSDATE
          , l_fnd_user_id
          , l_fnd_login_id
          , cur_phase.ITERATION_NUMBER
          , 'S'
          , change_type.CHANGE_WF_ROUTE_ID
        FROM ENG_ENGINEERING_CHANGES ch
           , ENG_LIFECYCLE_STATUSES cur_phase
           , ENG_LIFECYCLE_STATUSES change_type
        WHERE change_type.entity_id1 = p_change_type_id
         AND change_type.entity_name = 'ENG_CHANGE_TYPE'
         AND ch.CHANGE_ORDER_TYPE_ID = change_type.entity_id1
         AND ch.STATUS_TYPE NOT IN (0, 5, 6, 11) -- exclude draft, cancel, implemented, completed
         AND ch.plm_or_erp_change = 'PLM'
         AND cur_phase.entity_name  = G_ENG_CHANGE
         AND cur_phase.entity_id1   = ch.CHANGE_ID
         AND cur_phase.active_flag  = 'Y'
         AND cur_phase.status_code  = ch.STATUS_CODE
         AND cur_phase.SEQUENCE_NUMBER < change_type.SEQUENCE_NUMBER
         AND NOT EXISTS ( SELECT 'exists'
                          FROM  ENG_LIFECYCLE_STATUSES change_lc_phase
                          WHERE change_lc_phase.entity_name  = G_ENG_CHANGE
                          AND   change_lc_phase.entity_id1   = ch.CHANGE_ID
                          AND   change_lc_phase.active_flag  = 'Y'
                          AND   change_lc_phase.status_code  = change_type.STATUS_CODE
                          AND   change_lc_phase.SEQUENCE_NUMBER = change_type.SEQUENCE_NUMBER
                        ) ;



IF g_debug_flag THEN
   IF SQL%FOUND THEN
      Write_Debug(' Add LC Phase for Submitted Change Object:' || to_char(SQL%ROWCOUNT)) ;
   END IF ;
END IF ;

IF g_debug_flag THEN
   Write_Debug(' Add LC Phase for Draft Change Objects. . .') ;
END IF ;

        -- Add LC Phase for Draft Change Objects
        INSERT INTO ENG_LIFECYCLE_STATUSES
        (   CHANGE_LIFECYCLE_STATUS_ID
          , ENTITY_NAME
          , ENTITY_ID1
          , ENTITY_ID2
          , ENTITY_ID3
          , ENTITY_ID4
          , ENTITY_ID5
          , SEQUENCE_NUMBER
          , STATUS_CODE
          , START_DATE
          , COMPLETION_DATE
          , CHANGE_WF_ROUTE_ID
          , AUTO_PROMOTE_STATUS
          , AUTO_DEMOTE_STATUS
          , WORKFLOW_STATUS
          , CHANGE_EDITABLE_FLAG
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , LAST_UPDATE_LOGIN
          , ITERATION_NUMBER
          , ACTIVE_FLAG
          , CHANGE_WF_ROUTE_TEMPLATE_ID
        )
        SELECT
            ENG_LIFECYCLE_STATUSES_S.NEXTVAL
          , G_ENG_CHANGE
          , ch.CHANGE_ID
          , NULL -- ENTITY_ID2
          , NULL -- ENTITY_ID3
          , NULL -- ENTITY_ID4
          , NULL -- ENTITY_ID5
          , change_type.SEQUENCE_NUMBER
          , change_type.STATUS_CODE
          , NULL -- START_DATE
          , NULL -- COMPLETION_DATE
          , NULL -- CHANGE_WF_ROUTE_ID
          , change_type.AUTO_PROMOTE_STATUS
          , change_type.AUTO_DEMOTE_STATUS
          , NULL -- WORKFLOW_STATUS
          , change_type.CHANGE_EDITABLE_FLAG
          , SYSDATE
          , l_fnd_user_id
          , SYSDATE
          , l_fnd_user_id
          , l_fnd_login_id
          , 0   -- ITERATION_NUMBER
          , 'S' -- ACTIVE_FLAG
          , change_type.CHANGE_WF_ROUTE_ID
        FROM ENG_ENGINEERING_CHANGES ch
           , ENG_LIFECYCLE_STATUSES change_type
        WHERE change_type.entity_id1 = p_change_type_id
         AND change_type.entity_name = 'ENG_CHANGE_TYPE'
         AND ch.CHANGE_ORDER_TYPE_ID = change_type.entity_id1
         AND ch.STATUS_CODE = 0 -- DRAFT
         AND NOT EXISTS ( SELECT 'exists'
                           FROM  ENG_LIFECYCLE_STATUSES change_lc_phase
                           WHERE change_lc_phase.entity_name  = G_ENG_CHANGE
                           AND   change_lc_phase.entity_id1   = ch.CHANGE_ID
                           AND   change_lc_phase.active_flag  = 'Y'
                           AND   change_lc_phase.status_code  = change_type.STATUS_CODE
                           AND   change_lc_phase.SEQUENCE_NUMBER = change_type.SEQUENCE_NUMBER
                         ) ;


IF g_debug_flag THEN
   IF SQL%FOUND THEN
      Write_Debug(' Added LC Phase for Draft Change Objects:' || to_char(SQL%ROWCOUNT)) ;
   END IF ;
END IF ;


IF g_debug_flag THEN
   Write_Debug(' Add LC Phase Properties for reocrds for active_flag S. . .') ;
END IF ;

        -- Add LC Phase Properties for reocrds for active_flag S
        -- Inserting the status properties
        INSERT INTO  ENG_STATUS_PROPERTIES
        (
            CHANGE_LIFECYCLE_STATUS_ID
          , STATUS_CODE
          , PROMOTION_STATUS_FLAG
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , LAST_UPDATE_LOGIN
        )
        SELECT
            lc_phase.CHANGE_LIFECYCLE_STATUS_ID
          , phase_prop_setup.STATUS_CODE
          , phase_prop_setup.PROMOTION_STATUS_FLAG
          , SYSDATE
          , l_fnd_user_id
          , SYSDATE
          , l_fnd_user_id
          , l_fnd_login_id
        FROM ENG_STATUS_PROPERTIES  phase_prop_setup
           , ENG_LIFECYCLE_STATUSES lc_phase_setup
           , ENG_LIFECYCLE_STATUSES lc_phase
           , ENG_ENGINEERING_CHANGES ch
        WHERE lc_phase_setup.entity_id1   = p_change_type_id
          AND lc_phase_setup.entity_name = 'ENG_CHANGE_TYPE'
          AND phase_prop_setup.CHANGE_LIFECYCLE_STATUS_ID = lc_phase_setup.CHANGE_LIFECYCLE_STATUS_ID
          AND ch.CHANGE_ORDER_TYPE_ID = lc_phase_setup.ENTITY_ID1
          AND ch.STATUS_TYPE NOT IN (5, 6, 11) -- exclude cancel, implemented, completed
          AND lc_phase.entity_name  = G_ENG_CHANGE
          AND lc_phase.entity_id1   = ch.CHANGE_ID
          AND lc_phase.SEQUENCE_NUMBER = lc_phase_setup.SEQUENCE_NUMBER
          AND lc_phase.STATUS_CODE = lc_phase_setup.STATUS_CODE
          AND lc_phase.ACTIVE_FLAG = 'S' ;


IF g_debug_flag THEN
   IF SQL%FOUND THEN
      Write_Debug(' Added LC Phase Properties: ' || to_char(SQL%ROWCOUNT)) ;
   END IF ;
END IF ;



IF g_debug_flag THEN
   Write_Debug(' -------------------------------------------') ;
END IF ;

    --
    --   2. Removing a Phase: Similar to the addition, the removal of the phase would also happen only for those
    --      change objects that have not reached the Phase being removed.
    --      For Change Objects already past the Phase, will not be affected for history purposes.
    --      If a Change Object is in a Phase that is being removed, then it should not be affected.
    --
    --   NOTE: Internally we hide the phase by changing active flag  to 'D'
    --

IF g_debug_flag THEN
   Write_Debug(' Removing a Phase. . .') ;
END IF ;


    UPDATE ENG_LIFECYCLE_STATUSES
    SET  ACTIVE_FLAG  = 'D'
    WHERE CHANGE_LIFECYCLE_STATUS_ID IN (
                                          SELECT change_phase.CHANGE_LIFECYCLE_STATUS_ID
                                          FROM ENG_ENGINEERING_CHANGES ch
                                             , ENG_LIFECYCLE_STATUSES cur_phase
                                             , ENG_LIFECYCLE_STATUSES change_phase
                                          WHERE ch.CHANGE_ORDER_TYPE_ID = p_change_type_id
                                          AND ch.STATUS_TYPE NOT IN (5, 6, 11) -- exclude cancel, implemented, completed
                                          AND cur_phase.entity_name  = G_ENG_CHANGE
                                          AND cur_phase.entity_id1   = ch.CHANGE_ID
                                          AND cur_phase.active_flag  = 'Y'
                                          AND cur_phase.status_code  = ch.STATUS_CODE
                                          AND cur_phase.SEQUENCE_NUMBER < change_phase.SEQUENCE_NUMBER
                                          AND change_phase.entity_name  = 'ENG_CHANGE'
                                          AND change_phase.entity_id1   = ch.CHANGE_ID
                                          AND change_phase.active_flag  = 'Y'
                                          AND NOT EXISTS ( SELECT 'exists'
                                                           FROM  eng_lifecycle_statuses lc_phase_setup
                                                           WHERE lc_phase_setup.entity_name  = 'ENG_CHANGE_TYPE'
                                                           AND   lc_phase_setup.entity_id1   = ch.CHANGE_ORDER_TYPE_ID
                                                           AND   lc_phase_setup.SEQUENCE_NUMBER = change_phase.SEQUENCE_NUMBER
                                                           AND   lc_phase_setup.STATUS_CODE = change_phase.STATUS_CODE
                                                          )
                                          UNION ALL
                                          SELECT change_phase.CHANGE_LIFECYCLE_STATUS_ID
                                          FROM   ENG_ENGINEERING_CHANGES ch
                                               , ENG_LIFECYCLE_STATUSES change_phase
                                          WHERE ch.CHANGE_ORDER_TYPE_ID = p_change_type_id
                                          AND ch.STATUS_CODE = 0 -- DRAFT
                                          AND ch.STATUS_TYPE NOT IN (5, 6, 11) -- exclude cancel, implemented, completed
                                          AND change_phase.entity_name  = G_ENG_CHANGE
                                          AND change_phase.entity_id1   = ch.CHANGE_ID
                                          AND change_phase.active_flag  = 'Y'
                                          AND NOT EXISTS ( SELECT 'exists'
                                                           FROM  eng_lifecycle_statuses lc_phase_setup
                                                           WHERE lc_phase_setup.entity_name  = 'ENG_CHANGE_TYPE'
                                                           AND   lc_phase_setup.entity_id1   = ch.CHANGE_ORDER_TYPE_ID
                                                           AND   lc_phase_setup.SEQUENCE_NUMBER = change_phase.SEQUENCE_NUMBER
                                                           AND   lc_phase_setup.STATUS_CODE = change_phase.STATUS_CODE
                                                         )
                                         ) ;



IF g_debug_flag THEN
   IF SQL%FOUND THEN
      Write_Debug(' Removed Phases. . .' || to_char(SQL%ROWCOUNT)) ;
   END IF ;
END IF ;


IF g_debug_flag THEN
   Write_Debug(' Mass Update Change LC Phases marked as S to make them Activie. . .') ;
END IF ;

    -- 3. Mass Update Change LC Phases marked as 'S' in the above process of syncronization of newly added phase.
    --  to make them Activie
    UPDATE ENG_LIFECYCLE_STATUSES lc_phase
    SET  lc_phase.ACTIVE_FLAG  = 'Y'
    WHERE lc_phase.CHANGE_LIFECYCLE_STATUS_ID IN (
                                          SELECT added_change_phase.CHANGE_LIFECYCLE_STATUS_ID
                                          FROM ENG_ENGINEERING_CHANGES ch
                                             , ENG_LIFECYCLE_STATUSES added_change_phase
                                          WHERE ch.CHANGE_ORDER_TYPE_ID = p_change_type_id
                                          AND ch.STATUS_TYPE NOT IN (5, 6, 11) -- exclude cancel, implemented, completed
                                          AND added_change_phase.entity_name  = G_ENG_CHANGE
                                          AND added_change_phase.entity_id1   = ch.CHANGE_ID
                                          AND added_change_phase.active_flag  = 'S'
                                         ) ;


IF g_debug_flag THEN
   IF SQL%FOUND THEN
      Write_Debug(' Mass Update Change to make added phase active: ' || to_char(SQL%ROWCOUNT)) ;
   END IF ;
END IF ;



    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of procedure: ' || l_api_name);
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
          ROLLBACK TO Sync_LC_Phase_Setup ;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

      IF g_debug_flag THEN
        Write_Debug('Finish with expected error.') ;
      END IF;

      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
          ROLLBACK TO Sync_LC_Phase_Setup ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF;


      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;


    WHEN OTHERS THEN

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
          ROLLBACK TO Sync_LC_Phase_Setup ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );


      IF g_debug_flag THEN
        Write_Debug('Finish with other error.') ;
      END IF;

      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session;
      END IF;

  END Sync_LC_Phase_Setup ;


END ENG_CHANGE_LIFECYCLE_UTIL;


/
