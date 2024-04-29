--------------------------------------------------------
--  DDL for Package Body XLE_HISTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_HISTORIES_PKG" AS
/* $Header: xlehistb.pls 120.1 2005/07/26 17:10:23 shijain ship $ */

PROCEDURE Insert_Row(
    x_history_id IN OUT NOCOPY NUMBER,
    p_source_table IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL,
    p_source_column_name IN VARCHAR2 DEFAULT NULL,
    p_source_column_value IN VARCHAR2 DEFAULT NULL,
    p_effective_from IN DATE DEFAULT NULL,
    p_effective_to IN DATE DEFAULT NULL,
    p_comment IN VARCHAR2 DEFAULT NULL,
    p_last_update_date IN DATE DEFAULT NULL,
    p_last_updated_by IN NUMBER DEFAULT NULL,
    p_creation_date IN DATE DEFAULT NULL,
    p_created_by IN NUMBER DEFAULT NULL,
    p_last_update_login IN NUMBER DEFAULT NULL,
    p_object_version_number IN NUMBER
) IS
BEGIN
    INSERT INTO xle_histories (
        history_id,
        source_table,
        source_id,
        source_column_name,
        source_column_value,
        effective_from,
        effective_to,
        comments,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number
    ) VALUES (
        xle_histories_s.NEXTVAL,
        DECODE(p_source_table, FND_API.G_MISS_CHAR, NULL, p_source_table),
        DECODE(p_source_id, FND_API.G_MISS_NUM, NULL, p_source_id),
        DECODE(p_source_column_name, FND_API.G_MISS_CHAR, NULL, p_source_column_name),
        DECODE(p_source_column_value, FND_API.G_MISS_CHAR, NULL, p_source_column_value),
        DECODE(p_effective_from, NULL, XLE_UTILITY_PUB.LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_effective_from),
        DECODE(p_effective_to, FND_API.G_MISS_DATE, NULL, p_effective_to),
        DECODE(p_comment, FND_API.G_MISS_CHAR, NULL, p_comment),
        XLE_UTILITY_PUB.LAST_UPDATE_DATE,
        XLE_UTILITY_PUB.LAST_UPDATED_BY,
        XLE_UTILITY_PUB.CREATION_DATE,
        XLE_UTILITY_PUB.CREATED_BY,
        XLE_UTILITY_PUB.LAST_UPDATE_LOGIN,
        DECODE(p_object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number)
    ) RETURNING
        history_id
    INTO
        x_history_id;
END Insert_Row;

PROCEDURE Update_Row(
    p_history_id IN NUMBER,
    p_source_table IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL,
    p_source_column_name IN VARCHAR2 DEFAULT NULL,
    p_source_column_value IN VARCHAR2 DEFAULT NULL,
    p_effective_from IN DATE DEFAULT NULL,
    p_effective_to IN DATE DEFAULT NULL,
    p_comment IN VARCHAR2 DEFAULT NULL,
    p_last_update_date IN DATE DEFAULT NULL,
    p_last_updated_by IN NUMBER DEFAULT NULL,
    p_last_update_login IN NUMBER DEFAULT NULL,
    p_object_version_number IN NUMBER
) IS
BEGIN
    UPDATE xle_histories SET
        source_table = DECODE(p_source_table, NULL, source_table, FND_API.G_MISS_CHAR, NULL, p_source_table),
        source_id = DECODE(p_source_id, NULL, source_id, FND_API.G_MISS_NUM, NULL, p_source_id),
        source_column_name = DECODE(p_source_column_name, NULL, source_column_name, FND_API.G_MISS_CHAR, NULL, p_source_column_name),
        source_column_value = DECODE(p_source_column_value, NULL, source_column_value, FND_API.G_MISS_CHAR, NULL, p_source_column_value),
        effective_from = DECODE(p_effective_from, NULL, effective_from, FND_API.G_MISS_DATE, NULL, p_effective_from),
        effective_to = DECODE(p_effective_to, NULL, effective_to, FND_API.G_MISS_DATE, NULL, p_effective_to),
        comments = DECODE(p_comment, NULL, comments, FND_API.G_MISS_CHAR, NULL, p_comment),
        last_update_date = XLE_UTILITY_PUB.LAST_UPDATE_DATE,
        last_updated_by = XLE_UTILITY_PUB.LAST_UPDATED_BY,
        last_update_login = XLE_UTILITY_PUB.LAST_UPDATE_LOGIN,
        object_version_number= DECODE(p_object_version_number, NULL, object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number)
    WHERE history_id = p_history_id;

    IF (sql%notfound) THEN
        RAISE no_data_found;
    END IF;
