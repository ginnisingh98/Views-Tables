--------------------------------------------------------
--  DDL for Package Body BIV_DBI_TMPL_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_TMPL_SEC" as
/* $Header: bivsrvrsecb.pls 115.1 2004/02/25 01:57:23 kreardon noship $ */

function get_type_sec_where_clause
return varchar2
is
begin

/**

  -- -----------
  -- 11.5.9 code
  -- -----------

  if nvl(fnd_profile.value('CS_SR_USE_TYPE_RESPON_SETUP'),'NO') = 'NO' then
    return null;
  end if;

  return '
and exists ( select 1
             from cs_sr_type_mapping m
             where m.incident_type_id = fact.incident_type_id
             and m.responsibility_id = fnd_global.resp_id
             and trunc(sysdate) between trunc(nvl(m.start_date, sysdate))
                                    and trunc(nvl(m.end_date,sysdate))
           )';

**/

  -- -------------
  -- 11.5.10+ code
  -- -------------

return '
and exists
   ( select 1
     from cs_incident_types_vl_sec m
     where incident_subtype = ''INC''
     and m.incident_type_id = fact.incident_type_id
   )';

end get_type_sec_where_clause;

end biv_dbi_tmpl_sec;

/
