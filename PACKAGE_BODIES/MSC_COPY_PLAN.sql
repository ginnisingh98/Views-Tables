--------------------------------------------------------
--  DDL for Package Body MSC_COPY_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_COPY_PLAN" AS
/* $Header: MSCCPPLB.pls 115.2 2004/08/09 12:16:57 alsriniv ship $  */
 function COPY_PLAN (
                     p_application IN varchar2 default null,
                     p_program     IN varchar2 default null,
                     p_description IN varchar2 default null,
                     p_start_time  IN varchar2 default null,
                     p_sub_request IN boolean  default false,
                     p_source_plan_id IN number default null,
                     p_dest_plan_name IN varchar2 default null,
                     p_dest_plan_desc IN varchar2 default null,
                     p_dest_org_selection IN number default null,
                     p_dest_atp IN number default null,
                     p_dest_production IN number default null,
                     p_dest_notifications IN number default null,
                     p_dest_inactive_on IN varchar2,
                     p_organization_id  IN number default null,
                     p_sr_instance_id IN number default null) return number IS
l_return_code number;
begin
  l_return_code := fnd_request.submit_request(p_application,
                                       p_program,
                                       p_description,
                                       p_start_time,
                                       p_sub_request,
                                       p_source_plan_id,
                                       p_dest_plan_name,
                                       p_dest_plan_desc,
                                       p_dest_org_selection,
                                       p_dest_atp,
                                       p_dest_production,
                                       p_dest_notifications,
                                       p_dest_inactive_on,
                                       p_organization_id,
                                       p_sr_instance_id);
   if l_return_code <> 0 then
        commit;
   end if;
   return  l_return_code;

end COPY_PLAN;
end msc_copy_plan;

/
