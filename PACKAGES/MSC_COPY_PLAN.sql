--------------------------------------------------------
--  DDL for Package MSC_COPY_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_COPY_PLAN" AUTHID CURRENT_USER AS
/* $Header: MSCCPPLS.pls 115.2 2002/12/30 09:41:12 skakani ship $  */

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
                     p_sr_instance_id IN number default null) return number;
END msc_copy_plan;

 

/
