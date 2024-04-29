--------------------------------------------------------
--  DDL for Package WMS_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: WMSFUTLS.pls 120.1.12010000.1 2008/07/28 18:34:04 appldev ship $ */


-- =====================================================
-- API name    : Get_log_dir
-- Type        : Private
-- Function    : Get path name defined from utl_file_dir
-- =====================================================
PROCEDURE get_log_dir(
   x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_log_dir             OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

-- ======================================================
-- API name    : file_debug
-- Type        : Private
-- Function    : Write message to logfile.
-- ======================================================
PROCEDURE file_debug(line IN VARCHAR2);


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
   x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

-- ===========================================
-- API name    : disabel_file_debug
-- Type        : Private
-- Function    : Close the logfile

-- ===========================================
PROCEDURE disable_file_debug;

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
RETURN NUMBER;

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
RETURN NUMBER;

END WMS_UTILITY_PVT;

/
