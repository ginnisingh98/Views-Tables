--------------------------------------------------------
--  DDL for Package Body OE_PRICING_CONT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICING_CONT_PUB" AS
/* $Header: OEXPPRCB.pls 120.5 2006/09/14 17:58:30 shulin ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Pricing_Cont_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_Agreement_rec                 IN  Agreement_Rec_Type
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  Agreement_Rec_Type
,   p_Agreement_val_rec             IN  Agreement_Val_Rec_Type
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_Price_LHeader_val_rec         IN  QP_Price_List_PUB.Price_List_Val_Rec_Type
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_Price_LLine_val_tbl           IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   p_Pricing_Attr_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Pricing_Attr_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
);

--  Start of Comments
--  API name    Process_Agreement
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

PROCEDURE Process_Agreement
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  Agreement_Rec_Type :=
                                        G_MISS_AGREEMENT_REC
,   p_Agreement_val_rec             IN  Agreement_Val_Rec_Type :=
                                        G_MISS_AGREEMENT_VAL_REC
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type :=
								G_MISS_PRICE_LIST_REC
,   p_Price_LHeader_val_rec         IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
								G_MISS_PRICE_LIST_VAL_REC
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
								G_MISS_PRICE_LIST_LINE_TBL
,   p_Price_LLine_val_tbl           IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
								G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
								G_MISS_PRICING_ATTR_TBL
,   p_Pricing_Attr_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
								G_MISS_PRICING_ATTR_VAL_TBL
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
,   p_check_duplicate_lines         IN  VARCHAR2 DEFAULT NULL  --5024919, 5018856, 5024801
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Agreement';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_control_rec_dummy                 OE_GLOBALS.Control_Rec_Type;

l_return_status               VARCHAR2(1);
l_Agreement_rec               Agreement_Rec_Type;
l_Price_LHeader_rec           QP_Price_List_PUB.Price_List_Rec_Type;
l_Price_LHeader_rec_dummy     OE_Price_List_PUB.Price_List_Rec_Type;
l_Price_LLine_tbl             QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_Price_LLine_tbl_dummy       OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
x_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type; --4949185, 5530054
l_Pricing_Attr_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_installed_status            VARCHAR2(1);

l_Contract_rec                Contract_Rec_Type;
l_Discount_Header_rec         Discount_Header_Rec_Type;
l_Discount_Cust_tbl           Discount_Cust_Tbl_Type;
l_Discount_Line_tbl           Discount_Line_Tbl_Type;
l_Price_Break_tbl             Price_Break_Tbl_Type;

l_p_Price_LHeader_rec		QP_Price_List_PUB.Price_List_Rec_Type;--[prarasto]
l_p_Price_LLine_tbl		QP_Price_List_PUB.Price_List_Line_Tbl_Type;	 --[prarasto]
l_p_QUALIFIERS_tbl		Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;	 --[prarasto]
l_p_Pricing_Attr_tbl		QP_Price_List_PUB.Pricing_Attr_Tbl_Type;	 --[prarasto]
l_p_Contract_rec		Contract_Rec_Type;	 --[prarasto]
l_p_Agreement_rec		Agreement_Rec_Type;	 --[prarasto]
l_p_Price_LHeader_rec_dummy	OE_Price_List_PUB.Price_List_Rec_Type; --[prarasto]
l_p_Discount_Header_rec		Discount_Header_Rec_Type; --[prarasto]
l_p_Price_LLine_tbl_dummy	OE_Price_List_PUB.Price_List_Line_Tbl_Type;  --[prarasto]
l_p_Discount_Cust_tbl		Discount_Cust_Tbl_Type; --[prarasto]
l_p_Discount_Line_tbl		Discount_Line_Tbl_Type; --[prarasto]
l_p_Price_Break_tbl		Price_Break_Tbl_Type; --[prarasto]

BEGIN
--5018856, 5024919, 5024801
QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES := p_check_duplicate_lines;
oe_debug_pub.add('G_CHECK_DUP_PRICELIST_LINES '||QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES);
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


  	/* check for installation status ; if it's basic then this api
   	is not available */

  	l_installed_status := QP_UTIL.get_qp_status;

  	IF l_installed_status IN ('S', 'N') THEN
		 l_return_status := FND_API.G_RET_STS_ERROR;
		 FND_MESSAGE.SET_NAME('QP', 'QP_BASIC_PRICING_UNAVAILABLE');
		 OE_MSG_PUB.Add;
		 RAISE FND_API.G_EXC_ERROR;
	END IF;

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
--    MO_GLOBAL.set_policy_context('M', null); --commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL


    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_Agreement_rec               => p_Agreement_rec
    ,   p_Agreement_val_rec           => p_Agreement_val_rec
    ,   p_Price_LHeader_rec           => p_Price_LHeader_rec
    ,   p_Price_LHeader_val_rec       => p_Price_LHeader_val_rec
    ,   p_Price_LLine_tbl             => p_Price_LLine_tbl
    ,   p_Price_LLine_val_tbl         => p_Price_LLine_val_tbl
    ,   p_Pricing_Attr_tbl	      => p_Pricing_Attr_tbl
    ,   p_Pricing_Attr_val_tbl        => p_Pricing_Attr_val_tbl
    ,   x_Agreement_rec               => l_Agreement_rec
    ,   x_Price_LHeader_rec           => l_Price_LHeader_rec
    ,   x_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   x_Pricing_Attr_tbl            => l_Pricing_Attr_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


