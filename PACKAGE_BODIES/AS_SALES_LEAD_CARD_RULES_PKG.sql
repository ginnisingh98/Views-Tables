--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_CARD_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_CARD_RULES_PKG" AS
/* $Header: asxtscrb.pls 120.1 2005/06/24 17:02:27 appldev ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY  VARCHAR2
        , x_card_rule_id                     NUMBER
        , x_scorecard_id                     NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_creation_date                    DATE
        , x_created_by                       NUMBER
        , x_last_update_login                NUMBER
        , x_description                      VARCHAR2
        , x_start_date_active                DATE
        , x_end_date_active                  DATE
        , x_score                            NUMBER
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM as_sales_lead_card_rules
          WHERE card_rule_id = x_card_rule_id;
     BEGIN
        INSERT INTO as_sales_lead_card_rules (
          card_rule_id
        , scorecard_id
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , description
        , start_date_active
        , end_date_active
        , score
        ) VALUES (
          x_card_rule_id
        , DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        , DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        , DECODE(x_score,FND_API.G_MISS_NUM,NULL,x_score)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_card_rule_id                     NUMBER
     ) IS
     BEGIN
        DELETE FROM as_sales_lead_card_rules
        WHERE card_rule_id = x_card_rule_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_card_rule_id                   NUMBER
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_score                          NUMBER
     ) IS
     BEGIN
        UPDATE as_sales_lead_card_rules
        SET
          card_rule_id=DECODE(x_card_rule_id,FND_API.G_MISS_NUM,NULL,x_card_rule_id)
        , scorecard_id=DECODE(x_scorecard_id,FND_API.G_MISS_NUM,NULL,x_scorecard_id)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , creation_date=DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
        , created_by=DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , description=DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        , start_date_active=DECODE(x_start_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_start_date_active)
        , end_date_active=DECODE(x_end_date_active,FND_API.G_MISS_DATE,TO_DATE(NULL),x_end_date_active)
        , score=DECODE(x_score,FND_API.G_MISS_NUM,NULL,x_score)
        WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_card_rule_id                   NUMBER
        , x_scorecard_id                   NUMBER
        , x_last_update_date               DATE
        , x_last_updated_by                NUMBER
        , x_creation_date                  DATE
        , x_created_by                     NUMBER
        , x_last_update_login              NUMBER
        , x_description                    VARCHAR2
        , x_start_date_active              DATE
        , x_end_date_active                DATE
        , x_score                          NUMBER
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM as_sales_lead_card_rules
          WHERE rowid = x_rowid
          FOR UPDATE OF card_rule_id NOWAIT;
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
          ((l_table_rec.card_rule_id = x_card_rule_id)
            OR ((l_table_rec.card_rule_id IS NULL)
                AND ( x_card_rule_id IS NULL)))
          AND           ((l_table_rec.scorecard_id = x_scorecard_id)
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
          AND           ((l_table_rec.start_date_active = x_start_date_active)
            OR ((l_table_rec.start_date_active IS NULL)
                AND ( x_start_date_active IS NULL)))
          AND           ((l_table_rec.end_date_active = x_end_date_active)
            OR ((l_table_rec.end_date_active IS NULL)
                AND ( x_end_date_active IS NULL)))
          AND           ((l_table_rec.score = x_score)
            OR ((l_table_rec.score IS NULL)
                AND ( x_score IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;
END as_sales_lead_card_rules_pkg;

/
