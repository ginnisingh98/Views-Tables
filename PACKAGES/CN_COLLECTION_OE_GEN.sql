--------------------------------------------------------
--  DDL for Package CN_COLLECTION_OE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTION_OE_GEN" AUTHID CURRENT_USER AS
-- $Header: cnoegens.pls 120.1 2005/08/29 08:16:02 vensrini noship $



PROCEDURE insert_comm_lines_api (
     x_table_map_id      cn_table_maps.table_map_id%TYPE,
	x_package_id		cn_obj_packages_v.package_id%TYPE,
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_repository_id 	cn_repositories.repository_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code		IN OUT	NOCOPY cn_utils.code_type,
	x_org_id IN NUMBER);


END CN_COLLECTION_OE_GEN;
 

/
