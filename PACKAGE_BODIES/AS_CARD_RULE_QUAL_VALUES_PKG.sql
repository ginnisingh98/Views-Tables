--------------------------------------------------------
--  DDL for Package Body AS_CARD_RULE_QUAL_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_CARD_RULE_QUAL_VALUES_PKG" AS
/* $Header: asxtcqvb.pls 120.1 2005/06/24 16:58:11 appldev ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY  VARCHAR2
        , x_qual_value_id                    NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_creation_date                    DATE
        , x_created_by                       NUMBER
        , x_last_update_login                NUMBER
        , x_scorecard_id                     NUMBER
        , x_score                            NUMBER
        , x_card_rule_id                     NUMBER
        , x_seed_qual_id                     NUMBER
        , x_high_value_number                NUMBER
        , x_low_value_number                 NUMBER
        , x_high_value_char                  VARCHAR2
        , x_low_value_char                   VARCHAR2
        , x_currency_code                    VARCHAR2
        , x_low_value_date                   DATE
        , x_high_value_date                  DATE
        , x_start_date_active                DATE
        , x_end_date_active                  DATE
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM as_card_rule_qual_values
          WHERE qual_value_id = x_qual_value_id;
     BEGIN
        INSERT INTO as_card_rule_qual_values (
          qual_value_id
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , scorecard_id
        , score
        , card_rule_id
        , seed_qual_id
        , high_value_number
        , low_value_number
        , high_value_char
        , low_value_char
        , currency_code
        , low_value_date
        , high_value_date
        , start_date_active
        , end_date_active
        ) VALUES (
          x_qual_value_id
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , DECODE(x_score,FND_API.G_MISS_NUM,NULL,x_score)
        , DECODE(x_card_rule_id,FND_API.G_MISS_NUM,NULL,x_card_rule_id)
        , DECODE(x_seed_qual_id,FND_API.G_MISS_NUM,NULL,x_seed_qual_id)
        , DECODE(x_high_value_number,FND_API.G_MISS_NUM,NULL,x_high_value_number)
        , DECODE(x_low_value_number,FND_API.G_MISS_NUM,NULL,x_low_value_number)
        , DECODE(x_high_value_char,FND_API.G_MISS_CHAR,NULL,x_high_value_char)
        , DECODE(x_low_value_char,FND_API.G_MISS_CHAR,NULL,x_low_value_char)
        , DECODE(x_currency_code,FND_API.G_MISS_CHAR,NULL,x_currency_code)
        , DECODE(x_low_value_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_low_value_date)
        , DECODE(x_high_value_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_high_value_date)
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
        x_qual_value_id                    NUMBER
     ) IS
     BEGIN
        DELETE FROM as_card_rule_qual_values
        WHERE qual_value_id = x_qual_value_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_qual_value_id                  NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_last_update_login              NUMBER
        , x_scorecard_id                   NUMBER
        , x_score                          NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     ) IS
     BEGIN
        UPDATE as_card_rule_qual_values
        SET
          qual_value_id=DECODE(x_qual_value_id,FND_API.G_MISS_NUM,NULL,x_qual_value_id)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , scorecard_id=DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , score=DECODE(x_score,FND_API.G_MISS_NUM,NULL,x_score)
        , card_rule_id=DECODE(x_card_rule_id,FND_API.G_MISS_NUM,NULL,x_card_rule_id)
        , seed_qual_id=DECODE(x_seed_qual_id,FND_API.G_MISS_NUM,NULL,x_seed_qual_id)
        , high_value_number=DECODE(x_high_value_number,FND_API.G_MISS_NUM,NULL,x_high_value_number)
        , low_value_number=DECODE(x_low_value_number,FND_API.G_MISS_NUM,NULL,x_low_value_number)
        , high_value_char=DECODE(x_high_value_char,FND_API.G_MISS_CHAR,NULL,x_high_value_char)
        , low_value_char=DECODE(x_low_value_char,FND_API.G_MISS_CHAR,NULL,x_low_value_char)
        , currency_code=DECODE(x_currency_code,FND_API.G_MISS_CHAR,NULL,x_currency_code)
        , low_value_date=DECODE(x_low_value_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_low_value_date)
        , high_value_date=DECODE(x_high_value_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_high_value_date)
        , start_date_active=DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , end_date_active=DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;
     PROCEDURE update_row(
          x_qual_value_id                  NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_last_update_login              NUMBER
        , x_scorecard_id                   NUMBER
        , x_score                          NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     ) IS
     BEGIN
        UPDATE as_card_rule_qual_values
        SET
          qual_value_id=DECODE(x_qual_value_id,FND_API.G_MISS_NUM,NULL,x_qual_value_id)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , scorecard_id=DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , score=DECODE(x_score,FND_API.G_MISS_NUM,NULL,x_score)
        , card_rule_id=DECODE(x_card_rule_id,FND_API.G_MISS_NUM,NULL,x_card_rule_id)
        , seed_qual_id=DECODE(x_seed_qual_id,FND_API.G_MISS_NUM,NULL,x_seed_qual_id)
        , high_value_number=DECODE(x_high_value_number,FND_API.G_MISS_NUM,NULL,x_high_value_number)
        , low_value_number=DECODE(x_low_value_number,FND_API.G_MISS_NUM,NULL,x_low_value_number)
        , high_value_char=DECODE(x_high_value_char,FND_API.G_MISS_CHAR,NULL,x_high_value_char)
        , low_value_char=DECODE(x_low_value_char,FND_API.G_MISS_CHAR,NULL,x_low_value_char)
        , currency_code=DECODE(x_currency_code,FND_API.G_MISS_CHAR,NULL,x_currency_code)
        , low_value_date=DECODE(x_low_value_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_low_value_date)
        , high_value_date=DECODE(x_high_value_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_high_value_date)
        , start_date_active=DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , end_date_active=DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        WHERE qual_value_id = x_qual_value_id;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;


     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_qual_value_id                  NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_scorecard_id                   NUMBER
        , x_score                          NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM as_card_rule_qual_values
          WHERE rowid = x_rowid
          FOR UPDATE OF qual_value_id NOWAIT;
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
          ((l_table_rec.qual_value_id = x_qual_value_id)
            OR ((l_table_rec.qual_value_id IS NULL)
                AND ( x_qual_value_id IS NULL)))
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
          AND           ((l_table_rec.scorecard_id = x_scorecard_id)
            OR ((l_table_rec.scorecard_id IS NULL)
                AND ( x_scorecard_id IS NULL)))
          AND           ((l_table_rec.score = x_score)
            OR ((l_table_rec.score IS NULL)
                AND ( x_score IS NULL)))
          AND           ((l_table_rec.card_rule_id = x_card_rule_id)
            OR ((l_table_rec.card_rule_id IS NULL)
                AND ( x_card_rule_id IS NULL)))
          AND           ((l_table_rec.seed_qual_id = x_seed_qual_id)
            OR ((l_table_rec.seed_qual_id IS NULL)
                AND ( x_seed_qual_id IS NULL)))
          AND           ((l_table_rec.high_value_number = x_high_value_number)
            OR ((l_table_rec.high_value_number IS NULL)
                AND ( x_high_value_number IS NULL)))
          AND           ((l_table_rec.low_value_number = x_low_value_number)
            OR ((l_table_rec.low_value_number IS NULL)
                AND ( x_low_value_number IS NULL)))
          AND           ((l_table_rec.high_value_char = x_high_value_char)
            OR ((l_table_rec.high_value_char IS NULL)
                AND ( x_high_value_char IS NULL)))
          AND           ((l_table_rec.low_value_char = x_low_value_char)
            OR ((l_table_rec.low_value_char IS NULL)
                AND ( x_low_value_char IS NULL)))
          AND           ((l_table_rec.currency_code = x_currency_code)
            OR ((l_table_rec.currency_code IS NULL)
                AND ( x_currency_code IS NULL)))
          AND           ((l_table_rec.low_value_date = x_low_value_date)
            OR ((l_table_rec.low_value_date IS NULL)
                AND ( x_low_value_date IS NULL)))
          AND           ((l_table_rec.high_value_date = x_high_value_date)
            OR ((l_table_rec.high_value_date IS NULL)
                AND ( x_high_value_date IS NULL)))
          AND           ((l_table_rec.start_date_active = x_start_date_active)
            OR ((l_table_rec.start_date_active IS NULL)
                AND ( x_start_date_active IS NULL)))
          AND           ((l_Table_rec.end_date_active = x_end_date_active)
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
          x_qual_value_id                  NUMBER
        , x_scorecard_id                     NUMBER
        , x_score                            NUMBER
        , x_card_rule_id                   NUMBER
        , x_seed_qual_id                   NUMBER
        , x_high_value_number              NUMBER
        , x_low_value_number               NUMBER
        , x_high_value_char                VARCHAR2
        , x_low_value_char                 VARCHAR2
        , x_currency_code                  VARCHAR2
        , x_low_value_date                 DATE
        , x_high_value_date                DATE
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_owner                          VARCHAR2
     )
IS
    user_id            number := 0;
    row_id             varchar2(64);

    CURSOR c_get_last_updated (c_qual_value_id NUMBER) IS
        SELECT last_updated_by
        FROM as_card_rule_qual_values
        WHERE qual_value_id = c_qual_value_id;
    l_last_updated_by  NUMBER;
    l_rowid             varchar2(64);

BEGIN
    -- If last_updated_by is not 1, means this record has been updated by
    -- customer, we should not overwrite it.
    OPEN c_get_last_updated (x_qual_value_id );
    FETCH c_get_last_updated INTO l_last_updated_by;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN
        if (X_OWNER = 'SEED') then
            user_id := 1;
        end if;

      Update_Row(
          x_qual_value_id                  => x_qual_value_id
        , x_last_update_date               => SYSDATE
        , x_last_updated_by                => user_id
        , x_last_update_login              => 0
        , x_scorecard_id                   => x_scorecard_id
        , x_score                          => x_score
        , x_card_rule_id                   => x_card_rule_id
        , x_seed_qual_id                   => x_seed_qual_id
        , x_high_value_number              => x_high_value_number
        , x_low_value_number               => x_low_value_number
        , x_high_value_char                => x_high_value_char
        , x_low_value_char                 => x_low_value_char
        , x_currency_code                  => x_currency_code
        , x_low_value_date                 => x_low_value_date
        , x_high_value_date                => x_high_value_date
        , x_start_date_active              => x_start_date_active
        , x_end_date_active                => x_end_date_active
      );


    END IF;

    EXCEPTION
        when no_data_found then
        Insert_Row(
            x_rowid                          => l_rowid
          , x_qual_value_id                  => x_qual_value_id
          , x_last_update_date               => SYSDATE
          , x_last_updated_by                => user_id
          , x_creation_date                  => sysdate
          , x_created_by                     => 0
          , x_last_update_login              => 0
          , x_scorecard_id                   => x_scorecard_id
          , x_score                          => x_score
          , x_card_rule_id                   => x_card_rule_id
          , x_seed_qual_id                   => x_seed_qual_id
          , x_high_value_number              => x_high_value_number
          , x_low_value_number               => x_low_value_number
          , x_high_value_char                => x_high_value_char
          , x_low_value_char                 => x_low_value_char
          , x_currency_code                  => x_currency_code
          , x_low_value_date                 => x_low_value_date
          , x_high_value_date                => x_high_value_date
          , x_start_date_active              => x_start_date_active
          , x_end_date_active                => x_end_date_active
           );

END load_row;

END as_card_rule_qual_values_pkg;

/
