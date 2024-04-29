--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ATTR_RT_INSERT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ATTR_RT_INSERT_PVT" as
/* $Header: pvxptaib.pls 120.1 2005/12/14 15:32:21 amaram noship $ */
g_pkg_name   constant varchar2(100) := 'PV_PARTNER_ATTR_RT_INSERT_PVT';
/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
);


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);

PROCEDURE partner_attr_insert (
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_partner_id             IN   NUMBER,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'partner_attr_insert';
   l_api_version_number  CONSTANT NUMBER   := 1.0;


cnt                  NUMBER := 0;
l_attr_text          VARCHAR2(100);
l_search_attr_id     NUMBER;
l_chk_flag           VARCHAR2(1);

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
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--
      EXECUTE IMMEDIATE
      '
      INSERT INTO pv_search_attr_values
      SELECT  pv_search_attr_values_s.nextval
           ,  partner_id
           ,  null
           ,  attr_text
           ,  SYSDATE
           ,  FND_GLOBAL.user_id
           ,  SYSDATE
           ,  FND_GLOBAL.user_id
           ,  1.0
           ,  FND_GLOBAL.user_id
           ,  null
           ,  attribute_id
           ,  null
      from (
      SELECT  19 attribute_id, attr_code attr_text, pp.partner_id partner_id
      FROM    pv_partner_profiles pp,
              pv_attribute_codes_vl pac
      WHERE   pp.partner_level=to_char(pac.attr_code_id)
      AND     pp.partner_id = :1
      AND     pac.enabled_flag = ''Y''
      UNION all
      SELECT distinct 4 attribute_id, hl.country attr_text, pvpp.partner_id partner_id
      FROM   hz_locations hl,
             hz_party_sites hs,
             pv_partner_profiles pvpp
      WHERE  hl.location_id = hs.location_id
      AND    hs.party_id =  pvpp.partner_party_id
      AND    pvpp.partner_id = :1
      AND   (hs.status = ''A'' OR hs.status IS NULL)
      UNION all
      SELECT 11 attribute_id,
		hzp.party_name attr_text,
		pvpp.partner_id partner_id
	FROM  pv_partner_profiles pvpp, hz_parties hzp
	WHERE  partner_id=:1
	AND    hzp.party_id = pvpp.partner_party_id

      UNION all
      SELECT 3 attribute_id,pear.attr_value attr_text, pear.entity_id partner_id
      FROM   pv_enty_attr_values pear
      WHERE  pear.entity_id = :1
      AND    pear.latest_flag = ''Y''
      AND    attr_value is not null
      AND    attribute_id = 3 )' USING p_partner_id,p_partner_id,p_partner_id,p_partner_id ;


EXCEPTION
      WHEN others THEN
         Debug(SQLCODE || ': ' || SQLERRM);

END partner_attr_insert;

--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);
   FND_MSG_PUB.Add;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);

        IF (p_token1 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        END IF;

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        FND_MSG_PUB.Add;


    END IF;
END Set_Message;
-- ==============================End of Set_Message==============================


END  PV_PARTNER_ATTR_RT_INSERT_PVT;

/
