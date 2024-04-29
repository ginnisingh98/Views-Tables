--------------------------------------------------------
--  DDL for Package Body WMS_CONTAINER2_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONTAINER2_PUB" AS
/* $Header: WMSCNT2B.pls 115.17 2003/02/05 02:15:59 rbande ship $ */

--  Global constant holding the package name
G_PKG_NAME	   CONSTANT VARCHAR2(30) := 'WMS_Container2_PUB';


PROCEDURE mdebug(msg in varchar2)
   IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
   l_msg:=l_ts||'  '||msg;


   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'WMS_Container2_PUB',
      p_level => 4);
   --dbms_output.put_line(msg);
   --INSERT INTO amintemp1 VALUES (msg);
   null;

END;


-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE Purge_LPN
(  p_api_version	    IN	    NUMBER                         ,
   p_init_msg_list	    IN	    VARCHAR2 := fnd_api.g_false    ,
   p_commit		    IN	    VARCHAR2 := fnd_api.g_false    ,
   x_return_status	    OUT	    VARCHAR2                       ,
   x_msg_count		    OUT	    NUMBER                         ,
   x_msg_data		    OUT	    VARCHAR2                       ,
   p_lpn_id		    IN	    NUMBER                         ,
   p_purge_history          IN      NUMBER   := 2                  ,
   p_del_history_days_old   IN      NUMBER   := NULL
)
IS
l_api_name	             CONSTANT VARCHAR2(30)    := 'Purge_LPN';
l_api_version	             CONSTANT NUMBER	      := 1.0;
l_lpn                        WMS_CONTAINER_PUB.LPN;
l_result                     NUMBER;
l_lpn_exist                  VARCHAR2(20);
l_lpn_contents_exist         VARCHAR2(20);
l_lpn_serial_contents_exist  VARCHAR2(20);
CURSOR c_lpn IS
   SELECT 'Check for empty LPN'
     FROM DUAL
     WHERE EXISTS
     (SELECT 'Child LPN'
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE parent_lpn_id = p_lpn_id);
CURSOR c_lpn_contents IS
   SELECT 'Check for empty LPN'
     FROM DUAL
     WHERE EXISTS
     (SELECT 'Non serialized items'
      FROM WMS_LPN_CONTENTS
      WHERE parent_lpn_id = p_lpn_id);
CURSOR c_lpn_serial_contents IS
   SELECT 'Check for empty LPN'
     FROM DUAL
     WHERE EXISTS
     (SELECT 'Serialized items'
      FROM MTL_SERIAL_NUMBERS
      WHERE lpn_id = p_lpn_id);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Purge_LPN_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   /* Validate LPN */
   l_lpn.lpn_id := p_lpn_id;
   l_lpn.license_plate_number := NULL;
   l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* End of input validation */

   /* Check WMS_LICENSE_PLATE_NUMBERS table for any item stored within the LPN */
   OPEN c_lpn;
   FETCH c_lpn INTO l_lpn_exist;
   IF c_lpn%FOUND THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NON_EMPTY_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_lpn;

   /* Check WMS_LPN_CONTENTS table for any item(s) stored within the LPN */
   OPEN c_lpn_contents;
   FETCH c_lpn_contents INTO l_lpn_contents_exist;
   IF c_lpn_contents%FOUND THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NON_EMPTY_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_lpn_contents;

   /* Check MTL_SERIAL_NUMBERS table for any serialized item(s) stored within the LPN */
   OPEN c_lpn_serial_contents;
   FETCH c_lpn_serial_contents INTO l_lpn_serial_contents_exist;
   IF c_lpn_serial_contents%FOUND THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NON_EMPTY_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_lpn_serial_contents;

   /* Nothing found within the LPN so okay to purge it now */
   DELETE FROM WMS_LICENSE_PLATE_NUMBERS
     WHERE lpn_id = p_lpn_id;

   /* Check if the LPN history of this should be deleted or not */
   IF (p_purge_history = 1) THEN
      -- If this value is other than 1, we will just assume that no
      -- LPN history records shall be purged
      DELETE FROM WMS_LPN_HISTORIES
	WHERE lpn_id = p_lpn_id
	OR parent_lpn_id = p_lpn_id;
   END IF;

   -- If the entire history is not to be purged, check if some of
   -- the past history records should be deleted or not
   IF ((p_purge_history <> 1) AND
       (p_del_history_days_old IS NOT NULL)) THEN
      DELETE FROM wms_lpn_histories
	WHERE (lpn_id = p_lpn_id
	       OR parent_lpn_id = p_lpn_id)
	AND (SYSDATE - creation_date >= p_del_history_days_old);
   END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Purge_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Purge_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      ROLLBACK TO Purge_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Purge_LPN;


-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE Explode_LPN
(  p_api_version   	IN	NUMBER                         ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false    ,
   p_commit		IN	VARCHAR2 := fnd_api.g_false    ,
   x_return_status	OUT	VARCHAR2                       ,
   x_msg_count		OUT	NUMBER                         ,
   x_msg_data		OUT	VARCHAR2                       ,
   p_lpn_id        	IN	NUMBER                         ,
   p_explosion_level	IN	NUMBER   := 0                  ,
   x_content_tbl	OUT	WMS_CONTAINER_PUB.WMS_Container_Tbl_Type
)
IS
l_api_name	     CONSTANT VARCHAR2(30)    := 'Explode_LPN';
l_api_version	     CONSTANT NUMBER	      := 1.0;
l_lpn                WMS_CONTAINER_PUB.LPN;
l_result             NUMBER;
l_counter            NUMBER := 1;  -- Counter variable initialized to 1
l_current_lpn        NUMBER;
CURSOR nested_lpn_cursor IS
-- Bug# 1546081
--   SELECT *
   SELECT lpn_id, parent_lpn_id, inventory_item_id, organization_id,
        revision, lot_number, serial_number, cost_group_id
     FROM WMS_LICENSE_PLATE_NUMBERS
     WHERE Level <= p_explosion_level
     START WITH lpn_id = p_lpn_id
     CONNECT BY parent_lpn_id = PRIOR lpn_id;
CURSOR all_nested_lpn_cursor IS
-- Bug# 1546081
--   SELECT *
   SELECT lpn_id, parent_lpn_id, inventory_item_id, organization_id,
		revision, lot_number, serial_number, cost_group_id
     FROM WMS_LICENSE_PLATE_NUMBERS
     START WITH lpn_id = p_lpn_id
     CONNECT BY parent_lpn_id = PRIOR lpn_id;
CURSOR lpn_contents_cursor IS
-- Bug# 1546081
--   SELECT *
   SELECT parent_lpn_id, inventory_item_id, item_description,
		organization_id, revision, lot_number,
		serial_number, quantity, uom_code, cost_group_id
     FROM WMS_LPN_CONTENTS
     WHERE parent_lpn_id = l_current_lpn
     AND NVL(serial_summary_entry, 2) = 2;
CURSOR lpn_serial_contents_cursor IS
-- Bug# 1546081
--   SELECT *
   SELECT inventory_item_id, current_organization_id, lpn_id,
		revision, lot_number, serial_number, cost_group_id
     FROM MTL_SERIAL_NUMBERS
     WHERE lpn_id = l_current_lpn;
