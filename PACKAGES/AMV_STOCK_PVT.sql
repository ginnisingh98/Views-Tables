--------------------------------------------------------
--  DDL for Package AMV_STOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_STOCK_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvstks.pls 120.1 2005/06/30 13:13:56 appldev ship $ */
--
-- NAME
--   AMV_STOCK_PVT
--
-- HISTORY
--   11/10/1999        SLKRISHN        CREATED
--
--
--------------------------------------------------------------------------------
G_ASC_ORDER     CONSTANT    VARCHAR2(5) := 'ASC';
G_DESC_ORDER    CONSTANT    VARCHAR2(5) := 'DESC';

-- RECORDS TYPES USED IN THIS PACKAGE
TYPE AMV_TKR_OBJ_TYPE IS RECORD(
	key_id    VARCHAR2(60),
 	stock_id 	NUMBER
);

TYPE AMV_SYM_OBJ_TYPE IS RECORD(
	stock_id 	NUMBER,
  	symbol   	VARCHAR2(20),
	exchange 	VARCHAR2(30)
);

TYPE AMV_STK_OBJ_TYPE IS RECORD(
	stock_id 	NUMBER,
	symbol   	VARCHAR2(20),
	description	VARCHAR2(240),
	price    	NUMBER,
	change   	NUMBER
);

TYPE AMV_NEWS_OBJ_TYPE IS RECORD(
	key_id    VARCHAR2(60),
	news_url  VARCHAR2(2000),
	title     VARCHAR2(2000),
	provider 	VARCHAR2(240),
	date_time DATE
);
-- TABLE TYPES USED IN THIS PACKAGE
TYPE AMV_TKR_VARRAY_TYPE IS TABLE OF AMV_TKR_OBJ_TYPE
	INDEX BY BINARY_INTEGER;
TYPE AMV_SYM_VARRAY_TYPE IS TABLE OF AMV_SYM_OBJ_TYPE
	INDEX BY BINARY_INTEGER;
TYPE AMV_STK_VARRAY_TYPE IS TABLE OF AMV_STK_OBJ_TYPE
	INDEX BY BINARY_INTEGER;
TYPE AMV_NEWS_VARRAY_TYPE IS TABLE OF AMV_NEWS_OBJ_TYPE
	INDEX BY BINARY_INTEGER;
--
TYPE AMV_CHAR_VARRAY_TYPE IS TABLE OF VARCHAR2(400)
	INDEX BY BINARY_INTEGER;