/* First we will process the price list associated with the agreement
   and as we get the price list id, we can associate that with the agreement record later */

-- Call the Process_Price_List PRIVATE API
	oe_debug_pub.add('operation='||NVL(l_Price_LHeader_rec.operation,'MYNAME'));

  if l_Price_LHeader_rec.operation <> FND_API.G_MISS_CHAR  then

		-- Call the process_price_list only when a price list record has been passed

		oe_debug_pub.add('Calling the process_price_list API');

    l_p_Price_LHeader_rec := l_Price_LHeader_rec;--[prarasto]
    l_p_Price_LLine_tbl := l_Price_LLine_tbl;	 --[prarasto]
    l_p_QUALIFIERS_tbl  := l_QUALIFIERS_tbl;	 --[prarasto]
    l_p_Pricing_Attr_tbl:= l_Pricing_Attr_tbl;	 --[prarasto]

    QP_LIST_HEADERS_PVT.Process_Price_List
	(   p_api_version_number          => 1.0
	,   p_init_msg_list               => p_init_msg_list
	,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
	,   p_commit                      => p_commit
	,   x_return_status               => x_return_status
	,   x_msg_count                   => x_msg_count
	,   x_msg_data                    => x_msg_data
	,   p_control_rec                 => l_control_rec
	,   p_PRICE_LIST_rec              => l_p_Price_LHeader_rec
	,   p_PRICE_LIST_LINE_tbl         => l_p_Price_LLine_tbl
	,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
	,   p_PRICING_ATTR_tbl            => l_p_Pricing_Attr_tbl
	,   x_PRICE_LIST_rec              => x_Price_LHeader_rec -- 4949185, 5530054
	,   x_PRICE_LIST_LINE_tbl         => x_Price_LLine_tbl -- 4949185, 5530054
	,   x_QUALIFIERS_tbl              => x_QUALIFIERS_tbl-- 4949185, 5530054
	,   x_PRICING_ATTR_tbl            => x_Pricing_Attr_tbl-- 4949185, 5530054
    );

	oe_debug_pub.add('After process price list..');
	oe_debug_pub.add('Price List Id ='||to_char(l_Price_LHeader_rec.list_header_id));

    --  Load Id OUT parameters.
    -- 4949185, 5530054 x_Price_LHeader_rec            := l_Price_LHeader_rec;
    -- 4949185, 5530054 x_Price_LLine_tbl              := l_Price_LLine_tbl;
    -- 4949185, 5530054 x_Pricing_Attr_tbl             := l_Pricing_Attr_tbl;

                l_Price_LHeader_rec            := x_Price_LHeader_rec; --4949185, 5530054
      		l_Price_LLine_tbl              := x_Price_LLine_tbl; --4949185, 5530054
	 	l_Pricing_Attr_tbl             := x_Pricing_Attr_tbl; --4949185, 5530054

	/*

	--  If p_return_values is TRUE then convert Ids to Values.

	IF FND_API.to_Boolean(p_return_values) THEN
		Id_To_Value
		(   p_PRICE_LIST_rec              => l_Price_LHeader_rec
		,   p_PRICE_LIST_LINE_tbl         => l_Price_LLine_tbl
		,   p_PRICING_ATTR_tbl            => l_Pricing_Attr_tbl
		,   x_PRICE_LIST_val_rec          => x_Price_LHeader_val_rec
		,   x_PRICE_LIST_LINE_val_tbl     => x_Price_LLine_val_tbl
		,   x_PRICING_ATTR_val_tbl        => x_Pricing_Attr_val_tbl
		);

	END IF;

	*/

		/* Assign the price list id to agreement.price_list_id */

		l_Agreement_rec.price_list_id := x_Price_LHeader_rec.list_header_id;

	end if;
	-- end calling the process_price_list when a price lisr record is passed



	oe_debug_pub.add('Price List Id ='||to_char(l_Agreement_rec.price_list_id));

    	--  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont
	--  We are still using the old structure for calling this procedure
	--  since the procedure is already used by many other programs

   l_Discount_Header_rec.attribute1 := 'Calling from PUBLIC API';

    l_p_Contract_rec	:= l_Contract_rec;	 --[prarasto]
    l_p_Agreement_rec	:= l_Agreement_rec;	 --[prarasto]
    l_p_Price_LHeader_rec_dummy := l_Price_LHeader_rec_dummy; --[prarasto]
    l_p_Discount_Header_rec := l_Discount_Header_rec; --[prarasto]
    l_p_Price_LLine_tbl_dummy := l_Price_LLine_tbl_dummy;  --[prarasto]
    l_p_Discount_Cust_tbl := l_Discount_Cust_tbl; --[prarasto]
    l_p_Discount_Line_tbl := l_Discount_Line_tbl;  --[prarasto]
    l_p_Price_Break_tbl	:= l_Price_Break_tbl; --[prarasto]

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec_dummy
    ,   p_Contract_rec                => l_p_Contract_rec
    ,   p_Agreement_rec               => l_p_Agreement_rec
    ,   p_Price_LHeader_rec           => l_p_Price_LHeader_rec_dummy
    ,   p_Discount_Header_rec         => l_p_Discount_Header_rec
    ,   p_Price_LLine_tbl             => l_p_Price_LLine_tbl_dummy
    ,   p_Discount_Cust_tbl           => l_p_Discount_Cust_tbl
    ,   p_Discount_Line_tbl           => l_p_Discount_Line_tbl
    ,   p_Price_Break_tbl             => l_p_Price_Break_tbl
    ,   x_Contract_rec                => l_Contract_rec
    ,   x_Agreement_rec               => l_Agreement_rec
    ,   x_Price_LHeader_rec           => l_Price_LHeader_rec_dummy
    ,   x_Discount_Header_rec         => l_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_Price_LLine_tbl_dummy
    ,   x_Discount_Cust_tbl           => l_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_Price_Break_tbl
    );


    --  Load Id OUT parameters.

    x_Agreement_rec                := l_Agreement_rec;

    -- oe_msg_pub.add('After Process_pricing_Cont.');
    -- oe_msg_pub.add('Agreement id is ='||to_char(l_Agreement_rec.agreement_id));
    -- bug 3650357

     oe_debug_pub.add('After Process_pricing_Cont.');
     oe_debug_pub.add('Agreement id is ='||to_char(l_Agreement_rec.agreement_id));

