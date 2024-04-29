--------------------------------------------------------
--  DDL for Package Body INV_LOT_SERIAL_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_SERIAL_UPGRADE" AS
/* $Header: INVLSUGB.pls 120.2 2005/06/11 08:44:29 appldev  $ */

/**************************
 * Private API            *
 **************************/

/* Debug */
PROCEDURE trace(p_msg IN VARCHAR2, p_level IN NUMBER DEFAULT 4) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
   	inv_trx_util_pub.trace(p_msg, 'UPGRADE_LOT_SER', 1);
	END IF;
	--dbms_output.put_line(p_msg);
END trace;

/* Private API to upgrade the lot numbers*/
PROCEDURE UPGRADE_LOT(
	x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,	x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
,	x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,	x_upgrade_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,	p_organization_id     IN   NUMBER DEFAULT NULL
) IS

	CURSOR c_lot(p_org_id NUMBER) IS
		SELECT organization_id, inventory_item_id, lot_number
		FROM mtl_lot_numbers
		WHERE organization_id = nvl(p_org_id, organization_id)
		AND lot_attribute_category IS NULL
		ORDER BY organization_id, inventory_item_id;

	l_lot_count NUMBER;
	l_upgrade_count NUMBER;
	l_context_code VARCHAR2(30);
	l_attribute_default inv_lot_sel_attr.lot_sel_attributes_tbl_type;
	l_null_attribute inv_lot_sel_attr.lot_sel_attributes_tbl_type;
	l_attribute_default_count NUMBER := 0;
	l_update_count NUMBER := 0;
	l_return_status VARCHAR2(10);
	l_msg_count NUMBER := 0;
	l_msg_data  VARCHAR2(2000);
	l_previous_item_id NUMBER := -1;
	l_previous_org_id NUMBER := -1;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
   	trace('Upgrading Lot numbers, org ='|| p_organization_id);
	END IF;

	l_lot_count := 0;
	l_upgrade_count := 0;
	x_return_status := fnd_api.g_ret_sts_success ;

	l_previous_item_id := -1;
	l_previous_org_id := -1;
	FOR v_lot IN c_lot(p_organization_id) LOOP
		--trace('In Lot loop, org, item, lot: '|| v_lot.organization_id
		--	||','||v_lot.inventory_item_id||','||v_lot.lot_number);

		-- Step 1. Get the context code for the lot
		--   we only need to run this for every org/item, not every lot
		IF((v_lot.inventory_item_id <> l_previous_item_id) OR
		   (v_lot.organization_id <> l_previous_org_id)) THEN
			INV_LOT_SEL_ATTR.GET_CONTEXT_CODE(
			   context_value => l_context_code
			,  org_id        => v_lot.organization_id
			,  item_id       => v_lot.inventory_item_id
			,  flex_name     => LOT_FLEX_NAME);
			l_previous_org_id := v_lot.organization_id;
			l_previous_item_id := v_lot.inventory_item_id;
		END IF;
		--trace('Got context code:' || l_context_code);
		IF l_context_code IS NOT NULL THEN
			l_lot_count := l_lot_count + 1;

			-- Step 2. Get the default attribute for this lot
			INV_LOT_SEL_ATTR.GET_DEFAULT(
			   x_attributes_default  => l_attribute_default
			,  x_attributes_default_count => l_attribute_default_count
			,  x_return_status       => l_return_status
			,  x_msg_count           => l_msg_count
			,  x_msg_data            => l_msg_data
			,  p_table_name          => LOT_TABLE_NAME
			,  p_attributes_name     => LOT_FLEX_NAME
			,  p_inventory_item_id   => v_lot.inventory_item_id
			,  p_organization_id     => v_lot.organization_id
			,  p_lot_serial_number   => v_lot.lot_number
			,  p_attributes          => l_null_attribute);
			--trace('Got default attributes, status, count '
			--	|| l_return_status || ',' || l_attribute_default_count);
			IF l_return_status <> 'S' THEN
				IF (l_debug = 1) THEN
   				trace('Error in getting default attr, can not upgrade lot '||v_lot.lot_number
				  || ',org:'||v_lot.organization_id||',item:'||v_lot.inventory_item_id);
				END IF;
			ELSE
				-- Step 3. Update lot with the default attribute
				UPDATE_LOT_SERIAL_ATTR(
					x_return_status     => l_return_status
				,	x_msg_count         => l_msg_count
				,  x_msg_data          => l_msg_data
				,  x_update_count      => l_update_count
				,  p_lot_serial_option => OPTION_LOT
				,  p_organization_id   => v_lot.organization_id
				,  p_inventory_item_id => v_lot.inventory_item_id
				,  p_lot_serial_number => v_lot.lot_number
				,	p_attribute_category  => l_context_code
				,  p_attributes        => l_attribute_default);
				--trace('Updated lot wtih attributes, status, count '
				--	|| l_return_status || ',' || l_update_count);
				IF l_return_status <> 'S' THEN
					IF (l_debug = 1) THEN
   					trace('Error in updating lot with default attributes, can not upgrade lot '
					||v_lot.lot_number|| ',org:'||v_lot.organization_id||',item:'||v_lot.inventory_item_id);
					END IF;
				ELSE
					IF (l_debug = 1) THEN
   					trace('Successfully updated lot:'||v_lot.lot_number
				     || ',org:'||v_lot.organization_id||',item:'||v_lot.inventory_item_id);
					END IF;
					l_upgrade_count := l_upgrade_count + 1;
				END IF; -- Step 3. update lot
			END IF; -- Step 2. get default attribute
		END IF; -- Step 1. get context code
	END LOOP;
	IF (l_debug = 1) THEN
   	trace('Upgraded ' || l_upgrade_count || ' lot numbers out of '
		|| l_lot_count || ' lot numbers found.');
	END IF;

