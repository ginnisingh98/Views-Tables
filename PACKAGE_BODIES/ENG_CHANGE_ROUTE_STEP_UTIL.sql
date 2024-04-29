--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ROUTE_STEP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ROUTE_STEP_UTIL" AS
/* $Header: ENGUSTPB.pls 115.5 2004/05/27 19:06:37 mkimizuk ship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'Eng_Change_Route_Step_Util' ;

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


     -- Set Defualt debug file name
     IF g_debug_filename IS NULL THEN
         g_debug_filename := 'Eng_Change_Route_Step_Util.log' ;
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
* API Type      : Private Copy Steps APIs
* Purpose       : Those APIs are private to Copy Steps
*********************************************************************/
PROCEDURE COPY_STEPS (
  P_FROM_ROUTE_ID  IN NUMBER ,
  P_TO_ROUTE_ID    IN NUMBER ,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
)
IS

  cursor c is select
      STEP_ID,
      ROUTE_ID,
      STEP_SEQ_NUM,
      ADHOC_STEP_FLAG,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      WF_PROCESS_NAME,
      CONDITION_TYPE_CODE,
      TIMEOUT_OPTION,
      STEP_STATUS_CODE,
      STEP_START_DATE,
      STEP_END_DATE,
      REQUIRED_RELATIVE_DAYS,
      REQUIRED_DATE,
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
      ORIGINAL_SYSTEM_REFERENCE,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ASSIGNMENT_CODE,
      INSTRUCTION
    from ENG_CHANGE_ROUTE_STEPS_VL
    where ROUTE_ID = P_FROM_ROUTE_ID ;

    -- No Need to Lock
    -- for update of STEP_ID nowait;

  -- General variables
  l_fnd_user_id        NUMBER ;
  l_fnd_login_id       NUMBER ;
  l_language           VARCHAR2(4) ;
  l_rowid              ROWID;

  l_step_id            NUMBER ;


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

    --  Get Next Sequence Value for ROUTE_ID
    SELECT ENG_CHANGE_ROUTE_STEPS_S.NEXTVAL  into l_step_id
    FROM DUAL;

    INSERT_ROW (
    X_ROWID                     => l_rowid,
    X_STEP_ID                   => l_step_id ,
    X_ROUTE_ID                  => P_TO_ROUTE_ID ,
    X_STEP_SEQ_NUM              => recinfo.STEP_SEQ_NUM,
    X_ADHOC_STEP_FLAG           => recinfo.ADHOC_STEP_FLAG,
    X_WF_ITEM_TYPE              => recinfo.WF_ITEM_TYPE,
    X_WF_ITEM_KEY               => recinfo.WF_ITEM_KEY,
    X_WF_PROCESS_NAME           => recinfo.WF_PROCESS_NAME,
    X_CONDITION_TYPE_CODE       => recinfo.CONDITION_TYPE_CODE,
    X_TIMEOUT_OPTION            => recinfo.TIMEOUT_OPTION,
    X_STEP_STATUS_CODE          => 'NOT_STARTED' ,
    X_STEP_START_DATE           => NULL ,
    X_STEP_END_DATE             => NULL ,
    X_REQUIRED_RELATIVE_DAYS    => recinfo.REQUIRED_RELATIVE_DAYS,
    X_REQUIRED_DATE             => NULL,
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
    X_ORIGINAL_SYSTEM_REFERENCE => recinfo.ORIGINAL_SYSTEM_REFERENCE,
    X_INSTRUCTION               => recinfo.INSTRUCTION,
    X_CREATION_DATE             => SYSDATE,
    X_CREATED_BY                => l_fnd_user_id,
    X_LAST_UPDATE_DATE          => SYSDATE,
    X_LAST_UPDATED_BY           => l_fnd_user_id,
    X_LAST_UPDATE_LOGIN         => l_fnd_login_id,
    X_PROGRAM_ID                => recinfo.PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID    => recinfo.PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE       => recinfo.PROGRAM_UPDATE_DATE,
    X_ASSIGNMENT_CODE           => recinfo.ASSIGNMENT_CODE
    ) ;

    --
    --
    -- Call People's Copy Row Procedures
    --
    Eng_Change_Route_People_Util.COPY_PEOPLE (
       P_FROM_STEP_ID  => recinfo.STEP_ID,
       P_TO_STEP_ID    => l_step_id ,
       P_USER_ID       => l_fnd_user_id ,
       P_API_CALLER    => P_API_CALLER
    ) ;

  end loop;


