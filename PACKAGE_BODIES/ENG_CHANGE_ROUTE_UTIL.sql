--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ROUTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ROUTE_UTIL" AS
/* $Header: ENGURTEB.pls 120.1 2006/01/12 19:24:01 mkimizuk noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'Eng_Change_Route_Util' ;

    -- For Debug
    g_debug_file      UTL_FILE.FILE_TYPE ;
    g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    g_output_dir      VARCHAR2(80) ;
    g_debug_filename  VARCHAR2(30) ;
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

     -- Set Default Debug File Name
     IF g_debug_filename IS NULL THEN
         g_debug_filename  := 'Eng_Change_Route_Util.log' ;
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
* API Type      : Refresh Route API
* Scope         : Oracle (for Oracle Applications development use only)
* Purpose       : This api will create another instance of Route specified
*                 as param and set original Route as History
*********************************************************************/
PROCEDURE REFRESH_ROUTE(
  X_NEW_ROUTE_ID   OUT NOCOPY NUMBER,
  P_ROUTE_ID       IN NUMBER,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
)
IS

BEGIN


   --  Get Next Sequence Value for ROUTE_ID
   SELECT ENG_CHANGE_ROUTES_S.NEXTVAL  into X_NEW_ROUTE_ID
   FROM DUAL;

   -- Call COPY_ROUTE Prodedure
   COPY_ROUTE (
     X_TO_ROUTE_ID    => X_NEW_ROUTE_ID ,
     P_FROM_ROUTE_ID  => P_ROUTE_ID,
     P_USER_ID        => P_USER_ID ,
     P_API_CALLER     => P_API_CALLER
   ) ;

   -- Set Original Route to History
   UPDATE ENG_CHANGE_ROUTES
   SET TEMPLATE_FLAG = 'H'
   WHERE ROUTE_ID = P_ROUTE_ID ;


END REFRESH_ROUTE ;


