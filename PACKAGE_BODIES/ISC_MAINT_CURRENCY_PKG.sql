--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_CURRENCY_PKG" 
/* $Header: iscmaintccyb.pls 120.0 2005/05/25 17:18:16 appldev noship $ */
as

  g_primary_global_ccy_code   varchar2(15);
  g_secondary_global_ccy_code varchar2(15);
  g_org_ccy_code              varchar2(15);

  g_resp_id number;
  g_resp_appl_id number;
  g_org varchar2(100);

function get_org_currency
( p_selected_org   in varchar2
) return varchar2
is

  cursor c_one_org_currency(b_org_id number) is
    select distinct
      gsob.currency_code
    from
      hr_organization_information hoi
    , gl_sets_of_books gsob
    , mtl_parameters mp
    where hoi.org_information_context  = 'Accounting Information'
    and hoi.org_information1  = to_char(gsob.set_of_books_id)
    and hoi.organization_id = mp.organization_id
    and mp.organization_id = b_org_id
    and mp.eam_enabled_flag = 'Y';

  cursor c_all_orgs_currency is
    select distinct
      gsob.currency_code
    , count(distinct gsob.currency_code) over() currency_count
    from
      hr_organization_information hoi
    , gl_sets_of_books gsob
    , mtl_parameters mp
    where hoi.org_information_context  = 'Accounting Information'
    and hoi.org_information1  = to_char(gsob.set_of_books_id)
    and hoi.organization_id = mp.organization_id
    and
        ( exists
            ( select 1
              from org_access o
              where o.responsibility_id = fnd_global.resp_id
              and o.resp_application_id = fnd_global.resp_appl_id
              and o.organization_id = mp.organization_id ) or
            ( not exists ( select 1
                           from org_access ora
                           where mp.organization_id = ora.organization_id
                          )
            )
        )
    and mp.eam_enabled_flag = 'Y';

  l_currency varchar(15);
  l_currency_count number;
  l_org_id number;

begin

  if g_primary_global_ccy_code is null then

    g_primary_global_ccy_code := bis_common_parameters.get_currency_code;
    g_secondary_global_ccy_code := bis_common_parameters.get_secondary_currency_code;

  end if;

  if nvl(g_resp_id,-5) <> fnd_global.resp_id or
     nvl(g_resp_appl_id,-5) <> fnd_global.resp_appl_id or
     nvl(g_org,'NULL') <> p_selected_org then

    g_resp_id := fnd_global.resp_id;
    g_resp_appl_id := fnd_global.resp_appl_id;
    g_org := p_selected_org;
    g_org_ccy_code := 'FII_GLOBAL1';

    if p_selected_org = 'ALL' then

      open c_all_orgs_currency;
      fetch c_all_orgs_currency into l_currency, l_currency_count;
      close c_all_orgs_currency;

    else

      l_org_id := to_number(p_selected_org);

      open c_one_org_currency(l_org_id);
      fetch c_one_org_currency into l_currency;
      if c_one_org_currency%found then
        l_currency_count := 1;
      end if;
      close c_one_org_currency;

    end if;

      if l_currency_count = 1 and
         l_currency <> g_primary_global_ccy_code and
         l_currency <> nvl(g_secondary_global_ccy_code,g_primary_global_ccy_code) then

        g_org_ccy_code := l_currency;

      end if;

  end if;

  return g_org_ccy_code;

exception
  when others then
    return nvl(g_org_ccy_code,'FII_GLOBAL1');

end get_org_currency;

end isc_maint_currency_pkg;

/