l_container_content_rec WMS_CONTAINER_PUB.WMS_Container_Content_Rec_Type;
l_temp_uom_code      VARCHAR2(3);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Explode_LPN_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   /* Validate LPN */
   l_lpn.lpn_id := p_lpn_id;
   l_lpn.license_plate_number := NULL;
   l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Explosion Level */
   IF (p_explosion_level < 0) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_EXP_LVL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   /* End of input validation */

   IF (p_explosion_level = 0) THEN
      /* Use the cursor that searches through all levels in the parent child relationship */
      FOR v_lpn_id IN all_nested_lpn_cursor LOOP
	 l_current_lpn := v_lpn_id.lpn_id;

	 /* Store the lpn information also from license plate numbers table */
	 l_container_content_rec.parent_lpn_id        :=  v_lpn_id.parent_lpn_id;
	 l_container_content_rec.content_lpn_id       :=  v_lpn_id.lpn_id;
	 l_container_content_rec.content_item_id      :=  v_lpn_id.inventory_item_id;
	 l_container_content_rec.content_description  :=  NULL;
	 l_container_content_rec.content_type         :=  '2';
	 l_container_content_rec.organization_id      :=  v_lpn_id.organization_id;
	 l_container_content_rec.revision             :=  v_lpn_id.revision;
	 l_container_content_rec.lot_number           :=  v_lpn_id.lot_number;
	 l_container_content_rec.serial_number        :=  v_lpn_id.serial_number;
	 l_container_content_rec.quantity             :=  1;
	 l_container_content_rec.uom                  :=  NULL;
	 l_container_content_rec.cost_group_id        :=  v_lpn_id.cost_group_id;

	 x_content_tbl(l_counter) := l_container_content_rec;
	 l_counter := l_counter + 1;

	 /* Store all the item information from the lpn contents table */
	 FOR v_lpn_content IN lpn_contents_cursor LOOP
	    l_container_content_rec.parent_lpn_id        :=  v_lpn_content.parent_lpn_id;
	    l_container_content_rec.content_lpn_id       :=  NULL;
	    l_container_content_rec.content_item_id      :=  v_lpn_content.inventory_item_id;
	    l_container_content_rec.content_description  :=  v_lpn_content.item_description;
	    IF (v_lpn_content.inventory_item_id IS NOT NULL) THEN
	       l_container_content_rec.content_type      :=  '1';
	     ELSE
	       l_container_content_rec.content_type      :=  '3';
	    END IF;
	    l_container_content_rec.organization_id      :=  v_lpn_content.organization_id;
	    l_container_content_rec.revision             :=  v_lpn_content.revision;
	    l_container_content_rec.lot_number           :=  v_lpn_content.lot_number;
	    l_container_content_rec.serial_number        :=  v_lpn_content.serial_number;
	    l_container_content_rec.quantity             :=  v_lpn_content.quantity;
	    l_container_content_rec.uom                  :=  v_lpn_content.uom_code;
	    l_container_content_rec.cost_group_id        :=  v_lpn_content.cost_group_id;

	    x_content_tbl(l_counter) := l_container_content_rec;
	    l_counter := l_counter + 1;
	 END LOOP;

	 -- Store all the serialized item information from the serial
	 -- numbers table
	 FOR v_lpn_serial_content IN lpn_serial_contents_cursor LOOP
	    /* Get the primary UOM for the serialized item */
	    SELECT primary_uom_code
	      INTO l_temp_uom_code
	      FROM mtl_system_items
	      WHERE inventory_item_id = v_lpn_serial_content.inventory_item_id
	      AND organization_id = v_lpn_serial_content.current_organization_id;

	    l_container_content_rec.parent_lpn_id        :=  v_lpn_serial_content.lpn_id;
	    l_container_content_rec.content_lpn_id       :=  NULL;
	    l_container_content_rec.content_item_id      :=  v_lpn_serial_content.inventory_item_id;
	    l_container_content_rec.content_description  :=  NULL;
	    l_container_content_rec.content_type         :=  '1';
	    l_container_content_rec.organization_id      :=  v_lpn_serial_content.current_organization_id;
	    l_container_content_rec.revision             :=  v_lpn_serial_content.revision;
	    l_container_content_rec.lot_number           :=  v_lpn_serial_content.lot_number;
	    l_container_content_rec.serial_number        :=  v_lpn_serial_content.serial_number;
	    l_container_content_rec.quantity             :=  1;
	    l_container_content_rec.uom                  :=  l_temp_uom_code;
	    l_container_content_rec.cost_group_id        :=  v_lpn_serial_content.cost_group_id;

	    x_content_tbl(l_counter) := l_container_content_rec;
	    l_counter := l_counter + 1;
	 END LOOP;

      END LOOP;
    ELSE
      /* Use the cursor that searches only a specified number of levels */
      FOR v_lpn_id IN nested_lpn_cursor LOOP
	 l_current_lpn := v_lpn_id.lpn_id;

	 /* Store the lpn information also from license plate numbers table */
	 l_container_content_rec.parent_lpn_id        :=  v_lpn_id.parent_lpn_id;
	 l_container_content_rec.content_lpn_id       :=  v_lpn_id.lpn_id;
	 l_container_content_rec.content_item_id      :=  v_lpn_id.inventory_item_id;
	 l_container_content_rec.content_description  :=  NULL;
	 l_container_content_rec.content_type         :=  '2';
	 l_container_content_rec.organization_id      :=  v_lpn_id.organization_id;
	 l_container_content_rec.revision             :=  v_lpn_id.revision;
	 l_container_content_rec.lot_number           :=  v_lpn_id.lot_number;
	 l_container_content_rec.serial_number        :=  v_lpn_id.serial_number;
	 l_container_content_rec.quantity             :=  1;
	 l_container_content_rec.uom                  :=  NULL;
	 l_container_content_rec.cost_group_id        :=  v_lpn_id.cost_group_id;

	 x_content_tbl(l_counter) := l_container_content_rec;
	 l_counter := l_counter + 1;

	 /* Store all the item information from the lpn contents table */
	 FOR v_lpn_content IN lpn_contents_cursor LOOP
	    l_container_content_rec.parent_lpn_id        :=  v_lpn_content.parent_lpn_id;
	    l_container_content_rec.content_lpn_id       :=  NULL;
	    l_container_content_rec.content_item_id      :=  v_lpn_content.inventory_item_id;
	    l_container_content_rec.content_description  :=  v_lpn_content.item_description;
	    IF (v_lpn_content.inventory_item_id IS NOT NULL) THEN
	       l_container_content_rec.content_type      :=  '1';
	     ELSE
	       l_container_content_rec.content_type      :=  '3';
	    END IF;
	    l_container_content_rec.organization_id      :=  v_lpn_content.organization_id;
	    l_container_content_rec.revision             :=  v_lpn_content.revision;
	    l_container_content_rec.lot_number           :=  v_lpn_content.lot_number;
	    l_container_content_rec.serial_number        :=  v_lpn_content.serial_number;
	    l_container_content_rec.quantity             :=  v_lpn_content.quantity;
	    l_container_content_rec.uom                  :=  v_lpn_content.uom_code;
	    l_container_content_rec.cost_group_id        :=  v_lpn_content.cost_group_id;

	    x_content_tbl(l_counter) := l_container_content_rec;
	    l_counter := l_counter + 1;
	 END LOOP;

	 -- Store all the serialized item information from the serial
	 -- numbers table
	 FOR v_lpn_serial_content IN lpn_serial_contents_cursor LOOP
	    /* Get the primary UOM for the serialized item */
	    SELECT primary_uom_code
	      INTO l_temp_uom_code
	      FROM mtl_system_items
	      WHERE inventory_item_id = v_lpn_serial_content.inventory_item_id
	      AND organization_id = v_lpn_serial_content.current_organization_id;

	    l_container_content_rec.parent_lpn_id        :=  v_lpn_serial_content.lpn_id;
	    l_container_content_rec.content_lpn_id       :=  NULL;
	    l_container_content_rec.content_item_id      :=  v_lpn_serial_content.inventory_item_id;
	    l_container_content_rec.content_description  :=  NULL;
	    l_container_content_rec.content_type         :=  '1';
	    l_container_content_rec.organization_id      :=  v_lpn_serial_content.current_organization_id;
	    l_container_content_rec.revision             :=  v_lpn_serial_content.revision;
	    l_container_content_rec.lot_number           :=  v_lpn_serial_content.lot_number;
	    l_container_content_rec.serial_number        :=  v_lpn_serial_content.serial_number;
	    l_container_content_rec.quantity             :=  1;
	    l_container_content_rec.uom                  :=  l_temp_uom_code;
	    l_container_content_rec.cost_group_id        :=  v_lpn_serial_content.cost_group_id;

	    x_content_tbl(l_counter) := l_container_content_rec;
	    l_counter := l_counter + 1;
	 END LOOP;

      END LOOP;
   END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Explode_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Explode_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      ROLLBACK TO Explode_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Explode_LPN;


