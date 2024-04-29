--------------------------------------------------------
--  DDL for Package Body QP_FNA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_FNA_UTIL" AS
/* $Header: QPXUFNAB.pls 120.3 2006/04/21 18:03:51 gtippire noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Fna_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
,   x_FNA_rec                       OUT NOCOPY QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_FNA_rec := p_FNA_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute1,p_old_FNA_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute10,p_old_FNA_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute11,p_old_FNA_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute12,p_old_FNA_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute13,p_old_FNA_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute14,p_old_FNA_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute15,p_old_FNA_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute2,p_old_FNA_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute3,p_old_FNA_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute4,p_old_FNA_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute5,p_old_FNA_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute6,p_old_FNA_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute7,p_old_FNA_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute8,p_old_FNA_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute9,p_old_FNA_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.context,p_old_FNA_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.created_by,p_old_FNA_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.creation_date,p_old_FNA_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.enabled_flag,p_old_FNA_rec.enabled_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.functional_area_id,p_old_FNA_rec.functional_area_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_FUNCTIONAL_AREA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.last_updated_by,p_old_FNA_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.last_update_date,p_old_FNA_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.last_update_login,p_old_FNA_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.program_application_id,p_old_FNA_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.program_id,p_old_FNA_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.program_update_date,p_old_FNA_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.pte_sourcesystem_fnarea_id,p_old_FNA_rec.pte_sourcesystem_fnarea_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PTE_SOURCESYSTEM_FNAREA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.pte_source_system_id,p_old_FNA_rec.pte_source_system_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PTE_SOURCE_SYSTEM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.request_id,p_old_FNA_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FNA_rec.seeded_flag,p_old_FNA_rec.seeded_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_SEEDED;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_ENABLED;
    ELSIF p_attr_id = G_FUNCTIONAL_AREA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_FUNCTIONAL_AREA;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_PTE_SOURCESYSTEM_FNAREA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PTE_SOURCESYSTEM_FNAREA;
    ELSIF p_attr_id = G_PTE_SOURCE_SYSTEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_PTE_SOURCE_SYSTEM;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_SEEDED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FNA_UTIL.G_SEEDED;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
,   p_called_from_ui                IN  VARCHAR2
,   x_FNA_rec                       OUT NOCOPY QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
l_dummy_ret_status            VARCHAR2(1);
BEGIN

    --  Load out record

    x_FNA_rec := p_FNA_rec;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute1,p_old_FNA_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute10,p_old_FNA_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute11,p_old_FNA_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute12,p_old_FNA_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute13,p_old_FNA_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute14,p_old_FNA_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute15,p_old_FNA_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute2,p_old_FNA_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute3,p_old_FNA_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute4,p_old_FNA_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute5,p_old_FNA_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute6,p_old_FNA_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute7,p_old_FNA_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute8,p_old_FNA_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.attribute9,p_old_FNA_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.context,p_old_FNA_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.created_by,p_old_FNA_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.creation_date,p_old_FNA_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.enabled_flag,p_old_FNA_rec.enabled_flag)
    THEN
      -- If enabled flag has been changed from 'Y', log DR to check for enabled
      --  functional area mappings

      IF p_old_FNA_rec.enabled_flag = 'Y' THEN
      qp_delayed_requests_PVT.log_request(
           p_entity_code => QP_GLOBALS.G_ENTITY_FNA,
           p_entity_id  => p_FNA_rec.pte_source_system_id,
           p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_FNA,
           p_requesting_entity_id => p_FNA_rec.pte_source_system_id,
           p_request_type => QP_GLOBALS.G_CHECK_ENABLED_FUNC_AREAS,
           x_return_status => l_dummy_ret_status);

      IF p_called_from_ui = 'N' THEN
        Warn_Disable_Delete_Fna
          ( p_action             => 'DISABLE'
          , p_called_from_ui     => p_called_from_ui
          , p_functional_area_id => p_FNA_rec.functional_area_id
          , p_pte_ss_id          => p_FNA_rec.pte_source_system_id
          );
      END IF;

      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.functional_area_id,p_old_FNA_rec.functional_area_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.last_updated_by,p_old_FNA_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.last_update_date,p_old_FNA_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.last_update_login,p_old_FNA_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.program_application_id,p_old_FNA_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.program_id,p_old_FNA_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.program_update_date,p_old_FNA_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.pte_sourcesystem_fnarea_id,p_old_FNA_rec.pte_sourcesystem_fnarea_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.pte_source_system_id,p_old_FNA_rec.pte_source_system_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.request_id,p_old_FNA_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FNA_rec.seeded_flag,p_old_FNA_rec.seeded_flag)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type
) RETURN QP_Attr_Map_PUB.Fna_Rec_Type
IS
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type := p_FNA_rec;
BEGIN

    IF l_FNA_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute1 := p_old_FNA_rec.attribute1;
    END IF;

    IF l_FNA_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute10 := p_old_FNA_rec.attribute10;
    END IF;

    IF l_FNA_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute11 := p_old_FNA_rec.attribute11;
    END IF;

    IF l_FNA_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute12 := p_old_FNA_rec.attribute12;
    END IF;

    IF l_FNA_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute13 := p_old_FNA_rec.attribute13;
    END IF;

    IF l_FNA_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute14 := p_old_FNA_rec.attribute14;
    END IF;

    IF l_FNA_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute15 := p_old_FNA_rec.attribute15;
    END IF;

    IF l_FNA_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute2 := p_old_FNA_rec.attribute2;
    END IF;

    IF l_FNA_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute3 := p_old_FNA_rec.attribute3;
    END IF;

    IF l_FNA_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute4 := p_old_FNA_rec.attribute4;
    END IF;

    IF l_FNA_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute5 := p_old_FNA_rec.attribute5;
    END IF;

    IF l_FNA_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute6 := p_old_FNA_rec.attribute6;
    END IF;

    IF l_FNA_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute7 := p_old_FNA_rec.attribute7;
    END IF;

    IF l_FNA_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute8 := p_old_FNA_rec.attribute8;
    END IF;

    IF l_FNA_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute9 := p_old_FNA_rec.attribute9;
    END IF;

    IF l_FNA_rec.context = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.context := p_old_FNA_rec.context;
    END IF;

    IF l_FNA_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FNA_rec.created_by := p_old_FNA_rec.created_by;
    END IF;

    IF l_FNA_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FNA_rec.creation_date := p_old_FNA_rec.creation_date;
    END IF;

    IF l_FNA_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.enabled_flag := p_old_FNA_rec.enabled_flag;
    END IF;

    IF l_FNA_rec.functional_area_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.functional_area_id := p_old_FNA_rec.functional_area_id;
    END IF;

    IF l_FNA_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FNA_rec.last_updated_by := p_old_FNA_rec.last_updated_by;
    END IF;

    IF l_FNA_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FNA_rec.last_update_date := p_old_FNA_rec.last_update_date;
    END IF;

    IF l_FNA_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FNA_rec.last_update_login := p_old_FNA_rec.last_update_login;
    END IF;

    IF l_FNA_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.program_application_id := p_old_FNA_rec.program_application_id;
    END IF;

    IF l_FNA_rec.program_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.program_id := p_old_FNA_rec.program_id;
    END IF;

    IF l_FNA_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_FNA_rec.program_update_date := p_old_FNA_rec.program_update_date;
    END IF;

    IF l_FNA_rec.pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.pte_sourcesystem_fnarea_id := p_old_FNA_rec.pte_sourcesystem_fnarea_id;
    END IF;

    IF l_FNA_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.pte_source_system_id := p_old_FNA_rec.pte_source_system_id;
    END IF;

    IF l_FNA_rec.request_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.request_id := p_old_FNA_rec.request_id;
    END IF;

    IF l_FNA_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.seeded_flag := p_old_FNA_rec.seeded_flag;
    END IF;

    RETURN l_FNA_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
) RETURN QP_Attr_Map_PUB.Fna_Rec_Type
IS
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type := p_FNA_rec;
BEGIN
    IF l_FNA_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute1 := NULL;
    END IF;

    IF l_FNA_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute10 := NULL;
    END IF;

    IF l_FNA_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute11 := NULL;
    END IF;

    IF l_FNA_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute12 := NULL;
    END IF;

    IF l_FNA_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute13 := NULL;
    END IF;

    IF l_FNA_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute14 := NULL;
    END IF;

    IF l_FNA_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute15 := NULL;
    END IF;

    IF l_FNA_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute2 := NULL;
    END IF;

    IF l_FNA_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute3 := NULL;
    END IF;

    IF l_FNA_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute4 := NULL;
    END IF;

    IF l_FNA_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute5 := NULL;
    END IF;

    IF l_FNA_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute6 := NULL;
    END IF;

    IF l_FNA_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute7 := NULL;
    END IF;

    IF l_FNA_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute8 := NULL;
    END IF;

    IF l_FNA_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.attribute9 := NULL;
    END IF;

    IF l_FNA_rec.context = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.context := NULL;
    END IF;

    IF l_FNA_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FNA_rec.created_by := NULL;
    END IF;

    IF l_FNA_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FNA_rec.creation_date := NULL;
    END IF;

    IF l_FNA_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.enabled_flag := NULL;
    END IF;

    IF l_FNA_rec.functional_area_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.functional_area_id := NULL;
    END IF;

    IF l_FNA_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FNA_rec.last_updated_by := NULL;
    END IF;

    IF l_FNA_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FNA_rec.last_update_date := NULL;
    END IF;

    IF l_FNA_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FNA_rec.last_update_login := NULL;
    END IF;

    IF l_FNA_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.program_application_id := NULL;
    END IF;

    IF l_FNA_rec.program_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.program_id := NULL;
    END IF;

    IF l_FNA_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_FNA_rec.program_update_date := NULL;
    END IF;

    IF l_FNA_rec.pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.pte_sourcesystem_fnarea_id := NULL;
    END IF;

    IF l_FNA_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.pte_source_system_id := NULL;
    END IF;

    IF l_FNA_rec.request_id = FND_API.G_MISS_NUM THEN
        l_FNA_rec.request_id := NULL;
    END IF;

    IF l_FNA_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_FNA_rec.seeded_flag := NULL;
    END IF;

    RETURN l_FNA_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
BEGIN

    UPDATE  QP_SOURCESYSTEM_FNAREA_MAP
    SET     ATTRIBUTE1                     = p_FNA_rec.attribute1
    ,       ATTRIBUTE10                    = p_FNA_rec.attribute10
    ,       ATTRIBUTE11                    = p_FNA_rec.attribute11
    ,       ATTRIBUTE12                    = p_FNA_rec.attribute12
    ,       ATTRIBUTE13                    = p_FNA_rec.attribute13
    ,       ATTRIBUTE14                    = p_FNA_rec.attribute14
    ,       ATTRIBUTE15                    = p_FNA_rec.attribute15
    ,       ATTRIBUTE2                     = p_FNA_rec.attribute2
    ,       ATTRIBUTE3                     = p_FNA_rec.attribute3
    ,       ATTRIBUTE4                     = p_FNA_rec.attribute4
    ,       ATTRIBUTE5                     = p_FNA_rec.attribute5
    ,       ATTRIBUTE6                     = p_FNA_rec.attribute6
    ,       ATTRIBUTE7                     = p_FNA_rec.attribute7
    ,       ATTRIBUTE8                     = p_FNA_rec.attribute8
    ,       ATTRIBUTE9                     = p_FNA_rec.attribute9
    ,       CONTEXT                        = p_FNA_rec.context
    ,       CREATED_BY                     = p_FNA_rec.created_by
    ,       CREATION_DATE                  = p_FNA_rec.creation_date
    ,       ENABLED_FLAG                   = p_FNA_rec.enabled_flag
    ,       FUNCTIONAL_AREA_ID             = p_FNA_rec.functional_area_id
    ,       LAST_UPDATED_BY                = p_FNA_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_FNA_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_FNA_rec.last_update_login
    ,       PROGRAM_APPLICATION_ID         = p_FNA_rec.program_application_id
    ,       PROGRAM_ID                     = p_FNA_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_FNA_rec.program_update_date
    ,       PTE_SOURCESYSTEM_FNAREA_ID     = p_FNA_rec.pte_sourcesystem_fnarea_id
    ,       PTE_SOURCE_SYSTEM_ID           = p_FNA_rec.pte_source_system_id
    ,       REQUEST_ID                     = p_FNA_rec.request_id
    ,       SEEDED_FLAG                    = p_FNA_rec.seeded_flag
    WHERE   PTE_SOURCESYSTEM_FNAREA_ID = p_FNA_rec.pte_sourcesystem_fnarea_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
BEGIN

    INSERT  INTO QP_SOURCESYSTEM_FNAREA_MAP
    (       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       FUNCTIONAL_AREA_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PTE_SOURCESYSTEM_FNAREA_ID
    ,       PTE_SOURCE_SYSTEM_ID
    ,       REQUEST_ID
    ,       SEEDED_FLAG
    )
    VALUES
    (       p_FNA_rec.attribute1
    ,       p_FNA_rec.attribute10
    ,       p_FNA_rec.attribute11
    ,       p_FNA_rec.attribute12
    ,       p_FNA_rec.attribute13
    ,       p_FNA_rec.attribute14
    ,       p_FNA_rec.attribute15
    ,       p_FNA_rec.attribute2
    ,       p_FNA_rec.attribute3
    ,       p_FNA_rec.attribute4
    ,       p_FNA_rec.attribute5
    ,       p_FNA_rec.attribute6
    ,       p_FNA_rec.attribute7
    ,       p_FNA_rec.attribute8
    ,       p_FNA_rec.attribute9
    ,       p_FNA_rec.context
    ,       p_FNA_rec.created_by
    ,       p_FNA_rec.creation_date
    ,       p_FNA_rec.enabled_flag
    ,       p_FNA_rec.functional_area_id
    ,       p_FNA_rec.last_updated_by
    ,       p_FNA_rec.last_update_date
    ,       p_FNA_rec.last_update_login
    ,       p_FNA_rec.program_application_id
    ,       p_FNA_rec.program_id
    ,       p_FNA_rec.program_update_date
    ,       p_FNA_rec.pte_sourcesystem_fnarea_id
    ,       p_FNA_rec.pte_source_system_id
    ,       p_FNA_rec.request_id
    ,       p_FNA_rec.seeded_flag
    );

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_pte_sourcesystem_fnarea_id    IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_SOURCESYSTEM_FNAREA_MAP
    WHERE   PTE_SOURCESYSTEM_FNAREA_ID = p_pte_sourcesystem_fnarea_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_pte_sourcesystem_fnarea_id    IN  NUMBER
) RETURN QP_Attr_Map_PUB.Fna_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_pte_sourcesystem_fnarea_id  => p_pte_sourcesystem_fnarea_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_pte_sourcesystem_fnarea_id    IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_pte_source_system_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Attr_Map_PUB.Fna_Tbl_Type
IS
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;
l_FNA_tbl                     QP_Attr_Map_PUB.Fna_Tbl_Type;

CURSOR l_FNA_csr IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       FUNCTIONAL_AREA_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PTE_SOURCESYSTEM_FNAREA_ID
    ,       PTE_SOURCE_SYSTEM_ID
    ,       REQUEST_ID
    ,       SEEDED_FLAG
    FROM    QP_SOURCESYSTEM_FNAREA_MAP
    WHERE ( PTE_SOURCESYSTEM_FNAREA_ID = p_pte_sourcesystem_fnarea_id
    )
    OR (    PTE_SOURCE_SYSTEM_ID = p_pte_source_system_id
    );

BEGIN

    IF
    (p_pte_sourcesystem_fnarea_id IS NOT NULL
     AND
     p_pte_sourcesystem_fnarea_id <> FND_API.G_MISS_NUM)
    AND
    (p_pte_source_system_id IS NOT NULL
     AND
     p_pte_source_system_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: pte_sourcesystem_fnarea_id = '|| p_pte_sourcesystem_fnarea_id || ', pte_source_system_id = '|| p_pte_source_system_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_FNA_csr LOOP

        l_FNA_rec.attribute1           := l_implicit_rec.ATTRIBUTE1;
        l_FNA_rec.attribute10          := l_implicit_rec.ATTRIBUTE10;
        l_FNA_rec.attribute11          := l_implicit_rec.ATTRIBUTE11;
        l_FNA_rec.attribute12          := l_implicit_rec.ATTRIBUTE12;
        l_FNA_rec.attribute13          := l_implicit_rec.ATTRIBUTE13;
        l_FNA_rec.attribute14          := l_implicit_rec.ATTRIBUTE14;
        l_FNA_rec.attribute15          := l_implicit_rec.ATTRIBUTE15;
        l_FNA_rec.attribute2           := l_implicit_rec.ATTRIBUTE2;
        l_FNA_rec.attribute3           := l_implicit_rec.ATTRIBUTE3;
        l_FNA_rec.attribute4           := l_implicit_rec.ATTRIBUTE4;
        l_FNA_rec.attribute5           := l_implicit_rec.ATTRIBUTE5;
        l_FNA_rec.attribute6           := l_implicit_rec.ATTRIBUTE6;
        l_FNA_rec.attribute7           := l_implicit_rec.ATTRIBUTE7;
        l_FNA_rec.attribute8           := l_implicit_rec.ATTRIBUTE8;
        l_FNA_rec.attribute9           := l_implicit_rec.ATTRIBUTE9;
        l_FNA_rec.context              := l_implicit_rec.CONTEXT;
        l_FNA_rec.created_by           := l_implicit_rec.CREATED_BY;
        l_FNA_rec.creation_date        := l_implicit_rec.CREATION_DATE;
        l_FNA_rec.enabled_flag         := l_implicit_rec.ENABLED_FLAG;
        l_FNA_rec.functional_area_id   := l_implicit_rec.FUNCTIONAL_AREA_ID;
        l_FNA_rec.last_updated_by      := l_implicit_rec.LAST_UPDATED_BY;
        l_FNA_rec.last_update_date     := l_implicit_rec.LAST_UPDATE_DATE;
        l_FNA_rec.last_update_login    := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_FNA_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_FNA_rec.program_id           := l_implicit_rec.PROGRAM_ID;
        l_FNA_rec.program_update_date  := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_FNA_rec.pte_sourcesystem_fnarea_id := l_implicit_rec.PTE_SOURCESYSTEM_FNAREA_ID;
        l_FNA_rec.pte_source_system_id := l_implicit_rec.PTE_SOURCE_SYSTEM_ID;
        l_FNA_rec.request_id           := l_implicit_rec.REQUEST_ID;
        l_FNA_rec.seeded_flag          := l_implicit_rec.SEEDED_FLAG;

        l_FNA_tbl(l_FNA_tbl.COUNT + 1) := l_FNA_rec;
    END LOOP;


    --  PK sent and no rows found

    IF
    (p_pte_sourcesystem_fnarea_id IS NOT NULL
     AND
     p_pte_sourcesystem_fnarea_id <> FND_API.G_MISS_NUM)
    AND
    (l_FNA_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_FNA_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   x_FNA_rec                       OUT NOCOPY QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;
BEGIN

    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       FUNCTIONAL_AREA_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PTE_SOURCESYSTEM_FNAREA_ID
    ,       PTE_SOURCE_SYSTEM_ID
    ,       REQUEST_ID
    ,       SEEDED_FLAG
    INTO    l_FNA_rec.attribute1
    ,       l_FNA_rec.attribute10
    ,       l_FNA_rec.attribute11
    ,       l_FNA_rec.attribute12
    ,       l_FNA_rec.attribute13
    ,       l_FNA_rec.attribute14
    ,       l_FNA_rec.attribute15
    ,       l_FNA_rec.attribute2
    ,       l_FNA_rec.attribute3
    ,       l_FNA_rec.attribute4
    ,       l_FNA_rec.attribute5
    ,       l_FNA_rec.attribute6
    ,       l_FNA_rec.attribute7
    ,       l_FNA_rec.attribute8
    ,       l_FNA_rec.attribute9
    ,       l_FNA_rec.context
    ,       l_FNA_rec.created_by
    ,       l_FNA_rec.creation_date
    ,       l_FNA_rec.enabled_flag
    ,       l_FNA_rec.functional_area_id
    ,       l_FNA_rec.last_updated_by
    ,       l_FNA_rec.last_update_date
    ,       l_FNA_rec.last_update_login
    ,       l_FNA_rec.program_application_id
    ,       l_FNA_rec.program_id
    ,       l_FNA_rec.program_update_date
    ,       l_FNA_rec.pte_sourcesystem_fnarea_id
    ,       l_FNA_rec.pte_source_system_id
    ,       l_FNA_rec.request_id
    ,       l_FNA_rec.seeded_flag
    FROM    QP_SOURCESYSTEM_FNAREA_MAP
    WHERE   PTE_SOURCESYSTEM_FNAREA_ID = p_FNA_rec.pte_sourcesystem_fnarea_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_FNA_rec.attribute1,
                         l_FNA_rec.attribute1)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute10,
                         l_FNA_rec.attribute10)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute11,
                         l_FNA_rec.attribute11)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute12,
                         l_FNA_rec.attribute12)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute13,
                         l_FNA_rec.attribute13)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute14,
                         l_FNA_rec.attribute14)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute15,
                         l_FNA_rec.attribute15)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute2,
                         l_FNA_rec.attribute2)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute3,
                         l_FNA_rec.attribute3)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute4,
                         l_FNA_rec.attribute4)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute5,
                         l_FNA_rec.attribute5)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute6,
                         l_FNA_rec.attribute6)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute7,
                         l_FNA_rec.attribute7)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute8,
                         l_FNA_rec.attribute8)
    AND QP_GLOBALS.Equal(p_FNA_rec.attribute9,
                         l_FNA_rec.attribute9)
    AND QP_GLOBALS.Equal(p_FNA_rec.context,
                         l_FNA_rec.context)
    AND QP_GLOBALS.Equal(p_FNA_rec.created_by,
                         l_FNA_rec.created_by)
    AND QP_GLOBALS.Equal(p_FNA_rec.creation_date,
                         l_FNA_rec.creation_date)
    AND QP_GLOBALS.Equal(p_FNA_rec.enabled_flag,
                         l_FNA_rec.enabled_flag)
    AND QP_GLOBALS.Equal(p_FNA_rec.functional_area_id,
                         l_FNA_rec.functional_area_id)
    AND QP_GLOBALS.Equal(p_FNA_rec.last_updated_by,
                         l_FNA_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_FNA_rec.last_update_date,
                         l_FNA_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_FNA_rec.last_update_login,
                         l_FNA_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_FNA_rec.program_application_id,
                         l_FNA_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_FNA_rec.program_id,
                         l_FNA_rec.program_id)
    AND QP_GLOBALS.Equal(p_FNA_rec.program_update_date,
                         l_FNA_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_FNA_rec.pte_sourcesystem_fnarea_id,
                         l_FNA_rec.pte_sourcesystem_fnarea_id)
    AND QP_GLOBALS.Equal(p_FNA_rec.pte_source_system_id,
                         l_FNA_rec.pte_source_system_id)
    AND QP_GLOBALS.Equal(p_FNA_rec.request_id,
                         l_FNA_rec.request_id)
    AND QP_GLOBALS.Equal(p_FNA_rec.seeded_flag,
                         l_FNA_rec.seeded_flag)
    THEN

        --  Row has not changed. Set out parameter.

        x_FNA_rec                      := l_FNA_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_FNA_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FNA_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FNA_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FNA_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_FNA_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
) RETURN QP_Attr_Map_PUB.Fna_Val_Rec_Type
IS
l_FNA_val_rec                 QP_Attr_Map_PUB.Fna_Val_Rec_Type;
BEGIN

    IF p_FNA_rec.enabled_flag IS NOT NULL AND
        p_FNA_rec.enabled_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_FNA_rec.enabled_flag,
        p_old_FNA_rec.enabled_flag)
    THEN
        l_FNA_val_rec.enabled := QP_Id_To_Value.Enabled
        (   p_enabled_flag                => p_FNA_rec.enabled_flag
        );
    END IF;

    IF p_FNA_rec.functional_area_id IS NOT NULL AND
        p_FNA_rec.functional_area_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FNA_rec.functional_area_id,
        p_old_FNA_rec.functional_area_id)
    THEN
        l_FNA_val_rec.functional_area := QP_Id_To_Value.Functional_Area
        (   p_functional_area_id          => p_FNA_rec.functional_area_id
        );
    END IF;

    IF p_FNA_rec.pte_sourcesystem_fnarea_id IS NOT NULL AND
        p_FNA_rec.pte_sourcesystem_fnarea_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FNA_rec.pte_sourcesystem_fnarea_id,
        p_old_FNA_rec.pte_sourcesystem_fnarea_id)
    THEN
      -- We comment this code out because we have a pte_sourcesystem_fnarea_id,
      --  but there is no corresponding value.  The code changes the value from
      --  G_MISS_CHAR to NULL, and this throws an "Invalid Item ID" error.
      NULL;
/*
       l_FNA_val_rec.pte_sourcesystem_fnarea := QP_Id_To_Value.Pte_Sourcesystem_Fnarea
        (   p_pte_sourcesystem_fnarea_id  => p_FNA_rec.pte_sourcesystem_fnarea_id
        );
*/
    END IF;


    IF p_FNA_rec.pte_source_system_id IS NOT NULL AND
        p_FNA_rec.pte_source_system_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FNA_rec.pte_source_system_id,
        p_old_FNA_rec.pte_source_system_id)
    THEN
        l_FNA_val_rec.pte_source_system := QP_Id_To_Value.Pte_Source_System
        (   p_pte_source_system_id        => p_FNA_rec.pte_source_system_id
        );
    END IF;


    IF p_FNA_rec.seeded_flag IS NOT NULL AND
        p_FNA_rec.seeded_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_FNA_rec.seeded_flag,
        p_old_FNA_rec.seeded_flag)
    THEN
        l_FNA_val_rec.seeded := QP_Id_To_Value.Seeded
        (   p_seeded_flag                 => p_FNA_rec.seeded_flag
        );
    END IF;

    RETURN l_FNA_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_FNA_val_rec                   IN  QP_Attr_Map_PUB.Fna_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Fna_Rec_Type
