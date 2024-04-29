--------------------------------------------------------
--  DDL for Package Body QP_PTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PTE_UTIL" AS
/* $Header: QPXUPTEB.pls 120.1 2005/06/12 23:51:52 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Pte_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PTE_rec := p_PTE_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.description,p_old_PTE_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_DESCRIPTION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.enabled_flag,p_old_PTE_rec.enabled_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.end_date_active,p_old_PTE_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.lookup_code,p_old_PTE_rec.lookup_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_LOOKUP;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.lookup_type,p_old_PTE_rec.lookup_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_LOOKUP_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.meaning,p_old_PTE_rec.meaning)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_MEANING;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PTE_rec.start_date_active,p_old_PTE_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_START_DATE_ACTIVE;
        END IF;

    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_DESCRIPTION;
    ELSIF p_attr_id = G_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_ENABLED;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_LOOKUP THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_LOOKUP;
    ELSIF p_attr_id = G_LOOKUP_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_LOOKUP_TYPE;
    ELSIF p_attr_id = G_MEANING THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_MEANING;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PTE_UTIL.G_START_DATE_ACTIVE;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_PTE_rec := p_PTE_rec;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.description,p_old_PTE_rec.description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.enabled_flag,p_old_PTE_rec.enabled_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.end_date_active,p_old_PTE_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.lookup_code,p_old_PTE_rec.lookup_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.lookup_type,p_old_PTE_rec.lookup_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.meaning,p_old_PTE_rec.meaning)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PTE_rec.start_date_active,p_old_PTE_rec.start_date_active)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type
IS
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type := p_PTE_rec;
BEGIN

    IF l_PTE_rec.description = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.description := p_old_PTE_rec.description;
    END IF;

    IF l_PTE_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.enabled_flag := p_old_PTE_rec.enabled_flag;
    END IF;

    IF l_PTE_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PTE_rec.end_date_active := p_old_PTE_rec.end_date_active;
    END IF;

    IF l_PTE_rec.lookup_code = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.lookup_code := p_old_PTE_rec.lookup_code;
    END IF;

    IF l_PTE_rec.lookup_type = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.lookup_type := p_old_PTE_rec.lookup_type;
    END IF;

    IF l_PTE_rec.meaning = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.meaning := p_old_PTE_rec.meaning;
    END IF;

    IF l_PTE_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PTE_rec.start_date_active := p_old_PTE_rec.start_date_active;
    END IF;

    RETURN l_PTE_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type
IS
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type := p_PTE_rec;
BEGIN

    IF l_PTE_rec.description = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.description := NULL;
    END IF;

    IF l_PTE_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.enabled_flag := NULL;
    END IF;

    IF l_PTE_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PTE_rec.end_date_active := NULL;
    END IF;

    IF l_PTE_rec.lookup_code = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.lookup_code := NULL;
    END IF;

    IF l_PTE_rec.lookup_type = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.lookup_type := NULL;
    END IF;

    IF l_PTE_rec.meaning = FND_API.G_MISS_CHAR THEN
        l_PTE_rec.meaning := NULL;
    END IF;

    IF l_PTE_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PTE_rec.start_date_active := NULL;
    END IF;

    RETURN l_PTE_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
BEGIN

   null;
/*
    UPDATE  QP_LOOKUPS
    SET     DESCRIPTION                    = p_PTE_rec.description
    ,       ENABLED_FLAG                   = p_PTE_rec.enabled_flag
    ,       END_DATE_ACTIVE                = p_PTE_rec.end_date_active
    ,       LOOKUP_CODE                    = p_PTE_rec.lookup_code
    ,       LOOKUP_TYPE                    = p_PTE_rec.lookup_type
    ,       MEANING                        = p_PTE_rec.meaning
    ,       START_DATE_ACTIVE              = p_PTE_rec.start_date_active
    WHERE   LOOKUP_CODE = p_PTE_rec.lookup_code
    ;
*/

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
BEGIN

    null;
/*
    INSERT  INTO QP_LOOKUPS
    (       DESCRIPTION
    ,       ENABLED_FLAG
    ,       END_DATE_ACTIVE
    ,       LOOKUP_CODE
    ,       LOOKUP_TYPE
    ,       MEANING
    ,       START_DATE_ACTIVE
    )
    VALUES
    (       p_PTE_rec.description
    ,       p_PTE_rec.enabled_flag
    ,       p_PTE_rec.end_date_active
    ,       p_PTE_rec.lookup_code
    ,       p_PTE_rec.lookup_type
    ,       p_PTE_rec.meaning
    ,       p_PTE_rec.start_date_active
    );
*/

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_lookup_code                   IN  VARCHAR2
)
IS
BEGIN
    null;
