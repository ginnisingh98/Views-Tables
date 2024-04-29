--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ROUTE_ASSOCS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ROUTE_ASSOCS_UTIL" AS
/* $Header: ENGURTAB.pls 115.2 2004/05/27 19:33:22 mkimizuk noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'Eng_Change_Route_Assocs_Util' ;

    -- For Debug
    g_debug_file      UTL_FILE.FILE_TYPE ;
    g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    g_output_dir      VARCHAR2(80) ;
    g_debug_filename  VARCHAR2(35) ;
    g_debug_errmesg   VARCHAR2(240);



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

     -- Set default debug file name
     IF g_debug_filename IS NULL THEN
         g_debug_filename  := 'Eng_Change_Route_Assocs_Util.log' ;
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
* API Type      : Private Copy Associations API
* Purpose       : This api will copy instances for Route Associaitons
*********************************************************************/
PROCEDURE COPY_ASSOCIATIONS (
  P_FROM_PEOPLE_ID   IN NUMBER ,
  P_TO_PEOPLE_ID     IN NUMBER ,
  P_USER_ID          IN NUMBER   := NULL ,
  P_API_CALLER       IN VARCHAR2 := NULL
)
IS


  cursor c is select
      ROUTE_ASSOCIATION_ID,
      ROUTE_PEOPLE_ID,
      ADHOC_ASSOC_FLAG,
      ASSOC_OBJECT_NAME,
      ASSOC_OBJ_PK1_VALUE,
      ASSOC_OBJ_PK2_VALUE,
      ASSOC_OBJ_PK3_VALUE,
      ASSOC_OBJ_PK4_VALUE,
      ASSOC_OBJ_PK5_VALUE,
      OBJECT_NAME,
      OBJECT_ID1,
      OBJECT_ID2,
      OBJECT_ID3,
      OBJECT_ID4,
      OBJECT_ID5,
      REQUEST_ID,
      ORIGINAL_SYSTEM_REFERENCE,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE
    from ENG_CHANGE_ROUTE_ASSOCS
    where ROUTE_PEOPLE_ID = P_FROM_PEOPLE_ID ;

    -- No need to lock
    -- for update of ROUTE_PEOPLE_ID nowait;


  -- General variables
  l_fnd_user_id        NUMBER ;
  l_fnd_login_id       NUMBER ;
  l_language           VARCHAR2(4) ;
  l_rowid              ROWID;

  l_assoc_id           NUMBER ;


BEGIN

  -- Init Vars
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
    SELECT ENG_CHANGE_ROUTE_ASSOCS_S.NEXTVAL  into l_assoc_id
    FROM DUAL;

    INSERT_ROW (
    X_ROWID                     => l_rowid,
    X_ROUTE_ASSOCIATION_ID      => l_assoc_id,
    X_ROUTE_PEOPLE_ID           => P_TO_PEOPLE_ID,
    X_ASSOC_OBJECT_NAME         => recinfo.ASSOC_OBJECT_NAME,
    X_ASSOC_OBJ_PK1_VALUE       => recinfo.ASSOC_OBJ_PK1_VALUE,
    X_ASSOC_OBJ_PK2_VALUE       => recinfo.ASSOC_OBJ_PK2_VALUE,
    X_ASSOC_OBJ_PK3_VALUE       => recinfo.ASSOC_OBJ_PK3_VALUE,
    X_ASSOC_OBJ_PK4_VALUE       => recinfo.ASSOC_OBJ_PK4_VALUE,
    X_ASSOC_OBJ_PK5_VALUE       => recinfo.ASSOC_OBJ_PK5_VALUE,
    X_OBJECT_NAME               => recinfo.OBJECT_NAME,
    X_OBJECT_ID1                => recinfo.OBJECT_ID1,
    X_OBJECT_ID2                => recinfo.OBJECT_ID2,
    X_OBJECT_ID3                => recinfo.OBJECT_ID3,
    X_OBJECT_ID4                => recinfo.OBJECT_ID4,
    X_OBJECT_ID5                => recinfo.OBJECT_ID5,
    X_REQUEST_ID                => recinfo.REQUEST_ID,
    X_CREATION_DATE             => SYSDATE,
    X_CREATED_BY                => l_fnd_user_id,
    X_LAST_UPDATE_DATE          => SYSDATE,
    X_LAST_UPDATED_BY           => l_fnd_user_id,
    X_LAST_UPDATE_LOGIN         => l_fnd_login_id,
    X_PROGRAM_ID                => recinfo.PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID    => recinfo.PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE       => recinfo.PROGRAM_UPDATE_DATE,
    X_ORIGINAL_SYSTEM_REFERENCE => recinfo.ORIGINAL_SYSTEM_REFERENCE,
    X_ADHOC_ASSOC_FLAG          => recinfo.ADHOC_ASSOC_FLAG
    ) ;


  end loop ;


