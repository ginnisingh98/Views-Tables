--------------------------------------------------------
--  DDL for Package PSB_DISTRIBUTE_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_DISTRIBUTE_WORKSHEET_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWSDPS.pls 120.2 2005/07/13 11:37:24 shtripat ship $ */


PROCEDURE Start_Process
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_item_key                  IN       NUMBER   ,
  p_distribution_instructions IN       VARCHAR2 ,
  p_recipient_name            IN       VARCHAR2
);


PROCEDURE Populate_Worksheet
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


END PSB_Distribute_Worksheet_PVT;

 

/
