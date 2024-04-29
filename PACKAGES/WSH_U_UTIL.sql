--------------------------------------------------------
--  DDL for Package WSH_U_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_U_UTIL" AUTHID CURRENT_USER AS
/* $Header: WSHUUTLS.pls 115.5 2002/11/12 02:04:35 nparikh ship $ */

-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Calculate_Token
--	Type				: public
--	Function			: use '%' as delimiter, strip off the first token.
--						  if '%' is not found, just return the substring
--						  starting from x_Start_Token till the end.
--
--	Version			: Initial version 1.0
-- Notes
--
--
-- End of comments
-- ---------------------------------------------------------------------
FUNCTION Calculate_Token(x_In_Message IN OUT NOCOPY  VARCHAR2,
                         x_Start_Token IN OUT NOCOPY  NUMBER,
                         x_End_Token IN OUT NOCOPY  NUMBER) RETURN VARCHAR2;



-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Get_Carrier_API_URL
--	Type				: public
--	Function			: get the URL to for calling Carrier API
--	Version			: Initial version 1.0
-- Notes
--
--
-- End of comments
-- ---------------------------------------------------------------------


FUNCTION Get_Carrier_API_URL(
			   p_api_version            IN     NUMBER,
			   p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
			   x_return_status         OUT NOCOPY      VARCHAR2,
			   x_msg_count             OUT NOCOPY      NUMBER,
			   x_msg_data              OUT NOCOPY      VARCHAR2,
			   p_Carrier_Name 		  IN 	VARCHAR2,
                  p_API_Name		 	  IN 	VARCHAR2) RETURN VARCHAR2;

-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Get_PROXY
--	Type				: public
--	Function			: get oracle proxy server
--	Version			: Initial version 1.0
-- Notes				:
--						  proper alignment
--
-- End of comments
-- ---------------------------------------------------------------------


FUNCTION Get_PROXY (
			   	p_api_version            IN     NUMBER,
			   	p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
				x_return_status         OUT NOCOPY      VARCHAR2,
				x_msg_count             OUT NOCOPY      NUMBER,
				x_msg_data              OUT NOCOPY      VARCHAR2) RETURN VARCHAR2;

END WSH_U_UTIL;

 

/
