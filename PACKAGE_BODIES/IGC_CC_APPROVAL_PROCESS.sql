--------------------------------------------------------
--  DDL for Package Body IGC_CC_APPROVAL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_APPROVAL_PROCESS" AS
/* $Header: IGCCAPPB.pls 120.7.12010000.2 2008/08/04 14:48:51 sasukuma ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'IGC_CC_APPROVAL_PROCESS';
g_profile_name          VARCHAR2(255)   := 'IGC_DEBUG_LOG_DIRECTORY';

--l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
g_debug_mode            VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--Variables for ATG Central logging
g_debug_level           NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level           NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level            NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level           NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level           NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level           NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level           NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path                  VARCHAR2(255) := 'IGC.PLSQL.IGCCAPPB.IGC_CC_APPROVAL_PROCESS.';


PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);


PROCEDURE change_document_status
 ( p_itemtype           IN      VARCHAR2
 , p_itemkey            IN      VARCHAR2
 , p_cc_header_id	IN	NUMBER
 , p_cc_state		IN	VARCHAR2
 , p_cc_type		IN	VARCHAR2
 , p_cc_preparer_id	IN	NUMBER
 , p_cc_owner_id	IN	NUMBER
 , p_cc_current_owner	IN	NUMBER
 , p_cc_apprvl_status	IN	VARCHAR2
 , p_cc_encumb_status	IN	VARCHAR2
 , p_cc_action_request	IN	VARCHAR2
 , p_error_code		OUT NOCOPY	NUMBER
  ) ;
PROCEDURE Create_Action_History
 ( p_cc_header_id	IN	IGC_CC_HEADERS.cc_header_id%TYPE
 , p_cc_version_num	IN	IGC_CC_HEADERS.cc_version_num%TYPE
 , p_cc_state		IN	IGC_CC_HEADERS.cc_state%TYPE
 , p_cc_old_cc_state	IN      IGC_CC_HEADERS.cc_state%TYPE
 , p_cc_ctrl_status	IN	IGC_CC_HEADERS.cc_ctrl_status%TYPE
 , p_cc_apprvl_status	IN	IGC_CC_HEADERS.cc_apprvl_status%TYPE
 , p_cc_notes		IN	IGC_CC_ACTIONS.cc_action_notes%TYPE
 , p_action_requested   IN 	VARCHAR2
 , p_error_code		OUT NOCOPY	NUMBER
 ) ;

   PROCEDURE message_token(
   tokname IN VARCHAR2,
   tokval  IN VARCHAR2
) IS

BEGIN

  IGC_MSGS_PKG.message_token (p_tokname => tokname,
                              p_tokval  => tokval);

END message_token;


/****************************************************************************/

-- Sets the Message Stack

PROCEDURE add_message(
   appname IN VARCHAR2,
   msgname IN VARCHAR2
) IS

i  BINARY_INTEGER;
l_full_path             VARCHAR2(255);
BEGIN

   l_full_path:= g_path || 'add_message';

   IGC_MSGS_PKG.add_message (p_appname => appname,
                             p_msgname => msgname);
   IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Raising an execution exception: '||fnd_msg_pub.get(1,FND_API.G_FALSE));
   END IF;

END add_message;

PROCEDURE Generate_Message
IS
l_cur                     NUMBER;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(32000) ;
l_full_path               VARCHAR2(255);

BEGIN

  l_full_path:= g_path || 'Generate_Message';

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Error during the execution ');
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                              p_data  => l_msg_data );

  IF l_msg_count >0 THEN
     l_msg_data :='';

     FOR l_cur IN 1..l_msg_count LOOP
