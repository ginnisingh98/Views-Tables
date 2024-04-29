--------------------------------------------------------
--  DDL for Package Body ENG_DOCUMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DOCUMENT_UTIL" AS
/* $Header: ENGUDOCB.pls 120.14 2006/11/14 08:47:20 asjohal noship $ */


  PLSQL_COMPILE_ERROR EXCEPTION;
  PRAGMA EXCEPTION_INIT(PLSQL_COMPILE_ERROR, -6550);

  G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ENG_DOCUMENT_UTIL' ;

  -- For Debug
  g_debug_flag            BOOLEAN       := FALSE ;
  g_output_dir            VARCHAR2(240) := NULL ;
  g_debug_filename        VARCHAR2(200) := NULL ;
  g_debug_errmesg         VARCHAR2(240);
  G_BO_IDENTIFIER         VARCHAR2(30) := 'ENG_DOCUMENT_UTIL';
  G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);
  g_profile_debug_option  VARCHAR2(10) ;
  g_profile_debug_level   VARCHAR2(10) ;


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

         FND_FILE.put_line(FND_FILE.LOG, 'Log file location --> '||l_log_output_dir||'/'||g_debug_filename ||' created with status '|| l_log_return_status);
         FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Open_Debug_Session LOGGING SQL ERROR => '||g_debug_errmesg);
         g_debug_flag := FALSE;
  END Open_Debug_Session ;


  -- Close Debug_Session
  PROCEDURE Close_Debug_Session
  IS
  BEGIN

       -----------------------------------------------------------------------------
       -- Close Error_Handler debug session, only if Debug session is already open.
       -----------------------------------------------------------------------------
       IF (Error_Handler.Get_Debug = 'Y') THEN
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
         Open_Debug_Session(p_output_dir => p_output_dir, p_file_name => p_file_name) ;
       END IF;

    END IF;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Check_And_Open_Debug_Session LOGGING SQL ERROR => '||g_debug_errmesg);
         g_debug_flag := FALSE;
  END Check_And_Open_Debug_Session;



  /********************************************************************
  * API Type      : Private APIs
  * Purpose       : Those APIs are private
  *********************************************************************/
  FUNCTION Is_Dom_Document_Lifecycle( p_change_id                  IN NUMBER
                                    , p_base_change_mgmt_type_code IN VARCHAR2 := NULL
                                    )
  RETURN BOOLEAN
  IS
      l_base_change_mgmt_type_code VARCHAR2(30) ;

      CURSOR  c_change_mgmt_cur (c_change_id NUMBER)
      IS
           SELECT eec.change_mgmt_type_code
                , ecot.base_change_mgmt_type_code
           FROM eng_engineering_changes eec,
                eng_change_order_types ecot
           WHERE ecot.change_order_type_id = eec.change_order_type_id
           AND eec.change_id = c_change_id ;


  BEGIN


      l_base_change_mgmt_type_code := p_base_change_mgmt_type_code ;

      IF  l_base_change_mgmt_type_code IS  NULL
      THEN

        FOR l_rec IN c_change_mgmt_cur (c_change_id => p_change_id)
        LOOP
            l_base_change_mgmt_type_code :=  l_rec.base_change_mgmt_type_code  ;
        END LOOP ;

      END IF ;


      IF l_base_change_mgmt_type_code = G_DOM_DOCUMENT_LIFECYCLE
      THEN

          RETURN TRUE  ;

      ELSE

          RETURN FALSE ;

      END IF ;


  END Is_Dom_Document_Lifecycle ;


  PROCEDURE Get_Document_Revision_Id( p_change_id                 IN  NUMBER
                                    , x_document_id               OUT NOCOPY NUMBER
                                    , x_document_revision_id      OUT NOCOPY NUMBER
                                    )
  IS

  BEGIN


     SELECT TO_NUMBER(pk2_value)  document_revision_id
          , TO_NUMBER(pk1_value)  document_id
     INTO   x_document_revision_id
          , x_document_id
     FROM  ENG_CHANGE_SUBJECTS subj
     WHERE subj.entity_name = 'DOM_DOCUMENT_REVISION'
     AND   subj.change_id  = p_change_id
     AND   ROWNUM = 1 ;

  END  Get_Document_Revision_Id ;


  -- Get Document Revision Info
  PROCEDURE Get_Document_Rev_Info
  (  p_document_revision_id      IN NUMBER
   , x_document_id               OUT NOCOPY NUMBER
   , x_document_number           OUT NOCOPY VARCHAR2
   , x_document_revision         OUT NOCOPY VARCHAR2
   , x_documnet_name             OUT NOCOPY VARCHAR2
   , x_document_detail_page_url  OUT NOCOPY VARCHAR2
  )
  IS


  BEGIN

      SELECT dom_doc.document_id
           , dom_doc.doc_number
           , dom_doc_rev.revision
           , dom_doc.name
       INTO  x_document_id
           , x_document_number
           , x_document_revision
           , x_documnet_name
        FROM dom_documents_vl        dom_doc
           , dom_document_revisions  dom_doc_rev
       WHERE dom_doc.document_id  = dom_doc_rev.document_id
       AND   dom_doc_rev.revision_id = p_document_revision_id ;

       -- Get Document Revision Overview Page URL using RF.jsp version
       -- e.g. OA.jsp?OAFunc=DOM_DOC_OVERVIEW&documentId=999&revisionId=7777
       x_document_detail_page_url := Eng_Workflow_Ntf_Util.GetRunFuncURL
                          ( p_function_name => 'DOM_DOC_OVERVIEW'
                          , p_parameters    => '&documentId=' || TO_CHAR(x_document_id) || '&revisionId=' || TO_CHAR(p_document_revision_id) ) ;

  END Get_Document_Rev_Info ;



  --
  -- Wrapper API to integrate DOM Document API when Updating Approval Status
  -- of Document LC Phase Change Object
  --
  PROCEDURE Update_Approval_Status
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
   ,p_approval_status           IN   NUMBER                             -- header new approval status
   ,p_wf_route_status           IN   VARCHAR2                           -- workflow routing status (for document types)
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN

      -- For Test/Debug
      Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

