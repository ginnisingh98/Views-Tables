--------------------------------------------------------
--  DDL for Package Body POA_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_CURRENCY_PKG" as
/* $Header: POACURB.pls 120.1 2005/09/09 11:37:44 nnewadka noship $ */

g_rate_date DATE := to_date('01/01/0039', 'DD/MM/YYYY');
g_currency_rate  NUMBER;
g_rate_type  VARCHAR2(150) := '**YYYYYYY';
g_currency_code VARCHAR2(150) := '**YYYYYYY';
g_rate  NUMBER := -99999;

g_global_currency_code varchar2(3);
g_operating_unit varchar2(10);
g_functional_currency_code varchar2(3);
g_common_functional_currency varchar2(3);
g_sec_profile_id varchar2(10);

g_sglobal_currency_code varchar2(3);
g_display_sglobal_currency Boolean;

-- -------------------------------
-- get_global_currency
-- -------------------------------
FUNCTION get_global_currency RETURN VARCHAR2 IS

BEGIN

 return bis_common_parameters.get_currency_code;

END get_global_currency;


-- -------------------------------
-- get_secondary_global_currency
-- -------------------------------
FUNCTION get_secondary_global_currency RETURN VARCHAR2 IS

BEGIN

 return bis_common_parameters.get_secondary_currency_code;

END get_secondary_global_currency;

-- -------------------------------
-- display_secondary_currency_yn
-- -------------------------------
FUNCTION display_secondary_currency_yn RETURN BOOLEAN IS
BEGIN

    IF(bis_common_parameters.get_secondary_currency_code IS NOT NULL AND
        (
            (bis_common_parameters.get_currency_code <>
            bis_common_parameters.get_secondary_currency_code)
            OR
           ( bis_common_parameters.get_rate_type <>
	    bis_common_parameters.get_secondary_rate_type)
        )
      )
    THEN
           RETURN TRUE;
    ELSE
           RETURN FALSE;
    END IF;
END display_secondary_currency_yn;

-- -------------------------------
-- get_global_rate
-- -------------------------------
FUNCTION get_global_rate (x_trx_currency_code     VARCHAR2,
                          x_exchange_date         DATE,
                          x_exchange_rate_type    VARCHAR2
) RETURN NUMBER IS

  l_global_currency_code  VARCHAR2(30);
  l_global_rate_type   VARCHAR2(15);

begin
    l_global_currency_code := fnd_profile.value('POA_CURRENCY_CODE');
    l_global_rate_type := fnd_profile.value('POA_CURRENCY_RATE_TYPE');

    if  x_trx_currency_code = l_global_currency_code then
       return 1;
  else
    return GL_CURRENCY_API.get_rate_sql (
                    x_trx_currency_code,
                    l_global_currency_code,
                    x_exchange_date,
                    l_global_rate_type);

  end if;

EXCEPTION
  WHEN OTHERS THEN
     return null;

END get_global_rate;

-- -------------------------------
-- get_global_currency_rate
-- -------------------------------
FUNCTION get_global_currency_rate (p_rate_type      VARCHAR2,
                                   p_currency_code  VARCHAR2,
                                   p_rate_date      DATE,
                                   p_rate           NUMBER)  RETURN NUMBER IS