-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE Transfer_LPN_Contents
(  p_api_version   	IN	NUMBER                         ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false    ,
   p_commit		IN	VARCHAR2 := fnd_api.g_false    ,
   x_return_status	OUT	VARCHAR2                       ,
   x_msg_count		OUT	NUMBER                         ,
   x_msg_data		OUT	VARCHAR2                       ,
   p_lpn_id_source      IN	NUMBER                         ,
   p_lpn_id_dest        IN      NUMBER
)
IS
l_api_name	         CONSTANT VARCHAR2(30)     := 'Transfer_LPN_Contents';
l_api_version	         CONSTANT NUMBER	   := 1.0;
l_lpn_source             WMS_CONTAINER_PUB.LPN;
l_lpn_dest               WMS_CONTAINER_PUB.LPN;
l_result                 NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Transfer_LPN_Contents_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   /* Validate source LPN */
   l_lpn_source.lpn_id := p_lpn_id_source;
   l_lpn_source.license_plate_number := NULL;
   l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn_source);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate destination LPN */
   l_lpn_dest.lpn_id := p_lpn_id_dest;
   l_lpn_dest.license_plate_number := NULL;
   l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn_dest);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   /* End of input validation */

   UPDATE WMS_LICENSE_PLATE_NUMBERS
     SET parent_lpn_id = p_lpn_id_dest
     WHERE parent_lpn_id = p_lpn_id_source;

   UPDATE WMS_LPN_CONTENTS
     SET parent_lpn_id = p_lpn_id_dest
     WHERE parent_lpn_id = p_lpn_id_source;

   UPDATE MTL_SERIAL_NUMBERS
     SET lpn_id = p_lpn_id_dest
     WHERE lpn_id = p_lpn_id_source;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Transfer_LPN_Contents_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Transfer_LPN_Contents_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      ROLLBACK TO Transfer_LPN_Contents_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Transfer_LPN_Contents;


-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE Container_Required_Qty
(  p_api_version           IN	  NUMBER                          ,
   p_init_msg_list	   IN	  VARCHAR2 := fnd_api.g_false     ,
   p_commit		   IN	  VARCHAR2 := fnd_api.g_false     ,
   x_return_status	   OUT	  VARCHAR2                        ,
   x_msg_count		   OUT	  NUMBER                          ,
   x_msg_data		   OUT	  VARCHAR2                        ,
   p_source_item_id	   IN	  NUMBER                          ,
   p_source_qty	    	   IN	  NUMBER                          ,
   p_source_qty_uom	   IN	  VARCHAR2                        ,
   p_qty_per_cont	   IN	  NUMBER   := NULL                ,
   p_qty_per_cont_uom	   IN	  VARCHAR2 := NULL                ,
   p_organization_id       IN     NUMBER                          ,
   p_dest_cont_item_id     IN OUT NUMBER                          ,
   p_qty_required	   OUT	  NUMBER
)
IS
l_api_name	         CONSTANT VARCHAR2(30)     := 'Container_Required_Qty';
l_api_version	         CONSTANT NUMBER	   := 1.0;
l_source_item            INV_Validate.ITEM;
l_dest_cont_item         INV_Validate.ITEM;
l_cont_item              INV_Validate.ITEM;
l_org                    INV_Validate.ORG;
l_result                 NUMBER;
l_max_load_quantity      NUMBER;
l_qty_per_cont           NUMBER;
l_curr_min_container     NUMBER;
l_curr_min_value         NUMBER;
l_curr_load_quantity     NUMBER;
l_temp_min_value         NUMBER;
l_temp_value             NUMBER;
l_temp_load_quantity     NUMBER;
CURSOR max_load_cursor IS
   SELECT max_load_quantity
	FROM WSH_CONTAINER_ITEMS
	WHERE master_organization_id = p_organization_id
	AND container_item_id = p_dest_cont_item_id
	AND load_item_id = p_source_item_id;

CURSOR container_items_cursor IS
	SELECT container_item_id, max_load_quantity, preferred_flag
	FROM WSH_CONTAINER_ITEMS
	WHERE master_organization_id = p_organization_id
	AND load_item_id = p_source_item_id
	AND container_item_id IN
	(SELECT inventory_item_id
	 FROM MTL_SYSTEM_ITEMS
	 WHERE mtl_transactions_enabled_flag = 'Y'
	 AND container_item_flag = 'Y'
	 AND organization_id = p_organization_id);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Container_Required_Qty_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   /* Validate Organization ID */
   l_org.organization_id := p_organization_id;
   l_result := INV_Validate.Organization(l_org);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ORG');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Source item */
   l_source_item.inventory_item_id := p_source_item_id;
   l_result := INV_Validate.inventory_item(l_source_item, l_org);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ITEM');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Source Quantity */
   IF ((p_source_qty IS NULL) OR (p_source_qty <= 0)) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SRC_QTY');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Source UOM */
   l_result := INV_Validate.Uom(p_source_qty_uom, l_org, l_source_item);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SRC_UOM');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Quantity Per Container */
   IF (p_qty_per_cont IS NOT NULL) THEN
      IF (p_qty_per_cont <= 0) THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVLD_QTY_PER_CONT');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /* Validate Quantity Per Container UOM */
   IF (p_qty_per_cont IS NOT NULL) THEN
      l_result := INV_Validate.Uom(p_qty_per_cont_uom, l_org, l_source_item);
      IF (l_result = INV_Validate.F) THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVLD_QTY_PER_UOM');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /* Validate Destination container item */
   IF (p_dest_cont_item_id IS NOT NULL) THEN
      l_dest_cont_item.inventory_item_id := p_dest_cont_item_id;
      l_result := INV_Validate.inventory_item(l_dest_cont_item, l_org);
      IF (l_result = INV_Validate.F) THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONT_ITEM');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_dest_cont_item.container_item_flag = 'N') THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_ITEM_NOT_A_CONT');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   /* End of input validation */

   IF (p_dest_cont_item_id IS NOT NULL) THEN
		/* Extract or calculate the value of l_max_load_quantity */
		OPEN max_load_cursor;
		FETCH max_load_cursor INTO l_max_load_quantity;
		IF max_load_cursor%NOTFOUND THEN
		/* Need to calculate this value based on weight and volume constraints */
		-- Check that the source item contains all the physical item information
		-- needed for calculation of l_max_load_quantity
		IF ((l_source_item.unit_weight IS NULL) OR
		    (l_source_item.weight_uom_code IS NULL) OR
		    (l_source_item.unit_volume IS NULL) OR
		    (l_source_item.volume_uom_code IS NULL)) THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NOT_ENOUGH_INFO');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		/* Volume constraint */
		l_temp_value := inv_convert.inv_um_convert(l_source_item.inventory_item_id, 6,
						    l_source_item.unit_volume,
						    l_source_item.volume_uom_code,
						    l_dest_cont_item.volume_uom_code,
						    NULL, NULL);
		IF (l_temp_value = -99999) THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (l_dest_cont_item.internal_volume IS NOT NULL) THEN
		   -- Check that the source item's unit volume is less than or
		   -- equal to the destination container item's internal volume
			IF (l_temp_value <= l_dest_cont_item.internal_volume) THEN
				l_max_load_quantity := FLOOR(l_dest_cont_item.internal_volume/l_temp_value);
			ELSE
				FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_ITEM_TOO_LARGE');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
		   END IF;
		END IF;
		/* Weight constraint */
		l_temp_value := inv_convert.inv_um_convert(l_source_item.inventory_item_id, 6,
						    l_source_item.unit_weight,
						    l_source_item.weight_uom_code,
						    l_dest_cont_item.weight_uom_code,
						    NULL, NULL);
		IF (l_temp_value = -99999) THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		/* Select the most constraining value for l_max_load_quantity */
		IF (l_dest_cont_item.maximum_load_weight IS NOT NULL) THEN
			-- Check that the source item's unit weight is less than or
			-- equal to the destination container item's maximum load weight
			IF (l_temp_value <= l_dest_cont_item.maximum_load_weight) THEN
				IF (l_max_load_quantity > FLOOR (l_dest_cont_item.maximum_load_weight /
							  l_temp_value)) THEN
				   l_max_load_quantity := FLOOR (l_dest_cont_item.maximum_load_weight /
							  l_temp_value);
				END IF;
			ELSE
				FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_ITEM_TOO_LARGE');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
	END IF;
	CLOSE max_load_cursor;

	/* Convert l_max_load_quantity into the same UOM as p_source_qty_uom */
	IF (l_max_load_quantity IS NOT NULL) THEN
		l_max_load_quantity := inv_convert.inv_um_convert(l_source_item.inventory_item_id, 6,
							   l_max_load_quantity,
							   l_source_item.primary_uom_code,
							   p_source_qty_uom,
							   NULL, NULL);
		IF (l_max_load_quantity = -99999) THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	/* Calculate the required number of containers needed to store the items */
	IF ((p_qty_per_cont IS NOT NULL) AND (l_max_load_quantity IS NOT NULL)) THEN
		l_qty_per_cont := inv_convert.inv_um_convert(l_source_item.inventory_item_id, 6,
						      p_qty_per_cont,
						      p_qty_per_cont_uom,
						      p_source_qty_uom,
						      NULL, NULL);
		IF (l_qty_per_cont = -99999) THEN
		   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (l_qty_per_cont > l_max_load_quantity) THEN
			FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_OVERPACKED_OPERATION');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		ELSE
		   p_qty_required := CEIL(p_source_qty/l_qty_per_cont);
		END IF;
	ELSIF ((p_qty_per_cont IS NULL) AND (l_max_load_quantity IS NOT NULL)) THEN
	 		p_qty_required := CEIL(p_source_qty/l_max_load_quantity);
	ELSE
		-- If the destination container item contains no internal volume or maximum
		-- load weight restriction values, assume that it has infinite capacity
		  FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NO_RESTRICTIONS_FND');
		-- FND_MESSAGE.SHOW;
		p_qty_required := 1;
	END IF;

	ELSE /* No container item was given */
		l_curr_min_container := 0;
		-- Search through all the containers in WSH_CONTAINER_ITEMS table which can store
		-- the given load_item_id
		FOR v_container_item IN container_items_cursor LOOP
			/* Get the item information for the current container item being considered */
			l_cont_item.inventory_item_id := v_container_item.container_item_id;
			l_result := INV_Validate.inventory_item(l_cont_item, l_org);
			IF (l_result = INV_Validate.F) THEN
			   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONT_ITEM');
			   FND_MSG_PUB.ADD;
			   RAISE FND_API.G_EXC_ERROR;
			END IF;

			/* Get the max load quantity for that given container */
			l_temp_load_quantity := inv_convert.inv_um_convert
			  (l_source_item.inventory_item_id, 6, v_container_item.max_load_quantity,
			   l_source_item.primary_uom_code, p_source_qty_uom, NULL, NULL);
			IF (l_temp_load_quantity = -99999) THEN
			   FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
			   FND_MSG_PUB.ADD;
			   RAISE FND_API.G_EXC_ERROR;
			END IF;

			-- Calculate the min value, i.e. how much space is empty in the final container
			-- used to store the items in units of the source item's uom
			l_temp_min_value := l_temp_load_quantity - MOD(p_source_qty, l_temp_load_quantity);

			-- If ther preferred container flag is set for this container load relationship
			-- Use it reguardless of it's min value
			IF ( v_container_item.preferred_flag = 'Y' ) THEN
			   l_curr_min_container := v_container_item.container_item_id;
			   l_curr_load_quantity := l_temp_load_quantity;
			  	EXIT;
			-- Compare the min value for this container with the best one found so far
			ELSIF ((l_curr_min_container = 0) OR (l_temp_min_value < l_curr_min_value)) THEN
			   l_curr_min_value := l_temp_min_value;
			   l_curr_min_container := v_container_item.container_item_id;
			   l_curr_load_quantity := l_temp_load_quantity;
			   -- If the min values are the same, then choose the container which can hold
			   -- more of the source item, i.e. has a higher load quantity
			ELSIF (l_temp_min_value = l_curr_min_value) THEN
			   IF (l_temp_load_quantity > l_curr_load_quantity) THEN
					l_curr_min_value := l_temp_min_value;
					l_curr_min_container := v_container_item.container_item_id;
					l_curr_load_quantity := l_temp_load_quantity;
				END IF;
			END IF;
      END LOOP;
      /* No containers were found that can store the source item */
      IF (l_curr_min_container = 0) THEN
			p_qty_required := 0;
			FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NO_CONTAINER_FOUND');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			/* Valid container found.  Store this information in the output parameters */
			p_dest_cont_item_id := l_curr_min_container;
			p_qty_required := CEIL(p_source_qty / l_curr_load_quantity);
      END IF;
   END IF;
   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Container_Required_Qty_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Container_Required_Qty_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      ROLLBACK TO Container_Required_Qty_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Container_Required_Qty;



