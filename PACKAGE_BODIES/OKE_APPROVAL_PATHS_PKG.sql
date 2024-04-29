--------------------------------------------------------
--  DDL for Package Body OKE_APPROVAL_PATHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_APPROVAL_PATHS_PKG" AS
/* $Header: OKEAPVPB.pls 120.1 2005/05/27 16:02:31 appldev  $ */
  g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_approval_paths_pkg.';
--
-- Table Handler Procedures
--
PROCEDURE INSERT_ROW
( X_ROWID                   IN OUT NOCOPY VARCHAR2
, X_APPROVAL_PATH_ID        IN OUT NOCOPY NUMBER
, X_SIGNATURE_REQUIRED_FLAG IN     VARCHAR2
, X_SIGNATORY_ROLE_ID       IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_START_DATE_ACTIVE       IN     DATE
, X_END_DATE_ACTIVE         IN     DATE
, X_CREATION_DATE           IN     DATE
, X_CREATED_BY              IN     NUMBER
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_LAST_UPDATE_LOGIN       IN     NUMBER
, X_RECORD_VERSION_NUMBER   IN OUT NOCOPY NUMBER
) IS

CURSOR c IS
  SELECT ROWID
  FROM OKE_APPROVAL_PATHS
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;

BEGIN

  IF ( X_APPROVAL_PATH_ID IS NULL ) THEN
    SELECT OKE_APPROVAL_PATHS_S.NEXTVAL
    INTO   X_APPROVAL_PATH_ID
    FROM   DUAL;
  END IF;

  X_RECORD_VERSION_NUMBER := 1;

  INSERT INTO OKE_APPROVAL_PATHS
  ( APPROVAL_PATH_ID
  , SIGNATURE_REQUIRED_FLAG
  , SIGNATORY_ROLE_ID
  , RECORD_VERSION_NUMBER
  , START_DATE_ACTIVE
  , END_DATE_ACTIVE
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  ) VALUES
  ( X_APPROVAL_PATH_ID
  , X_SIGNATURE_REQUIRED_FLAG
  , X_SIGNATORY_ROLE_ID
  , X_RECORD_VERSION_NUMBER
  , X_START_DATE_ACTIVE
  , X_END_DATE_ACTIVE
  , X_CREATION_DATE
  , X_CREATED_BY
  , X_LAST_UPDATE_DATE
  , X_LAST_UPDATED_BY
  , X_LAST_UPDATE_LOGIN
  );

  INSERT INTO OKE_APPROVAL_PATHS_TL
  ( APPROVAL_PATH_ID
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , NAME
  , DESCRIPTION
  , LANGUAGE
  , SOURCE_LANG
  )
  SELECT X_APPROVAL_PATH_ID
  ,      X_CREATION_DATE
  ,      X_CREATED_BY
  ,      X_LAST_UPDATE_DATE
  ,      X_LAST_UPDATED_BY
  ,      X_LAST_UPDATE_LOGIN
  ,      X_NAME
  ,      X_DESCRIPTION
  ,      L.LANGUAGE_CODE
  ,      USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM OKE_APPROVAL_PATHS_TL T
    WHERE T.APPROVAL_PATH_ID = X_APPROVAL_PATH_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%notfound) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;


PROCEDURE LOCK_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_RECORD_VERSION_NUMBER   IN     NUMBER
) IS

CURSOR C IS
  SELECT RECORD_VERSION_NUMBER
  FROM OKE_APPROVAL_PATHS
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID
  FOR UPDATE OF APPROVAL_PATH_ID NOWAIT;
RecInfo c%rowtype;

