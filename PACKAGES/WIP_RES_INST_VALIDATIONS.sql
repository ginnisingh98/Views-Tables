--------------------------------------------------------
--  DDL for Package WIP_RES_INST_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RES_INST_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: wiprivds.pls 120.0 2005/05/25 07:43:53 appldev noship $ */

/********************** ERROR HANDLING *********************************/
/* Is there errors for the previous validations? It doesn't pass more resource
   parameters, because it is unique up to resource_seq_num */
function IS_Error(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number) return number;

/* Check errors occurred when there could be NULL data */
/*
function Info_Missing(p_group_id                number,
                   p_wip_entity_id              number,
                   p_organization_id            number,
                   p_substitution_type          number,
                   p_operation_seq_num          number) return number;
*/

Procedure Add_Resource_Instance(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2);

Procedure Change_Resource_Instance(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2);

Procedure Delete_Resource_Instance(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2);
END WIP_RES_INST_VALIDATIONS;

 

/