-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE Get_Outermost_LPN
(  p_api_version           IN	  NUMBER                          ,
   p_init_msg_list	   IN	  VARCHAR2 := fnd_api.g_false     ,
   p_commit		   IN	  VARCHAR2 := fnd_api.g_false     ,
   x_return_status	   OUT	  VARCHAR2                        ,
   x_msg_count		   OUT	  NUMBER                          ,
   x_msg_data		   OUT	  VARCHAR2                        ,
   p_lpn_id                IN     NUMBER   := NULL                ,
   p_inventory_item_id     IN     NUMBER   := NULL                ,
   p_revision              IN     VARCHAR2 := NULL                ,
   p_lot_number            IN     VARCHAR2 := NULL                ,
   p_serial_number         IN     VARCHAR2 := NULL                ,
   x_lpn_list              OUT    WMS_CONTAINER_PUB.LPN_Table_Type
)
IS
l_api_name	     CONSTANT VARCHAR2(30)    := 'Get_Outermost_LPN';
l_api_version	     CONSTANT NUMBER	      := 1.0;
l_SelectStmt         VARCHAR2(500);
l_CursorID           INTEGER;
l_Dummy              INTEGER;
l_temp_lpn           NUMBER;
CURSOR nested_parent_lpn_cursor IS
   SELECT *
     FROM WMS_LICENSE_PLATE_NUMBERS
     START WITH lpn_id = p_lpn_id
     CONNECT BY lpn_id = PRIOR parent_lpn_id;
l_current_lpn        NUMBER;
CURSOR nested_parent_lpn_cursor_2 IS
   SELECT *
     FROM WMS_LICENSE_PLATE_NUMBERS
     START WITH lpn_id = l_current_lpn
     CONNECT BY lpn_id = PRIOR parent_lpn_id;
