--------------------------------------------------------
--  DDL for Package QA_SS_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_OM" AUTHID CURRENT_USER as
/* $Header: qltssomb.pls 115.4 2002/11/27 19:33:34 jezheng ship $ */

type plan_info_rec is record (
		plan_id qa_plans.plan_id%type,
		name qa_plans.name%type,
		description qa_plans.description%type,
		meaning fnd_common_lookups.meaning%type);

type plan_tab_type is table of plan_info_rec index by binary_integer;


function are_om_header_plans_applicable (
		P_So_Header_Id IN Number DEFAULT NULL
	)

	Return VARCHAR2;

function are_om_lines_plans_applicable (
		P_So_Header_Id IN Number DEFAULT NULL,
		P_Item_Id IN Number Default Null
	)

	Return VARCHAR2;


procedure om_header_to_quality (
			PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
			c_outputs1 OUT NOCOPY VARCHAR2,
			c_outputs2 OUT NOCOPY VARCHAR2,
			c_outputs3 OUT NOCOPY VARCHAR2,
			c_outputs4 OUT NOCOPY VARCHAR2,
			c_outputs5 OUT NOCOPY VARCHAR2,
			c_outputs6 OUT NOCOPY VARCHAR2,
			c_outputs7 OUT NOCOPY VARCHAR2,
			c_outputs8 OUT NOCOPY VARCHAR2,
			c_outputs9 OUT NOCOPY VARCHAR2,
			c_outputs10 OUT NOCOPY VARCHAR2);

procedure om_lines_to_quality (
			PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
			c_outputs1 OUT NOCOPY VARCHAR2,
			c_outputs2 OUT NOCOPY VARCHAR2,
			c_outputs3 OUT NOCOPY VARCHAR2,
			c_outputs4 OUT NOCOPY VARCHAR2,
			c_outputs5 OUT NOCOPY VARCHAR2,
			c_outputs6 OUT NOCOPY VARCHAR2,
			c_outputs7 OUT NOCOPY VARCHAR2,
			c_outputs8 OUT NOCOPY VARCHAR2,
			c_outputs9 OUT NOCOPY VARCHAR2,
			c_outputs10 OUT NOCOPY VARCHAR2);


procedure List_OM_Plans (plan_tab IN plan_tab_type,
			 P_so_header_id IN NUMBER Default Null,
			 P_item_id IN NUMBER DEFAULT Null);

function is_om_header_plan_applicable (
		x_Pid IN NUMBER,
		x_so_header_id IN VARCHAR2 default null)
Return VARCHAR2;

function is_om_lines_plan_applicable (
		x_Pid IN NUMBER,
		x_so_header_id IN VARCHAR2 default null,
		x_Item_Id in VARCHAR2 default null )
Return VARCHAR2;

end qa_ss_om;


 

/
