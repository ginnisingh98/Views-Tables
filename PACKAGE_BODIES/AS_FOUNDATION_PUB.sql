--------------------------------------------------------
--  DDL for Package Body AS_FOUNDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_FOUNDATION_PUB" as
/* $Header: asxpfoub.pls 120.1 2005/06/05 22:52:17 appldev  $ */
--
-- NAME
-- AS_FOUNDATION_PUB
--
-- HISTORY
--   8/06/98       ALHUNG        CREATED
--   Sept 1, 98    cklee         Added new function Get_Constant
--   06/22/99      awu           Added get_messages and get_periodNames
--	6/29/2000		Srikanth	deleted get_messages as it was implemented in as_utility_pub

G_PKG_NAME  CONSTANT VARCHAR2(30):='AS_FOUNDATION_PUB';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxpfoub.pls';
--G_USER_ID         NUMBER := FND_GLOBAL.User_Id;


PROCEDURE Get_inventory_items(  p_api_version_number      IN    NUMBER,
                                p_init_msg_list           IN    VARCHAR2
                                    := FND_API.G_FALSE,
                                p_identity_salesforce_id  IN    NUMBER,
                                p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE,
                                x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                                x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER,
                                x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                                x_inventory_item_tbl      OUT NOCOPY /* file.sql.39 change */   AS_FOUNDATION_PUB.inventory_item_TBL_TYPE) IS




          -- Local API Variables
          l_api_name    CONSTANT VARCHAR2(30)     := 'Get_inventory_items';
          l_api_version_number  CONSTANT NUMBER   := 2.0;

          -- Local Identity Variables

          l_identity_sales_member_rec      AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

          -- Locat tmp Variables
          l_inventory_item_rec AS_FOUNDATION_PUB.inventory_item_Rec_Type;

          -- Local record index
          l_cur_index Number := 0;

          -- Local return statuses
          l_return_status Varchar2(1);

  BEGIN
            -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      --THEN
          --dbms_output.put_line('AS_FOUNDATION_PUB.Get_inventory_items: Start');
      --END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- API BODY

      AS_FOUNDATION_PVT.Get_inventory_items(  p_api_version_number  => 2.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_identity_salesforce_id => p_identity_salesforce_id,
                                p_inventory_item_rec => p_inventory_item_rec,
                                x_return_status  => l_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_inventory_item_tbl  => x_inventory_item_tbl);


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) Then
          RAISE FND_API.G_EXC_ERROR;
      End if;

    -- API Ending

    x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
        FND_MSG_PUB.Add;
    END IF;


      -- Debug Message
    --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    --THEN
      --dbms_output.put_line('AS_FOUNDATION_PUB.Get_inventory_items: End');
    --END IF;

      -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );


  End Get_inventory_items;

--
-- NAME
--   Get_FND_API_Constant
--
-- PURPOSE
--   This function will return constant according to the passed in constant name.
--   This is a problem referencing constants from forms. We have to create server-
--   side function that return these values.
--
-- NOTES
--
FUNCTION Get_Constant(Constant_Name varchar2)
return varchar2
IS
BEGIN

	if upper(Constant_Name) = 'FND_API.G_TRUE' then
		return FND_API.G_TRUE;
	elsif upper(Constant_Name) = 'FND_API.G_VALID_LEVEL_FULL' then
		return FND_API.G_VALID_LEVEL_FULL;
	elsif upper(Constant_Name) = 'FND_API.G_VALID_LEVEL_NONE' then
		return FND_API.G_VALID_LEVEL_NONE;
	-- elsif upper(Constant_Name) = 'CS_INTERACTION_GRP.G_VALID_LEVEL_INT' then
		-- return CS_INTERACTION_GRP.G_VALID_LEVEL_INT; -- Commented OUT NOCOPY /* file.sql.39 change */ by Twzhou on March 07, 2000
	else
		return null;
	end if;

EXCEPTION
  When OTHERS  then
	NULL;
END;

PROCEDURE Calculate_Amount( p_api_version_number      IN    NUMBER,
                            p_init_msg_list           IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
			    p_validation_level	      IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            p_identity_salesforce_id  IN    NUMBER,
			    p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE
				 DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
			    p_secondary_interest_code_id    IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			    p_currency_code	      IN    VARCHAR2,
			    p_volume		      IN    NUMBER,
                            x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                            x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER,
                            x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
			    x_amount		      OUT NOCOPY /* file.sql.39 change */   NUMBER) IS

	-- Local API Variables
	l_api_name    CONSTANT VARCHAR2(30)     := 'Calculate_Amount';
	l_api_version_number  CONSTANT NUMBER   := 2.0;

	l_inv_item_tbl	AS_FOUNDATION_PUB.Inventory_Item_tbl_type;
	l_price_list_id NUMBER;
	l_price		NUMBER;
	l_amount	NUMBER;
