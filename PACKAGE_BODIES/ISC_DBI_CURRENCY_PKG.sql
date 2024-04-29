--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CURRENCY_PKG" AS
/* $Header: ISCCURRB.pls 120.0.12000000.2 2007/01/25 07:10:18 abhdixi ship $ */

  g_global_currency_code	varchar2(100);
  g_global_rate_type		varchar2(100);
  g_sec_currency_code		varchar2(100);
  g_sec_rate_type		varchar2(100);
  g_ou_is_cached		BOOLEAN := FALSE;
  g_w_is_cached			BOOLEAN := FALSE;
  g_s_is_cached			BOOLEAN := FALSE;
  g_common_functional_currency  varchar2(15);


function is_sec_curr_defined return varchar2 is

begin
  if not g_s_is_cached then
    g_sec_currency_code := bis_common_parameters.get_secondary_currency_code;
    g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;
    g_s_is_cached := true;
  end if;

  if (g_sec_currency_code is null and g_sec_rate_type is null) then
    return 'N';
  elsif (g_sec_currency_code is not null and g_sec_rate_type is not null) then
    return 'Y';
  else
    return 'E';
  end if;

end is_sec_curr_defined;


-- -------
-- get_ou
-- -------

function get_ou(p_selected_org IN varchar2) return number is

  l_ou	number;

begin

 select	decode(fpg.multi_org_flag, 'Y', to_number(hoi2.org_information3), to_number(null))
   into	l_ou
   from	hr_organization_information 	hoi2,
	fnd_product_groups		fpg
  where	(hoi2.org_information_context || '') = 'Accounting Information'
    and	organization_id = p_selected_org;

  return l_ou;

  exception
    when others then
	return (-1);

end get_ou;

-- ---------------------
-- get_display_currency
-- ----------------------

