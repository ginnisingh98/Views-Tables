--------------------------------------------------------
--  DDL for Package Body OZF_CHARGEBACK_ATTRMAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CHARGEBACK_ATTRMAP_PUB" AS
/* $Header: ozfpcamb.pls 115.0 2003/06/26 05:06:00 mchang noship $ */

-- Package name     : OZF_CHARGEBACK_ATTRMAP_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(50) := 'OZF_CHARGEBACK_ATTRMAP_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(20) := 'ozfpcamb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    get_sold_to_org_id
--
-- PURPOSE
--    This function returns the sold_to_org_id based on the input parameters.
--
--    User can modify the code to his own mapping rules and validation rules
--    for sold_to_org_id.  User can either use the input header record or the
--    interface table record based on the p_id to get the proper value.
--
--    Similar functions should be created if user wants to modify other attribute
--    in the header structure.
--
-- PARAMETERS
--    p_hdr   in oe_order_pub.header_rec_type
--    p_id    in number
--    return  number;
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_sold_to_org_id(
           xp_hdr IN OUT NOCOPY oe_order_pub.header_rec_type
	  ,p_id  in number
	  ,x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Add Mapping and validation rules here
END get_sold_to_org_id;

---------------------------------------------------------------------
-- PROCEDURE
--    get_sold_to_org_id
--
-- PURPOSE
--    This function returns the sold_to_org_id based on the input parameters.
--    It overrides the function get_sold_to_org_id.
--
--    User can modify the code to his own mapping rules and validation rules
--    for sold_to_org_id.  User can either use the input header record or the
--    interface table record based on the p_id to get the proper value.
--
--    Similar functions should be created if user wants to modify other attribute
--    in the Line structure.
--
-- PARAMETERS
--    p_line   in oe_order_pub.line_rec_type
--    p_id    in number
--    return  number;
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_sold_to_org_id(
           xp_line IN OUT NOCOPY oe_order_pub.line_rec_type
	   ,p_id  in number
	   ,x_return_status out NOCOPY varchar2)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Add Mapping and validation rules here
END get_sold_to_org_id;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Global_Header
--
-- PURPOSE
--    Create_Global_Header
--
-- PARAMETERS
--    xp_hdr                   INOUT NOCOPY OE_ORDER_PUB.HEADER_REC_TYPE
--    p_interface_id           IN    NUMBER
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Create_Global_Header
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,xp_hdr                   IN OUT NOCOPY OE_ORDER_PUB.HEADER_REC_TYPE
   ,p_interface_id           IN    NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Global_Header';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status          varchar2(30);
BEGIN
   -- Standard begin of API savepoint
    SAVEPOINT  Global_Header_Pub;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    get_sold_to_org_id(xp_hdr   => xp_hdr,
                       p_id     => p_interface_id,
		       x_return_status => l_return_status);
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Global_Header_Pub ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Global_Header_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	-- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO Global_Header_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Create_Global_Header;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Global_Line
--
-- PURPOSE
--    Create_Global_Line
--
-- PARAMETERS
--    xp_line                  INOUT NOCOPY OE_ORDER_PUB.line_REC_TYPE
--    p_interface_id           IN    NUMBER
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Create_Global_Line
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,xp_line                  IN OUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE
   ,p_interface_id           IN    NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Global_Line';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status          varchar2(30);

BEGIN
   -- Standard begin of API savepoint
    SAVEPOINT  Global_Line_Pub;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Here is an example how to overwrite a value in the line global structure.
    get_sold_to_org_id( xp_line   => xp_line,
                        p_id       => p_interface_id,
		        x_return_status => l_return_status);
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Global_Line_Pub ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Global_Line_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	-- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO Global_Line_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Create_Global_Line;

END OZF_CHARGEBACK_ATTRMAP_PUB;

/
