--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ROUTE_PEOPLE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ROUTE_PEOPLE_UTIL" AS
/* $Header: ENGURTPB.pls 120.1 2006/01/12 19:23:03 mkimizuk noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'Eng_Change_Route_People_Util' ;

    -- For Debug
    g_debug_file      UTL_FILE.FILE_TYPE ;
    g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    g_output_dir      VARCHAR2(80) ;
    g_debug_filename  VARCHAR2(35) ;
    g_debug_errmesg   VARCHAR2(240);

    -- Global Assignee Rec
    g_orig_assignee_rec Eng_Change_Route_People_Util.Assignee_Rec_Type ;
    g_assignee_rec      Eng_Change_Route_People_Util.Assignee_Rec_Type ;



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

     -- Set Default Debug Name
     IF g_debug_filename IS NULL THEN
         g_debug_filename := 'Eng_Change_Route_People_Util.log' ;
     END IF ;

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



/********************************************************************
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/

-- Get assignee rec from cache rec or database rec
PROCEDURE GetAssigneeRec
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL -- Y or NULL regarded as Current
, x_assignee_rec       OUT NOCOPY Eng_Change_Route_People_Util.Assignee_Rec_Type
)
IS

    l_idx     BINARY_INTEGER ;
    l_found   BOOLEAN  := FALSE ;

    CURSOR assignee_type_cur(p_assignee_type VARCHAR2)
    IS
      SELECT AssigneeTypeLookup.MEANING ASSIGNEE_TYPE
      FROM  FND_LOOKUPS AssigneeTypeLookup
      WHERE AssigneeTypeLookup.LOOKUP_CODE = p_assignee_type
      AND   AssigneeTypeLookup.LOOKUP_TYPE = 'ENG_ROUTE_ASSIGNEE_TYPES' ;

    CURSOR role_assignee_cur(p_role_id NUMBER)
    IS
      SELECT MenuTL.USER_MENU_NAME      ASSIGNEE_NAME
      FROM  FND_MENUS_TL MenuTL
      WHERE MenuTL.LANGUAGE = USERENV('LANG')
      AND   MenuTL.MENU_ID = p_role_id ;


    CURSOR role_assignee_lkup_cur
    IS
      SELECT AssigneeTypeLookup.MEANING ASSIGNEE_TYPE
           , ''                         ASSIGNEE_COMPANY
      FROM  FND_LOOKUPS AssigneeTypeLookup
      WHERE AssigneeTypeLookup.LOOKUP_CODE = 'ROLE'
      AND   AssigneeTypeLookup.LOOKUP_TYPE = 'ENG_ROUTE_ASSIGNEE_TYPES' ;



    -- Decided to put prefix 'Change'for Change Object role also
    CURSOR role_object_name(p_role_id NUMBER)
    IS
       SELECT Obj.DISPLAY_NAME OBJECT_NAME
       FROM   ( select distinct f.object_id, e.menu_id
                from fnd_form_functions f, fnd_menu_entries e
                where e.function_id = f.function_id) EgoRoles,
              FND_OBJECTS_VL Obj
       WHERE  Obj.OBJECT_ID = EgoRoles.OBJECT_ID
       -- AND    Obj.OBJ_NAME <> 'ENG_CHANGE'
       AND    EgoRoles.MENU_ID = p_role_id ;


    CURSOR person_assignee_cur (p_person_id NUMBER)
    IS
      SELECT Parties.PARTY_NAME         ASSIGNEE_NAME
           , AssigneeTypeLookup.MEANING ASSIGNEE_TYPE
           , Company.PARTY_NAME         ASSIGNEE_COMPANY
      FROM FND_LOOKUPS AssigneeTypeLookup
         , HZ_RELATIONSHIPS Emp_Cmpy
         , HZ_PARTIES Company
         , HZ_PARTIES Parties
      WHERE  AssigneeTypeLookup.LOOKUP_CODE = 'PERSON'
      AND AssigneeTypeLookup.LOOKUP_TYPE = 'ENG_ROUTE_ASSIGNEE_TYPES'
      AND Emp_Cmpy.SUBJECT_TYPE (+)= 'PERSON'
      AND Emp_Cmpy.SUBJECT_TABLE_NAME (+)= 'HZ_PARTIES'
      AND Emp_Cmpy.OBJECT_TYPE (+)= 'ORGANIZATION'
      AND Emp_Cmpy.RELATIONSHIP_CODE (+)= 'EMPLOYEE_OF'
      AND Emp_Cmpy.OBJECT_TABLE_NAME (+)= 'HZ_PARTIES'
      AND Emp_Cmpy.STATUS (+)= 'A'
      AND Emp_Cmpy.START_DATE (+)<= SYSDATE
      AND (Emp_Cmpy.END_DATE IS NULL OR Emp_Cmpy.END_DATE >= SYSDATE)
      AND Company.PARTY_ID (+)= Emp_Cmpy.OBJECT_ID
      AND Company.STATUS (+)= 'A'
      AND Emp_Cmpy.SUBJECT_ID (+)= Parties.PARTY_ID
      AND Parties.PARTY_TYPE = 'PERSON'
      AND Parties.PARTY_ID = p_person_id ;

    CURSOR group_assignee_cur (p_group_id NUMBER)
    IS
       SELECT Grp.PARTY_NAME             ASSIGNEE_NAME
            , AssigneeTypeLookup.MEANING ASSIGNEE_TYPE
            , ''                         ASSIGNEE_COMPANY
       FROM FND_LOOKUPS AssigneeTypeLookup
          , HZ_PARTIES Grp
       WHERE AssigneeTypeLookup.LOOKUP_CODE = 'GROUP'
       AND AssigneeTypeLookup.LOOKUP_TYPE = 'ENG_ROUTE_ASSIGNEE_TYPES'
       AND Grp.PARTY_TYPE = 'GROUP'
       AND Grp.PARTY_ID = p_group_id ;


    CURSOR chg_policy_assignee_cur (p_chg_policy_assignee_id VARCHAR2)
    IS
       SELECT ChgPolicyAssigneeLookup.MEANING   ASSIGNEE_NAME
            , AssigneeTypeLookup.MEANING        ASSIGNEE_TYPE
            , ''                                ASSIGNEE_COMPANY
       FROM    FND_LOOKUPS ChgPolicyAssigneeLookup
             , FND_LOOKUPS AssigneeTypeLookup
       WHERE AssigneeTypeLookup.LOOKUP_CODE = 'CHANGE_POLICY'
       AND   AssigneeTypeLookup.LOOKUP_TYPE = 'ENG_ROUTE_ASSIGNEE_TYPES'
       AND   ChgPolicyAssigneeLookup.LOOKUP_TYPE = 'ENG_ROUTE_CHG_POLICY_ASSIGNEES'
       AND   ChgPolicyAssigneeLookup.LOOKUP_CODE =  p_chg_policy_assignee_id ;

BEGIN

    -- 1. Check Current Cache Record
    IF p_current_flag IS NULL OR p_current_flag = 'Y' THEN

        IF  g_assignee_rec.assignee_id = p_assignee_id
        AND g_assignee_rec.assignee_type_code = p_assignee_type_code
        THEN
            x_assignee_rec := g_assignee_rec ;
            RETURN ;
        END IF ;

    ELSE

        IF  g_orig_assignee_rec.assignee_id = p_assignee_id
        AND g_orig_assignee_rec.assignee_type_code = p_assignee_type_code
        THEN
            x_assignee_rec := g_orig_assignee_rec;
            RETURN ;
        END IF ;

    END IF ;

    -- 2. Check Cache Table
    l_idx := NVL(G_ASSIGNEE_TBL.COUNT, 0 ) ;

    -- Cache exists in table
    IF l_idx <> 0 THEN

        FOR i IN 1..G_ASSIGNEE_TBL.COUNT
        LOOP

            IF  G_ASSIGNEE_TBL(i).assignee_id = p_assignee_id
            AND G_ASSIGNEE_TBL(i).assignee_type_code = p_assignee_type_code
            THEN

                 x_assignee_rec := G_ASSIGNEE_TBL(i) ;
                 l_found := TRUE ;

            END IF ;

        END LOOP;

    END IF ;

    -- 3. Query from Database
    IF NOT l_found OR l_idx = 0
    THEN

        l_idx := l_idx + 1 ;

        IF p_assignee_type_code = 'ROLE'
        THEN

            FOR l_role_rec IN role_assignee_cur (p_assignee_id)
            LOOP
                x_assignee_rec.assignee_id            :=  p_assignee_id ;
                x_assignee_rec.assignee_type_code     :=  p_assignee_type_code ;
                x_assignee_rec.assignee_name          :=  l_role_rec.assignee_name ;
                x_assignee_rec.assignee_role_obj_name :=  NULL ;
            END LOOP ;


            FOR l_role_rec IN role_assignee_lkup_cur
            LOOP
                x_assignee_rec.assignee_type          :=  l_role_rec.assignee_type ;
                x_assignee_rec.assignee_company       :=  l_role_rec.assignee_company ;
            END LOOP ;


            IF x_assignee_rec.assignee_type IS NOT NULL
            THEN
                -- May need to use FND_MESSAGE for Object Role Name
                FOR l_obj_rec IN role_object_name (p_assignee_id)
                LOOP

                    FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_OBJECT_ROLE') ;
                    FND_MESSAGE.SET_TOKEN('OBJECT_NAME', l_obj_rec.object_name);
                    FND_MESSAGE.SET_TOKEN('ROLE', x_assignee_rec.assignee_type);
                    x_assignee_rec.assignee_role_obj_name := FND_MESSAGE.GET ;

                END LOOP ;
            END IF ;


        ELSIF p_assignee_type_code = 'PERSON'
        THEN

            IF p_assignee_id = -1 THEN

                -- FND_MESSAGE.SET_NAME('ENG','ENG_ROUTE_NO_ASSIGNEE');
                x_assignee_rec.assignee_id            :=  p_assignee_id ;
                x_assignee_rec.assignee_type_code     :=  p_assignee_type_code ;
                x_assignee_rec.assignee_name          :=  NULL ;
                -- x_assignee_rec.assignee_name          :=  FND_MESSAGE.GET ;
                x_assignee_rec.assignee_company       :=  NULL ;
                x_assignee_rec.assignee_role_obj_name :=  NULL ;

                FOR l_type_rec IN assignee_type_cur (p_assignee_type_code)
                LOOP
                    x_assignee_rec.assignee_type      :=  l_type_rec.assignee_type ;
                END LOOP ;

            ELSE

                FOR l_per_rec IN person_assignee_cur (p_assignee_id)
                LOOP
                    x_assignee_rec.assignee_id            :=  p_assignee_id ;
                    x_assignee_rec.assignee_type_code     :=  p_assignee_type_code ;
                    x_assignee_rec.assignee_type          :=  l_per_rec.assignee_type ;
                    x_assignee_rec.assignee_name          :=  l_per_rec.assignee_name ;
                    x_assignee_rec.assignee_company       :=  l_per_rec.assignee_company ;
                    x_assignee_rec.assignee_role_obj_name :=  NULL ;
                END LOOP ;

            END IF ;

        ELSIF p_assignee_type_code = 'GROUP'
        THEN

            FOR l_grp_rec IN group_assignee_cur (p_assignee_id)
            LOOP
                x_assignee_rec.assignee_id := p_assignee_id ;
                x_assignee_rec.assignee_type_code     :=  p_assignee_type_code ;
                x_assignee_rec.assignee_type          :=  l_grp_rec.assignee_type ;
                x_assignee_rec.assignee_name          :=  l_grp_rec.assignee_name ;
                x_assignee_rec.assignee_company       :=  l_grp_rec.assignee_company ;
                x_assignee_rec.assignee_role_obj_name :=  NULL ;
            END LOOP ;

        ELSIF p_assignee_type_code = 'CHANGE_POLICY'
        THEN

            FOR l_policy_rec IN chg_policy_assignee_cur (TO_CHAR(p_assignee_id))
            LOOP
                x_assignee_rec.assignee_id            :=  p_assignee_id ;
                x_assignee_rec.assignee_type_code     :=  p_assignee_type_code ;
                x_assignee_rec.assignee_type          :=  l_policy_rec.assignee_type ;
                x_assignee_rec.assignee_name          :=  l_policy_rec.assignee_name ;
                x_assignee_rec.assignee_company       :=  l_policy_rec.assignee_company ;
                x_assignee_rec.assignee_role_obj_name :=  NULL ;
            END LOOP ;

        END IF ;


        G_ASSIGNEE_TBL(l_idx).assignee_id            :=  x_assignee_rec.assignee_id ;
        G_ASSIGNEE_TBL(l_idx).assignee_type_code     :=  x_assignee_rec.assignee_type_code ;
        G_ASSIGNEE_TBL(l_idx).assignee_type          :=  x_assignee_rec.assignee_type ;
        G_ASSIGNEE_TBL(l_idx).assignee_name          :=  x_assignee_rec.assignee_name ;
        G_ASSIGNEE_TBL(l_idx).assignee_company       :=  x_assignee_rec.assignee_company ;
        G_ASSIGNEE_TBL(l_idx).assignee_role_obj_name :=  x_assignee_rec.assignee_role_obj_name ;


    END IF ;

    -- 4. Set current rec
    IF p_current_flag IS NULL OR p_current_flag = 'Y' THEN
        g_assignee_rec := x_assignee_rec ;
    ELSE
        g_orig_assignee_rec := x_assignee_rec ;
    END IF ;

EXCEPTION
    WHEN OTHERS THEN
       NULL ;

END GetAssigneeRec ;


FUNCTION Get_Assignee_Name
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL  -- Y or NULL regarded as Current
)
RETURN VARCHAR2
IS

    l_assignee_rec Eng_Change_Route_People_Util.Assignee_Rec_Type ;

BEGIN

    IF p_assignee_id IS NOT NULL AND p_assignee_type_code IS NOT NULL
    THEN
        -- Get assignee rec from cache rec or database rec
        GetAssigneeRec(  p_assignee_id        => p_assignee_id
                       , p_assignee_type_code => p_assignee_type_code
                       , p_current_flag       => p_current_flag
                       , x_assignee_rec       => l_assignee_rec ) ;

        RETURN l_assignee_rec.assignee_name ;

    ELSE
        RETURN NULL ;

    END IF ;

EXCEPTION
    WHEN OTHERS THEN
         RETURN NULL ;

END Get_Assignee_Name ;


FUNCTION Get_Assignee_Company
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL -- Y or NULL regarded as Current
)
RETURN VARCHAR2
IS

    l_assignee_rec Eng_Change_Route_People_Util.Assignee_Rec_Type ;

BEGIN

    IF p_assignee_id IS NOT NULL AND p_assignee_type_code = 'PERSON'
    THEN
        -- Get assignee rec from cache rec or database rec
        GetAssigneeRec(  p_assignee_id        => p_assignee_id
                       , p_assignee_type_code => p_assignee_type_code
                       , p_current_flag       => p_current_flag
                       , x_assignee_rec       => l_assignee_rec ) ;

        RETURN l_assignee_rec.assignee_company ;

    ELSE
        RETURN NULL ;

    END IF ;

EXCEPTION
    WHEN OTHERS THEN
         RETURN NULL ;

END Get_Assignee_Company ;


FUNCTION Get_Assignee_Type
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL -- Y or NULL regarded as Current
)
RETURN VARCHAR2
IS

    l_assignee_rec Eng_Change_Route_People_Util.Assignee_Rec_Type ;

BEGIN

    IF p_assignee_id IS NOT NULL AND p_assignee_type_code IS NOT NULL
    THEN

        -- Get assignee rec from cache rec or database rec
        GetAssigneeRec(  p_assignee_id        => p_assignee_id
                       , p_assignee_type_code => p_assignee_type_code
                       , p_current_flag       => p_current_flag
                       , x_assignee_rec       => l_assignee_rec ) ;


        IF l_assignee_rec.assignee_role_obj_name IS NULL
        THEN

            RETURN l_assignee_rec.assignee_type ;
        ELSE

            RETURN l_assignee_rec.assignee_role_obj_name ;

        END IF ;

    ELSIF p_assignee_id IS NULL AND p_assignee_type_code = 'PERSON'
    THEN

        -- Get assignee rec from cache rec or database rec
        GetAssigneeRec(  p_assignee_id        => -1
                       , p_assignee_type_code => p_assignee_type_code
                       , p_current_flag       => p_current_flag
                       , x_assignee_rec       => l_assignee_rec ) ;

        RETURN l_assignee_rec.assignee_type ;

    ELSE
        RETURN NULL ;

    END IF ;

EXCEPTION
    WHEN OTHERS THEN
         RETURN NULL ;

END Get_Assignee_Type ;



/********************************************************************
* API Type      : Private Copy People API
* Purpose       : This api will copy instances for Route People
*********************************************************************/
PROCEDURE COPY_PEOPLE (
  P_FROM_STEP_ID   IN NUMBER ,
  P_TO_STEP_ID     IN NUMBER ,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
)
IS

  -- Added check PARENT_ROUTE_PEOPLE_ID IS NULL
  -- not to copy transferred assignee by ntf reassignment
  cursor c is select
      ROUTE_PEOPLE_ID,
      STEP_ID,
      ASSIGNEE_ID,
      ASSIGNEE_TYPE_CODE,
      ADHOC_PEOPLE_FLAG,
      WF_NOTIFICATION_ID,
      RESPONSE_CODE,
      RESPONSE_DATE,
      REQUEST_ID,
      ORIGINAL_SYSTEM_REFERENCE,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ORIGINAL_ASSIGNEE_ID,
      ORIGINAL_ASSIGNEE_TYPE_CODE,
      RESPONSE_CONDITION_CODE,
      RESPONSE_DESCRIPTION
    from ENG_CHANGE_ROUTE_PEOPLE_VL
    where STEP_ID = P_FROM_STEP_ID
    and  PARENT_ROUTE_PEOPLE_ID IS NULL
    ;

    -- No need to lock
    -- for update of ROUTE_PEOPLE_ID nowait;


  -- General variables
  l_fnd_user_id        NUMBER ;
  l_fnd_login_id       NUMBER ;
  l_language           VARCHAR2(4) ;
  l_rowid              ROWID;

  l_people_id          NUMBER ;