IF g_debug_flag THEN
   Write_Debug('ENG_DOCUMENT_UTIL.Update_Approval_Status Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id          : ' || TO_CHAR(p_change_id) );
   Write_Debug('Approval Status    : ' || TO_CHAR(p_approval_status) );
   Write_Debug('Workflow Status    : ' || p_wf_route_status);
   Write_Debug('API Caller         : ' || p_api_caller);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Calling DOM_LIFECYCLE_UTIL.UPDATE_APPROVAL_STATUS');
END IF ;


      l_return_status := FND_API.G_RET_STS_SUCCESS ;

      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      l_pls_block :=    ' BEGIN '
                          || '  DOM_DOCUMENT_UTIL.UPDATE_APPROVAL_STATUS'
                          || '  ( p_api_version        => :1 '
                          || '   ,p_init_msg_list      => :2 '
                          || '   ,p_commit             => :3 '
                          || '   ,p_validation_level   => :4 '
                          || '   ,x_return_status      => :5 '
                          || '   ,x_msg_count          => :6 '
                          || '   ,x_msg_data           => :7 '
                          || '   ,p_change_id          => :8 '
                          || '   ,p_approval_status    => :9 '
                          || '   ,p_wf_route_status    => :10 '
                          || '   ,p_api_caller         => :11 '
                          || ' ); '
                          || ' END; ';

      EXECUTE IMMEDIATE l_pls_block USING
          p_api_version
         ,p_init_msg_list
         ,p_commit
         ,p_validation_level
         ,OUT l_return_status
         ,OUT l_msg_count
         ,OUT l_msg_data
         ,p_change_id
         ,p_approval_status
         ,p_wf_route_status
         ,p_api_caller    ;

      -- Set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;

      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;

IF g_debug_flag THEN
   Write_Debug('After Calling DOM_DOCUMENT_UTIL.UPDATE_APPROVAL_STATUS: ' || l_return_status);
END IF ;


  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;


IF g_debug_flag THEN
   Write_Debug('Exception Update_Approval_Status: PLSQL_COMPILE_ERROR ');
END IF ;


     WHEN OTHERS THEN

IF g_debug_flag THEN
   Write_Debug('Unexpected Exception Update_Approval_Status: ' || SQLERRM);
END IF ;


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_DOCUMENT_UTIL' ,
            p_procedure_name      => 'UPDATE_APPROVAL_STATUS',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END  Update_Approval_Status ;


  --
  -- Wrapper API to integrate DOM Document API when Promoting/Demoting
  -- Document LC Phase
  --
  PROCEDURE Change_Doc_LC_Phase
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
   ,p_lc_phase_code             IN   NUMBER                             -- new phase
   ,p_action_type               IN   VARCHAR2 := NULL                   -- promote/demote action type 'PROMOTE' or 'DEMOTE'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS


    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN


      -- For Test/Debug
      Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

IF g_debug_flag THEN
   Write_Debug('ENG_DOCUMENT_UTIL.Change_Doc_LC_Phase Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id          : ' || TO_CHAR(p_change_id) );
   Write_Debug('LC Phase Code      : ' || TO_CHAR(p_lc_phase_code) );
   Write_Debug('Action Type        : ' || p_action_type);
   Write_Debug('API Caller         : ' || p_api_caller);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Calling DOM_DOCUMENT_UTIL.CHANGE_DOC_LC_PHASE');
