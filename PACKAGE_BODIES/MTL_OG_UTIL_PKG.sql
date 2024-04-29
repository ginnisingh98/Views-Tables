--------------------------------------------------------
--  DDL for Package Body MTL_OG_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_OG_UTIL_PKG" AS
  /* $Header: INVOGUTB.pls 115.16 2004/08/13 02:01:16 ssia ship $ */
  --
  /*
   * Get the Object_ID and Object_Type of an object given its object_number
   * and Inventory_Item_Id
   */
  PROCEDURE get_objid(
    p_object_number     IN     VARCHAR2
  , p_inventory_item_id IN     NUMBER
  , p_organization_id   IN     NUMBER
  , x_object_id         OUT    NOCOPY NUMBER
  , x_object_type       OUT    NOCOPY NUMBER
  , x_return_status     OUT    NOCOPY VARCHAR2
  , x_msg_data          OUT    NOCOPY VARCHAR2
  , x_msg_count         OUT    NOCOPY NUMBER
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    /* Bug 2456261: Added Object_Type = 2 in the Query */
    SELECT object_id, object_type
      INTO x_object_id, x_object_type
      FROM mtl_object_numbers_v
     WHERE object_number = p_object_number
       AND inventory_item_id = p_inventory_item_id
       AND object_type = 2
       AND organization_id = NVL(p_organization_id, organization_id);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('INV','INV_NO_OBJECT_ID');
        fnd_message.set_token('OBJECT_NAME',p_object_number,FALSE);
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_data => x_msg_data, p_count => x_msg_count);
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_data => x_msg_data, p_count => x_msg_count);
  END get_objid;

  /*
   * Insert a new Genealogy record connecting a child and it's parent
   * Due to AK Navigator considerations, to show 'Child Genealogy', all objects
   * should have a record connecting them with a parent. Similary, to show
   * 'Parent-Genealogy' all objects should have a record connecting them
   * to a child.
   */
  PROCEDURE gen_insert(
    p_rowid             IN OUT NOCOPY VARCHAR2
  , p_item_id           IN     NUMBER
  , p_object_num        IN     VARCHAR2
  , p_parent_item_id    IN     NUMBER
  , p_parent_object_num IN     VARCHAR2
  , p_origin_txn_id     IN     NUMBER
  , p_org_id            IN     NUMBER := NULL
  ) IS
    l_trx_date           DATE;
    l_obj_id             NUMBER;
    l_obj_type           NUMBER;
    l_parent_obj_id      NUMBER;
    l_parent_obj_type    NUMBER;
    l_genealogy_origin   NUMBER;
    l_genealogy_type     NUMBER;
    l_user_id            NUMBER := fnd_global.user_id;
    l_return_status      VARCHAR2(30);
    l_msg_data           VARCHAR2(200);
    l_msg_count          NUMBER;

    CURSOR c IS
      SELECT ROWID
        FROM mtl_object_genealogy
       WHERE object_id = l_obj_id
         AND parent_object_id = l_parent_obj_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    /*
     * First get Obj. ID and Type of Object and its parent
     */
    get_objid(p_object_num, p_item_id, p_org_id, l_obj_id,l_obj_type,l_return_status,l_msg_data,l_msg_count);
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE NO_DATA_FOUND;
    END IF;
    get_objid(p_parent_object_num, p_parent_item_id, p_org_id, l_parent_obj_id,l_parent_obj_type,l_return_status,l_msg_data,l_msg_count);
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE NO_DATA_FOUND;
    END IF;
    l_genealogy_type    := 1;
    l_genealogy_origin  := 1;
    l_trx_date          := SYSDATE;

    INSERT INTO mtl_object_genealogy
                (
                object_id
              , object_type
              , parent_object_type
              , parent_object_id
              , last_update_date
              , last_updated_by
              , creation_date
              , created_by
              , start_date_active
              , genealogy_origin
              , origin_txn_id
              , genealogy_type
                )
         VALUES (
                l_obj_id
              , l_obj_type
              , l_parent_obj_type
              , l_parent_obj_id
              , SYSDATE
              , l_user_id
              , SYSDATE
              , l_user_id
              , l_trx_date
              , l_genealogy_origin
              , p_origin_txn_id
              , l_genealogy_type
                );

    OPEN c;
    FETCH c INTO p_rowid;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE c;
  END gen_insert;


  PROCEDURE gen_insert(
    x_return_status     OUT    NOCOPY VARCHAR2
  , x_msg_data          OUT    NOCOPY VARCHAR2
  , x_msg_count         OUT    NOCOPY NUMBER
  , p_item_id           IN     NUMBER
  , p_object_num        IN     VARCHAR2
  , p_parent_item_id    IN     NUMBER
  , p_parent_object_num IN     VARCHAR2
  , p_origin_txn_id     IN     NUMBER
  , p_org_id            IN     NUMBER
  ) IS
     l_trx_date           DATE;
     l_obj_id             NUMBER;
     l_obj_type           NUMBER;
     l_parent_obj_id      NUMBER;
     l_parent_obj_type    NUMBER;
     l_genealogy_origin   NUMBER;
     l_genealogy_type     NUMBER;
     l_user_id            NUMBER := fnd_global.user_id;
     l_rowid              VARCHAR2(30);
     l_parent_ser_ctrl    NUMBER;

     CURSOR c IS
       SELECT ROWID
         FROM mtl_object_genealogy
        WHERE object_id = l_obj_id
          AND parent_object_id = l_parent_obj_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* Checking whether Parent Item is Serial Controlled */
     BEGIN
        SELECT serial_number_control_code INTO l_parent_ser_ctrl
           FROM mtl_system_items
           WHERE inventory_item_id = p_parent_item_id
             AND organization_id = p_org_id;

        IF l_parent_ser_ctrl IN (1,6) THEN
           IF (l_debug = 1) THEN
              inv_log_util.trace('Parent not Serial Controlled','INV_OG_UTIL_PKG.GET_INSERT',3);
           END IF;
           RETURN;
        END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           fnd_message.set_name(application=> 'INV',NAME   => 'INV_INVALID_ITEM_ORG');
           fnd_msg_pub.ADD;
           RAISE FND_API.G_EXC_ERROR;
     END;

     /* Getting Object ID of the Child Object */
     get_objid(p_object_num, p_item_id, p_org_id, l_obj_id, l_obj_type, x_return_status, x_msg_data, x_msg_count);
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /* Getting Object ID of the Parent Object */
     get_objid(p_parent_object_num, p_parent_item_id, p_org_id, l_parent_obj_id, l_parent_obj_type, x_return_status, x_msg_data, x_msg_count);
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_genealogy_type    := 1;
     l_genealogy_origin  := 1;
     l_trx_date          := SYSDATE;

     INSERT INTO mtl_object_genealogy
                 (
                 object_id
               , object_type
               , parent_object_type
               , parent_object_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , start_date_active
               , genealogy_origin
               , origin_txn_id
               , genealogy_type
                 )
          VALUES (
                 l_obj_id
               , l_obj_type
               , l_parent_obj_type
               , l_parent_obj_id
               , SYSDATE
               , l_user_id
               , SYSDATE
               , l_user_id
               , l_trx_date
               , l_genealogy_origin
               , p_origin_txn_id
               , l_genealogy_type
                 );

     OPEN c;
     FETCH c INTO l_rowid;

     IF (c%NOTFOUND) THEN
       CLOSE c;
       fnd_message.set_name(application=> 'INV',NAME   => 'INV_INSERT_ERROR');
       fnd_message.set_token(token  => 'ENTITY1',VALUE  => 'Genealogy',TRANSLATE=> FALSE);
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     CLOSE c;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_data => x_msg_data, p_count => x_msg_count);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_data => x_msg_data, p_count => x_msg_count);
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_data => x_msg_data, p_count => x_msg_count);
  END gen_insert;

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
  ) IS
     l_object_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
    if( p_parent_sernum is not null ) then
        SELECT gen_object_id INTO l_object_id
        FROM mtl_serial_numbers
        WHERE serial_number = p_sernum
        AND parent_serial_number = p_parent_sernum
        AND current_organization_id = p_org_id
	AND inventory_item_id = p_item_id;	--Bug # 2682600
     else
        SELECT gen_object_id into l_object_id
        FROM mtl_serial_numbers
	WHERE serial_number = p_sernum
	AND current_organization_id = p_org_id
	AND inventory_item_id = p_item_id;	--Bug # 2682600
    end if;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF (l_debug = 1) THEN
          inv_trx_util_pub.trace(' no data found in gen_update','MTL_OG_UTIL_PKG');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          inv_trx_util_pub.trace(' exception in gen_update','MTL_OG_UTIL_PKG');
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
    BEGIN
     UPDATE mtl_object_genealogy
        SET end_date_active = SYSDATE
       ,LAST_UPDATE_DATE = SYSDATE
       ,LAST_UPDATED_BY = -1
       ,LAST_UPDATE_LOGIN = -1
        WHERE object_id = l_object_id
        AND END_date_active IS NULL
	AND genealogy_type <> 5 ;

     UPDATE mtl_serial_numbers
        SET parent_serial_number = NULL
       ,LAST_UPDATE_DATE = SYSDATE
       ,LAST_UPDATED_BY = -1
       ,LAST_UPDATE_LOGIN = -1
        WHERE gen_object_id = l_object_id;
    EXCEPTION
       WHEN no_data_found THEN
         IF (l_debug = 1) THEN
            inv_trx_util_pub.trace(' no data found while trying to update in gen_update','MTL_OG_UTIL_PKG');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
       WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          inv_trx_util_pub.trace(' exception in gen_update when trying to update','MTL_OG_UTIL_PKG');
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END gen_update;

  /** Insert a record corresponding to an event into the MTL_OBJECT_EVENTS table
   */
  PROCEDURE event_insert(
    p_rowid         IN OUT NOCOPY VARCHAR2
  , p_item_id       IN     NUMBER
  , p_object_number IN     VARCHAR2
  , p_trx_id        IN     NUMBER
  , p_trx_date      IN     DATE
  , p_trx_src_id    IN     NUMBER
  , p_trx_actin_id  IN     NUMBER
  , p_org_id        IN     NUMBER := NULL
  ) IS
    l_gen_event_type NUMBER;
    l_object_type    NUMBER;
    l_object_id      NUMBER := 0;
    l_user_id        NUMBER := fnd_global.user_id;
    l_return_status      VARCHAR2(30);
    l_msg_data           VARCHAR2(200);
    l_msg_count          NUMBER;
  /*   mrana : 10/02/01:
       Removed the cursot C, to select rowid of the row just inserted into mtl_object_event
       since it is un-necessary.
       Also , now populating p_rowid (IN OUT parameter) with '0' to avoid any problems with NULL
       calue in inltis.
       p_rowid is not used anywhere */
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    p_rowid      := '0';
    /*
     * Determine the type of transaction from the transaction source and action
     */
    get_objid(p_object_number, p_item_id, p_org_id, l_object_id, l_object_type, l_return_status, l_msg_data, l_msg_count);
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE NO_DATA_FOUND;
    END IF;

    /*
     * Determine the Genealogy Event Type
     * If src_id = 5 AND trx_actin_id = 1 this is a WIP issue. So event
     * type is 'Built'. If src_id = 13 and trx_actin_id = 27, then this
     * is a Misc. receipt transaction. So event is 'Issued'
     */
    IF  (p_trx_src_id = 5)
        AND (p_trx_actin_id = 1) THEN
      l_gen_event_type  := 1;
    ELSIF  (p_trx_src_id = 13)
           AND (p_trx_actin_id = 27) THEN
      l_gen_event_type  := 4;
    END IF;

    INSERT INTO mtl_object_events
                (
                object_id
              , genealogy_event_type
              , genealogy_event_date
              , transaction_id
              , creation_date
              , created_by
              , last_update_date
              , last_updated_by
                )
         VALUES (
                l_object_id
              , l_gen_event_type
              , p_trx_date
              , p_trx_id
              , SYSDATE
              , l_user_id
              , SYSDATE
              , l_user_id
                );
  END event_insert;
END;

/
