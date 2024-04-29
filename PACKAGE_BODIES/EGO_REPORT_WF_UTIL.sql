--------------------------------------------------------
--  DDL for Package Body EGO_REPORT_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_REPORT_WF_UTIL" AS
/* $Header: EGORWKFB.pls 120.3 2006/03/03 05:51:27 sdarbha noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'EGO_REPORT_WF_UTIL' ;

    -- For Debug
    g_debug_file      UTL_FILE.FILE_TYPE ;
    g_debug_flag      BOOLEAN      := FALSE ;  -- For Debug, set TRUE
    g_output_dir      VARCHAR2(80) := NULL ;
    g_debug_filename  VARCHAR2(30) := 'EgoReportWorkflow.log' ;
    g_debug_errmesg   VARCHAR2(240);
    g_report_url      VARCHAR2(2000);
    g_message         VARCHAR2(2000);


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
     l_found NUMBER := 0;
     l_utl_file_dir    VARCHAR2(2000);

BEGIN

     IF p_output_dir IS NOT NULL THEN
        g_output_dir := p_output_dir ;

     END IF ;

     IF p_file_name IS NOT NULL THEN
        g_debug_filename := p_file_name ;
     END IF ;

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
          RETURN;
     END IF;

     g_debug_file := utl_file.fopen(  g_output_dir
                                    , g_debug_filename
                                    , 'w');
     g_debug_flag := TRUE ;

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;

END Open_Debug_Session ;

-- Close Debug_Session
PROCEDURE Close_Debug_Session
IS
BEGIN
    IF utl_file.is_open(g_debug_file)
    THEN
      utl_file.fclose(g_debug_file);
    END IF ;

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;

END Close_Debug_Session ;

-- Test Debug
PROCEDURE Write_Debug
(  p_debug_message      IN  VARCHAR2 )
IS
BEGIN

    IF utl_file.is_open(g_debug_file)
    THEN
        utl_file.put_line(g_debug_file, p_debug_message);
    END IF ;

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
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


END Get_Debug_Mode ;



FUNCTION GetUserName
( p_user_id      IN   NUMBER)
 RETURN VARCHAR2
IS

    l_user_name  varchar2(100) ;

BEGIN

    SELECT user_name
    INTO   l_user_name
    FROM   FND_USER
    WHERE  user_id = p_user_id ;

    RETURN l_user_name ;

END  GetUserName ;

FUNCTION GetUserRole
( p_user_id      IN   NUMBER)
 RETURN VARCHAR2
IS

    l_user_name  varchar2(100) ;

BEGIN

    SELECT user_name
    INTO   l_user_name
    FROM   FND_USER
    WHERE  user_id = p_user_id ;

    RETURN l_user_name ;

END  GetUserRole ;


FUNCTION GetNewItemKey
RETURN VARCHAR2
IS
    l_rev_seq      NUMBER         := NULL;
    l_new_item_key VARCHAR2(240)  := NULL;
BEGIN

    -- Generate Item Key from ego_wf_rpt_s.NEXTVAL
    -- and return the value
    SELECT ego_wf_rpt_s.NEXTVAL
    INTO   l_rev_seq
    FROM DUAL;

    l_new_item_key := TO_CHAR(l_rev_seq) ;

    RETURN l_new_item_key ;

END GetNewItemKey ;


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

    l_existence BOOLEAN  := FALSE ;

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

BEGIN

    begin


       --
       -- if p_role does not exist, it throws exception
       -- So we should not write sql to check AdhocRole existence directly
       -- For safety purpose we just don't care about this execption
       --
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



----------------------------------------------------------
-- WF Directory related OBSOLETE API for Bug4532263
-- Replaced with new APIs with post_fix 2
-- Keep APIs here for any customization
----------------------------------------------------------

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

-- Set User to Role Users
PROCEDURE SetGroupToRoleUsers
(  p_group_id    IN NUMBER
 , x_role_users  IN OUT NOCOPY  VARCHAR2
)
IS


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


END SetWFAdhocRole ;
----------------------------------------------------------
-- End of WF Directory related Obsolete API for Bug4532263
----------------------------------------------------------


-------------------------------------------------------------------
-- New WF Directory related APIs for Bug4532263
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

    -- First, check the user role is Active
    IF (WF_DIRECTORY.UserActive(p_role_name))
    THEN

        l_dup_flag := FALSE ;
        l_new_index := 0 ;

        -- Second, check the user role is duplicate
        IF (x_role_users IS NOT NULL AND x_role_users.COUNT > 0)
        THEN
            l_index := x_role_users.FIRST;
            l_new_index := x_role_users.LAST + 1;

            WHILE (l_index IS NOT NULL AND NOT l_dup_flag )
            LOOP
                IF p_role_name = x_role_users(l_index)
                THEN
                    l_dup_flag := TRUE ;
                END IF ;
                l_index := x_role_users.NEXT(l_index);
            END LOOP ;

        END IF ;


        IF NOT l_dup_flag
        THEN
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
-- End of New WF Directory related APIs for Bug4532263
-------------------------------------------------------------------


-- Get Organization Info
PROCEDURE GetOrgInfo
(  p_organization_id   IN  NUMBER
 , x_organization_code OUT NOCOPY VARCHAR2
 , x_organization_name OUT NOCOPY VARCHAR2
)
IS

BEGIN

   -- in 115.10 org id may be -1
   IF  p_organization_id IS NOT NULL AND p_organization_id > 0
   THEN

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



/********************************************************************
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/

--  API name   : GetMessageTextBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf text message body
--  Parameters : p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
--
PROCEDURE GetMessageTextBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
)
IS

    l_index1                    NUMBER;
    l_index2                    NUMBER;

    l_doc                       VARCHAR2(32000) ;

    NL VARCHAR2(1) := FND_GLOBAL.NEWLINE;

BEGIN

   -- Call GetMessageHTMLBody if display type is text/plain
    IF (display_type = WF_NOTIFICATION.DOC_HTML ) THEN

       GetMessageHTMLBody
       (  document_id    => document_id
        , display_type   => display_type
        , document       => document
        , document_type  => document_type
       ) ;

       RETURN ;

    END IF;

  l_doc :=  g_message ||  g_report_url ;
  WF_NOTIFICATION.WriteToClob( document , l_doc);


END GetMessageTextBody ;


--  API name   : GetMessageHTMLBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf HTML message body
--  Parameters : p_document_id  IN  VARCHAR2     Required
--                              Format:
--                              <wf item type>:<wf item key>:<&#NID>
--
PROCEDURE GetMessageHTMLBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
)
IS

l_doc                  VARCHAR2(32000) ;
l_index1                    NUMBER;
l_index2                    NUMBER;
l_host_url             VARCHAR2(5000);
NL                     VARCHAR2(1) := FND_GLOBAL.NEWLINE;
p_url                 VARCHAR2(5000);
p_message               VARCHAR2(5000);

BEGIN

    l_index1   := instr(document_id, ':');
    l_index2   := instr(document_id, ':', 1, 2);

    p_url := substr(document_id, 1, l_index1 - 1);
    p_message := substr(document_id, l_index1 + 1, l_index2 - l_index1 -1);


    l_host_url := rtrim(FND_PROFILE.VALUE('APPS_FRAMEWORK_AGENT'), '/') || '/OA_HTML/';
    l_doc := '<base href= "' || l_host_url || '"> ';
    l_doc := l_doc  || '<br><br>' || p_message || '<br><br>' || '<a href=' || p_url || '>Report</a>';

    l_doc := l_doc || '<!-- Base Href URL -->' || NL;

    WF_NOTIFICATION.WriteToClob( document , l_doc);

END GetMessageHTMLBody;



-- Get Ntf Message PL/SQL Document API Info
PROCEDURE GetNtfMessageDocumentAPI
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_report_url        IN  VARCHAR2
 ,  p_message           IN  VARCHAR2
 ,  x_message_text_body OUT NOCOPY VARCHAR2
 ,  x_message_html_body OUT NOCOPY VARCHAR2
)
IS

BEGIN

    -- Message Text Body Document API
    x_message_text_body := 'PLSQLCLOB:EGO_REPORT_WF_UTIL.GetMessageTextBody/'
                         || p_item_type ||':'||p_item_key ||':&#NID' ;

    -- Message HTML Body Document API
    x_message_html_body := 'PLSQLCLOB:EGO_REPORT_WF_UTIL.GetMessageHTMLBody/'
                         || p_report_url ||':'||p_message ||':&#NID' ;


END GetNtfMessageDocumentAPI ;


/********************************************************************
* API Type      : Private APIs
* Purpose       : Internal Use Only
*********************************************************************/


