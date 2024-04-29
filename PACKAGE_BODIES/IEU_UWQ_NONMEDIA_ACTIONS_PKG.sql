--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_NONMEDIA_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_NONMEDIA_ACTIONS_PKG" AS
/* $Header: IEUNMACB.pls 115.4 2003/08/21 18:34:42 fsuthar ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_nonmedia_action_id               NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_action_object_code               VARCHAR2
        , x_maction_def_id                   NUMBER
        , x_application_id                   NUMBER
        , x_source_for_task_flag             VARCHAR2
        , x_responsibility_id                NUMBER
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM ieu_uwq_nonmedia_actions
          WHERE nonmedia_action_id = x_nonmedia_action_id;
     BEGIN
        INSERT INTO ieu_uwq_nonmedia_actions (
          nonmedia_action_id
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        , action_object_code
        , maction_def_id
        , application_id
        , source_for_task_flag
        , responsibility_id
        , object_version_number
        ) VALUES (
          x_nonmedia_action_id
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_action_object_code,FND_API.G_MISS_CHAR,NULL,x_action_object_code)
        , DECODE(x_maction_def_id,FND_API.G_MISS_NUM,NULL,x_maction_def_id)
        , DECODE(x_application_id,FND_API.G_MISS_NUM,NULL,x_application_id)
        , DECODE(x_source_for_task_flag,FND_API.G_MISS_CHAR,NULL,x_source_for_task_flag)
        , DECODE(x_responsibility_id,FND_API.G_MISS_NUM,NULL,x_responsibility_id)
        , 1
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;

     END insert_row;

     PROCEDURE delete_row(
        x_nonmedia_action_id                  NUMBER
     ) IS
     BEGIN
        DELETE FROM ieu_uwq_nonmedia_actions
        WHERE nonmedia_action_id = x_nonmedia_action_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_nonmedia_action_id             NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_action_object_code             VARCHAR2
        , x_maction_def_id                 NUMBER
        , x_application_id                 NUMBER
        , x_source_for_task_flag             VARCHAR2
        , x_responsibility_id                NUMBER
     ) IS
     BEGIN
        UPDATE ieu_uwq_nonmedia_actions
        SET
          nonmedia_action_id=DECODE(x_nonmedia_action_id,FND_API.G_MISS_NUM,NULL,x_nonmedia_action_id)
        , created_by=DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , creation_date=DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , action_object_code=DECODE(x_action_object_code,FND_API.G_MISS_CHAR,NULL,x_action_object_code)
        , maction_def_id=DECODE(x_maction_def_id,FND_API.G_MISS_NUM,NULL,x_maction_def_id)
        , application_id=DECODE(x_application_id,FND_API.G_MISS_NUM,NULL,x_application_id)
        , source_for_task_flag = DECODE(x_source_for_task_flag,FND_API.G_MISS_CHAR,NULL,x_source_for_task_flag)
        , responsibility_id = DECODE(x_responsibility_id,FND_API.G_MISS_NUM,NULL,x_responsibility_id)
        , object_version_number=nvl(object_version_number,0) + 1
        WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;


     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_nonmedia_action_id             NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_action_object_code             VARCHAR2
        , x_maction_def_id                 NUMBER
        , x_application_id                 NUMBER
        , x_source_for_task_flag             VARCHAR2
        , x_responsibility_id                NUMBER
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM ieu_uwq_nonmedia_actions
          WHERE rowid = x_rowid
          FOR UPDATE OF nonmedia_action_id NOWAIT;
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
          ((l_table_rec.nonmedia_action_id = x_nonmedia_action_id)
            OR ((l_table_rec.nonmedia_action_id IS NULL)
                AND ( x_nonmedia_action_id IS NULL)))
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
          AND           ((l_table_rec.action_object_code = x_action_object_code)
            OR ((l_table_rec.action_object_code IS NULL)
                AND ( x_action_object_code IS NULL)))
          AND           ((l_table_rec.maction_def_id = x_maction_def_id)
            OR ((l_table_rec.maction_def_id IS NULL)
                AND ( x_maction_def_id IS NULL)))
          AND           ((l_table_rec.application_id = x_application_id)
            OR ((l_table_rec.application_id IS NULL)
                AND ( x_application_id IS NULL)))
          AND           ((l_table_rec.source_for_task_flag = x_source_for_task_flag)
            OR ((l_table_rec.source_for_task_flag IS NULL)
                AND ( x_source_for_task_flag IS NULL)))
          AND           ((l_table_rec.responsibility_id = x_responsibility_id)
            OR ((l_table_rec.responsibility_id IS NULL)
                AND ( x_responsibility_id IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;
END ieu_uwq_nonmedia_actions_pkg;

/