EXCEPTION
	WHEN others THEN
		IF (l_debug = 1) THEN
   		trace('Error in UPGRADE_LOT ');
		END IF;
		x_return_status := fnd_api.g_ret_sts_error;
END UPGRADE_LOT;

/* Private API to upgrade the serial numbers*/
PROCEDURE UPGRADE_SERIAL(
	x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,	x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
,	x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,	x_upgrade_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,	p_organization_id     IN   NUMBER DEFAULT NULL
) IS
	CURSOR c_serial(p_org_id NUMBER) IS
		SELECT current_organization_id, inventory_item_id, serial_number
		FROM mtl_serial_numbers
		WHERE current_organization_id = nvl(p_org_id, current_organization_id)
		AND serial_attribute_category IS NULL
		AND current_status in (3,4,5)
		ORDER BY current_organization_id, inventory_item_id;

	l_serial_count NUMBER;
	l_upgrade_count NUMBER;
	l_context_code VARCHAR2(30);
	l_attribute_default inv_lot_sel_attr.lot_sel_attributes_tbl_type;
	l_null_attribute inv_lot_sel_attr.lot_sel_attributes_tbl_type;
	l_attribute_default_count NUMBER := 0;
	l_update_count NUMBER := 0;
	l_return_status VARCHAR2(10);
	l_msg_count NUMBER := 0;
	l_msg_data  VARCHAR2(2000);
	l_previous_item_id NUMBER := -1;
	l_previous_org_id NUMBER := -1;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	--trace('Upgrading Serial numbers, org, item='|| p_organization_id
	--	|| ',' || p_inventory_item_id);

	l_serial_count := 0;
	l_upgrade_count := 0;
	x_return_status := fnd_api.g_ret_sts_success ;

	l_previous_item_id := -1;
	l_previous_org_id := -1;
	FOR v_serial IN c_serial(p_organization_id) LOOP
		--trace('In Serial loop, org, item, serial: '|| v_serial.current_organization_id
		--	||','||v_serial.inventory_item_id||','||v_serial.serial_number);

		-- Step 1. Get the context code for the serial
		--   we only need to run this for every org/item, not every serial
		IF((v_serial.inventory_item_id <> l_previous_item_id) OR
		   (v_serial.current_organization_id <> l_previous_org_id)) THEN
			INV_LOT_SEL_ATTR.GET_CONTEXT_CODE(
			   context_value => l_context_code
			,  org_id        => v_serial.current_organization_id
			,  item_id       => v_serial.inventory_item_id
			,  flex_name     => SERIAL_FLEX_NAME);
			l_previous_item_id := v_serial.inventory_item_id;
			l_previous_org_id := v_serial.current_organization_id;
		END IF;
		--trace('Got context code:' || l_context_code);

		IF l_context_code IS NOT NULL THEN
			l_serial_count := l_serial_count + 1;
			-- Step 2. Get the default attribute for this serial
			INV_LOT_SEL_ATTR.GET_DEFAULT(
			   x_attributes_default  => l_attribute_default
			,  x_attributes_default_count => l_attribute_default_count
			,  x_return_status       => l_return_status
			,  x_msg_count           => l_msg_count
			,  x_msg_data            => l_msg_data
			,  p_table_name          => SERIAL_TABLE_NAME
			,  p_attributes_name     => SERIAL_FLEX_NAME
			,  p_inventory_item_id   => v_serial.inventory_item_id
			,  p_organization_id     => v_serial.current_organization_id
			,  p_lot_serial_number   => v_serial.serial_number
			,  p_attributes          => l_null_attribute);
			--trace('Got default attributes, status, count '
			--	|| l_return_status || ',' || l_attribute_default_count);
			IF l_return_status <> 'S' THEN
				IF (l_debug = 1) THEN
   				trace('Error in getting default attributes, can not upgrade serial '||v_serial.serial_number
				|| ',org:'||v_serial.current_organization_id||',item:'||v_serial.inventory_item_id);
				END IF;
			ELSE
				-- Step 3. Update serial with the default attribute
				UPDATE_LOT_SERIAL_ATTR(
					x_return_status     => l_return_status
				,	x_msg_count         => l_msg_count
				,  x_msg_data          => l_msg_data
				,  x_update_count      => l_update_count
				,  p_lot_serial_option => OPTION_SERIAL
				,  p_organization_id   => v_serial.current_organization_id
				,  p_inventory_item_id => v_serial.inventory_item_id
				,  p_lot_serial_number => v_serial.serial_number
				,	p_attribute_category  => l_context_code
				,  p_attributes        => l_attribute_default);
				--trace('Updated serial wtih attributes, status, count '
				--	|| l_return_status || ',' || l_update_count);
				IF l_return_status <> 'S' THEN
					IF (l_debug = 1) THEN
   					trace('Error in updating serial with default attributes, can not upgrade serial '
					  ||v_serial.serial_number|| ',org:'||v_serial.current_organization_id
					  ||',item:'||v_serial.inventory_item_id);
					END IF;
				ELSE
					IF (l_debug = 1) THEN
   					trace('Successfully updated serial:'||v_serial.serial_number
					  || ',org:'||v_serial.current_organization_id ||',item:'||v_serial.inventory_item_id);
					END IF;
					l_upgrade_count := l_upgrade_count + 1;
				END IF; -- Step 3. update serial
			END IF; -- Step 2. get default attribute
		END IF; -- Step 1. get context code
	END LOOP;
	IF (l_debug = 1) THEN
   	trace('Upgraded ' || l_upgrade_count || ' serial numbers out of '
		|| l_serial_count || ' serial numbers found.');
	END IF;

