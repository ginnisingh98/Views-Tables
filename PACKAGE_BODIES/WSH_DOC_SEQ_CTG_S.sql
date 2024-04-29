--------------------------------------------------------
--  DDL for Package Body WSH_DOC_SEQ_CTG_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DOC_SEQ_CTG_S" AS
-- $Header: WSHVDOCB.pls 115.9 2002/11/12 02:04:50 nparikh ship $

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------

category_exists EXCEPTION;

-----------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-----------------------------------

    -- validate_category procedure raises the following user exceptions
    -----------------------------------------------------------------
    --  Exception          |  What it means
    -----------------------|-----------------------------------------
    --  category_exists    |  The category definition (combination
    --                     |  of location, document type, document
    --                     |  code) is not unique as it is either
    --                     |  identical to or is part of another
    --                     |  category definition that already exists
    -----------------------------------------------------------------

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DOC_SEQ_CTG_S';
--
PROCEDURE validate_category
  ( p_document_type     VARCHAR2
  , p_document_code     VARCHAR2
  , p_location_id       NUMBER
  , p_enabled_flag      VARCHAR2
  , p_rowid             VARCHAR2
  )
IS
  -- cursor to check that the combination of document_type, document_code
  -- and location is valid (not a duplicate and does not overlap any
  -- other existing category definition)
  CURSOR category_csr
  IS
  SELECT
    doc_sequence_category_id
  FROM
    wsh_doc_sequence_categories
  WHERE ((p_rowid IS NULL) OR (p_rowid <> rowid))
    AND document_type = p_document_type
    AND NVL(enabled_flag,'N') = 'Y'
    AND NVL(p_enabled_flag,'N') = 'Y'
    AND ((location_id = p_location_id AND document_code = p_document_code)
         OR
         (location_id = p_location_id AND document_code IS NULL)
	    OR
	    (location_id = p_location_id AND document_code IS NOT NULL
            AND p_document_code IS NULL)
         OR
	    (document_code = p_document_code AND location_id IS NOT NULL
	       AND (nvl(p_location_id,-99) = -99) )
         OR
	    ((nvl(location_id,-99) = -99) AND document_code = p_document_code)
         OR
         ((nvl(location_id,-99) = -99) AND document_code IS NULL)
	    OR
	    ((nvl(p_location_id,-99) = -99) AND p_document_code IS NULL));

  category_rec  category_csr%rowtype;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CATEGORY';
  --
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_CODE',P_DOCUMENT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ENABLED_FLAG',P_ENABLED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
  END IF;
  --
  OPEN category_csr;
  FETCH category_csr INTO category_rec;
  IF category_csr%FOUND
  THEN
    CLOSE category_csr;
    RAISE category_exists;
  END IF;
  CLOSE category_csr;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END;


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

PROCEDURE insert_row
  ( x_rowid                       IN OUT NOCOPY  VARCHAR2
  , x_doc_sequence_category_id    NUMBER
  , x_location_id                 NUMBER
  , x_document_type               VARCHAR2
  , x_document_code               VARCHAR2
  , x_application_id              VARCHAR2
  , x_category_code               VARCHAR2
  , x_name                        VARCHAR2
  , x_description                 VARCHAR2
  , x_prefix                      VARCHAR2
  , x_suffix                      VARCHAR2
  , x_delimiter                   VARCHAR2
  , x_enabled_flag                VARCHAR2
  , x_created_by                  NUMBER
  , x_creation_date               DATE
  , x_last_updated_by             NUMBER
  , x_last_update_date            DATE
  , x_last_update_login           NUMBER
  , x_program_application_id      NUMBER
  , x_program_id                  NUMBER
  , x_program_update_date         DATE
  , x_request_id                  NUMBER
  , x_attribute_category          VARCHAR2
  , x_attribute1                  VARCHAR2
  , x_attribute2                  VARCHAR2
  , x_attribute3                  VARCHAR2
  , x_attribute4                  VARCHAR2
  , x_attribute5                  VARCHAR2
  , x_attribute6                  VARCHAR2
  , x_attribute7                  VARCHAR2
  , x_attribute8                  VARCHAR2
  , x_attribute9                  VARCHAR2
  , x_attribute10                 VARCHAR2
  , x_attribute11                 VARCHAR2
  , x_attribute12                 VARCHAR2
  , x_attribute13                 VARCHAR2
  , x_attribute14                 VARCHAR2
  , x_attribute15                 VARCHAR2
)
IS

  -- cursor to check successful insert of the row based on primary key
  CURSOR insert_csr (p_doc_sequence_category_id NUMBER) IS
  SELECT
    rowid
  FROM
    wsh_doc_sequence_categories
  WHERE doc_sequence_category_id = p_doc_sequence_category_id;

  -- cursor selects a sequence for the primary key
  CURSOR sequence_csr IS
  SELECT wsh_doc_sequence_categories_s.nextval
  FROM dual;

  -- cursor selects a sequence for category code
  CURSOR category_code_csr IS
  SELECT wsh_doc_categories_s.nextval category_code
  FROM dual;

  l_doc_sequence_category_id NUMBER;
  l_category_code            wsh_doc_sequence_categories.category_code%type;
  category_code_rec          category_code_csr%rowtype;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
