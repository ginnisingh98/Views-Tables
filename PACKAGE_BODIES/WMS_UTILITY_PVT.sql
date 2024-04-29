--------------------------------------------------------
--  DDL for Package Body WMS_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_UTILITY_PVT" as
-- $Header: WMSFUTLB.pls 120.1.12010000.2 2008/08/19 09:54:14 anviswan ship $
--

G_PKG_NAME    CONSTANT VARCHAR2(30):='WMS_UTILITY_PVT';

pg_file_name    VARCHAR2(100) := NULL;
pg_path_name    VARCHAR2(100) := NULL;
pg_fp           utl_file.file_type;

-- =====================================================
-- API name    : Get_log_dir
-- Type        : Private
-- Function    : Get path name defined from utl_file_dir
-- =====================================================
PROCEDURE get_log_dir(
   x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_log_dir             OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  Invalid_dir    EXCEPTION;
 l_write_dir    VARCHAR2(2000) := NULL;
 l_msg          VARCHAR2(2000);


  Cursor Get_FileDebugDir IS
   select rtrim(ltrim(value)) from v$parameter
   where upper(name) = 'UTL_FILE_DIR';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  open Get_FileDebugDir;
  fetch Get_FileDebugDir into l_write_dir;
  IF(l_write_dir IS NULL) THEN
      l_msg := 'Invalid directory defined in utl_file_dir';
      RAISE Invalid_dir;
   END IF;
   close Get_FileDebugDir;

   IF(instr(l_write_dir,',') > 0) THEN
      l_write_dir := substr(l_write_dir,1,instr(l_write_dir,',')-1);
   END IF;
   x_log_dir := l_write_dir;


  EXCEPTION
     WHEN Invalid_dir THEN

     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

END get_log_dir;

-- ======================================================
-- API name    : file_debug
-- Type        : Private
-- Function    : Write message to logfile.
-- ======================================================

PROCEDURE file_debug(line in varchar2) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  if (pg_file_name is not null) then

--     dbms_output.put_line('pg_file_name ' || pg_file_name);
     utl_file.put_line(pg_fp, line);
     utl_file.fflush(pg_fp);
  end if;
END file_debug;

-- ======================================================
-- API name    : enable_file_debug
-- Type        : Private
-- Function    : Open the logfile for writing log message.
-- ======================================================
PROCEDURE enable_file_debug(
   p_path_name            IN varchar2,
   p_file_name            IN varchar2,
   x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  if (pg_file_name is null) then
    pg_fp := utl_file.fopen(p_path_name, p_file_name, 'a',32767);
    pg_file_name := p_file_name;
    pg_path_name := p_path_name;
  end if;

EXCEPTION
   WHEN utl_file.invalid_path then
       x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );


   WHEN utl_file.invalid_mode then
      x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );


END enable_file_debug;

-- ===========================================
-- API name    : disabel_file_debug
-- Type        : Private
-- Function    : Close the logfile

-- ===========================================
PROCEDURE disable_file_debug is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  if (pg_file_name is not null) THEN
     utl_file.fclose(pg_fp);
  end if;
END disable_file_debug;

-- ===========================================
-- API name    : GET_CREATE_TRX_ID
-- Type        : Private
-- Function    : returns an approximate GET_CREATE_TRX_ID
--               for given item in an lpn
-- ===========================================
FUNCTION GET_CREATE_TRX_ID (
  p_inventory_item_id IN NUMBER
, p_revision IN VARCHAR2
, p_lot_number IN VARCHAR2
, p_cost_group_id IN NUMBER
, p_parent_lpn_id IN NUMBER )
RETURN NUMBER
IS
l_transaction_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

SELECT MIN(mmt.transaction_id)
INTO l_transaction_id
FROM MTL_MATERIAL_TRANSACTIONS mmt, MTL_TRANSACTION_LOT_NUMBERS mtln
WHERE  mmt.transaction_id = mtln.transaction_id (+)
AND mmt.INVENTORY_ITEM_ID = p_inventory_item_id
AND NVL(mmt.revision, '@') = NVL(p_revision, '@')
AND NVL(mtln.lot_number, '@') = NVL(p_lot_number, '@')
AND NVL(mmt.cost_group_id, -99) = NVL(p_cost_group_id, -99)
AND (mmt.CONTENT_LPN_ID = p_parent_lpn_id OR
     mmt.TRANSFER_LPN_ID = p_parent_lpn_id)
AND NOT (mmt.TRANSACTION_ACTION_ID = 50 AND mmt.CONTENT_LPN_ID IS NOT NULL)
AND mmt.TRANSACTION_ACTION_ID <> 51
AND mmt.TRANSACTION_QUANTITY > 0;

RETURN l_transaction_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RETURN NULL;
END GET_CREATE_TRX_ID;

-- ===========================================
-- API name    : GET_UPDATE_TRX_ID
-- Type        : Private
-- Function    : returns an approximate GET_UPDATE_TRX_ID
--               for given item in an lpn
-- ===========================================
FUNCTION GET_UPDATE_TRX_ID (
  p_inventory_item_id IN NUMBER
, p_revision IN VARCHAR2
, p_lot_number IN VARCHAR2
, p_cost_group_id IN NUMBER
, p_parent_lpn_id IN NUMBER )
RETURN NUMBER
IS
l_transaction_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

SELECT MAX(mmt.transaction_id)
INTO l_transaction_id
FROM MTL_MATERIAL_TRANSACTIONS mmt, MTL_TRANSACTION_LOT_NUMBERS mtln
WHERE  mmt.transaction_id = mtln.transaction_id (+)
AND mmt.INVENTORY_ITEM_ID = p_inventory_item_id
AND NVL(mmt.revision, '@') = NVL(p_revision, '@')
AND NVL(mtln.lot_number, '@') = NVL(p_lot_number, '@')
AND NVL(mmt.cost_group_id, -99) = NVL(p_cost_group_id, -99)
AND (mmt.LPN_ID = p_parent_lpn_id
     OR mmt.CONTENT_LPN_ID = p_parent_lpn_id
     OR mmt.TRANSFER_LPN_ID = p_parent_lpn_id)
AND NOT (mmt.TRANSACTION_ACTION_ID IN (50, 51) AND mmt.CONTENT_LPN_ID IS NOT NULL);

RETURN l_transaction_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RETURN NULL;
END GET_UPDATE_TRX_ID;

END WMS_UTILITY_PVT;

/