l_lpn                WMS_CONTAINER_PUB.LPN;
l_temp_table         WMS_CONTAINER_PUB.LPN_Table_Type;
l_index              BINARY_INTEGER := 1;
l_index_2            BINARY_INTEGER := 1;
l_duplicate_index    BINARY_INTEGER := 1;
l_result             NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Get_Outermost_LPN_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   /* Validate that enough info has been passed in */
   IF ((p_lpn_id IS NULL) AND (p_inventory_item_id IS NULL)) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NOT_ENOUGH_INFO');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate LPN */
   IF (p_lpn_id IS NOT NULL) THEN
      l_lpn.lpn_id := p_lpn_id;
      l_lpn.license_plate_number := NULL;
      l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn);
      IF (l_result = INV_Validate.F) THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   /* End of input validation */

   IF (p_lpn_id IS NOT NULL) THEN
      -- Find outermost LPN for a specific LPN
      FOR l_lpn_record IN nested_parent_lpn_cursor LOOP
	 IF (l_lpn_record.parent_lpn_id IS NULL) THEN
	    x_lpn_list(1) := l_lpn_record;
	    -- There should only be one record that has no parent
	    -- which corresponds to the outermost LPN, assuming that
	    -- the data in the table is consistent.
	 END IF;
      END LOOP;
    ELSE -- Find outermost LPN(s) for a specific item
      -- First we need to get all of the LPN's which store the given
      -- inventory item.  Use DBMS_SQL to do a dynamic query on the
      -- WMS_LPN_CONTENTS table to get all the LPN's that store the
      -- given item with the specified parameters.

      l_SelectStmt := 'SELECT PARENT_LPN_ID FROM WMS_LPN_CONTENTS WHERE ';
      l_SelectStmt := l_SelectStmt || 'inventory_item_id = ' ||
	p_inventory_item_id || ' AND ';
      IF (p_revision IS NOT NULL) THEN
	 l_SelectStmt := l_SelectStmt || 'revision = ' ||
	   p_revision || ' AND ';
      END IF;
      IF (p_lot_number IS NOT NULL) THEN
	 l_SelectStmt := l_SelectStmt || 'lot_number = ' ||
	   p_lot_number || ' AND ';
      END IF;
      IF (p_serial_number IS NOT NULL) THEN
	 l_SelectStmt := l_SelectStmt || 'serial_number = ' ||
	   p_serial_number || ' AND ';
      END IF;

      -- Tie up loose ends of the where clause in the query statement
      l_SelectStmt := l_SelectStmt || '1 = 1';

      -- Open a cursor for processing.
      l_CursorID := DBMS_SQL.OPEN_CURSOR;

      -- Parse the query
      DBMS_SQL.PARSE(l_CursorID, l_SelectStmt, DBMS_SQL.V7);

      -- Define the output variables
      DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, l_temp_lpn);

      -- Execute the statement. We don't care about the return value,
      -- but we do need to declare a variable for it.
      l_Dummy := DBMS_SQL.EXECUTE(l_CursorID);

      -- This is the fetch loop
      LOOP
	 -- Fetch the rows into the buffer, and also check for the exit
	 -- condition from the loop.
	 IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	    EXIT;
	 END IF;

	 -- Retrieve the rows from the buffer into a temp variable.
	 DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_temp_lpn);

	 -- Get the outermost LPN for each parent lpn from WMS_LPN_CONTENTS
	 l_current_lpn := l_temp_lpn;
	 FOR l_lpn_record IN nested_parent_lpn_cursor_2 LOOP
	    IF (l_lpn_record.parent_lpn_id IS NULL) THEN
	       l_temp_table(l_index) := l_lpn_record;
	       l_index := l_index + 1;
	       -- There should only be one record that has no parent lpn
	       -- which corresponds to the outermost LPN, assuming that
	       -- the data in the table is consistent.
	    END IF;
	 END LOOP;
      END LOOP;

      -- Close the cursor.
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

      -- Now we have a table, l_temp_table which contains the list of
      -- outermost LPN records.  There are possibly duplicate records
      -- since an item can be stored in multiple LPN's.  We now need to
      -- pick out only one of each LPN record to be stored in the output
      -- table, x_lpn_list.

      IF (l_temp_table.COUNT <> 0) THEN  -- Check that entries found
	 l_index := l_temp_table.FIRST;  -- Initialize the index
	 LOOP
	    -- Transfer only new lpn record entries from l_temp_table into
	    -- x_lpn_list.  Check if the current record in l_temp_table is
	    -- already in x_lpn_list
	    IF (x_lpn_list.COUNT = 0) THEN  -- Insert first initial record
	       x_lpn_list(l_index_2) := l_temp_table(l_index);
		  l_index_2 := l_index_2 + 1;
	     ELSE -- Check if current record in l_temp_table is already there
	       l_duplicate_index := x_lpn_list.FIRST;

	       <<Check_Duplicate_Loop>>
		 LOOP
		    IF (l_temp_table(l_index).lpn_id =
			x_lpn_list(l_duplicate_index).lpn_id) THEN
		       EXIT Check_Duplicate_Loop; -- Entry is already in table
		    END IF;

		    IF (l_duplicate_index = x_lpn_list.LAST) THEN
		       -- All entries have been checked and none match
		       x_lpn_list(l_index_2) := l_temp_table(l_index);
		       l_index_2 := l_index_2 + 1;
		    END IF;
		    EXIT WHEN l_duplicate_index = x_lpn_list.LAST;
		    l_duplicate_index := x_lpn_list.NEXT(l_duplicate_index);
		 END LOOP Check_Duplicate_Loop;

	    END IF;
	    EXIT WHEN l_index = l_temp_table.LAST;
	    l_index := l_temp_table.NEXT(l_index);
	 END LOOP;
      END IF;

   END IF;
   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Outermost_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Outermost_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
      ROLLBACK TO Get_Outermost_LPN_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Get_Outermost_LPN;



-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE Get_LPN_List
(  p_api_version           IN	  NUMBER                          ,
   p_init_msg_list	   IN	  VARCHAR2 := fnd_api.g_false     ,
   p_commit		   IN	  VARCHAR2 := fnd_api.g_false     ,
   x_return_status	   OUT	  VARCHAR2                        ,
   x_msg_count		   OUT	  NUMBER                          ,
   x_msg_data		   OUT	  VARCHAR2                        ,
   p_lpn_context           IN     NUMBER   := NULL                ,
   p_content_item_id       IN     NUMBER   := NULL                ,
   p_max_content_item_qty  IN     NUMBER   := NULL                ,
   p_organization_id       IN     NUMBER                          ,
   p_subinventory          IN     VARCHAR2 := NULL                ,
   p_locator_id            IN     NUMBER   := NULL                ,
   p_revision              IN     VARCHAR2 := NULL                ,
   p_lot_number            IN     VARCHAR2 := NULL                ,
   p_serial_number         IN     VARCHAR2 := NULL                ,
   p_container_item_id     IN     NUMBER   := NULL                ,
   x_lpn_list              OUT    WMS_CONTAINER_PUB.LPN_Table_Type
)
IS
l_api_name	           CONSTANT VARCHAR2(30)    := 'Get_LPN_List';
l_api_version	           CONSTANT NUMBER	    := 1.0;
l_SelectStmt               VARCHAR2(500);
TYPE lpn_id_table IS TABLE OF WMS_LICENSE_PLATE_NUMBERS.LPN_ID%TYPE
  INDEX BY BINARY_INTEGER;
l_temp_table               lpn_id_table;
l_CursorID                 INTEGER;
l_Dummy                    INTEGER;
l_temp_record              WMS_LICENSE_PLATE_NUMBERS%ROWTYPE;
l_index                    BINARY_INTEGER := 1;
l_list_index               BINARY_INTEGER := 1;
l_temp_lpn                 NUMBER;
l_org                      INV_Validate.ORG;
l_result                   NUMBER;
l_single_item_flag         INTEGER;
l_dummy_lpn                NUMBER;
CURSOR item_cursor IS
   SELECT parent_lpn_id
     FROM WMS_LPN_CONTENTS
     WHERE parent_lpn_id = l_temp_lpn
     AND NVL(serial_summary_entry, 2) = 2;
