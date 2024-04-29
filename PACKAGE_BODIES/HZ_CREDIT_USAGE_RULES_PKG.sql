--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_USAGE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_USAGE_RULES_PKG" AS
/* $Header: ARHCRURB.pls 115.5 2003/08/18 17:51:43 rajkrish ship $ */


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record
--             p_credit_usage_rule_set_id   rule set id
--             p_credit_usage_rule_id       primary key
--             p_usage_type                 usage type
--             p_user_code                  user code=currency_code
--             p_exclude_flag               exclude_flag = Y/N
--             p_include_all_flag           include all currencies Y/N
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_USAGE_RULES
--========================================================================
PROCEDURE Insert_row
( p_row_id IN OUT  NOCOPY           VARCHAR2
, p_credit_usage_rule_set_id   NUMBER
, p_credit_usage_rule_id       NUMBER
, p_usage_type                 VARCHAR2
, p_user_code                  VARCHAR2
, p_exclude_flag               VARCHAR2
, p_include_all_flag           VARCHAR2
, p_creation_date              DATE
, p_created_by                 NUMBER
, p_last_update_date           DATE
, p_last_updated_by            NUMBER
, p_last_update_login          NUMBER
, p_attribute_category         VARCHAR2
, p_attribute1                 VARCHAR2
, p_attribute2                 VARCHAR2
, p_attribute3                 VARCHAR2
, p_attribute4                 VARCHAR2
, p_attribute5                 VARCHAR2
, p_attribute6                 VARCHAR2
, p_attribute7                 VARCHAR2
, p_attribute8                 VARCHAR2
, p_attribute9                 VARCHAR2
, p_attribute10                VARCHAR2
, p_attribute11                VARCHAR2
, p_attribute12                VARCHAR2
, p_attribute13                VARCHAR2
, p_attribute14                VARCHAR2
, p_attribute15                VARCHAR2
)
IS

CURSOR usage_rule_csr IS
  SELECT
    rowid
  FROM
    HZ_CREDIT_USAGE_RULES
  WHERE credit_usage_rule_id=p_credit_usage_rule_id;

BEGIN

  INSERT INTO hz_credit_usage_rules
  ( credit_usage_rule_id
  , usage_type
  , user_code
  , exclude_flag
  , include_all_flag
  , credit_usage_rule_set_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
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
  )
  VALUES
  ( p_credit_usage_rule_id
  , p_usage_type
  , p_user_code
  , p_exclude_flag
  , p_include_all_flag
  , p_credit_usage_rule_set_id
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , null
  , null
  , null
  , null
  , p_attribute_category
  , p_attribute1
  , p_attribute2
  , p_attribute3
  , p_attribute4
  , p_attribute5
  , p_attribute6
  , p_attribute7
  , p_attribute8
  , p_attribute9
  , p_attribute10
  , p_attribute11
  , p_attribute12
  , p_attribute13
  , p_attribute14
  , p_attribute15
  );

  OPEN usage_rule_csr;
  FETCH  usage_rule_csr INTO p_row_id;
  IF (usage_rule_csr%NOTFOUND)
  THEN
    CLOSE usage_rule_csr;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE usage_rule_csr;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Insert_row');
    END IF;
    RAISE;

 END Insert_row;

--========================================================================
-- PROCEDURE : Lock_row              PUBLIC
-- PARAMETERS: p_row_id              ROWID of the current record
--             p_usage_type          usage type
--             p_user_code           user code=currency_code
--             p_exclude_flag        exclude_flag = Y/N
--             p_include_all_flag    include all currencies Y/N
-- COMMENT   : Procedure locks current record in the table HZ_CREDIT_USAGE_RULES.
--========================================================================
PROCEDURE Lock_row
( p_row_id                     VARCHAR2
, p_usage_type                 VARCHAR2
, p_user_code                  VARCHAR2
, p_exclude_flag               VARCHAR2
, p_include_all_flag           VARCHAR2
)
IS
  CURSOR usage_rule_csr
  IS
    SELECT *
    FROM HZ_CREDIT_USAGE_RULES
    WHERE ROWID=CHARTOROWID(p_row_id)
    FOR UPDATE OF user_code NOWAIT;

  recinfo usage_rule_csr%ROWTYPE;

