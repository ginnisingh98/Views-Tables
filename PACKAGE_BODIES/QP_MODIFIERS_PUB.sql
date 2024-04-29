--------------------------------------------------------
--  DDL for Package Body QP_MODIFIERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIERS_PUB" AS
/* $Header: QPXPMLSB.pls 120.8 2006/10/25 08:22:25 nirmkuma ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Modifiers_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_MODIFIER_LIST_rec             IN  Modifier_List_Rec_Type
,   p_MODIFIERS_tbl                 IN  Modifiers_Tbl_Type
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ Modifier_List_Val_Rec_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  Modifier_List_Rec_Type
,   p_MODIFIER_LIST_val_rec         IN  Modifier_List_Val_Rec_Type
,   p_MODIFIERS_tbl                 IN  Modifiers_Tbl_Type
,   p_MODIFIERS_val_tbl             IN  Modifiers_Val_Tbl_Type
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   p_QUALIFIERS_val_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type
,   p_PRICING_ATTR_val_tbl          IN  Pricing_Attr_Val_Tbl_Type
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
);

--  Start of Comments
--  API name    Process_Modifiers
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  Modifier_List_Rec_Type :=
                                        G_MISS_MODIFIER_LIST_REC
,   p_MODIFIER_LIST_val_rec         IN  Modifier_List_Val_Rec_Type :=
                                        G_MISS_MODIFIER_LIST_VAL_REC
,   p_MODIFIERS_tbl                 IN  Modifiers_Tbl_Type :=
                                        G_MISS_MODIFIERS_TBL
,   p_MODIFIERS_val_tbl             IN  Modifiers_Val_Tbl_Type :=
                                        G_MISS_MODIFIERS_VAL_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  Pricing_Attr_Val_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_VAL_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ Modifier_List_Rec_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ Modifier_List_Val_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ Modifiers_Tbl_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Modifiers';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_MODIFIER_LIST_rec           Modifier_List_Rec_Type;
l_p_MODIFIER_LIST_rec           Modifier_List_Rec_Type;
l_MODIFIERS_tbl               Modifiers_Tbl_Type;
l_p_MODIFIERS_tbl               Modifiers_Tbl_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            Pricing_Attr_Tbl_Type;
l_p_PRICING_ATTR_tbl            Pricing_Attr_Tbl_Type;
l_qp_status                   VARCHAR2(1);
l_request_type_code 	      VARCHAR2(3);
l_list_source_code            VARCHAR2(10); -- bug#3599792

BEGIN
       SAVEPOINT QP_Process_Modifiers;
    oe_debug_pub.add('BEGIN process_modifiers in Public');
    --dbms_output.put_line('BEGIN process_modifiers in Public');

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- BOI not available when QP not installed

    l_qp_status := QP_UTIL.GET_QP_STATUS;

    -- shulin, detect calls from FTE
    IF (QP_PRL_LOADER_PUB.G_PROCESS_LST_REQ_TYPE='FTE' or QP_MOD_LOADER_PUB.G_PROCESS_LST_REQ_TYPE='FTE' ) THEN
    	 l_request_type_code := 'FTE';
    END IF;

    IF l_qp_status = 'N' AND l_request_type_code <> 'FTE' -- shulin, 'FTE' should pass this exception
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_PRICING_NOT_INSTALLED');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
--    MO_GLOBAL.set_policy_context('M', null);--commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL

	-- bug#3599792/bug#3888568/#bug4261021
    IF p_MODIFIERS_tbl.COUNT <> 0 THEN
       IF p_MODIFIERS_tbl(1).list_header_id IS NOT NULL AND
          p_MODIFIERS_tbl(1).list_header_id <> FND_API.G_MISS_NUM THEN
        BEGIN
                select list_source_code into l_list_source_code
                from qp_list_headers_b
                where list_header_id = p_MODIFIERS_tbl(1).list_header_id;
        EXCEPTION
                WHEN OTHERS THEN
                 oe_debug_pub.add('MODIFIERS list_header_id : '||p_MODIFIERS_tbl(1).list_header_id);
                 IF p_MODIFIER_LIST_rec.list_source_code IS NOT NULL
                 AND p_MODIFIER_LIST_rec.list_source_code <> FND_API.G_MISS_CHAR
                 THEN
                    l_list_source_code := p_MODIFIER_LIST_rec.list_source_code;
                 END IF;
        END;
       ELSIF  p_MODIFIERS_tbl(1).list_line_id IS NOT NULL AND
              p_MODIFIERS_tbl(1).list_line_id <> FND_API.G_MISS_NUM THEN
        BEGIN
                select list_source_code into l_list_source_code
                from qp_list_headers_b
                where list_header_id = (select list_header_id from qp_list_lines
                                        where list_line_id = p_MODIFIERS_tbl(1).list_line_id);
        EXCEPTION
                WHEN OTHERS THEN
		 oe_debug_pub.add('MODIFIERS list_line_id : '|| p_MODIFIERS_tbl(1).list_line_id);
                 IF p_MODIFIER_LIST_rec.list_source_code IS NOT NULL
                 AND p_MODIFIER_LIST_rec.list_source_code <> FND_API.G_MISS_CHAR
                 THEN
                    l_list_source_code := p_MODIFIER_LIST_rec.list_source_code;
                 END IF;
        END;
       ELSE
	IF p_MODIFIER_LIST_rec.list_source_code IS NOT NULL
	AND p_MODIFIER_LIST_rec.list_source_code <> FND_API.G_MISS_CHAR
	THEN
	     l_list_source_code := p_MODIFIER_LIST_rec.list_source_code;
	END IF;
       END IF;
    ELSE
	IF p_MODIFIER_LIST_rec.list_source_code IS NOT NULL
	AND p_MODIFIER_LIST_rec.list_source_code <> FND_API.G_MISS_CHAR
	THEN
	     l_list_source_code := p_MODIFIER_LIST_rec.list_source_code;
	END IF;
    END IF;

    -- BOI not available for Basic Pricing when called through the Public Package

    IF l_qp_status = 'S' AND l_request_type_code <> 'FTE' -- shulin, 'FTE' should pass this exception
    AND nvl(l_list_source_code,'NULL') <> QP_GLOBALS.G_ENTITY_BSO --Bug3385041
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_BASIC_PRICING_UNAVAILABLE');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Perform Value to Id conversion

    --dbms_output.put_line('before calling value to id');
    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_MODIFIER_LIST_rec           => p_MODIFIER_LIST_rec
    ,   p_MODIFIER_LIST_val_rec       => p_MODIFIER_LIST_val_rec
    ,   p_MODIFIERS_tbl               => p_MODIFIERS_tbl
    ,   p_MODIFIERS_val_tbl           => p_MODIFIERS_val_tbl
    ,   p_QUALIFIERS_tbl              => p_QUALIFIERS_tbl
    ,   p_QUALIFIERS_val_tbl          => p_QUALIFIERS_val_tbl
    ,   p_PRICING_ATTR_tbl            => p_PRICING_ATTR_tbl
    ,   p_PRICING_ATTR_val_tbl        => p_PRICING_ATTR_val_tbl
    ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --bug#5154678 Continuous Price Break Changes
    FOR i in 1..l_MODIFIERS_tbl.COUNT
    LOOP
        IF l_MODIFIERS_tbl(i).list_line_type_code = 'PBH' AND
	   l_MODIFIERS_tbl(i).operation = QP_GLOBALS.G_OPR_CREATE
	THEN
	   l_MODIFIERS_tbl(i).continuous_price_break_flag := 'Y';
	END IF;
    END LOOP;

    --  Call QP_Modifiers_PVT.Process_Modifiers

    --dbms_output.put_line('before calling pvt');

    -- mkarya - set the called_from_ui indicator to 'N', as QP_Modifiers_PVT.Process_Modifiers is
    -- being called from public package

    l_control_rec.called_from_ui := 'N';
    l_p_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
    l_p_MODIFIERS_tbl := l_MODIFIERS_tbl;
    l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
    l_p_PRICING_ATTR_tbl := l_PRICING_ATTR_tbl;
    QP_Modifiers_PVT.Process_Modifiers
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIER_LIST_rec           => l_p_MODIFIER_LIST_rec
    ,   p_MODIFIERS_tbl               => l_p_MODIFIERS_tbl
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   p_PRICING_ATTR_tbl            => l_p_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );



    --  Load Id OUT parameters.

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
    x_MODIFIERS_tbl                := l_MODIFIERS_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
        ,   x_MODIFIER_LIST_val_rec       => x_MODIFIER_LIST_val_rec
        ,   x_MODIFIERS_val_tbl           => x_MODIFIERS_val_tbl
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        ,   x_PRICING_ATTR_val_tbl        => x_PRICING_ATTR_val_tbl
        );

    END IF;

--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652

        If x_return_status <> 'S' AND l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_Process_Modifiers;
        END IF;

    oe_debug_pub.add('END process_modifiers in Public');
    --dbms_output.put_line('END process_modifiers in Public');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
	If l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_Process_Modifiers;
        END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
	If l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_Process_Modifiers;
        END IF;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Modifiers'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
        If l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_Process_Modifiers;
        END IF;

END Process_Modifiers;

--  Start of Comments
--  API name    Lock_Modifiers
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  Modifier_List_Rec_Type :=
                                        G_MISS_MODIFIER_LIST_REC
,   p_MODIFIER_LIST_val_rec         IN  Modifier_List_Val_Rec_Type :=
                                        G_MISS_MODIFIER_LIST_VAL_REC
,   p_MODIFIERS_tbl                 IN  Modifiers_Tbl_Type :=
                                        G_MISS_MODIFIERS_TBL
,   p_MODIFIERS_val_tbl             IN  Modifiers_Val_Tbl_Type :=
                                        G_MISS_MODIFIERS_VAL_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  Pricing_Attr_Val_Tbl_Type :=
                                        G_MISS_PRICING_ATTR_VAL_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ Modifier_List_Rec_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ Modifier_List_Val_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ Modifiers_Tbl_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Modifiers';
l_return_status               VARCHAR2(1);
l_MODIFIER_LIST_rec           Modifier_List_Rec_Type;
l_p_MODIFIER_LIST_rec           Modifier_List_Rec_Type;
l_MODIFIERS_tbl               Modifiers_Tbl_Type;
l_p_MODIFIERS_tbl               Modifiers_Tbl_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            Pricing_Attr_Tbl_Type;
l_p_PRICING_ATTR_tbl            Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN lock_modifiers in Public');
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
--    MO_GLOBAL.set_policy_context('M', null);--commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL



    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_MODIFIER_LIST_rec           => p_MODIFIER_LIST_rec
    ,   p_MODIFIER_LIST_val_rec       => p_MODIFIER_LIST_val_rec
    ,   p_MODIFIERS_tbl               => p_MODIFIERS_tbl
    ,   p_MODIFIERS_val_tbl           => p_MODIFIERS_val_tbl
    ,   p_QUALIFIERS_tbl              => p_QUALIFIERS_tbl
    ,   p_QUALIFIERS_val_tbl          => p_QUALIFIERS_val_tbl
    ,   p_PRICING_ATTR_tbl            => p_PRICING_ATTR_tbl
    ,   p_PRICING_ATTR_val_tbl        => p_PRICING_ATTR_val_tbl
    ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Modifiers_PVT.Lock_Modifiers
    l_p_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
    l_p_MODIFIERS_tbl := l_MODIFIERS_tbl;
    l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
    l_p_PRICING_ATTR_tbl := l_PRICING_ATTR_tbl;
    QP_Modifiers_PVT.Lock_Modifiers
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_MODIFIER_LIST_rec           => l_p_MODIFIER_LIST_rec
    ,   p_MODIFIERS_tbl               => l_p_MODIFIERS_tbl
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   p_PRICING_ATTR_tbl            => l_p_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    --  Load Id OUT parameters.

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
    x_MODIFIERS_tbl                := l_MODIFIERS_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
        ,   x_MODIFIER_LIST_val_rec       => x_MODIFIER_LIST_val_rec
        ,   x_MODIFIERS_val_tbl           => x_MODIFIERS_val_tbl
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        ,   x_PRICING_ATTR_val_tbl        => x_PRICING_ATTR_val_tbl
        );

    END IF;

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
            ,   'Lock_Modifiers'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    oe_debug_pub.add('END lock_modifiers in Public');
END Lock_Modifiers;

--  Start of Comments
--  API name    Get_Modifiers
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ Modifier_List_Rec_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ Modifier_List_Val_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ Modifiers_Tbl_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Modifiers';
l_list_header_id              NUMBER := p_list_header_id;
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN get_modifiers in Public');
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
--    MO_GLOBAL.set_policy_context('M', null);--commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL



    --  Standard check for Val/ID conversion

    IF  p_list_header = FND_API.G_MISS_CHAR
    THEN

        l_list_header_id := p_list_header_id;

    ELSIF p_list_header_id <> FND_API.G_MISS_NUM THEN

        l_list_header_id := p_list_header_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_list_header_id := QP_Value_To_Id.list_header
        (   p_list_header                 => p_list_header
        );

        IF l_list_header_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Modifiers_PVT.Get_Modifiers

    QP_Modifiers_PVT.Get_Modifiers
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_list_header_id              => l_list_header_id
    ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    --  Load Id OUT parameters.

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
    x_MODIFIERS_tbl                := l_MODIFIERS_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
        ,   x_MODIFIER_LIST_val_rec       => x_MODIFIER_LIST_val_rec
        ,   x_MODIFIERS_val_tbl           => x_MODIFIERS_val_tbl
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        ,   x_PRICING_ATTR_val_tbl        => x_PRICING_ATTR_val_tbl
        );

    END IF;

    --  Set return status

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
            ,   'Get_Modifiers'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    oe_debug_pub.add('END get_modifiers in Public');
END Get_Modifiers;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_MODIFIER_LIST_rec             IN  Modifier_List_Rec_Type
,   p_MODIFIERS_tbl                 IN  Modifiers_Tbl_Type
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type
,   x_MODIFIER_LIST_val_rec         OUT NOCOPY /* file.sql.39 change */ Modifier_List_Val_Rec_Type
,   x_MODIFIERS_val_tbl             OUT NOCOPY /* file.sql.39 change */ Modifiers_Val_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Val_Tbl_Type
)
IS
BEGIN

    oe_debug_pub.add('BEGIN id_to_value in Public');
    --  Convert MODIFIER_LIST

    x_MODIFIER_LIST_val_rec := QP_Modifier_List_Util.Get_Values(p_MODIFIER_LIST_rec);

    --  Convert MODIFIERS

    FOR I IN 1..p_MODIFIERS_tbl.COUNT LOOP
        x_MODIFIERS_val_tbl(I) :=
            QP_Modifiers_Util.Get_Values(p_MODIFIERS_tbl(I));
    END LOOP;

    --  Convert QUALIFIERS

    FOR I IN 1..p_QUALIFIERS_tbl.COUNT LOOP
        x_QUALIFIERS_val_tbl(I) :=
            QP_Qualifiers_Util.Get_Values(p_QUALIFIERS_tbl(I));
    END LOOP;

    --  Convert PRICING_ATTR

    FOR I IN 1..p_PRICING_ATTR_tbl.COUNT LOOP
        x_PRICING_ATTR_val_tbl(I) :=
            QP_Pricing_Attr_Util.Get_Values(p_PRICING_ATTR_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    oe_debug_pub.add('END id_to_value in Public');
END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  Modifier_List_Rec_Type
,   p_MODIFIER_LIST_val_rec         IN  Modifier_List_Val_Rec_Type
,   p_MODIFIERS_tbl                 IN  Modifiers_Tbl_Type
,   p_MODIFIERS_val_tbl             IN  Modifiers_Val_Tbl_Type
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   p_QUALIFIERS_val_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  Pricing_Attr_Tbl_Type
,   p_PRICING_ATTR_val_tbl          IN  Pricing_Attr_Val_Tbl_Type
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ Pricing_Attr_Tbl_Type
)
IS
l_MODIFIER_LIST_rec           Modifier_List_Rec_Type;
l_MODIFIERS_rec               Modifiers_Rec_Type;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_PRICING_ATTR_rec            Pricing_Attr_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    oe_debug_pub.add('START value_to_id in Public');

    --  Init x_return_status.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --  Convert MODIFIER_LIST

    l_MODIFIER_LIST_rec := QP_Modifier_List_Util.Get_Ids
    (   p_MODIFIER_LIST_rec           => p_MODIFIER_LIST_rec
    ,   p_MODIFIER_LIST_val_rec       => p_MODIFIER_LIST_val_rec
    );

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;

    IF l_MODIFIER_LIST_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert MODIFIERS

    x_MODIFIERS_tbl := p_MODIFIERS_tbl;

    l_index := p_MODIFIERS_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_MODIFIERS_rec := QP_Modifiers_Util.Get_Ids
        (   p_MODIFIERS_rec               => p_MODIFIERS_tbl(l_index)
        ,   p_MODIFIERS_val_rec           => p_MODIFIERS_val_tbl(l_index)
        );

        x_MODIFIERS_tbl(l_index)       := l_MODIFIERS_rec;

        IF l_MODIFIERS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_MODIFIERS_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert QUALIFIERS

    x_QUALIFIERS_tbl := p_QUALIFIERS_tbl;

    l_index := p_QUALIFIERS_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_QUALIFIERS_rec := QP_Qualifiers_Util.Get_Ids
        (   p_QUALIFIERS_rec              => p_QUALIFIERS_tbl(l_index)
        ,   p_QUALIFIERS_val_rec          => p_QUALIFIERS_val_tbl(l_index)
        );

        x_QUALIFIERS_tbl(l_index)      := l_QUALIFIERS_rec;

        IF l_QUALIFIERS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_QUALIFIERS_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert PRICING_ATTR

    x_PRICING_ATTR_tbl := p_PRICING_ATTR_tbl;

    l_index := p_PRICING_ATTR_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_PRICING_ATTR_rec := QP_Pricing_Attr_Util.Get_Ids
        (   p_PRICING_ATTR_rec            => p_PRICING_ATTR_tbl(l_index)
        ,   p_PRICING_ATTR_val_rec        => p_PRICING_ATTR_val_tbl(l_index)
        );

        x_PRICING_ATTR_tbl(l_index)    := l_PRICING_ATTR_rec;

        IF l_PRICING_ATTR_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_PRICING_ATTR_val_tbl.NEXT(l_index);

    END LOOP;

    oe_debug_pub.add('END value_to_id in Public');
EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

END QP_Modifiers_PUB;

/
