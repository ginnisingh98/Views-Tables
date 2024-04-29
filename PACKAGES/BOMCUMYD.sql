--------------------------------------------------------
--  DDL for Package BOMCUMYD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMCUMYD" AUTHID CURRENT_USER AS
/* $Header: BOMCMYLS.pls 120.2 2006/01/03 22:27:22 bbpatel ship $ */
/*#
 * This API contains procedures to
 *   1. Calculate Cumulative Yield values for Network Routing for
 *      a. Single Item
 *      b. Range of Items
 *   2. Calculate Cumulative Yield and Times for Flow Routing for
 *      a. Single Item
 *      b. Range of Items
 *      c. All Items in the Organization
 *
 * @rep:scope public
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Cumulative Yield calculation for Flow and Network Routing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */

/*#
 * This procedure will Calculate Cumulative Yield values for Network routing for
 *   a) Single Item
 *   b) Range of Items
 *
 * @param ERRBUF IN OUT NOCOPY Error Message
 * @param RETCODE IN OUT NOCOPY Return Code. In case of error, Return Code = 2
 * @param Current_org_id IN Organization from where the concurrent program is launched
 * @param Scope IN 1 - Specific Routing; 2 - Range of Routings
 * @param Flag_Value IN Flag indicating whether item is ENG or BOM. This Value is set based on
 *                      profile value for BOM_OR_ENG.
 * @param Item_Id IN Item Id if the scope is Specific Routing
 * @param Operation_Type IN Process or Line Operation
 * @param Update_Events IN 1 - Yes; 2 - No
 * @param Item_low IN Start Item Id if the scope is Range of Routings
 * @param Item_high IN End Item Id if the scope is Range of Routings
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Cumulative Yield for Network Routing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Cumulative_Yield(
	ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	RETCODE                 IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	Current_org_id		IN	NUMBER,
	Scope			IN	NUMBER		DEFAULT 1,
	Flag_Value		IN	VARCHAR2,
	Item_Id			IN	NUMBER	,
	Operation_Type		IN	NUMBER          DEFAULT 1,
	Update_Events		IN	NUMBER          DEFAULT 1,
	Item_low		IN	VARCHAR2,
	Item_high		IN	VARCHAR2);

/*#
 * This is a procedure for Calculating Yield and Times for Flow Routings for
 *   a) A Specific Item
 *   b) Range of Items
 *   c) All Items in the Organization
 * Flow Routings are filtered by specifying:
 *   a) Line
 *   b) Operation Type
 *   c) Operation Name
 *   d) Event Name
 *
 * @param ERRBUF IN OUT NOCOPY Error Message
 * @param RETCODE IN OUT NOCOPY Return Code. In case of error, Return Code = 2
 * @param Current_org_id IN Organization from where the concurrent program is launched
 * @param Scope IN 1 - Specific Routing; 2 - Range of Routings
 * @param Flag_Value IN Flag indicating whether item is ENG or BOM. This Value is set based on
 *                      profile value for BOM_OR_ENG.
 * @param Item_Id IN Item Id if the scope is Specific Routing
 * @param Line_Id IN Line Id
 * @param Oper_Type IN Process, Line Operation or Event
 * @param Item_low IN Start Item Id if the scope is Range of Routings
 * @param Item_high IN End Item Id if the scope is Range of Routings
 * @param Operation_Name IN Operation Name
 * @param Event_Name IN Event Name
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Cumulative Yield and Times for Flow Routing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Flow_Batch_Calc(
	ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	RETCODE                 IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	Current_org_id		IN	NUMBER,
	Scope			IN	NUMBER		DEFAULT 1,
	Flag_Value		IN	VARCHAR2,
	Item_Id			IN	NUMBER,
        Line_Id                 IN      NUMBER,
	Oper_Type		IN	NUMBER		DEFAULT 3,
	Item_low		IN	VARCHAR2,
	Item_high		IN	VARCHAR2,
        Operation_Name          IN      VARCHAR2,
        Event_Name		IN	VARCHAR2);

END BOMCUMYD;

 

/