-- not needed
/*
     x_Contract_rec                 := l_Contract_rec;
--	x_Discount_Header_rec          := l_Discount_Header_rec;
	x_Discount_Cust_tbl            := l_Discount_Cust_tbl;
	x_Discount_Line_tbl            := l_Discount_Line_tbl;
	x_Price_Break_tbl              := l_Price_Break_tbl;
*/


    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_Agreement_rec               => l_Agreement_rec
        ,   p_Price_LHeader_rec           => l_Price_LHeader_rec
        ,   p_Price_LLine_tbl             => l_Price_LLine_tbl
	   ,   p_Pricing_Attr_tbl		  => l_Pricing_Attr_tbl
        ,   x_Agreement_val_rec           => x_Agreement_val_rec
        ,   x_Price_LHeader_val_rec       => x_Price_LHeader_val_rec
        ,   x_Price_LLine_val_tbl         => x_Price_LLine_val_tbl
	   ,   x_Pricing_Attr_val_tbl    	  => x_Pricing_Attr_val_tbl
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
            ,   'Process_Agreement'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Agreement;

--  Start of Comments
--  API name    Lock_Agreement
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

PROCEDURE Lock_Agreement
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  Agreement_Rec_Type :=
                                        G_MISS_AGREEMENT_REC
,   p_Agreement_val_rec             IN  Agreement_Val_Rec_Type :=
                                        G_MISS_AGREEMENT_VAL_REC
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        G_MISS_PRICE_List_REC
--                                        QP_Price_List_PUB.G_MISS_PRICE_List_REC   --2449157
,   p_Price_LHeader_val_rec         IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_List_VAL_REC
--                                        QP_Price_List_PUB.G_MISS_PRICE_List_VAL_REC --2449157
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_List_Line_TBL
--                                        QP_Price_List_PUB.G_MISS_PRICE_List_Line_TBL --2449157
,   p_Price_LLine_val_tbl           IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_List_Line_VAL_TBL
--                                        QP_Price_List_PUB.G_MISS_PRICE_List_Line_VAL_TBL  --2449157
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
								G_MISS_PRICING_ATTR_TBL
