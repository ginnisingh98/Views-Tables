--------------------------------------------------------
--  DDL for Package Body QP_QUALIFIER_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QUALIFIER_RULES_PUB" AS
/* $Header: QPXPQRQB.pls 120.4 2006/10/25 07:06:45 nirmkuma ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Qualifier_Rules_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type
,   p_QUALIFIER_RULES_val_rec       IN  Qualifier_Rules_Val_Rec_Type
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type
,   p_QUALIFIERS_val_tbl            IN  Qualifiers_Val_Tbl_Type
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
);

--  Start of Comments
--  API name    Process_Qualifier_Rules
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

PROCEDURE Process_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIER_RULES_val_rec       IN  Qualifier_Rules_Val_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_VAL_REC
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type :=
                                        G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qualifiers_Val_Tbl_Type :=
                                        G_MISS_QUALIFIERS_VAL_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Qualifier_Rules';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_QUALIFIER_RULES_rec         Qualifier_Rules_Rec_Type;
l_p_QUALIFIER_RULES_rec       Qualifier_Rules_Rec_Type;
l_QUALIFIERS_tbl              Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            Qualifiers_Tbl_Type;

l_qp_status                   VARCHAR2(1);
l_list_source_code            VARCHAR2(10); --Bug3385041

BEGIN

          SAVEPOINT QP_PQR;
        --dbms_output.put_line('in public process qualifiers');


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

    --bug#3385041 begin
    begin
	select list_source_code into l_list_source_code
	from qp_list_headers_b
	where list_header_id = p_QUALIFIERS_tbl(1).list_header_id;
    exception
        when others then
	   oe_debug_pub.add('Process_Qualifier_Rules - l_list_source_code error : '||sqlerrm);
	   null;
    end;
    --bug#3385041 end

    l_qp_status := QP_UTIL.get_qp_status;

    IF l_qp_status = 'S'
    AND nvl(l_list_source_code,'NULL') <> QP_GLOBALS.G_ENTITY_BSO --Bug3385041
    THEN -- Public API unavailable for Basic Pricing

       l_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('QP', 'QP_BASIC_PRICING_UNAVAILABLE');
	  OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_QUALIFIER_RULES_rec         => p_QUALIFIER_RULES_rec
    ,   p_QUALIFIER_RULES_val_rec     => p_QUALIFIER_RULES_val_rec
    ,   p_QUALIFIERS_tbl              => p_QUALIFIERS_tbl
    ,   p_QUALIFIERS_val_tbl          => p_QUALIFIERS_val_tbl
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
    -- mkarya - set the called_from_ui indicator to 'N', as
    -- QP_Qualifier_Rules_PVT.Process_Qualifier_Rules is being called from public package

    l_control_rec.called_from_ui := 'N';
     l_p_QUALIFIER_RULES_rec := l_QUALIFIER_RULES_rec; -- added for nocopy hint
     l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
    QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    );

    --  Load Id OUT parameters.

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   x_QUALIFIER_RULES_val_rec     => x_QUALIFIER_RULES_val_rec
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        );

    END IF;

   --5345652
    If x_return_status <> 'S' AND l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_PQR;
    END IF;
   --5345652

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

   --5345652
    If  l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_PQR;
    END IF;
   --5345652

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

   --5345652
    If  l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_PQR;
    END IF;
   --5345652

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Qualifier_Rules'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

   --5345652
    If  l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_PQR;
    END IF;
   --5345652

END Process_Qualifier_Rules;

--  Start of Comments
--  API name    Lock_Qualifier_Rules
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

PROCEDURE Lock_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIER_RULES_val_rec       IN  Qualifier_Rules_Val_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_VAL_REC
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type :=
                                        G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qualifiers_Val_Tbl_Type :=
                                        G_MISS_QUALIFIERS_VAL_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Qualifier_Rules';
l_return_status               VARCHAR2(1);
l_QUALIFIER_RULES_rec         Qualifier_Rules_Rec_Type;
l_p_QUALIFIER_RULES_rec       Qualifier_Rules_Rec_Type;
l_QUALIFIERS_tbl              Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            Qualifiers_Tbl_Type;
BEGIN

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

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_QUALIFIER_RULES_rec         => p_QUALIFIER_RULES_rec
    ,   p_QUALIFIER_RULES_val_rec     => p_QUALIFIER_RULES_val_rec
    ,   p_QUALIFIERS_tbl              => p_QUALIFIERS_tbl
    ,   p_QUALIFIERS_val_tbl          => p_QUALIFIERS_val_tbl
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Qualifier_Rules_PVT.Lock_Qualifier_Rules
     l_p_QUALIFIER_RULES_rec := l_p_QUALIFIER_RULES_rec; -- added for nocopy hint
     l_p_QUALIFIERS_tbl := l_p_QUALIFIERS_tbl;
    QP_Qualifier_Rules_PVT.Lock_Qualifier_Rules
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    );

    --  Load Id OUT parameters.

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   x_QUALIFIER_RULES_val_rec     => x_QUALIFIER_RULES_val_rec
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
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
            ,   'Lock_Qualifier_Rules'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Qualifier_Rules;

--  Start of Comments
--  API name    Get_Qualifier_Rules
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

PROCEDURE Get_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_rule_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_qualifier_rule                IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Qualifier_Rules';
l_qualifier_rule_id           NUMBER := p_qualifier_rule_id;
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

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

    --  Standard check for Val/ID conversion

    IF  p_qualifier_rule = FND_API.G_MISS_CHAR
    THEN

        l_qualifier_rule_id := p_qualifier_rule_id;

    ELSIF p_qualifier_rule_id <> FND_API.G_MISS_NUM THEN

        l_qualifier_rule_id := p_qualifier_rule_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id
        --dbms_output.put_line('converting value to id');

        l_qualifier_rule_id := QP_Value_To_Id.qualifier_rule
        (   p_qualifier_rule              => p_qualifier_rule
        );

        --dbms_output.put_line('after convertid'||l_qualifier_rule_id);
        --dbms_output.put_line('qualifier rule id is miss num');

        IF l_qualifier_rule_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

          --commented by svdeshmu
          --With this uncommented  , after QP_Value_to_id ,exeception is raised.

          RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Qualifier_Rules_PVT.Get_Qualifier_Rules




    QP_Qualifier_Rules_PVT.Get_Qualifier_Rules
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_qualifier_rule_id           => l_qualifier_rule_id
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    );

    --  Load Id OUT parameters.

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   x_QUALIFIER_RULES_val_rec     => x_QUALIFIER_RULES_val_rec
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
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

    --dbms_output.put_line('calling get qualifiers g_exe_error');
        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --dbms_output.put_line('calling get qualifiers unexpected error');

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
    --dbms_output.put_line('calling get qualifiers other');

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Qualifier_Rules'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Qualifier_Rules;

PROCEDURE Copy_Qualifier_Rule
(  p_api_version_number            IN NUMBER
,  p_init_msg_list                 IN VARCHAR2 :=FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_rule_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_qualifier_rule                IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_to_qualifier_rule             IN VARCHAR2
,   p_to_description                IN VARCHAR2 :=FND_API.G_MISS_CHAR
,   x_qualifier_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER) IS


l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Copy_Qualifier_Rule';
l_qualifier_rule_id           NUMBER;
l_p_qualifier_rule_id         NUMBER;
BEGIN


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

    --  Standard check for Val/ID conversion

    IF  p_qualifier_rule = FND_API.G_MISS_CHAR
    THEN

        l_qualifier_rule_id := p_qualifier_rule_id;

    ELSIF p_qualifier_rule_id <> FND_API.G_MISS_NUM THEN

        l_qualifier_rule_id := p_qualifier_rule_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id
        --dbms_output.put_line('converting value to id');

        l_qualifier_rule_id := QP_Value_To_Id.qualifier_rule
        (   p_qualifier_rule              => p_qualifier_rule
        );

        --dbms_output.put_line('after convertid'||l_qualifier_rule_id);
        --dbms_output.put_line('qualifier rule id is miss num');

        IF l_qualifier_rule_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

          --commented by svdeshmu
          --With this uncommented  , after QP_Value_to_id ,exeception is raised.

          --RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Qualifier_Rules_PVT.Copy_Qualifier_Rules


    l_p_qualifier_rule_id := l_qualifier_rule_id; -- added for nocopy hint

    QP_Qualifier_Rules_PVT.Copy_Qualifier_Rule
    (   p_api_version_number            => 1.0
    ,   p_init_msg_list                 => p_init_msg_list
    ,   p_commit                        => p_commit
    ,   x_return_status                 => x_return_status
    ,   x_msg_count                     => x_msg_count
    ,   x_msg_data                      => x_msg_data
    ,   p_qualifier_rule_id             => l_p_qualifier_rule_id
    ,   p_to_qualifier_rule             => p_to_qualifier_rule
    ,   p_to_description                => p_to_description
    ,   x_qualifier_rule_id             => l_qualifier_rule_id
    );







    --  Load Id OUT parameters.

    x_qualifier_rule_id          := l_qualifier_rule_id;

    /*--  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   x_QUALIFIER_RULES_val_rec     => x_QUALIFIER_RULES_val_rec
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        );

    END IF;*/

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    --dbms_output.put_line('calling get qualifiers g_exe_error');
        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --dbms_output.put_line('calling get qualifiers unexpected error');

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN
    --dbms_output.put_line('calling get qualifiers other');

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_Qualifier_Rule'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Copy_Qualifier_Rule;