END IF ;

      l_return_status := FND_API.G_RET_STS_SUCCESS ;


      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      l_pls_block :=    ' BEGIN '
                          || '  DOM_DOCUMENT_UTIL.CHANGE_DOC_LC_PHASE'
                          || '  ( p_api_version        => :1 '
                          || '   ,p_init_msg_list      => :2 '
                          || '   ,p_commit             => :3 '
                          || '   ,p_validation_level   => :4 '
                          || '   ,x_return_status      => :5 '
                          || '   ,x_msg_count          => :6 '
                          || '   ,x_msg_data           => :7 '
                          || '   ,p_change_id          => :8 '
                          || '   ,p_lc_phase_code      => :9 '
                          || '   ,p_action_type        => :10 '    --  'PROMOTE' or 'DEMOTE'
                          || '   ,p_api_caller         => :11 '
                          || ' ); '
                          || ' END; ';

      EXECUTE IMMEDIATE l_pls_block USING
          p_api_version
         ,p_init_msg_list
         ,p_commit
         ,p_validation_level
         ,OUT l_return_status
         ,OUT l_msg_count
         ,OUT l_msg_data
         ,p_change_id
         ,p_lc_phase_code
         ,p_action_type
         ,p_api_caller    ;


      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;

      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;


IF g_debug_flag THEN
   Write_Debug('After Calling DOM_DOCUMENT_UTIL.CHANGE_DOC_LC_PHASE: ' || l_return_status);
END IF ;


  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;

  IF g_debug_flag THEN
     Write_Debug('Exception Change_Doc_LC_Phase: PLSQL_COMPILE_ERROR ');
  END IF ;

     WHEN OTHERS THEN



IF g_debug_flag THEN
   Write_Debug('Unexpected Exception Change_Doc_LC_Phase: ' || SQLERRM);
END IF ;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_DOCUMENT_UTIL' ,
            p_procedure_name      => 'CHANGE_DOC_LC_PHASE',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END Change_Doc_LC_Phase ;



  --
  -- Wrapper API to integrate DOM Document API when starting
  -- Document LC Phase Workflow
  --
  PROCEDURE Start_Doc_LC_Phase_WF
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
   ,p_change_id                 IN   NUMBER                             -- DOC LC Object Change Id
   ,p_route_id                  IN   NUMBER                             -- DOC LC Phase WF Route ID
   ,p_lc_phase_code             IN   NUMBER   := NULL                   -- Doc LC Phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS


    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN


      -- For Test/Debug
      Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

IF g_debug_flag THEN
   Write_Debug('ENG_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id          : ' || TO_CHAR(p_change_id) );
   Write_Debug('Route Id           : ' || TO_CHAR(p_route_id) );
   Write_Debug('LC Phase Code      : ' || TO_CHAR(p_lc_phase_code) );
   Write_Debug('API Caller         : ' || p_api_caller);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Calling DOM_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF');
END IF ;

      l_return_status := FND_API.G_RET_STS_SUCCESS ;


      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      l_pls_block :=    ' BEGIN '
                          || '  DOM_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF'
                          || '  ( p_api_version        => :1 '
                          || '   ,p_init_msg_list      => :2 '
                          || '   ,p_commit             => :3 '
                          || '   ,p_validation_level   => :4 '
                          || '   ,x_return_status      => :5 '
                          || '   ,x_msg_count          => :6 '
                          || '   ,x_msg_data           => :7 '
                          || '   ,p_change_id          => :8 '
                          || '   ,p_route_id           => :9 '
                          || '   ,p_lc_phase_code      => :10 '
                          || '   ,p_api_caller         => :11 '
                          || ' ); '
                          || ' END; ';

      EXECUTE IMMEDIATE l_pls_block USING
          p_api_version
         ,p_init_msg_list
         ,p_commit
         ,p_validation_level
         ,OUT l_return_status
         ,OUT l_msg_count
         ,OUT l_msg_data
         ,p_change_id
         ,p_route_id
         ,p_lc_phase_code
         ,p_api_caller    ;


      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;

      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;


IF g_debug_flag THEN
   Write_Debug('After Calling DOM_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF: ' || l_return_status);
END IF ;


  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;

  IF g_debug_flag THEN
     Write_Debug('Exception Start_Doc_LC_Phase_WF: PLSQL_COMPILE_ERROR ');
  END IF ;

     WHEN OTHERS THEN



IF g_debug_flag THEN
   Write_Debug('Unexpected Exception Start_Doc_LC_Phase_WF: ' || SQLERRM);
END IF ;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_DOCUMENT_UTIL' ,
            p_procedure_name      => 'Start_Doc_LC_Phase_WF',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END Start_Doc_LC_Phase_WF ;


  --
  -- Wrapper API to integrate DOM Document API when aborting
  -- Document LC Phase Workflow
  --
  PROCEDURE Abort_Doc_LC_Phase_WF
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
   ,p_change_id                 IN   NUMBER                             -- DOC LC Object Change Id
   ,p_route_id                  IN   NUMBER                             -- DOC LC Phase WF Route ID
   ,p_lc_phase_code             IN   NUMBER   := NULL                   -- Doc LC Phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS


    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN


      -- For Test/Debug
      Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

IF g_debug_flag THEN
   Write_Debug('ENG_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id          : ' || TO_CHAR(p_change_id) );
   Write_Debug('Route Id           : ' || TO_CHAR(p_route_id) );
   Write_Debug('LC Phase Code      : ' || TO_CHAR(p_lc_phase_code) );
   Write_Debug('API Caller         : ' || p_api_caller);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Calling DOM_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF');