--
BEGIN

  ----------------------------------------------------
  -- First check if category definition exists      --
  -- in Shipping document definition repository.    --
  -- If invalid this will raise category_exists     --
  -- exception                                      --
  ----------------------------------------------------

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
        WSH_DEBUG_SV.log(l_module_name,'X_DOC_SEQUENCE_CATEGORY_ID',X_DOC_SEQUENCE_CATEGORY_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_LOCATION_ID',X_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_TYPE',X_DOCUMENT_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_CODE',X_DOCUMENT_CODE);
        WSH_DEBUG_SV.log(l_module_name,'X_APPLICATION_ID',X_APPLICATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_CATEGORY_CODE',X_CATEGORY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'X_NAME',X_NAME);
        WSH_DEBUG_SV.log(l_module_name,'X_DESCRIPTION',X_DESCRIPTION);
        WSH_DEBUG_SV.log(l_module_name,'X_PREFIX',X_PREFIX);
        WSH_DEBUG_SV.log(l_module_name,'X_SUFFIX',X_SUFFIX);
        WSH_DEBUG_SV.log(l_module_name,'X_DELIMITER',X_DELIMITER);
        WSH_DEBUG_SV.log(l_module_name,'X_ENABLED_FLAG',X_ENABLED_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'X_CREATED_BY',X_CREATED_BY);
        WSH_DEBUG_SV.log(l_module_name,'X_CREATION_DATE',X_CREATION_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATED_BY',X_LAST_UPDATED_BY);
        WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATE_DATE',X_LAST_UPDATE_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATE_LOGIN',X_LAST_UPDATE_LOGIN);
        WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_APPLICATION_ID',X_PROGRAM_APPLICATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_ID',X_PROGRAM_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_UPDATE_DATE',X_PROGRAM_UPDATE_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_REQUEST_ID',X_REQUEST_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE_CATEGORY',X_ATTRIBUTE_CATEGORY);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE1',X_ATTRIBUTE1);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE2',X_ATTRIBUTE2);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE3',X_ATTRIBUTE3);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE4',X_ATTRIBUTE4);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE5',X_ATTRIBUTE5);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE6',X_ATTRIBUTE6);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE7',X_ATTRIBUTE7);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE8',X_ATTRIBUTE8);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE9',X_ATTRIBUTE9);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE10',X_ATTRIBUTE10);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE11',X_ATTRIBUTE11);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE12',X_ATTRIBUTE12);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE13',X_ATTRIBUTE13);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE14',X_ATTRIBUTE14);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE15',X_ATTRIBUTE15);
    END IF;
    --
    validate_category ( x_document_type
                      , x_document_code
                      , x_location_id
		      , x_enabled_flag
		      , x_rowid );

  ----------------------------------------------------
  -- If success, create a new category.             --
  -- category_code is a varchar2(30) column and     --
  -- hence the sequence value will be truncated to  --
  -- 25 char and prefixed with Shipping shortname   --
  -- This may have to be replaced by a cleaner      --
  -- solution later                                 --
  ----------------------------------------------------

  OPEN category_code_csr;
  FETCH category_code_csr INTO category_code_rec;
  l_category_code :=  FND_GLOBAL.application_short_name||': '||
	              substr(to_char(category_code_rec.category_code),1,25);
  CLOSE category_code_csr;

  ----------------------------------------------------
  -- Next check if category definition exists       --
  -- in the FND document definition repository      --
  -- In case of failure FND API raises exception    --
  -- APP_EXCEPTIONS.application_exception           --
  -- which is passed to the calling program         --
  ----------------------------------------------------

  BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_APPLICATION_ID',x_application_id);
      WSH_DEBUG_SV.log(l_module_name,'CATEGORY CODE',l_category_code);
    END IF;

    FND_SEQ_CATEGORIES_PKG.check_unique_cat
      ( x_application_id => x_application_id
      , x_category_code  => l_category_code
      );
  EXCEPTION
    WHEN others THEN
      RAISE;
  END;

  OPEN sequence_csr;
  FETCH sequence_csr INTO l_doc_sequence_category_id;
  CLOSE sequence_csr;

  INSERT INTO wsh_doc_sequence_categories
  ( doc_sequence_category_id
  , location_id
  , document_type
  , document_code
  , application_id
  , category_code
  , prefix
  , suffix
  , delimiter
  , enabled_flag
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  ) VALUES (
    l_doc_sequence_category_id
  , x_location_id
  , x_document_type
  , x_document_code
  , x_application_id
  , l_category_code
  , x_prefix
  , x_suffix
  , x_delimiter
  , x_enabled_flag
  , x_created_by
  , x_creation_date
  , x_last_updated_by
  , x_last_update_date
  , x_last_update_login
  , x_program_application_id
  , x_program_id
  , x_program_update_date
  , x_request_id
  , x_attribute_category
  , x_attribute1
  , x_attribute2
  , x_attribute3
  , x_attribute4
  , x_attribute5
  , x_attribute6
  , x_attribute7
  , x_attribute8
  , x_attribute9
  , x_attribute10
  , x_attribute11
  , x_attribute12
  , x_attribute13
  , x_attribute14
  , x_attribute15 );

  OPEN insert_csr (l_doc_sequence_category_id);
  FETCH insert_csr INTO x_rowid;
  IF insert_csr%NOTFOUND
  THEN
    CLOSE insert_csr;
    RAISE no_data_found;
  END IF;

  CLOSE insert_csr;

  ----------------------------------------------------
  -- Once the category is successfully inserted     --
  -- insert a corresponding row in the FND document --
  -- repository by calling the FND API              --
  ----------------------------------------------------

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Call to Fnd_Seq_Categories X_APPLICATION_ID',x_application_id);
    WSH_DEBUG_SV.log(l_module_name,'X_CATEGORY_CODE',l_category_code);
    WSH_DEBUG_SV.log(l_module_name,'NAME',x_name);
    WSH_DEBUG_SV.log(l_module_name,'DESCRIPTION',x_description);
  END IF;

  FND_SEQ_CATEGORIES_PKG.insert_cat
    ( x_application_id    => x_application_id
    , x_category_code     => l_category_code
    , x_category_name     => x_name
    , x_description       => x_description
    , x_table_name        => 'WSH_DOCUMENT_INSTANCES'
    , x_last_updated_by   => x_last_updated_by
    , x_created_by        => x_created_by
    , x_last_update_login => x_last_update_login
    );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN category_exists THEN
    FND_MESSAGE.set_name('WSH','WSH_DOC_CATEGORY_EXISTS');
    APP_EXCEPTION.raise_exception;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CATEGORY_EXISTS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CATEGORY_EXISTS');
    END IF;
    --
