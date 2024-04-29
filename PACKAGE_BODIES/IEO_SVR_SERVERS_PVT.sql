--------------------------------------------------------
--  DDL for Package Body IEO_SVR_SERVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SVR_SERVERS_PVT" AS
/* $Header: IEOSVRSB.pls 120.1 2005/06/12 01:21:57 appldev  $ */


     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_server_id                        NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_type_id                          NUMBER
        , x_server_name                      VARCHAR2
        , x_member_svr_group_id              NUMBER
        , x_using_svr_group_id               NUMBER
        , x_dns_name                         VARCHAR2
        , x_ip_address                       VARCHAR2
        , x_location                         VARCHAR2
        , x_description                      VARCHAR2
        , x_user_address                     VARCHAR2
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM ieo_svr_servers
          WHERE server_id = x_server_id;
     BEGIN
        INSERT INTO ieo_svr_servers (
          server_id
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        , type_id
        , server_name
        , member_svr_group_id
        , using_svr_group_id
        , dns_name
        , ip_address
        , location
        , description
        , user_address
        ) VALUES (
          x_server_id
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_type_id,FND_API.G_MISS_NUM,NULL,x_type_id)
        , DECODE(x_server_name,FND_API.G_MISS_CHAR,NULL,x_server_name)
        , DECODE(x_member_svr_group_id,FND_API.G_MISS_NUM,NULL,x_member_svr_group_id)
        , DECODE(x_using_svr_group_id,FND_API.G_MISS_NUM,NULL,x_using_svr_group_id)
        , DECODE(x_dns_name,FND_API.G_MISS_CHAR,NULL,x_dns_name)
        , DECODE(x_ip_address,FND_API.G_MISS_CHAR,NULL,x_ip_address)
        , DECODE(x_location,FND_API.G_MISS_CHAR,NULL,x_location)
        , DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        , DECODE(x_user_address,FND_API.G_MISS_CHAR,NULL,x_user_address)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_server_id                        NUMBER
     ) IS
     BEGIN
        DELETE FROM ieo_svr_servers
        WHERE server_id = x_server_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_server_id                      NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_type_id                        NUMBER
        , x_server_name                    VARCHAR2
        , x_member_svr_group_id            NUMBER
        , x_using_svr_group_id             NUMBER
        , x_dns_name                       VARCHAR2
        , x_ip_address                     VARCHAR2
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
        , x_user_address                   VARCHAR2
     ) IS
     BEGIN
        UPDATE ieo_svr_servers
        SET
          server_id=DECODE(x_server_id,FND_API.G_MISS_NUM,NULL,x_server_id)
        , created_by=DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , creation_date=DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , type_id=DECODE(x_type_id,FND_API.G_MISS_NUM,NULL,x_type_id)
        , server_name=DECODE(x_server_name,FND_API.G_MISS_CHAR,NULL,x_server_name)
        , member_svr_group_id=DECODE(x_member_svr_group_id,FND_API.G_MISS_NUM,NULL,x_member_svr_group_id)
        , using_svr_group_id=DECODE(x_using_svr_group_id,FND_API.G_MISS_NUM,NULL,x_using_svr_group_id)
        , dns_name=DECODE(x_dns_name,FND_API.G_MISS_CHAR,NULL,x_dns_name)
        , ip_address=DECODE(x_ip_address,FND_API.G_MISS_CHAR,NULL,x_ip_address)
        , location=DECODE(x_location,FND_API.G_MISS_CHAR,NULL,x_location)
        , description=DECODE(x_description,FND_API.G_MISS_CHAR,NULL,x_description)
        , user_address=DECODE(x_user_address,FND_API.G_MISS_CHAR,NULL,x_user_address)
        WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_server_id                      NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_type_id                        NUMBER
        , x_server_name                    VARCHAR2
        , x_member_svr_group_id            NUMBER
        , x_using_svr_group_id             NUMBER
        , x_dns_name                       VARCHAR2
        , x_ip_address                     VARCHAR2
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
        , x_user_address                   VARCHAR2
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM ieo_svr_servers
          WHERE rowid = x_rowid
          FOR UPDATE OF server_id NOWAIT;
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
          ((l_table_rec.server_id = x_server_id)
            OR ((l_table_rec.server_id IS NULL)
                AND ( x_server_id IS NULL)))
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
          AND           ((l_table_rec.type_id = x_type_id)
            OR ((l_table_rec.type_id IS NULL)
                AND ( x_type_id IS NULL)))
          AND           ((l_table_rec.server_name = x_server_name)
            OR ((l_table_rec.server_name IS NULL)
                AND ( x_server_name IS NULL)))
          AND           ((l_table_rec.member_svr_group_id = x_member_svr_group_id)
            OR ((l_table_rec.member_svr_group_id IS NULL)
                AND ( x_member_svr_group_id IS NULL)))
          AND           ((l_table_rec.using_svr_group_id = x_using_svr_group_id)
            OR ((l_table_rec.using_svr_group_id IS NULL)
                AND ( x_using_svr_group_id IS NULL)))
          AND           ((l_table_rec.dns_name = x_dns_name)
            OR ((l_table_rec.dns_name IS NULL)
                AND ( x_dns_name IS NULL)))
          AND           ((l_table_rec.ip_address = x_ip_address)
            OR ((l_table_rec.ip_address IS NULL)
                AND ( x_ip_address IS NULL)))
          AND           ((l_table_rec.location = x_location)
            OR ((l_table_rec.location IS NULL)
                AND ( x_location IS NULL)))
          AND           ((l_table_rec.description = x_description)
            OR ((l_table_rec.description IS NULL)
                AND ( x_description IS NULL)))
          AND           ((l_table_rec.user_address = x_user_address)
            OR ((l_table_rec.user_address IS NULL)
                AND ( x_user_address IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;
END ieo_svr_servers_pvt;

/
