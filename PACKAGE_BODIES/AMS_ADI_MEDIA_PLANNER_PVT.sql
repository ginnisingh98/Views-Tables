--------------------------------------------------------
--  DDL for Package Body AMS_ADI_MEDIA_PLANNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADI_MEDIA_PLANNER_PVT" AS
/* $Header: amsvwmpb.pls 120.3 2005/10/13 11:08:52 dmvincen noship $ */
-- ===============================================================
-- Package name
--    Web ADI Media Planner
--
-- Purpose
--
-- History
--    06-Jul-2005 dmvincen BUG4475733: Failing to create forumla metrics.
--    13-Jul-2005 dmvincen BUG4477880: Incorrect commits.
--    04-Oct-2005 dmvincen BUG4621065: Update error on import.
--    12-Oct-2005 dmvincen BUG4667183: Correcting rollbacks.
--
-- NOTE
--
-- ===============================================================

/* ############  Private TYPE Declarations ############### */
TYPE actmetrics_tab_t IS TABLE OF AMS_ActMetric_PVT.act_metric_rec_type
   INDEX BY BINARY_INTEGER;

/* ############  Global Variable Declarations ############### */
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_ADI_MEDIA_PLANNER_PVT';

/* #############   Forward Procedure Declarations ################ */
PROCEDURE resolve_metrics_from_rec (
   p_interface_rec IN ams_adi_media_planner%ROWTYPE,
   x_actmetric_table OUT NOCOPY actmetrics_tab_t
);

--   ==========================================================================
--   API Name
--       Load Metrics
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version
--       p_init_msg_list      Default FND_API.g_false; indicate whether to
--                            initialize the message buffer.
--       p_commit             Default FND_API.g_false; indicate whether to
--                            commit the transaction.
--       p_upload_batch_id    Batch ID used to identify the records belonging
--                            in the same upload batch.
--       p_object_type        Default 'CSCH'; the type of object the metrics
--                            are being loaded for.
--       p_object_name        Name of the object the metrics are being loaded
--                            for.  The name and parent_id are used to uniquely
--                            identify the record in the interface table
--                            associated with the object; the object ID is not
--                            in the interface table during import.
--       p_parent_type        The type of object of the parent of the object.
--       p_parent_id          The object ID of the parent object.  Used with
--                            object name to identify the record in the
--                            interface table associated with the object; the
--                            record in the interface table does not have the
--                            object ID during import.
--       p_object_id          Used with the metric API.
--       x_return_status      Status of the API execution.
--       x_msg_count          Number of messages in the message buffer.
--       x_msg_data           Contents of the message buffer.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--       Invoked from the import concurrent program after the object gets
--       created and the objet ID is available.
--
--       upload_batch_id is intended to be used to identify a unique set of
--       working records for the user's session.  Currently, there is an issue
--       with syncing a system (Web ADI) generated batch_id during upload to
--       multiple interfaces.
--
--   ==========================================================================
PROCEDURE load_metrics (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.g_false,
   p_commit          IN VARCHAR2 := FND_API.g_false,
   p_upload_batch_id IN NUMBER,
   p_object_type     IN VARCHAR2 := 'CSCH',
   p_object_name     IN VARCHAR2,
--   p_parent_type     IN VARCHAR2 := 'CAMP',
   p_parent_type     IN VARCHAR2,
   p_parent_id       IN NUMBER,
   p_object_id       IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'load_metrics';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_interface_rec      ams_adi_media_planner%ROWTYPE;
   l_err_recs AMS_ADI_COMMON_PVT.ams_adi_error_rec_t :=
           AMS_ADI_COMMON_PVT.ams_adi_error_rec_t();
BEGIN
   IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT FND_API.Compatible_API_Call(L_API_VERSION_NUMBER,
         p_api_version, l_API_NAME, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   BEGIN
      SELECT *
      INTO l_interface_rec
      FROM ams_adi_media_planner
      WHERE operation_type = 'IMPORT'
      AND object_type = p_object_type
      AND object_name = p_object_name
      AND parent_type = p_parent_type
      AND parent_id = p_parent_id;
   EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         x_return_status := FND_API.g_ret_sts_error;
         FND_MESSAGE.set_name ('AMS', 'AMS_CSCH_NOT_UNIQUE');
         FND_MSG_PUB.add;
         RETURN;
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.g_ret_sts_error;
         FND_MESSAGE.set_name ('AMS', 'AMS_CSCH_NOT_FOUND');
         FND_MSG_PUB.add;
         RETURN;
   END;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Public API: ' || l_api_name ||
               ': upload batch id : '||p_upload_batch_id||
               ', p_object_id : '||p_object_id);
   END IF;

   l_interface_rec.object_id := p_object_id;

   load_metrics (
      p_api_version        => 1.0,
      p_media_planner_rec  => l_interface_rec,
      p_err_recs           => l_err_recs,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
   );

   IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
      COMMIT;
   END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Public API: ' || l_api_name ||
             ': upload batch id : '||p_upload_batch_id||'.  Done load');
   END IF;