END COPY_STEPS ;




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
  X_ROWID                      IN OUT NOCOPY VARCHAR2,
  X_STEP_ID                    IN NUMBER,
  X_ROUTE_ID                   IN NUMBER,
  X_STEP_SEQ_NUM               IN NUMBER,
  X_ADHOC_STEP_FLAG            IN VARCHAR2,
  X_WF_ITEM_TYPE               IN VARCHAR2,
  X_WF_ITEM_KEY                IN VARCHAR2,
  X_WF_PROCESS_NAME            IN VARCHAR2,
  X_CONDITION_TYPE_CODE        IN VARCHAR2,
  X_TIMEOUT_OPTION             IN VARCHAR2,
  X_STEP_STATUS_CODE           IN VARCHAR2,
  X_STEP_START_DATE            IN DATE,
  X_STEP_END_DATE              IN DATE,
  X_REQUIRED_RELATIVE_DAYS     IN NUMBER,
  X_REQUIRED_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
  X_ATTRIBUTE1                 IN VARCHAR2,
  X_ATTRIBUTE2                 IN VARCHAR2,
  X_ATTRIBUTE3                 IN VARCHAR2,
  X_ATTRIBUTE4                 IN VARCHAR2,
  X_ATTRIBUTE5                 IN VARCHAR2,
  X_ATTRIBUTE6                 IN VARCHAR2,
  X_ATTRIBUTE7                 IN VARCHAR2,
  X_ATTRIBUTE8                 IN VARCHAR2,
  X_ATTRIBUTE9                 IN VARCHAR2,
  X_ATTRIBUTE10                IN VARCHAR2,
  X_ATTRIBUTE11                IN VARCHAR2,
  X_ATTRIBUTE12                IN VARCHAR2,
  X_ATTRIBUTE13                IN VARCHAR2,
  X_ATTRIBUTE14                IN VARCHAR2,
  X_ATTRIBUTE15                IN VARCHAR2,
  X_REQUEST_ID                 IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE  IN VARCHAR2,
  X_INSTRUCTION                IN VARCHAR2,
  X_CREATION_DATE              IN DATE,
  X_CREATED_BY                 IN NUMBER,
  X_LAST_UPDATE_DATE           IN DATE,
  X_LAST_UPDATED_BY            IN NUMBER,
  X_LAST_UPDATE_LOGIN          IN NUMBER,
  X_PROGRAM_ID                 IN NUMBER,
  X_PROGRAM_APPLICATION_ID     IN NUMBER,
  X_PROGRAM_UPDATE_DATE        IN DATE,
  X_ASSIGNMENT_CODE            IN VARCHAR2
)
IS

  CURSOR C IS select ROWID from ENG_CHANGE_ROUTE_STEPS
    where STEP_ID = X_STEP_ID
    ;