BEGIN
  OPEN C;
  FETCH C INTO RecInfo;
  IF (c%notfound) THEN
    CLOSE c;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE c;
  IF (RecInfo.RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;

END LOCK_ROW;


PROCEDURE UPDATE_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_SIGNATURE_REQUIRED_FLAG IN     VARCHAR2
, X_SIGNATORY_ROLE_ID       IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_START_DATE_ACTIVE       IN     DATE
, X_END_DATE_ACTIVE         IN     DATE
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_LAST_UPDATE_LOGIN       IN     NUMBER
, X_RECORD_VERSION_NUMBER   OUT    NOCOPY NUMBER
) IS

CURSOR c IS
  SELECT RECORD_VERSION_NUMBER
  FROM OKE_APPROVAL_PATHS
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;

BEGIN

  UPDATE OKE_APPROVAL_PATHS
  SET SIGNATURE_REQUIRED_FLAG = X_SIGNATURE_REQUIRED_FLAG
  ,   SIGNATORY_ROLE_ID       = X_SIGNATORY_ROLE_ID
  ,   START_DATE_ACTIVE       = X_START_DATE_ACTIVE
  ,   END_DATE_ACTIVE         = X_END_DATE_ACTIVE
  ,   LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY         = X_LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN
  ,   RECORD_VERSION_NUMBER   = RECORD_VERSION_NUMBER + 1
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  OPEN c;
  FETCH c INTO X_RECORD_VERSION_NUMBER;
  IF (c%notfound) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  UPDATE OKE_APPROVAL_PATHS_TL
  SET NAME              = X_NAME
  ,   DESCRIPTION       = X_DESCRIPTION
  ,   LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY   = X_LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  ,   SOURCE_LANG       = USERENV('LANG')
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;


PROCEDURE DELETE_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
) IS
BEGIN

  DELETE FROM OKE_APPROVAL_PATHS_TL
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM OKE_APPROVAL_PATHS
  WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_ROW;


PROCEDURE LOAD_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_SIGNATURE_REQUIRED_FLAG IN     VARCHAR2
, X_SIGNATORY_ROLE_ID       IN     NUMBER
, X_START_DATE_ACTIVE       IN     DATE
, X_END_DATE_ACTIVE         IN     DATE
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_CUSTOM_MODE             IN     VARCHAR2
) IS

l_approval_path_id       NUMBER := X_APPROVAL_PATH_ID;
l_rowid                  VARCHAR2(30);
l_record_version_number  NUMBER;

db_luby    NUMBER;  -- entity owner in db
db_ludate  DATE;    -- entity update date in db

BEGIN

  BEGIN

    SELECT LAST_UPDATE_DATE , LAST_UPDATED_BY
    INTO   db_ludate , db_luby
    FROM   OKE_APPROVAL_PATHS
    WHERE  APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;

    --
    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is USER, db owner is ORACLE
    -- c. owners are the same, and file_date > db_date
    --
    IF ( FND_LOAD_UTIL.UPLOAD_TEST
         ( X_LAST_UPDATED_BY
         , X_LAST_UPDATE_DATE
         , db_luby
         , db_ludate
         , X_CUSTOM_MODE ) ) THEN

      UPDATE_ROW
      ( X_APPROVAL_PATH_ID        => l_approval_path_id
      , X_SIGNATURE_REQUIRED_FLAG => X_SIGNATURE_REQUIRED_FLAG
      , X_SIGNATORY_ROLE_ID       => X_SIGNATORY_ROLE_ID
      , X_NAME                    => X_NAME
      , X_DESCRIPTION             => X_DESCRIPTION
      , X_START_DATE_ACTIVE       => X_START_DATE_ACTIVE
      , X_END_DATE_ACTIVE         => X_END_DATE_ACTIVE
      , X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
      , X_LAST_UPDATED_BY         => X_LAST_UPDATED_BY
      , X_LAST_UPDATE_LOGIN       => NULL
      , X_RECORD_VERSION_NUMBER   => l_record_version_number
      );

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Record doesn't exist - insert in all cases
      INSERT_ROW
      ( X_ROWID                   => l_rowid
      , X_APPROVAL_PATH_ID        => l_approval_path_id
      , X_SIGNATURE_REQUIRED_FLAG => X_SIGNATURE_REQUIRED_FLAG
      , X_SIGNATORY_ROLE_ID       => X_SIGNATORY_ROLE_ID
      , X_NAME                    => X_NAME
      , X_DESCRIPTION             => X_DESCRIPTION
      , X_START_DATE_ACTIVE       => X_START_DATE_ACTIVE
      , X_END_DATE_ACTIVE         => X_END_DATE_ACTIVE
      , X_CREATION_DATE           => X_LAST_UPDATE_DATE
      , X_CREATED_BY              => X_LAST_UPDATED_BY
      , X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
      , X_LAST_UPDATED_BY         => X_LAST_UPDATED_BY
      , X_LAST_UPDATE_LOGIN       => NULL
      , X_RECORD_VERSION_NUMBER   => l_record_version_number
      );
  END;

  --
  -- If CUSTOM_MODE is FORCE, tramp all approval steps
  --
  IF ( X_CUSTOM_MODE = 'FORCE' ) THEN
    DELETE FROM OKE_APPROVAL_STEPS
    WHERE APPROVAL_PATH_ID = X_APPROVAL_PATH_ID;
  END IF;

