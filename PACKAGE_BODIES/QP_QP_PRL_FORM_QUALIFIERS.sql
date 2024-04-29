--------------------------------------------------------
--  DDL for Package Body QP_QP_PRL_FORM_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_PRL_FORM_QUALIFIERS" AS
/* $Header: QPXFPLQB.pls 120.2 2005/08/31 18:06:39 srashmi noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_PRL_Form_Qualifiers';

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
(   p_qualifier_rule_id             IN  NUMBER := FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER := FND_API.G_MISS_NUM
,   p_qualifier_context             IN  VARCHAR2 := FND_API.G_MISS_CHAR
,   p_qualifier_attribute           IN  VARCHAR2 := FND_API.G_MISS_CHAR
,   p_qualifier_attr_value          IN  VARCHAR2 := FND_API.G_MISS_CHAR
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
,   x_qualify_hier_descendent_flag OUT NOCOPY VARCHAR2   -- Added for TCA
)
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_val_rec          QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_qualifier_group_no          number := -1;
BEGIN

    --  Set control flags.

    oe_debug_pub.add('Ren: inside default attr of qualifiers 1');

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


    l_QUALIFIERS_rec.list_header_id              := p_list_header_id;
    l_QUALIFIERS_rec.qualifier_rule_id           := p_qualifier_rule_id;
    l_QUALIFIERS_rec.qualifier_context           := p_qualifier_context;
    l_QUALIFIERS_rec.qualifier_attribute         := p_qualifier_attribute;
    l_QUALIFIERS_rec.qualifier_attr_value        := p_qualifier_attr_value;
    l_QUALIFIERS_rec.qualifier_grouping_no       := l_qualifier_group_no;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

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

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

  /*
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

    */


    oe_debug_pub.add('Ren: after process qualifier rules');

    oe_debug_pub.add('return status is : ' || l_return_status);

    oe_debug_pub.add('ren : msg data is : ' || x_msg_data);

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
    x_qualify_hier_descendent_flag := l_x_QUALIFIERS_rec.qualify_hier_descendent_flag ;  -- Added for TCA

    --  Load display out parameters if any

    oe_debug_pub.add('Ren: before get_values');
    oe_debug_pub.add('ren : msg data 0.5 is : ' || x_msg_data);

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

    oe_debug_pub.add('Ren: after get_values ');

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_QUALIFIERS_rec.db_flag := FND_API.G_FALSE;

    oe_debug_pub.add('Ren: before write qualifiers');
    oe_debug_pub.add('Ren: msg data 1 is :' || x_msg_data);

    Write_QUALIFIERS
    (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
    );
    oe_debug_pub.add('Ren: msg data 2 is :' || x_msg_data);

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    oe_debug_pub.add('Ren: msg data 2.5 is :' || x_msg_data);

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Ren: msg data 3 is :' || x_msg_data);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   x_qualify_hier_descendent_flag OUT NOCOPY VARCHAR2  -- Added for TCA
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
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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
-- Added for TCA
    ELSIF p_attr_id = QP_Qualifiers_Util.G_QUALIFY_HIER_DESCENDENT_FLAG THEN
        l_QUALIFIERS_rec.qualify_hier_descendent_flag := p_attr_value;
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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
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

    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;
    l_old_QUALIFIERS_tbl(1) := l_old_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Process_QUALIFIER_RULES

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   p_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

