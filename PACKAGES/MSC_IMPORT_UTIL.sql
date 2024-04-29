--------------------------------------------------------
--  DDL for Package MSC_IMPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_IMPORT_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCIMPUS.pls 120.1.12010000.2 2010/03/23 13:50:57 skakani noship $ */
-- Modification for bug 1863615
	            PROCEDURE load_frm_stg_tbl (
				errbuf                  OUT NOCOPY VARCHAR2,
                                retcode                 OUT NOCOPY NUMBER,
                                req_id 		in 	number,
				stg_tbl		in	varchar2 Default 'MSC_ST_ITEM_ATTRIBUTES'
				);
		    function sim_set(p_plan_id number) return varchar2;

		    procedure attach_simset_toplan(p_plan_id number, p_simset varchar2);

		    procedure modify_imm_item_attr(p_plan_id number, p_attr_name varchar2,p_attr_val varchar2,p_item_id number,p_org_id number,p_inst_id number);

		    procedure modify_plan_item_attr(p_plan_id number, p_attr_name varchar2,p_attr_val varchar2,p_item_id number,p_org_id number,p_sr_instance_id number);

		    procedure get_sql(p_attr_name varchar2,p_sql out nocopy varchar2,p_lov_type out nocopy number);

		    function get_real_attrname(p_attr_name varchar2) return varchar2;

END MSC_IMPORT_UTIL;

/
