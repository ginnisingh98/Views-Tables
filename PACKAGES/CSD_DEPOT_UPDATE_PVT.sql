--------------------------------------------------------
--  DDL for Package CSD_DEPOT_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_DEPOT_UPDATE_PVT" AUTHID CURRENT_USER as
/* $Header: csddrups.pls 115.3 2002/11/08 20:20:00 swai noship $ */

procedure convert_to_primary_uom
          (p_item_id         in number,
           p_organization_id in number,
           p_from_uom        in varchar2,
           p_from_quantity   in number,
           p_result_quantity OUT NOCOPY number);

/*--------------------------------------------------*/
/* procedure name: group_wip_update                 */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

PROCEDURE group_wip_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2);


/*--------------------------------------------------*/
/* procedure name: Pre_process_update               */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure Pre_process_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     number,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: Post_process_update              */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure Post_process_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     number,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2);


/*--------------------------------------------------*/
/* procedure name: Group_Rma_Update                 */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure Group_Rma_Update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id       IN     NUMBER,
  x_update_count          OUT NOCOPY    NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: Group_ship_update                */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure Group_ship_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id       IN     number,
  x_update_count          OUT NOCOPY    NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2);

End CSD_DEPOT_UPDATE_PVT;

 

/