END IF ;

      l_return_status := FND_API.G_RET_STS_SUCCESS ;


      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      l_pls_block :=    ' BEGIN '
                          || '  DOM_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF'
                          || '  ( p_api_version        => :1 '
                          || '   ,p_init_msg_list      => :2 '
                          || '   ,p_commit             => :3 '
                          || '   ,p_validation_level   => :4 '
                          || '   ,x_return_status      => :5 '
                          || '   ,x_msg_count          => :6 '
                          || '   ,x_msg_data           => :7 '
                          || '   ,p_change_id          => :8 '
                          || '   ,p_route_id           => :9 '
                          || '   ,p_lc_phase_code      => :10 '
                          || '   ,p_api_caller         => :11 '
                          || ' ); '
                          || ' END; ';

      EXECUTE IMMEDIATE l_pls_block USING
          p_api_version
         ,p_init_msg_list
         ,p_commit
         ,p_validation_level
         ,OUT l_return_status
         ,OUT l_msg_count
         ,OUT l_msg_data
         ,p_change_id
         ,p_route_id
         ,p_lc_phase_code
         ,p_api_caller    ;


      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;

      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;

IF g_debug_flag THEN
   Write_Debug('After Calling DOM_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF: ' || l_return_status);
END IF ;


  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;

  IF g_debug_flag THEN
     Write_Debug('Exception Abort_Doc_LC_Phase_WF: PLSQL_COMPILE_ERROR ');
  END IF ;

     WHEN OTHERS THEN



IF g_debug_flag THEN
   Write_Debug('Unexpected Exception Abort_Doc_LC_Phase_WF: ' || SQLERRM);
END IF ;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_DOCUMENT_UTIL' ,
            p_procedure_name      => 'CHANGE_DOC_LC_PHASE',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END Abort_Doc_LC_Phase_WF ;


  --
  -- Wrapper API to grant Document Role to Document Revision
  --
  PROCEDURE Grant_Document_Role
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
   ,p_document_id               IN   NUMBER                             -- Dom Document Id
   ,p_document_revision_id      IN   NUMBER                             -- Dom Document Revision Id
   ,p_change_id                 IN   NUMBER                             -- Change Id
   ,p_change_line_id            IN   NUMBER                             -- Change Line Id
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_role_id                   IN   NUMBER                             -- Role Id to be granted
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS

    l_change_line_id       NUMBER ;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN


        -- For Test/Debug
        Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

  IF g_debug_flag THEN
     Write_Debug('ENG_DOCUMENT_UTIL.Grant_Document_Role Log');
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Document Id          : ' || TO_CHAR(p_document_id) );
     Write_Debug('Document Revision Id : ' || TO_CHAR(p_document_revision_id) );
     Write_Debug('Change Id            : ' || TO_CHAR(p_change_id) );
     Write_Debug('Change Line Id       : ' || TO_CHAR(p_change_line_id) );
     Write_Debug('Role Id              : ' || TO_CHAR(p_role_id) );
     Write_Debug('API Caller           : ' || p_api_caller);
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Calling DOM_SECURITY_PUB.Grant_Document_Role');
  END IF ;


      l_return_status := FND_API.G_RET_STS_SUCCESS ;

      l_change_line_id := p_change_line_id ;

      IF l_change_line_id <= 0 THEN

          l_change_line_id := NULL ;

      END IF ;

  IF g_debug_flag THEN
     Write_Debug('Param: Change Line Id       : ' || TO_CHAR(l_change_line_id) );
  END IF ;


      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback

      /*
      --
      -- Comment out: somehow dynamic call does not work
      -- I guess we should use DBMS_SQL to achieve this
      --
      -- l_pls_block :=    ' BEGIN '
      --                     || '  DOM_SECURITY_PUB.Grant_Document_Role'
      --                     || '  ( p_api_version        => :1 '
      --                     || '   ,p_init_msg_list      => :2 '
      --                     || '   ,p_commit             => :3 '
      --                     || '   ,p_validation_level   => :4 '
      --                     || '   ,x_return_status      => :5 '
      --                     || '   ,x_msg_count          => :6 '
      --                     || '   ,x_msg_data           => :7 '
      --                     || '   ,p_object_name        => ''DOM_DOCUMENT_REVISION'' '
      --                     || '   ,p_pk1_value          => :8 '   -- Document_Id
      --                     || '   ,p_pk2_value          => :9 '   -- Revision_Id
      --                     || '   ,p_pk3_value          => :10 '  -- Change_Id
      --                     || '   ,p_pk4_value          => :11 '  -- Change_Line_Id
      --                     || '   ,p_pk5_value          => NULL '
      --                     || '   ,p_party_ids          => :12 '
      --                     || '   ,p_role_id            => :13 '
      --                     || '   ,p_api_caller         => :14 '
      --                     || ' ); '
      --                     || ' END; ';
      --
      -- EXECUTE IMMEDIATE l_pls_block USING
      --     p_api_version
      --    ,p_init_msg_list
      --    ,p_commit
      --    ,p_validation_level
      --    ,OUT l_return_status
      --    ,OUT l_msg_count
      --    ,OUT l_msg_data
      --    ,TO_CHAR(p_document_id)
      --    ,TO_CHAR(p_document_revision_id)
      --    ,TO_CHAR(p_change_id)
      --    ,TO_CHAR(l_change_line_id)
      --    ,p_party_ids
      --    ,p_role_id
      --    ,p_api_caller    ;
      --
      */


      BEGIN

          DOM_SECURITY_PUB.Grant_Document_Role
          ( p_api_version        => p_api_version
           ,p_init_msg_list      => p_init_msg_list
           ,p_commit             => p_commit
           ,p_validation_level   => p_validation_level
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           ,p_object_name        => 'DOM_DOCUMENT_REVISION'
           ,p_pk1_value          => TO_CHAR(p_document_id)            -- Document_Id
           ,p_pk2_value          => TO_CHAR(p_document_revision_id)   -- Revision_Id
           ,p_pk3_value          => TO_CHAR(p_change_id)              -- Change_Id
           ,p_pk4_value          => TO_CHAR(l_change_line_id)         -- Change_Line_Id
           ,p_pk5_value          => NULL
           ,p_party_ids          => p_party_ids
           ,p_role_id            => p_role_id
           ,p_api_caller         => p_api_caller
           );

      EXCEPTION
             WHEN OTHERS THEN
                IF g_debug_flag THEN
                   Write_Debug('Unexpected Exception DOM_SECURITY_PUB.Grant_Document_Role: ' || SQLERRM);
                END IF ;

      END ;

      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;


      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;


