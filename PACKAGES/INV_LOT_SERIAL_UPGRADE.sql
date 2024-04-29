--------------------------------------------------------
--  DDL for Package INV_LOT_SERIAL_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_SERIAL_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: INVLSUGS.pls 120.1 2005/06/11 11:07:16 appldev  $ */

/* Global constant holding package name */
g_pkg_name CONSTANT VARCHAR2(50) := 'INV_LOT_SERIAL_UPGRADE' ;

/* Constant for the option of upgrade lot, or serial, or both */
OPTION_LOT    CONSTANT NUMBER := 1;
OPTION_SERIAL CONSTANT NUMBER := 2;
OPTION_ALL    CONSTANT NUMBER := 3;

/* Constant for lot/serial flexfield name and table name */
LOT_FLEX_NAME CONSTANT VARCHAR2(30) := 'Lot Attributes';
SERIAL_FLEX_NAME CONSTANT VARCHAR2(30) := 'Serial Attributes';
LOT_TABLE_NAME CONSTANT VARCHAR2(30) := 'MTL_LOT_NUMBERS';
SERIAL_TABLE_NAME CONSTANT VARCHAR2(30) := 'MTL_SERIAL_NUMBERS';

/**********************************************************
  Update lot/serial number with the given attribute record
   Input Parameter:
     p_lot_serial_option: specify update lot or serial
       possible value: OPTION_LOT(1), OPTION_SERIAL(2)
 **********************************************************/
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
,  p_attributes        IN  inv_lot_sel_attr.lot_sel_attributes_tbl_type);

/*****************************************************************
   Upgrade lot/serial API to be called by the concurrent program
    which follows the concurrent program API standard
   Input Parameter:
     p_organization_id: specify an organization or all orgs(if null)
*****************************************************************/
PROCEDURE UPGRADE_LOT_SERIAL(
	x_retcode              OUT NOCOPY /* file.sql.39 change */  NUMBER
,	x_errbuf               OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,	p_organization_id      IN   NUMBER := NULL);


END INV_LOT_SERIAL_UPGRADE;

 

/
