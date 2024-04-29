--------------------------------------------------------
--  DDL for Package WIP_OPERATION_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OPERATION_VALIDATE" AUTHID CURRENT_USER as
/* $Header: wipopvds.pls 120.0 2005/05/25 07:28:10 appldev noship $ */

WIP_JOB_COMPLETED CONSTANT NUMBER := 4;

Procedure Add_Operation (p_group_id in number,
                         p_parent_header_id in number,
                         p_wip_entity_id in number,
                         p_organization_id in number,
                         x_err_code out nocopy varchar2,
                         x_err_msg  out nocopy varchar2,
                         x_return_status out nocopy varchar2 );

Procedure Change_Operation (p_group_id in number,
                            p_parent_header_id in number,
                            p_wip_entity_id in number,
                            p_organization_id in number,
                            x_err_code out nocopy varchar2,
                            x_err_msg  out nocopy varchar2,
                            x_return_status out nocopy varchar2 );

END WIP_OPERATION_VALIDATE;

 

/
