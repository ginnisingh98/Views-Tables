--------------------------------------------------------
--  DDL for Package MSD_CS_CLMN_DIM_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_CLMN_DIM_LOAD_DATA" AUTHID CURRENT_USER as
/* $Header: msdcscds.pls 115.5 2003/07/09 20:55:06 pinamati ship $ */
    --
    procedure load_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_table_column               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2);
    --
    Procedure Insert_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_table_column               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2);
    --
    Procedure Update_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_table_column               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2);
    --
End;

 

/
