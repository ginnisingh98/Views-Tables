--------------------------------------------------------
--  DDL for Package CSI_CTR_EST_CTR_READING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_EST_CTR_READING_GRP" AUTHID CURRENT_USER AS
/* $Header: csigects.pls 120.0.12010000.1 2008/07/25 08:08:02 appldev ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_EST_CTR_READING_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csigects.pls';

--|---------------------------------------------------
--| procedure name: estimate_counter_reading
--| description :   procedure used to
--|                 estimate counter reading
--|---------------------------------------------------

PROCEDURE estimate_counter_reading
(
   P_Api_Version_Number           IN   NUMBER,
   P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_counter_id                   IN   NUMBER,
   p_estimation_period_start_date IN   DATE,
   p_estimation_period_end_date   IN   DATE,
   p_avg_calculation_start_date   IN   DATE,
   p_number_of_readings           IN   NUMBER,
   x_estimated_usage_qty          OUT  NOCOPY NUMBER,
   x_estimated_meter_reading      OUT  NOCOPY NUMBER,
   x_estimated_period_start_rdg   OUT  NOCOPY NUMBER,
   X_Return_Status                OUT  NOCOPY VARCHAR2,
   X_Msg_Count                    OUT  NOCOPY NUMBER,
   X_Msg_Data                     OUT  NOCOPY VARCHAR2
);

END CSI_CTR_EST_CTR_READING_GRP;

/
