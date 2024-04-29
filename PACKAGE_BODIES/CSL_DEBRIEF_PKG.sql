--------------------------------------------------------
--  DDL for Package Body CSL_DEBRIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_DEBRIEF_PKG" AS
/* $Header: cslvdblb.pls 120.0 2005/05/24 17:54:56 appldev noship $ */


error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_DEBRIEF_PKG';     -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_DEBRIEF_LINES';   -- publication item name
g_pub_name2    CONSTANT VARCHAR2(30) := 'CSF_DEBRIEF_HEADERS'; -- publication item name
g_debug_level  NUMBER;                                         -- debug level
g_header_id    NUMBER := NULL;
TYPE  Deferred_Line_Tbl_Type      IS TABLE OF CSF_DEBRIEF_LINES.DEBRIEF_LINE_ID%TYPE INDEX BY BINARY_INTEGER;
g_deferred_line_id_tbl          Deferred_Line_Tbl_Type;

/***
  Cursor to retrieve all debrief lines from the debrief line inqueue that
  have a debrief header record in the debrief header inqueue.
***/
CURSOR c_debrief ( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT   dbl.*
  FROM     CSL_CSF_DEBRIEF_LINES_INQ dbl
  ,        CSL_CSF_DEBRIEF_HEADERS_INQ dbh
  WHERE    dbl.debrief_header_id = dbh.debrief_header_id
  AND      dbl.tranid$$ = b_tranid
  AND      dbl.clid$$cs = b_user_name
  ORDER BY dbl.debrief_header_id;

/***
  Cursor to retrieve all debrief lines from the debrief line inqueue that
  have no debrief header record in the debrief header inqueue but have one in the backend.
  This one is executed after all debrief lines with headers have been deleted from the inqueue.
  The debrief lines without header remain then.
***/
CURSOR   c_debrief_no_headers( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM   CSL_CSF_DEBRIEF_LINES_INQ
  WHERE  tranid$$ = b_tranid
  AND    clid$$cs = b_user_name;

CURSOR   c_debrief_no_lines( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM   CSL_CSF_DEBRIEF_HEADERS_INQ
  WHERE  tranid$$ = b_tranid
  AND    clid$$cs = b_user_name;

/***
  This procedure is called from APPLY_RECORD and creates a debrief header.
***/
PROCEDURE CREATE_DEBRIEF_HEADER
         (
           p_debrief_header_id IN      CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE,
           p_error_msg         OUT NOCOPY     VARCHAR2,
           x_return_status     IN OUT NOCOPY  VARCHAR2
         )
IS
/********************************************************
 Name:
   CREATE_DEBRIEF_HEADER

 Purpose:
   Insert new header record into CSF_DEBRIEF_HEADERS

 Arguments:
   p_debrief_header_id  The debrief header id comes from
                        the debrief line inqueue record.
                        This is used to retrieve the data
                        from the debrief headers inqueue
                        which is used to call the API.
********************************************************/

CURSOR c_csf_debrief_headers (b_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE) is
  SELECT *
  FROM  CSL_CSF_DEBRIEF_HEADERS_INQ
  WHERE debrief_header_id = b_debrief_header_id;

  r_csf_debrief_headers c_csf_debrief_headers%ROWTYPE;

  l_deb_rec             csf_debrief_pub.debrief_rec_type;
  l_line_tbl            csf_debrief_pub.debrief_line_tbl_type;

  l_debrief_header_id   CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE;

  l_date                DATE;
  l_process_status      NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(240);
BEGIN

  l_date := SYSDATE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => r_csf_debrief_headers.debrief_header_id  -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.CREATE_DEBRIEF_HEADER'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Open cursor to retrieve debrief header for debrief line
  OPEN  c_csf_debrief_headers (p_debrief_header_id);
  FETCH c_csf_debrief_headers INTO r_csf_debrief_headers;
  CLOSE c_csf_debrief_headers;

  -- Create a new debrief header record
  l_deb_rec.debrief_header_id  := r_csf_debrief_headers.debrief_header_id;
  l_deb_rec.debrief_date       := r_csf_debrief_headers.debrief_date;
  l_deb_rec.debrief_status_id  := r_csf_debrief_headers.debrief_status_id;
  l_deb_rec.task_assignment_id := r_csf_debrief_headers.task_assignment_id;
  l_deb_rec.last_update_date   := l_date;
  l_deb_rec.last_updated_by    := FND_GLOBAL.USER_ID;
  l_deb_rec.creation_date      := l_date;
  l_deb_rec.created_by         := FND_GLOBAL.USER_ID;
  l_deb_rec.last_update_login  := FND_GLOBAL.LOGIN_ID;
  l_deb_rec.attribute1         := r_csf_debrief_headers.attribute1;
  l_deb_rec.attribute2         := r_csf_debrief_headers.attribute2;
  l_deb_rec.attribute3         := r_csf_debrief_headers.attribute3;
  l_deb_rec.attribute4         := r_csf_debrief_headers.attribute4;
  l_deb_rec.attribute5         := r_csf_debrief_headers.attribute5;
  l_deb_rec.attribute6         := r_csf_debrief_headers.attribute6;
  l_deb_rec.attribute7         := r_csf_debrief_headers.attribute7;
  l_deb_rec.attribute8         := r_csf_debrief_headers.attribute8;
  l_deb_rec.attribute9         := r_csf_debrief_headers.attribute9;
  l_deb_rec.attribute10        := r_csf_debrief_headers.attribute10;
  l_deb_rec.attribute11        := r_csf_debrief_headers.attribute11;
  l_deb_rec.attribute12        := r_csf_debrief_headers.attribute12;
  l_deb_rec.attribute13        := r_csf_debrief_headers.attribute13;
  l_deb_rec.attribute14        := r_csf_debrief_headers.attribute14;
  l_deb_rec.attribute15        := r_csf_debrief_headers.attribute15;
  l_deb_rec.attribute_category := r_csf_debrief_headers.attribute_category;

  csf_debrief_pub.create_debrief
    ( p_api_version_number => 1.0
    , p_init_msg_list      => FND_API.G_TRUE
    , p_commit             => FND_API.G_FALSE
    , p_debrief_rec        => l_deb_rec
    , p_debrief_line_tbl   => l_line_tbl
    , x_debrief_header_id  => l_debrief_header_id
    , x_return_status      => x_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => r_csf_debrief_headers.debrief_header_id  -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.CREATE_DEBRIEF_HEADER'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => r_csf_debrief_headers.debrief_header_id  -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.CREATE_DEBRIEF_HEADER : ' || p_error_msg
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

END CREATE_DEBRIEF_HEADER;

/***
  This function checks whether a header id already exists in the backend or not.
***/
FUNCTION DEBRIEF_HEADER_EXISTS
        (
          p_debrief_header_id IN OUT NOCOPY CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE,
          p_task_assignment_id IN NUMBER
        )
RETURN BOOLEAN
IS

  CURSOR   c_debrief_header_exists ( b_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE ) is
    SELECT null
    FROM   csf_debrief_headers
    WHERE  debrief_header_id = b_debrief_header_id;

  CURSOR   c_debrief_header_id ( b_task_assignment_id CSF_DEBRIEF_HEADERS.TASK_ASSIGNMENT_ID%TYPE ) is
    SELECT debrief_header_id
    FROM   csf_debrief_headers
    WHERE  task_assignment_id = b_task_assignment_id;


  r_debrief_header_exists  c_debrief_header_exists%ROWTYPE;
  r_debrief_header_id  c_debrief_header_id%ROWTYPE;
  l_header_exists          BOOLEAN;
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Debrief_Header_Exists'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Check if a header already exists in the backend or not.
  l_header_exists := FALSE;

  -- First check if there is already a header created on backend
  OPEN  c_debrief_header_id (p_task_assignment_id);
  FETCH c_debrief_header_id INTO r_debrief_header_id;
  IF c_debrief_header_id%FOUND THEN
    l_header_exists := TRUE;
    p_debrief_header_id := r_debrief_header_id.debrief_header_id;
    CLOSE c_debrief_header_id;
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name || '.Debrief_Header_Exists'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    return l_header_exists;
  END IF;
  CLOSE c_debrief_header_id;

  -- If the header is not on a task assignment see if the header already exists
  OPEN  c_debrief_header_exists (p_debrief_header_id);
  FETCH c_debrief_header_exists INTO r_debrief_header_exists;
  IF c_debrief_header_exists%FOUND THEN
    l_header_exists := TRUE;
  END IF;
  CLOSE c_debrief_header_exists;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Debrief_Header_Exists'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_header_exists;
END DEBRIEF_HEADER_EXISTS;

  /* Just forward Declaration */
  PROCEDURE APPLY_UPDATE_HEADER
    ( p_user_name      IN      VARCHAR2,
      p_tranid         IN      NUMBER,
      p_header_id      IN OUT NOCOPY     NUMBER,
      p_error_msg      OUT NOCOPY     VARCHAR2,
      x_return_status  IN OUT NOCOPY  VARCHAR2 );

  /***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record
  is to be processed.
  ***/

PROCEDURE APPLY_INSERT_HEADER
         (
           p_user_name      IN      VARCHAR2,
           p_tranid         IN      NUMBER,
	   p_header_id      IN OUT NOCOPY     NUMBER,
           p_error_msg      OUT NOCOPY     VARCHAR2,
           x_return_status  IN OUT NOCOPY  VARCHAR2
         ) IS
/***
  Name:
    APPLY_INSERT_HEADER

  Purpose:
    First process all debrief lines that have debrief headers.
    After processing a debrief line with debrief header delete both from
    inqueues.

    Then process all debrief lines that have no debrief header record in
    the debrief header inqueue.
    These are the ones coming from the backend and that have a header
    record in the backend.
    After processing these debrief lines, delete them from the debrief
    line inqueue.
***/

  /***
    Cursor to retrieve task_assignment_id to check if there is already
    an record created on the backend for this header.
  ***/
  CURSOR c_debrief_assignment_id ( b_debrief_header_id NUMBER) is
    SELECT   task_assignment_id, seqno$$
    FROM     CSL_CSF_DEBRIEF_HEADERS_INQ dbh
    WHERE    debrief_header_id = b_debrief_header_id;
  r_debrief_assignment_id c_debrief_assignment_id%ROWTYPE;

  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(240);

  l_process_status         NUMBER;
  l_header_exists          BOOLEAN;
  l_header_id              NUMBER; -- p_record.debrief_header_id%TYPE;
  l_task_assignment_id     NUMBER;
  l_seqno                  NUMBER;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_header_id
    , v_object_name => g_object_name
      , v_message     => 'Entering ' || g_object_name ||
                         '.APPLY_INSERT_HEADER'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /***
      First check if header already exists in the backend or not. If so
      then do not create a new one.
      The situation could occur where multiple debrief lines have been
      created for 1 debrief header.
      In this case the header only has is created the first time and
      should not be created a second time.
  ***/

  -- If the header is not on a task assignment see if the header already
  --   exists
  l_header_id := p_header_id; --p_record.debrief_header_id;
  OPEN  c_debrief_assignment_id (l_header_id);
  FETCH c_debrief_assignment_id INTO r_debrief_assignment_id;
  IF c_debrief_assignment_id%FOUND THEN
    l_task_assignment_id := r_debrief_assignment_id.task_assignment_id;
  ELSE
    l_task_assignment_id := NULL;
  END IF;
  -- Also set seqno number because it is different from the line.
  l_seqno := r_debrief_assignment_id.seqno$$;
  CLOSE c_debrief_assignment_id;
    l_header_exists := DEBRIEF_HEADER_EXISTS(l_header_id,
                                             l_task_assignment_id);

   IF l_header_exists THEN
      APPLY_UPDATE_HEADER( p_user_name => p_user_name
                           , p_tranid   => p_tranid
  	                   , p_header_id  => p_header_id
                           , p_error_msg  => p_error_msg
                           , x_return_status  => x_return_status );
   ELSE
      savepoint save_rec;
    -- Create debrief header.
    CREATE_DEBRIEF_HEADER(l_header_id, p_error_msg, l_return_status);

    -- Delete debrief header record from debrief header inqueue.
    /*** was record processed successfully? ***/
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => l_header_id -- put PK column here
        , v_object_name => g_object_name
          , v_message     => 'Record successfully processed, deleting from
                             inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
           p_user_name     => p_user_name,
           p_tranid        => p_tranid,
           p_seqno         => l_seqno,
           p_pk            => p_header_id, -- p_record.debrief_header_id
           p_object_name   => g_object_name,
           p_pub_name      => g_pub_name2,
           p_error_msg     => p_error_msg,
           x_return_status => l_return_status
        );

      /*** was delete successful? ***/
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_header_id --p_record.debrief_header_id
          , v_object_name => g_object_name
            , v_message     => 'Deleting from inqueue failed, '||
                               'rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK to save_rec;
      END IF;
    ELSE
      /*** Record was not processed successfully or delete failed
           -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_header_id --p_record.debrief_header_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, '||
                             'deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
      (
           p_user_name     => p_user_name
          ,p_tranid        => p_tranid
          ,p_seqno         => l_seqno
          ,p_pk            => p_header_id --p_record.debrief_header_id
          ,p_object_name   => g_object_name
          ,p_pub_name      => g_pub_name2
          ,p_error_msg     => p_error_msg
	  ,x_return_status => l_return_status
      );

      /*** Was defer successful? ***/
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_header_id --p_record.debrief_header_id
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK to save_rec;
      END IF;
    END IF;
  END IF;

  IF p_header_id <> l_header_id THEN

   /*** Record was not processed successfully or delete failed ->
        defer and reject record ***/
   IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( v_object_id   => p_header_id --p_record.debrief_header_id
     , v_object_name => g_object_name
     , v_message     => 'Record not processed successfully, '||
                          'deferring and rejecting record'
     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
   END IF;
   p_header_id := l_header_id;
  -- If true the header is created on the backend already.
  -- The client header needs to be removed
    CSL_SERVICEL_WRAPPER_PKG.REJECT_RECORD(
                             P_USER_NAME      => p_user_name
                            ,P_TRANID         => p_tranid
                            ,P_SEQNO          => l_seqno
                            ,P_PK             => p_header_id
                            ,P_OBJECT_NAME    => g_object_name
                            ,P_PUB_NAME       => g_pub_name2
                            ,P_ERROR_MSG      => p_error_msg
                            ,X_RETURN_STATUS  => l_return_status
              );
    /*** Was defer successful? ***/
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** no -> rollback ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_header_id --p_record.debrief_header_id
        , v_object_name => g_object_name
        , v_message     => 'Defer record failed, rolling back to savepoint'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      ROLLBACK to save_rec;
    END IF;
  END IF;

IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( v_object_id   => p_header_id -- p_record.DEBRIEF_LINE_ID
  , v_object_name => g_object_name
  , v_message     => 'Leaving ' || g_object_name ||
                         '.APPLY_INSERT_HEADER'
  , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_header_id --p_record.DEBRIEF_LINE_ID
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT_HEADER:' ||
                         FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT_HEADER', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_header_id -- p_record.DEBRIEF_LINE_ID
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name ||
                         '.APPLY_INSERT_HEADER'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT_HEADER;


  /* New Procedure for ER - 3218717 */
  PROCEDURE call_charges
      ( p_debrief_header_id NUMBER
      ) IS

    -- Cursor to check if the Assignment Status is either of the
    -- following rejected, on_hold, cancelled, closed or completed
    CURSOR c_chk_task_status
      (  b_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE
      ) IS
    SELECT tst.rejected_flag, tst.on_hold_flag, tst.cancelled_flag,
           tst.closed_flag, tst.completed_flag
        FROM csf_debrief_headers dh, jtf_task_assignments tas,
             jtf_task_statuses_b tst
        WHERE dh.task_assignment_id = tas.task_assignment_id
          AND tas.assignment_status_id = tst.task_status_id
          AND dh.debrief_header_id = b_debrief_header_id;

    l_rejected_flag          VARCHAR2(1);
    l_on_hold_flag           VARCHAR2(1);
    l_cancelled_flag         VARCHAR2(1);
    l_closed_flag            VARCHAR2(1);
    l_completed_flag         VARCHAR2(1);

  BEGIN

    -- For a given debrief header check the task Assignment status.
    -- If it is one of the following -
    -- rejected, on_hold, cancelled, closed or completed then call the api
    --  csf_debrief_update_pkg.form_Call for processing charges

    OPEN c_chk_task_status ( p_debrief_header_id );
    FETCH c_chk_task_status INTO l_rejected_flag, l_on_hold_flag,
       l_cancelled_flag, l_closed_flag, l_completed_flag;
    CLOSE c_chk_task_status;

    IF ( (l_rejected_flag='Y') OR (l_on_hold_flag='Y') OR (l_cancelled_flag='Y')
         OR (l_closed_flag='Y') OR (l_completed_flag='Y') ) THEN
      csf_debrief_update_pkg.form_Call (1.0, p_debrief_header_id );
    END IF;

  END call_charges ;


PROCEDURE APPLY_INSERT_LINE
         (
           p_record         IN      c_debrief%ROWTYPE,
           p_user_name      IN      VARCHAR2,
           p_tranid         IN      NUMBER,
	   p_header_id      IN      NUMBER,
           p_error_msg      OUT NOCOPY     VARCHAR2,
           x_return_status  IN OUT NOCOPY  VARCHAR2
         ) IS

  -- Retrieve source_object_type_code
  CURSOR c_task_obj_code
         ( b_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE
         )
  IS
    SELECT source_object_type_code
    FROM   jtf_tasks_b jtb
    ,      jtf_task_assignments jta
    ,      csf_debrief_headers dbh
    WHERE  jtb.task_id = jta.task_id
    AND    jta.task_assignment_id = dbh.task_assignment_id
    AND    dbh.debrief_header_id = b_debrief_header_id;

  r_task_obj_code    c_task_obj_code%ROWTYPE;


  --Bug 3850061
  /*
  CURSOR c_material_transaction
         ( p_inventory_item_id p_record.inventory_item_id%TYPE
          , p_inv_organization_id p_record.receiving_inventory_org_id%TYPE
         )
  IS
    SELECT null
    FROM   CS_BILLING_TYPE_CATEGORIES tbc
    ,      MTL_SYSTEM_ITEMS_B         msi
    WHERE  tbc.BILLING_CATEGORY  = 'M'
    AND    msi.MATERIAL_BILLABLE_FLAG = tbc.BILLING_TYPE
    AND    msi.INVENTORY_ITEM_ID = p_inventory_item_id
    AND    msi.ORGANIZATION_ID = p_inv_organization_id;

  -- For Bug Fix 3168617
  CURSOR c_debrief_header
     ( b_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE
     ) IS
  SELECT debrief_number
    FROM csf_debrief_headers
    WHERE debrief_header_id = b_debrief_header_id;

  r_material_transaction   c_material_transaction%ROWTYPE;
*/

  l_return_status          VARCHAR2(1);
  l_header_id              p_record.debrief_header_id%type;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(240);
  l_date                   DATE;

  l_spare_update_status    p_record.spare_update_status%TYPE;
  l_transaction_type_id    NUMBER;
  l_inventory_org_id       p_record.issuing_inventory_org_id%TYPE;
  l_sub_inventory_code     p_record.issuing_sub_inventory_code%TYPE;
  l_locator_id             p_record.issuing_locator_id%TYPE;
  l_debrief_number         CSF_DEBRIEF_HEADERS.DEBRIEF_NUMBER%TYPE;
  l_transaction_id         NUMBER;
  l_transaction_header_id  NUMBER;

  -- l_line_rec and l_line_tbl are record/table types from the debrief API
  l_line_rec               csf_debrief_pub.debrief_line_rec_type;
  l_line_tbl               csf_debrief_pub.debrief_line_tbl_type;

BEGIN

  l_date := SYSDATE;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT_LINE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Check if header_id is given or not from APPLY_INSERT_HEADER
  IF p_header_id IS NULL THEN
    l_header_id :=p_record.debrief_header_id;
  ELSE
    l_header_id := p_header_id;
  END IF;

  -- ER 3218717

  IF ( g_header_id IS NOT NULL ) AND ( g_header_id <> l_header_id ) THEN

    call_charges ( g_header_id );
    g_header_id := l_header_id;

  ELSIF ( g_header_id IS NULL ) THEN
     g_header_id := l_header_id;

  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID
    , v_object_name => g_object_name
    , v_message     => 'l_header_id = ' || l_header_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  --Bug 3850061
  /*
  -- Verify if transaction is a non-IB material transaction and a subinventory is involved
  OPEN c_material_transaction(p_record.inventory_item_id,
    NVL(p_record.issuing_inventory_org_id, p_record.receiving_inventory_org_id));
  FETCH c_material_transaction INTO r_material_transaction;
  IF c_material_transaction%FOUND
   AND (p_record.issuing_sub_inventory_code IS NOT NULL
    OR p_record.receiving_sub_inventory_code IS NOT NULL) THEN
    -- yes -> update on-hand quantity in Oracle Inventory using Spares Management API

    IF (   p_record.receiving_inventory_org_id IS NULL
       AND p_record.issuing_inventory_org_id   IS NOT NULL
       )
    THEN
      l_transaction_type_id := 93; -- miscellaneous issue
      l_inventory_org_id    := p_record.issuing_inventory_org_id;
      l_sub_inventory_code  := p_record.issuing_sub_inventory_code;
      l_locator_id          := p_record.issuing_locator_id;
    ELSIF (   p_record.receiving_inventory_org_id IS NOT NULL
          AND p_record.issuing_inventory_org_id   IS NULL
          )
    THEN
      l_transaction_type_id := 94; -- miscellaneous receipt
      l_inventory_org_id    := p_record.receiving_inventory_org_id;
      l_sub_inventory_code  := p_record.receiving_sub_inventory_code;
      l_locator_id          := p_record.receiving_locator_id;
    END IF;

    -- For Bug Fix 3168617. Need to pass debrief_number
    -- to p_transaction_source_name
    OPEN c_debrief_header (l_header_id);
    FETCH c_debrief_header INTO l_debrief_number;
    CLOSE c_debrief_header;

    csp_transactions_pub.transact_material
      ( p_api_version              => 1.0
      , p_init_msg_list            => FND_API.G_TRUE
      , p_commit                   => FND_API.G_FALSE
      , px_transaction_id          => l_transaction_id
      , px_transaction_header_id   => l_transaction_header_id
      , p_inventory_item_id        => p_record.inventory_item_id
      , p_organization_id          => l_inventory_org_id
      , p_subinventory_code        => l_sub_inventory_code
      , p_locator_id               => l_locator_id
      , p_lot_number               => p_record.item_lotnumber
      , p_revision                 => p_record.item_revision
      , p_serial_number            => p_record.item_serial_number
      , p_quantity                 => p_record.quantity
      , p_uom                      => p_record.uom_code
      , p_source_id                => NULL
      , p_source_line_id           => NULL
      , p_transaction_type_id      => l_transaction_type_id
      , p_transfer_to_subinventory => NULL
      , p_transfer_to_locator      => NULL
      , p_transfer_to_organization => NULL
      , p_transaction_source_id    => NULL
      , p_transaction_source_name  => l_debrief_number
      , p_trx_source_line_id       => NULL
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data
      );

    -- Check whether API error occurred
    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      -- Successful -> set spares update status flag in debrief line to 'SUCCEEDED',
      -- so the quantities won't be updated again when the FSE confirms the debriefline
      -- in connected debrief
      l_spare_update_status := 'SUCCEEDED';
    ELSE
      -- spares update failed -> continue debrief line creation but set spares update status to 'FAILED'
      l_spare_update_status := 'FAILED';
    END IF;

  END IF;
  CLOSE c_material_transaction;
*/

  -- Create debrief line
  l_line_rec.debrief_line_id	          := p_record.debrief_line_id;
  l_line_rec.debrief_header_id            := l_header_id;
  l_line_rec.issuing_inventory_org_id     := p_record.issuing_inventory_org_id;
  l_line_rec.issuing_sub_inventory_code   := p_record.issuing_sub_inventory_code;
  l_line_rec.issuing_locator_id           := p_record.issuing_locator_id;
  l_line_rec.receiving_inventory_org_id   := p_record.receiving_inventory_org_id;
  l_line_rec.receiving_sub_inventory_code := p_record.receiving_sub_inventory_code;
  l_line_rec.receiving_locator_id         := p_record.receiving_locator_id;
  l_line_rec.last_update_date             := l_date;
  l_line_rec.last_updated_by              := FND_GLOBAL.USER_ID;
  l_line_rec.creation_date                := l_date;
  l_line_rec.created_by                   := FND_GLOBAL.USER_ID;
  l_line_rec.last_update_login            := FND_GLOBAL.LOGIN_ID;
  l_line_rec.spare_update_status          := l_spare_update_status;
  l_line_rec.inventory_item_id            := p_record.inventory_item_id;
  l_line_rec.txn_billing_type_id          := p_record.txn_billing_type_id;
  l_line_rec.service_date                 := p_record.service_date;
  l_line_rec.debrief_line_number          := To_Char(p_record.debrief_line_id );
  l_line_rec.quantity                     := p_record.quantity;
  l_line_rec.uom_code                     := p_record.uom_code;
  l_line_rec.item_serial_number           := p_record.item_serial_number;
  l_line_rec.item_revision                := p_record.item_revision;
  l_line_rec.item_lotnumber               := p_record.item_lotnumber;
  l_line_rec.business_process_id          := p_record.business_process_id;
  l_line_rec.channel_code                 := 'CSF_LAPTOP';
  l_line_rec.expense_amount               := p_record.expense_amount;
  l_line_rec.currency_code                := p_record.currency_code;
  l_line_rec.labor_start_date             := p_record.labor_start_date;
  l_line_rec.labor_end_date               := p_record.labor_end_date;
  l_line_rec.starting_mileage             := p_record.starting_mileage;
  l_line_rec.ending_mileage               := p_record.ending_mileage;
  l_line_rec.instance_id                  := p_record.instance_id;
  l_line_rec.PARENT_PRODUCT_ID            := p_record.PARENT_PRODUCT_ID;
  l_line_rec.transaction_type_id          := p_record.transaction_type_id;
  /* New code for Reason */
  l_line_rec.material_reason_code         := p_record.material_reason_code;
  l_line_rec.labor_reason_code            := p_record.labor_reason_code;
  l_line_rec.expense_reason_code          := p_record.expense_reason_code;
  l_line_rec.disposition_code             := p_record.disposition_code;
  -- ER 3223881 - Return Reason Code
  l_line_rec.return_reason_code           := p_record.return_reason_code;
  -- ER 3746450
  l_line_rec.removed_product_id            := p_record.removed_product_id;
  /* Support for DFF - 3737857 */
  l_line_rec.attribute1                   := p_record.attribute1;
  l_line_rec.attribute2                   := p_record.attribute2;
  l_line_rec.attribute3                   := p_record.attribute3;
  l_line_rec.attribute4                   := p_record.attribute4;
  l_line_rec.attribute5                   := p_record.attribute5;
  l_line_rec.attribute6                   := p_record.attribute6;
  l_line_rec.attribute7                   := p_record.attribute7;
  l_line_rec.attribute8                   := p_record.attribute8;
  l_line_rec.attribute9                   := p_record.attribute9;
  l_line_rec.attribute10                  := p_record.attribute10;
  l_line_rec.attribute11                  := p_record.attribute11;
  l_line_rec.attribute12                  := p_record.attribute12;
  l_line_rec.attribute13                  := p_record.attribute13;
  l_line_rec.attribute14                  := p_record.attribute14;
  l_line_rec.attribute15                  := p_record.attribute15;
  l_line_rec.attribute_category           := p_record.attribute_category;

  l_line_tbl(1) := l_line_rec;

  -- Fetch SOURCE_OBJECT_TYPE_CODE from task record
  OPEN c_task_obj_code
       ( l_header_id
       );
  FETCH c_task_obj_code INTO r_task_obj_code;
  CLOSE c_task_obj_code;

  csf_debrief_pub.create_debrief_lines
    ( p_api_version_number      => 1.0
    , p_init_msg_list           => FND_API.G_TRUE
    , p_commit                  => FND_API.G_FALSE
    , x_return_status           => x_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_debrief_header_id       => l_header_id
    , p_debrief_line_tbl        => l_line_tbl
    , p_source_object_type_code => r_task_obj_code.source_object_type_code
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT_LINE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN

  --Bug 3850061
  /*
  IF c_debrief_header%ISOPEN THEN
     CLOSE c_debrief_header;
  END IF;
  */

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT_LINE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT_LINE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT_LINE;


  /***
    This procedure is called by PROCESS_DEBRIEF
  ***/

  PROCEDURE APPLY_UPDATE_HEADER
         (
           p_user_name      IN      VARCHAR2,
           p_tranid         IN      NUMBER,
	   p_header_id      IN OUT NOCOPY     NUMBER,
           p_error_msg      OUT NOCOPY     VARCHAR2,
           x_return_status  IN OUT NOCOPY  VARCHAR2
         ) IS
  /***
    Name:
      APPLY_UPDATE_HEADER

    Purpose:
      If debrief header gets updated, say DFF fields got changed in client
      application, Then process all debrief headers even if no debrief
      lines associated with it in INQ.
      After processing these debrief headers, delete them from the debrief
      header inqueue.
  ***/

  /***
    Cursor to retrieve task_assignment_id to check if there is already
    an record created on the backend for this header.
  ***/

    CURSOR c_debrief_assignment_id ( b_debrief_header_id NUMBER) is
      SELECT   task_assignment_id, seqno$$
      FROM     CSL_CSF_DEBRIEF_HEADERS_INQ dbh
      WHERE    debrief_header_id = b_debrief_header_id;
    r_debrief_assignment_id c_debrief_assignment_id%ROWTYPE;

    CURSOR c_csf_debrief_headers (
      b_debrief_header_id CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE) IS
      SELECT * FROM  CSL_CSF_DEBRIEF_HEADERS_INQ
      WHERE debrief_header_id = b_debrief_header_id;
    r_csf_debrief_headers c_csf_debrief_headers%ROWTYPE;

    l_deb_rec             csf_debrief_pub.debrief_rec_type;
    l_date                DATE;

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(240);

    l_process_status         NUMBER;
    l_header_exists          BOOLEAN;
    l_header_id              NUMBER; -- p_record.debrief_header_id%TYPE;
    l_task_assignment_id     NUMBER;
    l_seqno                  NUMBER;

  BEGIN
    l_date := SYSDATE;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_header_id -- p_record.DEBRIEF_LINE_ID
      , v_object_name => g_object_name
      , v_message     => 'Entering ' || g_object_name ||
                         '.APPLY_UPDATE_HEADER'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;


    /***
      First check if header already exists in the backend or not. If so
      then do not create a new one.  The situation could occur where
      multiple debrief lines have been created for 1 debrief header.
      In this case the header only has is created the first time and
      should not be created a second time.
    ***/

    l_header_id := p_header_id; --p_record.debrief_header_id;
    OPEN  c_debrief_assignment_id (l_header_id);
    FETCH c_debrief_assignment_id INTO r_debrief_assignment_id;
    IF c_debrief_assignment_id%FOUND THEN
      l_task_assignment_id := r_debrief_assignment_id.task_assignment_id;
    ELSE
      l_task_assignment_id := NULL;
    END IF;
    -- Also set seqno number because it is different from the line.
    l_seqno := r_debrief_assignment_id.seqno$$;
    CLOSE c_debrief_assignment_id;
    l_header_exists := DEBRIEF_HEADER_EXISTS(l_header_id,
                       l_task_assignment_id);

    IF NOT l_header_exists THEN
      APPLY_INSERT_HEADER( p_user_name => p_user_name
             , p_tranid   => p_tranid
  	       , p_header_id  => p_header_id
             , p_error_msg  => p_error_msg
             , x_return_status  => x_return_status );

    ELSE
      SAVEPOINT save_rec;
      -- update debrief header.
      OPEN  c_csf_debrief_headers (l_header_id);
      FETCH c_csf_debrief_headers INTO r_csf_debrief_headers;
      CLOSE c_csf_debrief_headers;

      -- update existing debrief header record
      l_deb_rec.debrief_header_id  := r_csf_debrief_headers.debrief_header_id;
      l_deb_rec.debrief_date       := r_csf_debrief_headers.debrief_date;
      l_deb_rec.debrief_status_id  := r_csf_debrief_headers.debrief_status_id;
      l_deb_rec.task_assignment_id := r_csf_debrief_headers.task_assignment_id;
      l_deb_rec.last_update_date   := l_date;
      l_deb_rec.last_updated_by    := FND_GLOBAL.USER_ID;
      l_deb_rec.creation_date      := l_date;
      l_deb_rec.created_by         := FND_GLOBAL.USER_ID;
      l_deb_rec.last_update_login  := FND_GLOBAL.LOGIN_ID;
      l_deb_rec.attribute1         := r_csf_debrief_headers.attribute1;
      l_deb_rec.attribute2         := r_csf_debrief_headers.attribute2;
      l_deb_rec.attribute3         := r_csf_debrief_headers.attribute3;
      l_deb_rec.attribute4         := r_csf_debrief_headers.attribute4;
      l_deb_rec.attribute5         := r_csf_debrief_headers.attribute5;
      l_deb_rec.attribute6         := r_csf_debrief_headers.attribute6;
      l_deb_rec.attribute7         := r_csf_debrief_headers.attribute7;
      l_deb_rec.attribute8         := r_csf_debrief_headers.attribute8;
      l_deb_rec.attribute9         := r_csf_debrief_headers.attribute9;
      l_deb_rec.attribute10        := r_csf_debrief_headers.attribute10;
      l_deb_rec.attribute11        := r_csf_debrief_headers.attribute11;
      l_deb_rec.attribute12        := r_csf_debrief_headers.attribute12;
      l_deb_rec.attribute13        := r_csf_debrief_headers.attribute13;
      l_deb_rec.attribute14        := r_csf_debrief_headers.attribute14;
      l_deb_rec.attribute15        := r_csf_debrief_headers.attribute15;
      l_deb_rec.attribute_category := r_csf_debrief_headers.attribute_category;

      csf_debrief_pub.update_debrief
        ( p_api_version_number => 1.0
        , p_init_msg_list      => FND_API.G_TRUE
        , p_commit             => FND_API.G_FALSE
        , p_debrief_rec        => l_deb_rec
        , x_return_status      => x_return_status
        , x_msg_count          => l_msg_count
        , x_msg_data           => l_msg_data
      );

    -- Delete debrief header record from debrief header inqueue.

    /*** was record processed successfully? ***/
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
          ( v_object_id   => l_header_id -- put PK column here
            , v_object_name => g_object_name
            , v_message     => 'Record successfully processed, '||
                               ' deleting from inqueue'
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
      (
         p_user_name     => p_user_name,
         p_tranid        => p_tranid,
         p_seqno         => l_seqno,
         p_pk            => p_header_id, -- p_record.debrief_header_id,
         p_object_name   => g_object_name,
         p_pub_name      => g_pub_name2,
         p_error_msg     => p_error_msg,
         x_return_status => l_return_status
      );

      /*** was delete successful? ***/
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_header_id --p_record.debrief_header_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling '||
                             ' back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK to save_rec;
      END IF;  -- end if delete failed

    ELSE -- else when record was not processed successfully

      /*** Record was not processed successfully or delete failed
           -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN

        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_header_id --p_record.debrief_header_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, '||
                           'deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
      (
         p_user_name     => p_user_name
        ,p_tranid        => p_tranid
        ,p_seqno         => l_seqno
        ,p_pk            => p_header_id --p_record.debrief_header_id
        ,p_object_name   => g_object_name
        ,p_pub_name      => g_pub_name2
        ,p_error_msg     => p_error_msg
        ,x_return_status => l_return_status
      );

      /*** Was defer successful? ***/
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /*** no -> rollback ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_header_id --p_record.debrief_header_id
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed,rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
          ROLLBACK to save_rec;
          END IF;
        END IF; -- end of if defer failed.
      END IF; -- end of checking was record processed successfully
    END IF; -- end of else DML_TYPE = 'U'

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_header_id -- p_record.DEBRIEF_LINE_ID
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name ||
                         '.APPLY_UPDATE_HEADER'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  EXCEPTION WHEN OTHERS THEN

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_header_id --p_record.DEBRIEF_LINE_ID
      , v_object_name => g_object_name
      , v_message     => 'Exception occurred in APPLY_UPDATE_HEADER:' ||
                         FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE_HEADER', sqlerrm);
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error   => TRUE
      );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_header_id -- p_record.DEBRIEF_LINE_ID
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name ||
                         '.APPLY_UPDATE_HEADER'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;
  END APPLY_UPDATE_HEADER;


  /***
    This procedure is called by APPLY_CLIENT_CHANGES when an updated record
    is to be processed.
    No update for debrief lines yet.
  ***/
PROCEDURE APPLY_UPDATE
         (
           p_record         IN      c_debrief%ROWTYPE,
           p_user_name      IN      VARCHAR2,
           p_tranid         IN      NUMBER,
           p_error_msg      OUT NOCOPY     VARCHAR2,
           x_return_status  IN OUT NOCOPY  VARCHAR2
         ) IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- For Debrief no update is possible, so return success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_UPDATE:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error   => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.DEBRIEF_LINE_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

  /***
   This procedure is called from APPLY_CLIENT_CHANGES and processes all
   debrief lines that a debrief header record in the debrief header inqueue.
  ***/
PROCEDURE PROCESS_DEBRIEF
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS
  l_error_msg VARCHAR2(4000);
  l_header_id NUMBER := 0;
  j NUMBER := 0;
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Process_Debrief'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /***
    Loop through cursor with all debrief line records in debrief line
    inqueue, that have a debrief header in the debrief header inqueue.
  ***/
  FOR r_debrief IN c_debrief ( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    IF r_debrief.dmltype$$='I' THEN
      l_header_id := r_debrief.DEBRIEF_HEADER_ID;
    APPLY_INSERT_HEADER
      (
          -- p_record        => r_debrief
        p_user_name     => p_user_name
        , p_tranid        => p_tranid
        , p_header_id     => l_header_id
        , p_error_msg     => l_error_msg
        , x_return_status => x_return_status
      );

    APPLY_INSERT_LINE
      (
          p_record        => r_debrief
        , p_user_name     => p_user_name
        , p_tranid        => p_tranid
        , p_header_id     => l_header_id
        , p_error_msg     => l_error_msg
        , x_return_status => x_return_status
      );

    /*** was record processed successfully? ***/
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Line record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_debrief.seqno$$,
          r_debrief.DEBRIEF_LINE_ID, -- put PK column here
          g_object_name,
          g_pub_name,
          l_error_msg,
          x_return_status
        );

      /*** was delete successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Deleting line record from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed
           -> defer and reject record ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Line record not processed successfully, deferring and rejecting record'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_debrief.seqno$$
       , r_debrief.DEBRIEF_LINE_ID -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Defer line record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        g_deferred_line_id_tbl(j) := r_debrief.DEBRIEF_LINE_ID;
        j := j+1;
        ROLLBACK TO save_rec;
      END IF;
    END IF;
    ELSIF r_debrief.dmltype$$='U' THEN

      APPLY_UPDATE
         (
           p_record        => r_debrief,
           p_user_name     => p_user_name,
           p_tranid        => p_tranid,
           p_error_msg     => l_error_msg,
           x_return_status => x_return_status);

    END IF;
  END LOOP;

  -- ER 3218717
  -- Calling Charges for the last Debrief in the Queue
  IF ( l_header_id <> 0 ) THEN
    call_charges ( l_header_id );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Process_Debrief'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in PROCESS_DEBRIEF:' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;

END PROCESS_DEBRIEF;

/***
  This procedure is called from APPLY_CLIENT_CHANGES and processes all debrief lines
  that have no debrief header record in the debrief header inqueue.
***/
PROCEDURE PROCESS_DEBRIEF_NO_HEADERS
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS
  l_error_msg      VARCHAR2(4000);
    l_header_id NUMBER := 0 ;
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Process_Debrief_No_Headers'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /***
    Loop through cursor with all debrief line records in debrief line inqueue,
    that have no debrief header in the debrief header inqueue (but have one in the backend).
  ***/
  FOR r_debrief IN c_debrief_no_headers ( p_user_name, p_tranid) LOOP
    SAVEPOINT save_rec;

    -- ER 3218717
    l_header_id := r_debrief.DEBRIEF_HEADER_ID;


    /*** apply record ***/
   /*** Bug 3373654  not to handle deferred debrief line as no-header line ***/
   --Bug 3702875
      IF (g_deferred_line_id_tbl.COUNT > 0) THEN
        IF(g_deferred_line_id_tbl.EXISTS(r_debrief.DEBRIEF_LINE_ID)) THEN
          NULL;
        ELSE
          APPLY_INSERT_LINE
          (
            p_record        => r_debrief
            , p_user_name     => p_user_name
            , p_tranid        => p_tranid
            , p_header_id     => NULL
            , p_error_msg     => l_error_msg
            , x_return_status => x_return_status
          );
        END IF;
      ELSE
        APPLY_INSERT_LINE --Bug 3702875
        (
          p_record        => r_debrief
        , p_user_name     => p_user_name
        , p_tranid        => p_tranid
        , p_header_id     => NULL
        , p_error_msg     => l_error_msg
        , x_return_status => x_return_status
        );
      END IF;

    /*** was record processed successfully? ***/
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_debrief.seqno$$,
          r_debrief.DEBRIEF_LINE_ID, -- put PK column here
          g_object_name,
          g_pub_name,
          l_error_msg,
          x_return_status
        );

      /*** was delete successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      --Since the record was not processed successfully, rollback to the point before
      --calling APPLY_INSERT_LINE
      ROLLBACK to save_rec;
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_debrief.seqno$$
       , r_debrief.DEBRIEF_LINE_ID -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , x_return_status
       );

      /*** Was defer successful? ***/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_debrief.DEBRIEF_LINE_ID -- put PK column here
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;
  END LOOP;

  -- ER 3218717
  -- Calling Charges for the last Debrief in the Queue
  IF (l_header_id <> 0) THEN
    call_charges ( l_header_id );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Process_Debrief_No_Headers'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

/*** clear deferred_line queue   ****/
IF (g_deferred_line_id_tbl.COUNT > 0 ) THEN
       g_deferred_line_id_tbl.DELETE;
END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in Process_Debrief_No_Headers: ' || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

END PROCESS_DEBRIEF_NO_HEADERS;

  /***
  This procedure is called from APPLY_CLIENT_CHANGES and processes all
  debrief lines that have no debrief header record in the debrief header
  inqueue.
  ***/

  PROCEDURE PROCESS_DEBRIEF_NO_LINES
           (
             p_user_name     IN VARCHAR2,
             p_tranid        IN NUMBER,
             x_return_status IN OUT NOCOPY VARCHAR2
           )
  IS
    l_error_msg      VARCHAR2(4000);
    l_header_id      NUMBER;
  BEGIN

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'Entering ' || g_object_name ||
                         '.PROCESS_DEBRIEF_NO_LINES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;


    /***
      Loop through cursor with all debrief header records in debrief
      header inqueue, that have no debrief lines inqueue
    ***/

    FOR r_debrief IN c_debrief_no_lines ( p_user_name, p_tranid) LOOP
      l_header_id := r_debrief.DEBRIEF_HEADER_ID;
      /*** apply record ***/
      IF r_debrief.dmltype$$='I' THEN
        APPLY_INSERT_HEADER
        (
          --  p_record        => r_debrief
          --,
            p_user_name     => p_user_name
          , p_tranid        => p_tranid
          , p_header_id     => l_header_id
          , p_error_msg     => l_error_msg
          , x_return_status => x_return_status
        );

      ELSIF r_debrief.dmltype$$='U' THEN

        APPLY_UPDATE_HEADER
           (
             -- p_record        => r_debrief,
             p_user_name     => p_user_name,
             p_tranid        => p_tranid,
             p_error_msg     => l_error_msg,
             p_header_id     => l_header_id,
             x_return_status => x_return_status);

      END IF;

    END LOOP;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name ||
                         '.PROCESS_DEBRIEF_NO_LINES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  EXCEPTION WHEN OTHERS THEN

    /*** catch and log exceptions ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'Exception occurred in PROCESS_DEBRIEF_NO_LINES: '
                         || FND_GLOBAL.LOCAL_CHR(10) || sqlerrm
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;

  END PROCESS_DEBRIEF_NO_LINES;

 /***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication
  item CSF_DEBRIEF_LINES is dirty. This happens when a mobile field service
  device executed DML on an updatable table and did a fast sync. This
  procedure will insert the data that came from mobile into the backend
  tables using public APIs.
 ***/

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_header_id := NULL;
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => null
        , v_object_name => g_object_name
        , v_message     => 'Entering ' || g_object_name ||
                           '.Apply_Client_Changes'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;

      -- First process all debrief lines that have a debrief header.
      -- Delete them after processing.
      PROCESS_DEBRIEF(p_user_name, p_tranid, x_return_status);

      -- Then process all remaining debrief lines (no debrief header).
      -- These already have a debrief header in Apps.
      PROCESS_DEBRIEF_NO_HEADERS(p_user_name, p_tranid, x_return_status);

      -- Then process the debrief headers (no debrief lines).
      -- For example, DFF updates on local client etc.
      PROCESS_DEBRIEF_NO_LINES(p_user_name, p_tranid, x_return_status);

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => null
        , v_object_name => g_object_name
        , v_message     => 'Leaving ' || g_object_name ||
                           '.Apply_Client_Changes'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;

END APPLY_CLIENT_CHANGES;
END CSL_DEBRIEF_PKG;

/