IF g_debug_flag THEN
   Write_Debug('After Calling DOM_SECURITY_PUB.Grant_Document_Role: ' || l_return_status);
END IF ;

  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;

IF g_debug_flag THEN
   Write_Debug('Exception Grant_Document_Role: PLSQL_COMPILE_ERROR ');
END IF ;

     WHEN OTHERS THEN

IF g_debug_flag THEN
   Write_Debug('Unexpected Exception Grant_Document_Role: ' || SQLERRM);
END IF ;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_SECURITY_PUB' ,
            p_procedure_name      => 'Grant_Document_Role',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END Grant_Document_Role ;



  --
  -- Wrapper API to revoke Document Role to Document Revision
  --
  PROCEDURE Revoke_Document_Role
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
   ,p_document_id               IN   NUMBER                             -- Dom Document Id
   ,p_document_revision_id      IN   NUMBER                             -- Dom Document Revision Id
   ,p_change_id                 IN   NUMBER                             -- Change Id
   ,p_change_line_id            IN   NUMBER                             -- Change Line Id
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_role_id                   IN   NUMBER                             -- Role Id to be revoked. If NULL, Revoke all grants per given object info
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS

    l_change_line_id NUMBER ;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN

        -- For Test/Debug
        Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

  IF g_debug_flag THEN
     Write_Debug('ENG_DOCUMENT_UTIL.Revoke_Document_Role Log');
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Document Id          : ' || TO_CHAR(p_document_id) );
     Write_Debug('Document Revision Id : ' || TO_CHAR(p_document_revision_id) );
     Write_Debug('Change Id            : ' || TO_CHAR(p_change_id) );
     Write_Debug('Change Line Id       : ' || TO_CHAR(p_change_line_id) );
     Write_Debug('Role Id              : ' || TO_CHAR(p_role_id) );
     Write_Debug('API Caller           : ' || p_api_caller);
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Calling DOM_SECURITY_PUB.Revoke_Document_Role');
  END IF ;


      l_return_status := FND_API.G_RET_STS_SUCCESS ;

      l_change_line_id := p_change_line_id ;

      IF l_change_line_id <= 0 THEN

          l_change_line_id := NULL ;

      END IF ;


  IF g_debug_flag THEN
     Write_Debug('Param: Change Line Id       : ' || TO_CHAR(l_change_line_id) );
  END IF ;



      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      -- No need to pass p_role_id

      /*
      --
      -- Comment out: somehow dynamic call does not work
      -- I guess we should use DBMS_SQL to achieve this
      --
      -- l_pls_block :=    ' BEGIN '
      --                     || '  DOM_SECURITY_PUB.Revoke_Document_Role'
      --                     || '  ( p_api_version        => :1 '
      --                     || '   ,p_init_msg_list      => :2 '
      --                     || '   ,p_commit             => :3 '
      --                     || '   ,p_validation_level   => :4 '
      --                     || '   ,x_return_status      => :5 '
      --                     || '   ,x_msg_count          => :6 '
      --                     || '   ,x_msg_data           => :7 '
      --                     || '   ,p_object_name        => ''DOM_DOCUMENT_REVISION'' '
      --                     || '   ,p_pk1_value          => :8 '   -- Document_Id
      --                     || '   ,p_pk2_value          => :9 '   -- Revision_Id
      --                     || '   ,p_pk3_value          => :10 '  -- Change_Id
      --                     || '   ,p_pk4_value          => :11 '  -- Change_Line_Id
      --                     || '   ,p_pk5_value          => NULL '
      --                     || '   ,p_party_ids          => :12 '
      --                     || '   ,p_role_id            => NULL '
      --                     || '   ,p_api_caller         => :13 '
      --                     || ' ); '
      --                     || ' END; ';
      --
      -- EXECUTE IMMEDIATE l_pls_block USING
      --     p_api_version
      --    ,p_init_msg_list
      --    ,p_commit
      --    ,p_validation_level
      --    ,OUT l_return_status
      --    ,OUT l_msg_count
      --    ,OUT l_msg_data
      --    ,TO_CHAR(p_document_id)
      --    ,TO_CHAR(p_document_revision_id)
      --    ,TO_CHAR(p_change_id)
      --    ,TO_CHAR(l_change_line_id)
      --    ,p_party_ids
      --    ,p_api_caller    ;
      --
      */

      BEGIN

          DOM_SECURITY_PUB.Revoke_Document_Role
          ( p_api_version        => p_api_version
           ,p_init_msg_list      => p_init_msg_list
           ,p_commit             => p_commit
           ,p_validation_level   => p_validation_level
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           ,p_object_name        => 'DOM_DOCUMENT_REVISION'
           ,p_pk1_value          => TO_CHAR(p_document_id)            -- Document_Id
           ,p_pk2_value          => TO_CHAR(p_document_revision_id)   -- Revision_Id
           ,p_pk3_value          => TO_CHAR(p_change_id)              -- Change_Id
           ,p_pk4_value          => TO_CHAR(l_change_line_id)         -- Change_Line_Id
           ,p_pk5_value          => NULL
           ,p_party_ids          => p_party_ids
           ,p_role_id            => NULL
           ,p_api_caller         => p_api_caller
           );

      EXCEPTION
             WHEN OTHERS THEN
                IF g_debug_flag THEN
                   Write_Debug('Unexpected Exception DOM_SECURITY_PUB.Revoke_Document_Role: ' || SQLERRM);
                END IF ;

      END ;


      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;


      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;


