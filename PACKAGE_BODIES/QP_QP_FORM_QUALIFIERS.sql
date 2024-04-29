--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_QUALIFIERS" AS
/* $Header: QPXFQPQB.pls 120.1 2005/06/27 04:58:11 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Qualifiers';

--  Global variables holding cached record.

g_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
g_db_QUALIFIERS_rec           QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_QUALIFIERS
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_QUALIFIERS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_qualifier_id                  IN  NUMBER
)
RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

PROCEDURE Clear_QUALIFIERS;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_qualifier_rule_id            IN NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value_to       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_datatype            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier_date_format         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_qualifier_number_format       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_precedence          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
--,   x_comparison_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_val_rec          QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_QUALIFIERS_rec.qualifier_rule_id            := p_qualifier_rule_id;
    l_QUALIFIERS_rec.attribute1                   := NULL;
    l_QUALIFIERS_rec.attribute10                  := NULL;
    l_QUALIFIERS_rec.attribute11                  := NULL;
    l_QUALIFIERS_rec.attribute12                  := NULL;
    l_QUALIFIERS_rec.attribute13                  := NULL;
    l_QUALIFIERS_rec.attribute14                  := NULL;
    l_QUALIFIERS_rec.attribute15                  := NULL;
    l_QUALIFIERS_rec.attribute2                   := NULL;
    l_QUALIFIERS_rec.attribute3                   := NULL;
    l_QUALIFIERS_rec.attribute4                   := NULL;
    l_QUALIFIERS_rec.attribute5                   := NULL;
    l_QUALIFIERS_rec.attribute6                   := NULL;
    l_QUALIFIERS_rec.attribute7                   := NULL;
    l_QUALIFIERS_rec.attribute8                   := NULL;
    l_QUALIFIERS_rec.attribute9                   := NULL;
    l_QUALIFIERS_rec.context                      := NULL;

    --  Set Operation to Create

    l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate QUALIFIERS table

    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES

    QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_x_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_QUALIFIERS_rec := l_x_QUALIFIERS_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_QUALIFIERS_rec.attribute1;
    x_attribute10                  := l_x_QUALIFIERS_rec.attribute10;
    x_attribute11                  := l_x_QUALIFIERS_rec.attribute11;
    x_attribute12                  := l_x_QUALIFIERS_rec.attribute12;
    x_attribute13                  := l_x_QUALIFIERS_rec.attribute13;
    x_attribute14                  := l_x_QUALIFIERS_rec.attribute14;
    x_attribute15                  := l_x_QUALIFIERS_rec.attribute15;
    x_attribute2                   := l_x_QUALIFIERS_rec.attribute2;
    x_attribute3                   := l_x_QUALIFIERS_rec.attribute3;
    x_attribute4                   := l_x_QUALIFIERS_rec.attribute4;
    x_attribute5                   := l_x_QUALIFIERS_rec.attribute5;
    x_attribute6                   := l_x_QUALIFIERS_rec.attribute6;
    x_attribute7                   := l_x_QUALIFIERS_rec.attribute7;
    x_attribute8                   := l_x_QUALIFIERS_rec.attribute8;
    x_attribute9                   := l_x_QUALIFIERS_rec.attribute9;
    x_comparison_operator_code     := l_x_QUALIFIERS_rec.comparison_operator_code;
    x_context                      := l_x_QUALIFIERS_rec.context;
    x_created_from_rule_id         := l_x_QUALIFIERS_rec.created_from_rule_id;
    x_end_date_active              := l_x_QUALIFIERS_rec.end_date_active;
    x_excluder_flag                := l_x_QUALIFIERS_rec.excluder_flag;
    x_list_header_id               := l_x_QUALIFIERS_rec.list_header_id;
    x_list_line_id                 := l_x_QUALIFIERS_rec.list_line_id;
    x_qualifier_attribute          := l_x_QUALIFIERS_rec.qualifier_attribute;
    x_qualifier_attr_value         := l_x_QUALIFIERS_rec.qualifier_attr_value;
    x_qualifier_attr_value_to    := l_x_QUALIFIERS_rec.qualifier_attr_value_to;
    x_qualifier_context            := l_x_QUALIFIERS_rec.qualifier_context;
    x_qualifier_datatype           := l_x_QUALIFIERS_rec.qualifier_datatype;
    --x_qualifier_date_format        := l_x_QUALIFIERS_rec.qualifier_date_format;
    x_qualifier_grouping_no        := l_x_QUALIFIERS_rec.qualifier_grouping_no;
    x_qualifier_id                 := l_x_QUALIFIERS_rec.qualifier_id;
    --x_qualifier_number_format      := l_x_QUALIFIERS_rec.qualifier_number_format;
    x_qualifier_precedence         := l_x_QUALIFIERS_rec.qualifier_precedence;
    x_qualifier_rule_id            := l_x_QUALIFIERS_rec.qualifier_rule_id;
    x_start_date_active            := l_x_QUALIFIERS_rec.start_date_active;

    --  Load display out parameters if any

    l_QUALIFIERS_val_rec := QP_Qualifiers_Util.Get_Values
    (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
    );
    --x_comparison_operator          := l_QUALIFIERS_val_rec.comparison_operator;
    x_created_from_rule            := l_QUALIFIERS_val_rec.created_from_rule;
    --x_excluder                     := l_QUALIFIERS_val_rec.excluder;
    x_list_header                  := l_QUALIFIERS_val_rec.list_header;
    x_list_line                    := l_QUALIFIERS_val_rec.list_line;
   -- x_qualifier                    := l_QUALIFIERS_val_rec.qualifier;
    x_qualifier_rule               := l_QUALIFIERS_val_rec.qualifier_rule;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_QUALIFIERS_rec.db_flag := FND_API.G_FALSE;

    Write_QUALIFIERS
    (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_attr_value_to       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_datatype            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier_date_format         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_qualifier_number_format       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_precedence          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_qualifier_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
--,   x_comparison_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_created_from_rule             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_qualifier                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_qualifier_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_old_QUALIFIERS_rec          QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_val_rec          QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read QUALIFIERS from cache

    l_QUALIFIERS_rec := Get_QUALIFIERS
    (   p_db_record                   => FALSE
    ,   p_qualifier_id                => p_qualifier_id
    );

    l_old_QUALIFIERS_rec           := l_QUALIFIERS_rec;

    IF p_attr_id = QP_Qualifiers_Util.G_COMPARISON_OPERATOR THEN
        l_QUALIFIERS_rec.comparison_operator_code := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_CREATED_FROM_RULE THEN
        l_QUALIFIERS_rec.created_from_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Qualifiers_Util.G_END_DATE_ACTIVE THEN
        l_QUALIFIERS_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Qualifiers_Util.G_EXCLUDER THEN
        l_QUALIFIERS_rec.excluder_flag := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_LIST_HEADER THEN
        l_QUALIFIERS_rec.list_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Qualifiers_Util.G_LIST_LINE THEN
        l_QUALIFIERS_rec.list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_ATTRIBUTE THEN
        l_QUALIFIERS_rec.qualifier_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_ATTR_VALUE THEN
        l_QUALIFIERS_rec.qualifier_attr_value := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_ATTR_VALUE_TO THEN
        l_QUALIFIERS_rec.qualifier_attr_value_to := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_CONTEXT THEN
        l_QUALIFIERS_rec.qualifier_context := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_DATATYPE THEN
        l_QUALIFIERS_rec.qualifier_datatype := p_attr_value;
    --ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_DATE_FORMAT THEN
    --    l_QUALIFIERS_rec.qualifier_date_format := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_GROUPING_NO THEN
        l_QUALIFIERS_rec.qualifier_grouping_no := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER THEN
        l_QUALIFIERS_rec.qualifier_id := TO_NUMBER(p_attr_value);
    --ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_NUMBER_FORMAT THEN
    --    l_QUALIFIERS_rec.qualifier_number_format := p_attr_value;
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_PRECEDENCE THEN
        l_QUALIFIERS_rec.qualifier_precedence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFIER_RULE THEN
        l_QUALIFIERS_rec.qualifier_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Qualifiers_Util.G_START_DATE_ACTIVE THEN
        l_QUALIFIERS_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Qualifiers_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Qualifiers_Util.G_CONTEXT
    THEN

        l_QUALIFIERS_rec.attribute1    := p_attribute1;
        l_QUALIFIERS_rec.attribute10   := p_attribute10;
        l_QUALIFIERS_rec.attribute11   := p_attribute11;
        l_QUALIFIERS_rec.attribute12   := p_attribute12;
        l_QUALIFIERS_rec.attribute13   := p_attribute13;
        l_QUALIFIERS_rec.attribute14   := p_attribute14;
        l_QUALIFIERS_rec.attribute15   := p_attribute15;
        l_QUALIFIERS_rec.attribute2    := p_attribute2;
        l_QUALIFIERS_rec.attribute3    := p_attribute3;
        l_QUALIFIERS_rec.attribute4    := p_attribute4;
        l_QUALIFIERS_rec.attribute5    := p_attribute5;
        l_QUALIFIERS_rec.attribute6    := p_attribute6;
        l_QUALIFIERS_rec.attribute7    := p_attribute7;
        l_QUALIFIERS_rec.attribute8    := p_attribute8;
        l_QUALIFIERS_rec.attribute9    := p_attribute9;
        l_QUALIFIERS_rec.context       := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_QUALIFIERS_rec.db_flag) THEN
        l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate QUALIFIERS table

    oe_debug_pub.add('before calling process qualifier rules from change attribute');
    oe_debug_pub.add('precedence is '||l_QUALIFIERS_rec.qualifier_precedence);





    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;
    l_old_QUALIFIERS_tbl(1) := l_old_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES






    QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   p_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_x_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_QUALIFIERS_rec := l_x_QUALIFIERS_tbl(1);

    --  Init OUT parameters to missing.

    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_comparison_operator_code     := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_created_from_rule_id         := FND_API.G_MISS_NUM;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_excluder_flag                := FND_API.G_MISS_CHAR;
    x_list_header_id               := FND_API.G_MISS_NUM;
    x_list_line_id                 := FND_API.G_MISS_NUM;
    x_qualifier_attribute          := FND_API.G_MISS_CHAR;
    x_qualifier_attr_value         := FND_API.G_MISS_CHAR;
    x_qualifier_attr_value_to      := FND_API.G_MISS_CHAR;
    x_qualifier_context            := FND_API.G_MISS_CHAR;
    x_qualifier_datatype           := FND_API.G_MISS_CHAR;
    --x_qualifier_date_format        := FND_API.G_MISS_CHAR;
    x_qualifier_grouping_no        := FND_API.G_MISS_NUM;
    x_qualifier_id                 := FND_API.G_MISS_NUM;
    --x_qualifier_number_format      := FND_API.G_MISS_CHAR;
    x_qualifier_precedence         := FND_API.G_MISS_NUM;
    x_qualifier_rule_id            := FND_API.G_MISS_NUM;
    x_start_date_active            := FND_API.G_MISS_DATE;
    --x_comparison_operator          := FND_API.G_MISS_CHAR;
    x_created_from_rule            := FND_API.G_MISS_CHAR;
    --x_excluder                     := FND_API.G_MISS_CHAR;
    x_list_header                  := FND_API.G_MISS_CHAR;
    x_list_line                    := FND_API.G_MISS_CHAR;
    --x_qualifier                    := FND_API.G_MISS_CHAR;
    x_qualifier_rule               := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_QUALIFIERS_val_rec := QP_Qualifiers_Util.Get_Values
    (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
    ,   p_old_QUALIFIERS_rec          => l_QUALIFIERS_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute1,
                            l_QUALIFIERS_rec.attribute1)
    THEN
        x_attribute1 := l_x_QUALIFIERS_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute10,
                            l_QUALIFIERS_rec.attribute10)
    THEN
        x_attribute10 := l_x_QUALIFIERS_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute11,
                            l_QUALIFIERS_rec.attribute11)
    THEN
        x_attribute11 := l_x_QUALIFIERS_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute12,
                            l_QUALIFIERS_rec.attribute12)
    THEN
        x_attribute12 := l_x_QUALIFIERS_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute13,
                            l_QUALIFIERS_rec.attribute13)
    THEN
        x_attribute13 := l_x_QUALIFIERS_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute14,
                            l_QUALIFIERS_rec.attribute14)
    THEN
        x_attribute14 := l_x_QUALIFIERS_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute15,
                            l_QUALIFIERS_rec.attribute15)
    THEN
        x_attribute15 := l_x_QUALIFIERS_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute2,
                            l_QUALIFIERS_rec.attribute2)
    THEN
        x_attribute2 := l_x_QUALIFIERS_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute3,
                            l_QUALIFIERS_rec.attribute3)
    THEN
        x_attribute3 := l_x_QUALIFIERS_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute4,
                            l_QUALIFIERS_rec.attribute4)
    THEN
        x_attribute4 := l_x_QUALIFIERS_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute5,
                            l_QUALIFIERS_rec.attribute5)
    THEN
        x_attribute5 := l_x_QUALIFIERS_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute6,
                            l_QUALIFIERS_rec.attribute6)
    THEN
        x_attribute6 := l_x_QUALIFIERS_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute7,
                            l_QUALIFIERS_rec.attribute7)
    THEN
        x_attribute7 := l_x_QUALIFIERS_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute8,
                            l_QUALIFIERS_rec.attribute8)
    THEN
        x_attribute8 := l_x_QUALIFIERS_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.attribute9,
                            l_QUALIFIERS_rec.attribute9)
    THEN
        x_attribute9 := l_x_QUALIFIERS_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.comparison_operator_code,
                            l_QUALIFIERS_rec.comparison_operator_code)
    THEN
        x_comparison_operator_code := l_x_QUALIFIERS_rec.comparison_operator_code;
     -- x_comparison_operator := l_QUALIFIERS_val_rec.comparison_operator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.context,
                            l_QUALIFIERS_rec.context)
    THEN
        x_context := l_x_QUALIFIERS_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.created_from_rule_id,
                            l_QUALIFIERS_rec.created_from_rule_id)
    THEN
        x_created_from_rule_id := l_x_QUALIFIERS_rec.created_from_rule_id;
        x_created_from_rule := l_QUALIFIERS_val_rec.created_from_rule;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.end_date_active,
                            l_QUALIFIERS_rec.end_date_active)
    THEN
        x_end_date_active := l_x_QUALIFIERS_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.excluder_flag,
                            l_QUALIFIERS_rec.excluder_flag)
    THEN
        x_excluder_flag := l_x_QUALIFIERS_rec.excluder_flag;
        --x_excluder := l_QUALIFIERS_val_rec.excluder;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.list_header_id,
                            l_QUALIFIERS_rec.list_header_id)
    THEN
        x_list_header_id := l_x_QUALIFIERS_rec.list_header_id;
        x_list_header := l_QUALIFIERS_val_rec.list_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.list_line_id,
                            l_QUALIFIERS_rec.list_line_id)
    THEN
        x_list_line_id := l_x_QUALIFIERS_rec.list_line_id;
        x_list_line := l_QUALIFIERS_val_rec.list_line;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_attribute,
                            l_QUALIFIERS_rec.qualifier_attribute)
    THEN
        x_qualifier_attribute := l_x_QUALIFIERS_rec.qualifier_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_attr_value,
                            l_QUALIFIERS_rec.qualifier_attr_value)
    THEN
        x_qualifier_attr_value := l_x_QUALIFIERS_rec.qualifier_attr_value;
    END IF;
    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_attr_value_to,
                            l_QUALIFIERS_rec.qualifier_attr_value_to)
    THEN
       x_qualifier_attr_value_to := l_x_QUALIFIERS_rec.qualifier_attr_value_to;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_context,
                            l_QUALIFIERS_rec.qualifier_context)
    THEN
        x_qualifier_context := l_x_QUALIFIERS_rec.qualifier_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_datatype,
                            l_QUALIFIERS_rec.qualifier_datatype)
    THEN
        x_qualifier_datatype := l_x_QUALIFIERS_rec.qualifier_datatype;
    END IF;

    /*IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_date_format,
                            l_QUALIFIERS_rec.qualifier_date_format)
    THEN
        x_qualifier_date_format := l_x_QUALIFIERS_rec.qualifier_date_format;
    END IF;*/

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_grouping_no,
                            l_QUALIFIERS_rec.qualifier_grouping_no)
    THEN
        x_qualifier_grouping_no := l_x_QUALIFIERS_rec.qualifier_grouping_no;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_id,
                            l_QUALIFIERS_rec.qualifier_id)
    THEN
        x_qualifier_id := l_x_QUALIFIERS_rec.qualifier_id;
        --x_qualifier := l_QUALIFIERS_val_rec.qualifier;
    END IF;

    /*IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_number_format,
                            l_QUALIFIERS_rec.qualifier_number_format)
    THEN
        x_qualifier_number_format := l_x_QUALIFIERS_rec.qualifier_number_format;
    END IF;*/

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_precedence,
                            l_QUALIFIERS_rec.qualifier_precedence)
    THEN
        x_qualifier_precedence := l_x_QUALIFIERS_rec.qualifier_precedence;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualifier_rule_id,
                            l_QUALIFIERS_rec.qualifier_rule_id)
    THEN
        x_qualifier_rule_id := l_x_QUALIFIERS_rec.qualifier_rule_id;
        x_qualifier_rule := l_QUALIFIERS_val_rec.qualifier_rule;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.start_date_active,
                            l_QUALIFIERS_rec.start_date_active)
    THEN
        x_start_date_active := l_x_QUALIFIERS_rec.start_date_active;
    END IF;


    --  Write to cache.

    Write_QUALIFIERS
    (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_old_QUALIFIERS_rec          QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read QUALIFIERS from cache

    l_old_QUALIFIERS_rec := Get_QUALIFIERS
    (   p_db_record                   => TRUE
    ,   p_qualifier_id                => p_qualifier_id
    );

    l_QUALIFIERS_rec := Get_QUALIFIERS
    (   p_db_record                   => FALSE
    ,   p_qualifier_id                => p_qualifier_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_QUALIFIERS_rec.db_flag) THEN
        l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate QUALIFIERS table

    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;
    l_old_QUALIFIERS_tbl(1) := l_old_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES


    oe_debug_pub.add('calling qualifers rule pvt from qulifiers form validate and write');
    oe_debug_pub.add('with record as id  '||l_QUALIFIERS_rec.qualifier_id);
    oe_debug_pub.add('with record as con  '||l_QUALIFIERS_rec.qualifier_context);
    oe_debug_pub.add('with record as attr  '||l_QUALIFIERS_rec.qualifier_attribute);
    oe_debug_pub.add('with record as val  '||l_QUALIFIERS_rec.qualifier_attr_value);
    oe_debug_pub.add('with record as precedence  '||l_QUALIFIERS_rec.qualifier_precedence);



    QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   p_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_x_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_QUALIFIERS_rec := l_x_QUALIFIERS_tbl(1);

    x_creation_date                := l_x_QUALIFIERS_rec.creation_date;
    x_created_by                   := l_x_QUALIFIERS_rec.created_by;
    x_last_update_date             := l_x_QUALIFIERS_rec.last_update_date;
    x_last_updated_by              := l_x_QUALIFIERS_rec.last_updated_by;
    x_last_update_login            := l_x_QUALIFIERS_rec.last_update_login;

    --  Clear QUALIFIERS record cache

    Clear_QUALIFIERS;

    --  Keep track of performed operations.

    l_old_QUALIFIERS_rec.operation := l_QUALIFIERS_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
)
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_QUALIFIERS_rec := Get_QUALIFIERS
    (   p_db_record                   => TRUE
    ,   p_qualifier_id                => p_qualifier_id
    );

    --  Set Operation.

    l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate QUALIFIERS table

    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES

    QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_x_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear QUALIFIERS record cache

    Clear_QUALIFIERS;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_QUALIFIERS;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES

    QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_QUALIFIER_RULES_rec         => l_x_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_comparison_operator_code      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_created_from_rule_id          IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_end_date_active               IN  DATE
