--------------------------------------------------------
--  DDL for Package Body OPI_DBI_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_CURRENCY_PKG" as
/* $Header: OPICURRB.pls 115.2 2003/01/10 00:07:47 csheu noship $ */

g_global_currency_code	varchar2(3);
g_ou_is_cached		BOOLEAN := FALSE;
g_w_is_cached		BOOLEAN := FALSE;

g_rate_date DATE := to_date('01/01/0039', 'DD/MM/YYYY');
g_currency_rate  NUMBER;
g_rate_type  VARCHAR2(150) := '**YYYYYYY';
g_currency_code VARCHAR2(150) := '**YYYYYYY';
g_rate  NUMBER := -99999;

g_operating_unit varchar2(10);
g_functional_currency_code varchar2(3);
g_common_functional_currency varchar2(3);
g_sec_profile_id varchar2(10);

-- -------------------------------
-- get_global_currency
-- -------------------------------
FUNCTION get_global_currency RETURN VARCHAR2 IS

BEGIN

 return bis_common_parameters.get_currency_code;

END get_global_currency;

-- -------
-- get_ou
-- -------

FUNCTION get_ou(p_selected_org IN varchar2) RETURN NUMBER IS

l_ou	NUMBER;

BEGIN

    select DECODE(FPG.MULTI_ORG_FLAG, 'Y', TO_NUMBER(HOI2.ORG_INFORMATION3),
     TO_NUMBER(NULL))
    into l_ou
    from HR_ORGANIZATION_INFORMATION HOI2,
	FND_PRODUCT_GROUPS FPG
    where (HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
    and organization_id = p_selected_org;

    return l_ou;

  EXCEPTION
    when others then
	return (-1);

END get_ou;

-- ---------------------
-- get_display_currency
-- ----------------------

FUNCTION get_display_currency( p_currency_code	IN varchar2,
			       p_selected_org  	IN varchar2,
                               p_org_type	IN varchar2) return varchar2
 IS

 l_f_currency_code	varchar2(15) := null;
 l_return_value		varchar2(1)  := '0';
 l_ou			number;
 l_failure		exception;


 BEGIN

    -- selected currency is the same as the global currency

   if(upper(p_org_type) = 'O') THEN -- for operating unit page parameter

    IF NOT g_ou_is_cached THEN
        g_global_currency_code := bis_common_parameters.get_currency_code;
        g_ou_is_cached := TRUE;

        IF (g_global_currency_code is null) THEN
          RAISE l_failure;
        END IF;

    end IF;

    if(p_currency_code = 'FII_GLOBAL1') then
     	return '1';

    else -- Currency is not the global currency

     if(p_selected_org <> 'ALL') then
	select currency_code
	  into l_f_currency_code
	from financials_system_params_all fsp,
	     gl_sets_of_books gsob
	where fsp.org_id = p_selected_org
	  and fsp.set_of_books_id = gsob.set_of_books_id;

     	if(p_currency_code = l_f_currency_code) then
		if(l_f_currency_code = g_global_currency_code) then return '0';
		else return '1';
		end if;
        else
            return '0';
        end if;

     else -- if org ='ALL' returns '0' for non-global currency
      return '0';
     end if;
    end if;

  elsif (upper(p_org_type) = 'W') THEN   -- for inventory org page parameter

    IF NOT g_w_is_cached then
        g_global_currency_code := bis_common_parameters.get_currency_code;
        g_w_is_cached := TRUE;

        IF (g_global_currency_code is null) THEN
          RAISE l_failure;
        END IF;
    END IF;

    if(p_currency_code = 'FII_GLOBAL1') then
	  return '1';

    else  -- Currency is not the global currency

     if(p_selected_org <> 'ALL') then

        l_ou := get_ou(p_selected_org);

	IF(l_ou = -1) THEN
	  RAISE l_failure;
	END IF;

	select currency_code
	  into l_f_currency_code
	from financials_system_params_all fsp,
	     gl_sets_of_books gsob
	where fsp.org_id = l_ou
	  and fsp.set_of_books_id = gsob.set_of_books_id;

       	if(p_currency_code = l_f_currency_code) then
		if(l_f_currency_code = g_global_currency_code) then return '0';
		else return '1';
		end if;
       	else
	  return '0';
       	end if;

     else -- p_selected_org = 'ALL' and functional currency
	  return '0';

     end if; -- end if p_selected_org<>'ALL'
    end if;  -- end if p_currency_code = 'FII_GLOBAL1'

  end if;

  EXCEPTION
    when l_failure then
	return '0';

    when others then
	return '0';


  END get_display_currency;


END OPI_DBI_CURRENCY_PKG;

/
