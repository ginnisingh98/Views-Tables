--------------------------------------------------------
--  DDL for Package Body JTF_IH_OUTCOME_RSLTS_SEED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_OUTCOME_RSLTS_SEED_PUB" AS
 /* $Header: JTFIHORB.pls 115.2 2001/11/09 19:00:22 pkm ship      $ */

     PROCEDURE insert_row(
          x_rowid                          IN OUT VARCHAR2
        , x_result_id                        NUMBER
        , x_outcome_id                       NUMBER
        , x_object_version_number            NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM jtf_ih_outcome_results
          WHERE result_id = x_result_id;
     BEGIN
        INSERT INTO jtf_ih_outcome_results (
          result_id
        , outcome_id
        , object_version_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        ) VALUES (
          x_result_id
        , DECODE(x_outcome_id,FND_API.G_MISS_NUM,NULL,x_outcome_id)
        , DECODE(x_object_version_number,FND_API.G_MISS_NUM,NULL,x_object_version_number)
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_result_id                        NUMBER
     ) IS
     BEGIN
        DELETE FROM jtf_ih_outcome_results
        WHERE result_id = x_result_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_result_id                      NUMBER
        , x_outcome_id                     NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
     ) IS
     BEGIN
        UPDATE jtf_ih_outcome_results
        SET
          result_id=DECODE(x_result_id,FND_API.G_MISS_NUM,NULL,x_result_id)
        , outcome_id=DECODE(x_outcome_id,FND_API.G_MISS_NUM,NULL,x_outcome_id)
        , object_version_number=DECODE(x_object_version_number,FND_API.G_MISS_NUM,NULL,x_object_version_number)
        , created_by=DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , creation_date=DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_result_id                      NUMBER
        , x_outcome_id                     NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM jtf_ih_outcome_results
          WHERE rowid = x_rowid
          FOR UPDATE OF result_id NOWAIT;
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
          ((l_table_rec.result_id = x_result_id)
            OR ((l_table_rec.result_id IS NULL)
                AND ( x_result_id IS NULL)))
          AND           ((l_table_rec.outcome_id = x_outcome_id)
            OR ((l_table_rec.outcome_id IS NULL)
                AND ( x_outcome_id IS NULL)))
          AND           ((l_table_rec.object_version_number = x_object_version_number)
            OR ((l_table_rec.object_version_number IS NULL)
                AND ( x_object_version_number IS NULL)))
          AND           ((l_table_rec.created_by = x_created_by)
            OR ((l_table_rec.created_by IS NULL)
                AND ( x_created_by IS NULL)))
          AND           ((l_table_rec.creation_date = x_creation_date)
            OR ((l_table_rec.creation_date IS NULL)
                AND ( x_creation_date IS NULL)))
          AND           ((l_table_rec.last_updated_by = x_last_updated_by)
            OR ((l_table_rec.last_updated_by IS NULL)
                AND ( x_last_updated_by IS NULL)))
          AND           ((l_table_rec.last_update_date = x_last_update_date)
            OR ((l_table_rec.last_update_date IS NULL)
                AND ( x_last_update_date IS NULL)))
          AND           ((l_table_rec.last_update_login = x_last_update_login)
            OR ((l_table_rec.last_update_login IS NULL)
                AND ( x_last_update_login IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;
END jtf_ih_outcome_rslts_seed_pub;

/
