--------------------------------------------------------
--  DDL for Package CSI_COUNTER_READINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_READINGS_PVT" AUTHID CURRENT_USER as
/* $Header: csivcrds.pls 120.1.12010000.1 2008/07/25 08:15:27 appldev ship $ */

PROCEDURE Create_Reading_Transaction
   ( p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT     NOCOPY VARCHAR2
    ,x_msg_count             OUT     NOCOPY NUMBER
    ,x_msg_data              OUT     NOCOPY VARCHAR2
   );
--
/*----------------------------------------------------*/
/* procedure name: Capture_Counter_Reading            */
/* description :   procedure used to                  */
/*                 capture counter readings           */
/*----------------------------------------------------*/

PROCEDURE Capture_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );
--
/*----------------------------------------------------*/
/* procedure name: Compute_Formula_Counters           */
/* description :   procedure used to                  */
/*                 compute formula  counter readings  */
/*----------------------------------------------------*/

PROCEDURE Compute_Formula_Counters
   (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN     csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );
--
/*----------------------------------------------------*/
/* procedure name: Compute_Target_Counters            */
/* description :   procedure used to                  */
/*                 compute Target  counter readings   */
/*----------------------------------------------------*/

PROCEDURE Compute_Target_Counters
   (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN     csi_ctr_datastructures_pub.counter_readings_rec
    ,p_mode                  IN     VARCHAR2
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );
--
PROCEDURE Compute_Derive_Counters(
    P_Api_Version           IN   NUMBER,
    P_Init_Msg_List         IN   VARCHAR2,
    P_Commit                IN   VARCHAR2,
    p_validation_level      IN   NUMBER,
    p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    p_ctr_rdg_rec           IN   csi_ctr_datastructures_pub.counter_readings_rec,
    p_mode                  IN     VARCHAR2,
    X_Return_Status         OUT  NOCOPY VARCHAR2,
    X_Msg_Count             OUT  NOCOPY NUMBER,
    X_Msg_Data              OUT  NOCOPY VARCHAR2
    );
--
PROCEDURE Update_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_rdg_rec           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );
--
PROCEDURE Capture_Ctr_Property_Reading
   (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_prop_rdg_rec      IN OUT NOCOPY csi_ctr_datastructures_pub.ctr_property_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );
--
FUNCTION Est_daily_avg(
    p_start_date	IN DATE,
    p_start_reading	IN NUMBER,
    p_end_date		IN DATE,
    p_end_reading	IN NUMBER
   ) RETURN NUMBER;
--
PROCEDURE ESTIMATE_START_READINGS(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_default_value		 IN   NUMBER,
    p_calculation_start_date     IN   DATE,
    x_calc_start_reading         OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--
PROCEDURE EST_PERIOD_START_READINGS(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_default_value		 IN   NUMBER,
    p_avg_calculation_start_date  IN    DATE,
    p_calculation_start_date     IN   DATE,
    x_calc_start_reading         OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--
PROCEDURE ESTIMATE_USAGE(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_usage_markup		 IN   NUMBER,
    p_default_value		 IN   NUMBER,
    p_estimation_avg_type        IN   VARCHAR2,
    p_estimation_period_start_date IN DATE,
    p_estimation_period_end_date IN   DATE,
    p_avg_calculation_start_date  IN    DATE,
    p_number_of_readings         IN   NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--
PROCEDURE ESTIMATE_COUNTER_READING(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_estimation_period_start_date IN DATE,
    p_estimation_period_end_date IN   DATE,
    p_avg_calculation_start_date  IN    DATE,
    p_number_of_readings         IN   NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--
PROCEDURE ESTIMATE_FIXED_VALUES(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_fixed_value                IN   NUMBER,
    p_default_value              IN   NUMBER,
    p_estimation_period_start_date   IN   DATE,
    p_estimation_period_end_date     IN   DATE,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
  );
--
FUNCTION Transaction_ID_Exists
               (p_transaction_id IN NUMBER)
RETURN BOOLEAN;
--
FUNCTION get_reading_before_reset(p_counter_id NUMBER,
                                  p_value_timestamp DATE)
RETURN NUMBER;
--
FUNCTION get_previous_net_reading(p_counter_id NUMBER,
                                  p_value_timestamp DATE)
RETURN NUMBER;
--
FUNCTION get_latest_reading(p_counter_id NUMBER)
RETURN NUMBER;
--
END CSI_COUNTER_READINGS_PVT;

/