END Update_Row;

PROCEDURE Delete_Row(p_history_id IN NUMBER) IS
BEGIN
    DELETE FROM xle_histories
    WHERE history_id = p_history_id;

    IF (sql%notfound) THEN
        RAISE no_data_found;
    END IF;
END Delete_Row;

PROCEDURE Lock_Row(
    p_history_id IN NUMBER,
    p_source_table IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL,
    p_source_column_name IN VARCHAR2 DEFAULT NULL,
    p_source_column_value IN VARCHAR2 DEFAULT NULL,
    p_effective_from IN DATE DEFAULT NULL,
    p_effective_to IN DATE DEFAULT NULL,
    p_comment IN VARCHAR2 DEFAULT NULL,
    p_last_update_date IN DATE DEFAULT NULL,
    p_last_updated_by IN NUMBER DEFAULT NULL,
    p_creation_date IN DATE DEFAULT NULL,
    p_created_by IN NUMBER DEFAULT NULL,
    p_last_update_login IN NUMBER DEFAULT NULL,
    p_object_version_number IN NUMBER
) IS
    CURSOR C IS
        SELECT * FROM xle_histories
        WHERE history_id = p_history_id
        FOR UPDATE OF history_id NOWAIT;
    Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

    IF (
        (Recinfo.history_id = p_history_id)
        AND ( (Recinfo.source_table = p_source_table)
            OR ( (Recinfo.source_table IS NULL)
                AND (p_source_table IS NULL)))
        AND ( (Recinfo.source_id= p_source_id)
            OR ( (Recinfo.source_id IS NULL)
                AND (p_source_id IS NULL)))
        AND ( (Recinfo.source_column_name = p_source_column_name)
            OR ( (Recinfo.source_column_name IS NULL)
                AND (p_source_column_name IS NULL)))
        AND ( (Recinfo.source_column_value = p_source_column_value)
            OR ( (Recinfo.source_column_value IS NULL)
                AND (p_source_column_value IS NULL)))
        AND ( (Recinfo.effective_from = p_effective_from)
            OR ( (Recinfo.effective_from IS NULL)
                AND (p_effective_from IS NULL)))
        AND ( (Recinfo.effective_to = p_effective_to)
            OR ( (Recinfo.effective_to IS NULL)
                AND (p_effective_to IS NULL)))
        AND ( (Recinfo.comments = p_comment)
            OR ( (Recinfo.comments IS NULL)
                AND (p_comment IS NULL)))
        AND ( (Recinfo.last_update_date = p_last_update_date)
            OR ( (Recinfo.last_update_date IS NULL)
                AND (p_last_update_date IS NULL)))
        AND ( (Recinfo.last_updated_by = p_last_updated_by)
            OR ( (Recinfo.last_updated_by IS NULL)
                AND (p_last_updated_by IS NULL)))
        AND ( (Recinfo.creation_date = p_creation_date)
            OR ( (Recinfo.creation_date IS NULL)
                AND (p_creation_date IS NULL)))
        AND ( (Recinfo.created_by = p_created_by)
            OR ( (Recinfo.created_by IS NULL)
                AND (p_created_by IS NULL)))
        AND ( (Recinfo.last_update_login = p_last_update_login)
            OR ( (Recinfo.last_update_login IS NULL)
                AND (p_last_update_login IS NULL)))
        AND ( (Recinfo.object_version_number = p_object_version_number)
            OR ( (Recinfo.object_version_number IS NULL)
                AND (p_object_version_number IS NULL)))
       ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
    END IF;
END Lock_Row;

END XLE_Histories_PKG;


/