IF g_debug_flag THEN
   Write_Debug('After Calling DOM_SECURITY_PUB.Revoke_Document_Role: ' || l_return_status);
END IF ;



  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;

  IF g_debug_flag THEN
     Write_Debug('Exception Revoke_Document_Role: PLSQL_COMPILE_ERROR ');
  END IF ;

       WHEN OTHERS THEN

  IF g_debug_flag THEN
     Write_Debug('Unexpected Exception Revoke_Document_Role: ' || SQLERRM);
  END IF ;


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_SECURITY_PUB' ,
            p_procedure_name      => 'Revoke_Document_Role',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );

  END Revoke_Document_Role ;


  --
  -- Wrapper API to grant Document Role to Document Revision
  --
  PROCEDURE Grant_Attachments_OCSRole
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
   ,p_entity_name               IN   VARCHAR2
   ,p_pk1value                  IN   VARCHAR2
   ,p_pk2value                  IN   VARCHAR2
   ,p_pk3value                  IN   VARCHAR2
   ,p_pk4value                  IN   VARCHAR2
   ,p_pk5value                  IN   VARCHAR2
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_ocs_role                  IN   VARCHAR2                           -- OCS File Role to be granted
   ,p_source_media_id_tbl       IN   FND_TABLE_OF_NUMBER := null
   ,p_attachment_id_tbl         IN   FND_TABLE_OF_NUMBER := null
   ,p_repository_id_tbl         IN   FND_TABLE_OF_NUMBER := null
   ,p_submitted_by              IN   NUMBER := null
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN

        -- For Test/Debug
        Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

  IF g_debug_flag THEN
     Write_Debug('ENG_DOCUMENT_UTIL.Grant_Attachments_OCSRole Log');
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Entity Name         : ' || p_entity_name);
     Write_Debug('PK1 Value           : ' || p_pk1value);
     Write_Debug('PK2 Value           : ' || p_pk2value);
     Write_Debug('PK3 Value           : ' || p_pk3value);
     Write_Debug('PK4 Value           : ' || p_pk4value);
     Write_Debug('PK5 Value           : ' || p_pk5value);
     Write_Debug('OCS ROle            : ' || p_ocs_role);
     Write_Debug('API Caller          : ' || p_api_caller);
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Calling DOM_SECURITY_PUB.Grant_Attachments_OCSRole');
  END IF ;


      l_return_status := FND_API.G_RET_STS_SUCCESS ;

      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback

      /*
      --
      -- Comment out: somehow dynamic call does not work
      -- I guess we should use DBMS_SQL to achieve this
      --
      -- l_pls_block :=    ' BEGIN '
      --                     || '  DOM_SECURITY_PUB.Grant_Attachments_OCSRole'
      --                     || '  ( p_api_version        => :1 '
      --                     || '   ,p_init_msg_list      => :2 '
      --                     || '   ,p_commit             => :3 '
      --                     || '   ,p_validation_level   => :4 '
      --                     || '   ,x_return_status      => :5 '
      --                     || '   ,x_msg_count          => :6 '
      --                     || '   ,x_msg_data           => :7 '
      --                     || '   ,p_entity_name        => :8 '
      --                     || '   ,p_pk1_value           => :9 '   -- Document_Id
      --                     || '   ,p_pk2_value           => :10 '  -- Revision_Id
      --                     || '   ,p_pk3_value           => :11 '  -- Change_Id
      --                     || '   ,p_pk4_value           => :12 '  -- Change_Line_Id
      --                     || '   ,p_pk5_value           => :13 '
      --                     || '   ,p_party_ids          => :14 '
      --                     || '   ,p_ocs_role           => :15 '
      --                     || '   ,p_api_caller         => :16 '
      --                     || ' ); '
      --                     || ' END; ';
      --
      -- EXECUTE IMMEDIATE l_pls_block USING
      --     p_api_version
      --    ,p_init_msg_list
      --    ,p_commit
      --    ,p_validation_level
      --    ,OUT l_return_status
      --    ,OUT l_msg_count
      --    ,OUT l_msg_data
      --    ,p_entity_name
      --    ,p_pk1value
      --    ,p_pk2value
      --    ,p_pk3value
      --    ,p_pk4value
      --    ,p_pk5value
      --    ,p_party_ids
      --    ,p_ocs_role
      --    ,p_api_caller    ;
      --
      */

      BEGIN


         DOM_SECURITY_PUB.Grant_Attachments_OCSRole
         ( p_api_version        => p_api_version
          ,p_init_msg_list      => p_init_msg_list
          ,p_commit             => p_commit
          ,p_validation_level   => p_validation_level
          ,x_return_status      => l_return_status
          ,x_msg_count          => l_msg_count
          ,x_msg_data           => l_msg_data
          ,p_entity_name        => p_entity_name
          ,p_pk1_value          => p_pk1value
          ,p_pk2_value          => p_pk2value
          ,p_pk3_value          => p_pk3value
          ,p_pk4_value          => p_pk4value
          ,p_pk5_value          => p_pk5value
          ,p_party_ids          => p_party_ids
          ,p_ocs_role           => p_ocs_role
          ,p_api_caller         => p_api_caller
          );

          IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;

         if x_return_status =  FND_API.G_RET_STS_SUCCESS
            AND  p_source_media_id_tbl is not null and p_source_media_id_tbl.count > 0
            AND  p_repository_id_tbl is not null and p_repository_id_tbl.count>0
         then
           for  ind in p_source_media_id_tbl.first .. p_source_media_id_tbl.last
           loop
               DOM_SECURITY_PUB.Grant_Attachment_Access
              (
                 p_api_version           =>  p_api_version,
                 p_attached_document_id  =>  p_attachment_id_tbl(ind),
                 p_source_media_id       =>  p_source_media_id_tbl(ind),
                 p_repository_id         =>  p_repository_id_tbl(ind),
                 p_ocs_role              =>  p_ocs_role,
                 p_party_ids             =>  p_party_ids,
                 p_submitted_by          =>  p_submitted_by,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data ,
                 x_return_status         => l_return_status
              );
           END LOOP;

        END IF;

      EXCEPTION
             WHEN OTHERS THEN
                IF g_debug_flag THEN
                   Write_Debug('Unexpected Exception Grant_Attachments_OCSRole: ' || SQLERRM);
                END IF ;

      END  ;


      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;


      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;


