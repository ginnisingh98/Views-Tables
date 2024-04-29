--------------------------------------------------------
--  DDL for Package Body AMW_PUBLIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PUBLIC_PKG" AS
/* $Header: amwpbpkb.pls 115.0 2004/04/28 19:50:33 abedajna noship $ */

FUNCTION get_proc_org_opinion_status(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2 is

l_last_audit_status varchar2(240);

begin

select audit_result
into l_last_audit_status
from amw_opinions_v
where pk1_value = p_process_id and pk3_value = p_org_id
and object_opinion_type_id =
    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b where opinion_type_code = p_mode)
    and object_id = (select object_id from fnd_objects where obj_name = 'AMW_ORG_PROCESS') )
and last_update_date =
	(select max(last_update_date) from amw_opinions_v
	where pk1_value = p_process_id and pk3_value = p_org_id
	and object_opinion_type_id =
	    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
	    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b where opinion_type_code = p_mode)
	    and object_id = (select object_id from fnd_objects where obj_name = 'AMW_ORG_PROCESS') ) );

return   l_last_audit_status;

exception
    when no_data_found then
        return null;
    when others then
        return null;

end get_proc_org_opinion_status;



FUNCTION get_proc_org_opinion_date(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2 is

l_last_update_date date;

begin

select max(last_update_date) into l_last_update_date from amw_opinions_v
	where pk1_value = p_process_id and pk3_value = p_org_id
	and object_opinion_type_id =
	    (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES
	    where opinion_type_id = (select opinion_type_id from amw_opinion_types_b where opinion_type_code = p_mode)
	    and object_id = (select object_id from fnd_objects where obj_name = 'AMW_ORG_PROCESS') );

return   l_last_update_date;

exception
    when no_data_found then
        return null;
    when others then
        return null;

end get_proc_org_opinion_date;


END AMW_PUBLIC_PKG;

/