/*
    DELETE  FROM QP_LOOKUPS
    WHERE   LOOKUP_CODE = p_lookup_code
    ;
*/

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_lookup_code                   IN  VARCHAR2
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type
IS
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;
BEGIN

    SELECT  DESCRIPTION
    ,       ENABLED_FLAG
    ,       END_DATE_ACTIVE
    ,       LOOKUP_CODE
    ,       LOOKUP_TYPE
    ,       MEANING
    ,       START_DATE_ACTIVE
    INTO    l_PTE_rec.description
    ,       l_PTE_rec.enabled_flag
    ,       l_PTE_rec.end_date_active
    ,       l_PTE_rec.lookup_code
    ,       l_PTE_rec.lookup_type
    ,       l_PTE_rec.meaning
    ,       l_PTE_rec.start_date_active
    FROM    QP_LOOKUPS
    WHERE   LOOKUP_CODE = p_lookup_code
    ;

    RETURN l_PTE_rec;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;
BEGIN
    null;
/*
    SELECT  DESCRIPTION
    ,       ENABLED_FLAG
    ,       END_DATE_ACTIVE
    ,       LOOKUP_CODE
    ,       LOOKUP_TYPE
    ,       MEANING
    ,       START_DATE_ACTIVE
    INTO    l_PTE_rec.description
    ,       l_PTE_rec.enabled_flag
    ,       l_PTE_rec.end_date_active
    ,       l_PTE_rec.lookup_code
    ,       l_PTE_rec.lookup_type
    ,       l_PTE_rec.meaning
    ,       l_PTE_rec.start_date_active
    FROM    QP_LOOKUPS
    WHERE   LOOKUP_CODE = p_PTE_rec.lookup_code
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_PTE_rec.description,
                         l_PTE_rec.description)
    AND QP_GLOBALS.Equal(p_PTE_rec.enabled_flag,
                         l_PTE_rec.enabled_flag)
    AND QP_GLOBALS.Equal(p_PTE_rec.end_date_active,
                         l_PTE_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_PTE_rec.lookup_code,
                         l_PTE_rec.lookup_code)
    AND QP_GLOBALS.Equal(p_PTE_rec.lookup_type,
                         l_PTE_rec.lookup_type)
    AND QP_GLOBALS.Equal(p_PTE_rec.meaning,
                         l_PTE_rec.meaning)
    AND QP_GLOBALS.Equal(p_PTE_rec.start_date_active,
                         l_PTE_rec.start_date_active)
    THEN

        --  Row has not changed. Set out parameter.

        x_PTE_rec                      := l_PTE_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_PTE_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PTE_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;
*/
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PTE_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PTE_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PTE_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
) RETURN QP_Attr_Map_PUB.Pte_Val_Rec_Type
IS
l_PTE_val_rec                 QP_Attr_Map_PUB.Pte_Val_Rec_Type;
BEGIN

    IF p_PTE_rec.enabled_flag IS NOT NULL AND
        p_PTE_rec.enabled_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PTE_rec.enabled_flag,
        p_old_PTE_rec.enabled_flag)
    THEN
        l_PTE_val_rec.enabled := QP_Id_To_Value.Enabled
        (   p_enabled_flag                => p_PTE_rec.enabled_flag
        );
    END IF;

    IF p_PTE_rec.lookup_code IS NOT NULL AND
        p_PTE_rec.lookup_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PTE_rec.lookup_code,
        p_old_PTE_rec.lookup_code)
    THEN
        l_PTE_val_rec.lookup := QP_Id_To_Value.Lookup
        (   p_lookup_code                 => p_PTE_rec.lookup_code
        );
    END IF;

    RETURN l_PTE_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_PTE_val_rec                   IN  QP_Attr_Map_PUB.Pte_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type
IS
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PTE_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PTE_rec.

    l_PTE_rec := p_PTE_rec;

    IF  p_PTE_val_rec.enabled <> FND_API.G_MISS_CHAR
    THEN

        IF p_PTE_rec.enabled_flag <> FND_API.G_MISS_CHAR THEN

            l_PTE_rec.enabled_flag := p_PTE_rec.enabled_flag;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_PTE_rec.enabled_flag := QP_Value_To_Id.enabled
            (   p_enabled                     => p_PTE_val_rec.enabled
            );

            IF l_PTE_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
                l_PTE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PTE_val_rec.lookup <> FND_API.G_MISS_CHAR
    THEN

        IF p_PTE_rec.lookup_code <> FND_API.G_MISS_CHAR THEN

            l_PTE_rec.lookup_code := p_PTE_rec.lookup_code;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_PTE_rec.lookup_code := QP_Value_To_Id.lookup
            (   p_lookup                      => p_PTE_val_rec.lookup
            );

            IF l_PTE_rec.lookup_code = FND_API.G_MISS_CHAR THEN
                l_PTE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_PTE_rec;

END Get_Ids;

END QP_Pte_Util;

/