PROCEDURE SetAttributes
(   x_return_status      OUT NOCOPY VARCHAR2
 ,  x_msg_count          OUT NOCOPY NUMBER
 ,  x_msg_data           OUT NOCOPY VARCHAR2
 ,  p_item_type          IN  VARCHAR2
 ,  p_item_key           IN  VARCHAR2
 ,  p_process_name       IN  VARCHAR2
 ,  p_report_url         IN  VARCHAR2
 ,  p_subject            IN  VARCHAR2
 ,  p_message            IN  VARCHAR2
 ,  p_wf_user_id         IN  NUMBER
 ,  p_wf_user_name       IN  VARCHAR2  := NULL
 ,  p_adhoc_party_list   IN  VARCHAR2  := NULL
 ,  p_report_fwk_region  IN  VARCHAR2  := NULL
 ,  p_report_custom_code IN  VARCHAR2  := NULL
 ,  p_browse_mode        IN  VARCHAR2  := NULL
 ,  p_report_org_id      IN  NUMBER    := NULL
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

    l_wf_user_name              VARCHAR2(320) ;
    l_message_text_body         VARCHAR2(4000) ;
    l_message_html_body         VARCHAR2(4000) ;
    l_default_novalue           VARCHAR2(2000) ;
    l_host_url                  VARCHAR2(256);
    l_base_href                 VARCHAR2(256);

    l_report_recepients         varchar2(2000);

    l_organization_code         VARCHAR2(3) ;
    l_organization_name         VARCHAR2(60) ;
    l_organization_context      VARCHAR2(2000) ;

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF g_debug_flag THEN
   Write_Debug('SetAttribute Private API . . .');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type   : ' || p_item_type );
   Write_Debug('Report URL  : ' || p_report_url );
   Write_Debug('-----------------------------------------------------');

END IF ;


IF g_debug_flag THEN
   Write_Debug('Got User Info . . .');
END IF ;

    -- Get User Info
    IF p_wf_user_name IS NULL THEN

        l_wf_user_name := GetUserName(p_user_id => p_wf_user_id ) ;

    ELSE

        l_wf_user_name := p_wf_user_name ;

    END IF ;

    IF p_report_org_id IS NOT NULL THEN

IF g_debug_flag THEN
   Write_Debug('Get Org Info: ' || TO_CHAR(p_report_org_id));
END IF ;


       -- Get Organization Info
       GetOrgInfo
       ( p_organization_id   => p_report_org_id
       , x_organization_code => l_organization_code
       , x_organization_name => l_organization_name
       ) ;


    END IF ;

IF g_debug_flag THEN
   Write_Debug('Got Workflow Item Attribute Info . . .');
END IF ;

    -- Set the values of an array of item type attributes
    -- Use the correct procedure for your attribute type. All attribute types
    -- except number and date use SetItemAttrTextArray.

    -- Text Item Attributes
    -- Using SetItemAttrTextArray():
    I := 0 ;

    -- Ntf Default From Role
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'FROM_ROLE' ;
    l_text_attr_value_tbl(I) := l_wf_user_name ;


    -- Subject
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'SUBJECT' ;
    l_text_attr_value_tbl(I) := p_subject ;


    -- Message
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'REPORT_MESSAGE' ;
    l_text_attr_value_tbl(I) := p_message ;

    -- Report URL
    l_host_url := rtrim(FND_PROFILE.VALUE('APPS_FRAMEWORK_AGENT'), '/') || '/OA_HTML/';

    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'REPORT_URL' ;
    l_text_attr_value_tbl(I) := l_host_url ||  p_report_url ;



    -- Report Framework Region
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'REPORT_FWK_RN' ;
    l_text_attr_value_tbl(I) := p_report_fwk_region || '&ntfId=-&#NID-' ;



    -- Report Custom Code
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'REPORT_CUSTOM_CODE' ;
    l_text_attr_value_tbl(I) := p_report_custom_code ;

    -- Report  Browse Mode
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'BROWSE_MODE' ;
    l_text_attr_value_tbl(I) := p_browse_mode ;


    -- Organization Code
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ORGANIZATION_CODE' ;
    l_text_attr_value_tbl(I) := l_organization_code ;

    IF l_organization_code IS NOT NULL AND l_organization_name IS NOT NULL
    THEN

        FND_MESSAGE.SET_NAME('ENG', 'ENG_ORG_NAME_AND_CODE') ;
        FND_MESSAGE.SET_TOKEN('ORG_NAME', l_organization_name) ;
        FND_MESSAGE.SET_TOKEN('ORG_CODE', l_organization_code) ;
        l_organization_context :=  FND_MESSAGE.GET ;

    END IF ;

    -- Organization Context
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ORGANIZATION_CONTEXT' ;
    l_text_attr_value_tbl(I) := l_organization_context ;

    g_report_url := p_report_url;
    g_message    := p_message;

/*
     Code that is causing the P1 bug

    -- Set the Message text and HTML body
    l_host_url := rtrim(FND_PROFILE.VALUE('APPS_FRAMEWORK_AGENT'), '/') || '/OA_HTML/';
    l_base_href := '<base href= "' || l_host_url || '"> ';
    l_message_text_body := p_message || p_report_url;
    l_message_html_body := l_base_href  || '<br><br>' || p_message || '<br><br>' || '<a href=' || p_report_url || '>Report</a>';

*/

    -- Get Ntf Message PL/SQL Document API Info
    GetNtfMessageDocumentAPI
    ( p_item_type         => p_item_type
    , p_item_key          => p_item_key
    , p_process_name      => p_process_name
    , p_report_url        => p_report_url
    , p_message           => p_message
    , x_message_text_body => l_message_text_body
    , x_message_html_body => l_message_html_body
    ) ;


    -- Message Text Body
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'MESSAGE_TEXT_BODY' ;
    l_text_attr_value_tbl(I) := l_message_text_body ;

    -- Message HTML Body
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'MESSAGE_HTML_BODY' ;
    l_text_attr_value_tbl(I) := l_message_html_body ;

       -- Adhoc Party List
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ADHOC_PARTY_LIST' ;
    l_text_attr_value_tbl(I) := p_adhoc_party_list ;

      -- Adhoc Party Role
    I := I + 1  ;
    l_text_attr_name_tbl(I)  := 'ADHOC_PARTY_ROLE' ;
    l_text_attr_value_tbl(I) := GetWFAdhocRoleName
                                    ( p_role_prefix => EGO_REPORT_WF_UTIL.G_ADHOC_PARTY_ROLE
                                    , p_item_type   => p_item_type
                                    , p_item_key    => p_item_key ) ;





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

    -- Organization Id
    I := I + 1  ;
    l_num_attr_name_tbl(I)  := 'ORGANIZATION_ID' ;
    l_num_attr_value_tbl(I) := p_report_org_id ;

    -- Set Number Attributes
    WF_ENGINE.SetItemAttrNumberArray
    ( itemtype     => p_item_type
    , itemkey      => p_item_key
    , aname        => l_num_attr_name_tbl
    , avalue       => l_num_attr_value_tbl
    ) ;


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

   x_return_status := '';
   x_msg_count := '';
   x_msg_data := '';

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
        x_return_status := EGO_REPORT_WF_UTIL.G_RET_STS_NONE;

    END IF;

  return;
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


    I := I + 1 ;
    l_role_names(I) := GetWFAdhocRoleName
                       ( p_role_prefix => EGO_REPORT_WF_UTIL.G_ADHOC_PARTY_ROLE
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


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


--  API name   : StartWorkflow
--  Type       : Public
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
 ,  p_report_url         IN  VARCHAR2    := NULL
 ,  p_subject            IN  VARCHAR2    := NULL
 ,  p_message            IN  VARCHAR2    := NULL
 ,  p_wf_user_id         IN  NUMBER
 ,  p_adhoc_party_list   IN  VARCHAR2    := NULL
 ,  p_report_fwk_region  IN  VARCHAR2    := NULL
 ,  p_report_custom_code IN  VARCHAR2    := NULL
 ,  p_browse_mode        IN  VARCHAR2    := NULL  -- EGO_SUMMARY or EGO_SEQUENTIAL
 ,  p_report_org_id      IN  NUMBER      := NULL
 ,  p_debug              IN  VARCHAR2    := FND_API.G_FALSE
 ,  p_output_dir         IN  VARCHAR2    := NULL
 ,  p_debug_filename     IN  VARCHAR2    := 'EgoReportStartWf.log'
)
IS

   l_api_name         CONSTANT VARCHAR2(30) := 'StartWorkflow';
   l_api_version      CONSTANT NUMBER      := 1.0;

   l_wf_user_name     VARCHAR2(320) ;
   l_wf_user_key      VARCHAR2(240) ;


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
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;

IF g_debug_flag THEN
   Write_Debug('Ego_SendReport.SendReport Log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Item Type         : ' || p_item_type );
   Write_Debug('Item Key          : ' || x_item_key );
   Write_Debug('Process Name      : ' || p_process_name);
   Write_Debug('Report URL: ' || p_report_url );
   Write_Debug('Subject: ' || p_subject );
   Write_Debug('Message: ' || p_message );
   Write_Debug('WF User Id        : ' || to_char(p_wf_user_id));
   Write_Debug('Adhoc Party List  : ' || p_adhoc_party_list);
   Write_Debug('Report Fwk Region : ' || p_report_fwk_region);
   Write_Debug('Report Custom Code : ' || p_report_custom_code);
   Write_Debug('Browse Mode       : ' || p_browse_mode);
   Write_Debug('Report Org Id     : ' || to_char(p_report_org_id));
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Initialize return status ' );
END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------

    -- 2. CreateProcess:
    -- 2-1. SetItemUserKey:
    -- 2-2. SetItemOwner:
    -- 3. SetItemAttribute:
    -- 4. SetItemParent:
    -- 4-1. Additional Set
    -- 5. Execute Custom Hook:
    -- 6. StartProcess:

   -- Call Validate WFProcess
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

    -- Comment out
    -- 115.9 WF User Key
    -- l_wf_user_key :=  substr(p_report_url, 1, 100) || x_item_key;

    IF p_report_custom_code IS NOT NULL
    THEN
        l_wf_user_key :=  p_report_custom_code || '-' || x_item_key ;

    ELSE
        l_wf_user_key := x_item_key ;
    END IF ;




IF g_debug_flag THEN
   Write_Debug('2-1. Set ItemUserKey. . .' || l_wf_user_key );
END IF ;



    -- Get User Info
    l_wf_user_name := GetUserName(p_user_id => p_wf_user_id ) ;


IF g_debug_flag THEN
   Write_Debug('2-2. Set ItemOwner. . .' || l_wf_user_name );
END IF ;


    -- Set Workflow Process Owner
    WF_ENGINE.CreateProcess
    ( itemtype     => p_item_type
    , itemkey      => x_item_key
    , process      => p_process_name
    , user_key     => l_wf_user_key
    , owner_role   => l_wf_user_name ) ;


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
    ,  p_report_url        => p_report_url
    ,  p_subject           => p_subject
    ,  p_message           => p_message
    ,  p_wf_user_id        => p_wf_user_id
    ,  p_wf_user_name      => l_wf_user_name
    ,  p_adhoc_party_list  => p_adhoc_party_list
    ,  p_report_fwk_region => p_report_fwk_region
    ,  p_report_custom_code => p_report_custom_code
    ,  p_browse_mode        => p_browse_mode
    ,  p_report_org_id      => p_report_org_id
    ) ;


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
       ROLLBACK TO StartWorkflow_Util ;
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
       ROLLBACK TO StartWorkflow_Util ;
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
       ROLLBACK TO StartWorkflow_Util ;
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