BEGIN

  insert into ENG_CHANGE_ROUTE_STEPS (
    STEP_ID,
    ROUTE_ID,
    STEP_SEQ_NUM,
    ADHOC_STEP_FLAG,
    WF_ITEM_TYPE,
    WF_ITEM_KEY,
    WF_PROCESS_NAME,
    CONDITION_TYPE_CODE,
    TIMEOUT_OPTION,
    STEP_STATUS_CODE,
    STEP_START_DATE,
    STEP_END_DATE,
    REQUIRED_RELATIVE_DAYS,
    REQUIRED_DATE,
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
    ORIGINAL_SYSTEM_REFERENCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ASSIGNMENT_CODE
  ) values (
    X_STEP_ID,
    X_ROUTE_ID,
    X_STEP_SEQ_NUM,
    X_ADHOC_STEP_FLAG,
    X_WF_ITEM_TYPE,
    X_WF_ITEM_KEY,
    X_WF_PROCESS_NAME,
    X_CONDITION_TYPE_CODE,
    X_TIMEOUT_OPTION,
    X_STEP_STATUS_CODE,
    X_STEP_START_DATE,
    X_STEP_END_DATE,
    X_REQUIRED_RELATIVE_DAYS,
    X_REQUIRED_DATE,
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
    X_ORIGINAL_SYSTEM_REFERENCE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    X_ASSIGNMENT_CODE
  );

  insert into ENG_CHANGE_ROUTE_STEPS_TL (
    STEP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    INSTRUCTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_STEP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_INSTRUCTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_ROUTE_STEPS_TL T
    where T.STEP_ID = X_STEP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW ;

PROCEDURE LOCK_ROW (
  X_STEP_ID                    IN NUMBER,
  X_ROUTE_ID                   IN NUMBER,
  X_STEP_SEQ_NUM               IN NUMBER,
  X_ADHOC_STEP_FLAG            IN VARCHAR2,
  X_WF_ITEM_TYPE               IN VARCHAR2,
  X_WF_ITEM_KEY                IN VARCHAR2,
  X_WF_PROCESS_NAME            IN VARCHAR2,
  X_CONDITION_TYPE_CODE        IN VARCHAR2,
  X_TIMEOUT_OPTION             IN VARCHAR2,
  X_STEP_STATUS_CODE           IN VARCHAR2,
  X_STEP_START_DATE            IN DATE,
  X_STEP_END_DATE              IN DATE,
  X_REQUIRED_RELATIVE_DAYS     IN NUMBER,
  X_REQUIRED_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
  X_ATTRIBUTE1                 IN VARCHAR2,
  X_ATTRIBUTE2                 IN VARCHAR2,
  X_ATTRIBUTE3                 IN VARCHAR2,
  X_ATTRIBUTE4                 IN VARCHAR2,
  X_ATTRIBUTE5                 IN VARCHAR2,
  X_ATTRIBUTE6                 IN VARCHAR2,
  X_ATTRIBUTE7                 IN VARCHAR2,
  X_ATTRIBUTE8                 IN VARCHAR2,
  X_ATTRIBUTE9                 IN VARCHAR2,
  X_ATTRIBUTE10                IN VARCHAR2,
  X_ATTRIBUTE11                IN VARCHAR2,
  X_ATTRIBUTE12                IN VARCHAR2,
  X_ATTRIBUTE13                IN VARCHAR2,
  X_ATTRIBUTE14                IN VARCHAR2,
  X_ATTRIBUTE15                IN VARCHAR2,
  X_REQUEST_ID                 IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE  IN VARCHAR2,
  X_INSTRUCTION                IN VARCHAR2,
  X_PROGRAM_ID                 IN NUMBER,
  X_PROGRAM_APPLICATION_ID     IN NUMBER,
  X_PROGRAM_UPDATE_DATE        IN DATE,
  X_ASSIGNMENT_CODE            IN VARCHAR2
)
IS

  cursor c is select
      ROUTE_ID,
      STEP_SEQ_NUM,
      ADHOC_STEP_FLAG,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      WF_PROCESS_NAME,
      CONDITION_TYPE_CODE,
      TIMEOUT_OPTION,
      STEP_STATUS_CODE,
      STEP_START_DATE,
      STEP_END_DATE,
      REQUIRED_RELATIVE_DAYS,
      REQUIRED_DATE,
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
      ORIGINAL_SYSTEM_REFERENCE,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ASSIGNMENT_CODE
    from ENG_CHANGE_ROUTE_STEPS
    where STEP_ID = X_STEP_ID
    for update of STEP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      INSTRUCTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_ROUTE_STEPS_TL
    where STEP_ID = X_STEP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STEP_ID nowait;

BEGIN

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ROUTE_ID = X_ROUTE_ID)
      AND (recinfo.STEP_SEQ_NUM = X_STEP_SEQ_NUM)
      AND (recinfo.ADHOC_STEP_FLAG = X_ADHOC_STEP_FLAG)
      AND ((recinfo.WF_ITEM_TYPE = X_WF_ITEM_TYPE)
           OR ((recinfo.WF_ITEM_TYPE is null) AND (X_WF_ITEM_TYPE is null)))
      AND ((recinfo.WF_ITEM_KEY = X_WF_ITEM_KEY)
           OR ((recinfo.WF_ITEM_KEY is null) AND (X_WF_ITEM_KEY is null)))
      AND ((recinfo.WF_PROCESS_NAME = X_WF_PROCESS_NAME)
           OR ((recinfo.WF_PROCESS_NAME is null) AND (X_WF_PROCESS_NAME is null)))
      AND (recinfo.CONDITION_TYPE_CODE = X_CONDITION_TYPE_CODE)
      AND ((recinfo.TIMEOUT_OPTION = X_TIMEOUT_OPTION)
           OR ((recinfo.TIMEOUT_OPTION is null) AND (X_TIMEOUT_OPTION is null)))
      AND ((recinfo.STEP_STATUS_CODE = X_STEP_STATUS_CODE)
           OR ((recinfo.STEP_STATUS_CODE is null) AND (X_STEP_STATUS_CODE is null)))
      AND ((recinfo.STEP_START_DATE = X_STEP_START_DATE)
           OR ((recinfo.STEP_START_DATE is null) AND (X_STEP_START_DATE is null)))
      AND ((recinfo.STEP_END_DATE = X_STEP_END_DATE)
           OR ((recinfo.STEP_END_DATE is null) AND (X_STEP_END_DATE is null)))
      AND ((recinfo.REQUIRED_RELATIVE_DAYS = X_REQUIRED_RELATIVE_DAYS)
           OR ((recinfo.REQUIRED_RELATIVE_DAYS is null) AND (X_REQUIRED_RELATIVE_DAYS is null)))
      AND ((recinfo.REQUIRED_DATE = X_REQUIRED_DATE)
           OR ((recinfo.REQUIRED_DATE is null) AND (X_REQUIRED_DATE is null)))
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
      AND ((recinfo.ASSIGNMENT_CODE = X_ASSIGNMENT_CODE)
           OR ((recinfo.ASSIGNMENT_CODE is null) AND (X_ASSIGNMENT_CODE is null)))
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
      if (    ((tlinfo.INSTRUCTION = X_INSTRUCTION)
               OR ((tlinfo.INSTRUCTION is null) AND (X_INSTRUCTION is null)))
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
  X_STEP_ID                    IN NUMBER,
  X_ROUTE_ID                   IN NUMBER,
  X_STEP_SEQ_NUM               IN NUMBER,
  X_ADHOC_STEP_FLAG            IN VARCHAR2,
  X_WF_ITEM_TYPE               IN VARCHAR2,
  X_WF_ITEM_KEY                IN VARCHAR2,
  X_WF_PROCESS_NAME            IN VARCHAR2,
  X_CONDITION_TYPE_CODE        IN VARCHAR2,
  X_TIMEOUT_OPTION             IN VARCHAR2,
  X_STEP_STATUS_CODE           IN VARCHAR2,
  X_STEP_START_DATE            IN DATE,
  X_STEP_END_DATE              IN DATE,
  X_REQUIRED_RELATIVE_DAYS     IN NUMBER,
  X_REQUIRED_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
  X_ATTRIBUTE1                 IN VARCHAR2,
  X_ATTRIBUTE2                 IN VARCHAR2,
  X_ATTRIBUTE3                 IN VARCHAR2,
  X_ATTRIBUTE4                 IN VARCHAR2,
  X_ATTRIBUTE5                 IN VARCHAR2,
  X_ATTRIBUTE6                 IN VARCHAR2,
  X_ATTRIBUTE7                 IN VARCHAR2,
  X_ATTRIBUTE8                 IN VARCHAR2,
  X_ATTRIBUTE9                 IN VARCHAR2,
  X_ATTRIBUTE10                IN VARCHAR2,
  X_ATTRIBUTE11                IN VARCHAR2,
  X_ATTRIBUTE12                IN VARCHAR2,
  X_ATTRIBUTE13                IN VARCHAR2,
  X_ATTRIBUTE14                IN VARCHAR2,
  X_ATTRIBUTE15                IN VARCHAR2,
  X_REQUEST_ID                 IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE  IN VARCHAR2,
  X_INSTRUCTION                IN VARCHAR2,
  X_LAST_UPDATE_DATE           IN DATE,
  X_LAST_UPDATED_BY            IN NUMBER,
  X_LAST_UPDATE_LOGIN          IN NUMBER,
  X_PROGRAM_ID                 IN NUMBER,
  X_PROGRAM_APPLICATION_ID     IN NUMBER,
  X_PROGRAM_UPDATE_DATE        IN DATE,
  X_ASSIGNMENT_CODE            IN VARCHAR2
)
IS

