--------------------------------------------------------
--  DDL for Package WIP_OPERATION_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OPERATION_DEFAULT" AUTHID CURRENT_USER as
/* $Header: wipopdfs.pls 115.6 2002/11/29 09:33:21 rmahidha ship $ */

Procedure Default_Operations(p_group_id  in number,
                             p_parent_header_id in number,
                             p_wip_entity_id    in number,
                             p_organization_id  in number,
                             p_substitution_type in number,
                             x_err_code out nocopy varchar2,
                             x_err_msg out nocopy varchar2,
                             x_return_status out nocopy varchar2 );

PROCEDURE Default_Oper  (p_group_id in number,
                            p_parent_header_id in number := NULL,
                            p_wip_entity_id number,
                            p_organization_id number,
                            p_operation_seq_num number,
                            p_substitution_type number,
                            p_description varchar2 := NULL,
                            p_department_id number := NULL,
                            p_standard_operation_id number:=NULL,
                            p_fusd date := NULL,
                            p_fucd date := NULL,
                            p_lusd date := NULL,
                            p_lucd date := NULL,
                            p_min_xfer_qty number := NULL,
                            p_count_point number := NULL,
                            p_backflush_flag number := NULL,
                            x_err_code out nocopy varchar2,
                            x_err_msg out nocopy varchar2,
                            x_return_status out nocopy varchar2 );

END WIP_OPERATION_DEFAULT;

 

/