/*
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

*/

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
    x_qualify_hier_descendent_flag := FND_API.G_MISS_CHAR; -- Added for TCA

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
   -- Added for TCA
    IF NOT QP_GLOBALS.Equal(l_x_QUALIFIERS_rec.qualify_hier_descendent_flag,
                            l_QUALIFIERS_rec.qualify_hier_descendent_flag)
    THEN
        x_qualify_hier_descendent_flag := l_x_QUALIFIERS_rec.qualify_hier_descendent_flag;
    END IF;


    --  Write to cache.

    Write_QUALIFIERS
    (   p_QUALIFIERS_rec              => l_x_QUALIFIERS_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   x_program_application_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_update_date           OUT NOCOPY /* file.sql.39 change */ DATE
,   x_request_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
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
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

   oe_debug_pub.add('in v and write 1');

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

   oe_debug_pub.add('in v and write 2');
    l_old_QUALIFIERS_rec := Get_QUALIFIERS
    (   p_db_record                   => TRUE
    ,   p_qualifier_id                => p_qualifier_id
    );
   oe_debug_pub.add('in v and write 3');

    l_QUALIFIERS_rec := Get_QUALIFIERS
    (   p_db_record                   => FALSE
    ,   p_qualifier_id                => p_qualifier_id
    );
   oe_debug_pub.add('in v and write 4');

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
   oe_debug_pub.add('in v and write 5');

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   p_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );
   oe_debug_pub.add('in v and write 6');

    /*

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

    */

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   oe_debug_pub.add('in v and write 7');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
   oe_debug_pub.add('in v and write 8');
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_QUALIFIERS_rec := l_x_QUALIFIERS_tbl(1);

    x_creation_date                := l_x_QUALIFIERS_rec.creation_date;
    x_created_by                   := l_x_QUALIFIERS_rec.created_by;
    x_last_update_date             := l_x_QUALIFIERS_rec.last_update_date;
    x_last_updated_by              := l_x_QUALIFIERS_rec.last_updated_by;
    x_last_update_login            := l_x_QUALIFIERS_rec.last_update_login;
    x_program_application_id       := l_x_QUALIFIERS_rec.program_application_id;
    x_program_id                   := l_x_QUALIFIERS_rec.program_id;
    x_program_update_date          := l_x_QUALIFIERS_rec.program_update_date;
    x_request_id                   := l_x_QUALIFIERS_rec.request_id;

    --  Clear QUALIFIERS record cache

   oe_debug_pub.add('in v and write 9');
    Clear_QUALIFIERS;

    --  Keep track of performed operations.

    l_old_QUALIFIERS_rec.operation := l_QUALIFIERS_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data
   oe_debug_pub.add('in v and write 10; msg is : ' || x_msg_data);

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );
   oe_debug_pub.add('in v and write 11; msg is : ' || x_msg_data);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

   /*

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

    */

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

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

/*

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

*/

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   p_qualify_hier_descendent_flag IN VARCHAR2   -- Added for TCA
)
IS
l_return_status               VARCHAR2(1);
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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
    l_QUALIFIERS_rec.operation := QP_GLOBALS.G_OPR_LOCK;
    l_QUALIFIERS_rec.qualify_hier_descendent_flag := p_qualify_hier_descendent_flag;  -- Added for TCA

    --  Populate QUALIFIERS table

    l_QUALIFIERS_tbl(1) := l_QUALIFIERS_rec;

    --  Call QP_Qualifier_Rules_PVT.Lock_QUALIFIER_RULES

    QP_LIST_HEADERS_PVT.Lock_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

   /*

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

    */

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

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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

    ELSE

        RETURN g_QUALIFIERS_rec;

    END IF;

END Get_Qualifiers;

PROCEDURE Clear_Qualifiers
IS
BEGIN

    g_QUALIFIERS_rec               := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC;
    g_db_QUALIFIERS_rec            := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC;

END Clear_Qualifiers;