BEGIN

  update ENG_CHANGE_ROUTE_STEPS set
    ROUTE_ID = X_ROUTE_ID,
    STEP_SEQ_NUM = X_STEP_SEQ_NUM,
    ADHOC_STEP_FLAG = X_ADHOC_STEP_FLAG,
    WF_ITEM_TYPE = X_WF_ITEM_TYPE,
    WF_ITEM_KEY = X_WF_ITEM_KEY,
    WF_PROCESS_NAME = X_WF_PROCESS_NAME,
    CONDITION_TYPE_CODE = X_CONDITION_TYPE_CODE,
    TIMEOUT_OPTION = X_TIMEOUT_OPTION,
    STEP_STATUS_CODE = X_STEP_STATUS_CODE,
    STEP_START_DATE = X_STEP_START_DATE,
    STEP_END_DATE = X_STEP_END_DATE,
    REQUIRED_RELATIVE_DAYS = X_REQUIRED_RELATIVE_DAYS,
    REQUIRED_DATE = X_REQUIRED_DATE,
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
    ORIGINAL_SYSTEM_REFERENCE = X_ORIGINAL_SYSTEM_REFERENCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    ASSIGNMENT_CODE = X_ASSIGNMENT_CODE
  where STEP_ID = X_STEP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_ROUTE_STEPS_TL set
    INSTRUCTION = X_INSTRUCTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STEP_ID = X_STEP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;