BEGIN
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                       p_api_version_number,
                       l_api_name,
                       G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
	--IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           --dbms_output.put_line('AS_Foundation_PUB.Calculate_Amount: Start');
	--END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- Fix bug 858155 initialize the l_price to NULL instead of 0
	l_price := NULL;
	IF (p_inventory_item_rec.inventory_item_id IS NOT NULL) AND
	   (p_inventory_item_rec.inventory_item_id <> FND_API.G_MISS_NUM) THEN
	      AS_FOUNDATION_PUB.Get_Inventory_items(
			p_api_version_number => 2.0,
			p_init_msg_list => FND_API.G_TRUE,
			p_identity_salesforce_id => NULL,
			p_inventory_item_rec => p_inventory_item_rec,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data,
			x_inventory_item_tbl => l_inv_item_tbl);
	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	         --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		    --dbms_output.put_line('AS_FOUNDATION_PUB - Item : Not Found');
	         --END IF;
	         raise FND_API.G_EXC_ERROR;
	      END IF;
	      IF (p_inventory_item_rec.Primary_UOM_Code IS NOT NULL) THEN
		   l_inv_item_tbl(1).Primary_UOM_Code := p_inventory_item_rec.Primary_UOM_Code;
	      END IF;
	      -- Debug Message
--	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                 --dbms_output.put_line('AS_Foundation_PVT - UOM:' || p_inventory_item_rec.Primary_Uom_Code);
	      --END IF;
	      AS_FOUNDATION_PVT.Get_Price_Info(p_api_version_number => 2.0,
			     p_init_msg_list => FND_API.G_FALSE,
			     p_inventory_item_rec => l_inv_item_tbl(1),
			     p_secondary_interest_code_id => NULL,
			     p_currency_code => p_currency_code,
			     x_return_status => x_return_status,
			     x_msg_count => x_msg_count,
			     x_msg_data => x_msg_data,
			     x_price_list_id => l_price_list_id,
			     x_price => l_price);
	     Elsif (p_secondary_interest_code_id IS NOT NULL) AND
		   (p_secondary_interest_code_id <> FND_API.G_MISS_NUM) THEN
	      AS_FOUNDATION_PVT.Get_Price_Info(p_api_version_number => 2.0,
			     p_init_msg_list => FND_API.G_FALSE,
			     p_inventory_item_rec => NULL,
			     p_secondary_interest_code_id => p_secondary_interest_code_id,
			     p_currency_code => p_currency_code,
			     x_return_status => x_return_status,
			     x_msg_count => x_msg_count,
			     x_msg_data => x_msg_data,
			     x_price_list_id => l_price_list_id,
			     x_price => l_price);
	   END IF;
	   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		   --dbms_output.put_line('AS_FOUNDATION_PUB - Price : Not Found');
	      --END IF;
	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		   FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
		   FND_MESSAGE.Set_Token('COLUMN','Price', FALSE);
		   FND_MSG_PUB.ADD;
	      END IF;
	      raise FND_API.G_EXC_ERROR;
	   END IF;
	   -- Fix bug 858155
	   IF l_price IS NULL THEN
	      l_amount := NULL;
	     ELSE
	      l_amount := p_volume * l_price;
	   END IF;
--	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	      --dbms_output.put_line('AS_Foundation_PUB - Amount: ' || to_char(l_amount));
	   --END IF;
 	   x_amount := l_amount;
	   -- Success Message
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
	      FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
	      FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
	      FND_MSG_PUB.Add;
	   END IF;

	   -- Debug Message
--	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	      --dbms_output.put_line('AS_Foundation_PUB.Calculate_Amount: End');
	   --END IF;

	   -- Standard call to get message count and if count is 1, get message info.
	   FND_MSG_PUB.Count_And_Get
           (   p_count           =>      x_msg_count,
               p_data            =>      x_msg_data
           );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
          --THEN
            --dbms_output.put_line('AS_Foundation_PUB. - Cannot Find Price List Id');
          --END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );
END Calculate_Amount;

PROCEDURE Get_PeriodNames
(    p_api_version_number             IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                            := FND_API.G_FALSE,
    p_period_rec                 IN     UTIL_PERIOD_REC_TYPE,
    x_period_tbl                 OUT NOCOPY /* file.sql.39 change */     UTIL_PERIOD_TBL_TYPE,
        x_return_status                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        x_msg_count                 OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2
) IS
l_api_name    CONSTANT VARCHAR2(30)     := 'Get_PeriodNames';
l_api_version_number  CONSTANT NUMBER   := 2.0;
l_period_rec_in AS_FOUNDATION_PVT.UTIL_PERIOD_REC_TYPE;
l_period_tbl AS_FOUNDATION_PVT.UTIL_PERIOD_TBL_TYPE;

begin
 -- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
			FND_MESSAGE.Set_Token('ROW', 'AS_ACCESSES', TRUE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--
	-- API body
	--

	-- Validate Environment

	IF FND_GLOBAL.User_Id IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
	END IF;

	l_period_rec_in.period_name := p_period_rec.period_name;
	l_period_rec_in.start_date := p_period_rec.start_date;
	l_period_rec_in.end_date := p_period_rec.end_date;

	as_foundation_pvt.Get_PeriodNames
	(       p_api_version_number  => l_api_version_number,
		p_init_msg_list       => FND_API.G_FALSE,
		p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
		p_period_rec          => l_period_rec_in,
		x_period_tbl          => l_period_tbl,
		x_return_status       => x_return_status,
		x_msg_count           => x_msg_count,
		x_msg_data            => x_msg_data);


    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

end get_periodNames;


END AS_FOUNDATION_PUB;

/
