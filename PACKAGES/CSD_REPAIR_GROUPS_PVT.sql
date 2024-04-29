--------------------------------------------------------
--  DDL for Package CSD_REPAIR_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_GROUPS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvrpgs.pls 115.8 2002/11/15 22:43:40 swai noship $ */

----------------------------------------------------
-- Record name : REPAIR_ORDER_GROUP_REC
-- description : Group Repair Order Record
--
----------------------------------------------------
TYPE REPAIR_ORDER_GROUP_REC  IS RECORD
(
  repair_group_id            NUMBER,
  incident_id                NUMBER,
  repair_group_number        VARCHAR2(30),
  repair_type_id             NUMBER,
  wip_entity_id              NUMBER,
  inventory_item_id          NUMBER,
  unit_of_measure            VARCHAR2(3),
  group_quantity             NUMBER,
  repair_order_quantity      NUMBER,
  rma_quantity               NUMBER,
  received_quantity          NUMBER,
  approved_quantity          NUMBER,
  submitted_quantity         NUMBER,
  completed_quantity         NUMBER,
  released_quantity          NUMBER,
  shipped_quantity           NUMBER,
  created_by                 NUMBER,
  creation_date              DATE,
  last_updated_by            NUMBER,
  last_update_date           DATE,
  last_update_login          NUMBER,
  context                    VARCHAR2(240),
  attribute1                 VARCHAR2(100),
  attribute2                 VARCHAR2(100),
  attribute3                 VARCHAR2(100),
  attribute4                 VARCHAR2(100),
  attribute5                 VARCHAR2(100),
  attribute6                 VARCHAR2(100),
  attribute7                 VARCHAR2(100),
  attribute8                 VARCHAR2(100),
  attribute9                 VARCHAR2(100),
  attribute10                VARCHAR2(100),
  attribute11                VARCHAR2(100),
  attribute12                VARCHAR2(100),
  attribute13                VARCHAR2(100),
  attribute14                VARCHAR2(100),
  attribute15                VARCHAR2(100),
  security_group_id          NUMBER,
  object_version_number      NUMBER,
  group_txn_status           VARCHAR2(30),
  group_approval_status      VARCHAR2(30),
  repair_mode                VARCHAR2(30)
);

----------------------------------------------------
-- procedure name: create_repair_groups
-- description   : procedure used to create
--                 group repair orders
--
----------------------------------------------------

PROCEDURE CREATE_REPAIR_GROUPS
( p_api_version               IN     NUMBER,
  p_commit                    IN     VARCHAR2,
  p_init_msg_list             IN     VARCHAR2,
  p_validation_level          IN     NUMBER,
  x_repair_order_group_rec    IN OUT NOCOPY CSD_REPAIR_GROUPS_PVT.REPAIR_ORDER_GROUP_REC,
  x_repair_group_id           OUT NOCOPY    NUMBER,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2  );


----------------------------------------------------
-- procedure name: update_repair_groups
-- description   : procedure used to update
--                 group repair orders
--
----------------------------------------------------

PROCEDURE UPDATE_REPAIR_GROUPS
( p_api_version               IN     NUMBER,
  p_commit                    IN     VARCHAR2,
  p_init_msg_list             IN     VARCHAR2,
  p_validation_level          IN     NUMBER,
  x_repair_order_group_rec    IN OUT NOCOPY CSD_REPAIR_GROUPS_PVT.REPAIR_ORDER_GROUP_REC,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2  );

----------------------------------------------------
-- procedure name: delete_repair_groups
-- description   : procedure used to delete
--                 group repair orders
--
----------------------------------------------------

PROCEDURE DELETE_REPAIR_GROUPS
( p_api_version           IN   NUMBER,
  p_commit                IN   VARCHAR2,
  p_init_msg_list         IN   VARCHAR2,
  p_validation_level      IN   NUMBER,
  p_repair_group_id       IN   NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2  );

----------------------------------------------------
-- procedure name: lock_repair_groups
-- description   : procedure used to lock
--                 group repair orders
--
----------------------------------------------------

PROCEDURE LOCK_REPAIR_GROUPS
( p_api_version             IN   NUMBER,
  p_commit                  IN   VARCHAR2,
  p_init_msg_list           IN   VARCHAR2,
  p_validation_level        IN   NUMBER,
  p_repair_order_group_rec  IN   REPAIR_ORDER_GROUP_REC,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2  );


-----------------------------------------------------------
-- procedure name: apply_to_group
-- description   : procedure used to update promise_date
--                 approval_req_flag,resource for all the
--                 repair orders of the group.
-----------------------------------------------------------

PROCEDURE  APPLY_TO_GROUP
( p_api_version             IN     NUMBER,
  p_commit                  IN     VARCHAR2,
  p_init_msg_list           IN     VARCHAR2,
  p_validation_level        IN     NUMBER,
  p_repair_group_id         IN     NUMBER,
  p_promise_date            IN     DATE,
  p_resource_id             IN     NUMBER,
  p_approval_required_flag  IN     VARCHAR2,
  x_object_version_number   OUT NOCOPY    NUMBER,
  x_return_status           OUT NOCOPY    VARCHAR2,
  x_msg_count               OUT NOCOPY    NUMBER,
  x_msg_data                OUT NOCOPY    VARCHAR2  );


END CSD_REPAIR_GROUPS_PVT;


 

/