--spgopal  added out parameters to error out when copy failed
--and also display the number of qualifier records processed
PROCEDURE Get_Rules(p_qualifier_rule_id IN NUMBER,
                    p_list_header_id IN NUMBER,
				p_list_line_id IN NUMBER := NULL, -- -1,  --2422176
				p_group_condition IN VARCHAR2 DEFAULT 'AND',
				x_processed_qual_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
				x_msg_count    OUT NOCOPY /* file.sql.39 change */ NUMBER,
				x_msg_data     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
--x_msg_count  NUMBER;
--x_msg_data  VARCHAR2(2000);
l_return_status  VARCHAR2(1);
l_qualifier_rule_id number;
l_list_header_id number;
l_list_line_id number;
l_max_grouping_no NUMBER;
l_list_type_code  VARCHAR2(30);

l_QUALIFIER_RULES_rec          QP_Qualifier_Rules_pub.Qualifier_Rules_Rec_Type;
l_QUALIFIER_RULES_val_rec      QP_Qualifier_Rules_pub.Qualifier_Rules_Val_Rec_Type;
l_QUALIFIERS_tbl               QP_Qualifier_Rules_pub.Qualifiers_Tbl_Type;
l_QUALIFIERS_val_tbl           QP_Qualifier_Rules_pub.Qualifiers_Val_Tbl_Type;
l_x_qualifiers_tbl             QP_Qualifier_Rules_pub.Qualifiers_Tbl_Type;
l_x_qualifier_rules_rec        QP_Qualifier_Rules_pub.Qualifier_rules_rec_type;
l_x_qualifier_rules_val_rec    QP_Qualifier_Rules_pub.Qualifier_rules_val_rec_type;
l_x_qualifiers_val_tbl         QP_Qualifier_Rules_pub.Qualifiers_val_tbl_type;

BEGIN

  l_qualifier_rule_id := p_qualifier_rule_id;
  l_list_header_id := p_list_header_id;
  l_list_line_id := p_list_line_id;

  BEGIN
    select list_type_code
    into   l_list_type_code
    from   qp_list_headers_b
    where  list_header_id = p_list_header_id;
  EXCEPTION
    WHEN OTHERS THEN
	 l_list_type_code := '';
  END;

  qp_qualifier_rules_pub.get_qualifier_rules(
		p_api_version_number => 1.0,
		p_init_msg_list => 'F',
		p_return_values => 'F',
		x_return_status => l_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
                p_qualifier_rule_id => l_qualifier_rule_id,
 		x_qualifier_rules_rec => l_qualifier_rules_rec,
		x_qualifier_rules_val_rec => l_qualifier_rules_val_rec,
		x_qualifiers_tbl => l_qualifiers_tbl,
		x_qualifiers_val_tbl => l_qualifiers_val_tbl);

   oe_debug_pub.add('count of qualifiers table 1 : '  || l_qualifiers_tbl.count);

  IF p_group_condition = 'AND' THEN
    SELECT NVL(MAX(ABS(qualifier_grouping_no)),-1)
      INTO l_max_grouping_no
      FROM qp_qualifiers
     WHERE list_header_id = l_list_header_id;

/* In the case where grp no is 0, we need to add more than max) */
    l_max_grouping_no := l_max_grouping_no + 1;
oe_debug_pub.add('max grp no = '||l_max_grouping_no);
    FOR k IN 1..l_qualifiers_tbl.COUNT LOOP
		l_qualifiers_tbl(k).list_header_id := l_list_header_id;
		l_qualifiers_tbl(k).list_line_id := l_list_line_id;
		l_qualifiers_tbl(k).qualifier_rule_id := NULL;
		l_qualifiers_tbl(k).qualifier_id := FND_API.G_MISS_NUM;
		l_qualifiers_tbl(k).created_from_rule_id := l_qualifier_rule_id;

	 IF l_qualifiers_tbl(K).qualifier_grouping_no < 0 THEN
		IF l_qualifiers_tbl(K).qualifier_grouping_no = -1 THEN
		--we want to retain -1 group as it is
		NULL;
		ELSE
	   		l_qualifiers_tbl(K).qualifier_grouping_no := l_qualifiers_tbl(K).qualifier_grouping_no - l_max_grouping_no;
		oe_debug_pub.add('chg grp no = '||l_qualifiers_tbl(K).qualifier_grouping_no);
		END IF;
      ELSE
	   l_qualifiers_tbl(K).qualifier_grouping_no := l_qualifiers_tbl(K).qualifier_grouping_no + l_max_grouping_no;
oe_debug_pub.add('chg grp no = '||l_qualifiers_tbl(K).qualifier_grouping_no);
	 END IF;

	 IF NOT (l_list_type_code IN ('PRL','AGR') AND
		    l_qualifiers_tbl(K).qualifier_context = 'VOLUME' AND
		    l_qualifiers_tbl(K).qualifier_attribute = 'QUALIFIER_ATTRIBUTE10')
       --Qualifier Attribute of 'Order Amount' under qualifier context 'Volume'.
	 THEN
	   l_qualifiers_tbl(K).operation := 'CREATE';
	 ELSE
	   l_qualifiers_tbl(K).operation := '';
	 END IF;


/* Added for Bug 1754116 */
        If l_list_type_code = 'PRL' AND
           l_qualifiers_tbl(K).qualifier_context = 'MODLIST' AND
           l_qualifiers_tbl(K).qualifier_attribute = 'QUALIFIER_ATTRIBUTE4' Then
         l_qualifiers_tbl(K).operation := '';
        End If;
/* End of 1754116 */

        IF l_list_type_code IN ('PRL', 'AGR') AND
           QP_UTIL.Get_Segment_Level(l_list_header_id,
                             l_qualifiers_tbl(K).qualifier_context,
                             l_qualifiers_tbl(K).qualifier_attribute
                             ) = 'ORDER'
        THEN
	  l_qualifiers_tbl(K).operation := 'CREATE';
        END IF;

    END LOOP;
  ELSIF p_group_condition = 'OR' THEN
    FOR k IN 1..l_qualifiers_tbl.COUNT LOOP
	 l_qualifiers_tbl(k).list_header_id := l_list_header_id;
	 l_qualifiers_tbl(k).list_line_id := l_list_line_id;
	 l_qualifiers_tbl(k).qualifier_rule_id := NULL;
	 l_qualifiers_tbl(k).qualifier_id := FND_API.G_MISS_NUM;
	 l_qualifiers_tbl(k).created_from_rule_id := l_qualifier_rule_id;
	 IF NOT (l_list_type_code IN ('PRL','AGR') AND
		    l_qualifiers_tbl(K).qualifier_context = 'VOLUME' AND
		    l_qualifiers_tbl(K).qualifier_attribute = 'QUALIFIER_ATTRIBUTE10')
       --Qualifier Attribute of 'Order Amount' under qualifier context 'Volume'.
	 THEN
	   l_qualifiers_tbl(k).operation := 'CREATE';
	 ELSE
	   l_qualifiers_tbl(K).operation := '';
	 END IF;

         IF l_list_type_code IN ('PRL', 'AGR') AND
            QP_UTIL.Get_Segment_Level(l_list_header_id,
                              l_qualifiers_tbl(K).qualifier_context,
                              l_qualifiers_tbl(K).qualifier_attribute
                              ) = 'ORDER'
         THEN
 	   l_qualifiers_tbl(K).operation := '';
         END IF;

    END LOOP;
  END IF;

oe_debug_pub.add('before copy qual_rules');

  QP_QUALIFIER_RULES_PVT.PROCESS_QUALIFIER_RULES(
		  p_api_version_number => 1.0,
		  x_return_status => l_return_status,
		  x_msg_count => x_msg_count,
		  x_msg_data => x_msg_data,
		  p_qualifiers_tbl => l_qualifiers_tbl,
		  x_qualifier_rules_rec => l_x_qualifier_rules_rec,
		  x_qualifiers_tbl => l_x_qualifiers_tbl);

oe_debug_pub.add('after copy qual_rules');

	x_processed_qual_count := l_QUALIFIERS_tbl.COUNT;
	x_return_status := l_return_status;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      --  x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     --   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Rules'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );




END Get_Rules;

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


END QP_QP_PRL_Form_Qualifiers;

/