--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
)
IS
BEGIN

    --  Convert QUALIFIER_RULES



    x_QUALIFIER_RULES_val_rec := QP_Qualifier_Rules_Util.Get_Values(p_QUALIFIER_RULES_rec);

    --  Convert QUALIFIERS

    FOR I IN 1..p_QUALIFIERS_tbl.COUNT LOOP
        x_QUALIFIERS_val_tbl(I) :=
            QP_Qualifiers_Util.Get_Values(p_QUALIFIERS_tbl(I));
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

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type
,   p_QUALIFIER_RULES_val_rec       IN  Qualifier_Rules_Val_Rec_Type
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type
,   p_QUALIFIERS_val_tbl            IN  Qualifiers_Val_Tbl_Type
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
)
IS
l_QUALIFIER_RULES_rec         Qualifier_Rules_Rec_Type;
l_QUALIFIERS_rec              Qualifiers_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert QUALIFIER_RULES

    l_QUALIFIER_RULES_rec := QP_Qualifier_Rules_Util.Get_Ids
    (   p_QUALIFIER_RULES_rec         => p_QUALIFIER_RULES_rec
    ,   p_QUALIFIER_RULES_val_rec     => p_QUALIFIER_RULES_val_rec
    );

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;

    IF l_QUALIFIER_RULES_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

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

END QP_Qualifier_Rules_PUB;

/
