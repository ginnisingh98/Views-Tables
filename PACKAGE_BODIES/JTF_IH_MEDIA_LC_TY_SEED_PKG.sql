--------------------------------------------------------
--  DDL for Package Body JTF_IH_MEDIA_LC_TY_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_MEDIA_LC_TY_SEED_PKG" AS
/* $Header: JTFIHMTB.pls 120.2 2005/07/08 07:55:37 nchouras ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_milcs_type_id                    NUMBER
        , x_object_version_number            NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_milcs_code                       VARCHAR2
        , x_short_description                VARCHAR2
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM jtf_ih_media_itm_lc_seg_tys
          WHERE milcs_type_id = x_milcs_type_id;
     BEGIN
        INSERT INTO jtf_ih_media_itm_lc_seg_tys (
          milcs_type_id
        , object_version_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        , milcs_code
        , short_description
        ) VALUES (
          x_milcs_type_id
        , DECODE(x_object_version_number,FND_API.G_MISS_NUM,NULL,x_object_version_number)
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_milcs_code,FND_API.G_MISS_CHAR,NULL,x_milcs_code)
        , DECODE(x_short_description,FND_API.G_MISS_CHAR,NULL,x_short_description)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_milcs_type_id                    NUMBER
     ) IS
     BEGIN
        DELETE FROM jtf_ih_media_itm_lc_seg_tys
        WHERE milcs_type_id = x_milcs_type_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_milcs_type_id                  NUMBER
        , x_object_version_number          NUMBER
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_milcs_code                     VARCHAR2
        , x_short_description              VARCHAR2
     ) IS
     BEGIN
        UPDATE jtf_ih_media_itm_lc_seg_tys
        SET
          milcs_type_id=DECODE(x_milcs_type_id,FND_API.G_MISS_NUM,NULL,x_milcs_type_id)
        , object_version_number=DECODE(x_object_version_number,FND_API.G_MISS_NUM,NULL,x_object_version_number)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , milcs_code=DECODE(x_milcs_code,FND_API.G_MISS_CHAR,NULL,x_milcs_code)
        , short_description=DECODE(x_short_description,FND_API.G_MISS_CHAR,NULL,x_short_description)
        WHERE milcs_type_id = x_milcs_type_id;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_milcs_type_id                  NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_milcs_code                     VARCHAR2
        , x_short_description              VARCHAR2
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM jtf_ih_media_itm_lc_seg_tys
          WHERE rowid = x_rowid
          FOR UPDATE OF milcs_type_id NOWAIT;
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
          ((l_table_rec.milcs_type_id = x_milcs_type_id)
            OR ((l_table_rec.milcs_type_id IS NULL)
                AND ( x_milcs_type_id IS NULL)))
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
          AND           ((l_table_rec.milcs_code = x_milcs_code)
            OR ((l_table_rec.milcs_code IS NULL)
                AND ( x_milcs_code IS NULL)))
          AND           ((l_table_rec.short_description = x_short_description)
            OR ((l_table_rec.short_description IS NULL)
                AND ( x_short_description IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;

     procedure LOAD_ROW (
  X_MILCS_TYPE_ID in NUMBER,
  X_MILCS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2
) IS
begin
declare
	user_id			NUMBER := 0;
	row_id			VARCHAR2(64);
	l_api_version		NUMBER := 1.0;
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(100);
	l_init_msg_list		VARCHAR2(1) := 'F';
	l_commit		VARCHAR2(1) := 'F';
	l_validation_level 	NUMBER := 100;
  	l_milcs_type_id 		NUMBER;
  	l_object_version_number NUMBER;
  	l_milcs_code		VARCHAR2(80);
  	l_short_description 	VARCHAR2(240);
	l_last_update_date	DATE;
	l_last_updated_by	NUMBER;
	l_last_update_login	NUMBER;
	l_creation_date		DATE;
	l_created_by		NUMBER;

begin
	--if (x_owner = 'SEED') then
	--	user_id := 1;
	--end if;
        user_id := fnd_load_util.owner_id(x_owner);
  	l_milcs_type_id  := X_MILCS_TYPE_ID;
  	l_object_version_number := 1;
  	l_milcs_code := X_MILCS_CODE;
  	l_short_description := X_SHORT_DESCRIPTION;
	l_last_update_date := sysdate;
	l_last_updated_by := user_id;
	l_last_update_login := 0;


	UPDATE_ROW(
  			X_MILCS_TYPE_ID => l_milcs_type_id,
			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_MILCS_CODE => l_milcs_code,
  			X_SHORT_DESCRIPTION => l_short_description,
  			X_LAST_UPDATE_DATE => l_last_update_date,
  			X_LAST_UPDATED_BY => l_last_updated_by,
  			X_LAST_UPDATE_LOGIN => l_last_update_login);
	EXCEPTION
		when no_data_found then
			l_creation_date := sysdate;
			l_created_by := user_id;
			INSERT_ROW(
			row_id,
  			X_MILCS_TYPE_ID => l_milcs_type_id,
  			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_MILCS_CODE => l_milcs_code,
  			X_SHORT_DESCRIPTION => l_short_description,
			X_CREATION_DATE => l_creation_date,
			X_CREATED_BY => l_created_by,
  			X_LAST_UPDATE_DATE => l_last_update_date,
  			X_LAST_UPDATED_BY => l_last_updated_by,
  			X_LAST_UPDATE_LOGIN => l_last_update_login);
	end;
end LOAD_ROW;


procedure LOAD_SEED_ROW (
  X_MILCS_TYPE_ID in NUMBER,
  X_MILCS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_UPLOAD_MODE in VARCHAR2
) IS
begin
	if (X_UPLOAD_MODE = 'NLS') then
     		null;
     	else
     		jtf_ih_media_lc_ty_seed_pkg.LOAD_ROW (
     			X_MILCS_TYPE_ID,
     			X_MILCS_CODE,
     			X_OBJECT_VERSION_NUMBER,
     			X_SHORT_DESCRIPTION,
     			X_OWNER);
	end if;

end LOAD_SEED_ROW;

END jtf_ih_media_lc_ty_seed_pkg;

/
