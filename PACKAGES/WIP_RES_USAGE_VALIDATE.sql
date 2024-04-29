--------------------------------------------------------
--  DDL for Package WIP_RES_USAGE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RES_USAGE_VALIDATE" AUTHID CURRENT_USER as
/* $Header: wipruvds.pls 120.0 2005/05/24 18:49:09 appldev noship $ */


Procedure Validate_Usage ( p_group_id 		in number,
                           p_wip_entity_id 	in number,
                           p_organization_id 	in number,
                           x_err_code 		out NOCOPY varchar2,
                           x_err_msg 		out NOCOPY varchar2,
                           x_return_status 	out NOCOPY varchar2);


END WIP_RES_USAGE_VALIDATE;


 

/