/********************************************************************
* API Type      : Private Copy Route API
* Purpose       : This api will create another instance of Route
*********************************************************************/
PROCEDURE COPY_ROUTE (
  X_TO_ROUTE_ID    IN OUT NOCOPY NUMBER ,
  P_FROM_ROUTE_ID  IN NUMBER ,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
)
IS

  cursor c is select
      TEMPLATE_FLAG,
      OWNER_ID,
      FIXED_FLAG,
      OBJECT_NAME,
      OBJECT_ID1,
      OBJECT_ID2,
      OBJECT_ID3,
      OBJECT_ID4,
      OBJECT_ID5,
      APPLIED_TEMPLATE_ID,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      WF_PROCESS_NAME,
      STATUS_CODE,
      ROUTE_START_DATE,
      ROUTE_END_DATE,
      CHANGE_REVISION,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ORIGINAL_SYSTEM_REFERENCE,
      CLASSIFICATION_CODE,
      ROUTE_TYPE_CODE
    from ENG_CHANGE_ROUTES
    where ROUTE_ID = P_FROM_ROUTE_ID  ;

    -- No need to lock
    -- for update of ROUTE_ID nowait;

  recinfo c%rowtype;

  cursor c1 is select
      ROUTE_NAME,
      ROUTE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_ROUTES_TL
    where ROUTE_ID = P_FROM_ROUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

    -- No need to lock
    -- for update of ROUTE_ID nowait;

  tlrecinfo c1%rowtype;

  -- General variables
  l_fnd_user_id        NUMBER ;
  l_fnd_login_id       NUMBER ;
  l_language           VARCHAR2(4) ;
  l_rowid              ROWID;


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

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  open c1;
  fetch c1 into tlrecinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c1;


  INSERT_ROW (
  X_ROWID                     => l_rowid,
  X_ROUTE_ID                  => X_TO_ROUTE_ID ,
  X_ROUTE_NAME                => tlrecinfo.ROUTE_NAME,
  X_ROUTE_DESCRIPTION         => tlrecinfo.ROUTE_DESCRIPTION,
  X_TEMPLATE_FLAG             => 'N' ,  -- recinfo.TEMPLATE_FLAG,
  X_OWNER_ID                  => recinfo.OWNER_ID,
  X_FIXED_FLAG                => recinfo.FIXED_FLAG,
  X_OBJECT_NAME               => recinfo.OBJECT_NAME,
  X_OBJECT_ID1                => recinfo.OBJECT_ID1,
  X_OBJECT_ID2                => recinfo.OBJECT_ID2,
  X_OBJECT_ID3                => recinfo.OBJECT_ID3,
  X_OBJECT_ID4                => recinfo.OBJECT_ID4,
  X_OBJECT_ID5                => recinfo.OBJECT_ID5,
  X_APPLIED_TEMPLATE_ID       => recinfo.APPLIED_TEMPLATE_ID,
  X_WF_ITEM_TYPE              => recinfo.WF_ITEM_TYPE,
  X_WF_ITEM_KEY               => recinfo.WF_ITEM_KEY,
  X_WF_PROCESS_NAME           => recinfo.WF_PROCESS_NAME,
  X_STATUS_CODE               => 'NOT_STARTED' ,  -- recinfo.STATUS_CODE,
  X_ROUTE_START_DATE          => NULL ,           -- recinfo.ROUTE_START_DATE,
  X_ROUTE_END_DATE            => NULL ,           -- recinfo.ROUTE_END_DATE,
  X_CHANGE_REVISION           => recinfo.CHANGE_REVISION,
  X_CREATION_DATE             => SYSDATE,
  X_CREATED_BY                => l_fnd_user_id,
  X_LAST_UPDATE_DATE          => SYSDATE,
  X_LAST_UPDATED_BY           => l_fnd_user_id,
  X_LAST_UPDATE_LOGIN         => l_fnd_login_id,
  X_ATTRIBUTE_CATEGORY        => recinfo.ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1                => recinfo.ATTRIBUTE1,
  X_ATTRIBUTE2                => recinfo.ATTRIBUTE2,
  X_ATTRIBUTE3                => recinfo.ATTRIBUTE3,
  X_ATTRIBUTE4                => recinfo.ATTRIBUTE4,
  X_ATTRIBUTE5                => recinfo.ATTRIBUTE5,
  X_ATTRIBUTE6                => recinfo.ATTRIBUTE6,
  X_ATTRIBUTE7                => recinfo.ATTRIBUTE7,
  X_ATTRIBUTE8                => recinfo.ATTRIBUTE8,
  X_ATTRIBUTE9                => recinfo.ATTRIBUTE9,
  X_ATTRIBUTE10               => recinfo.ATTRIBUTE10,
  X_ATTRIBUTE11               => recinfo.ATTRIBUTE11,
  X_ATTRIBUTE12               => recinfo.ATTRIBUTE12,
  X_ATTRIBUTE13               => recinfo.ATTRIBUTE13,
  X_ATTRIBUTE14               => recinfo.ATTRIBUTE14,
  X_ATTRIBUTE15               => recinfo.ATTRIBUTE15,
  X_REQUEST_ID                => recinfo.REQUEST_ID,
  X_PROGRAM_ID                => recinfo.PROGRAM_ID,
  X_PROGRAM_APPLICATION_ID    => recinfo.PROGRAM_APPLICATION_ID,
  X_PROGRAM_UPDATE_DATE       => recinfo.PROGRAM_UPDATE_DATE,
  X_ORIGINAL_SYSTEM_REFERENCE => recinfo.ORIGINAL_SYSTEM_REFERENCE,
  X_CLASSIFICATION_CODE       => recinfo.CLASSIFICATION_CODE,
  X_ROUTE_TYPE_CODE           => recinfo.ROUTE_TYPE_CODE
  );

  --
  --
  -- Call Step's Copy Row Procedures
  --
  Eng_Change_Route_Step_Util.COPY_STEPS (
     P_FROM_ROUTE_ID  => P_FROM_ROUTE_ID,
     P_TO_ROUTE_ID    => X_TO_ROUTE_ID ,
     P_USER_ID        => l_fnd_user_id ,
     P_API_CALLER     => P_API_CALLER
  ) ;


END COPY_ROUTE ;


