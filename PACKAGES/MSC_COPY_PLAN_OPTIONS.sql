--------------------------------------------------------
--  DDL for Package MSC_COPY_PLAN_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_COPY_PLAN_OPTIONS" AUTHID CURRENT_USER AS
/* $Header: MSCCPPOS.pls 120.1.12000000.1 2007/01/16 22:29:34 appldev ship $  */

Type Copy_Plan_Bind_Variables is Record
(
  P_DESIGNATOR_ID  number ,
  P_DEST_PLAN_ID number ,
  P_DEST_PLAN_NAME varchar2(255) ,
  P_DEST_PLAN_TYPE number ,
  P_DEST_PLAN_DESC varchar2(255) ,
  P_SOURCE_PLAN_ID number ,
  P_DESIGNATOR_TYPE number ,
  P_ORGANIZATION_ID number ,
  P_MPS_RELIEF number ,
  P_INVENTORY_ATP_FLAG number ,
  P_PRODUCTION number ,
  P_LAUNCH_WORKFLOW_FLAG number ,
  P_DESCRIPTION varchar2(255) ,
  P_DISABLE_DATE date ,
  P_COLLECTED_FLAG number ,
  P_SR_INSTANCE_ID number ,
  P_REFRESH_NUMBER number ,
  P_ORGANIZATION_SELECTION number ,
  P_COPY_PLAN number ,
  P_LAST_UPDATE_DATE date ,
  P_LAST_UPDATED_BY number ,
  P_CREATION_DATE date ,
  P_CREATED_BY number ,
  P_LAST_UPDATE_LOGIN number
 );

 TYPE Copy_Plan_Options_Type IS TABLE OF Copy_Plan_Bind_Variables
  INDEX BY BINARY_INTEGER;

  Type Copy_Plan_Source_Tables is Record
(
  P_TABLE_NAME  varchar2(30)
 );

 TYPE Copy_Plan_Source_Tables_Type IS TABLE OF Copy_Plan_Source_Tables
 INDEX BY BINARY_INTEGER;


PROCEDURE copy_plan_options (
                     p_source_plan_id     IN number,
                     p_dest_plan_name     IN varchar2,
                     p_dest_plan_desc     IN varchar2,
                     p_dest_plan_type     IN number,
                     p_dest_atp           IN number,
                     p_dest_production    IN number,
                     p_dest_notifications IN number,
                     p_dest_inactive_on   IN date,
                     p_organization_id    IN number,
                     p_sr_instance_id     IN number);
PROCEDURE copy_firm_orders(
			   ERRBUF 		out NOCOPY varchar2,
			   RETCODE 		out NOCOPY number,
			   P_source_plan_id 	IN  	   number,
			   P_dest_plan_id   	IN  	   number);
PROCEDURE delete_temp_plan (    ERRBUF 		out NOCOPY varchar2,
				RETCODE 	out NOCOPY number,
				P_DESIG_ID      IN  	   number,
				p_childreq	IN 	   boolean default false);
PROCEDURE delete_plan_options(  ERRBUF 		out NOCOPY varchar2,
				RETCODE 	out NOCOPY number,
				P_plan_id 	IN  	   number);
PROCEDURE link_plans(
			ERRBUF		out NOCOPY varchar2,
			RETCODE		out NOCOPY number,
			P_Src_plan_id   in  	   number,
			P_Src_Desg_id   in  	   number,
			P_plan_id 	out NOCOPY number,
			P_designator_id out NOCOPY number);

PROCEDURE init_plan_id(P_temp_plan in varchar2, P_Plan_id in number, P_designator_id in number) ;

PROCEDURE inti_pl_sql_table(p_source_table in out NOCOPY Copy_Plan_Source_Tables_Type );

FUNCTION get_column_name(p_bind_var_col in Copy_Plan_Options_Type
			 , p_source_table in varchar2
                         , p_column_name varchar2)
return varchar2 ;

PROCEDURE generate_sql_script(p_bind_var_col in Copy_Plan_Options_Type
			    , p_table_name varchar2 );

FUNCTION Convert_to_String(p_value varchar2)
return varchar2;

FUNCTION Get_Column_Value(p_bind_var_col1 in Copy_Plan_Options_Type ,
					p_column_name varchar2,
					p_data_type varchar2 ,
					p_table_name varchar2 )
return varchar2;
end;

 

/