--        l_msg_data :=l_msg_data||' Mes No'||l_cur||' '||FND_MSG_PUB.GET(l_cur,FND_API.G_FALSE);
        l_msg_data :=l_msg_data||' '||l_cur||' '||FND_MSG_PUB.GET(l_cur,FND_API.G_FALSE);
        IF(g_error_level >= g_debug_level) THEN
            FND_LOG.STRING(g_error_level, l_full_path, l_msg_data);
        END IF;
     END LOOP;
  ELSE
     IF(g_error_level >= g_debug_level) THEN
         FND_LOG.STRING(g_error_level, l_full_path, l_msg_data);
     END IF;
     l_msg_data :='Error stack has no data';
  END IF;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Error text is '||l_msg_data);
  END IF;

END Generate_Message;


PROCEDURE Preparer_Can_Approve
( p_api_version         IN      NUMBER	,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER	 := FND_API.G_VALID_LEVEL_FULL	,
  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER  ,
  x_msg_data            OUT NOCOPY     VARCHAR2,
  p_org_id	        IN	NUMBER  ,
  p_cc_state	        IN	VARCHAR2,
  p_cc_type             IN	VARCHAR2,
  x_result              OUT NOCOPY     VARCHAR2
) IS

l_api_name           CONSTANT VARCHAR2(30)   := 'Preparer_Can_Approve';
l_api_version        CONSTANT NUMBER         := 1.0;

l_can_approve VARCHAR2(2);

CURSOR c_setup_opt IS
  SELECT UPPER(icrc.cc_can_prpr_apprv_flag)
    FROM   IGC_CC_ROUTING_CTRLS icrc
   WHERE  icrc.org_id   = p_org_id
        AND    icrc.cc_state = p_cc_state
        AND    icrc.cc_type  = p_cc_type;

CURSOR c_meaning_state IS
   SELECT meaning
     FROM fnd_lookups
    WHERE lookup_code     = p_cc_state
          AND lookup_type = 'IGC_CC_STATE';

CURSOR c_meaning_type IS
   SELECT meaning
     FROM fnd_lookups
    WHERE lookup_code     = p_cc_type
          AND lookup_type = 'IGC_CC_TYPE';

CURSOR c_org_name IS
   SELECT name
     FROM hr_organization_units
    WHERE organization_id = p_org_id;

l_value VARCHAR2(255);
l_full_path             VARCHAR2(255);