BEGIN

  -- Initialize Vars
  l_fnd_user_id        := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
  l_fnd_login_id       := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));
  l_language           := userenv('LANG');

  -- Real code starts here
  -- FND_PROFILE package is not available for workflow (WF),
  -- therefore manually set WHO column values
  IF p_api_caller = 'WF' THEN
      l_fnd_user_id := p_user_id;
      l_fnd_login_id := '';
  END IF;


  IF l_fnd_user_id IS NULL THEN

     l_fnd_user_id := -10000 ;

  END IF ;


  for recinfo in c loop

    --  Get Next Sequence Value for STEP_ID
    SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL  into l_people_id
    FROM DUAL;

    INSERT_ROW (
    X_ROWID                     => l_rowid,
    X_ROUTE_PEOPLE_ID           => l_people_id ,
    X_STEP_ID                   => P_TO_STEP_ID ,
    X_ASSIGNEE_ID               => recinfo.ASSIGNEE_ID,
    X_ASSIGNEE_TYPE_CODE        => recinfo.ASSIGNEE_TYPE_CODE,
    X_ADHOC_PEOPLE_FLAG         => recinfo.ADHOC_PEOPLE_FLAG,
    X_WF_NOTIFICATION_ID        => NULL ,
    X_RESPONSE_CODE             => NULL ,
    X_RESPONSE_DATE             => NULL ,
    X_REQUEST_ID                => recinfo.REQUEST_ID,
    X_ORIGINAL_SYSTEM_REFERENCE => recinfo.ORIGINAL_SYSTEM_REFERENCE,
    X_RESPONSE_DESCRIPTION      => NULL,
    X_CREATION_DATE             => SYSDATE,
    X_CREATED_BY                => l_fnd_user_id,
    X_LAST_UPDATE_DATE          => SYSDATE,
    X_LAST_UPDATED_BY           => l_fnd_user_id,
    X_LAST_UPDATE_LOGIN         => l_fnd_login_id,
    X_PROGRAM_ID                => recinfo.PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID    => recinfo.PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE       => recinfo.PROGRAM_UPDATE_DATE,
    X_ORIGINAL_ASSIGNEE_ID        => recinfo.ORIGINAL_ASSIGNEE_ID,
    X_ORIGINAL_ASSIGNEE_TYPE_CODE => recinfo.ORIGINAL_ASSIGNEE_TYPE_CODE,
    X_RESPONSE_CONDITION_CODE   => recinfo.RESPONSE_CONDITION_CODE,
    X_PARENT_ROUTE_PEOPLE_ID    => NULL
    ) ;

    --
    --
    -- Call Assoc's Copy Row Procedures
    --
    Eng_Change_Route_Assocs_Util.COPY_ASSOCIATIONS(
       P_FROM_PEOPLE_ID  => recinfo.ROUTE_PEOPLE_ID,
       P_TO_PEOPLE_ID    => l_people_id ,
       P_USER_ID       => l_fnd_user_id,
       P_API_CALLER    => P_API_CALLER
    ) ;

  end loop ;