END UPDATE_ROW ;

PROCEDURE DELETE_ROW (
  X_STEP_ID                    IN NUMBER
)
IS

BEGIN

  delete from ENG_CHANGE_ROUTE_STEPS_TL
  where STEP_ID = X_STEP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_ROUTE_STEPS
  where STEP_ID = X_STEP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


END DELETE_ROW ;


PROCEDURE ADD_LANGUAGE
IS

BEGIN

  delete from ENG_CHANGE_ROUTE_STEPS_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_ROUTE_STEPS B
    where B.STEP_ID = T.STEP_ID
    );

  update ENG_CHANGE_ROUTE_STEPS_TL T set (
      INSTRUCTION
    ) = (select
      B.INSTRUCTION
    from ENG_CHANGE_ROUTE_STEPS_TL B
    where B.STEP_ID = T.STEP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STEP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STEP_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_ROUTE_STEPS_TL SUBB, ENG_CHANGE_ROUTE_STEPS_TL SUBT
    where SUBB.STEP_ID = SUBT.STEP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.INSTRUCTION <> SUBT.INSTRUCTION
      or (SUBB.INSTRUCTION is null and SUBT.INSTRUCTION is not null)
      or (SUBB.INSTRUCTION is not null and SUBT.INSTRUCTION is null)
  ));


  insert into ENG_CHANGE_ROUTE_STEPS_TL (
    STEP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    INSTRUCTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STEP_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.INSTRUCTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_ROUTE_STEPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_ROUTE_STEPS_TL T
    where T.STEP_ID = B.STEP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


END ADD_LANGUAGE ;


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


END Eng_Change_Route_Step_Util ;

/
