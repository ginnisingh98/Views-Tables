--------------------------------------------------------
--  DDL for Package EAM_UTILITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_UTILITY_GRP" AUTHID CURRENT_USER AS
/* $Header: EAMGUTLS.pls 120.0 2005/06/22 14:09:42 amondal noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMGUTLS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_UTILITY_GRP
--
--  NOTES
--
--  HISTORY
--
--  16-MAY-2005   Anju Gupta      Initial Creation
***************************************************************************/

TYPE REPLACE_REBUILD_REC_type IS RECORD

(
  instance_id   NUMBER := NULL
);



TYPE REPLACE_REBUILD_tbl_type IS TABLE OF REPLACE_REBUILD_REC_type INDEX BY BINARY_INTEGER;


PROCEDURE Get_ReplacedRebuilds (
                  p_api_version      IN  NUMBER,
                  p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                  p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                  p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
	          p_wip_entity_id   	    IN         number,
                  p_organization_id         IN         number,

                  x_replaced_rebuild_tbl    OUT nocopy EAM_UTILITY_GRP.REPLACE_REBUILD_tbl_type,
                  x_return_status           OUT nocopy varchar2,
                  x_msg_count               OUT NOCOPY  NUMBER,
                  x_msg_data                OUT NOCOPY  VARCHAR2
	);

/* Function to get next maintenance date for an equipment for OSFM*/

FUNCTION get_next_maintenance_date( p_organization_id NUMBER,
				    p_resource_id NUMBER,
				    p_gen_object_id NUMBER)
                              	 return DATE;

END  EAM_UTILITY_GRP;

 

/
