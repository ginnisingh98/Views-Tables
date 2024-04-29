--------------------------------------------------------
--  DDL for Package WIP_OP_LINK_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OP_LINK_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: wipolvds.pls 120.0 2005/05/24 18:27:59 appldev noship $ */

/******************* DELETE OP_LINK ****************************/
Procedure Delete_Op_Link(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number,
                        x_err_code              out nocopy varchar2,
                        x_err_msg               out nocopy varchar2,
                        x_return_status         out nocopy varchar2);


/************************ ADD OP_LINK ******************/
Procedure Add_Op_Link(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number,
                        x_err_code              out nocopy varchar2,
                        x_err_msg               out nocopy varchar2,
                        x_return_status         out nocopy varchar2);
END WIP_OP_LINK_VALIDATIONS;

 

/
