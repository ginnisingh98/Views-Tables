--------------------------------------------------------
--  DDL for Package Body ASO_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_VALIDATE_PVT" as
/* $Header: asovvldb.pls 120.31.12010000.7 2012/11/21 18:53:40 vidsrini ship $ */

-- Start of Comments
-- Package name     : ASO_VALIDATE_PVT
-- Purpose          :
--
-- History          :
--				08/01/2002 hyang - 2492841, performance change
--				10/18/2002 hyang - 2633507, performance fix
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_VALIDATE_PVT';


PROCEDURE Validate_NotNULL_NUMBER (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_notnull_column IS NULL OR p_notnull_column = FND_API.G_MISS_NUM) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', p_column_name, FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_NotNULL_NUMBER;


PROCEDURE Validate_NotNULL_VARCHAR2 (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_notnull_column IS NULL OR p_notnull_column = FND_API.G_MISS_CHAR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', p_column_name, FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_NotNULL_VARCHAR2;


PROCEDURE Validate_NotNULL_DATE (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_notnull_column IS NULL OR p_notnull_column = FND_API.G_MISS_DATE) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', p_column_name, FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_NotNULL_DATE;


PROCEDURE Validate_For_GreaterEndDate (
	p_init_msg_list		IN	VARCHAR2,
	p_start_date            IN      DATE,
        p_end_date              IN      DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_start_date IS NOT NULL AND p_start_date <> FND_API.G_MISS_DATE) AND
     (p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE) THEN

    IF (p_end_date < p_start_date ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'INVALID COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', 'END DATE', FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;
  END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_For_GreaterEndDate;


PROCEDURE Validate_Party(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_party_usage		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Party IS
	SELECT status FROM HZ_PARTIES
	WHERE party_id = p_party_id;
    l_party_status	VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Party: Begin: p_party_id: '||p_party_id, 1, 'N');
  aso_debug_pub.add('Validate_Party: p_party_usage: '||p_party_usage, 1, 'N');
END IF;

    IF (p_party_id IS NOT NULL AND p_party_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Party;
	FETCH C_Party INTO l_party_status;
        IF (C_Party%NOTFOUND OR l_party_status <> 'A') THEN
	    CLOSE C_Party;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', p_party_usage, FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Party;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Party: x_return_status: '||x_return_status, 1, 'N');
END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_Party;

PROCEDURE Validate_Contact(
	p_init_msg_list		IN	VARCHAR2,
	p_contact_id		IN	NUMBER,
	p_contact_usage		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Contact IS
	SELECT status FROM HZ_ORG_CONTACTS
	WHERE org_contact_id = p_contact_id;

    l_contact_status	VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Contact: p_contact_id: '||p_contact_id, 1, 'N');
  aso_debug_pub.add('Validate_Contact: p_contact_usage: '||p_contact_usage, 1, 'N');
END IF;

    IF (p_contact_id IS NOT NULL AND p_contact_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Contact;
	FETCH C_Contact INTO l_contact_status;
        IF (C_Contact%NOTFOUND OR l_contact_status <> 'A') THEN
	    CLOSE C_Contact;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', p_contact_usage, FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Contact;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Contact: x_return_status: '||x_return_status, 1, 'N');
END IF;
    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_Contact;


PROCEDURE Validate_PartySite(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_party_site_id		IN	NUMBER,
	p_site_usage		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Party_Site IS
	SELECT status -- start_date_active, end_date_active obsolete
	FROM HZ_PARTY_SITES
	WHERE  party_site_id = p_party_site_id;

    l_status        VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartySite: p_party_id: '||p_party_id, 1, 'N');
  aso_debug_pub.add('Validate_PartySite: p_party_site_id: '||p_party_site_id, 1, 'N');
  aso_debug_pub.add('Validate_PartySite: p_site_usage: '||p_site_usage, 1, 'N');
END IF;

    IF (p_party_site_id IS NOT NULL AND p_party_site_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Party_Site;
	FETCH C_Party_Site INTO l_status;
        IF C_Party_Site%NOTFOUND OR
		 l_status <> 'A' THEN

	    CLOSE C_Party_Site;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', p_site_usage, FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Party_Site;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartySite: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_PartySite;

PROCEDURE Validate_OrderType(
	p_init_msg_list		IN	VARCHAR2,
	p_order_type_id		IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Order_Type IS
	SELECT start_date_active, end_date_active FROM ASO_I_ORDER_TYPES_V
	WHERE order_type_id = p_order_type_id;
    l_start_date	DATE;
    l_end_date		DATE;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrderType: p_order_type_id: '||p_order_type_id, 1, 'N');
END IF;
    IF (p_order_type_id IS NOT NULL AND p_order_type_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Order_Type;
	FETCH C_Order_Type INTO l_start_date, l_end_date;
        IF (C_Order_Type%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
				 NVL(l_end_date, sysdate))) THEN
	    CLOSE C_Order_Type;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'ORDER_TYPE_ID', FALSE);
			 FND_MESSAGE.Set_Token ('VALUE' ,to_char(p_order_type_id), FALSE );
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Order_Type;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrderType: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_OrderType;



PROCEDURE Validate_LineType(
	p_init_msg_list		IN	VARCHAR2,
	p_order_line_type_id		IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Order_Line_Type IS
	SELECT start_date_active, end_date_active FROM ASO_I_LINE_TYPES_V
	WHERE line_type_id = p_order_line_type_id;
    l_start_date	DATE;
    l_end_date		DATE;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_LineType: p_order_line_type_id: '||p_order_line_type_id, 1, 'N');
END IF;
    IF (p_order_line_type_id IS NOT NULL AND p_order_line_type_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Order_Line_Type;
	FETCH C_Order_Line_Type INTO l_start_date, l_end_date;
        IF (C_Order_Line_Type%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
				 NVL(l_end_date, sysdate))) THEN
	    CLOSE C_Order_Line_Type;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'ORDER_LINE_TYPE_ID', FALSE);
			 FND_MESSAGE.Set_Token ('VALUE' ,to_char(p_order_line_type_id), FALSE );
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Order_Line_Type;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_LineType: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_LineType;


PROCEDURE Validate_PriceList(
	p_init_msg_list		IN	VARCHAR2,
	p_price_list_id		IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Price_List IS
	SELECT (start_date_active), (end_date_active) FROM QP_PRICELISTS_LOV_V
	WHERE price_list_id = p_price_list_id and (orig_org_id = mo_global.get_current_org_id or global_flag ='Y'); --bug5188699
	/* Verified with QP this UNION is not necessary dgyawali verified with spgopal 08/12/02*/
	/**
	UNION
		select  qlhv.start_date_active, qlhv.end_date_active
			from qp_list_headers_vl qlhv, oe_agreements oa
				where oa.price_list_id = qlhv.list_header_id
					and qlhv.list_type_code = 'PRL'
						and oa.price_list_id = p_price_list_id;
	**/


    l_start_date	DATE;
    l_end_date		DATE;
    l_org_id        NUMBER  :=  mo_global.get_current_org_id;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('Validate_PriceList Begin: p_price_list_id: '||p_price_list_id, 1, 'N');
     aso_debug_pub.add('Validate_PriceList :mo_global.get_current_org_id '||l_org_id, 1, 'N');
    END IF;



    IF (p_price_list_id IS NOT NULL AND p_price_list_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Price_List;
	FETCH C_Price_List INTO l_start_date, l_end_date;
        IF (C_Price_List%NOTFOUND OR
	    (trunc(sysdate) NOT BETWEEN NVL(trunc(l_start_date), trunc(sysdate)) AND
				 NVL(trunc(l_end_date), trunc(sysdate)))) THEN
	    CLOSE C_Price_List;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PRICE_LIST_ID', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_price_list_id),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Price_List;
	END IF;
    END IF;

END Validate_PriceList;

PROCEDURE Validate_Quote_Price_Exp(
	p_init_msg_list		IN	VARCHAR2,
	p_price_list_id		IN	NUMBER,
        p_quote_expiration_date   IN DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Price_List IS
	SELECT start_date_active, end_date_active FROM QP_PRICE_LISTS_V
	WHERE price_list_id = p_price_list_id;
     /* Verified with QP this UNION is not necessary dgyawali verified with spgopal 08/12/02*/
	/**
	UNION
		select  qlhv.start_date_active, qlhv.end_date_active
			from qp_list_headers_vl qlhv, oe_agreements oa
				where oa.price_list_id = qlhv.list_header_id
					and qlhv.list_type_code = 'PRL'
						and oa.price_list_id = p_price_list_id;
     **/

    l_start_date	DATE;
    l_end_date		DATE;
    l_quote_expiration_date		DATE;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_price_list_id IS NOT NULL AND p_price_list_id <> FND_API.G_MISS_NUM) THEN

        OPEN C_Price_List;
     	FETCH C_Price_List INTO l_start_date, l_end_date;
        IF (C_Price_List%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
				 NVL(l_end_date, sysdate))) THEN
	    CLOSE C_Price_List;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PRICE_LIST_ID', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_price_list_id),FALSE);
                FND_MSG_PUB.ADD;
      	    END IF;
    ELSIF l_end_date IS NOT NULL  AND p_quote_expiration_date <> FND_API.G_MISS_DATE AND nvl(trunc(p_quote_expiration_date), trunc(l_end_date)) > trunc(l_end_date) THEN
       -- ELSIF nvl(p_quote_expiration_date,(sysdate+30))  > l_end_date THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'Price List Expires Before Quote', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_price_list_id),FALSE);
                FND_MSG_PUB.ADD;
	           END IF;
        --CLOSE C_Price_List;
	   END IF;
     CLOSE C_Price_List;
    END IF;
   --END IF;
END Validate_Quote_Price_Exp;


PROCEDURE Validate_Quote_Exp_date(
    p_init_msg_list         IN  VARCHAR2,
    p_quote_expiration_date IN  DATE,
    x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS

    l_start_date            DATE;
    l_end_date              DATE;
    l_quote_expiration_date DATE;

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_quote_expiration_date IS NOT NULL and p_quote_expiration_date <> FND_API.G_MISS_DATE THEN
        IF (trunc(sysdate) > trunc(p_quote_expiration_date))THEN
       	    x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

END Validate_Quote_Exp_date;



-- hyang quote_status
PROCEDURE Validate_Quote_Status(
	p_init_msg_list		  IN	VARCHAR2,
	p_quote_status_id	  IN	NUMBER,
	x_return_status		  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  x_msg_count		      OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  x_msg_data		      OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

  CURSOR c_Quote_Status
  IS
	  SELECT  quote_status_id, enabled_flag
	  FROM    ASO_QUOTE_STATUSES_B
	  WHERE   quote_status_id = p_quote_status_id;


  l_quote_status_id   NUMBER;
  l_enabled_flag      VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_Quote_Status;
    FETCH c_Quote_Status INTO l_quote_status_id, l_enabled_flag;
    IF (c_Quote_Status%NOTFOUND) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_STATUS_ID', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
    ELSIF (l_enabled_flag <> 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_DISABLED_STATUS');
        FND_MSG_PUB.ADD;
      END IF;
  	END IF;
    CLOSE C_Quote_Status;

END Validate_Quote_Status;
-- end of hyang quote_status


PROCEDURE Validate_Inventory_Item(
	p_init_msg_list		IN	VARCHAR2,
	p_inventory_item_id	IN	NUMBER,
	p_organization_id       IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

/* 2633507 - hyang: use mtl_system_items_b instead of vl */

    CURSOR C_Inventory_Item IS
	SELECT start_date_active, end_date_active,vendor_warranty_flag,service_item_flag  FROM MTL_SYSTEM_ITEMS_B
	WHERE inventory_item_id = p_inventory_item_id
	and organization_id = p_organization_id;

    l_start_date	DATE;
    l_end_date		DATE;
    l_war_flag          VARCHAR2(1);
    l_svr_flag          VARCHAr2(1);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_inventory_item_id IS NULL OR p_inventory_item_id = FND_API.G_MISS_NUM) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', 'INVENTORY_ITEM_ID', FALSE);
            FND_MSG_PUB.ADD;
	   END IF;
    ELSE
        OPEN C_Inventory_Item;
	FETCH C_Inventory_Item INTO l_start_date, l_end_date,l_war_flag,l_svr_flag;
        IF (C_Inventory_Item%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
				 NVL(l_end_date, sysdate))) THEN
	    CLOSE C_Inventory_Item;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'INVENTORY_ITEM_ID', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_inventory_item_id),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
	ELSIF l_war_flag ='Y'and l_svr_flag ='Y' THEN
		  CLOSE C_Inventory_Item;
             x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO4');
               -- FND_MESSAGE.Set_Token('COLUMN', 'INVENTORY_ITEM_ID', FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Inventory_Item;
	END IF;
    END IF;

END Validate_Inventory_Item;

PROCEDURE Validate_Item_Type_Code(
	p_init_msg_list		IN	VARCHAR2,
	p_item_type_code	IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
 CURSOR C_item_type_code IS
 SELECT lookup_code
 FROM   aso_lookups lk
 WHERE  lookup_type = 'ASO_ITEM_TYPE'
 AND    lookup_code = p_item_type_code;

/* select item_type_code from aso_i_item_types_v
   where item_type_code = p_item_type_code; */

 l_item_type_code   VARCHAR2(30);
BEGIN
--dbms_output.put_line('beginning of item type code '||p_item_type_code);
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_item_type_code IS NOT NULL AND p_item_type_code <> FND_API.G_MISS_CHAR) THEN
--        dbms_output.put_line('in item type code '|| x_return_status);
        OPEN C_item_type_code;
	FETCH C_item_type_code INTO l_item_type_code;
        IF (C_item_type_code%NOTFOUND) THEN
	    CLOSE C_item_type_code;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'ITEM_TYPE_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_item_type_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_item_type_code;
	END IF;
    END IF;
END Validate_ITEM_TYPE_CODE;




PROCEDURE Validate_Marketing_Source_Code(
	p_init_msg_list		IN	VARCHAR2,
	p_mkting_source_code_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
 CURSOR C_marketing_code IS
 select source_code_id from aso_i_mktg_src_codes_v
 where source_code_id = p_mkting_source_code_id;

 l_mkting_source_code   NUMBER;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_mkting_source_code_id IS NOT NULL AND p_mkting_source_code_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_marketing_code;
	FETCH C_marketing_code INTO l_mkting_source_code;
        IF (C_marketing_code%NOTFOUND) THEN
	    CLOSE C_marketing_code;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'MARKETING_SOURCE_CODE_ID', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_mkting_source_code_id),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_marketing_code;
	END IF;
    END IF;

END Validate_MARKETING_SOURCE_CODE;


PROCEDURE Validate_UOM_code(
	p_init_msg_list		IN	VARCHAR2,
	p_uom_code      	IN	VARCHAR2,
        p_organization_id       IN      NUMBER,
        p_inventory_item_id     IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
 CURSOR C_uom_code IS
 select uom_code from MTL_ITEM_UOMS_VIEW
 where uom_code = p_uom_code
 and inventory_item_id = p_inventory_item_id
 and organization_id = p_organization_id;

 l_uom_code   VARCHAR2(30);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_uom_code IS NOT NULL AND p_uom_code <> FND_API.G_MISS_CHAR) THEN
        OPEN C_uom_code;
	FETCH C_uom_code INTO l_uom_code;
        IF (C_uom_code%NOTFOUND) THEN
	    CLOSE C_uom_code;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'UOM_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_uom_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_uom_code;
	END IF;
    END IF;

END Validate_UOM_CODE;


PROCEDURE Validate_Tax_Exemption(
	p_init_msg_list		IN	VARCHAR2,
	p_tax_exempt_flag	IN	VARCHAR2,
	p_tax_exempt_reason_code IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_tax_exempt_flag = 'E' AND
	(p_tax_exempt_reason_code IS NULL OR
	 p_tax_exempt_reason_code = FND_API.G_MISS_CHAR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', 'TAX_EXEMPT_REASON', FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_Tax_Exemption;


-- New procedure added by Bmishra on 01/23/2002 by removing the earlier validate_configuration procedure

PROCEDURE Validate_Configuration(
    p_init_msg_list         IN  VARCHAR2,
    p_config_header_id      IN  NUMBER,
    p_config_revision_num   IN  NUMBER,
    p_config_item_id        IN  NUMBER,
    --p_component_code      IN  VARCHAR2,
    x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
 -- We will add config_item_id when we will implement solution model
 CURSOR C_configuration IS
 SELECT component_code
 FROM cz_config_details_V
 WHERE CONFIG_HDR_ID = p_config_header_id
 AND CONFIG_REV_NBR  = p_config_revision_num
 --AND component_code = p_component_code;
 AND CONFIG_ITEM_ID  = config_item_id;

 l_component_code   VARCHAR2(1000);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN C_configuration;
    FETCH C_configuration INTO l_component_code;
    IF (C_configuration%NOTFOUND) THEN
       CLOSE C_configuration;
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_VALIDATE_PVT.validate_configuration: Inside C_configuration Not Found condition',1,'N');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_CONFIGURATION');
           FND_MESSAGE.Set_Token('HDR_ID',p_config_header_id, FALSE);
           FND_MESSAGE.Set_Token('REV_NO',p_config_revision_num, FALSE);
           FND_MESSAGE.Set_Token('CONFIG_ITEM_ID',p_config_item_id, FALSE);
           FND_MSG_PUB.ADD;
       END IF;
    ELSE
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_VALIDATE_PVT.validate_configuration: Inside C_configuration Not Found ELSE condition', 1, 'N');
       END IF;
       CLOSE C_configuration;
    END IF;
END Validate_Configuration;

-- End Of procedure Bmishra 01/23/2002

PROCEDURE Validate_Delayed_Service(
	p_init_msg_list		IN	VARCHAR2,
	p_service_ref_type_code IN      VARCHAR2,
        p_service_ref_line_id   IN      NUMBER,
        p_service_ref_system_id IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
/*CURSOR C_servicetypes IS
  select service_reference_type_code
  from aso_i_service_types_v
  where service_reference_type_code = p_service_ref_type_code;*/
CURSOR C_servicetypes IS
  select lookup_code
  from aso_lookups
  where lookup_code = p_service_ref_type_code and
  lookup_type = 'ASO_SERVICE_TYPE';

l_service_code VARCHAR2(30);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_service_ref_type_code IS NOT NULL AND p_service_ref_type_code <> FND_API.G_MISS_CHAR) THEN
        OPEN C_servicetypes;
	FETCH C_servicetypes INTO l_service_code;
        IF (C_servicetypes%NOTFOUND) THEN
	    CLOSE C_servicetypes;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_TYPE_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_service_ref_type_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_servicetypes;
              null;
           -- kchervel check
           -- IF p_service_ref_type_code = 'CUSTOMER_PRODUCT' THEN
           -- IF p_service_ref_type_code = 'ORDER' THEN

	END IF;
    END IF;


END;


PROCEDURE Validate_Service(
        p_init_msg_list             IN   VARCHAR2,
        p_inventory_item_id         IN   NUMBER,
        p_start_date_active         IN   DATE,
        p_end_date_active           IN   DATE,
        p_service_duration          IN   NUMBER,
        p_service_period            IN   VARCHAR2,
        p_service_coterminate_flag  IN   VARCHAR2,
        p_organization_id           IN   NUMBER,
        x_return_status             OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count                 OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data                  OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS

  CURSOR C_service_item IS
  SELECT inventory_item_id, service_item_flag
  FROM mtl_system_items_b
  WHERE inventory_item_id  =  p_inventory_item_id
  AND   organization_id    =  p_organization_id;

  l_inventory_item_id NUMBER;
  l_service_item_flag VARCHAR(1);

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_VALIDATE_PVT: Validate_Service: Begin validate_service procedure.');
      aso_debug_pub.add('Validate_Service: p_inventory_item_id:        '|| p_inventory_item_id);
      aso_debug_pub.add('Validate_Service: p_start_date_active:        '|| p_start_date_active);
      aso_debug_pub.add('Validate_Service: p_end_date_active:          '|| p_end_date_active);
      aso_debug_pub.add('Validate_Service: p_service_duration:         '|| p_service_duration);
      aso_debug_pub.add('Validate_Service: p_service_period:           '|| p_service_period);
      aso_debug_pub.add('Validate_Service: p_service_coterminate_flag: '|| p_service_coterminate_flag);
      aso_debug_pub.add('Validate_Service: p_organization_id:          '|| p_organization_id);
    END IF;

    IF p_inventory_item_id <> FND_API.G_MISS_NUM THEN

        OPEN  C_service_item;
	   FETCH C_service_item INTO l_inventory_item_id, l_service_item_flag;

        IF C_service_item%NOTFOUND THEN

             CLOSE C_service_item;
	        x_return_status := FND_API.G_RET_STS_ERROR;

             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                 FND_MESSAGE.Set_Token('COLUMN', 'Inventory_item_id', FALSE);
			  FND_MESSAGE.Set_Token('VALUE',to_char(p_inventory_item_id),FALSE);
                 FND_MSG_PUB.ADD;
	        END IF;

        ELSE
             CLOSE C_service_item;

             --if service start date must exist
             IF l_service_item_flag = 'Y' THEN

                 IF p_start_date_active IS NULL  OR  p_start_date_active = FND_API.G_MISS_DATE THEN

	    	           x_return_status := FND_API.G_RET_STS_ERROR;

            	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                         FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_START_DATE', FALSE);
                         FND_MSG_PUB.ADD;
	                END IF;

                 -- if service we should be able to calc end date
                 ELSIF (p_end_date_active IS NULL  OR  p_end_date_active = FND_API.G_MISS_DATE) AND
                       (p_service_duration IS NULL OR  p_service_duration = FND_API.G_MISS_NUM) AND
                       (p_service_coterminate_flag IS NULL  OR
                          p_service_coterminate_flag = FND_API.G_MISS_CHAR) THEN


	    	                x_return_status := FND_API.G_RET_STS_ERROR;

            	           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                         FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                              FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_END_DATE', FALSE);
                              FND_MSG_PUB.ADD;
	                     END IF;

                 END IF; -- start and end date active

             END IF; -- l_service_item_flag = 'Y'

         END IF; -- C_service_item%NOTFOUND

      END IF; -- p_inventory_item_id <> FND_API.G_MISS_NUM
END;



PROCEDURE Validate_Service_Duration(
	p_init_msg_list		IN	VARCHAR2,
        p_service_duration      IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_service_duration IS NOT NULL AND p_service_duration <> FND_API.G_MISS_NUM) THEN
        IF p_service_duration < 1 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_DURATION', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_service_duration),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        END IF;
    END IF;

END;

PROCEDURE Validate_Service_Period(
	p_init_msg_list		IN	VARCHAR2,
        p_service_period        IN      VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
null;
END;

PROCEDURE Validate_Returns(
        p_init_msg_list		IN	VARCHAR2,
        p_return_ref_type_code  IN      VARCHAR2,
        p_return_ref_header_id  IN      NUMBER,
        p_return_ref_line_id    IN      NUMBER,
        x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_returntypes IS
  select return_reference_type_code
  from aso_i_return_types_v
  where return_reference_type_code = p_return_ref_type_code;

l_return_code VARCHAR2(30);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_return_ref_type_code IS NOT NULL AND p_return_ref_type_code <> FND_API.G_MISS_CHAR) THEN
        OPEN C_returntypes;
	FETCH C_returntypes INTO l_return_code;
        IF (C_returntypes%NOTFOUND) THEN
	    CLOSE C_returntypes;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'RETURN_TYPE_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_return_ref_type_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_returntypes;
	END IF;
    END IF;


END ;


PROCEDURE Validate_EmployPerson(
        p_init_msg_list		IN	VARCHAR2,
        p_employee_id           IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_employperson IS
 SELECT start_date_active, end_date_active,status
 FROM jtf_rs_srp_vl
 WHERE person_id = p_employee_id;

l_start_date DATE;
l_end_date DATE;
l_status VARCHAR2(1);
BEGIN

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_employee_id IS NOT NULL AND p_employee_id <> FND_API.G_MISS_NUM THEN
       Open C_employperson;
       FETCH C_employperson into l_start_date, l_end_date,l_status;

       IF (C_employperson%NOTFOUND OR l_status<> 'A') THEN
	    CLOSE C_employperson;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SALES_REP');
                FND_MESSAGE.Set_Token('COLUMN','EMPLOYEE_PERSON_ID' , FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_employperson;
            IF trunc(sysdate) > nvl(trunc(l_end_date), trunc(sysdate)) THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'NOT_EFFECTIVE');
                FND_MESSAGE.Set_Token('COLUMN','EMPLOYEE_PERSON_ID' , FALSE);
                FND_MSG_PUB.ADD;
	      END IF;
            END IF;
	END IF;
      END IF;
END;

PROCEDURE Validate_CategoryCode(
        p_init_msg_list		IN	VARCHAR2,
        p_category_code         IN      VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
null;
END;



PROCEDURE Validate_For_Positive(
	p_init_msg_list		IN	VARCHAR2,
        p_column_name           IN      VARCHAR2,
	p_value			IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_value < 0) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', p_column_name, FALSE);
            FND_MSG_PUB.ADD;
	END IF;
    END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_For_Positive;


PROCEDURE Validate_Salescredit_Type(
	p_init_msg_list		IN	VARCHAR2,
	p_salescredit_type_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

/*
 * 2633507 - hyang: use oe_sales_credit_types instead of
 * aso_i_sales_credit_types_v
 */

 CURSOR C_salescredit_type IS
 select name from oe_sales_credit_types
 where sales_credit_type_id = p_salescredit_type_id;

 l_sc_type VARCHAR2(240);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_salescredit_type_id IS NOT NULL AND p_salescredit_type_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_salescredit_type;
	FETCH C_salescredit_type INTO l_sc_type;
        IF (C_salescredit_type%NOTFOUND) THEN
	    CLOSE C_salescredit_type;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SALES CREDIT TYPE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_salescredit_type_id),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_salescredit_type;
	END IF;
    END IF;

END Validate_Salescredit_Type;

PROCEDURE Validate_Party_Type(
	p_init_msg_list		IN	VARCHAR2,
	p_party_type     	IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_party_type IS
 select 'VALID'
 from aso_lookups
 where lookup_type = 'ASO_PARTY_TYPE'
 and lookup_code = p_party_type;

 l_valid VARCHAR2(240);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartyType: p_party_type: '||p_party_type, 1, 'N');
END IF;
    IF (p_party_type IS NOT NULL AND p_party_type <> FND_API.G_MISS_CHAR) THEN
        OPEN C_party_type;
	FETCH C_party_type INTO l_valid;
        IF (C_party_type%NOTFOUND) THEN
	    CLOSE C_party_type;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PARTY TYPE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_party_type,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_party_type;
	END IF;
    END IF;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartyType: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_Party_Type;

PROCEDURE Validate_Resource_id(
    p_init_msg_list     IN      VARCHAR2,
    p_resource_id       IN      NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count	        OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data	        OUT NOCOPY /* file.sql.39 change */       VARCHAR2
)
IS

    CURSOR C_sales_rep (l_resource_id NUMBER) IS
    select 'VALID'
    /*  from jtf_rs_srp_vl */  --Commented Code Yogeshwar (MOAC)
    from jtf_rs_salesreps_mo_v --New Code Yogeshwar (MOAC)
     WHERE trunc(sysdate) BETWEEN trunc(NVL(start_date_active, sysdate))
       AND trunc(NVL(end_date_active, sysdate))
       --Commentd Code Start Yogeshwar (MOAC)
       /*
       AND NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO' ),1,1) , ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
       */
       --Commented Code End Yogeshwar (MOAC)
       AND resource_id = l_resource_id;

    l_valid VARCHAR2(240);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_resource_id IS NOT NULL AND p_resource_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_sales_rep(p_resource_id);
	FETCH C_sales_rep INTO l_valid;
        IF (C_sales_rep%NOTFOUND) THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
        CLOSE C_sales_rep;
    END IF;

END Validate_Resource_id;

-- jtf_rs_resource_ext
-- jtf_rs_res_emp_vl

PROCEDURE Validate_Emp_Res_id(
	p_init_msg_list		IN	VARCHAR2,
	p_resource_id	        IN	NUMBER,
	p_employee_person_id    IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_emp_res IS
 select person_id
 from jtf_rs_srp_vl
 where resource_id = p_resource_id
 and trunc(sysdate) BETWEEN trunc(NVL(start_date_active, sysdate)) AND
				 trunc(NVL(end_date_active, sysdate));

 l_person_id NUMBER;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_resource_id IS NOT NULL AND p_resource_id <> FND_API.G_MISS_NUM)
    AND  (p_employee_person_id IS NOT NULL AND p_employee_person_id <> FND_API.G_MISS_NUM)	 THEN
        OPEN  C_emp_res;
	FETCH  C_emp_res  INTO l_person_id;
        IF (C_emp_res%NOTFOUND) OR l_person_id IS NULL OR l_person_id =  FND_API.G_MISS_NUM  THEN
	    CLOSE C_emp_res;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_SALESREP');
                FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE ID', FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSIF l_person_id <> p_employee_person_id THEN
	    CLOSE C_emp_res;
              x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_SALESREP');
                FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE ID', FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
	END IF;
    END IF;

END  Validate_Emp_Res_id;

PROCEDURE Validate_Resource_group_id(
	p_init_msg_list		IN	VARCHAR2,
	p_resource_group_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_resource_group IS
 select 'VALID'
 from jtf_rs_groups_b
 where group_id = p_resource_group_id
 and trunc(sysdate) BETWEEN trunc(NVL(start_date_active, sysdate)) AND
				 trunc(NVL(end_date_active, sysdate));

 l_valid VARCHAR2(240);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_resource_group_id IS NOT NULL AND p_resource_group_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_resource_group;
	FETCH C_resource_group INTO l_valid;
        IF (C_resource_group%NOTFOUND) THEN
	    CLOSE C_resource_group;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE GROUP', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_resource_group_id),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_resource_group;
	END IF;
    END IF;

END Validate_Resource_group_id;

PROCEDURE Validate_Party_Object_Type(
	p_init_msg_list		IN	VARCHAR2,
	p_party_object_type     IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_party_object_type IS
 select 'VALID'
 from aso_lookups
 where lookup_type = 'ASO_PARTY_OBJECT_TYPE'
 and lookup_code = p_party_object_type;

 l_valid VARCHAR2(240);
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartyObjType: p_party_object_type: '||p_party_object_type, 1, 'N');
END IF;
    IF (p_party_object_type IS NOT NULL AND p_party_object_type <> FND_API.G_MISS_CHAR) THEN
        OPEN C_party_object_type;
	FETCH C_party_object_type INTO l_valid;
        IF (C_party_object_type%NOTFOUND) THEN
	    CLOSE C_party_object_type;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PARTY OBJECT TYPE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_party_object_type,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_party_object_type;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartyObjType: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_Party_Object_Type;

PROCEDURE Validate_Party_Object_Id(
	p_init_msg_list		IN	VARCHAR2,
        p_party_id              IN      NUMBER,
	p_party_object_type     IN	VARCHAR2,
        p_party_object_id       IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_contact_point IS
 select contact_point_type
 from aso_i_contact_points_v
 where contact_point_id = p_party_object_id;

l_type varchar(240);
BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartyObjId: p_party_object_type: '||p_party_object_type, 1, 'N');
  aso_debug_pub.add('Validate_PartyObjId: p_party_object_id: '||p_party_object_id, 1, 'N');
END IF;
   IF p_party_object_type IS NOT NULL  and p_party_object_type <> FND_API.G_MISS_CHAR THEN
       IF p_party_object_id is null OR p_party_object_id = FND_API.G_MISS_NUM THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
            FND_MESSAGE.Set_Token('COLUMN', 'PARTY OBJECT ID', FALSE);
            FND_MSG_PUB.ADD;
	END IF;
      END IF;

  /*  IF (p_party_object_type = 'PARTY_SITE') THEN

        Validate_PartySite(
	p_init_msg_list      => p_init_msg_list,
	p_party_id	     => p_party_id,
	p_party_site_id      => p_party_object_id,
	p_site_usage         => p_party_object_type,
	x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data	     => x_msg_data) ;
   */

    IF (p_party_object_type = 'CONTACT_POINT') THEN

        OPEN C_contact_point;
	FETCH C_contact_point INTO l_type;
        IF (C_contact_point%NOTFOUND) THEN
	    CLOSE C_contact_point;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'CONTACT POINT', FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_contact_point;
	END IF;


    END IF; -- party site.
   END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PartyObjId: x_return_status: '||x_return_status, 1, 'N');
END IF;
END;


-- this procedure is used to make sure that the same quote number is not
-- being used especially when the user calls create quote and passes the
-- quote number

PROCEDURE Validate_Quote_Number(
	p_init_msg_list		IN	VARCHAR2,
	p_quote_number  	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
CURSOR C_quote_number IS
 select quote_version
 from aso_quote_headers_all
 where quote_number = p_quote_number;

l_version varchar(240);
BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_quote_number is not NULL and p_quote_number <> FND_API.G_MISS_NUM THEN

        OPEN C_quote_number;
	FETCH C_quote_number INTO l_version;
        IF (C_quote_number%NOTFOUND) THEN
	    CLOSE C_quote_number;   -- unique quote number
        ELSE
	    CLOSE C_quote_number;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'QUOTE NUMBER', FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
	END IF;

     END IF;
END Validate_Quote_Number;

PROCEDURE Validate_Desc_Flexfield(
           p_desc_flex_rec       IN OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.attribute_rec_type,
           p_desc_flex_name      IN VARCHAR2 ,
           p_value_or_id         IN VARCHAR2 := 'I',
           x_return_status       OUT NOCOPY /* file.sql.39 change */    varchar2)
IS

l_flex_name     fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name     VARCHAR2(50);
l_flex_exists  VARCHAR2(1);
l_error_msg    VARCHAR2(240);

CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM fnd_descriptive_flexs
  WHERE application_id = ASO_QUOTE_PUB.OC_APPL_ID
    and descriptive_flexfield_name = p_desc_flex_name;


BEGIN

           x_return_status := FND_API.G_RET_STS_SUCCESS;


           OPEN desc_flex_exists;
      	   FETCH desc_flex_exists INTO l_flex_exists;
      		IF desc_flex_exists%NOTFOUND THEN
       		CLOSE desc_flex_exists;
       		x_return_status := FND_API.G_RET_STS_ERROR;
       		FND_MESSAGE.SET_NAME('ASO', 'ASO_FLEX_INVALID_NAME');
                FND_MESSAGE.SET_TOKEN('FLEX_NAME',p_desc_flex_name);
       		FND_MSG_PUB.ADD ;
       		return;
      		END IF;
      	   CLOSE desc_flex_exists;


   fnd_flex_descval.set_context_value(p_desc_flex_rec.attribute_category);
   fnd_flex_descval.set_column_value('ATTRIBUTE1', p_desc_flex_rec.attribute1);
   fnd_flex_descval.set_column_value('ATTRIBUTE2', p_desc_flex_rec.attribute2);
   fnd_flex_descval.set_column_value('ATTRIBUTE3', p_desc_flex_rec.attribute3);
   fnd_flex_descval.set_column_value('ATTRIBUTE4', p_desc_flex_rec.attribute4);
   fnd_flex_descval.set_column_value('ATTRIBUTE5', p_desc_flex_rec.attribute5);
   fnd_flex_descval.set_column_value('ATTRIBUTE6', p_desc_flex_rec.attribute6);
   fnd_flex_descval.set_column_value('ATTRIBUTE7', p_desc_flex_rec.attribute7);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', p_desc_flex_rec.attribute8);
   fnd_flex_descval.set_column_value('ATTRIBUTE9', p_desc_flex_rec.attribute9);
 fnd_flex_descval.set_column_value('ATTRIBUTE10', p_desc_flex_rec.attribute10);
 fnd_flex_descval.set_column_value('ATTRIBUTE11',p_desc_flex_rec.attribute11);
 fnd_flex_descval.set_column_value('ATTRIBUTE12', p_desc_flex_rec.attribute12);
 fnd_flex_descval.set_column_value('ATTRIBUTE13', p_desc_flex_rec.attribute13);
 fnd_flex_descval.set_column_value('ATTRIBUTE14', p_desc_flex_rec.attribute14);
 fnd_flex_descval.set_column_value('ATTRIBUTE15', p_desc_flex_rec.attribute15);

    IF ( NOT fnd_flex_descval.validate_desccols('ASO', p_desc_flex_name, p_value_or_id) )
     THEN

       FND_MESSAGE.SET_NAME('ASO', 'ASO_DESC_FLEX_INVALID');
       FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name);
       FND_MSG_PUB.ADD ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_error_msg := FND_FLEX_DESCVAL.error_message;
       FND_MESSAGE.SET_NAME('ASO', 'ASO_FLEX_INVALID_MSG');
       FND_MESSAGE.SET_TOKEN('MSG_TEXT',l_error_msg);
       FND_MSG_PUB.ADD ;
    END IF;

      l_count := fnd_flex_descval.segment_count;

      FOR i in 1..l_count LOOP
        l_col_name := fnd_flex_descval.segment_column_name(i);

        IF l_col_name = 'ATTRIBUTE1' THEN
          p_desc_flex_rec.attribute1 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE_CATEGORY'  THEN
       p_desc_flex_rec.attribute_category := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE2' THEN
          p_desc_flex_rec.attribute2 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE3' THEN
          p_desc_flex_rec.attribute3 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE4' THEN
          p_desc_flex_rec.attribute4 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE5' THEN
          p_desc_flex_rec.attribute5 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE6' THEN
          p_desc_flex_rec.attribute6 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE7' THEN
          p_desc_flex_rec.attribute7 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE8' THEN
          p_desc_flex_rec.attribute8 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE9' THEN
          p_desc_flex_rec.attribute9 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE10' THEN
          p_desc_flex_rec.attribute10 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE11' THEN
          p_desc_flex_rec.attribute11 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE12' THEN
          p_desc_flex_rec.attribute12 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE13' THEN
          p_desc_flex_rec.attribute13 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE14' THEN
          p_desc_flex_rec.attribute14 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'ATTRIBUTE15' THEN
          p_desc_flex_rec.attribute15 := fnd_flex_descval.segment_value(i);
        END IF;

        IF i > l_count  THEN
          EXIT;
        END IF;
       END LOOP;

EXCEPTION
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_Desc_Flexfield;


 -- TCA CHANGES
/*
If specified, should be a valid (i.e. active) cust account.
Should not be null if either the invoice_to_cust_account_id
or the ship_to_cust_account_id is specified
*/
PROCEDURE Validate_CustAccount_bsc(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		    IN	NUMBER,
	p_cust_account_id	IN	NUMBER,
    p_inv_cust_account_id	IN	NUMBER,
    p_end_cust_account_id	IN	NUMBER,
    p_shp_cust_account_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Account(l_account_id NUMBER)  IS
	SELECT status, account_activation_date, account_termination_date
    FROM HZ_CUST_ACCOUNTS
	WHERE  cust_account_id = l_account_id;

    l_api_name          VARCHAR2(40) := 'Validate_CustAccount_bsc' ;
    l_account_status	VARCHAR2(1);
    l_activation_date	DATE;
    l_termination_date		DATE;
BEGIN
   -- SAVEPOINT VALIDATE_CUSTACCOUNT_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_custAcctBsc: p_cust_account_id: '||p_cust_account_id, 1, 'N');
END IF;
    IF (p_cust_account_id IS NOT NULL AND p_cust_account_id <> FND_API.G_MISS_NUM) THEN
      	OPEN C_Account(p_cust_account_id);
    	FETCH C_Account INTO l_account_status, l_activation_date, l_termination_date;
        IF (C_Account%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_activation_date, sysdate) AND
            				 NVL(l_termination_date, sysdate))OR
		l_account_status <> 'A') THEN
	                x_return_status := FND_API.G_RET_STS_ERROR;
               		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	              	FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                  	FND_MESSAGE.Set_Token('COLUMN', 'CUST_ACCOUNT', FALSE);
				FND_MESSAGE.Set_Token('VALUE',to_char(p_cust_account_id),FALSE);
                  	FND_MSG_PUB.ADD;
	          	    END IF;

     	END IF;
        CLOSE C_Account;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('p_ship_cust_account_id = ' ||p_shp_cust_account_id,2,'N');
  aso_debug_pub.add('p_inv_cust_account = ' || p_inv_cust_account_id , 2, 'N');
  aso_debug_pub.add('p_end_cust_account = ' || p_end_cust_account_id , 2, 'N');
END IF;

    IF (p_inv_cust_account_id IS NOT NULL AND
        p_inv_cust_account_id <> FND_API.G_MISS_NUM) THEN

            OPEN C_Account(p_inv_cust_account_id);
            FETCH C_Account INTO l_account_status, l_activation_date, l_termination_date;
        	IF (C_Account%NOTFOUND OR
        	    (sysdate NOT BETWEEN NVL(l_activation_date, sysdate) AND
	 			NVL(l_termination_date, sysdate))OR
 	            l_account_status <> 'A') THEN

	         	x_return_status := FND_API.G_RET_STS_ERROR;
               		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	              	FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                  	FND_MESSAGE.Set_Token('COLUMN', 'INVOICE_CUST_ACCOUNT', FALSE);
				FND_MESSAGE.Set_Token('VALUE',to_char(p_inv_cust_account_id),FALSE);
                  	FND_MSG_PUB.ADD;
	       		    END IF;

     		END IF;
	       CLOSE C_Account;
    END IF;

    IF (p_end_cust_account_id IS NOT NULL AND
        p_end_cust_account_id <> FND_API.G_MISS_NUM) THEN

            OPEN C_Account(p_end_cust_account_id);
            FETCH C_Account INTO l_account_status, l_activation_date, l_termination_date;
          IF (C_Account%NOTFOUND OR
              (sysdate NOT BETWEEN NVL(l_activation_date, sysdate) AND
                    NVL(l_termination_date, sysdate))OR
                 l_account_status <> 'A') THEN

               x_return_status := FND_API.G_RET_STS_ERROR;
                         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'END_CUST_ACCOUNT', FALSE);
                    FND_MESSAGE.Set_Token('VALUE',to_char(p_end_cust_account_id),FALSE);
                    FND_MSG_PUB.ADD;
                        END IF;

               END IF;
            CLOSE C_Account;
    END IF;

    IF (p_shp_cust_account_id IS NOT NULL AND
        p_shp_cust_account_id <> FND_API.G_MISS_NUM) THEN

        OPEN C_Account(p_shp_cust_account_id);
	    FETCH C_Account INTO l_account_status, l_activation_date, l_termination_date;
       	IF (C_Account%NOTFOUND OR
           (sysdate NOT BETWEEN NVL(l_activation_date, sysdate) AND
           NVL(l_termination_date, sysdate))OR
           l_account_status <> 'A') THEN

	         	x_return_status := FND_API.G_RET_STS_ERROR;
           		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	              	FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                  	FND_MESSAGE.Set_Token('COLUMN', 'SHIP_CUST_ACCOUNT', FALSE);
				FND_MESSAGE.Set_Token('VALUE',to_char(p_shp_cust_account_id),FALSE);
                  	FND_MSG_PUB.ADD;
	       		END IF;

     		END IF;
	 CLOSE C_Account;
    END IF;
	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	     aso_debug_pub.add('after validate cust ' || x_return_status , 2, 'N');
	   END IF;

END Validate_CustAccount_bsc;

/* If specified, should be a valid org_contact_id, where
party in the subject of the  relationship is of type person*/
PROCEDURE Validate_org_contact_bsc(
	p_init_msg_list		IN	VARCHAR2,
	p_contact_id		IN	NUMBER,
	p_cust_account_id   IN  NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    x_msg_count	        OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data	        OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

   CURSOR C_Contact(l_contact_id NUMBER) IS
	SELECT subject_id, a.status
    FROM HZ_ORG_CONTACTS a, HZ_RELATIONSHIPS b
	WHERE org_contact_id = l_contact_id
    AND a.party_relationship_id = b.relationship_id
    AND b.subject_type = 'PERSON';


   CURSOR C_Party_Cust(l_party_id NUMBER) IS
    SELECT status, party_type
    FROM HZ_PARTIES
    WHERE party_id= l_party_id;

    l_party_relationship_id NUMBER;
    l_subject_id NUMBER;
    l_status VARCHAR2(1);
    l_party_type VARCHAR2(30);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrgContBsc: p_contact_id: '||p_contact_id, 1, 'N');
  aso_debug_pub.add('Validate_OrgContBsc: p_cust_account_id: '||p_cust_account_id, 1, 'N');
END IF;
    IF (p_contact_id IS NOT NULL AND p_contact_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Contact(p_contact_id);
	    FETCH C_Contact INTO l_subject_id, l_status;
        IF (C_Contact%NOTFOUND OR l_status <>'A') THEN

	        x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'org_contact_id', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_contact_id),FALSE);
                FND_MSG_PUB.ADD;
            END IF;
        ELSE
            OPEN  C_Party_Cust(l_subject_id);
            FETCH  C_Party_Cust INTO l_status ,l_party_type;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrgContBsc: l_subject_id: '||l_subject_id, 1, 'N');
  aso_debug_pub.add('Validate_OrgContBsc: l_party_type: '||l_party_type, 1, 'N');
END IF;
            IF ( C_Party_Cust%NOTFOUND OR l_status <> 'A' OR l_party_type <> 'PERSON' ) THEN
                CLOSE  C_Party_Cust;
	            x_return_status := FND_API.G_RET_STS_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'org_contact_id', FALSE);
				FND_MESSAGE.Set_Token('VALUE',to_char(p_contact_id),FALSE);
                    FND_MSG_PUB.ADD;
	            END IF;
            END IF;
            CLOSE C_Party_Cust;
       END IF;
       CLOSE C_Contact;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrgContBsc: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_Org_Contact_bsc;

/* Should not be null, Should be a valid party_id of type person,
organization or relationship.*/
PROCEDURE Validate_Party_bsc(
	p_init_msg_list	IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	x_return_status OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Party(l_pty_id NUMBER) IS
	SELECT status FROM HZ_PARTIES
	WHERE party_id = l_pty_id and party_type in
    ('PERSON','PARTY_RELATIONSHIP','ORGANIZATION');

    l_party_status	VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyBsc: p_party_id: '||p_party_id, 1, 'N');
END IF;
    IF (p_party_id IS NOT NULL AND p_party_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Party(p_party_id);
	    FETCH C_Party INTO l_party_status;
        IF (C_Party%NOTFOUND OR l_party_status <> 'A') THEN
	        CLOSE C_Party;
	        x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'party_Id', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_party_id),FALSE);
                FND_MSG_PUB.ADD;
	         END IF;
        ELSE
	      CLOSE C_Party;
	    END IF;
   END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyBsc: x_return_status: '||x_return_status, 1, 'N');
END IF;
    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_Party_bsc;

PROCEDURE Validate_Inv_Party_bsc(
	p_init_msg_list	IN	VARCHAR2,
	p_party_id		IN	NUMBER ,
    p_site_use  	IN	VARCHAR2,
	x_return_status OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Party(l_pty_id NUMBER) IS
	SELECT status FROM HZ_PARTIES
	WHERE party_id = l_pty_id AND party_type ='PARTY_RELATIONSHIP';

    l_party_status	VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_InvPtyBsc: p_party_id: '||p_party_id, 1, 'N');
  aso_debug_pub.add('Validate_InvPtyBsc: p_site_use: '||p_site_use, 1, 'N');
END IF;
    IF (p_party_id IS NOT NULL AND p_party_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Party(p_party_id);
	    FETCH C_Party INTO l_party_status;
        IF (C_Party%NOTFOUND OR l_party_status <> 'A') THEN
	        CLOSE C_Party;
	        x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                IF p_site_use ='BILL_TO' THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'Invoice_to_party_Id', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_party_id),FALSE);
                FND_MSG_PUB.ADD;
                ELSIF p_site_use ='END_USER' THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'End_Customer_party_Id', FALSE);
                FND_MESSAGE.Set_Token('VALUE',to_char(p_party_id),FALSE);
                FND_MSG_PUB.ADD;
                ELSIF p_site_use ='SHIP_TO' THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'Ship_to_party_Id', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_party_id),FALSE);
                FND_MSG_PUB.ADD;
                END IF;
	         END IF;
        ELSE
	      CLOSE C_Party;
	    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_InvPtyBsc: x_return_status: '||x_return_status, 1, 'N');
END IF;
   END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

END Validate_Inv_Party_bsc;


/*Should not be null if either -invoice_to_party_id is specified,
should be a valid party_site_id with party_site_use of 'Bill_To'*/

PROCEDURE Validate_Inv_PartySite_bsc(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_party_site_id		IN	NUMBER,
     p_party_site_use     IN VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
     x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
     x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

    CURSOR C_Inv_Party_Site(l_pty_site NUMBER) IS
	SELECT a.status
	FROM HZ_PARTY_SITES a
	WHERE  a.party_site_id = l_pty_site;

    l_status        VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_InvPtySiteBsc: p_party_id: '||p_party_id, 1, 'N');
  aso_debug_pub.add('Validate_InvPtySiteBsc: p_party_site_id: '||p_party_site_id, 1, 'N');
  aso_debug_pub.add('Validate_InvPtySiteBsc: p_party_site_use: '||p_party_site_use, 1, 'N');
END IF;
    IF (p_party_id IS NOT NULL AND p_party_id <> FND_API.G_MISS_NUM) THEN
       IF (p_party_site_id IS NULL OR p_party_site_id = FND_API.G_MISS_NUM) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
		  IF p_party_site_use = 'BILL_TO' THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	           FND_MESSAGE.Set_Name('ASO', 'ASO_BILL_ADDRESS_REQD');
                FND_MSG_PUB.ADD;
	         END IF;
            ELSIF p_party_site_use = 'END_USER' THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_END_ADDRESS_REQD');
                FND_MSG_PUB.ADD;
              END IF;
            ELSIF p_party_site_use = 'SHIP_TO' THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	           FND_MESSAGE.Set_Name('ASO', 'ASO_SHIP_ADDRESS_REQD');
                FND_MSG_PUB.ADD;
	         END IF;
            END IF;
        END IF;
    ELSE
     IF (p_party_site_id IS NOT NULL AND p_party_site_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Inv_Party_Site(p_party_site_id);
	    FETCH C_Inv_Party_Site INTO l_status;
        IF (C_Inv_Party_Site%NOTFOUND OR
		    l_status <> 'A') THEN
	   	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'party_site_id', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_party_site_id),FALSE);
                FND_MSG_PUB.ADD;
	        END IF;
     	END IF;
     CLOSE C_Inv_Party_Site;
    END IF;
END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_InvPtySiteBsc: x_return_status: '||x_return_status, 1, 'N');
END IF;
END Validate_Inv_PartySite_bsc;

PROCEDURE Validate_Party_Crs(
	p_init_msg_list	  IN VARCHAR2,
	p_party_id		  IN NUMBER,
	p_cust_party_id   IN NUMBER,
	p_cust_account_id IN NUMBER,
	x_return_status   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count       OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data        OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

    CURSOR C_Account IS
	SELECT a.status FROM HZ_CUST_ACCOUNTS a
	WHERE a.party_id = p_cust_party_id AND cust_account_id = p_cust_account_id;

    CURSOR C_Account_Role IS
	SELECT begin_date, end_date FROM HZ_CUST_ACCOUNT_ROLES
	WHERE party_id = p_party_id AND cust_account_id = p_cust_account_id
    AND role_type ='ACCOUNT_USER';

    CURSOR C_party(l_pty_id NUMBER) IS
    SELECT party_type FROM HZ_PARTIES
    WHERE party_id= l_pty_id;

	CURSOR C_relation IS
	SELECT 'x' FROM
	HZ_RELATIONSHIPS a, HZ_ORG_CONTACTS b
	WHERE a.relationship_id = b.party_relationship_id
	AND a.object_id = p_cust_party_id;

    CURSOR C_org_reltn IS
	SELECT 'x' FROM
	HZ_RELATIONSHIPS a, HZ_ORG_CONTACTS b,
	HZ_CUST_ACCOUNTS c
	WHERE  a.relationship_id= b.party_relationship_id
	AND c.cust_Account_id = p_cust_account_id
	AND a.object_id = c.party_id;

    CURSOR C_Person_Reltn (l_party NUMBER) IS
    SELECT 'X'
    FROM HZ_RELATIONSHIPS
    WHERE party_id = l_party
    AND subject_type = 'PERSON'
    AND object_type = 'PERSON';

    l_api_name          VARCHAR2(40) := 'Validate_Party_Crs' ;
    l_account_status	VARCHAR2(1);
    l_start_date	DATE;
    l_end_date		DATE;
    l_party_type        VARCHAR2(30);
    l_test VARCHAR2(1);
    l_dummy VARCHAR2(1);

BEGIN
    --SAVEPOINT Validate_Party_CustAccount;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyCrs: p_party_id: '||p_party_id, 1, 'N');
  aso_debug_pub.add('Validate_PtyCrs: p_cust_party_id: '||p_cust_party_id, 1, 'N');
  aso_debug_pub.add('Validate_PtyCrs: p_cust_account_id: '||p_cust_account_id, 1, 'N');
END IF;

    IF (p_cust_account_id IS NOT NULL AND p_cust_account_id <> FND_API.G_MISS_NUM) THEN
      IF (p_cust_party_id IS NOT NULL AND p_cust_party_id <> FND_API.G_MISS_NUM) THEN
	     OPEN C_Account;
		 FETCH C_Account INTO l_account_status;
         IF (C_Account%NOTFOUND OR l_account_status <> 'A') THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
	         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_PARTY_CRS');
             FND_MSG_PUB.ADD;
	       END IF;
		  END IF;
          CLOSE C_Account;
       END IF;
	END IF;

    IF p_party_id IS NOT NULL AND p_party_id <> FND_API.G_MISS_NUM THEN
	  OPEN C_party(p_party_id);
      FETCH C_party into l_party_type;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyCrs: l_party_type: '||l_party_type, 1, 'N');
END IF;
      IF l_party_type <> 'PARTY_RELATIONSHIP' THEN
        IF (p_cust_party_id IS NOT NULL AND p_cust_party_id <> FND_API.G_MISS_NUM) THEN
		  IF p_party_id <> p_cust_party_id THEN
		     x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	           FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_PARTY_CRS');
               FND_MSG_PUB.ADD;
	         END IF;
		   END IF;
		 END IF;
	   ELSE  -- relationship

         OPEN C_Person_Reltn (p_party_id);
         FETCH C_Person_Reltn INTO l_dummy;
         IF l_dummy = 'X' THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyCrs: Person_Reltn: '||l_dummy, 1, 'N');
END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_RELATIONSHIP');
                 FND_MSG_PUB.ADD;
             END IF;
         END IF;
         CLOSE C_Person_Reltn;

	     IF (p_cust_party_id IS NOT NULL AND p_cust_party_id <> FND_API.G_MISS_NUM) THEN
	        OPEN C_relation;
			FETCH C_relation into l_test;
			IF (C_relation%NOTFOUND OR l_test IS NULL) THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyCrs: Cust_Party Relation not found: '||l_test, 1, 'N');
END IF;
			  x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_PARTY_CRS');
                FND_MSG_PUB.ADD;
	          END IF;
			 END IF;
		  END IF;

		  IF (p_cust_account_id IS NOT NULL AND
              p_cust_account_id <>  FND_API.G_MISS_NUM) THEN
            OPEN C_org_reltn;
            FETCH C_org_reltn into l_test;
            IF (C_org_reltn%NOTFOUND OR l_test IS NULL ) THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyCrs: Org Relation not found: '||l_test, 1, 'N');
END IF;
		      x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_PARTY_CRS');
                FND_MSG_PUB.ADD;
	          END IF;
            END IF;
            CLOSE C_org_reltn;
           END IF;
	     END IF;--l_party_type
         CLOSE C_party;
      END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_PtyCrs: x_return_status: '||x_return_status, 1, 'N');
END IF;
 END Validate_Party_Crs;


 PROCEDURE Validate_Inv_Party_Crs(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_cust_party_id  IN NUMBER,
	p_inv_party_id		IN	NUMBER,
	p_cust_account_id	IN	NUMBER,
	p_inv_cust_account_id	IN	NUMBER,
	p_inv_cust_party_id IN NUMBER,
    p_site_use          IN VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_val_inv_id(lc_party_id number) IS
	SELECT 'x' FROM
	HZ_RELATIONSHIPS a, hz_org_contacts b
	WHERE
    a.party_id = p_inv_party_id
	AND a.object_id = lc_party_id
	AND b.party_relationship_id = a.relationship_id
	AND exists (select 'y' from HZ_PARTIES d
	where d.party_type ='PERSON' and
	d.party_id= a.subject_id);


	CURSOR C_Cust_party_id(l_cust_acct_id number) IS
	select party_id from
	hz_cust_accounts
	where
	cust_account_id = l_cust_acct_id;
	CURSOR C_party_type IS
	select party_type
	from hz_parties
	where party_id = p_party_id;

	CURSOR C_relation_object IS
	select object_id
	from
	hz_relationships
	where party_id = p_party_id
	and subject_type ='PERSON'
	and subject_table_name = 'HZ_PARTIES'
	and object_type = 'ORGANIZATION'
	and object_table_name = 'HZ_PARTIES';

    CURSOR C_Person_Reltn (l_party NUMBER) IS
    SELECT 'X'
    FROM HZ_RELATIONSHIPS
    WHERE party_id = l_party
    AND subject_type = 'PERSON'
    AND object_type = 'PERSON';

    l_party_id          NUMBER;
    l_api_name          VARCHAR2(40) := 'Validate_Inv_Party_Crs' ;
    l_exist             VARCHAR2(1);
	l_party_type        VARCHAR2(40);
    l_dummy             VARCHAR2(1);

BEGIN
    --SAVEPOINT Validate_Party_CustAccount;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('in validate_inv_party_crs',1,'N');
    aso_debug_pub.add('Validate_InvPtyCrs: p_inv_party_id = '|| p_inv_party_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtyCrs: p_inv_cust_party_id = '|| p_inv_cust_party_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtyCrs: p_inv_cust_account_id = '|| p_inv_cust_account_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtyCrs: p_cust_party_id = '|| p_cust_party_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtyCrs: p_cust_account_id = '|| p_cust_account_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtyCrs: p_party_id = '|| p_party_id ,1,'N');
  END IF;
  IF (p_inv_party_id IS NOT NULL AND p_inv_party_id <> FND_API.G_MISS_NUM) THEN
    IF (p_inv_cust_party_id IS NOT NULL AND
	    p_inv_cust_party_id <> FND_API.G_MISS_NUM) THEN
	   l_party_id := p_inv_cust_party_id;
	ELSE
	  IF (p_inv_cust_account_id IS NOT NULL AND
	      p_inv_cust_account_id <> FND_API.G_MISS_NUM) THEN
		 OPEN C_cust_party_id(p_inv_cust_account_id);
		 FETCH C_cust_party_id INTO l_party_id;
		 CLOSE C_cust_party_id;
		 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		   aso_debug_pub.add('Validate_InvPtyCrs: 1: l_party_id = '|| l_party_id ,1,'N');
		 END IF;
	  ELSE
	    IF (p_cust_party_id IS NOT NULL AND
		    p_cust_party_id <> FND_API.G_MISS_NUM) THEN
		   l_party_id := p_cust_party_id;
		ELSE
		  IF (p_cust_account_id IS NOT NULL AND
		      p_cust_account_id <> FND_API.G_MISS_NUM) THEN
			 OPEN C_cust_party_id(p_cust_account_id);
		     FETCH C_cust_party_id INTO l_party_id;
		     CLOSE C_cust_party_id;
			 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			   aso_debug_pub.add('Validate_InvPtyCrs: 2: l_party_id = '|| l_party_id ,1,'N');
			 END IF;
		  ELSE
		    IF (p_party_id IS NOT NULL AND
			    p_party_id <> FND_API.G_MISS_NUM) THEN
			   OPEN C_party_type;
			   FETCH C_party_type into l_party_type;
			   CLOSE C_party_type;
			   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			     aso_debug_pub.add('Validate_InvPtyCrs: p_party_id: party_type = ' ||l_party_type,1,'N');
			   END IF;
			   IF l_party_type = 'PARTY_RELATIONSHIP' THEN
                  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('Validate_InvPtyCrs: in reltn'||p_inv_party_id,1);
                  END IF;
                 OPEN C_Person_Reltn (p_inv_party_id);
                 FETCH C_Person_Reltn INTO l_dummy;
                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('Validate_InvPtyCrs: in dummy'||l_dummy,1);
                 END IF;
                 IF l_dummy = 'X' THEN
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_RELATIONSHIP');
                         FND_MSG_PUB.ADD;
                     END IF;
                 END IF;
                 CLOSE C_Person_Reltn;

			     OPEN C_relation_object;
				 FETCH C_relation_object into l_party_id;
				 CLOSE C_relation_object;
				 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				   aso_debug_pub.add('Validate_InvPtyCrs: 3: l_party_id = '|| l_party_id ,1,'N');
				 END IF;
			   ELSE
			     l_party_id := p_party_id;
			   END IF;
			 END IF;
		   END IF;
		 END IF;
	   END IF;
	 END IF;

	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('Validate_InvPtyCrs: 4: l_party_id = '|| l_party_id ,1,'N');
	 END IF;
	 IF l_party_id IS NOT NULL AND l_party_id <> FND_API.G_MISS_NUM THEN
	   IF l_party_id <> p_inv_party_id THEN
	     OPEN C_val_inv_id(l_party_id);
	     FETCH C_val_inv_id INTO l_exist;
		 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		   aso_debug_pub.add('Validate_InvPtyCrs: l_exist = ' ||l_exist,1, 'N');
		 END IF;
	     IF C_val_inv_id%NOTFOUND or l_exist IS  NULL THEN
	       x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)THEN
             IF p_site_use = 'BILL_TO' THEN
	           FND_MESSAGE.Set_Name('ASO','ASO_VALIDATE_INV_PARTY_PT_CRS');
             ELSIF p_site_use = 'END_USER' THEN
               FND_MESSAGE.Set_Name('ASO','ASO_VALIDATE_END_PARTY_PT_CRS');
             ELSIF p_site_use = 'SHIP_TO' THEN
               FND_MESSAGE.Set_Name('ASO','ASO_VALIDATE_SHP_PARTY_PT_CRS');
             END IF;
             FND_MSG_PUB.ADD;
	       END IF;
		 END IF;
	     CLOSE C_val_inv_id;
	   END IF ;
	 END IF;

    END IF;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('Validate_InvPtyCrs: x_return_status = ' || x_return_status,1,'N');
	  aso_debug_pub.add('Validate_Inv_Party_Crs: End',1,'N');
	END IF;
 END Validate_Inv_Party_Crs;




PROCEDURE Validate_inv_PartySite_crs(
     p_init_msg_list          IN   VARCHAR2,
     p_party_id               IN   NUMBER,
     p_cust_party_id  IN NUMBER,
	 p_inv_party_id		IN	NUMBER,
	 p_cust_account_id	IN	NUMBER,
	 p_inv_cust_account_id	IN	NUMBER,
	 p_inv_cust_party_id IN NUMBER,
     p_party_site_id          IN   NUMBER,
     p_site_usage             IN   VARCHAR2,
     x_return_status          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count              OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data               OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS

   CURSOR c_party_site( l_party_site_id NUMBER) IS
     SELECT b.party_id,a.party_type FROM HZ_PARTIES a,HZ_PARTY_SITES b
     WHERE a.party_id = b.party_id
     AND b.party_site_id = l_party_site_id;

   CURSOR C_Cust_party_id(l_cust_acct_id number) IS
	select party_id from
	hz_cust_accounts
	where
	cust_account_id = l_cust_acct_id;
	CURSOR C_party_type IS
	select party_type
	from hz_parties
	where party_id = p_party_id;

	CURSOR C_relation_object(px_party_id number) IS
	select object_id
	from
	hz_relationships
	where party_id = px_party_id
	and subject_type ='PERSON'
	and subject_table_name = 'HZ_PARTIES'
	and object_type = 'ORGANIZATION'
	and object_table_name = 'HZ_PARTIES';


    l_party_type     VARCHAR2(30);
    l_party_id NUMBER;
	lp_party_id NUMBER;
	lp_party_type VARCHAR2(30);
    l_status        VARCHAR2(1);
	l_party_site_object_id number;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('in validate_inv_party_site_crs',1,'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: validate inv party site- p_party_site_id '||p_party_site_id, 1, 'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: p_inv_party_id = '|| p_inv_party_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: p_inv_cust_party_id = '|| p_inv_cust_party_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: p_inv_cust_account_id = '|| p_inv_cust_account_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: p_cust_party_id = '|| p_cust_party_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: p_cust_account_id = '|| p_cust_account_id ,1,'N');
    aso_debug_pub.add('Validate_InvPtySiteCrs: p_party_id = '|| p_party_id ,1,'N');
  END IF;

  IF (p_party_site_id IS  NOT NULL AND  p_party_site_id <> FND_API.G_MISS_NUM) THEN
    IF (p_inv_cust_party_id IS NOT NULL AND
	    p_inv_cust_party_id <> FND_API.G_MISS_NUM) THEN
	   l_party_id := p_inv_cust_party_id;
	ELSE
	  IF (p_inv_cust_account_id IS NOT NULL AND
	      p_inv_cust_account_id <> FND_API.G_MISS_NUM) THEN
		 OPEN C_cust_party_id(p_inv_cust_account_id);
		 FETCH C_cust_party_id INTO l_party_id;
		 CLOSE C_cust_party_id;
		 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		   aso_debug_pub.add('Validate_InvPtySiteCrs: 1: l_party_id = '|| l_party_id ,1,'N');
		 END IF;
	  ELSE
	    IF (p_cust_party_id IS NOT NULL AND
		    p_cust_party_id <> FND_API.G_MISS_NUM) THEN
		   l_party_id := p_cust_party_id;
		ELSE
		  IF (p_cust_account_id IS NOT NULL AND
		      p_cust_account_id <> FND_API.G_MISS_NUM) THEN
			 OPEN C_cust_party_id(p_cust_account_id);
		     FETCH C_cust_party_id INTO l_party_id;
		     CLOSE C_cust_party_id;
			 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			   aso_debug_pub.add('Validate_InvPtySiteCrs: 2: l_party_id = '|| l_party_id ,1,'N');
			 END IF;
		  ELSE
		    IF (p_party_id IS NOT NULL AND
			    p_party_id <> FND_API.G_MISS_NUM) THEN
			   OPEN C_party_type;
			   FETCH C_party_type into l_party_type;
			   CLOSE C_party_type;
			   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			     aso_debug_pub.add('Validate_InvPtySiteCrs: p_party_id: party_type = ' ||l_party_type,1,'N');
			   END IF;
			   IF l_party_type = 'PARTY_RELATIONSHIP' THEN
			     OPEN C_relation_object(p_party_id);
				 FETCH C_relation_object into l_party_id;
				 CLOSE C_relation_object;
				 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				   aso_debug_pub.add('Validate_InvPtySiteCrs: 3: l_party_id = '|| l_party_id ,1,'N');
				 END IF;
			   ELSE
			     l_party_id := p_party_id;
			   END IF;
			END IF;
		  END IF;
		END IF;
	  END IF;
	END IF;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('Validate_InvPtySiteCrs: 4: l_party_id = '|| l_party_id ,1,'N');
	END IF;
    OPEN c_party_site(p_party_site_id);
    FETCH c_party_site into lp_party_id,lp_party_type;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('Validate_InvPtySiteCrs: lp_party_id = ' ||lp_party_id, 1,'N');
	  aso_debug_pub.add('Validate_InvPtySiteCrs: lp_party_type = ' || lp_party_type, 1 , 'N');
	END IF;
    IF c_party_site%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF lp_party_type = 'PARTY_RELATIONSHIP' THEN
      IF (p_inv_party_id IS NOT NULL AND p_inv_party_id <> FND_API.G_MISS_NUM) THEN
		IF p_inv_party_id <> lp_party_id THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
	  ELSE
		OPEN C_relation_object(lp_party_id);
		FETCH C_relation_object into l_party_site_object_id;
		CLOSE C_relation_object;
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('Validate_InvPtySiteCrs: l_party_site_object_id = ' || l_party_site_object_id,1,'N');
		END IF;
		IF l_party_site_object_id <> l_party_id THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
      END IF;
    ELSE
	    IF lp_party_id <> l_party_id THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END IF;
	CLOSE C_party_site;
  END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_InvPtySiteCrs: x_return_status = ' || x_return_status,1,'N');
END IF;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)THEN
      IF p_site_usage = 'BILL_TO' THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
      ELSIF p_site_usage = 'END_USER' THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_END_SITE_AC_CRS');
      ELSIF p_site_usage = 'SHIP_TO' THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_SHP_SITE_AC_CRS');
      ELSIF p_site_usage = 'SOLD_TO' THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_SLD_SITE_AC_CRS'); -- Sold_to
      END IF;
      FND_MSG_PUB.ADD;
    END IF;
  END IF;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('Validate_inv_partysite_crs: end',1,'N');
  END IF;

END Validate_inv_PartySite_crs;



PROCEDURE Validate_org_contact_crs(
	p_init_msg_list		IN	VARCHAR2,
	p_contact_id		IN	NUMBER,
	p_cust_account_id       IN      NUMBER,
        p_party_id              IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    CURSOR C_Contact IS
	SELECT object_id ,a.status FROM HZ_ORG_CONTACTS a,
        HZ_RELATIONSHIPS b
	WHERE org_contact_id = p_contact_id
        and a.party_relationship_id = b.relationship_id
	and b.object_type = 'ORGANIZATION';
   CURSOR C_Party(l_party_id NUMBER) IS
       SELECT status from HZ_PARTIES a
       WHERE a.party_id=l_party_id and a.party_id=p_party_id
	AND Party_type in('ORGANIZATION','PARTY_RELATIONSHIP');


 CURSOR C_Cust_account(l_party_id NUMBER) IS
       SELECT status from HZ_CUST_ACCOUNTS
       WHERE party_id=l_party_id and
       cust_account_id =  p_cust_account_id;
    l_party_relationship_id NUMBER;
    l_object_id NUMBER;
    l_status VARCHAR2(1);
    l_acct_status VARCHAR2(1);
    l_party_status VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrgConCrs: p_contact_id = ' || p_contact_id,1,'N');
  aso_debug_pub.add('Validate_OrgConCrs: p_cust_account_id = ' || p_cust_account_id,1,'N');
  aso_debug_pub.add('Validate_OrgConCrs: p_party_id = ' || p_party_id,1,'N');
END IF;
    IF (p_contact_id IS NOT NULL AND p_contact_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Contact;
	    FETCH C_Contact INTO l_object_id,l_status ;
        IF (C_Contact%NOTFOUND OR l_status <> 'A') THEN
	             x_return_status := FND_API.G_RET_STS_ERROR;
            	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       	       FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
               	   FND_MESSAGE.Set_Token('COLUMN', 'Org_contact_id', FALSE);
				   FND_MESSAGE.Set_Token('VALUE',to_char(p_contact_id),FALSE);
               	   FND_MSG_PUB.ADD;
	              END IF;
	   END IF;
       CLOSE C_Contact;
    END IF;
   IF (p_cust_account_id IS NOT NULL AND p_cust_account_id <> FND_API.G_MISS_NUM)
        AND (p_contact_id IS NOT NULL AND p_contact_id <> FND_API.G_MISS_NUM) THEN
    	OPEN C_Contact ;
    	FETCH C_Contact INTO l_object_id,l_status ;
    	IF C_Contact%FOUND and l_object_id is NOT NULL THEN
       		OPEN C_Cust_account(l_object_id);
       		FETCH C_Cust_account INTO l_acct_status ;
      		IF C_Cust_account%NOTFOUND or l_acct_status <>'A' THEN
                       x_return_status := FND_API.G_RET_STS_ERROR;
            		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       	 		FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_ORG_CON_ACT_CRS');
                   -- FND_MESSAGE.Set_Name('ASO', 'INVALID_OBJECT_PARTY_ID');

		               	FND_MSG_PUB.ADD;
	        	      END IF;
      		END IF;
       		CLOSE C_Cust_account;
   	    END IF;
    	CLOSE C_Contact;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrgConCrs: x_return_status = ' || x_return_status,1,'N');
END IF;
  ELSE
  	IF (p_party_id IS NOT NULL AND p_party_id <> FND_API.G_MISS_NUM)
    AND (p_contact_id IS NOT NULL AND p_contact_id <> FND_API.G_MISS_NUM)  THEN
      	    OPEN C_Contact;
	        FETCH C_Contact INTO l_object_id,l_status ;
        	IF (C_Contact%NOTFOUND OR l_status <> 'A') THEN

	       	 x_return_status := FND_API.G_RET_STS_ERROR;
            		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                      	FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_ORG_CON_PTY_CRS');

               		 FND_MSG_PUB.ADD;
	        	      END IF;
            CLOSE C_Contact;
		    ELSE
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_InvPtySiteCrs: l_object_id = ' || l_object_id,1,'N');
END IF;
			        OPEN c_party(l_object_id);
                	FETCH c_party into l_party_status;
                	IF c_party%NOTFOUND or l_party_status <> 'A' THEN
                  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
THEN
	       	 		    FND_MESSAGE.Set_Name('ASO',
'ASO_VALIDATE_ORG_CON_PTY_CRS');
               	 		--FND_MESSAGE.Set_Token('COLUMN', 'Org_contact_id', FALSE);
               	 		FND_MSG_PUB.ADD;
	        		     END IF;
                	END IF;
			        CLOSE c_party;
                     CLOSE  C_Contact;
 		     END IF;

	END IF;
 END IF;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_OrgConCrs: x_return_status = ' || x_return_status,1,'N');
END IF;
END Validate_Org_Contact_crs;

PROCEDURE Validate_item_tca_bsc(
	p_init_msg_list		IN	VARCHAR2,
	p_qte_header_rec        IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type :=
ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
	p_shipment_rec        	IN	ASO_QUOTE_PUB.shipment_rec_type  :=
ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
     p_operation_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
     p_application_type_code  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    	l_api_name                CONSTANT VARCHAR2(30) := 'Validate_item_tca_bsc';
     l_party_id          NUMBER;

	l_qte_header_rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
	lp_qte_header_rec       ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
     l_shipment_rec          ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;
     lp_shipment_rec         ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;

    CURSOR C_Get_Party_From_Org(l_org_contact_id NUMBER) IS
      SELECT par.party_id
      FROM hz_relationships par,
           hz_org_contacts org
      WHERE org.party_relationship_id = par.relationship_id
      AND org.org_contact_id  = l_org_contact_id
--      AND org.status = 'A'  status column obseleted
      and par.status = 'A'
      and (sysdate between nvl(par.start_date, sysdate) and nvl(par.end_date, sysdate));

BEGIN
   SAVEPOINT VALIDATE_ITEM_TCA_BSC_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/** Changes for OA uptake **/
    lp_qte_header_rec := p_qte_header_rec;
    lp_shipment_rec := p_shipment_rec;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: lp_qte_header_rec.quote_header_id: ' || lp_qte_header_rec.quote_header_id,1,'N');
        aso_debug_pub.add('Validate_ItemTcaBsc: lp_shipment_rec.shipment_id: ' || lp_shipment_rec.shipment_id,1,'N');
     END IF;

    IF (p_application_type_code = 'QUOTING HTML' AND p_operation_code = 'UPDATE') THEN
      l_qte_header_rec := ASO_UTILITY_PVT.query_header_row (lp_qte_header_rec.quote_header_id);

      IF lp_qte_header_rec.party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.party_id := l_qte_header_rec.party_id;
      END IF;
      IF lp_qte_header_rec.cust_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.cust_party_id := l_qte_header_rec.cust_party_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_cust_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_cust_party_id := l_qte_header_rec.invoice_to_cust_party_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_cust_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_cust_party_id := l_qte_header_rec.End_Customer_cust_party_id;
      END IF;
      IF lp_qte_header_rec.cust_account_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.cust_account_id := l_qte_header_rec.cust_account_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_cust_account_id := l_qte_header_rec.invoice_to_cust_account_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_cust_account_id := l_qte_header_rec.End_Customer_cust_account_id;
      END IF;
      IF lp_qte_header_rec.org_contact_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.org_contact_id := l_qte_header_rec.org_contact_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_party_id := l_qte_header_rec.invoice_to_party_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_party_id := l_qte_header_rec.End_Customer_party_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_party_site_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_party_site_id := l_qte_header_rec.invoice_to_party_site_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_party_site_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_party_site_id := l_qte_header_rec.End_Customer_party_site_id;
      END IF;
      IF lp_qte_header_rec.sold_to_party_site_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.sold_to_party_site_id := l_qte_header_rec.sold_to_party_site_id;
      END IF;

      IF lp_shipment_rec.operation_code = 'UPDATE' THEN
       IF lp_shipment_rec.shipment_id IS NOT NULL AND lp_shipment_rec.shipment_id <> FND_API.G_MISS_NUM THEN
        l_shipment_rec := ASO_UTILITY_PVT.query_shipment_row (lp_shipment_rec.shipment_id);
        IF lp_shipment_rec.ship_to_cust_party_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_cust_party_id := l_shipment_rec.ship_to_cust_party_id;
        END IF;
        IF lp_shipment_rec.ship_to_cust_account_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_cust_account_id := l_shipment_rec.ship_to_cust_account_id;
        END IF;
        IF lp_shipment_rec.ship_to_party_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_party_id := l_shipment_rec.ship_to_party_id;
        END IF;
        IF lp_shipment_rec.ship_to_party_site_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_party_site_id := l_shipment_rec.ship_to_party_site_id;
        END IF;
  	  END IF;
     END IF;

    END IF; -- UPDATE

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_ItemTcaBsc: Begin ',1,'N');
    END IF;
	ASO_VALIDATE_PVT.Validate_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: party_id: x_return_status: ' || x_return_status,1,'N');
     END IF;

	ASO_VALIDATE_PVT.Validate_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.cust_party_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: cust_party_id: x_return_status: ' || x_return_status,1,'N');
     END IF;

	ASO_VALIDATE_PVT.Validate_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.invoice_to_cust_party_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: inv_cust_party_id: x_return_status: ' || x_return_status,1,'N');
     END IF;

	ASO_VALIDATE_PVT.Validate_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.End_Customer_cust_party_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: end_cust_party_id: x_return_status: ' || x_return_status,1,'N');
     END IF;

	ASO_VALIDATE_PVT.Validate_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_shipment_rec.ship_to_cust_party_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: shp_cust_party_id: x_return_status: ' || x_return_status,1,'N');
     END IF;


	ASO_VALIDATE_PVT.Validate_CustAccount_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
    	p_inv_cust_account_id	=> lp_qte_header_rec.invoice_to_cust_account_id,
    	p_end_cust_account_id	=> lp_qte_header_rec.End_Customer_cust_account_id,
    	p_shp_cust_account_id	=> lp_shipment_rec.ship_to_cust_account_id,
	x_return_status		=> x_return_status,
    	x_msg_count		=> x_msg_count,
    	x_msg_data		=> x_msg_data);
	 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	  END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: custAcctBsc: x_return_status: ' || x_return_status,1,'N');
     END IF;

	ASO_VALIDATE_PVT.Validate_org_contact_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_contact_id		=> lp_qte_header_rec.org_contact_id,
	p_cust_account_id       => lp_qte_header_rec.cust_account_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: OrgConBsc: x_return_status: ' || x_return_status,1,'N');
     END IF;


    ASO_VALIDATE_PVT.Validate_Inv_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id			=> lp_qte_header_rec.invoice_to_party_id,
    p_site_use          => 'BILL_TO',
   	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_ItemTcaBsc: InvPty: BillTo: x_return_status: ' || x_return_status,1,'N');
     END IF;

    ASO_VALIDATE_PVT.Validate_Inv_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id			=> lp_qte_header_rec.End_Customer_party_id,
     p_site_use          => 'END_USER',
   	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_ItemTcaBsc: InvPty: EndUser: x_return_status: ' || x_return_status,1,'N');
     END IF;

	       ASO_VALIDATE_PVT.Validate_Inv_Party_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_shipment_rec.ship_to_party_id,
      p_site_use          => 'SHIP_TO',
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: InvPty: ShipTo: x_return_status: ' || x_return_status,1,'N');
        aso_debug_pub.add('before Validate_Inv_PartySite_bsc:lp_qte_header_rec.invoice_to_cust_party_id: '||p_qte_header_rec.invoice_to_cust_party_id, 1, 'Y');
        aso_debug_pub.add('before Validate_Inv_PartySite_bsc:lp_qte_header_rec.invoice_to_party_site_id: '||p_qte_header_rec.invoice_to_party_site_id, 1, 'Y');
     END IF;

	ASO_VALIDATE_PVT.Validate_Inv_PartySite_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.invoice_to_cust_party_id,
	p_party_site_id	=> lp_qte_header_rec.invoice_to_party_site_id,
	p_party_site_use   => 'BILL_TO',
    x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: InvPtySite: ShipTo: x_return_status: ' || x_return_status,1,'N');
        aso_debug_pub.add('before Validate_Inv_PartySite_bsc:lp_qte_header_rec.End_Customer_cust_party_id: '||p_qte_header_rec.End_Customer_cust_party_id, 1, 'Y');
        aso_debug_pub.add('before Validate_Inv_PartySite_bsc:lp_qte_header_rec.End_Customer_party_site_id: '||p_qte_header_rec.End_Customer_party_site_id, 1, 'Y');
     END IF;

	ASO_VALIDATE_PVT.Validate_Inv_PartySite_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.End_Customer_cust_party_id,
	p_party_site_id	=> lp_qte_header_rec.End_Customer_party_site_id,
	p_party_site_use   => 'END_USER',
    x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: InvPtySite: ShipTo: x_return_status: ' || x_return_status,1,'N');
        aso_debug_pub.add('before Validate_Inv_PartySite_bsc:lp_shipment_rec.ship_to_cust_party_id: '||p_shipment_rec.ship_to_cust_party_id, 1, 'Y');
        aso_debug_pub.add('before Validate_Inv_PartySite_bsc:lp_shipment_rec.ship_to_party_site_id: '||p_shipment_rec.ship_to_party_site_id, 1, 'Y');
     END IF;

    	ASO_VALIDATE_PVT.Validate_Inv_PartySite_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_shipment_rec.ship_to_cust_party_id,
	p_party_site_id	=> lp_shipment_rec.ship_to_party_site_id,
	p_party_site_use   => 'SHIP_TO',
    x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaBsc: InvPtySite: ShipTo: x_return_status: ' || x_return_status,1,'N');
     END IF;

-- Sold_to
  IF lp_qte_header_rec.sold_to_party_site_id IS NOT NULL
   AND lp_qte_header_rec.sold_to_party_site_id <> FND_API.G_MISS_NUM THEN
    IF lp_qte_header_rec.org_contact_id IS NOT NULL
	  AND lp_qte_header_rec.org_contact_id <> FND_API.G_MISS_NUM THEN
        OPEN C_Get_Party_From_Org(lp_qte_header_rec.org_contact_id);
        FETCH C_Get_Party_From_Org INTO l_party_id;
        CLOSE C_Get_Party_From_Org;
    ELSE
        l_party_id := lp_qte_header_rec.party_id;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('before Validate_Inv_PartySite_bsc:l_party_id: '||l_party_id, 1, 'Y');
    END IF;
    	ASO_VALIDATE_PVT.Validate_Inv_PartySite_bsc(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> l_party_id,
	p_party_site_id	=> lp_qte_header_rec.sold_to_party_site_id,
	p_party_site_use   => 'SOLD_TO',
    x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;
  END IF;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('Validate_ItemTcaBsc: InvPtySite: SoldTo: x_return_status: ' || x_return_status,1,'N');
  END IF;
-- Sold_to

   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Validate_item_tca_bsc;


PROCEDURE Validate_record_tca_crs(
	p_init_msg_list		IN	VARCHAR2,
	p_qte_header_rec        IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type :=
ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
	p_shipment_rec        	IN	ASO_QUOTE_PUB.shipment_rec_type 		:=
ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
     p_operation_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
     p_application_type_code  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

    l_api_name          VARCHAR2(40) := 'Validate_record_tca_crs' ;
    l_party_id          NUMBER;

	l_qte_header_rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
	lp_qte_header_rec       ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
     l_shipment_rec          ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;
     lp_shipment_rec         ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;

    CURSOR C_Get_Party_From_Org(l_org_contact_id NUMBER) IS
      SELECT par.party_id
      FROM hz_relationships par,
           hz_org_contacts org
      WHERE org.party_relationship_id = par.relationship_id
      AND org.org_contact_id  = l_org_contact_id
--      AND org.status = 'A' -- status column obseleted
      and par.status = 'A'
      and (sysdate between nvl(par.start_date, sysdate) and nvl(par.end_date, sysdate));

BEGIN
     SAVEPOINT VALIDATE_RECORD_TCA_CRS_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

/** Changes for OA uptake **/
    lp_qte_header_rec := p_qte_header_rec;
    lp_shipment_rec := p_shipment_rec;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_ItemTcaCrs: lp_qte_header_rec.quote_header_id: ' || lp_qte_header_rec.quote_header_id,1,'N');
        aso_debug_pub.add('Validate_ItemTcaCrs: lp_shipment_rec.shipment_id: ' || lp_shipment_rec.shipment_id,1,'N');
     END IF;

    IF (p_application_type_code = 'QUOTING HTML' AND p_operation_code = 'UPDATE') THEN
      l_qte_header_rec := ASO_UTILITY_PVT.query_header_row (lp_qte_header_rec.quote_header_id);

      IF lp_qte_header_rec.party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.party_id := l_qte_header_rec.party_id;
      END IF;
      IF lp_qte_header_rec.cust_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.cust_party_id := l_qte_header_rec.cust_party_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_cust_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_cust_party_id := l_qte_header_rec.invoice_to_cust_party_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_cust_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_cust_party_id := l_qte_header_rec.End_Customer_cust_party_id;
      END IF;
      IF lp_qte_header_rec.cust_account_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.cust_account_id := l_qte_header_rec.cust_account_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_cust_account_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_cust_account_id := l_qte_header_rec.invoice_to_cust_account_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_cust_account_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_cust_account_id := l_qte_header_rec.End_Customer_cust_account_id;
      END IF;
      IF lp_qte_header_rec.org_contact_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.org_contact_id := l_qte_header_rec.org_contact_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_party_id := l_qte_header_rec.invoice_to_party_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_party_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_party_id := l_qte_header_rec.End_Customer_party_id;
      END IF;
      IF lp_qte_header_rec.invoice_to_party_site_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.invoice_to_party_site_id := l_qte_header_rec.invoice_to_party_site_id;
      END IF;
      IF lp_qte_header_rec.End_Customer_party_site_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.End_Customer_party_site_id := l_qte_header_rec.End_Customer_party_site_id;
      END IF;
      IF lp_qte_header_rec.sold_to_party_site_id = FND_API.G_MISS_NUM THEN
        lp_qte_header_rec.sold_to_party_site_id := l_qte_header_rec.sold_to_party_site_id;
      END IF;

      IF lp_shipment_rec.operation_code = 'UPDATE' THEN
       IF lp_shipment_rec.shipment_id IS NOT NULL AND lp_shipment_rec.shipment_id <> FND_API.G_MISS_NUM THEN
        l_shipment_rec := ASO_UTILITY_PVT.query_shipment_row (lp_shipment_rec.shipment_id);
        IF lp_shipment_rec.ship_to_cust_party_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_cust_party_id := l_shipment_rec.ship_to_cust_party_id;
        END IF;
        IF lp_shipment_rec.ship_to_cust_account_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_cust_account_id := l_shipment_rec.ship_to_cust_account_id;
        END IF;
        IF lp_shipment_rec.ship_to_party_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_party_id := l_shipment_rec.ship_to_party_id;
        END IF;
        IF lp_shipment_rec.ship_to_party_site_id = FND_API.G_MISS_NUM THEN
          lp_shipment_rec.ship_to_party_site_id := l_shipment_rec.ship_to_party_site_id;
        END IF;
	  END IF;
      END IF;

    END IF; -- UPDATE

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	ASO_VALIDATE_PVT.Validate_Party_Crs(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	p_cust_party_id  => lp_qte_header_rec.cust_party_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('validate record tca crs - after validate party crs '||x_return_status, 1, 'N');
	END IF;

	 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
	  END IF;
	 ASO_VALIDATE_PVT.Validate_org_contact_crs(
	p_init_msg_list		=> p_init_msg_list,
	p_contact_id		=> lp_qte_header_rec.org_contact_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
        p_party_id		=> lp_qte_header_rec.party_id,
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	  aso_debug_pub.add('validate record tca crs - after validate org contact crs '||x_return_status, 1, 'N');
 	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
	  END IF;
 ASO_VALIDATE_PVT.Validate_Inv_Party_Crs(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	p_cust_party_id => lp_qte_header_rec.cust_party_id,
	p_inv_party_id		=> lp_qte_header_rec.invoice_to_party_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
	p_inv_cust_account_id	=> lp_qte_header_rec.invoice_to_cust_account_id,
	p_inv_cust_party_id => lp_qte_header_rec.invoice_to_cust_party_id,
    p_site_use   => 'BILL_TO',
	x_return_status		=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('validate record tca crs - after validate Inv party crs(Bill to) '||x_return_status, 1, 'N');
	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
	 END IF;

 ASO_VALIDATE_PVT.Validate_Inv_Party_Crs(
     p_init_msg_list          => p_init_msg_list,
     p_party_id          => lp_qte_header_rec.party_id,
     p_cust_party_id => lp_qte_header_rec.cust_party_id,
     p_inv_party_id      => lp_qte_header_rec.End_Customer_party_id,
     p_cust_account_id   => lp_qte_header_rec.cust_account_id,
     p_inv_cust_account_id    => lp_qte_header_rec.End_Customer_cust_account_id,
     p_inv_cust_party_id => lp_qte_header_rec.End_Customer_cust_party_id,
    p_site_use   => 'END_USER',
     x_return_status          => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data);
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('validate record tca crs - after validate Inv party crs(End User) '||x_return_status, 1, 'N');
     END IF;

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

  ASO_VALIDATE_PVT.Validate_Inv_Party_Crs(
	p_init_msg_list		=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	p_cust_party_id => lp_qte_header_rec.cust_party_id,
	p_inv_party_id		=> lp_shipment_rec.ship_to_party_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
	p_inv_cust_account_id	=> lp_shipment_rec.ship_to_cust_account_id,
	p_inv_cust_party_id	=> lp_shipment_rec.ship_to_cust_party_id,
     p_site_use   		=> 'SHIP_TO',
	x_return_status	=> x_return_status,
     x_msg_count		=> x_msg_count,
     x_msg_data		=> x_msg_data);
 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	  aso_debug_pub.add('validate record tca crs - after validate Inv party crs(Ship to) '||x_return_status, 1, 'N');
 	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
	 END IF;
	ASO_VALIDATE_PVT.Validate_inv_PartySite_crs(
	p_init_msg_list	=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	p_cust_party_id => lp_qte_header_rec.cust_party_id,
	p_inv_party_id		=> lp_qte_header_rec.invoice_to_party_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
	p_inv_cust_account_id	=> lp_qte_header_rec.invoice_to_cust_account_id,
	p_inv_cust_party_id => lp_qte_header_rec.invoice_to_cust_party_id,
	p_party_site_id	=> lp_qte_header_rec.invoice_to_party_Site_id,
	p_site_usage		=> 'BILL_TO',
	x_return_status	=> x_return_status,
     x_msg_count		=> x_msg_count,
     x_msg_data		=> x_msg_data);
 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	  aso_debug_pub.add('validate record tca crs - after validate Inv party site crs(Bill to) '||x_return_status, 1, 'N');
 	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
	 END IF;

     ASO_VALIDATE_PVT.Validate_inv_PartySite_crs(
     p_init_msg_list     => p_init_msg_list,
     p_party_id          => lp_qte_header_rec.party_id,
     p_cust_party_id => lp_qte_header_rec.cust_party_id,
     p_inv_party_id      => lp_qte_header_rec.End_Customer_party_id,
     p_cust_account_id   => lp_qte_header_rec.cust_account_id,
     p_inv_cust_account_id    => lp_qte_header_rec.End_Customer_cust_account_id,
     p_inv_cust_party_id => lp_qte_header_rec.End_Customer_cust_party_id,
     p_party_site_id     => lp_qte_header_rec.End_Customer_party_Site_id,
     p_site_usage        => 'END_USER',
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data);
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('validate record tca crs - after validate Inv party site crs(End User) '||x_return_status, 1, 'N');
     END IF;

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
      END IF;

	ASO_VALIDATE_PVT.Validate_inv_PartySite_crs(
	p_init_msg_list	=> p_init_msg_list,
	p_party_id		=> lp_qte_header_rec.party_id,
	p_party_site_id	=> lp_shipment_rec.ship_to_party_Site_id,
	p_cust_party_id => lp_qte_header_rec.cust_party_id,
	p_inv_party_id		=> lp_shipment_rec.ship_to_party_id,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
	p_inv_cust_account_id	=> lp_shipment_rec.ship_to_cust_account_id,
	p_inv_cust_party_id	=> lp_shipment_rec.ship_to_cust_party_id,
	p_site_usage		=> 'SHIP_TO',
	x_return_status	=> x_return_status,
     x_msg_count		=> x_msg_count,
     x_msg_data		=> x_msg_data);
 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	  aso_debug_pub.add('validate record tca crs - after validate Inv party site crs(Ship to) '||x_return_status, 1, 'N');
 	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	 END IF;

-- Sold_to
    IF lp_qte_header_rec.org_contact_id IS NOT NULL
	AND lp_qte_header_rec.org_contact_id <> FND_API.G_MISS_NUM THEN
        OPEN C_Get_Party_From_Org(lp_qte_header_rec.org_contact_id);
        FETCH C_Get_Party_From_Org INTO l_party_id;
        CLOSE C_Get_Party_From_Org;
    ELSE
        l_party_id := lp_qte_header_rec.party_id;
    END IF;

    ASO_VALIDATE_PVT.Validate_inv_PartySite_crs(
	p_init_msg_list	=> p_init_msg_list,
	p_party_id		=> l_party_id,
	p_cust_party_id => lp_qte_header_rec.cust_party_id,
	p_inv_party_id		=> null,
	p_cust_account_id	=> lp_qte_header_rec.cust_account_id,
	p_inv_cust_account_id	=> null,
	p_inv_cust_party_id => null,
	p_party_site_id	=> lp_qte_header_rec.sold_to_party_Site_id,
	p_site_usage		=> 'SOLD_TO',
	x_return_status	=> x_return_status,
     x_msg_count		=> x_msg_count,
     x_msg_data		=> x_msg_data);
 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
 	  aso_debug_pub.add('validate record tca crs - after validate Inv party site crs(Sold to) '||x_return_status, 1, 'N');
 	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
	 END IF;
-- Sold_to

   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Validate_record_tca_crs;

   PROCEDURE Validate_QTE_OBJ_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_QUOTE_OBJECT_TYPE_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
  CURSOR C1 IS select 'x'
           from aso_lookups
           where lookup_type = 'ASO_QUOTE_OBJECT_TYPE'
           and lookup_code = p_QUOTE_OBJECT_TYPE_CODE;
l_exist VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF P_QUOTE_OBJECT_TYPE_CODE IS NOT NULL AND P_QUOTE_OBJECT_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
         OPEN C1;
         FETCH C1 INTO l_exist;
         IF C1%NOTFOUND or l_exist is NULL THEN
            CLOSE C1;
               x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_OBJECT_TYPE_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',P_QUOTE_OBJECT_TYPE_CODE,FALSE);
                FND_MSG_PUB.ADD;
	        END IF;

        ELSE
	       CLOSE C1;
	    END IF;

     END IF;

END Validate_QTE_OBJ_TYPE_CODE;

PROCEDURE Validate_OBJECT_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_OBJECT_TYPE_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
  CURSOR C1 IS select 'x'
          from aso_lookups
          where lookup_type = 'ASO_RELATED_OBJECT_TYPE'
          and lookup_code = p_OBJECT_TYPE_CODE;

l_exist VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF p_OBJECT_TYPE_CODE IS NOT NULL AND p_OBJECT_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
         OPEN C1;
         FETCH C1 INTO l_exist;
         IF C1%NOTFOUND or l_exist is NULL THEN
            CLOSE C1;
               x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'OBJECT_TYPE_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_OBJECT_TYPE_CODE,FALSE);
                FND_MSG_PUB.ADD;
	        END IF;

        ELSE
	       CLOSE C1;
	    END IF;

     END IF;


END Validate_OBJECT_TYPE_CODE;
PROCEDURE Validate_RLTSHIP_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_RELATIONSHIP_TYPE_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    )
IS
  CURSOR C1 IS SELECT 'x'
          from aso_lookups
          where lookup_type = 'ASO_OBJECT_RELATIONSHIP_TYPE'
          and lookup_code = p_RELATIONSHIP_TYPE_CODE;

l_exist VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF P_RELATIONSHIP_TYPE_CODE IS NOT NULL AND P_RELATIONSHIP_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
         OPEN C1;
         FETCH C1 INTO l_exist;
         IF C1%NOTFOUND or l_exist is NULL THEN
            CLOSE C1;
               x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'RELATIONSHIP_TYPE_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',P_RELATIONSHIP_TYPE_CODE,FALSE);
                FND_MSG_PUB.ADD;
	        END IF;

        ELSE
	       CLOSE C1;
	    END IF;

     END IF;


END Validate_RLTSHIP_TYPE_CODE;



PROCEDURE Validate_Minisite(
        p_init_msg_list         IN      VARCHAR2,
        p_minisite_id           IN      NUMBER,
        x_return_status         OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */       NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
IS
    CURSOR C_Minisite IS
        SELECT start_date_active, end_date_active FROM IBE_MSITES_B
        WHERE msite_id = p_minisite_id;
    l_start_date        DATE;
    l_end_date          DATE;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_minisite_id IS NOT NULL AND p_minisite_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Minisite;
        FETCH C_Minisite INTO l_start_date, l_end_date;
        IF (C_Minisite%NOTFOUND OR
            (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
                                 NVL(l_end_date, sysdate))) THEN
            CLOSE C_Minisite;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'MSITE_ID', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_minisite_id),FALSE);
                FND_MSG_PUB.ADD;
            END IF;
        ELSE
            CLOSE C_Minisite;
        END IF;
    END IF;

END Validate_Minisite;



PROCEDURE Validate_Section(
        p_init_msg_list         IN      VARCHAR2,
        p_section_id            IN      NUMBER,
        x_return_status         OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */       NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
IS
    CURSOR C_Section IS
        SELECT start_date_active, end_date_active FROM IBE_DSP_SECTIONS_B
        WHERE section_id = p_section_id;
    l_start_date        DATE;
    l_end_date          DATE;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_section_id IS NOT NULL AND p_section_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Section;
        FETCH C_Section INTO l_start_date, l_end_date;
        IF (C_Section%NOTFOUND OR
            (sysdate NOT BETWEEN NVL(l_start_date, sysdate) AND
                                 NVL(l_end_date, sysdate))) THEN
            CLOSE C_Section;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SECTION_ID', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_section_id),FALSE);
                FND_MSG_PUB.ADD;
            END IF;
        ELSE
            CLOSE C_Section;
        END IF;
    END IF;

END Validate_Section;


Procedure Validate_Quote_Percent(
    p_init_msg_list             IN      VARCHAR2,
    p_sales_credit_tbl          IN      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
)
IS

    CURSOR C_Quota_Header(l_quote_header_id NUMBER) IS
    SELECT SUM(A.percent)        total
      FROM ASO_SALES_CREDITS     A,
           OE_SALES_CREDIT_TYPES B
     WHERE A.quote_header_id = l_quote_header_id
       AND A.quote_line_id IS NULL
       AND A.sales_credit_type_id = B.sales_credit_type_id
       AND B.quota_flag = 'Y';

    CURSOR C_Quota_Line(l_quote_header_id NUMBER, l_quote_line_id NUMBER) IS
    SELECT SUM(A.percent)        total
      FROM ASO_SALES_CREDITS     A,
           OE_SALES_CREDIT_TYPES B
     WHERE A.quote_header_id = l_quote_header_id
       AND A.quote_line_id = l_quote_line_id
       AND A.sales_credit_type_id = B.sales_credit_type_id
       AND B.quota_flag = 'Y';

    l_percent_total NUMBER;

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('validate_quote_percent: sales_credit_tbl.cnt: '|| p_sales_credit_tbl.count, 1, 'N');
      aso_debug_pub.add('validate_quote_percent: quote_header_id:      '|| p_sales_credit_tbl(1).quote_header_id, 1, 'N');
      aso_debug_pub.add('validate_quote_percent: quote_line_id:        '|| p_sales_credit_tbl(1).quote_line_id, 1, 'N');
      aso_debug_pub.add('validate_quote_percent: qte_line_index:       '|| p_sales_credit_tbl(1).qte_line_index, 1, 'N');
    END IF;

    IF p_sales_credit_tbl(1).quote_header_id IS NOT NULL AND p_sales_credit_tbl(1).quote_header_id <> FND_API.G_MISS_NUM THEN
        IF p_sales_credit_tbl(1).quote_line_id IS NOT NULL AND p_sales_credit_tbl(1).quote_line_id <> FND_API.G_MISS_NUM THEN
            FOR percent_rec IN c_quota_line(p_sales_credit_tbl(1).quote_header_id, p_sales_credit_tbl(1).quote_line_id) LOOP
                l_percent_total := percent_rec.total;
            END LOOP;
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('validate_quote_percent: line level sales credit', 1, 'N');
              aso_debug_pub.add('validate_quote_percent: percent in line db:   '|| l_percent_total, 1, 'N');
            END IF;
        ELSE
            FOR percent_rec IN c_quota_header(p_sales_credit_tbl(1).quote_header_id) LOOP
                l_percent_total := percent_rec.total;
            END LOOP;
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('validate_quote_percent: header level sales credit', 1, 'N');
              aso_debug_pub.add('validate_quote_percent: percent in header db: '|| l_percent_total, 1, 'N');
            END IF;
        END IF;
    END IF;

    --IF nvl(l_percent_total,0) <> 100 THEN --commented to fix bug5671266
    IF l_percent_total IS NOT NULL AND l_percent_total <> 100 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_SALES_CREDIT_PERCENT');
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

END Validate_Quote_Percent;


Procedure Validate_Sales_Credit_Return(
    p_init_msg_list             IN      VARCHAR2,
    p_sales_credit_tbl          IN      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    p_qte_line_rec              IN      ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
)
IS

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('validate_sales_credit_return: start '|| x_return_status, 1, 'N');
    END IF;

    IF p_qte_line_rec.LINE_CATEGORY_CODE = 'RETURN' THEN
        IF p_sales_credit_tbl.count > 0 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_SALES_CREDIT_RETURN');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('validate_sales_credit_return: end '|| x_return_status, 1, 'N');
    END IF;

END Validate_Sales_Credit_Return;


PROCEDURE  validate_ship_from_org_ID (
    P_Qte_Line_rec	 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Shipment_rec   IN   ASO_QUOTE_PUB.Shipment_Rec_Type,
    x_return_status  OUT NOCOPY /* file.sql.39 change */    VARCHAR2
  )
IS

l_org_id          NUMBER;

-- bug 2492841
-- view org_organization_definitions is changed to base table
-- hr_organization_units

CURSOR c_org_id is
SELECT org.organization_id
FROM mtl_system_items msi, hr_organization_units org
WHERE msi.inventory_item_id = p_qte_line_rec.inventory_item_id
AND org.organization_id= msi.organization_id
AND sysdate <= nvl( org.date_to, sysdate)
AND org.organization_id= p_shipment_rec.ship_from_org_id
 --AND msi.organization_id= p_qte_line_rec.organization_id
AND rownum = 1 ;

BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_VALIDATE_PVT inventory_item_id: '||p_qte_line_rec.inventory_item_id, 1, 'N');
      aso_debug_pub.add('ASO_VALIDATE_PVT organization_id: '||p_qte_line_rec.organization_id, 1, 'N');
      aso_debug_pub.add('ASO_VALIDATE_PVT ship_from_org_id: '||p_shipment_rec.ship_from_org_id, 1, 'N');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_qte_line_rec.inventory_item_id is not null AND p_qte_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
	  (p_qte_line_rec.organization_id is not null AND p_qte_line_rec.organization_id <> FND_API.G_MISS_NUM) AND
	  (p_shipment_rec.ship_from_org_id is not null AND p_shipment_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN

	  open c_org_id;
	  fetch c_org_id into l_org_id;
	  IF  c_org_id%NOTFOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;
       close c_org_id;
   END IF;
END validate_ship_from_org_ID;


PROCEDURE Validate_Commitment(
     P_Init_Msg_List     IN   VARCHAR2,
     P_Qte_Header_Rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Qte_Line_Rec      IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2)

IS

     CURSOR C_Commitment_Cur(l_cust_account_id NUMBER, l_currency_code VARCHAR2, l_org_id NUMBER,
                         l_agreement_id NUMBER, l_commitment_id NUMBER, l_inventory_item_id NUMBER) IS
      SELECT 'VALID'
      FROM ra_customer_trx ratrx, ra_customer_trx_lines ratrl
      WHERE EXISTS
      (SELECT 1 FROM ra_cust_trx_types ractt
       WHERE ractt.type IN ('DEP', 'GUAR')
       AND ratrx.cust_trx_type_id = ractt.cust_trx_type_id
       AND ractt.org_id = l_org_id)
      AND ratrx.bill_to_customer_id = l_cust_account_id
      AND ratrx.complete_flag = 'Y'
      AND trunc(sysdate) BETWEEN trunc(nvl(ratrx.start_date_commitment, sysdate))
          AND trunc(nvl(ratrx.end_date_commitment, sysdate))
      AND ratrx.invoice_currency_code = l_currency_code
      AND nvl(l_agreement_id, nvl(ratrx.agreement_id,0)) = nvl(ratrx.agreement_id, nvl(l_agreement_id,0))
      AND ratrl.customer_trx_id = ratrx.customer_trx_id
      AND nvl(ratrl.inventory_item_id, nvl(l_inventory_item_id,0)) = nvl(l_inventory_item_id,0)
      AND ratrx.customer_trx_id = l_commitment_id;

     CURSOR C_Get_Agreement(l_qte_hdr_id NUMBER) IS
      SELECT Contract_Id
      FROM ASO_QUOTE_HEADERS_ALL
      WHERE Quote_Header_Id = l_qte_hdr_id;

     CURSOR C_Header_Cur(l_qte_hdr_id NUMBER) IS
      SELECT Org_Id, Currency_Code, Invoice_To_Cust_Account_Id
      FROM ASO_QUOTE_HEADERS_ALL
      WHERE Quote_Header_Id = l_qte_hdr_id;
     CURSOR C_Line_Cur(l_qte_ln_id NUMBER) IS
      SELECT Agreement_Id, Commitment_Id, Inventory_Item_Id
      FROM ASO_QUOTE_LINES_ALL
      WHERE Quote_Line_Id = l_qte_ln_id;

     l_Org_Id            NUMBER;
     l_Currency_Code     VARCHAR2(15);
     l_Cust_Account_Id   NUMBER;
     l_Agreement_Id      NUMBER;
     l_Commitment_Id     NUMBER;
     l_Inventory_Item_Id NUMBER;
     l_Cur_Variable      VARCHAR2(10);

BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Entering Validate_Commitment', 1, 'N');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Quote_Header_Id: '||P_Qte_Header_Rec.Quote_Header_Id, 1, 'N');
       aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Commitment_Id: '||P_Qte_Line_Rec.Commitment_Id, 1, 'N');
    END IF;

     IF P_Qte_Line_Rec.Commitment_Id IS NOT NULL AND
      P_Qte_Line_Rec.Commitment_Id <> FND_API.G_MISS_NUM THEN

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Operation_Code: '||P_Qte_Line_Rec.Operation_Code, 1, 'N');
      END IF;
          IF P_Qte_Line_Rec.Operation_Code = 'CREATE' THEN

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Org_Id: '||P_Qte_Header_Rec.Org_Id, 1, 'N');
             aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Currency_Code: '||P_Qte_Header_Rec.Currency_Code, 1, 'N');
             aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Invoice_To_Cust_Account_Id: '||P_Qte_Header_Rec.Invoice_To_Cust_Account_Id, 1, 'N');
             aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Cust_Account_Id: '||P_Qte_Header_Rec.Cust_Account_Id, 1, 'N');
             aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Agreement_Id: '||P_Qte_Line_Rec.Agreement_Id, 1, 'N');
             aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Commitment_Id: '||P_Qte_Line_Rec.Commitment_Id, 1, 'N');
             aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Inventory_Item_Id: '||P_Qte_Line_Rec.Inventory_Item_Id, 1, 'N');
           END IF;
               l_Org_Id := P_Qte_Header_Rec.Org_Id;
               l_Currency_Code := P_Qte_Header_Rec.Currency_Code;
/*
               IF P_Qte_Line_Rec.Invoice_To_Cust_Account_Id IS NOT NULL AND
                P_Qte_Line_Rec.Invoice_To_Cust_Account_Id <> FND_API.G_MISS_NUM THEN
aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Invoice_To_Cust_Account_Id: '||P_Qte_Line_Rec.Invoice_To_Cust_Account_Id, 1, 'N');

                    l_Cust_Account_Id := P_Qte_Line_Rec.Invoice_To_Cust_Account_Id;

               ELSIF P_Qte_Header_Rec.Invoice_To_Cust_Account_Id IS NOT NULL AND
                P_Qte_Header_Rec.Invoice_To_Cust_Account_Id <> FND_API.G_MISS_NUM THEN
aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Invoice_To_Cust_Account_Id: '||P_Qte_Header_Rec.Invoice_To_Cust_Account_Id, 1, 'N');

                    l_Cust_Account_Id := P_Qte_Header_Rec.Invoice_To_Cust_Account_Id;

               ELSE
aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Cust_Account_Id: '||P_Qte_Header_Rec.Cust_Account_Id, 1, 'N');
*/
                    l_Cust_Account_Id := P_Qte_Header_Rec.Cust_Account_Id;

/*               END IF; */

               l_Agreement_Id := P_Qte_Line_Rec.Agreement_Id;
               l_Commitment_Id := P_Qte_Line_Rec.Commitment_Id;
               l_Inventory_Item_Id := P_Qte_Line_Rec.Inventory_Item_Id;

               IF l_Agreement_Id IS NULL  OR l_agreement_id = FND_API.G_MISS_NUM
			THEN
                    OPEN C_Get_Agreement(P_Qte_Header_Rec.Quote_Header_id);
                    FETCH C_Get_Agreement INTO l_Agreement_Id;
                    CLOSE C_Get_Agreement;
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Validate_Commitment-l_Agreement_Id: '||l_Agreement_Id, 1, 'N');
               END IF;
               END IF;

               OPEN C_Commitment_Cur(l_cust_account_id, l_currency_code, l_org_id,
                              l_agreement_id, l_commitment_id, l_inventory_item_id);
               FETCH C_Commitment_Cur INTO l_Cur_Variable;
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Validate_Commitment-l_Cur_Variable: '||l_Cur_Variable, 1, 'N');
               END IF;
               IF C_Commitment_Cur%NOTFOUND OR l_Cur_Variable <> 'VALID' THEN
               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Validate_Commitment-Invalid Commitment: ', 1, 'N');
               END IF;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_COMMITMENT');
                         FND_MSG_PUB.ADD;
                    END IF;
               END IF;

               CLOSE C_Commitment_Cur;

          ELSE  -- Operation is 'UPDATE'

               OPEN C_Header_Cur(P_Qte_Header_Rec.Quote_Header_Id);
               FETCH C_Header_Cur INTO l_Org_Id, l_Currency_Code, l_Cust_Account_Id;
               CLOSE C_Header_Cur;

               IF P_Qte_Header_Rec.Org_Id IS NOT NULL AND
                P_Qte_Header_Rec.Org_Id <> FND_API.G_MISS_NUM THEN
                    l_Org_Id := P_Qte_Header_Rec.Org_Id;
               END IF;

               IF P_Qte_Header_Rec.Currency_Code IS NOT NULL AND
                P_Qte_Header_Rec.Currency_Code <> FND_API.G_MISS_CHAR THEN
                    l_Currency_Code := P_Qte_Header_Rec.Currency_Code;
               END IF;

               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('Validate_Commitment-l_Org_Id: '||l_Org_Id, 1, 'N');
                  aso_debug_pub.add('Validate_Commitment-l_Currency_Code: '||l_Currency_Code, 1, 'N');
               END IF;
/*
               IF P_Qte_Line_Rec.Invoice_To_Cust_Account_Id IS NOT NULL AND
                P_Qte_Line_Rec.Invoice_To_Cust_Account_Id <> FND_API.G_MISS_NUM THEN
aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Invoice_To_Cust_Account_Id: '||P_Qte_Line_Rec.Invoice_To_Cust_Account_Id, 1, 'N');

                    l_Cust_Account_Id := P_Qte_Line_Rec.Invoice_To_Cust_Account_Id;

               ELSIF P_Qte_Header_Rec.Invoice_To_Cust_Account_Id IS NOT NULL AND
                P_Qte_Header_Rec.Invoice_To_Cust_Account_Id <> FND_API.G_MISS_NUM THEN
aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Invoice_To_Cust_Account_Id: '||P_Qte_Header_Rec.Invoice_To_Cust_Account_Id, 1, 'N');

                    l_Cust_Account_Id := P_Qte_Header_Rec.Invoice_To_Cust_Account_Id;

               ELSE
aso_debug_pub.add('Validate_Commitment-P_Qte_Header_Rec.Cust_Account_Id: '||P_Qte_Header_Rec.Cust_Account_Id, 1, 'N');
*/
                    l_Cust_Account_Id := P_Qte_Header_Rec.Cust_Account_Id;

/*               END IF; */

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Commitment-P_Qte_Line_Rec.Quote_Line_Id: '||P_Qte_Line_Rec.Quote_Line_Id, 1, 'N');
END IF;

               OPEN C_Line_Cur(P_Qte_Line_Rec.Quote_Line_Id);
               FETCH C_Line_Cur INTO l_Agreement_Id, l_Commitment_Id, l_Inventory_Item_Id;
               CLOSE C_Line_Cur;

               IF P_Qte_Line_Rec.Agreement_Id IS NOT NULL AND
                P_Qte_Line_Rec.Agreement_Id <> FND_API.G_MISS_NUM THEN
                    l_Agreement_Id := P_Qte_Line_Rec.Agreement_Id;
               END IF;

               IF P_Qte_Line_Rec.Commitment_id IS NOT NULL AND
                P_Qte_Line_Rec.Commitment_Id <> FND_API.G_MISS_NUM THEN
                    l_Commitment_Id := P_Qte_Line_Rec.Commitment_Id;
               END IF;

               IF P_Qte_Line_Rec.Inventory_Item_Id IS NOT NULL AND
                P_Qte_Line_Rec.Inventory_Item_Id <> FND_API.G_MISS_NUM THEN
                    l_Inventory_Item_Id := P_Qte_Line_Rec.Inventory_Item_Id;
               END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Commitment-l_Agreement_Id: '||l_Agreement_Id, 1, 'N');
  aso_debug_pub.add('Validate_Commitment-l_Commitment_Id: '||l_Commitment_Id, 1, 'N');
  aso_debug_pub.add('Validate_Commitment-l_inventory_item_id: '||l_inventory_item_id, 1, 'N');
END IF;

               OPEN C_Commitment_Cur(l_cust_account_id, l_currency_code, l_org_id,
                              l_agreement_id, l_commitment_id, l_inventory_item_id);
               FETCH C_Commitment_Cur INTO l_Cur_Variable;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Commitment-l_Cur_Variable: '||l_Cur_Variable, 1, 'N');
END IF;
               IF C_Commitment_Cur%NOTFOUND OR l_Cur_Variable <> 'VALID' THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Commitment-Invalid Commitment: ', 1, 'N');
END IF;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_COMMITMENT');
                         FND_MSG_PUB.ADD;
                    END IF;
               END IF;

               CLOSE C_Commitment_Cur;

          END IF; -- Operation

     END IF;

END Validate_Commitment;


PROCEDURE Validate_Agreement(
     P_Init_Msg_List     IN   VARCHAR2,
     P_Agreement_Id      IN   NUMBER,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2)

IS

     CURSOR C_Agreement_Cur(l_agreement_id NUMBER) IS
      SELECT Start_Date_Active, End_Date_Active
      FROM OE_AGREEMENTS_B
      WHERE Agreement_Id = l_agreement_id;

     l_Start_Date_Active      DATE;
     l_End_Date_Active        DATE;

BEGIN

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Entering Validate_Agreement', 1, 'N');
  aso_debug_pub.add('Validate_Agreement-P_Agreement_Id: '||P_Agreement_Id, 1, 'N');
END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN C_Agreement_Cur(P_Agreement_Id);
     FETCH C_Agreement_Cur INTO l_Start_Date_Active, l_End_Date_Active;

     IF C_Agreement_Cur%NOTFOUND THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Agreement-Agreement Not Found', 1, 'N');
END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_AGREEMENT');
               FND_MSG_PUB.ADD;
          END IF;
     END IF;

     IF (trunc(sysdate) NOT BETWEEN trunc(l_Start_Date_Active) AND NVL(trunc(l_End_Date_Active),trunc(sysdate))) THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Validate_Agreement-Agreement Invalid', 1, 'N');
END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_INACTIVE_AGREEMENT');
               FND_MSG_PUB.ADD;
          END IF;
     END IF;

     CLOSE C_Agreement_Cur;

END Validate_Agreement;

-- hyang quote_status
PROCEDURE Validate_Status_Transition(
	p_init_msg_list		  IN	VARCHAR2,
	p_source_status_id  IN	NUMBER,
	p_dest_status_id	  IN	NUMBER,
	x_return_status		  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  x_msg_count		      OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  x_msg_data		      OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

  CURSOR c_transition(from_status_id NUMBER, to_status_id NUMBER)
  IS
	  SELECT  transition_id, enabled_flag
	  FROM    ASO_QUOTE_STATUS_TRANSITIONS
	  WHERE   from_status_id = p_source_status_id
	          AND to_status_id = p_dest_status_id;

	l_transition_id     NUMBER;
	l_enabled_flag      VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Validate_Quote_Status(
      p_init_msg_list     => p_init_msg_list,
      p_quote_status_id   => p_source_status_id,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'SOURCE_STATUS_ID', FALSE);
	   FND_MESSAGE.Set_Token('VALUE',to_char(p_source_status_id),FALSE);
        FND_MSG_PUB.ADD;
	    END IF;
      RETURN;
    END IF;

    Validate_Quote_Status(
      p_init_msg_list     => p_init_msg_list,
      p_quote_status_id   => p_dest_status_id,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'DEST_STATUS_ID', FALSE);
	   FND_MESSAGE.Set_Token('VALUE',to_char(p_dest_status_id),FALSE);
        FND_MSG_PUB.ADD;
	    END IF;
      RETURN;
    END IF;

    OPEN c_transition(p_source_status_id, p_dest_status_id);
	  FETCH c_transition INTO l_transition_id, l_enabled_flag;
    IF (c_transition%NOTFOUND) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_NONEXISTENT_STATUS_TRANS');
        FND_MSG_PUB.ADD;
	    END IF;
    ELSIF (l_enabled_flag <> 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_DISABLED_STATUS_TRANS');
        FND_MSG_PUB.ADD;
      END IF;
  	END IF;
    CLOSE c_transition;

END Validate_Status_Transition;

-- end of hyang quote_status

-- hyang okc
PROCEDURE Validate_Contract_Template(
	p_init_msg_list		          IN	VARCHAR2,
	p_template_id               IN	NUMBER,
	p_template_major_version	  IN	NUMBER,
	x_return_status		          OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  x_msg_count		              OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  x_msg_data		              OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS

    l_major_version              NUMBER;

    CURSOR c_k_template (lc_template_id NUMBER) IS
      SELECT  major_version
      FROM    okc_sales_templates_v
      WHERE   id = lc_template_id;

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_k_template(p_template_id);
    FETCH c_k_template INTO l_major_version;
    IF c_k_template%NOTFOUND
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'TEMPLATE_ID', FALSE);
        FND_MSG_PUB.ADD;
	    END IF;
    ELSE
      IF l_major_version <> p_template_major_version
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'TEMPLATE_MAJOR_VERSION', FALSE);
		FND_MESSAGE.Set_Token('VALUE',to_char(p_template_major_version),FALSE);
          FND_MSG_PUB.ADD;
  	    END IF;
      END IF;
    END IF;

    CLOSE c_k_template;

END Validate_Contract_Template;

-- end of hyang okc

PROCEDURE Validate_Promotion (
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_price_attr_tbl           IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
     x_price_attr_tbl           OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Validate_Promotion';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_price_attr_tbl              ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    m_price_attr_tbl              ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_search_price_attr1_tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_search_price_attr2_tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_search_priceline_attr1_tbl  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_search_priceline_attr2_tbl  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;
    temp_count                    NUMBER;
    G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    l_count                       NUMBER := 0;
    l_dup_count                   NUMBER := 0;
    l_dup_ln_count                NUMBER := 0;
    l_list_header_id              NUMBER;
    l_list_line_id                NUMBER;
    l_price_attribute_id          NUMBER;
    adj_rec_exists                VARCHAR2(1):= 'N';

    Cursor C_get_list_lines(p_list_header_id NUMBER) IS
    SELECT list_line_id
    FROM qp_list_lines
    WHERE list_header_id = p_list_header_id;

    Cursor C_get_list_header(p_list_line_id NUMBER) IS
    SELECT list_header_id
    FROM qp_list_lines
    WHERE list_line_id = p_list_line_id;

    Cursor C_get_attr(p_quote_header_id NUMBER,
                      p_quote_line_id NUMBER,
                      p_pricing_attribute1 VARCHAR2,
                      p_pricing_attribute2 VARCHAR2 ) IS
    SELECT price_attribute_id
    FROM aso_price_attributes
    WHERE quote_header_id = p_quote_header_id
    AND nvl(quote_line_id,0) = nvl(decode(p_quote_line_id,FND_API.G_MISS_NUM,null,p_quote_line_id),0)
    AND nvl(pricing_attribute1,'X') = nvl(p_pricing_attribute1,'X')
    AND nvl(pricing_attribute2,'Y') = nvl(p_pricing_attribute2,'Y');

    Cursor C_get_attr1(p_quote_header_id NUMBER,
                      p_quote_line_id NUMBER,
                      p_list_line_id   NUMBER) IS
    SELECT price_attribute_id
    FROM aso_price_attributes
    WHERE quote_header_id = p_quote_header_id
    AND nvl(quote_line_id,0) = nvl(decode(p_quote_line_id,FND_API.G_MISS_NUM,null,p_quote_line_id),0)
    AND  pricing_attribute1 IN ( SELECT to_char(qpe.list_header_id)
                                 FROM qp_list_lines qpe
                                 WHERE qpe.list_line_id = p_list_line_id);

    Cursor C_get_attr2(p_quote_header_id NUMBER,
                      p_quote_line_id NUMBER,
                      p_list_header_id   NUMBER,
                      p_pricing_attribute2 VARCHAR2) IS
    SELECT price_attribute_id
    FROM aso_price_attributes
    WHERE quote_header_id = p_quote_header_id
    AND nvl(quote_line_id,0) = nvl(decode(p_quote_line_id,FND_API.G_MISS_NUM,null,p_quote_line_id),0)
    AND  (
	  ( nvl(pricing_attribute2,'X') = nvl(p_pricing_attribute2,'X') AND
            p_pricing_attribute2 IS NOT NULL
           )
           OR ( p_pricing_attribute2 IS NULL
                AND  pricing_attribute2 IN ( SELECT to_char(qpe.list_line_id)
                                 FROM qp_list_lines qpe
                                 WHERE qpe.list_header_id = p_list_header_id)
          )
    );

/*
    OR  (quote_header_id = p_quote_header_id
    	 AND nvl(quote_line_id,0) = nvl(p_quote_line_id,0)
    	 AND nvl(pricing_attribute1,'X') = nvl(to_char(p_list_header_id),'X')
        )
    OR  (quote_header_id = p_quote_header_id
    	 AND nvl(quote_line_id,0) = nvl(p_quote_line_id,0)
    	 AND nvl(pricing_attribute2,'Y') = nvl(to_char(p_list_line_id),'Y')
        )
    OR  (NVL(qp.list_line_id,'0') = nvl(to_char(p_list_line_id),'0')
         AND quote_header_id = p_quote_header_id
    	 AND nvl(quote_line_id,0) = nvl(p_quote_line_id,0)
         AND pricing_attribute1 IS NULL
    	 AND nvl(pricing_attribute2,'Y') IN ( SELECT qpe.list_line_id
                                              FROM qp_list_lines qpe
                                              WHERE qpe.list_header_id = qp.list_header_id)
        )
*/

BEGIN

-- Standard Start of API savepoint
SAVEPOINT VALIDATE_PROMOTION_PVT;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                     p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Start of Validate_Promotion .....',1,'Y');
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('Begin FND_API.to_Boolean'||p_init_msg_list, 1, 'Y');
 END IF;
 FND_MSG_PUB.initialize;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_price_attr_tbl := p_price_attr_tbl;
m_price_attr_tbl := p_price_attr_tbl;


l_count := 0;
adj_rec_exists := 'N';
For i IN 1..m_price_attr_tbl.count LOOP
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('********Loop No:'||i,1,'N');
     aso_debug_pub.add('m_price_attr_tbl(i).operation_code:'||m_price_attr_tbl(i).operation_code,1,'N');
   END IF;
   If m_price_attr_tbl(i).operation_code = 'CREATE' Then

    If m_price_attr_tbl(i).pricing_attribute1 IS NOT NULL
	    AND m_price_attr_tbl(i).pricing_attribute1 <> FND_API.G_MISS_CHAR THEN
	        m_price_attr_tbl(i).pricing_attribute2 := null;
             l_list_header_id := to_number(m_price_attr_tbl(i).pricing_attribute1);
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('If m_price_attr_tbl(i).pricing_attribute1 IS NOT NULL l_list_header_id:'
                                  ||l_list_header_id,1,'N');
             END IF;

             If l_search_price_attr1_tbl.exists(l_list_header_id) Then
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('p_price_attr1_tbl(i).pricing_attribute1 already searched:'
                                      ||l_list_header_id,1,'N');
                END IF;
                l_dup_count := l_dup_count + 1;
             else
                l_search_price_attr1_tbl(l_list_header_id).qte_line_index := l_list_header_id;

	           For j IN 1..l_price_attr_tbl.count LOOP
		          If m_price_attr_tbl(i).pricing_attribute1 = l_price_attr_tbl(j).pricing_attribute1
			        AND l_price_attr_tbl(j).operation_code = 'CREATE' THEN
				       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				          aso_debug_pub.add('Comparing with CREATE incrementing l_count',1,'N');
				       END IF;
				       l_count := l_count + 1;
		          END If;

		          If m_price_attr_tbl(i).pricing_attribute1 = l_price_attr_tbl(j).pricing_attribute1
			        AND l_price_attr_tbl(j).operation_code = 'DELETE' THEN
				       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				          aso_debug_pub.add('Comparing with DELETE decrementing l_count',1,'N');
				       END IF;
				       l_count := l_count - 1;
		          END If;

	           End LOOP;--j IN 1..l_price_attr_tbl.count
             End If;--l_search_price_attr1_tbl.exists(l_list_header_id)

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('After Comparing within PL/SQL table l_count:'||l_count,1,'N');
             END IF;

             For C_get_list_lines_rec in C_get_list_lines(l_list_header_id) LOOP
                 l_list_line_id := C_get_list_lines_rec.list_line_id;
                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('Inside C_get_list_lines list line id to compare:'||l_list_line_id,1,'N');
                 END IF;

                 If l_search_price_attr2_tbl.exists(l_list_line_id) Then
                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                      aso_debug_pub.add('p_price_attr2_tbl(i).pricing_attribute2 already searched:'
                                         ||l_list_line_id,1,'N');
                    END IF;
                    l_dup_ln_count := l_dup_ln_count + 1;
                 else
                     l_search_price_attr2_tbl(l_list_line_id).qte_line_index := l_list_line_id;
	                For j IN 1..l_price_attr_tbl.count LOOP
                         if ( l_price_attr_tbl(j).pricing_attribute2 = FND_API.G_MISS_CHAR ) then
			             l_price_attr_tbl(j).pricing_attribute2 := null;
                         end if;
		               If l_list_line_id = to_number(nvl(l_price_attr_tbl(j).pricing_attribute2,'0'))
			             AND l_price_attr_tbl(j).operation_code = 'CREATE' THEN
				            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				              aso_debug_pub.add('Comparing with CREATE incrementing l_count',1,'N');
				            END IF;
				            l_count := l_count + 1;
		               END If;

		               If l_list_line_id = to_number(nvl(l_price_attr_tbl(j).pricing_attribute2,'0'))
			             AND l_price_attr_tbl(j).operation_code = 'DELETE' THEN
				            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				               aso_debug_pub.add('Comparing with DELETE decrementing l_count',1,'N');
				            END IF;
				            l_count := l_count - 1;
		               END If;

	                 End LOOP;--j IN 1..l_price_attr_tbl.count
                 End If;--l_search_price_attr2_tbl.exists( l_list_header_id )

                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('After comparing the modifier hdr and ln l_count:'||l_count,1,'N');
                 END IF;

             End Loop;-- C_get_list_lines_rec in C_get_list_lines( l_list_header_id )

             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).quote_header_id:'
                                  ||m_price_attr_tbl(i).quote_header_id,1,'N');
                aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).quote_line_id:'
                                   ||m_price_attr_tbl(i).quote_line_id,1,'N');
                aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).pricing_attribute1:'
                                   ||m_price_attr_tbl(i).pricing_attribute1,1,'N');
                aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).pricing_attribute2:'
                                   ||nvl(m_price_attr_tbl(i).pricing_attribute2,'null'),1,'N');
                aso_debug_pub.add('B4 C_get_attr: l_list_header_id:'
                                   ||l_list_header_id,1,'N');
                aso_debug_pub.add('B4 C_get_attr: l_list_line_id:'
                                   ||l_list_line_id,1,'N');
             END IF;

             OPEN C_get_attr(m_price_attr_tbl(i).quote_header_id,
                             m_price_attr_tbl(i).quote_line_id,
                             m_price_attr_tbl(i).pricing_attribute1,
                             m_price_attr_tbl(i).pricing_attribute2);
             FETCH C_get_attr INTO l_price_attribute_id;
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Inside C_get_attr - record existing in db - Price_attribute_Id: '
                                  ||l_price_attribute_id,1,'N');
               aso_debug_pub.add('Inside C_get_attr - Total # of rows : '
                                  ||C_get_attr%ROWCOUNT,1,'N');
             END IF;
             IF (C_get_attr%FOUND OR C_get_attr%ROWCOUNT > 0) THEN
                 adj_rec_exists := 'Y';
             END IF;
             CLOSE C_get_attr;
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Inside C_get_attr - adj_rec_exists : '
                                  ||adj_rec_exists,1,'N');
             END IF;

             OPEN C_get_attr1(m_price_attr_tbl(i).quote_header_id,
                             m_price_attr_tbl(i).quote_line_id,
                             l_list_line_id);
             FETCH C_get_attr1 INTO l_price_attribute_id;
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Inside C_get_attr1 - record existing in db - Price_attribute_Id: '
                                  ||l_price_attribute_id,1,'N');
               aso_debug_pub.add('Inside C_get_attr1 - Total # of rows : '
                                  ||C_get_attr1%ROWCOUNT,1,'N');
             END IF;
             IF (C_get_attr1%FOUND OR C_get_attr1%ROWCOUNT > 0) THEN
                 adj_rec_exists := 'Y';
             END IF;
             CLOSE C_get_attr1;
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Inside C_get_attr1 - adj_rec_exists : '
                                  ||adj_rec_exists,1,'N');
             END IF;


             OPEN C_get_attr2(m_price_attr_tbl(i).quote_header_id,
                             m_price_attr_tbl(i).quote_line_id,
                             l_list_header_id,
                             m_price_attr_tbl(i).pricing_attribute2);
             FETCH C_get_attr2 INTO l_price_attribute_id;
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Inside C_get_attr2 - record existing in db - Price_attribute_Id: '
                                  ||l_price_attribute_id,1,'N');
               aso_debug_pub.add('Inside C_get_attr2 - Total # of rows : '
                                  ||C_get_attr2%ROWCOUNT,1,'N');
             END IF;
             IF (C_get_attr2%FOUND OR C_get_attr2%ROWCOUNT > 0) THEN
                 adj_rec_exists := 'Y';
             END IF;
             CLOSE C_get_attr2;
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Inside C_get_attr2 - adj_rec_exists : '
                                  ||adj_rec_exists,1,'N');
               aso_debug_pub.add('Before the error stack - for PRICING_ATTRIBUTE1 NOT NULL',1,'N');
               aso_debug_pub.add('l_count:'||l_count||' adj_rec_exists:'||adj_rec_exists,1,'N');
               aso_debug_pub.add('l_dup_count:'||l_dup_count,1,'N');
             END IF;


             If (l_count > 1 AND l_dup_count >= 1) OR (l_count >= 1 AND adj_rec_exists = 'Y')   Then
               /*Duplicate*/
	            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	              aso_debug_pub.add('Duplicate record for list_header_id: '
			     			   ||m_price_attr_tbl(i).pricing_attribute1,1,'N');
	            END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_VAL_PROMO_DUPLICATE_HDR');
                    FND_MESSAGE.Set_Token('MODHDRID', m_price_attr_tbl(i).pricing_attribute1, FALSE);
                    FND_MSG_PUB.Add;
                 END IF;
                 --RAISE FND_API.G_EXC_ERROR;
             End If;
    End If;-- m_price_attr_tbl(i).pricing_attribute1 IS NOT NULL

    If m_price_attr_tbl(i).pricing_attribute2 IS NOT NULL
	    AND m_price_attr_tbl(i).pricing_attribute2 <> FND_API.G_MISS_CHAR THEN

	m_price_attr_tbl(i).pricing_attribute1 := null;

        l_list_line_id := to_number(m_price_attr_tbl(i).pricing_attribute2);
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('If m_price_attr_tbl(i).pricing_attribute2 IS NOT NULL l_list_line_id:'
                             ||l_list_line_id,1,'N');
        END IF;

        If l_search_price_attr2_tbl.exists(l_list_line_id) Then
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('p_price_attr1_tbl(i).pricing_attribute2 already searched:'
                                ||l_list_line_id,1,'N');
           END IF;
           l_dup_ln_count := l_dup_ln_count + 1;
        else
            l_search_price_attr2_tbl(l_list_line_id).qte_line_index := l_list_line_id;

	       For j IN 1..l_price_attr_tbl.count LOOP
		      If m_price_attr_tbl(i).pricing_attribute2 = l_price_attr_tbl(j).pricing_attribute2
			    AND l_price_attr_tbl(j).operation_code = 'CREATE' THEN
				   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				     aso_debug_pub.add('Comparing with CREATE incrementing l_count',1,'N');
				   END IF;
				   l_count := l_count + 1;
		      END If;

			 If m_price_attr_tbl(i).pricing_attribute2 = l_price_attr_tbl(j).pricing_attribute2
			    AND l_price_attr_tbl(j).operation_code = 'DELETE' THEN
				   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				     aso_debug_pub.add('Comparing with DELETE decrementing l_count',1,'N');
				   END IF;
				   l_count := l_count - 1;
		      END If;

	      End LOOP;--j IN 1..l_price_attr_tbl.count
        End If;--l_search_price_attr2_tbl.exists(l_list_line_id)
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('After Comparing within PL/SQL table l_count:'||l_count,1,'N');
        END IF;

        For C_get_list_header_rec in C_get_list_header(l_list_line_id) LOOP

        l_list_header_id := C_get_list_header_rec.list_header_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_list_header list header id to compare:'||l_list_header_id,1,'N');
        END IF;

        If l_search_price_attr1_tbl.exists(l_list_header_id) Then
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('p_price_attr1_tbl(i).pricing_attribute2 already searched:'
                                ||l_list_header_id,1,'N');
           END IF;
           l_dup_count := l_dup_count + 1;
        else
            l_search_price_attr1_tbl(l_list_header_id).qte_line_index := l_list_header_id;

	       For j IN 1..l_price_attr_tbl.count LOOP
                      if ( l_price_attr_tbl(j).pricing_attribute1 = FND_API.G_MISS_CHAR ) then
			              l_price_attr_tbl(j).pricing_attribute1 := null;
                      end if;
		      If l_list_header_id = to_number(nvl(l_price_attr_tbl(j).pricing_attribute1,'0'))
			    AND l_price_attr_tbl(j).operation_code = 'CREATE' THEN
				   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				     aso_debug_pub.add('Comparing with CREATE incrementing l_count',1,'N');
				   END IF;
				   l_count := l_count + 1;
		      END If;

			 If l_list_header_id = to_number(nvl(l_price_attr_tbl(j).pricing_attribute1,'0'))
			    AND l_price_attr_tbl(j).operation_code = 'DELETE' THEN
				   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				     aso_debug_pub.add('Comparing with DELETE decrementing l_count',1,'N');
				   END IF;
				   l_count := l_count - 1;
		      END If;

	      End LOOP;--j IN 1..l_price_attr_tbl.count
        End If;--l_search_price_attr1_tbl.exists( l_list_header_id )

        End Loop;-- C_get_list_header_rec in C_get_list_header( l_list_line_id )
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('After comparing the modifier hdr and ln l_count:'||l_count,1,'N');
          aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).quote_header_id:'
                             ||m_price_attr_tbl(i).quote_header_id,1,'N');
          aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).quote_line_id:'
                             ||m_price_attr_tbl(i).quote_line_id,1,'N');
          aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).pricing_attribute1:'
                             ||m_price_attr_tbl(i).pricing_attribute1,1,'N');
          aso_debug_pub.add('B4 C_get_attr: m_price_attr_tbl(i).pricing_attribute2:'
                             ||nvl(m_price_attr_tbl(i).pricing_attribute2,'null'),1,'N');
          aso_debug_pub.add('B4 C_get_attr: l_list_header_id:'
                             ||l_list_header_id,1,'N');
          aso_debug_pub.add('B4 C_get_attr: l_list_line_id:'
                             ||l_list_line_id,1,'N');
        END IF;

        OPEN C_get_attr(m_price_attr_tbl(i).quote_header_id,
                        m_price_attr_tbl(i).quote_line_id,
                        m_price_attr_tbl(i).pricing_attribute1,
                        m_price_attr_tbl(i).pricing_attribute2);
        FETCH C_get_attr INTO l_price_attribute_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_attr - record existing in db - Price_attribute_Id: '
                             ||l_price_attribute_id,1,'N');
          aso_debug_pub.add('Inside C_get_attr - Total # of rows : '
                             ||C_get_attr%ROWCOUNT,1,'N');
        END IF;
        IF (C_get_attr%FOUND OR C_get_attr%ROWCOUNT > 0) THEN
            adj_rec_exists := 'Y';
        END IF;
        CLOSE C_get_attr;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_attr - adj_rec_exists : '
                             ||adj_rec_exists,1,'N');
        END IF;

        OPEN C_get_attr1(m_price_attr_tbl(i).quote_header_id,
                        m_price_attr_tbl(i).quote_line_id,
                        l_list_line_id);
        FETCH C_get_attr1 INTO l_price_attribute_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_attr1 - record existing in db - Price_attribute_Id: '
                             ||l_price_attribute_id,1,'N');
          aso_debug_pub.add('Inside C_get_attr1 - Total # of rows : '
                             ||C_get_attr1%ROWCOUNT,1,'N');
        END IF;
        IF (C_get_attr1%FOUND OR C_get_attr1%ROWCOUNT > 0) THEN
            adj_rec_exists := 'Y';
        END IF;
        CLOSE C_get_attr1;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_attr1 - adj_rec_exists : '
                             ||adj_rec_exists,1,'N');
        END IF;


        OPEN C_get_attr2(m_price_attr_tbl(i).quote_header_id,
                        m_price_attr_tbl(i).quote_line_id,
                        l_list_header_id,
                        m_price_attr_tbl(i).pricing_attribute2);
        FETCH C_get_attr2 INTO l_price_attribute_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_attr2 - record existing in db - Price_attribute_Id: '
                             ||l_price_attribute_id,1,'N');
          aso_debug_pub.add('Inside C_get_attr2 - Total # of rows : '
                             ||C_get_attr2%ROWCOUNT,1,'N');
        END IF;
        IF (C_get_attr2%FOUND OR C_get_attr2%ROWCOUNT > 0) THEN
            adj_rec_exists := 'Y';
        END IF;
        CLOSE C_get_attr2;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('Inside C_get_attr2 - adj_rec_exists : '
                             ||adj_rec_exists,1,'N');
          aso_debug_pub.add('Before the error stack - for PRICING_ATTRIBUTE2 NOT NULL',1,'N');
          aso_debug_pub.add('l_count:'||l_count||' adj_rec_exists:'||adj_rec_exists,1,'N');
          aso_debug_pub.add('l_dup_ln_count:'||l_dup_ln_count,1,'N');
        END IF;


        If ( l_count > 1 AND l_dup_ln_count >= 1) OR (l_count >= 1 AND adj_rec_exists = 'Y')   Then
               /*Duplicate*/
	       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	         aso_debug_pub.add('Duplicate record for list_line_id: '
						   ||m_price_attr_tbl(i).pricing_attribute2,1,'N');
	       END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_VAL_PROMO_DUPLICATE_LN');
                  FND_MESSAGE.Set_Token('MODLNID', m_price_attr_tbl(i).pricing_attribute2, FALSE);
                  FND_MSG_PUB.Add;
               END IF;
               --RAISE FND_API.G_EXC_ERROR;
        End If;


    End If;-- m_price_attr_tbl(i).pricing_attribute2 IS NOT NULL

 End If;-- m_price_attr_tbl(i).operation_code = 'CREATE'

END LOOP;

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      => x_msg_count,
        p_data       => x_msg_data
      );

 for l in 1 .. x_msg_count loop
    x_msg_data := fnd_msg_pub.get( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
 end loop;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('End Validate_Promotion',1,'N');
END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('after inside EXCEPTION  return status'||x_return_status, 1, 'Y');
      END IF;
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

END Validate_Promotion;


FUNCTION Validate_PaymentTerms(
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_TRUE,
	p_payment_term_id	IN	NUMBER)
RETURN VARCHAR2
IS
    CURSOR C_Payment_Terms IS
	SELECT start_date_active, end_date_active FROM RA_TERMS_VL
	WHERE  term_id = p_payment_term_id;

    l_start_date	DATE;
    l_end_date		DATE;
    x_return_status     VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Inititalizing Global Debug Flag Variable.

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_PaymentTerms: p_payment_term_id: '||p_payment_term_id, 1, 'N');
    END IF;

    IF (p_payment_term_id IS NOT NULL AND p_payment_term_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Payment_Terms;
	FETCH C_Payment_Terms INTO l_start_date, l_end_date;
        IF (C_Payment_Terms%NOTFOUND OR
	    (TRUNC(sysdate) NOT BETWEEN NVL(TRUNC(l_start_date), TRUNC(sysdate)) AND
				 NVL(TRUNC(l_end_date), TRUNC(sysdate)))) THEN
	    CLOSE C_Payment_Terms;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PAYMENT_TERM', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',to_char(p_payment_term_id),FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Payment_Terms;
	END IF;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_PaymentTerms: x_return_status: '||x_return_status, 1, 'N');
    END IF;
RETURN x_return_status;
END Validate_PaymentTerms;


FUNCTION Validate_FreightTerms(
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_TRUE,
	p_freight_terms_code	IN	VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR C_Freight_Terms IS
	SELECT start_date_active, end_date_active FROM OE_LOOKUPS
	WHERE   lookup_type = 'FREIGHT_TERMS'
        AND     enabled_flag = 'Y'
	AND     lookup_code  = p_freight_terms_code;

    l_start_date	DATE;
    l_end_date		DATE;
    x_return_status     VARCHAR2(1);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Inititalizing Global Debug Flag Variable.

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_FreightTerms: p_freight_terms_code: '||p_freight_terms_code, 1, 'N');
    END IF;

    IF (p_freight_terms_code IS NOT NULL AND p_freight_terms_code <> FND_API.G_MISS_NUM) THEN
        OPEN C_Freight_Terms;
	FETCH C_Freight_Terms INTO l_start_date, l_end_date;
        IF (C_Freight_Terms%NOTFOUND OR
	    (TRUNC(sysdate) NOT BETWEEN NVL(TRUNC(l_start_date), TRUNC(sysdate)) AND
				 NVL(TRUNC(l_end_date), TRUNC(sysdate)))) THEN
	    CLOSE C_Freight_Terms;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'FREIGHT_TERM', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_freight_terms_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_Freight_Terms;
	END IF;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_FreightTerms: x_return_status: '||x_return_status, 1, 'N');
    END IF;
RETURN x_return_status;
END Validate_FreightTerms;


FUNCTION Validate_ShipMethods(
	p_init_msg_list		IN	VARCHAR2   := FND_API.G_TRUE,
	p_ship_method_code	IN	VARCHAR2,
	p_ship_from_org_id      IN      NUMBER     := FND_API.G_MISS_NUM,
        p_qte_header_id         IN      NUMBER,
        p_qte_line_id           IN      NUMBER := FND_API.G_MISS_NUM)
RETURN VARCHAR2
IS
    CURSOR C_ship_method_code (p_org_id NUMBER) IS
	SELECT start_date_active, end_date_active
	FROM wsh_carrier_ship_methods csm,
	     fnd_lookup_values fl
	WHERE  csm.ship_method_code = p_ship_method_code
	AND    csm.organization_id = p_org_id
        AND    csm.enabled_flag = 'Y'
	AND    fl.lookup_type = 'SHIP_METHOD'
	AND    fl.lookup_code = csm.ship_method_code
	AND    fl.view_application_id = 3
	AND    fl.LANGUAGE = userenv('LANG')
	AND    fl.enabled_flag = 'Y';

    CURSOR C_qte_header_org_info IS
	SELECT aso.org_id
	FROM   ASO_QUOTE_HEADERS_ALL aso
	WHERE  aso.quote_header_id = p_qte_header_id;

    CURSOR C_qte_line_organization IS
	SELECT aso.organization_id
	FROM   ASO_QUOTE_LINES_ALL aso
	WHERE  aso.quote_line_id = p_qte_line_id;

    CURSOR C_qte_line_org_id_info IS
	SELECT aso.org_id
	FROM   ASO_QUOTE_LINES_ALL aso
	WHERE  aso.quote_line_id = p_qte_line_id;

    l_start_date		DATE;
    l_end_date			DATE;
    l_org_id            	NUMBER := FND_API.G_MISS_NUM;
    l_hdr_org_id        	NUMBER;
    l_line_organization_id 	NUMBER;
    l_line_org_id        	NUMBER;
    x_return_status		VARCHAR2(1);

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Inititalizing Global Debug Flag Variable.

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('Validate_ShipMethods: p_ship_method_code :'||p_ship_method_code, 1, 'N');
       aso_debug_pub.add('Validate_ShipMethods: p_ship_from_org_id :'||p_ship_from_org_id, 1, 'N');
       aso_debug_pub.add('Validate_ShipMethods: p_qte_header_id:'||p_qte_header_id, 1, 'N');
       aso_debug_pub.add('Validate_ShipMethods: p_qte_line_id:'||p_qte_line_id, 1, 'N');
    END IF;

    IF (p_ship_from_org_id IS NULL OR p_ship_from_org_id = FND_API.G_MISS_NUM) THEN
	IF (p_qte_header_id IS NOT NULL AND p_qte_header_id <> FND_API.G_MISS_NUM) THEN
	    IF (p_qte_line_id IS NULL OR p_qte_line_id = FND_API.G_MISS_NUM) THEN
		-- Header Level
		OPEN  C_qte_header_org_info;
		FETCH C_qte_header_org_info INTO l_hdr_org_id;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		   aso_debug_pub.add('Validate_ShipMethods: l_hdr_org_id:'||l_hdr_org_id, 1, 'N');
		END IF;
		IF C_qte_header_org_info%FOUND THEN
			l_org_id := TO_NUMBER(OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_hdr_org_id));
		ELSE
	    		x_return_status := FND_API.G_RET_STS_ERROR;
            		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        		FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                		FND_MESSAGE.Set_Token('COLUMN', 'SHIPPING_METHOD', FALSE);
					FND_MESSAGE.Set_Token('VALUE',p_ship_method_code,FALSE);
                		FND_MSG_PUB.ADD;
	    		END IF;
		END IF;
		 CLOSE C_qte_header_org_info;
	    ELSIF (p_qte_line_id IS NOT NULL AND p_qte_line_id <> FND_API.G_MISS_NUM) THEN
		-- Line Level
		OPEN C_qte_line_organization;
		FETCH C_qte_line_organization INTO l_line_organization_id;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		   aso_debug_pub.add('Validate_ShipMethods: l_line_organization_id:'||l_line_organization_id, 1, 'N');
                END IF;
		IF C_qte_line_organization%FOUND THEN
		    l_org_id := l_line_organization_id;
		ELSE
		    OPEN C_qte_line_org_id_info;
		    FETCH C_qte_line_org_id_info INTO l_line_org_id;
                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		       aso_debug_pub.add('Validate_ShipMethods: l_line_org_id:'||l_line_org_id, 1, 'N');
                    END IF;
		    IF C_qte_line_org_id_info%FOUND THEN
			l_org_id := TO_NUMBER(OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_line_org_id));
		    ELSE
	    		x_return_status := FND_API.G_RET_STS_ERROR;
            		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        		FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                		FND_MESSAGE.Set_Token('COLUMN', 'SHIPPING_METHOD', FALSE);
					FND_MESSAGE.Set_Token('VALUE',p_ship_method_code,FALSE);
                		FND_MSG_PUB.ADD;
	    		END IF;
	             END IF;

		     CLOSE C_qte_line_org_id_info;
		END IF;
		 CLOSE C_qte_line_organization;
	    END IF;
	ELSIF (p_qte_header_id IS NULL OR p_qte_header_id = FND_API.G_MISS_NUM) THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SHIPPING_METHOD', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_ship_method_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
	END IF;
    ELSE -- Ship_from_org_id is not null.
	l_org_id := p_ship_from_org_id;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('Validate_ShipMethods: l_org_id:'||l_org_id, 1, 'N');
   aso_debug_pub.add('Validate_ShipMethods: Before Process x_return_status:'||x_return_status, 1, 'N');
END IF;
    IF (p_ship_method_code IS NOT NULL ) AND
-- AND p_ship_method_code <> FND_API.G_MISS_CHAR) AND
       (l_org_id IS NOT NULL AND l_org_id <> FND_API.G_MISS_NUM) AND
       (x_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
        OPEN C_ship_method_code(l_org_id);
	FETCH C_ship_method_code INTO l_start_date, l_end_date;
        IF (C_ship_method_code%NOTFOUND OR
	    (TRUNC(sysdate) NOT BETWEEN NVL(TRUNC(l_start_date), TRUNC(sysdate)) AND
				 NVL(TRUNC(l_end_date), TRUNC(sysdate)))) THEN
	    CLOSE C_ship_method_code;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SHIP_METHOD_CODE', FALSE);
			 FND_MESSAGE.Set_Token('VALUE',p_ship_method_code,FALSE);
                FND_MSG_PUB.ADD;
	    END IF;
        ELSE
	    CLOSE C_ship_method_code;
	END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('Validate_ShipMethods: After Process FINAL RESULT - X_RETURN_STATUS: '||x_return_status, 1, 'N');
END IF;
RETURN x_return_status;

END Validate_ShipMethods;

Procedure Validate_ln_type_for_ord_type
(
p_init_msg_list	IN	VARCHAR2,
p_qte_header_rec	IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type,
P_Qte_Line_rec	IN	ASO_QUOTE_PUB.Qte_Line_Rec_Type,
x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_msg_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
--Validate line type passed in p_qte_line_rec against the Order type
--passed in p_qte_header_rec using the following query:

Cursor c_ln_type_for_ord_type is
SELECT start_date_active, end_date_active
FROM OE_WF_LINE_ASSIGN_V
WHERE order_type_id = p_qte_header_rec.order_type_id
and line_type_id = p_qte_line_rec.order_line_type_id
and (trunc(sysdate) BETWEEN NVL(start_date_active, sysdate) AND
NVL(end_date_active, sysdate));

l_start_date date;
l_end_date date;

Begin
	IF p_qte_line_rec.order_line_type_id IS NOT NULL AND
	   p_qte_line_rec.order_line_type_id <> FND_API.G_MISS_NUM THEN

		OPEN c_ln_type_for_ord_type;
		FETCH c_ln_type_for_ord_type into l_start_date, l_end_Date;

		IF c_ln_type_for_ord_type%NOTFOUND THEN

            x_return_status := FND_API.G_RET_STS_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			     FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_LINE_TYPE');
			     FND_MSG_PUB.ADD;
            END IF;
        END IF;
            CLOSE c_ln_type_for_ord_type;
	END IF;
End Validate_ln_type_for_ord_type;

Procedure Validate_ln_category_code
(
p_init_msg_list	    IN   VARCHAR2,
p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
P_Qte_Line_rec	    IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
--Validate line category code for the quote line
--against the Order type using the following query:
Cursor c_ln_category_code is
SELECT line_category_code from aso_quote_lines_all
where quote_line_id = p_qte_line_rec.quote_line_id;


Cursor c_qte_category_code is
SELECT quote_category_code from aso_quote_headers_all
where quote_header_id = p_qte_header_rec.quote_header_id;

l_line_category_code VARCHAR2(30);
l_quote_category_code VARCHAR2(240);

Begin

      OPEN c_ln_category_code;
      FETCH c_ln_category_code into l_line_category_code;
	 CLOSE c_ln_category_code;

     IF (p_qte_header_rec.quote_category_code = FND_API.G_MISS_CHAR)  THEN
		OPEN c_qte_category_code;
		FETCH c_qte_category_code into l_quote_category_code;
		CLOSE c_qte_category_code;
	else
		l_quote_category_code := p_qte_header_rec.quote_category_code;
	end if;

IF l_line_category_code = 'RETURN' THEN
        IF (l_quote_category_code <> 'MIXED') THEN

            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_LINE_CATEGORY_CODE');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;

END IF;

End Validate_ln_category_code;


Procedure Validate_po_line_number
(
p_init_msg_list	IN   VARCHAR2 := fnd_api.g_false,
p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
P_Qte_Line_rec	     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
-- cursor to find any line payments with po line number
Cursor c_po_ln_number_lines is
SELECT 'x' from aso_payments
where quote_header_id = p_qte_header_rec.quote_header_id
and cust_po_line_number is not null
and cust_po_number is null;

-- cursor to find po line number from header payment
Cursor c_ln_hd_po_number is
SELECT cust_po_number from aso_payments
where quote_header_id = p_qte_header_rec.quote_header_id
and quote_line_id is null;

-- cursor to find po number and po line number for line payment
Cursor c_ln_po_line_number is
SELECT cust_po_number, cust_po_line_number from aso_payments
where quote_header_id = p_qte_header_rec.quote_header_id
and quote_line_id = p_qte_line_rec.quote_line_id;

l_cust_po_line_number   varchar2(50);
l_ln_po_number          varchar2(50);
l_ln_hd_po_number       varchar2(50);
l_po_ln_number_lines    varchar2(50);


Begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if (P_Qte_Line_rec.quote_line_id is not null) and (P_Qte_Line_rec.quote_line_id <> FND_API.G_MISS_NUM) then

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Validate_po_line_number:quote_header_id:'||p_qte_header_rec.quote_header_id , 1, 'N');
   			aso_debug_pub.add('Validate_po_line_number:quote_line_id:'||P_Qte_Line_rec.quote_line_id , 1, 'N');
	      END IF;


            OPEN c_ln_po_line_number;

		FETCH c_ln_po_line_number into l_ln_po_number,l_cust_po_line_number;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Validate_po_line_number:l_ln_po_number:'||l_ln_po_number, 1, 'N');
   			aso_debug_pub.add('Validate_po_line_number:l_cust_po_line_number:'||l_cust_po_line_number, 1, 'N');
	      END IF;

		IF c_ln_po_line_number%FOUND AND l_cust_po_line_number is not null THEN

                IF l_ln_po_number is null THEN

                   OPEN c_ln_hd_po_number;
                   FETCH c_ln_hd_po_number into l_ln_hd_po_number;

		       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('Validate_po_line_number:l_ln_hd_po_number:'||l_ln_hd_po_number, 1, 'N');
	             END IF;


                   IF l_ln_hd_po_number is null THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_PO_NUMBER');
                            FND_MSG_PUB.ADD;
                        END IF;

                   end if;

                   CLOSE c_ln_hd_po_number;

                end if;

       end if;
                CLOSE c_ln_po_line_number;

     else

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Validate_po_line_number:quote_header_id:'||p_qte_header_rec.quote_header_id , 1, 'N');
	      END IF;

            OPEN c_ln_hd_po_number;
		    FETCH c_ln_hd_po_number into l_ln_hd_po_number;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Validate_po_line_number:l_ln_hd_po_number:'||l_ln_hd_po_number, 1, 'N');
	      END IF;

            IF l_ln_hd_po_number is null THEN

                OPEN c_po_ln_number_lines;
		        FETCH c_po_ln_number_lines into l_po_ln_number_lines;

                IF l_po_ln_number_lines is not null THEN

                        x_return_status := FND_API.G_RET_STS_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_PO_NUMBER');
                            FND_MSG_PUB.ADD;
                        END IF;
                end if;

                close  c_po_ln_number_lines;

            end if;

            close  c_ln_hd_po_number;


	 END IF;

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

End Validate_po_line_number;


PROCEDURE validate_service_ref_line_id
(
p_init_msg_list          IN    VARCHAR2  := fnd_api.g_false,
p_service_ref_type_code  IN    VARCHAR2,
p_service_ref_line_id    IN    NUMBER,
p_qte_header_id          IN    NUMBER    := fnd_api.g_miss_num,
x_return_status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_msg_count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
x_msg_data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
is

cursor c_quote is
select quote_line_id from aso_quote_lines_all
where quote_line_id = p_service_ref_line_id
and quote_header_id = p_qte_header_id;

cursor c_order is
select line_id from oe_order_lines_all
where line_id = p_service_ref_line_id;

cursor c_customer_product is
select instance_id
from csi_item_instances
where instance_id = p_service_ref_line_id;

identifier number;

Begin
    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Begin validate_service_ref_line_id', 1, 'Y');
    end if;

    if p_init_msg_list = fnd_api.g_true then
        fnd_msg_pub.initialize;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;

    if p_service_ref_type_code = 'QUOTE' then

       open c_quote;
       fetch c_quote into identifier;

       if aso_debug_pub.g_debug_flag = 'Y' then
          aso_debug_pub.add('validate_service_ref_line_id: Quote: identifier: '|| identifier, 1, 'Y');
       end if;

       if c_quote%notfound then

          x_return_status := fnd_api.g_ret_sts_error;

          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_REF_LINE_ID', FALSE);
		   FND_MESSAGE.Set_Token('VALUE',p_service_ref_line_id,FALSE);
             FND_MSG_PUB.ADD;
	     END IF;

       end if;

       close c_quote;

    elsif p_service_ref_type_code = 'ORDER' then

       open c_order;
       fetch c_order into identifier;

       if aso_debug_pub.g_debug_flag = 'Y' then
          aso_debug_pub.add('validate_service_ref_line_id: Order: identifier: '|| identifier, 1, 'Y');
       end if;

       if c_order%notfound then

          x_return_status := fnd_api.g_ret_sts_error;

          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_REF_LINE_ID', FALSE);
		   FND_MESSAGE.Set_Token('VALUE',p_service_ref_line_id,FALSE);
             FND_MSG_PUB.ADD;
	     END IF;

       end if;

       close c_order;

    elsif p_service_ref_type_code = 'CUSTOMER_PRODUCT' then

       open c_customer_product;
       fetch c_customer_product into identifier;

       if aso_debug_pub.g_debug_flag = 'Y' then
          aso_debug_pub.add('validate_service_ref_line_id: c_customer_product: identifier: '|| identifier, 1, 'Y');
       end if;

       if c_customer_product%notfound then

          x_return_status := fnd_api.g_ret_sts_error;

          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_REF_LINE_ID', FALSE);
		   FND_MESSAGE.Set_Token('VALUE',p_service_ref_line_id,FALSE);
             FND_MSG_PUB.ADD;
	     END IF;

       end if;

       close c_customer_product;
    /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
    elsif p_service_ref_type_code = 'PRODUCT_CATALOG' then
      if p_service_ref_line_id is null then
        x_return_status := fnd_api.g_ret_sts_error;
        IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_REF_LINE_ID', FALSE);
		   FND_MESSAGE.Set_Token('VALUE',p_service_ref_line_id,FALSE);
             FND_MSG_PUB.ADD;
	END IF;


      end if;
    /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
    end if;

End validate_service_ref_line_id;

--Changes for Validating Defaulting Parameters (Start):14/09/2005
PROCEDURE VALIDATE_DEFAULTING_DATA(
				P_quote_header_rec		IN		ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
				P_quote_line_rec		IN		ASO_QUOTE_PUB.QTE_LINE_Rec_Type,
				P_Shipment_header_rec		IN		ASO_QUOTE_PUB.shipment_rec_type,
				P_shipment_line_rec		IN		ASO_QUOTE_PUB.shipment_rec_type,
				P_Payment_header_rec		IN		ASO_QUOTE_PUB.Payment_Rec_Type,
				P_Payment_line_rec		IN		ASO_QUOTE_PUB.Payment_Rec_Type,
				P_tax_header_rec		IN		ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
				P_tax_line_rec			IN		ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
				p_def_object_name		IN		VARCHAR,
				X_quote_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
				X_quote_line_rec		OUT NOCOPY	ASO_QUOTE_PUB.QTE_LINE_Rec_Type,
				X_Shipment_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.shipment_rec_type,
				X_Shipment_line_rec		OUT NOCOPY       ASO_QUOTE_PUB.shipment_rec_type,
				X_Payment_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.Payment_Rec_Type,
				X_Payment_line_rec		OUT NOCOPY      ASO_QUOTE_PUB.Payment_Rec_Type,
				X_tax_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
				X_tax_line_rec			OUT NOCOPY	ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
				X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
				X_MSG_DATA			OUT NOCOPY	VARCHAR2,
				X_MSG_COUNT			OUT NOCOPY	VARCHAR2

				) is


l_data_exists		VARCHAR2(10);
P_Api_Version_Number    NUMBER;
P_Init_Msg_List		VARCHAR2(100) := FND_API.G_FALSE ;
l_api_version_number	CONSTANT NUMBER   := 1.0;
l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_DEFAULTING_DATA';
G_PKG_NAME		CONSTANT VARCHAR2(30) := 'ASO_VALIDATE_PVT';
l_periodicity_profile	varchar2(30);
P_FLAG				VARCHAR2(10);
P_HEADER			VARCHAR2(1);


CURSOR C_FOB(p_lookup_code varchar2)is
SELECT 1 FROM DUAL WHERE exists
(
	SELECT  meaning fob
	FROM	ar_lookups
	WHERE	lookup_type = 'FOB'
	AND	enabled_flag = 'Y'
	AND	trunc(sysdate) BETWEEN NVL(start_date_active, trunc(sysdate))
	AND	NVL(end_date_active, trunc(sysdate))
	AND     lookup_code = p_lookup_code
) ;

CURSOR	C_SHIPMENT_PRIORITY_CODE(p_shipment_priority_code varchar2) IS
SELECT 1 FROM DUAL WHERE EXISTS
(
	SELECT	meaning shipment_priority
	FROM	oe_lookups
	WHERE   lookup_type = 'SHIPMENT_PRIORITY'
	AND	enabled_flag = 'Y'
	AND	trunc(sysdate) between nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate))
	AND	lookup_code = p_shipment_priority_code
);

CURSOR C_SALESCHANNEL(p_lookup_code varchar2) is
SELECT 1 FROM DUAL WHERE exists
(
	SELECT	lookup_code
	FROM	fnd_lookup_values_vl
	WHERE	lookup_type = 'SALES_CHANNEL'
	AND	view_application_id = 660
	AND	enabled_flag = 'Y'
	AND	trunc( NVL(start_date_active, sysdate) ) <=  trunc( sysdate )
	AND	trunc( NVL(end_date_active, sysdate) ) >= trunc( sysdate )
	and	lookup_code = p_lookup_code
 );


CURSOR C_QOTHDDET_CURRENCY_NOT_NULL(p_currency_code varchar2,p_price_list_id varchar2) is
SELECT 1 FROM DUAL WHERE exists
(
 SELECT   d.currency_code currency_code
 FROM     Fnd_currencies      d
         ,qp_currency_details b
         ,qp_list_headers_b   c
 WHERE   c.list_header_id = p_price_list_id
 AND  b.currency_header_id = c.currency_header_id
 AND  d.currency_code = b.to_currency_code
 AND  c.list_type_code IN ('PRL', 'AGR')
 AND  d.currency_flag = 'Y'
 AND  d.enabled_flag = 'Y'
 AND  trunc(sysdate) between trunc(nvl(d.start_date_active,sysdate)) and trunc(nvl(d.end_date_active,sysdate))
 and  trunc(sysdate) between trunc(nvl(c.start_date_active,sysdate)) and trunc(nvl(c.end_date_active,sysdate))
 and  trunc(sysdate) between trunc(nvl(b.start_date_active,sysdate)) and trunc(nvl(b.end_date_active,sysdate))
 AND  d.currency_code = p_currency_code
 UNION
 SELECT    b.currency_code currency_code
 FROM      fnd_currencies b,qp_list_headers_b c
 WHERE     c.currency_code = b.currency_code
 AND  c.list_header_id = p_price_list_id
 AND  c.list_type_code IN ('PRL', 'AGR')
 AND  b.currency_flag = 'Y'
 AND  b.enabled_flag = 'Y'
 and  trunc(sysdate) between trunc(nvl(b.start_date_active,sysdate)) and trunc(nvl(b.end_date_active,sysdate))
 AND  b.currency_code = p_currency_code
 );


CURSOR C_QOTHDDET_CURRENCY_NULL(p_currency_code varchar2) is
SELECT 1 FROM DUAL WHERE exists
(
      SELECT    b.currency_code
      FROM      fnd_currencies b
      WHERE     b.currency_flag = 'Y'
      AND       b.enabled_flag = 'Y'
      AND       trunc(sysdate) between trunc(nvl(start_date_active,sysdate)) and trunc(nvl(end_date_active,sysdate))
      and       b.currency_code = p_currency_code
 );

--New Cursor(s) start
CURSOR C_PAYMENT_TYPE(p_lookup_code varchar2) is		--Payment Type
SELECT 1 FROM DUAL WHERE exists
(
	SELECT	Lookup_Code Payment_Type_Code
	from	ASO_LOOKUPS
	WHERE	LOOKUP_TYPE = 'ASO_PAYMENT_TYPE'
	and	lookup_code <> 'PO'
	and	trunc(nvl(start_date_active,sysdate)) <= trunc(sysdate)
	and	trunc(nvl(end_daTe_active,sysdate)) >=   trunc (sysdate)
	and	enabled_flag = 'Y'
	and	lookup_code  = p_lookup_code
);

CURSOR C_CREDIT_CARD_TYPE(p_credit_card_code varchar2) is	--Credit Card Type
SELECT 1 FROM DUAL WHERE exists
(
	SELECT	CARD_ISSUER_CODE credit_card_code
	FROM	IBY_CREDITCARD_ISSUERS_V
	where   CARD_ISSUER_CODE = p_credit_card_code
);

CURSOR C_DEMAND_CLASS(p_lookup_code varchar2) is		--Demand Class
SELECT 1 FROM DUAL WHERE exists
(
	 Select lookup_code Demand_Class_Code,
		meaning Demand_Class,
		description
	 From 	FND_COMMON_LOOKUPS
	 Where	lookup_type = 'DEMAND_CLASS'
	 And	application_id = 700
	 And	enabled_flag = 'Y'
	 And	trunc(sysdate) Between NVL(start_date_active,trunc(sysdate))
	 And	NVL(end_date_active,trunc(sysdate))
	 And    lookup_code = p_lookup_code
 );

CURSOR C_REQUEST_DATE_TYPE(p_lookup_code varchar2) is		--Request Date Type
SELECT 1 FROM DUAL WHERE exists
(
	Select	lookup_code
	from	oe_lookups
	where	lookup_type='REQUEST_DATE_TYPE'
	and	lookup_code = p_lookup_code
	and	ENABLED_FLAG = 'Y'
	and	trunc(sysdate) between trunc(start_date_active)
	and	trunc(nvl(end_date_active,sysdate))
);

CURSOR C_REQUEST_DATE(p_request_date date) is		--Request Date(Confirm it)
SELECT 1 FROM DUAL WHERE exists
(
	select 1 from dual where trunc(p_request_date) >= trunc(sysdate)
);

CURSOR C_OPERATING_UNIT(p_org_id varchar2) is
select DECODE(MO_GLOBAL.CHECK_ACCESS(p_org_id),'Y','Y','N',NULL,NULL) from dual ;


CURSOR C_CHARGE_PERIODICITY_CODE(p_periodicity_code VARCHAR2,p_periodicity_profile VARCHAR2) is		--CHARGE_PERIODICITY
SELECT 1 FROM DUAL WHERE exists
(
	Select distinct uom_code
	From  MTL_UNITS_OF_MEASURE_VL --Changed mtl_uom_conversions to MTL_UNITS_OF_MEASURE_VL 05/10/2005(Yogeshwar)
	Where uom_class=p_periodicity_profile
	And uom_code=p_periodicity_code
);

CURSOR C_AUTOMATIC_PRICING(p_lookup_code varchar2) IS                          --Auotmatic Pricing
SELECT 1 FROM DUAL WHERE exists
(
	select	lookup_code
	from	aso_lookups
	where	lookup_type='ASO_PRICE_TAX_COMPUTE_OPTION'
	and	lookup_code = p_lookup_code
	and	ENABLED_FLAG = 'Y'
	and	trunc(sysdate) between trunc(start_date_active)
	and	trunc(nvl(end_date_active,sysdate))

);


CURSOR C_AUTOMATIC_TAX(p_lookup_code varchar2) IS                          --Auotmatic Tax
SELECT 1 FROM DUAL WHERE exists
(
	select	lookup_code
	from	aso_lookups
	where	lookup_type='ASO_PRICE_TAX_COMPUTE_OPTION'
	and	lookup_code = p_lookup_code
	and	ENABLED_FLAG = 'Y'
	and	trunc(sysdate) between trunc(start_date_active)
	and	trunc(nvl(end_date_active,sysdate))

);

--New Cursors end


---                             TCA  Routines  Start                             --------------------------------

--1)                            Validate Phone
PROCEDURE VALIDATE_PHONE
			(	p_phone_id	varchar2,
				p_party_id	varchar2,		-- QOTHDDET_MAIN.sold_to_contact_party_id
				p_cust_party_id varchar2		-- QOTHDDET_MAIN.sold_to_cust_party_id'
			) is


CURSOR C_VALIDATE_PHONE_CONTACT IS
SELECT 1 FROM DUAL WHERE EXISTS
	(
		SELECT	phone.contact_point_id
		FROM	HZ_CONTACT_POINTS phone,
			HZ_PARTIES hp
		WHERE	HP.party_id = p_party_id        --When contact is specified
		AND	phone.owner_table_id = hp.party_id
		AND	hp.status = 'A'
		AND	phone.status = 'A'
		AND	phone.owner_table_name = 'HZ_PARTIES'
		AND	phone.contact_point_type = 'PHONE'
		AND	phone.contact_point_id = p_phone_id
	);


CURSOR C_VALIDATE_PHONE_CUSTOMER IS -- when customer is specified and party_type is of type 'PERSON'
SELECT 1 FROM DUAL WHERE EXISTS
	(

		SELECT	phone.contact_point_id
		FROM	HZ_CONTACT_POINTS phone,
			HZ_PARTIES hp
		WHERE	HP.party_id = p_cust_party_id
		AND	phone.owner_table_id = hp.party_id
		AND	hp.status = 'A'
		AND	phone.status = 'A'
		AND	phone.owner_table_name = 'HZ_PARTIES'
		AND	phone.contact_point_type = 'PHONE'
		AND	phone.contact_point_id = p_phone_id
	);

l_data_exists varchar2(10);
l_cust_party_type varchar(20);

BEGIN

SELECT	PARTY_TYPE                    --Selecting the party type from HZ_PARTIES
INTO	l_cust_party_type
FROM	HZ_PARTIES
WHERE	PARTY_ID = nvl(p_party_id,p_cust_party_id);

--When contact is specified
IF p_party_id is not null then
	aso_debug_pub.add('Before Opening the cursor...C_VALIDATE_PHONE_CONTACT', 1, 'Y');
	OPEN C_VALIDATE_PHONE_CONTACT ;

	aso_debug_pub.add('After Opening the cursor...C_VALIDATE_PHONE_CONTACT', 1, 'Y');
	FETCH C_VALIDATE_PHONE_CONTACT INTO l_data_exists ;

	aso_debug_pub.add('After Fetching the cursor...C_VALIDATE_PHONE_CONTACT', 1, 'Y');

	IF C_VALIDATE_PHONE_CONTACT%FOUND THEN
		x_quote_header_rec.PHONE_ID := p_phone_id;
	ELSE
		x_quote_header_rec.PHONE_ID := NULL ;
                aso_debug_pub.add('No Data Found for Cursor...C_VALIDATE_PHONE_CONTACT', 1, 'Y');

		FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_PHONE_NO', TRUE);
		FND_MSG_PUB.ADD;
	END IF;
	aso_debug_pub.add('before Closing the Cursor...C_VALIDATE_PHONE_CONTACT', 1, 'Y');
	CLOSE C_VALIDATE_PHONE_CONTACT;
        aso_debug_pub.add('After Closing the Cursor...C_VALIDATE_PHONE_CONTACT', 1, 'Y');
END IF;

-- when customer is specified and party_type is of type 'PERSON'

IF  p_cust_party_id is NOT NULL AND l_cust_party_type = 'PERSON' THEN
	aso_debug_pub.add('Before Opening the cursor...C_VALIDATE_PHONE_CUSTOMER', 1, 'Y');
	OPEN C_VALIDATE_PHONE_CUSTOMER ;
	aso_debug_pub.add('After Opening the cursor...C_VALIDATE_PHONE_CUSTOMER', 1, 'Y');
	FETCH C_VALIDATE_PHONE_CUSTOMER INTO l_data_exists ;
	aso_debug_pub.add('After Fetching the cursor...C_VALIDATE_PHONE_CUSTOMER', 1, 'Y');

	IF C_VALIDATE_PHONE_CUSTOMER%FOUND THEN
		x_quote_header_rec.PHONE_ID := p_phone_id;
	ELSE
		x_quote_header_rec.PHONE_ID := NULL ;
                aso_debug_pub.add('No Data Found for Cursor...C_VALIDATE_PHONE_CUSTOMER', 1, 'Y');

		FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_PHONE_NO', TRUE);
		FND_MSG_PUB.ADD;
	END IF;
        aso_debug_pub.add('Before Closing the Cursor...C_VALIDATE_PHONE_CUSTOMER', 1, 'Y');
	CLOSE C_VALIDATE_PHONE_CUSTOMER;
        aso_debug_pub.add('After Closing the Cursor...C_VALIDATE_PHONE_CUSTOMER', 1, 'Y');
END IF;

END VALIDATE_PHONE;


--2):			Validate Customer
PROCEDURE VALIDATE_CUSTOMER
(	p_cust_party_id varchar2,
	p_resource_id   varchar2,
	p_flag          varchar2,
	p_header        varchar2
) IS

--Routine for End Customer
-- p_flag possible values END-
-- p_header possible values Y and N

CURSOR C_CUST_PARTY IS
SELECT 1 FROM DUAL WHERE EXISTS
(
	SELECT	hp.party_name  --(Base Query)
	FROM	HZ_PARTIES HP
	WHERE	hp.party_type in ('PERSON','ORGANIZATION')
	AND	hp.status =   'A'
	AND	HP.PARTY_ID = p_cust_party_id
);


-- When ASN_CUST_ACCESS = T and manager_flag = 'Y'
CURSOR C_CUST_PARTY_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		select null
		from   HZ_PARTIES P
		where  P.status = 'A'
		AND	  p.party_type in ('PERSON','ORGANIZATION')
		AND	  P.party_id = p_cust_party_id
		AND	  EXISTS ( SELECT null
				      FROM   as_accesses_all_all secu
				      WHERE  secu.customer_id = P.party_id
				      and  secu.delete_flag is null
				      and  secu.sales_group_id in (
									SELECT  jrgd.group_id
									FROM    jtf_rs_groups_denorm jrgd,
										jtf_rs_group_usages  jrgu
									WHERE   jrgd.parent_group_id  IN (
													select	u.group_id
													from	jtf_rs_rep_managers mgr,
														jtf_rs_group_usages u
													where	mgr.parent_resource_id = p_resource_id
													and     trunc(sysdate) between trunc(mgr.start_date_active)
													and	trunc(nvl(mgr.end_date_active,sysdate))
													and     mgr.hierarchy_type = 'MGR_TO_REP'
													and     mgr.group_id = u.group_id
													and     u.usage in ('SALES','PRM')
													)
					AND trunc(jrgd.start_date_active) <= TRUNC(SYSDATE)
					AND trunc(NVL(jrgd.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
					AND jrgu.group_id = jrgd.group_id
					AND jrgu.usage  in ('SALES', 'PRM'))
					AND secu.lead_id IS NULL
					AND secu.sales_lead_id IS NULL )
					UNION ALL
					SELECT null
					FROM   as_accesses_all_all secu,
						HZ_PARTIES P
					WHERE  secu.customer_id = P.party_id
					AND  secu.lead_id IS NULL
					AND secu.sales_lead_id IS NULL
					AND secu.delete_flag is NULL
					AND salesforce_id = p_resource_id

) ;

-- When ASN_CUST_ACCESS = T and manager_flag = 'N'

CURSOR C_CUST_PARTY_NO_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(

	select	P.party_name
	from	HZ_PARTIES P
	where	P.status = 'A'
	AND	P.party_id = p_cust_party_id
	AND	p.party_type in ('PERSON','ORGANIZATION')
	AND	(exists  (SELECT null
				FROM   as_accesses_all secu
				WHERE secu.customer_id = p.party_id
				AND secu.lead_id IS NULL
				AND secu.sales_lead_id IS NULL                                                                                                         AND salesforce_id = p_resource_id
			  )
		)

);

Cursor C_Mgr_Check  Is   --to check the manager flag
select 1 from dual where exists
	(
	     SELECT  MGR.group_id
	     FROM    jtf_rs_rep_managers MGR ,
		        jtf_rs_group_usages U
	     WHERE   U.usage  = 'SALES'
	     AND     U.group_id = MGR.group_id
	     AND     trunc(MGR.start_date_active)  <= trunc(SYSDATE)
	     AND     trunc(NVL(MGR.end_date_active, SYSDATE)) >= trunc(SYSDATE)
	     AND     MGR.parent_resource_id = MGR.resource_id
	     AND     MGR.hierarchy_type in ('MGR_TO_MGR', 'MGR_TO_REP')
	     AND     MGR.parent_resource_id = p_resource_id
	);

l_data_exists	VARCHAR2(10);
l_manager_flag	VARCHAR2(1);

BEGIN

IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'F' THEN --Base Query

	aso_debug_pub.add('Before Opening the cursor...C_CUST_PARTY', 1, 'Y');

	OPEN C_CUST_PARTY ;
	aso_debug_pub.add('After Opening the cursor...C_CUST_PARTY', 1, 'Y');
	FETCH C_CUST_PARTY INTO l_data_exists ;
	aso_debug_pub.add('After Fetching the cursor...C_CUST_PARTY', 1, 'Y');

	IF C_CUST_PARTY%FOUND THEN
		aso_debug_pub.add('Value of p_flag is..'||p_flag, 1, 'Y');
		aso_debug_pub.add('Value of p_header is..'||p_header, 1, 'Y');

		IF ( p_flag = 'SOLD' ) THEN
			IF ( p_header = 'Y' ) THEN
			   x_quote_header_rec.cust_party_id := p_cust_party_id;
			END IF;
		END IF;

		IF ( p_flag = 'END' ) THEN
			IF ( p_header = 'Y' ) THEN
			   x_quote_header_rec.end_customer_cust_party_id := p_cust_party_id;
			END IF;
			IF ( p_header = 'N' ) THEN
			   x_quote_line_rec.end_customer_cust_party_id := p_cust_party_id;
			END IF;
		END IF;

	ELSE
		IF ( p_flag = 'SOLD' ) THEN
			IF ( p_header = 'Y' ) THEN
			   x_quote_header_rec.cust_party_id := NULL;
			   aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY(Line Header)', 1, 'Y');

			   FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			   FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_CUSTOMER', TRUE);
			   FND_MSG_PUB.ADD;
			END IF;
		END IF;

		IF ( p_flag = 'END' ) THEN
			IF ( p_header = 'Y' ) THEN
			   x_quote_header_rec.end_customer_cust_party_id := NULL;
			   aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY(Line Header)', 1, 'Y');

			   FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			   FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_CUSTOMER', TRUE);
			   FND_MSG_PUB.ADD;
			END IF;

			IF ( p_header = 'N' ) THEN
			   x_quote_line_rec.end_customer_cust_party_id := NULL;
			   aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY(Line End)', 1, 'Y');
			END IF;
		END IF;
	END IF;
        aso_debug_pub.add('Before Closing the Cursor...C_CUST_PARTY', 1, 'Y');
	CLOSE C_CUST_PARTY;
        aso_debug_pub.add('After Closing the Cursor...C_CUST_PARTY', 1, 'Y');
END IF;


IF (NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'T' AND p_resource_id IS NOT NULL) THEN

	aso_debug_pub.add('Before Opening the cursor...C_Mgr_Check', 1, 'Y');
	OPEN C_Mgr_Check    ;              --Assigning the manager flag
	aso_debug_pub.add('After Opening the cursor...C_Mgr_Check', 1, 'Y');
	FETCH C_Mgr_Check INTO l_data_exists ;
	aso_debug_pub.add('After Fetching the cursor...C_Mgr_Check', 1, 'Y');

	IF C_Mgr_Check%FOUND THEN
		l_manager_flag := 'Y';
	ELSE
		l_manager_flag := 'N';
                aso_debug_pub.add('No Data Found for Cursor...C_Mgr_Check', 1, 'Y');
	END IF ;

	CLOSE C_Mgr_Check ;

	IF l_manager_flag = 'Y' THEN

		OPEN C_CUST_PARTY_MANAGER;
		FETCH C_CUST_PARTY_MANAGER INTO l_data_exists ;

		IF C_CUST_PARTY_MANAGER%FOUND THEN

		   IF ( p_flag = 'SOLD' ) THEN
		      IF ( p_header = 'Y' ) THEN
			x_quote_header_rec.cust_party_id := p_cust_party_id;
                      END IF;
                   END IF;

		   IF ( p_flag = 'END' ) THEN
		      IF ( p_header = 'Y' ) THEN
			x_quote_header_rec.end_customer_cust_party_id := p_cust_party_id;
                      END IF;
	              IF ( p_header = 'N' ) THEN
		        x_quote_line_rec.end_customer_cust_party_id := p_cust_party_id;
                      END IF;

                   END IF;
		ELSE
		   IF ( p_flag = 'SOLD' ) THEN
	               IF ( p_header = 'Y' ) THEN

				x_quote_header_rec.cust_party_id := NULL;
				aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY_MANAGER(Line/Header)', 1, 'Y');

				FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_CUSTOMER', TRUE);
				FND_MSG_PUB.ADD;
                        END IF;
                   END IF;

		   IF ( p_flag = 'END' ) THEN
	               IF ( p_header = 'Y' ) THEN

				x_quote_header_rec.end_customer_cust_party_id := NULL;
				aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY_MANAGER(Line/Header)', 1, 'Y');

				FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_CUSTOMER', TRUE);
				FND_MSG_PUB.ADD;
                        END IF;

		        IF ( p_header = 'N' ) THEN
				x_quote_line_rec.end_customer_cust_party_id := NULL;
				aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY_MANAGER(Line/End)', 1, 'Y');
		        END IF;
                   END IF;
		END IF;
		CLOSE C_CUST_PARTY_MANAGER;
	END IF;

	IF l_manager_flag = 'N' THEN

		aso_debug_pub.add('Before Opening the cursor...C_CUST_PARTY_NO_MANAGER', 1, 'Y');
		OPEN C_CUST_PARTY_NO_MANAGER;
		aso_debug_pub.add('After Opening the cursor...C_CUST_PARTY_NO_MANAGER', 1, 'Y');
		FETCH C_CUST_PARTY_NO_MANAGER INTO l_data_exists ;
		aso_debug_pub.add('After Fetching the cursor...C_CUST_PARTY_NO_MANAGER', 1, 'Y');

		IF C_CUST_PARTY_NO_MANAGER%FOUND THEN

		  IF ( p_flag = 'SOLD' ) THEN
	              IF ( p_header = 'Y' ) THEN
			x_quote_header_rec.cust_party_id := p_cust_party_id;
		      END IF;
		   END IF;

	           IF ( p_flag = 'END' ) THEN
	              IF ( p_header = 'Y' ) THEN
			x_quote_header_rec.end_customer_cust_party_id := p_cust_party_id;
		      END IF;
	              IF ( p_header = 'N' ) THEN
		        x_quote_line_rec.end_customer_cust_party_id := p_cust_party_id;
                      END IF;
		   END IF;

		ELSE
		   IF ( p_flag = 'SOLD' ) THEN
	              IF ( p_header = 'Y' ) THEN
		        x_quote_header_rec.cust_party_id := NULL;
			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_CUSTOMER', TRUE);
			FND_MSG_PUB.ADD;
                      END IF;
                   END IF;

	           IF ( p_flag = 'END' ) THEN
	              IF ( p_header = 'Y' ) THEN
		        x_quote_header_rec.end_customer_cust_party_id := NULL;
			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_CUSTOMER', TRUE);
			FND_MSG_PUB.ADD;
                      END IF;
	              IF ( p_header = 'N' ) THEN
		        x_quote_line_rec.end_customer_cust_party_id := NULL;
                      END IF;
                   END IF;

		   aso_debug_pub.add('No Data Found for Cursor...C_CUST_PARTY_NO_MANAGER', 1, 'Y');
	        END IF;

		aso_debug_pub.add('Before Closing the cursor...C_CUST_PARTY_NO_MANAGER', 1, 'Y');
	        CLOSE C_CUST_PARTY_NO_MANAGER;
	        aso_debug_pub.add('After Closing the cursor...C_CUST_PARTY_NO_MANAGER', 1, 'Y');

	END IF;
END IF;

END VALIDATE_CUSTOMER ;
--3):					Validate Contact

PROCEDURE VALIDATE_CONTACT(	p_party_id varchar2,
				p_cust_party_id varchar2,
				p_flag varchar2,
				p_header varchar2
			   )IS

l_data_exists VARCHAR2(10);

--	SOLD to/Bill to/Ship to/ENd Customer - Header or Line
--	p_flag possible values : BILL/SHIP/END/SOLD
--	p_header possible values : Y or N
--	QOTHDDET_MAIN.sold_to_cust_party_id --> p_quote_header_rec.cust_party_id

--CURSOR C_BILL_SHIP_CONTACT_NAME IS
CURSOR C_CONTACT_NAME IS
SELECT 1 FROM DUAL WHERE EXISTS
	(
		SELECT	hp_contact.party_name
		FROM	HZ_PARTIES hp_contact,
			HZ_RELATIONSHIPS hp_rltn
		WHERE	hp_rltn.object_id =   p_cust_party_id   --lv_cust_party_id
		AND	hp_rltn.party_id  = p_party_id
		AND	hp_contact.party_id = hp_rltn.subject_id
		AND	hp_contact.party_type = 'PERSON'
		AND	hp_rltn.relationship_code IN ( Select distinct reltype.forward_rel_code
							 From HZ_RELATIONSHIP_TYPES reltype, HZ_CODE_ASSIGNMENTS code
							 Where code.class_category =   'RELATIONSHIP_TYPE_GROUP'
							 and code.class_code =    'PARTY_REL_GRP_CONTACTS'
							 and code.owner_table_name =   'HZ_RELATIONSHIP_TYPES'
							 and code.owner_table_id =  reltype.relationship_type_id
							 and code.status =   'A'
							 and trunc(code.start_date_active) <= trunc(sysdate)
							 and trunc(nvl(code.end_date_active,sysdate)) >= trunc(sysdate)
							 and reltype.subject_type =   'PERSON'
							 and reltype.object_type =   'ORGANIZATION'
						      )
			 AND hp_contact.status =   'A'
			 AND hp_rltn.status =   'A'
			 AND trunc(hp_rltn.start_date) <= trunc(sysdate)
			 AND trunc(nvl(hp_rltn.end_date,sysdate)) >= trunc(sysdate)
	);

BEGIN
	aso_debug_pub.add('Before Opening the cursor...C_CONTACT_NAME', 1, 'Y');
	OPEN C_CONTACT_NAME ;
	aso_debug_pub.add('After Opening the cursor...C_CONTACT_NAME', 1, 'Y');
	FETCH C_CONTACT_NAME INTO l_data_exists ;
	aso_debug_pub.add('After Fteching the cursor...C_CONTACT_NAME', 1, 'Y');
	aso_debug_pub.add('Value of p_flag is...'||p_flag, 1, 'Y');
	aso_debug_pub.add('Value of p_header is...'||p_header, 1, 'Y');
	IF C_CONTACT_NAME%FOUND THEN
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.INVOICE_TO_PARTY_ID := p_party_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_ID := p_party_id;
				END IF;
			 END IF;

		--Case:2 SHIP

			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
					x_shipment_header_rec.SHIP_TO_PARTY_ID := p_party_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_shipment_line_rec.SHIP_TO_PARTY_ID := p_party_id;
				END IF;
			 END IF;

		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.END_CUSTOMER_PARTY_ID := p_party_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.END_CUSTOMER_PARTY_ID := p_party_id;
				END IF;
			 END IF;

		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN		--No Check for line level
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.PARTY_ID := p_party_id;
				END IF;
			 END IF;

	ELSE   --Set al values to NULL

		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.INVOICE_TO_PARTY_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_CONTACT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_ID := NULL;
				END IF;
			 END IF;

		--Case:2 SHIP

			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
					x_shipment_header_rec.SHIP_TO_PARTY_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_CONTACT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_shipment_line_rec.SHIP_TO_PARTY_ID := NULL;
				END IF;
			 END IF;

		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.END_CUSTOMER_PARTY_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_CONTACT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.END_CUSTOMER_PARTY_ID := NULL;
				END IF;
			 END IF;

		--Case:4 SOLD--Bug 15872732
			/*IF P_FLAG = 'SOLD' THEN		--No Check for line level
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.PARTY_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_CONTACT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;
			 END IF; */

END IF;
        aso_debug_pub.add('Before Closing the Cursor...C_CONTACT_NAME', 1, 'Y');
CLOSE C_CONTACT_NAME;
        aso_debug_pub.add('After Closing the Cursor...C_CONTACT_NAME', 1, 'Y');
END VALIDATE_CONTACT ;


--4):                    Validate Bill Ship Customer
--PARTY NAME
PROCEDURE VALIDATE_BILL_SHIP_CUSTOMER(  		p_cust_party_id varchar2,
							p_cust_acct_id	varchar2,
							p_resource_id	varchar2,
							p_flag		varchar2,
							p_header	varchar2
							) IS

--CREATE OR REPLACE PROCEDURE ASO_SHIP_BILL_CUST_PARTY(p_cust_acct_id varchar2,p_flag varchar2) AS
--:QOTHDDET_MAIN.sold_to_cust_party_id -->p_quote_header_record.CUST_PARTY_ID
--QOTHDDET_MAIN.sold_to_cust_acct_id - > p_quote_header_rec.cust_account_id --> P_CUST_ACCT_ID
-- p_flag possible values : BILL or SHIP
-- p_header possible values : Y or N

Cursor C_Mgr_Check  Is   --to check the manager flag
select 1 from DUAL where exists
	(
	     SELECT	MGR.group_id
	     FROM	jtf_rs_rep_managers MGR ,
			jtf_rs_group_usages U
	     WHERE	U.usage  = 'SALES'
	     AND	U.group_id = MGR.group_id
	     AND	TRUNC(MGR.start_date_active)  <= trunc(SYSDATE)
	     AND	TRUNC(NVL(MGR.end_date_active, SYSDATE) )>= trunc(SYSDATE)
	     AND	MGR.parent_resource_id = MGR.resource_id
	     AND	MGR.hierarchy_type in ('MGR_TO_MGR', 'MGR_TO_REP')
	     AND	MGR.parent_resource_id = p_resource_id
	);

--CURSOR C_INVOICE_TO_CUST_PARTY_NAME_FLD IS
CURSOR C_INVOICE_TO_CUSTOMER IS
--p_quote_header_rec.cust_account_id-->p_cust_acct_id
SELECT 1 FROM DUAL WHERE EXISTS
(
	SELECT	hp.party_id          --Removed HZ_CUST_ACCOUNTS ca
	FROM	HZ_PARTIES hp
	WHERE	hp.party_type in ('PERSON','ORGANIZATION')
	AND	hp.party_id = p_cust_party_id
	AND	hp.status =  'A'
	UNION
	SELECT	hp.party_id
	FROM	HZ_PARTIES hp,
		HZ_CUST_ACCT_RELATE car
	WHERE   car.related_cust_account_id =   p_cust_acct_id
	AND	car.relationship_type =  'ALL'
	AND	car.bill_to_flag = 'Y'
	AND	hp.party_id = p_cust_party_id
	AND	hp.party_type in ('PERSON','ORGANIZATION')
	AND	hp.status =   'A'
	AND	car.status =   'A'
) ;


CURSOR C_SHIP_TO_CUSTOMER IS
--CURSOR C_SHIP_TO_CUST_PARTY_NAME_FLD IS
--p_quote_header_rec.cust_account_id-->p_cust_acct_id
SELECT 1 FROM DUAL WHERE EXISTS
(
	SELECT	hp.party_id
	FROM	HZ_PARTIES hp
	WHERE	hp.party_id = p_cust_party_id
	AND	hp.status =  'A'
	AND	hp.party_type in ('PERSON','ORGANIZATION')
	UNION
	SELECT	hp.party_id
	FROM	HZ_PARTIES hp,
		HZ_CUST_ACCT_RELATE car
	WHERE	car.related_cust_account_id =   p_cust_acct_id
	AND	car.relationship_type =  'ALL'
	AND	car.ship_to_flag = 'Y'
	AND	hp.party_id = p_cust_party_id
	AND	hp.party_type in ('PERSON','ORGANIZATION')
	AND	hp.status =   'A'
	AND	car.status =   'A'
);

-- When ASO_ENFORCE_ACCOUNT_RELATIONSHIPS = 'N' and ASN_CUST_ACCESS = T
--CURSOR C_CUST_PARTY_NAME1 IS
CURSOR C_CUSTOMER IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		SELECT	hp.party_id
		FROM	HZ_PARTIES hp
		WHERE	hp.party_type in ('PERSON','ORGANIZATION')
		AND	hp.status = 'A'
		AND	hp.party_id =  p_cust_party_id               --:QOTHDDET_MAIN.sold_to_cust_party_id
) ;

-- When ASO_ENFORCE_ACCOUNT_RELATIONSHIPS = 'N' and ASN_CUST_ACCESS = T and manager_flag = 'Y'
--CURSOR C_CUST_PARTY_NAME2 IS
CURSOR C_CUSTOMER_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		select	P.party_id
		from	HZ_PARTIES P
		where	P.status = 'A'
		AND     P.party_id = p_cust_party_id
		AND	EXISTS ( SELECT null
				      FROM   as_accesses_all secu
				      WHERE  secu.customer_id = P.party_id
				      AND    secu.sales_group_id in (
									SELECT  jrgd.group_id
									FROM    jtf_rs_groups_denorm jrgd,
										jtf_rs_group_usages  jrgu
									WHERE   jrgd.parent_group_id  IN (
													select	u.group_id
													from	jtf_rs_rep_managers mgr,
														jtf_rs_group_usages u
													where	mgr.parent_resource_id = p_resource_id
													and	trunc(sysdate) between trunc(mgr.start_date_active)
													and	trunc(nvl(mgr.end_date_active,sysdate))
													and	mgr.hierarchy_type = 'MGR_TO_REP'
													and	mgr.group_id = u.group_id
													and	u.usage in ('SALES','PRM')
													)
					    AND TRUNC(jrgd.start_date_active) <= TRUNC(SYSDATE)
					    AND TRUNC(NVL(jrgd.end_date_active, SYSDATE) )>= TRUNC(SYSDATE)
					    AND jrgu.group_id = jrgd.group_id
					    AND jrgu.usage  in ('SALES', 'PRM'))
					AND secu.lead_id IS NULL
					AND secu.sales_lead_id IS NULL
					UNION ALL
					SELECT null
					FROM   as_accesses_all secu
					WHERE  secu.customer_id = p.party_id
					AND	secu.lead_id IS NULL
					AND	secu.sales_lead_id IS NULL
					AND	salesforce_id = p_resource_id
				    )
) ;

-- When ASO_ENFORCE_ACCOUNT_RELATIONSHIPS = 'N' and ASN_CUST_ACCESS = T and manager_flag = 'N'

CURSOR C_CUSTOMER_NO_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(

	select	P.status
	from	HZ_PARTIES P
	where	P.status = 'A'
	AND	P.party_id = p_cust_party_id
	AND	(exists  (SELECT null
				FROM   as_accesses_all secu
				WHERE secu.customer_id = p.party_id
				AND secu.lead_id IS NULL
				AND secu.sales_lead_id IS NULL
				AND salesforce_id = p_resource_id
			  )
		)
);

l_data_exists varchar2(10);
l_manager_flag varchar2(1);

BEGIN

--Case:1 ==================================Enforced Account Relationship is set to 'Y'(Start)=========================================================

IF	NVL(FND_PROFILE.value('ASO_ENFORCE_ACCOUNT_RELATIONSHIPS'),'N')  = 'Y'
	AND p_cust_acct_id IS NOT NULL THEN

		IF P_FLAG = 'BILL' THEN
			 aso_debug_pub.add('Before Opening the cursor...C_INVOICE_TO_CUSTOMER', 1, 'Y');
			 OPEN C_INVOICE_TO_CUSTOMER ;
			 aso_debug_pub.add('Before Fetching the cursor...C_INVOICE_TO_CUSTOMER', 1, 'Y');
			 FETCH C_INVOICE_TO_CUSTOMER INTO l_data_exists ;

			 IF C_INVOICE_TO_CUSTOMER%FOUND THEN

				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
				END IF;

      			ELSE    --Assign Null
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := NULL ;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_CUSTOMER', TRUE);
					FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := NULL;
				END IF;
			aso_debug_pub.add('No Data Found for the cursor...C_INVOICE_TO_CUSTOMER', 1, 'Y');
			END IF;
			aso_debug_pub.add('Before Closing the cursor...C_INVOICE_TO_CUSTOMER', 1, 'Y');
			CLOSE C_INVOICE_TO_CUSTOMER;
		END IF ;

		IF P_FLAG = 'SHIP' THEN
			aso_debug_pub.add('Before Opening the cursor...C_SHIP_TO_CUSTOMER', 1, 'Y');
			OPEN C_SHIP_TO_CUSTOMER ;
			aso_debug_pub.add('Before Fetching the cursor...C_SHIP_TO_CUSTOMER', 1, 'Y');
			FETCH C_SHIP_TO_CUSTOMER INTO l_data_exists ;

			IF C_SHIP_TO_CUSTOMER%FOUND THEN
				IF ( p_header = 'Y' ) THEN
					x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := p_cust_party_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := p_cust_party_id;
				END IF;
			ELSE
				IF ( p_header = 'Y' ) THEN
					x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_CUSTOMER', TRUE);
					FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := NULL;
				END IF;

			END IF;
			aso_debug_pub.add('Before Closing the cursor...C_SHIP_TO_CUSTOMER', 1, 'Y');
			CLOSE C_SHIP_TO_CUSTOMER ;
			aso_debug_pub.add('After Closing the cursor...C_SHIP_TO_CUSTOMER', 1, 'Y');
		END IF;
END IF;

--Case:2==================================Enforced Account Relationship is set to 'N' =========================================================

IF NVL(FND_PROFILE.value('ASO_ENFORCE_ACCOUNT_RELATIONSHIPS'),'N')  = 'N' THEN
--Case 2a
	IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'F' THEN --Put the base query
		aso_debug_pub.add('Before Opening the cursor...C_CUSTOMER', 1, 'Y');
			OPEN C_CUSTOMER ;
			aso_debug_pub.add('Before Fetching the cursor...C_CUSTOMER', 1, 'Y');
			FETCH C_CUSTOMER INTO l_data_exists ;

				IF C_CUSTOMER%FOUND THEN

					IF P_FLAG = 'BILL' THEN

							IF ( p_header = 'Y' ) THEN
								x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

					END IF;

					IF P_FLAG = 'SHIP' THEN
							IF ( p_header = 'Y' ) THEN
								x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := p_cust_party_id;
							END IF;
					END IF;
				ELSE    --Assign Null
					IF P_FLAG = 'BILL' THEN

							IF ( p_header = 'Y' ) THEN
								x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := NULL ;
								FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
								FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_CUSTOMER', TRUE);
								FND_MSG_PUB.ADD;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := NULL;
							END IF;

					END IF;

					IF P_FLAG = 'SHIP' THEN
							IF ( p_header = 'Y' ) THEN
								x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := NULL;
								FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
								FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_CUSTOMER', TRUE);
								FND_MSG_PUB.ADD;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := NULL;
							END IF ;
					END IF ;
					aso_debug_pub.add('No Data found for the cursor...C_CUSTOMER', 1, 'Y');
				END IF ;
					aso_debug_pub.add('Before Closing the cursor...C_CUSTOMER', 1, 'Y');
			CLOSE C_CUSTOMER;
	END IF;

--Case 2b

	IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'T'   then --Check for the manager flag

		OPEN C_Mgr_Check ;        --Assigning the manager flag
		FETCH C_Mgr_Check INTO l_data_exists ;
		IF C_Mgr_Check%FOUND THEN
			l_manager_flag := 'Y';
		ELSE
			l_manager_flag := 'N';
                aso_debug_pub.add('No Data Found for Cursor...C_Mgr_Check', 1, 'Y');
		END IF ;
		CLOSE C_Mgr_Check ;

		IF  l_manager_flag = 'Y' THEN       --New query for manager_flag = 'Y'
			aso_debug_pub.add('Before Opening the cursor...C_CUSTOMER_MANAGER', 1, 'Y');
			OPEN C_CUSTOMER_MANAGER;
			aso_debug_pub.add('Before Fetching the cursor...C_CUSTOMER_MANAGER', 1, 'Y');
			FETCH C_CUSTOMER_MANAGER INTO l_data_exists ;
			IF C_CUSTOMER_MANAGER%FOUND THEN

					IF P_FLAG = 'BILL' THEN

							IF ( p_header = 'Y' ) THEN
								x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

					END IF;

					IF P_FLAG = 'SHIP' THEN
							IF ( p_header = 'Y' ) THEN
								x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := p_cust_party_id;
							END IF;
					END IF;
			ELSE    --Assign Null
					IF P_FLAG = 'BILL' THEN

							IF ( p_header = 'Y' ) THEN
								x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := NULL ;
								FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
								FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_CUSTOMER', TRUE);
								FND_MSG_PUB.ADD;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := NULL;
							END IF;

					END IF;

					IF P_FLAG = 'SHIP' THEN
							IF ( p_header = 'Y' ) THEN
								x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := NULL;
								FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
								FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_CUSTOMER', TRUE);
								FND_MSG_PUB.ADD;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := NULL;
							END IF ;
					END IF ;
					aso_debug_pub.add('No Data Found for the cursor...C_CUSTOMER_MANAGER', 1, 'Y');
				END IF ;

			aso_debug_pub.add('Before Closing the cursor...C_CUSTOMER_MANAGER', 1, 'Y');
			CLOSE C_CUSTOMER_MANAGER;
			aso_debug_pub.add('After Closing the cursor...C_CUSTOMER_MANAGER', 1, 'Y');

		END IF;


		IF l_manager_flag = 'N' THEN      --New query for manager_flag = 'N'
			aso_debug_pub.add('Before Opening the cursor...C_CUSTOMER_NO_MANAGER', 1, 'Y');
			OPEN C_CUSTOMER_NO_MANAGER;
			aso_debug_pub.add('Before Fetching the cursor...C_CUSTOMER_NO_MANAGER', 1, 'Y');
			FETCH C_CUSTOMER_NO_MANAGER INTO l_data_exists ;
			IF C_CUSTOMER_NO_MANAGER%FOUND THEN
					IF P_FLAG = 'BILL' THEN

							IF ( p_header = 'Y' ) THEN
								x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

					END IF;

					IF P_FLAG = 'SHIP' THEN
							IF ( p_header = 'Y' ) THEN
								x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := p_cust_party_id;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := p_cust_party_id;
							END IF;
					END IF;
			ELSE    --Assign Null
					IF P_FLAG = 'BILL' THEN

							IF ( p_header = 'Y' ) THEN
								x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID := NULL ;
								FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
								FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_CUSTOMER', TRUE);
								FND_MSG_PUB.ADD;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID := NULL;
							END IF;

					END IF;

					IF P_FLAG = 'SHIP' THEN
							IF ( p_header = 'Y' ) THEN
								x_shipment_header_rec.SHIP_TO_CUST_PARTY_ID := NULL;
								FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
								FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_CUSTOMER', TRUE);
								FND_MSG_PUB.ADD;
							END IF;

							IF ( p_header = 'N' ) THEN
								x_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  := NULL;
							END IF ;
					END IF ;
					aso_debug_pub.add('No Data Found for the cursor...C_CUSTOMER_NO_MANAGER', 1, 'Y');
				END IF;
			aso_debug_pub.add('Before closing the cursor...C_CUSTOMER_NO_MANAGER', 1, 'Y');
			CLOSE C_CUSTOMER_NO_MANAGER;
			aso_debug_pub.add('After closing the cursor...C_CUSTOMER_NO_MANAGER', 1, 'Y');

		END IF;
	END if;
END IF;

END VALIDATE_BILL_SHIP_CUSTOMER;
--5):				Validate Bill Ship Account

PROCEDURE VALIDATE_BILL_SHIP_ACCOUNT(
					p_cust_acct_id		VARCHAR2,
					p_cust_party_id		VARCHAR2,
					p_resource_id		VARCHAR2,
					p_sold_to_cust_acct_id  VARCHAR2,
					p_flag			VARCHAR2,
					p_header		VARCHAR2
				    ) IS

--:QOTHDDET_MAIN.sold_to_cust_party_id -->p_quote_header_record.CUST_PARTY_ID
--QOTHDDET_MAIN.sold_to_cust_acct_id - > p_quote_header_rec.cust_account_id --> P_CUST_ACCT_ID
--p_flag is the parameter to differentiate between bill to and ship to
-- p_flag possible values : BILL or SHIP
-- p_header possible values : Y or N

Cursor C_Mgr_Check  Is   --to check the manager flag
select 1 from dual where exists
	(
	     SELECT  MGR.group_id
	     FROM    jtf_rs_rep_managers MGR ,
		     jtf_rs_group_usages U
	     WHERE   U.usage  = 'SALES'
	     AND     U.group_id = MGR.group_id
	     AND     trunc(MGR.start_date_active)  <= trunc(SYSDATE)
	     AND     trunc(NVL(MGR.end_date_active, SYSDATE)) >= trunc(SYSDATE)
	     AND     MGR.parent_resource_id = MGR.resource_id
	     AND     MGR.hierarchy_type in ('MGR_TO_MGR', 'MGR_TO_REP')
	     AND     MGR.parent_resource_id = p_resource_id
	);

CURSOR C_INVOICE_TO_CUST_ACCOUNT IS
--p_quote_header_rec.cust_account_id-->p_cust_acct_id
--SELECT 1 FROM DUAL WHERE EXISTS
--(
--	SELECT ca.account_number
--	FROM	HZ_PARTIES hp,
--		HZ_CUST_ACCOUNTS ca,
--		HZ_CUST_ACCT_RELATE car
--	WHERE	hp.party_id = ca.party_id
--	AND   ((car.related_cust_account_id =   p_sold_to_cust_acct_id
--		AND	car.cust_account_id = ca.cust_account_id
--		AND	car.relationship_type =  'ALL'
--		AND	car.bill_to_flag = 'Y')
--		OR	ca.cust_account_id =   p_sold_to_cust_acct_id )
--	AND	hp.party_id = p_cust_party_id
--	AND	ca.cust_account_id = p_cust_acct_id
--	AND	hp.party_type in ('PERSON','ORGANIZATION')
--	AND	hp.status =   'A'
--	AND	ca.status =   'A'
--	AND	trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
--	AND	trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate)
--	AND	car.status =   'A'
--) ;
SELECT 1 FROM DUAL WHERE EXISTS
(
	SELECT ca.account_number
	FROM	HZ_PARTIES hp,
		HZ_CUST_ACCOUNTS ca,
		HZ_CUST_ACCT_RELATE car
	WHERE	hp.party_id = ca.party_id
	AND	car.related_cust_account_id =   p_sold_to_cust_acct_id
		AND	car.cust_account_id = ca.cust_account_id
		AND	car.relationship_type =  'ALL'
		AND	car.ship_to_flag = 'Y'
	AND	hp.party_id = p_cust_party_id
	AND	ca.cust_account_id = p_cust_acct_id
	AND	hp.party_type in ('PERSON','ORGANIZATION')
	AND	hp.status =   'A'
	AND	ca.status =   'A'
	AND	trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
	AND	trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate)
	AND	car.status =   'A'
	UNION
	SELECT ca.account_number
	FROM	HZ_PARTIES hp,
		HZ_CUST_ACCOUNTS ca
	WHERE	hp.party_id = ca.party_id
	AND	ca.cust_account_id =   p_sold_to_cust_acct_id
	AND	hp.party_id = p_cust_party_id
	AND	ca.cust_account_id = p_cust_acct_id
	AND	hp.party_type in ('PERSON','ORGANIZATION')
	AND	hp.status =   'A'
	AND	ca.status =   'A'
	AND	trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
	AND	trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate)
);



CURSOR C_SHIP_TO_CUST_ACCOUNT IS
--p_quote_header_rec.cust_account_id-->p_cust_acct_id
--SELECT 1 FROM DUAL WHERE EXISTS
--(
--	SELECT ca.account_number
--	FROM	HZ_PARTIES hp,
--		HZ_CUST_ACCOUNTS ca,
--		HZ_CUST_ACCT_RELATE car
--	WHERE	hp.party_id = ca.party_id
--	AND	((car.related_cust_account_id =   p_sold_to_cust_acct_id
--		AND	car.cust_account_id = ca.cust_account_id
--		AND	car.relationship_type =  'ALL'
--		AND	car.ship_to_flag = 'Y')
--		OR	ca.cust_account_id =   p_sold_to_cust_acct_id )
--	AND	hp.party_id = p_cust_party_id
--	AND	ca.cust_account_id = p_cust_acct_id
--	AND	hp.party_type in ('PERSON','ORGANIZATION')
--	AND	hp.status =   'A'
--	AND	ca.status =   'A'
--	AND	trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
--	AND	trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate)
--	AND	car.status =   'A'
--) ;
SELECT ca.account_number
FROM	HZ_PARTIES hp,
	HZ_CUST_ACCOUNTS ca,
	HZ_CUST_ACCT_RELATE car
WHERE	hp.party_id = ca.party_id
AND	car.related_cust_account_id = p_sold_to_cust_acct_id
AND  	car.status = 'A'
AND  	ca.cust_account_id = car.cust_account_id
AND	car.relationship_type =  'ALL'
AND	car.ship_to_flag = 'Y'
AND	hp.party_id = p_cust_party_id
AND	ca.cust_account_id =  p_cust_acct_id
AND	hp.party_type in ('PERSON','ORGANIZATION')
AND	hp.status =   'A'
AND	ca.status =   'A'
UNION
SELECT ca.account_number
FROM	HZ_PARTIES hp,
	HZ_CUST_ACCOUNTS ca
WHERE	hp.party_id = ca.party_id
AND	ca.cust_account_id =   p_sold_to_cust_acct_id
AND	hp.party_id = p_cust_party_id
AND	ca.cust_account_id = p_cust_acct_id
AND	hp.party_type in ('PERSON','ORGANIZATION')
AND	hp.status =   'A'
AND	ca.status =   'A'
AND	trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
AND	trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate) ;


-- When ASO_ENFORCE_ACCOUNT_RELATIONSHIPS = 'N' and ASN_CUST_ACCESS = F
CURSOR C_CUST_ACCOUNT IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		SELECT ca.account_number
		FROM   HZ_PARTIES hp,
		       HZ_CUST_ACCOUNTS ca
		WHERE hp.party_id = ca.party_id
		AND hp.party_type in ('PERSON','ORGANIZATION')
		AND hp.status = 'A'
		AND ca.status = 'A'
		AND hp.party_id =  p_cust_party_id
		AND CA.CUST_ACCOUNT_ID = p_cust_acct_id
		AND trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
		AND trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate)
) ;

-- When ASO_ENFORCE_ACCOUNT_RELATIONSHIPS = 'N' and ASN_CUST_ACCESS = T and manager_flag = 'Y'

CURSOR C_CUST_ACCOUNT_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		select null
		from   HZ_PARTIES P
		      ,HZ_CUST_ACCOUNTS CA
		where	CA.status = 'A'
		AND   p.party_type in ('PERSON','ORGANIZATION')
		AND  P.party_id = p_cust_party_id
		AND	P.status = 'A'
		AND	P.party_id = CA.party_id
		AND	CA.CUST_ACCOUNT_ID = p_cust_acct_id
		AND	EXISTS ( SELECT null
				      FROM   as_accesses_all_all secu
				      WHERE  secu.customer_id = P.party_id
				      AND secu.lead_id IS NULL
				      AND secu.sales_lead_id IS NULL
				      AND secu.delete_flag is NULL
				      and  secu.sales_group_id in (
									SELECT  jrgd.group_id
									FROM    jtf_rs_groups_denorm jrgd,
										jtf_rs_group_usages  jrgu
									WHERE   jrgd.parent_group_id  IN (
												select	u.group_id
												from	jtf_rs_rep_managers mgr,
													jtf_rs_group_usages u
												where	mgr.parent_resource_id = p_resource_id
												and    trunc(sysdate) between trunc(mgr.start_date_active)
												and	trunc(nvl(mgr.end_date_active,sysdate))
												and     mgr.hierarchy_type = 'MGR_TO_REP'
												and     mgr.group_id = u.group_id
												and     u.usage in ('SALES','PRM')
													)
				     AND trunc(jrgd.start_date_active) <= TRUNC(SYSDATE)
				     AND trunc(NVL(jrgd.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
				     AND jrgu.group_id = jrgd.group_id
				     AND jrgu.usage  in ('SALES', 'PRM')))
					UNION ALL
					SELECT null
					FROM    as_accesses_all_all secu,
						HZ_PARTIES P
					WHERE  secu.customer_id = P.party_id
					AND  secu.lead_id IS NULL
					AND secu.sales_lead_id IS NULL
					AND secu.delete_flag is NULL
					AND salesforce_id = p_resource_id

) ;

-- When ASO_ENFORCE_ACCOUNT_RELATIONSHIPS = 'N' and ASN_CUST_ACCESS = T and manager_flag = 'N'

CURSOR C_CUST_ACCOUNT_NO_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(

	select CA.account_number
	from	HZ_PARTIES HP ,
		HZ_CUST_ACCOUNTS CA
	where	CA.status = 'A'
	AND  trunc(nvl(CA.account_activation_date, SYSDATE))  <= trunc(SYSDATE)
	AND	trunc(nvl(CA.account_termination_date, SYSDATE)) >= trunc(SYSDATE)
	AND	HP.status = 'A'
	AND	HP.party_id = CA.party_id
     AND  hp.party_type in ('PERSON','ORGANIZATION')
	AND	HP.party_id = p_cust_party_id
	AND  CA.cust_account_id = p_cust_acct_id
	AND	(exists  (SELECT null
				FROM   as_accesses_all secu
				WHERE secu.customer_id = hp.party_id
				AND secu.lead_id IS NULL
				AND secu.sales_lead_id IS NULL
				AND salesforce_id = p_resource_id
			  )
		)

);

l_data_exists varchar2(10);
l_manager_flag varchar2(1);

BEGIN

--Case:1 ==================================Enforced Account Relationship is set to 'Y'(Start)=========================================================
IF NVL(FND_PROFILE.value('ASO_ENFORCE_ACCOUNT_RELATIONSHIPS'),'N')  = 'Y'  then

		IF P_FLAG = 'BILL' THEN
			aso_debug_pub.add('Before opening the cursor...C_INVOICE_TO_CUST_ACCOUNT', 1, 'Y');
			OPEN C_INVOICE_TO_CUST_ACCOUNT;
			aso_debug_pub.add('Before Fetching the cursor...C_INVOICE_TO_CUST_ACCOUNT', 1, 'Y');
			FETCH C_INVOICE_TO_CUST_ACCOUNT INTO l_data_exists ;

			IF C_INVOICE_TO_CUST_ACCOUNT%FOUND THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.invoice_to_cust_account_id := p_cust_acct_id;
				END IF;
				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.invoice_to_cust_account_id := p_cust_acct_id;
				END IF;
			ELSE
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.invoice_to_cust_account_id := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ACCOUNT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;
				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.invoice_to_cust_account_id := NULL;
				END IF;
			aso_debug_pub.add('No Data found for the cursor...C_INVOICE_TO_CUST_ACCOUNT', 1, 'Y');
			END IF;
			aso_debug_pub.add('Before closing the cursor...C_INVOICE_TO_CUST_ACCOUNT', 1, 'Y');
			CLOSE C_INVOICE_TO_CUST_ACCOUNT;
			aso_debug_pub.add('After closing the cursor...C_INVOICE_TO_CUST_ACCOUNT', 1, 'Y');

		END IF;


		IF P_FLAG = 'SHIP' THEN
			aso_debug_pub.add('Before Opening the cursor...C_SHIP_TO_CUST_ACCOUNT', 1, 'Y');
			OPEN C_SHIP_TO_CUST_ACCOUNT;
			aso_debug_pub.add('Before Fetching the cursor...C_SHIP_TO_CUST_ACCOUNT', 1, 'Y');
			FETCH C_SHIP_TO_CUST_ACCOUNT INTO l_data_exists ;

				IF C_SHIP_TO_CUST_ACCOUNT%FOUND THEN
					IF ( p_header = 'Y' ) THEN
					      x_shipment_header_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;
					IF ( p_header = 'N' ) THEN
					      x_shipment_line_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;
				ELSE
					IF ( p_header = 'Y' ) THEN
					      x_shipment_header_rec.ship_to_cust_account_id := NULL;
					      FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					      FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ACCOUNT', TRUE);
					      FND_MSG_PUB.ADD;
					END IF;
					IF ( p_header = 'N' ) THEN
					      x_shipment_line_rec.ship_to_cust_account_id := NULL;
					END IF;
					aso_debug_pub.add('No Data Found for the cursor...C_SHIP_TO_CUST_ACCOUNT', 1, 'Y');
				END IF;
					aso_debug_pub.add('Before Closing the cursor...C_SHIP_TO_CUST_ACCOUNT', 1, 'Y');
			CLOSE C_SHIP_TO_CUST_ACCOUNT;
					aso_debug_pub.add('After Closing the cursor...C_SHIP_TO_CUST_ACCOUNT', 1, 'Y');


		END IF;
END IF;
--Case:2==================================Enforced Account Relationship is set to 'N' =========================================================

IF NVL(FND_PROFILE.value('ASO_ENFORCE_ACCOUNT_RELATIONSHIPS'),'N')  = 'N' THEN

--Case 2a
	IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'F' THEN --Put the base query
			aso_debug_pub.add('Before Opening the cursor...C_CUST_ACCOUNT', 1, 'Y');
			OPEN C_CUST_ACCOUNT;
			aso_debug_pub.add('Before Fetching the cursor...C_CUST_ACCOUNT', 1, 'Y');
			FETCH C_CUST_ACCOUNT INTO l_data_exists ;
				IF C_CUST_ACCOUNT%FOUND THEN
				  IF ( p_flag = 'BILL') THEN
					IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.invoice_to_cust_account_id := p_cust_acct_id;
					END IF;

					IF ( p_header = 'N' ) THEN
						x_quote_line_rec.invoice_to_cust_account_id := p_cust_acct_id;
					END IF;
				END IF;

				IF ( p_flag = 'SHIP') THEN
					IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;

					IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;
				END IF;

				ELSE
				IF ( p_flag = 'BILL') THEN
					IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.invoice_to_cust_account_id := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ACCOUNT', TRUE);
						FND_MSG_PUB.ADD;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_quote_line_rec.invoice_to_cust_account_id := NULL;
					END IF;
				END IF;
				IF ( p_flag = 'SHIP') THEN
					IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.ship_to_cust_account_id := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					        FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ACCOUNT', TRUE);
					        FND_MSG_PUB.ADD;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.ship_to_cust_account_id := NULL;
					END IF;
				END IF;
				aso_debug_pub.add('No Data Found for the cursor the cursor...C_CUST_ACCOUNT', 1, 'Y');
			END IF;
				aso_debug_pub.add('Before closing the cursor...C_CUST_ACCOUNT', 1, 'Y');
		CLOSE C_CUST_ACCOUNT;
				aso_debug_pub.add('After closing the cursor...C_CUST_ACCOUNT', 1, 'Y');

	END IF;

--Case 2b
	IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'T'   then --Check for the manager flag

		OPEN C_Mgr_Check ;                 --Assigning the manager flag
		FETCH C_Mgr_Check INTO l_data_exists ;

		IF C_Mgr_Check%FOUND THEN
			l_manager_flag := 'Y';
		ELSE
			l_manager_flag := 'N';
                aso_debug_pub.add('No Data Found for Cursor...C_Mgr_Check', 1, 'Y');
		END IF;

		CLOSE C_Mgr_Check;

		IF l_manager_flag = 'Y' THEN       --New query for manager_flag = 'Y'
			aso_debug_pub.add('Before opening the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			OPEN C_CUST_ACCOUNT_MANAGER;
			aso_debug_pub.add('Before fetching the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			FETCH C_CUST_ACCOUNT_MANAGER INTO l_data_exists ;
			IF C_CUST_ACCOUNT_MANAGER%FOUND THEN
				IF ( p_flag = 'BILL') THEN
					IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.invoice_to_cust_account_id := p_cust_acct_id;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_quote_line_rec.invoice_to_cust_account_id := p_cust_acct_id;
					END IF;
				END IF;

				IF ( p_flag = 'SHIP') THEN
					IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;
				END IF;
			ELSE
				IF ( p_flag = 'BILL') THEN
					IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.invoice_to_cust_account_id := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ACCOUNT', TRUE);
						FND_MSG_PUB.ADD;
		                        END IF;
					IF ( p_header = 'N' ) THEN
						x_quote_line_rec.invoice_to_cust_account_id := NULL;
					END IF;
				END IF;

				IF ( p_flag = 'SHIP') THEN
					IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.ship_to_cust_account_id := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					        FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ACCOUNT', TRUE);
					        FND_MSG_PUB.ADD;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.ship_to_cust_account_id := NULL;
					END IF;
				END IF;
				aso_debug_pub.add('No Data Found for the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');

			END IF;
			aso_debug_pub.add('Before closing the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			CLOSE C_CUST_ACCOUNT_MANAGER;
			aso_debug_pub.add('After closing the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');

		END IF;

		IF l_manager_flag = 'N' THEN      --New query for manager_flag = 'N'
			aso_debug_pub.add('Before opening the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			OPEN C_CUST_ACCOUNT_NO_MANAGER;
			aso_debug_pub.add('Before fetching the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			FETCH C_CUST_ACCOUNT_NO_MANAGER INTO l_data_exists ;
			IF C_CUST_ACCOUNT_NO_MANAGER%FOUND THEN
				IF ( p_flag = 'BILL') THEN
					IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.invoice_to_cust_account_id := p_cust_acct_id;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_quote_line_rec.invoice_to_cust_account_id := p_cust_acct_id;
					END IF;
				END IF;

				IF ( p_flag = 'SHIP') THEN
					IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;

					IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.ship_to_cust_account_id := p_cust_acct_id;
					END IF;
				END IF;
			ELSE
				IF ( p_flag = 'BILL') THEN
					IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.invoice_to_cust_account_id := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ACCOUNT', TRUE);
						FND_MSG_PUB.ADD;
					END IF;
					IF ( p_header = 'N' ) THEN
						x_quote_line_rec.invoice_to_cust_account_id := NULL;
					END IF;
				END IF;

				IF ( p_flag = 'SHIP') THEN
					IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.ship_to_cust_account_id := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					        FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ACCOUNT', TRUE);
					        FND_MSG_PUB.ADD;
					END IF;

					IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.ship_to_cust_account_id := NULL;
					END IF;
				END IF;
			aso_debug_pub.add('No Data Found for the  cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			END IF;
			aso_debug_pub.add('Before closing the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
			CLOSE C_CUST_ACCOUNT_NO_MANAGER;
			aso_debug_pub.add('After closing the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');


		END IF;
	END IF;
END IF;

END VALIDATE_BILL_SHIP_ACCOUNT ;


--6):				Validate Address
PROCEDURE VALIDATE_ADDRESS(	p_party_site_id VARCHAR2,
				p_party_id	VARCHAR2,
				p_cust_party_id VARCHAR2,
				p_flag		VARCHAR2,
				p_header	VARCHAR2
			 ) is

--parameters
--party id can be bill to ,ship to or end customer
--party_site_id is the party address
--hd_sold_to_cust_party_id --> l_quote_header_rec.cust_party_id --> p_cust_party_id
--hd_ship_to_party_id --> l_quote_header_rec.PARTY_ID --> P_PARTY_ID
--	p_flag possible values : BILL/SHIP/END/SOLD
--	p_header possible values : Y or N

l_data_exists VARCHAR2(10) ;

CURSOR C_PARTY_ADDRESS IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		 SELECT		site.party_site_id
		 FROM		HZ_PARTIES hp,
				HZ_PARTY_SITES site
		 WHERE		site.party_id = hp.party_id
		 AND		site.PARTY_SITE_ID = p_party_site_id         --Added join for party_site_id
		 AND		hp.status = 'A'
		 AND		site.status = 'A'
		 AND		hp.party_id in (p_party_id,p_cust_party_id)
);

--CURSOR C_PARTY_ADDRESS2 IS
CURSOR C_CUST_PARTY_ADDRESS_NOT_NULL IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		SELECT		site.party_site_id
		FROM		HZ_PARTIES hp,
				HZ_PARTY_SITES site
		WHERE		site.party_id = hp.party_id
		AND		site.PARTY_SITE_ID = p_party_site_id         --Added join for party_site_id
		AND		hp.status = 'A'
		AND		site.status = 'A'
		AND		hp.party_id  = p_cust_party_id
);

--CURSOR C_PARTY_ADDRESS3 IS
CURSOR C_CUSTOMER_ADDRESS_NOT_NULL IS
SELECT 1 FROM DUAL WHERE EXISTS
(

	       SELECT		site.party_site_id
		FROM		HZ_PARTIES hp,
				HZ_PARTY_SITES site
		WHERE		site.party_id = hp.party_id
		AND		site.PARTY_SITE_ID = p_party_site_id         --Added join for party_site_id
		AND		hp.status = 'A'
		AND		site.status = 'A'
		AND		hp.party_id  = p_party_id


);

BEGIN
 --Case 1 :  IF lv_cust_party_id is not null and lv_party_id is not null (p_cust_party_id and p_party_id)

IF p_party_id  IS NOT NULL AND p_cust_party_id IS NOT NULL THEN
	aso_debug_pub.add('Before opening the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
	OPEN C_PARTY_ADDRESS ;
	aso_debug_pub.add('Before fetching the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
	FETCH C_PARTY_ADDRESS INTO l_data_exists ;
	IF C_PARTY_ADDRESS%FOUND THEN
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
		--Case:2 SHIP
			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.SHIP_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.SHIP_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  := p_party_site_id;
				END IF;
			 END IF;
		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.SOLD_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
	ELSE       --Set all values to NULL
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ADDRESS', TRUE);
					FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID := NULL;
				END IF;
			 END IF;
		--Case:2 SHIP
			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.SHIP_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.SHIP_TO_PARTY_SITE_ID := NULL;
				END IF;
			 END IF;
		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  := NULL;
				END IF;
			 END IF;
		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.SOLD_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;
			 END IF;
	aso_debug_pub.add('No data found for the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
	END IF ;
	aso_debug_pub.add('Before closing the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');
	CLOSE C_PARTY_ADDRESS;
	aso_debug_pub.add('After closing the cursor...C_CUST_ACCOUNT_MANAGER', 1, 'Y');

END IF;

--Case 2 :  incase only customer is there(p_cust_party_id IS NOT NULL AND p_party_id IS NULL)

IF p_party_id  IS NULL AND p_cust_party_id IS  NOT NULL THEN
	aso_debug_pub.add('before opening the cursor...C_CUST_PARTY_ADDRESS_NOT_NULL', 1, 'Y');
	OPEN C_CUST_PARTY_ADDRESS_NOT_NULL ;
	aso_debug_pub.add('before fetching the cursor...C_CUST_PARTY_ADDRESS_NOT_NULL', 1, 'Y');
	FETCH C_CUST_PARTY_ADDRESS_NOT_NULL INTO l_data_exists ;

	IF C_CUST_PARTY_ADDRESS_NOT_NULL%FOUND THEN
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
		--Case:2 SHIP
			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.SHIP_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.SHIP_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  := p_party_site_id;
				END IF;
			 END IF;
		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.SOLD_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
	ELSE       --Set all values to NULL
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID := NULL;
				END IF;
			 END IF;
		--Case:2 SHIP
			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.SHIP_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.SHIP_TO_PARTY_SITE_ID := NULL;
				END IF;
			 END IF;
		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  := NULL;
				END IF;
			 END IF;
		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.SOLD_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;
			 END IF;
	aso_debug_pub.add('No Data Found for the cursor...C_CUST_PARTY_ADDRESS_NOT_NULL', 1, 'Y');
	END IF ;
	aso_debug_pub.add('Before closing the cursor...C_CUST_PARTY_ADDRESS_NOT_NULL', 1, 'Y');
	CLOSE C_CUST_PARTY_ADDRESS_NOT_NULL;
	aso_debug_pub.add('After closing the cursor...C_CUST_PARTY_ADDRESS_NOT_NULL', 1, 'Y');

END IF;

--Case 3 :  incase only customer is there(p_cust_party_id IS NULL AND p_party_id IS NOT NULL)

IF p_party_id  IS NOT NULL AND p_cust_party_id IS  NULL THEN
	aso_debug_pub.add('Before opening the cursor...C_CUSTOMER_ADDRESS_NOT_NULL', 1, 'Y');
	OPEN C_CUSTOMER_ADDRESS_NOT_NULL ;
	aso_debug_pub.add('Before fetching the cursor...C_CUSTOMER_ADDRESS_NOT_NULL', 1, 'Y');
	FETCH C_CUSTOMER_ADDRESS_NOT_NULL INTO l_data_exists ;

	IF C_CUSTOMER_ADDRESS_NOT_NULL%FOUND THEN
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
		--Case:2 SHIP
			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.SHIP_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.SHIP_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID := p_party_site_id;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  := p_party_site_id;
				END IF;
			 END IF;
		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.SOLD_TO_PARTY_SITE_ID := p_party_site_id;
				END IF;
			 END IF;
	ELSE       --Set all values to NULL
		--Case:1 BILL
			IF P_FLAG = 'BILL' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_BILL_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID := NULL;
				END IF;
			 END IF;
		--Case:2 SHIP
			IF P_FLAG = 'SHIP' THEN
				IF ( p_header = 'Y' ) THEN
						x_shipment_header_rec.SHIP_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHIP_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_shipment_line_rec.SHIP_TO_PARTY_SITE_ID := NULL;
				END IF;
			 END IF;
		--Case:3 END
			IF P_FLAG = 'END' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;

				IF ( p_header = 'N' ) THEN
						x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  := NULL;
				END IF;
			 END IF;
		--Case:4 SOLD
			IF P_FLAG = 'SOLD' THEN
				IF ( p_header = 'Y' ) THEN
						x_quote_header_rec.SOLD_TO_PARTY_SITE_ID := NULL;
						FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
						FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_ADDRESS', TRUE);
						FND_MSG_PUB.ADD;
				END IF;
			 END IF;
	aso_debug_pub.add('no data found for the cursor...C_CUSTOMER_ADDRESS_NOT_NULL', 1, 'Y');
	END IF ;
	aso_debug_pub.add('Before Closing the cursor...C_CUSTOMER_ADDRESS_NOT_NULL', 1, 'Y');
	CLOSE C_CUSTOMER_ADDRESS_NOT_NULL;
	aso_debug_pub.add('After Closing the cursor...C_CUSTOMER_ADDRESS_NOT_NULL', 1, 'Y');

END IF;

END VALIDATE_ADDRESS;

--7):				Validate Account


PROCEDURE VALIDATE_ACCOUNT
(	p_cust_acct_id	varchar2,
	p_cust_party_id	varchar2,
	p_resource_id	varchar2,
	p_flag		varchar2,
	p_header        varchar2
   ) IS

-- p_flag possible values : SOLD or END
-- p_header possible values : Y or N
-- Calling procedure should pass ASO_TCA_SOLD_TO_ACCOUNT(p_quote_header_rec.cust_party_id,P_quote_header_rec.RESOURCE_ID )
--:QOTHDDET_MAIN.sold_to_cust_party_id --> p_cust_party_id --> p_quote_header_rec.cust_party_id)
--:PARAMETER.user_resource_id-->p_resource_id-->p_quote_header_rec.resource_id


Cursor C_Mgr_Check  Is   --to check the manager flag
select 1 from dual where exists
	(
	     SELECT  MGR.group_id
	     FROM    jtf_rs_rep_managers MGR ,
		     jtf_rs_group_usages U
	     WHERE   U.usage  = 'SALES'
	     AND     U.group_id = MGR.group_id
	     AND     trunc(MGR.start_date_active)  <= trunc(SYSDATE)
	     AND     trunc(NVL(MGR.end_date_active, SYSDATE)) >= trunc(SYSDATE)
	     AND     MGR.parent_resource_id = MGR.resource_id
	     AND     MGR.hierarchy_type in ('MGR_TO_MGR', 'MGR_TO_REP')
	     AND     MGR.parent_resource_id = p_resource_id
	);


CURSOR C_SOLD_TO_ACCOUNT IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		SELECT ca.account_number
		FROM HZ_PARTIES HP,
		HZ_CUST_ACCOUNTS CA
		WHERE hp.party_id = ca.party_id
		AND hp.status = 'A'
		AND ca.status = 'A'
		AND trunc(nvl(ca.account_activation_date,sysdate)) <= trunc(sysdate)
		AND trunc(nvl(ca.account_termination_date,sysdate)) >= trunc(sysdate)
		AND HP.party_id = p_cust_party_id
		AND ca.cust_account_id = p_cust_acct_id
);

CURSOR C_SOLD_TO_ACCOUNT_NO_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(
		select ca.account_number
		from	  HZ_PARTIES P
			, HZ_CUST_ACCOUNTS CA
		where  CA.status = 'A'
		   AND trunc(nvl(CA.account_activation_date, SYSDATE))  <= trunc(SYSDATE)
		   AND trunc(nvl(CA.account_termination_date, SYSDATE)) >= trunc(SYSDATE)
		   AND P.status = 'A'
		   AND P.party_id = CA.party_id
		   AND (exists  (SELECT null
				     FROM   as_accesses_all secu
			      	WHERE secu.customer_id = p.party_id
				     AND secu.lead_id IS NULL
					AND secu.sales_lead_id IS NULL                                                                                                         AND salesforce_id = p_resource_id
				    ))
		  AND P.party_id = p_cust_party_id                --Added joins for cust_account_id
		  AND ca.cust_account_id = p_cust_acct_id         --and party id

);


CURSOR C_SOLD_TO_ACCOUNT_MANAGER IS
SELECT 1 FROM DUAL WHERE EXISTS
(

		select null
		from   HZ_PARTIES P
		      ,HZ_CUST_ACCOUNTS CA
		where	CA.status = 'A'
		AND	P.status = 'A'
		AND	P.party_id = CA.party_id
		AND	P.party_id = p_cust_party_id              --Added joins for cust_acct_id and
		AND	ca.cust_account_id = p_cust_acct_id       --party id
		AND	EXISTS ( SELECT null
				      FROM   as_accesses_all_all secu
				      WHERE  secu.customer_id = P.party_id
				      AND    secu.lead_id IS NULL
				      AND   secu.sales_lead_id IS NULL
				      AND    secu.delete_flag is NULL
				      AND    secu.sales_group_id in (
									SELECT  jrgd.group_id
									FROM    jtf_rs_groups_denorm jrgd,
										jtf_rs_group_usages  jrgu
									WHERE   jrgd.parent_group_id  IN (
													select	U.group_id
													from	jtf_rs_rep_managers mgr,
														jtf_rs_group_usages u
													where	mgr.parent_resource_id = p_resource_id
													and     trunc(sysdate) between trunc(mgr.start_date_active) and trunc(nvl(mgr.end_date_active,sysdate))
													and     mgr.hierarchy_type = 'MGR_TO_REP'
													and     mgr.group_id = u.group_id
													and     u.usage in ('SALES','PRM')
													)
					    AND trunc(jrgd.start_date_active) <= TRUNC(SYSDATE)
					    AND trunc(NVL(jrgd.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
					    AND jrgu.group_id = jrgd.group_id
					    AND jrgu.usage  in ('SALES', 'PRM')) )
                         UNION ALL
					SELECT null
					FROM   as_accesses_all_all secu,HZ_PARTIES P
					WHERE  secu.customer_id = P.party_id
					AND    secu.lead_id IS NULL
					AND    secu.sales_lead_id IS NULL
					AND    secu.delete_flag is NULL
					AND    salesforce_id = p_resource_id  --Added new join for salesforceid

);

l_data_exists varchar2(10);
l_manager_flag varchar2(1) ;

BEGIN
--case:1 When sold-to or End Customer customer is specified

IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'F' AND p_cust_party_id  is not null THEN
	aso_debug_pub.add('Before opeing the cursor...C_SOLD_TO_ACCOUNT', 1, 'Y');
	OPEN C_SOLD_TO_ACCOUNT;
	FETCH C_SOLD_TO_ACCOUNT INTO l_data_exists ;

	IF C_SOLD_TO_ACCOUNT%FOUND THEN
       IF ( p_flag = 'SOLD' ) THEN
	     IF ( p_header = 'Y' ) THEN
		  x_quote_header_rec.CUST_ACCOUNT_ID := p_cust_acct_id;
          END IF;
       END IF;
       IF ( p_flag = 'END' ) THEN
	     IF ( p_header = 'Y' ) THEN
		   x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_cust_acct_id;
          END IF;
	     IF ( p_header = 'N' ) THEN
		   x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_cust_acct_id;
          END IF;
       END IF;
	ELSE
       IF ( p_flag = 'SOLD' ) THEN
	     IF ( p_header = 'Y' ) THEN
		  x_quote_header_rec.CUST_ACCOUNT_ID := NULL;
		  FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
  		  FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_ACCOUNT', TRUE);
		  FND_MSG_PUB.ADD;
          END IF;
       END IF;
       IF ( p_flag = 'END' ) THEN
	     IF ( p_header = 'Y' ) THEN
		   x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := NULL;
		   FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
		   FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_ACCOUNT', TRUE);
		   FND_MSG_PUB.ADD;
          END IF;
	     IF ( p_header = 'N' ) THEN
		   x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := NULL;
          END IF;
       END IF;
      	aso_debug_pub.add('No Data Found for the cursor...C_SOLD_TO_ACCOUNT', 1, 'Y');
	END IF;
      	aso_debug_pub.add('Before Closing the cursor...C_SOLD_TO_ACCOUNT', 1, 'Y');
	CLOSE C_SOLD_TO_ACCOUNT;
      	aso_debug_pub.add('After Closing the cursor...C_SOLD_TO_ACCOUNT', 1, 'Y');

 END IF;

--Case:2 When ASN:Customer Access Privilege is set to Sales Team and resource_id is not null

IF NVL(FND_PROFILE.VALUE('ASN_CUST_ACCESS'),'T') = 'T' AND p_resource_id IS NOT NULL THEN


	OPEN C_Mgr_Check;        --Checking the manager flag
	FETCH C_Mgr_Check INTO l_data_exists ;

	IF C_Mgr_Check%FOUND THEN
		l_manager_flag := 'Y';
	ELSE
		l_manager_flag := 'N';
                aso_debug_pub.add('No Data Found for Cursor...C_Mgr_Check', 1, 'Y');
	END IF;
     CLOSE C_Mgr_Check;


	IF  l_manager_flag = 'N' THEN                 --New Query
      		aso_debug_pub.add('Before opening the cursor...C_SOLD_TO_ACCOUNT_NO_MANAGER', 1, 'Y');
		OPEN C_SOLD_TO_ACCOUNT_NO_MANAGER;
      		aso_debug_pub.add('Before fetching the cursor...C_SOLD_TO_ACCOUNT_NO_MANAGER', 1, 'Y');

		FETCH C_SOLD_TO_ACCOUNT_NO_MANAGER INTO l_data_exists ;

		IF C_SOLD_TO_ACCOUNT_NO_MANAGER%FOUND THEN
             IF ( p_flag = 'SOLD' ) THEN
	           IF ( p_header = 'Y' ) THEN
		        x_quote_header_rec.CUST_ACCOUNT_ID := p_cust_acct_id;
                END IF;
             END IF;
             IF ( p_flag = 'END' ) THEN
	           IF ( p_header = 'Y' ) THEN
		         x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_cust_acct_id;
                END IF;
	           IF ( p_header = 'N' ) THEN
		         x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_cust_acct_id;
                END IF;
             END IF;
		ELSE
             IF ( p_flag = 'SOLD' ) THEN
	           IF ( p_header = 'Y' ) THEN
		        x_quote_header_rec.CUST_ACCOUNT_ID := NULL;
			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_ACCOUNT', TRUE);
			FND_MSG_PUB.ADD;
                END IF;
             END IF;
             IF ( p_flag = 'END' ) THEN
	                 IF ( p_header = 'Y' ) THEN
		         x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := NULL;
			 FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			 FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_ACCOUNT', TRUE);
			 FND_MSG_PUB.ADD;
                END IF;
	           IF ( p_header = 'N' ) THEN
		         x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := NULL;
                END IF;
             END IF;
    		aso_debug_pub.add('No data found for the cursor...C_SOLD_TO_ACCOUNT_NO_MANAGER', 1, 'Y');
		END IF;
		aso_debug_pub.add('Before closing the cursor...C_SOLD_TO_ACCOUNT_NO_MANAGER', 1, 'Y');
		CLOSE C_SOLD_TO_ACCOUNT_NO_MANAGER;
	END IF;


	IF  l_manager_flag = 'Y' THEN                 --New Query
     		aso_debug_pub.add('Before opeing the cursor...C_SOLD_TO_ACCOUNT_MANAGER', 1, 'Y');

		OPEN C_SOLD_TO_ACCOUNT_MANAGER;
     		aso_debug_pub.add('Before Fetching the cursor...C_SOLD_TO_ACCOUNT_MANAGER', 1, 'Y');

		FETCH C_SOLD_TO_ACCOUNT_MANAGER INTO l_data_exists ;

		IF C_SOLD_TO_ACCOUNT_MANAGER%FOUND THEN
			IF ( p_flag = 'SOLD' ) THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.CUST_ACCOUNT_ID := p_cust_acct_id;
				END IF;
			END IF;
			IF ( p_flag = 'END' ) THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_cust_acct_id;
				END IF;
				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_cust_acct_id;
				END IF;
			END IF;
		ELSE
			IF ( p_flag = 'SOLD' ) THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.CUST_ACCOUNT_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_QUOTE_ACCOUNT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;
			END IF;
			IF ( p_flag = 'END' ) THEN
				IF ( p_header = 'Y' ) THEN
					x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := NULL;
					FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
					FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_END_ACCOUNT', TRUE);
					FND_MSG_PUB.ADD;
				END IF;
				IF ( p_header = 'N' ) THEN
					x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := NULL;
				END IF;
			END IF;
     		aso_debug_pub.add('No Data Found for the cursor...C_SOLD_TO_ACCOUNT_MANAGER', 1, 'Y');
		END IF;
     		aso_debug_pub.add('Before Closing the cursor...C_SOLD_TO_ACCOUNT_MANAGER', 1, 'Y');
		CLOSE C_SOLD_TO_ACCOUNT_MANAGER;
      		aso_debug_pub.add('After Closing the cursor...C_SOLD_TO_ACCOUNT_MANAGER', 1, 'Y');

	END IF ;
  END IF;
END VALIDATE_ACCOUNT;

---                                 TCA  Routines  End                             --------------------------------
PROCEDURE PRINT_DEFAULTING_ATTRIBUTES(p_begin_flag VARCHAR2)  IS

BEGIN
--Header and Line Attributes that are not validated by the ASO_VALIDATE_PROCEDURE
	X_SHIPMENT_HEADER_REC.FREIGHT_TERMS_CODE := P_SHIPMENT_HEADER_REC.FREIGHT_TERMS_CODE ;
	X_QUOTE_HEADER_REC.RESOURCE_GRP_ID:=P_QUOTE_HEADER_REC.RESOURCE_GRP_ID ;
	X_QUOTE_HEADER_REC.RESOURCE_ID := P_QUOTE_HEADER_REC.RESOURCE_ID ;
	X_SHIPMENT_HEADER_REC.PACKING_INSTRUCTIONS := P_SHIPMENT_HEADER_REC.PACKING_INSTRUCTIONS ;
	X_SHIPMENT_LINE_REC.PACKING_INSTRUCTIONS := P_SHIPMENT_LINE_REC.PACKING_INSTRUCTIONS ;
	X_SHIPMENT_HEADER_REC.SHIPPING_INSTRUCTIONS := P_SHIPMENT_HEADER_REC.SHIPPING_INSTRUCTIONS ;
	X_SHIPMENT_LINE_REC.SHIPPING_INSTRUCTIONS := P_SHIPMENT_LINE_REC.SHIPPING_INSTRUCTIONS ;
	X_QUOTE_HEADER_REC.QUOTE_EXPIRATION_DATE := p_QUOTE_HEADER_REC.QUOTE_EXPIRATION_DATE ;
	X_QUOTE_HEADER_REC.PRICE_LIST_ID := P_QUOTE_HEADER_REC.PRICE_LIST_ID ;
	X_QUOTE_LINE_REC.PRICE_LIST_ID := P_QUOTE_LINE_REC.PRICE_LIST_ID ;
	x_QUOTE_HEADER_REC.ORDER_TYPE_ID := p_QUOTE_HEADER_REC.ORDER_TYPE_ID;
	x_QUOTE_HEADER_REC.CONTRACT_TEMPLATE_ID := P_QUOTE_HEADER_REC.CONTRACT_TEMPLATE_ID ;
	x_PAYMENT_HEADER_REC.PAYMENT_TERM_ID := P_PAYMENT_HEADER_REC.PAYMENT_TERM_ID ;
	x_PAYMENT_LINE_REC.PAYMENT_TERM_ID := P_PAYMENT_LINE_REC.PAYMENT_TERM_ID ;
	x_SHIPMENT_HEADER_REC.SHIP_METHOD_CODE := P_SHIPMENT_HEADER_REC.SHIP_METHOD_CODE ;
	x_SHIPMENT_LINE_REC.SHIP_METHOD_CODE := P_SHIPMENT_LINE_REC.SHIP_METHOD_CODE ;
	x_quote_line_rec.ORDER_LINE_TYPE_ID := p_quote_line_rec.ORDER_LINE_TYPE_ID;
	x_PAYMENT_HEADER_REC.CUST_PO_NUMBER := P_PAYMENT_HEADER_REC.CUST_PO_NUMBER;
	x_PAYMENT_LINE_REC.CUST_PO_NUMBER := P_PAYMENT_LINE_REC.CUST_PO_NUMBER ;
	x_quote_header_rec.CREATED_BY := p_quote_header_rec.CREATED_BY ;
	x_quote_line_rec.CREATED_BY := p_quote_line_rec.CREATED_BY ;
	x_QUOTE_HEADER_REC.QUOTE_NAME := p_QUOTE_HEADER_REC.QUOTE_NAME ;
	x_QUOTE_HEADER_REC.QUOTE_STATUS_ID := p_QUOTE_HEADER_REC.QUOTE_STATUS_ID ;
--                                 END                                   --------


IF p_begin_flag  = 'Y'  THEN

		aso_debug_pub.add('***************************************************************', 1, 'Y');
                aso_debug_pub.add('ASO_VALIDATE_PVT: Begin PRINT_DEFAULTING_ATTRIBUTES Procedure..');
		aso_debug_pub.add('***************************************************************', 1, 'Y');
	IF p_def_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN  --Print header attributes only'

		aso_debug_pub.add('**		Header Attributes Start		**', 1, 'Y');
--Header Attributes (Input)
		aso_debug_pub.add('1.	Value of P_QUOTE_HEADER_REC.PRICE_LIST_ID:		'||p_quote_header_rec.PRICE_LIST_ID, 1,'Y');
		aso_debug_pub.add('2.	Value of P_QUOTE_HEADER_REC.CURRENCY_CODE:		'||p_quote_header_rec.CURRENCY_CODE, 1,'Y');
		aso_debug_pub.add('3.	Value of P_QUOTE_HEADER_REC.SALES_CHANNEL_CODE:		'||p_quote_header_rec.SALES_CHANNEL_CODE, 1,'Y');
		aso_debug_pub.add('4.	Value of P_QUOTE_HEADER_REC.AUTOMATIC_PRICE_FLAG:	'||p_quote_header_rec.AUTOMATIC_PRICE_FLAG, 1,'Y');
		aso_debug_pub.add('5.	Value of P_QUOTE_HEADER_REC.AUTOMATIC_TAX_FLAG:		'||p_quote_header_rec.AUTOMATIC_TAX_FLAG, 1,'Y');
		aso_debug_pub.add('6.	Value of P_QUOTE_HEADER_REC.PHONE_ID:			'||p_quote_header_rec.phone_id, 1,'Y');

		aso_debug_pub.add('7.	Value of P_QUOTE_HEADER_REC.CUST_PARTY_ID:		'||p_quote_header_rec.cust_party_id, 1,'Y');
		aso_debug_pub.add('8.	Value of P_QUOTE_HEADER_REC.CUST_ACCOUNT_ID:		'||p_quote_header_rec.CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('9.	Value of P_QUOTE_HEADER_REC.PARTY_ID:			'||p_quote_header_rec.party_id, 1,'Y');
		aso_debug_pub.add('10.	Value of P_QUOTE_HEADER_REC.SOLD_TO_PARTY_SITE_ID:	'||p_quote_header_rec.SOLD_TO_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('11.	Value of P_QUOTE_HEADER_REC.INVOICE_TO_CUST_PARTY_ID:	'||p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('12.	Value of P_QUOTE_HEADER_REC.INVOICE_TO_CUST_ACCOUNT_ID:'||p_quote_header_rec.INVOICE_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('13.	Value of P_QUOTE_HEADER_REC.INVOICE_TO_PARTY_ID:	'||p_quote_header_rec.INVOICE_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('14.	Value of P_QUOTE_HEADER_REC.INVOICE_TO_PARTY_SITE_ID:	'||p_quote_header_rec.INVOICE_TO_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('15.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE_CATEGORY:		'|| p_quote_header_rec.ATTRIBUTE_CATEGORY,1,'Y');
		aso_debug_pub.add('16.	Value of P_QUOTE_HEADER_REC.CONTRACT_ID:		'|| p_quote_header_rec.CONTRACT_ID,1,'Y');
		aso_debug_pub.add('17.	Value of P_QUOTE_HEADER_REC.CONTRACT_TEMPLATE_ID:	'|| p_quote_header_rec.CONTRACT_TEMPLATE_ID,1,'Y');
		aso_debug_pub.add('18.	Value of P_QUOTE_HEADER_REC.CREATED_BY:			'|| p_quote_header_rec.CREATED_BY,1,'Y');
		aso_debug_pub.add('19.	Value of P_QUOTE_HEADER_REC.LAST_UPDATE_DATE:		'|| p_quote_header_rec.LAST_UPDATE_DATE,1,'Y');
		aso_debug_pub.add('20.	Value of P_QUOTE_HEADER_REC.MARKETING_SOURCE_CODE_ID:	'|| p_quote_header_rec.MARKETING_SOURCE_CODE_ID,1,'Y');
		aso_debug_pub.add('21.	Value of P_QUOTE_HEADER_REC.OBJECT_VERSION_NUMBER:	'|| p_quote_header_rec.OBJECT_VERSION_NUMBER,1,'Y');
		aso_debug_pub.add('22.	Value of P_QUOTE_HEADER_REC.ORDER_TYPE_ID:		'|| p_quote_header_rec.ORDER_TYPE_ID,1,'Y');
		aso_debug_pub.add('23.	Value of P_QUOTE_HEADER_REC.PHONE_ID:			'|| p_quote_header_rec.PHONE_ID,1,'Y');
		aso_debug_pub.add('24.	Value of P_QUOTE_HEADER_REC.PRICE_FROZEN_DATE:		'|| p_quote_header_rec.PRICE_FROZEN_DATE,1,'Y');
		aso_debug_pub.add('25.	Value of P_QUOTE_HEADER_REC.QUOTE_EXPIRATION_DATE:	'|| p_quote_header_rec.QUOTE_EXPIRATION_DATE,1,'Y');
		aso_debug_pub.add('26.	Value of P_QUOTE_HEADER_REC.QUOTE_HEADER_ID:		'|| p_quote_header_rec.QUOTE_HEADER_ID,1,'Y');
		aso_debug_pub.add('27.	Value of P_QUOTE_HEADER_REC.QUOTE_NAME:			'|| p_quote_header_rec.QUOTE_NAME,1,'Y');
		aso_debug_pub.add('28.	Value of P_QUOTE_HEADER_REC.QUOTE_STATUS_ID:		'|| p_quote_header_rec.QUOTE_STATUS_ID,1,'Y');
		aso_debug_pub.add('29.	Value of P_QUOTE_HEADER_REC.RESOURCE_GRP_ID:		'|| p_quote_header_rec.RESOURCE_GRP_ID,1,'Y');
		aso_debug_pub.add('30.	Value of P_QUOTE_HEADER_REC.RESOURCE_ID:		'|| p_quote_header_rec.RESOURCE_ID,1,'Y');
		aso_debug_pub.add('31.	Value of P_QUOTE_HEADER_REC.RESOURCE_ID:		'||p_quote_header_rec.resource_id, 1,'Y');

		aso_debug_pub.add('32.	Value of P_SHIPMENT_HEADER_REC.SHIP_TO_CUST_PARTY_ID:	'||p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('33.	Value of P_SHIPMENT_HEADER_REC.SHIP_TO_CUST_ACCOUNT_ID:'||p_shipment_header_rec.SHIP_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('34.	Value of P_SHIPMENT_HEADER_REC.SHIP_TO_PARTY_ID:	'||p_shipment_header_rec.SHIP_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('35.	Value of P_SHIPMENT_HEADER_REC.SHIP_TO_PARTY_SITE_ID:	'||p_shipment_header_rec.SHIP_TO_PARTY_SITE_ID, 1,'Y');
		aso_debug_pub.add('36.	Value of P_SHIPMENT_HEADER_REC.REQUEST_DATE_TYPE: 	'||p_Shipment_header_rec.REQUEST_DATE_TYPE, 1,'Y');
		aso_debug_pub.add('37.	Value of P_SHIPMENT_HEADER_REC.REQUEST_DATE:		'||P_Shipment_header_rec.REQUEST_DATE, 1,'Y');
		aso_debug_pub.add('38.	Value of P_SHIPMENT_HEADER_REC.SHIPMENT_PRIORITY_CODE:	'||P_Shipment_header_rec.SHIPMENT_PRIORITY_CODE, 1,'Y');
		aso_debug_pub.add('39.	Value of P_SHIPMENT_HEADER_REC.FOB_CODE:		'||P_Shipment_header_rec.FOB_CODE, 1,'Y');
		aso_debug_pub.add('40.	Value of P_SHIPMENT_HEADER_REC.DEMAND_CLASS_CODE:	'||P_Shipment_header_rec.DEMAND_CLASS_CODE, 1,'Y');
		aso_debug_pub.add('41.	Value of P_SHIPMENT_HEADER_REC.SHIPPING_INSTRUCTIONS:	'|| P_SHIPMENT_HEADER_REC.SHIPPING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('42.	Value of P_SHIPMENT_HEADER_REC.PACKING_INSTRUCTIONS:	'|| p_shipment_header_rec.PACKING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('43.	Value of P_SHIPMENT_HEADER_REC.SHIP_METHOD_CODE:	'|| P_SHIPMENT_HEADER_REC.SHIP_METHOD_CODE,1,'Y');
		aso_debug_pub.add('44.	Value of P_SHIPMENT_HEADER_REC.FREIGHT_TERMS_CODE:	'|| P_SHIPMENT_HEADER_REC.FREIGHT_TERMS_CODE,1,'Y');

		aso_debug_pub.add('45.	Value of P_PAYMENT_HEADER_REC.PAYMENT_TYPE_CODE:	'||P_Payment_header_rec.PAYMENT_TYPE_CODE, 1,'Y');
		aso_debug_pub.add('46.	Value of P_PAYMENT_HEADER_REC.CREDIT_CARD_CODE:		'||P_Payment_header_rec.CREDIT_CARD_CODE, 1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('47.  Value of P_PAYMENT_HEADER_REC.CREDIT_CARD_EXPIRATION_DATE  :'|| P_PAYMENT_HEADER_REC.CREDIT_CARD_EXPIRATION_DATE,1,'Y');
		aso_debug_pub.add('48.  Value of P_PAYMENT_HEADER_REC.CREDIT_CARD_HOLDER_NAME     :	'|| P_PAYMENT_HEADER_REC.CREDIT_CARD_HOLDER_NAME,1,'Y');
                Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('49.	Value of P_PAYMENT_HEADER_REC.CUST_PO_NUMBER:		'|| p_payment_header_rec.CUST_PO_NUMBER,1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('50.  Value of P_PAYMENT_HEADER_REC.PAYMENT_REF_NUMBER:	'|| P_PAYMENT_HEADER_REC.PAYMENT_REF_NUMBER,1,'Y');
		Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('51.	Value of P_PAYMENT_HEADER_REC.PAYMENT_TERM_ID:		'|| P_PAYMENT_HEADER_REC.PAYMENT_TERM_ID,1,'Y');

		aso_debug_pub.add('52.	Value of P_QUOTE_HEADER_REC.END_CUSTOMER_CUST_PARTY_ID:	'||p_quote_header_rec.end_customer_cust_party_id, 1,'Y');
		aso_debug_pub.add('53.	Value of P_QUOTE_HEADER_REC.END_CUSTOMER_CUST_ACCOUNT_ID:'||p_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('54.	Value of P_QUOTE_HEADER_REC.END_CUSTOMER_PARTY_ID:	'||p_quote_header_rec.END_CUSTOMER_PARTY_ID, 1,'Y');
		aso_debug_pub.add('55.	Value of P_QUOTE_HEADER_REC.END_CUSTOMER_PARTY_SITE_ID:	'||p_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('56.	Value of P_QUOTE_HEADER_REC.ORG_ID:			'||p_quote_header_rec.ORG_ID, 1,'Y');
		aso_debug_pub.add('57.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE1:			'|| p_quote_header_rec.ATTRIBUTE1,1,'Y');
		aso_debug_pub.add('58.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE10:		'|| p_quote_header_rec.ATTRIBUTE10,1,'Y');
		aso_debug_pub.add('59.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE11:		'|| p_quote_header_rec.ATTRIBUTE11,1,'Y');
		aso_debug_pub.add('60.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE12:		'|| p_quote_header_rec.ATTRIBUTE12,1,'Y');
		aso_debug_pub.add('61.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE13:		'|| p_quote_header_rec.ATTRIBUTE13,1,'Y');
		aso_debug_pub.add('62.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE14:		'|| p_quote_header_rec.ATTRIBUTE14,1,'Y');
		aso_debug_pub.add('63.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE15:		'|| p_quote_header_rec.ATTRIBUTE15,1,'Y');
		aso_debug_pub.add('64.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE16:		'|| p_quote_header_rec.ATTRIBUTE16,1,'Y');
		aso_debug_pub.add('65.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE17:		'|| p_quote_header_rec.ATTRIBUTE17,1,'Y');
		aso_debug_pub.add('66.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE18:		'|| p_quote_header_rec.ATTRIBUTE18,1,'Y');
		aso_debug_pub.add('67.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE19:		'|| p_quote_header_rec.ATTRIBUTE19,1,'Y');
		aso_debug_pub.add('68.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE2:			'|| p_quote_header_rec.ATTRIBUTE2,1,'Y');
		aso_debug_pub.add('69.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE20:		'|| p_quote_header_rec.ATTRIBUTE20,1,'Y');
		aso_debug_pub.add('70.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE3:			'|| p_quote_header_rec.ATTRIBUTE3,1,'Y');
		aso_debug_pub.add('71.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE4:			'|| p_quote_header_rec.ATTRIBUTE4,1,'Y');
		aso_debug_pub.add('72.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE5:			'|| p_quote_header_rec.ATTRIBUTE5,1,'Y');
		aso_debug_pub.add('73.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE6:			'|| p_quote_header_rec.ATTRIBUTE6,1,'Y');
		aso_debug_pub.add('74.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE7:			'|| p_quote_header_rec.ATTRIBUTE7,1,'Y');
		aso_debug_pub.add('75.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE8:			'|| p_quote_header_rec.ATTRIBUTE8,1,'Y');
		aso_debug_pub.add('76.	Value of P_QUOTE_HEADER_REC.ATTRIBUTE9:			'|| p_quote_header_rec.ATTRIBUTE9,1,'Y');
		aso_debug_pub.add('**		Header Attributes End		**', 1, 'Y');

	ELSIF p_def_object_name = 'ASO_AK_QUOTE_LINE_V'    THEN --Print Line Attribues Only

--Line Attributes (Input)
		aso_debug_pub.add('**		Line Attributes Start		**', 1, 'Y');

		aso_debug_pub.add('78.	Value of P_QUOTE_LINE_REC.CHARGE_PERIODICITY_CODE:	'||p_quote_line_rec.CHARGE_PERIODICITY_CODE,1,'Y');
		aso_debug_pub.add('79.	Value of P_QUOTE_LINE_REC.PRICE_LIST_ID:		'||p_quote_line_rec.PRICE_LIST_ID, 1,'Y');

		aso_debug_pub.add('80.	Value of P_QUOTE_LINE_REC.INVOICE_TO_CUST_PARTY_ID:	'||p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('81.	Value of P_QUOTE_LINE_REC.INVOICE_TO_CUST_ACCOUNT_ID:	'||p_quote_line_rec.INVOICE_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('82.	Value of P_QUOTE_LINE_REC.INVOICE_TO_PARTY_ID		'||p_quote_Line_rec.INVOICE_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('83.	Value of P_QUOTE_LINE_REC.INVOICE_TO_PARTY_SITE_ID:	'||p_quote_line_rec.INVOICE_TO_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('84.	Value of P_QUOTE_LINE_REC.END_CUSTOMER_CUST_PARTY_ID:	'||p_quote_line_rec.end_customer_cust_party_id, 1,'Y');
		aso_debug_pub.add('85.	Value of P_QUOTE_LINE_REC.END_CUSTOMER_CUST_ACCOUNT_ID:	'||p_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('86.	Value of P_QUOTE_LINE_REC.END_CUSTOMER_PARTY_ID:	'||p_quote_Line_rec.END_CUSTOMER_PARTY_ID, 1,'Y');
		aso_debug_pub.add('87.	Value of P_QUOTE_LINE_REC.END_CUSTOMER_PARTY_SITE_ID:	'||p_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('88.	Value of P_PAYMENT_LINE_REC.PAYMENT_TYPE_CODE:		'||P_Payment_line_rec.PAYMENT_TYPE_CODE, 1,'Y');
		aso_debug_pub.add('89.	Value of P_PAYMENT_LINE_REC.CREDIT_CARD_CODE:		'||P_Payment_line_rec.CREDIT_CARD_CODE, 1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('90.  Value of p_payment_line_rec.CREDIT_CARD_EXPIRATION_DATE:'|| p_payment_line_rec.CREDIT_CARD_EXPIRATION_DATE,1,'Y');
		aso_debug_pub.add('91.	Value of p_payment_line_rec.CREDIT_CARD_HOLDER_NAME:	'|| p_payment_line_rec.CREDIT_CARD_HOLDER_NAME,1,'Y');
                Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('92.	Value of p_payment_line_rec.CUST_PO_LINE_NUMBER:	'|| p_payment_line_rec.CUST_PO_LINE_NUMBER,1,'Y');
		aso_debug_pub.add('93.	Value of p_payment_line_rec.CUST_PO_NUMBER:		'|| p_payment_line_rec.CUST_PO_NUMBER,1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('94. Value of p_payment_line_rec.PAYMENT_REF_NUMBER:	'|| p_payment_line_rec.PAYMENT_REF_NUMBER,1,'Y');
                Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('95.	Value of p_payment_line_rec.PAYMENT_TERM_ID:		'|| p_payment_line_rec.PAYMENT_TERM_ID,1,'Y');


		aso_debug_pub.add('96.	Value of P_SHIPMENT_LINE_REC.SHIP_TO_CUST_PARTY_ID:	'||p_shipment_line_rec.SHIP_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('97.	Value of P_SHIPMENT_LINE_REC.SHIP_TO_CUST_ACCOUNT_ID:	'||p_shipment_line_rec.SHIP_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('98.	Value of P_SHIPMENT_LINE_REC.SHIP_TO_PARTY_ID:		'||p_shipment_Line_rec.SHIP_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('99.	Value of P_SHIPMENT_LINE_REC.SHIP_TO_PARTY_SITE_ID:	'||p_shipment_line_rec.SHIP_TO_PARTY_SITE_ID, 1,'Y');
		aso_debug_pub.add('100.	Value of p_shipment_line_rec.ATTRIBUTE_CATEGORY:	'|| p_shipment_line_rec.ATTRIBUTE_CATEGORY,1,'Y');
		aso_debug_pub.add('101.	Value of p_shipment_line_rec.FREIGHT_TERMS_CODE:	'|| p_shipment_line_rec.FREIGHT_TERMS_CODE,1,'Y');
		aso_debug_pub.add('102.	Value of p_shipment_line_rec.SHIP_FROM_ORG_ID:		'|| p_shipment_line_rec.SHIP_FROM_ORG_ID,1,'Y');
		aso_debug_pub.add('103.	Value of p_shipment_line_rec.PACKING_INSTRUCTIONS:	'|| p_shipment_line_rec.PACKING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('104.	Value of p_shipment_line_rec.SHIPPING_INSTRUCTIONS:	'|| p_shipment_line_rec.SHIPPING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('105.	Value of p_shipment_line_rec.SHIP_METHOD_CODE:		'|| p_shipment_line_rec.SHIP_METHOD_CODE,1,'Y');

		aso_debug_pub.add('106.	Value of P_SHIPMENT_LINE_REC.REQUEST_DATE_TYPE:		'||p_Shipment_line_rec.REQUEST_DATE_TYPE, 1,'Y');
		aso_debug_pub.add('107.	Value of P_SHIPMENT_LINE_REC.REQUEST_DATE:		'||P_Shipment_line_rec.REQUEST_DATE, 1,'Y');
		aso_debug_pub.add('108.	Value of P_SHIPMENT_LINE_REC.SHIPMENT_PRIORITY_CODE:	'||P_Shipment_line_rec.SHIPMENT_PRIORITY_CODE, 1,'Y');
		aso_debug_pub.add('109.	Value of P_SHIPMENT_LINE_REC.FOB_CODE:			'||P_Shipment_line_rec.FOB_CODE, 1,'Y');
		aso_debug_pub.add('110.	Value of P_SHIPMENT_LINE_REC.DEMAND_CLASS_CODE:		'||P_Shipment_line_rec.DEMAND_CLASS_CODE, 1,'Y');

		aso_debug_pub.add('111.	Value of P_QUOTE_LINE_REC.ORG_ID:			'||P_quote_line_rec.ORG_ID, 1,'Y');
		aso_debug_pub.add('112.	Value of p_quote_line_rec.AGREEMENT_ID:			'|| p_quote_line_rec.AGREEMENT_ID,1,'Y');
		aso_debug_pub.add('113.	Value of p_quote_line_rec.ATTRIBUTE1:			'|| p_quote_line_rec.ATTRIBUTE1,1,'Y');
		aso_debug_pub.add('114.	Value of p_quote_line_rec.ATTRIBUTE10:			'|| p_quote_line_rec.ATTRIBUTE10,1,'Y');
		aso_debug_pub.add('115.	Value of p_quote_line_rec.ATTRIBUTE11:			'|| p_quote_line_rec.ATTRIBUTE11,1,'Y');
		aso_debug_pub.add('116.	Value of p_quote_line_rec.ATTRIBUTE12:			'|| p_quote_line_rec.ATTRIBUTE12,1,'Y');
		aso_debug_pub.add('117.	Value of p_quote_line_rec.ATTRIBUTE13:			'|| p_quote_line_rec.ATTRIBUTE13,1,'Y');
		aso_debug_pub.add('118.	Value of p_quote_line_rec.ATTRIBUTE14:			'|| p_quote_line_rec.ATTRIBUTE14,1,'Y');
		aso_debug_pub.add('119.	Value of p_quote_line_rec.ATTRIBUTE15:			'|| p_quote_line_rec.ATTRIBUTE15,1,'Y');
		aso_debug_pub.add('120.	Value of p_quote_line_rec.ATTRIBUTE16:			'|| p_quote_line_rec.ATTRIBUTE16,1,'Y');
		aso_debug_pub.add('121.	Value of p_quote_line_rec.ATTRIBUTE17:			'|| p_quote_line_rec.ATTRIBUTE17,1,'Y');
		aso_debug_pub.add('122.	Value of p_quote_line_rec.ATTRIBUTE18:			'|| p_quote_line_rec.ATTRIBUTE18,1,'Y');
		aso_debug_pub.add('123.	Value of p_quote_line_rec.ATTRIBUTE19:			'|| p_quote_line_rec.ATTRIBUTE19,1,'Y');
		aso_debug_pub.add('124.	Value of p_quote_line_rec.ATTRIBUTE2:			'|| p_quote_line_rec.ATTRIBUTE2,1,'Y');
		aso_debug_pub.add('125.	Value of p_quote_line_rec.ATTRIBUTE20:			'|| p_quote_line_rec.ATTRIBUTE20,1,'Y');
		aso_debug_pub.add('126.	Value of p_quote_line_rec.ATTRIBUTE3:			'|| p_quote_line_rec.ATTRIBUTE3,1,'Y');
		aso_debug_pub.add('127.	Value of p_quote_line_rec.ATTRIBUTE4:			'|| p_quote_line_rec.ATTRIBUTE4,1,'Y');
		aso_debug_pub.add('128.	Value of p_quote_line_rec.ATTRIBUTE5:			'|| p_quote_line_rec.ATTRIBUTE5,1,'Y');
		aso_debug_pub.add('129.	Value of p_quote_line_rec.ATTRIBUTE6:			'|| p_quote_line_rec.ATTRIBUTE6,1,'Y');
		aso_debug_pub.add('130.	Value of p_quote_line_rec.ATTRIBUTE7:			'|| p_quote_line_rec.ATTRIBUTE7,1,'Y');
		aso_debug_pub.add('131.	Value of p_quote_line_rec.ATTRIBUTE8:			'|| p_quote_line_rec.ATTRIBUTE8,1,'Y');
		aso_debug_pub.add('132.	Value of p_quote_line_rec.ATTRIBUTE9:			'|| p_quote_line_rec.ATTRIBUTE9,1,'Y');
		aso_debug_pub.add('133.	Value of p_quote_line_rec.CREATED_BY:			'|| p_quote_line_rec.CREATED_BY,1,'Y');
		aso_debug_pub.add('134.	Value of p_quote_line_rec.ORDER_LINE_TYPE_ID:		'|| p_quote_line_rec.ORDER_LINE_TYPE_ID,1,'Y');
		aso_debug_pub.add('135.	Value of p_quote_line_rec.LAST_UPDATE_DATE:		'|| p_quote_line_rec.LAST_UPDATE_DATE,1,'Y');
		aso_debug_pub.add('136.	Value of p_quote_line_rec.LINE_CATEGORY_CODE:		'|| p_quote_line_rec.LINE_CATEGORY_CODE,1,'Y');
		aso_debug_pub.add('137.	Value of p_quote_line_rec.OBJECT_VERSION_NUMBER:	'|| p_quote_line_rec.OBJECT_VERSION_NUMBER,1,'Y');
		aso_debug_pub.add('138.	Value of p_quote_line_rec.QUOTE_HEADER_ID:		'|| p_quote_line_rec.QUOTE_HEADER_ID,1,'Y');
		aso_debug_pub.add('139.	Value of p_quote_line_rec.QUOTE_LINE_ID:		'|| p_quote_line_rec.QUOTE_LINE_ID,1,'Y');

		aso_debug_pub.add('**		Line Attributes End		**', 1, 'Y');
	END IF ;

ELSIF p_begin_flag = 'N' THEN

	IF p_def_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN

--Header Attributes(Output)
		aso_debug_pub.add('**		Header Attributes Start		**', 1, 'Y');

		aso_debug_pub.add('1.	Value of x_QUOTE_HEADER_REC.PRICE_LIST_ID:		'||x_quote_header_rec.PRICE_LIST_ID, 1,'Y');
		aso_debug_pub.add('2.	Value of x_QUOTE_HEADER_REC.CURRENCY_CODE:		'||x_quote_header_rec.CURRENCY_CODE, 1,'Y');
		aso_debug_pub.add('3.	Value of x_QUOTE_HEADER_REC.SALES_CHANNEL_CODE:		'||x_quote_header_rec.SALES_CHANNEL_CODE, 1,'Y');
		aso_debug_pub.add('4.	Value of x_QUOTE_HEADER_REC.AUTOMATIC_PRICE_FLAG:	'||x_quote_header_rec.AUTOMATIC_PRICE_FLAG, 1,'Y');
		aso_debug_pub.add('5.	Value of x_QUOTE_HEADER_REC.AUTOMATIC_TAX_FLAG:		'||x_quote_header_rec.AUTOMATIC_TAX_FLAG, 1,'Y');
		aso_debug_pub.add('6.	Value of x_QUOTE_HEADER_REC.PHONE_ID:			'||x_quote_header_rec.phone_id, 1,'Y');

		aso_debug_pub.add('7.	Value of x_QUOTE_HEADER_REC.CUST_PARTY_ID:		'||x_quote_header_rec.cust_party_id, 1,'Y');
		aso_debug_pub.add('8.	Value of x_QUOTE_HEADER_REC.CUST_ACCOUNT_ID:		'||x_quote_header_rec.CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('9.	Value of x_QUOTE_HEADER_REC.PARTY_ID:			'||x_quote_header_rec.party_id, 1,'Y');
		aso_debug_pub.add('10.	Value of x_QUOTE_HEADER_REC.SOLD_TO_PARTY_SITE_ID:	'||x_quote_header_rec.SOLD_TO_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('11.	Value of x_QUOTE_HEADER_REC.INVOICE_TO_CUST_PARTY_ID:	'||x_quote_header_rec.INVOICE_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('12.	Value of x_QUOTE_HEADER_REC.INVOICE_TO_CUST_ACCOUNT_ID:'||x_quote_header_rec.INVOICE_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('13.	Value of x_QUOTE_HEADER_REC.INVOICE_TO_PARTY_ID:	'||x_quote_header_rec.INVOICE_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('14.	Value of x_QUOTE_HEADER_REC.INVOICE_TO_PARTY_SITE_ID:	'||x_quote_header_rec.INVOICE_TO_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('15.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE_CATEGORY:		'|| x_quote_header_rec.ATTRIBUTE_CATEGORY,1,'Y');
		aso_debug_pub.add('16.	Value of x_QUOTE_HEADER_REC.CONTRACT_ID:		'|| x_quote_header_rec.CONTRACT_ID,1,'Y');
		aso_debug_pub.add('17.	Value of x_QUOTE_HEADER_REC.CONTRACT_TEMPLATE_ID:	'|| x_quote_header_rec.CONTRACT_TEMPLATE_ID,1,'Y');
		aso_debug_pub.add('18.	Value of x_QUOTE_HEADER_REC.CREATED_BY:			'|| x_quote_header_rec.CREATED_BY,1,'Y');
		aso_debug_pub.add('19.	Value of x_QUOTE_HEADER_REC.LAST_UPDATE_DATE:		'|| x_quote_header_rec.LAST_UPDATE_DATE,1,'Y');
		aso_debug_pub.add('20.	Value of x_QUOTE_HEADER_REC.MARKETING_SOURCE_CODE_ID:	'|| x_quote_header_rec.MARKETING_SOURCE_CODE_ID,1,'Y');
		aso_debug_pub.add('21.	Value of x_QUOTE_HEADER_REC.OBJECT_VERSION_NUMBER:	'|| x_quote_header_rec.OBJECT_VERSION_NUMBER,1,'Y');
		aso_debug_pub.add('22.	Value of x_QUOTE_HEADER_REC.ORDER_TYPE_ID:		'|| x_quote_header_rec.ORDER_TYPE_ID,1,'Y');
		aso_debug_pub.add('23.	Value of x_QUOTE_HEADER_REC.PHONE_ID:			'|| x_quote_header_rec.PHONE_ID,1,'Y');
		aso_debug_pub.add('24.	Value of x_QUOTE_HEADER_REC.PRICE_FROZEN_DATE:		'|| x_quote_header_rec.PRICE_FROZEN_DATE,1,'Y');
		aso_debug_pub.add('25.	Value of x_QUOTE_HEADER_REC.QUOTE_EXPIRATION_DATE:	'|| x_quote_header_rec.QUOTE_EXPIRATION_DATE,1,'Y');
		aso_debug_pub.add('26.	Value of x_QUOTE_HEADER_REC.QUOTE_HEADER_ID:		'|| x_quote_header_rec.QUOTE_HEADER_ID,1,'Y');
		aso_debug_pub.add('27.	Value of x_QUOTE_HEADER_REC.QUOTE_NAME:			'|| x_quote_header_rec.QUOTE_NAME,1,'Y');
		aso_debug_pub.add('28.	Value of x_QUOTE_HEADER_REC.QUOTE_STATUS_ID:		'|| x_quote_header_rec.QUOTE_STATUS_ID,1,'Y');
		aso_debug_pub.add('29.	Value of x_QUOTE_HEADER_REC.RESOURCE_GRP_ID:		'|| x_quote_header_rec.RESOURCE_GRP_ID,1,'Y');
		aso_debug_pub.add('30.	Value of x_QUOTE_HEADER_REC.RESOURCE_ID:		'|| x_quote_header_rec.RESOURCE_ID,1,'Y');
		aso_debug_pub.add('31.	Value of x_QUOTE_HEADER_REC.RESOURCE_ID:		'||x_quote_header_rec.resource_id, 1,'Y');

		aso_debug_pub.add('32.	Value of x_SHIPMENT_HEADER_REC.ship_TO_CUST_PARTY_ID:	'||x_shipment_header_rec.ship_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('33.	Value of x_SHIPMENT_HEADER_REC.ship_TO_CUST_ACCOUNT_ID:'||x_shipment_header_rec.ship_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('34.	Value of x_SHIPMENT_HEADER_REC.ship_TO_PARTY_ID:	'||x_shipment_header_rec.ship_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('35.	Value of x_SHIPMENT_HEADER_REC.ship_TO_PARTY_SITE_ID:	'||x_shipment_header_rec.ship_TO_PARTY_SITE_ID, 1,'Y');
		aso_debug_pub.add('36.	Value of x_SHIPMENT_HEADER_REC.REQUEST_DATE_TYPE: 	'||x_Shipment_header_rec.REQUEST_DATE_TYPE, 1,'Y');
		aso_debug_pub.add('37.	Value of x_SHIPMENT_HEADER_REC.REQUEST_DATE:		'||x_Shipment_header_rec.REQUEST_DATE, 1,'Y');
		aso_debug_pub.add('38.	Value of x_SHIPMENT_HEADER_REC.SHIPMENT_PRIORITY_CODE:	'||x_Shipment_header_rec.SHIPMENT_PRIORITY_CODE, 1,'Y');
		aso_debug_pub.add('39.	Value of x_SHIPMENT_HEADER_REC.FOB_CODE:		'||x_Shipment_header_rec.FOB_CODE, 1,'Y');
		aso_debug_pub.add('40.	Value of x_SHIPMENT_HEADER_REC.DEMAND_CLASS_CODE:	'||x_Shipment_header_rec.DEMAND_CLASS_CODE, 1,'Y');
		aso_debug_pub.add('41.	Value of x_SHIPMENT_HEADER_REC.SHIPPING_INSTRUCTIONS:	'|| x_SHIPMENT_HEADER_REC.SHIPPING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('42.	Value of x_SHIPMENT_HEADER_REC.PACKING_INSTRUCTIONS:	'|| x_shipment_header_rec.PACKING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('43.	Value of x_SHIPMENT_HEADER_REC.ship_METHOD_CODE:	'|| x_SHIPMENT_HEADER_REC.ship_METHOD_CODE,1,'Y');
		aso_debug_pub.add('44.	Value of x_SHIPMENT_HEADER_REC.FREIGHT_TERMS_CODE:	'|| x_SHIPMENT_HEADER_REC.FREIGHT_TERMS_CODE,1,'Y');

		aso_debug_pub.add('45.	Value of x_PAYMENT_HEADER_REC.PAYMENT_TYPE_CODE:	'||x_Payment_header_rec.PAYMENT_TYPE_CODE, 1,'Y');
		aso_debug_pub.add('46.	Value of x_PAYMENT_HEADER_REC.CREDIT_CARD_CODE:		'||x_Payment_header_rec.CREDIT_CARD_CODE, 1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('47.  Value of x_PAYMENT_HEADER_REC.CREDIT_CARD_EXPIRATION_DATE:'|| x_PAYMENT_HEADER_REC.CREDIT_CARD_EXPIRATION_DATE,1,'Y');
		aso_debug_pub.add('48. Value of x_PAYMENT_HEADER_REC.CREDIT_CARD_HOLDER_NAME:	'|| x_PAYMENT_HEADER_REC.CREDIT_CARD_HOLDER_NAME,1,'Y');
		Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('49.	Value of x_PAYMENT_HEADER_REC.CUST_PO_NUMBER:		'|| x_payment_header_rec.CUST_PO_NUMBER,1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('50. Value of x_PAYMENT_HEADER_REC.PAYMENT_REF_NUMBER:	'|| x_PAYMENT_HEADER_REC.PAYMENT_REF_NUMBER,1,'Y');
                Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('51.	Value of x_PAYMENT_HEADER_REC.PAYMENT_TERM_ID:		'|| x_PAYMENT_HEADER_REC.PAYMENT_TERM_ID,1,'Y');

		aso_debug_pub.add('52.	Value of x_QUOTE_HEADER_REC.END_CUSTOMER_CUST_PARTY_ID:	'||x_quote_header_rec.end_customer_cust_party_id, 1,'Y');
		aso_debug_pub.add('53.	Value of x_QUOTE_HEADER_REC.END_CUSTOMER_CUST_ACCOUNT_ID:'||x_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('54.	Value of x_QUOTE_HEADER_REC.END_CUSTOMER_PARTY_ID:	'||x_quote_header_rec.END_CUSTOMER_PARTY_ID, 1,'Y');
		aso_debug_pub.add('55.	Value of x_QUOTE_HEADER_REC.END_CUSTOMER_PARTY_SITE_ID:	'||x_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('56.	Value of x_QUOTE_HEADER_REC.ORG_ID:			'||x_quote_header_rec.ORG_ID, 1,'Y');
		aso_debug_pub.add('57.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE1:			'|| x_quote_header_rec.ATTRIBUTE1,1,'Y');
		aso_debug_pub.add('58.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE10:		'|| x_quote_header_rec.ATTRIBUTE10,1,'Y');
		aso_debug_pub.add('59.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE11:		'|| x_quote_header_rec.ATTRIBUTE11,1,'Y');
		aso_debug_pub.add('60.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE12:		'|| x_quote_header_rec.ATTRIBUTE12,1,'Y');
		aso_debug_pub.add('61.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE13:		'|| x_quote_header_rec.ATTRIBUTE13,1,'Y');
		aso_debug_pub.add('62.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE14:		'|| x_quote_header_rec.ATTRIBUTE14,1,'Y');
		aso_debug_pub.add('63.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE15:		'|| x_quote_header_rec.ATTRIBUTE15,1,'Y');
		aso_debug_pub.add('64.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE16:		'|| x_quote_header_rec.ATTRIBUTE16,1,'Y');
		aso_debug_pub.add('65.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE17:		'|| x_quote_header_rec.ATTRIBUTE17,1,'Y');
		aso_debug_pub.add('66.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE18:		'|| x_quote_header_rec.ATTRIBUTE18,1,'Y');
		aso_debug_pub.add('67.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE19:		'|| x_quote_header_rec.ATTRIBUTE19,1,'Y');
		aso_debug_pub.add('68.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE2:			'|| x_quote_header_rec.ATTRIBUTE2,1,'Y');
		aso_debug_pub.add('69.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE20:		'|| x_quote_header_rec.ATTRIBUTE20,1,'Y');
		aso_debug_pub.add('70.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE3:			'|| x_quote_header_rec.ATTRIBUTE3,1,'Y');
		aso_debug_pub.add('71.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE4:			'|| x_quote_header_rec.ATTRIBUTE4,1,'Y');
		aso_debug_pub.add('72.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE5:			'|| x_quote_header_rec.ATTRIBUTE5,1,'Y');
		aso_debug_pub.add('73.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE6:			'|| x_quote_header_rec.ATTRIBUTE6,1,'Y');
		aso_debug_pub.add('74.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE7:			'|| x_quote_header_rec.ATTRIBUTE7,1,'Y');
		aso_debug_pub.add('75.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE8:			'|| x_quote_header_rec.ATTRIBUTE8,1,'Y');
		aso_debug_pub.add('76.	Value of x_QUOTE_HEADER_REC.ATTRIBUTE9:			'|| x_quote_header_rec.ATTRIBUTE9,1,'Y');
		aso_debug_pub.add('**		Header Attributes End		**', 1, 'Y');

	ELSIF p_def_object_name = 'ASO_AK_QUOTE_LINE_V' THEN
--Line Attributes (Input)
		aso_debug_pub.add('**		Line Attributes Start		**', 1, 'Y');

		aso_debug_pub.add('78.	Value of x_QUOTE_LINE_REC.CHARGE_PERIODICITY_CODE:	'||x_quote_line_rec.CHARGE_PERIODICITY_CODE,1,'Y');
		aso_debug_pub.add('79.	Value of x_QUOTE_LINE_REC.PRICE_LIST_ID:		'||x_quote_line_rec.PRICE_LIST_ID, 1,'Y');

		aso_debug_pub.add('80.	Value of x_QUOTE_LINE_REC.INVOICE_TO_CUST_PARTY_ID:	'||x_quote_line_rec.INVOICE_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('81.	Value of x_QUOTE_LINE_REC.INVOICE_TO_CUST_ACCOUNT_ID:	'||x_quote_line_rec.INVOICE_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('82.	Value of x_QUOTE_LINE_REC.INVOICE_TO_PARTY_ID		'||x_quote_Line_rec.INVOICE_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('83.	Value of x_QUOTE_LINE_REC.INVOICE_TO_PARTY_SITE_ID:	'||x_quote_line_rec.INVOICE_TO_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('84.	Value of x_QUOTE_LINE_REC.END_CUSTOMER_CUST_PARTY_ID:	'||x_quote_line_rec.end_customer_cust_party_id, 1,'Y');
		aso_debug_pub.add('85.	Value of x_QUOTE_LINE_REC.END_CUSTOMER_CUST_ACCOUNT_ID:	'||x_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('86.	Value of x_QUOTE_LINE_REC.END_CUSTOMER_PARTY_ID:	'||x_quote_Line_rec.END_CUSTOMER_PARTY_ID, 1,'Y');
		aso_debug_pub.add('87.	Value of x_QUOTE_LINE_REC.END_CUSTOMER_PARTY_SITE_ID:	'||x_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID, 1,'Y');

		aso_debug_pub.add('88.	Value of x_PAYMENT_LINE_REC.PAYMENT_TYPE_CODE:		'||x_Payment_line_rec.PAYMENT_TYPE_CODE, 1,'Y');
		aso_debug_pub.add('89.	Value of x_PAYMENT_LINE_REC.CREDIT_CARD_CODE:		'||x_Payment_line_rec.CREDIT_CARD_CODE, 1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('90.  Value of x_payment_line_rec.CREDIT_CARD_EXPIRATION_DATE:'|| x_payment_line_rec.CREDIT_CARD_EXPIRATION_DATE,1,'Y');
		aso_debug_pub.add('91. Value of x_payment_line_rec.CREDIT_CARD_HOLDER_NAME:	'|| x_payment_line_rec.CREDIT_CARD_HOLDER_NAME,1,'Y');
		Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('92.	Value of x_payment_line_rec.CUST_PO_LINE_NUMBER:	'|| x_payment_line_rec.CUST_PO_LINE_NUMBER,1,'Y');
		aso_debug_pub.add('93.	Value of x_payment_line_rec.CUST_PO_NUMBER:		'|| x_payment_line_rec.CUST_PO_NUMBER,1,'Y');

		/* Code change for PA-DSS ER 8499296 Start
		aso_debug_pub.add('94. Value of x_payment_line_rec.PAYMENT_REF_NUMBER:		'|| x_payment_line_rec.PAYMENT_REF_NUMBER,1,'Y');
                Code change for PA-DSS ER 8499296 End */

		aso_debug_pub.add('95.	Value of x_payment_line_rec.PAYMENT_TERM_ID:		'|| x_payment_line_rec.PAYMENT_TERM_ID,1,'Y');


		aso_debug_pub.add('96.	Value of x_SHIPMENT_LINE_REC.ship_TO_CUST_PARTY_ID:	'||x_shipment_line_rec.ship_TO_CUST_PARTY_ID, 1,'Y');
		aso_debug_pub.add('97.	Value of x_SHIPMENT_LINE_REC.ship_TO_CUST_ACCOUNT_ID:	'||x_shipment_line_rec.ship_TO_CUST_ACCOUNT_ID, 1,'Y');
		aso_debug_pub.add('98.	Value of x_SHIPMENT_LINE_REC.ship_TO_PARTY_ID:		'||x_shipment_Line_rec.ship_TO_PARTY_ID, 1,'Y');
		aso_debug_pub.add('99.	Value of x_SHIPMENT_LINE_REC.ship_TO_PARTY_SITE_ID:	'||x_shipment_line_rec.ship_TO_PARTY_SITE_ID, 1,'Y');
		aso_debug_pub.add('100.	Value of x_shipment_line_rec.ATTRIBUTE_CATEGORY:	'|| x_shipment_line_rec.ATTRIBUTE_CATEGORY,1,'Y');
		aso_debug_pub.add('101.	Value of x_shipment_line_rec.FREIGHT_TERMS_CODE:	'|| x_shipment_line_rec.FREIGHT_TERMS_CODE,1,'Y');
		aso_debug_pub.add('102.	Value of x_shipment_line_rec.ship_FROM_ORG_ID:		'|| x_shipment_line_rec.ship_FROM_ORG_ID,1,'Y');
		aso_debug_pub.add('103.	Value of x_shipment_line_rec.PACKING_INSTRUCTIONS:	'|| x_shipment_line_rec.PACKING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('104.	Value of x_shipment_line_rec.SHIPPING_INSTRUCTIONS:	'|| x_shipment_line_rec.SHIPPING_INSTRUCTIONS,1,'Y');
		aso_debug_pub.add('105.	Value of x_shipment_line_rec.ship_METHOD_CODE:		'|| x_shipment_line_rec.ship_METHOD_CODE,1,'Y');

		aso_debug_pub.add('106.	Value of x_SHIPMENT_LINE_REC.REQUEST_DATE_TYPE:		'||x_Shipment_line_rec.REQUEST_DATE_TYPE, 1,'Y');
		aso_debug_pub.add('107.	Value of x_SHIPMENT_LINE_REC.REQUEST_DATE:		'||x_Shipment_line_rec.REQUEST_DATE, 1,'Y');
		aso_debug_pub.add('108.	Value of x_SHIPMENT_LINE_REC.SHIPMENT_PRIORITY_CODE:	'||x_Shipment_line_rec.SHIPMENT_PRIORITY_CODE, 1,'Y');
		aso_debug_pub.add('109.	Value of x_SHIPMENT_LINE_REC.FOB_CODE:			'||x_Shipment_line_rec.FOB_CODE, 1,'Y');
		aso_debug_pub.add('110.	Value of x_SHIPMENT_LINE_REC.DEMAND_CLASS_CODE:		'||x_Shipment_line_rec.DEMAND_CLASS_CODE, 1,'Y');

		aso_debug_pub.add('111.	Value of x_QUOTE_LINE_REC.ORG_ID:			'||x_quote_line_rec.ORG_ID, 1,'Y');
		aso_debug_pub.add('112.	Value of x_quote_line_rec.AGREEMENT_ID:			'|| x_quote_line_rec.AGREEMENT_ID,1,'Y');
		aso_debug_pub.add('113.	Value of x_quote_line_rec.ATTRIBUTE1:			'|| x_quote_line_rec.ATTRIBUTE1,1,'Y');
		aso_debug_pub.add('114.	Value of x_quote_line_rec.ATTRIBUTE10:			'|| x_quote_line_rec.ATTRIBUTE10,1,'Y');
		aso_debug_pub.add('115.	Value of x_quote_line_rec.ATTRIBUTE11:			'|| x_quote_line_rec.ATTRIBUTE11,1,'Y');
		aso_debug_pub.add('116.	Value of x_quote_line_rec.ATTRIBUTE12:			'|| x_quote_line_rec.ATTRIBUTE12,1,'Y');
		aso_debug_pub.add('117.	Value of x_quote_line_rec.ATTRIBUTE13:			'|| x_quote_line_rec.ATTRIBUTE13,1,'Y');
		aso_debug_pub.add('118.	Value of x_quote_line_rec.ATTRIBUTE14:			'|| x_quote_line_rec.ATTRIBUTE14,1,'Y');
		aso_debug_pub.add('119.	Value of x_quote_line_rec.ATTRIBUTE15:			'|| x_quote_line_rec.ATTRIBUTE15,1,'Y');
		aso_debug_pub.add('120.	Value of x_quote_line_rec.ATTRIBUTE16:			'|| x_quote_line_rec.ATTRIBUTE16,1,'Y');
		aso_debug_pub.add('121.	Value of x_quote_line_rec.ATTRIBUTE17:			'|| x_quote_line_rec.ATTRIBUTE17,1,'Y');
		aso_debug_pub.add('122.	Value of x_quote_line_rec.ATTRIBUTE18:			'|| x_quote_line_rec.ATTRIBUTE18,1,'Y');
		aso_debug_pub.add('123.	Value of x_quote_line_rec.ATTRIBUTE19:			'|| x_quote_line_rec.ATTRIBUTE19,1,'Y');
		aso_debug_pub.add('124.	Value of x_quote_line_rec.ATTRIBUTE2:			'|| x_quote_line_rec.ATTRIBUTE2,1,'Y');
		aso_debug_pub.add('125.	Value of x_quote_line_rec.ATTRIBUTE20:			'|| x_quote_line_rec.ATTRIBUTE20,1,'Y');
		aso_debug_pub.add('126.	Value of x_quote_line_rec.ATTRIBUTE3:			'|| x_quote_line_rec.ATTRIBUTE3,1,'Y');
		aso_debug_pub.add('127.	Value of x_quote_line_rec.ATTRIBUTE4:			'|| x_quote_line_rec.ATTRIBUTE4,1,'Y');
		aso_debug_pub.add('128.	Value of x_quote_line_rec.ATTRIBUTE5:			'|| x_quote_line_rec.ATTRIBUTE5,1,'Y');
		aso_debug_pub.add('129.	Value of x_quote_line_rec.ATTRIBUTE6:			'|| x_quote_line_rec.ATTRIBUTE6,1,'Y');
		aso_debug_pub.add('130.	Value of x_quote_line_rec.ATTRIBUTE7:			'|| x_quote_line_rec.ATTRIBUTE7,1,'Y');
		aso_debug_pub.add('131.	Value of x_quote_line_rec.ATTRIBUTE8:			'|| x_quote_line_rec.ATTRIBUTE8,1,'Y');
		aso_debug_pub.add('132.	Value of x_quote_line_rec.ATTRIBUTE9:			'|| x_quote_line_rec.ATTRIBUTE9,1,'Y');
		aso_debug_pub.add('133.	Value of x_quote_line_rec.CREATED_BY:			'|| x_quote_line_rec.CREATED_BY,1,'Y');
		aso_debug_pub.add('134.	Value of x_quote_line_rec.ORDER_LINE_TYPE_ID:		'|| x_quote_line_rec.ORDER_LINE_TYPE_ID,1,'Y');
		aso_debug_pub.add('135.	Value of x_quote_line_rec.LAST_UPDATE_DATE:		'|| x_quote_line_rec.LAST_UPDATE_DATE,1,'Y');
		aso_debug_pub.add('136.	Value of x_quote_line_rec.LINE_CATEGORY_CODE:		'|| x_quote_line_rec.LINE_CATEGORY_CODE,1,'Y');
		aso_debug_pub.add('137.	Value of x_quote_line_rec.OBJECT_VERSION_NUMBER:	'|| x_quote_line_rec.OBJECT_VERSION_NUMBER,1,'Y');
		aso_debug_pub.add('138.	Value of x_quote_line_rec.QUOTE_HEADER_ID:		'|| x_quote_line_rec.QUOTE_HEADER_ID,1,'Y');
		aso_debug_pub.add('139.	Value of x_quote_line_rec.QUOTE_LINE_ID:		'|| x_quote_line_rec.QUOTE_LINE_ID,1,'Y');

		aso_debug_pub.add('**		Line Attributes End		**', 1, 'Y');
	END IF;
END IF ;
END;

BEGIN

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	     aso_debug_pub.add('Begin VALIDATE_DEFAULTING_DATA', 1, 'Y');
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	 END IF;
      -- Standard call to check for call compatibility.
--      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
--                                           p_api_version_number,
--                                           l_api_name,
--                                           G_PKG_NAME) THEN
--
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
	     FND_MSG_PUB.initialize;
      END IF;

	--- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Before copying all the input parameters to output parameters', 1, 'Y');
	END IF;

	X_quote_header_rec	:= P_quote_header_rec ;
	X_quote_line_rec	:= P_quote_line_rec ;
	X_Shipment_header_rec	:= P_Shipment_header_rec ;
	X_Shipment_line_rec	:= P_shipment_line_rec ;
	X_Payment_header_rec	:= P_Payment_header_rec ;
	X_Payment_line_rec	:= P_Payment_line_rec ;
	X_tax_header_rec	:= P_tax_header_rec ;
	X_tax_line_rec		:= P_tax_line_rec ;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Copied all the input parameters to output parameters', 1, 'Y');
	END IF;


        --For charged periodicity
        l_periodicity_profile := FND_PROFILE.value('ONT_UOM_CLASS_CHARGE_PERIODICITY');
      	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Value of profile ONT_UOM_CLASS_CHARGE_PERIODICITY : '||l_periodicity_profile, 1, 'Y');
	END IF;

     --Printing the Values before processing
     PRINT_DEFAULTING_ATTRIBUTES('Y');

--Shipment Priority

if (	p_shipment_header_rec.SHIPMENT_PRIORITY_CODE is NOT NULL
	AND p_shipment_header_rec.SHIPMENT_PRIORITY_CODE <> FND_API.G_MISS_CHAR) THEN

		aso_debug_pub.add('Before opening Cursor C_SHIPMENT_PRIORITY_CODE--Header Level', 1, 'Y');
		OPEN C_SHIPMENT_PRIORITY_CODE(P_Shipment_header_rec.SHIPMENT_PRIORITY_CODE);       --Header Level
		aso_debug_pub.add('Before fetching Cursor C_SHIPMENT_PRIORITY_CODE--Header Level', 1, 'Y');
		FETCH C_SHIPMENT_PRIORITY_CODE INTO l_data_exists ;

		IF C_SHIPMENT_PRIORITY_CODE%FOUND THEN
			x_Shipment_header_rec.SHIPMENT_PRIORITY_CODE	 := P_Shipment_header_rec.SHIPMENT_PRIORITY_CODE;
		ELSE
			x_Shipment_header_rec.SHIPMENT_PRIORITY_CODE	 := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_SHIPMENT_PRIORITY_CODE--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SHPMT_PRIORITY', TRUE);
			FND_MSG_PUB.ADD;

		aso_debug_pub.add('No Data Found for Cursor C_SHIPMENT_PRIORITY_CODE--Header Level', 1, 'Y');
		END IF;
		aso_debug_pub.add('Before Closing Cursor C_SHIPMENT_PRIORITY_CODE-Header Level', 1, 'Y');
		CLOSE C_SHIPMENT_PRIORITY_CODE;
		aso_debug_pub.add('After Closing Cursor C_SHIPMENT_PRIORITY_CODE-Header Level', 1, 'Y');

END IF;

if (	p_shipment_line_rec.SHIPMENT_PRIORITY_CODE is NOT NULL
	AND p_shipment_line_rec.SHIPMENT_PRIORITY_CODE <> FND_API.G_MISS_CHAR) THEN

		aso_debug_pub.add('Before opening Cursor C_SHIPMENT_PRIORITY_CODE--Line Level', 1, 'Y');
		OPEN C_SHIPMENT_PRIORITY_CODE(P_Shipment_line_rec.SHIPMENT_PRIORITY_CODE);         --line Level
		aso_debug_pub.add('Before fetching Cursor C_SHIPMENT_PRIORITY_CODE--Line Level', 1, 'Y');

		FETCH C_SHIPMENT_PRIORITY_CODE INTO l_data_exists ;

		IF C_SHIPMENT_PRIORITY_CODE%FOUND THEN
			x_Shipment_line_rec.SHIPMENT_PRIORITY_CODE	 := P_Shipment_line_rec.SHIPMENT_PRIORITY_CODE;
		ELSE
			x_Shipment_line_rec.SHIPMENT_PRIORITY_CODE	 := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_SHIPMENT_PRIORITY_CODE--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		aso_debug_pub.add('Before Closing Cursor C_SHIPMENT_PRIORITY_CODE-Line Level', 1, 'Y');
		CLOSE C_SHIPMENT_PRIORITY_CODE;
		aso_debug_pub.add('After Closing Cursor C_SHIPMENT_PRIORITY_CODE-Line Level', 1, 'Y');

END IF;

--FOB CODE

if (	p_shipment_header_rec.FOB_CODE is NOT NULL
	AND p_shipment_header_rec.FOB_CODE <> FND_API.G_MISS_CHAR) THEN
	      aso_debug_pub.add('Before opening Cursor C_FOB--Header Level', 1, 'Y');
		OPEN C_FOB(P_Shipment_header_rec.FOB_CODE) ;                   --Header Level
	      aso_debug_pub.add('Before fetching Cursor C_FOB--Header Level', 1, 'Y');

		FETCH C_FOB INTO l_data_exists ;

		IF C_FOB%FOUND THEN
			x_Shipment_header_rec.FOB_CODE	 := P_Shipment_header_rec.FOB_CODE ;
		ELSE
			x_Shipment_header_rec.FOB_CODE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_FOB--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_FOB', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before Closing Cursor C_FOB--Header Level', 1, 'Y');
		CLOSE C_FOB;
	      aso_debug_pub.add('After Closing Cursor C_FOB--Header Level', 1, 'Y');

END IF;

if (	p_shipment_line_rec.FOB_CODE is NOT NULL
	AND p_shipment_line_rec.FOB_CODE <> FND_API.G_MISS_CHAR) THEN
		aso_debug_pub.add('Before opening Cursor C_FOB--Line Level', 1, 'Y');
		OPEN C_FOB(P_Shipment_line_rec.FOB_CODE) ;                   --line Level
		aso_debug_pub.add('Before fetching Cursor C_FOB--Line Level', 1, 'Y');
		FETCH C_FOB INTO l_data_exists ;

		IF C_FOB%FOUND THEN
			x_Shipment_line_rec.FOB_CODE	 := P_Shipment_line_rec.FOB_CODE ;
		ELSE
			x_Shipment_line_rec.FOB_CODE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_FOB--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before Closing Cursor C_FOB--Line Level', 1, 'Y');
		CLOSE C_FOB;
	      aso_debug_pub.add('After Closing Cursor C_FOB--Line Level', 1, 'Y');

END IF;

--Credit Card Type

if (	P_Payment_header_rec.CREDIT_CARD_CODE is NOT NULL
	AND P_Payment_header_rec.CREDIT_CARD_CODE <> FND_API.G_MISS_CHAR ) THEN

	IF (P_Payment_header_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD') THEN

	      aso_debug_pub.add('Before opening Cursor C_CREDIT_CARD_TYPE--Header Level', 1, 'Y');

		OPEN C_CREDIT_CARD_TYPE(P_Payment_header_rec.CREDIT_CARD_CODE) ;                   --Header Level
	      aso_debug_pub.add('Before fetching Cursor C_CREDIT_CARD_TYPE--Header Level', 1, 'Y');
		FETCH C_CREDIT_CARD_TYPE INTO l_data_exists ;

		IF C_CREDIT_CARD_TYPE%FOUND THEN
			x_Payment_header_rec.CREDIT_CARD_CODE	 := P_Payment_header_rec.CREDIT_CARD_CODE;
		ELSE
			x_Payment_header_rec.CREDIT_CARD_CODE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_CREDIT_CARD_TYPE--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_CREDIT_CARD_TYPE', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before Closing Cursor C_CREDIT_CARD_TYPE--Header Level', 1, 'Y');
		CLOSE C_CREDIT_CARD_TYPE;
	      aso_debug_pub.add('After Closing Cursor C_CREDIT_CARD_TYPE--Header Level', 1, 'Y');

	 ELSE
		x_Payment_header_rec.CREDIT_CARD_CODE := NULL ;
		aso_debug_pub.add('Credit card code needs to be null if payment type is not CREDIT_CARD.', 1, 'Y');

		FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_CREDIT_CARD_TYPE', TRUE);
		FND_MSG_PUB.ADD;

	END IF ;
end if;


if (	P_Payment_line_rec.CREDIT_CARD_CODE is NOT NULL
	AND P_Payment_line_rec.CREDIT_CARD_CODE <> FND_API.G_MISS_CHAR ) THEN

	IF (P_Payment_header_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD') THEN

	      aso_debug_pub.add('Before opening Cursor C_CREDIT_CARD_TYPE--Line Level', 1, 'Y');
		OPEN C_CREDIT_CARD_TYPE(P_Payment_line_rec.CREDIT_CARD_CODE) ;                   --line Level
	      aso_debug_pub.add('Before fetching Cursor C_CREDIT_CARD_TYPE--Line Level', 1, 'Y');
		FETCH C_CREDIT_CARD_TYPE INTO l_data_exists ;

		IF C_CREDIT_CARD_TYPE%FOUND THEN
			x_Payment_line_rec.CREDIT_CARD_CODE	 := P_Payment_line_rec.CREDIT_CARD_CODE;
		ELSE
			x_Payment_line_rec.CREDIT_CARD_CODE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_CREDIT_CARD_TYPE--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before Closing Cursor C_CREDIT_CARD_TYPE--Line Level', 1, 'Y');
		CLOSE C_CREDIT_CARD_TYPE;
	      aso_debug_pub.add('After Closing Cursor C_CREDIT_CARD_TYPE--Line Level', 1, 'Y');

	ELSE
		x_Payment_line_rec.CREDIT_CARD_CODE := NULL ;
                aso_debug_pub.add('Credit card code needs to be null if payment type is not CREDIT_CARD.', 1, 'Y');
	END IF ;

END IF;

--Demand Class

if (	P_Shipment_header_rec.DEMAND_CLASS_CODE is NOT NULL
	AND P_Shipment_header_rec.DEMAND_CLASS_CODE <> FND_API.G_MISS_CHAR) THEN
	      aso_debug_pub.add('Before opening Cursor C_DEMAND_CLASS--Header Level', 1, 'Y');

		OPEN C_DEMAND_CLASS(P_Shipment_header_rec.DEMAND_CLASS_CODE) ;                   --Header Level
		aso_debug_pub.add('Before fetching Cursor C_DEMAND_CLASS--Header Level', 1, 'Y');
		FETCH C_DEMAND_CLASS INTO l_data_exists ;

		IF C_DEMAND_CLASS%FOUND THEN
			x_Shipment_header_rec.DEMAND_CLASS_CODE	 := P_Shipment_header_rec.DEMAND_CLASS_CODE ;
		ELSE
			x_Shipment_header_rec.DEMAND_CLASS_CODE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_DEMAND_CLASS--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_DEMAND_CLASS', TRUE);
			FND_MSG_PUB.ADD;
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('before Closing Cursor C_DEMAND_CLASS--Header Level', 1, 'Y');
		CLOSE C_DEMAND_CLASS;
	      aso_debug_pub.add('After Closing Cursor C_DEMAND_CLASS--Header Level', 1, 'Y');

end if;

if (	P_Shipment_line_rec.DEMAND_CLASS_CODE is NOT NULL
	AND P_Shipment_line_rec.DEMAND_CLASS_CODE <> FND_API.G_MISS_CHAR) THEN
	      aso_debug_pub.add('Before opening Cursor C_DEMAND_CLASS--Line Level', 1, 'Y');

		OPEN C_DEMAND_CLASS(P_Shipment_line_rec.DEMAND_CLASS_CODE) ;                      --Line Level
		aso_debug_pub.add('Before fetching Cursor C_DEMAND_CLASS--Line Level', 1, 'Y');
		FETCH C_DEMAND_CLASS INTO l_data_exists ;

		IF C_DEMAND_CLASS%FOUND THEN
			x_Shipment_line_rec.DEMAND_CLASS_CODE	 := P_Shipment_line_rec.DEMAND_CLASS_CODE ;
		ELSE
			x_Shipment_line_rec.DEMAND_CLASS_CODE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_DEMAND_CLASS--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before Closing Cursor C_DEMAND_CLASS--Line Level', 1, 'Y');
		CLOSE C_DEMAND_CLASS;
	      aso_debug_pub.add('After Closing Cursor C_DEMAND_CLASS--Line Level', 1, 'Y');

END IF;

--Request Date Type

if (	P_Shipment_header_rec.REQUEST_DATE_TYPE is NOT NULL
	AND P_Shipment_header_rec.REQUEST_DATE_TYPE <> FND_API.G_MISS_CHAR) THEN

	      aso_debug_pub.add('Before opening Cursor C_REQUEST_DATE_TYPE--Header Level', 1, 'Y');

		OPEN C_REQUEST_DATE_TYPE(p_Shipment_header_rec.REQUEST_DATE_TYPE) ;                   --Header Level
	      aso_debug_pub.add('Before fetching Cursor C_REQUEST_DATE_TYPE--Header Level', 1, 'Y');
		FETCH C_REQUEST_DATE_TYPE INTO l_data_exists ;

		IF C_REQUEST_DATE_TYPE%FOUND THEN
			x_Shipment_header_rec.REQUEST_DATE_TYPE	 := p_Shipment_header_rec.REQUEST_DATE_TYPE ;
		ELSE
			x_Shipment_header_rec.REQUEST_DATE_TYPE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_REQUEST_DATE_TYPE--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_RQSTD_DATE_TYPE', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before closing Cursor C_REQUEST_DATE_TYPE--Header Level', 1, 'Y');
		CLOSE C_REQUEST_DATE_TYPE;
	      aso_debug_pub.add('After Closing Cursor C_REQUEST_DATE_TYPE--Header Level', 1, 'Y');

end if;

if (	P_Shipment_line_rec.REQUEST_DATE_TYPE is NOT NULL
	AND P_Shipment_line_rec.REQUEST_DATE_TYPE <> FND_API.G_MISS_CHAR) THEN

	      aso_debug_pub.add('Before opening Cursor REQUEST_DATE_TYPE--Line Level', 1, 'Y');

		OPEN C_REQUEST_DATE_TYPE(p_Shipment_line_rec.REQUEST_DATE_TYPE) ;                   --Line Level
	      aso_debug_pub.add('Before fetching Cursor REQUEST_DATE_TYPE--Line Level', 1, 'Y');
		FETCH C_REQUEST_DATE_TYPE INTO l_data_exists ;

		IF C_REQUEST_DATE_TYPE%FOUND THEN
			x_Shipment_line_rec.REQUEST_DATE_TYPE	 := p_Shipment_line_rec.REQUEST_DATE_TYPE ;
		ELSE
			x_Shipment_line_rec.REQUEST_DATE_TYPE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_REQUEST_DATE_TYPE--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before Closing Cursor REQUEST_DATE_TYPE--Line Level', 1, 'Y');
		CLOSE C_REQUEST_DATE_TYPE;
	      aso_debug_pub.add('After Closing Cursor REQUEST_DATE_TYPE--Line Level', 1, 'Y');

END IF;

--Request Date

if (	P_Shipment_header_rec.REQUEST_DATE is NOT NULL
	AND P_Shipment_header_rec.REQUEST_DATE <> FND_API.G_MISS_DATE) THEN

	      aso_debug_pub.add('Before opening Cursor C_REQUEST_DATE--Header Level', 1, 'Y');
		OPEN C_REQUEST_DATE(p_Shipment_header_rec.REQUEST_DATE) ;                   --Header Level
	      aso_debug_pub.add('Before fetching Cursor C_REQUEST_DATE--Header Level', 1, 'Y');
		FETCH C_REQUEST_DATE INTO l_data_exists ;

		IF C_REQUEST_DATE%FOUND THEN
			x_Shipment_header_rec.REQUEST_DATE	 := p_Shipment_header_rec.REQUEST_DATE ;
		ELSE
			x_Shipment_header_rec.REQUEST_DATE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_REQUEST_DATE--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_REQUESTED_DATE', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('before Closing Cursor C_REQUEST_DATE--Header Level', 1, 'Y');
		CLOSE C_REQUEST_DATE;
	      aso_debug_pub.add('After Closing Cursor C_REQUEST_DATE--Header Level', 1, 'Y');

end if;

if (	P_Shipment_line_rec.REQUEST_DATE is NOT NULL
	AND P_Shipment_line_rec.REQUEST_DATE <> FND_API.G_MISS_DATE) THEN

	      aso_debug_pub.add('Before opening Cursor C_REQUEST_DATE--Line Level', 1, 'Y');

		OPEN C_REQUEST_DATE(p_Shipment_line_rec.REQUEST_DATE) ;                   --Line Level
	      aso_debug_pub.add('Before fetching Cursor C_REQUEST_DATE--Line Level', 1, 'Y');
		FETCH C_REQUEST_DATE INTO l_data_exists ;

		IF C_REQUEST_DATE%FOUND THEN
			x_Shipment_line_rec.REQUEST_DATE	 := p_Shipment_line_rec.REQUEST_DATE ;
		ELSE
			x_Shipment_line_rec.REQUEST_DATE := NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_REQUEST_DATE--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      aso_debug_pub.add('Before closing Cursor C_REQUEST_DATE--Line Level', 1, 'Y');
		CLOSE C_REQUEST_DATE;
	      aso_debug_pub.add('After Closing Cursor C_REQUEST_DATE--Line Level', 1, 'Y');

END IF;

--Operating Unit


if (	p_quote_header_rec.ORG_ID is NOT NULL
	AND p_quote_header_rec.ORG_ID <> FND_API.G_MISS_NUM) THEN

	      aso_debug_pub.add('Before opening Cursor C_OPERATING_UNIT--Header Level', 1, 'Y');

		OPEN C_OPERATING_UNIT(p_quote_header_rec.ORG_ID) ;                   --Header Level
	      aso_debug_pub.add('Before fetching Cursor C_OPERATING_UNIT--Header Level', 1, 'Y');

		FETCH C_OPERATING_UNIT INTO l_data_exists ;

		IF C_OPERATING_UNIT%FOUND THEN
			if l_data_exists is NOT NULL then
				x_quote_header_rec.ORG_ID	 := p_quote_header_rec.ORG_ID ;
			else
				x_quote_header_rec.ORG_ID	 := NULL;

				FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_OPERATING_UNIT', TRUE);
				FND_MSG_PUB.ADD;
			end if;
		ELSE
			x_quote_header_rec.ORG_ID	:= NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_OPERATING_UNIT', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_OPERATING_UNIT', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	        aso_debug_pub.add('Before closing Cursor C_OPERATING_UNIT--Header Level', 1, 'Y');
		CLOSE C_OPERATING_UNIT;
		aso_debug_pub.add('After Closing Cursor C_CHARGE_PERIODICITY_CODE--Header Level', 1, 'Y');
end if;

if (	p_quote_line_rec.ORG_ID is NOT NULL
	AND p_quote_line_rec.ORG_ID <> FND_API.G_MISS_NUM) THEN

	      aso_debug_pub.add('Before opening Cursor C_OPERATING_UNIT--Line Level', 1, 'Y');
		OPEN C_OPERATING_UNIT(p_quote_line_rec.ORG_ID) ;                       --Line Level
		aso_debug_pub.add('Before fetching Cursor C_OPERATING_UNIT--Line Level', 1, 'Y');
		FETCH C_OPERATING_UNIT INTO l_data_exists ;

		IF C_OPERATING_UNIT%FOUND THEN
			if l_data_exists is NOT NULL then
				x_quote_line_rec.ORG_ID	 := p_quote_line_rec.ORG_ID ;
			else
				x_quote_line_rec.ORG_ID	 := NULL;
			end if;
		ELSE
			x_quote_line_rec.ORG_ID	:= NULL ;
                        aso_debug_pub.add('No Data Found for Cursor...C_OPERATING_UNIT--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		aso_debug_pub.add('before Closing Cursor C_CHARGE_PERIODICITY_CODE--Line Level', 1, 'Y');
		CLOSE C_OPERATING_UNIT;
		aso_debug_pub.add('After Closing Cursor C_CHARGE_PERIODICITY_CODE--Line Level', 1, 'Y');

END IF;

--Charged Periodicity

if (	p_quote_line_rec.CHARGE_PERIODICITY_CODE is NOT NULL
	AND p_quote_line_rec.CHARGE_PERIODICITY_CODE <> FND_API.G_MISS_CHAR) THEN

	if (	l_periodicity_profile is NOT NULL
		AND l_periodicity_profile <> FND_API.G_MISS_CHAR) THEN
			aso_debug_pub.add('Before opening Cursor C_CHARGE_PERIODICITY_CODE', 1, 'Y');

			OPEN C_CHARGE_PERIODICITY_CODE(p_quote_line_rec.CHARGE_PERIODICITY_CODE,l_periodicity_profile) ;   --Line Level Only

			aso_debug_pub.add('Before fetching Cursor C_CHARGE_PERIODICITY_CODE', 1, 'Y');
			FETCH C_CHARGE_PERIODICITY_CODE INTO l_data_exists ;

			IF C_CHARGE_PERIODICITY_CODE%FOUND THEN
				x_quote_line_rec.CHARGE_PERIODICITY_CODE	 := p_quote_line_rec.CHARGE_PERIODICITY_CODE ;
			ELSE
				x_quote_line_rec.CHARGE_PERIODICITY_CODE	:= NULL ;
				aso_debug_pub.add('No Data Found for Cursor...CHARGE_PERIODICITY_CODE', 1, 'Y');
				--x_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
			aso_debug_pub.add('Before closing Cursor C_CHARGE_PERIODICITY_CODE', 1, 'Y');
			CLOSE C_CHARGE_PERIODICITY_CODE;
			aso_debug_pub.add('After Closing  Cursor C_CHARGE_PERIODICITY_CODE', 1, 'Y');

	END IF;
END IF;

--Auotmatic Pricing

if (	p_quote_header_rec.AUTOMATIC_PRICE_FLAG is NOT NULL
	AND p_quote_header_rec.AUTOMATIC_PRICE_FLAG <> FND_API.G_MISS_CHAR) THEN
		aso_debug_pub.add('Before opening Cursor C_AUTOMATIC_PRICING', 1, 'Y');

		OPEN C_AUTOMATIC_PRICING(p_quote_header_rec.AUTOMATIC_PRICE_FLAG) ;                       --Header Level
		aso_debug_pub.add('Before fetching Cursor C_AUTOMATIC_PRICING', 1, 'Y');
		FETCH C_AUTOMATIC_PRICING INTO l_data_exists ;

		IF C_AUTOMATIC_PRICING%FOUND THEN
			x_quote_header_rec.AUTOMATIC_PRICE_FLAG	 := p_quote_header_rec.AUTOMATIC_PRICE_FLAG ;
		ELSE
			x_quote_header_rec.AUTOMATIC_PRICE_FLAG	:= NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_AUTOMATIC_PRICING', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_AUTO_PRICING', TRUE);
			FND_MSG_PUB.ADD;
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		aso_debug_pub.add('Before closing Cursor C_AUTOMATIC_PRICING', 1, 'Y');
		CLOSE C_AUTOMATIC_PRICING;
		aso_debug_pub.add('After Closing Cursor C_AUTOMATIC_PRICING', 1, 'Y');

END IF;

--Auotmatic TAX

if (	p_quote_header_rec.AUTOMATIC_TAX_FLAG is NOT NULL
	AND p_quote_header_rec.AUTOMATIC_TAX_FLAG <> FND_API.G_MISS_CHAR) THEN

		aso_debug_pub.add('Before opening Cursor C_AUTOMATIC_TAX', 1, 'Y');

		OPEN C_AUTOMATIC_TAX(p_quote_header_rec.AUTOMATIC_TAX_FLAG) ;                       --Header Level
		aso_debug_pub.add('Before fetching Cursor C_AUTOMATIC_TAX', 1, 'Y');
		FETCH C_AUTOMATIC_TAX INTO l_data_exists ;

		IF C_AUTOMATIC_TAX%FOUND THEN
			x_quote_header_rec.AUTOMATIC_TAX_FLAG	 := p_quote_header_rec.AUTOMATIC_TAX_FLAG ;
		ELSE
			x_quote_header_rec.AUTOMATIC_TAX_FLAG	:= NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_AUTOMATIC_TAX', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_AUTOMATIC_TAX', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		aso_debug_pub.add('Before closing Cursor C_AUTOMATIC_TAX', 1, 'Y');
		CLOSE C_AUTOMATIC_TAX;
		aso_debug_pub.add('After Closing Cursor C_AUTOMATIC_TAX.', 1, 'Y');


END IF;

--Payment Type

if (	P_Payment_header_rec.PAYMENT_TYPE_CODE is NOT NULL
	AND P_Payment_header_rec.PAYMENT_TYPE_CODE <> FND_API.G_MISS_CHAR) THEN

		aso_debug_pub.add('Before opening C_PAYMENT_TYPE--Header Level', 1, 'Y');

		OPEN C_PAYMENT_TYPE(P_Payment_header_rec.PAYMENT_TYPE_CODE) ;          --Header Level
		aso_debug_pub.add('Before fetching C_PAYMENT_TYPE--Header Level', 1, 'Y');
		FETCH C_PAYMENT_TYPE INTO l_data_exists ;

		IF C_PAYMENT_TYPE%FOUND THEN
			x_Payment_header_rec.PAYMENT_TYPE_CODE	 := P_Payment_header_rec.PAYMENT_TYPE_CODE ;
		ELSE
			x_Payment_header_rec.PAYMENT_TYPE_CODE := NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_PAYMENT_TYPE--Header Level', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_PAYMENT_TYPE', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		aso_debug_pub.add('before  Closing Cursor C_PAYMENT_TYPE--Header Level', 1, 'Y');
		CLOSE C_PAYMENT_TYPE;
		aso_debug_pub.add('After  Closing Cursor C_PAYMENT_TYPE--Header Level', 1, 'Y');

end if;

if (	P_Payment_line_rec.PAYMENT_TYPE_CODE is NOT NULL
	AND P_Payment_line_rec.PAYMENT_TYPE_CODE <> FND_API.G_MISS_CHAR) THEN

		aso_debug_pub.add('Before opening cursor C_PAYMENT_TYPE--Line Level', 1, 'Y');

		OPEN C_PAYMENT_TYPE(P_Payment_line_rec.PAYMENT_TYPE_CODE) ;               --Line Level
		aso_debug_pub.add('Before fetching cursor C_PAYMENT_TYPE--Line Level', 1, 'Y');

		FETCH C_PAYMENT_TYPE INTO l_data_exists ;

		IF C_PAYMENT_TYPE%FOUND THEN
			x_Payment_line_rec.PAYMENT_TYPE_CODE	 := P_Payment_line_rec.PAYMENT_TYPE_CODE ;
		ELSE
			x_Payment_line_rec.PAYMENT_TYPE_CODE := NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_PAYMENT_TYPE--Line Level', 1, 'Y');
			--x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		aso_debug_pub.add('Before closing cursor C_PAYMENT_TYPE--Line Level', 1, 'Y');
		CLOSE C_PAYMENT_TYPE;
		aso_debug_pub.add('After Closing cursor C_PAYMENT_TYPE--Line Level', 1, 'Y');


END IF;

if (	p_quote_header_rec.SALES_CHANNEL_CODE is NOT NULL
	AND p_quote_header_rec.SALES_CHANNEL_CODE <> FND_API.G_MISS_CHAR) THEN

		aso_debug_pub.add('Before opening Cursor..C_SALESCHANNEL', 1, 'Y');

		OPEN C_SALESCHANNEL(p_quote_header_rec.SALES_CHANNEL_CODE) ;  -- Sales Channel(Header)
		aso_debug_pub.add('Before fetching Cursor..C_SALESCHANNEL', 1, 'Y');

		FETCH C_SALESCHANNEL INTO l_data_exists ;


		IF C_SALESCHANNEL%FOUND THEN
			x_quote_header_rec.SALES_CHANNEL_CODE := p_quote_header_rec.SALES_CHANNEL_CODE ;
		ELSE
			x_quote_header_rec.SALES_CHANNEL_CODE := NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_SALESCHANNEL', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_SALES_CHANNEL', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;

		END IF;
		aso_debug_pub.add('Before closing Cursor..C_SALESCHANNEL', 1, 'Y');
		CLOSE C_SALESCHANNEL;
		aso_debug_pub.add('After Closing Cursor..C_SALESCHANNEL', 1, 'Y');


END IF;
-- ============                 Currency-queries (Start)                   ====================

if (	p_quote_header_rec.CURRENCY_CODE is NOT NULL
	AND p_quote_header_rec.CURRENCY_CODE <> FND_API.G_MISS_CHAR) THEN

	if ( p_quote_header_rec.PRICE_LIST_ID is NOT NULL
	     AND p_quote_header_rec.PRICE_LIST_ID <> FND_API.G_MISS_NUM ) THEN

		aso_debug_pub.add('Before opening Cursor..C_QOTHDDET_CURRENCY_NOT_NULL', 1, 'Y');

		OPEN C_QOTHDDET_CURRENCY_NOT_NULL(p_quote_header_rec.CURRENCY_CODE,p_quote_header_rec.PRICE_LIST_ID) ; -- Header Record
		aso_debug_pub.add('Before fetching Cursor..C_QOTHDDET_CURRENCY_NOT_NULL', 1, 'Y');

		FETCH C_QOTHDDET_CURRENCY_NOT_NULL INTO l_data_exists ;
		IF C_QOTHDDET_CURRENCY_NOT_NULL%FOUND THEN
			x_quote_header_rec.CURRENCY_CODE := p_quote_header_rec.CURRENCY_CODE;
		ELSE
			x_quote_header_rec.CURRENCY_CODE := NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_QOTHDDET_CURRENCY_NOT_NULL', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_CURRENCY', TRUE);
			FND_MSG_PUB.ADD;

			--x_return_status := FND_API.G_RET_STS_ERROR;

		END IF;
		aso_debug_pub.add('Before closing Cursor..C_QOTHDDET_CURRENCY_NOT_NULL', 1, 'Y');

		CLOSE C_QOTHDDET_CURRENCY_NOT_NULL;

		aso_debug_pub.add('After closing Cursor..C_QOTHDDET_CURRENCY_NOT_NULL', 1, 'Y');

	ELSE
		aso_debug_pub.add('Before opening Cursor..C_QOTHDDET_CURRENCY_NULL', 1, 'Y');

		OPEN C_QOTHDDET_CURRENCY_NULL(p_quote_header_rec.CURRENCY_CODE)   ; --Header Record
		aso_debug_pub.add('Before fetching Cursor..C_QOTHDDET_CURRENCY_NULL', 1, 'Y');

		FETCH C_QOTHDDET_CURRENCY_NULL INTO l_data_exists ;
		IF C_QOTHDDET_CURRENCY_NULL%FOUND THEN
			x_quote_header_rec.CURRENCY_CODE := p_quote_header_rec.CURRENCY_CODE;
		ELSE
			x_quote_header_rec.CURRENCY_CODE := NULL ;
			aso_debug_pub.add('No Data Found for Cursor...C_QOTHDDET_CURRENCY_NULL', 1, 'Y');

			FND_MESSAGE.SET_NAME('ASO', 'ASO_DFLT_VLDN_ERR_MSG');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', 'ASO_DFLT_VLDN_CURRENCY', TRUE);
			FND_MSG_PUB.ADD;
			--x_return_status := FND_API.G_RET_STS_ERROR;

		END IF;
		aso_debug_pub.add('Before closing Cursor..C_QOTHDDET_CURRENCY_NULL', 1, 'Y');
		CLOSE C_QOTHDDET_CURRENCY_NULL;
		aso_debug_pub.add('After Closing Cursor..C_QOTHDDET_CURRENCY_NULL', 1, 'Y');

	END IF;
END IF;

--				                  TCA Calls Start

--1.                                   ***Validate Contact - Header and Line Level***

--Validate Contact(Header/Bill)
if (	p_quote_header_rec.invoice_to_party_id is NOT NULL
	AND p_quote_header_rec.invoice_to_party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Header/Bill)', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_quote_header_rec.INVOICE_TO_PARTY_ID,
			 p_cust_party_id=>p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID,
			 p_flag=>'BILL',
			 p_header=>'Y'
			 );
aso_debug_pub.add('After Calling Validate Contact(Header/Bill)', 1, 'Y');
END IF ;



--Validate Contact(Header/Ship)
if (	p_shipment_header_rec.ship_to_party_id is NOT NULL
	AND p_shipment_header_rec.ship_to_party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Header/Ship)', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_shipment_header_rec.SHIP_TO_PARTY_ID,
			 p_cust_party_id=>p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID,
			 p_flag=>'SHIP',
			 p_header=>'Y'
			 );
aso_debug_pub.add('After Calling Validate Contact(Header/Ship)', 1, 'Y');
END IF ;

--Validate Contact(Header/End)
if (	p_quote_header_rec.end_customer_party_id is NOT NULL
	AND p_quote_header_rec.end_customer_party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Header/End)', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_quote_header_rec.END_CUSTOMER_PARTY_ID,
			 p_cust_party_id=>p_quote_header_rec.END_CUSTOMER_CUST_PARTY_ID,
			 p_flag=>'END',
			 p_header=>'Y'
			);
aso_debug_pub.add('After Calling Validate Contact(Header/End)', 1, 'Y');
END IF ;

--Validate Contact(Header/SOLD)
if (	p_quote_header_rec.party_id is NOT NULL
	AND p_quote_header_rec.party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Header/SOLD)', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_quote_header_rec.PARTY_ID,
			 p_cust_party_id=>p_quote_header_rec.CUST_PARTY_ID,
			 p_flag=>'SOLD',
			 p_header=>'Y'
			);
aso_debug_pub.add('After Calling Validate Contact(Header/SOLD)', 1, 'Y');
END IF ;

--Validate Contact(Line/Bill)
if (	p_quote_line_rec.invoice_to_party_id  is NOT NULL
	AND p_quote_line_rec.invoice_to_party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Line/Bill)', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_quote_line_rec.INVOICE_TO_PARTY_ID,
			 p_cust_party_id=>p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID,
			 p_flag=>'BILL',
			 p_header=>'N'
			);
aso_debug_pub.add('After Calling Validate Contact(Line/Bill)', 1, 'Y');

END IF ;

--Validate Contact(Line/Ship)
if (	p_shipment_line_rec.ship_to_party_id  is NOT NULL
	AND p_shipment_line_rec.ship_to_party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Line/Ship))', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_shipment_line_rec.ship_to_party_id,
			 p_cust_party_id=>p_shipment_line_rec.ship_to_cust_party_id,
			 p_flag=>'SHIP',
			 p_header=>'N'
			);
aso_debug_pub.add('Before Calling Validate Contact(Line/Ship))', 1, 'Y');

END IF;

 --Validate Contact(Line/End)
if (	p_quote_line_rec.end_customer_party_id  is NOT NULL
	AND p_quote_line_rec.end_customer_party_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Contact(Line/End)', 1, 'Y');

	VALIDATE_CONTACT(p_party_id=>p_quote_line_rec.end_customer_party_id,
			 p_cust_party_id=>p_quote_line_rec.end_customer_cust_party_id,
			 p_flag=>'END',
			 p_header=>'N'
			);
aso_debug_pub.add('After Calling Validate Contact(Line/End)', 1, 'Y');

END IF ;


--2.                                   ***Validate Phone - Header Level Only***

if (	p_quote_header_rec.phone_id  is NOT NULL
	AND p_quote_header_rec.phone_id <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Phone', 1, 'Y');

	VALIDATE_PHONE(p_phone_id => p_quote_header_rec.phone_id,
		       p_party_id => p_quote_header_rec.party_id,
		       p_cust_party_id => p_quote_header_rec.cust_party_id
		       );
aso_debug_pub.add('After Calling Validate Phone', 1, 'Y');

END IF ;


--3.                                   ***Validate Address - Header and Line Level***

--Validate Address(Header/Bill)
if (	p_quote_header_rec.INVOICE_TO_PARTY_SITE_ID  is NOT NULL
	AND p_quote_header_rec.INVOICE_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Address(Header/Bill)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_quote_header_rec.INVOICE_TO_PARTY_SITE_ID,
			 p_party_id =>  p_quote_header_rec.INVOICE_TO_PARTY_ID,
			 p_cust_party_id =>p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID,
			 p_flag	    =>'BILL',
			 p_header   => 'Y'
			);
aso_debug_pub.add('After Calling Validate Address(Header/Bill)', 1, 'Y');

END IF ;

--Validate Address(Header/Ship)

if (	p_shipment_header_rec.SHIP_TO_PARTY_SITE_ID  is NOT NULL
	AND p_shipment_header_rec.SHIP_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Address(Header/Ship)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_shipment_header_rec.SHIP_TO_PARTY_SITE_ID,
			 p_party_id =>  p_shipment_header_rec.SHIP_TO_PARTY_ID,
			 p_cust_party_id =>p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID,
			 p_flag	    =>'SHIP',
			 p_header   => 'Y'
			);

aso_debug_pub.add('After Calling Validate Address(Header/Ship)', 1, 'Y');

END IF ;

--Validate Address(Header/end)
if (	p_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID  is NOT NULL
	AND p_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Address(Header/end)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_quote_header_rec.END_CUSTOMER_PARTY_SITE_ID,
			 p_party_id =>  p_quote_header_rec.END_CUSTOMER_PARTY_ID,
			 p_cust_party_id =>p_quote_header_rec.END_CUSTOMER_CUST_PARTY_ID,
			 p_flag	    =>'END',
			 p_header   => 'Y'
			);
aso_debug_pub.add('After Calling Validate Address(Header/end)', 1, 'Y');

END IF ;



--Validate Address(Header/SOLD)
if (	p_quote_header_rec.SOLD_TO_PARTY_SITE_ID  is NOT NULL
	AND p_quote_header_rec.SOLD_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Address(Header/SOLD)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_quote_header_rec.SOLD_TO_PARTY_SITE_ID,
			 p_party_id =>  p_quote_header_rec.party_id,
			 p_cust_party_id =>p_quote_header_rec.cust_party_id,
			 p_flag	    =>'SOLD',
			 p_header   => 'Y'
			);
aso_debug_pub.add('After Calling Validate Address(Header/SOLD)', 1, 'Y');
END IF ;


--Validate Address(Line/Bill)
if (	p_quote_line_rec.INVOICE_TO_PARTY_SITE_ID  is NOT NULL
	AND p_quote_line_rec.INVOICE_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN
aso_debug_pub.add('Before Calling Validate Address(Line/Bill)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_quote_line_rec.INVOICE_TO_PARTY_SITE_ID,
			 p_party_id =>  p_quote_line_rec.INVOICE_TO_PARTY_ID,
			 p_cust_party_id =>p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID,
			 p_flag	    =>'BILL',
			 p_header   => 'N'
			);
aso_debug_pub.add('After Calling Validate Address(Line/Bill)', 1, 'Y');
END IF;

--Validate Address(Line/Ship)
if (	p_shipment_line_rec.SHIP_TO_PARTY_SITE_ID  is NOT NULL
	AND p_shipment_line_rec.SHIP_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Address(Line/Ship)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_shipment_line_rec.SHIP_TO_PARTY_SITE_ID,
			 p_party_id =>  p_shipment_line_rec.SHIP_TO_PARTY_ID,
			 p_cust_party_id =>p_shipment_line_rec.SHIP_TO_CUST_PARTY_ID,
			 p_flag	    =>'SHIP',
			 p_header   => 'N'
			);
aso_debug_pub.add('End Calling Validate Address(Line/Ship)', 1, 'Y');
END IF;

--Validate Address(Line/end)
if (	p_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID  is NOT NULL
	AND p_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Address(Line/end)', 1, 'Y');

	VALIDATE_ADDRESS(p_party_site_id => p_quote_line_rec.END_CUSTOMER_PARTY_SITE_ID,
			 p_party_id =>  p_quote_line_rec.END_CUSTOMER_PARTY_ID,
			 p_cust_party_id =>p_quote_line_rec.END_CUSTOMER_CUST_PARTY_ID,
			 p_flag	    =>'END',
			 p_header   => 'N'
			);
aso_debug_pub.add('After Calling Validate Address(Line/end)', 1, 'Y');

END IF;


--4.                                   ***Validate Customer - Header and Line Level***

--Validate Customer(Header/Sold)
if (	P_QUOTE_HEADER_REC.CUST_PARTY_ID  is NOT NULL
	AND P_QUOTE_HEADER_REC.CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Customer(Header/Sold)', 1, 'Y');

	VALIDATE_CUSTOMER(p_cust_party_id => p_quote_header_rec.cust_party_id,
			  p_resource_id  => p_quote_header_rec.resource_id,
			  p_flag => 'SOLD',
			  p_header=> 'Y'
			  );
aso_debug_pub.add('After Calling Validate Customer(Header/Sold)', 1, 'Y');

END IF;


--Validate Customer(Header/End)
if (	P_QUOTE_HEADER_REC.END_CUSTOMER_CUST_PARTY_ID  is NOT NULL
	AND P_QUOTE_HEADER_REC.END_CUSTOMER_CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Customer(Header/End)', 1, 'Y');

	VALIDATE_CUSTOMER(p_cust_party_id => p_quote_header_rec.end_customer_cust_party_id,
			  p_resource_id  => p_quote_header_rec.resource_id,
			  p_flag => 'END',
			  p_header=> 'Y'
			  );
aso_debug_pub.add('After Calling Validate Customer(Header/End)', 1, 'Y');

END IF;


--Validate Customer(Line/End)
if (	 P_QUOTE_LINE_REC.END_CUSTOMER_CUST_PARTY_ID  is NOT NULL
	AND  P_QUOTE_LINE_REC.END_CUSTOMER_CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

aso_debug_pub.add('Before Calling Validate Customer(Line/End)', 1, 'Y');

VALIDATE_CUSTOMER(p_cust_party_id => p_quote_line_rec.end_customer_cust_party_id,
		  p_resource_id  => p_quote_header_rec.resource_id,
	          p_flag => 'END',
		  p_header=> 'N'
		  );
aso_debug_pub.add('After Calling Validate Customer(Line/End)', 1, 'Y');

END IF;

--5.                                   ***Validate Bill Ship Customer***

--Validate Bill Ship Customer (Header/Bill)
if (	 p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID  is NOT NULL
	AND  p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before calling Validate Bill Ship Customer (Header/Bill)', 1, 'Y');

	VALIDATE_BILL_SHIP_CUSTOMER(p_cust_party_id =>p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID,
			            p_cust_acct_id  =>p_quote_header_rec.CUST_ACCOUNT_ID,							                    p_resource_id   =>p_quote_header_rec.resource_id,
				    p_flag	    =>'BILL',
				    p_header	    => 'Y'
				    );
	aso_debug_pub.add('After calling Validate Bill Ship Customer (Header/Bill)', 1, 'Y');

END IF;



--Validate Bill Ship Customer (Header/Ship)
if (	 p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID  is NOT NULL
	AND  p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Customer (Header/Ship)', 1, 'Y');

VALIDATE_BILL_SHIP_CUSTOMER(p_cust_party_id =>p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID,
			    p_cust_acct_id  =>p_quote_header_rec.CUST_ACCOUNT_ID,							                    p_resource_id   =>p_quote_header_rec.resource_id,
			    p_flag	    =>'SHIP',
			    p_header	    => 'Y'
			   );

	aso_debug_pub.add('After Calling Validate Bill Ship Customer (Header/Ship)', 1, 'Y');
END IF;


--Validate Bill Ship Customer (Line/Bill)
if (	p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID  is NOT NULL
	AND  p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Customer (Line/Bill)', 1, 'Y');

VALIDATE_BILL_SHIP_CUSTOMER(p_cust_party_id =>p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID,
			    p_cust_acct_id  =>p_quote_header_rec.CUST_ACCOUNT_ID,							                    p_resource_id   =>p_quote_header_rec.resource_id,
			    p_flag	    =>'BILL',
			    p_header	    => 'N'
			    );

	aso_debug_pub.add('After Calling Validate Bill Ship Customer (Line/Bill)', 1, 'Y');
END IF;


--Validate Bill Ship Customer (Line/Ship)
if (	p_shipment_line_rec.SHIP_TO_CUST_PARTY_ID  is NOT NULL
	AND  p_shipment_line_rec.SHIP_TO_CUST_PARTY_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Customer (Line/Ship)', 1, 'Y');

VALIDATE_BILL_SHIP_CUSTOMER(p_cust_party_id =>p_shipment_line_rec.SHIP_TO_CUST_PARTY_ID,
			    p_cust_acct_id  =>p_quote_header_rec.CUST_ACCOUNT_ID,							                    p_resource_id   =>p_quote_header_rec.resource_id,
			    p_flag	    =>'SHIP',
			    p_header	    => 'N'
			   );

	aso_debug_pub.add('After Calling Validate Bill Ship Customer (Line/Ship)', 1, 'Y');
END IF;

--6.                                   ***Validate Bill Ship Account***

--Validate Bill Ship Account(Header/Bill)
if (	p_quote_header_rec.INVOICE_TO_CUST_ACCOUNT_ID  is NOT NULL
	AND  p_quote_header_rec.INVOICE_TO_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Account(Header/Bill)', 1, 'Y');

VALIDATE_BILL_SHIP_ACCOUNT(p_cust_acct_id  =>p_quote_header_rec.INVOICE_TO_CUST_ACCOUNT_ID,
			   p_cust_party_id =>p_quote_header_rec.INVOICE_TO_CUST_PARTY_ID,
			   p_resource_id   =>p_quote_header_rec.resource_id,
			   p_sold_to_cust_acct_id=>p_quote_header_rec.CUST_ACCOUNT_ID,
			   p_flag	    =>'BILL',
			   p_header	    => 'Y'
			  );
	aso_debug_pub.add('After Calling Validate Bill Ship Account(Header/Bill)', 1, 'Y');
END IF;


--Validate Bill Ship Account(Header/Ship)
if (	p_shipment_header_rec.SHIP_TO_CUST_ACCOUNT_ID  is NOT NULL
	AND  p_shipment_header_rec.SHIP_TO_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Account(Header/Ship)', 1, 'Y');


VALIDATE_BILL_SHIP_ACCOUNT(p_cust_acct_id  =>p_shipment_header_rec.SHIP_TO_CUST_ACCOUNT_ID,
			   p_cust_party_id =>p_shipment_header_rec.SHIP_TO_CUST_PARTY_ID,
			   p_resource_id   =>p_quote_header_rec.resource_id,
			   p_sold_to_cust_acct_id=>p_quote_header_rec.CUST_ACCOUNT_ID,
			   p_flag	    =>'SHIP',
			   p_header	    => 'Y'
			  );
	aso_debug_pub.add('After Calling Validate Bill Ship Account(Header/Ship)', 1, 'Y');
END IF;



--Validate Bill Ship Account(Line/Bill)
if (	p_quote_line_rec.INVOICE_TO_CUST_ACCOUNT_ID  is NOT NULL
	AND  p_quote_line_rec.INVOICE_TO_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Account(Line/Bill)', 1, 'Y');

VALIDATE_BILL_SHIP_ACCOUNT(p_cust_acct_id  =>p_quote_line_rec.INVOICE_TO_CUST_ACCOUNT_ID,
			   p_cust_party_id =>p_quote_line_rec.INVOICE_TO_CUST_PARTY_ID,
			   p_resource_id   =>p_quote_header_rec.resource_id,
			   p_sold_to_cust_acct_id=>p_quote_header_rec.CUST_ACCOUNT_ID,
			   p_flag	    =>'BILL',
			   p_header	    => 'N'
			  );
	aso_debug_pub.add('After Calling Validate Bill Ship Account(Line/Bill)', 1, 'Y');
END IF;



--Validate Bill Ship Account(Line/Ship)
if (	p_shipment_line_rec.SHIP_TO_CUST_ACCOUNT_ID  is NOT NULL
	AND  p_shipment_line_rec.SHIP_TO_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Bill Ship Account(Line/Ship)', 1, 'Y');

VALIDATE_BILL_SHIP_ACCOUNT(p_cust_acct_id  =>p_shipment_line_rec.SHIP_TO_CUST_ACCOUNT_ID,
			   p_cust_party_id =>p_shipment_line_rec.SHIP_TO_CUST_PARTY_ID,
			   p_resource_id   =>p_quote_header_rec.resource_id,
			   p_sold_to_cust_acct_id=>p_quote_header_rec.CUST_ACCOUNT_ID,
			   p_flag	    =>'SHIP',
			   p_header	    => 'N'
			  );
	aso_debug_pub.add('After Calling Validate Bill Ship Account(Line/Ship)', 1, 'Y');
END IF;



--7.                                   ***Validate Account***

--Validate Account (Header/SOLD)
if (	p_quote_header_rec.CUST_ACCOUNT_ID  is NOT NULL
	AND  p_quote_header_rec.CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Account (Header/SOLD)', 1, 'Y');

VALIDATE_ACCOUNT(p_cust_acct_id	=> p_quote_header_rec.CUST_ACCOUNT_ID,
		p_cust_party_id	=> p_quote_header_rec.cust_party_id,
		p_resource_id	=> p_quote_header_rec.resource_id,
		p_flag		=> 'SOLD' ,
		p_header        => 'Y'
		);
	aso_debug_pub.add('After Calling Validate Account (Header/SOLD)', 1, 'Y');
END IF;


--Validate Account (Header/END)
if (	p_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID  is NOT NULL
	AND  p_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Account (Header/END)', 1, 'Y');

VALIDATE_ACCOUNT(p_cust_acct_id	=> p_quote_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
		p_cust_party_id	=> p_quote_header_rec.END_CUSTOMER_CUST_PARTY_ID,
		p_resource_id	=> p_quote_header_rec.resource_id,
		p_flag		=> 'END',
		p_header        => 'Y'
		);
	aso_debug_pub.add('After Calling Validate Account (Header/END)', 1, 'Y');
END IF;


--Validate Account (Line/END)
if (	p_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID  is NOT NULL
	AND  p_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)  THEN

	aso_debug_pub.add('Before Calling Validate Account (Line/END)', 1, 'Y');

VALIDATE_ACCOUNT(p_cust_acct_id	=> p_quote_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
		p_cust_party_id	=> p_quote_line_rec.END_CUSTOMER_CUST_PARTY_ID,
		p_resource_id	=> p_quote_header_rec.resource_id,
		p_flag		=> 'END',
		p_header        => 'N'
		);
	aso_debug_pub.add('After Calling Validate Account (Line/END)', 1, 'Y');
END IF;


--TCA Calls End

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get
      (  p_count	  =>   x_msg_count,
	 p_data 	  =>   x_msg_data
      );

    --Printing the Values After processing
     PRINT_DEFAULTING_ATTRIBUTES('N');

END VALIDATE_DEFAULTING_DATA ;
--Changes for Validating Defaulting Parameters (End):14/09/2005

Procedure Validate_cc_info
(
  p_init_msg_list     IN   VARCHAR2  := fnd_api.g_false,
  p_payment_rec       IN   aso_quote_pub.payment_rec_type,
  p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  P_Qte_Line_rec      IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
  x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_payment_type_code   varchar2(240);
l_inv_cust_party_id   number;

cursor c_get_payment_type_code(p_qte_hdr_id number) is
select payment_type_code
from aso_payments
where quote_header_id = p_qte_hdr_id
and quote_line_id is null;

cursor c_get_lines_with_null_payment(p_qte_hdr_id number) is
select b.invoice_to_cust_party_id
from aso_payments a, aso_quote_lines_all b
where a.quote_header_id = b.quote_header_id
and a.quote_line_id = b.quote_line_id
and b.quote_header_id = p_qte_hdr_id
and a.quote_line_id is not null
and a.payment_type_code is null
and b.invoice_to_cust_party_id is not null;

Begin
    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Begin Validate_payment_rec', 1, 'Y');
    end if;

    if p_init_msg_list = fnd_api.g_true then
        fnd_msg_pub.initialize;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;

    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Payment Rec.payment_type_code: '||p_payment_rec.payment_type_code, 1, 'Y');
       aso_debug_pub.add('Payment Rec.quote_header_id: '||p_payment_rec.quote_header_id, 1, 'Y');
       aso_debug_pub.add('Payment Rec.quote_line_id: '||p_payment_rec.quote_line_id, 1, 'Y');
       aso_debug_pub.add('P_Qte_Line_rec.invoice_to_cust_party_id: '||P_Qte_Line_rec.invoice_to_cust_party_id, 1, 'Y');
       aso_debug_pub.add('p_qte_header_rec.invoice_to_cust_party_id: '||p_qte_header_rec.invoice_to_cust_party_id, 1, 'Y');
    end if;



   if (p_payment_rec.payment_type_code = 'CREDIT_CARD' and
       (p_payment_rec.quote_line_id is null or p_payment_rec.quote_line_id = fnd_api.g_miss_num) and
       (p_qte_header_rec.invoice_to_cust_party_id is null or p_qte_header_rec.invoice_to_cust_party_id = fnd_api.g_miss_num))
      or
      (p_payment_rec.payment_type_code  = 'CREDIT_CARD' and
       (p_payment_rec.quote_line_id is not null and p_payment_rec.quote_line_id <> fnd_api.g_miss_num) and
       (P_Qte_Line_rec.invoice_to_cust_party_id is null or P_Qte_Line_rec.invoice_to_cust_party_id = fnd_api.g_miss_num))
   then

          x_return_status := fnd_api.g_ret_sts_error;

          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_MISSING_BILLTOPARTY');
             FND_MSG_PUB.ADD;
          END IF;

   end if;

   -- if line payment has bill to and payment type is null while header has payment type credit card, throw error
   if ((p_payment_rec.quote_line_id is not null and p_payment_rec.quote_line_id <> fnd_api.g_miss_num) and
       (P_Qte_Line_rec.invoice_to_cust_party_id is not null and  P_Qte_Line_rec.invoice_to_cust_party_id <> fnd_api.g_miss_num) and
       (p_payment_rec.payment_type_code is null or p_payment_rec.payment_type_code = fnd_api.g_miss_char)) then

       -- get the payment type from header payment record
        open c_get_payment_type_code(p_payment_rec.quote_header_id);
        fetch c_get_payment_type_code into l_payment_type_code;
        close c_get_payment_type_code;

        if nvl(l_payment_type_code,'null')  = 'CREDIT_CARD' then

          x_return_status := fnd_api.g_ret_sts_error;

          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_MISSING_PAYMENT_DETAILS');
             FND_MSG_PUB.ADD;
          END IF;

        end if;

   end if;

   -- if  hdr payment is changed to cc, then make sure all lines have no null payment type if bill to is specified at line
   if ((p_payment_rec.quote_line_id is null or p_payment_rec.quote_line_id = fnd_api.g_miss_num) and
       (p_payment_rec.payment_type_code = 'CREDIT_CARD' )) then

       --  get all the lines in quote and check their payment type
        open c_get_lines_with_null_payment(p_payment_rec.quote_header_id);
        fetch c_get_lines_with_null_payment  into l_inv_cust_party_id;

        if c_get_lines_with_null_payment%FOUND Then
          close c_get_lines_with_null_payment;
          x_return_status := fnd_api.g_ret_sts_error;

          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_MISSING_LN_PAYMENT_DETAILS');
             FND_MSG_PUB.ADD;
          END IF;

        end if;

   end if;
    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('End Validate_payment_rec', 1, 'Y');
    end if;

End Validate_cc_info;


PROCEDURE VALIDATE_OU(p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type) IS           --Procedure for OU Validtion (Yogeshwar 05/10/2005)

l_org_id number;
l_access_mode varchar2(1);

BEGIN
	--Getting the current org_id
	l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID;

	--Getting the Context Mode
	l_access_mode := MO_GLOBAL.GET_ACCESS_MODE ;

        --when access mode is set to 'S'
	--Check if the current org_id matches with the org_id in p_qte_header_rec
	IF l_access_mode IS NOT NULL AND l_access_mode = 'S' THEN
	BEGIN
		IF ((p_qte_header_rec.org_id <> FND_API.G_MISS_NUM)
		    AND (p_qte_header_rec.org_id IS NOT NULL)
		    AND (l_org_id <> p_qte_header_rec.org_id)) THEN

			 IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		             FND_MESSAGE.Set_Name('ASO', 'ASO_ORG_ID_MISMATCH');
		             FND_MSG_PUB.ADD;
		         END IF;

			 RAISE FND_API.G_EXC_ERROR;
		END IF;
	END ;
	ELSE
		IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('ASO', 'ASO_WRONG_ACCESS_MODE');
			FND_MSG_PUB.ADD;
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	END IF;
END VALIDATE_OU;

PROCEDURE validate_ship_method_code
(
p_init_msg_list          IN    VARCHAR2  := fnd_api.g_false,
p_qte_header_id          IN    NUMBER    := fnd_api.g_miss_num,
p_qte_line_id            IN    NUMBER    := fnd_api.g_miss_num,
p_organization_id        IN    NUMBER    := fnd_api.g_miss_num,
p_ship_method_code       IN    VARCHAR2  := fnd_api.g_miss_char,
p_operation_code         IN    VARCHAR2  := fnd_api.g_miss_char,
x_return_status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_msg_count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
x_msg_data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2) is

Cursor C_Get_ship_method ( l_ship_method_code varchar2, l_org_id number) is
SELECT csm.ship_method_code
from      wsh_carrier_ship_methods csm,
          fnd_lookup_values fl
where     fl.lookup_type = 'SHIP_METHOD'
and       csm.ship_method_code = l_ship_method_code
and       fl.view_application_id = 3
and       csm.organization_id = l_org_id
and       fl.enabled_flag = 'Y'
and     csm.enabled_flag = 'Y'
and       (trunc(sysdate) between nvl(fl.start_date_active,trunc(sysdate))
          AND  nvl(fl.end_date_active,trunc(sysdate)) );


Cursor get_organization_id(l_qte_line_id number) is
select organization_id
from   aso_quote_lines_all
where  quote_line_id = l_qte_line_id;

Cursor get_ship_code(l_qte_line_id number) is
select ship_method_code
from   aso_shipments
where  quote_line_id = l_qte_line_id;

Cursor get_ship_code_from_hdr(l_qte_header number) is
select ship_method_code
from   aso_shipments
where  quote_header_id = l_qte_header;

l_ship_method_code varchar2(30) := p_ship_method_code;
lx_ship_method_code varchar2(30);
l_organization_id  number := p_organization_id;


BEGIN

    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Begin validate_ship_method_code', 1, 'Y');
    end if;

    if p_init_msg_list = fnd_api.g_true then
        fnd_msg_pub.initialize;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;

    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('p_qte_header_id  :  '||p_qte_header_id, 1, 'Y');
       aso_debug_pub.add('p_qte_line_id:      '||p_qte_line_id, 1, 'Y');
       aso_debug_pub.add('p_organization_id:  '||p_organization_id, 1, 'Y');
       aso_debug_pub.add('p_ship_method_code: '||p_ship_method_code, 1, 'Y');
       aso_debug_pub.add('p_operation_code:   '||p_operation_code, 1, 'Y');
    end if;

    IF (p_operation_code = 'CREATE' and p_ship_method_code is not null and p_ship_method_code <> fnd_api.g_miss_char) THEN

      OPEN C_Get_ship_method(p_ship_method_code,p_organization_id);
	 fetch C_Get_ship_method into lx_ship_method_code;

	 if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Operation code is CREATE', 1, 'Y');
       aso_debug_pub.add('lx_ship_method_code  :  '|| lx_ship_method_code, 1, 'Y');
      end if;

	 if C_Get_ship_method%NOTFOUND THEN
         Close C_Get_ship_method;
         x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SHIP_METHOD', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_ship_method_code, FALSE);
                FND_MSG_PUB.ADD;
            END IF;
       else
        Close C_Get_ship_method;
	  end if;


    ELSIF  p_operation_code = 'UPDATE' THEN

       -- get the value from the db if not passed in
       IF (p_organization_id is null or p_organization_id = fnd_api.g_miss_num) then
          open get_organization_id(p_qte_line_id);
          fetch get_organization_id into l_organization_id;
          close get_organization_id;
       END IF;

       IF (p_ship_method_code is null or p_ship_method_code = fnd_api.g_miss_char) then
         IF (p_qte_line_id is not null and p_qte_line_id <> fnd_api.g_miss_num) then
		open get_ship_code(p_qte_line_id);
		fetch get_ship_code into l_ship_method_code;
		close get_ship_code;
	    ELSE
          open get_ship_code_from_hdr(p_qte_header_id);
		fetch get_ship_code_from_hdr into l_ship_method_code;
		close get_ship_code_from_hdr;
	    END IF;
	  End if;

       if aso_debug_pub.g_debug_flag = 'Y' then
          aso_debug_pub.add('l_organization_id:   '|| l_organization_id, 1, 'Y');
          aso_debug_pub.add('l_ship_method_code:  '|| l_ship_method_code, 1, 'Y');
       end if;

     IF (l_ship_method_code is not null and l_ship_method_code <> fnd_api.g_miss_char) then
      OPEN C_Get_ship_method(l_ship_method_code,l_organization_id);
      fetch C_Get_ship_method into lx_ship_method_code;

	 if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Operation code is UPDATE', 1, 'Y');
       aso_debug_pub.add('lx_ship_method_code  :  '|| lx_ship_method_code, 1, 'Y');
      end if;

	 if C_Get_ship_method%NOTFOUND THEN
         Close C_Get_ship_method;
         x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SHIP_METHOD', FALSE);
                FND_MESSAGE.Set_Token('VALUE', l_ship_method_code, FALSE);
                FND_MSG_PUB.ADD;
            END IF;
       else
        Close C_Get_ship_method;
       end if;
      end if; -- end if for the ship_method code check
    END IF; -- end if for the operation_code check


    if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('End validate_ship_method_code', 1, 'Y');
    end if;
END validate_ship_method_code;

End ASO_VALIDATE_PVT;


/