,   p_excluder_flag                 IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_qualifier_attribute           IN  VARCHAR2
,   p_qualifier_attr_value          IN  VARCHAR2
,   p_qualifier_attr_value_to       IN  VARCHAR2
,   p_qualifier_context             IN  VARCHAR2
,   p_qualifier_datatype            IN  VARCHAR2
--,   p_qualifier_date_format         IN  VARCHAR2
,   p_qualifier_grouping_no         IN  NUMBER
,   p_qualifier_id                  IN  NUMBER
--,   p_qualifier_number_format       IN  VARCHAR2
,   p_qualifier_precedence          IN  NUMBER
,   p_qualifier_rule_id             IN  NUMBER
,   p_request_id                    IN  NUMBER
,   p_start_date_active             IN  DATE
)
IS
l_return_status               VARCHAR2(1);
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Load QUALIFIERS record

    l_QUALIFIERS_rec.attribute1    := p_attribute1;
    l_QUALIFIERS_rec.attribute10   := p_attribute10;
    l_QUALIFIERS_rec.attribute11   := p_attribute11;
    l_QUALIFIERS_rec.attribute12   := p_attribute12;
    l_QUALIFIERS_rec.attribute13   := p_attribute13;
    l_QUALIFIERS_rec.attribute14   := p_attribute14;
    l_QUALIFIERS_rec.attribute15   := p_attribute15;
    l_QUALIFIERS_rec.attribute2    := p_attribute2;
    l_QUALIFIERS_rec.attribute3    := p_attribute3;
    l_QUALIFIERS_rec.attribute4    := p_attribute4;
    l_QUALIFIERS_rec.attribute5    := p_attribute5;
    l_QUALIFIERS_rec.attribute6    := p_attribute6;
    l_QUALIFIERS_rec.attribute7    := p_attribute7;
    l_QUALIFIERS_rec.attribute8    := p_attribute8;
    l_QUALIFIERS_rec.attribute9    := p_attribute9;
    l_QUALIFIERS_rec.comparison_operator_code := p_comparison_operator_code;
    l_QUALIFIERS_rec.context       := p_context;
    l_QUALIFIERS_rec.created_by    := p_created_by;
    l_QUALIFIERS_rec.created_from_rule_id := p_created_from_rule_id;
    l_QUALIFIERS_rec.creation_date := p_creation_date;
    l_QUALIFIERS_rec.end_date_active := p_end_date_active;
    l_QUALIFIERS_rec.excluder_flag := p_excluder_flag;
    l_QUALIFIERS_rec.last_updated_by := p_last_updated_by;
    l_QUALIFIERS_rec.last_update_date := p_last_update_date;
    l_QUALIFIERS_rec.last_update_login := p_last_update_login;
    l_QUALIFIERS_rec.list_header_id := p_list_header_id;
    l_QUALIFIERS_rec.list_line_id  := p_list_line_id;
    l_QUALIFIERS_rec.program_application_id := p_program_application_id;
    l_QUALIFIERS_rec.program_id    := p_program_id;
    l_QUALIFIERS_rec.program_update_date := p_program_update_date;
    l_QUALIFIERS_rec.qualifier_attribute := p_qualifier_attribute;
    l_QUALIFIERS_rec.qualifier_attr_value := p_qualifier_attr_value;
    l_QUALIFIERS_rec.qualifier_attr_value_to := p_qualifier_attr_value_to;
    l_QUALIFIERS_rec.qualifier_context := p_qualifier_context;
    l_QUALIFIERS_rec.qualifier_datatype := p_qualifier_datatype;
    --l_QUALIFIERS_rec.qualifier_date_format := p_qualifier_date_format;
    l_QUALIFIERS_rec.qualifier_grouping_no := p_qualifier_grouping_no;
    l_QUALIFIERS_rec.qualifier_id  := p_qualifier_id;
    --l_QUALIFIERS_rec.qualifier_number_format := p_qualifier_number_format;
    l_QUALIFIERS_rec.qualifier_precedence := p_qualifier_precedence;
    l_QUALIFIERS_rec.qualifier_rule_id := p_qualifier_rule_id;
    l_QUALIFIERS_rec.request_id    := p_request_id;
    l_QUALIFIERS_rec.start_date_active := p_start_date_active;

    --  Populate QUALIFIERS table

    l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_LOCK;
    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Lock_QUALIFIER_RULES


    --l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_LOCK;

    oe_debug_pub.add('calling privates lock row from QPXFQPQB.pls');

    QP_Qualifier_Rules_PVT.Lock_QUALIFIER_RULES
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_x_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_QUALIFIERS_rec.db_flag := FND_API.G_TRUE;

        Write_QUALIFIERS
        (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining QUALIFIERS record cache.

PROCEDURE Write_QUALIFIERS
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_QUALIFIERS_rec := p_QUALIFIERS_rec;

    IF p_db_record THEN

        g_db_QUALIFIERS_rec := p_QUALIFIERS_rec;

    END IF;

END Write_Qualifiers;

FUNCTION Get_QUALIFIERS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_qualifier_id                  IN  NUMBER
)
RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
IS
BEGIN

    OE_DEBUG_PUB.ADD('in Get qualifiers');

    IF  p_qualifier_id <> g_QUALIFIERS_rec.qualifier_id
    THEN

        --  Query row from DB

        g_QUALIFIERS_rec := QP_Qualifiers_Util.Query_Row
        (   p_qualifier_id                => p_qualifier_id
        );

        g_QUALIFIERS_rec.db_flag       := FND_API.G_TRUE;

        --  Load DB record

        g_db_QUALIFIERS_rec            := g_QUALIFIERS_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_QUALIFIERS_rec;
        OE_DEBUG_PUB.ADD('leaving  Get qualifiers');

    ELSE

        RETURN g_QUALIFIERS_rec;
        OE_DEBUG_PUB.ADD('leaving  Get qualifiers');

    END IF;




END Get_Qualifiers;

PROCEDURE Clear_Qualifiers
IS
BEGIN

    g_QUALIFIERS_rec               := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC;
    g_db_QUALIFIERS_rec            := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC;

END Clear_Qualifiers;



-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_id                  IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => QP_GLOBALS.G_ENTITY_QUALIFIERS
					,p_entity_id    => p_qualifier_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_qualifiers;

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Clear_Record'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Clear_Record;


-- This procedure will be called from the client when the user
-- clears a block or Form
Procedure Delete_All_Requests
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Clear_Request(
				     x_return_status => l_return_status);

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_All_Requests'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Delete_All_Requests;



END QP_QP_Form_Qualifiers;

/