END COPY_PEOPLE ;




/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for TL Entity Object:
*                      ENG_CHANGE_ROUTE_PEOPLE_VL
*                 PROCEDURE INSERT_ROW;
*                 PROCEDURE LOCK_ROW;
*                 PROCEDURE UPDATE_ROW;
*                 PROCEDURE DELETE_ROW;
*********************************************************************/
PROCEDURE INSERT_ROW (
  X_ROWID                     IN OUT NOCOPY VARCHAR2,
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_STEP_ID                   IN NUMBER,
  X_ASSIGNEE_ID               IN NUMBER,
  X_ASSIGNEE_TYPE_CODE        IN VARCHAR2,
  X_ADHOC_PEOPLE_FLAG         IN VARCHAR2,
  X_WF_NOTIFICATION_ID        IN NUMBER,
  X_RESPONSE_CODE             IN VARCHAR2,
  X_RESPONSE_DATE             IN DATE,
  X_REQUEST_ID                IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_RESPONSE_DESCRIPTION      IN VARCHAR2,
  X_CREATION_DATE             IN DATE,
  X_CREATED_BY                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_ASSIGNEE_ID        IN NUMBER,
  X_ORIGINAL_ASSIGNEE_TYPE_CODE IN VARCHAR2,
  X_RESPONSE_CONDITION_CODE   IN VARCHAR2,
  X_PARENT_ROUTE_PEOPLE_ID       IN NUMBER
)
IS

  cursor C is select ROWID from ENG_CHANGE_ROUTE_PEOPLE
    where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID
    ;