CURSOR container_cursor IS
   SELECT parent_lpn_id
     FROM WMS_LICENSE_PLATE_NUMBERS
     WHERE parent_lpn_id = l_temp_lpn;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Get_LPN_List_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   /* Validate Organization ID */
   l_org.organization_id := p_organization_id;
   l_result := INV_Validate.Organization(l_org);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ORG');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   /* End of input validation */

   -- First we need to get all of the LPN's which store the given
   -- inventory item.  Use DBMS_SQL to do a dynamic query on the
   -- WMS_LPN_CONTENTS table to get all the LPN's that store the
   -- given item with the specified parameters.

   l_SelectStmt := 'SELECT a.lpn_id
     FROM WMS_LICENSE_PLATE_NUMBERS a, WMS_LPN_CONTENTS b WHERE ';

   IF (p_lpn_context IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'a.lpn_context = ' ||
	p_lpn_context || ' AND ';
   END IF;
   IF (p_content_item_id IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'b.inventory_item_id = ' ||
	p_content_item_id || ' AND ';
   END IF;
   IF (p_max_content_item_qty IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'b.quantity <= ' ||
	p_max_content_item_qty || ' AND ';
   END IF;
   IF (p_organization_id IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'a.organization_id = ' ||
	p_organization_id || ' AND ';
   END IF;
   IF (p_subinventory IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'a.subinventory_code = ' ||
	p_subinventory || ' AND ';
   END IF;
   IF (p_locator_id IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'a.locator_id = ' ||
	p_locator_id || ' AND ';
   END IF;
   IF (p_revision IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'b.revision = ' ||
	p_revision || ' AND ';
   END IF;
   IF (p_lot_number IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'b.lot_number = ' ||
	p_lot_number || ' AND ';
   END IF;
   IF (p_serial_number IS NOT NULL) THEN
	 l_SelectStmt := l_SelectStmt || 'b.serial_number = ' ||
	   p_serial_number || ' AND ';
   END IF;
   IF (p_container_item_id IS NOT NULL) THEN
      l_SelectStmt := l_SelectStmt || 'a.inventory_item_id = ' ||
	p_container_item_id || ' AND ';
   END IF;

   -- Finish the WHERE clause with the join condition for the two tables
   l_SelectStmt := l_SelectStmt || 'a.lpn_id = b.parent_lpn_id';

   -- Open a cursor for processing.
   l_CursorID := DBMS_SQL.OPEN_CURSOR;

   -- Parse the query
   DBMS_SQL.PARSE(l_CursorID, l_SelectStmt, DBMS_SQL.V7);

   -- Define the output variables
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, l_temp_lpn);

   -- Execute the statement. We don't care about the return value,
   -- but we do need to declare a variable for it.
   l_Dummy := DBMS_SQL.EXECUTE(l_CursorID);

   -- This is the fetch loop
   LOOP
      -- Fetch the rows into the buffer, and also check for the exit
      -- condition from the loop.
      IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	 EXIT;
      END IF;

      -- Retrieve the rows from the buffer into a temp variable.
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_temp_lpn);

      -- Insert the fetched data in the temp record into the temp table
      l_temp_table(l_index) := l_temp_lpn;
      l_index := l_index + 1;

   END LOOP;

   -- Close the cursor.
   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
   -- Now that we have all the LPN records which satisfy the set of user
   -- parameters, we have to sort through these records to see which of them
   -- come from homogeneous LPN's.

   -- Check that something was retrieved and populated in the temp table.
   IF (l_temp_table.COUNT <> 0) THEN
      l_index := l_temp_table.FIRST;
      LOOP
	 l_temp_lpn := l_temp_table(l_index);
	 OPEN item_cursor;
	 FETCH item_cursor INTO l_dummy_lpn;
	 IF item_cursor%FOUND THEN
	    FETCH item_cursor INTO l_dummy_lpn;
	    IF item_cursor%NOTFOUND THEN
	       l_single_item_flag := 2; -- Homogeneously packed item-wise
	     ELSE
	       l_single_item_flag := 1;
	    END IF;
	 END IF;
	 CLOSE item_cursor;

	 IF (l_single_item_flag = 2) THEN
	    OPEN container_cursor;
	    FETCH container_cursor INTO l_dummy_lpn;
	    IF container_cursor%NOTFOUND THEN
	       SELECT *
		 INTO l_temp_record
		 FROM WMS_LICENSE_PLATE_NUMBERS
		 WHERE lpn_id = l_temp_lpn;
	       x_lpn_list(l_list_index) := l_temp_record;
	       l_list_index := l_list_index + 1;
	    END IF;
	    CLOSE container_cursor;
	 END IF;

	 EXIT WHEN l_index = l_temp_table.LAST;
	 l_index := l_temp_table.NEXT(l_index);
      END LOOP;
   END IF;
   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_LPN_List_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_LPN_List_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
      ROLLBACK TO Get_LPN_List_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Get_LPN_List;



-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
FUNCTION validate_pick_drop_lpn
(  p_api_version_number    IN   NUMBER                       ,
   p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
   p_pick_lpn_id           IN   NUMBER                       ,
   p_organization_id       IN   NUMBER                       ,
   p_drop_lpn              IN   VARCHAR2,
   p_drop_sub              IN   VARCHAR2,
   p_drop_loc              IN   NUMBER)
-- Added sub and loc for validation
  RETURN NUMBER

  IS
   l_dummy        VARCHAR2(1) := NULL;

   l_api_version_number  CONSTANT NUMBER        := 1.0;
   l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_Pick_Drop_Lpn';
   l_return_status       VARCHAR2(1)            := fnd_api.g_ret_sts_success;

   l_drop_lpn_exists          BOOLEAN := FALSE;
   l_drop_lpn_has_picked_inv  BOOLEAN := FALSE;
   l_pick_lpn_delivery_id     NUMBER  := NULL;
   l_drop_lpn_delivery_id     NUMBER  := NULL;

   TYPE lpn_rectype is RECORD
   (
    lpn_id       wms_license_plate_numbers.lpn_id%TYPE,
    lpn_context  wms_license_plate_numbers.lpn_context%TYPE,
    subinventory_code  wms_license_plate_numbers.subinventory_code%TYPE,
    locator_id  wms_license_plate_numbers.locator_id%TYPE
   );
   drop_lpn_rec lpn_rectype;

   CURSOR drop_lpn_cursor IS
   SELECT lpn_id,
     lpn_context,
     subinventory_code,
     locator_id
     FROM wms_license_plate_numbers
    WHERE license_plate_number = p_drop_lpn
      AND organization_id      = p_organization_id;

   CURSOR pick_delivery_cursor IS
   SELECT wda.delivery_id
     FROM wsh_delivery_assignments        wda,
          wsh_delivery_details            wdd,
          mtl_material_transactions_temp  temp
    WHERE wda.delivery_detail_id  = wdd.delivery_detail_id
      AND wdd.move_order_line_id  = temp.move_order_line_id
      AND wdd.organization_id     = temp.organization_id
      AND temp.transfer_lpn_id    = p_pick_lpn_id
      AND temp.organization_id    = p_organization_id ;

   CURSOR drop_delivery_cursor(l_lpn_id IN NUMBER) IS
   SELECT wda.delivery_id
     FROM wsh_delivery_assignments        wda,
          wsh_delivery_details            wdd,
          wms_license_plate_numbers lpn
     WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
      AND wdd.lpn_id                     = lpn.lpn_id
      AND lpn.outermost_lpn_id           = l_lpn_id
      AND wdd.organization_id            = p_organization_id ;

   l_delivery_match_flag NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mdebug ('Start Validate_Pick_Drop_Lpn.');
   END IF;

   --
   -- Initialize API return status to success
   --
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   l_delivery_match_flag := -1;

   --
   -- Begin validation process:
   -- Check if drop lpn exists by trying to retrieve
   -- its lpn ID.  If it does not exist,
   -- no further validations required - return success.
   --
   OPEN drop_lpn_cursor;
   FETCH drop_lpn_cursor INTO drop_lpn_rec;
   IF drop_lpn_cursor%NOTFOUND THEN
      l_drop_lpn_exists := FALSE;
   ELSE
      l_drop_lpn_exists := TRUE;
   END IF;

   IF NOT l_drop_lpn_exists THEN
      IF (l_debug = 1) THEN
         mdebug ('Drop LPN is a new LPN, no checking required.');
      END IF;
      RETURN 1;
   END IF;

   --
   -- If the drop lpn was pre-generated, no validations required
   --

   IF drop_lpn_rec.lpn_context =
      WMS_Container_PUB.LPN_CONTEXT_PREGENERATED THEN
      --
      -- Update the context to "Resides in Inventory" (1)
      --
   /*   UPDATE wms_license_plate_numbers
         SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
	   WHERE lpn_id = drop_lpn_rec.lpn_id;*/

      IF (l_debug = 1) THEN
         mdebug ('Drop LPN is pre-generated, no checking required.');
      END IF;
	 RETURN 1;

    ELSIF drop_lpn_rec.lpn_context = WMS_Container_PUB.lpn_context_picked THEN
      IF drop_lpn_rec.subinventory_code <>  p_drop_sub or
	drop_lpn_rec.locator_id <> p_drop_loc THEN
	 IF (l_debug = 1) THEN
   	 mdebug ('Drop LPN does not belong to the same sub and loc.');
	 END IF;
	 RETURN 2; -- Drop LPN resides in another Staging Lane
      END IF;
   END IF;

   IF drop_lpn_rec.lpn_context =
         WMS_Container_PUB.LPN_LOADED_FOR_SHIPMENT THEN
         IF (l_debug = 1) THEN
            mdebug ('Drop LPN is loaded to dock door already');
         END IF;
         RETURN 4; -- Drop LPN is loaded  to dock door already
   END IF;

   --
   -- Drop LPN cannot be the same as the picked LPN
   --
   IF drop_lpn_rec.lpn_id = p_pick_lpn_id THEN
      IF (l_debug = 1) THEN
         mdebug ('Drop LPN cannot be the picked LPN.');
      END IF;
      RETURN 3; -- Drop LPN Cannot be the same as Pick LPN
   END IF;


   --
   -- Now check if the picked LPN and drop LPN
   -- belong to different deliveries
   --
   OPEN pick_delivery_cursor;
   LOOP
      FETCH pick_delivery_cursor INTO l_pick_lpn_delivery_id;
      EXIT WHEN l_pick_lpn_delivery_id IS NOT NULL OR pick_delivery_cursor%NOTFOUND;
   END LOOP;
   CLOSE pick_delivery_cursor;

   --
   -- If the picked LPN is not associated with a delivery yet
   -- then no further checking required, return success
   --
   IF l_pick_lpn_delivery_id is NULL THEN
      IF (l_debug = 1) THEN
         mdebug('Picked LPN is not associated with a delivery, so dont show ANY lpn.');
      END IF;
      RETURN 0; -- Change here...
   END IF;

   --
   -- Find the drop LPN's delivery ID
   --

   OPEN drop_delivery_cursor(drop_lpn_rec.lpn_id);
   LOOP
      FETCH drop_delivery_cursor INTO l_drop_lpn_delivery_id;
      EXIT WHEN drop_delivery_cursor%notfound OR l_delivery_match_flag = 0;

      IF l_drop_lpn_delivery_id is NOT NULL THEN

	 IF l_drop_lpn_delivery_id <> l_pick_lpn_delivery_id THEN
	    IF (l_debug = 1) THEN
   	    mdebug('Picked and drop LPNs are on different deliveries.');
	    END IF;

	    l_delivery_match_flag := 0;
	  ELSE
	    --
	    -- Drop LPN and picked LPN are on the same delivery
	    -- return success
	    --
	    IF (l_debug = 1) THEN
   	    mdebug('Drop and pick LPNs are on the same delivery: '||l_drop_lpn_delivery_id);
	    END IF;

	    l_delivery_match_flag := 1;
	 END IF;
      END IF;

   END LOOP;
   CLOSE drop_delivery_cursor;

   IF l_delivery_match_flag = 0 OR l_delivery_match_flag = -1 THEN

      RETURN 0;

    ELSIF l_delivery_match_flag = 1 THEN

      RETURN 1;

   END IF;

   IF l_return_status =FND_API.g_ret_sts_success THEN
      RETURN 1;
    ELSE
      RETURN 0;
   END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN

       RETURN 0;

    WHEN OTHERS THEN

       RETURN 0;

END validate_pick_drop_lpn;
/*
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
PROCEDURE validate_pick_drop_lpn
(  p_api_version_number    IN   NUMBER                       ,
   p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
   x_return_status         OUT  VARCHAR2                     ,
   x_msg_count             OUT  NUMBER                       ,
   x_msg_data              OUT  VARCHAR2                     ,
   p_pick_lpn_id           IN   NUMBER                       ,
   p_organization_id       IN   NUMBER                       ,
   p_drop_lpn              IN   VARCHAR2 )
IS
   l_dummy        VARCHAR2(1) := NULL;

   l_api_version_number  CONSTANT NUMBER        := 1.0;
   l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_Pick_Drop_Lpn';
   l_return_status       VARCHAR2(1)            := fnd_api.g_ret_sts_success;

   l_drop_lpn_exists          BOOLEAN := FALSE;
   l_drop_lpn_has_picked_inv  BOOLEAN := FALSE;
   l_pick_lpn_delivery_id     NUMBER  := NULL;
   l_drop_lpn_delivery_id     NUMBER  := NULL;

   TYPE lpn_rectype is RECORD
   (
       lpn_id       wms_license_plate_numbers.lpn_id%TYPE,
       lpn_context  wms_license_plate_numbers.lpn_context%TYPE
   );
   drop_lpn_rec lpn_rectype;

   CURSOR drop_lpn_cursor IS
   SELECT lpn_id,
          lpn_context
     FROM wms_license_plate_numbers
    WHERE license_plate_number = p_drop_lpn
      AND organization_id      = p_organization_id;

   CURSOR child_lpns_cursor(l_lpn_id IN NUMBER) IS
   SELECT lpn_id
     FROM WMS_LICENSE_PLATE_NUMBERS
    START WITH lpn_id        = l_lpn_id
  CONNECT BY   parent_lpn_id = PRIOR lpn_id;
  child_lpns_rec  child_lpns_cursor%ROWTYPE;

   CURSOR delivery_detail_cursor(l_lpn_id IN NUMBER) IS
   SELECT 'x'
     FROM dual
    WHERE EXISTS (
                  SELECT 'x'
                    FROM wsh_delivery_details
                   WHERE lpn_id           = l_lpn_id
                     AND organization_id  = p_organization_id
                 );

   CURSOR pick_delivery_cursor IS
   SELECT wda.delivery_id
     FROM wsh_delivery_assignments        wda,
          wsh_delivery_details            wdd,
          mtl_material_transactions_temp  temp
    WHERE wda.delivery_detail_id  = wdd.delivery_detail_id
      AND wdd.move_order_line_id  = temp.move_order_line_id
      AND wdd.organization_id     = temp.organization_id
      AND temp.transfer_lpn_id    = p_pick_lpn_id
      AND temp.organization_id    = p_organization_id;

   CURSOR drop_delivery_cursor(l_lpn_id IN NUMBER) IS
   SELECT wda.delivery_id
     FROM wsh_delivery_assignments        wda,
          wsh_delivery_details            wdd
    WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
      AND wdd.lpn_id                    = l_lpn_id
      AND wdd.organization_id           = p_organization_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mdebug ('Start Validate_Pick_Drop_Lpn.');
   END IF;

   --
   -- Standard call to check for call compatibility
   --
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   --  Initialize message list.
   --
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   --
   -- Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin validation process:
   -- Check if drop lpn exists by trying to retrieve
   -- its lpn ID.  If it does not exist,
   -- no further validations required - return success.
   --
   OPEN drop_lpn_cursor;
   FETCH drop_lpn_cursor INTO drop_lpn_rec;
   IF drop_lpn_cursor%NOTFOUND THEN
      l_drop_lpn_exists := FALSE;
   ELSE
      l_drop_lpn_exists := TRUE;
   END IF;

   IF NOT l_drop_lpn_exists THEN
      IF (l_debug = 1) THEN
         mdebug ('Drop LPN is a new LPN, no checking required.');
      END IF;
      return;
   END IF;

   --
   -- If the drop lpn was pre-generated, no validations required
   --
   IF drop_lpn_rec.lpn_context =
      WMS_Container_PUB.LPN_CONTEXT_PREGENERATED THEN
      --
      -- Update the context to "Resides in Inventory" (1)
      --
      UPDATE wms_license_plate_numbers
         SET lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
       WHERE lpn_id = drop_lpn_rec.lpn_id;
      IF (l_debug = 1) THEN
         mdebug ('Drop LPN is pre-generated, no checking required.');
      END IF;
      return;
   END IF;

   --
   -- Drop LPN cannot be the same as the picked LPN
   --
   IF drop_lpn_rec.lpn_id = p_pick_lpn_id THEN
      IF (l_debug = 1) THEN
         mdebug ('Drop LPN cannot be the picked LPN.');
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_PICK_LPN_INVLD_DROP_LPN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   -- Make sure the drop LPN or one of its child LPNs
   -- is associated with delivery detail, i.e., contains
   -- picked inventory
   --
   OPEN delivery_detail_cursor(drop_lpn_rec.lpn_id);
   FETCH delivery_detail_cursor INTO l_dummy;
   IF delivery_detail_cursor%FOUND THEN
      l_drop_lpn_has_picked_inv := TRUE;
   ELSE
      l_drop_lpn_has_picked_inv := FALSE;
   END IF;
   CLOSE delivery_detail_cursor;

   --
   -- Check the child LPNs if the drop LPN is
   -- not picked for an order
   --
   IF NOT l_drop_lpn_has_picked_inv THEN
      IF (l_debug = 1) THEN
         mdebug('Drop LPN does not have picked inventory, checking child LPNs..');
      END IF;
      OPEN child_lpns_cursor(drop_lpn_rec.lpn_id);
      LOOP
         FETCH child_lpns_cursor INTO child_lpns_rec;
         EXIT WHEN child_lpns_cursor%NOTFOUND;
         IF (l_debug = 1) THEN
            mdebug('Trying to fetch a child (drop) LPN.');
         END IF;
         IF child_lpns_cursor%FOUND THEN
            OPEN delivery_detail_cursor(child_lpns_rec.lpn_id);
            FETCH delivery_detail_cursor INTO l_dummy;
            IF delivery_detail_cursor%FOUND THEN
               IF (l_debug = 1) THEN
                  mdebug('Child LPN '||child_lpns_rec.lpn_id||' has picked inventory.');
               END IF;
               l_drop_lpn_has_picked_inv := TRUE;
            END IF;
            CLOSE delivery_detail_cursor;
         END IF;
         EXIT WHEN l_drop_lpn_has_picked_inv;
      END LOOP;
      CLOSE child_lpns_cursor;
      --
      -- If the child LPNs also don't have picked inventory
      -- then the user scanned an non-picked LPN so return
      -- an error
      --
      IF NOT l_drop_lpn_has_picked_inv THEN
         IF (l_debug = 1) THEN
            mdebug('Drop LPN does not have child LPNs with picked inventory.');
         END IF;
         FND_MESSAGE.SET_NAME('WMS', 'WMS_DROP_LPN_NOT_PICKED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --
   -- Now check if the picked LPN and drop LPN
   -- belong to different deliveries
   --
   OPEN pick_delivery_cursor;
   LOOP
      FETCH pick_delivery_cursor INTO l_pick_lpn_delivery_id;
      EXIT WHEN l_pick_lpn_delivery_id IS NOT NULL OR pick_delivery_cursor%NOTFOUND;
   END LOOP;
   CLOSE pick_delivery_cursor;

   --
   -- If the picked LPN is not associated with a delivery yet
   -- then no further checking required, return success
   --
   IF l_pick_lpn_delivery_id is NULL THEN
      IF (l_debug = 1) THEN
         mdebug('Picked LPN is not associated with a delivery, so ok.');
      END IF;
      return;
   END IF;

   --
   -- Find the drop LPN's delivery ID
   --
   OPEN drop_delivery_cursor(drop_lpn_rec.lpn_id);
   FETCH drop_delivery_cursor INTO l_drop_lpn_delivery_id;
   CLOSE drop_delivery_cursor;

   IF l_drop_lpn_delivery_id is NOT NULL THEN
      IF l_drop_lpn_delivery_id <> l_pick_lpn_delivery_id THEN
         IF (l_debug = 1) THEN
            mdebug('Picked and drop LPNs are on different deliveries.');
         END IF;
         FND_MESSAGE.SET_NAME('WMS', 'WMS_DROP_LPN_DIFF_DELIV');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         --
         -- Drop LPN and picked LPN are on the same delivery
         -- return success
         --
         IF (l_debug = 1) THEN
            mdebug('Drop and pick LPNs are on the same delivery: '||l_drop_lpn_delivery_id);
         END IF;
         return;
      END IF;
   ELSE
      IF (l_debug = 1) THEN
         mdebug('Drop LPN does not have a delivery ID, checking child LPNs');
      END IF;
      OPEN child_lpns_cursor(drop_lpn_rec.lpn_id);
      LOOP
         FETCH child_lpns_cursor INTO child_lpns_rec;
         EXIT WHEN child_lpns_cursor%NOTFOUND;
         IF child_lpns_cursor%FOUND THEN
            OPEN drop_delivery_cursor(child_lpns_rec.lpn_id);
            FETCH drop_delivery_cursor INTO l_drop_lpn_delivery_id;
            CLOSE drop_delivery_cursor;
         END IF;
         EXIT WHEN l_drop_lpn_delivery_id IS NOT NULL;
      END LOOP;
      CLOSE child_lpns_cursor;

      --
      -- If the child LPNs also don't have a delivery ID
      -- then ok to deposit
      --
      IF l_drop_lpn_delivery_id is NOT NULL THEN
         IF l_drop_lpn_delivery_id <> l_pick_lpn_delivery_id THEN
            IF (l_debug = 1) THEN
               mdebug('LPNs are on diff deliveries.');
            END IF;
            FND_MESSAGE.SET_NAME('WMS', 'WMS_DROP_LPN_DIFF_DELIV');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            --
            -- Drop LPN has a child LPN that is assigned to the
            -- same delivery as the picked LPN, return success
            --
            IF (l_debug = 1) THEN
               mdebug('A child LPN is on the same delivery as the picked LPN, return success.');
            END IF;
            return;
         END IF;
      ELSE
         --
         -- No child LPNs on the drop LPN have a delivery ID yet
         -- return success
         --
         IF (l_debug = 1) THEN
            mdebug('Child LPNs of the drop LPN do not have a delivery ID either, return success.');
         END IF;
         return;
      END IF;
   END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
        IF (l_debug = 1) THEN
           mdebug ('@'||x_msg_data||'@');
        END IF;

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
        IF (l_debug = 1) THEN
           mdebug ('@'||x_msg_data||'@');
        END IF;

END validate_pick_drop_lpn;
  */

  Procedure default_pick_drop_lpn
  (  p_api_version_number    IN   NUMBER                   ,
  p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
  p_pick_lpn_id           IN   NUMBER                       ,
  p_organization_id       IN   NUMBER                       ,
  x_lpn_number           OUT   VARCHAR2)

  IS

  l_api_version_number  CONSTANT NUMBER        := 1.0;
  l_api_name            CONSTANT VARCHAR2(30)  :=
                        'default_pick_drop_lpn';
  l_return_status       VARCHAR2(1)            :=
    fnd_api.g_ret_sts_success;
  l_delivery_id NUMBER;
  l_drop_sub   VARCHAR2(10);
  l_drop_loc   NUMBER;
  l_lpn_id     NUMBER;


  CURSOR pick_delivery_cursor IS
  SELECT wda.delivery_id
  FROM wsh_delivery_assignments        wda,
  wsh_delivery_details            wdd,
  mtl_material_transactions_temp  temp
  WHERE wda.delivery_detail_id   = wdd.delivery_detail_id
  AND wdd.move_order_line_id  = temp.move_order_line_id
  AND wdd.organization_id     = temp.organization_id
  AND temp.transfer_lpn_id    = p_pick_lpn_id
  AND temp.organization_id    = p_organization_id;

  CURSOR drop_delivery_cursor (l_delivery_id_c IN NUMBER,
			       l_drop_sub_c IN VARCHAR2,
			       l_drop_loc_c IN NUMBER ) IS
  SELECT wlpn.outermost_lpn_id
  FROM wsh_delivery_assignments        wda,
  wsh_delivery_details            wdd,
  wms_license_plate_numbers       wlpn
  WHERE  wda.delivery_id               = l_delivery_id_c
  AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
  AND wdd.organization_id           = p_organization_id
    AND wdd.lpn_id                    = wlpn.lpn_id
  AND wlpn.subinventory_code        = l_drop_sub_c
  AND	wlpn.locator_id               = l_drop_loc_c
  AND wlpn.lpn_context              = 11
    ORDER BY wda.CREATION_DATE DESC ;


  delivery_id_rec pick_delivery_cursor%ROWTYPE;
  license_plate_rec drop_delivery_cursor%ROWTYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN


  IF NOT fnd_api.compatible_api_call (l_api_version_number
  , p_api_version_number
  , l_api_name
  , G_PKG_NAME
  ) THEN
     FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
       FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  --  Initialize message list.
  --

  IF fnd_api.to_boolean(p_init_msg_lst) THEN
  fnd_msg_pub.initialize;
  END IF;


  BEGIN
     Select transfer_subinventory, transfer_to_location into l_drop_sub,
       l_drop_loc
  from mtl_material_transactions_temp
  where transfer_lpn_id    = p_pick_lpn_id
  AND organization_id    = p_organization_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  l_delivery_id := NULL;

  WHEN OTHERS THEN
  l_delivery_id := NULL;
  END;

  -- Select the Delivery for the LPN that is being picked

  FOR delivery_id_rec IN pick_delivery_cursor
    LOOP
       l_delivery_id := delivery_id_rec.delivery_id;
    EXIT WHEN delivery_id_rec.delivery_id IS NOT NULL OR pick_delivery_cursor%NOTFOUND;
  END LOOP;


  -- Find the drop LPN's delivery ID
  FOR license_plate_rec IN drop_delivery_cursor
    (l_delivery_id,l_drop_sub,l_drop_loc )
  LOOP
     l_lpn_id  := license_plate_rec.outermost_lpn_id;
     EXIT WHEN  license_plate_rec.outermost_lpn_id IS NOT NULL OR drop_delivery_cursor%NOTFOUND;
  END LOOP;


  BEGIN
  SELECT license_plate_number INTO x_lpn_number FROM
    wms_license_plate_numbers WHERE lpn_id = l_lpn_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	x_lpn_number := NULL;

     WHEN OTHERS THEN
        x_lpn_number := NULL;
  END;

  END default_pick_drop_lpn;

-- End of package
END WMS_Container2_PUB;

/