EXCEPTION
	WHEN others THEN
		IF (l_debug = 1) THEN
   		trace('Error in UPGRADE_SERIAL ');
		END IF;
		x_return_status := fnd_api.g_ret_sts_error;
END UPGRADE_SERIAL;

/**************************
 * Public API             *
 **************************/

/* Update lot/serial number with the given attribute record
   Input Parameter:
     p_lot_serial_option: specify update lot or serial
       possible value: OPTION_LOT(1), OPTION_SERIAL(2)*/
PROCEDURE UPDATE_LOT_SERIAL_ATTR(
	x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER
,  x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,  x_update_count      OUT NOCOPY /* file.sql.39 change */ NUMBER
,  p_lot_serial_option IN  NUMBER
,  p_organization_id   IN  NUMBER
,  p_inventory_item_id IN  NUMBER
,  p_lot_serial_number IN  VARCHAR2
,	p_attribute_category IN VARCHAR2
,  p_attributes        IN  inv_lot_sel_attr.lot_sel_attributes_tbl_type
)IS

	l_update_cur INTEGER;
	l_update_stmt  VARCHAR2(1000);
	i BINARY_INTEGER;
	l_rowupdated NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	--trace('In UPDATE_LOT_SERIAL, lot/ser option, org, item, lot/ser, p_attr_count ');
	--trace('   ' || p_lot_serial_option || ',' || p_organization_id
	--       ||','|| p_inventory_item_id || ',' || p_lot_serial_number
	--       ||','|| p_attributes.count);

	x_return_status := fnd_api.g_ret_sts_success ;

	-- Construct the update statement
	l_update_stmt := 'UPDATE ';
	IF p_lot_serial_option = OPTION_LOT THEN
		l_update_stmt := l_update_stmt || LOT_TABLE_NAME ||
		                 ' SET lot_attribute_category = :attr_category ';
	ELSE
		l_update_stmt := l_update_stmt || SERIAL_TABLE_NAME ||
		                 ' SET serial_attribute_category = :attr_category ';
	END IF;

	FOR i IN 1..p_attributes.count LOOP
		l_update_stmt := l_update_stmt || ' , ' || p_attributes(i).column_name || '=';

		IF p_attributes(i).column_type = 'NUMBER' THEN
			IF length(rtrim(p_attributes(i).column_value)) IS NULL THEN
				l_update_stmt := l_update_stmt || 'null';
			ELSE
				l_update_stmt := l_update_stmt || p_attributes(i).column_value;
			END IF;
		ELSIF p_attributes(i).column_type in ('VARCHAR2', 'DATE') THEN
			l_update_stmt := l_update_stmt || '''' || p_attributes(i).column_value|| '''';
		ELSE
			l_update_stmt := l_update_stmt || p_attributes(i).column_value;
		END IF;
	END LOOP;

	IF p_lot_serial_option = OPTION_LOT THEN
		l_update_stmt := l_update_stmt ||
			' WHERE organization_id=:org_id AND inventory_item_id=:item_id AND lot_number=:lot_serial';
	ELSE
		l_update_stmt := l_update_stmt ||
			' WHERE current_organization_id=:org_id AND inventory_item_id=:item_id AND serial_number=:lot_serial';
	END IF;

	-- Open dynamic SQL cursor
	l_update_cur := DBMS_SQL.OPEN_CURSOR;
	-- Parse statement
	DBMS_SQL.PARSE(l_update_cur, l_update_stmt, DBMS_SQL.v7);
	-- Bind variables
	DBMS_SQL.BIND_VARIABLE(l_update_cur, ':attr_category', p_attribute_category);
	DBMS_SQL.BIND_VARIABLE(l_update_cur, ':org_id', p_organization_id);
	DBMS_SQL.BIND_VARIABLE(l_update_cur, ':item_id', p_inventory_item_id);
	DBMS_SQL.BIND_VARIABLE(l_update_cur, ':lot_serial', p_lot_serial_number);
	-- Execute statement
	l_rowupdated := DBMS_SQL.EXECUTE(l_update_cur);

	IF l_rowupdated >= 1 THEN
		x_update_count := l_rowupdated;
	ELSE
		IF (l_debug = 1) THEN
   		trace(' No rows updated , error in update lot/serial ' ||p_lot_serial_number
			|| ',org:'||p_organization_id	||',item:'||p_inventory_item_id);
		END IF;
		RAISE fnd_api.g_exc_error;
	END IF;

	-- Close the cursor
	DBMS_SQL.CLOSE_CURSOR(l_update_cur);

