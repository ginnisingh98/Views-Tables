--------------------------------------------------------
--  DDL for Package Body IMC_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_UTILITY_PVT" AS
/* $Header: imcvutlb.pls 120.2 2006/02/20 23:39:48 vnama noship $ */
-- Start of Comments
-- Package name     : IMC_UTILITY_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- Changes:
--    Colathur Vijayan (VJN) -- 1/4/2002 : Fixing Bug 2167071
--    Colathur Vijayan (VJN) -- 1/7/2002, included function that would return
--    a html link tag which will contain the address formatted for Yahoo Maps.
--    Colathur Vijayan (VJN) -- 2/7/2002 : Increased the size of the arrays
--    url and html_tagged_url
--    Colathur Vijayan (VJN) -- 4/15/2002 : Added code to catch exception
--                         when the AR Package function that returns the
--                         formatted address goes berserk(a bug in AR).
--    Colathur Vijayan (VJN) -- 4/18/2002,defined global variable for doing
--                              the fnd profile for default country and called
--                              the AR Package using this value.
--    Vivek Nama             -- Bug 4915127: stubbing apis
--                              GET_OVRW_MENU_PARAM()
--                              GET_EMP_MENU_PARAM()
--                              GET_ADMIN_FUNCTION_ID()
-- End of Comments
----------------------------------------------------

amp VARCHAR2(01) := '&';
staticURL VARCHAR2(100) := 'http://maps.yahoo.com/py/maps.py?BFCat=' || amp || 'Pyt=Tmap' || amp || 'newFL=Use+Address+Below' || amp || 'Get%A0Map=Get+Map';
countryProfileValue  VARCHAR2(25) := FND_PROFILE.Value ('ASF_DEFAULT_COUNTRY');

  type num_tab_ibbi is table of number index by binary_integer;

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
RETURN VARCHAR2 AS
    url VARCHAR2(300);
    country_code VARCHAR2(20);
BEGIN
-- Since TCA validates the country code of UK to GB and Yahoo Maps expects 'uk'
-- we resort to this work around
    IF upper(rtrim(country)) = 'GB'
    THEN
       country_code := 'uk';
    ELSE
       country_code := rtrim(country);
    END IF;

    URL := staticURL ||
           amp || 'addr=' || REPLACE(SUBSTRB(RTRIM(address1),1,60), ' ', '+') ||
           amp || 'csz=' || REPLACE(SUBSTRB(RTRIM(city),1,50), ' ', '+') || '%2C+' || SUBSTRB(RTRIM(state),1,20) || '+' || SUBSTRB(RTRIM(postal_code),1,20) ||
           amp || 'Country=' || country_code;

    RETURN url;
END GET_YAHOO_MAP_URL;
--

------------------------------------------------------------------------------------------------------------
-- This function will return a html link tag which will contain the address formatted for Yahoo Maps.
------------------------------------------------------------------------------------------------------------
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
RETURN VARCHAR2 AS
    url VARCHAR2(526);
    validated_country_code VARCHAR2(10);
    formatted_address VARCHAR2(200);
    html_tagged_url VARCHAR2(1000);
BEGIN
    IF upper(rtrim(country_code)) = 'GB'
    THEN
       validated_country_code := 'uk';
    ELSE
       validated_country_code := rtrim(country_code);
    END IF;

    URL := staticURL ||
           amp || 'addr=' || REPLACE(address1, ' ', '+') ||
           amp || 'csz=' || REPLACE(city, ' ', '+') || '%2C+' || RTRIM(state) || '+' || RTRIM(postal_code) ||
           amp || 'Country=' || validated_country_code ;

    formatted_address := ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(null,address1,address2,address3,address4,
                                                                city,county,state,province,postal_code,
                                                                country_code,country_code, null,null,null,null,null,
                                                                countryProfileValue,
                                                                null,    null,    2000,    1,    1);

    html_tagged_url := '<a href="' || URL || '", target="_blank">' || formatted_address || '</a>';
    RETURN html_tagged_url;

EXCEPTION
        WHEN OTHERS
        THEN
           html_tagged_url := '<a href="' || 'www.errorhappened.com' || '", targ
et="_blank">' || formatted_address || '</a>';
           RETURN html_tagged_url;


END GET_YAHOO_ADDRESS_LINK_TAG ;
--

------------------------------------------------------------------------------
-- Bug 4915127: stubbing api
------------------------------------------------------------------------------
FUNCTION GET_OVRW_MENU_PARAM(resp_id IN NUMBER,
                             type IN VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
 RETURN '';
END GET_OVRW_MENU_PARAM;


------------------------------------------------------------------------------
-- Bug 4915127: stubbing api
------------------------------------------------------------------------------
FUNCTION GET_EMP_MENU_PARAM(resp_id IN NUMBER)
RETURN VARCHAR2 AS
BEGIN
  RETURN '';
END GET_EMP_MENU_PARAM;


------------------------------------------------------------------------------
-- This procedure is an internal procedure called by GET_ADMIN_FUNCTION_ID.
-- It obtains menu structure recursively through in order recursion.
------------------------------------------------------------------------------

  procedure get_excl_menu_tree_recurs_tl(p_lang varchar2, p_menu_id number,
    p_respid number, p_appid number,
    p_kids_menu_ids in out nocopy jtf_menu_pub.number_table,
    p_kids_menu_data in out nocopy jtf_menu_pub.menu_table)
  is
    t_new_ids num_tab_ibbi;
    t_mt jtf_menu_pub.menu_table;
    cnt number;
    loc number;
  begin
    jtf_menu_pub.get_excluded_menu_entries_tl(p_lang, p_menu_id, p_respid, p_appid, t_mt);

    if t_mt is null or t_mt.count = 0 then return; end if;

    cnt := t_mt.first;
    while true loop
      -- put the p_menu_id in the p_kids_menu_ids, and the new menu_data
      -- from t_mt into the p_kids_menu_data
      loc := p_kids_menu_ids.count+1;
      p_kids_menu_ids(loc) := p_menu_id;
      p_kids_menu_data(loc) := t_mt(cnt);

      -- if this child also points at a menu, then recurse
      if t_mt(cnt).sub_menu_id is not null then
          get_excl_menu_tree_recurs_tl(p_lang, t_mt(cnt).sub_menu_id, p_respid, p_appid,
            p_kids_menu_ids, p_kids_menu_data);
      end if;

      -- next...
      if cnt = t_mt.last then exit; end if;
      cnt := t_mt.next(cnt);
    end loop;

  end get_excl_menu_tree_recurs_tl;

------------------------------------------------------------------------------
-- Bug 4915127: stubbing api
------------------------------------------------------------------------------
FUNCTION GET_ADMIN_FUNCTION_ID(p_lang IN VARCHAR2, p_respid in number, p_appid in number)
RETURN NUMBER IS
BEGIN
  RETURN 0;
END GET_ADMIN_FUNCTION_ID;

End IMC_UTILITY_PVT;

/
