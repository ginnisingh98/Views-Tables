--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_SCORECARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_SCORECARDS_PKG" AS
/* $Header: asxtscdb.pls 115.8 2002/11/22 08:05:07 ckapoor ship $ */
     AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_scorecard_id                     NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_creation_date                    DATE
        , x_created_by                       NUMBER
        , x_last_update_login                NUMBER
        , x_description                      VARCHAR2
        , x_enabled_flag                     VARCHAR2
        , x_start_date_active                DATE
        , x_end_date_active                  DATE
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM as_sales_lead_scorecards
          WHERE scorecard_id = x_scorecard_id;
     BEGIN
        INSERT INTO as_sales_lead_scorecards (
          scorecard_id
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , description
         , enabled_flag
        , start_date_active
        , end_date_active
        ) VALUES (
          x_scorecard_id
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        , DECODE(x_enabled_flag,FND_API.G_MISS_CHAR,NULL,x_enabled_flag)
        , DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_scorecard_id                     NUMBER
     ) IS
     BEGIN
        DELETE FROM as_sales_lead_scorecards
        WHERE scorecard_id = x_scorecard_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_enabled_flag                   VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     ) IS
     BEGIN
        UPDATE as_sales_lead_scorecards
        SET
          scorecard_id      = DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , last_update_date  = DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by   = DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , creation_date     = DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
        , created_by        = DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , last_update_login = DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , description       = DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
         , enabled_flag      = DECODE(x_enabled_flag,FND_API.G_MISS_CHAR,NULL,x_enabled_flag)
        , start_date_active = DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , end_date_active   = DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        WHERE ROWID         = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE update_row(
          x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     ) IS
     BEGIN
        UPDATE as_sales_lead_scorecards
        SET
          scorecard_id      = DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , last_update_date  = DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by   = DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_login = DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , description       = DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        , start_date_active = DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , end_date_active   = DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        WHERE scorecard_id  = x_scorecard_id;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_enabled_flag                   VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM as_sales_lead_scorecards
          WHERE rowid = x_rowid
          FOR UPDATE OF scorecard_id NOWAIT;
        l_table_rec l_lock%ROWTYPE;
     BEGIN
        OPEN l_lock;
        FETCH l_lock INTO l_table_rec;
        IF (l_lock%NOTFOUND) THEN
             CLOSE l_lock;
             FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
             APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE l_lock;
        IF (
          ((l_table_rec.scorecard_id = x_scorecard_id)
            OR ((l_table_rec.scorecard_id IS NULL)
                AND ( x_scorecard_id IS NULL)))
          AND           ((l_table_rec.last_update_date = x_last_update_date)
            OR ((l_table_rec.last_update_date IS NULL)
                AND ( x_last_update_date IS NULL)))
          AND           ((l_table_rec.last_updated_by = x_last_updated_by)
            OR ((l_table_rec.last_updated_by IS NULL)
                AND ( x_last_updated_by IS NULL)))
          AND           ((l_table_rec.creation_date = x_creation_date)
            OR ((l_table_rec.creation_date IS NULL)
                AND ( x_creation_date IS NULL)))
          AND           ((l_table_rec.created_by = x_created_by)
            OR ((l_table_rec.created_by IS NULL)
                AND ( x_created_by IS NULL)))
          AND           ((l_table_rec.last_update_login = x_last_update_login)
            OR ((l_table_rec.last_update_login IS NULL)
                AND ( x_last_update_login IS NULL)))
          AND           ((l_table_rec.description = x_description)
            OR ((l_table_rec.description IS NULL)
                AND ( x_description IS NULL)))
           AND           ((l_table_rec.enabled_flag = x_enabled_flag)
             OR ((l_table_rec.enabled_flag IS NULL)
                 AND ( x_enabled_flag IS NULL)))
          AND           ((l_table_rec.start_date_active = x_start_date_active)
            OR ((l_table_rec.start_date_active IS NULL)
                AND ( x_start_date_active IS NULL)))
          AND           ((l_table_rec.end_date_active = x_end_date_active)
            OR ((l_table_rec.end_date_active IS NULL)
                AND ( x_end_date_active IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;


    PROCEDURE load_row(
          x_scorecard_id                   NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_owner                          VARCHAR2
     )
IS
    user_id            number := 0;
    row_id             varchar2(64);


    CURSOR c_get_last_updated (c_scorecard_id NUMBER) IS
        SELECT last_updated_by
        FROM as_sales_lead_scorecards
        WHERE scorecard_id = c_scorecard_id;
    l_last_updated_by  NUMBER;
    l_rowid             varchar2(64);

BEGIN

    -- If last_updated_by is not 1, means this record has been updated by
    -- customer, we should not overwrite it.
    OPEN c_get_last_updated (x_scorecard_id);
    FETCH c_get_last_updated INTO l_last_updated_by;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN
        if (X_OWNER = 'SEED') then
            user_id := 1;
        end if;

      Update_Row(
          x_scorecard_id      => x_scorecard_id
        , x_last_update_date  => SYSDATE
        , x_last_updated_by   => user_id
        , x_last_update_login => 0
        , x_description       => x_description
        , x_start_date_active => x_start_date_active
        , x_end_date_active   => x_end_date_active
      );

    END IF;

    EXCEPTION
        when no_data_found then
      Insert_Row(
          x_rowid             => l_rowid
        , x_scorecard_id      => x_scorecard_id
        , x_last_update_date  => SYSDATE
        , x_last_updated_by   => user_id
        , x_creation_date     => sysdate
        , x_created_by        => 0
        , x_last_update_login => 0
        , x_description       => x_description
        , x_enabled_flag      => NULL
        , x_start_date_active => x_start_date_active
        , x_end_date_active   => x_end_date_active
      );

END load_row;



END as_sales_lead_scorecards_pkg;

/
