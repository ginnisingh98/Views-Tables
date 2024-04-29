--------------------------------------------------------
--  DDL for Package WSH_PICK_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PICK_RELEASE_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHPICKS.pls 115.2 2003/07/17 23:27:18 pojha noship $ */

    PROCEDURE Pick_Release (
           p_api_version               IN      NUMBER
          ,p_init_msg_list             IN      VARCHAR2
          ,p_commit                    IN      VARCHAR2
          ,x_return_status             OUT     NOCOPY VARCHAR2
          ,x_msg_count                 OUT     NOCOPY NUMBER
          ,x_msg_data                  OUT     NOCOPY VARCHAR2
          ,p_mo_line_tbl               IN      INV_Move_Order_PUB.TROLIN_TBL_TYPE
          ,p_auto_pick_confirm         IN      NUMBER
          ,p_grouping_rule_id          IN      NUMBER
          ,x_pick_release_status       OUT     NOCOPY INV_Pick_Release_PUB.INV_Release_Status_Tbl_Type
          ,p_plan_tasks IN BOOLEAN
   );

END WSH_PICK_RELEASE_GRP  ;

 

/