/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for TL Entity Object: ENG_CHANGE_ROUTES_VL
*                 PROCEDURE INSERT_ROW;
*                 PROCEDURE LOCK_ROW;
*                 PROCEDURE UPDATE_ROW;
*                 PROCEDURE DELETE_ROW;
*********************************************************************/
PROCEDURE INSERT_ROW (
  X_ROWID                     IN OUT NOCOPY VARCHAR2,
  X_ROUTE_ID                  IN NUMBER,
  X_ROUTE_NAME                IN VARCHAR2,
  X_ROUTE_DESCRIPTION         IN VARCHAR2,
  X_TEMPLATE_FLAG             IN VARCHAR2,
  X_OWNER_ID                  IN NUMBER,
  X_FIXED_FLAG                IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_APPLIED_TEMPLATE_ID       IN NUMBER,
  X_WF_ITEM_TYPE              IN VARCHAR2,
  X_WF_ITEM_KEY               IN VARCHAR2,
  X_WF_PROCESS_NAME           IN VARCHAR2,
  X_STATUS_CODE               IN VARCHAR2,
  X_ROUTE_START_DATE          IN DATE,
  X_ROUTE_END_DATE            IN DATE,
  X_CHANGE_REVISION           IN VARCHAR2,
  X_CREATION_DATE             IN DATE,
  X_CREATED_BY                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_ATTRIBUTE_CATEGORY        IN VARCHAR2,
  X_ATTRIBUTE1                IN VARCHAR2,
  X_ATTRIBUTE2                IN VARCHAR2,
  X_ATTRIBUTE3                IN VARCHAR2,
  X_ATTRIBUTE4                IN VARCHAR2,
  X_ATTRIBUTE5                IN VARCHAR2,
  X_ATTRIBUTE6                IN VARCHAR2,
  X_ATTRIBUTE7                IN VARCHAR2,
  X_ATTRIBUTE8                IN VARCHAR2,
  X_ATTRIBUTE9                IN VARCHAR2,
  X_ATTRIBUTE10               IN VARCHAR2,
  X_ATTRIBUTE11               IN VARCHAR2,
  X_ATTRIBUTE12               IN VARCHAR2,
  X_ATTRIBUTE13               IN VARCHAR2,
  X_ATTRIBUTE14               IN VARCHAR2,
  X_ATTRIBUTE15               IN VARCHAR2,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_CLASSIFICATION_CODE       IN VARCHAR2,
  X_ROUTE_TYPE_CODE           IN VARCHAR2
)
IS

  CURSOR C IS
    SELECT ROWID FROM ENG_CHANGE_ROUTES
    WHERE ROUTE_ID = X_ROUTE_ID
    ;

