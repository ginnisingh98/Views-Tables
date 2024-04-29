--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_PTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_PTE" AS
/* $Header: QPXLPTEB.pls 120.1 2005/06/09 00:01:33 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Pte';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_PTE_rec.lookup_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','description');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate PTE attributes

    IF  p_PTE_rec.description IS NOT NULL AND
        (   p_PTE_rec.description <>
            p_old_PTE_rec.description OR
            p_old_PTE_rec.description IS NULL )
    THEN
        IF NOT QP_Validate.Description(p_PTE_rec.description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PTE_rec.enabled_flag IS NOT NULL AND
        (   p_PTE_rec.enabled_flag <>
            p_old_PTE_rec.enabled_flag OR
            p_old_PTE_rec.enabled_flag IS NULL )
    THEN
        IF NOT QP_Validate.Enabled(p_PTE_rec.enabled_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PTE_rec.end_date_active IS NOT NULL AND
        (   p_PTE_rec.end_date_active <>
            p_old_PTE_rec.end_date_active OR
            p_old_PTE_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_PTE_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PTE_rec.lookup_code IS NOT NULL AND
        (   p_PTE_rec.lookup_code <>
            p_old_PTE_rec.lookup_code OR
            p_old_PTE_rec.lookup_code IS NULL )
    THEN
        IF NOT QP_Validate.Lookup(p_PTE_rec.lookup_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PTE_rec.lookup_type IS NOT NULL AND
        (   p_PTE_rec.lookup_type <>
            p_old_PTE_rec.lookup_type OR
            p_old_PTE_rec.lookup_type IS NULL )
    THEN
        IF NOT QP_Validate.Lookup_Type(p_PTE_rec.lookup_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PTE_rec.meaning IS NOT NULL AND
        (   p_PTE_rec.meaning <>
            p_old_PTE_rec.meaning OR
            p_old_PTE_rec.meaning IS NULL )
    THEN
        IF NOT QP_Validate.Meaning(p_PTE_rec.meaning) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PTE_rec.start_date_active IS NOT NULL AND
        (   p_PTE_rec.start_date_active <>
            p_old_PTE_rec.start_date_active OR
            p_old_PTE_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_PTE_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END QP_Validate_Pte;

/
