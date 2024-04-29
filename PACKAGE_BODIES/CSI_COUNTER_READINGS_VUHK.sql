--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_READINGS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_READINGS_VUHK" as
/* $Header: csivhcrb.pls 120.0 2005/06/10 08:58 srramakr noship $ */

/*----------------------------------------------------*/
/* procedure name: Capture_Counter_Reading            */
/* description :   procedure used to                  */
/*                 capture counter readings           */
/*----------------------------------------------------*/

PROCEDURE Capture_Counter_Reading_Pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_tbl               IN     csi_datastructures_pub.transaction_tbl
    ,p_ctr_rdg_tbl           IN     csi_ctr_datastructures_pub.counter_readings_tbl
    ,p_ctr_prop_rdg_tbl      IN     csi_ctr_datastructures_pub.ctr_property_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Capture_Counter_Reading_Pre;

PROCEDURE Capture_Counter_Reading_Post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_tbl               IN     csi_datastructures_pub.transaction_tbl
    ,p_ctr_rdg_tbl           IN     csi_ctr_datastructures_pub.counter_readings_tbl
    ,p_ctr_prop_rdg_tbl      IN     csi_ctr_datastructures_pub.ctr_property_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Capture_Counter_Reading_Post;

/*----------------------------------------------------*/
/* procedure name: Update_Counter_Reading             */
/* description :   procedure used to                  */
/*                 update counter readings            */
/*----------------------------------------------------*/

PROCEDURE Update_Counter_Reading_Pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_rdg_tbl           IN     csi_ctr_datastructures_pub.counter_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Update_Counter_Reading_Pre;

PROCEDURE Update_Counter_Reading_Post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_rdg_tbl           IN     csi_ctr_datastructures_pub.counter_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Update_Counter_Reading_Post;

END CSI_COUNTER_READINGS_VUHK;

/