BEGIN

  insert into ENG_CHANGE_ROUTES (
    ROUTE_ID,
    TEMPLATE_FLAG,
    OWNER_ID,
    FIXED_FLAG,
    OBJECT_NAME,
    OBJECT_ID1,
    OBJECT_ID2,
    OBJECT_ID3,
    OBJECT_ID4,
    OBJECT_ID5,
    APPLIED_TEMPLATE_ID,
    WF_ITEM_TYPE,
    WF_ITEM_KEY,
    WF_PROCESS_NAME,
    STATUS_CODE,
    ROUTE_START_DATE,
    ROUTE_END_DATE,
    CHANGE_REVISION,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
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
    CLASSIFICATION_CODE,
    ROUTE_TYPE_CODE
  ) values (
    X_ROUTE_ID,
    X_TEMPLATE_FLAG,
    X_OWNER_ID,
    X_FIXED_FLAG,
    X_OBJECT_NAME,
    X_OBJECT_ID1,
    X_OBJECT_ID2,
    X_OBJECT_ID3,
    X_OBJECT_ID4,
    X_OBJECT_ID5,
    X_APPLIED_TEMPLATE_ID,
    X_WF_ITEM_TYPE,
    X_WF_ITEM_KEY,
    X_WF_PROCESS_NAME,
    X_STATUS_CODE,
    X_ROUTE_START_DATE,
    X_ROUTE_END_DATE,
    X_CHANGE_REVISION,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
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
    X_CLASSIFICATION_CODE,
    X_ROUTE_TYPE_CODE
  );

  insert into ENG_CHANGE_ROUTES_TL (
    LAST_UPDATE_LOGIN,
    ROUTE_NAME,
    ROUTE_DESCRIPTION,
    ROUTE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_ROUTE_NAME,
    X_ROUTE_DESCRIPTION,
    X_ROUTE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_ROUTES_TL T
    where T.ROUTE_ID = X_ROUTE_ID
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
  X_ROUTE_ID                  IN NUMBER,
  X_ROUTE_NAME                IN VARCHAR2,
  X_ROUTE_DESCRIPTION         IN VARCHAR2,
  X_TEMPLATE_FLAG             IN VARCHAR2,
  X_OWNER_ID                  IN NUMBER,
  X_FIXED_FLAG                IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_APPLIED_TEMPLATE_ID       IN NUMBER,
  X_WF_ITEM_TYPE              IN VARCHAR2,
  X_WF_ITEM_KEY               IN VARCHAR2,
  X_WF_PROCESS_NAME           IN VARCHAR2,
  X_STATUS_CODE               IN VARCHAR2,
  X_ROUTE_START_DATE          IN DATE,
  X_ROUTE_END_DATE            IN DATE,
  X_CHANGE_REVISION           IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY        IN VARCHAR2,
  X_ATTRIBUTE1                IN VARCHAR2,
  X_ATTRIBUTE2                IN VARCHAR2,
  X_ATTRIBUTE3                IN VARCHAR2,
  X_ATTRIBUTE4                IN VARCHAR2,
  X_ATTRIBUTE5                IN VARCHAR2,
  X_ATTRIBUTE6                IN VARCHAR2,
  X_ATTRIBUTE7                IN VARCHAR2,
  X_ATTRIBUTE8                IN VARCHAR2,
  X_ATTRIBUTE9                IN VARCHAR2,
  X_ATTRIBUTE10               IN VARCHAR2,
  X_ATTRIBUTE11               IN VARCHAR2,
  X_ATTRIBUTE12               IN VARCHAR2,
  X_ATTRIBUTE13               IN VARCHAR2,
  X_ATTRIBUTE14               IN VARCHAR2,
  X_ATTRIBUTE15               IN VARCHAR2,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_CLASSIFICATION_CODE       IN VARCHAR2,
  X_ROUTE_TYPE_CODE           IN VARCHAR2
)
IS

  cursor c is select
      TEMPLATE_FLAG,
      OWNER_ID,
      FIXED_FLAG,
      OBJECT_NAME,
      OBJECT_ID1,
      OBJECT_ID2,
      OBJECT_ID3,
      OBJECT_ID4,
      OBJECT_ID5,
      APPLIED_TEMPLATE_ID,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      WF_PROCESS_NAME,
      STATUS_CODE,
      ROUTE_START_DATE,
      ROUTE_END_DATE,
      CHANGE_REVISION,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ORIGINAL_SYSTEM_REFERENCE,
      CLASSIFICATION_CODE,
      ROUTE_TYPE_CODE
    from ENG_CHANGE_ROUTES
    where ROUTE_ID = X_ROUTE_ID
    for update of ROUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ROUTE_NAME,
      ROUTE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_ROUTES_TL
    where ROUTE_ID = X_ROUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ROUTE_ID nowait;

