--------------------------------------------------------
--  DDL for Package CSD_UPDATE_SHIP_PROGRAM_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_UPDATE_SHIP_PROGRAM_CUHK" AUTHID CURRENT_USER as
/* $Header: csdcshps.pls 120.0.12010000.3 2010/04/19 18:30:08 nnadig noship $ */
--
-- Package name     : CSD_UPDATE_SHIP_PROGRAM_CUHK
-- Purpose          : This package contains custom hooks for the update
--					  shipping concurrent program.
-- History          :


-- History          :
-- Version        Date       Name			Description
-- 12.0           08/24/08   takwong        Created.
--
-- NOTE             :
--

--    -----------------------------------------------------------------
--     procedure name: POST_UPDATE_PROD_TXN
--     description   : This custom user hooks procedure called inside of the
--					   CSD_UPDATE_PROGRAMS_PVT.SO_SHIP_UPDATE procedure.
--					   It is called after updating csd_product_transactions
--					   table and before call log activity to the csd history
--					   table.
--					   Please review procedure -
--                     CSD_UPDATE_PROGRAMS_PVT.SO_SHIP_UPDATE
--					   before use this custom user hooks.
--	   Parameters:     p_repair_line_id				repair line id
--                     p_product_transaction_id     product transaction id
--					   p_instance_id				instance id of item shipped.
--					   p_comms_nl_trackable_flag    comms_nl_trackable_flag is
--													column in the mtl_system_items table
--													for shipped item id.
--					   x_flag		  if the value return is = 0, the main program
--									  CSD_UPDATE_PROGRAMS_PVT.SO_SHIP_UPDATE will
--									  log activity to the csd history table, otherwise
--									  it will not log activity and next time the so_ship_update
--									  will process this shipped line again.
--
--					   p_action_code	Depot action code on the shipped prod trxn line.
--					   x_return_status	The return status, if it is SUCCESS, it
--										will return FND_API.G_RET_STS_SUCCESS
--					   x_msg_count		standard msg count return
--					   x_msg_data		standard msg data return
--   -----------------------------------------------------------------

    PROCEDURE POST_UPDATE_PROD_TXN
    (
		p_repair_line_id			IN				NUMBER,
		p_product_transaction_id	IN				NUMBER,
		p_instance_id				IN				NUMBER,
		p_comms_nl_trackable_flag	IN				VARCHAR2,
		p_action_code				IN				VARCHAR2,
		x_flag						OUT NOCOPY		NUMBER,
		x_return_status				OUT NOCOPY		VARCHAR2,
		x_msg_count					OUT NOCOPY		NUMBER,
		x_msg_data					OUT NOCOPY		VARCHAR2
    );

--
END CSD_UPDATE_SHIP_PROGRAM_CUHK;

/