EXCEPTION
	WHEN others THEN
		DBMS_SQL.CLOSE_CURSOR(l_update_cur);
		IF (l_debug = 1) THEN
   		trace('Error in update lot/serial '|| p_lot_serial_number
		 || ',org:'||p_organization_id	||',item:'||p_inventory_item_id);
		END IF;
		x_return_status := fnd_api.g_ret_sts_error;

END UPDATE_LOT_SERIAL_ATTR;

/* Upgrade procedure to be called by the concurrent program
    which follows the concurrent program API standard
   Input Parameter:
     p_organization_id: specify an organization or all orgs (if null)*/
PROCEDURE UPGRADE_LOT_SERIAL(
	x_retcode              OUT NOCOPY /* file.sql.39 change */  NUMBER
,	x_errbuf               OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,	p_organization_id      IN   NUMBER := NULL
)IS
	l_return_status VARCHAR2(100);
	l_msg_count     NUMBER;
	l_msg_data      VARCHAR2(2000);
	l_upgrade_count NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
   	trace('**** Upgrade Lot and Serial('||
	       to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')||') ****');
   	trace(' org_id='|| p_organization_id);
	END IF;

	x_retcode := 0;

	IF (l_debug = 1) THEN
   	trace('Upgrading Lot');
	END IF;
	UPGRADE_LOT(
		l_return_status
	,	l_msg_count
	,	l_msg_data
	,  l_upgrade_count
	,	p_organization_id);
	IF (l_debug = 1) THEN
   	trace('Upgraded Lot, return_status: '|| l_return_status);
	END IF;

	IF (l_debug = 1) THEN
   	trace('Upgrading Serial');
	END IF;
	UPGRADE_SERIAL(
		l_return_status
	,	l_msg_count
	,	l_msg_data
	,  l_upgrade_count
	,	p_organization_id);
	IF (l_debug = 1) THEN
   	trace('Upgraded Serial, return_status: '|| l_return_status);
   	trace('End of upgrade lot/serial');
	END IF;

EXCEPTION
	WHEN others THEN
		IF (l_debug = 1) THEN
   		trace('Error in upgrade_lot_serial');
		END IF;
		x_retcode := 2;

END UPGRADE_LOT_SERIAL;

END INV_LOT_SERIAL_UPGRADE;

/