-- PROCEDURE SELECT_ADHOC_PARTY
PROCEDURE SELECT_ADHOC_PARTY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_action_id           NUMBER ;
    l_adhoc_party_list    VARCHAR2(2000) ;

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);
    l_err_num NUMBER;
    l_err_msg varchar2(100);

BEGIN

 l_return_status := '';
 l_msg_data := '';
 l_adhoc_party_list := '';


  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Adhoc Party List
    l_adhoc_party_list := WF_ENGINE.GetItemAttrText( itemtype
                                                   , itemkey
                                                   , 'ADHOC_PARTY_LIST');

    IF l_adhoc_party_list IS NULL THEN
          result  := 'COMPLETE:NONE';
          return;
    END IF ;


    -- Set Adhoc Party Role
    SetAdhocPartyRole
    (
         x_return_status     => l_return_status
      ,  x_msg_count         => l_msg_count
      ,  x_msg_data          => l_msg_data
      ,  p_item_type         => itemtype
      ,  p_item_key          => itemkey
      ,  p_adhoc_party_list  => l_adhoc_party_list
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = EGO_REPORT_WF_UTIL.G_RET_STS_NONE THEN
        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE
        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;
  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('EGO_REPORT_WF_UTIL', 'SELECT_ADHOC_PARTY',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('EGO_REPORT_WF_UTIL', 'SELECT_ADHOC_PARTY',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_ADHOC_PARTY ;

PROCEDURE DELETE_ADHOC_ROLES_AND_USERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

-- ut Wf_Directory.UserTable;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Delete Workflow Adhoc Role and Local Users
    DeleteAdhocRolesAndUsers
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ) ;

    -- wf_directory.getroleusers( 'EGO_ADHOC,'||itemtype || '-' ||itemkey,ut);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('EGO_REPORT_WF_UTIL', 'DELETE_ADHOC_ROLES_AND_USERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('EGO_REPORT_WF_UTIL', 'DELETE_ADHOC_ROLES_AND_USERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END DELETE_ADHOC_ROLES_AND_USERS ;

END EGO_REPORT_WF_UTIL ;

/
