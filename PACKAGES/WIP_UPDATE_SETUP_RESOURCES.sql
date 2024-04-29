--------------------------------------------------------
--  DDL for Package WIP_UPDATE_SETUP_RESOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_UPDATE_SETUP_RESOURCES" AUTHID CURRENT_USER AS
/* $Header: wpusetrs.pls 115.5 2002/11/29 15:03:36 simishra ship $  */


TYPE Number_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE UPDATE_SETUP_RESOURCES_PUB(p_wip_entity_id         IN NUMBER,
                                     p_organization_id       IN NUMBER,
                                     p_list_weid             IN Number_Tbl_Type,
                                     x_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2);


PROCEDURE UPDATE_SETUP_RESOURCES_PUB(p_wip_entity_id         IN  NUMBER,
				     p_organization_id       IN  NUMBER,
				     x_status                OUT NOCOPY VARCHAR2,
				     x_msg_count             OUT NOCOPY NUMBER,
				     x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_SETUP_RESOURCES_PUB(p_wip_entity_id         IN  NUMBER,
				     p_organization_id       IN  NUMBER);

-- ADD_SCHEDULED_JOBS:   adds the table of wip_entity_ids to a private global
--                       table.  This global table represents all the jobs
--                       that were scheduled in CBS scheduling run
PROCEDURE ADD_SCHEDULED_JOBS(p_list_weid IN  Number_Tbl_Type);

-- DELETE_SCHEDULED_JOBS_TBL:  deletes the records in the private global table
PROCEDURE DELETE_SCHEDULED_JOBS_TBL;



END WIP_UPDATE_SETUP_RESOURCES;

 

/