BEGIN

  OPEN usage_rule_csr;
  FETCH usage_rule_csr INTO recinfo;
  IF (usage_rule_csr%NOTFOUND)
  THEN
    CLOSE usage_rule_csr;
    FND_MESSAGE.Set_name('FND', 'FORM_RECORD_DELETED');
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE usage_rule_csr;

  IF
    ((recinfo.usage_type=p_usage_type)
      OR (recinfo.usage_type is NULL AND p_usage_type is NULL))
    AND
    ((recinfo.user_code=p_user_code)
      OR (recinfo.user_code is NULL AND p_user_code is NULL))
    AND
    ((recinfo.exclude_flag=p_exclude_flag)
      OR (recinfo.exclude_flag is NULL AND p_exclude_flag is NULL))
    AND
    ((recinfo.include_all_flag=p_include_all_flag)
      OR (recinfo.include_all_flag is NULL AND p_include_all_flag is NULL))
  THEN
     NULL;
  ELSE
     FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.raise_exception;
  END IF;

END Lock_Row;


--========================================================================
-- PROCEDURE : Update_row             PUBLIC
-- PARAMETERS: p_row_id               ROWID of the current record
--             p_usage_type           usage type
--             p_user_code            user code=currency_code
--             p_exclude_flag         exclude_flag = Y/N
--             p_include_all_flag     include all currencies Y/N
--             p_last_update_date     date,when the record was updated
--             p_last_updated_by      userid of the person,who updated the record
-- COMMENT   : Procedure updates columns in the table HZ_CREDIT_USAGE_RULES
--             for the record with ROWID,passed as a parameter p_row_id.
--========================================================================
PROCEDURE Update_row
( p_row_id                     VARCHAR2
, p_usage_type                 VARCHAR2
, p_user_code                  VARCHAR2
, p_exclude_flag               VARCHAR2
, p_include_all_flag           VARCHAR2
, p_last_update_date           DATE
, p_last_updated_by            NUMBER
, p_attribute_category         VARCHAR2
, p_attribute1                 VARCHAR2
, p_attribute2                 VARCHAR2
, p_attribute3                 VARCHAR2
, p_attribute4                 VARCHAR2
, p_attribute5                 VARCHAR2
, p_attribute6                 VARCHAR2
, p_attribute7                 VARCHAR2
, p_attribute8                 VARCHAR2
, p_attribute9                 VARCHAR2
, p_attribute10                VARCHAR2
, p_attribute11                VARCHAR2
, p_attribute12                VARCHAR2
, p_attribute13                VARCHAR2
, p_attribute14                VARCHAR2
, p_attribute15                VARCHAR2
)
IS

BEGIN
  UPDATE HZ_CREDIT_USAGE_RULES
  SET
    usage_type=p_usage_type
   ,user_code=p_user_code
   ,exclude_flag=p_exclude_flag
   ,include_all_flag=p_include_all_flag
   ,last_update_date=p_last_update_date
   ,last_updated_by=p_last_updated_by
   , attribute_category =p_attribute_category
   , attribute1= p_attribute1
   , attribute2= p_attribute2
   , attribute3= p_attribute3
   , attribute4= p_attribute4
   , attribute5= p_attribute5
   , attribute6= p_attribute6
   , attribute7= p_attribute7
   , attribute8= p_attribute8
   , attribute9= p_attribute9
   , attribute10= p_attribute10
   , attribute11= p_attribute11
   , attribute12= p_attribute12
   , attribute13= p_attribute13
   , attribute14= p_attribute14
   , attribute15= p_attribute15
  WHERE ROWID=CHARTOROWID(p_row_id);


 IF (SQL%NOTFOUND)
  THEN
       RAISE NO_DATA_FOUND;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Update_row');
    END IF;
  RAISE;

  END Update_Row;

--========================================================================
-- PROCEDURE : Delete_row                   PUBLIC
-- PARAMETERS: p_credit_usage_rule_id       credit_usage_rule_id
-- COMMENT   : Procedure deletes record with credit_usage_rule_id from the
--             table HZ_CREDIT_USAGE_RULES.
--========================================================================
PROCEDURE Delete_row
( p_credit_usage_rule_id NUMBER
)
IS
BEGIN
  DELETE
  FROM HZ_CREDIT_USAGE_RULES
  WHERE credit_usage_rule_id=p_credit_usage_rule_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Delete_row');
    END IF;
  RAISE;

END Delete_row;

END HZ_CREDIT_USAGE_RULES_PKG;

/
