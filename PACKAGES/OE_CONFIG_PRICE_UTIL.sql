--------------------------------------------------------
--  DDL for Package OE_CONFIG_PRICE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_PRICE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUCFPS.pls 120.0.12010000.3 2009/01/23 10:04:41 srsunkar ship $ */


PROCEDURE OE_Config_Price_Items
(  p_config_session_key      IN  VARCHAR2
  ,p_price_type              IN  VARCHAR2 -- list, selling
  ,x_total_price             OUT NOCOPY NUMBER

);

--For Bug# 7695217
 PROCEDURE OE_Config_Price_Items_MLS
   (  p_config_session_key      IN  VARCHAR2
     ,p_price_type              IN  VARCHAR2 -- list, selling
     ,x_total_price             OUT NOCOPY NUMBER
     ,x_currency_code           OUT NOCOPY VARCHAR2
   );
--End of Bug# 7695217

END OE_CONFIG_PRICE_UTIL;


/