EXCEPTION
   WHEN fnd_api.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count, p_data => x_msg_data);

END;

--   ==========================================================================
--   API Name
--       Load Metrics
--
--   Parameters
--
--   IN
--       p_api_version
--       p_init_msg_list      Default FND_API.g_false; indicate whether to
--                            initialize the message buffer.
--       p_commit             Default FND_API.g_false; indicate whether to
--                            commit the transaction.
--       p_media_planner_rec  ###### description here #######
--       x_return_status      Status of the API execution.
--       x_msg_count          Number of messages in the message buffer.
--       x_msg_data           Contents of the message buffer.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--       Invoked from the concurrent program after the media planner record
--       is constructed from the interface table data.
--
--       Rely on the calling program to handle errors.
--
--   ==========================================================================
PROCEDURE load_metrics (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.g_false,
   p_commit          IN VARCHAR2 := FND_API.g_false,
   p_media_planner_rec  IN ams_adi_media_planner%ROWTYPE,
   p_err_recs        IN OUT NOCOPY AMS_ADI_COMMON_PVT.ams_adi_error_rec_t,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION_NUMBER       CONSTANT NUMBER := 1;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'LOAD_METRICS';
   l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(4000);
   l_table_of_metrics         actmetrics_tab_t;

   l_act_metric_rec           AMS_ActMetric_PVT.act_metric_rec_type;
   x_activity_metric_id       NUMBER;

   CURSOR c_met(p_metric_id IN NUMBER,
                p_arc_act_metric_used_by IN VARCHAR2,
                p_act_metric_used_by_id IN NUMBER) IS
      SELECT activity_metric_id, object_version_number
      FROM ams_act_metrics_all
      WHERE metric_id = p_metric_id
          AND act_metric_used_by_id = p_act_metric_used_by_id
          AND arc_act_metric_used_by = p_arc_act_metric_used_by
      ORDER BY activity_metric_id;

   CURSOR c_met_display(p_metric_id IN NUMBER) IS
      SELECT display_type FROM ams_metrics_all_b
      WHERE metric_id = p_metric_id;

   l_activity_metric_id       NUMBER;
   l_object_version_number    NUMBER;
   l_display_type             VARCHAR2(30);

BEGIN
   IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT FND_API.Compatible_API_Call(L_API_VERSION_NUMBER,
         p_api_version, L_API_NAME, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Private API : load_metrics object_name:'||
            p_media_planner_rec.object_name||
            ' operation_type : '||p_media_planner_rec.operation_type);
   END IF;

   resolve_metrics_from_rec (
      p_interface_rec      => p_media_planner_rec,
      x_actmetric_table    => l_table_of_metrics
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Private API : load_metrics '||
       'after resolve_metrics_from_rec table count '||l_table_of_metrics.COUNT);
   END IF;

	SAVEPOINT LOAD_METRICS_SP;

   -- If there are any metrics loop through the table to do the processing.
   IF l_table_of_metrics.COUNT > 0 THEN

      FOR i IN l_table_of_metrics.FIRST..l_table_of_metrics.LAST LOOP

        -- If the activity metric is already existing for the schedule,
        --  update should take place.
        IF p_media_planner_rec.operation_type = 'IMPORT' THEN
			  /*** BUG4621065: Reset values on each loop. ***/
			  l_activity_metric_id := null;
			  l_object_version_number := null;
           OPEN c_met(l_table_of_metrics(i).metric_id,
                    p_media_planner_rec.object_type,
                    p_media_planner_rec.object_id);
           FETCH c_met INTO l_activity_metric_id, l_object_version_number;
           CLOSE c_met;

            IF l_activity_metric_id IS NOT NULL AND
               l_object_version_number = 1 THEN
               l_table_of_metrics(i).activity_metric_id := l_activity_metric_id;
               l_table_of_metrics(i).object_version_number := 1;
            END IF;
        END IF;

         -- Set the currency code according to display type.
         -- Default the currency if not set.

         OPEN c_met_display(l_table_of_metrics(i).metric_id);
         FETCH c_met_display INTO l_display_type;
         CLOSE c_met_display;

         IF l_display_type = 'CURRENCY' THEN
            IF l_table_of_metrics(i).transaction_currency_code IS NULL THEN
               l_act_metric_rec.transaction_currency_code  :=
                       p_media_planner_rec.transaction_currency_code;
            ELSE
               l_act_metric_rec.transaction_currency_code :=
                       l_table_of_metrics(i).transaction_currency_code;
            END IF;
         ELSE
            l_act_metric_rec.transaction_currency_code := null;
         END IF;

         IF l_table_of_metrics(i).activity_metric_id IS NULL THEN
            -- invoke create metric API
            l_act_metric_rec.metric_id   := l_table_of_metrics(i).metric_id;

            IF l_table_of_metrics(i).trans_forecasted_value <>
                   Fnd_Api.G_MISS_NUM THEN
               l_act_metric_rec.trans_forecasted_value  :=
                   l_table_of_metrics(i).trans_forecasted_value;
            END IF;

            IF l_table_of_metrics(i).trans_actual_value <>
                   Fnd_Api.G_MISS_NUM THEN
               l_act_metric_rec.trans_actual_value  :=
                      l_table_of_metrics(i).trans_actual_value;
            END IF;

            IF l_table_of_metrics(i).func_forecasted_value <>
                   Fnd_Api.G_MISS_NUM THEN
               l_act_metric_rec.func_forecasted_value   :=
                      l_table_of_metrics(i).func_forecasted_value;
            END IF;

            IF l_table_of_metrics(i).forecasted_variable_value <>
                   Fnd_Api.G_MISS_NUM THEN
               l_act_metric_rec.forecasted_variable_value   :=
                      l_table_of_metrics(i).forecasted_variable_value;
            END IF;

            l_act_metric_rec.act_metric_used_by_id  :=
                     p_media_planner_rec.object_id;
            l_act_metric_rec.arc_act_metric_used_by :=
                     p_media_planner_rec.object_type;
            l_act_metric_rec.application_id := 530;
            x_activity_metric_id := NULL;

            AMS_ActMetric_PVT.Create_ActMetric (
                     p_api_version           => 1.0,
                     p_init_msg_list         => FND_API.G_FALSE,
                     p_commit                => FND_API.G_FALSE,
                     p_validation_level      => Fnd_Api.G_Valid_Level_Full,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
                     p_act_metric_rec        => l_act_metric_rec,
                     x_activity_metric_id    => x_activity_metric_id);

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API : load_metric '||
                  'Return Status Create_ActMetric: '||l_return_status);
            END IF;

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						 AMS_ADI_COMMON_PVT.handle_error_row(
							 p_write_conc_log => FND_API.G_TRUE,
							 p_rollback => FND_API.G_FALSE,
							 p_error_code => NULL,
							 p_error_message => NULL,
							 p_object_id => p_media_planner_rec.object_id,
							 p_object_name => NULL,
							 p_parent_object_id => NULL,
							 p_error_records => p_err_recs
						 );
						 x_return_status := l_return_status;
				END IF;

            --Reset the metric record
            l_act_metric_rec.metric_id   := NULL;
            l_act_metric_rec.transaction_currency_code  := NULL;
            l_act_metric_rec.trans_forecasted_value  := NULL;
            l_act_metric_rec.trans_actual_value  := NULL;
            l_act_metric_rec.func_forecasted_value   := NULL;
            l_act_metric_rec.forecasted_variable_value   := NULL;
            l_act_metric_rec.act_metric_used_by_id  := NULL;
            l_act_metric_rec.arc_act_metric_used_by := NULL;

         ELSE
            -- invoke update metric API
            Ams_Actmetric_Pvt.update_actmetric (
                  p_api_version                => 1.0,
                  p_init_msg_list              => FND_API.G_FALSE,
                  p_commit                     => FND_API.G_FALSE,
                  p_act_metric_rec             => l_table_of_metrics(i),
                  x_return_status              => l_return_status,
                  x_msg_count                  => l_msg_count,
                  x_msg_data                   => l_msg_data);

            -- Debug Message
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Private API : load_metric '||
                  ': Return Status update_actmetric '||l_return_status);
               AMS_UTILITY_PVT.debug_message('Private API : load_metric '||
                  ': activity_metric_id='||l_table_of_metrics(i).activity_metric_id);
               AMS_UTILITY_PVT.debug_message('Private API : load_metric '||
                  ': metric_id='||l_table_of_metrics(i).metric_id);
               AMS_UTILITY_PVT.debug_message('Private API : load_metric '||
                  ': OVN='||l_table_of_metrics(i).object_version_number);
            END IF;

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               AMS_ADI_COMMON_PVT.handle_error_row(
                  p_write_conc_log => FND_API.G_TRUE,
                  p_rollback => FND_API.G_FALSE,
                  p_error_code => NULL,
                  p_error_message => NULL,
                  p_object_id => p_media_planner_rec.object_id,
                  p_object_name => NULL,
                  p_parent_object_id => NULL,
                  p_error_records => p_err_recs
               );
					x_return_status := l_return_status;
            END IF;
         END IF;
      END LOOP;

   END IF; -- COUNT >0

	IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		AMS_ADI_COMMON_PVT.handle_success_row(p_commit);
	ELSE
		ROLLBACK TO LOAD_METRICS_SP;
	END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Private API :AMS_ADI_MEDIA_PLANNER_PVT.LOAD_METRICS. x_return_status = '||x_return_status);
   END IF;