END COPY_ASSOCIATIONS ;




/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for Entity Object:
*                      ENG_CHANGE_ROUTE_ASSOCS
*                 PROCEDURE INSERT_ROW;
*                 -- Not Supproting PROCEDURE LOCK_ROW;
*                 -- Not Supproting PROCEDURE UPDATE_ROW;
*                 -- Not Supproting PROCEDURE DELETE_ROW;
*********************************************************************/
PROCEDURE INSERT_ROW (
  X_ROWID                     IN OUT NOCOPY VARCHAR2,
  X_ROUTE_ASSOCIATION_ID      IN NUMBER,
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_ASSOC_OBJECT_NAME         IN VARCHAR2,
  X_ASSOC_OBJ_PK1_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK2_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK3_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK4_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK5_VALUE       IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_REQUEST_ID                IN NUMBER,
  X_CREATION_DATE             IN DATE,
  X_CREATED_BY                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_ADHOC_ASSOC_FLAG          IN VARCHAR2
)
IS

  cursor C is select ROWID from ENG_CHANGE_ROUTE_ASSOCS
    where ROUTE_ASSOCIATION_ID = X_ROUTE_ASSOCIATION_ID
    ;


BEGIN

  insert into ENG_CHANGE_ROUTE_ASSOCS (
    ROUTE_ASSOCIATION_ID,
    ROUTE_PEOPLE_ID,
    ASSOC_OBJECT_NAME,
    ASSOC_OBJ_PK1_VALUE,
    ASSOC_OBJ_PK2_VALUE,
    ASSOC_OBJ_PK3_VALUE,
    ASSOC_OBJ_PK4_VALUE,
    ASSOC_OBJ_PK5_VALUE,
    OBJECT_NAME,
    OBJECT_ID1,
    OBJECT_ID2,
    OBJECT_ID3,
    OBJECT_ID4,
    OBJECT_ID5,
    REQUEST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ORIGINAL_SYSTEM_REFERENCE,
    ADHOC_ASSOC_FLAG
  ) values (
    X_ROUTE_ASSOCIATION_ID,
    X_ROUTE_PEOPLE_ID,
    X_ASSOC_OBJECT_NAME,
    X_ASSOC_OBJ_PK1_VALUE,
    X_ASSOC_OBJ_PK2_VALUE,
    X_ASSOC_OBJ_PK3_VALUE,
    X_ASSOC_OBJ_PK4_VALUE,
    X_ASSOC_OBJ_PK5_VALUE,
    X_OBJECT_NAME,
    X_OBJECT_ID1,
    X_OBJECT_ID2,
    X_OBJECT_ID3,
    X_OBJECT_ID4,
    X_OBJECT_ID5,
    X_REQUEST_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    X_ORIGINAL_SYSTEM_REFERENCE,
    X_ADHOC_ASSOC_FLAG
  );


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;



/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


END Eng_Change_Route_Assocs_Util ;

/