IF g_debug_flag THEN
   Write_Debug('After Calling DOM_SECURITY_PUB.Grant_Attachments_OCSRole: ' || l_return_status);
END IF ;

  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;


  IF g_debug_flag THEN
     Write_Debug('Exception Grant_Attachments_OCSRole: PLSQL_COMPILE_ERROR ');
  END IF ;

       WHEN OTHERS THEN
  IF g_debug_flag THEN
     Write_Debug('Unexpected Exception Grant_Attachments_OCSRole: ' || SQLERRM);
  END IF ;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_SECURITY_PUB' ,
            p_procedure_name      => 'Grant_Attachments_OCSRole',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END Grant_Attachments_OCSRole ;



  --
  -- Wrapper API to revoke Document Role to Document Revision
  --
  PROCEDURE Revoke_Attachments_OCSRole
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
   ,p_entity_name               IN   VARCHAR2
   ,p_pk1value                  IN   VARCHAR2
   ,p_pk2value                  IN   VARCHAR2
   ,p_pk3value                  IN   VARCHAR2
   ,p_pk4value                  IN   VARCHAR2
   ,p_pk5value                  IN   VARCHAR2
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_ocs_role                  IN   VARCHAR2                           -- OCS File Role to be revoked. If NULL, Revoke all grants per given entity info
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  )
  IS

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_pls_block          VARCHAR2(4000);

  BEGIN

        -- For Test/Debug
        Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;

  IF g_debug_flag THEN
     Write_Debug('ENG_DOCUMENT_UTIL.Revoke_Attachments_OCSRole Log');
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Entity Name         : ' || p_entity_name);
     Write_Debug('PK1 Value           : ' || p_pk1value);
     Write_Debug('PK2 Value           : ' || p_pk2value);
     Write_Debug('PK3 Value           : ' || p_pk3value);
     Write_Debug('PK4 Value           : ' || p_pk4value);
     Write_Debug('PK5 Value           : ' || p_pk5value);
     Write_Debug('API Caller          : ' || p_api_caller);
     Write_Debug('OCS ROle            : ' || p_ocs_role);
     Write_Debug('-----------------------------------------------------');
     Write_Debug('Calling DOM_SECURITY_PUB.Revoke_Attachments_OCSRole');
  END IF ;

      l_return_status := FND_API.G_RET_STS_SUCCESS ;



      -- We always pass p_commit FND_API.G_FALSE
      -- DOM API should NOT commit or rollback
      -- No need to pass p_ocs_role

      /*
      --
      -- Comment out: somehow dynamic call does not work
      -- I guess we should use DBMS_SQL to achieve this
      --
      --
      -- l_pls_block :=    ' BEGIN '
      --                     || '  DOM_SECURITY_PUB.Revoke_Attachments_OCSRole'
      --                     || '  ( p_api_version        => :1 '
      --                     || '   ,p_init_msg_list      => :2 '
      --                     || '   ,p_commit             => :3 '
      --                     || '   ,p_validation_level   => :4 '
      --                     || '   ,x_return_status      => :5 '
      --                     || '   ,x_msg_count          => :6 '
      --                     || '   ,x_msg_data           => :7 '
      --                     || '   ,p_entity_name        => :8 '
      --                     || '   ,p_pk1_value          => :9 '
      --                     || '   ,p_pk2_value          => :10 '
      --                     || '   ,p_pk3_value          => :11 '
      --                     || '   ,p_pk4_value          => :12 '
      --                     || '   ,p_pk5_value          => :13 '
      --                     || '   ,p_party_ids          => :14 '
      --                     || '   ,p_ocs_role           => NULL '
      --                     || '   ,p_api_caller         => :15 '
      --                     || ' ); '
      --                     || ' END; ';
      --
      -- EXECUTE IMMEDIATE l_pls_block USING
      --     p_api_version
      --    ,p_init_msg_list
      --    ,p_commit
      --    ,p_validation_level
      --    ,OUT l_return_status
      --    ,OUT l_msg_count
      --    ,OUT l_msg_data
      --    ,p_entity_name
      --    ,p_pk1value
      --    ,p_pk2value
      --    ,p_pk3value
      --    ,p_pk4value
      --    ,p_pk5value
      --    ,p_party_ids
      --    ,p_api_caller ;
      --
      */

      BEGIN


         DOM_SECURITY_PUB.Revoke_Attachments_OCSRole
         ( p_api_version        => p_api_version
          ,p_init_msg_list      => p_init_msg_list
          ,p_commit             => p_commit
          ,p_validation_level   => p_validation_level
          ,x_return_status      => l_return_status
          ,x_msg_count          => l_msg_count
          ,x_msg_data           => l_msg_data
          ,p_entity_name        => p_entity_name
          ,p_pk1_value          => p_pk1value
          ,p_pk2_value          => p_pk2value
          ,p_pk3_value          => p_pk3value
          ,p_pk4_value          => p_pk4value
          ,p_pk5_value          => p_pk5value
          ,p_party_ids          => p_party_ids
          ,p_ocs_role           => NULL
          ,p_api_caller         => p_api_caller
          );

      EXCEPTION
             WHEN OTHERS THEN
                IF g_debug_flag THEN
                   Write_Debug('Unexpected Exception Revoke_Attachments_OCSRole: ' || SQLERRM);
                END IF ;

      END  ;


      -- set Return vars
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;


      -- Until DOM team implemented the logic indeed
      IF x_return_status IS NULL
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
      END IF ;



IF g_debug_flag THEN
   Write_Debug('After Calling DOM_SECURITY_PUB.Revoke_Attachments_OCSRole: ' || l_return_status);
END IF ;


  EXCEPTION
      WHEN PLSQL_COMPILE_ERROR THEN
          -- Assuming DOM is not installed
          x_return_status := FND_API.G_RET_STS_SUCCESS ;
          x_msg_count := 0;
          x_msg_data := NULL;


IF g_debug_flag THEN
     Write_Debug('Exception Grant_Attachments_OCSRole: PLSQL_COMPILE_ERROR ');
END IF ;

      WHEN OTHERS THEN

IF g_debug_flag THEN
     Write_Debug('Unexpected Exception Grant_Attachments_OCSRole: ' || SQLERRM);
END IF ;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Add_Exc_Msg
          ( p_pkg_name            => 'DOM_SECURITY_PUB' ,
            p_procedure_name      => 'Revoke_Attachments_OCSRole',
            p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
          );

          FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count ,
            p_data  => x_msg_data
          );


  END Revoke_Attachments_OCSRole ;




END ENG_DOCUMENT_UTIL;

/