EXCEPTION
   WHEN fnd_api.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count, p_data => x_msg_data);

END;

--   ==========================================================================
--   API Name
--       Load Request
--
--   Parameters
--
--   IN
--       errbuf               Error message buffer for a concurrent program.
--       retcode              Return code for a concurrent program.
--       p_upload_batch_id    Batch ID used to identify the records belonging
--                            in the same upload batch.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--      Conccurrent request entry point for processing Media Planner records.
--
--   ==========================================================================
PROCEDURE load_request (
   x_errbuf         OUT NOCOPY VARCHAR2,
   x_retcode        OUT NOCOPY NUMBER,
   p_upload_batch_id IN NUMBER
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'LOAD_REQUEST';
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);
   l_err_recs AMS_ADI_COMMON_PVT.ams_adi_error_rec_t :=
        AMS_ADI_COMMON_PVT.ams_adi_error_rec_t();

   CURSOR c_interface IS
      SELECT *
      FROM   ams_adi_media_planner
      WHERE upload_batch_id = p_upload_batch_id;

BEGIN
   x_retcode := 0;     -- 0 is normal end of execution

   -- due to a requirement to support 8i databases,
   -- using bulk collect may not be efficient because
   -- the number of columns fetched is great.  See the
   -- following for reference:
   --    http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:3561337894959

   -- <TO DO>: bulk load metrics from interface table
   -- bulk_interface_into_recs (l_interface_recs);

   --Call init method to initialize
   AMS_ADI_COMMON_PVT.init();

   FOR l_interface_recs IN c_interface LOOP
      load_metrics (
         p_api_version        => 1.0,
			p_commit             => FND_API.G_TRUE,
         p_media_planner_rec  => l_interface_recs,
         p_err_recs           => l_err_recs,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         -- Return error code should be success for the web adi to show the
         -- messages on the Sheet.
         -- retcode := 2;  -- error code is 2
         AMS_Utility_PVT.write_conc_log;
         -- reset message buffer after contents
         -- have been dumped into the log file
         FND_MSG_PUB.initialize;
      END IF;
   END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Public API: load_request upload '||
          'batch id : '||p_upload_batch_id||'.  Done load');
   END IF;

   AMS_ADI_COMMON_PVT.complete_batch(
       'AMS_ADI_MEDIA_PLANNER',
       p_upload_batch_id,
       FND_API.G_TRUE,
       FND_API.G_TRUE,
       l_err_recs
   );

   AMS_ADI_COMMON_PVT.complete_all(FND_API.G_TRUE,FND_API.G_TRUE,p_upload_batch_id);

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Public API: load_request retcode : '||x_retcode||' Done load');
   END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
      x_retcode := 1;
      RAISE;
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_retcode := 1;
      RAISE;
   WHEN OTHERS THEN
      x_errbuf := SQLERRM;
      AMS_UTILITY_PVT.Write_Conc_Log(l_API_NAME||'SQLERROR: '||x_errbuf);
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_EXC_MSG(G_PKG_NAME, L_API_NAME);
      END IF;
      x_retcode := 1;
      RAISE;

