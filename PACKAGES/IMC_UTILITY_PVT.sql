--------------------------------------------------------
--  DDL for Package IMC_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IMC_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: imcvutls.pls 120.2 2006/02/20 23:40:50 vnama noship $ */
-- Start of Comments
-- Package name     : IMC_UTILITY_PVT
-- Purpose          :
-- History          :
--                  Colathur Vijayan (VJN) 1/7/2002, included function that would return
--                  a html link tag which will contain the address formatted for Yahoo Maps.
--    Vivek Nama             -- Bug 4915127: stubbing apis
--                              GET_OVRW_MENU_PARAM()
--                              GET_EMP_MENU_PARAM()
--                              GET_ADMIN_FUNCTION_ID()
-- NOTE             :
-- End of Comments
----------------------------------------------------

-- Returns a URL of the form,
--
FUNCTION GET_YAHOO_MAP_URL(address1                IN VARCHAR2,
                           address2                IN VARCHAR2,
                           address3                IN VARCHAR2,
                           address4                IN VARCHAR2,
                           city                    IN VARCHAR2,
                           country                 IN VARCHAR2,
                           state                   IN VARCHAR2,
                           postal_code             IN VARCHAR2)
RETURN VARCHAR2;
--
------------------------------------------------------------------------------
--
-- This function will return a html link tag which will contain the address formatted for Yahoo Maps.
------------------------------------------------------------------------------
FUNCTION GET_YAHOO_ADDRESS_LINK_TAG(       address_style           IN VARCHAR2,
                                           address1                IN VARCHAR2,
                                           address2                IN VARCHAR2,
                                           address3                IN VARCHAR2,
                                           address4                IN VARCHAR2,
                                           city                    IN VARCHAR2,
                                           county                  IN VARCHAR2,
                                           state                   IN VARCHAR2,
                                           province                IN VARCHAR2,
                                           postal_code             IN VARCHAR2,
                                           territory_short_name    IN VARCHAR2,
                                           country_code            IN VARCHAR2,
                                           customer_name           IN VARCHAR2,
                                           bill_to_location        IN VARCHAR2,
                                           first_name              IN VARCHAR2,
                                           last_name               IN VARCHAR2,
                                           mail_stop               IN VARCHAR2,
                                           default_country_code    IN VARCHAR2,
                                           default_country_desc    IN VARCHAR2,
                                           print_home_country_flag IN VARCHAR2,
                                           width                   IN NUMBER,
                                           height_min              IN NUMBER,
                                           height_max              IN NUMBER
                                          )
RETURN VARCHAR2;

------------------------------------------------------------------------------
-- Bug 4915127: stubbing api
------------------------------------------------------------------------------
FUNCTION GET_OVRW_MENU_PARAM(resp_id IN NUMBER,
		             type IN VARCHAR2)
RETURN VARCHAR2;

------------------------------------------------------------------------------
-- Bug 4915127: stubbing api
------------------------------------------------------------------------------
FUNCTION GET_EMP_MENU_PARAM(resp_id IN NUMBER)
RETURN VARCHAR2;

------------------------------------------------------------------------------
-- Bug 4915127: stubbing api
------------------------------------------------------------------------------
FUNCTION GET_ADMIN_FUNCTION_ID(p_lang IN VARCHAR2, p_respid in number, p_appid in number)
RETURN NUMBER;

End IMC_UTILITY_PVT;

 

/