BEGIN
   if (p_rate_type is NULL) then
      if (p_rate_date <> g_rate_date OR  p_currency_code <> g_currency_code
                                     OR g_rate_type is NOT NULL) then
         g_currency_code :=  p_currency_code;
         g_rate_date     :=  p_rate_date;
         g_rate_type     :=  p_rate_type;
         g_currency_rate :=  get_global_rate(p_currency_code,
                                             p_rate_date, NULL);
      end if;
   elsif (p_rate_type = 'User') then
      if (p_rate_date <> g_rate_date OR p_currency_code <> g_currency_code OR
          p_rate_type <> g_rate_type OR g_rate_type is NULL OR
          p_rate <> g_rate) then
         g_currency_code :=  p_currency_code;
         g_rate_date     :=  p_rate_date;
         g_rate_type     :=  p_rate_type;
         g_currency_rate :=  get_global_rate(p_currency_code,
                                             p_rate_date, NULL) * p_rate;
      end if;
   else   /* p_rate_type is NOT NULL and p_rate_type <> 'User' */
      if (p_rate_date <> g_rate_date OR p_currency_code <> g_currency_code OR
          p_rate_type <> g_rate_type OR g_rate_type is NULL) then
                  g_currency_code :=  p_currency_code;
         g_rate_date     :=  p_rate_date;
         g_rate_type     :=  p_rate_type;
         g_currency_rate :=  get_global_rate(p_currency_code,
                                             p_rate_date, p_rate_type);
      end if;
   end if;
   return g_currency_rate;

 END get_global_currency_rate;

 FUNCTION get_display_currency(p_currency_code                IN varchar2,
                               p_selected_operating_unit      IN varchar2,
                               p_global_cur_type              IN varchar2
                                                                    DEFAULT 'P'
                               ) return varchar2
 IS
 l_return_value varchar2(1) := '0';

 l_value        NUMBER;
 l_global_cur_type VARCHAR2(3);
 BEGIN
    -- selected currency is the same as the global currency

 	BEGIN
              l_value := to_number(p_global_cur_type);
            SELECT 	 CASE WHEN BitAnd(l_value , 7) = 7    THEN 'PS'
                          WHEN BitAnd(l_value , 5) = 5    THEN 'S'
                          WHEN BitAnd(l_value , 3) = 3    THEN 'P'
                     END     INTO  l_global_cur_type
            FROM DUAL;
        EXCEPTION
          WHEN OTHERS THEN
          l_global_cur_type := p_global_cur_type;
        END;
    if(g_global_currency_code is null) then
       g_global_currency_code := get_global_currency;
    end if;

    if(g_sglobal_currency_code is null) then
       g_sglobal_currency_code := get_secondary_global_currency;
    end if;

    IF(g_display_sglobal_currency IS NULL) THEN
       g_display_sglobal_currency := display_secondary_currency_yn;
    END IF;

	    -- Check for Annualized currency

    if ((BitAnd(l_value, 8) = 8) AND (p_currency_code = 'FII_GLOBAL3'))	THEN
         return 1;        --Show annualized currency
    elsif ((l_global_cur_type ='P' OR  l_global_cur_type ='PS')
              AND p_currency_code = 'FII_GLOBAL1') then
                return '1' ; --show the primary global currency

    elsif ((l_global_cur_type ='S' OR l_global_cur_type ='PS')
	          AND  p_currency_code = 'FII_GLOBAL2'
	             AND g_display_sglobal_currency) then
               return '1';  --  show the secondary global currency
   else
      -- Currency is not the global currency

     if(nvl(p_selected_operating_unit,'ALL') <> 'ALL') then

      if(p_selected_operating_unit <> g_operating_unit or g_operating_unit is null) then
        select currency_code
          into g_functional_currency_code
        from financials_system_params_all fsp,
             gl_sets_of_books gsob
        where fsp.org_id = p_selected_operating_unit
          and fsp.set_of_books_id = gsob.set_of_books_id;
        g_operating_unit := p_selected_operating_unit;
     end if;

     if(p_currency_code = g_functional_currency_code)
      then
    --if primary global currency and functional Currency are same then
       if (g_global_currency_code = g_functional_currency_code)
         then
           -- Same as primary global currency
           return '0';
        else

           if(l_global_cur_type ='S' OR l_global_cur_type ='PS')
            then
              -- product team is implementing Secondary global currency
              if(g_sglobal_currency_code = g_functional_currency_code)
               then
                 -- Currency is same as Secondary global currency
                 return '0';
               else
                 return '1';
              end if;
           else
              -- Product team is not implementing secondary global currency
              return '1';
           end if;
        end if;
      else
        -- Currency is not a functional currency
        return '0';
     end if;
   else  -- operating unit is 'All'


