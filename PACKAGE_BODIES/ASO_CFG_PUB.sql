--------------------------------------------------------
--  DDL for Package Body ASO_CFG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CFG_PUB" as
/* $Header: asopcfgb.pls 120.1.12010000.2 2010/01/08 12:26:05 vidsrini ship $ */
-- Start of Comments
-- Package name     : aso_cfg_pub
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
 --private variable declaration


 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ASO_CFG_PUB';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'asopcfgb.pls';


PROCEDURE Get_config_details(
    P_Api_Version_Number         IN           NUMBER                               := FND_API.G_MISS_NUM,
    P_Init_Msg_List              IN           VARCHAR2                             := FND_API.G_FALSE,
    P_Commit                     IN           VARCHAR2                             := FND_API.G_FALSE,
    p_control_rec                IN           aso_quote_pub.control_rec_type
                                              := aso_quote_pub.G_MISS_control_rec,
    p_config_rec                 IN           aso_quote_pub.qte_line_dtl_rec_type,
    p_model_line_rec             IN           aso_quote_pub.qte_line_rec_type,
    p_config_hdr_id              IN           NUMBER,
    p_config_rev_nbr             IN           NUMBER,
    p_quote_header_id            IN           NUMBER,
    x_return_status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
       )
IS

l_qte_header_rec   aso_quote_pub.qte_header_rec_type  := aso_quote_pub.g_miss_qte_header_rec;

BEGIN
     l_qte_header_rec.quote_header_id := p_quote_header_id;

     get_config_details(
          p_api_version_number         => p_api_version_number,
          p_init_msg_list              => fnd_api.g_false,
          p_commit                     => p_commit,
          p_control_rec                => p_control_rec,
          p_qte_header_rec             => l_qte_header_rec,
          p_model_line_rec             => p_model_line_rec,
          p_config_rec                 => p_config_rec,
          p_config_hdr_id              => p_config_hdr_id,
          p_config_rev_nbr             => p_config_rev_nbr,
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data );

END get_config_details;


--Overloaded get_config_details procedure

PROCEDURE get_config_details(
    p_api_version_number  IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2                           := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2                           := FND_API.G_FALSE,
    p_control_rec         IN            aso_quote_pub.control_rec_type
								:= aso_quote_pub.G_MISS_control_rec,
    p_qte_header_rec      IN            aso_quote_pub.qte_header_rec_type,
    p_model_line_rec      IN            aso_quote_pub.qte_line_rec_type,
    p_config_rec          IN            aso_quote_pub.qte_line_dtl_rec_type,
    p_config_hdr_id       IN            NUMBER,
    p_config_rev_nbr      IN            NUMBER,
    x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)

IS
 l_api_name              CONSTANT   VARCHAR2(30) :=  'Get_Config_Details' ;
 l_api_version_number    CONSTANT   NUMBER       :=  1.0;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT GET_CONFIG_DETAILS_PUB;

	 aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add( 'ASO_CFG_PUB: GET_CONFIG_DETAILS start %%%%%%%%%%%%%%%%%%%', 1, 'Y' );
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      ASO_CFG_INT.Get_config_details(
          P_Api_Version_Number         => P_Api_Version_Number,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => p_commit,
		p_control_rec                => p_control_rec,
          p_qte_header_rec             => p_qte_header_rec,
          p_model_line_rec             => p_model_line_rec,
          p_config_rec                 => p_config_rec,
          p_config_hdr_id              => p_config_hdr_id ,
          p_config_rev_nbr             => p_config_rev_nbr,
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data );


      -- Check return status from the above procedure call
	 IF x_return_status = FND_API.G_RET_STS_ERROR then
	     raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	     raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



	 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(  p_count          =>   x_msg_count,
					         p_data           =>   x_msg_data);

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add( 'ASO_CFG_PUB: GET_CONFIG_DETAILS End %%%%%%%%%%%%%%%%%%%', 1, 'Y' );
      END IF;

      EXCEPTION
		 WHEN FND_API.G_EXC_ERROR THEN
	         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME => L_API_NAME
									 ,P_PKG_NAME => G_PKG_NAME
								      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
									 ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
									 ,X_MSG_COUNT => X_MSG_COUNT
								      ,X_MSG_DATA => X_MSG_DATA
									 ,X_RETURN_STATUS => X_RETURN_STATUS);

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME => L_API_NAME
									 ,P_PKG_NAME => G_PKG_NAME
								      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
									 ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
									 ,X_MSG_COUNT => X_MSG_COUNT
									 ,X_MSG_DATA => X_MSG_DATA
									 ,X_RETURN_STATUS => X_RETURN_STATUS);

           WHEN OTHERS THEN
		    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS( P_API_NAME => L_API_NAME
									 ,P_PKG_NAME => G_PKG_NAME
									 ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
									 ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
								      ,X_MSG_COUNT => X_MSG_COUNT
									 ,X_MSG_DATA => X_MSG_DATA
									 ,X_RETURN_STATUS => X_RETURN_STATUS);

END;




PROCEDURE  Pricing_Callback(    p_config_session_key    IN             VARCHAR2,
                                p_price_type            IN             VARCHAR2,
                                x_total_price           OUT NOCOPY /* file.sql.39 change */      NUMBER )
is

Begin

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      ASO_CFG_INT.Pricing_Callback(p_config_session_key  => p_config_session_key,
                                   p_price_type          => p_price_type,
                                   x_total_price         => x_total_price );


End Pricing_Callback;



PROCEDURE  pricing_callback_manual( p_config_session_key    IN             VARCHAR2,
                                    p_price_type            IN             VARCHAR2,
                                    x_total_price           OUT NOCOPY /* file.sql.39 change */      NUMBER )
