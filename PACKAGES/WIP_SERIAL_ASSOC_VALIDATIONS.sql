--------------------------------------------------------
--  DDL for Package WIP_SERIAL_ASSOC_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SERIAL_ASSOC_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: wipsrvds.pls 115.1 2002/11/26 23:38:31 kmreddy noship $ */

procedure change_serial(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number);

procedure add_serial(p_group_id               in number,
                     p_wip_entity_id         in number,
                     p_organization_id       in number,
                     p_substitution_type     in number);

procedure delete_serial(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number);

end wip_serial_assoc_validations;

 

/