BEGIN

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;


  if (    (recinfo.TEMPLATE_FLAG = X_TEMPLATE_FLAG)
      AND (recinfo.OWNER_ID = X_OWNER_ID)
      AND ((recinfo.FIXED_FLAG = X_FIXED_FLAG)
           OR ((recinfo.FIXED_FLAG is null) AND (X_FIXED_FLAG is null)))
      AND (recinfo.OBJECT_NAME = X_OBJECT_NAME)
      AND (recinfo.OBJECT_ID1 = X_OBJECT_ID1)
      AND ((recinfo.OBJECT_ID2 = X_OBJECT_ID2)
           OR ((recinfo.OBJECT_ID2 is null) AND (X_OBJECT_ID2 is null)))
      AND ((recinfo.OBJECT_ID3 = X_OBJECT_ID3)
           OR ((recinfo.OBJECT_ID3 is null) AND (X_OBJECT_ID3 is null)))
      AND ((recinfo.OBJECT_ID4 = X_OBJECT_ID4)
           OR ((recinfo.OBJECT_ID4 is null) AND (X_OBJECT_ID4 is null)))
      AND ((recinfo.OBJECT_ID5 = X_OBJECT_ID5)
           OR ((recinfo.OBJECT_ID5 is null) AND (X_OBJECT_ID5 is null)))
      AND ((recinfo.APPLIED_TEMPLATE_ID = X_APPLIED_TEMPLATE_ID)
           OR ((recinfo.APPLIED_TEMPLATE_ID is null) AND (X_APPLIED_TEMPLATE_ID is null)))
      AND ((recinfo.WF_ITEM_TYPE = X_WF_ITEM_TYPE)
           OR ((recinfo.WF_ITEM_TYPE is null) AND (X_WF_ITEM_TYPE is null)))
      AND ((recinfo.WF_ITEM_KEY = X_WF_ITEM_KEY)
           OR ((recinfo.WF_ITEM_KEY is null) AND (X_WF_ITEM_KEY is null)))
      AND ((recinfo.WF_PROCESS_NAME = X_WF_PROCESS_NAME)
           OR ((recinfo.WF_PROCESS_NAME is null) AND (X_WF_PROCESS_NAME is null)))
      AND ((recinfo.STATUS_CODE = X_STATUS_CODE)
           OR ((recinfo.STATUS_CODE is null) AND (X_STATUS_CODE is null)))
      AND ((recinfo.ROUTE_START_DATE = X_ROUTE_START_DATE)
           OR ((recinfo.ROUTE_START_DATE is null) AND (X_ROUTE_START_DATE is null)))
      AND ((recinfo.ROUTE_END_DATE = X_ROUTE_END_DATE)
           OR ((recinfo.ROUTE_END_DATE is null) AND (X_ROUTE_END_DATE is null)))
      AND ((recinfo.CHANGE_REVISION = X_CHANGE_REVISION)
           OR ((recinfo.CHANGE_REVISION is null) AND (X_CHANGE_REVISION is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.ORIGINAL_SYSTEM_REFERENCE = X_ORIGINAL_SYSTEM_REFERENCE)
           OR ((recinfo.ORIGINAL_SYSTEM_REFERENCE is null) AND (X_ORIGINAL_SYSTEM_REFERENCE is null)))
      AND ((recinfo.CLASSIFICATION_CODE = X_CLASSIFICATION_CODE)
           OR ((recinfo.CLASSIFICATION_CODE is null) AND (X_CLASSIFICATION_CODE is null)))
      AND ((recinfo.ROUTE_TYPE_CODE = X_ROUTE_TYPE_CODE )
           OR ((recinfo.ROUTE_TYPE_CODE is null) AND (X_ROUTE_TYPE_CODE is null)))
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
      if (    (tlinfo.ROUTE_NAME = X_ROUTE_NAME)
          AND ((tlinfo.ROUTE_DESCRIPTION = X_ROUTE_DESCRIPTION)
               OR ((tlinfo.ROUTE_DESCRIPTION is null) AND (X_ROUTE_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  RETURN;

END LOCK_ROW;


PROCEDURE UPDATE_ROW (
  X_ROUTE_ID                  IN NUMBER,
  X_ROUTE_NAME                IN VARCHAR2,
  X_ROUTE_DESCRIPTION         IN VARCHAR2,
  X_TEMPLATE_FLAG             IN VARCHAR2,
  X_OWNER_ID                  IN NUMBER,
  X_FIXED_FLAG                IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_APPLIED_TEMPLATE_ID       IN NUMBER,
  X_WF_ITEM_TYPE              IN VARCHAR2,
  X_WF_ITEM_KEY               IN VARCHAR2,
  X_WF_PROCESS_NAME           IN VARCHAR2,
  X_STATUS_CODE               IN VARCHAR2,
  X_ROUTE_START_DATE          IN DATE,
  X_ROUTE_END_DATE            IN DATE,
  X_CHANGE_REVISION           IN VARCHAR2,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_ATTRIBUTE_CATEGORY        IN VARCHAR2,
  X_ATTRIBUTE1                IN VARCHAR2,
  X_ATTRIBUTE2                IN VARCHAR2,
  X_ATTRIBUTE3                IN VARCHAR2,
  X_ATTRIBUTE4                IN VARCHAR2,
  X_ATTRIBUTE5                IN VARCHAR2,
  X_ATTRIBUTE6                IN VARCHAR2,
  X_ATTRIBUTE7                IN VARCHAR2,
  X_ATTRIBUTE8                IN VARCHAR2,
  X_ATTRIBUTE9                IN VARCHAR2,
  X_ATTRIBUTE10               IN VARCHAR2,
  X_ATTRIBUTE11               IN VARCHAR2,
  X_ATTRIBUTE12               IN VARCHAR2,
  X_ATTRIBUTE13               IN VARCHAR2,
  X_ATTRIBUTE14               IN VARCHAR2,
  X_ATTRIBUTE15               IN VARCHAR2,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_CLASSIFICATION_CODE       IN VARCHAR2,
  X_ROUTE_TYPE_CODE           IN VARCHAR2
)
IS

BEGIN

  update ENG_CHANGE_ROUTES set
    TEMPLATE_FLAG = X_TEMPLATE_FLAG,
    OWNER_ID = X_OWNER_ID,
    FIXED_FLAG = X_FIXED_FLAG,
    OBJECT_NAME = X_OBJECT_NAME,
    OBJECT_ID1 = X_OBJECT_ID1,
    OBJECT_ID2 = X_OBJECT_ID2,
    OBJECT_ID3 = X_OBJECT_ID3,
    OBJECT_ID4 = X_OBJECT_ID4,
    OBJECT_ID5 = X_OBJECT_ID5,
    APPLIED_TEMPLATE_ID = X_APPLIED_TEMPLATE_ID,
    WF_ITEM_TYPE = X_WF_ITEM_TYPE,
    WF_ITEM_KEY = X_WF_ITEM_KEY,
    WF_PROCESS_NAME = X_WF_PROCESS_NAME,
    STATUS_CODE = X_STATUS_CODE,
    ROUTE_START_DATE = X_ROUTE_START_DATE,
    ROUTE_END_DATE = X_ROUTE_END_DATE,
    CHANGE_REVISION = X_CHANGE_REVISION,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    ORIGINAL_SYSTEM_REFERENCE = X_ORIGINAL_SYSTEM_REFERENCE,
    CLASSIFICATION_CODE = X_CLASSIFICATION_CODE,
    ROUTE_TYPE_CODE = X_ROUTE_TYPE_CODE
  where ROUTE_ID = X_ROUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_ROUTES_TL set
    ROUTE_NAME = X_ROUTE_NAME,
    ROUTE_DESCRIPTION = X_ROUTE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ROUTE_ID = X_ROUTE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;


PROCEDURE DELETE_ROW (
  X_ROUTE_ID                  IN NUMBER
)
IS

BEGIN
  delete from ENG_CHANGE_ROUTES_TL
  where ROUTE_ID = X_ROUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_ROUTES
  where ROUTE_ID = X_ROUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END DELETE_ROW;



PROCEDURE ADD_LANGUAGE
IS

BEGIN

  delete from ENG_CHANGE_ROUTES_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_ROUTES B
    where B.ROUTE_ID = T.ROUTE_ID
    );

  update ENG_CHANGE_ROUTES_TL T set (
      ROUTE_NAME,
      ROUTE_DESCRIPTION
    ) = (select
      B.ROUTE_NAME,
      B.ROUTE_DESCRIPTION
    from ENG_CHANGE_ROUTES_TL B
    where B.ROUTE_ID = T.ROUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ROUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ROUTE_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_ROUTES_TL SUBB, ENG_CHANGE_ROUTES_TL SUBT
    where SUBB.ROUTE_ID = SUBT.ROUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ROUTE_NAME <> SUBT.ROUTE_NAME
      or SUBB.ROUTE_DESCRIPTION <> SUBT.ROUTE_DESCRIPTION
      or (SUBB.ROUTE_DESCRIPTION is null and SUBT.ROUTE_DESCRIPTION is not null)
      or (SUBB.ROUTE_DESCRIPTION is not null and SUBT.ROUTE_DESCRIPTION is null)
  ));


  insert into ENG_CHANGE_ROUTES_TL (
    LAST_UPDATE_LOGIN,
    ROUTE_NAME,
    ROUTE_DESCRIPTION,
    ROUTE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.ROUTE_NAME,
    B.ROUTE_DESCRIPTION,
    B.ROUTE_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_ROUTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_ROUTES_TL T
    where T.ROUTE_ID = B.ROUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


END ADD_LANGUAGE;


PROCEDURE CLOSE_LOB(lob_loc IN OUT NOCOPY CLOB)
IS
BEGIN

  if (DBMS_LOB.isOpen(lob_loc) = 1) then
     DBMS_LOB.Close(lob_loc);
  end if;
  if (dbms_lob.isTemporary(lob_loc)=1) then
     DBMS_LOB.freeTemporary(lob_loc);
  end if;

END CLOSE_LOB ;

--
-- Don't forget calling CLOSAE_LOB after calling
-- this API if out param CLOB is not null
--
PROCEDURE CREATE_INSTANCE_SET_SQL
(
 p_Object_Values          IN VARCHAR2,
 x_User_Group_Flag        IN VARCHAR2,
 x_Complete_query         OUT NOCOPY CLOB
)
IS

  l_set_query VARCHAR2(3200);
  object_names VARCHAR2(2000);
  l_object_name VARCHAR2(2000);
  l_amount BINARY_INTEGER ;
  l_offset INTEGER ;
  text VARCHAR2(3200) ;
  l_loop_flag NUMBER ;


  -- Comment out
  -- cursor c_set_user_queries(p_object_name VARCHAR2) IS
  --   select
  --     'SELECT '  || a.OBJECT_ID || ' OBJECT_ID,'
  --                || b.menu_id|| ' ROLE_ID,'''
  --                || b.grantee_key||''' GRANTEE_KEY,'
  --                || a.PK1_COLUMN_NAME || ' PK1_VALUE,'
  --                || NVL(a.PK2_COLUMN_NAME ,-1) || ' PK2_VALUE,'
  --                || NVL(a.PK3_COLUMN_NAME ,-1) || ' PK3_VALUE,'
  --                || NVL(a.PK4_COLUMN_NAME ,-1) || ' PK4_VALUE,'
  --                || NVL(a.PK5_COLUMN_NAME ,-1) || ' PK5_VALUE '
  --     || ' FROM ' || a.database_object_name
  --     || ' WHERE ' || c.predicate query
  --   from
  --     fnd_object_instance_sets c,
  --     fnd_grants b,
  --     fnd_objects a
  --   where b.object_id=a.object_id
  --     and a.object_id=c.object_id
  --     and c.instance_set_id=b.instance_set_id
  --     and b.GRANTEE_ORIG_SYSTEM='HZ_PARTY'
  --     and b.instance_type='SET'
  --     and NVL(b.END_DATE,SYSDATE)>=SYSDATE
  --     and a.obj_name =p_object_name;

  -- Comment out
  -- cursor c_set_group_queries(p_object_name VARCHAR2) IS
  --   select
  --     'SELECT '  || a.OBJECT_ID || ' OBJECT_ID,'
  --                || b.menu_id|| ' ROLE_ID,'''
  --                || b.grantee_key||''' GRANTEE_KEY,'
  --                || a.PK1_COLUMN_NAME || ' PK1_VALUE,'
  --                || NVL(a.PK2_COLUMN_NAME ,-1) || ' PK2_VALUE,'
  --                || NVL(a.PK3_COLUMN_NAME ,-1) || ' PK3_VALUE,'
  --                || NVL(a.PK4_COLUMN_NAME ,-1) || ' PK4_VALUE,'
  --                || NVL(a.PK5_COLUMN_NAME ,-1) || ' PK5_VALUE '
  --     || ' FROM ' || a.database_object_name
  --     || ' WHERE ' || c.predicate query
  --   from
  --     fnd_object_instance_sets c,
  --     fnd_grants b,
  --     fnd_objects a
  --   where b.object_id=a.object_id
  --     and a.object_id=c.object_id
  --     and c.instance_set_id=b.instance_set_id
  --     and b.GRANTEE_ORIG_SYSTEM='HZ_GROUP'
  --     and b.instance_type='SET'
  --     and NVL(b.END_DATE,SYSDATE)>=SYSDATE
  --    and a.obj_name =p_object_name;


BEGIN

  -- Init Vars
  l_amount := 20 ;
  l_offset := 1 ;
  l_loop_flag := -1 ;

  -- This procedure obosolete
  /**********************************************************
  object_names:=p_object_values;

  if x_User_Group_Flag  = 'INSTANCE_SET_USER'
  then
    while l_loop_flag=-1
    loop
      IF INSTR(object_names,',') >0
      THEN
        l_object_name:=SUBSTR(object_names,0,INSTR(p_Object_Values,',')-1);
        object_names:=SUBSTR(object_names,INSTR(p_Object_Values,',')+1);
      ELSE
        l_object_name := object_names;
        l_loop_flag := 0;
      END IF;

      open c_set_user_queries(p_object_name => l_object_name);
      LOOP
        FETCH c_set_user_queries INTO l_set_query;
        exit when c_set_user_queries%NOTFOUND;
        if x_Complete_query is null
        then
          DBMS_LOB.createtemporary(x_Complete_query,true);
          DBMS_LOB.Trim ( lob_loc => x_Complete_query,newlen => 0 );
          DBMS_LOB.Write (  lob_loc  =>  x_Complete_query
              ,  amount   =>  Length (l_set_query)
              ,  offset   =>  l_offset
              ,  buffer   =>  l_set_query
              );
          -- insert into abc_table values('here in the null part');
        else
          l_set_query :=' UNION ALL ' || l_set_query;
          DBMS_LOB.WriteAppend (  lob_loc  =>  x_Complete_query
              ,  amount   =>  Length (l_set_query)
              ,  buffer   =>  l_set_query
              );
          -- insert into abc_table values('here in the not null');
        end if;
      END loop;
      close c_set_user_queries;
    END loop;

  --
  -- Starting x_User_Group_Flag  = 'INSTANCE_SET_GROUP'
  else
    while l_loop_flag=-1
    loop
      IF INSTR(object_names,',') >0
      THEN
        l_object_name:=SUBSTR(object_names,0,INSTR(p_Object_Values,',')-1);
        object_names:=SUBSTR(object_names,INSTR(p_Object_Values,',')+1);
      ELSE
        l_object_name := object_names;
        l_loop_flag := 0;
      END IF;

      open c_set_group_queries(p_object_name => l_object_name);
      LOOP
        FETCH c_set_group_queries INTO l_set_query;
        exit when c_set_group_queries%NOTFOUND;
        if x_Complete_query is null
        then
          DBMS_LOB.createtemporary(x_Complete_query,true);
          DBMS_LOB.Trim ( lob_loc => x_Complete_query,newlen => 0 );
          DBMS_LOB.Write (  lob_loc  =>  x_Complete_query
            ,  amount   =>  Length (l_set_query)
            ,  offset   =>  l_offset
            ,  buffer   =>  l_set_query
            );

          -- insert into abc_table values('here in the null part');

        else
          l_set_query :=' UNION ALL ' || l_set_query;

          DBMS_LOB.WriteAppend (  lob_loc  =>  x_Complete_query
              ,  amount   =>  Length (l_set_query)
              ,  buffer   =>  l_set_query
              );

          -- insert into abc_table values('here in the not null');

        end if;

      END loop;
      close c_set_group_queries;
    END loop;

  end if;
  *********************************************************************/

  --Append_VARCHAR_to_LOB(x_Complete_query,' ' ,'END');
  --DBMS_LOB.read(lob_loc => x_Complete_query,amount => l_amount ,offset => l_offset,buffer => text);

  --DBMS_OUTPUT.put_line(' Aman == >  ' ||'  ' ||text);


EXCEPTION
    WHEN OTHERS THEN
        -- closing and freeing the temp lob
        if (DBMS_LOB.isOpen(x_Complete_query) = 1) then
           DBMS_LOB.Close(x_Complete_query);
        end if;

        if (dbms_lob.isTemporary(x_Complete_query)=1) then
           DBMS_LOB.freeTemporary(x_Complete_query);
        end if;

        RAISE ;

END CREATE_INSTANCE_SET_SQL ;

/********************************************************************
* API Type      : Public APIs
* Purpose       : APIS to create Instance set query
*********************************************************************/




END Eng_Change_Route_Util ;

/