BEGIN

  insert into ENG_CHANGE_ROUTE_PEOPLE (
    ROUTE_PEOPLE_ID,
    STEP_ID,
    ASSIGNEE_ID,
    ASSIGNEE_TYPE_CODE,
    ADHOC_PEOPLE_FLAG,
    WF_NOTIFICATION_ID,
    RESPONSE_CODE,
    RESPONSE_DATE,
    REQUEST_ID,
    ORIGINAL_SYSTEM_REFERENCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ORIGINAL_ASSIGNEE_ID,
    ORIGINAL_ASSIGNEE_TYPE_CODE,
    RESPONSE_CONDITION_CODE,
    PARENT_ROUTE_PEOPLE_ID
  ) values (
    X_ROUTE_PEOPLE_ID,
    X_STEP_ID,
    X_ASSIGNEE_ID,
    X_ASSIGNEE_TYPE_CODE,
    X_ADHOC_PEOPLE_FLAG,
    X_WF_NOTIFICATION_ID,
    X_RESPONSE_CODE,
    X_RESPONSE_DATE,
    X_REQUEST_ID,
    X_ORIGINAL_SYSTEM_REFERENCE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    X_ORIGINAL_ASSIGNEE_ID,
    X_ORIGINAL_ASSIGNEE_TYPE_CODE,
    X_RESPONSE_CONDITION_CODE,
    X_PARENT_ROUTE_PEOPLE_ID
  );

  insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
    ROUTE_PEOPLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RESPONSE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ROUTE_PEOPLE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_RESPONSE_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_ROUTE_PEOPLE_TL T
    where T.ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_STEP_ID                   IN NUMBER,
  X_ASSIGNEE_ID               IN NUMBER,
  X_ASSIGNEE_TYPE_CODE        IN VARCHAR2,
  X_ADHOC_PEOPLE_FLAG         IN VARCHAR2,
  X_WF_NOTIFICATION_ID        IN NUMBER,
  X_RESPONSE_CODE             IN VARCHAR2,
  X_RESPONSE_DATE             IN DATE,
  X_REQUEST_ID                IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_RESPONSE_DESCRIPTION      IN VARCHAR2,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_ASSIGNEE_ID        IN NUMBER,
  X_ORIGINAL_ASSIGNEE_TYPE_CODE IN VARCHAR2,
  X_RESPONSE_CONDITION_CODE   IN VARCHAR2,
  X_PARENT_ROUTE_PEOPLE_ID       IN NUMBER
)
IS

  cursor c is select
      STEP_ID,
      ASSIGNEE_ID,
      ASSIGNEE_TYPE_CODE,
      ADHOC_PEOPLE_FLAG,
      WF_NOTIFICATION_ID,
      RESPONSE_CODE,
      RESPONSE_DATE,
      REQUEST_ID,
      ORIGINAL_SYSTEM_REFERENCE,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ORIGINAL_ASSIGNEE_ID,
      ORIGINAL_ASSIGNEE_TYPE_CODE,
      RESPONSE_CONDITION_CODE,
      PARENT_ROUTE_PEOPLE_ID
    from ENG_CHANGE_ROUTE_PEOPLE
    where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID
    for update of ROUTE_PEOPLE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RESPONSE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_ROUTE_PEOPLE_TL
    where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ROUTE_PEOPLE_ID nowait;