function get_display_currency(	p_org_type	IN varchar2,
				p_currency_code	IN varchar2,
				p_selected_org	IN varchar2) return varchar2 is

  l_f_currency_code		varchar2(15);
  l_return_value		varchar2(1);
  l_ou				number;
  l_sec				varchar2(1);
  l_failure			exception;
  l_fnd_prod_grp_flag		varchar2(1);
  l_fnd_prod_grp_filter		varchar2(20);
  l_stmt			varchar2(2000);

  begin

  l_return_value := '0';

  if (upper(p_org_type) = 'O') then -- for operating unit page parameter

    if not g_ou_is_cached then
	g_global_currency_code := bis_common_parameters.get_currency_code;
	g_ou_is_cached := true;
	if (g_global_currency_code is null) then
	  raise l_failure;
	end if;
    end if;

    if (p_currency_code = 'FII_GLOBAL1') then
	return '1';

    else -- Currency is not the global currency

      if (p_selected_org <> 'ALL') then

	 select	gsob.currency_code
	   into	l_f_currency_code
	   from	ar_system_parameters_all 	asp,
		gl_sets_of_books 		gsob
	  where	asp.org_id = p_selected_org
	    and	asp.set_of_books_id = gsob.set_of_books_id;

	if (p_currency_code = l_f_currency_code) then
	  if (l_f_currency_code = g_global_currency_code or l_f_currency_code = g_sec_currency_code) then
	    return '0';
	  else
	    return '1';
	  end if;
	else
	  return '0';
	end if;

      else -- if org ='ALL' and all OUs have same function curreny which is different from global currency, show functional curr.
	if(g_common_functional_currency is null) then

          select distinct gsob.currency_code
          into g_common_functional_currency
          from ar_system_parameters_all asp,
           gl_sets_of_books gsob
          where asp.set_of_books_id = gsob.set_of_books_id
          and asp.org_id in (select organization_id from per_organization_list where security_profile_id = fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'));
     	end if;

	if (p_currency_code = g_common_functional_currency) then
	  if (g_common_functional_currency = g_global_currency_code or g_common_functional_currency = g_sec_currency_code) then
	    return '0';
	  else
	    return '1';
	  end if;
	else
	  return '0';
	end if;


      end if;
    end if;

  elsif (upper(p_org_type) = 'W') then   -- for inventory org page parameter

    if not g_w_is_cached then
	g_global_currency_code := bis_common_parameters.get_currency_code;
	g_global_rate_type := bis_common_parameters.get_rate_type;
	g_w_is_cached := true;
	if (g_global_currency_code is null) then
	  raise l_failure;
	end if;
    end if;

    if (p_currency_code = 'FII_GLOBAL1') then
	return '1';

    elsif (p_currency_code = 'FII_GLOBAL2') then

      l_sec := is_sec_curr_defined;
      if (l_sec = 'Y') then
	if (g_global_currency_code = g_sec_currency_code and g_global_rate_type = g_sec_rate_type) then
	  return '0';
	else
	  return '1';
	end if;
      else
	return '0';
      end if;


    else  -- Currency is not the global currency

      if (p_selected_org <> 'ALL') then

	l_ou := get_ou(p_selected_org);

	if (l_ou = -1) then
	  raise l_failure;
	end if;

	 select	gsob.currency_code
	   into	l_f_currency_code
	   from	ar_system_parameters_all	asp,
		gl_sets_of_books		gsob
	  where	asp.org_id = l_ou
	    and	asp.set_of_books_id = gsob.set_of_books_id;

	if (p_currency_code = l_f_currency_code) then
	  if (l_f_currency_code = g_global_currency_code or l_f_currency_code = g_sec_currency_code) then
	    return '0';
	  else
	    return '1';
	  end if;
	else
	  return '0';
	end if;

      else -- p_selected_org = 'ALL' and functional currency
	if(g_common_functional_currency is null) then

-- <Bug 4913384>

	select multi_org_flag
	into l_fnd_prod_grp_flag
	from fnd_product_groups;

	if(SQL%ROWCOUNT = 1)
	then
	  if(l_fnd_prod_grp_flag = 'Y')
	  then
		l_fnd_prod_grp_filter := ' to_number(hoi2.org_information3) ';
	  else
		l_fnd_prod_grp_filter := ' to_number(null) ';
	  end if;

	l_stmt := '  select distinct gsob.currency_code
	    	   into g_common_functional_currency        -- if not all orgs have same func currency, will error out, return 0
 		   from	(select	o.organization_id
			   from	org_access o
		  where	o.responsibility_id = fnd_global.resp_id
		    and	o.resp_application_id = fnd_global.resp_appl_id
		  union
 		 select	org.organization_id
		   from	mtl_parameters org
		  where	not exists (select 1
				   from	org_access ora
 				  where	org.organization_id = ora.organization_id))
						org,
		ar_system_parameters_all 	asp,
		gl_sets_of_books		gsob,
		hr_organization_information 	hoi2
 	 where '|| l_fnd_prod_grp_filter || ' = asp.org_id
		    and	asp.set_of_books_id = gsob.set_of_books_id
 	    and	(hoi2.org_information_context || '') = ''Accounting Information''
 	    and	hoi2.organization_id = org.organization_id' ;

	execute immediate l_stmt;

        else
	   raise l_failure;
	end if;

-- </Bug 4913384>

	end if;

	if (p_currency_code = g_common_functional_currency) then
	  if (g_common_functional_currency = g_global_currency_code or g_common_functional_currency = g_sec_currency_code) then
	    return '0';
	  else
	    return '1';
	  end if;
	else
	  return '0';
	end if;
      end if; -- end if p_selected_org<>'ALL'
    end if;  -- end if p_currency_code = 'FII_GLOBAL1' or (p_currency_code = 'FII_GLOBAL2')
  end if;

  exception
    when too_many_rows then
     	g_common_functional_currency := 'N/A';
       	return '0';
    when l_failure then
	return '0';
    when others then
	return '0';

  end get_display_currency;

FUNCTION get_func_display_currency(p_org_type	IN varchar2,
				   p_currency_code	IN varchar2,
				   p_selected_org	IN varchar2) return varchar2 is

  l_f_currency_code	varchar2(15) := null;
  l_ou			number;
  l_sec			varchar2(1);
  l_failure		exception;

begin
  /*if (p_currency_code = 'FII_GLOBAL1' or p_currency_code = 'FII_GLOBAL2') then
	return '0';
  end if; */

  if not g_w_is_cached then
  	g_global_currency_code := bis_common_parameters.get_currency_code;
  	g_sec_currency_code := bis_common_parameters.get_secondary_currency_code;
  	g_global_rate_type := bis_common_parameters.get_rate_type;
  	g_w_is_cached := true;
  end if;

  if(upper(p_org_type) = 'W') then
    if(upper(p_selected_org) <> 'ALL') then
	l_ou := get_ou(p_selected_org);
	if (l_ou = -1) then
	  return '0';
	end if;
	select	gsob.currency_code
	  into	l_f_currency_code
	from	ar_system_parameters_all	asp,
		gl_sets_of_books		gsob
	where	asp.org_id = l_ou
	    and	asp.set_of_books_id = gsob.set_of_books_id;

        if (l_f_currency_code = g_global_currency_code and
            p_currency_code = 'FII_GLOBAL1') then
            return '1';
        else
            if (l_f_currency_code = g_sec_currency_code and
                p_currency_code = 'FII_GLOBAL2') then
                return '1';
            else
                if (p_currency_code = 'FII_GLOBAL1' or p_currency_code = 'FII_GLOBAL2') then
		   return '0';
	        else
                   if (l_f_currency_code = p_currency_code and
                       l_f_currency_code <> g_global_currency_code and
                       l_f_currency_code <> g_sec_currency_code) then
             	      return '1';
        	   else
        	      return '0';
        	   end if;
                end if;
            end if;
        end if;
    else
      return '0';
    end if;
  else
    return '0';
  end if;

end get_func_display_currency;

FUNCTION get_cpm_display_currency(	p_currency_code	IN varchar2) return varchar2 is

BEGIN

  if (p_currency_code = 'FII_GLOBAL1' or p_currency_code = 'FII_GLOBAL2') then
    return get_display_currency(p_org_type => 'W',
				p_currency_code => p_currency_code,
				p_selected_org => 'ALL');
  else
    return '0';
  end if;

end get_cpm_display_currency ;

END ISC_DBI_CURRENCY_PKG;

/