END insert_row;

PROCEDURE update_row
  ( x_rowid                       VARCHAR2
  , x_doc_sequence_category_id    NUMBER
  , x_location_id                 NUMBER
  , x_document_type               VARCHAR2
  , x_document_code               VARCHAR2
  , x_application_id              VARCHAR2
  , x_category_code               VARCHAR2
  , x_name                        VARCHAR2
  , x_description                 VARCHAR2
  , x_prefix                      VARCHAR2
  , x_suffix                      VARCHAR2
  , x_delimiter                   VARCHAR2
  , x_enabled_flag                VARCHAR2
  , x_created_by                  NUMBER
  , x_creation_date               DATE
  , x_last_updated_by             NUMBER
  , x_last_update_date            DATE
  , x_last_update_login           NUMBER
  , x_program_application_id      NUMBER
  , x_program_id                  NUMBER
  , x_program_update_date         DATE
  , x_request_id                  NUMBER
  , x_attribute_category          VARCHAR2
  , x_attribute1                  VARCHAR2
  , x_attribute2                  VARCHAR2
  , x_attribute3                  VARCHAR2
  , x_attribute4                  VARCHAR2
  , x_attribute5                  VARCHAR2
  , x_attribute6                  VARCHAR2
  , x_attribute7                  VARCHAR2
  , x_attribute8                  VARCHAR2
  , x_attribute9                  VARCHAR2
  , x_attribute10                 VARCHAR2
  , x_attribute11                 VARCHAR2
  , x_attribute12                 VARCHAR2
  , x_attribute13                 VARCHAR2
  , x_attribute14                 VARCHAR2
  , x_attribute15                 VARCHAR2
)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
--
BEGIN

  ----------------------------------------------------
  -- First check if category definition exists      --
  -- in Shipping document definition repository.    --
  -- If invalid this will raise category_exists     --
  -- exception                                      --
  ----------------------------------------------------

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
        WSH_DEBUG_SV.log(l_module_name,'X_DOC_SEQUENCE_CATEGORY_ID',X_DOC_SEQUENCE_CATEGORY_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_LOCATION_ID',X_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_TYPE',X_DOCUMENT_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_CODE',X_DOCUMENT_CODE);
        WSH_DEBUG_SV.log(l_module_name,'X_APPLICATION_ID',X_APPLICATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_CATEGORY_CODE',X_CATEGORY_CODE);
        WSH_DEBUG_SV.log(l_module_name,'X_NAME',X_NAME);
        WSH_DEBUG_SV.log(l_module_name,'X_DESCRIPTION',X_DESCRIPTION);
        WSH_DEBUG_SV.log(l_module_name,'X_PREFIX',X_PREFIX);
        WSH_DEBUG_SV.log(l_module_name,'X_SUFFIX',X_SUFFIX);
        WSH_DEBUG_SV.log(l_module_name,'X_DELIMITER',X_DELIMITER);
        WSH_DEBUG_SV.log(l_module_name,'X_ENABLED_FLAG',X_ENABLED_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'X_CREATED_BY',X_CREATED_BY);
        WSH_DEBUG_SV.log(l_module_name,'X_CREATION_DATE',X_CREATION_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATED_BY',X_LAST_UPDATED_BY);
        WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATE_DATE',X_LAST_UPDATE_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATE_LOGIN',X_LAST_UPDATE_LOGIN);
        WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_APPLICATION_ID',X_PROGRAM_APPLICATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_ID',X_PROGRAM_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_UPDATE_DATE',X_PROGRAM_UPDATE_DATE);
        WSH_DEBUG_SV.log(l_module_name,'X_REQUEST_ID',X_REQUEST_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE_CATEGORY',X_ATTRIBUTE_CATEGORY);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE1',X_ATTRIBUTE1);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE2',X_ATTRIBUTE2);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE3',X_ATTRIBUTE3);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE4',X_ATTRIBUTE4);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE5',X_ATTRIBUTE5);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE6',X_ATTRIBUTE6);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE7',X_ATTRIBUTE7);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE8',X_ATTRIBUTE8);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE9',X_ATTRIBUTE9);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE10',X_ATTRIBUTE10);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE11',X_ATTRIBUTE11);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE12',X_ATTRIBUTE12);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE13',X_ATTRIBUTE13);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE14',X_ATTRIBUTE14);
        WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE15',X_ATTRIBUTE15);
    END IF;
    --
    validate_category ( x_document_type
                      , x_document_code
                      , x_location_id
		      , x_enabled_flag
                      , x_rowid );

  ------------------------------------------------------
  -- update the shipping document category repository --
  ------------------------------------------------------

  UPDATE wsh_doc_sequence_categories SET
    doc_sequence_category_id = x_doc_sequence_category_id
  , location_id = x_location_id
  , document_type = x_document_type
  , document_code = x_document_code
  , application_id = x_application_id
  , category_code = x_category_code
  , prefix = x_prefix
  , suffix = x_suffix
  , delimiter = x_delimiter
  , enabled_flag = x_enabled_flag
  , created_by = x_created_by
  , creation_date = x_creation_date
  , last_updated_by = x_last_updated_by
  , last_update_date = x_last_update_date
  , last_update_login = x_last_update_login
  , program_application_id = x_program_application_id
  , program_id = x_program_id
  , program_update_date  = x_program_update_date
  , request_id = x_request_id
  , attribute_category = x_attribute_category
  , attribute1 = x_attribute1
  , attribute2 = x_attribute2
  , attribute3 = x_attribute3
  , attribute4 = x_attribute4
  , attribute5 = x_attribute5
  , attribute6 = x_attribute6
  , attribute7 = x_attribute7
  , attribute8 = x_attribute8
  , attribute9 = x_attribute9
  , attribute10 = x_attribute10
  , attribute11 = x_attribute11
  , attribute12 = x_attribute12
  , attribute13 = x_attribute13
  , attribute14 = x_attribute14
  , attribute15 = x_attribute15
  WHERE rowid = x_rowid;
  IF sql%NOTFOUND
  THEN
    RAISE no_data_found;
  END IF;

  --------------------------------------------------
  -- update the AOL document category repository. --
  -- This inturn calls is_duplicat_cat function   --
  -- that does the necessary check ( this may be  --
  -- redundant because category definitions are   --
  -- not updateable in shipping doc seq form )    --
  --------------------------------------------------

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Call to Fnd_Seq_Categories X_APPLICATION_ID',x_application_id);
    WSH_DEBUG_SV.log(l_module_name,'X_CATEGORY_CODE',x_category_code);
    WSH_DEBUG_SV.log(l_module_name,'NAME',x_name);
    WSH_DEBUG_SV.log(l_module_name,'DESCRIPTION',x_description);
  END IF;
  --

  FND_SEQ_CATEGORIES_PKG.update_cat
    ( x_application_id
    , x_category_code
    , x_name
    , x_description
    , x_last_updated_by
    );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN category_exists THEN
    FND_MESSAGE.set_name('WSH','WSH_PACK_CATEGORY_EXISTS');
    APP_EXCEPTION.raise_exception;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CATEGORY_EXISTS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CATEGORY_EXISTS');
    END IF;
    --
