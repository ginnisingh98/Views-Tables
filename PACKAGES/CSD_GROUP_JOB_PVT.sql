--------------------------------------------------------
--  DDL for Package CSD_GROUP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GROUP_JOB_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvjobs.pls 115.6 2002/11/08 20:30:29 sangigup noship $ */

/*--------------------------------------------------*/
/* Record name: JOB_PARAMETER_REC                   */
/* description : Record used for product txn        */
/*                                                  */
/*--------------------------------------------------*/

TYPE JOB_PARAMETER_REC  IS RECORD
( group_job_id               NUMBER          := FND_API.G_MISS_NUM,
  repair_group_id            NUMBER          := FND_API.G_MISS_NUM,
  incident_id                NUMBER          := FND_API.G_MISS_NUM,
  inventory_item_id          NUMBER          := FND_API.G_MISS_NUM,
  organization_id            NUMBER          := FND_API.G_MISS_NUM,
  job_type                   NUMBER          := FND_API.G_MISS_NUM,
  routing_reference_id       NUMBER          := FND_API.G_MISS_NUM,
  alternate_designator_code  VARCHAR2(10)    := FND_API.G_MISS_CHAR,
  job_status_type            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  accounting_class           VARCHAR2(10)    := FND_API.G_MISS_CHAR,
  start_date                 DATE            := FND_API.G_MISS_DATE,
  completion_date            DATE            := FND_API.G_MISS_DATE,
  quantity_received          NUMBER          := FND_API.G_MISS_NUM,
  quantity_submitted         NUMBER          := FND_API.G_MISS_NUM,
  item_revision              VARCHAR2(3)     := FND_API.G_MISS_CHAR,
  last_update_date           DATE            := FND_API.G_MISS_DATE,
  creation_date              DATE            := FND_API.G_MISS_DATE,
  last_updated_by            NUMBER          := FND_API.G_MISS_NUM,
  created_by                 NUMBER          := FND_API.G_MISS_NUM,
  last_update_login          NUMBER          := FND_API.G_MISS_NUM,
  object_version_number      NUMBER          := FND_API.G_MISS_NUM,
  process_id                 NUMBER          := FND_API.G_MISS_NUM);

/*-----------------------------------------------------------------*/
/* procedure name: create_job_parameters                           */
/* description   : procedure used to create                        */
/*                 RMA/sales orders for all groups                 */
/*-----------------------------------------------------------------*/

PROCEDURE  create_job_parameters
( p_api_version             IN  NUMBER,
  p_commit                  IN  VARCHAR2  := fnd_api.g_false,
  p_init_msg_list           IN  VARCHAR2  := fnd_api.g_false,
  p_validation_level        IN  NUMBER    := fnd_api.g_valid_level_full,
  p_job_parameter_rec       IN OUT NOCOPY JOB_PARAMETER_REC,
  x_group_job_id            OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------*/
/* procedure name: update_job_parameters                           */
/* description   : procedure used to create                        */
/*                 RMA/sales orders for all groups                 */
/*-----------------------------------------------------------------*/

PROCEDURE  update_job_parameters
( p_api_version             IN  NUMBER,
  p_commit                  IN  VARCHAR2  := fnd_api.g_false,
  p_init_msg_list           IN  VARCHAR2  := fnd_api.g_false,
  p_validation_level        IN  NUMBER    := fnd_api.g_valid_level_full,
  p_job_parameter_rec       IN OUT NOCOPY JOB_PARAMETER_REC,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------*/
/* procedure name: lock_job_parameters                             */
/* description   : procedure used to create                        */
/*                 RMA/sales orders for all groups                 */
/*-----------------------------------------------------------------*/

PROCEDURE  lock_job_parameters
( p_api_version             IN  NUMBER,
  p_commit                  IN  VARCHAR2  := fnd_api.g_false,
  p_init_msg_list           IN  VARCHAR2  := fnd_api.g_false,
  p_validation_level        IN  NUMBER    := fnd_api.g_valid_level_full,
  p_job_parameter_rec       IN  JOB_PARAMETER_REC,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);

------------------------------------------------
-- Procedure : UPDATE_RO_ORDERS
-- Purpose   : To update Repair Orders with the
--             status and qty in wip
--
------------------------------------------------
PROCEDURE UPDATE_RO_ORDERS(p_api_version        in number,
					  p_commit             in varchar2,
					  p_init_msg_list      in varchar2,
					  p_validation_level   in number,
					  p_repair_line_id     in  number,
					  x_return_status      OUT NOCOPY varchar2,
					  x_msg_count          OUT NOCOPY number,
					  x_msg_data           OUT NOCOPY varchar2);

---------------------------------------------------------
-- Procedure : UPDATE_RO_GROUP
-- Purpose   : To update group repair orders
--             with the status and qty submitted to wip
--
---------------------------------------------------------
PROCEDURE UPDATE_RO_GROUP(p_api_version         in number,
					 p_commit              in varchar2,
					 p_init_msg_list       in varchar2,
					 p_validation_level    in number,
					 p_repair_group_id     in  number,
                          p_quantity_submitted  in  number,
                          p_wip_entity_id       in  number,
					 x_return_status       OUT NOCOPY varchar2,
					 x_msg_count           OUT NOCOPY number,
					 x_msg_data            OUT NOCOPY varchar2);

----------------------------------------------
-- Procedure : CREATE_JOB_ALL_GROUPS
-- Purpose   : To create Jobs for all Groups
--
----------------------------------------------

PROCEDURE CREATE_JOB_ALL_GROUPS
( p_api_version      IN   NUMBER,
  p_commit           IN   VARCHAR2  := fnd_api.g_false,
  p_init_msg_list    IN   VARCHAR2  := fnd_api.g_false,
  p_validation_level IN   NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id      IN   NUMBER,
  x_return_status    OUT NOCOPY  VARCHAR2,
  x_msg_count        OUT NOCOPY  NUMBER,
  x_msg_data         OUT NOCOPY  VARCHAR2 );

----------------------------------------------
-- Procedure : CREATE_JOB_ONE_GROUPS
-- Purpose   : To create Jobs for one Groups
--
----------------------------------------------

PROCEDURE CREATE_JOB_ONE_GROUP
( p_api_version      IN    NUMBER,
  p_commit           IN    VARCHAR2  := fnd_api.g_false,
  p_init_msg_list    IN    VARCHAR2  := fnd_api.g_false,
  p_validation_level IN    NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id  IN    Number,
  x_return_status    OUT NOCOPY   VARCHAR2,
  x_msg_count        OUT NOCOPY   NUMBER,
  x_msg_data         OUT NOCOPY   VARCHAR2 );

END CSD_GROUP_JOB_PVT ;


 

/