END;


--   ==========================================================================
--   API Name
--       Resolve Metrics From Record
--
--   Parameters
--
--   IN
--       p_interface_rec      Complete Record from media planner table.
--       x_actmetric_table    Activity metric records for update or insert.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--      Create an activity metric record for each metric found in media planner
--      interface.
--
--   ==========================================================================
PROCEDURE resolve_metrics_from_rec (
   p_interface_rec IN ams_adi_media_planner%ROWTYPE,
   x_actmetric_table OUT NOCOPY actmetrics_tab_t
)
IS
l_act_metric_rec   AMS_ActMetric_PVT.act_metric_rec_type;
BEGIN

   -- Clear the table.
   x_actmetric_table.delete;

   --Fixed Manual Metrics Start
   IF p_interface_rec.ACT_METRIC_ID_101 IS NOT NULL OR
        p_interface_rec.METRIC_ID_101 IS NOT NULL THEN

      -- Records in this list are for updating.  All fields are defaulted
      -- to G_MISS... values.
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := p_interface_rec.ACT_METRIC_ID_101;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_101;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_101;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_101;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_101;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_101;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_102 IS NOT NULL OR
        p_interface_rec.METRIC_ID_102 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := p_interface_rec.ACT_METRIC_ID_102;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_102;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_102;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_102;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_102;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_102;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_103 IS NOT NULL OR p_interface_rec.METRIC_ID_103 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_103;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_103;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_103;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_103;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_103;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_103;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_104 IS NOT NULL OR p_interface_rec.METRIC_ID_104 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_104;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_104;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_104;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_104;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_104;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_104;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_105 IS NOT NULL OR p_interface_rec.METRIC_ID_105 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_105;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_105;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_105;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_105;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_105;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_105;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_106 IS NOT NULL OR p_interface_rec.METRIC_ID_106 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_106;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_106;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_106;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_106;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_106;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_106;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_107 IS NOT NULL OR p_interface_rec.METRIC_ID_107 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_107;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_107;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_107;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_107;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_107;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_107;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_108 IS NOT NULL OR p_interface_rec.METRIC_ID_108 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_108;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_108;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_108;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_108;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_108;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_108;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_109 IS NOT NULL OR p_interface_rec.METRIC_ID_109 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_109;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_109;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_109;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_109;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_109;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_109;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_110 IS NOT NULL OR p_interface_rec.METRIC_ID_110 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_110;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_110;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_110;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_110;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_110;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_110;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;
   --Fixed Manual Metrics End

   --Variable Manual Metrics Start
   IF p_interface_rec.ACT_METRIC_ID_201 IS NOT NULL OR p_interface_rec.METRIC_ID_201 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_201;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_201;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_201;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_201;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_201;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_201;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_202 IS NOT NULL OR p_interface_rec.METRIC_ID_202 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_202;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_202;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_202;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_202;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_202;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_202;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_203 IS NOT NULL OR p_interface_rec.METRIC_ID_203 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_203;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_203;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_203;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_203;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_203;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_203;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_204 IS NOT NULL OR p_interface_rec.METRIC_ID_204 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_204;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_204;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_204;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_204;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_204;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_204;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_205 IS NOT NULL OR p_interface_rec.METRIC_ID_205 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_205;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_205;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_205;
      l_act_metric_rec.trans_actual_value := p_interface_rec.METRIC_ACTUAL_205;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_205;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_205;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   --Variable Manual Metrics End

   --Fixed  Functional Metrics Start Only Forecast Value can be manually updated for Functional Metrics
   IF p_interface_rec.ACT_METRIC_ID_301 IS NOT NULL OR p_interface_rec.METRIC_ID_301 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_301;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_301;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_301;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_301;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_301;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_302 IS NOT NULL OR p_interface_rec.METRIC_ID_302 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_302;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_302;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_302;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_302;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_302;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_303 IS NOT NULL OR p_interface_rec.METRIC_ID_303 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_303;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_303;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_303;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_303;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_303;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_304 IS NOT NULL OR p_interface_rec.METRIC_ID_304 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_304;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_304;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_304;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_304;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_304;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_305 IS NOT NULL OR p_interface_rec.METRIC_ID_305 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_305;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_305;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_305;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_305;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_305;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_306 IS NOT NULL OR p_interface_rec.METRIC_ID_306 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_306;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_306;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_306;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_306;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_306;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_307 IS NOT NULL OR p_interface_rec.METRIC_ID_307 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_307;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_307;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_307;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_307;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_307;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_308 IS NOT NULL OR p_interface_rec.METRIC_ID_308 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_308;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_308;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_308;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_308;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_308;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_309 IS NOT NULL OR p_interface_rec.METRIC_ID_309 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_309;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_309;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_309;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_309;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_309;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_310 IS NOT NULL OR p_interface_rec.METRIC_ID_310 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_310;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_310;
      l_act_metric_rec.trans_forecasted_value := p_interface_rec.METRIC_FORECAST_310;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_310;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_310;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;
   --Fixed  Functional Metrics End

   --Variable Functional Metrics Start
   --For variable functional metrics, the user can update the unit forecast value only and the actual value is calculated by the system.
   IF p_interface_rec.ACT_METRIC_ID_401 IS NOT NULL OR p_interface_rec.METRIC_ID_401 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_401;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_401;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_401;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_401;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_401;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_402 IS NOT NULL OR p_interface_rec.METRIC_ID_402 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_402;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_402;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_402;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_402;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_402;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_403 IS NOT NULL OR p_interface_rec.METRIC_ID_403 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_403;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_403;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_403;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_403;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_403;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_404 IS NOT NULL OR p_interface_rec.METRIC_ID_404 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_404;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_404;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_404;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_404;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_404;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.ACT_METRIC_ID_405 IS NOT NULL OR p_interface_rec.METRIC_ID_405 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id  := p_interface_rec.ACT_METRIC_ID_405;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_405;
      l_act_metric_rec.forecasted_variable_value := p_interface_rec.METRIC_FORECAST_UNIT_405;
      l_act_metric_rec.object_version_number := p_interface_rec.OBJECT_VERSION_NUMBER_405;
      l_act_metric_rec.transaction_currency_code := p_interface_rec.TRANS_CURRENCY_CODE_405;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;
   --Variable Functional Metrics End

   --formula metrics start
	-- BUG4475733: Set activity_metric_id to null for creation.
   IF p_interface_rec.METRIC_ID_501 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := NULL;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_501;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.METRIC_ID_502 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := NULL;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_502;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.METRIC_ID_503 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := NULL;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_503;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.METRIC_ID_504 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := NULL;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_504;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;

   IF p_interface_rec.METRIC_ID_505 IS NOT NULL THEN
      AMS_ActMetric_PVT.Init_ActMetric_Rec(l_act_metric_rec);
      l_act_metric_rec.activity_metric_id := NULL;
      l_act_metric_rec.metric_id  :=  p_interface_rec.METRIC_ID_505;
      x_actmetric_table(x_actmetric_table.COUNT) := l_act_metric_rec;
   END IF;
   --formula metrics end

END;

PROCEDURE purge_import_metrics(
   p_object_type IN VARCHAR2,
   p_object_name IN VARCHAR2,
   p_parent_type IN VARCHAR2,
   p_parent_id IN NUMBER
)
IS
BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Public API: purge_import_metrics'  ||
          p_object_type|| '::'|| p_object_name|| '::' ||
          p_parent_type ||'::'|| p_parent_id);
   END IF;

   --Clean up rows for import
   DELETE FROM ams_adi_media_planner
      WHERE operation_type = 'IMPORT'
      AND object_type = p_object_type
      AND object_name = p_object_name
      AND parent_type = p_parent_type
      AND parent_id = p_parent_id;

     -- COMMIT;

END;

END ams_adi_media_planner_pvt;

/