END update_row;


PROCEDURE lock_row
  ( x_rowid                       VARCHAR2
  , x_doc_sequence_category_id    NUMBER
  , x_location_id                 NUMBER
  , x_document_type               VARCHAR2
  , x_document_code               VARCHAR2
  , x_application_id              VARCHAR2
  , x_category_code               VARCHAR2
  , x_prefix                      VARCHAR2
  , x_suffix                      VARCHAR2
  , x_delimiter                   VARCHAR2
  , x_enabled_flag                VARCHAR2
  , x_created_by                  NUMBER
  , x_creation_date               DATE
  , x_last_updated_by             NUMBER
  , x_last_update_date            DATE
  , x_last_update_login           NUMBER
  , x_program_application_id      NUMBER
  , x_program_id                  NUMBER
  , x_program_update_date         DATE
  , x_request_id                  NUMBER
  , x_attribute_category          VARCHAR2
  , x_attribute1                  VARCHAR2
  , x_attribute2                  VARCHAR2
  , x_attribute3                  VARCHAR2
  , x_attribute4                  VARCHAR2
  , x_attribute5                  VARCHAR2
  , x_attribute6                  VARCHAR2
  , x_attribute7                  VARCHAR2
  , x_attribute8                  VARCHAR2
  , x_attribute9                  VARCHAR2
  , x_attribute10                 VARCHAR2
  , x_attribute11                 VARCHAR2
  , x_attribute12                 VARCHAR2
  , x_attribute13                 VARCHAR2
  , x_attribute14                 VARCHAR2
  , x_attribute15                 VARCHAR2
)
IS
  counter NUMBER;
  CURSOR  lock_csr IS
    SELECT
      doc_sequence_category_id
    , location_id
    , document_type
    , document_code
    , application_id
    , category_code
    , prefix
    , suffix
    , delimiter
    , enabled_flag
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_application_id
    , program_id
    , program_update_date
    , request_id
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    FROM
      wsh_doc_sequence_categories
    WHERE rowid = x_rowid
    FOR UPDATE OF doc_sequence_category_id NOWAIT;
  lock_rec lock_csr%rowtype;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
  --
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
      WSH_DEBUG_SV.log(l_module_name,'X_DOC_SEQUENCE_CATEGORY_ID',X_DOC_SEQUENCE_CATEGORY_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_LOCATION_ID',X_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_TYPE',X_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_CODE',X_DOCUMENT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'X_APPLICATION_ID',X_APPLICATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_CATEGORY_CODE',X_CATEGORY_CODE);
      WSH_DEBUG_SV.log(l_module_name,'X_PREFIX',X_PREFIX);
      WSH_DEBUG_SV.log(l_module_name,'X_SUFFIX',X_SUFFIX);
      WSH_DEBUG_SV.log(l_module_name,'X_DELIMITER',X_DELIMITER);
      WSH_DEBUG_SV.log(l_module_name,'X_ENABLED_FLAG',X_ENABLED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_CREATED_BY',X_CREATED_BY);
      WSH_DEBUG_SV.log(l_module_name,'X_CREATION_DATE',X_CREATION_DATE);
      WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATED_BY',X_LAST_UPDATED_BY);
      WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATE_DATE',X_LAST_UPDATE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'X_LAST_UPDATE_LOGIN',X_LAST_UPDATE_LOGIN);
      WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_APPLICATION_ID',X_PROGRAM_APPLICATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_ID',X_PROGRAM_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_PROGRAM_UPDATE_DATE',X_PROGRAM_UPDATE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'X_REQUEST_ID',X_REQUEST_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE_CATEGORY',X_ATTRIBUTE_CATEGORY);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE1',X_ATTRIBUTE1);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE2',X_ATTRIBUTE2);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE3',X_ATTRIBUTE3);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE4',X_ATTRIBUTE4);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE5',X_ATTRIBUTE5);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE6',X_ATTRIBUTE6);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE7',X_ATTRIBUTE7);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE8',X_ATTRIBUTE8);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE9',X_ATTRIBUTE9);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE10',X_ATTRIBUTE10);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE11',X_ATTRIBUTE11);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE12',X_ATTRIBUTE12);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE13',X_ATTRIBUTE13);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE14',X_ATTRIBUTE14);
      WSH_DEBUG_SV.log(l_module_name,'X_ATTRIBUTE15',X_ATTRIBUTE15);
  END IF;
  --
  OPEN lock_csr;
  FETCH lock_csr INTO lock_rec;
  IF lock_csr%NOTFOUND
  THEN
    CLOSE lock_csr;
    FND_MESSAGE.set_name ('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.raise_exception;
  END IF;
  CLOSE lock_csr;
  -- verify the not null columns are identical
  IF (  lock_rec.doc_sequence_category_id = x_doc_sequence_category_id
    AND lock_rec.document_type = x_document_type
    AND lock_rec.application_id = x_application_id
    AND lock_rec.category_code = x_category_code
    AND lock_rec.created_by = x_created_by
    AND lock_rec.creation_date = x_creation_date
    AND lock_rec.last_updated_by = x_last_updated_by
    AND lock_rec.last_update_date = x_last_update_date
    -- verify the nullable columns are either identical or both null
    AND ((lock_rec.document_code = x_document_code)
	OR
	(lock_rec.document_code IS NULL AND x_document_code IS NULL))
    AND ((lock_rec.location_id = x_location_id)
	OR
	(lock_rec.location_id IS NULL AND x_location_id IS NULL))
    AND ((lock_rec.prefix = x_prefix)
        OR
        (lock_rec.prefix IS NULL AND x_prefix IS NULL))
    AND ((lock_rec.suffix = x_suffix)
        OR
        (lock_rec.suffix IS NULL AND x_suffix IS NULL))
    AND ((lock_rec.delimiter = x_delimiter)
        OR
        (lock_rec.delimiter IS NULL AND x_delimiter IS NULL))
    AND ((lock_rec.enabled_flag = x_enabled_flag)
        OR
        (lock_rec.enabled_flag IS NULL AND x_enabled_flag IS NULL))
    AND ((lock_rec.last_update_login = x_last_update_login)
        OR
        (lock_rec.last_update_login IS NULL AND x_last_update_login IS NULL))
    AND ((lock_rec.program_application_id = x_program_application_id)
        OR
        (lock_rec.program_application_id IS NULL
                                     AND x_program_application_id IS NULL))
    AND ((lock_rec.program_id = x_program_id)
        OR
        (lock_rec.program_id IS NULL AND x_program_id IS NULL))
    AND ((lock_rec.request_id = x_request_id)
        OR
        (lock_rec.request_id IS NULL AND x_request_id IS NULL))
    AND ((lock_rec.attribute_category = x_attribute_category)
        OR
        (lock_rec.attribute_category IS NULL AND x_attribute_category IS NULL))
    AND ((lock_rec.attribute1 = x_attribute1)
        OR
        (lock_rec.attribute1 IS NULL AND x_attribute1 IS NULL))
    AND ((lock_rec.attribute2 = x_attribute2)
        OR
        (lock_rec.attribute2 IS NULL AND x_attribute2 IS NULL))
    AND ((lock_rec.attribute3 = x_attribute3)
        OR
        (lock_rec.attribute3 IS NULL AND x_attribute3 IS NULL))
    AND ((lock_rec.attribute4 = x_attribute4)
        OR
        (lock_rec.attribute4 IS NULL AND x_attribute4 IS NULL))
    AND ((lock_rec.attribute5 = x_attribute5)
        OR
        (lock_rec.attribute5 IS NULL AND x_attribute5 IS NULL))
    AND ((lock_rec.attribute6 = x_attribute6)
        OR
        (lock_rec.attribute6 IS NULL AND x_attribute6 IS NULL))
    AND ((lock_rec.attribute7 = x_attribute7)
        OR
        (lock_rec.attribute7 IS NULL AND x_attribute7 IS NULL))
    AND ((lock_rec.attribute8 = x_attribute8)
        OR
        (lock_rec.attribute8 IS NULL AND x_attribute8 IS NULL))
    AND ((lock_rec.attribute9 = x_attribute9)
        OR
        (lock_rec.attribute9 IS NULL AND x_attribute9 IS NULL))
    AND ((lock_rec.attribute10 = x_attribute10)
        OR
        (lock_rec.attribute10 IS NULL AND x_attribute10 IS NULL))
    AND ((lock_rec.attribute11 = x_attribute11)
        OR
        (lock_rec.attribute11 IS NULL AND x_attribute11 IS NULL))
    AND ((lock_rec.attribute12 = x_attribute12)
        OR
        (lock_rec.attribute12 IS NULL AND x_attribute12 IS NULL))
    AND ((lock_rec.attribute13 = x_attribute13)
        OR
        (lock_rec.attribute13 IS NULL AND x_attribute13 IS NULL))
    AND ((lock_rec.attribute14 = x_attribute14)
        OR
        (lock_rec.attribute14 IS NULL AND x_attribute14 IS NULL))
    AND ((lock_rec.attribute15 = x_attribute15)
        OR
        (lock_rec.attribute15 IS NULL AND x_attribute15 IS NULL))
  )
  THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  ELSE
    FND_MESSAGE.set_name('FND','FORM_RECORD_CHANGED');
    APP_EXCEPTION.raise_exception;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END lock_row;

PROCEDURE delete_row ( x_rowid VARCHAR2 )
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
--
BEGIN
  -- currently document categories cannot be deleted.
  -- They can only be disabled  by setting the enabled_flag to 'N'
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
  END IF;
  --
  null;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END delete_row;

END wsh_doc_seq_ctg_s;

/