,   p_Pricing_Attr_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
								G_MISS_PRICING_ATTR_VAL_TBL
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Agreement';
l_return_status               VARCHAR2(1);
l_Agreement_rec               Agreement_Rec_Type;
l_Price_LHeader_rec           QP_Price_List_PUB.Price_List_Rec_Type;
l_Price_LHeader_rec_dummy     OE_Price_List_PUB.Price_List_Rec_Type;
l_Price_LLine_tbl             QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_Price_LLine_tbl_dummy       OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;

l_Contract_rec                Contract_Rec_Type;
l_Discount_Header_rec         Discount_Header_Rec_Type;
l_Discount_Cust_tbl           OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_Discount_Line_tbl           OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;


l_p_Contract_rec		Contract_Rec_Type;	 --[prarasto]
l_p_Agreement_rec		Agreement_Rec_Type;	 --[prarasto]
l_p_Price_LHeader_rec_dummy	OE_Price_List_PUB.Price_List_Rec_Type; --[prarasto]
l_p_Discount_Header_rec		Discount_Header_Rec_Type; --[prarasto]
l_p_Price_LLine_tbl_dummy	OE_Price_List_PUB.Price_List_Line_Tbl_Type;  --[prarasto]
l_p_Discount_Cust_tbl		Discount_Cust_Tbl_Type; --[prarasto]
l_p_Discount_Line_tbl		Discount_Line_Tbl_Type; --[prarasto]
l_p_Price_Break_tbl		Price_Break_Tbl_Type; --[prarasto]
BEGIN