IS
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_FNA_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_FNA_rec.

    l_FNA_rec := p_FNA_rec;

    IF  p_FNA_val_rec.enabled <> FND_API.G_MISS_CHAR
    THEN

        IF p_FNA_rec.enabled_flag <> FND_API.G_MISS_CHAR THEN

            l_FNA_rec.enabled_flag := p_FNA_rec.enabled_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FNA_rec.enabled_flag := QP_Value_To_Id.enabled
            (   p_enabled                     => p_FNA_val_rec.enabled
            );

            IF l_FNA_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
                l_FNA_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FNA_val_rec.functional_area <> FND_API.G_MISS_CHAR
    THEN

        IF p_FNA_rec.functional_area_id <> FND_API.G_MISS_NUM THEN

            l_FNA_rec.functional_area_id := p_FNA_rec.functional_area_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','functional_area');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FNA_rec.functional_area_id := QP_Value_To_Id.functional_area
            (   p_functional_area             => p_FNA_val_rec.functional_area
            );

            IF l_FNA_rec.functional_area_id = FND_API.G_MISS_NUM THEN
                l_FNA_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FNA_val_rec.pte_sourcesystem_fnarea <> FND_API.G_MISS_CHAR
    THEN

        IF p_FNA_rec.pte_sourcesystem_fnarea_id <> FND_API.G_MISS_NUM THEN

            l_FNA_rec.pte_sourcesystem_fnarea_id := p_FNA_rec.pte_sourcesystem_fnarea_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_sourcesystem_fnarea');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FNA_rec.pte_sourcesystem_fnarea_id := QP_Value_To_Id.pte_sourcesystem_fnarea
            (   p_pte_sourcesystem_fnarea     => p_FNA_val_rec.pte_sourcesystem_fnarea
            );

            IF l_FNA_rec.pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM THEN
                l_FNA_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FNA_val_rec.pte_source_system <> FND_API.G_MISS_CHAR
    THEN

        IF p_FNA_rec.pte_source_system_id <> FND_API.G_MISS_NUM THEN

            l_FNA_rec.pte_source_system_id := p_FNA_rec.pte_source_system_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_source_system');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FNA_rec.pte_source_system_id := QP_Value_To_Id.pte_source_system
            (   p_pte_source_system           => p_FNA_val_rec.pte_source_system
            );

            IF l_FNA_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN
                l_FNA_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FNA_val_rec.seeded <> FND_API.G_MISS_CHAR
    THEN

        IF p_FNA_rec.seeded_flag <> FND_API.G_MISS_CHAR THEN

            l_FNA_rec.seeded_flag := p_FNA_rec.seeded_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FNA_rec.seeded_flag := QP_Value_To_Id.seeded
            (   p_seeded                      => p_FNA_val_rec.seeded
            );

            IF l_FNA_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
                l_FNA_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_FNA_rec;