BEGIN


  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STEP_ID = X_STEP_ID)
      AND (recinfo.ASSIGNEE_ID = X_ASSIGNEE_ID)
      AND (recinfo.ASSIGNEE_TYPE_CODE = X_ASSIGNEE_TYPE_CODE)
      AND (recinfo.ADHOC_PEOPLE_FLAG = X_ADHOC_PEOPLE_FLAG)
      AND ((recinfo.WF_NOTIFICATION_ID = X_WF_NOTIFICATION_ID)
           OR ((recinfo.WF_NOTIFICATION_ID is null) AND (X_WF_NOTIFICATION_ID is null)))
      AND ((recinfo.RESPONSE_CODE = X_RESPONSE_CODE)
           OR ((recinfo.RESPONSE_CODE is null) AND (X_RESPONSE_CODE is null)))
      AND ((recinfo.RESPONSE_DATE = X_RESPONSE_DATE)
           OR ((recinfo.RESPONSE_DATE is null) AND (X_RESPONSE_DATE is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.ORIGINAL_SYSTEM_REFERENCE = X_ORIGINAL_SYSTEM_REFERENCE)
           OR ((recinfo.ORIGINAL_SYSTEM_REFERENCE is null) AND (X_ORIGINAL_SYSTEM_REFERENCE is null)))
      AND ((recinfo.ORIGINAL_ASSIGNEE_ID = X_ORIGINAL_ASSIGNEE_ID)
           OR ((recinfo.ORIGINAL_ASSIGNEE_ID is null) AND (X_ORIGINAL_ASSIGNEE_ID is null)))
      AND ((recinfo.ORIGINAL_ASSIGNEE_TYPE_CODE = X_ORIGINAL_ASSIGNEE_TYPE_CODE)
           OR ((recinfo.ORIGINAL_ASSIGNEE_TYPE_CODE is null) AND (X_ORIGINAL_ASSIGNEE_TYPE_CODE is null)))
      AND ((recinfo.RESPONSE_CONDITION_CODE = X_RESPONSE_CONDITION_CODE)
           OR ((recinfo.RESPONSE_CONDITION_CODE is null) AND (X_RESPONSE_CONDITION_CODE is null)))
      AND ((recinfo.PARENT_ROUTE_PEOPLE_ID = X_PARENT_ROUTE_PEOPLE_ID)
           OR ((recinfo.PARENT_ROUTE_PEOPLE_ID is null) AND (X_PARENT_ROUTE_PEOPLE_ID is null)))
      -- followings are not generated by tool
      -- AND ((recinfo.PROGRAM_ID= X_PROGRAM_ID)
      --    OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      -- AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
      --     OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      -- AND ((recinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE)
      --    OR ((recinfo.PROGRAM_UPDATE_DATE is null) AND (X_PROGRAM_UPDATE_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.RESPONSE_DESCRIPTION = X_RESPONSE_DESCRIPTION)
               OR ((tlinfo.RESPONSE_DESCRIPTION is null) AND (X_RESPONSE_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

END LOCK_ROW ;



PROCEDURE UPDATE_ROW (
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_STEP_ID                   IN NUMBER,
  X_ASSIGNEE_ID               IN NUMBER,
  X_ASSIGNEE_TYPE_CODE        IN VARCHAR2,
  X_ADHOC_PEOPLE_FLAG         IN VARCHAR2,
  X_WF_NOTIFICATION_ID        IN NUMBER,
  X_RESPONSE_CODE             IN VARCHAR2,
  X_RESPONSE_DATE             IN DATE,
  X_REQUEST_ID                IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_RESPONSE_DESCRIPTION      IN VARCHAR2,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_ASSIGNEE_ID        IN NUMBER,
  X_ORIGINAL_ASSIGNEE_TYPE_CODE IN VARCHAR2,
  X_RESPONSE_CONDITION_CODE   IN VARCHAR2,
  X_PARENT_ROUTE_PEOPLE_ID       IN NUMBER
)
IS

BEGIN

  update ENG_CHANGE_ROUTE_PEOPLE set
    STEP_ID = X_STEP_ID,
    ASSIGNEE_ID = X_ASSIGNEE_ID,
    ASSIGNEE_TYPE_CODE = X_ASSIGNEE_TYPE_CODE,
    ADHOC_PEOPLE_FLAG = X_ADHOC_PEOPLE_FLAG,
    WF_NOTIFICATION_ID = X_WF_NOTIFICATION_ID,
    RESPONSE_CODE = X_RESPONSE_CODE,
    RESPONSE_DATE = X_RESPONSE_DATE,
    REQUEST_ID = X_REQUEST_ID,
    ORIGINAL_SYSTEM_REFERENCE = X_ORIGINAL_SYSTEM_REFERENCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    ORIGINAL_ASSIGNEE_ID        = X_ORIGINAL_ASSIGNEE_ID,
    ORIGINAL_ASSIGNEE_TYPE_CODE = X_ORIGINAL_ASSIGNEE_TYPE_CODE,
    RESPONSE_CONDITION_CODE = X_RESPONSE_CONDITION_CODE,
    PARENT_ROUTE_PEOPLE_ID = PARENT_ROUTE_PEOPLE_ID
  where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_ROUTE_PEOPLE_TL set
    RESPONSE_DESCRIPTION = X_RESPONSE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;



PROCEDURE DELETE_ROW (
  X_ROUTE_PEOPLE_ID           IN NUMBER
)
IS


BEGIN


  delete from ENG_CHANGE_ROUTE_PEOPLE_TL
  where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_ROUTE_PEOPLE
  where ROUTE_PEOPLE_ID = X_ROUTE_PEOPLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END DELETE_ROW ;


PROCEDURE ADD_LANGUAGE
IS

BEGIN

  delete from ENG_CHANGE_ROUTE_PEOPLE_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_ROUTE_PEOPLE B
    where B.ROUTE_PEOPLE_ID = T.ROUTE_PEOPLE_ID
    );

  update ENG_CHANGE_ROUTE_PEOPLE_TL T set (
      RESPONSE_DESCRIPTION
    ) = (select
      B.RESPONSE_DESCRIPTION
    from ENG_CHANGE_ROUTE_PEOPLE_TL B
    where B.ROUTE_PEOPLE_ID = T.ROUTE_PEOPLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ROUTE_PEOPLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ROUTE_PEOPLE_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_ROUTE_PEOPLE_TL SUBB, ENG_CHANGE_ROUTE_PEOPLE_TL SUBT
    where SUBB.ROUTE_PEOPLE_ID = SUBT.ROUTE_PEOPLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RESPONSE_DESCRIPTION <> SUBT.RESPONSE_DESCRIPTION
      or (SUBB.RESPONSE_DESCRIPTION is null and SUBT.RESPONSE_DESCRIPTION is not null)
      or (SUBB.RESPONSE_DESCRIPTION is not null and SUBT.RESPONSE_DESCRIPTION is null)
  ));

  insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
    ROUTE_PEOPLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RESPONSE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ROUTE_PEOPLE_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.RESPONSE_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_ROUTE_PEOPLE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_ROUTE_PEOPLE_TL T
    where T.ROUTE_PEOPLE_ID = B.ROUTE_PEOPLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


END Eng_Change_Route_People_Util ;

/