TYPE AMV_NUM_VARRAY_TYPE IS TABLE OF NUMBER
	INDEX BY BINARY_INTEGER;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserTicker
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Returns the list of tickers for an user
--    Parameters :
--    IN           p_api_version            IN  NUMBER    Required
--                 p_init_msg_list          IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level       IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_user_id                IN  NUMBER    Required
--                 p_sort_order             IN  VARCHAR2  Optional
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--		   x_ticker_array	    OUT AMV_STK_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserTicker
(     p_api_version           	IN  NUMBER,
      p_init_msg_list         	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         	OUT NOCOPY  VARCHAR2,
      x_msg_count             	OUT NOCOPY  NUMBER,
      x_msg_data              	OUT NOCOPY  VARCHAR2,
      p_user_id     		IN  NUMBER,
	 p_distinct_stocks		IN VARCHAR2 := FND_API.G_FALSE,
      p_sort_order		IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      x_stkpr_array    		OUT NOCOPY  AMV_STK_VARRAY_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_StockDetails
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Returns the ticker details for list of stocks
--    Parameters :
--    IN           p_api_version            IN  NUMBER    Required
--                 p_init_msg_list          IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level       IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_symbols                IN  VARCHAR2    Required
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--		   x_ticker_array	    OUT AMV_STK_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_StockDetails
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_symbols     		IN  VARCHAR2,
      x_stkpr_array    		OUT NOCOPY  AMV_STK_VARRAY_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_UserTicker
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update the tickers for an user
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_object_version_number  	IN  NUMBER    Required
--                      object version number
--                 p_user_id            IN  NUMBER    Required
--                    user id.
--                 p_symbols      	IN  VARCHAR2  Required
--                    stock symbols.
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_UserTicker
(     p_api_version     	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_object_version_number 	IN  NUMBER,
      p_user_id          	IN  NUMBER,
      p_symbols      		IN  VARCHAR2
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_VendorMissedStocks
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Gets the list of stocks for which the vendor keys have not
--			been identified
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id                	IN  NUMBER    Required
--                    vendor id.
--                 p_start_index                  IN  NUMBER   Optional
--                        Default = 1
--                 p_batch_size                	IN  NUMBER   Optional
--                        Default = FND_API.G_MISS_NUM
--                    batch size of keys.
--    OUT        : x_return_status       OUT VARCHAR2
--                 x_msg_count           OUT NUMBER
--                 x_msg_data            OUT VARCHAR2
--                 x_stocks_array        OUT AMV_SYM_VARRAY_TYPE  Required
--                    stock symbol and ric.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_VendorMissedStocks
(     p_api_version     	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data        		OUT NOCOPY  VARCHAR2,
      p_vendor_id          	IN  NUMBER,
	 p_start_index			IN  NUMBER := 1,
	 p_batch_size			IN  NUMBER := FND_API.G_MISS_NUM,
      x_stocks_array      	OUT NOCOPY  AMV_SYM_VARRAY_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Insert_StockVendorKeys
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Inserts the Stock id and the vendor id and key id for vendor
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id           IN  NUMBER    Required
--                    vendor id.
--                 p_ticker_rec        IN  AMV_TKR_OBJ_TYPE  Required
--                    ticker array (ric and key id).
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Insert_StockVendorKeys
(     p_api_version     	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data        	OUT NOCOPY  VARCHAR2,
      p_vendor_id          	IN  NUMBER,
      p_ticker_rec      	IN  AMV_TKR_OBJ_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserSelectedKeys
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Gives an array of all the stocks selected by all users
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   p_vendor_id		IN NUMBER Required
--			vendor id
--    OUT        : x_return_status     OUT VARCHAR2
--                 x_msg_count         OUT NUMBER
--                 x_msg_data          OUT VARCHAR2
--                 x_keys_array        OUT  AMV_CHAR_VARRAY_TYPE  Required
--                    key id.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserSelectedKeys
(     p_api_version     	IN  NUMBER,
      p_init_msg_list   	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status   	OUT NOCOPY  VARCHAR2,
      x_msg_count       	OUT NOCOPY  NUMBER,
      x_msg_data        	OUT NOCOPY  VARCHAR2,
      p_vendor_id      	IN  NUMBER,
	 p_all_keys         IN VARCHAR2 := FND_API.G_FALSE,
      x_keys_array      	OUT NOCOPY   AMV_CHAR_VARRAY_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Insert_VendorNews
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Inserts News in to the vendor news table
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id         IN  NUMBER    Required
--                    vendor id.
--                 p_news_rec        IN  AMV_NEWS_OBJ_TYPE  Required
--                    array of news objects.
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Insert_VendorNews
(     p_api_version     	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_vendor_id          	IN  NUMBER,
      p_news_rec      	IN  AMV_NEWS_OBJ_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_CompanyNews
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Inserts News in to the vendor news table
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id         IN  NUMBER    Required
--                    vendor id.
--    OUT        : x_return_status     OUT VARCHAR2
--                 x_msg_count         OUT NUMBER
--                 x_msg_data          OUT VARCHAR2
--                 x_news_array        OUT AMV_NEWS_VARRAY_TYPE
--                    array of news objects.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_CompanyNews
(p_api_version             IN  NUMBER,
 p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
 p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 x_return_status           OUT NOCOPY  VARCHAR2,
 x_msg_count               OUT NOCOPY  NUMBER,
 x_msg_data                OUT NOCOPY  VARCHAR2,
 p_stock_id                IN  NUMBER,
 x_news_array              OUT NOCOPY  AMV_NEWS_VARRAY_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_stock_pvt;

 

/