/* In the Beta Version of the PUBLIC API, Lock( ) functionality is not delivered */

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
--    MO_GLOBAL.set_policy_context('M', null); --commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL


    --  Perform Value to Id conversion

     Value_To_Id
	(   x_return_status               => l_return_status
	,   p_Agreement_rec               => p_Agreement_rec
	,   p_Agreement_val_rec           => p_Agreement_val_rec
	,   p_Price_LHeader_rec           => p_Price_LHeader_rec
	,   p_Price_LHeader_val_rec       => p_Price_LHeader_val_rec
	,   p_Price_LLine_tbl             => p_Price_LLine_tbl
	,   p_Price_LLine_val_tbl         => p_Price_LLine_val_tbl
	,   p_Pricing_Attr_tbl            => p_Pricing_Attr_tbl
	,   p_Pricing_Attr_val_tbl        => p_Pricing_Attr_val_tbl
	,   x_Agreement_rec               => l_Agreement_rec
	,   x_Price_LHeader_rec           => l_Price_LHeader_rec
	,   x_Price_LLine_tbl             => l_Price_LLine_tbl
	,   x_Pricing_Attr_tbl            => l_Pricing_Attr_tbl
	);



    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call OE_Pricing_Cont_PVT.Lock_Pricing_Cont

    l_p_Contract_rec	:= l_Contract_rec;	 --[prarasto]
    l_p_Agreement_rec	:= l_Agreement_rec;	 --[prarasto]
    l_p_Price_LHeader_rec_dummy := l_Price_LHeader_rec_dummy; --[prarasto]
    l_p_Discount_Header_rec := l_Discount_Header_rec; --[prarasto]
    l_p_Price_LLine_tbl_dummy := l_Price_LLine_tbl_dummy;  --[prarasto]
    l_p_Discount_Cust_tbl := l_Discount_Cust_tbl; --[prarasto]
    l_p_Discount_Line_tbl := l_Discount_Line_tbl;  --[prarasto]
    l_p_Price_Break_tbl	:= l_Price_Break_tbl; --[prarasto]


    OE_Pricing_Cont_PVT.Lock_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Contract_rec                => l_p_Contract_rec
    ,   p_Agreement_rec               => l_p_Agreement_rec
    ,   p_Price_LHeader_rec           => l_p_Price_LHeader_rec_dummy
    ,   p_Discount_Header_rec         => l_p_Discount_Header_rec
    ,   p_Price_LLine_tbl             => l_p_Price_LLine_tbl_dummy
    ,   p_Discount_Cust_tbl           => l_p_Discount_Cust_tbl
    ,   p_Discount_Line_tbl           => l_p_Discount_Line_tbl
    ,   p_Price_Break_tbl             => l_p_Price_Break_tbl
    ,   x_Contract_rec                => l_Contract_rec
    ,   x_Agreement_rec               => l_Agreement_rec
    ,   x_Price_LHeader_rec           => l_Price_LHeader_rec_dummy
    ,   x_Discount_Header_rec         => l_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_Price_LLine_tbl_dummy
    ,   x_Discount_Cust_tbl           => l_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_Price_Break_tbl
    );

    --  Load Id OUT NOCOPY /* file.sql.39 change */ parameters.

    x_Agreement_rec                := l_Agreement_rec;
    x_Price_LHeader_rec            := l_Price_LHeader_rec;
    x_Price_LLine_tbl              := l_Price_LLine_tbl;

    --x_Contract_rec                 := l_Contract_rec;
    --x_Discount_Cust_tbl            := l_Discount_Cust_tbl;
    --x_Discount_Header_rec          := l_Discount_Header_rec;
    --x_Discount_Line_tbl            := l_Discount_Line_tbl;
    --x_Price_Break_tbl              := l_Price_Break_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
	 	(   p_Agreement_rec               => l_Agreement_rec
		,   p_Price_LHeader_rec           => l_Price_LHeader_rec
		,   p_Price_LLine_tbl             => l_Price_LLine_tbl
		,   p_Pricing_Attr_tbl            => l_Pricing_Attr_tbl
		,   x_Agreement_val_rec           => x_Agreement_val_rec
		,   x_Price_LHeader_val_rec       => x_Price_LHeader_val_rec
		,   x_Price_LLine_val_tbl         => x_Price_LLine_val_tbl
		,   x_Pricing_Attr_val_tbl        => x_Pricing_Attr_val_tbl
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
            ,   'Lock_Agreement'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Agreement;

--  Start of Comments
--  API name    Get_Agreement
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

PROCEDURE Get_Agreement
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id		    IN  NUMBER := FND_API.G_MISS_NUM
/*, p_agreement                     IN  VARCHAR2 := FND_API.G_MISS_CHAR
,   p_revision 		 		 IN VARCHAR2 := FND_API.G_MISS_CHAR */
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Agreement_val_rec 	    OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Agreement';
l_agreement_id                NUMBER := p_agreement_id;
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            OE_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICING_ATTR_tbl          OE_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_pricing_contract_id         NUMBER;

BEGIN

/* In the beta version of this API Get( ) and Lock( ) functionalities are not delivered */


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


    --  Call OE_Pricing_Cont_PVT.Get_Pricing_Cont
    /*

    OE_Pricing_Cont_PVT.Get_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_agreement_id 		        => l_pricing_contract_id
    ,   x_Agreement_rec               => l_Agreement_rec
    ,   x_Price_LHeader_rec           => l_Price_LHeader_rec
    ,   x_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   x_Pricing_Attr_tbl       	   => l_Pricing_Attr_tbl
    );

    */


    --  Load Id OUT parameters.
/*
    x_Agreement_rec                := l_Agreement_rec;
    x_Price_LHeader_rec            := l_Price_LHeader_rec;
    x_Price_LLine_tbl              := l_Price_LLine_tbl;
    --x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;
*/

    --  If p_return_values is TRUE then convert Ids to Values.

/* Commenting as of now since we do not have any logic for id_to_value conversion
    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
		(   p_Agreement_rec               => l_Agreement_rec
		,   p_Price_LHeader_rec           => l_Price_LHeader_rec
		,   p_Price_LLine_tbl             => l_Price_LLine_tbl
		,   p_Pricing_Attr_tbl            => l_Pricing_Attr_tbl
		,   x_Agreement_val_rec           => x_Agreement_val_rec
		,   x_Price_LHeader_val_rec       => x_Price_LHeader_val_rec
		,   x_Price_LLine_val_tbl         => x_Price_LLine_val_tbl
		,   x_Pricing_Attr_val_tbl        => x_Pricing_Attr_val_tbl
		);

    END IF;
*/

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
            ,   'Get_Agreement'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Agreement;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_Agreement_rec                 IN  Agreement_Rec_Type
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_Pricing_Attr_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_Agreement_val_rec             OUT NOCOPY /* file.sql.39 change */ Agreement_Val_Rec_Type
,   x_Price_LHeader_val_rec         OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_Price_LLine_val_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_Pricing_Attr_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS

BEGIN

    --  Convert Agreement

    x_Agreement_val_rec := OE_Agreement_Util.Get_Values(p_Agreement_rec);

    --  Convert Price_LHeader

    x_Price_LHeader_val_rec := QP_Price_List_Util.Get_Values(p_Price_LHeader_rec);

    --  Convert Price_LLine

    FOR I IN 1..p_Price_LLine_tbl.COUNT LOOP
        x_Price_LLine_val_tbl(I) :=
            QP_Price_List_Line_Util.Get_Values(p_Price_LLine_tbl(I));
    END LOOP;


    --  Convert PRICING_ATTR

    FOR I IN 1..p_Pricing_Attr_tbl.COUNT LOOP
        x_Pricing_Attr_val_tbl(I) :=
            QP_pll_pricing_attr_Util.Get_Values(p_Pricing_Attr_tbl(I));
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
,   p_Agreement_rec                 IN  Agreement_Rec_Type
,   p_Agreement_val_rec             IN  Agreement_Val_Rec_Type
,   p_Price_LHeader_rec             IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_Price_LHeader_val_rec         IN  QP_Price_List_PUB.Price_List_Val_Rec_Type
,   p_Price_LLine_tbl               IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_Price_LLine_val_tbl           IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   p_Pricing_Attr_tbl			 IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   p_Pricing_Attr_val_tbl		 IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LLine_tbl	            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Pricing_Attr_tbl	       	    OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
)
IS
l_Agreement_rec               Agreement_Rec_Type;
l_Price_LHeader_rec           QP_Price_List_PUB.Price_List_Rec_Type;
l_Price_LLine_rec             QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_Pricing_Attr_rec			QP_Price_List_PUB.Pricing_Attr_Rec_Type;

