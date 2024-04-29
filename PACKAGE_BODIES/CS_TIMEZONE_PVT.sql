--------------------------------------------------------
--  DDL for Package Body CS_TIMEZONE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TIMEZONE_PVT" AS
/* $Header: cscttzob.pls 115.1 99/07/16 08:55:09 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_TIME_ZONES_S.nextval FROM SYS.DUAL;
      l_seq_id                       NUMBER := 0;
  BEGIN
    OPEN get_seq_id_csr;
    FETCH get_seq_id_csr INTO l_seq_id;
    CLOSE get_seq_id_csr;
    RETURN(l_seq_id);
  END get_seq_id;


  -- Validation
  FUNCTION Validate_Item_Attributes
  (
    p_timezone_rec IN  TimeZone_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_timezone_rec.name = TAPI_DEV_KIT.G_MISS_CHAR OR
       p_timezone_rec.name IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_timezone_rec.offset_time = TAPI_DEV_KIT.G_MISS_DATE OR
          p_timezone_rec.offset_time IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'offset_time');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_timezone_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_timezone_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_timezone_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_timezone_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_timezone_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_timezone_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_timezone_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_timezone_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_timezone_rec IN  TimeZone_Rec_Type,
    l_def_timezone_rec OUT  TimeZone_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_timezone_rec := p_timezone_rec;
    l_def_timezone_rec.OBJECT_VERSION_NUMBER := NVL(l_def_timezone_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_timezone_rec IN TimeZone_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN TimeZone_Val_Rec_Type,
    p_to	OUT TimeZone_Rec_Type
  ) IS
  BEGIN
    p_to.time_zone_id := p_from.time_zone_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.offset_indicator := p_from.offset_indicator;
    p_to.offset_time := p_from.offset_time;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.context := p_from.context;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE migrate (
    p_from	IN TimeZone_Rec_Type,
    p_to	OUT TimeZone_Val_Rec_Type
  ) IS
  BEGIN
    p_to.time_zone_id := p_from.time_zone_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.offset_indicator := p_from.offset_indicator;
    p_to.offset_time := p_from.offset_time;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.context := p_from.context;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_timezone_rec                 IN TimeZone_Rec_Type := G_MISS_TIMEZONE_REC,
    x_time_zone_id                 OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_timezone_rec                 TimeZone_Rec_Type;
    l_def_timezone_rec             TimeZone_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_timezone_rec := p_timezone_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_timezone_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_timezone_rec,    ---- IN
      l_def_timezone_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_timezone_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_timezone_rec.time_zone_id := get_seq_id;
    INSERT INTO CS_TIME_ZONES(
        time_zone_id,
        name,
        description,
        offset_indicator,
        offset_time,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        start_date_active,
        end_date_active,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        context,
        object_version_number)
      VALUES (
        l_def_timezone_rec.time_zone_id,
        l_def_timezone_rec.name,
        l_def_timezone_rec.description,
        l_def_timezone_rec.offset_indicator,
        l_def_timezone_rec.offset_time,
        l_def_timezone_rec.last_update_date,
        l_def_timezone_rec.last_updated_by,
        l_def_timezone_rec.creation_date,
        l_def_timezone_rec.created_by,
        l_def_timezone_rec.last_update_login,
        l_def_timezone_rec.start_date_active,
        l_def_timezone_rec.end_date_active,
        l_def_timezone_rec.attribute1,
        l_def_timezone_rec.attribute2,
        l_def_timezone_rec.attribute3,
        l_def_timezone_rec.attribute4,
        l_def_timezone_rec.attribute5,
        l_def_timezone_rec.attribute6,
        l_def_timezone_rec.attribute7,
        l_def_timezone_rec.attribute8,
        l_def_timezone_rec.attribute9,
        l_def_timezone_rec.attribute10,
        l_def_timezone_rec.attribute11,
        l_def_timezone_rec.attribute12,
        l_def_timezone_rec.attribute13,
        l_def_timezone_rec.attribute14,
        l_def_timezone_rec.attribute15,
        l_def_timezone_rec.context,
        l_def_timezone_rec.object_version_number);
    -- Set OUT values
    x_time_zone_id := l_def_timezone_rec.time_zone_id;
    x_object_version_number       := l_def_timezone_rec.OBJECT_VERSION_NUMBER;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_row;
  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_name                         IN CS_TIME_ZONES.NAME%TYPE := NULL,
    p_description                  IN CS_TIME_ZONES.DESCRIPTION%TYPE := NULL,
    p_offset_indicator             IN CS_TIME_ZONES.OFFSET_INDICATOR%TYPE := NULL,
    p_offset_time                  IN CS_TIME_ZONES.OFFSET_TIME%TYPE := NULL,
    p_last_update_date             IN CS_TIME_ZONES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_TIME_ZONES.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_start_date_active            IN CS_TIME_ZONES.START_DATE_ACTIVE%TYPE := NULL,
    p_end_date_active              IN CS_TIME_ZONES.END_DATE_ACTIVE%TYPE := NULL,
    p_attribute1                   IN CS_TIME_ZONES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_TIME_ZONES.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_TIME_ZONES.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_TIME_ZONES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_TIME_ZONES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_TIME_ZONES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_TIME_ZONES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_TIME_ZONES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_TIME_ZONES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_TIME_ZONES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_TIME_ZONES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_TIME_ZONES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_TIME_ZONES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_TIME_ZONES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_TIME_ZONES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_TIME_ZONES.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_time_zone_id                 OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_timezone_rec                 TimeZone_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_timezone_rec.NAME := p_name;
    l_timezone_rec.DESCRIPTION := p_description;
    l_timezone_rec.OFFSET_INDICATOR := p_offset_indicator;
    l_timezone_rec.OFFSET_TIME := p_offset_time;
    l_timezone_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_timezone_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_timezone_rec.CREATION_DATE := p_creation_date;
    l_timezone_rec.CREATED_BY := p_created_by;
    l_timezone_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_timezone_rec.START_DATE_ACTIVE := p_start_date_active;
    l_timezone_rec.END_DATE_ACTIVE := p_end_date_active;
    l_timezone_rec.ATTRIBUTE1 := p_attribute1;
    l_timezone_rec.ATTRIBUTE2 := p_attribute2;
    l_timezone_rec.ATTRIBUTE3 := p_attribute3;
    l_timezone_rec.ATTRIBUTE4 := p_attribute4;
    l_timezone_rec.ATTRIBUTE5 := p_attribute5;
    l_timezone_rec.ATTRIBUTE6 := p_attribute6;
    l_timezone_rec.ATTRIBUTE7 := p_attribute7;
    l_timezone_rec.ATTRIBUTE8 := p_attribute8;
    l_timezone_rec.ATTRIBUTE9 := p_attribute9;
    l_timezone_rec.ATTRIBUTE10 := p_attribute10;
    l_timezone_rec.ATTRIBUTE11 := p_attribute11;
    l_timezone_rec.ATTRIBUTE12 := p_attribute12;
    l_timezone_rec.ATTRIBUTE13 := p_attribute13;
    l_timezone_rec.ATTRIBUTE14 := p_attribute14;
    l_timezone_rec.ATTRIBUTE15 := p_attribute15;
    l_timezone_rec.CONTEXT := p_context;
    l_timezone_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_timezone_rec,
      x_time_zone_id,
      x_object_version_number
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_row;
  Procedure lock_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_time_zone_id                 IN NUMBER,
    p_object_version_number        IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_TIME_ZONES
    WHERE
      TIME_ZONE_ID = p_time_zone_id AND
      OBJECT_VERSION_NUMBER = p_object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_TIME_ZONES
    WHERE
      TIME_ZONE_ID = p_time_zone_id
      ;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       CS_TIME_ZONES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      CS_TIME_ZONES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr;
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr;
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number > p_object_version_number THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number <> p_object_version_number THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END lock_row;
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_timezone_val_rec             IN TimeZone_Val_Rec_Type := G_MISS_TIMEZONE_VAL_REC,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_timezone_rec                 TimeZone_Rec_Type;
    l_def_timezone_rec             TimeZone_Rec_Type;
    FUNCTION populate_new_record (
      p_timezone_rec	IN TimeZone_Rec_Type,
      x_timezone_rec	OUT TimeZone_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cs_time_zones_pk_csr (p_time_zone_id       IN NUMBER) IS
      SELECT *
        FROM Cs_Time_Zones
       WHERE cs_time_zones.time_zone_id = p_time_zone_id;
      l_cs_time_zones_pk             cs_time_zones_pk_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_timezone_rec := p_timezone_rec;
      -- Get current database values
      OPEN cs_time_zones_pk_csr (p_timezone_rec.time_zone_id);
      FETCH cs_time_zones_pk_csr INTO l_cs_time_zones_pk;
      l_row_notfound := cs_time_zones_pk_csr%NOTFOUND;
      CLOSE cs_time_zones_pk_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_timezone_rec.time_zone_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_timezone_rec.time_zone_id := l_cs_time_zones_pk.time_zone_id;
      END IF;
      IF (x_timezone_rec.name = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.name := l_cs_time_zones_pk.name;
      END IF;
      IF (x_timezone_rec.description = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.description := l_cs_time_zones_pk.description;
      END IF;
      IF (x_timezone_rec.offset_indicator = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.offset_indicator := l_cs_time_zones_pk.offset_indicator;
      END IF;
      IF (x_timezone_rec.offset_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_timezone_rec.offset_time := l_cs_time_zones_pk.offset_time;
      END IF;
      IF (x_timezone_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_timezone_rec.last_update_date := l_cs_time_zones_pk.last_update_date;
      END IF;
      IF (x_timezone_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_timezone_rec.last_updated_by := l_cs_time_zones_pk.last_updated_by;
      END IF;
      IF (x_timezone_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_timezone_rec.creation_date := l_cs_time_zones_pk.creation_date;
      END IF;
      IF (x_timezone_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_timezone_rec.created_by := l_cs_time_zones_pk.created_by;
      END IF;
      IF (x_timezone_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_timezone_rec.last_update_login := l_cs_time_zones_pk.last_update_login;
      END IF;
      IF (x_timezone_rec.start_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_timezone_rec.start_date_active := l_cs_time_zones_pk.start_date_active;
      END IF;
      IF (x_timezone_rec.end_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_timezone_rec.end_date_active := l_cs_time_zones_pk.end_date_active;
      END IF;
      IF (x_timezone_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute1 := l_cs_time_zones_pk.attribute1;
      END IF;
      IF (x_timezone_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute2 := l_cs_time_zones_pk.attribute2;
      END IF;
      IF (x_timezone_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute3 := l_cs_time_zones_pk.attribute3;
      END IF;
      IF (x_timezone_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute4 := l_cs_time_zones_pk.attribute4;
      END IF;
      IF (x_timezone_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute5 := l_cs_time_zones_pk.attribute5;
      END IF;
      IF (x_timezone_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute6 := l_cs_time_zones_pk.attribute6;
      END IF;
      IF (x_timezone_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute7 := l_cs_time_zones_pk.attribute7;
      END IF;
      IF (x_timezone_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute8 := l_cs_time_zones_pk.attribute8;
      END IF;
      IF (x_timezone_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute9 := l_cs_time_zones_pk.attribute9;
      END IF;
      IF (x_timezone_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute10 := l_cs_time_zones_pk.attribute10;
      END IF;
      IF (x_timezone_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute11 := l_cs_time_zones_pk.attribute11;
      END IF;
      IF (x_timezone_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute12 := l_cs_time_zones_pk.attribute12;
      END IF;
      IF (x_timezone_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute13 := l_cs_time_zones_pk.attribute13;
      END IF;
      IF (x_timezone_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute14 := l_cs_time_zones_pk.attribute14;
      END IF;
      IF (x_timezone_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.attribute15 := l_cs_time_zones_pk.attribute15;
      END IF;
      IF (x_timezone_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_timezone_rec.context := l_cs_time_zones_pk.context;
      END IF;
      IF (x_timezone_rec.object_version_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_timezone_rec.object_version_number := l_cs_time_zones_pk.object_version_number;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    migrate(p_timezone_val_rec, l_timezone_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_timezone_rec,    ---- IN
      l_def_timezone_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_timezone_rec, l_def_timezone_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_timezone_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_timezone_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_TIME_ZONES
    SET
        TIME_ZONE_ID = l_def_timezone_rec.time_zone_id ,
        NAME = l_def_timezone_rec.name ,
        DESCRIPTION = l_def_timezone_rec.description ,
        OFFSET_INDICATOR = l_def_timezone_rec.offset_indicator ,
        OFFSET_TIME = l_def_timezone_rec.offset_time ,
        LAST_UPDATE_DATE = l_def_timezone_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_timezone_rec.last_updated_by ,
        CREATION_DATE = l_def_timezone_rec.creation_date ,
        CREATED_BY = l_def_timezone_rec.created_by ,
        LAST_UPDATE_LOGIN = l_def_timezone_rec.last_update_login ,
        START_DATE_ACTIVE = l_def_timezone_rec.start_date_active ,
        END_DATE_ACTIVE = l_def_timezone_rec.end_date_active ,
        ATTRIBUTE1 = l_def_timezone_rec.attribute1 ,
        ATTRIBUTE2 = l_def_timezone_rec.attribute2 ,
        ATTRIBUTE3 = l_def_timezone_rec.attribute3 ,
        ATTRIBUTE4 = l_def_timezone_rec.attribute4 ,
        ATTRIBUTE5 = l_def_timezone_rec.attribute5 ,
        ATTRIBUTE6 = l_def_timezone_rec.attribute6 ,
        ATTRIBUTE7 = l_def_timezone_rec.attribute7 ,
        ATTRIBUTE8 = l_def_timezone_rec.attribute8 ,
        ATTRIBUTE9 = l_def_timezone_rec.attribute9 ,
        ATTRIBUTE10 = l_def_timezone_rec.attribute10 ,
        ATTRIBUTE11 = l_def_timezone_rec.attribute11 ,
        ATTRIBUTE12 = l_def_timezone_rec.attribute12 ,
        ATTRIBUTE13 = l_def_timezone_rec.attribute13 ,
        ATTRIBUTE14 = l_def_timezone_rec.attribute14 ,
        ATTRIBUTE15 = l_def_timezone_rec.attribute15 ,
        CONTEXT = l_def_timezone_rec.context ,
        OBJECT_VERSION_NUMBER = l_def_timezone_rec.object_version_number
        WHERE
          TIME_ZONE_ID = l_def_timezone_rec.time_zone_id
          ;
    x_object_version_number := l_def_timezone_rec.OBJECT_VERSION_NUMBER;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END update_row;
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_time_zone_id                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_TIME_ZONES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_TIME_ZONES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_offset_indicator             IN CS_TIME_ZONES.OFFSET_INDICATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_offset_time                  IN CS_TIME_ZONES.OFFSET_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_update_date             IN CS_TIME_ZONES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_TIME_ZONES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_TIME_ZONES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_TIME_ZONES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_TIME_ZONES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_TIME_ZONES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_TIME_ZONES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_TIME_ZONES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_TIME_ZONES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_TIME_ZONES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_TIME_ZONES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_TIME_ZONES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_TIME_ZONES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_TIME_ZONES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_TIME_ZONES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_TIME_ZONES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_TIME_ZONES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_TIME_ZONES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_TIME_ZONES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_TIME_ZONES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_timezone_rec                 TimeZone_Val_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_timezone_rec.TIME_ZONE_ID := p_time_zone_id;
    l_timezone_rec.NAME := p_name;
    l_timezone_rec.DESCRIPTION := p_description;
    l_timezone_rec.OFFSET_INDICATOR := p_offset_indicator;
    l_timezone_rec.OFFSET_TIME := p_offset_time;
    l_timezone_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_timezone_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_timezone_rec.CREATION_DATE := p_creation_date;
    l_timezone_rec.CREATED_BY := p_created_by;
    l_timezone_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_timezone_rec.START_DATE_ACTIVE := p_start_date_active;
    l_timezone_rec.END_DATE_ACTIVE := p_end_date_active;
    l_timezone_rec.ATTRIBUTE1 := p_attribute1;
    l_timezone_rec.ATTRIBUTE2 := p_attribute2;
    l_timezone_rec.ATTRIBUTE3 := p_attribute3;
    l_timezone_rec.ATTRIBUTE4 := p_attribute4;
    l_timezone_rec.ATTRIBUTE5 := p_attribute5;
    l_timezone_rec.ATTRIBUTE6 := p_attribute6;
    l_timezone_rec.ATTRIBUTE7 := p_attribute7;
    l_timezone_rec.ATTRIBUTE8 := p_attribute8;
    l_timezone_rec.ATTRIBUTE9 := p_attribute9;
    l_timezone_rec.ATTRIBUTE10 := p_attribute10;
    l_timezone_rec.ATTRIBUTE11 := p_attribute11;
    l_timezone_rec.ATTRIBUTE12 := p_attribute12;
    l_timezone_rec.ATTRIBUTE13 := p_attribute13;
    l_timezone_rec.ATTRIBUTE14 := p_attribute14;
    l_timezone_rec.ATTRIBUTE15 := p_attribute15;
    l_timezone_rec.CONTEXT := p_context;
    l_timezone_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_timezone_rec,
      x_object_version_number
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END update_row;
  Procedure delete_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_time_zone_id                 IN NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    DELETE  FROM CS_TIME_ZONES
    WHERE
      TIME_ZONE_ID = p_time_zone_id
      ;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END delete_row;
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_timezone_val_rec             IN TimeZone_Val_Rec_Type := G_MISS_TIMEZONE_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_timezone_rec                 TimeZone_Rec_Type;
    l_def_timezone_rec             TimeZone_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    migrate(p_timezone_val_rec, l_timezone_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_timezone_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_timezone_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END validate_row;
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_time_zone_id                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_TIME_ZONES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_TIME_ZONES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_offset_indicator             IN CS_TIME_ZONES.OFFSET_INDICATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_offset_time                  IN CS_TIME_ZONES.OFFSET_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_update_date             IN CS_TIME_ZONES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_TIME_ZONES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_TIME_ZONES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_TIME_ZONES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_TIME_ZONES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_TIME_ZONES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_TIME_ZONES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_TIME_ZONES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_TIME_ZONES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_TIME_ZONES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_TIME_ZONES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_TIME_ZONES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_TIME_ZONES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_TIME_ZONES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_TIME_ZONES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_TIME_ZONES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_TIME_ZONES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_TIME_ZONES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_TIME_ZONES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_TIME_ZONES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_timezone_rec                 TimeZone_Val_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_timezone_rec.TIME_ZONE_ID := p_time_zone_id;
    l_timezone_rec.NAME := p_name;
    l_timezone_rec.DESCRIPTION := p_description;
    l_timezone_rec.OFFSET_INDICATOR := p_offset_indicator;
    l_timezone_rec.OFFSET_TIME := p_offset_time;
    l_timezone_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_timezone_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_timezone_rec.CREATION_DATE := p_creation_date;
    l_timezone_rec.CREATED_BY := p_created_by;
    l_timezone_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_timezone_rec.START_DATE_ACTIVE := p_start_date_active;
    l_timezone_rec.END_DATE_ACTIVE := p_end_date_active;
    l_timezone_rec.ATTRIBUTE1 := p_attribute1;
    l_timezone_rec.ATTRIBUTE2 := p_attribute2;
    l_timezone_rec.ATTRIBUTE3 := p_attribute3;
    l_timezone_rec.ATTRIBUTE4 := p_attribute4;
    l_timezone_rec.ATTRIBUTE5 := p_attribute5;
    l_timezone_rec.ATTRIBUTE6 := p_attribute6;
    l_timezone_rec.ATTRIBUTE7 := p_attribute7;
    l_timezone_rec.ATTRIBUTE8 := p_attribute8;
    l_timezone_rec.ATTRIBUTE9 := p_attribute9;
    l_timezone_rec.ATTRIBUTE10 := p_attribute10;
    l_timezone_rec.ATTRIBUTE11 := p_attribute11;
    l_timezone_rec.ATTRIBUTE12 := p_attribute12;
    l_timezone_rec.ATTRIBUTE13 := p_attribute13;
    l_timezone_rec.ATTRIBUTE14 := p_attribute14;
    l_timezone_rec.ATTRIBUTE15 := p_attribute15;
    l_timezone_rec.CONTEXT := p_context;
    l_timezone_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_timezone_rec
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END validate_row;
END CS_TIMEZONE_PVT;

/