END Get_Ids;


PROCEDURE Warn_Disable_Delete_Fna
( p_action IN VARCHAR2
, p_called_from_ui IN VARCHAR2
, p_functional_area_id NUMBER
, p_pte_ss_id IN NUMBER)
IS
l_action   VARCHAR2(40);
l_msg_name VARCHAR2(40);
l_pte      VARCHAR2(30);
l_ss       VARCHAR2(30);
l_fna_desc VARCHAR2(80);
BEGIN

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
    -- Get l_msg_name and l_action
    IF p_action = 'DELETE' OR
       p_action = 'DISABLE' THEN

      IF p_called_from_ui = 'Y' THEN
        l_msg_name := 'QP_WARN_DISABLE_FUNC_AREA_UI';
        FND_MESSAGE.set_name('QP', 'QP_' || p_action || 'D');
      ELSE
        l_msg_name := 'QP_WARN_DISABLE_FUNC_AREA_BOI' ;
        FND_MESSAGE.set_name('QP', 'QP_' || p_action || 'D');
      END IF;

      l_action := fnd_message.get;

    ELSE
      RETURN;
    END IF;

    -- Get PTE and SS
    select pte_code, application_short_name
    into l_pte, l_ss
    from qp_pte_source_systems
    where pte_source_system_id = p_pte_ss_id;

    -- Get Functional Area Description
    select functional_area_desc
    into l_fna_desc
    from qp_fass_v
    where functional_area_id = p_functional_area_id;

    -- Add Message
    FND_MESSAGE.set_name('QP', l_msg_name);
    FND_MESSAGE.set_token('ACTION', l_action);
    FND_MESSAGE.set_token('FNAREA', l_fna_desc);
    FND_MESSAGE.set_token('PTE', l_pte);
    FND_MESSAGE.set_token('SS', l_ss);
    OE_MSG_PUB.Add;
  END IF;

END Warn_Disable_Delete_Fna;


END QP_Fna_Util;

/
