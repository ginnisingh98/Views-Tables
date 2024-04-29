--------------------------------------------------------
--  DDL for Package MTL_OG_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_OG_UTIL_PKG" AUTHID CURRENT_USER AS
  /* $Header: INVOGUTS.pls 115.6 2002/12/01 02:27:58 rbande ship $ */

  PROCEDURE get_objid(
    p_object_number     IN     VARCHAR2
  , p_inventory_item_id IN     NUMBER
  , p_organization_id   IN     NUMBER := NULL
  , x_object_id         OUT    NOCOPY NUMBER
  , x_object_type       OUT    NOCOPY NUMBER
  , x_return_status     OUT    NOCOPY VARCHAR2
  , x_msg_data          OUT    NOCOPY VARCHAR2
  , x_msg_count         OUT    NOCOPY NUMBER
  );

  PROCEDURE gen_insert(
    p_rowid             IN OUT NOCOPY VARCHAR2
  , p_item_id           IN     NUMBER
  , p_object_num        IN     VARCHAR2
  , p_parent_item_id    IN     NUMBER
  , p_parent_object_num IN     VARCHAR2
  , p_origin_txn_id     IN     NUMBER
  , p_org_id            IN     NUMBER := NULL
  );

  PROCEDURE gen_insert(
    x_return_status     OUT    NOCOPY VARCHAR2
  , x_msg_data          OUT    NOCOPY VARCHAR2
  , x_msg_count         OUT    NOCOPY NUMBER
  , p_item_id           IN     NUMBER
  , p_object_num        IN     VARCHAR2
  , p_parent_item_id    IN     NUMBER
  , p_parent_object_num IN     VARCHAR2
  , p_origin_txn_id     IN     NUMBER
  , p_org_id            IN     NUMBER := NULL
  );

  PROCEDURE event_insert(
    p_rowid         IN OUT NOCOPY VARCHAR2
  , p_item_id       IN     NUMBER
  , p_object_number IN     VARCHAR2
  , p_trx_id        IN     NUMBER
  , p_trx_date      IN     DATE
  , p_trx_src_id    IN     NUMBER
  , p_trx_actin_id  IN     NUMBER
  , p_org_id        IN     NUMBER := NULL
  );

  /** added the procedure gen_update for the 'Serial Tracking in WIP Project.
      This updates the mtl_object_genealogy and mtl_serial_numbers tables
      when a serialized component is returned to stores from a WIP job.
      The genealogy between the parent and the child serials should be disabled
      whenever a component return transaction is performed. */

  PROCEDURE gen_update(
    x_return_status  OUT NOCOPY VARCHAR2
  , x_msg_data       OUT NOCOPY VARCHAR2
  , x_msg_count      OUT NOCOPY NUMBER
  , p_item_id        IN  NUMBER
  , p_sernum         IN  VARCHAR2
  , p_parent_sernum  IN  VARCHAR2
  , p_org_id         IN  NUMBER
  );

  END mtl_og_util_pkg;

 

/
