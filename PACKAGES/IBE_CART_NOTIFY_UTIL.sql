--------------------------------------------------------
--  DDL for Package IBE_CART_NOTIFY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CART_NOTIFY_UTIL" AUTHID CURRENT_USER AS
/* $Header: IBEVCNUS.pls 115.3 2002/12/13 02:52:28 mannamra ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_CART_NOTIFY_UTIL';

  TYPE notify_line_tokens_rec_type IS RECORD
  (
     Quote_line_id     NUMBER       := FND_API.G_MISS_NUM,
     Item_name         VARCHAR2(240):= FND_API.G_MISS_CHAR,
     Item_Quantity     NUMBER       := FND_API.G_MISS_NUM,
     Shippable_flag    VARCHAR2(10) := FND_API.G_MISS_CHAR,
     Line_quote_price  NUMBER       := FND_API.G_MISS_NUM
  );

  G_MISS_notify_line_tokens_rec    notify_line_tokens_rec_type;
  TYPE notify_line_tokens_tab_type IS TABLE OF notify_line_tokens_rec_type
                                   INDEX BY BINARY_INTEGER;
  G_MISS_notify_line_tokens_tab    notify_line_tokens_tab_type;

  PROCEDURE Get_sales_assist_hdr_tokens(
                 p_api_version      IN  NUMBER   := 1.0                   ,
                 p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE        ,
                 p_commit           IN  VARCHAR2 := FND_API.G_FALSE       ,
                 x_return_status    OUT NOCOPY VARCHAR2                   ,
                 x_msg_count        OUT NOCOPY NUMBER                     ,
                 x_msg_data         OUT NOCOPY VARCHAR2                   ,
                 p_quote_header_id  IN  NUMBER                            ,
                 p_minisite_id      IN  NUMBER                            ,
                 x_Contact_Name     OUT NOCOPY VARCHAR2                   ,
                 x_Contact_phone    OUT NOCOPY VARCHAR2                   ,
                 x_email            OUT NOCOPY VARCHAR2                   ,
                 x_first_name       OUT NOCOPY VARCHAR2                   ,
                 X_last_name        OUT NOCOPY VARCHAR2                   ,
                 x_Cart_name        OUT NOCOPY VARCHAR2                   ,
                 X_cart_date        OUT NOCOPY VARCHAR2                   ,
                 x_Ship_to_name     OUT NOCOPY VARCHAR2                   ,
                 x_ship_to_address1 OUT NOCOPY VARCHAR2                   ,
                 x_ship_to_address2 OUT NOCOPY VARCHAR2                   ,
                 x_ship_to_address3 OUT NOCOPY VARCHAR2                   ,
                 x_ship_to_address4 OUT NOCOPY VARCHAR2                   ,
                 x_country          OUT NOCOPY VARCHAR2                   ,
                 X_CITY             OUT NOCOPY VARCHAR2                   ,
                 X_POSTAL_CODE      OUT NOCOPY VARCHAR2                   ,
                 X_SHIP_TO_STATE    OUT NOCOPY VARCHAR2                   ,
                 X_SHIP_TO_PROVINCE OUT NOCOPY VARCHAR2                   ,
                 X_SHIP_TO_COUNTY   OUT NOCOPY VARCHAR2                   ,
                 x_shipping_method  OUT NOCOPY VARCHAR2                   ,
                 x_minisite_name    OUT NOCOPY VARCHAR2                   ,
                 x_ship_and_hand    OUT NOCOPY NUMBER                     ,
                 x_tax              OUT NOCOPY NUMBER                     ,
                 x_total            OUT NOCOPY NUMBER                     );

  PROCEDURE Get_sales_assist_line_tokens(
                 p_api_version        IN  NUMBER   := 1.0                  ,
                 p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE       ,
                 p_commit             IN  VARCHAR2 := FND_API.G_FALSE      ,
                 x_return_status      OUT NOCOPY VARCHAR2                  ,
                 x_msg_count          OUT NOCOPY NUMBER                    ,
                 x_msg_data           OUT NOCOPY VARCHAR2                  ,
                 P_quote_header_id    IN  NUMBER                           ,
                 x_notify_line_tokens OUT NOCOPY IBE_CART_NOTIFY_UTIL.notify_line_tokens_tab_type);

END IBE_CART_NOTIFY_UTIL;

 

/
