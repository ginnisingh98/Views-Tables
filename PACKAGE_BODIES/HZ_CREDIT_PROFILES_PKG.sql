--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_PROFILES_PKG" AS
/* $Header: ARHCRPRB.pls 115.3 2003/08/18 17:45:10 rajkrish ship $ */

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record in
--                                          table HZ_CREDIT_PROFILES
--             p_credit_profile_id          primary key
--             p_organization_id            operating unit id
--             p_item_category_id           item_category_id
--             p_enable_flag                YES/NO enable flag
--             p_effective_date_from        effective_date_from
--             p_effective_date_to          effective_date_to
--             p_credit_checking            credit_checking
--             p_next_credit_review_date    next_credit_review_date
--             p_tolerance                  tolerance
--             p_credit_hold                credit_hold
--             p_credit_rating              credit_rating
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
--
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Insert_row
( p_row_id               OUT NOCOPY VARCHAR2
, p_credit_profile_id        NUMBER
, p_organization_id          NUMBER
, p_item_category_id         NUMBER
, p_enable_flag              VARCHAR2
, p_effective_date_from      DATE
, p_effective_date_to        DATE
, p_credit_checking          VARCHAR2
, p_next_credit_review_date  DATE
, p_tolerance                NUMBER
, p_credit_hold              VARCHAR2
, p_credit_rating            VARCHAR2
, p_creation_date            DATE
, p_created_by               NUMBER
, p_last_update_date         DATE
, p_last_updated_by          NUMBER
, p_last_update_login        NUMBER
)
IS

CURSOR profile_csr IS
  SELECT
    rowid
  FROM
    hz_credit_profiles
  WHERE credit_profile_id=p_credit_profile_id;

BEGIN

  INSERT INTO hz_credit_profiles
  ( credit_profile_id
  , organization_id
  , item_category_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , enable_flag
  , effective_date_from
  , effective_date_to
  , credit_checking
  , next_credit_review_date
  , tolerance
  , credit_hold
  , credit_rating
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
  ( p_credit_profile_id
  , p_organization_id
  , p_item_category_id
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , p_enable_flag
  , p_effective_date_from
  , p_effective_date_to
  , p_credit_checking
  , p_next_credit_review_date
  , p_tolerance
  , p_credit_hold
  , p_credit_rating
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  , null
  );

  OPEN profile_csr;
  FETCH  profile_csr INTO p_row_id;
  IF (profile_csr%NOTFOUND)
  THEN
    CLOSE profile_csr;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE profile_csr;

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
-- PARAMETERS: p_credit_profile_id          credit_profile_id
--             p_last_update_date
-- COMMENT   : Procedure locks record in the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Lock_row
( p_credit_profile_id        NUMBER
, p_last_update_date         DATE
)
IS
  CURSOR prof_csr
  IS
    SELECT *
    FROM hz_credit_profiles
    WHERE credit_profile_id=p_credit_profile_id
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
    (recinfo.last_update_date=p_last_update_date)
  THEN
     NULL;
  ELSE
     FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.raise_exception;
  END IF;

END Lock_Row;


--========================================================================
-- PROCEDURE : Update_row                   PUBLIC
-- PARAMETERS: p_credit_profile_id          credit_profile_id
--             p_organization_id            operating unit id
--             p_item_category_id           item_category_id
--             p_enable_flag                YES/NO enable flag
--             p_effective_date_from        effective_date_from
--             p_effective_date_to          effective_date_to
--             p_credit_checking            credit_checking
--             p_next_credit_review_date    next_credit_review_date
--             p_tolerance                  tolerance
--             p_credit_hold                credit_hold
--             p_credit_rating              credit_rating
--             p_last_update_date           date, when record was updated
--             p_last_updated_by            userid of the person,who updated the record
-- COMMENT   : Procedure updates record in the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Update_row
( p_credit_profile_id        NUMBER
, p_organization_id          NUMBER
, p_item_category_id         NUMBER
, p_enable_flag              VARCHAR2
, p_effective_date_from      DATE
, p_effective_date_to        DATE
, p_credit_checking          VARCHAR2
, p_next_credit_review_date  DATE
, p_tolerance                NUMBER
, p_credit_hold              VARCHAR2
, p_credit_rating            VARCHAR2
, p_last_update_date         DATE
, p_last_updated_by          NUMBER
)
IS

BEGIN
  UPDATE hz_credit_profiles
  SET
    organization_id =p_organization_id
  , item_category_id=p_item_category_id
  , enable_flag=p_enable_flag
  , effective_date_from=p_effective_date_from
  , effective_date_to=p_effective_date_to
  , credit_checking=p_credit_checking
  , next_credit_review_date=p_next_credit_review_date
  , tolerance=p_tolerance
  , credit_hold=p_credit_hold
  , credit_rating=p_credit_rating
  , last_update_date=p_last_update_date
  , last_updated_by=p_last_updated_by
  WHERE credit_profile_id=p_credit_profile_id;

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
-- PARAMETERS: p_credit_profile_id        credit_profile_id
--
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_PROFILES
--
--========================================================================
PROCEDURE Delete_row
( p_credit_profile_id NUMBER
)
IS
BEGIN
  DELETE
  FROM HZ_CREDIT_PROFILES
  WHERE credit_profile_id=p_credit_profile_id;

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

END HZ_CREDIT_PROFILES_PKG;

/
