--------------------------------------------------------
--  DDL for Package BOM_OE_EXPLODER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OE_EXPLODER_PKG" AUTHID CURRENT_USER as
/* $Header: BOMORXPS.pls 120.0 2005/05/25 02:30:33 appldev noship $ */
/*#
 * This API  contains methods for the custom bom exploder for use by Order Entry.
 * It creates a time independent 'OPTIONAL' or 'INCLUDED' or 'ALL' bom
 * for the given item in the BOM_EXPLOSIONS table.
 * @rep:scope public
 * @rep:product BOM
 * @rep:displayname Order Entry Exploder
 * @rep:compatibility S
 * @rep:lifecycle active
 */


/*#
 * This is the driving method for the Explosion
 * External applications requiring data from explosion table will first invoke
 * this procedure before selecting directly from the table.
 * @param arg_org_id organization_id
 * @param arg_starting_rev_date Starting Revision Date
 * @param arg_expl_type Exploder Type OPTIONAL or INCLUDED
 * @param arg_order_by The order by parameter 1-Operation Sequnece,Item Sequence
 *					      2-Item Sequence,Operation Sequence
 * @param arg_levels_to_explode Number of levels to explode
 * @param arg_item_id Item Id of assembly to explode
 * @param arg_comp_code Concatenated Component Code
 * @param arg_user_id User Id
 * @param arg_err_msg Error Message Out Buffer
 * @param arg_error_code Error code out.Returns sql error code
 * if sql error, 9999 if loop detected.
 * @param arg_alt_bom_desig Alternate Bom Designator
 * @rep:scope public
 * @rep:displayname Exploder
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE be_exploder (
	arg_org_id		IN  NUMBER,
	arg_starting_rev_date	IN  DATE,
	arg_expl_type		IN  VARCHAR2 DEFAULT 'OPTIONAL',
	arg_order_by		IN  NUMBER DEFAULT 1,
	arg_levels_to_explode 	IN  NUMBER DEFAULT 20,
	arg_item_id		IN  NUMBER,
	arg_comp_code           IN  VARCHAR2 DEFAULT '',
	arg_user_id		IN  NUMBER DEFAULT 0,
	arg_err_msg		OUT NOCOPY VARCHAR2,
	arg_error_code		OUT NOCOPY NUMBER,
        arg_alt_bom_desig       IN  VARCHAR2 DEFAULT NULL
);

/*#
 * This method will delete a BOM from BOM_CONFIG_EXPLOSION.It uses Session Id as an arguement to identify the BOM
 * an delete it.
 * @param arg_session_id Session Id
 * @rep:scope private
 * @rep:displayname Delete Configuration Explosion
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */

PROCEDURE delete_config_exp (
	arg_session_id		IN  NUMBER
);


END bom_oe_exploder_pkg;

 

/