BEGIN

  l_full_path:= g_path || 'Preparer_Can_Approve';

  SAVEPOINT       Preparer_Can_Approve;
  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call ( l_api_version      ,
                                       p_api_version      ,
                                       l_api_name         ,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  OPEN c_setup_opt;
  FETCH c_setup_opt INTO   l_can_approve;

  IF c_setup_opt%NOTFOUND THEN

    CLOSE c_setup_opt;

    FND_MESSAGE.SET_NAME ('IGC',  'IGC_CC_OPTION_NOT_FOUND');

    OPEN c_meaning_type ;
    FETCH c_meaning_type INTO l_value;
    CLOSE c_meaning_type;
    FND_MESSAGE.SET_TOKEN ('CC_TYPE',l_value);

    OPEN c_meaning_state ;
    FETCH c_meaning_state INTO l_value;
    CLOSE c_meaning_state;
    FND_MESSAGE.SET_TOKEN ('CC_STATE',l_value);

    OPEN c_org_name ;
    FETCH c_org_name INTO l_value;
    CLOSE c_org_name;

    FND_MESSAGE.SET_TOKEN ('ORG_ID',l_value);

    FND_MSG_PUB.ADD;
    raise FND_API.G_EXC_ERROR;
  END IF;

  CLOSE c_setup_opt;

  IF l_can_approve = 'Y' THEN
     x_result := FND_API.G_TRUE;
  ELSE
     x_result := FND_API.G_FALSE;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Preparer_Can_Approve;

     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF (g_excep_level >=  g_debug_level ) THEN
        FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Preparer_Can_Approve;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF (g_excep_level >=  g_debug_level ) THEN
        FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
   WHEN OTHERS THEN
     ROLLBACK to Preparer_Can_Approve;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;

END Preparer_Can_Approve;


PROCEDURE Approved_By_Preparer
 ( p_api_version	IN	NUMBER
 , p_init_msg_list	IN	VARCHAR2
 , p_commit		IN  	VARCHAR2
 , p_validation_level	IN	NUMBER
 , p_return_status	OUT NOCOPY	VARCHAR2
 , p_msg_count		OUT NOCOPY	NUMBER
 , p_msg_data		OUT NOCOPY	VARCHAR2
 , p_cc_header_id	IN	NUMBER
 , p_org_id		IN	NUMBER
 , p_sob_id		IN	NUMBER
 , p_cc_state		IN	VARCHAR2
 , p_cc_type		IN	VARCHAR2
 , p_cc_preparer_id	IN	NUMBER
 , p_cc_owner_id	IN	NUMBER
 , p_cc_current_owner	IN	NUMBER
 , p_cc_apprvl_status	IN	VARCHAR2
 , p_cc_encumb_status	IN	VARCHAR2
 , p_cc_ctrl_status	IN	VARCHAR2
 , p_cc_version_number	IN	NUMBER
 , p_cc_notes		IN	VARCHAR2
 , p_acct_date          IN      DATE
 ) IS

l_cc_header_id		NUMBER         := p_cc_header_id;
l_cc_state		VARCHAR2(2)    := p_cc_state;
l_cc_old_cc_state   VARCHAR2(2)    := p_cc_state;
l_cc_type		VARCHAR2(2)    := p_cc_type;
l_cc_preparer_id	NUMBER         := p_cc_preparer_id;
l_cc_owner_id		NUMBER         := p_cc_owner_id;
l_cc_current_owner	NUMBER         := p_cc_current_owner;
l_cc_apprvl_status	VARCHAR2(2)    := p_cc_apprvl_status;
l_cc_encumb_status	VARCHAR2(2)    := p_cc_encumb_status;
l_cc_ctrl_status	VARCHAR2(2)    := p_cc_ctrl_status;
l_cc_version_number	NUMBER	       := p_cc_version_number;
l_cc_notes		VARCHAR2(240)  := p_cc_notes;
l_cc_org_id		NUMBER	       := p_org_id;
l_cc_sob_id		NUMBER	       := p_sob_id;

l_cc_Action_requested	VARCHAR2(240) := 'APPROVE';
l_encumbrance_on	VARCHAR2(1);
l_error_status		NUMBER := 0;
l_return_status		VARCHAR2(1);
l_bc_status		VARCHAR2(1);
l_error_code		NUMBER := 0;
l_mode			VARCHAR2(1);
l_status_flag		VARCHAR2(1);
l_msg_data		VARCHAR2(2000);
l_msg_count		NUMBER := 0;
l_msg		VARCHAR2(2000);
l_count		NUMBER := 0;

l_api_name              CONSTANT VARCHAR2(30)   := 'Approved_By_Preparer';
l_api_version           CONSTANT NUMBER         := 1.0;
l_full_path             VARCHAR2(255);

BEGIN

  l_full_path:= g_path || 'Approved_By_Preparer';
   -- check if the budgetary control is ON for a given cc state
  SAVEPOINT       Approved_By_Preparer;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version      ,
                                       p_api_version      ,
                                       l_api_name         ,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;


--  IF (upper(fnd_profile.value('IGC_DEBUG_ENABLED')) ='Y') THEN
--     IGC_MSGS_PKG.g_debug_mode := TRUE;
--  ELSE
--     IGC_MSGS_PKG.g_debug_mode := FALSE;
--  END IF;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, '**************************************************************************');
     Put_Debug_Msg(l_full_path, 'Procedure '||l_api_name||' called , Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
     Put_Debug_Msg(l_full_path, '**************************************************************************');

     Put_Debug_Msg(l_full_path, ' CCHeaderID '||p_cc_header_id
     ||' OrgID '||  p_org_id
     ||' SOBID '||  p_sob_id
     ||' State '||  p_cc_state
     ||' Type '||  p_cc_type
     ||' Preparer '||  p_cc_preparer_id
     ||' Owner '||  p_cc_owner_id
     ||' CurOwner '||  p_cc_current_owner
     ||' ApprStatus '||  p_cc_apprvl_status
     ||' EncStatus '||  p_cc_encumb_status
     ||' CtrlStat '||  p_cc_ctrl_status
     ||' Vers '||  p_cc_version_number
     ||' Notes '||  p_cc_notes		);


     Put_Debug_Msg(l_full_path, 'Checking budgetary control');
  END IF;

  IGC_CC_BUDGETARY_CTRL_PKG.Check_Budgetary_Ctrl_On
   ( 1.0
   , FND_API.G_FALSE
   , FND_API.G_VALID_LEVEL_NONE
   , l_return_status
   , l_msg_count
   , l_msg_data
   , l_cc_org_id
   , l_cc_sob_id
   , l_cc_state
   , l_encumbrance_on
   ) ;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  -- if budgetary control is ON then
  -- attempt to reserve the funds.

  IF l_encumbrance_on = FND_API.G_TRUE THEN

    global_budgetary_control_on := TRUE;

    -- attempt to reserve funds for the CC. For successful execution of
    -- this procedure, set the org id for the current session.


    IF (g_debug_mode = 'Y') THEN
       Put_Debug_Msg(l_full_path, 'Reserving funds');
    END IF;

    IGC_CC_BUDGETARY_CTRL_PKG.Execute_Budgetary_Ctrl
       ( 1.0
       , FND_API.G_FALSE
       , FND_API.G_TRUE
       , FND_API.G_VALID_LEVEL_FULL
       , l_return_status
       , l_bc_status
       , l_msg_count
       , l_msg_data
       , l_cc_header_id
       , p_acct_date
       , 'R'
       );

       SAVEPOINT       Approved_By_Preparer;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_bc_status <> FND_API.G_TRUE THEN
         raise FND_API.G_EXC_ERROR;
       END IF;

       -- read the new encumbrance status from the database.

       SELECT cc_encmbrnc_status
         INTO l_cc_encumb_status
         FROM igc_cc_headers
        WHERE cc_header_id = l_cc_header_id;

       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'New enc status is: '||l_cc_encumb_status);
       END IF;

   ELSE

      global_budgetary_control_on := FALSE;
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, ' No BC reqired');
      END IF;
      l_cc_encumb_status := p_cc_encumb_status;

   END IF;

   -- if funds reservation passes then
   -- change the document status, create a PO entry and create an action history rec.

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Changing doc status');
   END IF;

   Change_Document_Status
        ( p_itemtype           => NULL
         , p_itemkey           => NULL
         , p_cc_header_id      => l_cc_header_id
	 , p_cc_state	       => l_cc_state
	 , p_cc_type           => p_cc_type
	 , p_cc_preparer_id    => l_cc_preparer_id
	 , p_cc_owner_id       => l_cc_owner_id
	 , p_cc_current_owner  => l_cc_current_owner
	 , p_cc_apprvl_status  => 'AP'
	 , p_cc_encumb_status  => l_cc_encumb_status
	 , p_cc_action_request => 'APPROVE'
         , p_error_code	       => l_error_code
	);

    IF l_cc_type IN ('S', 'R') AND l_cc_state = 'CM' THEN

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Generating PO');
          END IF;

           -- generate interface entries.
	  IGC_CC_PO_INTERFACE_PKG.convert_cc_to_po
 	   ( p_api_version      => 1.0
 	   , p_init_msg_list    => FND_API.G_FALSE
 	   , p_commit	        => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , x_return_status    => l_return_status
           , x_msg_count	=> l_msg_count
           , x_msg_data	        => l_msg_data
           , p_cc_header_id     => l_cc_header_id
            );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
           END IF;

   END IF;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Creating action history');
   END IF;

   Create_Action_History
           ( p_cc_header_id	=> l_cc_header_id
           , p_cc_version_num   => l_cc_version_number
           , p_cc_state	        => l_cc_state
           , p_cc_old_cc_state  => l_cc_old_cc_state
           , p_cc_ctrl_status   => l_cc_ctrl_status
           , p_cc_apprvl_status => 'AP'
           , p_cc_notes	        => l_cc_notes
           , p_action_requested => 'APPROVE'
           , p_error_code	=> l_error_code
          ) ;

  -- Standard check of p_commit.
  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;


  FND_MSG_PUB.Count_And_Get(p_count =>      l_msg_count ,
                            p_data  =>      p_msg_data );
  p_msg_count := l_msg_count;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Successfully completed, '||l_msg_count||' messages');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Approved_By_Preparer;
     p_return_status := FND_API.G_RET_STS_ERROR;

     Generate_Message;

     FND_MSG_PUB.Count_And_Get(p_count =>   p_msg_count ,
                               p_data  =>   p_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Approved_By_Preparer;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     Generate_Message;

     FND_MSG_PUB.Count_And_Get(p_count =>   p_msg_count ,
                               p_data  =>   p_msg_data );
     IF (g_excep_level >=  g_debug_level ) THEN
        FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
   WHEN OTHERS THEN
     ROLLBACK to Approved_By_Preparer;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;

     Generate_Message;

     FND_MSG_PUB.Count_And_Get(p_count =>      p_msg_count ,
                               p_data  =>      p_msg_data );
     IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;


END Approved_By_Preparer;


PROCEDURE Change_Document_Status
 ( p_itemtype           IN      VARCHAR2
 , p_itemkey            IN      VARCHAR2
 , p_cc_header_id	    IN  	NUMBER
 , p_cc_state		    IN	    VARCHAR2
 , p_cc_type		    IN	    VARCHAR2
 , p_cc_preparer_id	    IN	    NUMBER
 , p_cc_owner_id	    IN	    NUMBER
 , p_cc_current_owner	IN	    NUMBER
 , p_cc_apprvl_status	IN	    VARCHAR2
 , p_cc_encumb_status	IN	    VARCHAR2
 , p_cc_action_request	IN	    VARCHAR2
 , p_error_code		OUT NOCOPY	NUMBER
  ) IS


l_cc_header_id	      IGC_CC_HEADERS.cc_header_id%TYPE := p_cc_header_id;
l_cc_state            VARCHAR2(100) := p_cc_state;
l_cc_encumbrnc_status VARCHAR2(100) := p_cc_encumb_status;


l_cc_number           VARCHAR2(255);
CURSOR c_ccnum IS
    SELECT cc_num
     FROM igc_cc_headers
     WHERE cc_header_id = l_cc_header_id;

   l_full_path             VARCHAR2(255);

BEGIN

  l_full_path:= g_path || 'Change_Document_Status';

    -- check on cc_state for document status change.
  IF (l_cc_state = 'PR' AND global_budgetary_control_on  AND l_cc_encumbrnc_status = 'P' )
     OR (l_cc_state = 'PR' AND NOT global_budgetary_control_on  AND l_cc_encumbrnc_status = 'N' )
     OR (l_cc_state = 'CM' AND global_budgetary_control_on  AND l_cc_encumbrnc_status = 'C' )
     OR (l_cc_state = 'CM' AND NOT global_budgetary_control_on  AND l_cc_encumbrnc_status = 'N' )
     OR (l_cc_state = 'CL' AND l_cc_encumbrnc_status = 'N' )
     OR (l_cc_state = 'CT' AND l_cc_encumbrnc_status = 'N' )
     OR (p_cc_type  = 'R' )


    THEN

    IF (g_debug_mode = 'Y') THEN
       Put_Debug_Msg(l_full_path, 'Updating headers to Approved status');
    END IF;


    UPDATE IGC_CC_HEADERS
       SET cc_apprvl_status = 'AP'
     WHERE cc_header_id = l_cc_header_id;

  ELSE

     OPEN c_ccnum;
     FETCH c_ccnum INTO l_cc_number;
     CLOSE c_ccnum;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Combination of statuses is incorrect, raising an exception');
     END IF;

     message_token ('CC_NUM', l_cc_number);
     message_token ('CC_STATE', l_cc_state);
     message_token ('CC_ENC_STATUS', l_cc_encumbrnc_status);
     message_token ('CC_APR_STATUS', 'AP');
     add_message ('IGC', 'IGC_CC_STATE_ERROR');
     RAISE FND_API.G_EXC_ERROR;

  END IF;

    -- update database table IGC_CC_HEADERS

END; -- END procedure change_document_status, overloaded.


PROCEDURE Create_Action_History
 ( p_cc_header_id	IN	IGC_CC_HEADERS.cc_header_id%TYPE
 , p_cc_version_num	IN	IGC_CC_HEADERS.cc_version_num%TYPE
 , p_cc_state		IN	IGC_CC_HEADERS.cc_state%TYPE
 , p_cc_old_cc_state	IN      IGC_CC_HEADERS.cc_state%TYPE
 , p_cc_ctrl_status	IN	IGC_CC_HEADERS.cc_ctrl_status%TYPE
 , p_cc_apprvl_status	IN	IGC_CC_HEADERS.cc_apprvl_status%TYPE
 , p_cc_notes		IN	IGC_CC_ACTIONS.cc_action_notes%TYPE
 , p_action_requested   IN 	VARCHAR2
 , p_error_code		OUT NOCOPY	NUMBER
 ) IS

l_cc_state		varchar2(2) := p_cc_state;
l_cc_action_type 	VARCHAR2(10);
l_return_status		VARCHAR2(100);
l_msg_data		VARCHAR2(2000);
l_msg_count	        NUMBER;
l_rowid			VARCHAR2(30);
g_flag			BOOLEAN := FALSE;
l_full_path             VARCHAR2(255);

BEGIN

  l_full_path:= g_path || 'Create_Action_History';


  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Generating history record app status: '||p_cc_apprvl_status||' action type: '||'AP');
  END IF;

  IGC_CC_ACTIONS_PKG.Insert_Row
   ( p_api_version               => 1.0
   , p_init_msg_list             => FND_API.G_FALSE
   , p_commit                    => FND_API.G_FALSE
   , p_validation_level          => FND_API.G_VALID_LEVEL_FULL
   , x_return_status             => l_return_status
   , x_msg_count                 => l_msg_count
   , x_msg_data                  => l_msg_data
   , P_Rowid			 => l_rowid
   , P_CC_Header_Id              => p_cc_header_id
   , P_CC_Action_Version_Num     => p_cc_version_num
   , P_CC_Action_Type            => 'AP'
   , P_CC_Action_State           => l_cc_state
   , P_CC_Action_Ctrl_Status     => p_cc_ctrl_status
   , P_CC_Action_Apprvl_Status   => p_cc_apprvl_status
   , P_CC_Action_Notes           => p_cc_notes
   , P_Last_Update_Date          => sysdate
   , P_Last_Updated_By           => fnd_global.user_id
   , P_Last_Update_Login         => fnd_global.login_id
   , P_Creation_Date             => sysdate
   , P_Created_By                => fnd_global.user_id
   ) ;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
   END IF;

END Create_Action_History;

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   /*l_return_status    VARCHAR2(1);*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';

BEGIN

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
      /*IGC_MSGS_PKG.Put_Debug_Msg (l_full_path, p_debug_message    => p_debug_msg,
                                  p_profile_log_name => g_profile_name,
                                  p_prod             => 'IGC',
                                  p_sub_comp         => 'CC_APPR',
                                  p_filename_val     => NULL,
                                  x_Return_Status    => l_return_status
                                 );
      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;*/
--   END IF;

   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;
-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       NULL;
       RETURN;

END Put_Debug_Msg;


END IGC_CC_APPROVAL_PROCESS;

/
