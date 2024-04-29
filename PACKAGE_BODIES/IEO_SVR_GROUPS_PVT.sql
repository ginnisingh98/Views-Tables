--------------------------------------------------------
--  DDL for Package Body IEO_SVR_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SVR_GROUPS_PVT" AS
/* $Header: IEOSVRGB.pls 120.1 2005/06/12 01:21:33 appldev  $ */


     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_server_group_id                  NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_group_name                       VARCHAR2
        , x_group_group_id                   NUMBER
        , x_location                         VARCHAR2
        , x_description                      VARCHAR2
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM ieo_svr_groups
          WHERE server_group_id = x_server_group_id;
     BEGIN
        INSERT INTO ieo_svr_groups (
          server_group_id
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        , group_name
        , group_group_id
        , location
        , description
        ) VALUES (
          x_server_group_id
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_group_name,FND_API.G_MISS_CHAR,NULL,x_group_name)
        , DECODE(x_group_group_id,FND_API.G_MISS_NUM,NULL,x_group_group_id)
        , DECODE(x_location,FND_API.G_MISS_CHAR,NULL,x_location)
        , DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_server_group_id                  NUMBER
     ) IS
     BEGIN
        DELETE FROM ieo_svr_groups
        WHERE server_group_id = x_server_group_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_server_group_id                NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_group_name                     VARCHAR2
        , x_group_group_id                 NUMBER
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
     ) IS
     BEGIN
        UPDATE ieo_svr_groups
        SET
          server_group_id=DECODE(x_server_group_id,FND_API.G_MISS_NUM,NULL,x_server_group_id)
        , created_by=DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , creation_date=DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , group_name=DECODE(x_group_name,FND_API.G_MISS_CHAR,NULL,x_group_name)
        , group_group_id=DECODE(x_group_group_id,FND_API.G_MISS_NUM,NULL,x_group_group_id)
        , location=DECODE(x_location,FND_API.G_MISS_CHAR,NULL,x_location)
        , description=DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_server_group_id                NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_group_name                     VARCHAR2
        , x_group_group_id                 NUMBER
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM ieo_svr_groups
          WHERE rowid = x_rowid
          FOR UPDATE OF server_group_id NOWAIT;
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
          ((l_table_rec.server_group_id = x_server_group_id)
            OR ((l_table_rec.server_group_id IS NULL)
                AND ( x_server_group_id IS NULL)))
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
          AND           ((l_table_rec.group_name = x_group_name)
            OR ((l_table_rec.group_name IS NULL)
                AND ( x_group_name IS NULL)))
          AND           ((l_table_rec.group_group_id = x_group_group_id)
            OR ((l_table_rec.group_group_id IS NULL)
                AND ( x_group_group_id IS NULL)))
          AND           ((l_table_rec.location = x_location)
            OR ((l_table_rec.location IS NULL)
                AND ( x_location IS NULL)))
          AND           ((l_table_rec.description = x_description)
            OR ((l_table_rec.description IS NULL)
                AND ( x_description IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;
END ieo_svr_groups_pvt;

/
