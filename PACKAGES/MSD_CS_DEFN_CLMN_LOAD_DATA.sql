--------------------------------------------------------
--  DDL for Package MSD_CS_DEFN_CLMN_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_DEFN_CLMN_LOAD_DATA" AUTHID CURRENT_USER as
/* $Header: msdcsdcs.pls 115.10 2003/07/09 20:56:33 pinamati ship $ */

    Procedure load_row (
       p_definition_name            in varchar2,
       p_table_column               in varchar2,
       p_column_identifier          in varchar2,
       p_source_view_column_name    in varchar2,
       p_planning_view_column_name  in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_uom_conversion_flag        in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2);


    Procedure Insert_row (
       p_definition_name            in varchar2,
       p_table_column               in varchar2,
       p_column_identifier          in varchar2,
       p_source_view_column_name    in varchar2,
       p_planning_view_column_name  in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_uom_conversion_flag        in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2);


    Procedure Update_row (
       p_definition_name            in varchar2,
       p_table_column               in varchar2,
       p_column_identifier          in varchar2,
       p_source_view_column_name    in varchar2,
       p_planning_view_column_name  in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_uom_conversion_flag        in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2);

End;

 

/
