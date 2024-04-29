--------------------------------------------------------
--  DDL for Package ASO_CFG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CFG_PUB" AUTHID CURRENT_USER as
/* $Header: asopcfgs.pls 120.1.12010000.2 2010/01/08 12:22:36 vidsrini ship $ */
-- Start of Comments
-- Package name     : aso_cfg_pub
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--   API Name:  Get_configuration_lines (OverLoaded)
--   Type    :  Public
--   Purpose :  The procedure is overloaded to include control record as an input parameter
--   Pre-Req :

PROCEDURE Get_config_details(
    P_Api_Version_Number         IN           NUMBER                              := FND_API.G_MISS_NUM,
    P_Init_Msg_List              IN           VARCHAR2                            := FND_API.G_FALSE,
    p_commit                     IN           VARCHAR2                            := FND_API.G_FALSE,
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
       );


--Overloaded

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
);


PROCEDURE  Pricing_Callback(    p_config_session_key    IN           VARCHAR2,
                                p_price_type            IN           VARCHAR2,
                                x_total_price           OUT NOCOPY /* file.sql.39 change */    NUMBER );


PROCEDURE  pricing_callback_manual( p_config_session_key    IN             VARCHAR2,
                                    p_price_type            IN             VARCHAR2,
                                    x_total_price           OUT NOCOPY /* file.sql.39 change */      NUMBER );

--bug8278795
PROCEDURE aso_Config_Price_Items_MLS
   (  p_config_session_key      IN  VARCHAR2
     ,p_price_type              IN  VARCHAR2 -- list, selling
     ,x_total_price             OUT NOCOPY NUMBER
     ,x_currency_code           OUT NOCOPY VARCHAR2
   );

PROCEDURE aso_Config_Price_Items_MLS_Man
   (  p_config_session_key      IN  VARCHAR2
     ,p_price_type              IN  VARCHAR2 -- list, selling
     ,x_total_price             OUT NOCOPY NUMBER
     ,x_currency_code           OUT NOCOPY VARCHAR2
   );


End aso_cfg_pub;

/
