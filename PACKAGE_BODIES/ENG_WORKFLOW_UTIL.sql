--------------------------------------------------------
--  DDL for Package Body ENG_WORKFLOW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_WORKFLOW_UTIL" AS
/* $Header: ENGUWKFB.pls 120.32 2007/05/11 16:05:54 asjohal ship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'Eng_Workflow_Util' ;

    -- For Debug
    g_debug_file      UTL_FILE.FILE_TYPE ;
    g_debug_flag      BOOLEAN      := FALSE ;  -- For Debug, set TRUE
    g_output_dir      VARCHAR2(240) := NULL ;
    g_debug_filename  VARCHAR2(30) := 'EngChangeWorkflowUtil.log' ;
    g_debug_errmesg   VARCHAR2(400);

    G_BO_IDENTIFIER         VARCHAR2(30) := 'ENG_WORKFLOW_UTIL';
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
-- Open_Debug_Session
PROCEDURE Open_Debug_Session
(  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
)
IS
    --local variables
    l_utl_file_dir    VARCHAR2(2000);
    l_error_mesg      VARCHAR2(2000) ;

    CURSOR c_get_utl_file_dir IS
       SELECT VALUE
        FROM V$PARAMETER
        WHERE NAME = 'utl_file_dir';

    l_found                NUMBER;

    l_log_output_dir       VARCHAR2(512);
    l_log_return_status    VARCHAR2(99);
    l_errbuff              VARCHAR2(2000);


BEGIN

     IF p_output_dir IS NOT NULL THEN
        g_output_dir := p_output_dir ;

     END IF ;

     IF p_file_name IS NOT NULL THEN
        g_debug_filename := p_file_name ;
     END IF ;


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


     /**********************************************************
     IF g_output_dir IS NULL
     THEN

         g_output_dir := FND_PROFILE.VALUE('ECX_UTL_LOG_DIR') ;

     END IF;

     select  value
     INTO l_utl_file_dir
     FROM v$parameter
     WHERE name = 'utl_file_dir';

     l_found := INSTR(l_utl_file_dir, g_output_dir);

     IF l_found = 0
     THEN
          l_error_mesg := 'Debug Session could not be started. ' ||
                          'The output directory is invalid.';

          --  'Debug Session could not be started because the ' ||
          --  ' output directory name is invalid. '             ||
          --  ' Output directory must be one of the directory ' ||
          --  ' value in v$parameter for name = utl_file_dir ';

          -- FND_MSG_PUB.Add_Exc_Msg
          -- (  G_PKG_NAME           ,
          --    'Open_Debug_Session' ,
          --    l_error_mesg  ) ;
          -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

          FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || ' Open_Debug_Session: LOGGING ERROR > '||l_error_mesg);
          g_debug_flag := FALSE;
          RETURN;

     END IF;

     g_debug_file := utl_file.fopen(  g_output_dir
                                    , g_debug_filename
                                    , 'w');
     g_debug_flag := TRUE ;
     **************************************************************/

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       FND_FILE.put_line(FND_FILE.LOG, 'LOGGING SQL ERROR => '||g_debug_errmesg);
       g_debug_flag := FALSE;
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END Open_Debug_Session ;



-----------------------------------------------------------
-- Open the Debug Session, conditionally if the profile: --
-- INV Debug Trace is set to TRUE                        --
-----------------------------------------------------------
PROCEDURE Check_And_Open_Debug_Session
(    p_debug_flag IN VARCHAR2
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
     l_error_mesg      VARCHAR2(2000) ;
BEGIN
    IF utl_file.is_open(g_debug_file)
    THEN
      utl_file.fclose(g_debug_file);
    END IF ;

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;

       l_error_mesg := 'Debug Session could not be closed because the ' ||
                       Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240) ;

       FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || '.Close_Debug_Session  LOGGING ERROR => '||l_error_mesg);

       -- FND_MSG_PUB.Add_Exc_Msg
       -- (  G_PKG_NAME           ,
       --   'Close_Debug_Session' ,
       --   l_error_mesg  ) ;
       --
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END Close_Debug_Session ;

-- Test Debug
PROCEDURE Write_Debug
(  p_debug_message      IN  VARCHAR2 )
IS
     l_error_mesg      VARCHAR2(2000) ;
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

    /*****
    IF utl_file.is_open(g_debug_file)
    THEN
        utl_file.put_line(g_debug_file, p_debug_message);
    END IF ;
    ***/



EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;
       l_error_mesg := 'In Debug Mode, Write_Debug procedure faild closed because the ' ||
                       Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240) ;


       FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || '.Write_Debug LOGGING ERROR => '||l_error_mesg);

       --
       -- FND_MSG_PUB.Add_Exc_Msg
       -- (  G_PKG_NAME           ,
       --   'Write_Debug' ,
       --   l_error_mesg  ) ;
       --
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

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
    l_error_mesg      VARCHAR2(2000) ;

BEGIN

    -- Get Debug Flag
    l_debug_flag := WF_ENGINE.GetItemAttrText
                            (  p_item_type
                             , p_item_key
                             , '.DEBUG_FLAG'
                             );

    IF FND_API.to_Boolean( l_debug_flag ) THEN
       x_debug_flag := TRUE ;
    END IF ;


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

       l_error_mesg := 'In Debug Mode, Get_Debug_Mode procedure faild closed because the ' ||
                       Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240) ;


       FND_FILE.put_line(FND_FILE.LOG, G_PKG_NAME || '.Get_Debug_Mode LOGGING ERROR => '||l_error_mesg);


END Get_Debug_Mode ;



/********************************************************************
* API Type      : Local APIs
* Purpose       : Those APIs are private
*********************************************************************/
FUNCTION GetDefaultResponseComment
 RETURN VARCHAR2
IS

BEGIN

    FND_MESSAGE.SET_NAME('ENG', 'ENG_NO_VALUE_SPECIFIED') ;
    RETURN FND_MESSAGE.GET ;

END  GetDefaultResponseComment ;

FUNCTION DefaultNoValueFilter( p_text IN VARCHAR2 )
 RETURN VARCHAR2
IS

    l_default_novalue VARCHAR2(2000) ;

BEGIN

     l_default_novalue := GetDefaultResponseComment ;

    IF l_default_novalue = p_text THEN
        return NULL ;
    ELSE
        return p_text ;
    END IF ;

END DefaultNoValueFilter ;


FUNCTION GetUserRole
( p_user_id      IN   NUMBER)
 RETURN VARCHAR2
IS

    l_user_name  varchar2(100) ;

BEGIN

    IF p_user_id = G_ACT_SYSTEM_USER_ID THEN

       -- We are not sure which user role we should return.
       NULL ;

    ELSE

       SELECT user_name
       INTO   l_user_name
       FROM   FND_USER
       WHERE  user_id = p_user_id ;

    END IF ;

    RETURN l_user_name ;

END  GetUserRole ;


FUNCTION GetNewItemKey
RETURN VARCHAR2
IS
    l_rev_seq      NUMBER         := NULL;
    l_new_item_key VARCHAR2(240)  := NULL;
BEGIN

    -- Generate Item Key from ENG_WORKFLOW_REVISION_S.NEXTVAL
    -- and return the value
    SELECT ENG_WORKFLOW_REVISION_S.NEXTVAL
    INTO   l_rev_seq
    FROM DUAL;

    l_new_item_key := TO_CHAR(l_rev_seq) ;

    RETURN l_new_item_key ;

END GetNewItemKey ;



-- Get Parent Change Id for  Change Line
FUNCTION GetParentChangeId
(  p_change_line_id IN  NUMBER
) RETURN NUMBER
IS

    l_change_id NUMBER ;

    CURSOR  c_line  (p_change_line_id NUMBER)
    IS
        SELECT change_id
          FROM ENG_CHANGE_LINES
         WHERE change_line_id = p_change_line_id ;
BEGIN

    FOR l_rec IN c_line(p_change_line_id => p_change_line_id)
    LOOP
        l_change_id :=  l_rec.change_id ;

    END LOOP ;

    RETURN l_change_id ;

END GetParentChangeId ;


FUNCTION GetChangeObjectNotice
(  p_change_id        IN  NUMBER)
 RETURN VARCHAR2
IS
    l_change_notice   VARCHAR2(20) ;

    CURSOR  c_change  (p_change_id NUMBER)
    IS
        SELECT change_notice
        FROM ENG_ENGINEERING_CHANGES
        WHERE change_id = p_change_id;

BEGIN

    FOR l_rec IN c_change(p_change_id => p_change_id)
    LOOP
        l_change_notice :=  l_rec.change_notice ;
    END LOOP ;

    RETURN l_change_notice;

END GetChangeObjectNotice ;


-- Get Change Line Object Seq No
FUNCTION GetChangeLineObjectSequence
(  p_change_line_id        IN  NUMBER
) RETURN NUMBER
IS

    x_line_sequence_number   NUMBER;

    CURSOR  c_line  (p_change_line_id NUMBER)
    IS
        SELECT ecl.sequence_number
        FROM ENG_CHANGE_LINES  ecl
        WHERE ecl.change_line_id = p_change_line_id ;

BEGIN

    FOR l_rec IN c_line(p_change_line_id => p_change_line_id)
    LOOP
        x_line_sequence_number :=  l_rec.sequence_number;

    END LOOP ;

    RETURN x_line_sequence_number;

END GetChangeLineObjectSequence ;



FUNCTION GetItemUserKey
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
)
RETURN VARCHAR2
IS
    l_item_user_key       VARCHAR2(240);
    l_change_notice       VARCHAR2(20) ;
    l_change_line_seq_num NUMBER ;

    l_parent_change_id    NUMBER ;
BEGIN

   IF p_change_id IS NOT NULL AND p_change_id > 0
   THEN

       l_change_notice := GetChangeObjectNotice(p_change_id);
       l_item_user_key := l_change_notice || ':' || TO_CHAR(p_change_id);

   END IF ;

   IF p_change_line_id IS NOT NULL AND p_change_line_id > 0
   THEN

        l_change_line_seq_num := GetChangeLineObjectSequence(p_change_line_id);

        IF l_change_notice IS NULL THEN
           l_parent_change_id := GetParentChangeId(p_change_line_id);
           l_change_notice := GetChangeObjectNotice(l_parent_change_id);
        END IF ;

        l_item_user_key := l_change_notice || ':' || TO_CHAR(l_change_line_seq_num) || ':' || TO_CHAR(p_change_line_id);


   END IF ;

   IF l_item_user_key IS NOT NULL THEN

      l_item_user_key := l_item_user_key || '-' ;

   END IF ;

   l_item_user_key := l_item_user_key || p_item_key ;

   RETURN l_item_user_key ;


END GetItemUserKey ;

FUNCTION GetWFAdhocRoleName
(   p_role_prefix       IN  VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
)
RETURN VARCHAR2
IS
    l_adhoc_role_name VARCHAR2(320)  := NULL;

BEGIN

    l_adhoc_role_name := p_role_prefix ||
                         p_item_type   || '-' ||
                         p_item_key ;

   RETURN l_adhoc_role_name ;

END GetWFAdhocRoleName ;


-- Get Organization Info
PROCEDURE GetOrgInfo
(  p_organization_id   IN  NUMBER
 , x_organization_code OUT NOCOPY VARCHAR2
 , x_organization_name OUT NOCOPY VARCHAR2
)
IS

BEGIN

   -- in 115.10 org id may be -1
   IF p_organization_id > 0 THEN

     SELECT
       MP.organization_code organization_code,
       HAOTL.name organization_name
      INTO    x_organization_code
            , x_organization_name
     FROM
       HR_ALL_ORGANIZATION_UNITS_TL HAOTL,
       MTL_PARAMETERS MP
     WHERE
       HAOTL.organization_id = p_organization_id
       AND HAOTL.organization_id = MP.ORGANIZATION_ID
       AND HAOTL.LANGUAGE = USERENV('LANG');

   END IF ;

END GetOrgInfo ;

FUNCTION GetPartyType
(   p_party_id        IN  NUMBER )
RETURN VARCHAR2
IS
    l_party_type VARCHAR2(30)  := NULL;

BEGIN

   SELECT party_type
   INTO   l_party_type
   FROM   HZ_PARTIES
   WHERE party_id = p_party_id ;

   RETURN l_party_type ;

END GetPartyType ;




FUNCTION CheckRoleExistence( p_role_name IN VARCHAR2 )
RETURN BOOLEAN
IS


    CURSOR c_role (p_role_name VARCHAR2 )
    IS
        SELECT 'Role Exists'
        FROM DUAL
        WHERE EXISTS ( SELECT null
                       from WF_LOCAL_ROLES
                       WHERE NAME = p_role_name
                       AND ORIG_SYSTEM = 'WF_LOCAL_ROLES'
                       AND ORIG_SYSTEM_ID = 0
                      ) ;

     l_existence BOOLEAN  := FALSE ;

BEGIN

    begin

       --
       -- if p_role does not exist, it throws exception
       -- So we should not write sql to check AdhocRole existence directly
       -- For safety purpose we just don't care about this execption
       WF_DIRECTORY.SetAdHocRoleStatus( role_name => p_role_name
                                      , status => 'ACTIVE') ;

       -- l_existence := TRUE ;
       -- OWF.G Bug3490260
       -- Added additoinal check because WF_DIRECTORY.SetAdHocRoleStatus
       -- does not raise exception correctly
       -- Once the bug is fixed need to remove
       FOR l_rec IN  c_role(p_role_name => p_role_name)
       LOOP

         l_existence := TRUE ;

       END LOOP ;

    exception
        when others then
            null ;

    end ;

    RETURN l_existence ;

END CheckRoleExistence ;



PROCEDURE DeleteRoleAndUsers
(   p_role_name         IN  VARCHAR2)
IS


BEGIN


    /* This might NOT be following standard
    -- Deleting these adhoc role and user roles
    -- should be done by WF Purge Program
    -- Instead of this, Set Adhoc Role Expiration
    -- using WF API. Then once user run WF Purge progam
    -- deleting these role and user roles is taken care of.

    -- DELETE FROM wf_local_roles
    -- WHERE  name = p_role_name ;

    -- DELETE FROM wf_local_user_roles
    -- WHERE  role_name = p_role_name ;
    */

    begin

       --
       -- if p_role does not exist, it throws exception
       -- since we don't have workflow pre-req in plm115.9
       -- we are not sure whether the customer have applied/will apply
       -- OWF.G patchset
       -- So we can not write correct sql to check AdhocRole existence
       -- before calling SetAdhocRoleExpiration
       -- For safety purpose we just don't care about this execption
       --
       WF_DIRECTORY.SetAdhocRoleExpiration
       ( role_name => p_role_name
       , expiration_date => SYSDATE) ;

    exception
       when others then
           null ;
    end ;


END DeleteRoleAndUsers ;

-------------------------------------------------------------------
-- WF Directory related OBSOLETE APIs for Bug4532263
-- Replaced with new APIs with post_fix 2
-- Keep APIs here for any customization
-------------------------------------------------------------------
-- Set User to Role Users
PROCEDURE SetUserToRoleUsers
(  p_party_id    IN  NUMBER
 , x_role_users  IN  OUT NOCOPY VARCHAR2
)
IS

    l_user_role VARCHAR2(320) ;

    CURSOR c_party  (p_party_id NUMBER)
    IS
        SELECT EngSecPeople.user_name user_role
        FROM   ENG_SECURITY_PEOPLE_V EngSecPeople
        WHERE  EngSecPeople.person_id =  p_party_id ;

BEGIN


    FOR person_rec IN c_party(p_party_id => p_party_id)
    LOOP

        l_user_role := person_rec.user_role ;

        IF (WF_DIRECTORY.UserActive(l_user_role ))
        THEN

            -- Prevent duplicate user
            IF  x_role_users IS NULL OR
               ( INSTR(x_role_users || ','  , l_user_role || ',' ) = 0 )
            THEN

                IF (x_role_users IS NOT NULL) THEN
                    x_role_users := x_role_users || ',';
                END IF;

                x_role_users := x_role_users || l_user_role ;

            END IF ;

        END IF ;

    END LOOP ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        null ;

END SetUserToRoleUsers ;


-- Set AppsUser to Role Users
PROCEDURE SetAppsUserToRoleUsers
(  p_user_id     IN  NUMBER
 , x_role_users  IN OUT NOCOPY  VARCHAR2
)
IS

    l_user_role VARCHAR2(320) ;

BEGIN

    l_user_role := GetUserRole(p_user_id => p_user_id ) ;

    IF (WF_DIRECTORY.UserActive(l_user_role ))
    THEN

        -- Prevent duplicate user
        IF  x_role_users IS NULL OR
           ( INSTR(x_role_users || ','  , l_user_role || ',' ) = 0 )
        THEN


            IF (x_role_users IS NOT NULL) THEN
                x_role_users := x_role_users || ',';
            END IF;

            x_role_users := x_role_users || l_user_role ;

        END IF ;

    END IF ;

END SetAppsUserToRoleUsers ;


-- Set User to Role Users
PROCEDURE SetGroupToRoleUsers
(  p_group_id    IN NUMBER
 , x_role_users  IN OUT NOCOPY  VARCHAR2
)
IS

    --
    -- CURSOR c_grp_members  (p_group_id NUMBER)
    -- IS
    --   SELECT member.user_name user_role
    --   FROM   EGO_PEOPLE_V member
    --        , HZ_RELATIONSHIPS member_group
    --        , HZ_PARTIES grp
    --   WHERE member_group.object_id = grp.party_id
    --   AND member_group.subject_id = member.person_id
    --   AND member_group.subject_type = 'PERSON'
    --   AND member_group.object_type = 'GROUP'
    --   AND member_group.relationship_type = 'MEMBERSHIP'
    --   AND member_group.status = 'A'
    --   AND member_group.start_date <= SYSDATE
    --   AND (member_group.end_date IS NULL OR member_group.end_date >= SYSDATE)
    --   AND grp.party_id = p_group_id ;
    --

    -- Replaced above sql to use ENG_SECURITY_GROUP_MEMBERS_V
    CURSOR c_grp_members  (p_group_id NUMBER)
    IS
       SELECT member.member_user_name user_role
       FROM   ENG_SECURITY_GROUP_MEMBERS_V member
       WHERE  member.group_id = p_group_id  ;


BEGIN

    FOR grp_member_rec in c_grp_members (p_group_id => p_group_id )
    LOOP

        IF (WF_DIRECTORY.UserActive(grp_member_rec.user_role ))
        THEN

            -- Prevent duplicate user
            IF  x_role_users IS NULL OR
               ( INSTR(x_role_users || ','  , grp_member_rec.user_role || ',' ) = 0 )
            THEN

                IF (x_role_users IS NOT NULL) THEN
                    x_role_users := x_role_users || ',';
                END IF;

                x_role_users := x_role_users || grp_member_rec.user_role ;

            END IF ;

        END IF ;

    END LOOP ;

END SetGroupToRoleUsers ;

-- Set Assignee to Role Users
PROCEDURE SetAssigneeToRoleUsers
(  p_assignee_party_id    IN NUMBER
 , x_role_users           IN OUT NOCOPY VARCHAR2
)
IS
    l_party_type          VARCHAR2(30) ;

BEGIN

    IF p_assignee_party_id IS NOT NULL  THEN

        l_party_type  := GetPartyType(p_party_id => p_assignee_party_id ) ;

        IF l_party_type = 'PERSON' THEN

            SetUserToRoleUsers( p_party_id   => p_assignee_party_id
                              , x_role_users => x_role_users
                              ) ;

        ELSIF l_party_type = 'GROUP' THEN

            SetGroupToRoleUsers( p_group_id   => p_assignee_party_id
                               , x_role_users => x_role_users
                               ) ;

        END IF ;

    END IF ; -- if p_assignee_party_id is not null

END SetAssigneeToRoleUsers ;




-- Set Creator to Role Users
PROCEDURE SetCreatorToRoleUsers
(  p_creator_user_id      IN NUMBER
 , x_role_users           IN OUT NOCOPY VARCHAR2
)
IS
    l_party_type          VARCHAR2(30) ;

BEGIN

    IF p_creator_user_id IS NOT NULL  THEN


        SetAppsUserToRoleUsers( p_user_id    => p_creator_user_id
                              , x_role_users => x_role_users
                              ) ;

    END IF ; -- if p_creator_user_id is not null

END SetCreatorToRoleUsers ;


-- Set Requestor to Role Users
PROCEDURE SetRequestorToRoleUsers
(  p_requestor_party_id IN NUMBER
 , x_role_users         IN OUT NOCOPY VARCHAR2
)
IS
    l_party_type          VARCHAR2(30) ;

BEGIN

    IF p_requestor_party_id IS NOT NULL  THEN

        l_party_type  := GetPartyType(p_party_id => p_requestor_party_id ) ;

        IF l_party_type = 'PERSON' THEN

            SetUserToRoleUsers( p_party_id   => p_requestor_party_id
                              , x_role_users => x_role_users
                              ) ;

        ELSIF l_party_type = 'GROUP' THEN

            SetGroupToRoleUsers( p_group_id   => p_requestor_party_id
                               , x_role_users => x_role_users
                               ) ;

        END IF ;

    END IF ; -- if p_requestor_party_id is not null

END SetRequestorToRoleUsers ;

-- Set Step People to Role Users
PROCEDURE SetRoutePeopleToRoleUsers
(  p_route_id IN NUMBER
 , x_role_users    IN OUT NOCOPY VARCHAR2
)
IS

    l_user_role VARCHAR2(320) ;


    CURSOR c_route_people (p_route_id NUMBER)
    IS
        SELECT EngSecPeople.user_name user_role
        FROM   ENG_SECURITY_PEOPLE_V EngSecPeople
             , ENG_CHANGE_ROUTE_PEOPLE step_people
             , ENG_CHANGE_ROUTE_STEPS  step
        WHERE  EngSecPeople.person_id =  step_people.assignee_id
        AND    step_people.assignee_type_code = Eng_Workflow_Util.G_PERSON
        AND    step_people.assignee_id <> -1
        AND    step_people.step_id = step.step_id
        AND    step.step_status_code <> Eng_Workflow_Util.G_RT_NOT_STARTED
        AND    step.step_start_date   IS NOT NULL
        AND    step.route_id  = p_route_id ;

BEGIN


    FOR l_rec in c_route_people (p_route_id => p_route_id)
    LOOP

        IF (WF_DIRECTORY.UserActive(l_rec.user_role ))
        THEN

            -- Prevent duplicate user
            IF  x_role_users IS NULL OR
               ( INSTR(x_role_users || ','  , l_rec.user_role || ',' ) = 0 )
            THEN

                IF (x_role_users IS NOT NULL) THEN
                    x_role_users := x_role_users || ',';
                END IF;

                x_role_users := x_role_users || l_rec.user_role ;

            END IF ;

        END IF ;

    END LOOP ;

END SetRoutePeopleToRoleUsers ;


-- Set Step People to Role Users
PROCEDURE SetStepPeopleToRoleUsers
(  p_route_step_id IN NUMBER
 , x_role_users    IN OUT NOCOPY VARCHAR2
)
IS

    l_user_role VARCHAR2(320) ;


    -- In case of Instance Route, Assignee Id is always person's party id
    CURSOR c_step_people (p_route_step_id NUMBER)
    IS
        SELECT EngSecPeople.user_name user_role
        FROM   ENG_SECURITY_PEOPLE_V EngSecPeople
             , ENG_CHANGE_ROUTE_PEOPLE step_people
        WHERE  EngSecPeople.person_id =  step_people.assignee_id
        AND    step_people.assignee_id <> -1
        AND    step_people.assignee_type_code = Eng_Workflow_Util.G_PERSON
        AND    step_people.step_id = p_route_step_id
        AND    ( step_people.response_code IS NULL
                 OR step_people.response_code = Eng_Workflow_Util.G_RT_SUBMITTED
                 OR step_people.response_code = Eng_Workflow_Util.G_RT_NOT_RECEIVED
                ) ;


BEGIN


    FOR l_rec in c_step_people (p_route_step_id => p_route_step_id)
    LOOP

        IF (WF_DIRECTORY.UserActive(l_rec.user_role ))
        THEN

            -- Prevent duplicate user
            IF  x_role_users IS NULL OR
               ( INSTR(x_role_users || ','  , l_rec.user_role || ',' ) = 0 )
            THEN

                IF (x_role_users IS NOT NULL) THEN
                    x_role_users := x_role_users || ',';
                END IF;

                x_role_users := x_role_users || l_rec.user_role ;

            END IF ;

        END IF ;

    END LOOP ;

END SetStepPeopleToRoleUsers ;



PROCEDURE SetWFAdhocRole (p_role_name           IN OUT NOCOPY VARCHAR2,
                          p_role_display_name   IN OUT NOCOPY VARCHAR2,
                          p_role_users          IN VARCHAR2 DEFAULT NULL,
                          p_expiration_date     IN DATE DEFAULT SYSDATE)
IS

BEGIN

    -- Check if the Role already exists
    IF CheckRoleExistence(p_role_name => p_role_name )  THEN

        -- Replacing existing Users in this Adhoc Role
        WF_DIRECTORY.RemoveUsersFromAdhocRole
        ( role_name  => p_role_name
        , role_users => NULL ) ;


        WF_DIRECTORY.AddUsersToAdhocRole
        ( role_name  => p_role_name
        , role_users => p_role_users ) ;


    ELSE

        WF_DIRECTORY.CreateAdHocRole( role_name         => p_role_name
                                    , role_display_name => p_role_display_name
                                    , role_users        => p_role_users
                                    , expiration_date   => p_expiration_date
                                    );
    END IF;



    -- The following is Original Logic
    -- We changed this logic
    -- because of DeleteRoleAndUsers change
        -- Check if the Role already exists
        -- IF CheckRoleExistence(p_role_name => l_role_name )  THEN

            -- if exists, delete it for duplicate role error.
            -- DeleteRoleAndUsers
            -- (  p_role_name  => l_role_name);

        -- END IF;
        --
        -- WF_DIRECTORY.CreateAdHocRole( role_name         => l_role_name
        --                             , role_display_name => l_role_name
        --                             , role_users        => l_role_users
        --                             , expiration_date   => NULL
        --                             );


END SetWFAdhocRole ;

-------------------------------------------------------------------
-- WF Directory related OBSOLETE APIs for Bug4532263
-- End of WF Directory related OBSOLETE APIs for Bug4532263
-------------------------------------------------------------------


-------------------------------------------------------------------
-- New WF Directory related APIs for CM Bug4532263
-------------------------------------------------------------------

-- Add Role to WF_DIRECTORY.UserTable
PROCEDURE AddRoleToRoleUserTable
(  p_role_name    IN  VARCHAR2
 , x_role_users   IN  OUT NOCOPY WF_DIRECTORY.UserTable
)
IS
   l_index NUMBER ;
   l_dup_flag BOOLEAN ;
   l_new_index NUMBER ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('AddRoleToRoleUserTable:  ' || p_role_name );
END IF ;


    -- First, check the user role is Active
    IF (WF_DIRECTORY.UserActive(p_role_name))
    THEN

IF g_debug_flag THEN
   Write_Debug('After WF_DIRECTORY.UserActive:  ' || p_role_name );
END IF ;

        l_dup_flag := FALSE ;
        l_new_index := 0 ;

        -- Second, check the user role is duplicate
        IF (x_role_users IS NOT NULL AND x_role_users.COUNT > 0)
        THEN

IF g_debug_flag THEN
   Write_Debug('x_role_users IS NOT NULL AND x_role_users.COUNT > 0 .. . ' );
   Write_Debug('x_role_users.COUNT ' || to_char(x_role_users.COUNT) );
   Write_Debug('x_role_users.FIRST ' || to_char(x_role_users.FIRST) );
   Write_Debug('x_role_users.LAST ' || to_char(x_role_users.LAST) );
END IF ;

            l_index := x_role_users.FIRST;
            l_new_index := x_role_users.LAST + 1;

            WHILE (l_index IS NOT NULL AND NOT l_dup_flag )
            LOOP

IF g_debug_flag THEN
   Write_Debug('x_role_users: Index ' || to_char(l_index) ||  '=' || x_role_users(l_index)  );
END IF ;

                IF p_role_name = x_role_users(l_index)
                THEN
                    l_dup_flag := TRUE ;
                END IF ;
                l_index := x_role_users.NEXT(l_index);
            END LOOP ;

        END IF ;


        IF NOT l_dup_flag
        THEN
IF g_debug_flag THEN
   Write_Debug('Duplicate Check is OK  ' );
   Write_Debug('New Index ' || to_char(l_new_index) );
END IF ;
            x_role_users(l_new_index) := p_role_name ;

        END IF ;

    END IF ;

END AddRoleToRoleUserTable ;

-- Set User to Role Users2
PROCEDURE SetUserToRoleUsers2
(  p_party_id    IN  NUMBER
 , x_role_users  IN  OUT NOCOPY WF_DIRECTORY.UserTable
)
IS

    l_user_role VARCHAR2(320) ;

    CURSOR c_party  (p_party_id NUMBER)
    IS
        SELECT EngSecPeople.user_name user_role
        FROM   ENG_SECURITY_PEOPLE_V EngSecPeople
        WHERE  EngSecPeople.person_id =  p_party_id ;

BEGIN

    FOR person_rec IN c_party(p_party_id => p_party_id)
    LOOP
        l_user_role := person_rec.user_role ;
        AddRoleToRoleUserTable(l_user_role, x_role_users) ;
    END LOOP ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        null ;

END SetUserToRoleUsers2 ;


-- Set AppsUser to Role Users
PROCEDURE SetAppsUserToRoleUsers2
(  p_user_id     IN  NUMBER
 , x_role_users  IN OUT NOCOPY  WF_DIRECTORY.UserTable
)
IS

    l_user_role VARCHAR2(320) ;

BEGIN

    l_user_role := GetUserRole(p_user_id => p_user_id ) ;
    AddRoleToRoleUserTable(l_user_role, x_role_users) ;

END SetAppsUserToRoleUsers2 ;


-- Set User to Role Users
PROCEDURE SetGroupToRoleUsers2
(  p_group_id    IN NUMBER
 , x_role_users  IN OUT NOCOPY  WF_DIRECTORY.UserTable
)
IS
    CURSOR c_grp_members  (p_group_id NUMBER)
    IS
       SELECT member.member_user_name user_role
       FROM   ENG_SECURITY_GROUP_MEMBERS_V member
       WHERE  member.group_id = p_group_id  ;


BEGIN

    FOR grp_member_rec in c_grp_members (p_group_id => p_group_id )
    LOOP
        AddRoleToRoleUserTable(grp_member_rec.user_role, x_role_users) ;
    END LOOP ;

END SetGroupToRoleUsers2 ;


-- Set Assignee to Role Users
PROCEDURE SetAssigneeToRoleUsers2
(  p_assignee_party_id    IN NUMBER
 , x_role_users           IN OUT NOCOPY WF_DIRECTORY.UserTable
)
IS
    l_party_type          VARCHAR2(30) ;

BEGIN

    IF p_assignee_party_id IS NOT NULL  THEN

        l_party_type  := GetPartyType(p_party_id => p_assignee_party_id ) ;

        IF l_party_type = 'PERSON' THEN

            SetUserToRoleUsers2( p_party_id   => p_assignee_party_id
                              , x_role_users => x_role_users
                              ) ;

        ELSIF l_party_type = 'GROUP' THEN

            SetGroupToRoleUsers2( p_group_id   => p_assignee_party_id
                               , x_role_users => x_role_users
                               ) ;

        END IF ;

    END IF ; -- if p_assignee_party_id is not null

END SetAssigneeToRoleUsers2 ;


-- Set Creator to Role Users2
PROCEDURE SetCreatorToRoleUsers2
(  p_creator_user_id      IN NUMBER
 , x_role_users           IN  OUT NOCOPY WF_DIRECTORY.UserTable
)
IS
    l_party_type          VARCHAR2(30) ;

BEGIN

    IF p_creator_user_id IS NOT NULL  THEN


        SetAppsUserToRoleUsers2( p_user_id    => p_creator_user_id
                              , x_role_users => x_role_users
                              ) ;

    END IF ; -- if p_creator_user_id is not null

END SetCreatorToRoleUsers2 ;


-- Set Requestor to Role Users2
PROCEDURE SetRequestorToRoleUsers2
(  p_requestor_party_id IN NUMBER
 , x_role_users           IN  OUT NOCOPY WF_DIRECTORY.UserTable
)
IS
    l_party_type          VARCHAR2(30) ;

BEGIN

    IF p_requestor_party_id IS NOT NULL  THEN

        l_party_type  := GetPartyType(p_party_id => p_requestor_party_id ) ;

        IF l_party_type = 'PERSON' THEN

            SetUserToRoleUsers2( p_party_id   => p_requestor_party_id
                              , x_role_users => x_role_users
                              ) ;

        ELSIF l_party_type = 'GROUP' THEN

            SetGroupToRoleUsers2( p_group_id   => p_requestor_party_id
                               , x_role_users => x_role_users
                               ) ;

        END IF ;

    END IF ; -- if p_requestor_party_id is not null

END SetRequestorToRoleUsers2 ;

-- Set Step People to Role Users2
PROCEDURE SetRoutePeopleToRoleUsers2
(  p_route_id             IN NUMBER
 , x_role_users           IN  OUT NOCOPY WF_DIRECTORY.UserTable
)
IS

    l_user_role VARCHAR2(320) ;

    CURSOR c_route_people (p_route_id NUMBER)
    IS
        SELECT EngSecPeople.user_name user_role
        FROM   ENG_SECURITY_PEOPLE_V EngSecPeople
             , ENG_CHANGE_ROUTE_PEOPLE step_people
             , ENG_CHANGE_ROUTE_STEPS  step
        WHERE  EngSecPeople.person_id =  step_people.assignee_id
        AND    step_people.assignee_type_code = Eng_Workflow_Util.G_PERSON
        AND    step_people.assignee_id <> -1
        AND    step_people.step_id = step.step_id
        AND    step.step_status_code <> Eng_Workflow_Util.G_RT_NOT_STARTED
        AND    step.step_start_date   IS NOT NULL
        AND    step.route_id  = p_route_id ;

BEGIN


    FOR l_rec in c_route_people (p_route_id => p_route_id)
    LOOP
        AddRoleToRoleUserTable(l_rec.user_role, x_role_users) ;
    END LOOP ;

END SetRoutePeopleToRoleUsers2 ;


-- Set Step People to Role Users2
PROCEDURE SetStepPeopleToRoleUsers2
(  p_route_step_id IN NUMBER
 , x_role_users    IN  OUT NOCOPY WF_DIRECTORY.UserTable
)
IS

    l_user_role VARCHAR2(320) ;


    -- In case of Instance Route, Assignee Id is always person's party id
    CURSOR c_step_people (p_route_step_id NUMBER)
    IS
        SELECT EngSecPeople.user_name user_role
        FROM   ENG_SECURITY_PEOPLE_V EngSecPeople
             , ENG_CHANGE_ROUTE_PEOPLE step_people
        WHERE  EngSecPeople.person_id =  step_people.assignee_id
        AND    step_people.assignee_id <> -1
        AND    step_people.assignee_type_code = Eng_Workflow_Util.G_PERSON
        AND    step_people.step_id = p_route_step_id
        AND    ( step_people.response_code IS NULL
                 OR step_people.response_code = Eng_Workflow_Util.G_RT_SUBMITTED
                 OR step_people.response_code = Eng_Workflow_Util.G_RT_NOT_RECEIVED
                ) ;

BEGIN


    FOR l_rec in c_step_people (p_route_step_id => p_route_step_id)
    LOOP
        AddRoleToRoleUserTable(l_rec.user_role, x_role_users) ;

    END LOOP ;

END SetStepPeopleToRoleUsers2 ;


-- Bug4532263
--
-- 4258267 9.2.0.5.0 MAILER 11.5.10 PRODID-174 PORTID-110 3623217
-- Abstract: UNABLE TO SEND NOTIFICATION FOR USER WHOSE NAME HAS SPACES
-- Need to call CreateAdHocRole2 which accepts
-- WF_DIRECTORY.UserTable as role_users.
-- WF base bug3623217 of wf bug4258267:
--
PROCEDURE SetWFAdhocRole2 (p_role_name           IN OUT NOCOPY VARCHAR2,
                           p_role_display_name   IN OUT NOCOPY VARCHAR2,
                           p_role_users          IN WF_DIRECTORY.UserTable,
                           p_expiration_date     IN DATE DEFAULT SYSDATE)
IS

BEGIN

    -- Check if the Role already exists
    IF CheckRoleExistence(p_role_name => p_role_name )  THEN

        -- Replacing existing Users in this Adhoc Role
        WF_DIRECTORY.RemoveUsersFromAdhocRole
        ( role_name  => p_role_name
        , role_users => NULL ) ;


        --
        -- WF_DIRECTORY.AddUsersToAdHocRole2(role_name         in varchar2,
        --                      role_users        in WF_DIRECTORY.UserTable);
        WF_DIRECTORY.AddUsersToAdhocRole2
        ( role_name  => p_role_name
        , role_users => p_role_users ) ;


    ELSE
        --    WF_DIRECTORY.CreateAdHocRole2(role_name          in out nocopy varchar2,
        --                role_display_name       in out nocopy  varchar2,
        --                language                in  varchar2 default null,
        --                territory               in  varchar2 default null,
        --                role_description        in  varchar2 default null,
        --                notification_preference in  varchar2 default 'MAILHTML',
        --                role_users              in  WF_DIRECTORY.UserTable,
        --                email_address           in  varchar2 default null,
        --                fax                     in  varchar2 default null,
        --                status                  in  varchar2 default 'ACTIVE',
        --                expiration_date         in  date default null,
        --                parent_orig_system      in  varchar2 default null,
        --                parent_orig_system_id   in  number default null,
        --                owner_tag               in  varchar2 default null);

        WF_DIRECTORY.CreateAdHocRole2( role_name         => p_role_name
                                     , role_display_name => p_role_display_name
                                     , role_users        => p_role_users
                                     , expiration_date   => p_expiration_date
                                     );
    END IF;

END SetWFAdhocRole2 ;

-------------------------------------------------------------------
-- End of New WF Directory related APIs for CM Bug4532263
-------------------------------------------------------------------



-- Get Change Object (FND Object) Name
FUNCTION GetChangeObjectName
(  p_change_id        IN  NUMBER)
 RETURN VARCHAR2
IS

BEGIN

    RETURN G_ENG_CHANGE ;

END GetChangeObjectName ;


-- Get Change Line Object (FND Object) Name
FUNCTION GetChangeLineObjectName
(  p_change_line_id        IN  NUMBER)
 RETURN VARCHAR2
IS

BEGIN

    RETURN G_ENG_CHANGE_LINE ;

END GetChangeLineObjectName ;



-- Get Change Object Party
PROCEDURE GetChangeObjectParty
(  p_change_id               IN  NUMBER
 , x_assignee_party_id       OUT NOCOPY NUMBER
 , x_requestor_party_id      OUT NOCOPY NUMBER
 , x_creator_user_id         OUT NOCOPY NUMBER
)
IS

BEGIN

    SELECT eec.assignee_id
         , eec.requestor_id
         , eec.created_by
      INTO x_assignee_party_id
         , x_requestor_party_id
         , x_creator_user_id
      FROM ENG_ENGINEERING_CHANGES    eec
     WHERE eec.change_id = p_change_id ;

END GetChangeObjectParty ;


-- Get Change Line Object Party
PROCEDURE GetChangeLineObjectParty
(  p_change_line_id          IN  NUMBER
 , x_assignee_party_id       OUT NOCOPY NUMBER
 , x_creator_user_id         OUT NOCOPY NUMBER
)
IS

BEGIN

    SELECT ecl.assignee_id
         , ecl.created_by
      INTO x_assignee_party_id
         , x_creator_user_id
      FROM ENG_CHANGE_LINES ecl
     WHERE ecl.change_line_id = p_change_line_id ;

END GetChangeLineObjectParty ;


-- Get Change Object Party
PROCEDURE GetChangeCurrentRev
(  p_change_id               IN  NUMBER
 , x_revision                OUT NOCOPY VARCHAR2
)
IS


    -- Added turnc for end_date condition
    -- requested by Revisino Entity
    CURSOR c_rev(p_change_id NUMBER)
    IS
          SELECT revision_id
               , revision
          FROM   ENG_CHANGE_ORDER_REVISIONS
          WHERE  start_date <= SYSDATE
          AND    (end_date >= TRUNC(SYSDATE) OR end_date IS NULL)
          AND    change_id = p_change_id
          ORDER BY revision  ;

BEGIN


    FOR rev_rec IN c_rev(p_change_id => p_change_id)
    LOOP

        x_revision := rev_rec.revision ;

    END LOOP ;

END GetChangeCurrentRev;


PROCEDURE GetAttachmentChangeDetails
(  p_change_id               IN  NUMBER
 , x_source_media_id_tbl       OUT NOCOPY FND_TABLE_OF_NUMBER
 , x_attached_document_id_tbl  OUT NOCOPY FND_TABLE_OF_NUMBER
 , x_repository_id_tbl         OUT NOCOPY FND_TABLE_OF_NUMBER
 , x_creator_user_id           OUT NOCOPY NUMBER
)
IS
CURSOR doc_details(p_change_id NUMBER)
is
SELECT ATTACHMENT_ID
         , SOURCE_MEDIA_ID
         , REPOSITORY_ID
         , CREATED_BY
      FROM ENG_ATTACHMENT_CHANGES    eec
     WHERE eec.change_id = p_change_id ;
l_index  NUMBER :=0;

BEGIN
   x_attached_document_id_tbl := new  FND_TABLE_OF_NUMBER();
   x_source_media_id_tbl := new  FND_TABLE_OF_NUMBER();
   x_repository_id_tbl := new  FND_TABLE_OF_NUMBER();
   for doc_detail in doc_details( p_change_id)
   loop
          l_index := l_index + 1;
          x_attached_document_id_tbl.EXTEND ;
          x_attached_document_id_tbl(l_index) := doc_detail.ATTACHMENT_ID ;

          x_source_media_id_tbl.EXTEND ;
          x_source_media_id_tbl(l_index) := doc_detail.SOURCE_MEDIA_ID ;

          x_repository_id_tbl.EXTEND ;
          x_repository_id_tbl(l_index) := doc_detail.REPOSITORY_ID ;
          if ( x_creator_user_id is null) then
           x_creator_user_id:= doc_detail.CREATED_BY ;
          end if;
   end loop;

END GetAttachmentChangeDetails ;

/*
-- OBSOLETE in 115.10
-- Get Change Object Child Enable Flags
PROCEDURE GetEnableChildFlags
(  p_change_id               IN  NUMBER
 , x_enable_rev_items_flag   OUT NOCOPY VARCHAR2
 , x_enable_tasks_flag       OUT NOCOPY VARCHAR2
)
IS
    CURSOR c_change(p_change_id NUMBER)
    IS
          -- Modified sql for 115.10 case change, also need additional changes
           SELECT 'Y' AS enable_rev_items_flag -- ecmt.enable_rev_items_flag
                , 'Y' AS enable_tasks_flag  -- ecmt.enable_tasks_flag
           FROM   ENG_CHANGE_MGMT_TYPES   ecmt,
                  ENG_ENGINEERING_CHANGES eec
           WHERE ecmt.change_mgmt_type_code = eec.change_mgmt_type_code
            AND   eec.change_id       = p_change_id ;

          -- SELECT 'Y' AS enable_rev_items_flag -- ecmt.enable_rev_items_flag
          --     , 'Y' AS enable_tasks_flag     -- ecmt.enable_tasks_flag
          -- FROM   ENG_CHANGE_ORDER_TYPES  ecmt,
          --       ENG_ENGINEERING_CHANGES eec
          -- WHERE ecmt.change_mgmt_type_code = eec.change_mgmt_type_code
          -- AND   type_classification = 'CATEGORY'
          -- AND   eec.change_id       = p_change_id ;

BEGIN


    FOR change_rec IN c_change(p_change_id => p_change_id)
    LOOP

        x_enable_rev_items_flag := change_rec.enable_rev_items_flag ;
        x_enable_tasks_flag := change_rec.enable_tasks_flag ;

    END LOOP ;

END GetEnableChildFlags ;
*/


-- Get Ntf Message PL/SQL Document API Info
PROCEDURE GetNtfMessageDocumentAPI
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  x_message_text_body OUT NOCOPY VARCHAR2
 ,  x_message_html_body OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Message Text Body Document API
    x_message_text_body := 'PLSQLCLOB:ENG_WORKFLOW_NTF_UTIL.GetMessageTextBody/'
                         || p_item_type ||':'||p_item_key ||':&#NID' ;

    -- Message HTML Body Document API
    x_message_html_body := 'PLSQLCLOB:ENG_WORKFLOW_NTF_UTIL.GetMessageHTMLBody/'
                         || p_item_type ||':'||p_item_key ||':&#NID' ;


END GetNtfMessageDocumentAPI ;


PROCEDURE GetNtfAttachmentLink
(   p_data_object_code         IN  VARCHAR2
 ,  p_pk1_value                IN  VARCHAR2
 ,  p_pk2_value                IN  VARCHAR2 := NULL
 ,  p_pk3_value                IN  VARCHAR2 := NULL
 ,  p_pk4_value                IN  VARCHAR2 := NULL
 ,  p_pk5_value                IN  VARCHAR2 := NULL
 ,  x_ntf_attachment_link  OUT NOCOPY VARCHAR2
)
IS


     CURSOR c_doc_entity (p_data_object_code VARCHAR2 )
     IS
         SELECT document_entity_id
              , pk1_column
              , pk2_column
              , pk3_column
              , pk4_column
              , pk5_column
         FROM fnd_document_entities
         WHERE data_object_code = p_data_object_code ;

BEGIN


    -- Get Attachment Link Info from FND_DOCUMENT_ENTITIES
    -- then construct Ntf Attachmet Link for the standard
    -- FND:entity=<DATA_OBJECT_CODE> &pk1name=<Key Name>&pk1value=<Key  Value>
    -- e.g.
    -- FND:entity=ENG_ENGINEERING_CHANGES&pk1name=CHANGE_ID&pk1value=9999
    --
    FOR doc_entity_rec IN c_doc_entity (p_data_object_code => p_data_object_code)
    LOOP

        x_ntf_attachment_link := 'FND:entity=' || p_data_object_code ;

        IF p_pk1_value IS NOT NULL THEN

           x_ntf_attachment_link
           := x_ntf_attachment_link || '&pk1name=' || doc_entity_rec.pk1_column
                                    || '&pk1value=' || p_pk1_value ;


        END IF ;

        IF p_pk2_value IS NOT NULL THEN

           x_ntf_attachment_link
           := x_ntf_attachment_link || '&pk2name=' || doc_entity_rec.pk2_column
                                    || '&pk2value=' || p_pk2_value ;


        END IF ;

        IF p_pk3_value IS NOT NULL THEN

           x_ntf_attachment_link
           := x_ntf_attachment_link || '&pk3name=' || doc_entity_rec.pk3_column
                                    || '&pk3value=' || p_pk3_value ;


        END IF ;

        IF p_pk4_value IS NOT NULL THEN

           x_ntf_attachment_link
           := x_ntf_attachment_link || '&pk4name=' || doc_entity_rec.pk4_column
                                    || '&pk4value=' || p_pk4_value ;


        END IF ;


        IF p_pk5_value IS NOT NULL THEN

           x_ntf_attachment_link
           := x_ntf_attachment_link || '&pk5name=' || doc_entity_rec.pk5_column
                                    || '&pk5value=' || p_pk5_value ;


        END IF ;



    END LOOP ;


END GetNtfAttachmentLink ;


/*
PROCEDURE SetWorkflowRevision
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_notice     IN  VARCHAR2
 ,  p_organization_id   IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
)
IS


BEGIN

        INSERT INTO ENG_ECO_SUBMIT_REVISIONS
                    ( change_notice
                    , organization_id
                    , process_name
                    , revision_id
                    , request_id
                    , submit_date
                    , last_update_date
                    , last_updated_by
                    , creation_date
                    , created_by
                    , last_update_login
                     )
        VALUES
                     ( p_change_notice
                     , p_organization_id
                     , p_Process_Name
                     , p_item_key
                     , ''
                     , SYSDATE
                     , SYSDATE
                     , p_wf_user_id
                     , SYSDATE
                     , p_wf_user_id
                     , p_wf_user_id
                     );

END SetWorkflowRevision ;
*/


PROCEDURE CheckWFActivityStatus
(   p_item_type          IN  VARCHAR2
 ,  p_item_key           IN  VARCHAR2
 ,  p_process_name       IN  VARCHAR2 := NULL
 ,  p_activity_item_type IN  VARCHAR2 := Eng_Workflow_Util.G_STD_ITEM_TYPE
 ,  p_activity_name      IN  VARCHAR2
 ,  x_activity_status    OUT NOCOPY VARCHAR2
)
IS

   l_begin_date DATE ;
   l_process_name VARCHAR2(30) ;

BEGIN


    select  WI.BEGIN_DATE
          , WI.ROOT_ACTIVITY
    into    l_begin_date
          , l_process_name
    from    WF_ITEMS WI
    where   WI.ITEM_TYPE  = p_item_type
    and     WI.ITEM_KEY   = p_item_key ;



    IF p_process_name IS NOT NULL
    THEN

       l_process_name := p_process_name ;

    END IF ;


    select WIAS.ACTIVITY_STATUS
         -- , PA.ACTIVITY_NAME
         -- , WIAS.ACTIVITY_RESULT_CODE,
         -- , WIAS.ASSIGNED_USER,
         -- , WIAS.NOTIFICATION_ID,
         -- , WIAS.BEGIN_DATE, WIAS.END_DATE,
         -- , WIAS.DUE_DATE,
         -- , WIAS.ERROR_NAME, WIAS.ERROR_MESSAGE,
         -- , WIAS.ERROR_STACK
    into x_activity_status
    from  WF_ITEM_ACTIVITY_STATUSES WIAS
        , WF_PROCESS_ACTIVITIES PA
        , WF_ACTIVITIES A
    where WIAS.ITEM_TYPE = p_item_type
    and WIAS.ITEM_KEY = p_item_key
    and WIAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
    and PA.PROCESS_ITEM_TYPE = p_item_type
    and PA.PROCESS_NAME = l_process_name
    and PA.ACTIVITY_NAME = A.NAME
    and PA.ACTIVITY_ITEM_TYPE = A.ITEM_TYPE
    and A.ITEM_TYPE = p_activity_item_type
    and A.NAME = p_activity_name
    and l_begin_date >= A.BEGIN_DATE
    and l_begin_date < NVL(A.END_DATE, l_begin_date + 1) ;


EXCEPTION
    WHEN OTHERS THEN
        x_activity_status := NULL;


END CheckWFActivityStatus ;


-- Get Party Info
PROCEDURE GetPartyInfo
(   p_party_id          IN  NUMBER
 ,  x_party_name        OUT NOCOPY VARCHAR2
 ,  x_party_company     OUT NOCOPY VARCHAR2
)
IS

    l_party_type          VARCHAR2(30) ;

BEGIN

     IF p_party_id IS NOT NULL THEN

         l_party_type  := GetPartyType(p_party_id => p_party_id ) ;

         IF l_party_type = 'GROUP' THEN

             begin

             /*
             SELECT  grp.party_name party_name
                   , company.party_name comp_name
             INTO    x_party_name
                   , x_party_company
             FROM    HZ_RELATIONSHIPS emp_cmpy,
                     HZ_PARTIES company,
                     HZ_RELATIONSHIPS owner_group_rel,
                     HZ_PARTIES owner ,
                     HZ_PARTIES grp
             WHERE  emp_cmpy.subject_type (+)= 'PERSON'
             AND    emp_cmpy.subject_table_name (+)= 'HZ_PARTIES'
             AND    emp_cmpy.object_type  (+)= 'ORGANIZATION'
             AND    emp_cmpy.relationship_code (+)= 'EMPLOYEE_OF'
             AND    emp_cmpy.object_table_name(+)= 'HZ_PARTIES'
             AND    emp_cmpy.status (+)= 'A'
             AND    emp_cmpy.start_date (+)<= SYSDATE
             AND    ( emp_cmpy.end_date IS NULL OR emp_cmpy.end_date >= SYSDATE)
             AND    company.party_id (+)= emp_cmpy.object_id
             AND    company.status (+)= 'A'
             AND    emp_cmpy.subject_id (+)= owner.party_id
             -- AND    owner.status='A'
             AND    owner.party_id = owner_group_rel.subject_id
             AND    owner_group_rel.subject_type = 'PERSON'
             AND    owner_group_rel.subject_table_name = 'HZ_PARTIES'
             AND    owner_group_rel.object_type  = 'GROUP'
             AND    owner_group_rel.object_table_name = 'HZ_PARTIES'
             AND    owner_group_rel.relationship_code = 'OWNER_OF'
             AND    owner_group_rel.status = 'A'
             AND    owner_group_rel.start_date <= SYSDATE
             AND    ( owner_group_rel.end_date IS NULL OR owner_group_rel.end_date >= SYSDATE)
             AND    owner_group_rel.object_id = grp.party_id
             -- AND    grp.status = 'A'
             AND    grp.party_id  = p_party_id ;
             */

             -- Replaced above sql to use EGO_GROUPS_V
             SELECT  grp.group_name party_name
                   , '' comp_name
             INTO    x_party_name
                   , x_party_company
             FROM    EGO_GROUPS_V grp
             WHERE  grp.group_id  = p_party_id ;

             exception
               when no_data_found then
                     null ;
             end ;

         ELSIF  l_party_type = 'PERSON'  THEN

             begin

             /* Comment out for bug3038792
              --  Decide to use EGO_PEOPLE_V to prevent from future change
              -- Sicne the EGO_PEOPLE_V may return multi recs per person id,
              --  we just pick first fetched rec
             SELECT  employee.party_name party_name
                   , company.party_name comp_name
             INTO    x_party_name
                   , x_party_company
             FROM    hz_parties employee
                   , hz_relationships emp_cmpy
                   , hz_parties company
             WHERE  emp_cmpy.subject_type (+)= 'PERSON'
             AND    emp_cmpy.subject_table_name (+)= 'HZ_PARTIES'
             AND    emp_cmpy.object_type  (+)= 'ORGANIZATION'
             AND    emp_cmpy.relationship_code (+)= 'EMPLOYEE_OF'
             AND    emp_cmpy.object_table_name (+)= 'HZ_PARTIES'
             AND    emp_cmpy.status (+)= 'A'
             AND    emp_cmpy.start_date (+) <= SYSDATE
             AND   (emp_cmpy.end_date IS NULL OR emp_cmpy.end_date >= SYSDATE)
             -- AND    employee.status = 'A'
             AND    company.party_id (+) = emp_cmpy.object_id
             AND    company.status (+)= 'A'
             AND    emp_cmpy.subject_id (+)= employee.party_id
             AND    employee.party_id =  p_party_id ;
             */

             SELECT  person_name party_name
                   , company_name comp_name
             INTO    x_party_name
                   , x_party_company
             FROM   EGO_PEOPLE_V
             WHERE  person_id = p_party_id
             AND    ROWNUM = 1 ;

             exception
               when no_data_found then
                     null ;
             end ;

         END IF ;

      END IF ; -- party id is not null

END GetPartyInfo ;


-- Get Step Activity Attributes
PROCEDURE GetStepActAttributes
(   p_step_id                 IN  NUMBER
 ,  x_default_role_name       OUT NOCOPY VARCHAR2
 ,  x_activity_condition_code OUT NOCOPY VARCHAR2
)
IS

     CURSOR c_step_act_attr (p_step_id NUMBER)
     IS
           SELECT WfActAttr.TEXT_DEFAULT  DEFAULT_ROLE_NAME,
                  WfActAttr2.TEXT_DEFAULT ACTIVITY_CONDITION_CODE
           FROM   WF_ACTIVITIES WfAct,
                  WF_ACTIVITY_ATTRIBUTES WfActAttr,
                  WF_ACTIVITY_ATTRIBUTES WfActAttr2,
                  ENG_CHANGE_ROUTE_STEPS RouteStep
           WHERE WfActAttr.NAME (+)= 'DEFAULT_CHANGE_ROLE'
           AND WfActAttr.ACTIVITY_VERSION (+)= WfAct.VERSION
           AND WfActAttr.ACTIVITY_ITEM_TYPE (+)= WfAct.ITEM_TYPE
           AND WfActAttr.ACTIVITY_NAME (+)= WfAct.NAME
           AND WfActAttr2.NAME (+)= 'ACTIVITY_CONDITION_CODE'
           AND WfActAttr2.ACTIVITY_VERSION (+)= WfAct.VERSION
           AND WfActAttr2.ACTIVITY_ITEM_TYPE (+)= WfAct.ITEM_TYPE
           AND WfActAttr2.ACTIVITY_NAME (+)= WfAct.NAME
           AND WfAct.TYPE = 'PROCESS'
           AND WfAct.BEGIN_DATE <= SYSDATE
           AND (WfAct.END_DATE >= SYSDATE OR WfAct.END_DATE IS NULL)
           AND WfAct.ITEM_TYPE = RouteStep.wf_item_type
           AND WfAct.NAME = RouteStep.wf_process_name
           AND RouteStep.step_id = p_step_id ;


BEGIN

    FOR step_attr_rec IN c_step_act_attr(p_step_id => p_step_id )
    LOOP

         x_default_role_name       :=  step_attr_rec.default_role_name ;
         x_activity_condition_code :=  step_attr_rec.activity_condition_code ;

    END LOOP ;

END GetStepActAttributes ;


-- R12B
-- Get Step Activity Attributes for Auto Grants
PROCEDURE GetStepAutoGranatRoles
(   p_step_id                 IN  NUMBER
 ,  x_document_role_id        OUT NOCOPY NUMBER
 ,  x_ocs_role                OUT NOCOPY VARCHAR2
)
IS

     CURSOR c_step_act_attr (c_step_id NUMBER)
     IS
           SELECT document_role_attr.TEXT_DEFAULT  DOCUMENT_ROLE
                , doc_role.MENU_ID                 DOCUMENT_ROLE_ID
                , cs_role_attr.TEXT_DEFAULT        OCS_ROLE
           FROM   FND_MENUS     doc_role
                , WF_ACTIVITIES WfAct
                , WF_ACTIVITY_ATTRIBUTES document_role_attr
                , WF_ACTIVITY_ATTRIBUTES cs_role_attr
                , ENG_CHANGE_ROUTE_STEPS RouteStep
           WHERE doc_role.MENU_NAME (+)= document_role_attr.TEXT_DEFAULT
           AND   document_role_attr.NAME (+)= 'AUTO_GRANT_DOCUMENT_ROLE'
           AND document_role_attr.ACTIVITY_VERSION (+)= WfAct.VERSION
           AND document_role_attr.ACTIVITY_ITEM_TYPE (+)= WfAct.ITEM_TYPE
           AND document_role_attr.ACTIVITY_NAME (+)= WfAct.NAME
           AND cs_role_attr.NAME (+)= 'AUTO_GRANT_OCS_ROLE'
           AND cs_role_attr.ACTIVITY_VERSION (+)= WfAct.VERSION
           AND cs_role_attr.ACTIVITY_ITEM_TYPE (+)= WfAct.ITEM_TYPE
           AND cs_role_attr.ACTIVITY_NAME (+)= WfAct.NAME
           AND WfAct.TYPE = 'PROCESS'
           AND WfAct.BEGIN_DATE <= SYSDATE
           AND (WfAct.END_DATE >= SYSDATE OR WfAct.END_DATE IS NULL)
           AND WfAct.ITEM_TYPE = RouteStep.wf_item_type
           AND WfAct.NAME = RouteStep.wf_process_name
           AND RouteStep.step_id = c_step_id ;

BEGIN

    FOR step_attr_rec IN c_step_act_attr(c_step_id => p_step_id )
    LOOP
         x_document_role_id  :=  step_attr_rec.DOCUMENT_ROLE_ID ;
         x_ocs_role          :=  step_attr_rec.OCS_ROLE ;
    END LOOP ;

END GetStepAutoGranatRoles ;

-- R12B
-- Get Additional Step Voting Option If Response Condition for Step is All
-- to support Request Response process in Line Workflow
PROCEDURE GetStepVoteOptionForAllResp
(   p_step_id                   IN  NUMBER
 ,  x_vote_option_for_step_all  OUT NOCOPY VARCHAR2
)
IS

     CURSOR c_step_act_attr (c_step_id NUMBER)
     IS
           SELECT vote_option_attr.TEXT_DEFAULT    VOTE_OPTION
           FROM   WF_ACTIVITIES WfAct
                , WF_ACTIVITY_ATTRIBUTES vote_option_attr
                , ENG_CHANGE_ROUTE_STEPS RouteStep
           WHERE vote_option_attr.NAME (+)= 'VOTE_OPTION_FOR_STEP_ALL'
           AND vote_option_attr.ACTIVITY_VERSION (+)= WfAct.VERSION
           AND vote_option_attr.ACTIVITY_ITEM_TYPE (+)= WfAct.ITEM_TYPE
           AND vote_option_attr.ACTIVITY_NAME (+)= WfAct.NAME
           AND WfAct.TYPE = 'PROCESS'
           AND WfAct.BEGIN_DATE <= SYSDATE
           AND (WfAct.END_DATE >= SYSDATE OR WfAct.END_DATE IS NULL)
           AND WfAct.ITEM_TYPE = RouteStep.wf_item_type
           AND WfAct.NAME = RouteStep.wf_process_name
           AND RouteStep.step_id = c_step_id ;

BEGIN

    FOR step_attr_rec IN c_step_act_attr(c_step_id => p_step_id )
    LOOP
         x_vote_option_for_step_all  :=  step_attr_rec.VOTE_OPTION ;
    END LOOP ;

END GetStepVoteOptionForAllResp ;


-- R12B
-- Get Step Assignee Default Response Code
-- to support Request Response process in Line Workflow
PROCEDURE GetStepDefaultRespCode
(   p_step_id                   IN  NUMBER
 ,  x_default_resp_code         OUT NOCOPY VARCHAR2
)
IS

     CURSOR c_step_act_attr (c_step_id NUMBER)
     IS
           SELECT vote_option_attr.TEXT_DEFAULT    VOTE_OPTION
           FROM   WF_ACTIVITIES WfAct
                , WF_ACTIVITY_ATTRIBUTES vote_option_attr
                , ENG_CHANGE_ROUTE_STEPS RouteStep
           WHERE vote_option_attr.NAME (+)= 'DEFAULT_ASSIGNEE_RESP_CODE'
           AND vote_option_attr.ACTIVITY_VERSION (+)= WfAct.VERSION
           AND vote_option_attr.ACTIVITY_ITEM_TYPE (+)= WfAct.ITEM_TYPE
           AND vote_option_attr.ACTIVITY_NAME (+)= WfAct.NAME
           AND WfAct.TYPE = 'PROCESS'
           AND WfAct.BEGIN_DATE <= SYSDATE
           AND (WfAct.END_DATE >= SYSDATE OR WfAct.END_DATE IS NULL)
           AND WfAct.ITEM_TYPE = RouteStep.wf_item_type
           AND WfAct.NAME = RouteStep.wf_process_name
           AND RouteStep.step_id = c_step_id ;

BEGIN


    FOR step_attr_rec IN c_step_act_attr(c_step_id => p_step_id )
    LOOP
         x_default_resp_code :=  step_attr_rec.VOTE_OPTION ;
    END LOOP ;


   IF x_default_resp_code IS NULL THEN
       x_default_resp_code := Eng_Workflow_Util.G_RT_SUBMITTED ;
   END IF ;

END GetStepDefaultRespCode ;



-- Get Step Required Date
FUNCTION GetStepRequiredDate
(   p_step_id                 IN  NUMBER
) RETURN DATE
IS

     l_required_date DATE ;

     CURSOR c_step (p_step_id NUMBER)
     IS
           SELECT required_relative_days
           FROM   ENG_CHANGE_ROUTE_STEPS RouteStep
           WHERE  RouteStep.step_id = p_step_id ;


BEGIN

    FOR step_rec IN c_step(p_step_id => p_step_id )
    LOOP
         IF step_rec.required_relative_days IS NOT NULL
         THEN

             -- Bug3456536
             -- For Different Timezon Support, we decided not to
             -- trucate the date so that we can display Date Time correctly
             -- l_required_date := TRUNC(SYSDATE + step_rec.required_relative_days) ;
             l_required_date := SYSDATE + step_rec.required_relative_days ;

         END IF ;

    END LOOP ;

    RETURN l_required_date ;

END GetStepRequiredDate ;


-- Get Workflow Signature Policy from Lifecycle Phase
FUNCTION GetWfSigPolicyFromLCPhase
(   p_change_id                 IN  NUMBER
,   p_route_id                  IN  NUMBER
) RETURN VARCHAR2
IS

     l_wf_sig_policy VARCHAR2(30) ;

     CURSOR c_wfsigpolicy ( p_route_id NUMBER )
     IS
        SELECT TempLCStatus.WF_SIG_POLICY
        FROM   ENG_LIFECYCLE_STATUSES TempLCStatus,
               ENG_CHANGE_ROUTES Route,
               ENG_ENGINEERING_CHANGES EngChange
        WHERE  TempLCStatus.ENTITY_NAME = 'ENG_CHANGE_TYPE'
        AND    TempLCStatus.ENTITY_ID1 = EngChange.CHANGE_ORDER_TYPE_ID
        AND    TO_CHAR(TempLCStatus.STATUS_CODE) = Route.CLASSIFICATION_CODE
        AND    EngChange.CHANGE_ID = Route.OBJECT_ID1
        AND    Route.OBJECT_NAME = 'ENG_CHANGE'
        AND    Route.ROUTE_ID = p_route_id ;



BEGIN

    FOR l_rec IN c_wfsigpolicy (p_route_id => p_route_id)
    LOOP

         IF   l_rec.WF_SIG_POLICY IS NOT NULL
         AND  l_rec.WF_SIG_POLICY = G_SIG_POLICY_PSIG_ONLY
         THEN

             l_wf_sig_policy := G_SIG_POLICY_PSIG_ONLY ;

         ELSIF   l_rec.WF_SIG_POLICY IS NOT NULL
         AND  l_rec.WF_SIG_POLICY = G_SIG_POLICY_PKCS7X509_ONLY
         THEN

             l_wf_sig_policy := G_SIG_POLICY_PKCS7X509_ONLY ;

         END IF ;

    END LOOP ;

    RETURN l_wf_sig_policy ;

END GetWfSigPolicyFromLCPhase ;


-- Get Workflow Signature Policy from Lifecycle Phase
PROCEDURE RespondToDuplicateNtf
(   p_dupllicate_ntf_id      IN  NUMBER
,   p_orig_ntf_id            IN  NUMBER
,   p_responder              IN  VARCHAR2
)
IS

    CURSOR  c_orig_ntf_resp (p_orig_ntf_id        NUMBER )
    IS
        SELECT na.NAME
             , na.TEXT_VALUE
             , na.NUMBER_VALUE
             , na.DATE_VALUE
         FROM WF_NOTIFICATION_ATTRIBUTES na,
              WF_MESSAGE_ATTRIBUTES ma,
              WF_NOTIFICATIONS ntf
         WHERE ntf.NOTIFICATION_ID = p_orig_ntf_id
         AND   na.NOTIFICATION_ID = ntf.NOTIFICATION_ID
         AND   ma.MESSAGE_NAME = ntf.MESSAGE_NAME
         AND   ma.MESSAGE_TYPE = ntf.MESSAGE_TYPE
         AND   ma.NAME = na.NAME
         AND   ma.SUBTYPE = 'RESPOND' ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.RespondToDuplicateNtf Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Target Dup Notification Id  : ' || TO_CHAR(p_dupllicate_ntf_id));
   Write_Debug('Original Notification Id  : ' || TO_CHAR(p_orig_ntf_id));
   Write_Debug('-----------------------------------------------------');
END IF ;

    -- Get the response attribute for original ntf id.
    -- Set attribute for target Duplicate Notificaiton Id
    FOR ntf_resp_rec IN c_orig_ntf_resp (p_orig_ntf_id => p_orig_ntf_id)
    LOOP

        IF ntf_resp_rec.TEXT_VALUE IS NOT NULL
        THEN


            WF_NOTIFICATION.SetAttrText
                             ( nid    => p_dupllicate_ntf_id
                             , aname  => ntf_resp_rec.NAME
                             , avalue => ntf_resp_rec.TEXT_VALUE
                             );

        END IF ;

        IF ntf_resp_rec.NUMBER_VALUE IS NOT NULL
        THEN

            WF_NOTIFICATION.SetAttrNumber
                             ( nid    => p_dupllicate_ntf_id
                             , aname  => ntf_resp_rec.NAME
                             , avalue => ntf_resp_rec.NUMBER_VALUE
                             );

        END IF ;

        IF ntf_resp_rec.DATE_VALUE IS NOT NULL
        THEN

            WF_NOTIFICATION.SetAttrDate
                             ( nid    => p_dupllicate_ntf_id
                             , aname  => ntf_resp_rec.NAME
                             , avalue => ntf_resp_rec.DATE_VALUE
                             );

        END IF ;

    END LOOP ;

IF g_debug_flag THEN
   Write_Debug('Calling WF_NOTIFICATION.RESPOND for Target Dup Ntf ');
END IF ;

    WF_NOTIFICATION.RESPOND
    ( nid => p_dupllicate_ntf_id -- nid in number
    , responder => p_responder  -- responder in varchar2 default null
    ) ;

END RespondToDuplicateNtf ;


-- R12B
-- Check if this workflow routing is Line Notificaiton Worklfow
FUNCTION Is_Line_Ntf_WF
( p_route_id  IN  NUMBER)
RETURN BOOLEAN
IS

    l_route_type_code   VARCHAR2(30) ;

BEGIN

    Eng_Workflow_Util.GetRouteTypeCode( p_route_id        => p_route_id
                                      , x_route_type_code => l_route_type_code
                                      ) ;

    IF Eng_Workflow_Util.G_LINE_RT_TYPE_NOTIFICATION = l_route_type_code
    THEN
        RETURN  TRUE ;
    ELSE
        RETURN  FALSE ;
    END IF ;


END Is_Line_Ntf_WF ;


/********************************************************************
* API Type      : Private APIs
* Purpose       : Internal Use Only
*********************************************************************/
FUNCTION GetBaseChangeMgmtTypeCode
( p_change_id         IN     NUMBER)
RETURN VARCHAR2
IS
   -- return SUMMARY or DETAIL
    l_base_cm_code VARCHAR2(30) ;

    CURSOR  c_base_cm_code(p_change_id NUMBER)
    IS
        SELECT ChangeCategory.BASE_CHANGE_MGMT_TYPE_CODE
        FROM ENG_ENGINEERING_CHANGES EngineeringChangeEO,
             ENG_CHANGE_ORDER_TYPES ChangeCategory
        WHERE  ChangeCategory.type_classification = 'CATEGORY'
        AND ChangeCategory.change_mgmt_type_code = EngineeringChangeEO.change_mgmt_type_code
        AND EngineeringChangeEO.change_id = p_change_id  ;

BEGIN
    FOR l_rec IN c_base_cm_code  (p_change_id => p_change_id)
    LOOP
        l_base_cm_code :=  l_rec.BASE_CHANGE_MGMT_TYPE_CODE  ;
    END LOOP ;

    RETURN l_base_cm_code ;

END  GetBaseChangeMgmtTypeCode ;


-- Get Change Object Identifier
PROCEDURE GetChangeObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_change_id         OUT NOCOPY NUMBER
)
IS

BEGIN

    -- Get Change Object Id
    x_change_id := WF_ENGINE.GetItemAttrNumber
                            (  p_item_type
                             , p_item_key
                             , 'CHANGE_ID'
                             );

END GetChangeObject ;


-- Get Change Line Object Identifier
PROCEDURE GetChangeLineObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_change_line_id    OUT NOCOPY NUMBER
)
IS

BEGIN

    -- Bug 3823830
    -- For upgrade, suppress the exception
    begin

    -- Get Change Line Object Id
    x_change_line_id := WF_ENGINE.GetItemAttrNumber
                            (  p_item_type
                             , p_item_key
                             , 'CHANGE_LINE_ID'
                             );

    exception
        when others then
            null ;
    end  ;

END GetChangeLineObject ;



-- Get Change Object Identifier
PROCEDURE GetChangeObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_change_id         OUT NOCOPY NUMBER
 ,  x_change_notice     OUT NOCOPY VARCHAR2
 ,  x_organization_id   OUT NOCOPY NUMBER
)
IS

BEGIN


    -- Get Change Object Id
    x_change_id := WF_ENGINE.GetItemAttrNumber
                            (  p_item_type
                             , p_item_key
                             , 'CHANGE_ID'
                             );


    -- Get Change Org Id
    x_organization_id := WF_ENGINE.GetItemAttrNumber
                            (  p_item_type
                             , p_item_key
                             , 'ORGANIZATION_ID'
                             );

    -- Get Change Notice
    x_change_notice := WF_ENGINE.GetItemAttrText
                            (  p_item_type
                             , p_item_key
                             , 'CHANGE_NOTICE'
                             );

END GetChangeObject ;



PROCEDURE GetHostURL
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_host_url          OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Get Host URL
    x_host_url := WF_ENGINE.GetItemAttrText
                  ( p_item_type
                  , p_item_key
                  , 'HOST_URL'
                  );

    IF x_host_url  IS NULL THEN

       x_host_url := GetFrameWorkAgentURL ;

    END IF ;

END GetHostURL;

FUNCTION GetFrameWorkAgentURL
RETURN VARCHAR2
IS

   apps_fwk_agent VARCHAR2(256);

BEGIN

    apps_fwk_agent := rtrim(FND_PROFILE.VALUE('APPS_FRAMEWORK_AGENT'), '/');

    RETURN apps_fwk_agent ;

END GetFrameWorkAgentURL ;



PROCEDURE SetWFUserId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
)
IS

BEGIN

    -- Set Workflow User Id
    WF_ENGINE.SetItemAttrNumber
                  ( p_item_type
                  , p_item_key
                  , 'WF_USER_ID'
                  , p_wf_user_id
                  );

END SetWFUserId ;


PROCEDURE SetWFUserRole
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_wf_user_role      IN  VARCHAR2
)
IS

BEGIN

    -- Set WF Owner's User Role
    WF_ENGINE.SetItemAttrText
                  ( p_item_type
                  , p_item_key
                  , 'WF_USER_ROLE'
                  , p_wf_user_role
                  );

END SetWFUserRole ;


PROCEDURE SetNTFFromRole
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_ntf_from_role     IN  VARCHAR2
)
IS

BEGIN

    -- Set Ntf From Role
    WF_ENGINE.SetItemAttrText
                  ( p_item_type
                  , p_item_key
                  , 'FROM_ROLE'
                  , p_ntf_from_role
                  );

END SetNTFFromRole ;

PROCEDURE GetWFUserId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_wf_user_id        OUT NOCOPY NUMBER
)
IS

BEGIN

    -- Get Workflow User Id
    x_wf_user_id := WF_ENGINE.GetItemAttrNumber
                  ( p_item_type
                  , p_item_key
                  , 'WF_USER_ID'
                  );

END GetWFUserId ;


PROCEDURE GetWFItemOwnerRole
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_item_owner_role   OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Fnd User's User Name
    SELECT owner_role
      INTO x_item_owner_role
      FROM WF_ITEMS
     WHERE item_type = p_item_type
       AND item_key  = p_item_key ;


END GetWFItemOwnerRole ;



PROCEDURE GetRouteId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_route_id          OUT NOCOPY NUMBER
)
IS

BEGIN

    -- Get Route Id
    x_route_id := WF_ENGINE.GetItemAttrNumber
                  ( p_item_type
                  , p_item_key
                  , 'ROUTE_ID'
                  );

END GetRouteId ;

PROCEDURE GetRouteObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_route_object      OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Get Route Object
    x_route_object := WF_ENGINE.GetItemAttrText
                  ( p_item_type
                  , p_item_key
                  , 'OBJECT_NAME'
                  , TRUE -- ignore_notfound
                  );

    IF x_route_object IS  NULL
    THEN
       x_route_object := G_ENG_CHANGE ;

    END IF ;

END GetRouteObject ;


PROCEDURE GetRouteTypeCode
(   p_route_id          IN  NUMBER
 ,  x_route_type_code   OUT NOCOPY VARCHAR2
)
IS

    CURSOR  c_route  (p_route_id NUMBER)
    IS
        SELECT ROUTE_TYPE_CODE
          FROM ENG_CHANGE_ROUTES
         WHERE ROUTE_ID = p_route_id ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.GetRouteTypeCode Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Route Id  : ' || TO_CHAR(p_route_id));
   Write_Debug('-----------------------------------------------------');
END IF ;


    -- Get Route WF Info
    FOR l_route_rec IN c_route (p_route_id => p_route_id )
    LOOP

        x_route_type_code := l_route_rec.ROUTE_TYPE_CODE ;

    END LOOP ;

IF g_debug_flag THEN
   Write_Debug('Route Type Code  : ' || x_route_type_code);
END IF ;


END GetRouteTypeCode ;


PROCEDURE GetRouteComplStatusCode
(   p_route_id                IN  NUMBER
 ,  p_route_type_code         IN  VARCHAR2 := NULL
 ,  x_route_compl_status_code OUT NOCOPY VARCHAR2
)
IS

    l_route_type_code VARCHAR2(30) ;

BEGIN

    l_route_type_code := p_route_type_code ;

    IF l_route_type_code IS NULL THEN


       GetRouteTypeCode( p_route_id => p_route_id
                       , x_route_type_code => l_route_type_code ) ;

    END IF ;

    IF l_route_type_code IN (G_RT_TYPE_APPROVAL, G_RT_TYPE_DEFINITION_APPROVAL)
    THEN

        x_route_compl_status_code := G_RT_APPROVED ;

    ELSE

        x_route_compl_status_code := G_RT_COMPLETED ;

    END IF ; -- Check Route Type Code and set Route Completion Status


END GetRouteComplStatusCode ;


PROCEDURE GetRouteStepId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_route_step_id     OUT NOCOPY NUMBER
)
IS

BEGIN

    -- Get Change Route Step Id
    x_route_step_id := WF_ENGINE.GetItemAttrNumber
                  ( p_item_type
                  , p_item_key
                  , 'STEP_ID'
                  );

END GetRouteStepId ;




PROCEDURE SetRouteStepId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_route_step_id     IN  NUMBER
)
IS

BEGIN

    -- Set Change Route Step Id
    WF_ENGINE.SetItemAttrNumber
                  ( p_item_type
                  , p_item_key
                  , 'STEP_ID'
                  , p_route_step_id
                  );

END SetRouteStepId ;


PROCEDURE GetStyleSheet
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_style_sheet       OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Get Style Sheet
    x_style_sheet := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                  , p_item_key
                  , 'DEFAULT_STYLE_SHEET'
                  );

END GetStyleSheet ;

PROCEDURE SetActionId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_action_id         IN  NUMBER
)
IS

BEGIN

    -- Set Action Id
    WF_ENGINE.SetItemAttrNumber
              ( p_item_type
              , p_item_key
              , 'ACTION_ID'
              , p_action_id
              );

END SetActionId ;


PROCEDURE GetActionId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_action_id         OUT NOCOPY NUMBER
)
IS

BEGIN

    -- Get Action Id
    x_action_id  :=  WF_ENGINE.GetItemAttrNumber
                          ( p_item_type
                          , p_item_key
                          , 'ACTION_ID'
                          );

END GetActionId ;


PROCEDURE GetNtfResponseTimeOut
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_timeout_min       OUT NOCOPY NUMBER
)
IS

BEGIN


    -- Get Response Timeout Min
    x_timeout_min :=  WF_ENGINE.GetItemAttrNumber
                          ( p_item_type
                          , p_item_key
                          , 'RESPONSE_TIMEOUT'
                          );

END GetNtfResponseTimeOut ;


-- This response by date version of SetNtfResponseTimeOut
-- is intended to be used for Request Comment Action
PROCEDURE SetNtfResponseTimeOut
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_response_by_date  IN  DATE
)
IS

    l_timeout_min    NUMBER ;

BEGIN

    -- calculate min by timeout date
    IF  p_response_by_date IS NOT NULL
    THEN
        l_timeout_min := trunc(((p_response_by_date + 1 - 0.0000001) - SYSDATE )
                               *  24 * 60 ) ;

        IF l_timeout_min < 1 THEN
            l_timeout_min := 1 ; -- Minimum TimeOut One Min
        END IF ;

    ELSE

        l_timeout_min := 0 ;

    END IF ;

    -- Set the timeout min to Item Attribute for ntf time out
    WF_ENGINE.SetItemAttrNumber( p_item_type
                               , p_item_key
                               , 'RESPONSE_TIMEOUT'
                               , l_timeout_min
                               );

END SetNtfResponseTimeOut ;

-- This p_required_relative_days version of SetNtfResponseTimeOut
-- is used for Workflow Routing Ntf
PROCEDURE SetNtfResponseTimeOut
(   p_item_type              IN  VARCHAR2
 ,  p_item_key               IN  VARCHAR2
 ,  p_required_relative_days IN  NUMBER
)
IS

    l_timeout_min    NUMBER ;

BEGIN

    -- calculate min by timeout date
    IF  p_required_relative_days IS NOT NULL
    THEN
        l_timeout_min := p_required_relative_days *  24 * 60 ;

        IF l_timeout_min < 1 THEN
            l_timeout_min := 1 ; -- Minimum TimeOut One Min
        END IF ;

    ELSE

        l_timeout_min := 0 ;

    END IF ;

    -- Set the timeout min to Item Attribute for ntf time out
    WF_ENGINE.SetItemAttrNumber( p_item_type
                               , p_item_key
                               , 'RESPONSE_TIMEOUT'
                               , l_timeout_min
                               );

END SetNtfResponseTimeOut ;



PROCEDURE SetStepActVotingOption
(   p_item_type           IN  VARCHAR2
 ,  p_item_key            IN  VARCHAR2
 ,  p_condition_type_code IN  VARCHAR2
)
IS

    l_step_voting_option        VARCHAR2(30) ;
    l_yes_percentage            NUMBER ;
    l_no_percentage             NUMBER ;

    -- R12B
    l_vote_option_for_step_all  VARCHAR2(30) ;
    l_route_step_id             NUMBER ;

BEGIN


     -- Get Route Step Id
     Eng_Workflow_Util.GetRouteStepId
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_route_step_id     => l_route_step_id
     ) ;



    -- Set Step Voting Option based on Step Activity Condition
    IF  p_condition_type_code = Eng_Workflow_Util.G_ALL THEN


        -- R12B
        -- Need to get Additional Vote Option for All
        -- to support Request Response process in Line Notification Workflow.
        -- In case of the process (Notifcation is Request Response Notification),
        -- we need to wait for the all response until all the notification recipient
        -- respond to the notification.
        -- By default, REQUEST_RESPONSE process has process level attribute
        -- VOTE_OPTION_FOR_STEP_ALL. ( the value is REQUIRE_ALL_VOTES)
        -- We will use the option which defined in VOTE_OPTION_FOR_STEP_ALL
        -- instead of G_TALLY_ON_EVERY_VOTE
        --
        GetStepVoteOptionForAllResp( p_step_id => l_route_step_id
                                   ,  x_vote_option_for_step_all => l_vote_option_for_step_all
                                    ) ;

        IF ( l_vote_option_for_step_all IS NULL
             OR (     Eng_Workflow_Util.G_WAIT_FOR_ALL_VOTES <> l_vote_option_for_step_all
                  AND Eng_Workflow_Util.G_TALLY_ON_EVERY_VOTE <> l_vote_option_for_step_all
                  AND Eng_Workflow_Util.G_REQUIRE_ALL_VOTES <> l_vote_option_for_step_all
                 )
            )
        THEN
             l_vote_option_for_step_all := Eng_Workflow_Util.G_TALLY_ON_EVERY_VOTE;

        END IF ;

        l_step_voting_option := l_vote_option_for_step_all ;
        -- Bug 5254686
        IF ( l_step_voting_option = Eng_Workflow_Util.G_REQUIRE_ALL_VOTES )
        THEN

           l_yes_percentage     := NULL ;
           l_no_percentage      := NULL  ;

        ELSE

           l_yes_percentage     := 100 ;
           l_no_percentage      := 0 ;
        END IF ;

    ELSIF p_condition_type_code = Eng_Workflow_Util.G_ONE THEN

        l_step_voting_option := Eng_Workflow_Util.G_TALLY_ON_EVERY_VOTE ;
        l_yes_percentage     := 0 ;
        l_no_percentage      := 0 ;

    ELSIF p_condition_type_code = Eng_Workflow_Util.G_PEOPLE THEN

        l_step_voting_option := Eng_Workflow_Util.G_PEOPLE;
        l_yes_percentage     := 100 ;
        l_no_percentage      := 0 ;


    /* For future ref
    ELSIF p_condition_type_code = Eng_Workflow_Util.G_WAIT_ALL THEN

        l_step_voting_option := Eng_Workflow_Util.G_WAIT_FOR_ALL_VOTES ;
        l_yes_percentage     := 100 ;
        l_no_percentage      := 0 ;
    */


    END IF ;

    -- Set Step Activity Condition to Item Attr
    WF_ENGINE.SetItemAttrText( p_item_type
                             , p_item_key
                             , 'STEP_CONDITION'
                             , p_condition_type_code );


    -- Set Step Activity Voting Option
    -- for Notification
    WF_ENGINE.SetItemAttrText( p_item_type
                             , p_item_key
                             , 'STEP_VOTING_OPTION'
                             , l_step_voting_option);


    -- Set Yes response percentage of votes
    -- for Notification
    WF_ENGINE.SetItemAttrNumber( p_item_type
                               , p_item_key
                             , 'YES_RESPONSE_PERCENT'
                             , l_yes_percentage );

    -- Set No response percentage of votes
    -- for Notification
    WF_ENGINE.SetItemAttrNumber( p_item_type
                               , p_item_key
                             , 'NO_RESPONSE_PERCENT'
                             , l_no_percentage );



END SetStepActVotingOption ;



-- Get Item Info
PROCEDURE GetItemInfo
(  p_organization_id         IN  NUMBER
 , p_item_id                 IN  NUMBER
 , p_item_revision_id        IN  NUMBER
 , x_item_name               OUT NOCOPY VARCHAR2
 , x_item_revision           OUT NOCOPY VARCHAR2
 , x_item_revision_label     OUT NOCOPY VARCHAR2
)
IS

    CURSOR c_item_info (p_item_id         NUMBER ,
                        p_organization_id NUMBER )
    IS
          SELECT item.concatenated_segments item_name
          FROM   MTL_SYSTEM_ITEMS_KFV item
          WHERE item.organization_id  = p_organization_id
          AND   item.inventory_item_id = p_item_id ;



    CURSOR c_item_rev_info (p_item_id           NUMBER ,
                            p_organization_id   NUMBER ,
                            p_item_revision_id  NUMBER )
    IS
          SELECT rev.revision item_revision
               , rev.revision_label item_revision_label
          FROM   MTL_ITEM_REVISIONS rev
          WHERE  rev.organization_id = p_organization_id
          AND    rev.inventory_item_id = p_item_id
          AND    rev.revision_id = p_item_revision_id ;


BEGIN


    FOR item_rec IN c_item_info ( p_item_id         => p_item_id
                                , p_organization_id => p_organization_id)
    LOOP

         x_item_name :=  item_rec.item_name ;

    END LOOP ;


    IF p_item_revision_id IS NOT NULL THEN


        FOR item_rev_rec IN c_item_rev_info ( p_item_id          => p_item_id
                                            , p_organization_id  => p_organization_id
                                            , p_item_revision_id => p_item_revision_id)
        LOOP

             x_item_revision :=  item_rev_rec.item_revision ;
             x_item_revision_label := item_rev_rec.item_revision_label ;

        END LOOP ;


    END IF ;

END GetItemInfo ;


-- Get Change Object Item Subject Info
PROCEDURE GetChangeItemSubjectInfo
(  p_change_id               IN  NUMBER
 , x_organization_id         OUT NOCOPY NUMBER
 , x_item_id                 OUT NOCOPY NUMBER
 , x_item_name               OUT NOCOPY VARCHAR2
 , x_item_revision_id        OUT NOCOPY NUMBER
 , x_item_revision           OUT NOCOPY VARCHAR2
 , x_item_revision_label     OUT NOCOPY VARCHAR2
)
IS

    CURSOR c_subj_item(p_change_id NUMBER, p_entity_name VARCHAR2)
    IS
          -- Modified for 115.10 Case Change
          -- SELECT TO_NUMBER(subject.pk2_value) organization_id
          --     , TO_NUMBER(subject.pk1_value) item_id
          --     , TO_NUMBER(subject.pk3_value) item_revision_id
          -- FROM   ENG_CHANGE_LINES subject
          --      , FND_OBJECTS          obj
          -- WHERE subject.pk1_value IS NOT NULL
          -- AND   subject.pk2_value IS NOT NULL
          -- AND   subject.sequence_number = -1
          -- AND   subject.object_id = obj.object_id
          -- AND   obj.obj_name IN ('EGO_ITEM', 'EGO_ITEM_REVISION')
          -- AND   subject.change_id = p_change_id ;

          SELECT TO_NUMBER(subject.pk2_value) organization_id
               , TO_NUMBER(subject.pk1_value) item_id
               , TO_NUMBER(subject.pk3_value) item_revision_id
          FROM   ENG_CHANGE_SUBJECTS subject
          WHERE subject.pk1_value IS NOT NULL
          AND   subject.pk2_value IS NOT NULL
          AND   subject.entity_name = p_entity_name
          AND   subject.change_line_id IS NULL
          AND   subject.change_id = p_change_id ;

    l_item_rev_found BOOLEAN := FALSE ;

BEGIN

    FOR subj_item_rec IN c_subj_item(p_change_id => p_change_id,
                                     p_entity_name => 'EGO_ITEM_REVISION' )
    LOOP

         x_organization_id         :=  subj_item_rec.organization_id ;
         x_item_id                 :=  subj_item_rec.item_id ;
         x_item_revision_id        :=  subj_item_rec.item_revision_id ;

         GetItemInfo( p_organization_id   => x_organization_id ,
                      p_item_id           => x_item_id ,
                      p_item_revision_id  => x_item_revision_id ,
                      x_item_name         => x_item_name ,
                      x_item_revision     => x_item_revision ,
                      x_item_revision_label => x_item_revision_label ) ;

         l_item_rev_found := TRUE ;

    END LOOP ;

    IF NOT l_item_rev_found
    THEN

        FOR subj_item_rec IN c_subj_item(p_change_id => p_change_id,
                                         p_entity_name => 'EGO_ITEM' )
        LOOP

             x_organization_id         :=  subj_item_rec.organization_id ;
             x_item_id                 :=  subj_item_rec.item_id ;
             x_item_revision_id        :=  subj_item_rec.item_revision_id ;

             GetItemInfo( p_organization_id   => x_organization_id ,
                          p_item_id           => x_item_id ,
                          p_item_revision_id  => x_item_revision_id ,
                          x_item_name         => x_item_name ,
                          x_item_revision     => x_item_revision ,
                          x_item_revision_label => x_item_revision_label ) ;


        END LOOP ;

    END IF ;


END GetChangeItemSubjectInfo ;


-- Get Change Line Item Subject Info
PROCEDURE GetChangeLineItemSubjectInfo
(  p_change_id               IN  NUMBER
 , p_change_line_id          IN  NUMBER
 , x_organization_id         OUT NOCOPY NUMBER
 , x_item_id                 OUT NOCOPY NUMBER
 , x_item_name               OUT NOCOPY VARCHAR2
 , x_item_revision_id        OUT NOCOPY NUMBER
 , x_item_revision           OUT NOCOPY VARCHAR2
 , x_item_revision_label     OUT NOCOPY VARCHAR2
)
IS

    -- Need to modify
    CURSOR c_subj_item(p_change_id NUMBER, p_change_line_id NUMBER, p_entity_name VARCHAR2)
    IS
          -- SELECT TO_NUMBER(subject.pk2_value) organization_id
          --      , TO_NUMBER(subject.pk1_value) item_id
          --      , TO_NUMBER(subject.pk3_value) item_revision_id
          -- FROM   ENG_CHANGE_LINES subject
          --      , FND_OBJECTS          obj
          -- WHERE subject.pk1_value IS NOT NULL
          -- AND   subject.pk2_value IS NOT NULL
          -- AND   subject.object_id = obj.object_id
          -- AND   obj.obj_name IN ('EGO_ITEM', 'EGO_ITEM_REVISION')
          -- AND   subject.change_line_id = p_change_line_id ;

          SELECT TO_NUMBER(subject.pk2_value) organization_id
               , TO_NUMBER(subject.pk1_value) item_id
               , TO_NUMBER(subject.pk3_value) item_revision_id
          FROM   ENG_CHANGE_SUBJECTS subject
          WHERE subject.pk1_value IS NOT NULL
          AND   subject.pk2_value IS NOT NULL
          AND   subject.entity_name = p_entity_name
          AND   subject.change_line_id = p_change_line_id
          AND   subject.change_id = p_change_id ;

    l_item_rev_found BOOLEAN := FALSE ;


BEGIN

    FOR subj_item_rec IN c_subj_item(p_change_id => p_change_id ,
                                     p_change_line_id => p_change_line_id ,
                                     p_entity_name => 'EGO_ITEM_REVISION' )
    LOOP

         x_organization_id         :=  subj_item_rec.organization_id ;
         x_item_id                 :=  subj_item_rec.item_id ;
         x_item_revision_id        :=  subj_item_rec.item_revision_id ;


         GetItemInfo( p_organization_id   => x_organization_id ,
                      p_item_id           => x_item_id ,
                      p_item_revision_id  => x_item_revision_id ,
                      x_item_name         => x_item_name ,
                      x_item_revision     => x_item_revision ,
                      x_item_revision_label => x_item_revision_label ) ;


    END LOOP ;

    IF NOT l_item_rev_found
    THEN

        FOR subj_item_rec IN c_subj_item(p_change_id => p_change_id ,
                                         p_change_line_id => p_change_line_id ,
                                         p_entity_name => 'EGO_ITEM' )
        LOOP

             x_organization_id         :=  subj_item_rec.organization_id ;
             x_item_id                 :=  subj_item_rec.item_id ;
             x_item_revision_id        :=  subj_item_rec.item_revision_id ;

             GetItemInfo( p_organization_id   => x_organization_id ,
                          p_item_id           => x_item_id ,
                          p_item_revision_id  => x_item_revision_id ,
                          x_item_name         => x_item_name ,
                          x_item_revision     => x_item_revision ,
                          x_item_revision_label => x_item_revision_label ) ;


        END LOOP ;

    END IF ;


END GetChangeLineItemSubjectInfo ;

-- Get Lifecycle Phase Display Text
FUNCTION GetChangeLCPhaseDisplayText
(  p_change_id               IN NUMBER
 , p_status_type             IN NUMBER
 , p_status_code             IN NUMBER
 , p_phase_status_type       IN NUMBER
 , p_status_type_meaning     IN VARCHAR2
 , p_status_code_meaning     IN VARCHAR2
) RETURN VARCHAR2
IS
BEGIN

    -- Bug Fix 3463308
    -- Check if Change Object's STATUS_TYPE and STATUS_TYPE of
    -- Change Object's Phase(STATUS_CODE)
    -- If it's matched, then Change LC Phase Text
    -- is Phase's Meaning
    -- Otherwise "<Phase Meaning>(<STATUS_TYPE's meaning>)"
    -- e.g "Open(Implementaion in progress)"
    IF p_status_type <> p_phase_status_type
    THEN

        FND_MESSAGE.SET_NAME('ENG', 'ENG_LC_PHASE_STATUS_CONTEXT') ;
        FND_MESSAGE.SET_TOKEN('PHASE', p_status_code_meaning ) ;
        FND_MESSAGE.SET_TOKEN('STATUS', p_status_type_meaning) ;
        RETURN FND_MESSAGE.GET ;

    ELSE

        RETURN p_status_code_meaning ;

    END IF ;


END GetChangeLCPhaseDisplayText ;



-- Get Change Object Info
PROCEDURE GetChangeObjectInfo
(  p_change_id               IN  NUMBER
 , x_change_notice           OUT NOCOPY VARCHAR2
 , x_organization_id         OUT NOCOPY NUMBER
 , x_change_name             OUT NOCOPY VARCHAR2
 , x_description             OUT NOCOPY VARCHAR2
 , x_change_status           OUT NOCOPY VARCHAR2
 , x_change_lc_phase         OUT NOCOPY VARCHAR2
 , x_approval_status         OUT NOCOPY VARCHAR2
 , x_priority                OUT NOCOPY VARCHAR2
 , x_reason                  OUT NOCOPY VARCHAR2
 , x_change_managemtent_type OUT NOCOPY VARCHAR2
 , x_change_order_type       OUT NOCOPY VARCHAR2
 , x_eco_department          OUT NOCOPY VARCHAR2
 , x_assignee                OUT NOCOPY VARCHAR2
 , x_assignee_company        OUT NOCOPY VARCHAR2
)
IS


    l_assignee_id         NUMBER ;
    l_party_type          VARCHAR2(30) ;
    l_change_status_code  NUMBER ;
    l_change_status_type  NUMBER ;
    l_phase_status_type   NUMBER ;

BEGIN

    -- Modified for 115.10 Case Change
    SELECT eec.change_notice ,
           eec.organization_id ,
           eec.change_name ,
           eec.description ,
           ecs.meaning change_status ,
           eclf.status_name change_lc_phase,
           -- eec.status_type ,
           mlu.meaning  approval_status ,
           -- eec.approval_status_type ,
           -- eec.approval_date ,
           -- eec.approval_list_id ,
           eec.priority_code priority ,
           -- priority.description priority,
           eec.reason_code reason,
           -- reason.description reason ,
           ecmt_tl.type_name change_managemtent_type ,
           --  eec.change_mgmt_type_code ,
           ecot.type_name change_order_type ,
           -- eec.change_order_type_id ,
           -- ecot.description change_order_type_description,
           hou.name eco_department ,
           -- eec.responsible_organization_id
           eec.assignee_id ,
           eec.status_type ,
           eec.status_code ,
           eclf.status_type phase_status_type
      INTO x_change_notice
         , x_organization_id
         , x_change_name
         , x_description
         , x_change_status
         , x_change_lc_phase
         , x_approval_status
         , x_priority
         , x_reason
         , x_change_managemtent_type
         , x_change_order_type
         , x_eco_department
         , l_assignee_id
         , l_change_status_type
         , l_change_status_code
         , l_phase_status_type
      FROM ENG_CHANGE_ORDER_TYPES_TL  ecot,
           -- ENG_CHANGE_PRIORITIES      priority,
           -- ENG_CHANGE_REASONS         reason,
           MFG_LOOKUPS                ecs,
           ENG_CHANGE_STATUSES_VL     eclf,
           MFG_LOOKUPS                mlu,
           HR_ORGANIZATION_UNITS      hou,
           ENG_CHANGE_ORDER_TYPES     ecmt,
           ENG_CHANGE_ORDER_TYPES_TL  ecmt_tl,
           -- ENG_CHANGE_ORDER_TYPES_VL ecmt,
           ENG_ENGINEERING_CHANGES    eec
     WHERE eec.change_order_type_id = ecot.change_order_type_id
     AND   ecot.language = userenv('LANG')
     -- AND   eec.priority_code   = priority.eng_change_priority_code(+)
     -- AND   priority.organization_id(+)= -1
     -- AND   eec.reason_code  =  reason.eng_change_reason_code(+)
     -- AND   reason.organization_id(+) = -1
     AND   eec.responsible_organization_id = hou.organization_id(+)
     AND   ecs.lookup_code  (+)=  eec.status_type
     AND   ecs.lookup_type   (+)= 'ECG_ECN_STATUS'
     AND   eclf.status_code    =  eec.status_code
     AND   mlu.lookup_code   (+)=  eec.approval_status_type
     AND   mlu.lookup_type   (+)= 'ENG_ECN_APPROVAL_STATUS'
     AND   ecmt_tl.language = userenv('LANG')
     AND   ecmt_tl.change_order_type_id = ecmt.change_order_type_id
     AND   ecmt.type_classification = 'CATEGORY'
     AND   ecmt.change_mgmt_type_code = eec.change_mgmt_type_code
     AND   eec.change_id       = p_change_id ;


     /* Comment Out: THIS SQL modified by Sachin/Mani
     SELECT eec.change_notice ,
                eec.organization_id ,
                eec.change_name ,
                eec.description ,
                ecs.status_name  change_status ,
                -- eec.status_type ,
                mlu.meaning  approval_status ,
                -- eec.approval_status_type ,
                -- eec.approval_date ,
                -- eec.approval_list_id ,
                eec.priority_code priority ,
                -- priority.description priority,
                eec.reason_code reason,
                -- reason.description reason ,
                ecmt.name change_managemtent_type ,
                --  eec.change_mgmt_type_code ,
                ecot.change_order_type change_order_type ,
                -- eec.change_order_type_id ,
                -- ecot.description change_order_type_description,
                hou.name eco_department ,
                -- eec.responsible_organization_id
                eec.assignee_id
           INTO x_change_notice
              , x_organization_id
              , x_change_name
              , x_description
              , x_change_status
              , x_approval_status
              , x_priority
              , x_reason
              , x_change_managemtent_type
              , x_change_order_type
              , x_eco_department
              , l_assignee_id
           FROM ENG_CHANGE_ORDER_TYPES     ecot,
                -- ENG_CHANGE_PRIORITIES      priority,
                -- ENG_CHANGE_REASONS         reason,
                ENG_CHANGE_STATUSES_TL     ecs,
                MFG_LOOKUPS                mlu,
                HR_ORGANIZATION_UNITS      hou,
                ENG_CHANGE_MGMT_TYPES_TL   ecmt,
                ENG_ENGINEERING_CHANGES    eec
          WHERE eec.change_order_type_id = ecot.change_order_type_id
          -- AND   eec.priority_code   = priority.eng_change_priority_code(+)
          -- AND   priority.organization_id(+)= -1
          -- AND   eec.reason_code  =  reason.eng_change_reason_code(+)
          -- AND   reason.organization_id(+) = -1
          AND   eec.responsible_organization_id = hou.organization_id(+)
          AND   ecs.status_code    =  eec.status_type
          AND   ecs.language = userenv('LANG')
          AND   mlu.lookup_code   (+)=  eec.approval_status_type
          AND   mlu.lookup_type   (+)= 'ENG_ECN_APPROVAL_STATUS'
          AND   ecmt.language       = userenv('LANG')
          AND   ecmt.change_mgmt_type_code = eec.change_mgmt_type_code
          AND   eec.change_id       = p_change_id ;
     */



     x_change_lc_phase := GetChangeLCPhaseDisplayText
                          (  p_change_id             => p_change_id
                           , p_status_type           => l_change_status_type
                           , p_status_code           => l_change_status_code
                           , p_phase_status_type     => l_phase_status_type
                           , p_status_type_meaning   => x_change_status
                           , p_status_code_meaning   => x_change_lc_phase
                          ) ;


     IF l_assignee_id IS NOT NULL THEN

        GetPartyInfo
        ( p_party_id          => l_assignee_id
        , x_party_name        => x_assignee
        , x_party_company     => x_assignee_company
        ) ;

     END IF ; -- assignee is not null


END GetChangeObjectInfo ;


-- Get Change Line Object Info
PROCEDURE GetChangeLineObjectInfo
(  p_change_line_id        IN  NUMBER
 , x_change_id             OUT NOCOPY NUMBER
 , x_line_sequence_number  OUT NOCOPY NUMBER
 , x_line_name             OUT NOCOPY VARCHAR2
 , x_line_description      OUT NOCOPY VARCHAR2
 , x_line_status           OUT NOCOPY VARCHAR2
 , x_line_approval_status  OUT NOCOPY VARCHAR2
 , x_line_assignee         OUT NOCOPY VARCHAR2
 , x_line_assignee_company OUT NOCOPY VARCHAR2
)
IS


    l_assignee_id      NUMBER ;
    l_party_type       VARCHAR2(30) ;
    l_route_type_code  VARCHAR2(30) ;
    l_list_dist_status VARCHAR2(80) ;

BEGIN

    SELECT ecl.change_id ,
           ecl.sequence_number ,
           ecl.name ,
           ecl.description ,
           flu.meaning line_status ,
           mlu.meaning line_approval_status ,
           ecl.assignee_id,
           dist_stat_flu.meaning dist_line_status ,
           line_wf.route_type_code
     INTO  x_change_id
         , x_line_sequence_number
         , x_line_name
         , x_line_description
         , x_line_status
         , x_line_approval_status
         , l_assignee_id
         , l_list_dist_status
         , l_route_type_code
      FROM FND_LOOKUPS          dist_stat_flu,
           FND_LOOKUPS          flu,
           MFG_LOOKUPS          mlu,
           ENG_CHANGE_ROUTES    line_wf,
           ENG_CHANGE_LINES_VL  ecl
     WHERE line_wf.route_id (+)=  ecl.route_id
     AND   dist_stat_flu.lookup_code  (+)=  ecl.status_code
     AND   dist_stat_flu.lookup_type  (+)= 'ENG_DIST_LINE_STATUSES'
     AND   flu.lookup_code  (+)=  ecl.status_code
     AND   flu.lookup_type  (+)= 'ENG_CHANGE_LINE_STATUSES'
     AND   mlu.lookup_code  (+)=  ecl.approval_status_type
     AND   mlu.lookup_type  (+)= 'ENG_ECN_APPROVAL_STATUS'
     AND   ecl.change_line_id = p_change_line_id ;


     -- R12B for Distribution Line Enh
     -- If the Line is attached to Line Workflow
     -- Line Status Display Name should be
     -- the value defined in lookup type: ENG_DIST_LINE_STATUSES
     IF l_route_type_code = Eng_Workflow_Util.G_LINE_RT_TYPE_NOTIFICATION
     THEN

          x_line_status := l_list_dist_status;

     END IF ;


     IF l_assignee_id IS NOT NULL THEN

        GetPartyInfo
        ( p_party_id          => l_assignee_id
        , x_party_name        => x_line_assignee
        , x_party_company     => x_line_assignee_company
        ) ;

     END IF ; -- assignee is not null

END GetChangeLineObjectInfo ;



-- Get Change Line Object Info
PROCEDURE GetDocumentLCInfo
(  p_change_id                 IN  NUMBER
 , x_document_id               OUT NOCOPY NUMBER
 , x_document_revision_id      OUT NOCOPY NUMBER
 , x_document_number           OUT NOCOPY VARCHAR2
 , x_document_revision         OUT NOCOPY VARCHAR2
 , x_documnet_name             OUT NOCOPY VARCHAR2
 , x_document_detail_page_url  OUT NOCOPY VARCHAR2
)
IS


BEGIN

     ENG_DOCUMENT_UTIL.Get_Document_Revision_Id
     ( p_change_id             =>  p_change_id
     , x_document_id           =>  x_document_id
     , x_document_revision_id  =>  x_document_revision_id
     ) ;


     IF (x_document_revision_id IS NOT NULL )
     THEN
         -- Get Dom Document Revision Object Info
         ENG_DOCUMENT_UTIL.Get_Document_Rev_Info
         ( p_document_revision_id     => x_document_revision_id
         , x_document_id              => x_document_id
         , x_document_number          => x_document_number
         , x_document_revision        => x_document_revision
         , x_documnet_name            => x_documnet_name
         , x_document_detail_page_url => x_document_detail_page_url
         ) ;

     END IF ;


END GetDocumentLCInfo ;


-- Get Workflow Change Object Info
PROCEDURE GetWFChangeObjectInfo
(  p_item_type               IN  VARCHAR2
 , p_item_key                IN  VARCHAR2
 , x_change_name             OUT NOCOPY VARCHAR2
 , x_description             OUT NOCOPY VARCHAR2
 , x_change_status           OUT NOCOPY VARCHAR2
 , x_approval_status         OUT NOCOPY VARCHAR2
 , x_priority                OUT NOCOPY VARCHAR2
 , x_reason                  OUT NOCOPY VARCHAR2
 , x_change_managemtent_type OUT NOCOPY VARCHAR2
 , x_change_order_type       OUT NOCOPY VARCHAR2
 , x_eco_department          OUT NOCOPY VARCHAR2
 , x_assignee                OUT NOCOPY VARCHAR2
 , x_assignee_company        OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Change Object Name
    x_change_name := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'CHANGE_NAME'
                  );

    -- Change Management Type
    x_change_managemtent_type := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'CHANGE_MANAGEMENT_TYPE'
                  );


    -- Description
    x_description := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'DESCRIPTION'
                  );

    -- Status
    x_change_status := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'STATUS'
                  );



    -- Approval Status
    x_approval_status := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'APPROVAL_STATUS'
                  );


    -- Assignee Name
    x_assignee := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'ASSIGNEE_NAME'
                  );


    -- Assignee Company
    x_assignee_company := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'ASSIGNEE_COMPANY'
                  );

    -- Priority
    x_priority := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'PRIORITY'
                  );


    -- Reason
    x_reason := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'REASON'
                  );


END GetWFChangeObjectInfo ;


-- Get WF Change Line Object Info
PROCEDURE GetWFChangeLineObjectInfo
(  p_item_type             IN  VARCHAR2
 , p_item_key              IN  VARCHAR2
 , x_line_sequence_number  OUT NOCOPY NUMBER
 , x_line_name             OUT NOCOPY VARCHAR2
 , x_line_description      OUT NOCOPY VARCHAR2
 , x_line_status           OUT NOCOPY VARCHAR2
 , x_line_assignee         OUT NOCOPY VARCHAR2
 , x_line_assignee_company OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Line Sequence Number
    x_line_sequence_number := WF_ENGINE.GetItemAttrNumber
                  (  p_item_type
                   , p_item_key
                   , 'LINE_SEQUENCE_NUMBER'
                  );

    -- Line Object Name
    x_line_name := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'LINE_NAME'
                  );

    -- Line Description
    x_line_description := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'LINE_DESCRIPTION'
                  );

    -- Line Status
    x_line_status := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'LINE_STATUS'
                  );

    -- Line Assignee Name
    x_line_assignee := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'LINE_ASSIGNEE_NAME'
                  );

    -- Line Assignee Company
    x_line_assignee_company := WF_ENGINE.GetItemAttrText
                  (  p_item_type
                   , p_item_key
                   , 'LINE_ASSIGNEE_COMPANY'
                  );


END  GetWFChangeLineObjectInfo ;

PROCEDURE GetActionTypeCode
(  p_action_id                 IN  NUMBER
 , x_action_type_code          OUT NOCOPY VARCHAR2
)
IS
    CURSOR c_action(p_action_id  NUMBER)
    IS
          SELECT ecav.ACTION_TYPE
          FROM   ENG_CHANGE_ACTIONS ecav
          WHERE  ecav.action_id = p_action_id ;
BEGIN


    FOR l_action_rec IN c_action (p_action_id)
    LOOP

        x_action_type_code := l_action_rec.ACTION_TYPE;

    END LOOP ;


END GetActionTypeCode ;



PROCEDURE GetActionInfo
(  p_action_id                 IN  NUMBER
 , x_action_desc               OUT NOCOPY VARCHAR2
 , x_action_party_id           OUT NOCOPY VARCHAR2
 , x_action_party_name         OUT NOCOPY VARCHAR2
 , x_action_party_company_name OUT NOCOPY VARCHAR2
)
IS

    -- Need to modify
    CURSOR c_action(p_action_id  NUMBER)
    IS
          SELECT ecav.action_id
                --  ,ecav.ACTION_TYPE
               , ecav.created_by    created_by
               , ecav.creation_date creation_date
               , ecav.description   description
               , EgoPeople.person_name     person_name
               , EgoPeople.company_name     company_name
          FROM   ENG_CHANGE_ACTIONS_VL ecav
               , EGO_PEOPLE_V EgoPeople
          WHERE EgoPeople.user_id = ecav.created_by
          AND   ecav.action_id = p_action_id ;


BEGIN


    FOR l_action_rec IN c_action (p_action_id)
    LOOP

        x_action_desc               := l_action_rec.description ;
        x_action_party_id           := l_action_rec.created_by ;
        x_action_party_name         := l_action_rec.person_name ;
        x_action_party_company_name := l_action_rec.company_name ;

    END LOOP ;


END GetActionInfo ;

PROCEDURE GetRouteStepInfo
(  p_route_step_id             IN  NUMBER
 , x_step_seq_num              OUT NOCOPY NUMBER
 , x_required_date             OUT NOCOPY DATE
 , x_condition_type            OUT NOCOPY VARCHAR2
 , x_step_instrunction         OUT NOCOPY VARCHAR2
)
IS

    CURSOR c_step(p_route_step_id  NUMBER)
    IS
        SELECT  Step.step_seq_num
              , TRUNC(Step.required_date)  required_date
              , ConditionTypeLookup.meaning condition_type
              , Step.instruction
        FROM FND_LOOKUPS               ConditionTypeLookup ,
             ENG_CHANGE_ROUTE_STEPS_VL Step
        WHERE ConditionTypeLookup.lookup_code = Step.condition_type_code
        AND   ConditionTypeLookup.lookup_type = 'ENG_CHANGE_ROUTE_CONDITIONS'
        AND   Step.step_id = p_route_step_id ;


BEGIN


    FOR l_step_rec IN c_step (p_route_step_id)
    LOOP

        x_step_seq_num         := l_step_rec.step_seq_num ;
        x_required_date        := l_step_rec.required_date ;
        x_condition_type       := l_step_rec.condition_type ;
        x_step_instrunction    := l_step_rec.instruction ;

    END LOOP ;

END GetRouteStepInfo ;


/*************************************************
--  in 115.10, Workflow Routing will not update
-- OBSOLETE
-- PROCEDURE SetChangeApprovalStatus
(   x_return_status        OUT NOCOPY VARCHAR2
 ,  x_msg_count            OUT NOCOPY NUMBER
 ,  x_msg_data             OUT NOCOPY VARCHAR2
 ,  p_item_type            IN  VARCHAR2 := NULL
 ,  p_item_key             IN  VARCHAR2 := NULL
 ,  p_change_id            IN  NUMBER
 ,  p_change_line_id       IN  NUMBER   := NULL
 ,  p_sync_lines           IN  NUMBER   := NULL -- Yes: greater than 0
 ,  p_wf_user_id           IN  NUMBER
 ,  p_new_appr_status_type IN  NUMBER
)
IS

    l_api_name         CONSTANT VARCHAR2(30) := 'SetChangeApprovalStatus';

    l_user_id               NUMBER;
    l_login_id              NUMBER;
    l_request_id            NUMBER;
    l_approval_status       VARCHAR2(80) ;

    l_enable_rev_items_flag VARCHAR2(1) ;
    l_enable_tasks_flag     VARCHAR2(1) ;


    l_header BOOLEAN := TRUE ;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_user_id := p_wf_user_id ;

    SELECT meaning
    INTO   l_approval_status
    FROM   MFG_LOOKUPS
    WHERE  lookup_code   =  p_new_appr_status_type
    AND    lookup_type   = 'ENG_ECN_APPROVAL_STATUS' ;

    -- Comment Out
    -- Due to some patch dependencies issue
    --
    -- Call Eng ECO/Change Header Util
    -- ENG_Eco_Util.Perform_Approval_Status_Change
    -- (   p_change_id            => p_change_id
    --  ,  p_user_id              => p_wf_user_id
    --  ,  p_approval_status_type => p_new_appr_status_type
    --  ,  p_caller_type          => 'WF'
    --  ,  x_return_status        => x_return_status
    --  ,  x_err_text             => x_msg_data
    -- );
    --

    IF p_change_line_id IS NOT NULL AND p_change_line_id > 0
    THEN

        l_header := FALSE ;

    END IF ;


    -- The following logic is copied
    -- from ENG_Eco_Util.Perform_Approval_Status_Change
    -- Approve Change

    -- For Change Object Header
    IF l_header THEN

        IF p_new_appr_status_type = 5 THEN

             -- Approve ECO/Change Object
             UPDATE eng_engineering_changes
                SET approval_status_type = p_new_appr_status_type ,
                    approval_date = sysdate ,
                    request_id = l_request_id ,
                    last_update_date = SYSDATE ,
                    last_updated_by = l_user_id ,
                    last_update_login = l_login_id
              WHERE change_id = p_change_id ;


              GetEnableChildFlags
              (  p_change_id            => p_change_id
               , x_enable_rev_items_flag => l_enable_rev_items_flag
               , x_enable_tasks_flag     => l_enable_tasks_flag
              ) ;


             --
             -- If this change object category enables Rev Items Child
             -- we will update status to Scheduled automatically
             IF l_enable_rev_items_flag = 'Y'
             THEN

                 -- Set Open Rev Item to Scheduled
                 UPDATE eng_revised_items
                    SET status_type = 4 ,  -- Set Rev Item Status: Scheduled
                        request_id = l_request_id ,
                        last_update_date = SYSDATE ,
                        last_updated_by = l_user_id ,
                        last_update_login = l_login_id
                  WHERE change_id = p_change_id
                    AND status_type = 1;  -- Rev Item Status: Open


                 -- If ECO is Open, Set Status to Scheduled (bug 2307416)
                 UPDATE eng_engineering_changes
                    SET status_type = 4 ,    -- Scheduled
                        request_id = l_request_id ,
                        last_update_date = SYSDATE ,
                        last_updated_by = l_user_id ,
                        last_update_login = l_login_id
                  WHERE change_id = p_change_id
                    AND status_type = 1;   -- Open


             END IF ;

         -- In case we need paticular business logic, put here
         -- Reject Change, Processing error or Timeout
         -- ELSIF p_new_appr_status_type IN (4, 7, 8)  THEN


             -- Reject ECO/Change Object or set Processing Error
             -- UPDATE eng_engineering_changes
                -- SET approval_status_type = p_new_appr_status_type ,
                --     approval_date = NULL ,
                --     request_id = l_request_id ,
                --     last_update_date = SYSDATE ,
                --     last_updated_by = l_user_id ,
                --     last_update_login = l_login_id
             --  WHERE change_id = p_change_id ;
         --

         -- Others
        ELSE

             -- Update Approval Status
             UPDATE eng_engineering_changes
                SET approval_status_type = p_new_appr_status_type,
                    approval_date = NULL ,
                    approval_request_date = DECODE(p_new_appr_status_type
                                                 , Eng_Workflow_Util.G_REQUESTED
                                                 , sysdate
                                                 , approval_request_date) ,
                    request_id = l_request_id ,
                    last_update_date = SYSDATE ,
                    last_updated_by = l_user_id ,
                    last_update_login = l_login_id
              WHERE change_id = p_change_id ;


        END IF ;


        --
        -- Set New Approval Status to Item Attr
        --
        IF p_item_type IS NOT NULL AND p_item_key IS NOT NULL
        THEN

            WF_ENGINE.SetItemAttrText( p_item_type
                                     , p_item_key
                                     , 'APPROVAL_STATUS'
                                     , l_approval_status );

        END IF ;


        IF p_sync_lines > 0 THEN

            -- Sync child line approval status
            Eng_Workflow_Util.SyncLineApprovalStatus
           (  x_return_status        => x_return_status
           ,  x_msg_count            => x_msg_count
           ,  x_msg_data             => x_msg_data
           ,  p_change_id            => p_change_id
           ,  p_wf_user_id           => p_wf_user_id
           ,  p_header_appr_status_type => p_new_appr_status_type
           ) ;


        END IF ;

    -- For Change Object Line
    ELSE

        IF p_new_appr_status_type = 5 THEN

             -- Approve Change Line
             UPDATE eng_change_lines
                SET approval_status_type = p_new_appr_status_type ,
                    approval_date = sysdate ,
                    request_id = l_request_id ,
                    last_update_date = SYSDATE ,
                    last_updated_by = l_user_id ,
                    last_update_login = l_login_id
              WHERE change_line_id = p_change_line_id ;


         -- In case we need paticular business logic, put here
         -- Reject Change, Processing error or Timeout
         -- ELSIF p_new_appr_status_type IN (4, 7, 8)  THEN


             -- Reject ECO/Change Object or set Processing Error
             -- UPDATE eng_change_lines
             --    SET approval_status_type = p_new_appr_status_type ,
             --        approval_date = NULL ,
             --        request_id = l_request_id ,
             --        last_update_date = SYSDATE ,
             --        last_updated_by = l_user_id ,
             --        last_update_login = l_login_id
             --  WHERE change_line_id = p_change_line_id ;
         --

         -- Others
        ELSE

             -- Update Approval Status
             UPDATE eng_change_lines
                SET approval_status_type = p_new_appr_status_type,
                    approval_date = NULL ,
                    approval_request_date = DECODE(p_new_appr_status_type
                                                 , Eng_Workflow_Util.G_REQUESTED
                                                 , sysdate
                                                 , approval_request_date) ,
                    request_id = l_request_id ,
                    last_update_date = SYSDATE ,
                    last_updated_by = l_user_id ,
                    last_update_login = l_login_id
              WHERE change_line_id = p_change_line_id ;


        END IF ;

        --
        -- Set New Approval Status to Item Attr
        --
        IF p_item_type IS NOT NULL AND p_item_key IS NOT NULL
        THEN

            WF_ENGINE.SetItemAttrText( p_item_type
                                     , p_item_key
                                     , 'LINE_APPROVAL_STATUS'
                                     , l_approval_status );

        END IF ;



    END IF ; -- Header or Line

EXCEPTION
    WHEN OTHERS THEN

IF g_debug_flag THEN
   Write_Debug('When Others in SetChangeApprovalStatus ' || SQLERRM );
END IF ;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;


END SetChangeApprovalStatus ;
*************************************************/


/*************************************************
-- OBSOLETE in 115.10
PROCEDURE SyncLineApprovalStatus
(   x_return_status           OUT NOCOPY VARCHAR2
 ,  x_msg_count               OUT NOCOPY NUMBER
 ,  x_msg_data                OUT NOCOPY VARCHAR2
 ,  p_change_id               IN  NUMBER
 ,  p_wf_user_id              IN  NUMBER
 ,  p_header_appr_status_type IN  NUMBER
)
IS

    l_api_name         CONSTANT VARCHAR2(30) := 'SyncLineApprovalStatus';

    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000) ;
    l_return_status     VARCHAR2(1) ;

    l_updatable_flag    BOOLEAN;

    --
    -- Select lines those approval status should be syncronized with Header
    -- Line Approval Status: not approved or requested
    --
    CURSOR  c_lines  (p_change_id NUMBER)
    IS
        SELECT ecl.change_line_id
          FROM ENG_CHANGE_LINES  ecl
             -- , ENG_CHANGE_ROUTES ecr
         WHERE  ( ecl.approval_status_type <> Eng_Workflow_Util.G_APPROVED
                 AND ecl.approval_status_type <> Eng_Workflow_Util.G_REQUESTED )
           -- AND  ( ecl.status_code <> Eng_Workflow_Util.G_CL_COMPLETED
           --    AND ecl.status_code <> Eng_Workflow_Util.G_CL_CANCELLED )
           AND ecl.sequence_number <> -1
           AND ecl.change_type_id <> -1
           -- AND ecl.parent_line_id IS NULL
           -- AND ecr.status_code = Eng_Workflow_Util.G_RT_NOT_STARTED
           -- AND ecl.route_id  = ecr.route_id
           AND ecl.change_id = p_change_id ;

BEGIN

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get Lines for this Header
    FOR l_line_rec IN c_lines (p_change_id)
    LOOP

        -- Initializse updateable flag for this line approval status
        l_updatable_flag := TRUE ;

        --
        -- Currently there is no paticular condition
        --

        IF l_updatable_flag THEN

            -- Set Approval Status
            Eng_Workflow_Util.SetChangeApprovalStatus
            (  x_return_status        => l_return_status
            ,  x_msg_count            => l_msg_count
            ,  x_msg_data             => l_msg_data
            ,  p_item_type            => null
            ,  p_item_key             => null
            ,  p_change_id            => p_change_id
            ,  p_change_line_id       => l_line_rec.change_line_id
            ,  p_wf_user_id           => p_wf_user_id
            ,  p_new_appr_status_type => p_header_appr_status_type
            ) ;

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN

                 x_return_status := l_return_status ;

            END IF ;

        END IF ;

    END LOOP ;


EXCEPTION
    WHEN OTHERS THEN

IF g_debug_flag THEN
   Write_Debug('When Others in SyncLineApprovalStatus ' || SQLERRM );
END IF ;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

END SyncLineApprovalStatus ;
*************************************************/


PROCEDURE SetRouteStatus
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
 ,  p_route_id          IN  NUMBER
 ,  p_new_status_code   IN  VARCHAR2
 ,  p_init_route        IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_change_id         IN  NUMBER   := NULL
 ,  p_change_line_id    IN  NUMBER   := NULL
)
IS

    l_set_start_date_flag NUMBER := 0 ;
    l_set_end_date_flag   NUMBER := 0 ;
    l_set_rev             NUMBER := 0 ;
    l_change_revision     VARCHAR2(10) ;

    -- R12B
    l_dist_line_ntf_wf_flag    BOOLEAN ;
    l_dist_line_status_code    VARCHAR2(30) ;

    l_line_stat_chg_act_id     NUMBER ;
    l_line_stat_chg_wf_key     VARCHAR2(240) ;
    l_return_status            VARCHAR2(1);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(3000);

BEGIN



IF g_debug_flag THEN
   Write_Debug('Set Route Status . . .');
END IF ;


    IF p_new_status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
    THEN

        l_set_start_date_flag := 1 ;

    ELSIF p_new_status_code IN ( Eng_Workflow_Util.G_RT_REJECTED
                               , Eng_Workflow_Util.G_RT_APPROVED
                               , Eng_Workflow_Util.G_RT_COMPLETED
                               , Eng_Workflow_Util.G_RT_TIME_OUT
                               , Eng_Workflow_Util.G_RT_ABORTED )
    THEN

        l_set_end_date_flag := 1 ;

    END IF ;


    -- Check if this call is to initialize Route Process
    IF FND_API.To_Boolean( p_init_route )
    AND p_change_id IS NOT NULL
    AND p_change_id > 0
    THEN
        -- Get Current Change Revision
        l_set_rev := 1 ;
        GetChangeCurrentRev( p_change_id => p_change_id
                           , x_revision => l_change_revision  ) ;
IF g_debug_flag THEN
   Write_Debug('Got current revision: ' || l_change_revision );
END IF ;


    END IF;

IF g_debug_flag THEN
   Write_Debug('Updating Route Table ... Route Id: ' || to_Char(p_route_id) );
END IF ;


    update ENG_CHANGE_ROUTES set
      OWNER_ID = DECODE(l_set_start_date_flag, 1, p_wf_user_id, OWNER_ID) ,
      WF_ITEM_TYPE = p_item_type ,
      WF_ITEM_KEY = p_item_key,
      STATUS_CODE = p_new_status_code ,
      ROUTE_START_DATE = DECODE(l_set_start_date_flag, 1, SYSDATE, ROUTE_START_DATE),
      ROUTE_END_DATE = DECODE(l_set_end_date_flag, 1, SYSDATE, ROUTE_END_DATE),
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = p_wf_user_id,
      LAST_UPDATE_LOGIN = '',
      CHANGE_REVISION = DECODE(l_set_rev, 1, l_change_revision, CHANGE_REVISION)
    where ROUTE_ID = p_route_id ;

    if (sql%notfound) then
        raise no_data_found;
    end if;


    -- R12B
    -- Check If this is Line Notification Workflow Routing
    -- Need to sync up with Line Status automatically
    --
    l_dist_line_ntf_wf_flag := FALSE ;
    IF ( Eng_Workflow_Util.Is_Line_Ntf_WF(p_route_id => p_route_id))
    THEN

IF g_debug_flag THEN
   Write_Debug('Set Route Status for Line Notification Workflow Routing  Flag. . .') ;
END IF ;
        l_dist_line_ntf_wf_flag := TRUE ;

    END IF ;


    IF (l_dist_line_ntf_wf_flag) THEN

        l_dist_line_status_code := Eng_Workflow_Util.ConvNtfWFStatToDistLNStat
                          ( p_route_status_code =>  p_new_status_code
                          , p_convert_type      =>  'WF_PROCESS' ) ;


        -- 1. Update Line Status
IF g_debug_flag THEN
   Write_Debug('Updating Line Status : ' || l_dist_line_status_code || ' for Line ' || to_char(p_change_line_id) );
END IF ;


        IF (p_change_line_id IS NOT NULL AND p_change_line_id > 0 )
        THEN
            update ENG_CHANGE_LINES set
              STATUS_CODE = l_dist_line_status_code ,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATED_BY = p_wf_user_id,
              LAST_UPDATE_LOGIN = ''
            where ROUTE_ID = p_route_id
            and   CHANGE_LINE_ID = p_change_line_id;

            if (sql%notfound) then
              raise no_data_found;
            end if;


            -- 2. Create Line Status Action Log
IF g_debug_flag THEN
   Write_Debug('Create Line Status Action Log. . ..  '  );
END IF ;

            ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
            (  p_api_version           => 1.0
             , x_return_status         => l_return_status
             , x_msg_count             => l_msg_count
             , x_msg_data              => l_msg_data
             , p_init_msg_list         => FND_API.G_FALSE
             , p_commit                => FND_API.G_FALSE
             , p_action_type           => Eng_Workflow_Util.G_LINE_ACT_CHG_STATUS
             , p_object_name           => Eng_Workflow_Util.G_ENG_CHANGE_LINE
             , p_object_id1            => p_change_id
             , p_object_id2            => p_change_line_id
             , p_object_id3            => NULL
             , p_object_id4            => NULL
             , p_object_id5            => NULL
             , p_parent_action_id      => NULL
             , p_action_date           => SYSDATE
             , p_change_description    => NULL
             , p_user_id               => p_wf_user_id
             , p_api_caller            => G_WF_CALL
             , p_status_code           => l_dist_line_status_code
             , x_change_action_id      => l_line_stat_chg_act_id
            );


IF g_debug_flag THEN
   Write_Debug('After Creating Line Status Action Log: return status ' ||  l_return_status
                                                                       || '- Act Id:' || to_char(l_line_stat_chg_act_id) );
END IF ;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF ;


            -- 3. Start Line Status Change Workflow
IF g_debug_flag THEN
   Write_Debug('Start Line Status Change Workflow. . ..  '  );
END IF ;

            -- Create and Start Line Status Change Workflow to send Resp FYI ntf
            Eng_Workflow_Util.StartWorkflow
            (   p_api_version       =>       1.0
             ,  p_init_msg_list     =>       FND_API.G_FALSE
             ,  p_commit            =>       FND_API.G_FALSE
             ,  p_validation_level  =>       FND_API.G_VALID_LEVEL_FULL
             ,  x_return_status     =>       l_return_status
             ,  x_msg_count         =>       l_msg_count
             ,  x_msg_data          =>       l_msg_data
             ,  p_item_type         =>       Eng_Workflow_Util.G_CHANGE_LINE_ACTION_ITEM_TYPE
             ,  x_item_key          =>       l_line_stat_chg_wf_key
             ,  p_process_name      =>       Eng_Workflow_Util.G_STATUS_CHANGE_PROC
             ,  p_change_id         =>       p_change_id
             ,  p_change_line_id    =>       p_change_line_id
             ,  p_wf_user_id        =>       p_wf_user_id
             ,  p_host_url          =>       NULL
             ,  p_action_id         =>       l_line_stat_chg_act_id
             ,  p_route_id          =>       0
             ,  p_route_step_id     =>       0
             ,  p_debug             =>       FND_API.G_FALSE
             ,  p_output_dir        =>       NULL
             ,  p_debug_filename    =>       'Eng_LineStatChg_Start.log'
            ) ;

IF g_debug_flag THEN
   Write_Debug('Starting Line Status Change Workflow: return status ' ||  l_return_status
                                                                      || '- Item Key:' || l_line_stat_chg_wf_key);
END IF ;


IF g_debug_flag THEN
   Write_Debug('After Starting Line Status Change Workflow. . ..  '  );
END IF ;
       END IF ; -- Line Id is not null


    END IF ; -- l_dist_line_ntf_wf_flag is TRUE



END SetRouteStatus ;


PROCEDURE SetRouteStepStatus
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
 ,  p_route_id          IN  NUMBER
 ,  p_route_step_id     IN  NUMBER
 ,  p_new_status_code   IN  VARCHAR2
)
IS

    l_set_start_date_flag NUMBER ;
    l_set_end_date_flag   NUMBER ;
    l_required_date       DATE ;

    -- R12B
    l_default_assignee_resp  VARCHAR2(30) ;

BEGIN

    -- Init Vars
    l_set_start_date_flag := 0 ;
    l_set_end_date_flag   := 0 ;


    IF p_new_status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
    THEN

        l_set_start_date_flag := 1 ;
        l_required_date := GetStepRequiredDate(p_step_id => p_route_step_id) ;

    ELSIF p_new_status_code IN ( Eng_Workflow_Util.G_RT_REJECTED
                               , Eng_Workflow_Util.G_RT_APPROVED
                               , Eng_Workflow_Util.G_RT_COMPLETED
                               , Eng_Workflow_Util.G_RT_TIME_OUT)
    THEN

        l_set_end_date_flag := 1 ;

    END IF ;

    update ENG_CHANGE_ROUTE_STEPS set
      WF_ITEM_TYPE = p_item_type ,
      WF_ITEM_KEY = p_item_key,
      STEP_STATUS_CODE = p_new_status_code,
      STEP_START_DATE = DECODE(l_set_start_date_flag, 1, SYSDATE,STEP_START_DATE),
      STEP_END_DATE = DECODE(l_set_end_date_flag, 1, SYSDATE,STEP_END_DATE),
      REQUIRED_DATE = DECODE(l_set_start_date_flag, 1, l_required_date, REQUIRED_DATE) ,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = p_wf_user_id,
      LAST_UPDATE_LOGIN = ''
    where STEP_ID = p_route_step_id ;

    if (sql%notfound) then
        raise no_data_found;
    end if;


    IF p_new_status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
    THEN

          -- R12B
          -- Check If this is Line Notification Workflow Routing
          -- Need to update assignee response code 'Not Received'
          --
          IF ( p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE
               AND Eng_Workflow_Util.Is_Line_Ntf_WF(p_route_id => p_route_id)
             )
          THEN

IF g_debug_flag THEN
    Write_Debug('Calling GetStepDefaultRespCode  ' ) ;
END IF ;

              Eng_Workflow_Util.GetStepDefaultRespCode
              (  p_step_id  => p_route_step_id
              ,  x_default_resp_code  => l_default_assignee_resp
              ) ;

IF g_debug_flag THEN
    Write_Debug('Get Route Assignee Response : ' || l_default_assignee_resp ) ;
END IF ;

          ELSE

              l_default_assignee_resp := Eng_Workflow_Util.G_RT_SUBMITTED ;

          END IF ;



         update ENG_CHANGE_ROUTE_PEOPLE set
           response_code = l_default_assignee_resp,
           last_update_date = SYSDATE ,
           last_updated_by = p_wf_user_id,
           last_update_login = ''
         where step_id = p_route_step_id
         and   assignee_id <> -1
         and   response_code IS NULL ;

    ELSIF p_new_status_code IN ( Eng_Workflow_Util.G_RT_REJECTED
                               , Eng_Workflow_Util.G_RT_APPROVED
                               , Eng_Workflow_Util.G_RT_COMPLETED
                               , Eng_Workflow_Util.G_RT_TIME_OUT
                               , Eng_Workflow_Util.G_RT_ABORTED
                               )
    THEN

         update ENG_CHANGE_ROUTE_PEOPLE set
           response_code = '',
           last_update_date = SYSDATE ,
           last_updated_by = p_wf_user_id,
           last_update_login = ''
         where step_id = p_route_step_id
         and   assignee_id <> -1
         and   ( response_code = Eng_Workflow_Util.G_RT_SUBMITTED
               OR response_code = Eng_Workflow_Util.G_RT_NOT_RECEIVED ) ;

    END IF ;

END SetRouteStepStatus ;



PROCEDURE GetRouteStepStatus
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_route_step_id     IN  NUMBER
 ,  x_status_code       OUT NOCOPY VARCHAR2
)
IS


    CURSOR  c_step (p_route_step_id NUMBER)
    IS
      SELECT step_status_code
        FROM ENG_CHANGE_ROUTE_STEPS
       WHERE step_id = p_route_step_id ;

    recinfo c_step%rowtype;


BEGIN

    -- Get Next Route Step Info
    OPEN c_step(p_route_step_id => p_route_step_id) ;
    FETCH c_step into recinfo;
    IF (c_step%notfound) THEN
        CLOSE c_step ;
        RAISE no_data_found;

    END IF;

    IF (c_step%ISOPEN) THEN

       CLOSE c_step ;

    END IF ;


    x_status_code := recinfo.step_status_code ;

END GetRouteStepStatus ;


PROCEDURE SetAttributes
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN OUT NOCOPY  NUMBER
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_wf_user_role      IN  VARCHAR2  := NULL
 ,  p_host_url          IN  VARCHAR2
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
)
IS

    l_api_name         CONSTANT VARCHAR2(30) := 'SetAttributes';

    -- PL/SQL Table Type Column Datatype Definition
    -- PL/SQL Table Type     Column DataType Definition
    -- WF_ENGINE.NameTabTyp  Wf_Item_Attribute_Values.NAME%TYPE
    -- WF_ENGINE.TextTabTyp  Wf_Item_Attribute_Values.TEXT_VALUE%TYPE
    -- WF_ENGINE.NumTabTyp   Wf_Item_Attribute_Values.NUMBER_VALUE%TYPE
    -- WF_ENGINE.DateTabTyp  Wf_Item_Attribute_Values.DATE_VALUE%TYPE

    l_text_attr_name_tbl   WF_ENGINE.NameTabTyp;
    l_text_attr_value_tbl  WF_ENGINE.TextTabTyp;

    l_num_attr_name_tbl    WF_ENGINE.NameTabTyp;
    l_num_attr_value_tbl   WF_ENGINE.NumTabTyp;

    l_date_attr_name_tbl   WF_ENGINE.NameTabTyp;
    l_date_attr_value_tbl  WF_ENGINE.DateTabTyp;

    I PLS_INTEGER ;

    l_change_id                 NUMBER ;
    l_change_notice             VARCHAR2(10) ;
    l_organization_id           NUMBER ;
    l_organization_code         VARCHAR2(3) ;
    l_change_managemtent_type   VARCHAR2(80) ;
    l_base_cm_type_code         VARCHAR2(30) ;
    l_change_name               VARCHAR2(240) ;
    l_description               VARCHAR2(2000) ;
    l_change_order_type         VARCHAR2(80) ;
    l_organization_name         VARCHAR2(60) ;
    l_eco_department            VARCHAR2(60) ;
    l_change_status             VARCHAR2(80) ;
    l_change_lc_phase           VARCHAR2(80) ;
    l_approval_status           VARCHAR2(80) ;
    l_priority                  VARCHAR2(50) ;
    l_reason                    VARCHAR2(50) ;
    l_assignee                  VARCHAR2(360) ;
    l_assignee_company          VARCHAR2(360) ;
    l_wf_user_role              VARCHAR2(320) ;
    l_message_text_body         VARCHAR2(4000) ;
    l_message_html_body         VARCHAR2(4000) ;
    l_attachments               VARCHAR2(240) ;
    l_line_attachments          VARCHAR2(240) ;
    l_default_novalue           VARCHAR2(2000) ;
    l_host_url                  VARCHAR2(256) ;
    l_action_type_msg           VARCHAR2(360) ;
    l_action_type_code          VARCHAR2(30) ;
    l_wf_sig_policy             VARCHAR2(30) ;

    l_line_sequence_number      NUMBER ;
    l_line_name                 VARCHAR2(240) ;
    l_line_description          VARCHAR2(4000) ;
    l_line_status               VARCHAR2(80) ;
    l_line_approval_status      VARCHAR2(80) ;
    l_line_assignee             VARCHAR2(360) ;
    l_line_assignee_company     VARCHAR2(360) ;


    l_change_detail_url         VARCHAR2(800) ;
    l_change_line_detail_url    VARCHAR2(800) ;
    l_change_subj_detail_url    VARCHAR2(800) ;


    -- R12B Doucmnet LC Phase Workflow Routing
    l_document_id               NUMBER ;
    l_document_revision_id      NUMBER ;
    l_document_number           VARCHAR2(50) ;
    l_document_revision         VARCHAR2(25) ;
    l_documnet_name             VARCHAR2(50) ;
    l_document_detail_page_url  VARCHAR2(800) ;



BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_change_id := p_change_id ;

IF g_debug_flag THEN
   Write_Debug('SetAttribute Private API . . .');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Change Id         : ' || TO_CHAR(l_change_id) );
   Write_Debug('Change Line Id    : ' || TO_CHAR(p_change_line_id) );
   Write_Debug('-----------------------------------------------------');

END IF ;

    --
    -- Get Item Attribute Info
    --
    IF p_change_line_id IS NOT NULL AND  p_change_line_id > 0
    THEN

        -- Get Change Line Object Info
        GetChangeLineObjectInfo
        ( p_change_line_id          => p_change_line_id
        , x_change_id               => l_change_id
        , x_line_sequence_number    => l_line_sequence_number
        , x_line_name               => l_line_name
        , x_line_description        => l_line_description
        , x_line_status             => l_line_status
        , x_line_approval_status    => l_line_approval_status
        , x_line_assignee           => l_line_assignee
        , x_line_assignee_company   => l_line_assignee_company
        ) ;

IF g_debug_flag THEN
   Write_Debug('Got Change Line Object Info . . .');
   Write_Debug('Change Id         : ' || TO_CHAR(l_change_id) );
   Write_Debug('Line Seq Num      : ' || TO_CHAR(l_line_sequence_number));
   Write_Debug('Line Status       : ' || l_line_status);
   Write_Debug('Line Assignee     : ' || l_line_assignee);
END IF ;

        -- Set out param for Change Id
        p_change_id := l_change_id ;

    END IF ;

    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

       -- Get Change Object Info
       GetChangeObjectInfo
       ( p_change_id               => l_change_id
       , x_change_notice           => l_change_notice
       , x_organization_id         => l_organization_id
       , x_change_name             => l_change_name
       , x_description             => l_description
       , x_change_status           => l_change_status
       , x_change_lc_phase         => l_change_lc_phase
       , x_approval_status         => l_approval_status
       , x_priority                => l_priority
       , x_reason                  => l_reason
       , x_change_managemtent_type => l_change_managemtent_type
       , x_change_order_type       => l_change_order_type
       , x_eco_department          => l_eco_department
       , x_assignee                => l_assignee
       , x_assignee_company        => l_assignee_company
       ) ;

IF g_debug_flag THEN
   Write_Debug('Got Change Object Info . . .');
END IF ;

       -- Get Organization Info
       GetOrgInfo
       ( p_organization_id   => l_organization_id
       , x_organization_code => l_organization_code
       , x_organization_name => l_organization_name ) ;

IF g_debug_flag THEN
   Write_Debug('Got Org Info . . .' || l_organization_code);
END IF ;


       l_base_cm_type_code := GetBaseChangeMgmtTypeCode(l_change_id) ;


IF g_debug_flag THEN
   Write_Debug('Get Base CM Type Code ' || l_base_cm_type_code );
END IF ;


   END IF ;


    -- Get User Info
    IF p_wf_user_role IS NULL THEN

        l_wf_user_role := GetUserRole(p_user_id => p_wf_user_id ) ;

    ELSE

        l_wf_user_role := p_wf_user_role ;

    END IF ;

IF g_debug_flag THEN
   Write_Debug('Got User Info . . .');
END IF ;



    -- R12B
    -- Get Document Info for Document Lifecyel Change Object
    IF ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle( p_change_id => l_change_id
                                                  , p_base_change_mgmt_type_code => l_base_cm_type_code
                                                  )
    THEN

IF g_debug_flag THEN
   Write_Debug('Change Object is  Document Lifecycle. . .');
END IF ;

       -- Get Change Object Info
       GetDocumentLCInfo
       ( p_change_id                => l_change_id
       , x_document_id              => l_document_id
       , x_document_revision_id     => l_document_revision_id
       , x_document_number          => l_document_number
       , x_document_revision        => l_document_revision
       , x_documnet_name            => l_documnet_name
       , x_document_detail_page_url => l_document_detail_page_url
       ) ;

IF g_debug_flag THEN
   Write_Debug('Got Documetn Info . . .');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Doc Id            : ' || TO_CHAR(l_document_id) );
   Write_Debug('Doc Revision Id   : ' || TO_CHAR(l_document_revision_id) );
   Write_Debug('Doc Number        : ' || l_document_number );
   Write_Debug('Doc Revision      : ' || l_document_revision );
   Write_Debug('Doc Name          : ' || l_documnet_name );
   Write_Debug('Doc Rev Page URL  : ' || l_document_detail_page_url );
   Write_Debug('-----------------------------------------------------');

END IF ;

    END IF ;


    -- Get Ntf Message PL/SQL Document API Info
    GetNtfMessageDocumentAPI
    ( p_item_type         => p_item_type
    , p_item_key          => p_item_key
    , p_process_name      => p_process_name
    , x_message_text_body => l_message_text_body
    , x_message_html_body => l_message_html_body
    ) ;



    --
    -- MK Comment:
    -- In R12B, we may not need this link any more
    --
    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

        -- BugFix: 3804170
        -- Check if this CO is  Doc Review or Approval by base cm type code
        -- if this is not Doc Review or Approval
        -- Call Get Change Notification Attachment Link Info
        IF  l_base_cm_type_code <>  'ATTACHMENT_APPROVAL'
        AND l_base_cm_type_code <>  'ATTACHMENT_REVIEW'
        THEN

            GetNtfAttachmentLink
             ( p_data_object_code    => 'ENG_ENGINEERING_CHANGES'
             , p_pk1_value          => TO_CHAR(l_change_id)
             , x_ntf_attachment_link => l_attachments ) ;

        END IF ;
    END IF ;


    IF p_change_line_id IS NOT NULL AND  p_change_line_id > 0
    THEN

        -- Get Change Line Notification Attachment Link Info
        GetNtfAttachmentLink
        ( p_data_object_code    => 'ENG_CHANGE_LINES'
        , p_pk1_value           => TO_CHAR(p_change_line_id)
        , x_ntf_attachment_link => l_line_attachments ) ;

    END IF ;

    -- Get Default No Value Comment for Response Field
    l_default_novalue :=  GetDefaultResponseComment ;

IF g_debug_flag THEN
   Write_Debug('Got Worklfow Item Attribute Info . . .');
END IF ;

    -- Comment Out for 115.9 code
    -- because this URL does not work 510 OA Fwk
    -- Get Change Detail Page URL
    -- l_change_detail_url  := 'JSP:/OA_HTML/'
    --                             || Eng_Workflow_Util.GetFunctionWebHTMLCall
    --                               (p_function_name => 'ENG_CHANGE_DETAIL_PAGE' )
    --                             || '&changeId=-&CHANGE_ID-'
    --                             || '&OAFunc=ENG_CHANGE_DETAIL_PAGE' ;
    --




    -- Get Change Detail Page URL using RF.jsp version
    l_change_detail_url := Eng_Workflow_Ntf_Util.GetRunFuncURL
                          ( p_function_name => 'ENG_CHANGE_DETAIL_PAGE'
                          , p_parameters    => '&changeId=' || TO_CHAR(l_change_id) ) ;


    IF p_change_line_id IS NOT NULL AND  p_change_line_id > 0
    THEN

        -- Comment Out for 115.9 code
         -- because this URL does not work 510 OA Fwk
        -- l_change_line_detail_url  := 'JSP:/OA_HTML/'
        --                         || Eng_Workflow_Util.GetFunctionWebHTMLCall
        --                            (p_function_name => 'ENG_CHANGE_LINE_DETAIL_PAGE' )
        --                         || '&changeLineId=-&CHANGE_LINE_ID-'
        --                         || '&OAFunc=ENG_CHANGE_LINE_DETAIL_PAGE'  ;
        --

        -- Get Change Detail Page URL using RF.jsp version
        l_change_line_detail_url := Eng_Workflow_Ntf_Util.GetRunFuncURL
                          ( p_function_name => 'ENG_CHANGE_LINE_DETAIL_PAGE'
                          , p_parameters    => '&changeLineId=' || TO_CHAR(p_change_line_id) ) ;

    END IF ;


    -- Set the values of an array of item type attributes
    -- Use the correct procedure for your attribute type. All attribute types
    -- except number and date use SetItemAttrTextArray.

    -- Text Item Attributes
    -- Using SetItemAttrTextArray():
    I := 0 ;

    -- Change Object Number
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'CHANGE_NOTICE' ;
    l_text_attr_value_tbl(I) := l_change_notice ;

    -- Change Object Name
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'CHANGE_NAME' ;
    l_text_attr_value_tbl(I) := l_change_name ;

    -- Organization Code
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ORGANIZATION_CODE' ;
    l_text_attr_value_tbl(I) := l_organization_code ;

    -- Organization Name
    -- I := I + 1  ;
    -- l_text_attr_name_tbl(I)  := 'ORGANIZATION_NAME' ;
    -- l_text_attr_value_tbl(I) := l_organization_name ;

    -- Change Management Type
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'CHANGE_MANAGEMENT_TYPE' ;
    l_text_attr_value_tbl(I) := l_change_managemtent_type ;

    -- Description
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'DESCRIPTION' ;
    l_text_attr_value_tbl(I) := l_description ;

    -- Change Order Type
    -- I := I + 1  ;
    -- l_text_attr_name_tbl(I)  := 'CHANGE_ORDER_TYPE' ;
    -- l_text_attr_value_tbl(I) := l_change_order_type ;

    -- Eco Department Name
    -- I := I + 1  ;
    -- l_text_attr_name_tbl(I)  := 'ECO_DEPARTMENT' ;
    -- l_text_attr_value_tbl(I) := l_eco_department ;

    -- OBJSOLETE in 115.10
    -- Status
    -- I := I + 1  ;
    -- l_text_attr_name_tbl(I)  := 'STATUS' ;
    -- l_text_attr_value_tbl(I) := l_change_status ;

    -- LC Phase
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'STATUS' ;
    l_text_attr_value_tbl(I) := l_change_lc_phase ;

    -- Approval Status
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'APPROVAL_STATUS' ;
    l_text_attr_value_tbl(I) := l_approval_status ;

    -- Assignee Name
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ASSIGNEE_NAME' ;
    l_text_attr_value_tbl(I) := l_assignee ;

    -- Assignee Company
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ASSIGNEE_COMPANY' ;
    l_text_attr_value_tbl(I) := l_assignee_company ;

    -- Priority
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'PRIORITY' ;
    l_text_attr_value_tbl(I) := l_priority ;

    -- Reason
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'REASON' ;
    l_text_attr_value_tbl(I) := l_reason ;

    -- WF Owner's User Role
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'WF_USER_ROLE' ;
    l_text_attr_value_tbl(I) := l_wf_user_role ;

    -- Ntf Default From Role
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'FROM_ROLE' ;
    l_text_attr_value_tbl(I) := l_wf_user_role ;

    -- Host URL
    I := I + 1  ;

    IF p_host_url  IS NULL THEN

       l_host_url := NULL ;
       -- Set NULL always to get Host URL from GetFrameWorkAgentURL
       -- in GetHostURL if p_host_url is not passed
       -- l_host_url := GetFrameWorkAgentURL ;

    ELSE

       l_host_url := p_host_url ;

    END IF ;

    l_text_attr_name_tbl(I)  := 'HOST_URL' ;
    l_text_attr_value_tbl(I) := l_host_url ;

    -- Message Text Body
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'MESSAGE_TEXT_BODY' ;
    l_text_attr_value_tbl(I) := l_message_text_body ;

    -- Message HTML Body
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'MESSAGE_HTML_BODY' ;
    l_text_attr_value_tbl(I) := l_message_html_body ;


    -- Ntf Attachemnts
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ATTACHMENTS' ;
    l_text_attr_value_tbl(I) := l_attachments ;


    -- Change Reviewer Role
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'REVIEWERS_ROLE' ;
    l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                ( p_role_prefix => Eng_Workflow_Util.G_REV_ROLE
                                , p_item_type   => p_item_type
                                , p_item_key    => p_item_key ) ;


    -- Change Assignee Role
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ASSIGNEE_ROLE' ;
    l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                ( p_role_prefix => Eng_Workflow_Util.G_ASSIGNEE_ROLE
                                , p_item_type   => p_item_type
                                , p_item_key    => p_item_key ) ;


    -- Response Comment
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'RESPONSE_COMMENT' ;
    l_text_attr_value_tbl(I) := l_default_novalue ;


    -- Change Detail Page URL
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'CHANGE_DETAIL_PAGE_URL' ;
    l_text_attr_value_tbl(I) := l_change_detail_url ;


    -- Change Action Worklfow Specific Attributes
    IF p_item_type = G_CHANGE_ACTION_ITEM_TYPE  THEN

        -- Change Adhoc Party List
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'ADHOC_PARTY_LIST' ;
        l_text_attr_value_tbl(I) := p_adhoc_party_list ;

        -- Change Adhoc Party Role
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'ADHOC_PARTY_ROLE' ;
        l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => Eng_Workflow_Util.G_ADHOC_PARTY_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;


        --
        -- 115.10 LC Phase Change
        -- Set to PROMOTE or DEMOTE For Notification Subject
        -- Action Type

        IF  p_process_name = G_STATUS_CHANGE_PROC
        THEN

            --
            -- Get Message for Ntf Subject
            -- Like:
            -- has been promoted to &STATUS Phase ENG_PHASE_PROMOTED_TO_NTF
            -- has been demoted to &STATUS Phase  ENG_PHASE_DEMOTED_TO_NTF
            --
            GetActionTypeCode(p_action_id        => p_action_id
                            , x_action_type_code => l_action_type_code) ;

            IF l_action_type_code = G_ACT_PROMOTE
            THEN

                FND_MESSAGE.SET_NAME('ENG', 'ENG_PHASE_PROMOTED_TO_NTF') ;
                FND_MESSAGE.SET_TOKEN('STATUS', l_change_lc_phase) ;
                l_action_type_msg :=  FND_MESSAGE.GET ;

            ELSIF l_action_type_code = G_ACT_DEMOTE
            THEN

                FND_MESSAGE.SET_NAME('ENG', 'ENG_PHASE_DEMOTED_TO_NTF') ;
                FND_MESSAGE.SET_TOKEN('STATUS', l_change_lc_phase) ;
                l_action_type_msg :=  FND_MESSAGE.GET ;

            END IF ;

            I := I + 1  ;
            l_text_attr_name_tbl(I)  := 'ACTION_TYPE' ;
            l_text_attr_value_tbl(I) := l_action_type_msg ;

        END IF ; -- End Of p_process_name = G_STATUS_CHANGE_PROC



    -- Change Route Worklfow Specific Attributes
    ELSIF p_item_type = G_CHANGE_ROUTE_ITEM_TYPE  THEN

        -- Change Route People Party Role
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'ROUTE_PEOPLE_ROLE' ;
        l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => Eng_Workflow_Util.G_ROUTE_PEOPLE_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;


        -- Change Route Object Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'OBJECT_NAME' ;
        l_text_attr_value_tbl(I) := p_object_name ;

        -- Change Route Parent Object Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'PARENT_OBJECT_NAME' ;
        l_text_attr_value_tbl(I) := p_parent_object_name ;


        -- Workflow Signature Policy
        l_wf_sig_policy := GetWfSigPolicyFromLCPhase
                           ( p_change_id => l_change_id
                           , p_route_id => p_route_id ) ;
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'WF_SIG_POLICY' ;
        l_text_attr_value_tbl(I) := l_wf_sig_policy ;


    -- Change Route Step Worklfow Specific Attributes
    -- R12B added new Line Workflow and Documet Workflow Route Step Type
    ELSIF (  p_item_type = G_CHANGE_ROUTE_STEP_ITEM_TYPE
          OR p_item_type = G_CHANGE_ROUTE_LINE_STEP_TYPE
          OR p_item_type = G_CHANGE_ROUTE_DOC_STEP_TYPE
          )
    THEN

        -- Change Route People Party Role
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'ROUTE_PEOPLE_ROLE' ;
        l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => Eng_Workflow_Util.G_ROUTE_PEOPLE_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;


        -- Change Route Step People Role
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'STEP_PEOPLE_ROLE' ;
        l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => Eng_Workflow_Util.G_STEP_PEOPLE_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;


        -- Workflow Signature Policy
        l_wf_sig_policy := GetWfSigPolicyFromLCPhase
                           ( p_change_id => l_change_id
                           , p_route_id => p_route_id ) ;
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'WF_SIG_POLICY' ;
        l_text_attr_value_tbl(I) := l_wf_sig_policy ;


        -- R12B
        -- Change Route Object Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'OBJECT_NAME' ;
        l_text_attr_value_tbl(I) := p_object_name ;

        -- Change Route Parent Object Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'PARENT_OBJECT_NAME' ;
        l_text_attr_value_tbl(I) := p_parent_object_name ;



    END IF ;



    -- Change Line Action Worklfow/Line Workflow Routing Specific Attributes
    -- R12B added new Line Workflow Route Step Type
    IF ( p_item_type = G_CHANGE_LINE_ACTION_ITEM_TYPE
         OR p_item_type = G_CHANGE_ROUTE_LINE_STEP_TYPE
         OR ( p_change_line_id IS NOT NULL AND  p_change_line_id > 0 )
       )
    THEN


IF g_debug_flag THEN
   Write_Debug('Setting Change Line Item Attribute Info . . .');
END IF ;

        -- Line Ntf Attachemnts
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_ATTACHMENTS' ;
        l_text_attr_value_tbl(I) := l_line_attachments ;

        -- Line Reviewer Role
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_REVIEWERS_ROLE' ;
        l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => Eng_Workflow_Util.G_LINE_REV_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;

        -- Line Assignee Role
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_ASSIGNEE_ROLE' ;
        l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => Eng_Workflow_Util.G_LINE_ASSIGNEE_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;

        -- Line Object Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_NAME' ;
        l_text_attr_value_tbl(I) := l_line_name ;

        -- Line Description
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_DESCRIPTION' ;
        l_text_attr_value_tbl(I) := l_line_description ;

        -- Line Status
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_APPROVAL_STATUS' ;
        l_text_attr_value_tbl(I) := l_line_approval_status ;

        -- Line Status
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_STATUS' ;
        l_text_attr_value_tbl(I) := l_line_status ;

        -- Line Assignee Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_ASSIGNEE_NAME' ;
        l_text_attr_value_tbl(I) := l_line_assignee ;

        -- Line Assignee Company
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_ASSIGNEE_COMPANY' ;
        l_text_attr_value_tbl(I) := l_line_assignee_company ;


        -- Line Detal Page URL
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'LINE_DETAIL_PAGE_URL' ;
        l_text_attr_value_tbl(I) := l_change_line_detail_url ;


    END IF ;
    -- End of Change Line Action Worklfow/Line Workflow Routing Specific Attributes



    -- Document Lifecycle Workflow Routing Specific Attributes
    IF p_item_type = G_CHANGE_ROUTE_DOC_STEP_TYPE
    THEN

IF g_debug_flag THEN
   Write_Debug('Setting Document Lifecycle Workflow Routing Item Attribute Info . . .');
END IF ;

        -- Document Number
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'DOCUMENT_NUMBER' ;
        l_text_attr_value_tbl(I) := l_document_number ;


        -- Document Revision
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'DOCUMENT_REVISION' ;
        l_text_attr_value_tbl(I) := l_document_revision ;

        -- Document Name
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'DOCUMNET_NAME' ;
        l_text_attr_value_tbl(I) := l_documnet_name ;


        -- Line Detal Page URL
        I := I + 1  ;
        l_text_attr_name_tbl(I)  := 'DOCUMENT_DETAIL_PAGE_URL' ;
        l_text_attr_value_tbl(I) := l_document_detail_page_url ;


    END IF ;
    -- End of Document Lifecycle Workflow Routing Specific Attributes



IF g_debug_flag THEN
   Write_Debug('Call WF_ENGINE.SetItemAttrTextArray . . .');
END IF ;


    -- Set Text Attributes
    WF_ENGINE.SetItemAttrTextArray
    ( itemtype     => p_item_type
    , itemkey      => p_item_key
    , aname        => l_text_attr_name_tbl
    , avalue       => l_text_attr_value_tbl
    ) ;

    -- Number Item Attributes
    -- Using SetItemAttrNumberArray():
    I := 0 ;

    -- Change Id
    I := I + 1  ;
    l_num_attr_name_tbl(I)  := 'CHANGE_ID' ;
    l_num_attr_value_tbl(I) := l_change_id ;

    -- Organization Id
    I := I + 1  ;
    l_num_attr_name_tbl(I)  := 'ORGANIZATION_ID' ;
    l_num_attr_value_tbl(I) := l_organization_id  ;

    -- Worklfow Owner User Id
    I := I + 1  ;
    l_num_attr_name_tbl(I)  := 'WF_USER_ID' ;
    l_num_attr_value_tbl(I) := p_wf_user_id ;

    -- Change Action Worklfow Specific Attributes
    IF p_item_type = G_CHANGE_ACTION_ITEM_TYPE
       OR p_item_type = G_CHANGE_LINE_ACTION_ITEM_TYPE THEN

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'ACTION_ID' ;
        l_num_attr_value_tbl(I) := p_action_id ;

    -- Change Route Worklfow Specific Attributes
    ELSIF p_item_type = G_CHANGE_ROUTE_ITEM_TYPE  THEN

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'ROUTE_ID' ;
        l_num_attr_value_tbl(I) := p_route_id ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'ACTION_ID' ;
        l_num_attr_value_tbl(I) := p_action_id ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID1' ;
        l_num_attr_value_tbl(I) := p_object_id1 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID2' ;
        l_num_attr_value_tbl(I) := p_object_id2 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID3' ;
        l_num_attr_value_tbl(I) := p_object_id3 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID4' ;
        l_num_attr_value_tbl(I) := p_object_id4 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID5' ;
        l_num_attr_value_tbl(I) := p_object_id5 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'PARENT_OBJECT_ID1' ;
        l_num_attr_value_tbl(I) := p_parent_object_id1 ;

    -- Change Route Worklfow Specific Attributes
    -- R12B added new Line Workflow and Documet Workflow Route Step Type
    ELSIF (  p_item_type = G_CHANGE_ROUTE_STEP_ITEM_TYPE
          OR p_item_type = G_CHANGE_ROUTE_LINE_STEP_TYPE
          OR p_item_type = G_CHANGE_ROUTE_DOC_STEP_TYPE
          )
    THEN

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'ROUTE_ID' ;
        l_num_attr_value_tbl(I) := p_route_id ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'STEP_ID' ;
        l_num_attr_value_tbl(I) := p_route_step_id ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'ACTION_ID' ;
        l_num_attr_value_tbl(I) := p_action_id ;


        -- R12B
        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID1' ;
        l_num_attr_value_tbl(I) := p_object_id1 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID2' ;
        l_num_attr_value_tbl(I) := p_object_id2 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID3' ;
        l_num_attr_value_tbl(I) := p_object_id3 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID4' ;
        l_num_attr_value_tbl(I) := p_object_id4 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'OBJECT_ID5' ;
        l_num_attr_value_tbl(I) := p_object_id5 ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'PARENT_OBJECT_ID1' ;
        l_num_attr_value_tbl(I) := p_parent_object_id1 ;

    END IF ;



    -- Change Line Action Worklfow/Line Workflow Routing Specific Attributes
    -- R12B added new Line Workflow Route Step Type
    IF ( p_item_type = G_CHANGE_LINE_ACTION_ITEM_TYPE
         OR p_item_type = G_CHANGE_ROUTE_LINE_STEP_TYPE
         OR ( p_change_line_id IS NOT NULL AND  p_change_line_id > 0 )
       )
    THEN

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'CHANGE_LINE_ID' ;
        l_num_attr_value_tbl(I) := p_change_line_id ;

        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'LINE_SEQUENCE_NUMBER' ;
        l_num_attr_value_tbl(I) := l_line_sequence_number ;

    END IF ;
    -- End of Change Line Action Worklfow/Line Workflow Routing Specific Attributes



    -- Document Lifecycle Workflow Routing Specific Attributes
    IF p_item_type = G_CHANGE_ROUTE_DOC_STEP_TYPE
    THEN

IF g_debug_flag THEN
   Write_Debug('Setting Document Lifecycle Workflow Routing Item Attribute Info . . .');
END IF ;

        -- Document Id
        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'DOCUMENT_ID' ;
        l_num_attr_value_tbl(I) := l_document_id ;

        -- Document Revision Id
        I := I + 1  ;
        l_num_attr_name_tbl(I)  := 'DOCUMENT_REVISION_ID' ;
        l_num_attr_value_tbl(I) := l_document_revision_id ;


    END IF ;
    -- End of Document Lifecycle Workflow Routing Specific Attributes



IF g_debug_flag THEN
   Write_Debug('Call WF_ENGINE.SetItemAttrNumberArray . . .');
END IF ;

    -- Set Number Attributes
    WF_ENGINE.SetItemAttrNumberArray
    ( itemtype     => p_item_type
    , itemkey      => p_item_key
    , aname        => l_num_attr_name_tbl
    , avalue       => l_num_attr_value_tbl
    ) ;


    -- Date Item Attributes
    -- Using SetItemAttrDateArray():
    I := 0 ;

    -- I := I + 1  ;
    -- l_date_attr_name_tbl(I)  := '' ;
    -- l_date_attr_value_tbl(I) := '' ;


    IF l_date_attr_name_tbl.EXISTS(1) THEN

IF g_debug_flag THEN
   Write_Debug('Call WF_ENGINE.SetItemAttrDateArray . . .');
END IF ;

        -- Set Date Attributes
        WF_ENGINE.SetItemAttrDateArray
        ( itemtype     => p_item_type
        , itemkey      => p_item_key
        , aname        => l_date_attr_name_tbl
        , avalue       => l_date_attr_value_tbl
        ) ;

    END IF ;


EXCEPTION
    WHEN OTHERS THEN

IF g_debug_flag THEN
   Write_Debug('When Others in SetAttributes ' || SQLERRM );
END IF ;


    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;


END SetAttributes ;


FUNCTION CheckRouteStepRequiredDate(p_route_id IN NUMBER )
RETURN BOOLEAN
IS

    CURSOR c_route_req_date (p_route_id NUMBER)
    IS

       SELECT step_seq_num
            , required_date
       FROM   ENG_CHANGE_ROUTE_STEPS
       WHERE  route_id = p_route_id
       AND    required_date IS NOT NULL
       ORDER BY step_seq_num ;

    l_return_status     VARCHAR2(1) ;
    l_pre_require_date  DATE ;



BEGIN

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;


    FOR step_rec IN  c_route_req_date(p_route_id => p_route_id)
    LOOP

        -- IF step_rec.required_date < TRUNC(SYSDATE) THEN
        -- We do not trucate required_date anymore
        -- for bug fix3456536
        IF step_rec.required_date < SYSDATE THEN


            l_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_REQDATE_INVALID') ;
            FND_MESSAGE.SET_TOKEN('STEP_SEQ_NUM', step_rec.step_seq_num );
            FND_MSG_PUB.Add ;

        END IF ;

        -- Step Req Date should be greater than or equal to
        -- req date in previous step
        IF step_rec.required_date < l_pre_require_date
        THEN


            l_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_REQDATE_LESS') ;
            FND_MESSAGE.SET_TOKEN('STEP_SEQ_NUM', step_rec.step_seq_num );
            FND_MSG_PUB.Add ;


        END IF ;


        -- Set current Required Date as Previous Required
        -- if it's not null
        IF step_rec.required_date IS NOT NULL  AND
           step_rec.required_date > NVL(l_pre_require_date, TRUNC(SYSDATE))
        THEN

            l_pre_require_date := step_rec.required_date ;

        END IF ;


    END LOOP ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       RETURN  FALSE ;

    END IF ;

    RETURN TRUE ;

END  CheckRouteStepRequiredDate ;

FUNCTION CheckRouteStatus( p_route_id        IN NUMBER
                         , p_change_id       IN NUMBER
                         , p_change_line_id  IN  NUMBER )
RETURN BOOLEAN
IS

    CURSOR c_route_status (p_route_id NUMBER)
    IS

       SELECT 'Can not be started'
       FROM   ENG_CHANGE_ROUTES
       WHERE  route_id = p_route_id
       AND    status_code <> Eng_Workflow_Util.G_RT_NOT_STARTED ;

    CURSOR c_route_instance (p_route_id NUMBER)
    IS

       SELECT 'Can not be started'
       FROM   ENG_CHANGE_ROUTES
       WHERE  route_id = p_route_id
       AND    template_flag <> Eng_Workflow_Util.G_RT_INSTANCE ;


    l_return_status     VARCHAR2(1) ;

    l_change_id                 NUMBER ;
    l_line_sequence_number      NUMBER ;
    l_line_name                 VARCHAR2(240) ;
    l_line_description          VARCHAR2(4000) ;
    l_line_status               VARCHAR2(80) ;
    l_line_approval_status      VARCHAR2(80) ;
    l_line_assignee             VARCHAR2(360) ;
    l_line_assignee_company     VARCHAR2(360) ;



BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check Route Status
    FOR route_rec IN  c_route_status(p_route_id => p_route_id)
    LOOP

        l_return_status := FND_API.G_RET_STS_ERROR ;

        IF p_change_line_id IS NOT NULL AND  p_change_line_id > 0
        THEN

            -- Set Error Message for Line

            -- Get Change Line Object Info
            GetChangeLineObjectInfo
            ( p_change_line_id          => p_change_line_id
            , x_change_id               => l_change_id
            , x_line_sequence_number    => l_line_sequence_number
            , x_line_name               => l_line_name
            , x_line_description        => l_line_description
            , x_line_status             => l_line_status
            , x_line_approval_status    => l_line_approval_status
            , x_line_assignee           => l_line_assignee
            , x_line_assignee_company   => l_line_assignee_company
            ) ;

            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_LN_NOT_ABLE_TO_START') ;
            FND_MESSAGE.SET_TOKEN('LINE_SEQ_NUM', l_line_sequence_number );
            FND_MSG_PUB.Add ;

        ELSE

            -- Set Error Message for Header
            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_NOT_ABLE_TO_START') ;
            FND_MSG_PUB.Add ;

        END IF ;

    END LOOP ;


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       RETURN  FALSE ;

    END IF ;

    -- Check Route is instance
    FOR route_rec IN  c_route_instance(p_route_id => p_route_id)
    LOOP

        l_return_status := FND_API.G_RET_STS_ERROR ;

        -- Set Error Message for Header
        FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_NOT_INSTANCE') ;
        FND_MSG_PUB.Add ;

    END LOOP ;


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       RETURN  FALSE ;

    END IF ;

    RETURN TRUE ;

END  CheckRouteStatus ;


FUNCTION CheckRouteAssignees( p_route_id        IN NUMBER
                            , p_change_id       IN NUMBER
                            , p_change_line_id  IN  NUMBER )

RETURN BOOLEAN
IS

    CURSOR c_route_assignees (p_route_id NUMBER)
    IS

        SELECT step.step_seq_num
        FROM   ENG_CHANGE_ROUTE_STEPS  step
        WHERE  EXISTS (SELECT 'Invalid Assignee Exists'
                       FROM   ENG_CHANGE_ROUTE_PEOPLE  people
                       WHERE  people.assignee_id = -1
                       AND    people.assignee_type_code = Eng_Workflow_Util.G_PERSON
                       AND    people.step_id = step.step_id )
        AND    step.route_id  = p_route_id ;


    l_return_status     VARCHAR2(1) ;

    l_change_id                 NUMBER ;
    l_line_sequence_number      NUMBER ;
    l_line_name                 VARCHAR2(240) ;
    l_line_description          VARCHAR2(4000) ;
    l_line_status               VARCHAR2(80) ;
    l_line_approval_status      VARCHAR2(80) ;
    l_line_assignee             VARCHAR2(360) ;
    l_line_assignee_company     VARCHAR2(360) ;



BEGIN

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;


    FOR route_rec IN  c_route_assignees(p_route_id => p_route_id)
    LOOP

        l_return_status := FND_API.G_RET_STS_ERROR ;

        IF p_change_line_id IS NOT NULL AND  p_change_line_id > 0
        THEN

            -- Set Error Message for Line

            -- Get Change Line Object Info
            GetChangeLineObjectInfo
            ( p_change_line_id          => p_change_line_id
            , x_change_id               => l_change_id
            , x_line_sequence_number    => l_line_sequence_number
            , x_line_name               => l_line_name
            , x_line_description        => l_line_description
            , x_line_status             => l_line_status
            , x_line_approval_status    => l_line_approval_status
            , x_line_assignee           => l_line_assignee
            , x_line_assignee_company   => l_line_assignee_company
            ) ;

            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_LN_INVALID_ASSIGNEE') ;
            FND_MESSAGE.SET_TOKEN('LINE_SEQ_NUM', l_line_sequence_number );
            FND_MESSAGE.SET_TOKEN('STEP_SEQ_NUM', route_rec.step_seq_num );
            FND_MSG_PUB.Add ;

        ELSE

            -- Set Error Message for Header
            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_INVALID_ASSIGNEE') ;
            FND_MESSAGE.SET_TOKEN('STEP_SEQ_NUM', route_rec.step_seq_num );
            FND_MSG_PUB.Add ;

        END IF ;


    END LOOP ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       RETURN  FALSE ;

    END IF ;

    RETURN TRUE ;

END  CheckRouteAssignees ;

FUNCTION CheckMandatoryAssignee( p_route_id        IN NUMBER)
RETURN BOOLEAN
IS
    CURSOR c_Mandatory_route_assignees (p_route_id NUMBER)
    IS
        SELECT steps.STEP_SEQ_NUM   ,steps.step_id
        FROM ENG_CHANGE_ROUTE_STEPS steps ,
             ENG_CHANGE_ROUTE_PEOPLE PEOPLE
        WHERE CONDITION_TYPE_CODE = 'PEOPLE'
          AND STEPS.STEP_ID = PEOPLE.STEP_ID
                         AND PEOPLE.RESPONSE_CONDITION_CODE = 'MANDATORY'
                         AND PEOPLE.ASSIGNEE_ID=-1
                         AND STEPS.route_id=p_route_id;

     l_return_status     VARCHAR2(1) ;
    route_rec c_Mandatory_route_assignees%rowtype;
BEGIN

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_Mandatory_route_assignees(p_route_id => p_route_id) ;
    FETCH c_Mandatory_route_assignees into route_rec;

    IF (c_Mandatory_route_assignees%found) THEN
        l_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_MANDAT_ASSIGN_MISS') ;
            --fnd_message.SET_TOKEN ('STEP_NO',route_rec.STEP_SEQ_NUM , TRUE);
            FND_MSG_PUB.Add ;

    END IF ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       RETURN  FALSE ;

    END IF ;

    RETURN TRUE ;

END  CheckMandatoryAssignee ;



PROCEDURE ValidateProcess
(   p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
)
IS

    l_api_name         CONSTANT VARCHAR2(30) := 'ValidateProcess';



    -- R12B for DOM API
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(3000);


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_validation_level <= FND_API.G_VALID_LEVEL_NONE THEN
       RETURN ;
    END IF ;

    -- Item Type: ALL
    -- p_wf_user_id should not be null
    -- p_host_url should not be null
    -- p_process_name should not be null



    -- Item Type: ALL except G_CHANGE_LINE_ACTION_ITEM_TYPE
    -- p_change_id should not be null

    -- Item type: G_CHANGE_ACTION_ITEM_TYPE
    -- Change Action Workflow Processes
    -- Validation Logic
    -- p_action_id should not be null

    -- Item type: G_CHANGE_LINE_ACTION_ITEM_TYPE
    -- Change Line Action Workflow Processes
    -- Validation Logic
    -- p_action_id should not be null
    -- p_change_line_id should not be null


    -- Item type: G_CHANGE_ROUTE_ITEM_TYPE
    -- Change Route Workflow Processes
    -- Validation Logic:
    --
    -- OA Page:
    -- p_route_id should not be null
    -- At least, should have one 'Not Started' route step
    -- The Route Status should be NOT_STARTED
    -- There should be no running Change Route Proc for the Change Object
    -- Should not be Route Template
    --
    --
    IF p_item_type = G_CHANGE_ROUTE_ITEM_TYPE THEN

        --
        -- R12 DOM LC Phase Workflow Support
        --
        IF ( ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle( p_change_id => p_change_id) )
        THEN

IF g_debug_flag THEN
    Write_Debug('Change Object is a Doc LC Object, calling API. . . . ');
    Write_Debug('Calling ENG_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF. . .' );
END IF ;

            ENG_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF
            (   p_api_version               => 1.0
             ,  p_init_msg_list             => FND_API.G_FALSE        --
             ,  p_commit                    => FND_API.G_FALSE        --
             ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
             ,  x_return_status             => l_return_status
             ,  x_msg_count                 => l_msg_count
             ,  x_msg_data                  => l_msg_data
             ,  p_change_id                 => p_change_id        -- Change Id
             ,  p_route_id                  => p_route_id         -- WF Route ID
            ) ;


IF g_debug_flag THEN
  Write_Debug('After calling ENG_DOCUMENT_UTIL.Start_Doc_LC_Phase_WF: ' || l_return_status );
END IF ;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                x_return_status :=  l_return_status ;
            END IF ;

        END IF ;




        IF NOT CheckMandatoryAssignee(p_route_id => p_route_id)
        THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;


        /*
        -- Check Required Date is not passed due
        -- No longer used
        -- because we changed the logic to that
        -- Required Date is generated when the step wf is started
        --
        -- Verify this route step required dates
        -- 1. equal to or greater than SYSDATE
        -- 2. the greater step num, the later required date
        IF NOT CheckRouteStepRequiredDate(p_route_id => p_route_id)
        THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;

        END IF ;
        */

        -- Verify Route Status is NOT_STARTED
        -- Verify Route is instance (neither tempalte or history
        IF NOT CheckRouteStatus( p_route_id       => p_route_id
                               , p_change_id      => p_change_id
                               , p_change_line_id => p_change_line_id )
        THEN

IF g_debug_flag THEN
   Write_Debug('Verify Route Status is NOT_STARTED . . .');
   Write_Debug('Verify Route is Instance . . .');
END IF ;


            x_return_status := FND_API.G_RET_STS_ERROR ;

        END IF ;



        /* Comment Out: We decided to igonore this assignee
        -- rather than returning an error
        -- Verify that not evaluated assignee does not exist
        IF NOT CheckRouteAssignees( p_route_id       => p_route_id
                                  , p_change_id      => p_change_id
                                  , p_change_line_id => p_change_line_id )
        THEN

IF g_debug_flag THEN
   Write_Debug('Verify there is not missing assignee . . .');
END IF ;

            x_return_status := FND_API.G_RET_STS_ERROR ;

        END IF ;
        */


    END IF ;



    -- Item type: G_CHANGE_ROUTE_STEP_ITEM_TYPE
    -- Change Route Step Workflow Processes
    -- Validation Logic
    -- p_route_id should not be null
    -- p_route_step_id should not be null
    -- The Route Step Status should be 'NOT_STARTED'



EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

END ValidateProcess;


PROCEDURE ValidateAbortingProcess
(   p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
)
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'ValidateAbortingProcess';
    l_status         VARCHAR2(8) ;
    l_result         VARCHAR2(30) ;

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_validation_level <= FND_API.G_VALID_LEVEL_NONE THEN
       RETURN ;
    END IF ;


    -- Item Type: ALL
    -- p_item_type should not be null
    -- p_item_key should not be null
    -- p_wf_user_id should not be null


    -- Check Process Status
    WF_ENGINE.ItemStatus
    (  itemtype    => p_item_type
    ,  itemkey     => p_item_key
    ,  status      => l_status
    ,  result      => l_result
    ) ;

IF g_debug_flag THEN
   Write_Debug('Process Status : ' ||  l_status || ' Result: ' ||  l_result );
END IF ;



   IF l_status = G_WF_COMPLETE
   THEN

       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MESSAGE.SET_NAME('ENG', 'ENG_ROUTE_WF_NOT_RUNNING') ;
       FND_MSG_PUB.Add ;

   END IF ;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

END ValidateAbortingProcess;



PROCEDURE SetAdhocPartyRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_adhoc_party_list  IN  VARCHAR2
)
IS

    l_api_name         CONSTANT VARCHAR2(30) := 'SetAdhocPartyRole';

    -- Role And Users And Privileges
    l_party_id            NUMBER ;
    l_party_type          VARCHAR2(30) ;
    l_role_name           VARCHAR2(320) ;
    l_role_display_name   VARCHAR2(320) ;
    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;



    c1        PLS_INTEGER;
    list_rest VARCHAR2(2000);

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Adhoc Party List
    list_rest := LTRIM(p_adhoc_party_list) ;
    LOOP

        c1 := INSTR(list_rest, ',');
        IF (c1 = 0) THEN
            c1 := INSTR(list_rest, ' ');
            IF (c1 = 0) THEN
               l_party_id := TO_NUMBER(list_rest) ;
            ELSE
               l_party_id := TO_NUMBER(substr(list_rest, 1, c1-1));
            END IF;
        ELSE
               l_party_id := TO_NUMBER(substr(list_rest, 1, c1-1));
        END IF;

        IF l_party_id IS NOT NULL  THEN

            l_party_type  := GetPartyType(p_party_id => l_party_id) ;

            IF l_party_type = 'PERSON' THEN


               SetUserToRoleUsers2( p_party_id   => l_party_id
                                 , x_role_users => l_role_users
                                 ) ;

            ELSIF l_party_type = 'GROUP' THEN

               SetGroupToRoleUsers2( p_group_id   => l_party_id
                                  , x_role_users => l_role_users
                                  ) ;

            END IF ;

        END IF ; -- if l_party_id is not null

        exit when (c1 = 0);
        list_rest := LTRIM(SUBSTR(list_rest, c1+1));

    END LOOP ;

    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN

        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'ADHOC_PARTY_ROLE');

        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );


    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

END SetAdhocPartyRole ;

PROCEDURE SetAssigneeRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetAssigneeRole';

    l_change_id           NUMBER ;
    l_assignee_party_id   NUMBER ;
    l_requestor_party_id  NUMBER ;
    l_creator_user_id     NUMBER ;
    l_role_name           VARCHAR2(320) ;
    l_role_display_name   VARCHAR2(320) ;

    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;



BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetAssigneeRole Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('-----------------------------------------------------');
END IF ;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Change Object Identifier
    GetChangeObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Change Object Identifier . . . ' );
END IF ;


    -- Get Change Object Party
    GetChangeObjectParty
    ( p_change_id               => l_change_id
    , x_assignee_party_id       => l_assignee_party_id
    , x_requestor_party_id      => l_requestor_party_id
    , x_creator_user_id         => l_creator_user_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Change Object Party . . . Assignee Party Id: ' || to_char(l_assignee_party_id) );
END IF ;

    -- Set Assignee to Role Users
    SetAssigneeToRoleUsers2( p_assignee_party_id => l_assignee_party_id
                            , x_role_users        => l_role_users
                            ) ;


IF g_debug_flag THEN
   Write_Debug('Set Assignee to Role Users . . . ' );
END IF ;


    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN


        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'ASSIGNEE_ROLE');

        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );



    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

IF g_debug_flag THEN
   Write_Debug('Exception in SetAssigneeRole: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;

END SetAssigneeRole ;

PROCEDURE SetReviewersRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_reviewer_type     IN  VARCHAR2 := 'STD'
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetReviewersRole';

    l_change_id           NUMBER ;
    l_assignee_party_id   NUMBER ;
    l_requestor_party_id  NUMBER ;
    l_creator_user_id     NUMBER ;
    l_role_name           VARCHAR2(320) ;
    l_role_display_name   VARCHAR2(320) ;
    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;


BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetReviewersRole Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('Reviewer Type     : ' || p_reviewer_type );
   Write_Debug('-----------------------------------------------------');
END IF ;



    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_flag THEN
   Write_Debug('Get Change Object Identifier . . . ' );
END IF ;


    -- Get Change Object Identifier
    GetChangeObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
    ) ;


IF g_debug_flag THEN
   Write_Debug('Get Change Object Party . . . ' );
END IF ;



    -- Get Change Object Party
    GetChangeObjectParty
    ( p_change_id               => l_change_id
    , x_assignee_party_id       => l_assignee_party_id
    , x_requestor_party_id      => l_requestor_party_id
    , x_creator_user_id         => l_creator_user_id
    ) ;


IF g_debug_flag THEN
   Write_Debug('Assignee Party Id: ' || TO_CHAR(l_assignee_party_id) );
   Write_Debug('Requestor Party Id: ' || TO_CHAR(l_requestor_party_id) );
   Write_Debug('Creator Party Id: ' || TO_CHAR(l_creator_user_id) );
END IF ;


    IF p_reviewer_type <> 'NO_ASSIGNEE' THEN

IF g_debug_flag THEN
   Write_Debug('Calling SetAssigneeToRoleUsers2. . . ' );
END IF ;

        -- Set Assignee to Role Users
        SetAssigneeToRoleUsers2( p_assignee_party_id => l_assignee_party_id
                               , x_role_users        => l_role_users
                               ) ;

IF g_debug_flag THEN
   Write_Debug('After Set Assignee to Role Users . . . ' );
END IF ;


    END IF ;


IF g_debug_flag THEN
   Write_Debug('Calling SetCreatorToRoleUsers2. . . ' );
END IF ;

    -- Set Creator to Role Users
    SetCreatorToRoleUsers2(  p_creator_user_id   => l_creator_user_id
                           , x_role_users        => l_role_users
                           ) ;


IF g_debug_flag THEN
   Write_Debug('After Set Creator to Role Users . . . ' );
   Write_Debug('Calling SetRequestorToRoleUsers2. . . ' );
END IF ;



    -- Set Requestor to Role Users
    SetRequestorToRoleUsers2(p_requestor_party_id => l_requestor_party_id
                           , x_role_users         => l_role_users
                           ) ;



IF g_debug_flag THEN
   Write_Debug('After Set Requstor to Role Users . . . ' );
END IF ;


    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN

        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'REVIEWERS_ROLE');


        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );


    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

IF g_debug_flag THEN
   Write_Debug('Exception in SetReviewersRole: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;

END SetReviewersRole ;




PROCEDURE StartAllLineWorkflows
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2 := NULL
 ,  p_line_item_type    IN  VARCHAR2
 ,  p_line_process_name IN  VARCHAR2
)
IS

    -- PRAGMA  AUTONOMOUS_TRANSACTION;
    l_api_name          CONSTANT VARCHAR2(30) := 'StartAllLineWorkflows';

    l_return_status     VARCHAR2(1) ;
    l_line_item_key     VARCHAR2(240)  ;
    l_change_id         NUMBER ;
    l_debug             VARCHAR2(1)    := FND_API.G_FALSE ;
    l_output_dir        VARCHAR2(240)  := '' ;
    l_debug_filename    VARCHAR2(200)  := 'StartAllLineWorkflows.log' ;

    CURSOR  c_lines  (p_change_id NUMBER)
    IS
        SELECT change_line_id
          FROM ENG_CHANGE_LINES
         WHERE change_id = p_change_id
           AND change_type_id <> -1  -- excluding change task
           AND sequence_number <> -1 ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.StartAllLineWorkflows');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type   : ' || p_item_type );
   Write_Debug('Item Key    : ' || p_item_key );
   Write_Debug('Change Id   : ' || TO_CHAR(p_change_id) );
   Write_Debug('WF User Id  : ' || TO_CHAR(p_wf_user_id) );
   Write_Debug('Line Item Type : ' || p_line_item_type );
   Write_Debug('Line Item Key  : ' || p_line_process_name);
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --
    -- Don't try to get Parent Item Attributes from this procedure
    -- because this proc is setting PRAGMA  AUTONOMOUS_TRANSACTION
    -- If the user modify the Cost info to '0' in Worklfow Definition,
    -- the process can not get the Item Attributes because the parent item
    -- attr is not saved yet and here is in different session
    --

    -- Get Change Lines
    FOR line_rec IN c_lines (p_change_id => p_change_id)
    LOOP

        -- Initialize Line Item Key
        l_line_item_key := null ;

        -- Start Change Line Workflows
        --  FND_MSG_PUB.initialize ;
        Eng_Workflow_Util.StartWorkflow
        (  p_api_version       => 1.0
        ,  p_init_msg_list     => FND_API.G_FALSE
        ,  p_commit            => FND_API.G_FALSE
        ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status     => l_return_status
        ,  x_msg_count         => x_msg_count
        ,  x_msg_data          => x_msg_data
        ,  p_item_type         => p_line_item_type
        ,  x_item_key          => l_line_item_key
        ,  p_process_name      => p_line_process_name
        ,  p_change_line_id    => line_rec.change_line_id
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_host_url          => p_host_url
        ,  p_parent_item_type  => p_item_type
        ,  p_parent_item_key   => p_item_key
        ,  p_debug             => l_debug
        ,  p_output_dir        => l_output_dir
        ,  p_debug_filename    => l_debug_filename || TO_CHAR(line_rec.change_line_id)
        ) ;

        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS
        THEN

           x_return_status := l_return_status ;

        END IF ;

IF g_debug_flag THEN
   Write_Debug('After call Eng_Workflow_Util.StartWorkflow' ) ;
   Write_Debug('Return Status: '     || l_return_status ) ;
   Write_Debug('Return Message: '    || x_msg_data ) ;
   Write_Debug('Started Change Line Id : ' || TO_CHAR(line_rec.change_line_id) ) ;
   Write_Debug('Started CL WF Item Type: ' || p_line_item_type ) ;
   Write_Debug('Started CL WF Item Kye: ' || l_line_item_key ) ;
   Write_Debug('Started CL WF Process Name: ' || p_line_process_name ) ;
END IF ;


    END LOOP ;



    IF x_return_status =  FND_API.G_RET_STS_SUCCESS
    THEN

        -- COMMENT OUT  PRAGMA  AUTONOMOUS_TRANSACTION
        -- COMMIT ;
        NULL ;

    ELSE

        -- COMMENT OUT  PRAGMA  AUTONOMOUS_TRANSACTION
        -- ROLLBACK ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


EXCEPTION
    WHEN OTHERS THEN
    -- ROLLBACK ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END StartAllLineWorkflows ;



PROCEDURE SetLineAssigneeRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetLineAssigneeRole';

    l_change_line_id           NUMBER ;
    l_line_assignee_party_id   NUMBER ;
    l_line_creator_user_id     NUMBER ;
    l_role_name                VARCHAR2(320) ;
    l_role_display_name        VARCHAR2(320) ;
    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetLineAssigneeRole Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Change Line Object Identifier
    GetChangeLineObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_line_id    => l_change_line_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Change Line Object Identifier . . . ' );
END IF ;

    -- Get Change Object Party
    GetChangeLineObjectParty
    ( p_change_line_id          => l_change_line_id
    , x_assignee_party_id       => l_line_assignee_party_id
    , x_creator_user_id         => l_line_creator_user_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Line Change Object Party . . . Assignee Party Id: ' || to_char(l_line_assignee_party_id) );
END IF ;

    -- Set Assignee to Role Users
    SetAssigneeToRoleUsers2( p_assignee_party_id => l_line_assignee_party_id
                           , x_role_users        => l_role_users
                            ) ;


IF g_debug_flag THEN
   Write_Debug('Set Assignee to Role Users . . . ' );
END IF ;


    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN

        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'LINE_ASSIGNEE_ROLE');

        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );


    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

IF g_debug_flag THEN
   Write_Debug('Exception in SetLineAssigneeRole: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;

END SetLineAssigneeRole ;


PROCEDURE SetLineReviewersRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_reviewer_type     IN  VARCHAR2 := 'STD'
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetLineReviewersRole';

    l_change_id                NUMBER ;
    l_change_line_id           NUMBER ;
    l_assignee_party_id        NUMBER ;
    l_requestor_party_id       NUMBER ;
    l_creator_user_id          NUMBER ;
    l_line_assignee_party_id   NUMBER ;
    l_line_creator_user_id     NUMBER ;
    l_role_name                VARCHAR2(320) ;
    l_role_display_name        VARCHAR2(320) ;
    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetLineReviewersRole Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('Reviewer Type     : ' || p_reviewer_type );
   Write_Debug('-----------------------------------------------------');
END IF ;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_flag THEN
   Write_Debug('Get Change Header and Line Object Identifier . . . ' );
END IF ;

    -- Get Change Object Identifier
    GetChangeObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
    ) ;

    -- Get Change Line Object Identifier
    GetChangeLineObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_line_id    => l_change_line_id
    ) ;


IF g_debug_flag THEN
   Write_Debug('Get Change Object Party . . . ' );
END IF ;


    -- Get Change Object Party
    GetChangeObjectParty
    ( p_change_id               => l_change_id
    , x_assignee_party_id       => l_assignee_party_id
    , x_requestor_party_id      => l_requestor_party_id
    , x_creator_user_id         => l_creator_user_id
    ) ;


    -- Get Change Line Object Party
    GetChangeLineObjectParty
    ( p_change_line_id          => l_change_line_id
    , x_assignee_party_id       => l_line_assignee_party_id
    , x_creator_user_id         => l_line_creator_user_id
    ) ;


    IF p_reviewer_type <> 'NO_ASSIGNEE' THEN

        -- Set Assignee to Role Users
        SetAssigneeToRoleUsers2( p_assignee_party_id => l_line_assignee_party_id
                               , x_role_users        => l_role_users
                               ) ;

IF g_debug_flag THEN
   Write_Debug('Set Line_Assignee to Role Users . . . ' );
END IF ;

    END IF ;


    -- Set Line Creator to Role Users
    SetCreatorToRoleUsers2(  p_creator_user_id   => l_line_creator_user_id
                           , x_role_users        => l_role_users
                           ) ;

IF g_debug_flag THEN
   Write_Debug('Set Line Creator to Role Users . . . ' );
END IF ;


    -- Set Header Assignee to Role Users
    SetAssigneeToRoleUsers2( p_assignee_party_id => l_line_assignee_party_id
                           , x_role_users        => l_role_users
                            ) ;

IF g_debug_flag THEN
   Write_Debug('Set Header Assignee to Role Users . . . ' );
END IF ;

    -- Set Header Creator to Role Users
    SetCreatorToRoleUsers2(  p_creator_user_id   => l_creator_user_id
                           , x_role_users        => l_role_users
                           ) ;

IF g_debug_flag THEN
   Write_Debug('Set Creator to Role Users . . . ' );
END IF ;

    -- Set Header Requestor to Role Users
    SetRequestorToRoleUsers2(p_requestor_party_id => l_requestor_party_id
                           , x_role_users         => l_role_users
                           ) ;



IF g_debug_flag THEN
   Write_Debug('Set Requstor to Role Users . . . ' );
END IF ;

    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN


        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'LINE_REVIEWERS_ROLE');

        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );


    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

IF g_debug_flag THEN
   Write_Debug('Exception in SetLineReviewersRole: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;

END SetLineReviewersRole ;


PROCEDURE SetRoutePeopleRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_option            IN  VARCHAR2 := NULL
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetRoutePeopleRole';

    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;
    l_change_id           NUMBER ;
    l_assignee_party_id   NUMBER ;
    l_requestor_party_id  NUMBER ;
    l_creator_user_id     NUMBER ;
    l_role_name           VARCHAR2(320) ;
    l_role_display_name   VARCHAR2(320) ;
    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetRoutePeopleRole Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('-----------------------------------------------------');
END IF ;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Route Route Id
    GetRouteId
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_id          => l_route_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Route Id . . .  ' || to_char(l_route_id) );
END IF ;

    -- Get Route Step Id
    GetRouteStepId
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_step_id     => l_route_step_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Route Step Id . . .  ' || to_char(l_route_step_id) );
END IF ;


IF g_debug_flag THEN
   Write_Debug('Get Change Route People ');
END IF ;

    -- Set Route People to Role Users
    -- all people in the approval workflow that have already
    -- been notified (i.e. completed or in process steps)
    SetRoutePeopleToRoleUsers2( p_route_id     => l_route_id
                              , x_role_users   => l_role_users
                              ) ;


IF g_debug_flag THEN
   Write_Debug('Set Step People to Role Users . . . ' );
END IF ;


    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN


        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'ROUTE_PEOPLE_ROLE');

        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );


    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

IF g_debug_flag THEN
   Write_Debug('Exception in SetRoutePeopleRole: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;

END SetRoutePeopleRole ;




PROCEDURE SetStepPeopleRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetStepPeopleRole';

    l_route_step_id       NUMBER ;
    l_change_id           NUMBER ;
    l_assignee_party_id   NUMBER ;
    l_requestor_party_id  NUMBER ;
    l_creator_user_id     NUMBER ;
    l_role_name           VARCHAR2(320) ;
    l_role_display_name   VARCHAR2(320) ;
    -- Bug4532263
    -- l_role_users       VARCHAR2(2000) ;
    l_role_users          WF_DIRECTORY.UserTable ;

BEGIN


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetStepPeopleRole Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('-----------------------------------------------------');
END IF ;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Route Step Id
    GetRouteStepId
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_step_id     => l_route_step_id
    ) ;

IF g_debug_flag THEN
   Write_Debug('Get Route Step Id . . .  ' || to_char(l_route_step_id) );
END IF ;


IF g_debug_flag THEN
   Write_Debug('Get Change Route Step People ');
END IF ;

    -- Set Step People to Role Users
    SetStepPeopleToRoleUsers2( p_route_step_id     => l_route_step_id
                             , x_role_users        => l_role_users
                              ) ;


IF g_debug_flag THEN
   Write_Debug('Set Step People to Role Users . . . ' );
END IF ;


    -- Create adhoc role and add users to role
    IF ( l_role_users IS NOT NULL AND l_role_users.COUNT > 0 ) THEN


        l_role_name := WF_ENGINE.GetItemAttrText( p_item_type
                                                , p_item_key
                                                , 'STEP_PEOPLE_ROLE');

        l_role_display_name := l_role_name ;

        -- Set Adhoc Role and Users in WF Directory Adhoc Role
        SetWFAdhocRole2( p_role_name         => l_role_name
                      , p_role_display_name => l_role_display_name
                      , p_role_users        => l_role_users
                      , p_expiration_date   => NULL
                      );

    ELSE

        -- Return N as None
        x_return_status := Eng_Workflow_Util.G_RET_STS_NONE;

    END IF;

EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

IF g_debug_flag THEN
   Write_Debug('Exception in SetStepPeopleRole: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;

END SetStepPeopleRole ;


PROCEDURE DeleteAdhocRolesAndUsers
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'DeleteAdhocRolesAndUsers';


    TYPE Del_Roles IS TABLE OF VARCHAR2(320)
    INDEX BY BINARY_INTEGER ;

    l_role_names Del_Roles ;
    I PLS_INTEGER := 0 ;


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Eng Workflow Adhoc Roles Pre-Fix
    -- G_ADHOC_PARTY_ROLE
    -- G_REV_ROLE
    -- G_ASSIGNEE_ROLE
    -- G_OWNER_ROLE
    -- G_ROUTE_PEOPLE_ROLE
    -- G_STEP_PEOPLE_ROLE
    -- G_LINE_REV_ROLE
    -- G_LINE_ASSIGNEE_ROLE

    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_ADHOC_PARTY_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;

    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_REV_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;


    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_ASSIGNEE_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;

    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_OWNER_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;

    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_ROUTE_PEOPLE_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;


    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_STEP_PEOPLE_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;

    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_LINE_REV_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;

    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => Eng_Workflow_Util.G_LINE_ASSIGNEE_ROLE
                       , p_item_type   => p_item_type
                       , p_item_key    => p_item_key ) ;



    FOR i IN l_role_names.FIRST..l_role_names.LAST
    LOOP

        DeleteRoleAndUsers(p_role_name => l_role_names(i) ) ;

    END LOOP ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
            );
    END IF;

END DeleteAdhocRolesAndUsers ;


PROCEDURE CreateAction
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_notification_id   IN  NUMBER
 ,  p_action_type       IN  VARCHAR2
 ,  p_comment           IN  VARCHAR2 := NULL
 ,  x_action_id         OUT NOCOPY NUMBER
 ,  p_assignee_id       IN  NUMBER    := NULL
 ,  p_raise_event_flag  IN  VARCHAR2 := FND_API.G_FALSE -- R12
 )
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'CreateAction';

    l_change_id           NUMBER ;
    l_object_name         VARCHAR2(30);
    l_comment             VARCHAR2(4000);

    l_performer_user_id   NUMBER;
    l_parent_action_id    NUMBER ;


    -- R12B
    l_route_object_name   VARCHAR2(30) ;
    l_change_line_id      NUMBER ;


    CURSOR  c_ntf  (p_notification_id NUMBER)
    IS
        SELECT fu.user_id
          FROM FND_USER fu
             , WF_NOTIFICATIONS wn
         WHERE fu.user_name = wn.recipient_role
           AND wn.notification_id = p_notification_id ;


BEGIN

--IF g_debug_flag THEN
--   Write_Debug('Eng_Workflow_Util.CreateAction Log');
--   Write_Debug('-----------------------------------------------------');
--   Write_Debug('Item Type         : ' || p_item_type );
--   Write_Debug('Item Key          : ' || p_item_key );
--   Write_Debug('Action Type       : ' || p_action_type );
--   Write_Debug('Comment           : ' || SUBSTR(p_comment,200));
--   Write_Debug('-----------------------------------------------------');
--END IF ;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Get Change Object Identifier
     GetChangeObject
     (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
     ) ;


     -- Get Action Id and set this as parent action id
     Eng_Workflow_Util.GetActionId
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_action_id         => l_parent_action_id
     ) ;


     -- Get Object Type
     -- l_object_name :=  GetChangeObjectName
     -- ( p_change_id           => l_change_id ) ;

     -- R12B
     -- Get Route Object Name
     Eng_Workflow_Util.GetRouteObject
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_route_object      => l_object_name
     ) ;


     -- Get Change Line Object Identifier
     Eng_Workflow_Util.GetChangeLineObject
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_change_line_id    => l_change_line_id
     ) ;


     IF ( l_change_line_id <= 0 OR l_object_name = G_ENG_CHANGE)
     THEN

         l_change_line_id := NULL ;
     END IF ;

-- IF g_debug_flag THEN
--   Debug('Set this as parent action id : ' || to_char(l_parent_action_id) );
--END IF ;


    IF p_comment IS NULL THEN

         /*
         l_comment :=  WF_NOTIFICATION.GetAttrText
                       ( nid   => p_notification_id
                       , aname => 'RESPONSE_COMMENT');
         */

         l_comment :=  WF_NOTIFICATION.GetAttrText
                       ( nid   => p_notification_id
                       , aname => 'WF_NOTE');

IF g_debug_flag THEN
   Write_Debug('Responded Comment: ' || SUBSTR(l_comment, 1, 200));
END IF ;


    ELSE

         l_comment := p_comment ;

    END IF ;

     -- Filter default value :  no value specified
     l_comment := DefaultNoValueFilter(p_text => l_comment ) ;


IF g_debug_flag THEN
   Write_Debug('Get Action Desc after filering: ' || SUBSTR(l_comment, 1, 200) );
END IF ;

     --
     -- We need to get the party id and the user id
     -- of the person adding the comments.  We are
     -- using the recipient role since the responder column
     -- sometimes contains the email address (or variation of it)
     -- rather than the user name when a user
     -- responds from an email client.
     --
     FOR ntf_rec  IN c_ntf (p_notification_id)
     LOOP
         l_performer_user_id  := ntf_rec.user_id ;

     END LOOP ;
IF g_debug_flag THEN
   Write_Debug('Before call ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action ' ) ;
END IF ;


     ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
     ( p_api_version           => 1.0
     , x_return_status         => x_return_status
     , x_msg_count             => x_msg_count
     , x_msg_data              => x_msg_data
     -- , p_init_msg_list         => FND_API.g_FALSE
     -- , p_commit                => FND_API.g_FALSE
     , p_action_type           => p_action_type
     , p_object_name           => l_object_name
     , p_object_id1            => l_change_id
     , p_object_id2            => l_change_line_id
     , p_object_id3            => NULL
     , p_object_id4            => NULL
     , p_object_id5            => NULL
     , p_parent_action_id      => l_parent_action_id
     , p_action_date           => SYSDATE
     , p_change_description    => l_comment
     , p_user_id               => l_performer_user_id
     , p_api_caller            => G_WF_CALL
     , x_change_action_id      => x_action_id
     , p_assignee_id           => p_assignee_id
     , p_raise_event_flag      => p_raise_event_flag -- R12
     );


IF g_debug_flag THEN
   Write_Debug('After call ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action ' ) ;
   Write_Debug('Return Status: '     || x_return_status ) ;
   Write_Debug('Return Message: '    || x_msg_data ) ;
   Write_Debug('Created Action id: ' || to_char(x_action_id ) ) ;
END IF ;



EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END CreateAction ;


PROCEDURE CreateRouteAction
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_change_id         IN  NUMBER   := NULL
 ,  p_change_line_id    IN  NUMBER   := NULL
 ,  p_action_type       IN  VARCHAR2
 ,  p_user_id           IN  NUMBER
 ,  p_parent_action_id  IN  NUMBER   := NULL
 ,  p_route_id          IN  NUMBER   := NULL
 ,  p_comment           IN  VARCHAR2 := NULL
 ,  x_action_id         OUT NOCOPY NUMBER
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
 ,  p_raise_event_flag  IN  VARCHAR2 := FND_API.G_FALSE -- R12
 )
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'CreateRouteAction';

    l_object_name         VARCHAR2(30);
    l_comment             VARCHAR2(4000);
    l_change_line_id      NUMBER ;


    l_classification_code          VARCHAR2(30) ;
    l_status_code                  NUMBER ;

    CURSOR  c_route  (p_route_id NUMBER)
    IS
        SELECT STATUS_CODE
             , CLASSIFICATION_CODE
             , OBJECT_NAME
             , OBJECT_ID1
          FROM ENG_CHANGE_ROUTES
         WHERE ROUTE_ID = p_route_id
           AND TEMPLATE_FLAG = Eng_Workflow_Util.G_RT_INSTANCE ;

BEGIN

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.CreateRouteAction Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id         : ' || TO_CHAR(p_change_id));
   Write_Debug('Change Line Id    : ' || TO_CHAR(p_change_line_id));
   Write_Debug('Action Type       : ' || p_action_type );
   Write_Debug('User Id           : ' || TO_CHAR(p_user_id));
   Write_Debug('Parent Action Id  : ' || TO_CHAR(p_parent_action_id));
   Write_Debug('Route Id          : ' || TO_CHAR(p_route_id));
   Write_Debug('Comment           : ' || SUBSTR(p_comment,200));
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF p_change_line_id IS NOT NULL AND p_change_line_id > 0
    THEN

        -- Get Change Line Object Name
        l_object_name := GetChangeLineObjectName
        ( p_change_line_id  => p_change_line_id ) ;

        l_change_line_id := p_change_line_id ;

    ELSE

        -- Get Change Object Name
        l_object_name :=  GetChangeObjectName
        ( p_change_id  => p_change_id ) ;
        l_change_line_id := NULL ;

    END IF ;


    -- Filter default value :  no value specified
    l_comment := DefaultNoValueFilter(p_text => p_comment ) ;

IF g_debug_flag THEN
   Write_Debug('Get Action Desc after filering: ' || SUBSTR(l_comment, 1, 200) );
END IF ;


    IF p_change_id IS NOT NULL THEN

        -- Need to get status code in 115.10 Action Log UI
        -- and pass it to Action Log Util
        -- Get Route WF Info
        FOR l_route_rec IN c_route (p_route_id => p_route_id )
        LOOP

            l_classification_code := l_route_rec.CLASSIFICATION_CODE ;

        END LOOP ;

IF g_debug_flag THEN
   Write_Debug('Status Code/Classification Code: ' || l_classification_code);
END IF ;

        l_status_code := TO_NUMBER(l_classification_code) ;

    END IF ;


IF g_debug_flag THEN
   Write_Debug('Before call ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action ' ) ;
END IF ;

    ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action
    (  p_api_version           => 1.0
     , x_return_status         => x_return_status
     , x_msg_count             => x_msg_count
     , x_msg_data              => x_msg_data
     -- , p_init_msg_list         => FND_API.g_FALSE
     -- , p_commit                => FND_API.g_FALSE
     , p_action_type           => p_action_type
     , p_object_name           => l_object_name
     , p_object_id1            => p_change_id
     , p_object_id2            => l_change_line_id
     , p_object_id3            => NULL
     , p_object_id4            => NULL
     , p_object_id5            => NULL
     , p_parent_action_id      => p_parent_action_id
     , p_action_date           => SYSDATE
     , p_change_description    => l_comment
     , p_user_id               => p_user_id
     , p_api_caller            => G_WF_CALL
     , p_route_id              => p_route_id
     , p_status_code           => l_status_code
     , x_change_action_id      => x_action_id
     , p_raise_event_flag      => p_raise_event_flag
    );


IF g_debug_flag THEN
   Write_Debug('After call ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action ' ) ;
   Write_Debug('Return Status: '     || x_return_status ) ;
   Write_Debug('Return Message: '    || x_msg_data ) ;
   Write_Debug('Created Action id: ' || to_char(x_action_id ) ) ;
END IF ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END CreateRouteAction ;



PROCEDURE SyncChangeLCPhase
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_id          IN  NUMBER
 ,  p_api_caller        IN  VARCHAR2 := NULL -- or G_WF_CALL:'WF'
 )
IS

    -- PRAGMA  AUTONOMOUS_TRANSACTION;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SyncChangeLCPhase';
    l_route_status                 VARCHAR2(30);
    l_change_id                    NUMBER ;
    l_classification_code          VARCHAR2(30) ;
    l_status_code                  NUMBER ;

    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000) ;
    l_return_status     VARCHAR2(1) ;

    CURSOR  c_route  (p_route_id NUMBER)
    IS
        SELECT STATUS_CODE
             , CLASSIFICATION_CODE
             , OBJECT_NAME
             , OBJECT_ID1
          FROM ENG_CHANGE_ROUTES
         WHERE ROUTE_ID = p_route_id
           AND TEMPLATE_FLAG = Eng_Workflow_Util.G_RT_INSTANCE ;

BEGIN

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SyncChangeLCPhase Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Route Id          : ' || TO_CHAR(p_route_id));
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- In case that we have to use PRAGMA AUTONOMOUS_TRANSACTION,
    -- DON'T try to get Data/Item Attributes updated
    -- in previous wf activity from this procedure
    -- because this proc is setting PRAGMA  AUTONOMOUS_TRANSACTION
    -- If the user modify the Cost info to '0' in Worklfow Definition,
    -- the process can not get the updated DB/Item Attributes
    -- because the prev sessioin may not be saved yet
    -- and here is in different session
    --

    -- Need to modify this logic in original caller side
    -- or make the previous one is PRAGMA too
    -- Get Route WF Info
    FOR l_route_rec IN c_route (p_route_id => p_route_id )
    LOOP

        l_route_status := l_route_rec.STATUS_CODE ;
        l_change_id := l_route_rec.OBJECT_ID1 ;
        l_classification_code := l_route_rec.CLASSIFICATION_CODE ;

    END LOOP ;

    IF l_change_id IS NOT NULL THEN

IF g_debug_flag THEN
   Write_Debug('Before call LC Phase API:  ' ) ;
   Write_Debug('Change Id          : ' || TO_CHAR(l_change_id));
   Write_Debug('Route Status       : ' || l_route_status );
   Write_Debug('Status Code/Classification Code: ' || l_classification_code);

END IF ;
       l_status_code := TO_NUMBER(l_classification_code) ;


       -- Procedure to be called by WF to update lifecycle states of the change header,
       -- revised items, tasks and lines lifecycle states
       -- Bug4741642 fix
       -- We will not return the status to the caller
       -- even if ENG_CHANGE_LIFECYCLE_UTIL.Update_Lifecycle_States
       -- return status error
       -- otherwise the Approval Status will not be updated
       -- properly if it return error based on some validation
       -- like Mandatory task is not completed on Auto Promotion
       ENG_CHANGE_LIFECYCLE_UTIL.Update_Lifecycle_States
       (  p_api_version           => 1.0
        , p_commit                => FND_API.g_FALSE
        , p_init_msg_list         => FND_API.g_FALSE
        , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
        , p_debug                 => FND_API.G_FALSE
        , p_output_dir            => NULL -- '/appslog/bis_top/utl/plm115dv/log'
        , p_debug_filename        => NULL -- 'UpdateLCStatesFromWF.log' || to_char(p_route_id)
        , x_return_status         => l_return_status
        , x_msg_count             => l_msg_count
        , x_msg_data              => l_msg_data
        , p_change_id             => l_change_id
        , p_api_caller            => p_api_caller
        , p_wf_route_id           => p_route_id
        , p_status_code           => l_status_code
        , p_route_status          => l_route_status
       );

IF g_debug_flag THEN
   Write_Debug('After call LC Phase API:   ' ) ;
   Write_Debug('Return Status: '     || l_return_status ) ;
   Write_Debug('Return Message: '    || l_msg_data ) ;
END IF ;

    END IF ;


    -- Comment Out Here
    -- IF x_return_status =  FND_API.G_RET_STS_SUCCESS
    -- THEN
    --    COMMIT ;
    -- ELSE
    --   ROLLBACK ;
    -- END IF ;



EXCEPTION
    WHEN OTHERS THEN

    -- ROLLBACK ;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END SyncChangeLCPhase ;


PROCEDURE SetRouteParentChild
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_change_line_id    IN  NUMBER   := NULL
 ,  p_route_id          IN  NUMBER
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_parent_item_type  IN  VARCHAR2 := NULL
 ,  p_parent_item_key   IN  VARCHAR2 := NULL
 )
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetRouteParentChild';

    l_object_name         VARCHAR2(30);
    l_comment             VARCHAR2(4000);
    l_change_line_id      NUMBER ;

    l_hdr_route_item_type VARCHAR2(30);
    l_hdr_route_item_key  VARCHAR2(240);

    TYPE Line_Route_WF_Rec_Type  IS RECORD
    ( item_type VARCHAR2(30)
    , item_key  VARCHAR2(240)
    ) ;

    TYPE Line_Route_WF_Tbl_Type IS TABLE OF Line_Route_WF_Rec_Type
    INDEX BY BINARY_INTEGER ;

    I    PLS_INTEGER := 0 ;

    l_line_route_wf_tbl Line_Route_WF_Tbl_Type ;

    CURSOR  c_header_route_wf  (p_change_id NUMBER)
    IS
        SELECT wi.item_type
             , wi.item_key
          FROM ENG_ENGINEERING_CHANGES eec
             , ENG_CHANGE_ROUTES ecr
             , WF_ITEMS          wi
         WHERE wi.end_date IS NULL
           AND wi.item_key = ecr.wf_item_key
           AND wi.item_type = ecr.wf_item_type
           AND ecr.status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
           AND ecr.route_id  = eec.route_id
           AND eec.approval_status_type = Eng_Workflow_Util.G_REQUESTED
           AND eec.change_id = p_change_id ;


    CURSOR  c_line_route_wf  (p_change_id NUMBER)
    IS
        SELECT wi.item_type
             , wi.item_key
          FROM ENG_CHANGE_LINES  ecl
             , ENG_CHANGE_ROUTES ecr
             , WF_ITEMS          wi
         WHERE wi.end_date IS NULL
           AND wi.item_key = ecr.wf_item_key
           AND wi.item_type = ecr.wf_item_type
           AND ecr.status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
           AND ecr.route_id  = ecl.route_id
           -- AND ecl.parent_line_id IS NULL
           AND ecl.approval_status_type = Eng_Workflow_Util.G_REQUESTED
           AND ecl.sequence_number <> -1
           AND ecl.change_type_id <> -1
           AND ecl.change_id = p_change_id ;



BEGIN

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.CreateRouteAction Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id         : ' || TO_CHAR(p_change_id));
   Write_Debug('Change Line Id    : ' || TO_CHAR(p_change_line_id));
   Write_Debug('Route Id          : ' || TO_CHAR(p_route_id));
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('Parent Item Type  : ' || p_parent_item_type );
   Write_Debug('Parent Item Key   : ' || p_parent_item_key );
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check if this is setting header or line
    IF p_change_line_id IS NOT NULL AND p_change_line_id > 0
    THEN

        -- Get Header Route Workflow Info
        IF p_parent_item_type IS NOT NULL AND p_parent_item_key IS NOT NULL
        THEN

            l_hdr_route_item_type := p_parent_item_type ;
            l_hdr_route_item_key  := p_parent_item_key ;

        ELSE
            -- Get Header Route WF Info
            FOR hdr_wf_rec IN c_header_route_wf (p_change_id => p_change_id)
            LOOP

                l_hdr_route_item_type := hdr_wf_rec.item_type ;
                l_hdr_route_item_key  := hdr_wf_rec.item_key ;

            END LOOP ;


        END IF ;

        I := I + 1 ;
        l_line_route_wf_tbl(I).item_type :=  p_item_type ;
        l_line_route_wf_tbl(I).item_key  :=  p_item_key ;

    ELSE

        -- Get Header Route Workflow Info
        l_hdr_route_item_type := p_item_type ;
        l_hdr_route_item_key  := p_item_key ;

        -- Get Line Route Workflows
        FOR line_wf_rec IN c_line_route_wf (p_change_id => p_change_id)
        LOOP

            I := I + 1 ;
            l_line_route_wf_tbl(I).item_type :=  line_wf_rec.item_type ;
            l_line_route_wf_tbl(I).item_key  :=  line_wf_rec.item_key ;

        END LOOP ;



    END IF ;


    IF l_hdr_route_item_type IS NOT NULL AND l_hdr_route_item_key IS NOT NULL
    THEN

       FOR i IN 1..l_line_route_wf_tbl.COUNT LOOP

           -- Set Parent Worklfow Process
           WF_ENGINE.SetItemParent
            ( itemtype        => l_line_route_wf_tbl(i).item_type
            , itemkey         => l_line_route_wf_tbl(i).item_key
            , parent_itemtype => l_hdr_route_item_type
            , parent_itemkey  => l_hdr_route_item_key
            , parent_context  => NULL
            );

       END LOOP ;

    END IF ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END SetRouteParentChild ;


-- R12B
PROCEDURE SetRouteResponse
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_notification_id   IN  NUMBER
 ,  p_response_code     IN  VARCHAR2
 ,  p_comment           IN  VARCHAR2 := NULL
 ,  p_actid             IN  NUMBER   := NULL  -- added in R12B
 ,  p_funcmode          IN  VARCHAR2 := NULL  -- added in R12B
)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'SetRouteResponse';

    l_change_id           NUMBER ;
    l_object_name         VARCHAR2(30);
    l_comment             VARCHAR2(4000);
    l_step_id             NUMBER ;

    l_route_people_id              NUMBER ;
    -- l_assignee_type_code           VARCHAR2(30);
    -- l_original_assignee_id         NUMBER ;
    -- l_original_assignee_type_code  VARCHAR2(30);
    -- l_response_condition_code      VARCHAR2(30);
    -- l_adhoc_people_flag            VARCHAR2(1) ;

    l_performer_user_id   NUMBER;
    l_performer_party_id  NUMBER;

    -- For Action Log
    l_action_type         VARCHAR2(30) ;
    l_created_action_id   NUMBER ;

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_result              VARCHAR2(4000) ;


    -- R12B
    l_auto_revoke_resp    VARCHAR2(30) ;

    -- R12B
    l_route_id            NUMBER;
    l_change_line_id      NUMBER;
    l_target_obj_tbl      FND_TABLE_OF_VARCHAR2_30;
    l_obj_index           PLS_INTEGER ;
    l_person_id_tbl       FND_TABLE_OF_NUMBER ;
    l_person_idx          PLS_INTEGER ;

    l_base_change_mgmt_type_code VARCHAR2(30);
    l_message_text               VARCHAR2(400);

    CURSOR  c_route_person ( p_step_id            NUMBER
                           , p_notification_id    NUMBER )
    IS
        SELECT EngSecPeople.user_id
             , EngSecPeople.person_id
             , RoutePeople.route_people_id
             , RoutePeople.adhoc_people_flag
             , RoutePeople.assignee_type_code
             , RoutePeople.original_assignee_id
             , RoutePeople.original_assignee_type_code
             , RoutePeople.response_condition_code
        FROM   ENG_CHANGE_ROUTE_PEOPLE RoutePeople
             , ENG_SECURITY_PEOPLE_V EngSecPeople
             , WF_NOTIFICATIONS wn
        WHERE RoutePeople.assignee_id = EngSecPeople.person_id
        -- AND   RoutePeople.assignee_type_code = p_assignee_type_code
        AND   RoutePeople.step_id = p_step_id
        AND   EngSecPeople.user_name = wn.recipient_role
        AND   wn.notification_id = p_notification_id ;


    CURSOR  c_duplicate_ntf ( p_item_type          VARCHAR2
                            , p_item_key           VARCHAR2
                            , p_orig_ntf_id        NUMBER )
    IS
        SELECT ntf.NOTIFICATION_ID,
               ntf.RECIPIENT_ROLE,
               ntf.MESSAGE_NAME,
               ntf.message_type
        FROM   WF_ITEM_ACTIVITY_STATUSES wias,
               WF_NOTIFICATIONS  ntf ,
               WF_NOTIFICATIONS  orig_ntf
        WHERE ntf.STATUS = 'OPEN'
        AND   wias.NOTIFICATION_ID = ntf.group_id
        AND   wias.NOTIFICATION_ID IS NOT NULL
        AND (wias.ACTIVITY_STATUS = 'NOTIFIED' OR wias.ACTIVITY_STATUS = 'ERROR')
        AND wias.ITEM_TYPE = p_item_type
        AND wias.ITEM_KEY = p_item_key
        AND ntf.RECIPIENT_ROLE = orig_ntf.RECIPIENT_ROLE
        AND ntf.GROUP_ID = orig_ntf.GROUP_ID
        AND ntf.NOTIFICATION_ID <> orig_ntf.NOTIFICATION_ID
        AND orig_ntf.NOTIFICATION_ID = p_orig_ntf_id
        AND EXISTS  (SELECT 1
                     FROM WF_NOTIFICATION_ATTRIBUTES na,
                          WF_MESSAGE_ATTRIBUTES ma
                     WHERE na.NOTIFICATION_ID = ntf.NOTIFICATION_ID
                     AND   ma.MESSAGE_NAME = ntf.MESSAGE_NAME
                     AND   ma.MESSAGE_TYPE = ntf.MESSAGE_TYPE
                     AND   ma.NAME = na.NAME
                     AND   ma.SUBTYPE = 'RESPOND') ;



BEGIN

   -- For Test/Debug
   Check_And_Open_Debug_Session(p_debug_flag      => FND_API.G_FALSE
                              , p_output_dir      => NULL
                              , p_file_name       => NULL
                              ) ;


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetRouteResponse Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('NTF Id            : ' || to_char(p_notification_id) );
   Write_Debug('Response Code     : ' || p_response_code );
   Write_Debug('Comment           : ' || SUBSTR(p_comment,200));
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize Table var
    l_target_obj_tbl := FND_TABLE_OF_VARCHAR2_30();
    l_person_id_tbl := FND_TABLE_OF_NUMBER();

    -- Get Change Object Identifier
    GetChangeObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
    ) ;

    -- Get Object Type
    l_object_name :=  GetChangeObjectName
    ( p_change_id           => l_change_id ) ;

    -- Get Current Route Step Id
    GetRouteStepId
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_step_id     => l_step_id
    ) ;


     -- R12B
     -- Get Route Id
     GetRouteId
     (  p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_id          => l_route_id
     ) ;

     -- Get Change Object Identifier
     GetChangeLineObject
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_change_line_id    => l_change_line_id
     ) ;


   l_base_change_mgmt_type_code := GetBaseChangeMgmtTypeCode(p_change_id  =>l_change_id);

   if l_base_change_mgmt_type_code = 'NEW_ITEM_REQUEST'
	AND p_response_code ='APPROVED'
	AND ENG_NIR_UTIL_PKG.checkNIRValidForApproval(p_change_id => l_change_id)
   then
	-- fnd_message.set_name('ENG','ENG_NIR_CANNOT_APPROVE');
   --       app_exception.raise_exception;

    l_message_text := fnd_message.get_String('ENG','ENG_NIR_CANNOT_APPROVE');
    wf_core.token('ERRCODE', l_message_text);
    wf_core.raise('WFENG_NOTIFICATION_FUNCTION');

   end if;



    IF p_comment IS NULL THEN

         /*
         l_comment :=  WF_NOTIFICATION.GetAttrText
                       ( nid   => p_notification_id
                       , aname => 'RESPONSE_COMMENT');
         */

         l_comment :=  WF_NOTIFICATION.GetAttrText
                       ( nid   => p_notification_id
                       , aname => 'WF_NOTE');


IF g_debug_flag THEN
   Write_Debug('Responded Comment: ' || SUBSTR(l_comment, 1, 200));
END IF ;

    ELSE

         l_comment := p_comment ;

    END IF ;

     -- Filter default value :  no value specified
     l_comment := DefaultNoValueFilter(p_text => l_comment ) ;


IF g_debug_flag THEN
   Write_Debug('Get Action Desc after filering: ' || SUBSTR(l_comment, 1, 200) );
END IF ;

     -- In this reslease assignee type is only 'PERSON' for Workflow Routing Instance
     -- l_assignee_type_code := 'PERSON' ;

IF g_debug_flag THEN
   Write_Debug('Getting corresponding route people info ' ) ;
   Write_Debug('step_id : ' ||  to_char(l_step_id) ) ;
   Write_Debug('notification_id : ' || to_char(p_notification_id) ) ;
END IF ;

    FOR rtp_rec  IN c_route_person (  p_step_id => l_step_id
                                     , p_notification_id => p_notification_id )
    LOOP
         l_performer_user_id            := rtp_rec.user_id ;
         l_performer_party_id           := rtp_rec.person_id ;
         l_route_people_id              := rtp_rec.route_people_id ;

         --
         -- Comment Out: Not Used
         -- l_adhoc_people_flag            := rtp_rec.adhoc_people_flag ;
         -- l_assignee_type_code           := rtp_rec.assignee_type_code ;
         -- l_original_assignee_id         := rtp_rec.original_assignee_id ;
         -- l_original_assignee_type_code  := rtp_rec.original_assignee_type_code ;
         -- l_response_condition_code      := rtp_rec.response_condition_code ;

         /* COMMENT OUT
          * There is issue if user uses different session lang
          * between responding to ntf and viewing response
          * if we use UPDATE_ROW api, the response is only updated with
          * the lang record used while responding to ntf

IF g_debug_flag THEN
   Write_Debug('Calling Eng_Change_Route_People_Util.UPDATE_ROW - Route People Id: ' || l_route_people_id ) ;
END IF ;

         Eng_Change_Route_People_Util.UPDATE_ROW
         ( X_ROUTE_PEOPLE_ID => l_route_people_id ,
           X_REQUEST_ID => null ,
           X_ORIGINAL_SYSTEM_REFERENCE => null ,
           X_ASSIGNEE_ID => l_performer_party_id ,
           X_RESPONSE_DATE => SYSDATE ,
           X_STEP_ID => l_step_id,
           X_ASSIGNEE_TYPE_CODE => l_assignee_type_code,
           X_ADHOC_PEOPLE_FLAG => l_adhoc_people_flag,
           X_WF_NOTIFICATION_ID => p_notification_id,
           X_RESPONSE_CODE => p_response_code,
           X_RESPONSE_DESCRIPTION => l_comment ,
           X_LAST_UPDATE_DATE => SYSDATE ,
           X_LAST_UPDATED_BY => l_performer_user_id ,
           X_LAST_UPDATE_LOGIN => null,
           X_PROGRAM_ID        => null,
           X_PROGRAM_APPLICATION_ID => null ,
           X_PROGRAM_UPDATE_DATE    => null ,
           X_ORIGINAL_ASSIGNEE_ID   => l_original_assignee_id  ,
           X_ORIGINAL_ASSIGNEE_TYPE_CODE => l_original_assignee_type_code ,
           X_RESPONSE_CONDITION_CODE => l_response_condition_code
         ) ;
         */

         update ENG_CHANGE_ROUTE_PEOPLE set
           WF_NOTIFICATION_ID = p_notification_id,
           RESPONSE_CODE = p_response_code ,
           RESPONSE_DATE = SYSDATE ,
           LAST_UPDATE_DATE = SYSDATE ,
           LAST_UPDATED_BY = l_performer_user_id ,
           LAST_UPDATE_LOGIN = null
         where ROUTE_PEOPLE_ID = l_route_people_id ;

         update ENG_CHANGE_ROUTE_PEOPLE_TL set
           RESPONSE_DESCRIPTION = l_comment,
           LAST_UPDATE_DATE = SYSDATE ,
           LAST_UPDATED_BY = l_performer_user_id ,
           LAST_UPDATE_LOGIN = null ,
           SOURCE_LANG = userenv('LANG')
         where ROUTE_PEOPLE_ID = l_route_people_id ;


    END LOOP ;


    -- In case that Route Object is Change Object
    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

        l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  p_response_code
                         , p_convert_type      =>  'RESPONSE' ) ;

        -- Record Action
        Eng_Workflow_Util.CreateAction
        ( x_return_status         =>  l_return_status
        , x_msg_count             =>  l_msg_count
        , x_msg_data              =>  l_msg_data
        , p_item_type             =>  p_item_type
        , p_item_key              =>  p_item_key
        , p_notification_id       =>  p_notification_id
        , p_action_type           =>  l_action_type
        , x_action_id             =>  l_created_action_id
        ) ;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            x_return_status  :=   l_return_status ;
            x_msg_count      :=   l_msg_count ;
            x_msg_data       :=   l_msg_data ;
        END IF ;

    END IF ; -- changeId is not null


    -- Added in 115.10E
    -- To support closing duplicate ntf for same assignee, which is
    -- inserted by Ntf Reassignement etc
    FOR dup_ntf_rec  IN c_duplicate_ntf (  p_item_type => p_item_type
                                        ,  p_item_key  => p_item_key
                                        ,  p_orig_ntf_id => p_notification_id )
    LOOP

IF g_debug_flag THEN
   Write_Debug('Duplicate Ntf Exists and call RespondToDuplicateNtf: ' || dup_ntf_rec.NOTIFICATION_ID ) ;
END IF ;


        begin

           -- Check Notifiation Result to make sure
           -- this notifiaction has not been responded
           -- WF Code has cache mechanism
           -- So just querying table is not enough
           l_result := WF_NOTIFICATION.GetAttrText(nid => dup_ntf_rec.notification_id
                                                  ,aname => 'RESULT' ) ;

IF g_debug_flag THEN
   Write_Debug('Duplicate Ntf Result : ' || l_result ) ;
END IF ;
           IF l_result IS NULL THEN

IF g_debug_flag THEN
   Write_Debug('Result is null and call RespondToDuplicateNtf: ' || dup_ntf_rec.NOTIFICATION_ID ) ;
END IF ;

               Eng_Workflow_Util.RespondToDuplicateNtf( p_dupllicate_ntf_id => dup_ntf_rec.notification_id
                                                      , p_orig_ntf_id => p_notification_id
                                                      , p_responder => dup_ntf_rec.RECIPIENT_ROLE
                                                      ) ;
           END IF ;

        exception
            when others then
            -- The exception may be thrown for Digisig Enabled Ntf
            -- Ignore this
            -- The user has to respond to each ntf in that case
IF g_debug_flag THEN
   Write_Debug('RespondToDuplicateNtf Exception: ' || SQLERRM ) ;
END IF ;

        end ;

    END LOOP ; -- duplicate_ntf loop


    --
    -- R12B Modified to support AUTO_REVOKE_RESPONSE NTF Attribute
    -- If the response is the value specified in AUTO_REVOKE_RESPONSE NTF Attribute
    -- we will revoke roles on this wf assignee
    -- Record Route Response
    IF  ( p_funcmode = 'RESPOND'
          AND (   p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
               OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE
               OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE
              )
        )
    THEN

IF g_debug_flag THEN
   Write_Debug('Getting AUTO_REVOKE_RESPONSE NTF Attribute . . . '  ) ;
END IF ;

        -- R12B
        -- Need to revoke auto grant if the response is DECLIEND.
        l_auto_revoke_resp := WF_ENGINE.GetActivityAttrText
                                     (  p_item_type
                                      , p_item_key
                                      , p_actid
                                      , G_ATTR_AUTO_REVOKE_RESPONSE  -- aname
                                      , TRUE -- ignore_notfound
                                      ) ;


IF g_debug_flag THEN
   Write_Debug('AUTO_REVOKE_RESPONSE NTF Attribute : ' || l_auto_revoke_resp  ) ;
END IF ;

        IF ( l_auto_revoke_resp IS NOT NULL AND p_response_code = l_auto_revoke_resp )
        THEN

            l_obj_index := 0 ;
            l_person_idx := 0 ;
            IF ( p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE )
            THEN
                l_obj_index := l_obj_index + 1 ;
                l_target_obj_tbl.EXTEND ;
                l_target_obj_tbl(l_obj_index) := G_DOM_DOCUMENT_REVISION ;
            END IF ;


            l_person_id_tbl.EXTEND ;
            l_person_id_tbl(l_person_idx + 1) := l_performer_party_id ;


IF g_debug_flag THEN
    Write_Debug('Calling Eng_Workflow_Util.RevokeObjectRoles for this assignee: ' || l_performer_party_id );
END IF ;


            Eng_Workflow_Util.RevokeObjectRoles
            (   p_api_version               => 1.0
             ,  p_init_msg_list             => FND_API.G_FALSE        --
             ,  p_commit                    => FND_API.G_FALSE        --
             ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
             ,  p_debug                     => FND_API.G_FALSE
             ,  p_output_dir                => NULL
             ,  p_debug_filename            => NULL
             ,  x_return_status             => l_return_status
             ,  x_msg_count                 => l_msg_count
             ,  x_msg_data                  => l_msg_data
             ,  p_change_id                 => l_change_id
             ,  p_change_line_id            => l_change_line_id
             ,  p_route_id                  => l_route_id
             ,  p_step_id                   => l_step_id
             ,  p_person_ids                => l_person_id_tbl
             ,  p_target_objects            => l_target_obj_tbl
             ,  p_api_caller                => G_WF_CALL
             ,  p_revoke_option             => NULL
            ) ;

IF g_debug_flag THEN
    Write_Debug('After Eng_Workflow_Util.RevokeObjectRoles.' || l_return_status );
END IF ;

           --
           -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
           -- THEN
           --     RAISE FND_API.G_EXC_ERROR ;
           -- END IF ;

        END IF ; -- ( l_auto_revoke_resp IS NOT NULL AND p_response_code = l_auto_revoke_resp )


     END IF ;


EXCEPTION
    WHEN OTHERS THEN

IF g_debug_flag THEN
    Write_Debug('Eng_Workflow_Util.SetRouteResponse Unxexpected Error.' || SQLERRM);
END IF ;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END SetRouteResponse ;





PROCEDURE FindNextRouteStep
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_id          IN  NUMBER
 ,  x_step_id           OUT NOCOPY NUMBER
 ,  x_step_item_type    OUT NOCOPY VARCHAR2
 ,  x_step_process_name OUT NOCOPY VARCHAR2
 )
IS

    l_api_name          CONSTANT VARCHAR2(30) := 'FindNextRouteStep';

    CURSOR  c_next_step (p_route_id NUMBER)
    IS
      SELECT step_id,
             step_seq_num,
             wf_item_type,
             wf_process_name
        FROM ENG_CHANGE_ROUTE_STEPS
       WHERE route_id = p_route_id
         AND step_status_code = Eng_Workflow_Util.G_RT_NOT_STARTED
         AND step_start_date   IS NULL
         AND step_end_date    IS NULL
       ORDER BY 2 ASC ;

    recinfo c_next_step%rowtype;


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    OPEN c_next_step(p_route_id => p_route_id) ;
    FETCH c_next_step into recinfo;
    IF (c_next_step%notfound) THEN
        CLOSE c_next_step ;

    END IF;

    IF c_next_step%ISOPEN THEN
        CLOSE c_next_step ;
    END IF ;

    x_step_id           := recinfo.step_id ;
    x_step_item_type    := recinfo.wf_item_type ;
    x_step_process_name := recinfo.wf_process_name ;




EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END FindNextRouteStep ;


PROCEDURE StartNextRouteStep
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_item_type   IN  VARCHAR2
 ,  p_route_item_key    IN  VARCHAR2
 ,  p_route_id          IN  NUMBER
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2
 ,  x_step_id           OUT NOCOPY NUMBER
 ,  x_step_item_type    OUT NOCOPY VARCHAR2
 ,  x_step_item_key     OUT NOCOPY VARCHAR2
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2 := NULL
 ,  p_parent_object_id1  IN  NUMBER   := NULL
 ,  p_route_action_id   IN  NUMBER    := NULL
 )
IS

    -- PRAGMA  AUTONOMOUS_TRANSACTION;
    l_api_name          CONSTANT VARCHAR2(30) := 'StartNextRouteStep';

    l_step_process_name VARCHAR2(30) ;
    -- l_change_id         NUMBER ;
    -- l_change_notice     VARCHAR2(10) ;
    -- l_organization_id   NUMBER ;
    -- l_wf_user_id        NUMBER ;
    -- l_host_url          VARCHAR2(256) ;
    l_debug             VARCHAR2(1)    := FND_API.G_FALSE ;
    l_output_dir        VARCHAR2(240)  := NULL ;
    l_debug_filename    VARCHAR2(200)  := 'StartNextRouteStep.log' ;


BEGIN

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.StartNextRouteStep Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Route Item Type   : ' || p_route_item_type );
   Write_Debug('Route Item Key    : ' || p_route_item_key );
   Write_Debug('Route Id          : ' || TO_CHAR(p_route_id) );
   Write_Debug('Change Id         : ' || TO_CHAR(p_change_id) );
   Write_Debug('Change Line Id    : ' || TO_CHAR(p_change_line_id) );
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Don't try to get Parent Item Attributes from this procedure
    -- because this proc is setting PRAGMA  AUTONOMOUS_TRANSACTION
    -- If the user modify the Cost info to '0' in Worklfow Definition,
    -- the process can not get the Item Attributes because the parent item
    -- attr is not saved yet and here is in different session
    --

    -- Get Next Route Step Info
    FindNextRouteStep
    (  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_route_id          => p_route_id
    ,  x_step_id           => x_step_id
    ,  x_step_item_type    => x_step_item_type
    ,  x_step_process_name => l_step_process_name
    ) ;


    IF x_step_id IS NULL THEN

       x_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;
       RETURN ;

    END IF ;


    --  FND_MSG_PUB.initialize ;
    Eng_Workflow_Util.StartWorkflow
    (  p_api_version       => 1.0
    ,  p_init_msg_list     => FND_API.G_FALSE
    ,  p_commit            => FND_API.G_FALSE
    ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
    ,  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_item_type         => x_step_item_type
    ,  x_item_key          => x_step_item_key
    ,  p_process_name      => l_step_process_name
    ,  p_change_id         => p_change_id
    ,  p_change_line_id    => p_change_line_id
    ,  p_wf_user_id        => p_wf_user_id
    ,  p_host_url          => p_host_url
    ,  p_route_id          => p_route_id
    ,  p_route_step_id     => x_step_id
    ,  p_parent_item_type  => p_route_item_type
    ,  p_parent_item_key   => p_route_item_key
    ,  p_action_id         => p_route_action_id
    ,  p_debug             => l_debug
    ,  p_output_dir        => l_output_dir
    ,  p_debug_filename    => l_debug_filename
    ) ;

    IF x_return_status =  FND_API.G_RET_STS_SUCCESS
    THEN

        -- COMMENT OUT  PRAGMA  AUTONOMOUS_TRANSACTION
        -- COMMIT ;
        NULL ;

    ELSE

        -- COMMENT OUT  PRAGMA  AUTONOMOUS_TRANSACTION
        -- ROLLBACK ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

IF g_debug_flag THEN
   Write_Debug('After call Eng_Workflow_Util.StartWorkflow' ) ;
   Write_Debug('Return Status: '     || x_return_status ) ;
   Write_Debug('Return Message: '    || x_msg_data ) ;
   Write_Debug('Started Step Id : ' || x_step_id ) ;
   Write_Debug('Started Step WF Item Type: ' || x_step_item_type ) ;
   Write_Debug('Started Step WF Item Kye: ' || x_step_item_key ) ;
   Write_Debug('Started Step WF Process Name: ' || l_step_process_name ) ;
END IF ;


EXCEPTION
    WHEN OTHERS THEN

    -- ROLLBACK ;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END StartNextRouteStep ;


PROCEDURE AbortRouteSteps
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_item_type   IN  VARCHAR2
 ,  p_route_item_key    IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
 )
IS
    l_api_name          CONSTANT VARCHAR2(30) := 'AbortRouteSteps';

    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000) ;
    l_return_status     VARCHAR2(1) ;

    l_debug             VARCHAR2(1)    := FND_API.G_FALSE ;
    l_output_dir        VARCHAR2(240)  := NULL ;
    l_debug_filename    VARCHAR2(200)  := 'AbortRouteSteps.log' ;


    CURSOR  c_abort_step ( p_route_item_type VARCHAR2
                         , p_route_item_key  VARCHAR2 )
    IS

      SELECT wi.item_type     wf_item_type
           , wi.item_key      wf_item_key
           , wi.root_activity wf_process_name
      FROM   WF_ITEMS  wi
      WHERE  wi.parent_item_type = p_route_item_type
      AND    wi.parent_item_key = p_route_item_key
      AND    wi.item_type IN ( Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
                             , Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE
                             , Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE )
      AND    wi.end_date IS NULL ;

BEGIN

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.AbortRouteStepsLog');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Route Item Type   : ' || p_route_item_type );
   Write_Debug('Route Item Key    : ' || p_route_item_key );
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR abort_step_rec IN c_abort_step (  p_route_item_type => p_route_item_type
                                        , p_route_item_key => p_route_item_key )
    LOOP


IF g_debug_flag THEN
   Write_Debug('Aborting Route Step Worklfow . . . ') ;
   Write_Debug('Step Item Type   : ' || abort_step_rec.wf_item_type);
   Write_Debug('Step Item Key    : ' || abort_step_rec.wf_item_key);
END IF ;


        Eng_Workflow_Util.AbortWorkflow
        (  p_api_version       => 1.0
        ,  p_init_msg_list     => FND_API.G_FALSE
        ,  p_commit            => FND_API.G_FALSE
        ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status     => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data          => l_msg_data
        ,  p_item_type         => abort_step_rec.wf_item_type
        ,  p_item_key          => abort_step_rec.wf_item_key
        ,  p_process_name      => abort_step_rec.wf_process_name
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_debug             => l_debug
        ,  p_output_dir        => l_output_dir
        ,  p_debug_filename    => l_debug_filename
        ) ;


        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN

            x_return_status := l_return_status ;
            x_msg_count     := NVL(l_msg_count, 0) + NVL(l_msg_count,0) ;
            x_msg_data      := l_msg_data ;

        END IF ;

    END LOOP ;

IF g_debug_flag THEN
   Write_Debug('After call Eng_Workflow_Util.AbortWorkflow' ) ;
   Write_Debug('Return Status: '     || x_return_status ) ;
   Write_Debug('Return Message: '    || x_msg_data ) ;
END IF ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END AbortRouteSteps ;



PROCEDURE GrantChangeRoleToParty
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_role_name         IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_party_id          IN  NUMBER
 ,  p_start_date        IN  DATE
 ,  p_end_date          IN  DATE := NULL
 )
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'GrantChangeRoleToParty';

    l_grant_guid    FND_GRANTS.GRANT_GUID%TYPE ;
    l_return_status VARCHAR2(3) ;


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;



    EGO_SECURITY_PUB.grant_role_guid
          ( p_api_version        => 1.0 ,
            p_role_name          => p_role_name ,
            p_object_name        => GetChangeObjectName(p_change_id)  ,
            p_instance_type      => 'INSTANCE' ,
            p_instance_set_id    => NULL ,
            p_instance_pk1_value => TO_CHAR(p_change_id) ,
            p_instance_pk2_value => NULL ,
            p_instance_pk3_value => NULL ,
            p_instance_pk4_value => NULL ,
            p_instance_pk5_value => NULL ,
            p_party_id           => p_party_id ,
            p_start_date         => NVL(p_start_date,SYSDATE) ,
            p_end_date           => p_end_date ,
            x_return_status      => l_return_status ,
            x_errorcode          => x_msg_data ,
            x_grant_guid         => l_grant_guid
            );


    --
    -- EGO Security pub returns T if the action is success
    -- and  F on failure
    --
    IF ( l_return_status = FND_API.G_TRUE OR
         l_return_status = FND_API.G_FALSE )
    THEN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        x_return_status := FND_API.G_RET_STS_ERROR ;

    END IF ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END GrantChangeRoleToParty ;


PROCEDURE StartLineRoutes
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2 := NULL
)
IS

    PRAGMA  AUTONOMOUS_TRANSACTION;
    l_api_name          CONSTANT VARCHAR2(30) := 'StartLineRoutes';

    l_return_status     VARCHAR2(1) ;
    l_line_item_key     VARCHAR2(240)  ;
    l_change_id         NUMBER ;

    l_debug             VARCHAR2(1)    := FND_API.G_FALSE ;
    l_output_dir        VARCHAR2(240)  := '' ;
    l_debug_filename    VARCHAR2(200)  := 'StartLineRoutes.log' ;


    -- Targe Change Line Route
    -- Change Line Object
    -- Approval Status: NOT Approved and Approva Requested
    -- Status:  Not Cancelled or Completed
    -- Main Line
    -- Not Header Line
    -- Line Route: NOT_STARTED or throw exception from StartWorkflow API
    --             At least, we should refres route at OA Page level
    CURSOR  c_lines  (p_change_id NUMBER)
    IS
        SELECT ecl.change_line_id
             , ecl.route_id
             , ecr.wf_item_type
             , ecr.wf_process_name
          FROM ENG_CHANGE_LINES  ecl
             , ENG_CHANGE_ROUTES ecr
         WHERE  ( ecl.status_code <> Eng_Workflow_Util.G_CL_COMPLETED
                AND ecl.status_code <> Eng_Workflow_Util.G_CL_CANCELLED )
           AND ( ecl.approval_status_type <> Eng_Workflow_Util.G_APPROVED
                 AND ecl.approval_status_type <> Eng_Workflow_Util.G_REQUESTED )
           AND ecl.sequence_number <> -1
           -- AND ecl.parent_line_id IS NULL
           -- AND ecr.status_code = Eng_Workflow_Util.G_RT_NOT_STARTED
           AND ecl.change_type_id <> -1
           AND ecl.route_id  = ecr.route_id
           AND ecl.change_id = p_change_id ;


BEGIN

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.StartLineRoutes');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type   : ' || p_item_type );
   Write_Debug('Item Key    : ' || p_item_key );
   Write_Debug('Change Id   : ' || TO_CHAR(p_change_id) );
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to None:N
    l_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;
    x_return_status := Eng_Workflow_Util.G_RET_STS_NONE ;

    --
    -- Don't try to get Parent Item Attributes from this procedure
    -- because this proc is setting PRAGMA  AUTONOMOUS_TRANSACTION
    -- If the user modify the Cost info to '0' in Worklfow Definition,
    -- the process can not get the Item Attributes because the parent item
    -- attr is not saved yet and here is in different session
    --

    -- Get Change Lines
    FOR line_rec IN c_lines (p_change_id => p_change_id)
    LOOP

        -- Initialize Line Item Key
        l_line_item_key := null ;

        -- Start Change Line Workflows
        --  FND_MSG_PUB.initialize ;
        Eng_Workflow_Util.StartWorkflow
        (  p_api_version       => 1.0
        ,  p_init_msg_list     => FND_API.G_FALSE
        ,  p_commit            => FND_API.G_FALSE
        ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status     => l_return_status
        ,  x_msg_count         => x_msg_count
        ,  x_msg_data          => x_msg_data
        ,  p_item_type         => line_rec.wf_item_type
        ,  x_item_key          => l_line_item_key
        ,  p_process_name      => line_rec.wf_process_name
        ,  p_change_line_id    => line_rec.change_line_id
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_host_url          => p_host_url
        ,  p_parent_item_type  => p_item_type
        ,  p_parent_item_key   => p_item_key
        ,  p_debug             => l_debug
        ,  p_output_dir        => l_output_dir
        ,  p_debug_filename    => l_debug_filename || TO_CHAR(line_rec.change_line_id)
        ) ;

        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS
        THEN

           x_return_status := l_return_status ;

        END IF ;

IF g_debug_flag THEN
   Write_Debug('After call Eng_Workflow_Util.StartWorkflow' ) ;
   Write_Debug('Return Status: '     || l_return_status ) ;
   Write_Debug('Return Message: '    || x_msg_data ) ;
   Write_Debug('Started Change Line Id : ' || TO_CHAR(line_rec.change_line_id) ) ;
   Write_Debug('Started CL WF Item Type: ' || line_rec.wf_item_type) ;
   Write_Debug('Started CL WF Item Kye: ' || l_line_item_key ) ;
   Write_Debug('Started CL WF Process Name: ' || line_rec.wf_process_name ) ;
END IF ;


    END LOOP ;



    IF x_return_status =  FND_API.G_RET_STS_SUCCESS
       OR x_return_status = Eng_Workflow_Util.G_RET_STS_NONE
    THEN

        COMMIT ;

    ELSE

        ROLLBACK ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


EXCEPTION
    WHEN OTHERS THEN

    ROLLBACK ;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END StartLineRoutes ;

PROCEDURE CheckAllLineApproved
(   x_return_status        OUT NOCOPY VARCHAR2
 ,  x_msg_count            OUT NOCOPY NUMBER
 ,  x_msg_data             OUT NOCOPY VARCHAR2
 ,  p_change_id            IN  NUMBER
 ,  x_line_approval_status OUT NOCOPY NUMBER
)
IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CheckAllLineApproved';

    -- Targe Change Line Route
    -- Change Line Object
    -- Status:  'OPEN'
    -- Main Line
    -- Not Header Line
    -- Line Route: Exists
    CURSOR c_approved_line (p_change_id NUMBER )
    IS
        SELECT 'Non Approved Line Exists'
        FROM DUAL
        WHERE EXISTS ( SELECT null
                       FROM   ENG_CHANGE_LINES ecl
                       WHERE  ( ecl.status_code <> Eng_Workflow_Util.G_CL_COMPLETED
                                AND ecl.status_code <> Eng_Workflow_Util.G_CL_CANCELLED )
                       AND    ecl.approval_status_type <> Eng_Workflow_Util.G_APPROVED
                       AND    ecl.change_type_id <> -1
                       AND    ecl.sequence_number <> -1
                       -- AND ecl.parent_line_id IS NULL
                       AND    ecl.route_id IS NOT NULL
                       AND    ecl.change_id = p_change_id
                     ) ;


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_line_approval_status := Eng_Workflow_Util.G_APPROVED ;

    FOR l_approved_line_rec IN c_approved_line (p_change_id )
    LOOP

        x_line_approval_status := Eng_Workflow_Util.G_REQUESTED ;

    END LOOP ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END CheckAllLineApproved ;



FUNCTION GetFunctionWebHTMLCall (p_function_name IN  VARCHAR2)
RETURN VARCHAR2
IS

    l_web_html_call   VARCHAR2(240) ;

    c1_OAHP PLS_INTEGER ;
    c2_OAHP PLS_INTEGER ;
    OAHP_param VARCHAR2(100) ;
    c1_OASF PLS_INTEGER ;
    c2_OASF PLS_INTEGER ;
    OASF_param VARCHAR2(100) ;

    CURSOR  c_func ( p_function_name VARCHAR2)
    IS

      SELECT web_html_call
      FROM   FND_FORM_FUNCTIONS
      WHERE  function_name = p_function_name ;

BEGIN

    FOR func_rec IN c_func (p_function_name)
    LOOP

        l_web_html_call := func_rec.web_html_call;

    END LOOP ;

    /*
    -- No need to remove OAHP and OASF
    -- Comment Out:
    -- Remvoed OAHP Param from web_html_call
    -- Otherwise OAFrameWork throws NPE
    c1_OAHP := INSTR(l_web_html_call, '&OAHP' ) ;
    IF ( c1_OAHP <> 0 ) THEN
        c2_OAHP := INSTR(l_web_html_call,  '&', c1_OAHP + 1 ) ;

        IF (c2_OAHP = 0) THEN
           c2_OAHP := LENGTH(l_web_html_call) + 1  ;
        END IF ;

        OAHP_param :=  SUBSTR( l_web_html_call, c1_OAHP, (c2_OAHP - c1_OAHP)) ;

        l_web_html_call := REPLACE(l_web_html_call, OAHP_param , '') ;

    END IF ;

    c1_OASF := INSTR(l_web_html_call, '&OASF' ) ;

    IF ( c1_OASF <> 0 ) THEN
        c2_OASF := INSTR(l_web_html_call,  '&', c1_OASF + 1 ) ;

        IF (c2_OASF = 0) THEN

            c2_OASF := LENGTH(l_web_html_call) + 1  ;

        END IF ;

        OASF_param :=  SUBSTR( l_web_html_call, c1_OASF, (c2_OASF - c1_OASF)) ;

        l_web_html_call := REPLACE(l_web_html_call, OASF_param , '') ;

    END IF ;
    */

    RETURN l_web_html_call ;


END GetFunctionWebHTMLCall;



-- OBSOLETE
-- NOT USED
-- Called from Eng_Workflow_Pub.GRANT_ROLE_TO_STEP_PEOPLE
-- Moved to instance set grant approach
PROCEDURE GrantChangeRoleToStepPeople
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_step_id           IN  NUMBER
)
IS

    l_api_name                CONSTANT VARCHAR2(30) := 'GrantChangeRoleToStepPeople';

    l_msg_count               NUMBER ;
    l_msg_data                VARCHAR2(2000) ;
    l_return_status           VARCHAR2(1) ;


    l_assignee_id             NUMBER ;
    l_assignee_type_code      VARCHAR2(30);
    l_adhoc_people_flag       VARCHAR2(1) ;
    l_default_role_name       VARCHAR2(30);
    l_activity_condition_code VARCHAR2(30);
    l_performer_party_id      NUMBER;



    CURSOR  c_route_person ( p_step_id            NUMBER
                           , p_assignee_type_code VARCHAR2 )
    IS

        SELECT RoutePeople.assignee_id
             , RoutePeople.adhoc_people_flag
          FROM ENG_CHANGE_ROUTE_PEOPLE RoutePeople
         WHERE RoutePeople.assignee_type_code = p_assignee_type_code
           AND RoutePeople.assignee_id <> -1
           AND RoutePeople.step_id = p_step_id ;

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get Step Activity Attributes
    GetStepActAttributes
    ( p_step_id                 => p_step_id
    , x_default_role_name       => l_default_role_name
    , x_activity_condition_code => l_activity_condition_code ) ;


    -- In this reslease assignee type is only 'PERSON' for Worklfow Routing Instance
    l_assignee_type_code := 'PERSON' ;


    IF l_default_role_name IS NOT NULL
    THEN

        FOR rtp_rec  IN c_route_person (  p_step_id => p_step_id
                                        , p_assignee_type_code => l_assignee_type_code )
        LOOP
            l_assignee_id   := rtp_rec.assignee_id ;
            l_adhoc_people_flag := rtp_rec.adhoc_people_flag ;

            GrantChangeRoleToParty
            (   x_return_status     => l_return_status
             ,  x_msg_count         => l_msg_count
             ,  x_msg_data          => l_msg_data
             ,  p_role_name         => l_default_role_name
             ,  p_change_id         => p_change_id
             ,  p_party_id          => l_assignee_id
             ,  p_start_date        => SYSDATE
             ,  p_end_date          => NULL
             ) ;


            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN

                x_return_status := l_return_status ;
                x_msg_count     := NVL(l_msg_count, 0) + NVL(l_msg_count,0) ;
                x_msg_data      := l_msg_data ;

            END IF ;

        END LOOP ;

    END IF ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END GrantChangeRoleToStepPeople ;


--
-- VoteForResultType
-- Because of bug2885157,
-- copied from WF_STANDARD.VoteForResultType 115.46
-- and put Wf_Item_Activity_Status.ClearCache before calling
-- Wf_Item_Activity_Status.Notification_Status to get notification group id correctly
--
--
-- Standard Voting Function
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   result    -
--
-- USED BY ACTIVITIES
--
--   WFSTD.VoteForResultType
--
-- ACTIVITY ATTRIBUTES REFERENCED
--      VOTING_OPTION
--          - WAIT_FOR_ALL_VOTES  - Evaluate voting after all votes are cast
--                                - or a Timeout condition closes the voting
--                                - polls.  When a Timeout occurs the
--                                - voting percentages are calculated as a
--                                - percentage ofvotes cast.
--
--          - REQUIRE_ALL_VOTES   - Evaluate voting after all votes are cast.
--                                - If a Timeout occurs and all votes have not
--                                - been cast then the standard timeout
--                                - transition is taken.  Votes are calculated
--                                - as a percenatage of users notified to vote.
--
--          - TALLY_ON_EVERY_VOTE - Evaluate voting after every vote or a
--                                - Timeout condition closes the voting polls.
--                                - After every vote voting percentages are
--                                - calculated as a percentage of user notified
--                                - to vote.  After a timeout voting
--                                - percentages are calculated as a percentage
--                                - of votes cast.
--
--      "One attribute for each of the activities result type codes"
--
--          - The standard Activity VOTEFORRESULTTYPE has the WFSTD_YES_NO
--          - result type assigned.
--          - Thefore activity has two activity attributes.
--
--                  Y       - Percenatage required for Yes transition
--                  N       - Percentage required for No transition
--
PROCEDURE VoteForResultType
(   itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2)
IS

  -- Select all lookup codes for an activities result type
  cursor result_codes is
  select  wfl.lookup_code result_code
  from    wf_lookups wfl,
          wf_activities wfa,
          wf_process_activities wfpa,
          wf_items wfi
  where   wfl.lookup_type         = wfa.result_type
  and     wfa.name                = wfpa.activity_name
  and     wfi.begin_date          >= wfa.begin_date
  and     wfi.begin_date          < nvl(wfa.end_date,wfi.begin_date+1)
  and     wfpa.activity_item_type = wfa.item_type
  and     wfpa.instance_id        = actid
  and     wfi.item_key            = itemkey
  and     wfi.item_type           = itemtype;

  l_code_count    pls_integer;
  l_group_id      pls_integer;
  l_user          varchar2(320);
  l_voting_option varchar2(30);
  l_per_of_total  number;
  l_per_of_vote   number;
  l_per_code      number;
  per_success     number;
  max_default     pls_integer := 0;
  default_result  varchar2(30) := '';
  result          varchar2(30) := '';

  wf_invalid_command exception;

begin


IF g_debug_flag THEN
   Write_Debug('Start VoteForResultType ...' );
END IF ;

  -- Do nothing unless in RUN or TIMEOUT modes
  if  (funcmode <> wf_engine.eng_run)
  and (funcmode <> wf_engine.eng_timeout) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.VotForResultType');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Always clear the cache first
  -- Bug2885157
  -- so it should be safe to force reading from
  -- the database.
  Wf_Item_Activity_Status.ClearCache;

  -- Get Notifications group_id for activity
  Wf_Item_Activity_Status.Notification_Status(itemtype,itemkey,actid,
      l_group_id,l_user);
  l_voting_option := Wf_Engine.GetActivityAttrText(itemtype,itemkey,
                         actid,'VOTING_OPTION');

IF g_debug_flag THEN
   Write_Debug('Got Ntf Group Id: ' || to_char(l_group_id) );
   Write_Debug('Got Voting Option : ' || l_voting_option );
END IF ;


  if (l_voting_option not in ('REQUIRE_ALL_VOTES', 'WAIT_FOR_ALL_VOTES',
                               'TALLY_ON_EVERY_VOTE')) then
    raise wf_invalid_command;
  end if;

  -- If here, then the mode is one of:
  --   a. TALLY_ON_ALL_VOTES
  --   b. WAIT_FOR_ALL_VOTES and timeout has occurred
  --   c. WAIT_FOR_ALL_VOTES and all votes are cast
  --   d. REQUIRE_ALL_VOTES and all votes are cast
  -- Tally votes.
  for result_rec in result_codes loop
    -- Tally Vote Count for this result code
    Wf_Notification.VoteCount(l_group_id,result_rec.result_code,
        l_code_count,l_per_of_total,l_per_of_vote);

IF g_debug_flag THEN
   Write_Debug('Couting result code : ' || result_rec.result_code  );
   Write_Debug('Code Count  : ' || to_char(l_code_count) );
   Write_Debug('Total percent : ' || to_char(l_per_of_total) );
   Write_Debug('Percent of vote  : ' || to_char(l_per_of_vote) );
END IF ;


    -- If this is timeout mode, then use the percent of votes cast so far.
    -- If this is run mode, then use the percent of total votes possible.
    if (funcmode = wf_engine.eng_timeout) then
      l_per_code := l_per_of_vote;
    else
      l_per_code := l_per_of_total;
    end if;

IF g_debug_flag THEN
   Write_Debug('Percent of code  : ' || to_char(l_per_code) );
END IF ;


    -- Get percent vote needed for this result to succeed
    per_success := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,
                       actid,result_rec.result_code);


IF g_debug_flag THEN
   Write_Debug('Percent of Success  : ' || to_char(per_success) );
END IF ;


    if (per_success is null) then

IF g_debug_flag THEN
   Write_Debug('Percent of Success  IS NULL  '  );
END IF ;

      -- Null value means this is a default result.
      -- Save the default result with max code_count.
      if (l_code_count > max_default) then
        max_default := l_code_count;
        default_result := result_rec.result_code;
      elsif (l_code_count = max_default) then
        -- Tie for default result.
        default_result := wf_engine.eng_tie;
      end if;
    else

IF g_debug_flag THEN
   Write_Debug('Percent of Success  IS NOT NULL  '  );
END IF ;

      -- If:
      --   a. % vote for this result > % needed for success OR
      --   b. % vote is 100% AND
      --   c. at least 1 vote for this result
      -- then this result succeeds.
      if (((l_per_code > per_success) or (l_per_code = 100)) and
          (l_code_count > 0))
      then
        if (result is null) then
          -- Save satisfied result.
          result := result_rec.result_code;

IF g_debug_flag THEN
   Write_Debug('Satisfied result ' || result  );
END IF ;

        else
          -- This is the second result to be satisfied.  Return a tie.
          resultout := wf_engine.eng_completed||':'||wf_engine.eng_tie;

IF g_debug_flag THEN
   Write_Debug('This is the second result to be satisfied ' );
END IF ;

          return;
        end if;
      end if;
    end if;
  end loop;

IF g_debug_flag THEN
   Write_Debug('Voting Count Result: ' || result );
END IF ;


  if (result is not null) then

IF g_debug_flag THEN
   Write_Debug('Satisfied result IS NOT NULL ' );
END IF ;

    -- Return the satisfied result code.
    resultout := wf_engine.eng_completed||':'||result;
  else

IF g_debug_flag THEN
   Write_Debug('Satisfied result IS NULL ' );
END IF ;


    -- If we get here no non-default results were satisfied.
    if (funcmode = wf_engine.eng_run and
        wf_notification.OpenNotificationsExist(l_group_id)) then
      -- Not timed out and still open notifications.
      -- Return waiting to continue voting.

IF g_debug_flag THEN
   Write_Debug('Not timed out and still open notifications. Return waiting to continue voting ' );
END IF ;

      resultout := wf_engine.eng_waiting;
    elsif (default_result is not null) then
      -- Either timeout or all notifications closed
      -- Return default result if one found.
      resultout := wf_engine.eng_completed||':'||default_result;

IF g_debug_flag THEN
   Write_Debug('Either timeout or all notifications closed. Return default result if one found ' );
END IF ;

    else
      -- Timeout or all notifications closed, and no default.
      -- Return nomatch

IF g_debug_flag THEN
   Write_Debug('Timeout or all notifications closed, and no default. Return nomatch ' );
END IF ;

      resultout := wf_engine.eng_completed||':'||wf_engine.eng_nomatch;
    end if;
  end if;
  return;

exception
  when wf_invalid_command then
    Wf_Core.Context('Wf_Standard', 'VoteForResultType', itemtype,
                    itemkey, to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', l_voting_option);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('Wf_Standard', 'VoteForResultType',itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;


end VoteForResultType ;

--
-- PeopleLevelVoteCount
--      Count the number of responses for a result_code
-- IN:
--      Gid -  Notification group id
--      ResultCode - Result code to be tallied
--      MandatoryResultCode - Result code to be tallied amang mandatory resonses
-- OUT:
--      ResultCount - Number of responses for ResultCode
--      PercentOfTotalPop - % ResultCode ( As a % of total population )
--      PercentOfVotes - % ResultCode ( As a % of votes cast )
--
procedure PeopleLevelVoteCount
                       (Gid                     in  number,
                        ResultCode              in  varchar2,
                        MandatoryResultCode     in  varchar2,
                        StepId                  in  number,
                        ResultCount             out nocopy number,
                        PercentOfTotalPop       out nocopy number,
                        PercentOfVotes          out nocopy number )
is
        l_code_count    pls_integer;
        l_total_pop     pls_integer;
        l_total_voted   pls_integer;
begin


IF g_debug_flag THEN
   Write_Debug('Start PeopleLevelVoteCount. . . for Step  '  || to_char(StepId) );
   Write_Debug('ResultCode '  || ResultCode );
   Write_Debug('MandatoryResultCode '  || MandatoryResultCode );
END IF ;

    IF  MandatoryResultCode IS NOT NULL AND
        ( MandatoryResultCode = ResultCode
          OR Eng_Workflow_Util.G_MANDATORY_RESP_ANY = MandatoryResultCode
        )  -- Added for Route
    THEN

        --
        --
        --
        SELECT COUNT(*)
        INTO   l_total_pop
        FROM   ENG_CHANGE_ROUTE_PEOPLE RoutePeople
             , EGO_USER_V  UserV
             , WF_NOTIFICATIONS wn
        WHERE RoutePeople.assignee_id = UserV.party_id
        AND   RoutePeople.response_condition_code = 'MANDATORY'
        AND   RoutePeople.step_id = StepId
        AND   UserV.user_name = wn.recipient_role
        AND   wn.group_id = Gid;


        SELECT COUNT(*)
        INTO   l_total_voted
        FROM   ENG_CHANGE_ROUTE_PEOPLE RoutePeople
             , EGO_USER_V  UserV
             , WF_NOTIFICATIONS wn
        WHERE RoutePeople.assignee_id = UserV.party_id
        AND   RoutePeople.response_condition_code = 'MANDATORY'
        AND   RoutePeople.step_id = StepId
        AND   UserV.user_name = wn.recipient_role
        AND   wn.status  = 'CLOSED'
        AND   wn.group_id = Gid;


        SELECT COUNT(*)
        INTO   l_code_count
        FROM   ENG_CHANGE_ROUTE_PEOPLE RoutePeople
             , EGO_USER_V  UserV
             , WF_NOTIFICATION_ATTRIBUTES wfna
             , WF_NOTIFICATIONS wn
        WHERE RoutePeople.assignee_id = UserV.party_id
        AND   RoutePeople.response_condition_code = 'MANDATORY'
        AND   RoutePeople.step_id = StepId
        AND   UserV.user_name = wn.recipient_role
        AND   wfna.name              = 'RESULT'
        AND   wfna.text_value        = ResultCode
        AND   wn.notification_id     = wfna.notification_id
        AND   wn.status              = 'CLOSED'
        AND   wn.group_id            = Gid;

        ResultCount := l_code_count;



IF g_debug_flag THEN
   Write_Debug('After Query Data for Step Assigness. . .'  );
   Write_Debug('l_total_pop: '  || to_char(l_total_pop) );
   Write_Debug('l_total_voted: '  || to_char(l_total_voted) );
   Write_Debug('l_code_count: '  || to_char(l_code_count) );
END IF ;

        IF ( Eng_Workflow_Util.G_MANDATORY_RESP_ANY = MandatoryResultCode )
        THEN

IF g_debug_flag THEN
   Write_Debug('In case Mandaotry Response Code is ANY. . .'  );
END IF ;

            --
            -- Prevent division by zero if group has no notifications
            --
            if ( l_total_pop = 0 ) then
                --
                PercentOfTotalPop := 0;
                --
            else
                --
                PercentOfTotalPop := l_code_count/l_total_pop*100;
                --
            end if;

            --
            -- Prevent division by zero if nobody votes
            --
            if ( l_total_voted = 0 ) then
                --
                PercentOfVotes := 0;
                --
            else
                -- Need to wait until all mandatory assignees repond
                IF l_total_voted = l_total_pop THEN

IF g_debug_flag THEN
   Write_Debug('Total Vote and Total Pop is same.  PercentOfVotes is 100. . .'  );
END IF ;
                    PercentOfVotes := 100;

                ELSE
IF g_debug_flag THEN
   Write_Debug('Total Vote and Total Pop is NOT  same.  PercentOfVotes is 0. . .'  );
END IF ;

                    PercentOfVotes := 0 ;

                END IF ;
                --
            end if;


        ELSE

            --
            -- Prevent division by zero if group has no notifications
            --
            if ( l_total_pop = 0 ) then
                --
                PercentOfTotalPop := 0;
                --
            else
                --
                PercentOfTotalPop := l_code_count/l_total_pop*100;
                --
            end if;
            --
            -- Prevent division by zero if nobody votes
            --
            if ( l_total_voted = 0 ) then
                --
                PercentOfVotes := 0;
                --
            else
                --
                PercentOfVotes := l_code_count/l_total_voted*100;
                --
            end if;

        END IF ;


    ELSE

        Wf_Notification.VoteCount
                       (Gid                     => Gid ,
                        ResultCode              => ResultCode ,
                        ResultCount             => ResultCount,
                        PercentOfTotalPop       => PercentOfTotalPop,
                        PercentOfVotes          => PercentOfVotes) ;


    END IF ;


exception
    when others then
        wf_core.context('Eng_Workflow_Util',
                        'PeopleLevelVoteCount',
                         to_char(gid),
                          ResultCode );
        raise;
end PeopleLevelVoteCount;


--
-- PeopleLevelVoteForResultType
--
-- Route People Level Standard Voting Function
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   result    -
--
-- USED BY ACTIVITIES
--
--   Route Notofication Call Back Functions
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   VOTING_OPTION
--   Eng_Workflow_Util.G_PEOPLE   - Evaluate voting after every vote.
--                                - After every vote voting percentages are
--                                - calculated as a percentage of user specified as
--                                - mandatory notified to vote.  voting
--                                - percentages are calculated as a percentage
--                                - of votes cast.
--
--   "One attribute for each of the activities result type codes"
--   MANDATORY                    -- Specified MANDATORY result type code
--
--
PROCEDURE PeopleLevelVoteForResultType
(   itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2)
IS

  -- Select all lookup codes for an activities result type
  cursor result_codes is
  select  wfl.lookup_code result_code
  from    wf_lookups wfl,
          wf_activities wfa,
          wf_process_activities wfpa,
          wf_items wfi
  where   wfl.lookup_type         = wfa.result_type
  and     wfa.name                = wfpa.activity_name
  and     wfi.begin_date          >= wfa.begin_date
  and     wfi.begin_date          < nvl(wfa.end_date,wfi.begin_date+1)
  and     wfpa.activity_item_type = wfa.item_type
  and     wfpa.instance_id        = actid
  and     wfi.item_key            = itemkey
  and     wfi.item_type           = itemtype;

  l_code_count    pls_integer;
  l_group_id      pls_integer;
  l_user          varchar2(320);
  l_voting_option varchar2(30);
  l_per_of_total  number;
  l_per_of_vote   number;
  l_per_code      number;
  per_success     number;
  max_default     pls_integer := 0;
  default_result  varchar2(30) := '';
  result          varchar2(30) := '';

  l_mandatory_result  varchar2(30);
  l_route_step_id     number;

  wf_invalid_command exception;

begin


IF g_debug_flag THEN
   Write_Debug('Start PeopleLevelVoteForResultType...' );
END IF ;

  -- Do nothing unless in RUN or TIMEOUT modes
  if  (funcmode <> wf_engine.eng_run)
  and (funcmode <> wf_engine.eng_timeout) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Eng_Workflow_Util.PeopleLevelVoteForResultType');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Always clear the cache first
  -- Bug2885157
  -- so it should be safe to force reading from
  -- the database.
  Wf_Item_Activity_Status.ClearCache;


  -- Get Notifications group_id for activity
  Wf_Item_Activity_Status.Notification_Status(itemtype,itemkey,actid,
      l_group_id,l_user);

  -- Get Voting Option
  l_voting_option := Wf_Engine.GetActivityAttrText(itemtype,itemkey,
                         actid,'VOTING_OPTION');

  l_mandatory_result := Wf_Engine.GetActivityAttrText(itemtype,itemkey,
                         actid,'MANDATORY', true);


IF g_debug_flag THEN
   Write_Debug('Got Ntf Group Id: ' || to_char(l_group_id) );
   Write_Debug('Got Voting Option : ' || l_voting_option );
   Write_Debug('Got Mandotory Result Option : ' || l_mandatory_result );
END IF ;


  if (l_voting_option not in ('REQUIRE_ALL_VOTES', 'WAIT_FOR_ALL_VOTES',
                               'TALLY_ON_EVERY_VOTE'))
     AND (l_voting_option <> Eng_Workflow_Util.G_PEOPLE ) -- Added for Route
  then
    raise wf_invalid_command;
  end if;

  -- If here, then the mode is one of:
  --   a. TALLY_ON_ALL_VOTES
  --   b. WAIT_FOR_ALL_VOTES and timeout has occurred
  --   c. WAIT_FOR_ALL_VOTES and all votes are cast
  --   d. REQUIRE_ALL_VOTES and all votes are cast
  -- Tally votes.
  for result_rec in result_codes loop

    IF (l_voting_option = Eng_Workflow_Util.G_PEOPLE
        AND ( ( l_mandatory_result IS NOT NULL
                AND l_mandatory_result = result_rec.result_code )
            OR  l_mandatory_result =  Eng_Workflow_Util.G_MANDATORY_RESP_ANY
           )
        )
    THEN


IF g_debug_flag THEN
   Write_Debug('Calling Eng_Workflow_Util.PeopleLevelVoteCount . . .' );
   Write_Debug('Step Id : ' || to_char(l_route_step_id) );
END IF ;

        -- Get Route Step Id
        GetRouteStepId
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  x_route_step_id     => l_route_step_id
        ) ;

        -- Tally Vote Count for this result code
        -- in case that Votion Option is Assignee Level(PEOPLE)
        -- and it is reponse code should be tallied among mandatory responses
        Eng_Workflow_Util.PeopleLevelVoteCount
                       (Gid                     => l_group_id,
                        ResultCode              => result_rec.result_code,
                        MandatoryResultCode     => l_mandatory_result,
                        ResultCount             => l_code_count,
                        StepId                  => l_route_step_id,
                        PercentOfTotalPop       => l_per_of_total,
                        PercentOfVotes          => l_per_of_vote ) ;


    ELSE

        -- Tally Vote Count for this result code
        Wf_Notification.VoteCount(l_group_id,result_rec.result_code,
            l_code_count,l_per_of_total,l_per_of_vote);

    END IF ;


IF g_debug_flag THEN
   Write_Debug('Couting result code : ' || result_rec.result_code  );
   Write_Debug('Code Count  : ' || to_char(l_code_count) );
   Write_Debug('Total percent : ' || to_char(l_per_of_total) );
   Write_Debug('Percent of vote  : ' || to_char(l_per_of_vote) );
END IF ;


    -- If this is timeout mode, then use the percent of votes cast so far.
    -- If this is run mode, then use the percent of total votes possible.
    if (funcmode = wf_engine.eng_timeout) then
      l_per_code := l_per_of_vote;
    else
      l_per_code := l_per_of_total;
    end if;

IF g_debug_flag THEN
   Write_Debug('Percent of code  : ' || to_char(l_per_code) );
END IF ;


    -- Get percent vote needed for this result to succeed
    per_success := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,
                       actid,result_rec.result_code);


IF g_debug_flag THEN
   Write_Debug('Percent of Success  : ' || to_char(per_success) );
END IF ;


    if (per_success is null) then

IF g_debug_flag THEN
   Write_Debug('Percent of Success  IS NULL  '  );
END IF ;

      -- Null value means this is a default result.
      -- Save the default result with max code_count.
      if (l_code_count > max_default) then
        max_default := l_code_count;
        default_result := result_rec.result_code;
      elsif (l_code_count = max_default) then
        -- Tie for default result.
        default_result := wf_engine.eng_tie;
      end if;
    else

IF g_debug_flag THEN
   Write_Debug('Percent of Success  IS NOT NULL  '  );
END IF ;

      -- If:
      --   a. % vote for this result > % needed for success OR
      --   b. % vote is 100% AND
      --   c. at least 1 vote for this result
      -- then this result succeeds.
      if (((l_per_code > per_success) or (l_per_code = 100)) and
          (l_code_count > 0))
      then
        if (result is null) then
          -- Save satisfied result.
          result := result_rec.result_code;

IF g_debug_flag THEN
   Write_Debug('Satisfied result ' || result  );
END IF ;

        else
          -- This is the second result to be satisfied.  Return a tie.
          resultout := wf_engine.eng_completed||':'||wf_engine.eng_tie;

IF g_debug_flag THEN
   Write_Debug('This is the second result to be satisfied ' );
END IF ;

          return;
        end if;
      end if;
    end if;
  end loop;

IF g_debug_flag THEN
   Write_Debug('Voting Count Result: ' || result );
END IF ;


  if (result is not null) then

IF g_debug_flag THEN
   Write_Debug('Satisfied result IS NOT NULL ' );
END IF ;

    -- Return the satisfied result code.
    resultout := wf_engine.eng_completed||':'||result;
  else

IF g_debug_flag THEN
   Write_Debug('Satisfied result IS NULL ' );
END IF ;


    -- If we get here no non-default results were satisfied.
    if (funcmode = wf_engine.eng_run and
        wf_notification.OpenNotificationsExist(l_group_id)) then
      -- Not timed out and still open notifications.
      -- Return waiting to continue voting.

IF g_debug_flag THEN
   Write_Debug('Not timed out and still open notifications. Return waiting to continue voting ' );
END IF ;

      resultout := wf_engine.eng_waiting;
    elsif (default_result is not null) then
      -- Either timeout or all notifications closed
      -- Return default result if one found.
      resultout := wf_engine.eng_completed||':'||default_result;

IF g_debug_flag THEN
   Write_Debug('Either timeout or all notifications closed. Return default result if one found ' );
END IF ;

    else
      -- Timeout or all notifications closed, and no default.
      -- Return nomatch

IF g_debug_flag THEN
   Write_Debug('Timeout or all notifications closed, and no default. Return nomatch ' );
END IF ;

      resultout := wf_engine.eng_completed||':'||wf_engine.eng_nomatch;
    end if;
  end if;
  return;


exception
  when wf_invalid_command then
    Wf_Core.Context('Eng_Workflow_Util', 'PeopleLevelVoteForResultType', itemtype,
                    itemkey, to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', l_voting_option);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('Eng_Workflow_Util', 'PeopleLevelVoteForResultType',itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;


END PeopleLevelVoteForResultType ;


PROCEDURE RouteStepVoteForResultType
(   itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2)
IS

  l_voting_option  VARCHAR2(30);

BEGIN


IF g_debug_flag THEN
   Write_Debug('Start RouteStepVoteForResultType...' );
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || itemtype );
   Write_Debug('Item Key          : ' || itemkey );
   Write_Debug('Acttivity Id      : ' || to_char(actid));
   Write_Debug('-----------------------------------------------------');
END IF ;

  -- Get Voting Option
  l_voting_option := Wf_Engine.GetActivityAttrText(itemtype,itemkey,
                         actid,'VOTING_OPTION');



IF g_debug_flag THEN
   Write_Debug('Voting Option: ' || l_voting_option );
END IF ;

  if (l_voting_option in (Eng_Workflow_Util.G_WAIT_FOR_ALL_VOTES,
                          Eng_Workflow_Util.G_REQUIRE_ALL_VOTES,
                          Eng_Workflow_Util.G_TALLY_ON_EVERY_VOTE)
     )
  then


IF g_debug_flag THEN
   Write_Debug('Calling Eng_Workflow_Util.VoteForResultType . . . ' );
END IF ;

    Eng_Workflow_Util.VoteForResultType
                      ( itemtype
                      , itemkey
                      , actid
                      , funcmode
                      , resultout ) ;

  elsif (l_voting_option = Eng_Workflow_Util.G_PEOPLE)
  then


IF g_debug_flag THEN
   Write_Debug('Calling Eng_Workflow_Util.Eng_Workflow_Util.PeopleLevelVoteForResultType . . . ' );
END IF ;

    Eng_Workflow_Util.PeopleLevelVoteForResultType
                      ( itemtype
                      , itemkey
                      , actid
                      , funcmode
                      , resultout ) ;

  end if;


IF g_debug_flag THEN
   Write_Debug('RouteStepVoteForResultType Result: '  || resultout );
END IF ;


END RouteStepVoteForResultType ;


PROCEDURE ContinueHeaderRoute
(   x_return_status           OUT NOCOPY VARCHAR2
 ,  x_msg_count               OUT NOCOPY NUMBER
 ,  x_msg_data                OUT NOCOPY VARCHAR2
 ,  p_item_type               IN  VARCHAR2
 ,  p_item_key                IN  VARCHAR2
 ,  p_actid                   IN  NUMBER
 ,  p_waiting_activity        IN  VARCHAR2
 ,  p_waiting_flow_type       IN  VARCHAR2
 ,  x_resultout               IN OUT NOCOPY VARCHAR2
)
IS

    l_change_id            NUMBER ;
    l_line_approval_status NUMBER ;

    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER ;
    l_msg_data             VARCHAR2(200);

    l_parent_itemtype      varchar2(8);
    l_parent_itemkey       varchar2(240);
    dummy varchar2(240);

    CURSOR c_header_route_wf (p_change_id NUMBER)
    IS
        SELECT ecr.wf_item_type parent_item_type
             , ecr.wf_item_key  parent_item_key
        FROM ENG_CHANGE_ROUTES ecr
           , ENG_ENGINEERING_CHANGES eec
           , WF_ITEMS wi
        WHERE wi.item_type = ecr.wf_item_type
        AND   wi.item_key  = ecr.wf_item_key
        AND   wi.end_date IS NULL
        AND   ecr.route_id  = eec.route_id
        AND   eec.change_id = p_change_id  ;


    l_debug             VARCHAR2(1)    := FND_API.G_FALSE ;
    l_output_dir        VARCHAR2(240)  := NULL ;
    l_debug_filename    VARCHAR2(200)  := 'ContinueHeaderRoute.log' ;



BEGIN



IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.ContinueHeaderRouteLog');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_key );
   Write_Debug('Acttivity Id      : ' || to_char(p_actid));
   Write_Debug('Waiting Activity  : ' || p_waiting_activity );
   Write_Debug('Waiting Flow Type : ' || p_waiting_flow_type);
   Write_Debug('-----------------------------------------------------');
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  if  (p_waiting_flow_type = 'APPROVAL') then

    -- Get Change Object Identifier
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
    ) ;

    --
    -- Get Header Route worklfow parent details
    --
    FOR l_header_wf_rec IN c_header_route_wf(p_change_id => l_change_id )
    LOOP

        l_parent_itemtype := l_header_wf_rec.parent_item_type ;
        l_parent_itemkey  := l_header_wf_rec.parent_item_key ;


IF g_debug_flag THEN
   Write_Debug('Header Item Type         : ' || l_parent_itemtype );
   Write_Debug('Header Item Key          : ' || l_parent_itemkey);
END IF ;


    END LOOP ;

    IF l_parent_itemtype IS NOT NULL AND l_parent_itemkey IS NOT NULL
    THEN

IF g_debug_flag THEN
   Write_Debug('lock the parent item, so only one child can execute this at the time. ' );
END IF ;


        -- lock the parent item, so only one child can execute this at the time.
        SELECT  item_key
        INTO    dummy
        FROM    wf_items
        WHERE   item_type = l_parent_itemtype
        AND     item_key  = l_parent_itemkey
        FOR UPDATE ;

        Eng_Workflow_Util.CheckAllLineApproved
        (  x_return_status        => x_return_status
        ,  x_msg_count            => x_msg_count
        ,  x_msg_data             => x_msg_data
        ,  p_change_id            => l_change_id
        ,  x_line_approval_status => l_line_approval_status
        ) ;


IF g_debug_flag THEN
   Write_Debug('After calling CheckAllLineApproved, line appr status: ' || to_char(l_line_approval_status)  );
END IF ;

        IF l_line_approval_status = Eng_Workflow_Util.G_APPROVED
        THEN


            begin

IF g_debug_flag THEN
   Write_Debug('calling CompleteActivity . . . ');
END IF ;

               wf_engine.CompleteActivity
               (  l_parent_itemtype
                , l_parent_itemkey
                , p_waiting_activity
                , wf_engine.eng_null );

            exception
               when others then
                --
                -- If call to CompleteActivity cannot find activity, return null
                -- and wait for master flow
                --
                if ( wf_core.error_name = 'WFENG_NOT_NOTIFIED' ) then
                    wf_core.clear;
                    x_resultout := wf_engine.eng_null;
IF g_debug_flag THEN
   Write_Debug('call to CompleteActivity cannot find activity. . . ');
END IF ;
                else
                    raise;
                end if;
            end;

        END IF ;

    END IF ; -- parent item type and key are not null

    x_resultout := wf_engine.eng_null;
    return ;

  else
  -- p_waiting_flow is not APPROVAL
    null ;

  end if ; -- p_waiting_flow condition


END ContinueHeaderRoute ;


PROCEDURE WaitForLineRoute
(   x_return_status           OUT NOCOPY VARCHAR2
 ,  x_msg_count               OUT NOCOPY NUMBER
 ,  x_msg_data                OUT NOCOPY VARCHAR2
 ,  p_item_type               IN  VARCHAR2
 ,  p_item_key                IN  VARCHAR2
 ,  p_actid                   IN  NUMBER
 ,  p_continuation_activity   IN  VARCHAR2
 ,  p_continuation_flow_type  IN  VARCHAR2
 ,  x_resultout               IN OUT NOCOPY VARCHAR2
)
IS

    l_change_id            NUMBER ;
    l_line_approval_status NUMBER ;

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

BEGIN


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  if  (p_continuation_flow_type = 'APPROVAL') then

    -- Get Change Object Identifier
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_change_id         => l_change_id
    ) ;

    Eng_Workflow_Util.CheckAllLineApproved
    (  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_change_id         => l_change_id
    ,  x_line_approval_status => l_line_approval_status
    ) ;


    IF l_line_approval_status <> Eng_Workflow_Util.G_APPROVED
    THEN
        x_resultout := wf_engine.eng_notified ||':'||
                       wf_engine.eng_null ||':'||
                       wf_engine.eng_null;
    ELSE
        x_resultout := wf_engine.eng_null;
    END IF ;

    return ;

  else

    null ;

  end if ;

END WaitForLineRoute ;


PROCEDURE  START_RESPONSE_FYI_PROCESS
( p_itemtype                IN  VARCHAR2
, p_itemkey                 IN  VARCHAR2
, p_orig_response_option    IN  VARCHAR2  := NULL  -- ALL or ONE
, p_responded_ntf_id        IN  NUMBER
, p_responded_comment_id    IN  NUMBER    := NULL
, x_msg_count               OUT NOCOPY   NUMBER
, x_msg_data                OUT NOCOPY   VARCHAR2
, x_return_status           OUT NOCOPY   VARCHAR2
)
IS
    lUserId            NUMBER ;

    l_adhoc_party      VARCHAR2(30000);
    l_orig_adhoc_role  VARCHAR2(100) ;

    l_orig_user_id     NUMBER ;
    l_orig_party_id    NUMBER ;
    l_change_id        NUMBER ;
    l_item_key         NUMBER;


    CURSOR c_ntf_info (p_ntf_id NUMBER)
    IS

        SELECT UserV.user_id      user_id
        FROM   EGO_USER_V UserV
             , WF_NOTIFICATIONS wf
        WHERE  UserV.user_name = wf.recipient_role
        AND    wf.notification_id = p_ntf_id ;


    CURSOR c_person_id (p_user_id NUMBER)
    IS
        SELECT UserV.party_id  person_id
        FROM   EGO_USER_V UserV
        WHERE  UserV.user_id = p_user_id ;

BEGIN


    FOR ntf_info_rec IN c_ntf_info (p_ntf_id => p_responded_ntf_id)
    LOOP

        lUserId  := ntf_info_rec.user_id ;

    END LOOP ;


    -- Get Original user_id and party_id who launched workflow
    l_orig_user_id := wf_engine.GetItemAttrNumber
                                      ( p_itemtype
                                      , p_itemkey
                                      , 'WF_USER_ID'
                                      );


    FOR l_rec IN c_person_id (l_orig_user_id)
    LOOP

        l_orig_party_id := l_rec.person_Id ;

    END LOOP ;


    Eng_Workflow_util.GetChangeObject( p_item_type  => p_itemtype
                                     , p_item_key   => p_itemKey
                                     , x_change_id  => l_change_Id
                                     );


    -- create and start Response FYI process to send Resp FYI ntf
    Eng_Workflow_Util.StartWorkflow
    (   p_api_version       =>       1.0
     ,  p_init_msg_list     =>       FND_API.G_FALSE
     ,  p_commit            =>       FND_API.G_FALSE
     ,  p_validation_level  =>       FND_API.G_VALID_LEVEL_FULL
     ,  x_return_status     =>       x_return_status
     ,  x_msg_count         =>       x_msg_count
     ,  x_msg_data          =>       x_msg_data
     ,  p_item_type         =>       G_CHANGE_ACTION_ITEM_TYPE
     ,  x_item_key          =>       l_item_key
     ,  p_process_name      =>       G_RESPONSE_FYI_PROC
     ,  p_change_id         =>       l_change_id
     ,  p_change_line_id    =>       0
     ,  p_wf_user_id        =>       lUserId
     ,  p_host_url          =>       NULL
     ,  p_action_id         =>       p_responded_comment_id
     ,  p_adhoc_party_list  =>       l_orig_party_id
     ,  p_route_id          =>       0
     ,  p_route_step_id     =>       0
     ,  p_parent_item_type  =>       p_itemtype
     ,  p_parent_item_key   =>       p_itemkey
     ,  p_debug             =>       FND_API.G_FALSE
     ,  p_output_dir        =>       NULL
     ,  p_debug_filename    =>       'Eng_ChangeWF_Start.log'
    ) ;


END START_RESPONSE_FYI_PROCESS ;


PROCEDURE  StartValidateDefProcess
(   x_msg_count              OUT  NOCOPY  NUMBER
 ,  x_msg_data               OUT  NOCOPY  VARCHAR2
 ,  x_return_status          OUT  NOCOPY  VARCHAR2
 ,  x_val_def_item_key       OUT  NOCOPY  VARCHAR2
 ,  p_step_item_type         IN   VARCHAR2
 ,  p_step_item_key          IN   VARCHAR2
 ,  p_responded_ntf_id       IN   NUMBER
 ,  p_route_id               IN   NUMBER
 ,  p_route_step_id          IN   NUMBER
 ,  p_val_def_item_type      IN   VARCHAR2
 ,  p_val_def_process_name   IN   VARCHAR2
 ,  p_orig_response          IN   VARCHAR2  := NULL
 ,  p_host_url               IN   VARCHAR2  := NULL
)
IS
    PRAGMA  AUTONOMOUS_TRANSACTION;

    l_api_name          CONSTANT VARCHAR2(30) := 'StartValidateDefProcess';

    l_debug             VARCHAR2(1)    := FND_API.G_FALSE ;
    l_output_dir        VARCHAR2(240)  := NULL ;
    l_debug_filename    VARCHAR2(200)  := 'StartValidateDefProcess.log' ;

    l_resp_user_id     NUMBER ;
    l_adhoc_party      VARCHAR2(30000);
    l_orig_adhoc_role  VARCHAR2(100) ;

    l_orig_user_id     NUMBER ;
    l_orig_party_id    NUMBER ;
    l_change_id        NUMBER ;
    l_item_key         NUMBER;

    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000) ;
    l_return_status     VARCHAR2(1) ;

    CURSOR c_ntf_info (p_ntf_id NUMBER)
    IS

        SELECT UserV.user_id      user_id
        FROM   EGO_USER_V UserV
             , WF_NOTIFICATIONS wf
        WHERE  UserV.user_name = wf.recipient_role
        AND    wf.notification_id = p_ntf_id ;


     CURSOR c_person_id (p_user_id NUMBER)
     IS
        SELECT UserV.party_id person_id
        FROM   EGO_USER_V UserV
        WHERE  UserV.user_id = p_user_id ;

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS ;


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.StartValidateDefProcess Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Step Item Type   : ' || p_step_item_type );
   Write_Debug('Step Item Key    : ' || p_step_item_key );
   Write_Debug('Route Id         : ' || TO_CHAR(p_route_id) );
   Write_Debug('Step Id          : ' || TO_CHAR(p_route_step_id) );
   Write_Debug('Responded Ntf Id : ' || TO_CHAR(p_responded_ntf_id) );
   Write_Debug('-----------------------------------------------------');
END IF ;

    FOR ntf_info_rec IN c_ntf_info (p_ntf_id => p_responded_ntf_id)
    LOOP
        l_resp_user_id := ntf_info_rec.user_id ;
    END LOOP ;

    BEGIN
        l_return_status :=  FND_API.G_RET_STS_SUCCESS ;

        --  FND_MSG_PUB.initialize ;
        Eng_Workflow_Util.StartWorkflow
        (  p_api_version       => 1.0
        ,  p_init_msg_list     => FND_API.G_FALSE
        ,  p_commit            => FND_API.G_FALSE
        ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,  x_return_status     => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data          => l_msg_data
        ,  p_item_type         => p_val_def_item_type
        ,  x_item_key          => x_val_def_item_key
        ,  p_process_name      => p_val_def_process_name
        ,  p_wf_user_id        => l_resp_user_id
        ,  p_host_url          => p_host_url
        ,  p_route_id          => p_route_id
        ,  p_route_step_id     => p_route_step_id
        ,  p_adhoc_party_list  => l_resp_user_id
        ,  p_parent_item_type  => p_step_item_type
        ,  p_parent_item_key   => p_step_item_key
        ,  p_debug             => l_debug
        ,  p_output_dir        => l_output_dir
        ,  p_debug_filename    => l_debug_filename
        ) ;


IF g_debug_flag THEN
   Write_Debug('After call Eng_Workflow_Util.StartWorkflow' ) ;
   Write_Debug('Return Status: '     || l_return_status ) ;
   Write_Debug('Return Message: '    || l_msg_data ) ;
   Write_Debug('Started Val Def WF Item Type: ' || p_val_def_item_type ) ;
   Write_Debug('Started Val Def WF Item Kye: ' || x_val_def_item_key ) ;
   Write_Debug('Started Val Def WF Process Name: ' || p_val_def_process_name ) ;
END IF ;


        IF l_return_status =  FND_API.G_RET_STS_SUCCESS
        THEN

            COMMIT ;

        ELSE

            ROLLBACK ;

        END IF ;

    EXCEPTION
       WHEN OTHERS THEN
         -- Since the Def Validation Process is kind of
         -- just place folder for customization, we will not handle
         -- any exception here
         NULL ;

    END ;


EXCEPTION
    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
    END IF;

END StartValidateDefProcess ;



FUNCTION ConvertRouteStatusToActionType
( p_route_status_code IN   VARCHAR2
, p_convert_type      IN   VARCHAR2 := 'RESPONSE' -- 'RESPONSE' or 'WF_PROCESS'
)
RETURN VARCHAR2
IS

    l_action_type VARCHAR2(30) ;


BEGIN

    IF  p_convert_type = 'RESPONSE' THEN

        -- Convert Route Status to Action Type for User Response in Route
        IF p_route_status_code = Eng_Workflow_Util.G_RT_APPROVED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_APPROVED ;

        ELSIF p_route_status_code = Eng_Workflow_Util.G_RT_REJECTED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_REJECTED ;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_COMPLETED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_COMPLETED ;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_REPLIED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_REPLIED;


        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_TIME_OUT
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_TIMEOUT_WF;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_FORWARDED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_DELEGATED;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_TRANSFERRED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_TRANSFERRED;


        -- R12B
        -- Added for Line Workflow Request Response
        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_RECEIVED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_RECEIVED;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_DECLINED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_DECLINED;


        ELSE

            l_action_type := Eng_Workflow_Util.G_ACT_COMPLETED ;
        END IF ;

    ELSIF p_convert_type = 'WF_PROCESS' THEN
        -- Convert Route Status to Action Type for Workflow Process Status

        IF p_route_status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_STARTED;

        ELSIF p_route_status_code = Eng_Workflow_Util.G_RT_APPROVED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_APPROVED ;


        ELSIF p_route_status_code = Eng_Workflow_Util.G_RT_REJECTED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_REJECTED;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_COMPLETED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_COMPLETED;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_ABORTED
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_ABORTED;


        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_TIME_OUT
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_TIME_OUT;

        ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_ERROR -- Not Stupported yet
        THEN

            l_action_type := Eng_Workflow_Util.G_ACT_WF_PROCESS_ERROR ;

        ELSE

            l_action_type := Eng_Workflow_Util.G_ACT_WF_COMPLETED ;

        END IF ;

    END IF ;

    RETURN l_action_type ;

END ConvertRouteStatusToActionType ;



FUNCTION ConvNtfWFStatToDistLNStat
( p_route_status_code IN   VARCHAR2
, p_convert_type      IN   VARCHAR2 := NULL -- Future use, 'WF_PROCESS'
)
RETURN VARCHAR2
IS

    l_dist_line_status_code VARCHAR2(30) ;

BEGIN

    -- Convert Notification Line Route Status to Distribution Line Status
    IF p_route_status_code = Eng_Workflow_Util.G_RT_IN_PROGRESS
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_DIST_IN_PROGRESS;

    ELSIF p_route_status_code = Eng_Workflow_Util.G_RT_APPROVED
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_DISTRIBUTED ;


    ELSIF p_route_status_code = Eng_Workflow_Util.G_RT_REJECTED
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_NOT_DISTRIBUTED;

    ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_COMPLETED
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_DISTRIBUTED;

    ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_ABORTED
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_NOT_DISTRIBUTED;


    ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_TIME_OUT
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_NOT_DISTRIBUTED;

    ELSIF  p_route_status_code = Eng_Workflow_Util.G_RT_ERROR -- Not Stupported yet
    THEN

        l_dist_line_status_code := Eng_Workflow_Util.G_ACT_WF_PROCESS_ERROR ;

    ELSE

        l_dist_line_status_code := Eng_Workflow_Util.G_DIST_CL_NOT_DISTRIBUTED ;

    END IF ;

    RETURN l_dist_line_status_code ;


END ConvNtfWFStatToDistLNStat ;



PROCEDURE RespondToActReqCommentFromUI
(   x_return_status     OUT  NOCOPY VARCHAR2
 ,  x_msg_count         OUT  NOCOPY NUMBER
 ,  x_msg_data          OUT  NOCOPY VARCHAR2
 ,  x_processed_ntf_id  OUT  NOCOPY NUMBER
 ,  p_item_type         IN   VARCHAR2
 ,  p_item_key          IN   VARCHAR2
 ,  p_responder         IN   VARCHAR2
 ,  p_response_comment  IN   VARCHAR2  := NULL
 ,  p_action_source     IN   VARCHAR2  := NULL
)
IS

    l_api_name          CONSTANT VARCHAR2(30) := 'RespondToActReqCommentFromUI';

    CURSOR c_ntf_info (p_item_type  VARCHAR2
                     , p_item_key   VARCHAR2
                     , p_responder  VARCHAR2)
    IS

        SELECT ntf.NOTIFICATION_ID,
               ntf.RECIPIENT_ROLE,
               ntf.MESSAGE_NAME,
               ntf.message_type
        FROM   WF_ITEM_ACTIVITY_STATUSES wias,
               WF_NOTIFICATIONS  ntf
        WHERE ntf.STATUS = 'OPEN'
        AND   wias.NOTIFICATION_ID = ntf.group_id
        AND   wias.NOTIFICATION_ID IS NOT NULL
        AND (wias.ACTIVITY_STATUS = 'NOTIFIED' OR wias.ACTIVITY_STATUS = 'ERROR')
        AND wias.ITEM_TYPE = p_item_type
        AND wias.ITEM_KEY = p_item_key
        AND ntf.RECIPIENT_ROLE = p_responder
        AND EXISTS  (SELECT 1
                     FROM WF_NOTIFICATION_ATTRIBUTES na,
                          WF_MESSAGE_ATTRIBUTES ma
                     WHERE na.NOTIFICATION_ID = ntf.NOTIFICATION_ID
                     AND   ma.MESSAGE_NAME = ntf.MESSAGE_NAME
                     AND   ma.MESSAGE_TYPE = ntf.MESSAGE_TYPE
                     AND   ma.NAME = na.NAME
                     AND   ma.SUBTYPE = 'RESPOND') ;


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.RespondToActReqCommentFromUI Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type   : ' || p_item_type );
   Write_Debug('Item Key    : ' || p_item_key );
   Write_Debug('Responder         : ' || p_responder );
   Write_Debug('Response Comment  : ' || p_response_comment );
   Write_Debug('-----------------------------------------------------');
END IF ;

    -- Init processed_ntf_id
    x_processed_ntf_id := 0 ;

    -- Get the corresponding ntf Id for this workflow and responder
    -- At this time, we are not checking message name and message
    -- type cause cutomer may create a cutom message
    -- If customer customizes action request comment workflow process
    -- there is small chance this logic does not work
    FOR ntf_info_rec IN c_ntf_info (p_item_type => p_item_type
                                  , p_item_key   => p_item_key
                                  , p_responder  => p_responder)
    LOOP
        x_processed_ntf_id := ntf_info_rec.NOTIFICATION_ID ;
    END LOOP ;

IF g_debug_flag THEN
   Write_Debug('Notification Id  : ' || TO_CHAR(x_processed_ntf_id));
END IF ;


IF g_debug_flag THEN
   Write_Debug('Calling WF_NOTIFICATION.SetAttrText for RESULT' );
END IF ;


    IF x_processed_ntf_id IS NOT NULL AND  x_processed_ntf_id > 0
    THEN
        WF_NOTIFICATION.SetAttrText
                             ( nid    => x_processed_ntf_id
                             , aname  => 'RESULT'
                             , avalue => G_REPLY
                             );

IF g_debug_flag THEN
   Write_Debug('Calling WF_NOTIFICATION.SetAttrText for WF_NOTE' );
END IF ;

        WF_NOTIFICATION.SetAttrText
                           ( nid   => x_processed_ntf_id
                           , aname => 'WF_NOTE'
                           , avalue=> p_response_comment) ;

IF g_debug_flag THEN
    Write_Debug('Calling WF_NOTIFICATION.RESPOND' );
END IF ;

        WF_NOTIFICATION.RESPOND
        ( nid => x_processed_ntf_id -- nid in number
        , responder => p_responder  -- responder in varchar2 default null
        ) ;

    END IF ;


EXCEPTION
   WHEN OTHERS THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
   END IF;


END RespondToActReqCommentFromUI ;



--
--  Bug5136260
--  API name   : SetChangeOrderMRPFlag
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Change Order's Revised Item MFP Flag to then given mrp_flag
--               if a revised item is in Status=Draft, Open,Approval, Scheduled, Released
--  Parameters :p_change_id               IN  NUMBER    Change Id
--              p_mrp_flag                IN  NUMBER    1: Yes G_MRP_FLAG_YES
--                                                      2: No  G_MRP_FLAG_NO
--              p_api_caller              IN  VARCHAR2 := NULL -- or G_WF_CALL:'WF'
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--              x_return_status           OUT VARCHAR2
--
PROCEDURE SetChangeOrderMRPFlag
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_mrp_flag          IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER   := NULL
 ,  p_api_caller        IN  VARCHAR2 := NULL -- or G_WF_CALL:'WF'
)
IS

    l_api_name          CONSTANT VARCHAR2(30) := 'SetChangeOrderMRPFlag';

    l_fnd_user_id       NUMBER ;
    l_fnd_login_id      NUMBER ;
    l_base_cm_type_code VARCHAR2(30) ;

BEGIN


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.SetChangeOrderMRPFlag Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id    : ' || to_char(p_change_id) );
   Write_Debug('MFP Flag     : ' || to_char(p_change_id) );
   Write_Debug('WF User Id   : ' || to_char(p_wf_user_id) );
   Write_Debug('API Caller   : ' || p_api_caller );
   Write_Debug('-----------------------------------------------------');
END IF ;


    -- Check if this Change Object is Chagne Order by base cm type code
    l_base_cm_type_code := GetBaseChangeMgmtTypeCode(p_change_id) ;

    IF  l_base_cm_type_code =  'CHANGE_ORDER'
    THEN

IF g_debug_flag THEN
   Write_Debug('Change Object is Change Order');
END IF ;

        l_fnd_user_id       := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_fnd_login_id      := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

        -- FND_PROFILE package is not available for workflow (WF),
        -- therefore manually set WHO column values
        IF p_api_caller = 'WF'
        THEN
          l_fnd_user_id := p_wf_user_id ;
          l_fnd_login_id := '' ;
        END IF;

        -- Put dummy fnd user id if it's still null
        IF l_fnd_user_id IS NULL
        THEN
           l_fnd_user_id := -10000;
        END IF ;

        UPDATE eng_revised_items
        SET mrp_active = p_mrp_flag
         , last_update_date = SYSDATE
         , last_updated_by = l_fnd_user_id
         , last_update_login = l_fnd_login_id
        WHERE change_id = p_change_id
        AND status_type in (0, 1, 4, 7, 8) ;

IF g_debug_flag THEN
   Write_Debug('After updating mrp flag in revised teims');
END IF ;

    END IF ; -- Base CM Code is Change Order


EXCEPTION
   WHEN OTHERS THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
            FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME
            , l_api_name
            );
   END IF;


END SetChangeOrderMRPFlag ;


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/
PROCEDURE GetWorkflowMonitorURL
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_url_type          IN  VARCHAR2 := Eng_Workflow_Util.G_MONITOR_DIAGRAM
 ,  p_admin_mode        IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_option            IN  VARCHAR2 := NULL
 ,  x_url               OUT NOCOPY VARCHAR2
)
IS

   l_api_name         CONSTANT VARCHAR2(30) := 'GetWorkflowMonitorURL';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_YES              CONSTANT VARCHAR2(3)  := 'YES';
   l_NO               CONSTANT VARCHAR2(3)  := 'NO';
   l_admin_mode                VARCHAR2(3) ;
   l_apps_web_agent            VARCHAR2(240) ;
   l_wf_web_agent              VARCHAR2(2000) ;

BEGIN
   -- Standard Start of API savepoint
   -- No Need to set SAVEPOINT for this API
   -- SAVEPOINT GetWorkflowMonitorURL_Util ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(  l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME )
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF ;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- API body

   -- Get Admin Mode.
   IF FND_API.to_Boolean( p_admin_mode ) THEN
      l_admin_mode := l_YES ;
   ELSE
      l_admin_mode := l_NO ;
   END IF ;

   -- Get Web Agent
   l_apps_web_agent  := fnd_web_config.plsql_agent(help_mode => 'APPS')  ;
   l_wf_web_agent    := WF_CORE.Translate('WF_WEB_AGENT') ;



   IF p_url_type = Eng_Workflow_Util.G_MONITOR_ACCESSKEY
   THEN

      x_url := WF_MONITOR.GetAccessKey
                          (  x_item_type  => p_item_type
                           , x_item_key   => p_item_key
                           , x_admin_mode => l_admin_mode ) ;

   ELSIF p_url_type = Eng_Workflow_Util.G_MONITOR_DIAGRAM
   THEN

      x_url := WF_MONITOR.GetDiagramURL
                          (  x_agent      => l_apps_web_agent
                           , x_item_type  => p_item_type
                           , x_item_key   => p_item_key
                           , x_admin_mode => l_admin_mode ) ;

   ELSIF p_url_type = Eng_Workflow_Util.G_MONITOR_ENVELOPE
   THEN

      x_url := WF_MONITOR.GetEnvelopeURL
                          (  x_agent      => l_apps_web_agent
                           , x_item_type  => p_item_type
                           , x_item_key   => p_item_key
                           , x_admin_mode => l_admin_mode ) ;


   ELSIF p_url_type = Eng_Workflow_Util.G_MONITOR_ADVANCED_ENVELOPE
   THEN

      x_url := WF_MONITOR.GetAdvancedEnvelopeURL
                          (  x_agent      => l_apps_web_agent
                           , x_item_type  => p_item_type
                           , x_item_key   => p_item_key
                           , x_admin_mode => l_admin_mode
                           , x_options    => p_option ) ;


   END IF ;


   -- Standard check of p_commit.
   -- IF FND_API.To_Boolean( p_commit ) THEN
   --  COMMIT WORK;
   -- END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count  => x_msg_count
      ,  p_data   => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       -- ROLLBACK TO GetWorkflowMonitorURL_Util ;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       -- ROLLBACK TO GetWorkflowMonitorURL_Util ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

   WHEN OTHERS THEN
       -- ROLLBACK TO GetWorkflowMonitorURL_Util ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME
              , l_api_name
              );
       END IF;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

END GetWorkflowMonitorURL ;



PROCEDURE StartWorkflow
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  x_item_key          IN OUT NOCOPY VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2  := NULL
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := 'Eng_ChangeWF_Start.log'
)
IS

   l_object_name        VARCHAR2(30) ;
   l_object_id1         NUMBER ;
   l_parent_object_name VARCHAR2(30) ;
   l_parent_object_id1  NUMBER ;

BEGIN


   IF p_change_line_id IS NOT NULL AND p_change_line_id > 0
   THEN
       l_object_name :=  G_ENG_CHANGE_LINE ;
       l_object_id1  := p_change_line_id ;
       l_parent_object_name := G_ENG_CHANGE ;

       IF p_change_id IS NOT NULL AND p_change_id > 0
       THEN

          l_parent_object_id1 := p_change_id ;

       ELSE
          l_parent_object_id1 := GetParentChangeId(p_change_line_id => p_change_line_id);
       END IF ;

   ELSE

       l_object_name :=  G_ENG_CHANGE ;
       l_object_id1 := p_change_id ;

   END IF ;


   StartWorkflow
   (   p_api_version        => p_api_version
    ,  p_init_msg_list      => p_init_msg_list
    ,  p_commit             => p_commit
    ,  p_validation_level   => p_validation_level
    ,  x_return_status      => x_return_status
    ,  x_msg_count          => x_msg_count
    ,  x_msg_data           => x_msg_data
    ,  p_item_type          => p_item_type
    ,  x_item_key           => x_item_key
    ,  p_process_name       => p_process_name
    ,  p_object_name        => l_object_name
    ,  p_object_id1         => l_object_id1
    ,  p_object_id2         => NULL
    ,  p_object_id3         => NULL
    ,  p_object_id4         => NULL
    ,  p_object_id5         => NULL
    ,  p_parent_object_name => l_parent_object_name
    ,  p_parent_object_id1  => l_parent_object_id1
    ,  p_wf_user_id         => p_wf_user_id
    ,  p_host_url           => p_host_url
    ,  p_action_id          => p_action_id
    ,  p_adhoc_party_list   => p_adhoc_party_list
    ,  p_route_id           => p_route_id
    ,  p_route_step_id      => p_route_step_id
    ,  p_parent_item_type   => p_parent_item_type
    ,  p_parent_item_key    => p_parent_item_key
    ,  p_debug              => p_debug
    ,  p_output_dir         => p_output_dir
    ,  p_debug_filename     => p_debug_filename
   ) ;


END StartWorkflow ;


PROCEDURE StartWorkflow
(   p_api_version        IN  NUMBER
 ,  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit             IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status      OUT NOCOPY VARCHAR2
 ,  x_msg_count          OUT NOCOPY NUMBER
 ,  x_msg_data           OUT NOCOPY VARCHAR2
 ,  p_item_type          IN  VARCHAR2
 ,  x_item_key           IN OUT NOCOPY VARCHAR2
 ,  p_process_name       IN  VARCHAR2
 ,  p_object_name        IN  VARCHAR2
 ,  p_object_id1         IN  NUMBER
 ,  p_object_id2         IN  NUMBER    := NULL
 ,  p_object_id3         IN  NUMBER    := NULL
 ,  p_object_id4         IN  NUMBER    := NULL
 ,  p_object_id5         IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
 ,  p_wf_user_id         IN  NUMBER
 ,  p_host_url           IN  VARCHAR2  := NULL
 ,  p_action_id          IN  NUMBER    := NULL
 ,  p_adhoc_party_list   IN  VARCHAR2  := NULL
 ,  p_route_id           IN  NUMBER    := NULL
 ,  p_route_step_id      IN  NUMBER    := NULL
 ,  p_parent_item_type   IN  VARCHAR2  := NULL
 ,  p_parent_item_key    IN  VARCHAR2  := NULL
 ,  p_debug              IN  VARCHAR2  := FND_API.G_FALSE
 ,  p_output_dir         IN  VARCHAR2  := NULL
 ,  p_debug_filename     IN  VARCHAR2  := 'Eng_ChangeWF_Start.log'
)
IS

   l_api_name         CONSTANT VARCHAR2(30) := 'StartWorkflow';
   l_api_version      CONSTANT NUMBER       := 1.0;

   l_wf_user_role     VARCHAR2(320) ;
   l_wf_user_key      VARCHAR2(240) ;

   l_change_id        NUMBER ;
   l_change_line_id   NUMBER ;

   l_action_id        NUMBER ;
   l_action_type      VARCHAR2(30) ;
   l_api_caller       VARCHAR2(30) ;


   -- R12B for Grants
   l_return_status    VARCHAR2(1);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(3000);

   l_target_obj_tbl   FND_TABLE_OF_VARCHAR2_30;
   l_index            PLS_INTEGER ;



BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT StartWorkflow_Util;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(  l_api_version
                                       , p_api_version
                                       , l_api_name
                                       , G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;



    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;

    --  Initialize Other Variables
    IF p_object_name = G_ENG_CHANGE
    THEN

       l_change_id := p_object_id1 ;

    ELSIF p_object_name = G_ENG_CHANGE_LINE
    THEN

       l_change_line_id := p_object_id1 ;
       l_change_id := p_parent_object_id1 ;

    END IF ;

    IF p_action_id IS NULL THEN
       l_action_id     := 0 ;
    ELSE
       l_action_id     := p_action_id ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.StartWorkflow Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || x_item_key );
   Write_Debug('Process Name      : ' || p_process_name);
   Write_Debug('Object Name       : ' || p_object_name );
   Write_Debug('Object Id1        : ' || to_char(p_object_id1));
   Write_Debug('Change Id         : ' || to_char(l_change_id));
   Write_Debug('Change Line Id    : ' || to_char(l_change_line_id));
   Write_Debug('Host URL          : ' || p_host_url);
   Write_Debug('WF User Id        : ' || to_char(p_wf_user_id));
   Write_Debug('Action Id         : ' || to_char(p_action_id));
   Write_Debug('Adhoc Party List  : ' || p_adhoc_party_list);
   Write_Debug('Route Id          : ' || to_char(p_route_id));
   Write_Debug('Route Step Id     : ' || to_char(p_route_step_id));
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Initialize return status ' );
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------
    -- 1. ValidateWorkflowProcess:
    -- 2. CreateProcess:
    -- 2-1. SetItemUserKey:
    -- 2-2. SetItemOwner:
    -- 3. SetItemAttribute:
    -- 4. SetItemParent:
    -- 4-1. Additional Set
    -- 5. Execute Custom Hook:
    -- 6. StartProcess:

IF g_debug_flag THEN
   Write_Debug('1. ValidateProcess. . .');
END IF ;

    -- Call ValiadteWFProcess
    -- ValidateProcess
    ValidateProcess
    (  p_validation_level  => p_validation_level
    ,  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_item_type         => p_item_type
    ,  p_process_name      => p_process_name
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id
    ,  p_wf_user_id        => p_wf_user_id
    ,  p_host_url          => p_host_url
    ,  p_action_id         => p_action_id
    ,  p_adhoc_party_list  => p_adhoc_party_list
    ,  p_route_id          => p_route_id
    ,  p_route_step_id     => p_route_step_id
    ,  p_parent_item_type  => p_parent_item_type
    ,  p_parent_item_key   => p_parent_item_key
    ,  p_object_name        => p_object_name
    ,  p_object_id1         => p_object_id1
    ,  p_object_id2         => p_object_id2
    ,  p_object_id3         => p_object_id3
    ,  p_object_id4         => p_object_id4
    ,  p_object_id5         => p_object_id5
    ,  p_parent_object_name => p_parent_object_name
    ,  p_parent_object_id1  => p_parent_object_id1
    ) ;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;


    --
    -- R12B
    -- Check WF availability for Document LC Change Object
    --
IF g_debug_flag THEN
   Write_Debug('Document LC Change Object check. WF should not be started except Doc LC Phase WF. . .');
END IF ;

    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

        IF (     p_item_type <> G_CHANGE_ROUTE_ITEM_TYPE
            AND  p_item_type <>  G_CHANGE_ROUTE_DOC_STEP_TYPE
            AND  ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle( p_change_id   => l_change_id)
           )
        THEN

            IF p_item_type =  G_CHANGE_ACTION_ITEM_TYPE
            THEN

IF g_debug_flag THEN
   Write_Debug('CM Workflows except Doc Phse WF Routing are not supported in Document LC ChangeObject. return. .. ');
END IF ;
               -- At this time, not raising any error
               -- Set dummy item key
               x_item_key := Eng_Workflow_Util.G_RET_STS_NONE ;
               RETURN ;

            ELSE

IF g_debug_flag THEN
   Write_Debug('CM Workflows except Doc Phse WF Routing are not supported in Document LC ChangeObject. Raise Error. .. ');
END IF ;
               -- At this time, not raising any error

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF ;


        END IF ;

    END IF ;


IF g_debug_flag THEN
   Write_Debug('2. CreateProcess. . .');
END IF ;


   IF x_item_key  IS NULL THEN

       -- Get new item key
       x_item_key := GetNewItemKey ;

   END IF ;


IF g_debug_flag THEN
   Write_Debug('Got new wf item key: ' || x_item_key );
END IF ;


    -- We no longer use Submit Revision for Change Workflow
    --  Set workflow revision history
    -- SetWorkflowRevision
    -- (  p_item_type         => p_item_type
    -- ,  p_item_key          => x_item_key
    -- ,  p_process_name      => p_process_name
    -- ,  p_change_notice     => p_change_notice
    -- ,  p_organization_id   => p_organization_id
    -- ,  p_wf_user_id        => p_wf_user_id
    -- ,  p_action_id         => p_action_id
    -- ,  p_route_id          => p_route_id
    -- ,  p_route_step_id     => p_route_step_id
    -- ) ;

    l_wf_user_key := GetItemUserKey
                     (  p_item_type          => p_item_type
                     ,  p_item_key           => x_item_key
                     ,  p_change_id          => l_change_id
                     ,  p_change_line_id     => l_change_line_id
                     ,  p_object_name        => p_object_name
                     ,  p_object_id1         => p_object_id1
                     ,  p_object_id2         => p_object_id2
                     ,  p_object_id3         => p_object_id3
                     ,  p_object_id4         => p_object_id4
                     ,  p_object_id5         => p_object_id5
                     ,  p_parent_object_name => p_parent_object_name
                     ,  p_parent_object_id1  => p_parent_object_id1
                     ) ;


IF g_debug_flag THEN
   Write_Debug('2-1. Set ItemUserKey. . .' || l_wf_user_key );
END IF ;

    -- Get User Info
    l_wf_user_role := GetUserRole(p_user_id => p_wf_user_id ) ;


IF g_debug_flag THEN
   Write_Debug('2-2. Set ItemOwner. . .' || l_wf_user_role );
END IF ;


    -- Set User Id
    IF p_wf_user_id IS NULL OR  p_wf_user_id < 0
    THEN
       l_api_caller := Eng_Workflow_Util.G_WF_CALL ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('2-2. Get Spcial  API Caller: ' || l_api_caller );
END IF ;

    -- Set Workflow Process Owner
    WF_ENGINE.CreateProcess
    ( itemtype     => p_item_type
    , itemkey      => x_item_key
    , process      => p_process_name
    , user_key     => l_wf_user_key
    , owner_role   => l_wf_user_role ) ;


IF g_debug_flag THEN
   Write_Debug('3. SetItemAttribute. . .');
END IF ;

    -- Set Item Attributes
    SetAttributes
    (  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_item_type         => p_item_type
    ,  p_item_key          => x_item_key
    ,  p_process_name      => p_process_name
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id
    ,  p_wf_user_id        => p_wf_user_id
    ,  p_wf_user_role      => l_wf_user_role
    ,  p_host_url          => p_host_url
    ,  p_action_id         => l_action_id
    ,  p_adhoc_party_list  => p_adhoc_party_list
    ,  p_route_id          => p_route_id
    ,  p_route_step_id     => p_route_step_id
    ,  p_parent_item_type  => p_parent_item_type
    ,  p_parent_item_key   => p_parent_item_key
    ,  p_object_name        => p_object_name
    ,  p_object_id1         => p_object_id1
    ,  p_object_id2         => p_object_id2
    ,  p_object_id3         => p_object_id3
    ,  p_object_id4         => p_object_id4
    ,  p_object_id5         => p_object_id5
    ,  p_parent_object_name => p_parent_object_name
    ,  p_parent_object_id1  => p_parent_object_id1
    ) ;


IF g_debug_flag THEN
   Write_Debug('After SetItemAttribute. . .');
   Write_Debug('Change Id         : ' || to_char(l_change_id));
END IF ;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('4. SetItemParent. . .');
   Write_Debug('Parent Item Type : ' || p_parent_item_type);
   Write_Debug('Parent Item Key  : ' || p_parent_item_key);
END IF ;

    -- If Parent WF Info is not null and
    -- item_type is NOT Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE
    -- G_CHANGE_ROUTE_ITEM_TYPE has own API to set parent wf info
    IF  p_parent_item_type IS NOT NULL
    AND p_parent_item_key  IS NOT NULL
    AND p_item_type <> Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE
    THEN

        -- Set Parent Worklfow Process
        WF_ENGINE.SetItemParent
        ( itemtype        => p_item_type
        , itemkey         => x_item_key
        , parent_itemtype => p_parent_item_type
        , parent_itemkey  => p_parent_item_key
        , parent_context  => NULL
        );

    END IF ;


    IF p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE
    THEN

IF g_debug_flag THEN
   Write_Debug('4-2. Set Route Status . . .');
END IF ;

        SetRouteStatus
        (  p_item_type         => p_item_type
        ,  p_item_key          => x_item_key
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_route_id          => p_route_id
        ,  p_new_status_code   => Eng_Workflow_Util.G_RT_IN_PROGRESS
        ,  p_init_route        => FND_API.G_TRUE
        ,  p_change_id         => l_change_id
        ,  p_change_line_id    => l_change_line_id   -- Added in R12B
        ) ;


        -- In case that Route Object is Change Object
        IF p_object_name = Eng_Workflow_Util.G_ENG_CHANGE
        THEN

        /***********************************************
        --
        -- In 115.10
        -- Workflow Routing will not chagne Change Object
        -- Approval Status
--  IF g_debug_flag THEN
--     Write_Debug('4-3. Set Approval Route Status . . .');
--  END IF ;
--
        --   SetChangeApprovalStatus
        --   (  x_return_status        => x_return_status
        --   ,  x_msg_count            => x_msg_count
        --   ,  x_msg_data             => x_msg_data
        --   ,  p_item_type            => p_item_type
        --   ,  p_item_key             => x_item_key
        --   ,  p_change_id            => l_change_id
        --   ,  p_change_line_id       => l_change_line_id
        --   ,  p_wf_user_id           => p_wf_user_id
        --   ,  p_new_appr_status_type => Eng_Workflow_Util.G_REQUESTED
        --  ) ;
        --

-- IF g_debug_flag THEN
--  Write_Debug('After Set Approval Status .' || x_return_status );
-- END IF ;

        --    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        --    THEN
        --        RAISE FND_API.G_EXC_ERROR ;
        --    END IF ;
        --
        ****************************************************/


IF g_debug_flag THEN
   Write_Debug('4-4. Set Workflow Routing Action Log . . .');
END IF ;
            l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  Eng_Workflow_Util.G_RT_IN_PROGRESS
                         , p_convert_type      =>  'WF_PROCESS' ) ;

            CreateRouteAction
            (  x_return_status        => x_return_status
            ,  x_msg_count            => x_msg_count
            ,  x_msg_data             => x_msg_data
            ,  p_change_id            => l_change_id
            ,  p_change_line_id       => l_change_line_id
            ,  p_action_type          => l_action_type
            ,  p_user_id              => p_wf_user_id
            ,  p_parent_action_id     => NULL
            ,  p_route_id             => p_route_id
            ,  p_comment              => NULL
            ,  x_action_id            => l_action_id
            ) ;

IF g_debug_flag THEN
   Write_Debug('After Set Workflow Routing Action Log .' || x_return_status );
END IF ;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF ;

            -- Set Action Id
            SetActionId
            (   p_item_type         => p_item_type
             ,  p_item_key          => x_item_key
             ,  p_action_id         => l_action_id
            ) ;

IF g_debug_flag THEN
   Write_Debug('4-5. Sync Workflow Routing Status and LC Phase WF Status. . .');
END IF ;

            -- R12B
            -- No need to call Eng_Workflow_Util.SyncChangeLCPhase
            -- For Line
            IF ( l_change_line_id IS NULL OR  l_change_line_id <= 0)
            THEN

                -- Call Sync Change Lifecycle Phase API
                Eng_Workflow_Util.SyncChangeLCPhase
                (  x_return_status        => x_return_status
                ,  x_msg_count            => x_msg_count
                ,  x_msg_data             => x_msg_data
                ,  p_route_id             => p_route_id
                ,  p_api_caller           => l_api_caller
                ) ;


    IF g_debug_flag THEN
       Write_Debug('After Sync Workflow Routing Status and LC Phase WF Status.' || x_return_status );
    END IF ;


                IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF ;

            END IF ;


        -- R12B Line Workfow Routing
        -- In case that Route Object is Change Line Object
        ELSIF p_object_name = Eng_Workflow_Util.G_ENG_CHANGE_LINE
        THEN


IF g_debug_flag THEN
   Write_Debug('4-4. Set Line Workflow Routing Action Log . . .');
END IF ;
            l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  Eng_Workflow_Util.G_RT_IN_PROGRESS
                         , p_convert_type      =>  'WF_PROCESS' ) ;

            CreateRouteAction
            (  x_return_status        => x_return_status
            ,  x_msg_count            => x_msg_count
            ,  x_msg_data             => x_msg_data
            ,  p_change_id            => l_change_id
            ,  p_change_line_id       => l_change_line_id
            ,  p_action_type          => l_action_type
            ,  p_user_id              => p_wf_user_id
            ,  p_parent_action_id     => NULL
            ,  p_route_id             => p_route_id
            ,  p_comment              => NULL
            ,  x_action_id            => l_action_id
            ) ;

IF g_debug_flag THEN
   Write_Debug('After Set Line Workflow Routing Action Log .' || x_return_status );
END IF ;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF ;

            -- Set Action Id
            SetActionId
            (   p_item_type         => p_item_type
             ,  p_item_key          => x_item_key
             ,  p_action_id         => l_action_id
            ) ;


        END IF ; -- End if p_object_name = Eng_Workflow_Util.G_ENG_CHANGE_LINE


      /***********************************************
      --  In 115.10
      --  We are not supproting
      --  Change Line Workflow Routing
      --  and Header/Line Coordination
      --
      --  SetRouteParentChild
      --  (  x_return_status        => x_return_status
      --  ,  x_msg_count            => x_msg_count
      --  ,  x_msg_data             => x_msg_data
      --  ,  p_change_id            => l_change_id
      --  ,  p_change_line_id       => l_change_line_id
      --  ,  p_route_id             => p_route_id
      --  ,  p_item_type            => p_item_type
      --  ,  p_item_key             => x_item_key
      --  ,  p_parent_item_type     => p_parent_item_type
      --  ,  p_parent_item_key      => p_parent_item_key
      --  ) ;

--IF g_debug_flag THEN
--   Write_Debug('After Set Parenet Child for Route Worklfow.' || x_return_status );
--END IF ;

       -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS
       -- THEN
       --     RAISE FND_API.G_EXC_ERROR ;
       -- END IF ;
       --
      ***********************************************/




    ELSIF (    p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
            OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE
            OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE
          )
    THEN

IF g_debug_flag THEN
   Write_Debug('4-2. Set Route Step Status . . .' || to_char(p_route_step_id));
END IF ;

        Eng_Workflow_Util.SetRouteStepStatus
        (  p_item_type         => p_item_type
        ,  p_item_key          => x_item_key
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_route_id          => p_route_id
        ,  p_route_step_id     => p_route_step_id
        ,  p_new_status_code   => Eng_Workflow_Util.G_RT_IN_PROGRESS
        ) ;


IF g_debug_flag THEN
   Write_Debug('4-3. Set Route Step Status . . .' || to_char(p_route_step_id));
END IF ;

        -- R12B
        -- Change Management Header/Line Workflow Routing Assignees Grants
        --
        -- NOTE: In R12B We support Document Revision subject and Files (Attachments)
        --
        -- Provide `view grants to workflow assignees' feature to all workflow routeing types not just for
        -- notification workflow type. across all subject entities
        -- for both header and line workflows
        --
        -- Header level: Will give Role specified in WF Definition to header subject
        -- entity for header workflow ad-hoc assignees across all subject entities
        -- Header Level: Will give OFO Role grants to header attachments for header workflow ad-hoc assignees
        --
        -- Line level: Will give Role specified in WF Definition to line subject
        -- entity for header workflow ad-hoc assignees across all subject entities
        -- Line Level: Give OFO Role grants to line workflow assignees on line attachments
        --
        -- Header and Line level: When workflow steps are re-assigned,
        -- same roles specified in WF Definition will be granted to the original assignee will be kept.
        -- In addition view grants will be provided to the new assignees
        --
IF g_debug_flag THEN
    Write_Debug('calling Eng_Workflow_Util.GrantObjectRoles.' );
END IF ;

        l_index := 0 ;
        l_target_obj_tbl := FND_TABLE_OF_VARCHAR2_30();
        IF ( p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE )
        THEN
            l_target_obj_tbl.EXTEND ;
            l_index := l_index + 1 ;
            l_target_obj_tbl(l_index) := G_DOM_DOCUMENT_REVISION ;
        END IF ;


        Eng_Workflow_Util.GrantObjectRoles
        (   p_api_version               => 1.0
         ,  p_init_msg_list             => FND_API.G_FALSE        --
         ,  p_commit                    => FND_API.G_FALSE        --
         ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
         ,  p_debug                     => p_debug
         ,  p_output_dir                => p_output_dir
         ,  p_debug_filename            => p_debug_filename
         ,  x_return_status             => l_return_status
         ,  x_msg_count                 => l_msg_count
         ,  x_msg_data                  => l_msg_data
         ,  p_change_id                 => l_change_id
         ,  p_change_line_id            => l_change_line_id
         ,  p_route_id                  => p_route_id
         ,  p_step_id                   => p_route_step_id
         ,  p_person_ids                => NULL
         ,  p_target_objects            => l_target_obj_tbl
         ,  p_api_caller                => l_api_caller
         ,  p_grant_option              => NULL
        ) ;


IF g_debug_flag THEN
    Write_Debug('After Eng_Workflow_Util.GrantObjectRoles: ' || l_return_status );
END IF ;

       --
       -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       -- THEN
       --     RAISE FND_API.G_EXC_ERROR ;
       -- END IF ;
       --

    END IF ;


IF g_debug_flag THEN
   Write_Debug('5. Executing Custom Hook: Eng_Workflow_Ext.StartCustomWorkflow . . .');
   Write_Debug('Item Type    : ' || p_item_type );
   Write_Debug('Item Key     : ' || x_item_key );
   Write_Debug('Process Name : ' || p_process_name);
END IF ;


    Eng_Workflow_Ext.StartCustomWorkflow
    (  p_validation_level  => p_validation_level
    ,  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_item_type         => p_item_type
    ,  x_item_key          => x_item_key
    ,  p_process_name      => p_process_name
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id
    ,  p_wf_user_id        => p_wf_user_id
    ,  p_host_url          => p_host_url
    ,  p_action_id         => p_action_id
    ,  p_adhoc_party_list  => p_adhoc_party_list
    ,  p_route_id          => p_route_id
    ,  p_route_step_id     => p_route_step_id
    ,  p_parent_item_type  => p_parent_item_type
    ,  p_parent_item_key   => p_parent_item_key
    ,  p_object_name        => p_object_name
    ,  p_object_id1         => p_object_id1
    ,  p_object_id2         => p_object_id2
    ,  p_object_id3         => p_object_id3
    ,  p_object_id4         => p_object_id4
    ,  p_object_id5         => p_object_id5
    ,  p_parent_object_name => p_parent_object_name
    ,  p_parent_object_id1  => p_parent_object_id1
    ) ;

IF g_debug_flag THEN
   Write_Debug('Return Status: ' || x_return_status );
END IF ;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('6. StartProcess. . .');
   Write_Debug('Item Type    : ' || p_item_type );
   Write_Debug('Item Key     : ' || x_item_key );
   Write_Debug('Process Name : ' || p_process_name);
END IF ;

    IF  p_item_type  IS NOT NULL
    AND x_item_key   IS NOT NULL
    THEN

IF g_debug_flag THEN
   Write_Debug('Calling WF_ENGINE.StartProcess . . .') ;
END IF ;


        -- Start process
        WF_ENGINE.StartProcess
        ( itemtype => p_item_type
        , itemkey  => x_item_key);

    END IF ;

IF g_debug_flag THEN
   Write_Debug('After executing StartWorkflow API Body') ;
END IF ;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN

IF g_debug_flag THEN
   Write_Debug('Do Commit.') ;
END IF ;

      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count  => x_msg_count
      ,  p_data   => x_msg_data
      );

IF g_debug_flag THEN
   Write_Debug('Finish. Eng Of Proc') ;
   Close_Debug_Session ;
END IF ;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
           ROLLBACK TO StartWorkflow_Util ;
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('RollBack and Finish with Error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
           ROLLBACK TO StartWorkflow_Util ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Rollback and Finish with unxepcted error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN OTHERS THEN
       IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
           ROLLBACK TO StartWorkflow_Util ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME
              , l_api_name
              );
       END IF;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Rollback and finish with system unxepcted error: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;


END StartWorkflow ;



PROCEDURE AbortWorkflow
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2  := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_debug             IN  VARCHAR2  := FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := 'Eng_ChangeWF_Abort.log'
)
IS

   l_api_name         CONSTANT VARCHAR2(30) := 'AbortWorkflow';
   l_api_version      CONSTANT NUMBER       := 1.0;

   l_activity_status  VARCHAR2(8) ;
   l_change_id        NUMBER ;
   l_change_line_id   NUMBER ;
   l_route_id         NUMBER ;
   l_route_step_id    NUMBER ;

   l_action_type      VARCHAR2(30) ;
   l_action_id        NUMBER ;
   l_parent_action_id NUMBER ;

   l_wf_user_role     VARCHAR2(320) ;
   l_api_caller       VARCHAR2(30) ;


   l_route_object_name VARCHAR2(30) ;



   -- R12B
   l_target_obj_tbl   FND_TABLE_OF_VARCHAR2_30;
   l_index            PLS_INTEGER ;

   l_msg_count                 NUMBER ;
   l_msg_data                  VARCHAR2(2000) ;
   l_return_status             VARCHAR2(1) ;


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT AbortWorkflow_Util;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(  l_api_version
                                       , p_api_version
                                       , l_api_name
                                       , G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;


    -- For Test/Debug
    Check_And_Open_Debug_Session(p_debug, p_output_dir, p_debug_filename) ;
    -- R12 Comment out
    -- IF FND_API.to_Boolean( p_debug ) THEN
    --     Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    -- END IF;


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.AbortWorkflow Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || p_item_Key );
   Write_Debug('Process Name      : ' || p_process_name);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Initialize return status ' );
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------

    -- 1. ValidateAbortingProcess:
    -- 2. Set User Id who would abort the process:
    -- 3. Execute the Item Type specific logic :
    -- 4. Execute Custom Hook:
    -- 4. SetItemParent:
    -- 6. Release Block Abort Activity:

IF g_debug_flag THEN
   Write_Debug('1. ValidateAbortingProcess. . .');
END IF ;

    -- ValidateAbortingProcess
    ValidateAbortingProcess
    (  p_validation_level  => p_validation_level
    ,  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_item_type         => p_item_type
    ,  p_item_key          => p_item_key
    ,  p_process_name      => p_process_name
    ,  p_wf_user_id        => p_wf_user_id
    ) ;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('2. Set User Id who is aborting the process. . .');
END IF ;

    -- Set User Id
    IF p_wf_user_id IS NOT NULL AND p_wf_user_id >= 0
    THEN

       -- Set WF User Id
       SetWFUserId
       (   p_item_type         => p_item_type
        ,  p_item_key          => p_item_key
        ,  p_wf_user_id        => p_wf_user_id
       ) ;

       l_wf_user_role := GetUserRole(p_user_id => p_wf_user_id ) ;


       -- Set WF User Role
       SetWFUserRole
       (   p_item_type         => p_item_type
        ,  p_item_key          => p_item_key
        ,  p_wf_user_role      => l_wf_user_role
       ) ;

       -- Set NTF User Role for Abort Notification
       SetNTFFromRole
       (   p_item_type         => p_item_type
        ,  p_item_key          => p_item_key
        ,  p_ntf_from_role     => l_wf_user_role
       ) ;

    ELSE

       l_api_caller := Eng_Workflow_Util.G_WF_CALL ;

    END IF ;



IF g_debug_flag THEN
   Write_Debug('3. Execute the Item Type specific logic. . .');
END IF ;


    -- Put the Item Type specific logic here
    IF p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE
    THEN

IF g_debug_flag THEN
   Write_Debug('3-1. Set Route Status . . .');
END IF ;

        -- Get Change Object Identifier
        Eng_Workflow_Util.GetChangeObject
        (   p_item_type         => p_item_type
         ,  p_item_key          => p_item_key
         ,  x_change_id         => l_change_id
        ) ;


        -- Get Change Line Object Identifier
        Eng_Workflow_Util.GetChangeLineObject
        (   p_item_type         => p_item_type
         ,  p_item_key          => p_item_key
         ,  x_change_line_id    => l_change_line_id
        ) ;

        -- Get Route Id
        Eng_Workflow_Util.GetRouteId
        (   p_item_type         => p_item_type
         ,  p_item_key          => p_item_key
         ,  x_route_id          => l_route_id
        ) ;

        -- Get Route Object Name
        Eng_Workflow_Util.GetRouteObject
        (   p_item_type         => p_item_type
         ,  p_item_key          => p_item_key
         ,  x_route_object      => l_route_object_name
        ) ;



        SetRouteStatus
        (  p_item_type         => p_item_type
        ,  p_item_key          => p_item_key
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_route_id          => l_route_id
        ,  p_new_status_code   => Eng_Workflow_Util.G_RT_ABORTED
        ,  p_change_id         => l_change_id
        ,  p_change_line_id    => l_change_line_id   -- Added in R12B
        ) ;


        /* Workflow will not change approval status in 115.10
IF g_debug_flag THEN
   Write_Debug('3-2. Set Approval Route Status . . .');
END IF ;

        -- SetChangeApprovalStatus
        -- (  x_return_status        => x_return_status
        -- ,  x_msg_count            => x_msg_count
        -- ,  x_msg_data             => x_msg_data
        -- ,  p_item_type            => p_item_type
        -- ,  p_item_key             => p_item_key
        -- ,  p_change_id            => l_change_id
        -- ,  p_change_line_id       => l_change_line_id
        -- ,  p_wf_user_id           => p_wf_user_id
        -- ,  p_new_appr_status_type => Eng_Workflow_Util.G_NOT_SUBMITTED
        -- ) ;

IF g_debug_flag THEN
   Write_Debug('After Set Approval Status .' || x_return_status );
END IF ;

        -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        -- THEN
        --     RAISE FND_API.G_EXC_ERROR ;
        -- END IF ;

        */

IF g_debug_flag THEN
   Write_Debug('3-3. Abort Child Route Step Workflows . . .');
END IF ;

        AbortRouteSteps
        (  x_return_status        => x_return_status
        ,  x_msg_count            => x_msg_count
        ,  x_msg_data             => x_msg_data
        ,  p_route_item_type      => p_item_type
        ,  p_route_item_key       => p_item_key
        ,  p_wf_user_id           => p_wf_user_id
        ) ;

IF g_debug_flag THEN
   Write_Debug('After Route Step Workflow ' || x_return_status );
END IF ;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF ;


        -- In case that Route Object is Change Object
        IF l_route_object_name = Eng_Workflow_Util.G_ENG_CHANGE
        THEN

            --
            -- R12 DOM LC Phase Workflow Support
            --
            IF ( ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle( p_change_id => l_change_id) )
            THEN

IF g_debug_flag THEN
    Write_Debug('Change Object is a Doc LC Object, calling API. . . . ');
    Write_Debug('Calling ENG_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF. . .' );
END IF ;

                ENG_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF
                (   p_api_version               => 1.0
                 ,  p_init_msg_list             => FND_API.G_FALSE        --
                 ,  p_commit                    => FND_API.G_FALSE        --
                 ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
                 ,  x_return_status             => l_return_status
                 ,  x_msg_count                 => l_msg_count
                 ,  x_msg_data                  => l_msg_data
                 ,  p_change_id                 => l_change_id        -- Change Id
                 ,  p_route_id                  => l_route_id         -- WF Route ID
                ) ;


IF g_debug_flag THEN
  Write_Debug('After calling ENG_DOCUMENT_UTIL.Abort_Doc_LC_Phase_WF: ' || l_return_status );
END IF ;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF ;

            END IF ;


IF g_debug_flag THEN
   Write_Debug('3-4. Set Workflow Routing Action Log . . .');
END IF ;

            -- Get Action Id and set this as parent action id
            Eng_Workflow_Util.GetActionId
            (   p_item_type         => p_item_type
             ,  p_item_key          => p_item_key
             ,  x_action_id         => l_parent_action_id
            ) ;

            l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                             ( p_route_status_code =>  Eng_Workflow_Util.G_RT_ABORTED
                             , p_convert_type      =>  'WF_PROCESS' ) ;


            CreateRouteAction
            (  x_return_status        => x_return_status
            ,  x_msg_count            => x_msg_count
            ,  x_msg_data             => x_msg_data
            ,  p_change_id            => l_change_id
            ,  p_change_line_id       => l_change_line_id
            ,  p_action_type          => l_action_type
            ,  p_user_id              => p_wf_user_id
            ,  p_parent_action_id     => l_parent_action_id
            ,  p_route_id             => l_route_id
            ,  p_comment              => NULL
            ,  x_action_id            => l_action_id
            ) ;

IF g_debug_flag THEN
   Write_Debug('After Set Workflow Routing Action Log: ' || x_return_status );
END IF ;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF ;


            -- R12B
            -- No need to call Eng_Workflow_Util.SyncChangeLCPhase
            -- For Line
            IF ( l_change_line_id IS NULL OR  l_change_line_id <= 0)
            THEN

                -- Call Sync Change Lifecycle Phase API
                Eng_Workflow_Util.SyncChangeLCPhase
                (  x_return_status        => x_return_status
                ,  x_msg_count            => x_msg_count
                ,  x_msg_data             => x_msg_data
                ,  p_route_id             => l_route_id
                ,  p_api_caller           => l_api_caller
                ) ;


IF g_debug_flag THEN
   Write_Debug('After call SyncChangeLCPhase: ' || x_return_status );
END IF ;

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF ;
            END IF ;


        -- R12B Line Workfow Routing
        -- In case that Route Object is Change Line Object
        ELSIF l_route_object_name = Eng_Workflow_Util.G_ENG_CHANGE_LINE
        THEN


IF g_debug_flag THEN
   Write_Debug('4-4. Set Line Workflow Routing Action Log . . .');
END IF ;

            -- Get Action Id and set this as parent action id
            Eng_Workflow_Util.GetActionId
            (   p_item_type         => p_item_type
             ,  p_item_key          => p_item_key
             ,  x_action_id         => l_parent_action_id
            ) ;


            l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  Eng_Workflow_Util.G_RT_ABORTED
                         , p_convert_type      =>  'WF_PROCESS' ) ;


            CreateRouteAction
            (  x_return_status        => x_return_status
            ,  x_msg_count            => x_msg_count
            ,  x_msg_data             => x_msg_data
            ,  p_change_id            => l_change_id
            ,  p_change_line_id       => l_change_line_id
            ,  p_action_type          => l_action_type
            ,  p_user_id              => p_wf_user_id
            ,  p_parent_action_id     => l_parent_action_id
            ,  p_route_id             => l_route_id
            ,  p_comment              => NULL
            ,  x_action_id            => l_action_id
            ) ;

IF g_debug_flag THEN
   Write_Debug('After Set Line Workflow Routing Abort Action Log .' || x_return_status );
END IF ;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF ;


        END IF ; -- End if p_object_name = Eng_Workflow_Util.G_ENG_CHANGE_LINE





        -- R12B Revoke Roles
        l_index := 0 ;

        IF ( ENG_DOCUMENT_UTIL.Is_Dom_Document_Lifecycle( p_change_id   => l_change_id) )
        THEN

IF g_debug_flag THEN
   Write_Debug('Change Object is a Doc LC Object, Setting target objects. . . . ');
END IF ;
            l_target_obj_tbl := FND_TABLE_OF_VARCHAR2_30();
            l_target_obj_tbl.EXTEND ;
            l_index := l_index+1 ;
            l_target_obj_tbl(l_index) := G_DOM_DOCUMENT_REVISION ;
        END IF ;


IF g_debug_flag THEN
   Write_Debug('Calling Eng_Workflow_Util.RevokeObjectRoles . . . . ');
END IF ;


        Eng_Workflow_Util.RevokeObjectRoles
        (   p_api_version               => 1.0
         ,  p_init_msg_list             => FND_API.G_FALSE        --
         ,  p_commit                    => FND_API.G_FALSE        --
         ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
         ,  p_debug                     => p_debug
         ,  p_output_dir                => p_output_dir
         ,  p_debug_filename            => p_debug_filename
         ,  x_return_status             => l_return_status
         ,  x_msg_count                 => l_msg_count
         ,  x_msg_data                  => l_msg_data
         ,  p_change_id                 => l_change_id
         ,  p_change_line_id            => l_change_line_id
         ,  p_route_id                  => l_route_id
         ,  p_person_ids                => NULL
         ,  p_target_objects            => l_target_obj_tbl
         ,  p_api_caller                => l_api_caller
         ,  p_revoke_option             => NULL
        ) ;


IF g_debug_flag THEN
    Write_Debug('After Eng_Workflow_Util.RevokeObjectRoles.' || l_return_status );
END IF ;

       --
       -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       -- THEN
       --     RAISE FND_API.G_EXC_ERROR ;
       -- END IF ;
       --

    -- R12B
    ELSIF (    p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
            OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE
            OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE
          )
    THEN

        -- Get Route Step Id
        GetRouteStepId
        (   p_item_type         => p_item_type
         ,  p_item_key          => p_item_key
         ,  x_route_step_id     => l_route_step_id
        ) ;

IF g_debug_flag THEN
   Write_Debug('3-1. Set Route Step Status . . .' || to_char(l_route_step_id));
END IF ;

        SetRouteStepStatus
        (  p_item_type         => p_item_type
        ,  p_item_key          => p_item_key
        ,  p_wf_user_id        => p_wf_user_id
        ,  p_route_id          => l_route_id
        ,  p_route_step_id     => l_route_step_id
        ,  p_new_status_code   => Eng_Workflow_Util.G_RT_ABORTED
        ) ;


    END IF ;


IF g_debug_flag THEN
   Write_Debug('4. Executing Custom Hook: Eng_Workflow_Ext.AbortCustomWorkflow . . .');
   Write_Debug('Item Type    : ' || p_item_type );
   Write_Debug('Item Key     : ' || p_item_key );
   Write_Debug('Process Name : ' || p_process_name);
END IF ;


    Eng_Workflow_Ext.AbortCustomWorkflow
    (  p_validation_level  => p_validation_level
    ,  x_return_status     => x_return_status
    ,  x_msg_count         => x_msg_count
    ,  x_msg_data          => x_msg_data
    ,  p_item_type         => p_item_type
    ,  p_item_key          => p_item_key
    ,  p_process_name      => p_process_name
    ,  p_wf_user_id        => p_wf_user_id
    ) ;


IF g_debug_flag THEN
   Write_Debug('Return Status: ' || x_return_status );
END IF ;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;



    -- 6. Abort Process or Release 'Block Abort' Activty
    --    Fisrt, check if Block Abort Activity is 'NOTIFIED'
    --    if so, complete Block Abort Activity
    --    if not, abort the process

IF g_debug_flag THEN
   Write_Debug('6. Abort Process or Release Block Abort Activty . .  ' );
END IF ;


    CheckWFActivityStatus
    ( p_item_type        => p_item_type
    , p_item_key         => p_item_key
    , p_activity_name    => Eng_Workflow_Util.G_BLOCK_ABORT_ACTIVITY
    , x_activity_status  => l_activity_status
    );

IF g_debug_flag THEN
   Write_Debug('6-1. Abort Block Activity Status: ' || l_activity_status  );
END IF ;



    IF (l_activity_status = Eng_Workflow_Util.G_WF_NOTIFIED)
    THEN

IF g_debug_flag THEN
   Write_Debug('6-2. Complete  Abort Block Activity. . .' );
END IF ;


        WF_ENGINE.CompleteActivity( p_item_type
                                  , p_item_key
                                  , Eng_Workflow_Util.G_BLOCK_ABORT_ACTIVITY
                                  , Eng_Workflow_Util.G_WF_COMPLETE
                                  );

    ELSE

IF g_debug_flag THEN
   Write_Debug('6-2. Abort Workflow Process directly. . .' );
END IF ;



        WF_ENGINE.AbortProcess( p_item_type
                              , p_Item_key
                              , p_process_name
                              );

    END IF;


IF g_debug_flag THEN
   Write_Debug('After executing AbortWorkflow API Body') ;
END IF ;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN

IF g_debug_flag THEN
   Write_Debug('Do Commit.') ;
END IF ;

      COMMIT WORK;

   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count  => x_msg_count
      ,  p_data   => x_msg_data
      );

IF g_debug_flag THEN
   Write_Debug('Finish. Eng Of Proc') ;
   Close_Debug_Session ;
END IF ;

-- To remove the step assignee created by the Reassignment.

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
           ROLLBACK TO AbortWorkflow_Util ;
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with Error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
           ROLLBACK TO AbortWorkflow_Util ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with unxepcted error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN OTHERS THEN
       IF FND_API.To_Boolean( p_commit ) THEN
IF g_debug_flag THEN
   Write_Debug('Rollback . . .') ;
END IF ;
           ROLLBACK TO AbortWorkflow_Util ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME
              , l_api_name
              );
       END IF;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with system unxepcted error: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;


END AbortWorkflow ;

PROCEDURE reassignRoutePeople(   x_return_status      OUT NOCOPY VARCHAR2
                              ,  x_msg_count          OUT NOCOPY NUMBER
                              ,  x_msg_data           OUT NOCOPY VARCHAR2
                              ,  p_item_type          IN  VARCHAR2
                              ,  p_item_key           IN  VARCHAR2
                              ,  p_notification_id    IN  NUMBER
                              ,  p_reassign_mode      IN  VARCHAR2)

IS

    l_notification_id     NUMBER;

    l_change_id           NUMBER ;
    l_object_name         VARCHAR2(30);
    l_step_id             NUMBER;

    l_route_people_id     NUMBER;
    l_assignee_type_code           VARCHAR2(30);
    l_original_assignee_id         NUMBER ;
    l_original_assignee_type_code  VARCHAR2(30);
    l_response_condition_code      VARCHAR2(30);
    l_adhoc_people_flag            VARCHAR2(1) ;
    l_response_code       VARCHAR2(30);
    l_comment             VARCHAR2(4000);

    --l_party_id            NUMBER;
    --l_fnd_user_id         NUMBER ;
    --l_fnd_login_id        NUMBER ;

    l_performer_user_id   NUMBER;
    l_performer_party_id  NUMBER;


    l_rowid               ROWID;
    l_new_party_id        NUMBER :=-1;
    l_new_route_people_id NUMBER ;
    l_new_route_assoc_id NUMBER;

    l_created_action_id   NUMBER;
    l_action_type         VARCHAR2(30);

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(3000);

    -- R12B
    l_route_id            NUMBER;
    l_change_line_id      NUMBER;
    l_target_obj_tbl      FND_TABLE_OF_VARCHAR2_30;
    l_obj_index           PLS_INTEGER ;
    l_person_id_tbl       FND_TABLE_OF_NUMBER ;
    l_person_idx          PLS_INTEGER ;
    l_default_assignee_resp  VARCHAR2(30) ;


    CURSOR  c_route_person ( p_step_id            NUMBER
                           , p_notification_id    NUMBER )
    IS
        SELECT EngSecPeople.user_id
             , EngSecPeople.person_id
             , RoutePeople.route_people_id
             , RoutePeople.adhoc_people_flag
             , RoutePeople.assignee_type_code
             , RoutePeople.original_assignee_id
             , RoutePeople.original_assignee_type_code
             , RoutePeople.response_condition_code
        FROM   ENG_CHANGE_ROUTE_PEOPLE RoutePeople
             , ENG_SECURITY_PEOPLE_V EngSecPeople
             , WF_NOTIFICATIONS wn
        WHERE RoutePeople.assignee_id = EngSecPeople.person_id
        -- AND   RoutePeople.assignee_type_code = p_assignee_type_code
        AND   RoutePeople.step_id = p_step_id
        AND   ( RoutePeople.response_code IS NULL
                OR RoutePeople.response_code = Eng_Workflow_Util.G_RT_SUBMITTED
                OR RoutePeople.response_code = Eng_Workflow_Util.G_RT_NOT_RECEIVED )
        AND   EngSecPeople.user_name = wn.recipient_role
        AND   wn.notification_id = p_notification_id ;

    CURSOR c_report_people_assocs (p_route_people_id NUMBER)
    IS
        SELECT  ASSOC_OBJECT_NAME,ASSOC_OBJ_PK1_VALUE, ADHOC_ASSOC_FLAG,
             OBJECT_NAME, OBJECT_ID1 from ENG_CHANGE_ROUTE_ASSOCS
             where ROUTE_PEOPLE_ID=p_route_people_id;

BEGIN
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_flag THEN
   Write_Debug('Route p_notification_id ' || to_char(p_notification_id));
END IF ;

     -- Get Change Object Identifier
     GetChangeObject
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_change_id         => l_change_id
     ) ;


     -- Get Object Type
     l_object_name :=  GetChangeObjectName
     ( p_change_id           => l_change_id ) ;


     -- Get Current Route Step Id
     GetRouteStepId
     (  p_item_type        => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_step_id     => l_step_id
     ) ;


     -- R12B
     -- Get Route Id
     GetRouteId
     (  p_item_type         => p_item_type
     ,  p_item_key          => p_item_key
     ,  x_route_id          => l_route_id
     ) ;

     -- Get Change Object Identifier
     GetChangeLineObject
     (   p_item_type         => p_item_type
      ,  p_item_key          => p_item_key
      ,  x_change_line_id    => l_change_line_id
     ) ;


     l_notification_id :=p_notification_id;
     l_comment :=  WF_ENGINE.context_user_comment;


IF g_debug_flag THEN
   Write_Debug('Route Step id ' || to_char(l_step_id));
   Write_Debug('Route p_item_type ' || p_item_type);
   Write_Debug('Route p_item_key ' || p_item_key);
   Write_Debug('Route new role ' || WF_ENGINE.context_new_role);
   Write_Debug('Change Id ' || to_char(l_change_id));
END IF ;


     SELECT person_id into l_new_party_id
     FROM   ENG_SECURITY_PEOPLE_V
     WHERE  user_name = WF_ENGINE.context_new_role;

IF g_debug_flag THEN
   Write_Debug('Route NEW Party id to whom NTF is being transfered or reassigned: ' || to_char(l_new_party_id));
END IF ;

     IF (p_reassign_mode = G_WF_TRANSFER)
     THEN
         l_response_code := G_RT_TRANSFERRED ;

     ELSIF (p_reassign_mode=G_WF_FORWARD)
     THEN
        l_response_code := G_RT_FORWARDED ;
     END IF;



     FOR rtp_rec  IN c_route_person (  p_step_id => l_step_id
                                     , p_notification_id => p_notification_id )
     LOOP
         l_performer_user_id            := rtp_rec.user_id ;
         l_performer_party_id           := rtp_rec.person_id ;
         l_route_people_id              := rtp_rec.route_people_id ;
         l_adhoc_people_flag            := rtp_rec.adhoc_people_flag ;
         l_assignee_type_code           := rtp_rec.assignee_type_code ;
         l_original_assignee_id         := rtp_rec.original_assignee_id ;
         l_original_assignee_type_code  := rtp_rec.original_assignee_type_code ;
         l_response_condition_code      := rtp_rec.response_condition_code ;


         update ENG_CHANGE_ROUTE_PEOPLE set
           WF_NOTIFICATION_ID = p_notification_id,
           RESPONSE_CODE = l_response_code ,
           RESPONSE_DATE = SYSDATE ,
           LAST_UPDATE_DATE = SYSDATE ,
           LAST_UPDATED_BY = l_performer_user_id ,
           LAST_UPDATE_LOGIN = null
         where ROUTE_PEOPLE_ID = l_route_people_id ;

         update ENG_CHANGE_ROUTE_PEOPLE_TL set
           RESPONSE_DESCRIPTION = l_comment,
           LAST_UPDATE_DATE = SYSDATE ,
           LAST_UPDATED_BY = l_performer_user_id ,
           LAST_UPDATE_LOGIN = null ,
           SOURCE_LANG = userenv('LANG')
         where ROUTE_PEOPLE_ID = l_route_people_id ;




         l_default_assignee_resp := Eng_Workflow_Util.G_RT_SUBMITTED ;

         IF ( p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE
               AND Eng_Workflow_Util.Is_Line_Ntf_WF(p_route_id => l_route_id)
             )
         THEN

IF g_debug_flag THEN
    Write_Debug('Calling GetStepDefaultRespCode  ' ) ;
END IF ;

              Eng_Workflow_Util.GetStepDefaultRespCode
              (  p_step_id  => l_step_id
              ,  x_default_resp_code  => l_default_assignee_resp
              ) ;

IF g_debug_flag THEN
    Write_Debug('Get Route Assignee Response : ' || l_default_assignee_resp ) ;
END IF ;

         END IF ;

         select ENG_CHANGE_ROUTE_PEOPLE_S.nextval  into l_new_route_people_id from dual;

         Eng_Change_Route_People_Util.INSERT_ROW
         (
          X_ROWID                     => l_rowid,
          X_ROUTE_PEOPLE_ID           => l_new_route_people_id ,
          X_STEP_ID                   => l_step_id ,
          X_ASSIGNEE_ID               => l_new_party_id,
          X_ASSIGNEE_TYPE_CODE        => G_PERSON,
          X_ADHOC_PEOPLE_FLAG         => 'Y',
          X_WF_NOTIFICATION_ID        => l_notification_id ,
          X_RESPONSE_CODE             => l_default_assignee_resp ,
          X_RESPONSE_DATE             => TO_DATE(NULL),
          X_REQUEST_ID                => NULL,
          X_ORIGINAL_SYSTEM_REFERENCE => NULL,
          X_RESPONSE_DESCRIPTION      => NULL,
          X_CREATION_DATE             => SYSDATE,
          X_CREATED_BY                => l_performer_user_id,
          X_LAST_UPDATE_DATE          => SYSDATE,
          X_LAST_UPDATED_BY           => l_performer_user_id,
          X_LAST_UPDATE_LOGIN         => null,
          X_PROGRAM_ID                => null,
          X_PROGRAM_APPLICATION_ID    => null,
          X_PROGRAM_UPDATE_DATE       => null,
          X_ORIGINAL_ASSIGNEE_ID      => l_original_assignee_id,
          X_ORIGINAL_ASSIGNEE_TYPE_CODE => l_original_assignee_type_code,
          X_RESPONSE_CONDITION_CODE   => l_response_condition_code,
          X_PARENT_ROUTE_PEOPLE_ID    => l_route_people_id
         ) ;

         FOR assoc_rec in c_report_people_assocs(l_route_people_id)
         LOOP
            SELECT ENG_CHANGE_ROUTE_ASSOCS_S.nextval into l_new_route_assoc_id from DUAL;

            insert into ENG_CHANGE_ROUTE_ASSOCS
            (
              ROUTE_ASSOCIATION_ID ,
              ROUTE_PEOPLE_ID,
              ASSOC_OBJECT_NAME,
              ASSOC_OBJ_PK1_VALUE,
              ADHOC_ASSOC_FLAG,
              OBJECT_NAME,
              OBJECT_ID1,
              CREATION_DATE ,
              CREATED_BY ,
              LAST_UPDATE_DATE ,
              LAST_UPDATED_BY ,
              LAST_UPDATE_LOGIN
            )
            values
            (
              l_new_route_assoc_id,
               l_new_route_people_id,
               assoc_rec.ASSOC_OBJECT_NAME,
               assoc_rec.ASSOC_OBJ_PK1_VALUE,
               'Y',
               assoc_rec.OBJECT_NAME,
               assoc_rec.OBJECT_ID1,
               SYSDATE,
               l_performer_user_id,
               SYSDATE,
               l_performer_user_id,
               l_performer_user_id
             );

          END LOOP;
      END LOOP;


    -- R12B
    -- CreateAction API will take care of inserting the action
    -- properly for Line Workflow too.
    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN
        l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  l_response_code
                         , p_convert_type      =>  'RESPONSE' ) ;

         -- Record Action
         Eng_Workflow_Util.CreateAction
         ( x_return_status         =>  l_return_status
         , x_msg_count             =>  l_msg_count
         , x_msg_data              =>  l_msg_data
         , p_item_type             =>  p_item_type
         , p_item_key              =>  p_item_key
         , p_notification_id       =>  p_notification_id
         , p_action_type           =>  l_action_type
         , p_comment               =>  l_comment
         , x_action_id             =>  l_created_action_id
         , p_assignee_id           =>  l_new_party_id
         ) ;


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            x_return_status  :=   l_return_status ;
            x_msg_count      :=   l_msg_count ;
            x_msg_data       :=   l_msg_data ;
        END IF ;

    END IF ; -- changeId is not null


    --
    -- R12B
    --  Grant Object Roles for this new assignee
    IF (    p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
            OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE
            OR p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_LINE_STEP_TYPE
          )
    THEN


        l_obj_index := 0 ;
        l_person_idx := 0 ;

        IF ( p_item_type = Eng_Workflow_Util.G_CHANGE_ROUTE_DOC_STEP_TYPE )
        THEN
            l_target_obj_tbl := FND_TABLE_OF_VARCHAR2_30();
            l_target_obj_tbl.EXTEND ;
            l_obj_index := l_obj_index + 1 ;
            l_target_obj_tbl(l_obj_index) := G_DOM_DOCUMENT_REVISION ;
        END IF ;


        l_person_id_tbl := FND_TABLE_OF_NUMBER();
        l_person_id_tbl.EXTEND ;
        l_person_idx := l_person_idx + 1 ;
        l_person_id_tbl(l_person_idx) := l_new_party_id ;


IF g_debug_flag THEN
    Write_Debug('Calling Eng_Workflow_Util.GrantObjectRoles for transfer assignee: ' || l_new_party_id );
END IF ;

        Eng_Workflow_Util.GrantObjectRoles
        (   p_api_version               => 1.0
         ,  p_init_msg_list             => FND_API.G_FALSE        --
         ,  p_commit                    => FND_API.G_FALSE        --
         ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
         ,  p_debug                     => FND_API.G_FALSE
         ,  p_output_dir                => NULL
         ,  p_debug_filename            => NULL
         ,  x_return_status             => l_return_status
         ,  x_msg_count                 => l_msg_count
         ,  x_msg_data                  => l_msg_data
         ,  p_change_id                 => l_change_id
         ,  p_change_line_id            => l_change_line_id
         ,  p_route_id                  => l_route_id
         ,  p_step_id                   => l_step_id
         ,  p_person_ids                => l_person_id_tbl
         ,  p_target_objects            => l_target_obj_tbl
         ,  p_api_caller                => G_WF_CALL
         ,  p_grant_option              => NULL
        ) ;

IF g_debug_flag THEN
    Write_Debug('After Eng_Workflow_Util.GrantObjectRoles: ' || l_return_status );
END IF ;

       --
       -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       -- THEN
       --     RAISE FND_API.G_EXC_ERROR ;
       -- END IF ;
    END IF ;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO AbortWorkflow_Util ;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );
END reassignRoutePeople;


--
--  R12B
--  API name   : GrantObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Grant Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line to WF Assignees
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
PROCEDURE GrantObjectRoles
(   p_api_version               IN   NUMBER
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2
 ,  x_msg_count                 OUT  NOCOPY  NUMBER
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2
 ,  p_change_id                 IN   NUMBER
 ,  p_change_line_id            IN   NUMBER
 ,  p_route_id                  IN   NUMBER
 ,  p_step_id                   IN   NUMBER
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_grant_option              IN   VARCHAR2  := NULL                   -- Optionnal
)
IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'GrantObjectRoles';
    l_api_version               CONSTANT NUMBER       := 1.0;

    l_msg_count                 NUMBER ;
    l_msg_data                  VARCHAR2(2000) ;
    l_return_status             VARCHAR2(1) ;

    l_document_role_id          NUMBER ;
    l_ocs_role                  VARCHAR2(250) ;

    l_change_id                 NUMBER ;
    l_change_line_id            NUMBER ;
    l_document_id               NUMBER ;
    l_document_revision_id      NUMBER ;

    l_target_object_tbl         FND_TABLE_OF_VARCHAR2_30 ;
    l_obj_idx                   PLS_INTEGER ;

    l_doc_rev_person_id_tbl     FND_TABLE_OF_NUMBER ;
    l_doc_rev_person_idx        PLS_INTEGER ;
    l_ocs_person_id_tbl         FND_TABLE_OF_NUMBER ;
    l_ocs_person_idx            PLS_INTEGER ;

    l_doc_rev_grant_flag        BOOLEAN ;
    l_ocs_grant_flag            BOOLEAN ;

    l_attachment_entity_name    VARCHAR2(40) ;
    l_attachment_pk1value       VARCHAR2(100) ;

    l_base_cm_type_code        VARCHAR2(40);
    l_attachment_ids           FND_TABLE_OF_NUMBER;
    l_repository_ids           FND_TABLE_OF_NUMBER;
    l_source_mdedia_ids        FND_TABLE_OF_NUMBER;
    l_sumitted_by              NUMBER;


    CURSOR  c_step_assignees ( c_step_id   NUMBER )
    IS
        SELECT   RoutePeople.STEP_ID
               , RoutePeople.ASSIGNEE_ID
               , RoutePeople.ASSIGNEE_TYPE_CODE
               , RoutePeople.ADHOC_PEOPLE_FLAG
               , RoutePeople.ORIGINAL_ASSIGNEE_ID
               , RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE
               , RoutePeople.RESPONSE_CONDITION_CODE
               , TO_CHAR(NULL)     ORIG_ROLE_OBJECT_NAME
               , TO_NUMBER(NULL)   ORIG_ROLE_OBJECT_ID
        FROM ENG_CHANGE_ROUTE_PEOPLE RoutePeople
        WHERE RoutePeople.ASSIGNEE_TYPE_CODE = 'PERSON'
        AND RoutePeople.ASSIGNEE_ID <> -1
        AND RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE <> 'ROLE'
        AND ( RoutePeople.RESPONSE_CODE IS  NULL
             OR RoutePeople.RESPONSE_CODE = G_RT_NOT_RECEIVED
             OR RoutePeople.RESPONSE_CODE = G_RT_SUBMITTED
            )
        AND RoutePeople.STEP_ID = c_step_id
        UNION ALL
        SELECT   RoutePeople.STEP_ID
               , RoutePeople.ASSIGNEE_ID
               , RoutePeople.ASSIGNEE_TYPE_CODE
               , RoutePeople.ADHOC_PEOPLE_FLAG
               , RoutePeople.ORIGINAL_ASSIGNEE_ID
               , RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE
               , RoutePeople.RESPONSE_CONDITION_CODE
               , fnd_obj.OBJ_NAME ORIG_ROLE_OBJECT_NAME
               , fnd_obj.OBJECT_ID ORIG_ROLE_OBJECT_ID
        FROM FND_FORM_FUNCTIONS fnd_func
           , FND_MENU_ENTRIES fnd_menu
           , FND_OBJECTS fnd_obj
           , ENG_CHANGE_ROUTE_PEOPLE RoutePeople
        WHERE fnd_obj.OBJECT_ID = fnd_func.OBJECT_ID
        AND fnd_func.FUNCTION_ID = fnd_menu.FUNCTION_ID
        AND fnd_menu.MENU_ID = ORIGINAL_ASSIGNEE_ID
        AND ( RoutePeople.RESPONSE_CODE IS  NULL
             OR RoutePeople.RESPONSE_CODE = G_RT_NOT_RECEIVED
             OR RoutePeople.RESPONSE_CODE = G_RT_SUBMITTED
            )
        AND RoutePeople.ASSIGNEE_TYPE_CODE = 'PERSON'
        AND RoutePeople.ASSIGNEE_ID <> -1
        AND RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE = 'ROLE'
        AND RoutePeople.STEP_ID = c_step_id  ;



    -- Future, this SQL should be dynmic SQL
    CURSOR  c_chg_objects ( c_change_id   NUMBER, c_change_line_id NUMBER)
    IS
        SELECT ChangeSubj.ENTITY_NAME CHANGE_OBJECT_NAME
             , ChangeSubj.PK1_VALUE
             , ChangeSubj.PK2_VALUE
             , ChangeSubj.PK3_VALUE
             , ChangeSubj.PK4_VALUE
             , ChangeSubj.PK5_VALUE
             , ChangeSubj.CHANGE_ID
             , ChangeSubj.CHANGE_LINE_ID
        FROM ENG_CHANGE_SUBJECTS ChangeSubj
          ,  FND_OBJECTS FndObj
        WHERE  ChangeSubj.ENTITY_NAME = FndObj.OBJ_NAME
        AND  ChangeSubj.CHANGE_ID = c_change_id
        AND  ( ChangeSubj.CHANGE_LINE_ID = c_change_line_id
               OR (ChangeSubj.CHANGE_LINE_ID IS NULL
                   AND c_change_line_id = -1)
              )
        AND FndObj.OBJ_NAME = G_DOM_DOCUMENT_REVISION ; -- R12B We only support G_DOM_DOCUMENT_REVISION

        -- For future, if we need to support Item Role in this approach too.
        -- For now, comment out
        --
        -- UNION
        -- SELECT 'EGO_ITEM' CHANGE_OBJECT_NAME
        --      , ChangeCompSubj.PK1_VALUE
        --      , ChangeCompSubj.PK2_VALUE
        --      , ChangeCompSubj.PK3_VALUE
        --      , ChangeCompSubj.PK4_VALUE
        --      , ChangeCompSubj.PK5_VALUE
        --  , ChangeCompSubj.CHANGE_ID
        --  , ChangeCompSubj.CHANGE_LINE_ID
        --  FROM ENG_CHANGE_SUBJECTS ChangeCompSubj
        --  WHERE ChangeCompSubj.ENTITY_NAME = 'EGO_COMPONENT'
        --  AND ChangeCompSubj.CHANGE_ID = :c_change_id
        --  AND  ( ChangeCompSubj.CHANGE_LINE_ID = :c_change_line_id
        --        OR ( ChangeCompSubj.CHANGE_LINE_ID IS NULL
        --            AND :c_change_line_id = -1)
        --       ) ) WHERE CHANGE_OBJECT_NAME IN ('EGO_ITEM') ;
        --


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT GrantObjectRoles;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(  l_api_version
                                       , p_api_version
                                       , l_api_name
                                       , G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;


    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.GrantObjectRoles Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id          : ' || TO_CHAR(p_change_id) );
   Write_Debug('Change Line Id     : ' || TO_CHAR(p_change_line_id) );
   Write_Debug('Route Id           : ' || TO_CHAR(p_route_id));
   Write_Debug('Step Id            : ' || TO_CHAR(p_step_id));
   Write_Debug('API Caller         : ' || p_api_caller);
   Write_Debug('Grant Option       : ' || p_grant_option);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Initialize return status ' );
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_target_object_tbl := FND_TABLE_OF_VARCHAR2_30() ;
    l_obj_idx           := 0 ;

    l_doc_rev_person_id_tbl := FND_TABLE_OF_NUMBER() ;
    l_doc_rev_person_idx    := 0 ;
    l_ocs_person_id_tbl     := FND_TABLE_OF_NUMBER() ;
    l_ocs_person_idx        := 0 ;

    l_change_id         := p_change_id ;
    l_change_line_id    := p_change_line_id ;



IF g_debug_flag THEN
   Write_Debug('Check Attachment Entity . . .');
   Write_Debug('Doc Role Id          : ' || TO_CHAR(l_document_role_id) );
   Write_Debug('File, OCS Role        : ' || l_ocs_role);
END IF ;


    IF l_change_line_id IS NULL OR l_change_line_id <= 0
    THEN
        l_change_line_id := -1 ;

        l_attachment_entity_name    :=  'ENG_ENGINEERING_CHANGES' ;
        l_attachment_pk1value       :=  TO_CHAR(l_change_id) ;
        l_base_cm_type_code := GetBaseChangeMgmtTypeCode(p_change_id);

    ELSE

        l_attachment_entity_name    :=  'ENG_CHANGE_LINES' ;
        l_attachment_pk1value       :=  TO_CHAR(l_change_line_id) ;

    END IF ;


IF g_debug_flag THEN
   Write_Debug('Attachment Entity     : ' || l_attachment_entity_name );
   Write_Debug('Attachment PK1Value   : ' || l_attachment_pk1value );
END IF ;


    l_ocs_grant_flag      := FALSE  ;
    l_doc_rev_grant_flag  := FALSE  ;

    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------

IF g_debug_flag THEN
   Write_Debug('1. Check p_target_objects parameter. . .   '  );
END IF ;

    --
    -- 1. Check p_target_objects parameter
    -- If, it's NOT null, we don't need to check Change Header and Line Subject
    -- Otherwise, we will query the Change Header or Line Subjects and get Subject Objects
    -- plus OCS File. Construct local target objects tables
    --
    -- Note: IN R12B, anyway we support only DOM_DOCUMENT_REVISION and OCS File
    --
    IF ( p_target_objects IS NOT NULL AND p_target_objects.count > 0 )
    THEN
        FOR i in p_target_objects.first .. p_target_objects.last
        LOOP
            l_target_object_tbl.EXTEND ;
            l_obj_idx := l_obj_idx + 1;
            l_target_object_tbl(l_obj_idx):=p_target_objects(i) ;

            IF (G_OCS_FILE = p_target_objects(i))
            THEN
                l_ocs_grant_flag      := TRUE  ;

IF g_debug_flag THEN
   Write_Debug(' OCS Grant Flag True . . .   '  );
END IF ;

            ELSIF (G_DOM_DOCUMENT_REVISION = p_target_objects(i))
            THEN
                l_doc_rev_grant_flag  := TRUE  ;

IF g_debug_flag THEN
   Write_Debug(' DCO Rev  Grant Flag True . . .   '  );
END IF ;
            END IF ;

        END LOOP;


    ELSE
        --
        -- By Default we support the following objects in R12B
        --
IF g_debug_flag THEN
   Write_Debug(' Target Object is Null. By Default we support the following objects. . .   '  );
END IF ;

        -- OCS Files
        l_target_object_tbl.EXTEND ;
        l_obj_idx := l_obj_idx + 1;
        l_target_object_tbl(l_obj_idx) := G_OCS_FILE ;
        l_ocs_grant_flag      := TRUE  ;

IF g_debug_flag THEN
   Write_Debug(' OCS Grant Flag True . . .   '  );
END IF ;

        -- G_DOM_DOCUMENT_REVISION
        l_target_object_tbl.EXTEND ;
        l_obj_idx := l_obj_idx + 1;
        l_target_object_tbl(l_obj_idx) := G_DOM_DOCUMENT_REVISION;
        l_doc_rev_grant_flag  := TRUE  ;

IF g_debug_flag THEN
   Write_Debug(' DCO Rev  Grant Flag True . . .   '  );
END IF ;


    END IF ;

    --
    -- 2. Get Auto Grants Roles specified in Workflow Definition
    --
    -- Note: IN R12B, anyway we support only DOM_DOCUMENT_REVISION and OCS File
    --
    --
    -- Get Step Activity Attributes for Auto Grants
    GetStepAutoGranatRoles
    ( p_step_id                => p_step_id
    , x_document_role_id       => l_document_role_id
    , x_ocs_role               => l_ocs_role ) ;


IF g_debug_flag THEN
   Write_Debug('Get Auto Grants Roles specified in Workflow Definition. . .');
   Write_Debug('Doc Role Id          : ' || TO_CHAR(l_document_role_id) );
   Write_Debug('File, OCS Role       : ' || l_ocs_role);
END IF ;

    IF (l_document_role_id IS NULL AND l_ocs_role IS NULL )
    THEN

IF g_debug_flag THEN
   Write_Debug('Any Roles for Auto Grants are not specified for this step process. Return.');
END IF ;
        RETURN ;

    END IF ;

    --
    -- 3. Check p_person_ids  parameter
    -- If, it's NOT null, we don't need to query assignees under given p_step_id
    -- Otherwise, we will query Workflow Step Assignees and construct person ids table
    --
    IF ( p_person_ids IS NOT NULL AND p_person_ids.count > 0 )
    THEN

        FOR j in p_person_ids.first .. p_person_ids.last
        LOOP
            l_doc_rev_person_id_tbl.EXTEND ;
            l_doc_rev_person_idx := l_doc_rev_person_idx + 1;
            l_doc_rev_person_id_tbl(l_doc_rev_person_idx) := p_person_ids(j) ;

            l_ocs_person_id_tbl.EXTEND ;
            l_ocs_person_idx := l_ocs_person_idx + 1;
            l_ocs_person_id_tbl(l_ocs_person_idx) := p_person_ids(j) ;

        END LOOP;

    ELSE

        FOR rtp_rec  IN c_step_assignees (c_step_id => p_step_id )
        LOOP

            --
            -- Exclude the assignees derivded from DOM_DOUCMENT_REVISION Role
            --
            IF ( rtp_rec.orig_role_object_name  IS NULL
                 OR rtp_rec.orig_role_object_name <> G_DOM_DOCUMENT_REVISION
                )
            THEN

                l_doc_rev_person_id_tbl.EXTEND ;
                l_doc_rev_person_idx := l_doc_rev_person_idx + 1;
                l_doc_rev_person_id_tbl(l_doc_rev_person_idx) := rtp_rec.assignee_id ;

            END IF ;

            l_ocs_person_id_tbl.EXTEND ;
            l_ocs_person_idx := l_ocs_person_idx + 1;
            l_ocs_person_id_tbl(l_ocs_person_idx) := rtp_rec.assignee_id ;

        END LOOP ;

    END IF ;

    IF (l_doc_rev_grant_flag)
    THEN

        --
        -- 4. Execute Query for Change Subject by given change id and change line id
        --    and iterlate the fetched row.
        --    Call insdividual API to grant the objects to assignees.
        --
        -- Note: IN R12B, anyway we support only DOM_DOCUMENT_REVISION and OCS File
        --



        FOR c_chg_objects_rec  IN c_chg_objects (  c_change_id => l_change_id
                                                ,  c_change_line_id => l_change_line_id
                                                )
        LOOP
            IF ( G_DOM_DOCUMENT_REVISION = c_chg_objects_rec.CHANGE_OBJECT_NAME
                 AND l_document_role_id IS NOT NULL
                 AND (l_doc_rev_person_id_tbl IS NOT NULL AND l_doc_rev_person_id_tbl.count > 0)
               )
            THEN

                -- MK Comment Need to verify this PK1 is Revision Id or not
                l_document_id          := TO_NUMBER(c_chg_objects_rec.PK1_VALUE) ;
                l_document_revision_id := TO_NUMBER(c_chg_objects_rec.PK2_VALUE) ;


IF g_debug_flag THEN
    Write_Debug('Calling ENG_DOCUMENT_UTIL.Grant_Document_Role. . .' );
END IF ;


                ENG_DOCUMENT_UTIL.Grant_Document_Role
                (   p_api_version               => 1.0
                 ,  p_init_msg_list             => FND_API.G_FALSE        --
                 ,  p_commit                    => FND_API.G_FALSE        --
                 ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
                 ,  p_debug                     => p_debug
                 ,  p_output_dir                => p_output_dir
                 ,  p_debug_filename            => p_debug_filename
                 ,  x_return_status             => l_return_status
                 ,  x_msg_count                 => l_msg_count
                 ,  x_msg_data                  => l_msg_data
                 ,  p_document_id               => l_document_id               -- Dom Document Id
                 ,  p_document_revision_id      => l_document_revision_id      -- Dom Document Revision Id
                 ,  p_change_id                 => l_change_id                 -- Change Id
                 ,  p_change_line_id            => l_change_line_id            -- Change Line Id
                 ,  p_party_ids                 => l_doc_rev_person_id_tbl     -- Person's HZ_PARTIES.PARTY_ID Array
                 ,  p_role_id                   => l_document_role_id          -- Role Id to be granted
                 ,  p_api_caller                => p_api_caller                -- Optionnal for future use
                ) ;


IF g_debug_flag THEN
    Write_Debug('After calling ENG_DOCUMENT_UTIL.Grant_Document_Role: ' || l_return_status );
END IF ;

                 --
                 -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                 -- THEN
                 --     RAISE FND_API.G_EXC_ERROR ;
                 -- END IF ;
                 --

            END IF ;
        END LOOP ;


    END IF ; -- (l_doc_rev_grant_flag IS TRUE)

    --
    -- 5. Call ENG_DOCUMENT_UTIL.Grant_Attachments_OCSRole
    --    to grant roles on Attachments
    --


    IF ( l_ocs_grant_flag
         AND  l_ocs_role IS NOT NULL
         AND (l_ocs_person_id_tbl IS NOT NULL AND l_ocs_person_id_tbl.count > 0)
       )
    THEN

IF g_debug_flag THEN
    Write_Debug('Calling ENG_DOCUMENT_UTIL.Grant_Attachments_OCSRole. . .' );

END IF ;
     if (l_base_cm_type_code is not null
     and l_base_cm_type_code in ('ATTACHMENT_APPROVAL','ATTACHMENT_REVIEW') )
     then
         GetAttachmentChangeDetails(  p_change_id  => l_attachment_pk1value
                     , x_source_media_id_tbl           => l_source_mdedia_ids
                     , x_attached_document_id_tbl      => l_attachment_ids
                     , x_repository_id_tbl             => l_repository_ids
                     , x_creator_user_id           => l_sumitted_by
                    );

     end if;

        ENG_DOCUMENT_UTIL.Grant_Attachments_OCSRole
        (   p_api_version               => 1.0
         ,  p_init_msg_list             => FND_API.G_FALSE        --
         ,  p_commit                    => FND_API.G_FALSE        --
         ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
         ,  p_debug                     => p_debug
         ,  p_output_dir                => p_output_dir
         ,  p_debug_filename            => p_debug_filename
         ,  x_return_status             => l_return_status
         ,  x_msg_count                 => l_msg_count
         ,  x_msg_data                  => l_msg_data
         ,  p_entity_name               => l_attachment_entity_name    -- ENG_ENGINEERING_CHANGES or ENG_CHANGE_LINES
         ,  p_pk1value                  => l_attachment_pk1value       -- CHANGE_ID or CHANGE_LINE_ID
         ,  p_pk2value                  => NULL
         ,  p_pk3value                  => NULL
         ,  p_pk4value                  => NULL
         ,  p_pk5value                  => NULL
         ,  p_party_ids                 => l_ocs_person_id_tbl         -- Person's HZ_PARTIES.PARTY_ID Array
         ,  p_ocs_role                  => l_ocs_role                  -- OCS Role to be granted
         ,  p_source_media_id_tbl           => l_source_mdedia_ids
         ,  p_attachment_id_tbl             => l_attachment_ids
         ,  p_repository_id_tbl             => l_repository_ids
         ,  p_submitted_by              => l_sumitted_by
         ,  p_api_caller                => p_api_caller                -- Optionnal for future use
        ) ;



IF g_debug_flag THEN
    Write_Debug('After ENG_DOCUMENT_UTIL.Grant_Attachments_OCSRole: ' || l_return_status );
END IF ;

       --
       -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       -- THEN
       --     RAISE FND_API.G_EXC_ERROR ;
       -- END IF ;
       --


    END IF ;



IF g_debug_flag THEN
   Write_Debug('After executing GrantObjectRoles API Body') ;
END IF ;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN

IF g_debug_flag THEN
   Write_Debug('Do Commit.') ;
END IF ;

      COMMIT WORK;

   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count  => x_msg_count
      ,  p_data   => x_msg_data
      );

IF g_debug_flag THEN
   Write_Debug('Finish. Eng Of Proc') ;
   Close_Debug_Session ;
END IF ;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit )
       THEN
         ROLLBACK TO GrantObjectRoles ;
       END IF ;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with Error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit )
       THEN
         ROLLBACK TO GrantObjectRoles ;
IF g_debug_flag THEN
   Write_Debug('Rollback. . . ' );
END IF ;

       END IF ;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with unxepcted error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN OTHERS THEN
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit )
       THEN
         ROLLBACK TO GrantObjectRoles ;

IF g_debug_flag THEN
   Write_Debug('Rollback. . . ' );
END IF ;

       END IF ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME
              , l_api_name
              );
       END IF;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with system unxepcted error: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;


END GrantObjectRoles ;


--
--  R12B
--  API name   : RevokeObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Revoke Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line from WF Assignees
--               This API is mainly called when Chagne Object or Change Line is cancelled.
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
--              p_revoke_option   G_REVOKE_ALL will reovked object roles for Header and Lines
--                                G_REVOKE_HEADER will reovked object roles for Header
--                                G_REVOKE_LINE will reovked object roles for Line
--                                p_revoke_option default G_REVOKE_LINE
--
PROCEDURE RevokeObjectRoles
(   p_api_version               IN   NUMBER                             --
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2                   --
 ,  x_msg_count                 OUT  NOCOPY  NUMBER                     --
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
 ,  p_change_id                 IN   NUMBER                             -- Change Id
 ,  p_change_line_id            IN   NUMBER                             -- Change Line Id
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_revoke_option             IN   VARCHAR2  := NULL                  -- Optionnal: G_REVOKE_ALL
 )
 IS
      l_msg_count                 NUMBER ;
      l_msg_data                  VARCHAR2(2000) ;
      l_return_status             VARCHAR2(1) ;

      l_change_id                 NUMBER ;
      l_change_line_id            NUMBER ;
      l_revoke_option             VARCHAR2(30) ;
      l_route_id                  NUMBER ;


      CURSOR  c_header_routes(c_change_id NUMBER)
      IS
          SELECT  routes.OBJECT_ID1 CHANGE_ID
                , TO_NUMBER(NULL)   CHANGE_LINE_ID
                , routes.ROUTE_ID
          FROM  ENG_CHANGE_ROUTES  routes
          WHERE routes.STATUS_CODE IN ( Eng_Workflow_Util.G_RT_REJECTED
                                 , Eng_Workflow_Util.G_RT_APPROVED
                                 , Eng_Workflow_Util.G_RT_COMPLETED
                                 , Eng_Workflow_Util.G_RT_TIME_OUT) -- G_RT_ABORTED was taken care by ABORT WF
          AND ( routes.TEMPLATE_FLAG = G_RT_INSTANCE
                OR routes.TEMPLATE_FLAG = G_RT_HISTORY)
          AND routes.OBJECT_NAME = G_ENG_CHANGE
          AND routes.OBJECT_ID1 = c_change_id ;


      CURSOR  c_line_routes(c_change_id NUMBER, c_change_line_id NUMBER)
      IS
          SELECT  chg_line.CHANGE_ID
                , chg_line.CHANGE_LINE_ID
                , line_routes.ROUTE_ID
          FROM  ENG_CHANGE_ROUTES  line_routes
             ,  ENG_CHANGE_LINES chg_line
          WHERE line_routes.STATUS_CODE IN ( Eng_Workflow_Util.G_RT_REJECTED
                                 , Eng_Workflow_Util.G_RT_APPROVED
                                 , Eng_Workflow_Util.G_RT_COMPLETED
                                 , Eng_Workflow_Util.G_RT_TIME_OUT ) -- G_RT_ABORTED was taken care by ABORT WF
          AND ( line_routes.TEMPLATE_FLAG = G_RT_INSTANCE
                OR line_routes.TEMPLATE_FLAG = G_RT_HISTORY)
          AND line_routes.object_id1 = chg_line.CHANGE_LINE_ID
          AND line_routes.OBJECT_NAME = G_ENG_CHANGE_LINE
          AND ( chg_line.CHANGE_LINE_ID = c_change_line_id  OR c_change_line_id = -1)
          AND chg_line.CHANGE_ID = c_change_id ;



  BEGIN

       l_change_id       :=  p_change_id ;
       l_change_line_id  :=  p_change_line_id ;

       IF  l_change_line_id IS NULL OR l_change_line_id <= 0
       THEN
           l_change_line_id := -1 ;
       END IF ;

       l_revoke_option := p_revoke_option ;
       IF l_revoke_option IS NULL
       THEN
          l_revoke_option := G_REVOKE_LINE ;
       END IF ;


       IF (l_revoke_option <> G_REVOKE_LINE)
       THEN
           FOR l_rec  IN c_header_routes (c_change_id => l_change_id )
           LOOP
               l_route_id := l_rec.ROUTE_ID ;

IF g_debug_flag THEN
    Write_Debug('ENG_DOCUMENT_UTIL.RevokeObjectRoles For Header Route .' || TO_CHAR(l_route_id) );
END IF ;
               BEGIN
                   RevokeObjectRoles
                   (   p_api_version               => p_api_version
                    ,  p_init_msg_list             => FND_API.G_FALSE
                    ,  p_commit                    => p_commit
                    ,  p_validation_level          => p_validation_level
                    ,  p_debug                     => p_debug
                    ,  p_output_dir                => p_output_dir
                    ,  p_debug_filename            => p_debug_filename
                    ,  x_return_status             => l_return_status
                    ,  x_msg_count                 => l_msg_count
                    ,  x_msg_data                  => l_msg_data
                    ,  p_change_id                 => p_change_id
                    ,  p_change_line_id            => p_change_line_id
                    ,  p_route_id                  => l_route_id
                    ,  p_person_ids                => p_person_ids
                    ,  p_target_objects            => p_target_objects
                    ,  p_api_caller                => p_api_caller
                    ,  p_revoke_option             => p_revoke_option
                    )  ;

IF g_debug_flag THEN
    Write_Debug('After ENG_DOCUMENT_UTIL.RevokeObjectRoles For Header Route.' || l_route_id );
END IF ;
                EXCEPTION
                  WHEN OTHERS THEN
                     NULL ;
                END ;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    x_return_status := l_return_status ;
                    x_msg_count     := l_msg_count ;
                    x_msg_data      := l_msg_data ;
                    RETURN ;
                END IF ;
           END LOOP ;
        END IF ; -- (p_revoke_option <> G_REVOKE_LINE)


       IF  ( l_revoke_option = G_REVOKE_ALL OR l_revoke_option = G_REVOKE_LINE )
       THEN

           FOR l_line_rec  IN c_line_routes (c_change_id => l_change_id, c_change_line_id => l_change_line_id )
           LOOP
               l_route_id := l_line_rec.ROUTE_ID ;

IF g_debug_flag THEN
    Write_Debug('Calling  ENG_DOCUMENT_UTIL.RevokeObjectRoles For Line .Route ' || TO_CHAR(l_route_id) );
END IF ;
               BEGIN
                   RevokeObjectRoles
                   (   p_api_version               => p_api_version
                    ,  p_init_msg_list             => FND_API.G_FALSE
                    ,  p_commit                    => p_commit
                    ,  p_validation_level          => p_validation_level
                    ,  p_debug                     => p_debug
                    ,  p_output_dir                => p_output_dir
                    ,  p_debug_filename            => p_debug_filename
                    ,  x_return_status             => l_return_status
                    ,  x_msg_count                 => l_msg_count
                    ,  x_msg_data                  => l_msg_data
                    ,  p_change_id                 => p_change_id
                    ,  p_change_line_id            => p_change_line_id
                    ,  p_route_id                  => l_route_id
                    ,  p_person_ids                => p_person_ids
                    ,  p_target_objects            => p_target_objects
                    ,  p_api_caller                => p_api_caller
                    ,  p_revoke_option             => p_revoke_option
                    )  ;

IF g_debug_flag THEN
    Write_Debug('After ENG_DOCUMENT_UTIL.RevokeObjectRoles For Line Route.' || l_route_id );
END IF ;
                EXCEPTION
                  WHEN OTHERS THEN
                     NULL ;
                END ;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    x_return_status := l_return_status ;
                    x_msg_count     := l_msg_count ;
                    x_msg_data      := l_msg_data ;
                    RETURN ;
                END IF ;
           END LOOP ;

       END IF ;

 END RevokeObjectRoles ;


--
--  R12B
--  API name   : RevokeObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Revoke Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line from WF Assignees
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
PROCEDURE RevokeObjectRoles
(   p_api_version               IN   NUMBER                             --
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2                   --
 ,  x_msg_count                 OUT  NOCOPY  NUMBER                     --
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
 ,  p_change_id                 IN   NUMBER                             -- Change Id
 ,  p_change_line_id            IN   NUMBER                             -- Change Line Id
 ,  p_route_id                  IN   NUMBER
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_revoke_option             IN   VARCHAR2  := NULL                  -- Optionnal
 )
 IS

     l_msg_count                 NUMBER ;
     l_msg_data                  VARCHAR2(2000) ;
     l_return_status             VARCHAR2(1) ;

     l_step_id                   NUMBER ;


     CURSOR  c_route_step( c_route_id   NUMBER )
     IS
         SELECT   RouteStep.STEP_ID
         FROM ENG_CHANGE_ROUTE_STEPS RouteStep
         WHERE ( RouteStep.STEP_STATUS_CODE <> Eng_Workflow_Util.G_RT_NOT_STARTED
                 AND  RouteStep.STEP_STATUS_CODE <> Eng_Workflow_Util.G_RT_IN_PROGRESS)
         AND RouteStep.ROUTE_ID = c_route_id ;



 BEGIN

      FOR l_rec  IN c_route_step (c_route_id => p_route_id )
      LOOP

          l_step_id := l_rec.STEP_ID ;

 IF g_debug_flag THEN
      Write_Debug('ENG_DOCUMENT_UTIL.RevokeObjectRoles For Step.' || TO_CHAR(l_step_id) );
 END IF ;
          BEGIN
              RevokeObjectRoles
              (   p_api_version               => p_api_version
               ,  p_init_msg_list             => FND_API.G_FALSE
               ,  p_commit                    => p_commit
               ,  p_validation_level          => p_validation_level
               ,  p_debug                     => p_debug
               ,  p_output_dir                => p_output_dir
               ,  p_debug_filename            => p_debug_filename
               ,  x_return_status             => l_return_status
               ,  x_msg_count                 => l_msg_count
               ,  x_msg_data                  => l_msg_data
               ,  p_change_id                 => p_change_id
               ,  p_change_line_id            => p_change_line_id
               ,  p_route_id                  => p_route_id
               ,  p_step_id                   => l_step_id
               ,  p_person_ids                => p_person_ids
               ,  p_target_objects            => p_target_objects
               ,  p_api_caller                => p_api_caller
               ,  p_revoke_option             => p_revoke_option
               )  ;

 IF g_debug_flag THEN
     Write_Debug('After ENG_DOCUMENT_UTIL.RevokeObjectRoles For Step.' || l_rec.STEP_ID );
 END IF ;
           EXCEPTION
             WHEN OTHERS THEN
                NULL ;
           END ;

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
               x_return_status := l_return_status ;
               x_msg_count     := l_msg_count ;
               x_msg_data      := l_msg_data ;
               RETURN ;
           END IF ;
      END LOOP;


END RevokeObjectRoles ;

--
--  R12B
--  API name   : RevokeObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Revoke Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line from WF Assignees
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
PROCEDURE RevokeObjectRoles
(   p_api_version               IN   NUMBER                             --
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2                   --
 ,  x_msg_count                 OUT  NOCOPY  NUMBER                     --
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
 ,  p_change_id                 IN   NUMBER                             -- Change Id
 ,  p_change_line_id            IN   NUMBER                             -- Change Line Id
 ,  p_route_id                  IN   NUMBER
 ,  p_step_id                   IN   NUMBER
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_revoke_option             IN   VARCHAR2  := NULL                  -- Optionnal
 )
 IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'RevokeObjectRoles';
    l_api_version               CONSTANT NUMBER       := 1.0;

    l_msg_count                 NUMBER ;
    l_msg_data                  VARCHAR2(2000) ;
    l_return_status             VARCHAR2(1) ;

    l_document_role_id          NUMBER ;
    l_ocs_role                  VARCHAR2(250) ;

    l_change_id                 NUMBER ;
    l_change_line_id            NUMBER ;

    l_document_id               NUMBER ;
    l_document_revision_id      NUMBER ;

    l_target_object_tbl         FND_TABLE_OF_VARCHAR2_30 ;
    l_obj_idx                   PLS_INTEGER ;

    l_doc_rev_person_id_tbl     FND_TABLE_OF_NUMBER ;
    l_doc_rev_person_idx        PLS_INTEGER ;
    l_ocs_person_id_tbl         FND_TABLE_OF_NUMBER ;
    l_ocs_person_idx            PLS_INTEGER ;

    l_doc_rev_revoke_flag       BOOLEAN ;
    l_ocs_revoke_flag           BOOLEAN ;

    l_attachment_entity_name    VARCHAR2(40) ;
    l_attachment_pk1value       VARCHAR2(100) ;


    CURSOR  c_step_assignees ( c_step_id   NUMBER )
    IS
        SELECT   RouteStep.ROUTE_ID
               , RoutePeople.STEP_ID
               , RoutePeople.ASSIGNEE_ID
               , RoutePeople.ASSIGNEE_TYPE_CODE
               , RoutePeople.ADHOC_PEOPLE_FLAG
               , RoutePeople.ORIGINAL_ASSIGNEE_ID
               , RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE
               , RoutePeople.RESPONSE_CONDITION_CODE
               , TO_CHAR(NULL)     ORIG_ROLE_OBJECT_NAME
               , TO_NUMBER(NULL)   ORIG_ROLE_OBJECT_ID
        FROM ENG_CHANGE_ROUTE_PEOPLE RoutePeople
           , ENG_CHANGE_ROUTE_STEPS RouteStep
        WHERE RoutePeople.ASSIGNEE_TYPE_CODE = 'PERSON'
        AND RoutePeople.ASSIGNEE_ID <> -1
        AND RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE <> 'ROLE'
        AND RoutePeople.STEP_ID = RouteStep.STEP_ID
        AND ( RouteStep.STEP_STATUS_CODE <> Eng_Workflow_Util.G_RT_NOT_STARTED
              AND  RouteStep.STEP_STATUS_CODE <> Eng_Workflow_Util.G_RT_IN_PROGRESS)
        AND RouteStep.STEP_ID = c_step_id
        UNION
        SELECT   RouteStep.ROUTE_ID
               , RoutePeople.STEP_ID
               , RoutePeople.ASSIGNEE_ID
               , RoutePeople.ASSIGNEE_TYPE_CODE
               , RoutePeople.ADHOC_PEOPLE_FLAG
               , RoutePeople.ORIGINAL_ASSIGNEE_ID
               , RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE
               , RoutePeople.RESPONSE_CONDITION_CODE
               , fnd_obj.OBJ_NAME ORIG_ROLE_OBJECT_NAME
               , fnd_obj.OBJECT_ID ORIG_ROLE_OBJECT_ID
        FROM FND_FORM_FUNCTIONS fnd_func
           , FND_MENU_ENTRIES fnd_menu
           , FND_OBJECTS fnd_obj
           , ENG_CHANGE_ROUTE_PEOPLE RoutePeople
           , ENG_CHANGE_ROUTE_STEPS RouteStep
        WHERE fnd_obj.OBJECT_ID = fnd_func.OBJECT_ID
        AND fnd_func.FUNCTION_ID = fnd_menu.FUNCTION_ID
        AND fnd_menu.MENU_ID = ORIGINAL_ASSIGNEE_ID
        AND RoutePeople.ASSIGNEE_TYPE_CODE = 'PERSON'
        AND RoutePeople.ASSIGNEE_ID <> -1
        AND RoutePeople.ORIGINAL_ASSIGNEE_TYPE_CODE = 'ROLE'
        AND RoutePeople.STEP_ID = RouteStep.STEP_ID
        AND ( RouteStep.STEP_STATUS_CODE <> Eng_Workflow_Util.G_RT_NOT_STARTED
              AND  RouteStep.STEP_STATUS_CODE <> Eng_Workflow_Util.G_RT_IN_PROGRESS)
        AND RouteStep.STEP_ID = c_step_id  ;



    -- Future, this SQL should be dynmic SQL
    CURSOR  c_chg_objects ( c_change_id   NUMBER, c_change_line_id NUMBER)
    IS
        SELECT ChangeSubj.ENTITY_NAME CHANGE_OBJECT_NAME
             , ChangeSubj.PK1_VALUE
             , ChangeSubj.PK2_VALUE
             , ChangeSubj.PK3_VALUE
             , ChangeSubj.PK4_VALUE
             , ChangeSubj.PK5_VALUE
             , ChangeSubj.CHANGE_ID
             , ChangeSubj.CHANGE_LINE_ID
        FROM ENG_CHANGE_SUBJECTS ChangeSubj
          ,  FND_OBJECTS FndObj
        WHERE  ChangeSubj.ENTITY_NAME = FndObj.OBJ_NAME
        AND  ChangeSubj.CHANGE_ID = c_change_id
        AND  ( ChangeSubj.CHANGE_LINE_ID = c_change_line_id
               OR (ChangeSubj.CHANGE_LINE_ID IS NULL
                   AND c_change_line_id = -1)
              )
        AND FndObj.OBJ_NAME = G_DOM_DOCUMENT_REVISION ; -- R12B We only support G_DOM_DOCUMENT_REVISION

        -- For future, if we need to support Item Role in this approach too.
        -- For now, comment out
        --
        -- UNION
        -- SELECT 'EGO_ITEM' CHANGE_OBJECT_NAME
        --      , ChangeCompSubj.PK1_VALUE
        --      , ChangeCompSubj.PK2_VALUE
        --      , ChangeCompSubj.PK3_VALUE
        --      , ChangeCompSubj.PK4_VALUE
        --      , ChangeCompSubj.PK5_VALUE
        --  , ChangeCompSubj.CHANGE_ID
        --  , ChangeCompSubj.CHANGE_LINE_ID
        --  FROM ENG_CHANGE_SUBJECTS ChangeCompSubj
        --  WHERE ChangeCompSubj.ENTITY_NAME = 'EGO_COMPONENT'
        --  AND ChangeCompSubj.CHANGE_ID = :c_change_id
        --  AND  ( ChangeCompSubj.CHANGE_LINE_ID = :c_change_line_id
        --        OR ( ChangeCompSubj.CHANGE_LINE_ID IS NULL
        --            AND :c_change_line_id = -1)
        --       ) ) WHERE CHANGE_OBJECT_NAME IN ('EGO_ITEM') ;
        --



BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT RevokeObjectRoles;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(  l_api_version
                                       , p_api_version
                                       , l_api_name
                                       , G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;


    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;


IF g_debug_flag THEN
   Write_Debug('Eng_Workflow_Util.RevokeObjectRoles Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Change Id          : ' || TO_CHAR(p_change_id) );
   Write_Debug('Change Line Id     : ' || TO_CHAR(p_change_line_id) );
   Write_Debug('Route Id           : ' || TO_CHAR(p_route_id));
   Write_Debug('Step Id            : ' || TO_CHAR(p_step_id));
   Write_Debug('API Caller         : ' || p_api_caller);
   Write_Debug('Revoke Option      : ' || p_revoke_option);
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Initialize return status ' );
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_target_object_tbl := FND_TABLE_OF_VARCHAR2_30() ;
    l_obj_idx           := 0 ;

    l_doc_rev_person_id_tbl := FND_TABLE_OF_NUMBER() ;
    l_doc_rev_person_idx    := 0 ;
    l_ocs_person_id_tbl     := FND_TABLE_OF_NUMBER() ;
    l_ocs_person_idx        := 0 ;

    l_change_id         := p_change_id ;
    l_change_line_id    := p_change_line_id ;

    IF l_change_line_id IS NULL OR l_change_line_id <= 0
    THEN

        l_change_line_id := -1 ;

        l_attachment_entity_name    :=  'ENG_ENGINEERING_CHANGES' ;
        l_attachment_pk1value       :=  TO_CHAR(l_change_id) ;

    ELSE
        l_attachment_entity_name    :=  'ENG_CHANGE_LINES' ;
        l_attachment_pk1value       :=  TO_CHAR(l_change_line_id) ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('Attachmetn Entity');
   Write_Debug('Entity Name : ' || l_attachment_entity_name );
   Write_Debug('Entity Id1  : ' || l_attachment_pk1value );
END IF ;

    l_ocs_revoke_flag      := FALSE  ;
    l_doc_rev_revoke_flag  := FALSE  ;

    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------


    --
    -- 1. Check p_target_objects parameter
    -- If, it's NOT null, we don't need to check Change Header and Line Subject
    -- Otherwise, we will query the Change Header or Line Subjects and get Subject Objects
    -- plus OCS File. Construct local target objects tables
    --
    -- Note: IN R12B, anyway we support only DOM_DOCUMENT_REVISION and OCS File
    --
    IF ( p_target_objects IS NOT NULL AND p_target_objects.count > 0 )
    THEN


IF g_debug_flag THEN
   Write_Debug('p_target_objects IS NOT NULL. . .');
END IF ;


        FOR i in p_target_objects.first .. p_target_objects.last
        LOOP

IF g_debug_flag THEN
   Write_Debug('p_target_objects = ' || to_char(i) || ' :  ' || p_target_objects(i) );
END IF ;
            l_target_object_tbl.EXTEND ;
            l_obj_idx := l_obj_idx + 1 ;
            l_target_object_tbl(l_obj_idx) := p_target_objects(i) ;

            IF (G_OCS_FILE = p_target_objects(i))
            THEN
                l_ocs_revoke_flag      := TRUE  ;

            ELSIF (G_DOM_DOCUMENT_REVISION = p_target_objects(i))
            THEN
                l_doc_rev_revoke_flag  := TRUE  ;

            END IF ;

        END LOOP;


    ELSE


IF g_debug_flag THEN
   Write_Debug('p_target_objects IS NULL. . .');
END IF ;

        --
        -- By Default we support the following objects in R12B
        --
        -- OCS Files
        l_target_object_tbl.EXTEND ;
        l_obj_idx := l_obj_idx + 1 ;
        l_target_object_tbl(l_obj_idx):= G_OCS_FILE ;
        l_ocs_revoke_flag      := TRUE  ;

        -- G_DOM_DOCUMENT_REVISION
        l_target_object_tbl.EXTEND ;
        l_obj_idx := l_obj_idx + 1 ;
        l_target_object_tbl(l_obj_idx):= G_DOM_DOCUMENT_REVISION;
        l_doc_rev_revoke_flag  := TRUE  ;

    END IF ;


    --
    -- We don't need to get Roles per discussion with DOM team
    -- DOM Security API should revoke the grants per entity or change object info
    -- and person ids.
    -- So if we face a performance issue, we should modify the logic to get all route and step
    -- people by one-query and call the API without getting Roles specified
    -- in WFT definition per Step Workflow Process
    --
    -- 2. Get Auto Grants Roles specified in Workflow Definition
    --
    -- Note: IN R12B, anyway we support only DOM_DOCUMENT_REVISION and OCS File
    --
    --
    -- Get Step Activity Attributes for Auto Grants
    GetStepAutoGranatRoles
    ( p_step_id                => p_step_id
    , x_document_role_id       => l_document_role_id
    , x_ocs_role               => l_ocs_role ) ;


IF g_debug_flag THEN
   Write_Debug('Get Auto Revoke Roles specified in Workflow Definition. . .');
   Write_Debug('Doc Role Id          : ' || TO_CHAR(l_document_role_id) );
   Write_Debug('File, OCS Role       : ' || l_ocs_role);
END IF ;

    IF (l_document_role_id IS NULL AND l_ocs_role IS NULL )
    THEN

IF g_debug_flag THEN
   Write_Debug('Any Roles for Auto Revoke are not specified for this step process. Return.');
END IF ;

        --
        -- Comment out this. Just in case
        -- RETURN ;

    END IF ;

    -- 3. Check p_person_ids  parameter
    -- If, it's NOT null, we don't need to query assignees under given p_step_id
    -- Otherwise, we will query Workflow Step Assignees and construct person ids table
    --
    IF ( p_person_ids IS NOT NULL AND p_person_ids.count > 0 )
    THEN

        FOR j in p_person_ids.first .. p_person_ids.last
        LOOP
            l_doc_rev_person_id_tbl.EXTEND ;
            l_doc_rev_person_idx := l_doc_rev_person_idx + 1 ;
            l_doc_rev_person_id_tbl(l_doc_rev_person_idx) := p_person_ids(j) ;

            l_ocs_person_id_tbl.EXTEND ;
            l_ocs_person_idx := l_ocs_person_idx + 1;
            l_ocs_person_id_tbl(l_ocs_person_idx) := p_person_ids(j) ;

        END LOOP;

    ELSE

        FOR rtp_rec  IN c_step_assignees (c_step_id => p_step_id )
        LOOP

            --
            -- Exclude the assignees derivded from DOM_DOUCMENT_REVISION Role
            --
            IF ( rtp_rec.orig_role_object_name  IS NULL
                 OR rtp_rec.orig_role_object_name <> G_DOM_DOCUMENT_REVISION
                )
            THEN

                l_doc_rev_person_id_tbl.EXTEND ;
                l_doc_rev_person_idx := l_doc_rev_person_idx + 1 ;
                l_doc_rev_person_id_tbl(l_doc_rev_person_idx):= rtp_rec.assignee_id ;

            END IF ;

            l_ocs_person_id_tbl.EXTEND ;
            l_ocs_person_idx := l_ocs_person_idx + 1;
            l_ocs_person_id_tbl(l_ocs_person_idx):=rtp_rec.assignee_id ;

        END LOOP ;

    END IF ;



    IF (l_doc_rev_revoke_flag)
    THEN

        --
        -- 4. Execute Query for Change Subject by given change id and change line id
        --    and iterlate the fetched row.
        --    Call insdividual API to grant the objects to assignees.
        --
        -- Note: IN R12B, anyway we support only DOM_DOCUMENT_REVISION and OCS File
        --
        FOR c_chg_objects_rec  IN c_chg_objects (  c_change_id => l_change_id
                                                ,  c_change_line_id => l_change_line_id
                                                )
        LOOP
            IF ( G_DOM_DOCUMENT_REVISION = c_chg_objects_rec.CHANGE_OBJECT_NAME
                 AND l_document_role_id IS NOT NULL
                 AND (l_doc_rev_person_id_tbl IS NOT NULL AND l_doc_rev_person_id_tbl.count > 0)
               )
            THEN

                -- MK Comment Need to verify this PK1 is Revision Id or not
                l_document_id          := TO_NUMBER(c_chg_objects_rec.PK1_VALUE) ;
                l_document_revision_id := TO_NUMBER(c_chg_objects_rec.PK2_VALUE) ;

IF g_debug_flag THEN
    Write_Debug('Calling ENG_DOCUMENT_UTIL.Revoke_Document_Role . . .  ');
END IF ;

                ENG_DOCUMENT_UTIL.Revoke_Document_Role
                (   p_api_version               => 1.0
                 ,  p_init_msg_list             => FND_API.G_FALSE        --
                 ,  p_commit                    => FND_API.G_FALSE        --
                 ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
                 ,  p_debug                     => p_debug
                 ,  p_output_dir                => p_output_dir
                 ,  p_debug_filename            => p_debug_filename
                 ,  x_return_status             => l_return_status
                 ,  x_msg_count                 => l_msg_count
                 ,  x_msg_data                  => l_msg_data
                 ,  p_document_id               => l_document_id               -- Dom Document Id
                 ,  p_document_revision_id      => l_document_revision_id      -- Dom Document Revision Id
                 ,  p_change_id                 => l_change_id                 -- Change Id
                 ,  p_change_line_id            => l_change_line_id            -- Change Line Id
                 ,  p_party_ids                 => l_doc_rev_person_id_tbl     -- Person's HZ_PARTIES.PARTY_ID Array
                 ,  p_role_id                   => l_document_role_id          -- Role Id to be granted
                 ,  p_api_caller                => p_api_caller                -- Optionnal for future use
                ) ;



IF g_debug_flag THEN
    Write_Debug('After ENG_DOCUMENT_UTIL.Revoke_Document_Role: ' || l_return_status );
END IF ;

                 --
                 -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                 -- THEN
                 --     RAISE FND_API.G_EXC_ERROR ;
                 -- END IF ;
                 --

            END IF ;
        END LOOP ;


    END IF ; -- (l_doc_rev_revoke_flag IS TRUE)

    --
    -- 5. Call ENG_DOCUMENT_UTIL.Grant_Attachments_OCSRole
    --    to grant roles on Attachments
    --
    IF ( l_ocs_revoke_flag
         AND  l_ocs_role IS NOT NULL
         AND (l_ocs_person_id_tbl IS NOT NULL AND l_ocs_person_id_tbl.count > 0)
       )
    THEN

IF g_debug_flag THEN
    Write_Debug('Calling ENG_DOCUMENT_UTIL.Revoke_Attachments_OCSRole . . .  ');
END IF ;

        ENG_DOCUMENT_UTIL.Revoke_Attachments_OCSRole
        (   p_api_version               => 1.0
         ,  p_init_msg_list             => FND_API.G_FALSE        --
         ,  p_commit                    => FND_API.G_FALSE        --
         ,  p_validation_level          => FND_API.G_VALID_LEVEL_FULL
         ,  p_debug                     => p_debug
         ,  p_output_dir                => p_output_dir
         ,  p_debug_filename            => p_debug_filename
         ,  x_return_status             => l_return_status
         ,  x_msg_count                 => l_msg_count
         ,  x_msg_data                  => l_msg_data
         ,  p_entity_name               => l_attachment_entity_name    -- ENG_ENGINEERING_CHANGES or ENG_CHANGE_LINES
         ,  p_pk1value                  => l_attachment_pk1value       -- CHANGE_ID or CHANGE_LINE_ID
         ,  p_pk2value                  => NULL
         ,  p_pk3value                  => NULL
         ,  p_pk4value                  => NULL
         ,  p_pk5value                  => NULL
         ,  p_party_ids                 => l_ocs_person_id_tbl         -- Person's HZ_PARTIES.PARTY_ID Array
         ,  p_ocs_role                  => l_ocs_role                  -- OCS Role to be revoked
         ,  p_api_caller                => p_api_caller                -- Optionnal for future use
        ) ;


IF g_debug_flag THEN
    Write_Debug('After ENG_DOCUMENT_UTIL.Revoke_Attachments_OCSRole: ' || l_return_status );
END IF ;

       --
       -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       -- THEN
       --     RAISE FND_API.G_EXC_ERROR ;
       -- END IF ;
       --


    END IF ;


    -----------------------------------------------------------------
    -- END OF API body
    -----------------------------------------------------------------


IF g_debug_flag THEN
   Write_Debug('After executing RevokeObjectRoles API Body') ;
END IF ;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN

IF g_debug_flag THEN
   Write_Debug('Do Commit.') ;
END IF ;

      COMMIT WORK;

   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count  => x_msg_count
      ,  p_data   => x_msg_data
      );

IF g_debug_flag THEN
   Write_Debug('Finish. Eng Of Proc') ;
   Close_Debug_Session ;
END IF ;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit )
       THEN
         ROLLBACK TO RevokeObjectRoles ;
       END IF ;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with Error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit )
       THEN
         ROLLBACK TO RevokeObjectRoles ;
IF g_debug_flag THEN
   Write_Debug('RollBack . .  ..') ;
END IF ;
       END IF ;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with unxepcted error.') ;
   Close_Debug_Session ;
END IF ;

   WHEN OTHERS THEN
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit )
       THEN
         ROLLBACK TO RevokeObjectRoles ;
IF g_debug_flag THEN
   Write_Debug('RollBack . .  ..') ;
END IF ;
       END IF ;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME
              , l_api_name
              );
       END IF;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF g_debug_flag THEN
   Write_Debug('Finish with system unxepcted error: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
END IF ;


END RevokeObjectRoles ;


END Eng_Workflow_Util ;

/
