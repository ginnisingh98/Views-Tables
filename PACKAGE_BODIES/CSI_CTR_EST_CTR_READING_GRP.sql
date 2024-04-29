--------------------------------------------------------
--  DDL for Package Body CSI_CTR_EST_CTR_READING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CTR_EST_CTR_READING_GRP" AS
/* $Header: csigectb.pls 120.0.12010000.2 2008/10/31 21:09:46 rsinn ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

--G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_EST_CTR_READING_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csigectb.pls';

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
   p_estimation_period_start_date IN	DATE,
   p_estimation_period_end_date   IN   DATE,
   p_avg_calculation_start_date   IN   DATE,
   p_number_of_readings           IN   NUMBER,
   x_estimated_usage_qty          OUT  NOCOPY NUMBER,
   x_estimated_meter_reading      OUT  NOCOPY NUMBER,
	x_estimated_period_start_rdg   OUT  NOCOPY NUMBER,
   X_Return_Status                OUT  NOCOPY VARCHAR2,
   X_Msg_Count                    OUT  NOCOPY NUMBER,
   X_Msg_Data                     OUT  NOCOPY VARCHAR2
) IS
   l_api_name           CONSTANT   VARCHAR2(30)   := 'ESTIMATE_COUNTER_READING';
   l_api_version_number CONSTANT   NUMBER         := 1.0;
   -- l_debug_level                   NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT ESTIMATE_COUNTER_READING;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'
   csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number ,
                                       p_api_version_number ,
                                       l_api_name ,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_COUNTER_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'estimate_counter_reading');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'estimate_counter_reading'   ||
					                         p_api_version_number    ||'-'||
					                         p_commit                ||'-'||
					                         p_init_msg_list         ||'-'||
					                         p_validation_level );
   END IF;

   -- call private API
   CSI_COUNTER_READINGS_PVT.ESTIMATE_COUNTER_READING(
      p_api_version                 => p_api_version_number,
      p_init_msg_list               => p_init_msg_list,
      p_commit                      => p_commit,
      p_validation_level            => p_validation_level,
      p_counter_id                  => p_counter_id,
      p_estimation_period_start_date => p_estimation_period_start_date,
      p_estimation_period_end_date  => p_estimation_period_end_date,
      p_avg_calculation_start_date  => p_avg_calculation_start_date,
      p_number_of_readings          => p_number_of_readings,
      x_estimated_usage_qty         => x_estimated_usage_qty,
      x_estimated_meter_reading     => x_estimated_meter_reading,
      x_estimated_period_start_rdg  => x_estimated_period_start_rdg,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      ROLLBACK TO ESTIMATE_COUNTER_READING;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- End of API Body.
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ESTIMATE_COUNTER_READING;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ESTIMATE_COUNTER_READING;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
   WHEN OTHERS THEN
      ROLLBACK TO  ESTIMATE_COUNTER_READING;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );

END estimate_counter_reading;

END CSI_CTR_EST_CTR_READING_GRP;

/