END LOAD_ROW;


PROCEDURE TRANSLATE_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_CUSTOM_MODE             IN     VARCHAR2
) IS

db_luby    NUMBER;  -- entity owner in db
db_ludate  DATE;    -- entity update date in db

BEGIN

  SELECT LAST_UPDATE_DATE , LAST_UPDATED_BY
  INTO   db_ludate , db_luby
  FROM   OKE_APPROVAL_PATHS_TL
  WHERE  APPROVAL_PATH_ID = X_APPROVAL_PATH_ID
  AND    USERENV('LANG') = LANGUAGE;

  --
  -- Update record, honoring customization mode.
  -- Record should be updated only if:
  -- a. CUSTOM_MODE = FORCE, or
  -- b. file owner is USER, db owner is ORACLE
  -- c. owners are the same, and file_date > db_date
  --
  IF ( FND_LOAD_UTIL.UPLOAD_TEST
       ( X_LAST_UPDATED_BY
       , X_LAST_UPDATE_DATE
       , db_luby
       , db_ludate
       , X_CUSTOM_MODE ) ) THEN

    UPDATE OKE_APPROVAL_PATHS_TL
    SET    NAME             = X_NAME
    ,      DESCRIPTION      = X_DESCRIPTION
    ,      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE
    ,      LAST_UPDATED_BY  = X_LAST_UPDATED_BY
    ,      SOURCE_LANG      = USERENV('LANG')
    WHERE  APPROVAL_PATH_ID = X_APPROVAL_PATH_ID
    AND    USERENV('LANG') IN ( LANGUAGE , SOURCE_LANG );

  END IF;

END TRANSLATE_ROW;