l_index                       BINARY_INTEGER;

BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert Agreement

    l_Agreement_rec := OE_Agreement_Util.Get_Ids
    (   p_Agreement_rec               => p_Agreement_rec
    ,   p_Agreement_val_rec           => p_Agreement_val_rec
    );

    x_Agreement_rec                := l_Agreement_rec;

    IF l_Agreement_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert Price_LHeader

    l_Price_LHeader_rec := QP_Price_List_Util.Get_Ids
    (   p_Price_List_rec           => p_Price_LHeader_rec
    ,   p_Price_List_val_rec       => p_Price_LHeader_val_rec
    );

    x_Price_LHeader_rec            := l_Price_LHeader_rec;

    IF l_Price_LHeader_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


    --  Convert Price_LLine

    x_Price_LLine_tbl := p_Price_LLine_tbl;

    l_index := p_Price_LLine_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_Price_LLine_rec := QP_Price_List_Line_Util.Get_Ids
        (   p_Price_List_Line_rec             => p_Price_LLine_tbl(l_index)
        ,   p_Price_List_Line_val_rec         => p_Price_LLine_val_tbl(l_index)
        );

        x_Price_LLine_tbl(l_index)     := l_Price_LLine_rec;

        IF l_Price_LLine_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Price_LLine_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert PRICING_ATTR

	x_Pricing_Attr_tbl := p_Pricing_Attr_tbl;

	l_index := p_PRICING_ATTR_val_tbl.FIRST;

	WHILE l_index IS NOT NULL LOOP

	 	l_PRICING_ATTR_rec := QP_pll_pricing_attr_Util.Get_Ids
	 	(   	p_PRICING_ATTR_rec            => p_PRICING_ATTR_tbl(l_index)
		 ,	p_PRICING_ATTR_val_rec        => p_PRICING_ATTR_val_tbl(l_index)
	 	 );

	 	x_Pricing_Attr_tbl(l_index)    := l_Pricing_Attr_rec;

	 	IF l_PRICING_ATTR_rec.return_status = FND_API.G_RET_STS_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
	 	END IF;

	 	l_index := p_Pricing_Attr_val_tbl.NEXT(l_index);
	 END LOOP;


EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR; /* file.sql.39 change */

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

END OE_Pricing_Cont_PUB;

/
