--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_PROFILE_AMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_PROFILE_AMTS_PKG" AS
/* $Header: ARHCRPAB.pls 115.3 2003/08/16 02:00:47 rajkrish ship $ */

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record in
--                                          table HZ_CREDIT_PROFILE_AMTS
--             p_credit_profile_amt_id      primary key
--             p_credit_profile_id          credit_profile_id
--             p_currency_code              currency_code
--             p_trx_credit_limit           trx_credit_limit
--             p_overall_credit_limit       overall_credit_limit
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
--             p_last_update_date
--             p_last_updated_by
--             p_last_update_login
--
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Insert_row
( p_row_id             OUT NOCOPY VARCHAR2
, p_credit_profile_amt_id  NUMBER
, p_credit_profile_id      NUMBER
, p_currency_code          VARCHAR2
, p_trx_credit_limit       NUMBER
, p_overall_credit_limit   NUMBER
, p_creation_date          DATE
, p_created_by             NUMBER
, p_last_update_date       DATE
, p_last_updated_by        NUMBER
, p_last_update_login      NUMBER
, p_attribute_category     VARCHAR2
, p_attribute1             VARCHAR2
, p_attribute2             VARCHAR2
, p_attribute3             VARCHAR2
, p_attribute4             VARCHAR2
, p_attribute5             VARCHAR2
, p_attribute6             VARCHAR2
, p_attribute7             VARCHAR2
, p_attribute8             VARCHAR2
, p_attribute9             VARCHAR2
, p_attribute10            VARCHAR2
, p_attribute11            VARCHAR2
, p_attribute12            VARCHAR2
, p_attribute13            VARCHAR2
, p_attribute14            VARCHAR2
, p_attribute15            VARCHAR2
)
IS

CURSOR prof_amt_csr IS
  SELECT
    rowid
  FROM
    hz_credit_profile_amts
  WHERE credit_profile_amt_id=p_credit_profile_amt_id;

BEGIN

  INSERT INTO hz_credit_profile_amts
  ( credit_profile_amt_id
  , credit_profile_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , currency_code
  , trx_credit_limit
  , overall_credit_limit
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
  ( p_credit_profile_amt_id
  , p_credit_profile_id
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , null
  , null
  , null
  , null
  , p_currency_code
  , p_trx_credit_limit
  , p_overall_credit_limit
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

  OPEN prof_amt_csr;
  FETCH  prof_amt_csr INTO p_row_id;
  IF (prof_amt_csr%NOTFOUND)
  THEN
    CLOSE prof_amt_csr;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE prof_amt_csr;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Insert_row');
    END IF;
    RAISE;

 END Insert_row;

--========================================================================
-- PROCEDURE : Lock_row                     PUBLIC
-- PARAMETERS: p_row_id                     rowid
--             p_currency_code              currency-code
--             p_trx_credit_limit           trx_credit_limit
--             p_overall_credit_limit       overall_credit_limit
--             p_last_update_date
-- COMMENT   : Procedure locks record in the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Lock_row
( p_row_id               VARCHAR2
, p_currency_code        VARCHAR2
, p_trx_credit_limit     NUMBER
, p_overall_credit_limit NUMBER
, p_last_update_date     DATE
)
IS
  CURSOR prof_csr
  IS
    SELECT *
    FROM hz_credit_profile_amts
    WHERE ROWID=CHARTOROWID(p_row_id)
    FOR UPDATE OF last_update_date NOWAIT;

  recinfo prof_csr%ROWTYPE;

BEGIN

  OPEN prof_csr;
  FETCH prof_csr INTO recinfo;
  IF (prof_csr%NOTFOUND)
  THEN
    CLOSE prof_csr;
    FND_MESSAGE.Set_name('FND', 'FORM_RECORD_DELETED');
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE prof_csr;

  IF
    ((recinfo.currency_code=p_currency_code)
      OR (recinfo.currency_code is NULL AND p_currency_code is NULL))
    AND
    ((recinfo.trx_credit_limit=p_trx_credit_limit)
      OR (recinfo.trx_credit_limit is NULL AND p_trx_credit_limit is NULL))
    AND
    ((recinfo.overall_credit_limit=p_overall_credit_limit)
      OR (recinfo.overall_credit_limit is NULL AND p_overall_credit_limit is NULL))

  THEN
     NULL;
  ELSE
     FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.raise_exception;
  END IF;

END Lock_Row;


--========================================================================
-- PROCEDURE : Update_row                   PUBLIC
-- PARAMETERS: p_row_id                     rowid
--             p_credit_profile_amt_id      primary key
--             p_credit_profile_id          credit_profile_id
--             p_currency_code              currency_code
--             p_trx_credit_limit           trx_credit_limit
--             p_overall_credit_limit       overall_credit_limit     credit_rating
--             p_last_update_date           date, when record was updated
--             p_last_updated_by            userid of the person,who updated the record
-- COMMENT   : Procedure updates record in the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Update_row
( p_row_id                 VARCHAR2
, p_credit_profile_amt_id  NUMBER
, p_credit_profile_id      NUMBER
, p_currency_code          VARCHAR2
, p_trx_credit_limit       NUMBER
, p_overall_credit_limit   NUMBER
, p_last_update_date       DATE
, p_last_updated_by        NUMBER
, p_attribute_category     VARCHAR2
, p_attribute1             VARCHAR2
, p_attribute2             VARCHAR2
, p_attribute3             VARCHAR2
, p_attribute4             VARCHAR2
, p_attribute5             VARCHAR2
, p_attribute6             VARCHAR2
, p_attribute7             VARCHAR2
, p_attribute8             VARCHAR2
, p_attribute9             VARCHAR2
, p_attribute10            VARCHAR2
, p_attribute11            VARCHAR2
, p_attribute12            VARCHAR2
, p_attribute13            VARCHAR2
, p_attribute14            VARCHAR2
, p_attribute15            VARCHAR2
)
IS

BEGIN
  UPDATE hz_credit_profile_amts
  SET
    credit_profile_id =p_credit_profile_id
  , currency_code=p_currency_code
  , trx_credit_limit=p_trx_credit_limit
  , overall_credit_limit=p_overall_credit_limit
  , last_update_date=p_last_update_date
  , last_updated_by=p_last_updated_by
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
-- PROCEDURE : Delete_row                 PUBLIC
-- PARAMETERS: p_row_id                   rowid
--
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_PROFILE_AMTS
--
--========================================================================
PROCEDURE Delete_row
( p_row_id VARCHAR2
)
IS
BEGIN
  DELETE
  FROM HZ_CREDIT_PROFILE_AMTS
  WHERE ROWID=CHARTOROWID(p_row_id);

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

--========================================================================
-- PROCEDURE : Delete_rows              PUBLIC
-- PARAMETERS: p_credit_profile_id      credit_profile_id
--
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_PROFILE_AMTS
--             when master record is deleted from HZ_CREDIT_PROFILES table
--========================================================================
PROCEDURE Delete_rows
( p_credit_profile_id NUMBER
)
IS
BEGIN
  DELETE
  FROM HZ_CREDIT_PROFILE_AMTS
  WHERE credit_profile_id=p_credit_profile_id;


EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Delete_row');
    END IF;
  RAISE;

END Delete_rows;


END HZ_CREDIT_PROFILE_AMTS_PKG;

/