PROCEDURE ADD_LANGUAGE
IS
BEGIN

  DELETE FROM OKE_APPROVAL_PATHS_TL T
  WHERE NOT EXISTS (
    SELECT NULL
    FROM OKE_APPROVAL_PATHS B
    WHERE B.APPROVAL_PATH_ID = T.APPROVAL_PATH_ID
  );

  UPDATE OKE_APPROVAL_PATHS_TL T SET
  ( NAME , DESCRIPTION ) = (
    SELECT B.NAME
    ,      B.DESCRIPTION
    FROM  OKE_APPROVAL_PATHS_TL B
    WHERE B.APPROVAL_PATH_ID = T.APPROVAL_PATH_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE ( T.APPROVAL_PATH_ID , T.LANGUAGE ) IN (
    SELECT SUBT.APPROVAL_PATH_ID
    ,      SUBT.LANGUAGE
    FROM OKE_APPROVAL_PATHS_TL SUBB
    ,    OKE_APPROVAL_PATHS_TL SUBT
    WHERE SUBB.APPROVAL_PATH_ID = SUBT.APPROVAL_PATH_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.NAME <> SUBT.NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION )
  );

  INSERT INTO OKE_APPROVAL_PATHS_TL
  ( APPROVAL_PATH_ID
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , NAME
  , DESCRIPTION
  , LANGUAGE
  , SOURCE_LANG
  )
  SELECT B.APPROVAL_PATH_ID
  ,      B.CREATION_DATE
  ,      B.CREATED_BY
  ,      B.LAST_UPDATE_DATE
  ,      B.LAST_UPDATED_BY
  ,      B.LAST_UPDATE_LOGIN
  ,      B.NAME
  ,      B.DESCRIPTION
  ,      L.LANGUAGE_CODE
  ,      B.SOURCE_LANG
  FROM OKE_APPROVAL_PATHS_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS (
    SELECT NULL
    FROM OKE_APPROVAL_PATHS_TL T
    WHERE T.APPROVAL_PATH_ID = B.APPROVAL_PATH_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE
  );

END ADD_LANGUAGE;


--
-- Utility Functions and Procedures
--

--
-- Approval_Steps returns a semi-colon separated list that is used
-- to cache the approval hierarchy in the beginnin of the aproval
-- process.  The cached hierarchy should be stored as an WF item
-- attribute and can be interpreted by the Next_Approval_Step()
-- procedure
--
FUNCTION Approval_Steps
( ApprovalPath         IN  NUMBER
) RETURN VARCHAR2 IS

CURSOR a IS
  SELECT approval_sequence || ',' || approver_role_id || ';' approval_step
  FROM   oke_approval_steps
  WHERE  approval_path_id = ApprovalPath
  ORDER BY approval_sequence ASC;
arec   a%rowtype;

steps VARCHAR2(4000);

BEGIN

  steps := ';';
  FOR arec IN a LOOP
    steps := steps || arec.approval_step;
  END LOOP;
  RETURN ( steps );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( ';' );

END Approval_Steps;


--
-- Next_Approval_Step returns the next approval step based on the
-- approval steps cached at the beginning of the approval process
--
PROCEDURE Next_Approval_Step
( ApprovalSteps        IN  VARCHAR2
, LastApprovalSeq      IN  NUMBER
, ApprovalSeq          OUT NOCOPY NUMBER
, ApproverRole         OUT NOCOPY NUMBER
) IS
l_api_name                   CONSTANT VARCHAR2(30) := 'Next_Approval_Step';
i         NUMBER;
s         NUMBER;
e         NUMBER;
NextStep  VARCHAR2(30);

BEGIN

  IF ( LastApprovalSeq = 0 ) THEN
    s := 2;
    e := instr( substr( ApprovalSteps , s , 4000 ) , ';' ) - 1;
  ELSE
    i := instr( ApprovalSteps , ';' || LastApprovalSeq || ',' );
    s := instr( substr( ApprovalSteps , i+1 , 4000 ) , ';' ) + i + 1;
    e := instr( substr( ApprovalSteps , s , 4000 ) , ';' ) - 1;
  END IF;

  NextStep := substr( ApprovalSteps , s , e );

  ApprovalSeq := to_number( substr( NextStep , 1 , instr( NextStep , ',' ) - 1) );
  ApproverRole := to_number( substr( NextStep , instr( NextStep , ',' ) + 1
                           , length( NextStep ) - 2 ) );

 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'ApprovalSteps = ' || ApprovalSteps);
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'i = ' || i);
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'s = ' || s);
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'e = ' || e);
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'Next Step = ' || NextStep);
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'Next Seq  = ' || ApprovalSeq);
     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,g_module||l_api_name,'Next Role = ' || ApproverRole);
 END IF;

END Next_Approval_Step;


END OKE_APPROVAL_PATHS_PKG;

/