IS

l_price_type           VARCHAR2(10);

Begin
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN

         aso_debug_pub.add('ASO_CFG_PUB: pricing_callback_manual: Start %%%%%%%%%%%%%%%%%%%%' , 1, 'Y' );
         aso_debug_pub.add('pricing_callback_manual: p_config_session_key: ' || p_config_session_key);
         aso_debug_pub.add('pricing_callback_manual: p_price_type:         ' || p_price_type);

     END IF;

     l_price_type := cz_prc_callback_util.g_prc_type_list;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('pricing_callback_manual: l_price_type: ' || l_price_type);
     END IF;

     pricing_callback( p_config_session_key   => p_config_session_key,
                       p_price_type           => l_price_type,
                       x_total_price          => x_total_price);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN

         aso_debug_pub.add('ASO_CFG_PUB: pricing_callback_manual End %%%%%%%%%%%%%%%%%%%%', 1, 'Y' );

     END IF;

End pricing_callback_manual;

-- bug8278795
  PROCEDURE Aso_config_price_items_mls (
    p_config_session_key      IN  VARCHAR2,
    p_price_type              IN  VARCHAR2, -- list, selling
    x_total_price             OUT NOCOPY NUMBER,
    x_currency_code           OUT NOCOPY VARCHAR2
  ) IS
    l_currency_code        VARCHAR2(15);
    l_top_line_id_pos      NUMBER;
    l_top_model_line_id    NUMBER;
    l_debug_level CONSTANT NUMBER := aso_debug_pub.g_debug_level;
  BEGIN
    IF l_debug_level > 0 THEN
      aso_debug_pub.add ('Entering aso_Config_Price_Items_MLS - '
                        || p_config_session_key || ' ***** ' || p_price_type);
    END IF;

    l_top_line_id_pos := INSTR (p_config_session_key, '-' );
    l_top_model_line_id := TO_NUMBER (SUBSTR (p_config_session_key, 1, l_top_line_id_pos - 1));

    IF l_debug_level > 0 THEN
      aso_debug_pub.add('top_model_line_id - ' || l_top_model_line_id);
    END IF;

    SELECT DISTINCT h.currency_code
    INTO x_currency_code
    FROM aso_quote_lines_all l,
         aso_quote_headers_all h
    WHERE h.QUOTE_header_id = l.QUOTE_header_id
          AND l.QUOTE_line_id = l_top_model_line_id;

    pricing_callback (
      p_config_session_key => p_config_session_key,
      p_price_type         => p_price_type,
      x_total_price        => x_total_price
    );

    IF l_debug_level > 0 THEN
      aso_debug_pub.add('Exiting ASO_CONFIG_PRICE_UTIL.ASO_config_price_items_mls');
    END IF;

  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
       IF l_debug_level > 0 THEN
          aso_debug_pub.add('Exception ASO_CONFIG_PRICE_UTIL.ASO_config_price_items_mls - TOO_MANY_ROWS');
       END IF;
    WHEN OTHERS THEN
       IF l_debug_level > 0 THEN
          aso_debug_pub.add('Exception ASO_CONFIG_PRICE_UTIL.ASO_config_price_items_mls - OTHERS');
       END IF;
  END aso_config_price_items_mls;
  -- end bug8278795

-- bug8278795
  PROCEDURE Aso_Config_Price_Items_MLS_Man(
    p_config_session_key      IN  VARCHAR2,
    p_price_type              IN  VARCHAR2, -- list, selling
    x_total_price             OUT NOCOPY NUMBER,
    x_currency_code           OUT NOCOPY VARCHAR2
  ) IS
    l_currency_code        VARCHAR2(15);
    l_top_line_id_pos      NUMBER;
    l_top_model_line_id    NUMBER;
    l_debug_level CONSTANT NUMBER := aso_debug_pub.g_debug_level;
  BEGIN
    IF l_debug_level > 0 THEN
      aso_debug_pub.add ('Entering aso_Config_Price_Items_MLS - '
                        || p_config_session_key || ' ***** ' || p_price_type);
    END IF;

    l_top_line_id_pos := INSTR (p_config_session_key, '-' );
    l_top_model_line_id := TO_NUMBER (SUBSTR (p_config_session_key, 1, l_top_line_id_pos - 1));

    IF l_debug_level > 0 THEN
      aso_debug_pub.add('top_model_line_id - ' || l_top_model_line_id);
    END IF;

    SELECT DISTINCT h.currency_code
    INTO x_currency_code
    FROM aso_quote_lines_all l,
         aso_quote_headers_all h
    WHERE h.QUOTE_header_id = l.QUOTE_header_id
          AND l.QUOTE_line_id = l_top_model_line_id;

    pricing_callback_manual (
      p_config_session_key => p_config_session_key,
      p_price_type         => p_price_type,
      x_total_price        => x_total_price
    );

    IF l_debug_level > 0 THEN
      aso_debug_pub.add('Exiting ASO_CONFIG_PRICE_UTIL.ASO_config_price_items_mls');
    END IF;

  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
       IF l_debug_level > 0 THEN
          aso_debug_pub.add('Exception ASO_CONFIG_PRICE_UTIL.ASO_config_price_items_mls - TOO_MANY_ROWS');
       END IF;
    WHEN OTHERS THEN
       IF l_debug_level > 0 THEN
          aso_debug_pub.add('Exception ASO_CONFIG_PRICE_UTIL.ASO_config_price_items_mls - OTHERS');
       END IF;
  END Aso_Config_Price_Items_MLS_Man;
  -- end bug8278795

End aso_cfg_pub;

/
