--------------------------------------------------------
--  DDL for Package Body FII_CURRENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CURRENCY_API" AS
/* $Header: FIICAC1B.pls 120.4 2005/10/30 05:07:42 appldev noship $  */

-- -------------------------------------------------------------------
-- Name: get_display_name
-- Desc: Returns the display name of a currency code in a specific format.
--       Info is cached after initial access
-- Output: Display name of a given currency at the given rate type. e.g. given USD
--         as the currency code and Corporate Rate as the rate type, it returns
--         USD at Corporate Rate
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_display_name(currency_code varchar2, rate varchar2) return varchar2 is
  l_name varchar2(100);
begin

  fnd_message.set_name('FII','FII_CURRENCY_DISPLAY_NAME');
  fnd_message.set_token('CURRENCY_CODE',currency_code,FALSE);
  fnd_message.set_token('RATE',rate,FALSE);
  l_name := fnd_message.get;

  return l_name;
end get_display_name;

Function get_prim_curr_name return varchar2 is
  l_name varchar2(100);
  l_currency_code varchar2(100);
  l_secondary_currency_code varchar2(100);
  l_rate varchar2(100);
begin

 IF bis_common_parameters.get_primary_curdis_name IS NOT NULL THEN
    l_name := bis_common_parameters.get_primary_curdis_name;
 ELSE
    SELECT bis_common_parameters.get_currency_code,
           bis_common_parameters.get_secondary_currency_code,
           user_conversion_type
      into l_currency_code,
           l_secondary_currency_code,
           l_rate
      FROM gl_daily_conversion_types
     WHERE bis_common_parameters.get_currency_code is not null
       AND bis_common_parameters.get_rate_type = conversion_type;

 -- bug 3887180: if primary not same as secondary, just display the code
    if l_secondary_currency_code is NULL OR
       l_secondary_currency_code <> l_currency_code then
      l_name := l_currency_code;
    else
      l_name := get_display_name(l_currency_code, l_rate);
    end if;

 END IF;

  return l_name;

EXCEPTION
  WHEN OTHERS THEN
    return NULL;

end get_prim_curr_name;

Function get_sec_curr_name return varchar2 is
  l_name varchar2(100);
  l_currency_code varchar2(100);
  l_secondary_currency_code varchar2(100);
  l_secondary_rate varchar2(100);
begin

 IF bis_common_parameters.get_secondary_curdis_name IS NOT NULL THEN
    l_name := bis_common_parameters.get_secondary_curdis_name;
 ELSE
    SELECT bis_common_parameters.get_currency_code,
           bis_common_parameters.get_secondary_currency_code,
           user_conversion_type
      into l_currency_code,
           l_secondary_currency_code,
           l_secondary_rate
     FROM gl_daily_conversion_types
    WHERE bis_common_parameters.get_secondary_currency_code is not null
      AND bis_common_parameters.get_secondary_rate_type = conversion_type;

 -- bug 3887180: if secondary not same as primary, just display the code
    if l_secondary_currency_code <> l_currency_code then
      l_name := l_secondary_currency_code;
    else
      l_name := get_display_name(l_secondary_currency_code, l_secondary_rate);
    end if;

 END IF;

  return l_name;

EXCEPTION
  WHEN OTHERS THEN
    return NULL;

end get_sec_curr_name;


/* Enh#3659270 : This function returns the annualized currency name */
Function get_annualized_curr_name return varchar2 is
  l_name varchar2(100):=null;
  l_currency_code varchar2(15);
  l_rate varchar2(30);
begin

     l_name := fnd_profile.value('BIS_ANNUALIZED_CURDISP_NAME');
     IF l_name is not null THEN
         return l_name;
     ELSE
         l_currency_code := fnd_profile.value('BIS_ANNUALIZED_CURRENCY_CODE');
         if l_currency_code is not null then
             SELECT user_conversion_type
	            into
		    l_rate
             FROM gl_daily_conversion_types
             WHERE conversion_type=fnd_profile.value('BIS_ANNUALIZED_RATE_TYPE');

       	   fnd_message.set_name('FII','FII_ANNUALIZED_CURR_DISP_NAME');
           fnd_message.set_token('CURRENCY_CODE',l_currency_code,FALSE);
           fnd_message.set_token('RATE',l_rate,FALSE);
	   l_name := fnd_message.get;

	 end if;

      END IF;

     return l_name;
  exception
    WHEN NO_DATA_FOUND THEN
        return null;
    WHEN OTHERS THEN
         raise;
end;


end;

/