---Begin MOAC changes
---Following block is commemnted
/*
     if(g_common_functional_currency is null or nvl(g_sec_profile_id, -1) <> poa_dbi_util_pkg.get_sec_profile) then
       g_sec_profile_id := poa_dbi_util_pkg.get_sec_profile;
       select distinct currency_code
        into g_common_functional_currency
       from financials_system_params_all fsp,
           gl_sets_of_books gsob
       where fsp.set_of_books_id = gsob.set_of_books_id
       and fsp.org_id in (select organization_id from per_organization_list where security_profile_id = poa_dbi_util_pkg.get_sec_profile);
     end if;
*/

     IF g_common_functional_currency IS NULL THEN
        IF poa_dbi_util_pkg.get_sec_profile <> -1 THEN
           SELECT DISTINCT currency_code
                  INTO g_common_functional_currency
           FROM financials_system_params_all fsp,
                gl_sets_of_books gsob
           WHERE fsp.set_of_books_id = gsob.set_of_books_id
           AND  EXISTS (SELECT 1
                              FROM per_organization_list  org_list
                WHERE org_list.security_profile_id = poa_dbi_util_pkg.get_sec_profile
                              AND   org_list.organization_id = fsp.org_id );

        ELSE
           SELECT DISTINCT currency_code
                  INTO g_common_functional_currency
           FROM financials_system_params_all fsp,
                gl_sets_of_books gsob
           WHERE fsp.set_of_books_id = gsob.set_of_books_id
           AND   fsp.org_id = poa_dbi_util_pkg.get_ou_org_id ;
        END IF ; --poa_dbi_util_pkg.get_sec_profile <> -1
     END IF ; --g_functional_currency IS NULL
---End MOAC changes

     if(p_currency_code = g_common_functional_currency)
      then
    --if primary global currency and functional Currency are same then
       if (g_global_currency_code = g_common_functional_currency)
         then
           -- Same as primary global currency
           return '0';
        else

           if(l_global_cur_type ='S' OR l_global_cur_type ='PS')
            then
              -- product team is is implementing Secondary global currency
              if(g_sglobal_currency_code = g_common_functional_currency)
               then
                 -- Currency is same as Secondary global currency
                 return '0';
               else
                 return '1';
              end if;
           else
              -- Product team is not implementing secondary global currency
              return '1';
           end if;
        end if;
      else
        -- Currency is not a functional currency
        return '0';
     end if;
    end if;
   end if;

  EXCEPTION
    when too_many_rows then
      g_common_functional_currency := 'N/A';
      return '0';
    when others then
      return '0';
  END get_display_currency;

-- -------------------------------
-- get_dbi_global_rate
-- -------------------------------
  FUNCTION get_dbi_global_rate (p_rate_type VARCHAR2,
				p_currency_code VARCHAR2,
				p_rate_date DATE,
                                p_txn_cur_code VARCHAR2) RETURN NUMBER
    IS
       l_ret NUMBER;
       l_rate_date DATE := p_rate_date;
    BEGIN
       l_ret := fii_currency.get_fc_to_pgc_rate(p_txn_cur_code, p_currency_code, p_rate_date);
       IF (l_ret < 0) THEN
	  IF (not g_missing_cur) THEN
	     bis_collection_utilities.writemissingrateheader;
	     g_missing_cur := TRUE;
	  END IF;
	  IF (l_ret = -3) THEN
	     l_rate_date := to_date('01/01/1999','MM/DD/RRRR');
	  END IF;
	  bis_collection_utilities.writemissingrate(p_rate_type, p_currency_code,  get_global_currency(), l_rate_date);
       END IF;
       RETURN l_ret;
  END get_dbi_global_rate;

-- -------------------------------
-- get_dbi_sglobal_rate
-- -------------------------------
  function get_dbi_sglobal_rate(
             p_rate_type varchar2,
             p_currency_code varchar2,
             p_rate_date date,
             p_txn_cur_code varchar2
           ) return number
  is
    l_ret number;
    l_rate_date date := p_rate_date;
  begin
    l_ret := fii_currency.get_fc_to_sgc_rate(p_txn_cur_code, p_currency_code, p_rate_date);
    if (l_ret < 0) then
      if (not g_missing_cur) then
        bis_collection_utilities.writemissingrateheader;
        g_missing_cur := true;
      end if;
      if (l_ret = -3) then
         l_rate_date := to_date('01/01/1999','MM/DD/RRRR');
      end if;
      bis_collection_utilities.writemissingrate(p_rate_type, p_currency_code, get_secondary_global_currency(), l_rate_date);
    end if;
    return l_ret;
  end get_dbi_sglobal_rate;

END POA_CURRENCY_PKG;

/
