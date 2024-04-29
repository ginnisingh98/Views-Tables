--------------------------------------------------------
--  DDL for Package Body WSH_PICK_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PICK_RELEASE_GRP" AS
/* $Header: WSHPICKB.pls 120.0 2005/05/26 18:01:58 appldev noship $ */

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
   ) IS
   Begin

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      INV_Pick_Release_Pub.Pick_Release (
                 p_api_version  => p_api_version,
                 p_init_msg_list  => p_init_msg_list,
                 p_commit   => p_commit,
                 p_mo_line_tbl  => p_mo_line_tbl ,
                 p_auto_pick_confirm   => p_auto_pick_confirm,
                 p_plan_tasks   => p_plan_tasks,
                 p_grouping_rule_id   => p_grouping_rule_id,
                 x_pick_release_status => x_pick_release_status,
                 x_return_status  => x_return_status,
                 x_msg_count => x_msg_count ,
                 x_msg_data   => x_msg_data
       );

    END  Pick_Release ;

END WSH_PICK_RELEASE_GRP  ;

/
