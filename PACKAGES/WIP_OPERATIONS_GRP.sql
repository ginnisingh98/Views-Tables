--------------------------------------------------------
--  DDL for Package WIP_OPERATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OPERATIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: wipopgps.pls 115.1 2003/09/28 11:57:36 mraman noship $ */

procedure WIP_PERCENTAGE_COMPLETE
  (   p_api_version         IN	NUMBER,
      p_init_msg_list       IN	VARCHAR2 := FND_API.G_FALSE	,
      p_wip_entity_id       IN 	NUMBER,
      x_Percentage_complete OUT NOCOPY NUMBER,
      x_scheduled_hours     OUT NOCOPY NUMBER,
      x_return_status       OUT	NOCOPY VARCHAR2,
      x_msg_data            OUT	NOCOPY VARCHAR2,
      x_msg_count     	    OUT NOCOPY NUMBER
);

END WIP_OPERATIONS_GRP;

 

/
