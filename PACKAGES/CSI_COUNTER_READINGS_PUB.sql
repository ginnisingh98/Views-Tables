--------------------------------------------------------
--  DDL for Package CSI_COUNTER_READINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_READINGS_PUB" AUTHID CURRENT_USER as
/* $Header: csipcrds.pls 120.1.12010000.1 2008/07/25 08:10:52 appldev ship $ */
/*#
 * This is a public API for managing Counter Readings.
 * It contains routines to Create and Update Counter Readings.
 * @rep:scope public
 * @rep:product CSI
 * @rep:displayname Manage Counter Readings
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSI_COUNTER
*/

/*----------------------------------------------------*/
/* procedure name: Capture_Counter_Reading            */
/* description :   procedure used to                  */
/*                 capture counter readings           */
/*----------------------------------------------------*/
/*#
 * This procedure is used to process the given Counter Reading. This reading could be
 * a regular counter Reading or an Adjustment or a Reset or an Automatic Rollover.
 * In this process, it also captures the property readings of the underlying properties of the
 * counter. It also computes Formula and Target counter Readings.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_txn_tbl Transaction Table structure
 * @param p_ctr_rdg_tbl Counter Reading Table containing the nature of the reading
 * @param p_ctr_prop_rdg_tbl Contains the corresponding  Propery Readings
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Capture Counter Reading
 */

PROCEDURE Capture_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_tbl               IN OUT NOCOPY csi_datastructures_pub.transaction_tbl
    ,p_ctr_rdg_tbl           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_tbl
    ,p_ctr_prop_rdg_tbl      IN OUT NOCOPY csi_ctr_datastructures_pub.ctr_property_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );

/*----------------------------------------------------*/
/* procedure name: Update_Counter_Reading             */
/* description :   procedure used to                  */
/*                 update counter readings            */
/*----------------------------------------------------*/
/*#
 * This procedure is used to disable the Counter Readings.
 * In this process, it re-computes the Later Net readings for the same counter.
 * Disabling a counter reading will have an impact on Formula and Target counter Readings.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_rdg_tbl Counter Reading Table containing the nature of the reading
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Reading
 */


PROCEDURE Update_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_rdg_tbl           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );
END CSI_COUNTER_READINGS_PUB;

/
