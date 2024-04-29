--------------------------------------------------------
--  DDL for Package Body AMS_DMSELECTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMSELECTION_PVT" AS
/* $Header: amsvdslb.pls 120.3 2006/07/17 12:03:37 kbasavar noship $ */
---------------------------------------------------------------
-- Note
--    Need to add handling of size constraints: min, max, random
--
-- History
-- 22-Feb-2001 choang   Created.
-- 23-Feb-2001 choang   Added schedule preview and aggregation.
-- 25-Feb-2001 choang   Fixed join condition for CSCH.
-- 03-Mar-2001 choang   Added implementation of min, max, nth
--                      row, and random selection options.
-- 05-Mar-2001 choang   1) decreased size of seed number for random
--                      num generator. 2) call purge procedure before
--                      and after main process. 3) fixed nth row by
--                      passing nth row instead of pct random. 4)
--                      used bind vars in populate_using_sql.
-- 06-Mar-2001 choang   Added workbook_owner_name so query uses
--                      index against ams_discoverer_sql.
-- 18-Apr-2001 choang   Added semicolon after exit for standards.
-- 22-Jul-2001 choang   Replaced select party_id from list_entries with
--                      select list_entry_source_system_id.
-- 31-Aug-2001 choang   Changed logic for getting responses.
-- 10-Oct-2001 choang   Changed logic for CSCH to use ams_act_lists
--                      to identify the schedule using a specific list.
-- 21-Nov-2001 choang   Fixed problem with using wrong arc qualifier
--                      when updating list select actions with preview
--                      results.
-- 26-Nov-2001 choang   arc qualifier needs to use both object used by
--                      and included object in preview.
-- 22-Jan-2002 choang   Fixed bug 2190920: target group filtered with
--                      enabled_flag.
-- 07-Jun-2002 choang   Modified to support data mining data sources.
-- 04-Jul-2002 choang   Fixed target value update in populate target
--                      staging and changed logic for loyalty indicator.
-- 14-Jul-2002 choang   Modified populate source to include total records
--                      and total positives (for models).
-- 01-Aug-2002 choang   - Fixed get where when checking for nulls.
--                      - Added perz filter logic
-- 08-Oct-2002 nyostos  Added get_target_positive_values to take
--                      care of multiple positive target values with
--                      comparison operators.
-- 18-Oct-2002 nyostos  Fixed a problem with get_where_clause for
--                      Scoring Runs with Alternative Data Sources
-- 21-Oct-2002 choang   Fixed problem updating total records and total
--                      positives.
-- 22-Oct-2002 nyostos  Added data checks in order to stop Model Build/
--                      Score Run if there is no data or if the data
--                      is invalid (e.g. no positive targets)
-- 27-Oct-2002 choang   Moved get_target_positive_values to spec
-- 06-Dec-2002 choang   Fixed get_where_clause comparison with null.
-- 19-Jun-2003 rosharma Bug # 3004453.
-- 18-Jul-2003 kbasavar Bug # 3004437.
-- 06-Aug-2003 kbasavar For Customer Profitability model.
-- 20-Aug-2003 rosharma Bug # 3102421.
-- 12-Sep-2003 kbasavar For Product Affinity.
-- 15-Sep-2003 nyostos  Changes for parallel mining operations using Global
--                      Temporary Tables.
-- 19-Sep-2003 rosharma Changes for Audience Data Sources Uptake
-- 22-Sep-2003 nyostos  Fixed GSCC Failure (line longer than 255 characters).
-- 19-Sep-2003 rosharma Changes to is_b2b_data_source
-- 31-Oct-2003 kbasavar Changes to populate_targets to handle B2B Customer
--                      Profitbility model for List data Source uptake
-- 02-Nov-2003 kbasavar Changed to use categories table instead of view
--                      for performance
-- 06-Nov-2003 rosharma Renamed ams_dm_org_contacts_stg to ams_dm_org_contacts
-- 21-Nov-2003 choang   bug 3275817 - changed to not exists and having clause
-- 27-Nov-2003 rosharma Fixed ambiguous column issue when cell or diwb is included in training data
-- 02-Dec-2003 rosharma Bug # 3290898
-- 09-Dec-2003 kbasavar Added is_org_prod_affn for Org Product Affinity Model
-- 23-Jan-2004 rosharma Bug # 3390720
-- 26-Jan-2004 choang   Fixed date format mask introduced in bug 3004453
-- 05-Feb-2004 rosharma Fixed bug # 3390720
-- 12-Feb-2004 rosharma Fixed bug # 3436093
-- 18-Feb-2004 rosharma Fixed bug # 3448905
-- 13-May-2004 rosharma Fixed bug # 3619647
-- 16-Jul-2004 rosharma Fixed bug # 3771444
-- 28-Jul-2004 rosharma Fixed bug # 3762677. Changed all instances of ams_list_entries.list_entry_source_system_id
--                      to ams_list_entries.party_id
-- 23-Dec-2004 kbasavar For bug 3935517Taken care of purging the underlying org. contacts
--                      table for Customer Profitability Score.
-- 03-Jan-2005 kbasavar Fixed appsperf bug # 4099354
-- 22-Feb-2005 srivikri Fixed bug # 4196941. handled the scenario for no where clause.
-- 17-Mar-2005 srivikri bug # 4196941. removed redundancy in get_where_clause and get_wb_filter
-------------------------------------------------------------
   G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_DMSelection_PVT';
   G_OBJECT_TYPE_MODEL  CONSTANT VARCHAR2(30) := 'MODL';
   G_OBJECT_TYPE_SCORE  CONSTANT VARCHAR2(30) := 'SCOR';
   G_ALTERNATIVE_DATA_SOURCE  CONSTANT VARCHAR2(30) := 'ADS';

   G_STATUS_BUILDING    CONSTANT VARCHAR2(30) := 'BUILDING';
   G_STATUS_SCORING     CONSTANT VARCHAR2(30) := 'SCORING';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

   ---- forward procedure declarations ----

   ---------------------------------------------------------------
   -- Purpose:
   --    Insert parties into ams_dm_target_stg_gt using
   --    different methods based on the data source
   --    type.
   -- Parameter:
   --
   ---------------------------------------------------------------
PROCEDURE populate_target_staging (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Purge records from the staging table for
   --    the specified object.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE purge_target_staging (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_arc_object      IN VARCHAR2,
      p_object_id       IN NUMBER,
      p_count        IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Update the selections with the summarized results
   --    for total selected and total targets.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE update_action_summary (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Calculate the target field value and update
   --    the staging table.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE populate_targets (
      p_model_id           IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Insert ams_dm_source with the parties and
   --    their respective target values, if the
   --    operation is model building.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE populate_source (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Insert into the staging table using SQL from
   --    a Discoverer workbook.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE populate_using_sql (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      p_discoverer_sql_id  IN NUMBER,  -- used to get workbook name and worksheet
      x_return_status   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Extract the customer field from a SQL statement
   --    formatted for use in list generation.  The customer
   --    field is associated to the source type of the SQL.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE get_customer_field (
      p_workbook_owner_name   IN VARCHAR2,
      p_workbook_name   IN VARCHAR2,
      p_worksheet_name  IN VARCHAR2,
      x_customer_field  OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Extract the from and where clause of a SQL
   --    statement.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE get_from_sql (
      p_workbook_owner_name   IN VARCHAR2,
      p_workbook_name   IN VARCHAR2,
      p_worksheet_name  IN VARCHAR2,
      x_from_sql        OUT NOCOPY VARCHAR2,
      x_found           OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Update ams_dm_source with the target value of the
   --    parties selected for model training.
   -- Parameter:
   --
   ---------------------------------------------------------------
   PROCEDURE update_source_target (
      p_object_type     IN VARCHAR2,
      p_object_id       IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Apply sizing options for the source selections.
   ---------------------------------------------------------------
   PROCEDURE apply_sizing_options (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Randomize records by returning a percent of the total
   --    records or the maximum records to return, whichever
   --    is smaller.
   -- Parameter:
   --    IN
   --    p_arc_object_for - the arc sys qualifier of the object using the
   --       source selections.
   --    p_object_for_id - the id of the object using the source selections.
   --    p_min_rows - the minimum number of records to populate in the
   --       source table for the datamining engine.
   --    p_max_rows - the maximum number of records to populate in the
   --       source table for the datamining engine.
   --    p_total_rows - the total number of rows available to be processed.
   --    p_pct_random - the percent of rows to return after randomization.
   --    OUT
   --    x_return_status - return status of the procedure.
   --
   ---------------------------------------------------------------
   PROCEDURE randomize_by_pct (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      p_min_rows        IN NUMBER,
      p_max_rows        IN NUMBER,
      p_total_rows      IN NUMBER,
      p_pct_random      IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Randomize records by returning every nth row of the original
   --    dataset up until the max number of rows.
   --
   -- Parameter:
   --    IN
   --    p_arc_object_for - the arc sys qualifier of the object using the
   --       source selections.
   --    p_object_for_id - the id of the object using the source selections.
   --    p_min_rows - the minimum number of records to populate in the
   --       source table for the datamining engine.
   --    p_max_rows - the maximum number of records to populate in the
   --       source table for the datamining engine.
   --    p_total_rows - the total number of rows available to be processed.
   --    p_every_nth_row - the nth row to select for populate of the
   --       source table.
   --    OUT
   --    x_return_status - return status of the procedure.
   --
   ---------------------------------------------------------------
   PROCEDURE randomize_nth_rows (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      p_min_rows        IN NUMBER,
      p_max_rows        IN NUMBER,
      p_total_rows      IN NUMBER,
      p_every_nth_row  IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Retrieve the selected fields for model building.
   --
   -- Parameter:
   --    p_select_object_type - ADS is for alternative data source
   --    p_select_object_id - if ADS, then data source ID
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    x_insert_fields
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_insert_fields (
      p_select_object_type IN VARCHAR2,
      p_select_object_id   IN NUMBER,
      p_workbook_owner     IN VARCHAR2,
      p_workbook_name      IN VARCHAR2,
      p_worksheet_name     IN VARCHAR2,
      x_insert_fields      OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2,
      x_pk_field           OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Get the listing of tables where the data selection
   --    is retrieved.
   --
   -- Parameter:
   --    p_select_object_type - ADS is for alternative data source
   --    p_select_object_id - if ADS, then data source ID
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    x_from_clause
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_from_clause (
      p_select_object_type IN VARCHAR2,
      p_select_object_id   IN NUMBER,
      p_workbook_owner     IN VARCHAR2,
      p_workbook_name      IN VARCHAR2,
      p_worksheet_name     IN VARCHAR2,
      p_is_b2b_custprof      IN BOOLEAN,
      x_from_clause        OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Get the filter for one selected data source.
   --
   -- Parameter:
   --    p_object_type
   --    p_object_id
   --    p_select_object_type
   --    p_select_object_id
   --    x_where_clause
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_where_clause (
      p_object_type        IN VARCHAR2,
      p_object_id          IN NUMBER,
      p_select_object_type IN VARCHAR2,
      p_select_object_id   IN NUMBER,
      p_workbook_owner     IN VARCHAR2,
      p_workbook_name      IN VARCHAR2,
      p_worksheet_name     IN VARCHAR2,
      p_is_b2b_custprof      IN BOOLEAN,
      x_where_clause       OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Get filter conditions based on saved filters
   --    using the personzliation framework.
   --
   -- Parameter:
   --    p_object_type
   --    p_object_id
   --    x_filter
   --    x_return_status      OUT VARCHAR2
   ---------------------------------------------------------------
   PROCEDURE get_perz_filter (
      p_object_type     IN VARCHAR2,
      p_object_id       IN NUMBER,
      p_data_source_id  IN NUMBER,
      x_filter          OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   -- Purpose:
   --    Get filter conditions as defined by a Discoverer
   --    worksheet.
   --
   -- NOTE
   --    Discoverer SQL statements could span across multiple
   --    ams_discoverer_sql records.  Must use combination of
   --    owner, workbook, and worksheet to query table for
   --    complete sql statement.
   --
   -- Parameter:
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    x_filter
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_wb_filter (
      p_workbook_owner  IN VARCHAR2,
      p_workbook_name   IN VARCHAR2,
      p_worksheet_name  IN VARCHAR2,
      x_filter          OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Determine whether a target is attached to
   --    a seeded DM data source
   --
   -- Parameter:
    --      p_target_id  IN NUMBER
    --      x_is_seeded  OUT BOOLEAN
   ---------------------------------------------------------------

   PROCEDURE is_target_attached_to_seeded (
          p_target_id     IN NUMBER,
          x_is_seeded     OUT NOCOPY BOOLEAN
       );

   ---------------------------------------------------------------
   -- Purpose:
   --    Check the status of selections to ensure that they are
   --    still valid. Only called for seeded models.
   --
   -- NOTE:
   --
   --
   -- Parameter:
   --    p_model_id
   --    p_model_type
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    p_select_object_type
   --    p_select_object_id
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE validate_selection_status (
         p_model_id                 IN NUMBER,
         p_model_type               IN VARCHAR2,
         p_workbook_owner           IN VARCHAR2,
         p_workbook_name            IN VARCHAR2,
         p_worksheet_name           IN VARCHAR2,
         p_select_object_type       IN VARCHAR2,
         p_select_object_id         IN NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   -- Purpose:
   --    Check the status of product selections for prod affn model to ensure that they are
   --    still valid. Only called for seeded models.
   --
   -- NOTE:
   --
   --
   -- Parameter:
   --    p_model_id
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE validate_product_selections (
         p_model_id IN NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
   );
   ---- procedure code -----

   ---------------------------------------------------------------
   -- History
   -- 15-Feb-2001 choang   Created.
   ---------------------------------------------------------------
   PROCEDURE Preview_Selections (
      p_arc_object      IN VARCHAR2,
      p_object_id       IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'Preview Selections';
      L_SEEDED_ID_THRESHOLD   CONSTANT NUMBER := 10000;

      CURSOR c_model (p_model_id IN NUMBER) IS
         SELECT target_id
         FROM   ams_dm_models_all_b
         WHERE  model_id = p_model_id
         ;

      CURSOR c_score (p_score_id IN NUMBER) IS
         SELECT model.target_id
         FROM   ams_dm_scores_all_b score, ams_dm_models_all_b model
         WHERE  score.score_id = p_score_id
         AND    model.model_id = score.model_id
         ;

      l_target_id     NUMBER;
      l_seeded_data_source BOOLEAN := FALSE;
      l_target_attached_to_seeded BOOLEAN := FALSE;
      l_msg_count          NUMBER;
      l_msg_data           VARCHAR2(2000);

      l_return_status   VARCHAR2(1);
      l_return_status_log   VARCHAR2(1);
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': Begin'
  );

      FND_MSG_PUB.initialize;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message ('OBJECT TYPE: ' || p_arc_object || ' OBJECT ID: ' || p_object_id);
      END IF;

      -- determine if the data source used is
      -- a seeded data source
      IF p_arc_object = 'MODL' THEN
         OPEN c_model(p_object_id);
         FETCH c_model INTO l_target_id;
         CLOSE c_model;
      ELSE
         OPEN c_score(p_object_id);
         FETCH c_score INTO l_target_id;
         CLOSE c_score;
      END IF;

      IF l_target_id < L_SEEDED_ID_THRESHOLD THEN
         l_seeded_data_source := TRUE;
      END IF;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': Before call to purge_target_staging '
  );

      -- Initialize staging tables
      -- If previous execution fails, the purge procedure
      -- doesn't get called, so the old data remains, which
      -- may cause some problems in processing.
      purge_target_staging (
         p_arc_object_for  => p_arc_object,
         p_object_for_id   => p_object_id,
         p_arc_object      => p_arc_object,
         p_object_id       => p_object_id,
         p_count        => 'INITIAL',
         x_return_status   => l_return_status
      );

       AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': After purge_target_staging  Status= ' || l_return_status
  );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- populate the staging table by going
      -- against all the different data sources.
      populate_target_staging (
         p_arc_object_for  => p_arc_object,
         p_object_for_id   => p_object_id,
         p_seeded_data_source => l_seeded_data_source,
         x_return_status   => l_return_status
      );

        AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': After populate_target_staging  Status= ' || l_return_status
  );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Only need to summarize the targeted column if
      -- process is model building -- target value is
      -- not needed when scoring.
      IF p_arc_object = G_OBJECT_TYPE_MODEL THEN

         AMS_Utility_PVT.create_log (
           x_return_status   => l_return_status_log,
           p_arc_log_used_by => p_arc_object,
           p_log_used_by_id  => p_object_id,
           p_msg_data        => L_API_NAME || ': MODL Going to call  populate_targets  '
         );

         is_target_attached_to_seeded (
          p_target_id     => l_target_id,
          x_is_seeded     => l_target_attached_to_seeded
    );
    IF l_seeded_data_source = FALSE AND l_target_attached_to_seeded = TRUE THEN
            AMS_DMExtract_pvt.ExtractMain (
                 p_api_version       => 1.0
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_true
               , x_return_status     => l_return_status
               , x_msg_count         => l_msg_count
               , x_msg_data          => l_msg_data
               , p_mode              => 'I'
               , p_model_id          => p_object_id
               , p_model_type        => p_arc_object
            );
         END IF;
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         populate_targets (
            p_model_id        => p_object_id,
            p_seeded_data_source => l_seeded_data_source,
            x_return_status   => l_return_status
         );

         AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': After populate_targets  Status= ' || l_return_status
  );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Update the list select actions table
      -- with the summarized data, specifically,
      -- the no_of_rows_used and no_of_rows_targeted.
      update_action_summary (
         p_arc_object_for  => p_arc_object,
         p_object_for_id   => p_object_id,
         p_seeded_data_source => l_seeded_data_source,
         x_return_status   => l_return_status
      );


          AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': After update_action_summary  Status= ' || l_return_status
  );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Insert into ams_dm_source a distinct set of parties
      -- with target values where applicable.  If a party has
      -- different target values, the positive takes precedence.
      populate_source (
         p_arc_object_for     => p_arc_object,
         p_object_for_id      => p_object_id,
         p_seeded_data_source => l_seeded_data_source,
         x_return_status      => l_return_status
      );
           AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status_log,
      p_arc_log_used_by => p_arc_object,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': After populate_source  Status= ' || l_return_status
  );


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- purge the data from all staging tables.
      purge_target_staging (
         p_arc_object_for  => p_arc_object,
         p_object_for_id   => p_object_id,
         p_arc_object      => p_arc_object,
         p_object_id       => p_object_id,
         p_count        => 'FINAL',
         x_return_status   => l_return_status
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END Preview_Selections;


   ---------------------------------------------------------------
   -- History
   -- 15-Feb-2001 choang   Created.
   ---------------------------------------------------------------
   PROCEDURE Aggregate_Selections (
      p_arc_object      IN VARCHAR2,
      p_object_id       IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'Aggregate Selections';
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Re-perform the preview selections to
      -- generate the source data set.  If user
      -- has removed some selections, we cannot
      -- currently detect that, so to be safe,
      -- call the process again.
      Preview_Selections (
         p_arc_object      => p_arc_object,
         p_object_id       => p_object_id,
         x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

/* - choang - 04-jun-2002 - callout replaced with logic in populate_source
                            and populate_targets
      update_source_target (
         p_object_type     => p_arc_object,
         p_object_id       => p_object_id,
         x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
*/
   EXCEPTION
/*
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
*/
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END Aggregate_Selections;


   --
   -- NOTE
   --    ams_dm_target_stg_gt used for calculating the summary of all the selected
   --    data sources.
   -- History
   -- 16-Feb-2001 choang   Created.
   -- 06-Jun-2002 choang   Alternative data source has different filter
   --                      conditions.
   PROCEDURE populate_target_staging (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME           CONSTANT VARCHAR2(30) := 'populate_target_staging';

      CURSOR c_objects (p_arc_object_for IN VARCHAR2, p_object_for_id IN NUMBER) IS
         SELECT arc_incl_object_from,
                incl_object_id
         FROM   ams_list_select_actions
         WHERE  arc_action_used_by = p_arc_object_for
         AND    action_used_by_id = p_object_for_id
         ;
      l_object_rec      c_objects%ROWTYPE;

      CURSOR c_workbook (p_discoverer_sql_id IN NUMBER) IS
         SELECT workbook_name,
                worksheet_name,
                workbook_owner_name
         FROM   ams_discoverer_sql
         WHERE  discoverer_sql_id = p_discoverer_sql_id
         ;
      l_workbook_rec       c_workbook%ROWTYPE;

      CURSOR c_model (p_model_id IN NUMBER) IS
         SELECT target.data_source_id , target.target_id
         FROM   ams_dm_models_all_b model, ams_dm_targets_b target
         WHERE  model.model_id = p_model_id
         AND    target.target_id = model.target_id
         ;

      CURSOR c_score (p_score_id IN NUMBER) IS
         SELECT target.data_source_id , target.target_id
         FROM   ams_dm_scores_all_b score, ams_dm_models_all_b model, ams_dm_targets_b target
         WHERE  score.score_id = p_score_id
         AND    model.model_id = score.model_id
         AND    target.target_id = model.target_id
         ;

      CURSOR c_model_type(p_model_id IN NUMBER) is
         SELECT model_type
         FROM ams_dm_models_vl
         WHERE model_id=p_model_id
         ;

      CURSOR c_model_type_scor(p_scor_id IN NUMBER) is
         SELECT model_id, model_type
         FROM ams_dm_models_vl
         WHERE model_id=(select model_id from ams_dm_scores_vl where score_id=p_scor_id)
         ;

      l_data_source_id     NUMBER;
      l_target_id          NUMBER;
      l_seeded_data_source BOOLEAN := FALSE;

      l_insert_clause      VARCHAR2(16000);
      l_insert_fields      VARCHAR2(16000);
      l_from_clause        VARCHAR2(4000);
      l_where_clause       VARCHAR2(32767);

      l_sql_statement      VARCHAR2(32767);

      l_model_id           NUMBER;
      l_model_type         VARCHAR2(30);
      l_is_b2b             BOOLEAN;
      l_pk_field           VARCHAR2(200);
      l_insert_string      VARCHAR2(32000);
      l_is_b2b_custprof    BOOLEAN := FALSE;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_model_id:=p_object_for_id;

      IF p_arc_object_for = 'MODL' THEN
         OPEN c_model_type(p_object_for_id);
         FETCH c_model_type INTO l_model_type;
         CLOSE c_model_type;
      ELSE
         OPEN c_model_type_scor(p_object_for_id);
         FETCH c_model_type_scor INTO l_model_id,l_model_type;
         CLOSE c_model_type_scor;
      END IF;

      is_b2b_data_source(
          p_model_id => l_model_id,
          x_is_b2b     => l_is_b2b
      );


          -- nyostos - Sep 15, 2003 - Use Global Temporart Table
          --l_insert_clause := 'INSERT INTO ams_dm_target_stg (arc_object_used_by, ';
          l_insert_clause := 'INSERT INTO ams_dm_target_stg_gt (arc_object_used_by, ';
          l_insert_clause := l_insert_clause || 'object_used_by_id, arc_object, ';
          l_insert_clause := l_insert_clause || 'object_id, party_id) SELECT ';

      IF p_seeded_data_source THEN

         IF l_is_b2b AND l_model_type='CUSTOMER_PROFITABILITY' THEN
             -- nyostos - Sep 15, 2003 - Use Global Temporart Table
             -- l_insert_clause := 'INSERT INTO ams_dm_org_contacts_stg (arc_object_used_by, ';
             -- l_insert_clause := 'INSERT INTO ams_dm_orgcont_stg_gt (arc_object_used_by, ';
             l_insert_clause := 'INSERT INTO ams_dm_org_contacts (arc_object_used_by, ';
             l_insert_clause := l_insert_clause || 'object_used_by_id, arc_object, ';
             l_insert_clause := l_insert_clause || 'object_id, party_id, org_party_id) SELECT ';
             l_is_b2b_custprof := TRUE;
         END IF;


         IF l_model_type='PRODUCT_AFFINITY' THEN
            validate_product_selections (
               p_model_id           => l_model_id,
               x_return_status      => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
	 END IF;
    -- process all the source selections
         FOR l_object_rec IN c_objects (p_arc_object_for, p_object_for_id) LOOP
            -- get_wb_filter relies on l_workbook_owner to identify if
            -- filters are returned based on workbook (non-seeded data sources)
            l_workbook_rec.workbook_owner_name := NULL;
            l_workbook_rec.workbook_name := NULL;
            l_workbook_rec.worksheet_name := NULL;
            IF l_object_rec.arc_incl_object_from = 'DIWB' THEN
               OPEN c_workbook (l_object_rec.incl_object_id);
               FETCH c_workbook INTO l_workbook_rec;
               CLOSE c_workbook;
            END IF;

            validate_selection_status (
               p_model_id           => l_model_id,
               p_model_type         => l_model_type,
               p_workbook_owner     => l_workbook_rec.workbook_owner_name,
               p_workbook_name      => l_workbook_rec.workbook_name,
               p_worksheet_name     => l_workbook_rec.worksheet_name,
	       p_select_object_type => l_object_rec.arc_incl_object_from,
               p_select_object_id   => l_object_rec.incl_object_id,
               x_return_status      => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

	    get_insert_fields (
               p_select_object_type => l_object_rec.arc_incl_object_from,
               p_select_object_id   => l_object_rec.incl_object_id,
               p_workbook_owner     => l_workbook_rec.workbook_owner_name,
               p_workbook_name      => l_workbook_rec.workbook_name,
               p_worksheet_name     => l_workbook_rec.worksheet_name,
               x_insert_fields      => l_insert_fields,
               x_return_status      => x_return_status,
               x_pk_field      => l_pk_field
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            get_from_clause (
               p_select_object_type => l_object_rec.arc_incl_object_from,
               p_select_object_id   => l_object_rec.incl_object_id,
               p_workbook_owner     => l_workbook_rec.workbook_owner_name,
               p_workbook_name      => l_workbook_rec.workbook_name,
               p_worksheet_name     => l_workbook_rec.worksheet_name,
               p_is_b2b_custprof      => l_is_b2b_custprof,
               x_from_clause        => l_from_clause,
               x_return_status      => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            get_where_clause (
               p_object_type        => p_arc_object_for,
               p_object_id          => p_object_for_id,
               p_select_object_type => l_object_rec.arc_incl_object_from,
               p_select_object_id   => l_object_rec.incl_object_id,
               p_workbook_owner     => l_workbook_rec.workbook_owner_name,
               p_workbook_name      => l_workbook_rec.workbook_name,
               p_worksheet_name     => l_workbook_rec.worksheet_name,
               p_is_b2b_custprof      => l_is_b2b_custprof,
               x_where_clause       => l_where_clause,
               x_return_status      => x_return_status
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       -- kbasavar For Customer Profitability
            IF l_is_b2b AND l_model_type='CUSTOMER_PROFITABILITY' THEN
               l_insert_fields := l_insert_fields || ', hpr.object_id ';
               l_from_clause :=l_from_clause || ',hz_relationships hpr';
               IF l_where_clause IS NOT NULL THEN
                  l_where_clause :=l_where_clause || ' AND hpr.party_id='|| l_pk_field;
               ELSE
                  l_where_clause :=' hpr.party_id='|| l_pk_field;
               END IF;
                  l_where_clause := l_where_clause || ' AND hpr.directional_flag=''F'' AND hpr.subject_table_name = ''HZ_PARTIES''';
                  l_where_clause := l_where_clause || ' AND  hpr.object_table_name = ''HZ_PARTIES''  AND  hpr.directional_flag = ''F''';
                  l_where_clause := l_where_clause || ' AND  hpr.relationship_code IN          (''CONTACT_OF'' ,   ''EMPLOYEE_OF'')';
            END IF;

            l_sql_statement := l_insert_clause || l_insert_fields ||
                     ' FROM ' || l_from_clause;
            IF l_where_clause IS NOT NULL THEN
               l_sql_statement := l_sql_statement || ' WHERE ' || l_where_clause;
            END IF;

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (substr(L_API_NAME || ' - SQL [' || l_object_rec.arc_incl_object_from || ', ' || l_object_rec.incl_object_id || ']: ' || l_sql_statement,1,4000));
            END IF;

            IF l_object_rec.arc_incl_object_from <> 'DIWB' THEN
               EXECUTE IMMEDIATE l_sql_statement
               USING p_arc_object_for, p_object_for_id, l_object_rec.arc_incl_object_from,
                     l_object_rec.incl_object_id, l_object_rec.incl_object_id;
            ELSE
               EXECUTE IMMEDIATE l_sql_statement
               USING p_arc_object_for, p_object_for_id, l_object_rec.arc_incl_object_from,
                     l_object_rec.incl_object_id;
            END IF;
         END LOOP;   -- for cursor

    IF l_is_b2b AND l_model_type='CUSTOMER_PROFITABILITY' THEN
--        l_insert_string := 'INSERT INTO ams_dm_target_stg_gt(arc_object_used_by,object_used_by_id,arc_object,object_id,party_id) ';
--        l_insert_string := l_insert_string || 'SELECT arc_object_used_by,object_used_by_id,arc_object,object_id,org_party_id  ';
--        l_insert_string := l_insert_string || 'FROM ams_dm_orgcont_stg_gt ';
--        l_insert_string := l_insert_string || 'GROUP BY arc_object_used_by,object_used_by_id,arc_object,object_id,org_party_id ';
             EXECUTE IMMEDIATE 'INSERT INTO ams_dm_target_stg_gt(arc_object_used_by,object_used_by_id,arc_object,object_id,party_id)
        SELECT arc_object_used_by,object_used_by_id,arc_object,object_id,org_party_id
        FROM ams_dm_org_contacts  GROUP BY arc_object_used_by,object_used_by_id,arc_object,object_id,org_party_id';
    END IF;

      ELSE  -- alternative data source
         IF p_arc_object_for = 'MODL' THEN
            OPEN c_model(p_object_for_id);
            FETCH c_model INTO l_data_source_id , l_target_id;
            CLOSE c_model;
         ELSE
            OPEN c_score(p_object_for_id);
            FETCH c_score INTO l_data_source_id , l_target_id;
            CLOSE c_score;
         END IF;

         get_insert_fields (
            p_select_object_type => G_ALTERNATIVE_DATA_SOURCE,
            p_select_object_id   => l_data_source_id,
            p_workbook_owner     => l_workbook_rec.workbook_owner_name,
            p_workbook_name      => l_workbook_rec.workbook_name,
            p_worksheet_name     => l_workbook_rec.worksheet_name,
            x_insert_fields      => l_insert_fields,
            x_return_status      => x_return_status,
            x_pk_field      => l_pk_field
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         get_from_clause (
            p_select_object_type => G_ALTERNATIVE_DATA_SOURCE,
            p_select_object_id   => l_target_id,
            p_workbook_owner     => l_workbook_rec.workbook_owner_name,
            p_workbook_name      => l_workbook_rec.workbook_name,
            p_worksheet_name     => l_workbook_rec.worksheet_name,
            p_is_b2b_custprof      => l_is_b2b_custprof,
            x_from_clause        => l_from_clause,
            x_return_status      => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- discoverer workbook can be used as a filter
         OPEN c_objects (p_arc_object_for, p_object_for_id);
         FETCH c_objects INTO l_object_rec;
         IF c_objects%ROWCOUNT = 1 THEN
            l_workbook_rec.workbook_owner_name := NULL;
            l_workbook_rec.workbook_name := NULL;
            l_workbook_rec.worksheet_name := NULL;
            IF l_object_rec.arc_incl_object_from = 'DIWB' THEN
               OPEN c_workbook (l_object_rec.incl_object_id);
               FETCH c_workbook INTO l_workbook_rec;
               CLOSE c_workbook;
            END IF;
         END IF;
         CLOSE c_objects;

         get_where_clause (
            p_object_type        => p_arc_object_for,
            p_object_id          => p_object_for_id,
            p_select_object_type => G_ALTERNATIVE_DATA_SOURCE,
            p_select_object_id   => l_data_source_id,
            p_workbook_owner     => l_workbook_rec.workbook_owner_name,
            p_workbook_name      => l_workbook_rec.workbook_name,
            p_worksheet_name     => l_workbook_rec.worksheet_name,
            p_is_b2b_custprof      => l_is_b2b_custprof,
            x_where_clause       => l_where_clause,
            x_return_status      => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_sql_statement := l_insert_clause || l_insert_fields ||
                  ' FROM ' || l_from_clause;
         IF l_where_clause IS NOT NULL THEN
            l_sql_statement := l_sql_statement || ' WHERE ' || l_where_clause;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' - SQL: ' || l_sql_statement);
         END IF;

         EXECUTE IMMEDIATE l_sql_statement
         USING p_arc_object_for, p_object_for_id, G_ALTERNATIVE_DATA_SOURCE, l_data_source_id;
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END populate_target_staging;


   --
   -- History
   -- 16-Feb-2001 choang   Created.
   PROCEDURE populate_using_sql (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      p_discoverer_sql_id  IN NUMBER,  -- used to get workbook name and worksheet
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME           CONSTANT VARCHAR2(30) := 'Populate Using SQL';

      l_workbook_owner_name   VARCHAR2(100);
      l_workbook_name      VARCHAR2(254);
      l_worksheet_name     VARCHAR2(254);
      l_source_pk_field    VARCHAR2(61);

      -- variable used to capture the from and
      -- where clause of the sql statement.
      l_from_and_where     VARCHAR2(32000);
      l_found              VARCHAR2(1);

      -- dynamic sql handler
      l_cursor             INTEGER;

      CURSOR c_workbook (p_discoverer_sql_id IN NUMBER) IS
         SELECT workbook_name,
                worksheet_name,
                workbook_owner_name
         FROM   ams_discoverer_sql
         WHERE  discoverer_sql_id = p_discoverer_sql_id
         ;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_workbook (p_discoverer_sql_id);
      FETCH c_workbook INTO l_workbook_name, l_worksheet_name, l_workbook_owner_name;
      CLOSE c_workbook;

      get_customer_field (
         p_workbook_owner_name   => l_workbook_owner_name,
         p_workbook_name   => l_workbook_name,
         p_worksheet_name  => l_worksheet_name,
         x_customer_field  => l_source_pk_field,
         x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      get_from_sql (
         p_workbook_owner_name   => l_workbook_owner_name,
         p_workbook_name   => l_workbook_name,
         p_worksheet_name  => l_worksheet_name,
         x_from_sql        => l_from_and_where,
         x_found           => l_found,
         x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ': ' || l_from_and_where);
      END IF;

      -- construct the entire sql statement
      -- which selects the source_pk_field
      -- from the from_and_where
      -- Note: SQL must not exceed 32K.  Shouldn't
      --       have that problem because we are only
      --       using the from and where clauses of
      --       the SQL from ams_discoverer_sql.
      EXECUTE IMMEDIATE
--         'INSERT INTO ams_dm_target_stg ' ||
         'INSERT INTO ams_dm_target_stg_gt ' ||
         '(arc_object_used_by, object_used_by_id, arc_object, object_id, party_id) ' ||
         'SELECT :arc_object' || ', :object_id' || ', :disco_wb, :disco_id' || ', ' || l_source_pk_field ||
         ' ' || l_from_and_where
      USING p_arc_object_for, p_object_for_id, 'DIWB', p_discoverer_sql_id;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END populate_using_sql;


   --
   -- NOTE
   --    use truncate to avoid fragmentation in db tablespace.
   --
   -- History
   -- 16-Feb-2001 choang   Created.
   -- 06-Jun-2002 choang   Use truncate for performance
  PROCEDURE  purge_target_staging (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_arc_object      IN VARCHAR2,
      p_object_id       IN NUMBER,
      p_count      IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS

      CURSOR c_model_type(p_model_id IN NUMBER) is
         SELECT model_type
         FROM ams_dm_models_vl
         WHERE model_id=p_model_id
         ;

      CURSOR c_model_id (p_score_id IN NUMBER) IS
         SELECT model_id
         FROM   ams_dm_scores_all_b
         WHERE  score_id = p_score_id
      ;

      L_API_NAME        CONSTANT VARCHAR2(30) := 'Purge Target Staging';
      l_result          BOOLEAN;
      l_status          VARCHAR2(10);
      l_industry        VARCHAR2(10);
      l_ams_schema      VARCHAR2(30);

      l_model_id    NUMBER;

      l_model_type    VARCHAR2(30);
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_result := fnd_installation.get_app_info(
                     'AMS',
                     l_status,
                     l_industry,
                     l_ams_schema
                  );

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ': ' || p_arc_object_for || ':  '||p_object_for_id || ':   '|| p_count);
      END IF;

     if p_arc_object_for = G_OBJECT_TYPE_SCORE then
        open c_model_id(p_object_for_id);
        fetch c_model_id into l_model_id;
        close c_model_id;
     else
        l_model_id:=p_object_for_id;
     end if;

     OPEN c_model_type(l_model_id);
     FETCH c_model_type into l_model_type;
     CLOSE c_model_type;



     if l_model_type='CUSTOMER_PROFITABILITY' THEN
--           DELETE FROM  ams_dm_org_contacts_stg WHERE ARC_OBJECT_USED_BY =  p_arc_object_for  AND OBJECT_USED_BY_ID =  p_object_for_id;
--           DELETE FROM  ams_dm_orgcont_stg_gt WHERE ARC_OBJECT_USED_BY =  p_arc_object_for  AND OBJECT_USED_BY_ID =  p_object_for_id;
        if p_count = 'FINAL' and p_arc_object_for = G_OBJECT_TYPE_SCORE then
           null;
        else
           DELETE FROM  ams_dm_org_contacts WHERE ARC_OBJECT_USED_BY =  p_arc_object_for  AND OBJECT_USED_BY_ID =  p_object_for_id;
        end if;
     END IF;

--      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_ams_schema || '.ams_dm_target_stg';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_ams_schema || '.ams_dm_target_stg_gt';

--    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_ams_schema || '.ams_dm_inter_source_stg';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_ams_schema || '.ams_dm_int_src_stg_gt ';

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END purge_target_staging;

   --
   -- History
   -- 16-Feb-2001 choang   Created.
   PROCEDURE get_customer_field (
      p_workbook_owner_name   IN VARCHAR2,
      p_workbook_name   IN VARCHAR2,
      p_worksheet_name  IN VARCHAR2,
      x_customer_field  OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME           CONSTANT VARCHAR2(30) := 'Get Customer Field';

      l_customer_pk_field  VARCHAR2(61);
      l_source_type_code   VARCHAR2(30);

      -- variables used to call search_sql_string
      l_found              VARCHAR2(1);
      l_found_in_str       NUMBER;
      l_position           NUMBER;
      l_overflow           NUMBER;

      CURSOR c_master_types (p_workbook_owner_name IN VARCHAR2, p_workbook_name IN VARCHAR2, p_worksheet_name IN VARCHAR2) IS
         SELECT a.source_type_code,
	        a.source_object_name || '.' || a.source_object_pk_field
         FROM   ams_list_src_types a , ams_discoverer_sql b
         WHERE  a.master_source_type_flag = 'Y'
         AND    a.enabled_flag = 'Y'
	 AND    b.workbook_owner_name = p_workbook_owner_name
	 AND    b.workbook_name = p_workbook_name
	 AND    b.worksheet_name = p_worksheet_name
	 AND    a.source_type_code = b.source_type_code
         ;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- find the master source type which is used
      -- in the workbook.  the master source type is
      -- needed to identify the pk field to select
      -- parties - list gen allows for customer
      -- records which are not from TCA, so they
      -- do not necessarily have party_id.
      OPEN c_master_types(p_workbook_owner_name, p_workbook_name, p_worksheet_name);
      LOOP
         l_source_type_code := NULL;
         l_customer_pk_field := NULL;

         FETCH c_master_types INTO l_source_type_code, l_customer_pk_field;

         AMS_DiscovererSQL_PVT.search_sql_string (
            p_search_string      => l_source_type_code,
            p_workbook_name      => p_workbook_name,
            p_worksheet_name     => p_worksheet_name,
            x_found              => l_found,
            x_found_in_str       => l_found_in_str,
            x_position           => l_position,
            x_overflow           => l_overflow
         );

         EXIT WHEN c_master_types%NOTFOUND OR l_found = FND_API.G_TRUE;
      END LOOP;
      CLOSE c_master_types;

      IF l_found = FND_API.G_FALSE THEN
         AMS_Utility_PVT.error_message ('AMS_DM_DIWB_NO_SOURCE_TYPE', 'WORKBOOKSHEET', p_workbook_name || '.' || p_worksheet_name);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      x_customer_field := l_customer_pk_field;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END get_customer_field;


   --
   -- NOTE
   --    - add target_value column to AMS_DM_INT_SRC_STG_GT to capture
   --      the calculated target_value from populate_target_staging to avoid
   --      duplicate effort in update_source_target
   -- History
   -- 16-Feb-2001 choang   Created.
   -- 06-jun-2002 choang   added support of target_value in AMS_DM_INT_SRC_STG_GT
   --                      to replace logic of update_source(); added calculation
   --                      of target value for alternative data sources.
   PROCEDURE populate_source (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        VARCHAR2(30) := 'Populate Source Table';

      l_target_value    VARCHAR2(30);
      l_row_count       NUMBER;

      CURSOR c_sources (p_arc_object_for IN VARCHAR2, p_object_for_id IN NUMBER) IS
         SELECT list_action_type, arc_incl_object_from, incl_object_id
         FROM   ams_list_select_actions
         WHERE  arc_action_used_by = p_arc_object_for
         AND    action_used_by_id = p_object_for_id
         ORDER BY order_number
         ;
      l_sources_rec        c_sources%ROWTYPE;

      CURSOR c_target_value (p_model_id IN NUMBER) IS
         SELECT target_positive_value
         FROM   ams_dm_models_all_b
         WHERE  model_id = p_model_id
         ;

      CURSOR c_recs IS
         SELECT COUNT(*),
                NVL (SUM (DECODE (target_value, l_target_value, 1, 0)), 0)
--       FROM ams_dm_inter_source_stg
         FROM ams_dm_int_src_stg_gt
         WHERE arc_object_used_by = p_arc_object_for
         AND   object_used_by_id = p_object_for_id
         AND   enabled_flag = 'Y'
         ;

      CURSOR c_model_status (p_model_id IN NUMBER) IS
        SELECT status_code
          FROM ams_dm_models_all_b
         WHERE model_id = p_model_id;

      CURSOR c_score_status (p_score_id IN NUMBER) IS
        SELECT status_code
          FROM ams_dm_scores_all_b
         WHERE score_id = p_score_id;

      CURSOR c_model_id (p_score_id IN NUMBER) IS
         SELECT model_id
         FROM   ams_dm_scores_all_b
         WHERE  score_id = p_score_id
    ;

      CURSOR c_model_type(p_model_id IN NUMBER) is
         SELECT model_type
         FROM ams_dm_models_vl
         WHERE model_id=p_model_id
         ;

      l_total_records         NUMBER := 0;
      l_total_positives       NUMBER := 0;
      l_status_code           VARCHAR2(30);
      l_party_type            VARCHAR2(30);
      l_is_b2b                  BOOLEAN;
      l_is_org_prod_affn    BOOLEAN;

      l_model_id               NUMBER;

      l_model_type           VARCHAR2(30);

      l_userId             NUMBER :=  FND_GLOBAL.user_id;
      l_concUserId             NUMBER :=   FND_GLOBAL.conc_login_id;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- purge the existing records
      DELETE /*+ index(AMS_DM_SOURCE AMS_DM_SOURCE_U2) */ FROM ams_dm_source
      WHERE arc_used_for_object = p_arc_object_for
      AND   used_for_object_id = p_object_for_id;

      -- get the target value if model building
      -- and reset the total count
      IF p_arc_object_for = G_OBJECT_TYPE_MODEL THEN
         OPEN c_target_value (p_object_for_id);
         FETCH c_target_value INTO l_target_value;
         CLOSE c_target_value;

         UPDATE ams_dm_models_all_b
         SET    total_records = 0,
                total_positives = 0
         WHERE  model_id = p_object_for_id
         ;

         -- get the Model status code
         OPEN  c_model_status (p_object_for_id);
         FETCH c_model_status INTO l_status_code;
         CLOSE c_model_status;

      ELSE
         UPDATE ams_dm_scores_all_b
         SET    total_records = 0,
                total_positives = 0
         WHERE  score_id = p_object_for_id
         ;

         -- get the Score status code
         OPEN  c_score_status (p_object_for_id);
         FETCH c_score_status INTO l_status_code;
         CLOSE c_score_status;

      END IF;

      IF p_seeded_data_source THEN
         -- Apply include, exclude and intersect rules
         OPEN c_sources (p_arc_object_for, p_object_for_id);
         FETCH c_sources INTO l_sources_rec;

      l_model_id := p_object_for_id;
      IF p_arc_object_for = 'SCOR' THEN
          OPEN c_model_id(p_object_for_id);
          FETCH c_model_id INTO l_model_id;
          CLOSE c_model_id;
      END IF;

      is_b2b_data_source(
          p_model_id => l_model_id,
          x_is_b2b     => l_is_b2b
      );

      OPEN c_model_type(l_model_id);
      FETCH c_model_type into l_model_type;
      CLOSE c_model_type;

      is_org_prod_affn (
          p_model_id => l_model_id,
          x_is_org_prod  => l_is_org_prod_affn
      );

      IF l_is_b2b THEN
         IF l_model_type='CUSTOMER_PROFITABILITY' OR l_is_org_prod_affn THEN
            l_party_type := 'ORGANIZATION';
         ELSE
            l_party_type := 'PARTY_RELATIONSHIP';
         END IF;
      ELSE
         l_party_type := 'PERSON';
      END IF;


      -- The first should be type INCLUDE
--    INSERT INTO ams_dm_inter_source_stg (
      INSERT INTO ams_dm_int_src_stg_gt (
            arc_object_used_by,
            object_used_by_id,
            party_id,
            enabled_flag,
            random_generated_num,
            target_value
         )
         SELECT p_arc_object_for
                , p_object_for_id
                , t.party_id
                , 'N'
                , NULL
                , DECODE (t.target_flag, 'Y', l_target_value, '0')
--       FROM   ams_dm_target_stg t, HZ_PARTIES p
         FROM   ams_dm_target_stg_gt t, HZ_PARTIES p
               WHERE  t.arc_object_used_by = p_arc_object_for
               AND    t.object_used_by_id = p_object_for_id
               AND    t.arc_object = l_sources_rec.arc_incl_object_from
               AND    t.object_id = l_sources_rec.incl_object_id
               AND    t.party_id = p.party_id
               AND    p.party_type = l_party_type;

         LOOP
            FETCH c_sources INTO l_sources_rec;
            EXIT WHEN c_sources%NOTFOUND;

            -- handle include
            IF l_sources_rec.list_action_type = 'INCLUDE' THEN
               --INSERT INTO ams_dm_inter_source_stg (
               INSERT INTO ams_dm_int_src_stg_gt (
                  arc_object_used_by,
                  object_used_by_id,
                  party_id,
                  enabled_flag,
                  random_generated_num,
                  target_value
               )
               SELECT p_arc_object_for
                      , p_object_for_id
                      , t.party_id
                      , 'N'
                      , NULL
                      , DECODE (t.target_flag, 'Y', l_target_value, '0')
--             FROM   ams_dm_target_stg t , HZ_PARTIES p
               FROM   ams_dm_target_stg_gt t , HZ_PARTIES p
               WHERE  t.arc_object_used_by = p_arc_object_for
               AND    t.object_used_by_id = p_object_for_id
               AND    t.arc_object = l_sources_rec.arc_incl_object_from
               AND    t.object_id = l_sources_rec.incl_object_id
               AND    t.party_id = p.party_id
               AND    p.party_type = l_party_type
               AND NOT EXISTS (SELECT 1
--                             FROM   ams_dm_inter_source_stg i
                               FROM   ams_dm_int_src_stg_gt i
                               WHERE  i.arc_object_used_by = t.arc_object_used_by
                               AND    i.object_used_by_id = t.object_used_by_id
                               AND    i.party_id = t.party_id)
               ;
            -- handle exclude
            ELSIF l_sources_rec.list_action_type = 'EXCLUDE' THEN
--             DELETE FROM ams_dm_inter_source_stg i
               DELETE FROM ams_dm_int_src_stg_gt i
               WHERE arc_object_used_by = p_arc_object_for
               AND   object_used_by_id = p_object_for_id
               AND   EXISTS (SELECT 1
                             FROM   ams_dm_target_stg_gt t    -- ams_dm_target_stg t
                             WHERE  t.arc_object_used_by = p_arc_object_for
                             AND    t.object_used_by_id = p_object_for_id
                             AND    t.arc_object = l_sources_rec.arc_incl_object_from
                             AND    t.object_id = l_sources_rec.incl_object_id
                             AND    t.party_id = i.party_id)
               ;
            -- handle intersect
            ELSIF l_sources_rec.list_action_type = 'INTERSECT' THEN
--             DELETE FROM ams_dm_inter_source_stg i
               DELETE FROM ams_dm_int_src_stg_gt i
               WHERE arc_object_used_by = p_arc_object_for
               AND   object_used_by_id = p_object_for_id
               AND   NOT EXISTS (SELECT 1
--                               FROM   ams_dm_target_stg t
                                 FROM   ams_dm_target_stg_gt t
                                 WHERE  t.arc_object_used_by = p_arc_object_for
                                 AND    t.object_used_by_id = p_object_for_id
                                 AND    t.arc_object = l_sources_rec.arc_incl_object_from
                                 AND    t.object_id = l_sources_rec.incl_object_id
                                 AND    t.party_id = i.party_id)
               ;
            ELSE
               AMS_Utility_PVT.error_message ('AMS_DM_UNSUPPORTED_ACTION');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END LOOP;
         CLOSE c_sources;
      ELSE
--       INSERT INTO ams_dm_inter_source_stg (
         INSERT INTO ams_dm_int_src_stg_gt (
            arc_object_used_by,
            object_used_by_id,
            party_id,
            enabled_flag,
            random_generated_num,
            target_value
         )
         SELECT p_arc_object_for
                , p_object_for_id
                , party_id
                , 'N'
                , NULL
                , DECODE (target_flag, 'Y', l_target_value, '0')
--       FROM   ams_dm_target_stg
         FROM   ams_dm_target_stg_gt
         WHERE  arc_object_used_by = p_arc_object_for
         AND    object_used_by_id = p_object_for_id
         ;
      END IF;

      -- Apply size options for selections
      apply_sizing_options (
         p_arc_object_for  => p_arc_object_for,
         p_object_for_id   => p_object_for_id,
         x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- ASSUMPTION: source_id only comes from ams_dm_source_s

      --added rosharma 20-aug-2003 bug # 3102421
      BEGIN
      --end add rosharma 20-aug-2003 bug # 3102421
   INSERT INTO ams_dm_source (
    source_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    arc_used_for_object,
    used_for_object_id,
    party_id,
    target_value
   )
   SELECT ams_dm_source_s.NEXTVAL,
        SYSDATE,
        l_concUserId,
        SYSDATE,
        l_userId,
        l_concUserId,
        1,
        p_arc_object_for,
        p_object_for_id,
        party_id,
        target_value
-- FROM ams_dm_inter_source_stg
   FROM ams_dm_int_src_stg_gt
   WHERE arc_object_used_by = p_arc_object_for
   AND object_used_by_id = p_object_for_id
   AND enabled_flag = 'Y'
   ;
      --added rosharma 20-aug-2003 bug # 3102421
      EXCEPTION
   WHEN OTHERS THEN
   AMS_Utility_PVT.error_message ('AMS_DM_INVALID_PRIMARY_KEY');
   RAISE FND_API.G_EXC_ERROR;
      END;
      --end add rosharma 20-aug-2003 bug # 3102421

      -- choang - 12-jul-2002 - logic to populate total records
      IF p_arc_object_for = G_OBJECT_TYPE_MODEL THEN
         OPEN c_recs;
         FETCH c_recs INTO l_total_records, l_total_positives;
         CLOSE c_recs;

         UPDATE ams_dm_models_all_b
         SET total_records = l_total_records
           , total_positives = l_total_positives
         WHERE model_id = p_object_for_id
         ;

         -- If model is building, then check that the data can be used for building
         IF l_status_code = G_STATUS_BUILDING THEN
            IF l_total_records <= 0 THEN
               AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_SELECTIONS_EMPTY');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_total_positives <= 0 THEN
               AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_NO_POSITIVE_TGTS');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_total_positives  = l_total_records THEN
               AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_MODEL_ALL_POSITIVE_TGTS');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
      ELSE
         -- use the results of the previous insert statement
         l_row_count := SQL%rowcount;
         UPDATE ams_dm_scores_all_b
         SET total_records = l_row_count
         WHERE score_id = p_object_for_id
         ;

         -- If Scoring Run is scoring, then check that the data can be used for scoring
         IF l_status_code = G_STATUS_SCORING THEN
            IF l_row_count <= 0 THEN
               AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SCORE_SELECTIONS_EMPTY');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
      END IF;

      --kbasavar contents of ams_dm_org_contacts will be synchronized with the organizations in ams_dm_source
      IF l_is_b2b AND l_model_type='CUSTOMER_PROFITABILITY' AND p_seeded_data_source THEN
--         DELETE FROM ams_dm_org_contacts_stg
--         DELETE FROM ams_dm_orgcont_stg_gt
         DELETE FROM ams_dm_org_contacts
--          WHERE org_party_id NOT IN (SELECT distinct party_id from ams_dm_inter_source_stg WHERE arc_object_used_by = p_arc_object_for AND
            WHERE org_party_id NOT IN (SELECT distinct party_id from ams_dm_int_src_stg_gt WHERE arc_object_used_by = p_arc_object_for AND
                                                 object_used_by_id = p_object_for_id);

    IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message ('In populate_source synchronize org_cotacts with org');
         END IF;

      END IF;

   END populate_source;


   --
   -- History
   -- 16-Feb-2001 choang   Created.
   PROCEDURE get_from_sql (
      p_workbook_owner_name   IN VARCHAR2,
      p_workbook_name   IN VARCHAR2,
      p_worksheet_name  IN VARCHAR2,
      x_from_sql        OUT NOCOPY VARCHAR2,
      x_found           OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      -- spaces included to ensure searched string is part of from clause
      L_FROM_KEYWORD       CONSTANT VARCHAR2(30) := 'FROM';
      L_API_NAME           CONSTANT VARCHAR2(30) := 'Get FROM SQL';

         -- variables used to call search_sql_string
      l_found              VARCHAR2(1);
      l_found_in_str       NUMBER;
      l_position           NUMBER;
      l_overflow           NUMBER;

      l_from_sql           VARCHAR2(4000);
      l_temp_sql           VARCHAR2(4000);

      CURSOR c_sql (p_str_num IN NUMBER) IS
         SELECT sql_string
         FROM   ams_discoverer_sql
         WHERE  workbook_owner_name = p_workbook_owner_name
         AND    workbook_name = p_workbook_name
         AND    worksheet_name = p_worksheet_name
         AND    sequence_order >= p_str_num
         ORDER BY sequence_order
         ;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      AMS_DiscovererSQL_PVT.search_sql_string (
         p_search_string      => L_FROM_KEYWORD,
         p_workbook_name      => p_workbook_name,
         p_worksheet_name     => p_worksheet_name,
         x_found              => l_found,
         x_found_in_str       => l_found_in_str,
         x_position           => l_position,
         x_overflow           => l_overflow
      );
      IF l_found <> FND_API.G_TRUE THEN
         AMS_Utility_PVT.error_message ('AMS_SQL_NO_FROM', 'WORKBOOKSHEET', p_workbook_name || '.' || p_worksheet_name);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- fetch the sql string from ams_discoverer_sql
      -- and start from the position of FROM.  append
      -- all subsequent strings to the out variable.
      OPEN c_sql (l_found_in_str);
      FETCH c_sql INTO l_from_sql;
      l_from_sql := SUBSTR (l_from_sql, l_position);
      LOOP
         FETCH c_sql INTO l_temp_sql;
         EXIT WHEN c_sql%NOTFOUND;

         l_from_sql := l_from_sql || l_temp_sql;
      END LOOP;
      CLOSE c_sql;

      x_from_sql := l_from_sql;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END get_from_sql;


   --
   -- NOTE
   --    The original table and process design for data mining data preparation
   --    used binary targets, so a Y/N binary set was used.  After design was
   --    completed, we found out the ODM engine could only handle numeric target
   --    values, so the value in ams_dm_source contains 0/1.  We convert the Y/N
   --    into 0/1 in populate_source().
   --
   -- History
   -- 16-Feb-2001 choang   Created.
   -- 05-Jun-2002 choang   Added logic to handle alternative targets.
   --
   PROCEDURE populate_targets (
      p_model_id           IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME              CONSTANT VARCHAR2(30) := 'Populate Targets in Staging';
      -- NOTE: We don't know the actual code to
      --       use because this function is not
      --       implemented.
      L_NON_LOYAL_CODE        CONSTANT VARCHAR2(30) := 'LEFT_FOR_COMPETITOR';   -- replace this with the correct; follow bug 1657447
      L_POSITIVE_TARGET_VALUE CONSTANT VARCHAR2(30) := 'Y';
      L_NEGATIVE_TARGET_VALUE CONSTANT VARCHAR2(30) := 'N';

      CURSOR c_model_details (p_model_id IN NUMBER) IS
         SELECT m.model_id
                , m.model_type
                , m.target_positive_value
                , t.target_id
                , t.data_source_id
         FROM   ams_dm_models_all_b m, ams_dm_targets_b t
         WHERE  m.model_id = p_model_id
         AND    t.target_id = m.target_id
         ;
      l_model_rec       c_model_details%ROWTYPE;

      CURSOR c_target (p_target_id IN NUMBER) IS
         SELECT field.source_column_name
		, source1.source_object_name
		, source2.source_object_name
                , source2.source_object_pk_field
                , source1.source_object_name||decode(UPPER(source1.remote_flag),'Y','@'||source1.database_link,'')
                , source2.source_object_name||decode(UPPER(source2.remote_flag),'Y','@'||source2.database_link,'')
                , target.data_source_id
                , target.target_source_id
		, field.enabled_flag
         FROM   ams_dm_targets_b target, ams_list_src_fields field, ams_list_src_types source1, ams_list_src_types source2
         WHERE  target.target_id = p_target_id
         AND    field.list_source_field_id = source_field_id
         AND    source2.list_source_type_id = target.data_source_id
         AND    source1.list_source_type_id = target.target_source_id
         ;


      l_target_source_object_full         VARCHAR2(151);
      l_pk_source_object_full         VARCHAR2(151);
      l_target_source_object         VARCHAR2(30);
      l_pk_source_object         VARCHAR2(30);
      l_pk_field              VARCHAR2(30);
      l_target_field          VARCHAR2(30);
      l_target_source_id      NUMBER;
      l_data_source_id        NUMBER;
      l_target_enabled        VARCHAR2(1);

      l_seeded_data_source    BOOLEAN;
      l_sql                   VARCHAR2(32000);
      l_positive_values_sql   VARCHAR2(4000);
      l_relation_cond         VARCHAR2(4000) := '';
      -- added rosharma 19-jun-2003 bug # 3004453
      l_date DATE := TRUNC(TO_DATE(TO_CHAR(ADD_MONTHS(SYSDATE, 1),'DD-MM-YYYY'), 'DD-MM-YYYY'), 'MONTH');
      -- end add rosharma 19-jun-2003 bug # 3004453

      l_is_b2b                  BOOLEAN;
      l_model_id               NUMBER;

      l_is_org_prod_affn   BOOLEAN;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_model_id := p_model_id;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ': L_DATE = ' || l_date);
         AMS_Utility_PVT.debug_message ('MODEL ID: ' || p_model_id);
      END IF;

      OPEN c_model_details (p_model_id);
      FETCH c_model_details INTO l_model_rec;
      CLOSE c_model_details;

      IF p_seeded_data_source THEN
         IF l_model_rec.model_type = 'LOYALTY' THEN

            --Check for model type
            is_b2b_data_source(
                    p_model_id => l_model_id,
                    x_is_b2b     => l_is_b2b
                 );
            -- choang - 04-jul-2002 - change loyalty logic
            -- use days since last ordered as loyalty indicator
            -- business reasoning: if customer has not ordered in the
            -- last n days, then he may have gone to do business with
            -- a competitor.

            IF l_is_b2b THEN
               --UPDATE ams_dm_target_stg t
               UPDATE ams_dm_target_stg_gt t
                  SET    target_flag = (SELECT L_POSITIVE_TARGET_VALUE
                                     FROM   dual
                                     -- choang - 21-nov-2003 - bug 3275817
                                     -- changed to not exists and having clause
                                     WHERE NOT EXISTS (SELECT 1
                                        -- changed rosharma 19-jun-2003 bug # 3004453
                                        --FROM   ams_dm_party_details_time p
                                        --WHERE  p.party_id = t.party_id
                                        --AND    p.tot_num_order_3_months < 1
                                     FROM   bic_party_summ p , hz_relationships hpr
                                     WHERE  hpr.party_id = t.party_id
                                     AND  hpr.status = 'A'
                                     AND  hpr.subject_table_name = 'HZ_PARTIES'
                                     AND  hpr.object_table_name = 'HZ_PARTIES'
                                     AND  hpr.directional_flag = 'F'
                                     AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
                                     AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
                                     AND  p.party_id = hpr.object_id        --the org's party id
                                     HAVING SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, p.period_start_date)) - 3),1,0,p.order_num)) >= 1
                                             -- end change rosharma 19-jun-2003 bug # 3004453
                                   )
                                 )
                  WHERE  arc_object_used_by = G_OBJECT_TYPE_MODEL
                  AND    object_used_by_id = p_model_id;
            ELSE
               -- UPDATE ams_dm_target_stg t
               UPDATE ams_dm_target_stg_gt t
                  SET    target_flag = (SELECT L_POSITIVE_TARGET_VALUE
                                     FROM   dual
                                     -- choang - 21-nov-2003 - bug 3275817
                                     -- changed to not exists and having clause
                                     WHERE NOT EXISTS (SELECT 1
                                     -- changed rosharma 19-jun-2003 bug # 3004453
                                     --FROM   ams_dm_party_details_time p
                                     --WHERE  p.party_id = t.party_id
                                     --AND    p.tot_num_order_3_months < 1
                                     FROM   bic_party_summ p
                                     WHERE  p.party_id = t.party_id
                                     HAVING SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, p.period_start_date)) - 3),1,0,p.order_num)) >= 1
                      -- end change rosharma 19-jun-2003 bug # 3004453
                                   )
                                 )
                  WHERE  arc_object_used_by = G_OBJECT_TYPE_MODEL
                  AND    object_used_by_id = p_model_id;
            END IF;
         ELSIF l_model_rec.model_type IN ('EMAIL', 'DIRECTMAIL', 'TELEMARKETING') THEN
            --          UPDATE ams_dm_target_stg t
            UPDATE ams_dm_target_stg_gt t
               SET    target_flag = (SELECT L_POSITIVE_TARGET_VALUE
                                     FROM   dual
                                     WHERE EXISTS (SELECT 1
                                                   FROM   ams_campaign_schedules_b c, jtf_ih_interactions i,
                                                          jtf_ih_results_b r, ams_list_select_actions l
                                                   WHERE  c.schedule_id = l.incl_object_id
                                                   AND    l.arc_action_used_by = t.arc_object_used_by
                                                   AND    l.action_used_by_id = t.object_used_by_id
                                                   AND    i.party_id = t.party_id
                                                   AND    i.source_code = c.source_code
                                                   AND    r.result_id = i.result_id
                                                   AND    r.positive_response_flag = 'Y'
                                                  ))
               WHERE  arc_object_used_by = G_OBJECT_TYPE_MODEL
               AND    object_used_by_id = p_model_id;
         ELSIF  l_model_rec.model_type = 'CUSTOMER_PROFITABILITY' THEN
             OPEN c_target (l_model_rec.target_id);
             FETCH c_target
                INTO l_target_field, l_target_source_object, l_pk_source_object, l_pk_field, l_target_source_object_full, l_pk_source_object_full, l_data_source_id, l_target_source_id, l_target_enabled;
             CLOSE c_target;

	     IF l_target_enabled <> 'Y' THEN
                IF (AMS_DEBUG_HIGH_ON) THEN
                    AMS_Utility_PVT.debug_message ('Target Field has been disabled. Raising Error.');
                END IF;
                AMS_Utility_PVT.error_message ('AMS_DM_TARGET_FIELD_DISABLED');
                RAISE FND_API.G_EXC_ERROR;
	     END IF;

             get_target_positive_values (  p_target_id       => l_model_rec.target_id,
                                                p_target_field    => l_target_source_object || '.' || l_target_field,
                                                x_sql_stmt        => l_positive_values_sql);

             IF l_positive_values_sql IS NULL THEN
               l_positive_values_sql := ' ' || l_target_source_object || '.' || l_target_field || ' = tv.target_value';
             END IF;

             --           l_sql := 'UPDATE ams_dm_target_stg t';
             l_sql := 'UPDATE ams_dm_target_stg_gt t';
             l_sql := l_sql || ' SET t.target_flag = (SELECT ''' || L_POSITIVE_TARGET_VALUE || '''';
             l_sql := l_sql || ' FROM dual WHERE EXISTS (SELECT 1';

             IF l_data_source_id = l_target_source_id THEN
                l_sql := l_sql || ' FROM ams_dm_target_values_b tv, ' || l_target_source_object_full;
             ELSE
                l_sql := l_sql || ' FROM ams_dm_target_values_b tv, ' || l_target_source_object_full || ', ' || l_pk_source_object_full;
             END IF;

             l_sql := l_sql || ' WHERE tv.target_id = :target_id';

             is_b2b_data_source(
                p_model_id => l_model_id,
                x_is_b2b     => l_is_b2b
             );

             IF l_is_b2b THEN
                l_sql := l_sql || ' AND ' || l_pk_source_object || '.organization_id = t.party_id';
             ELSE
                l_sql := l_sql || ' AND ' || l_pk_source_object || '.party_id = t.party_id';
             END IF;

             l_sql := l_sql || ' AND (' || l_positive_values_sql || ')';
             IF l_data_source_id <> l_target_source_id THEN
                get_related_ds_condition ( p_master_ds_id => l_data_source_id,
                                           p_child_ds_id  => l_target_source_id,
                                           x_sql_stmt     => l_relation_cond);
                IF LENGTH(l_relation_cond) > 0 THEN
                   l_sql := l_sql || ' AND (' || l_relation_cond || ')';
                END IF;
             END IF;
             l_sql := l_sql || '))';
             l_sql := l_sql || ' WHERE t.arc_object_used_by = :object_type';
             l_sql := l_sql || ' AND t.object_used_by_id = :model_id';

             IF (AMS_DEBUG_HIGH_ON) THEN
                 AMS_Utility_PVT.debug_message ('Customer Profitability-target sql: ' || l_sql);
             END IF;

             EXECUTE IMMEDIATE l_sql
             USING l_model_rec.target_id, G_OBJECT_TYPE_MODEL, p_model_id;

         ELSIF l_model_rec.model_type ='PRODUCT_AFFINITY' THEN

            OPEN c_target (l_model_rec.target_id);
               FETCH c_target
                  INTO l_target_field, l_target_source_object, l_pk_source_object, l_pk_field, l_target_source_object_full, l_pk_source_object_full, l_data_source_id, l_target_source_id, l_target_enabled;
            CLOSE c_target;

	     IF l_target_enabled <> 'Y' THEN
                IF (AMS_DEBUG_HIGH_ON) THEN
                    AMS_Utility_PVT.debug_message ('Target Field has been disabled. Raising Error.');
                END IF;
                AMS_Utility_PVT.error_message ('AMS_DM_TARGET_FIELD_DISABLED');
                RAISE FND_API.G_EXC_ERROR;
	     END IF;

            is_b2b_data_source(
                 p_model_id => l_model_id,
                 x_is_b2b     => l_is_b2b
                );

            is_org_prod_affn (
                   p_model_id => l_model_id,
                   x_is_org_prod  => l_is_org_prod_affn
                  );


            IF l_is_b2b AND l_is_org_prod_affn = false THEN
               --    UPDATE ams_dm_target_stg t
                  UPDATE ams_dm_target_stg_gt t
                     SET    target_flag = (SELECT L_POSITIVE_TARGET_VALUE
                                                  FROM   dual
                                                  WHERE EXISTS (SELECT 1
                                                                 FROM AMS_ACT_PRODUCTS aa, OE_ORDER_HEADERS_ALL oh, OE_ORDER_LINES_ALL ol,
                                                                          hz_cust_account_roles hcr, hz_relationships hpr
                                                                 WHERE aa.ARC_ACT_PRODUCT_USED_BY = 'MODL'
                                                                           and aa.ACT_PRODUCT_USED_BY_ID = p_model_id
                                                                           and ol.INVENTORY_ITEM_ID IN
                                                                                  (SELECT DISTINCT ic.INVENTORY_ITEM_ID
                                                                                    FROM MTL_ITEM_CATEGORIES ic
                                                                                    WHERE ic.CATEGORY_ID = aa.CATEGORY_ID
                                                                                         AND (ic.INVENTORY_ITEM_ID = aa.INVENTORY_ITEM_ID  OR aa.INVENTORY_ITEM_ID IS NULL))
                                                                           --and (oh.ORG_ID = aa.ORGANIZATION_ID OR aa.ORGANIZATION_ID IS NULL)
                                                                           --and ol.ORG_ID  = nvl(aa.ORGANIZATION_ID,ol.ORG_ID)
                                                                           and oh.SHIP_TO_CONTACT_ID = hcr.CUST_ACCOUNT_ROLE_ID
                                                                           and hcr.PARTY_ID=hpr.PARTY_ID
                                                                           and hpr.party_id = t.party_id
                                                                           and hpr.status = 'A'
                                                                           and hpr.subject_table_name = 'HZ_PARTIES'
                                                                           and hpr.object_table_name = 'HZ_PARTIES'
                                                                           and hpr.directional_flag = 'F'
                                                                           and hpr.relationship_code IN ('CONTACT_OF','EMPLOYEE_OF')
                                                                           and (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
                                                                           and oh.header_id = ol.header_id
                                                                           and nvl(oh.cancelled_flag,'N') <> 'Y'
                                                                           and nvl(oh.FLOW_STATUS_CODE,'N') <> 'CANCELLED'
                                                                           and nvl(ol.cancelled_flag,'N') <> 'Y'
                                                                           and nvl(ol.FLOW_STATUS_CODE,'N') <> 'CANCELLED'
                                                                           and oh.order_category_code <> 'RETURN'
                                                                           and ol.line_category_code <> 'RETURN'
                                                                          )
                                                  )
                  WHERE arc_object_used_by = G_OBJECT_TYPE_MODEL
                  AND    object_used_by_id = p_model_id;
            ELSE
               --           UPDATE ams_dm_target_stg t
               UPDATE ams_dm_target_stg_gt t
                  SET    target_flag = (SELECT L_POSITIVE_TARGET_VALUE
                                           FROM   dual
                                           WHERE EXISTS (SELECT 1
                                                            FROM AMS_ACT_PRODUCTS aa,
								 OE_ORDER_HEADERS_ALL oh,
								 OE_ORDER_LINES_ALL ol,
								 --hz_cust_site_uses_all hcsu,
								 --hz_cust_acct_sites_all hcs,
								 HZ_CUST_ACCOUNTS hc
                                                                 WHERE aa.ARC_ACT_PRODUCT_USED_BY = 'MODL'
                                                                       and aa.ACT_PRODUCT_USED_BY_ID = p_model_id
                                                                       and ol.INVENTORY_ITEM_ID IN
                                                                            (SELECT DISTINCT ic.INVENTORY_ITEM_ID
                                                                                FROM MTL_ITEM_CATEGORIES ic
                                                                                WHERE ic.CATEGORY_ID = aa.CATEGORY_ID
                                                                                     AND (ic.INVENTORY_ITEM_ID = aa.INVENTORY_ITEM_ID  OR aa.INVENTORY_ITEM_ID IS NULL))
                                                                       --and (oh.ORG_ID = aa.ORGANIZATION_ID OR aa.ORGANIZATION_ID IS NULL)
                                                                       --and ol.ORG_ID  = nvl(aa.ORGANIZATION_ID,ol.ORG_ID)
                                                                       --and oh.SHIP_TO_ORG_ID = hcsu.site_use_id
                       						       --and hcsu.cust_acct_site_id = hcs.cust_acct_site_id
								       --and hcs.cust_account_id = hc.cust_account_id
                                                                       and oh.SOLD_TO_ORG_ID = hc.cust_account_id
                                                                       and hc.PARTY_ID = t.party_id
                                                                       and oh.header_id = ol.header_id
                                                                       and nvl(oh.cancelled_flag,'N') <> 'Y'
                                                                       and nvl(oh.FLOW_STATUS_CODE,'N') <> 'CANCELLED'
                                                                       and nvl(ol.cancelled_flag,'N') <> 'Y'
                                                                       and nvl(ol.FLOW_STATUS_CODE,'N') <> 'CANCELLED'
                                                                       and oh.order_category_code <> 'RETURN'
                                                                       and ol.line_category_code <> 'RETURN'
                                                                    )
                                                        )
               WHERE arc_object_used_by = G_OBJECT_TYPE_MODEL
               AND    object_used_by_id = p_model_id;
            END IF;

         ELSE
            AMS_Utility_PVT.error_message ('AMS_DM_UNSUPPORTED_MODEL', 'MODEL_TYPE', l_model_rec.model_type);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      ELSE
         OPEN c_target (l_model_rec.target_id);
         FETCH c_target INTO l_target_field, l_target_source_object, l_pk_source_object, l_pk_field, l_target_source_object_full, l_pk_source_object_full, l_data_source_id, l_target_source_id, l_target_enabled;
         CLOSE c_target;

	 IF l_target_enabled <> 'Y' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message ('Target Field has been disabled. Raising Error.');
            END IF;
            AMS_Utility_PVT.error_message ('AMS_DM_TARGET_FIELD_DISABLED');
            RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 -- get the sql statement that ANDs all the positive values defined for the target
         -- and the comparison operators.
         get_target_positive_values (  p_target_id       => l_model_rec.target_id,
                 p_target_field    => l_target_source_object || '.' || l_target_field,
                 x_sql_stmt        => l_positive_values_sql);

         IF l_positive_values_sql IS NULL THEN
            l_positive_values_sql := ' ' || l_target_source_object || '.' || l_target_field || ' = tv.target_value';
         END IF;

         -- if target field is defined for numeric data
         -- but the data contains alphanumeric data, a
         -- database error could be raised
         BEGIN
         --           l_sql := 'UPDATE ams_dm_target_stg t';
              l_sql := 'UPDATE ams_dm_target_stg_gt t';
              l_sql := l_sql || ' SET t.target_flag = (SELECT ''' || L_POSITIVE_TARGET_VALUE || '''';
              IF l_data_source_id = l_target_source_id THEN
                 l_sql := l_sql || ' FROM ' || l_target_source_object_full;
              ELSE
                 l_sql := l_sql || ' FROM ' || l_target_source_object_full || ', ' || l_pk_source_object_full;
              END IF;
              l_sql := l_sql || ' WHERE ' || l_pk_source_object || '.' || l_pk_field || ' = t.party_id';
              l_sql := l_sql || ' AND (' || l_positive_values_sql || ')';
              l_sql := l_sql || ' AND ROWNUM = 1 ';
              IF l_data_source_id <> l_target_source_id THEN
                 get_related_ds_condition ( p_master_ds_id => l_data_source_id,
            p_child_ds_id  => l_target_source_id,
            x_sql_stmt     => l_relation_cond);
       IF LENGTH(l_relation_cond) > 0 THEN
                    l_sql := l_sql || ' AND (' || l_relation_cond || ')';
       END IF;
              END IF;
              l_sql := l_sql || ')';
              l_sql := l_sql || ' WHERE t.arc_object_used_by = :object_type';
              l_sql := l_sql || ' AND t.object_used_by_id = :model_id';

         EXCEPTION
            WHEN VALUE_ERROR THEN
               AMS_Utility_PVT.error_message ('AMS_DM_INVALID_DATA_CONVERT');
               RAISE FND_API.G_EXC_ERROR;
         END;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message ('target sql: ' || l_sql);
         END IF;

         EXECUTE IMMEDIATE l_sql
         USING G_OBJECT_TYPE_MODEL, p_model_id;
      END IF;

--    UPDATE ams_dm_target_stg
      UPDATE ams_dm_target_stg_gt
      SET    target_flag = L_NEGATIVE_TARGET_VALUE
      WHERE  arc_object_used_by = G_OBJECT_TYPE_MODEL
      AND    object_used_by_id = p_model_id
      AND    target_flag IS NULL;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END populate_targets;



   --
   -- History
   -- 16-Feb-2001 choang   Created.
   PROCEDURE update_action_summary (
      p_arc_object_for     IN VARCHAR2,
      p_object_for_id      IN NUMBER,
      p_seeded_data_source IN BOOLEAN,
      x_return_status      OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME           CONSTANT VARCHAR2(30) := 'Update Select Actions Summary';

      l_action_rec         AMS_ListAction_PVT.action_rec_type;
      l_action_id          NUMBER;
      l_obj_version_num    NUMBER;

      l_msg_data           VARCHAR2(32767);
      l_msg_count          NUMBER;
      l_return_status      VARCHAR2(1);

      CURSOR c_action_version (p_arc_incl_object IN VARCHAR2, p_incl_object_id IN NUMBER) IS
         SELECT list_select_action_id, object_version_number
         FROM   ams_list_select_actions
         WHERE  arc_action_used_by = p_arc_object_for
         AND    action_used_by_id = p_object_for_id
         AND    arc_incl_object_from = p_arc_incl_object
         AND    incl_object_id = p_incl_object_id
         ;

      CURSOR c_summary IS
         SELECT arc_object,
                object_id,
                COUNT(*) total_selected,  -- total selected
                SUM (DECODE (target_flag, 'Y', 1, 0)) total_targeted
--       FROM   ams_dm_target_stg
         FROM   ams_dm_target_stg_gt
         WHERE  arc_object_used_by = p_arc_object_for
         AND    object_used_by_id = p_object_for_id
         GROUP BY arc_object, object_id
         ;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- only perform the summarization for seeded data sources
      IF NOT p_seeded_data_source THEN
         RETURN;
      END IF;

      AMS_ListAction_PVT.init_action_rec (l_action_rec);

      FOR l_summary_rec IN c_summary LOOP
         OPEN c_action_version (l_summary_rec.arc_object, l_summary_rec.object_id);
         FETCH c_action_version INTO l_action_rec.list_select_action_id, l_action_rec.object_version_number;
         CLOSE c_action_version;

         l_action_rec.no_of_rows_used := l_summary_rec.total_selected;
         l_action_rec.no_of_rows_targeted := l_summary_rec.total_targeted;

         AMS_ListAction_PVT.Update_ListAction (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_TRUE,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_action_rec         => l_action_rec
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END update_action_summary;

   -- Note
   --    Different between this procedure and populate_target
   --    is that this procedure updates amd_dm_source versus
   --    ams_dm_target_stg_gt.  This procedure also populates
   --    0 or 1 for the target value due to ODM limitations
   --    in creating a balanced data set -- they can't use
   --    Y or N in the calculation of the balanced data set.
   --
   -- ***** OBSELETED ********
   --
   -- History
   -- 19-Feb-2001 choang   Created.
   -- 05-Jun-2002 choang   Obseleted.  Logic was incorporated into populate_source
   --                      and populate_targets.
   --
   PROCEDURE update_source_target (
      p_object_type     IN VARCHAR2,
      p_object_id       IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME              CONSTANT VARCHAR2(30) := 'Update Source Target';

      L_NON_LOYAL_CODE        CONSTANT VARCHAR2(30) := 'LEFT_FOR_COMPETITOR';   -- replace this with the correct; follow bug 1657447
      L_POSITIVE_TARGET_VALUE CONSTANT VARCHAR2(30) := '1';
      L_NEGATIVE_TARGET_VALUE CONSTANT VARCHAR2(30) := '0';
      L_SEEDED_ID_THRESHOLD   CONSTANT NUMBER := 10000;

      CURSOR c_model_details (p_model_id IN NUMBER) IS
         SELECT m.model_id
                , m.model_type
                , m.target_positive_value
                , t.target_id
                , t.data_source_id
         FROM   ams_dm_models_all_b m, ams_dm_targets_b t
         WHERE  m.model_id = p_model_id
         AND    t.target_id = m.target_id
         ;
      l_object_rec      c_model_details%ROWTYPE;

      CURSOR c_score_details (p_score_id IN NUMBER) IS
         SELECT m.model_id
                , m.model_type
                , m.target_positive_value
                , t.target_id
                , t.data_source_id
         FROM   ams_dm_models_all_b m, ams_dm_scores_all_b s, ams_dm_targets_b t
         WHERE  m.model_id = s.model_id
         AND    s.score_id = p_score_id
         AND    t.target_id = m.target_id
         ;

      l_seeded_flag     BOOLEAN;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_object_type = G_OBJECT_TYPE_MODEL THEN
      OPEN c_model_details (p_object_id);
      FETCH c_model_details INTO l_object_rec;
      CLOSE c_model_details;
      ELSE
         OPEN c_score_details (p_object_id);
         FETCH c_score_details INTO l_object_rec;
         CLOSE c_score_details;
      END IF;

      IF l_object_rec.data_source_id < L_SEEDED_ID_THRESHOLD THEN
         l_seeded_flag := TRUE;
      END IF;

      IF l_object_rec.model_type = 'LOYALTY' THEN
         UPDATE /*+ index(t AMS_DM_SOURCE_U2) */ ams_dm_source t
         SET    target_value = (SELECT L_POSITIVE_TARGET_VALUE
                                FROM   dual
                                WHERE EXISTS (SELECT 1
                                              FROM   hz_cust_accounts c, hz_suspension_activity s
                                              WHERE  c.party_id = t.party_id
                                              AND    s.cust_account_id = c.cust_account_id
                                              AND    s.action_type = L_NON_LOYAL_CODE
                                             ))
         WHERE  arc_used_for_object = p_object_type
         AND    used_for_object_id = p_object_id;
      ELSIF l_object_rec.model_type IN ('EMAIL', 'DIRECTMAIL', 'TELEMARKETING') THEN
         UPDATE /*+ index(t AMS_DM_SOURCE_U2) */ ams_dm_source t
         SET    target_value = (SELECT L_POSITIVE_TARGET_VALUE
                                FROM   dual
                                WHERE EXISTS (SELECT 1
                                              FROM   ams_campaign_schedules_b c,
                                                     jtf_ih_interactions i,
                                                     ams_list_select_actions l
                                              WHERE  c.schedule_id = l.incl_object_id
                                              AND    l.arc_action_used_by = t.arc_used_for_object
                                              AND    l.action_used_by_id = t.used_for_object_id
                                              AND    i.party_id = t.party_id
                                              AND    i.source_code = c.source_code
/*** enable this code when positive responses are captured
                                WHERE EXISTS (SELECT 1
                                              FROM   ams_campaign_schedules_b c, jtf_ih_interactions i,
                                                     jtf_ih_results_b r, ams_list_select_actions l
                                              WHERE  c.schedule_id = l.incl_object_id
                                              AND    l.arc_action_used_by = t.arc_used_for_object
                                              AND    l.action_used_by_id = t.used_for_object_id
                                              AND    i.party_id = t.party_id
                                              AND    i.source_code = c.source_code
                                              AND    r.result_id = i.result_id
                                              AND    r.positive_response_flag = 'Y'
***/
                                             ))
         WHERE  arc_used_for_object = p_object_type
         AND    used_for_object_id = p_object_id;
      ELSE
         AMS_Utility_PVT.error_message ('AMS_DM_UNSUPPORTED_MODEL', 'MODEL_TYPE', l_object_rec.model_type);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      UPDATE /*+ index(AMS_DM_SOURCE AMS_DM_SOURCE_U2) */ ams_dm_source
      SET    target_value = L_NEGATIVE_TARGET_VALUE
      WHERE  arc_used_for_object = p_object_type
      AND    used_for_object_id = p_object_id
      AND    target_value IS NULL;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
   END update_source_target;


   ---------------------------------------------------------------
   PROCEDURE schedule_preview (
      errbuf         OUT NOCOPY VARCHAR2,
      retcode        OUT NOCOPY VARCHAR2,
      p_arc_object   IN VARCHAR2,
      p_object_id    IN NUMBER
   )
   IS
      l_return_status   VARCHAR2(1);
      l_msg_count       NUMBER;
   BEGIN
      retcode := 0;

      Preview_Selections (
         p_arc_object      => p_arc_object,
         p_object_id       => p_object_id,
         x_return_status   => l_return_status
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         FOR i IN 1 .. l_msg_count LOOP
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => p_arc_object,
               p_log_used_by_id  => p_object_id,
               p_msg_data        => FND_MSG_PUB.get(i, FND_API.g_false),
               p_msg_type        => 'ERROR'
            );
         END LOOP;
         retcode := 2;
      END IF;

      -- write a complete message to log
      AMS_Utility_PVT.create_log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => p_arc_object,
         p_log_used_by_id  => p_object_id,
         p_msg_data        => 'Schedule Preview: COMPLETE',
         p_msg_type        => 'INFO'
      );
   END schedule_preview;


   ---------------------------------------------------------------
   PROCEDURE schedule_aggregation (
      errbuf         OUT NOCOPY VARCHAR2,
      retcode        OUT NOCOPY VARCHAR2,
      p_arc_object   IN VARCHAR2,
      p_object_id    IN NUMBER
   )
   IS
      l_return_status   VARCHAR2(1);
      l_msg_count       NUMBER;
   BEGIN
      retcode := 0;

      Aggregate_Selections (
         p_arc_object      => p_arc_object,
         p_object_id       => p_object_id,
         x_return_status   => l_return_status
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         FOR i IN 1 .. l_msg_count LOOP
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => p_arc_object,
               p_log_used_by_id  => p_object_id,
               p_msg_data        => FND_MSG_PUB.get(i, FND_API.g_false)
            );
         END LOOP;
         retcode := 2;
      END IF;
   END schedule_aggregation;


   ---------------------------------------------------------------
   -- History
   -- 03-Mar-2001 choang   Created.
   ---------------------------------------------------------------
   PROCEDURE apply_sizing_options (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_SELECTION_TYPE_STANDARD  CONSTANT VARCHAR2(30) := 'STANDARD';
      L_SELECTION_TYPE_NTH_ROW   CONSTANT VARCHAR2(30) := 'NTH_RECORD';
      L_SELECTION_TYPE_PCT       CONSTANT VARCHAR2(30) := 'RANDOM';

      l_total_records   NUMBER;

      l_min_records     NUMBER;
      l_max_records     NUMBER;
      l_row_selection_type    VARCHAR2(30);
      l_every_nth_row   NUMBER;
      l_pct_random      NUMBER;

      CURSOR c_model_details (p_model_id IN NUMBER) IS
         SELECT min_records,
                max_records,
                row_selection_type,
                every_nth_row,
                pct_random
         FROM   ams_dm_models_all_b
         WHERE  model_id = p_model_id
         ;
      CURSOR c_score_details (p_score_id IN NUMBER) IS
         SELECT min_records,
                max_records,
                row_selection_type,
                every_nth_row,
                pct_random
         FROM   ams_dm_scores_all_b
         WHERE  score_id = p_score_id
         ;

      CURSOR c_total_records (p_arc_object IN VARCHAR2, p_object_id IN NUMBER) IS
         SELECT COUNT(*)
--       FROM   ams_dm_inter_source_stg
         FROM   ams_dm_int_src_stg_gt
         WHERE  arc_object_used_by = p_arc_object
         AND    object_used_by_id = p_object_id
         ;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_total_records (p_arc_object_for, p_object_for_id);
      FETCH c_total_records INTO l_total_records;
      CLOSE c_total_records;

      -- get score or model details to be used
      -- in the subsequent processing.
      IF p_arc_object_for = G_OBJECT_TYPE_MODEL THEN
         OPEN c_model_details (p_object_for_id);
         FETCH c_model_details INTO l_min_records, l_max_records, l_row_selection_type, l_every_nth_row, l_pct_random;
         CLOSE c_model_details;
      ELSE
         OPEN c_score_details (p_object_for_id);
         FETCH c_score_details INTO l_min_records, l_max_records, l_row_selection_type, l_every_nth_row, l_pct_random;
         CLOSE c_score_details;
      END IF;

      IF l_total_records < NVL (l_min_records, 0) THEN
         AMS_Utility_PVT.error_message ('AMS_DM_NOT_ENOUGH_RECORDS', 'NUM_RECORDS', l_total_records);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_row_selection_type = L_SELECTION_TYPE_STANDARD THEN
--       UPDATE ams_dm_inter_source_stg
         UPDATE ams_dm_int_src_stg_gt
         SET    enabled_flag = 'Y'
         WHERE  arc_object_used_by = p_arc_object_for
         AND    object_used_by_id = p_object_for_id
         AND    rownum <= NVL (l_max_records, l_total_records)
         ;
--         IF (AMS_DEBUG_HIGH_ON) THEN                  AMS_Utility_PVT.debug_message (l_row_selection_type || ': ' || SQL%ROWCOUNT);         END IF;
      ELSIF l_row_selection_type = L_SELECTION_TYPE_NTH_ROW THEN
         randomize_nth_rows (
            p_arc_object_for  => p_arc_object_for,
            p_object_for_id   => p_object_for_id,
            p_min_rows        => l_min_records,
            p_max_rows        => l_max_records,
            p_total_rows      => l_total_records,
            p_every_nth_row   => l_every_nth_row,
            x_return_status   => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
--         IF (AMS_DEBUG_HIGH_ON) THEN                  AMS_Utility_PVT.debug_message (l_row_selection_type || ': ' || SQL%ROWCOUNT);         END IF;
      ELSIF l_row_selection_type = L_SELECTION_TYPE_PCT THEN
         randomize_by_pct (
            p_arc_object_for  => p_arc_object_for,
            p_object_for_id   => p_object_for_id,
            p_min_rows        => l_min_records,
            p_max_rows        => l_max_records,
            p_total_rows      => l_total_records,
            p_pct_random      => l_pct_random,
            x_return_status   => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
         AMS_Utility_PVT.error_message ('AMS_DM_BAD_SELECTION_TYPE', 'SELECTION_TYPE', l_row_selection_type);
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END apply_sizing_options;


   ---------------------------------------------------------------
   -- History
   -- 03-Mar-2001 choang   Created.
   ---------------------------------------------------------------
   PROCEDURE randomize_by_pct (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      p_min_rows        IN NUMBER,
      p_max_rows        IN NUMBER,
      p_total_rows      IN NUMBER,
      p_pct_random      IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      TYPE id_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

      l_object_ids         id_table_type;
      l_total_random_rows  NUMBER := FLOOR ((p_total_rows * p_pct_random) / 100);

      CURSOR c_randomized_sources (p_arc_object IN VARCHAR2, p_object_id IN NUMBER) IS
         SELECT party_id
--       FROM   ams_dm_inter_source_stg
         FROM   ams_dm_int_src_stg_gt
         WHERE  arc_object_used_by = p_arc_object
         AND    object_used_by_id = p_object_id
         ORDER BY random_generated_num
         ;
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_total_random_rows < NVL (p_min_rows, 0) THEN
         AMS_Utility_PVT.error_message ('AMS_DM_NOT_ENOUGH_RECORDS', 'NUM_RECORDS', l_total_random_rows);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Randomize the records
      -- Seed the random number generator with the Julian
      -- days and seconds representation of sysdate.
      DBMS_RANDOM.initialize (TO_NUMBER (TO_CHAR (SYSDATE, 'DDSSSS')));

--      UPDATE ams_dm_inter_source_stg
      UPDATE ams_dm_int_src_stg_gt
      SET    random_generated_num = DBMS_RANDOM.random
      WHERE  arc_object_used_by = p_arc_object_for
      AND    object_used_by_id = p_object_for_id
      ;

      DBMS_RANDOM.terminate;

      -- Bulk fetch the first l_total_random_rows up to the l_max_rows
      OPEN c_randomized_sources (p_arc_object_for, p_object_for_id);
      FETCH c_randomized_sources BULK COLLECT INTO l_object_ids LIMIT NVL (p_max_rows, l_total_random_rows);
      CLOSE c_randomized_sources;

      -- Bulk update the records ordered by the randomly generated number.
      -- This simulates a random order of the records.
      FORALL i IN l_object_ids.FIRST..l_object_ids.LAST
--         UPDATE ams_dm_inter_source_stg
         UPDATE ams_dm_int_src_stg_gt
         SET    enabled_flag = 'Y'
         WHERE  arc_object_used_by = p_arc_object_for
         AND    object_used_by_id = p_object_for_id
         AND    party_id = l_object_ids(i);
   END randomize_by_pct;


   ---------------------------------------------------------------
   -- History
   -- 03-Mar-2001 choang   Created.
   ---------------------------------------------------------------
   PROCEDURE randomize_nth_rows (
      p_arc_object_for  IN VARCHAR2,
      p_object_for_id   IN NUMBER,
      p_min_rows        IN NUMBER,
      p_max_rows        IN NUMBER,
      p_total_rows      IN NUMBER,
      p_every_nth_row  IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      l_total_random_rows  NUMBER := FLOOR (p_total_rows / p_every_nth_row);

      l_local_max_rows     NUMBER := NVL (p_max_rows, p_total_rows);
   BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_total_random_rows < NVL (p_min_rows, 0) THEN
         AMS_Utility_PVT.error_message ('AMS_DM_NOT_ENOUGH_RECORDS', 'NUM_RECORDS', l_total_random_rows);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- two phase updates
      -- 1) update all records but only set enabled_flag = Y for the nth row
      -- 2) update all records with enabled_flag = Y, but set all records
      --    greater than max to N
--      UPDATE ams_dm_inter_source_stg
      UPDATE ams_dm_int_src_stg_gt
      SET    enabled_flag = DECODE (MOD (rownum, p_every_nth_row), 0, 'Y', 'N')
      WHERE  arc_object_used_by = p_arc_object_for
      AND    object_used_by_id = p_object_for_id
      ;

      -- if total number of randomized rows is less than
      -- or equal to the max requested rows, then no records
      -- need to be updated with N
      IF l_total_random_rows > l_local_max_rows THEN
--         UPDATE ams_dm_inter_source_stg
         UPDATE ams_dm_int_src_stg_gt
         SET    enabled_flag = DECODE (SIGN (l_local_max_rows - rownum), -1, 'N', 'Y')
         WHERE  arc_object_used_by = p_arc_object_for
         AND    object_used_by_id = p_object_for_id
         AND    enabled_flag = 'Y'
         ;
      END IF;
   END randomize_nth_rows;


   ---------------------------------------------------------------
   -- Purpose:
   --    Retrieve the selected fields for model building.
   --
   -- NOTE:
   --    Assume list src type is enabled.
   --
   --    When executing the dynamic SQL, the following fields
   --    must be bound:
   --       p_object_type
   --       p_object_id
   --       p_select_object_type
   --       p_select_object_id
   --
   -- Parameter:
   --    p_object_type
   --    p_object_id
   --    p_select_object_type - ADS is for alternative data source
   --    p_select_object_id - if ADS, then data source ID
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    x_insert_fields
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_insert_fields (
      p_select_object_type IN VARCHAR2,
      p_select_object_id   IN NUMBER,
      p_workbook_owner     IN VARCHAR2,
      p_workbook_name      IN VARCHAR2,
      p_worksheet_name     IN VARCHAR2,
      x_insert_fields      OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2,
      x_pk_field             OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_pk_field (p_list_source_type_id IN NUMBER) IS
         SELECT source_object_name || '.' || source_object_pk_field
         FROM   ams_list_src_types
         WHERE  list_source_type_id = p_list_source_type_id
         ;

      l_source_pk_field    VARCHAR2(61);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      x_insert_fields := ':p_object_type, :p_object_id , :p_select_object_type, ';
      x_insert_fields := x_insert_fields || ':p_select_object_id , ';

      IF p_select_object_type = G_ALTERNATIVE_DATA_SOURCE THEN
         OPEN c_pk_field (p_select_object_id);
         FETCH c_pk_field INTO l_source_pk_field;
         CLOSE c_pk_field;

         x_insert_fields := x_insert_fields || l_source_pk_field;
    x_pk_field := l_source_pk_field;--kbasavar
      ELSIF p_select_object_type = 'LIST' THEN
         x_insert_fields := x_insert_fields || 'e.party_id';
    x_pk_field := 'e.party_id';--kbasavar
      ELSIF p_select_object_type = 'CSCH' THEN
         x_insert_fields := x_insert_fields || 'e.party_id';
    x_pk_field := 'e.party_id';--kbasavar
      ELSIF p_select_object_type = 'CELL' THEN
         x_insert_fields := x_insert_fields || 'aps.party_id';
    x_pk_field := 'aps.party_id';--kbasavar
      ELSIF p_select_object_type = 'DIWB' THEN
         get_customer_field (
            p_workbook_owner_name   => p_workbook_owner,
            p_workbook_name   => p_workbook_name,
            p_worksheet_name  => p_worksheet_name,
            x_customer_field  => l_source_pk_field,
            x_return_status   => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         x_insert_fields := x_insert_fields || l_source_pk_field;
    x_pk_field := l_source_pk_field;--kbasavar
      END IF;
   END get_insert_fields;


   ---------------------------------------------------------------
   -- Purpose:
   --    Get the listing of tables where the data selection
   --    is retrieved.
   --
   -- NOTE:
   --    Assume list src type is enabled.
   --
   -- Parameter:
   --    p_select_object_type - ADS is for alternative data source
   --    p_select_object_id - if ADS, then data source ID
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    x_from_clause
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_from_clause (
      p_select_object_type IN VARCHAR2,
      p_select_object_id   IN NUMBER,
      p_workbook_owner     IN VARCHAR2,
      p_workbook_name      IN VARCHAR2,
      p_worksheet_name     IN VARCHAR2,
      p_is_b2b_custprof      IN BOOLEAN,
      x_from_clause        OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME           CONSTANT VARCHAR2(30) := 'get_from_clause';
      L_FROM_OFFSET        CONSTANT NUMBER := 5;

      CURSOR c_source_object (p_target_id IN NUMBER) IS
         SELECT a.source_object_name||decode(UPPER(a.remote_flag),'Y','@'||a.database_link,'')
    FROM   ams_list_src_types a, ams_dm_targets_b b
    WHERE  a.list_source_type_id = b.data_source_id
    AND    b.target_id = p_target_id
    UNION
    SELECT a.source_object_name||decode(UPPER(a.remote_flag),'Y','@'||a.database_link,'')
         FROM   ams_list_src_types a, ams_dm_target_sources b
         WHERE  a.list_source_type_id = b.data_source_id
         AND    a.enabled_flag = 'Y'
         AND    b.target_id = p_target_id
         AND EXISTS (SELECT 1 FROM ams_list_src_type_assocs c,ams_dm_targets_b d
	             WHERE d.target_id = p_target_id
		     AND c.MASTER_SOURCE_TYPE_ID = d.data_source_id
		     AND c.SUB_SOURCE_TYPE_ID = b.data_source_id
		     AND c.enabled_flag = 'Y')
         ;

      l_source_object      VARCHAR2(151);
      l_from_and_where     VARCHAR2(16000);
      l_found              VARCHAR2(1);
      l_first              VARCHAR2(1) := 'T';
      l_where_pos       NUMBER;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_select_object_type = G_ALTERNATIVE_DATA_SOURCE THEN
         x_from_clause := '';
         OPEN c_source_object (p_select_object_id);
         LOOP
             FETCH c_source_object INTO l_source_object;
         EXIT WHEN c_source_object%NOTFOUND;

         IF l_first = 'F' THEN
             x_from_clause := x_from_clause || ' , ';
         ELSE
              l_first := 'F';
         END IF;
         x_from_clause := x_from_clause || l_source_object;
         END LOOP;
         CLOSE c_source_object;
      ELSIF p_select_object_type = 'LIST' THEN
         IF p_is_b2b_custprof THEN
            x_from_clause := 'ams_list_entries e';
         ELSE
            x_from_clause := 'ams_list_headers_all l, ams_list_entries e';
         END IF;
      ELSIF p_select_object_type = 'CSCH' THEN
         x_from_clause := 'ams_act_lists l, ams_list_entries e';
      ELSIF p_select_object_type = 'CELL' THEN
         x_from_clause := 'ams_party_market_segments aps';
      ELSIF p_select_object_type = 'DIWB' THEN
         get_from_sql (
            p_workbook_owner_name   => p_workbook_owner,
            p_workbook_name   => p_workbook_name,
            p_worksheet_name  => p_worksheet_name,
            x_from_sql        => l_from_and_where,
            x_found           => l_found,
            x_return_status   => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_where_pos := INSTR (UPPER (l_from_and_where), 'WHERE');

         -- no where clause
         IF l_where_pos = 0 THEN
            x_from_clause := SUBSTR (l_from_and_where, L_FROM_OFFSET);
         ELSE
            x_from_clause := SUBSTR (l_from_and_where, L_FROM_OFFSET, l_where_pos - L_FROM_OFFSET);
         END IF;
      END IF;
   END get_from_clause;


   ---------------------------------------------------------------
   -- Purpose:
   --    Get the filter for one selected data source.
   --
   -- Parameter:
   --    p_object_type
   --    p_object_id
   --    p_select_object_type
   --    p_select_object_id
   --    x_where_clause
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_where_clause (
      p_object_type        IN VARCHAR2,
      p_object_id          IN NUMBER,
      p_select_object_type IN VARCHAR2,
      p_select_object_id   IN NUMBER,
      p_workbook_owner     IN VARCHAR2,
      p_workbook_name      IN VARCHAR2,
      p_worksheet_name     IN VARCHAR2,
      p_is_b2b_custprof      IN BOOLEAN,
      x_where_clause       OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'get_where_clause';
      L_WHERE_OFFSET    CONSTANT NUMBER := 6;

      CURSOR c_target_field (p_model_id IN NUMBER) IS
         SELECT ds.source_object_name || '.' || field.source_column_name
         FROM   ams_dm_models_all_b model, ams_dm_targets_b target, ams_list_src_fields field , ams_list_src_types ds
         WHERE  model.model_id = p_model_id
         AND    target.target_id = model.target_id
         AND    field.list_source_field_id = target.source_field_id
         AND    ds.list_source_type_id = target.target_source_id
         ;

      CURSOR c_model_child_ds (p_model_id IN NUMBER) IS
         SELECT source.data_source_id
         FROM   ams_dm_models_all_b model, ams_dm_target_sources source, ams_list_src_types lst
         WHERE  model.model_id = p_model_id
         AND    source.target_id = model.target_id
         AND    lst.list_source_type_id = source.data_source_id
         AND    lst.enabled_flag = 'Y'
         AND EXISTS (SELECT 1 FROM ams_list_src_type_assocs c,ams_dm_targets_b d
	             WHERE d.target_id = model.target_id
		     AND c.MASTER_SOURCE_TYPE_ID = d.data_source_id
		     AND c.SUB_SOURCE_TYPE_ID = source.data_source_id
		     AND c.enabled_flag = 'Y')
         ;

      CURSOR c_score_child_ds (p_score_id IN NUMBER) IS
         SELECT source.data_source_id
         FROM   ams_dm_scores_all_b score, ams_dm_models_all_b model, ams_dm_target_sources source, ams_list_src_types lst
         WHERE  score.score_id = p_score_id
         AND    model.model_id = score.model_id
         AND    source.target_id = model.target_id
         AND    lst.list_source_type_id = source.data_source_id
         AND    lst.enabled_flag = 'Y'
         AND EXISTS (SELECT 1 FROM ams_list_src_type_assocs c,ams_dm_targets_b d
	             WHERE d.target_id = model.target_id
		     AND c.MASTER_SOURCE_TYPE_ID = d.data_source_id
		     AND c.SUB_SOURCE_TYPE_ID = source.data_source_id
		     AND c.enabled_flag = 'Y')
         ;

      l_perz_filter     VARCHAR2(15000);
      l_relation_cond   VARCHAR2(15000);
      l_composite_relation_cond VARCHAR2(15000) := '';
      l_wb_filter       VARCHAR2(15000);
      l_from_and_where  VARCHAR2(15000);
      l_found           VARCHAR2(1);
      l_where_pos       NUMBER;
      l_child_ds_id     NUMBER;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_select_object_type = G_ALTERNATIVE_DATA_SOURCE THEN
         IF p_object_type = G_OBJECT_TYPE_MODEL THEN
            OPEN c_target_field (p_object_id);
            FETCH c_target_field INTO x_where_clause;
            CLOSE c_target_field;

            x_where_clause := x_where_clause || ' IS NOT NULL ';
         END IF;

         get_perz_filter (
            p_object_type     => p_object_type,
            p_object_id       => p_object_id,
            p_data_source_id  => p_select_object_id,
            x_filter          => l_perz_filter,
            x_return_status   => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_relation_cond := '';
         IF p_object_type = G_OBJECT_TYPE_MODEL THEN
           OPEN c_model_child_ds (p_object_id);
           LOOP
               FETCH c_model_child_ds INTO l_child_ds_id;
               EXIT WHEN c_model_child_ds%NOTFOUND;

               get_related_ds_condition ( p_master_ds_id => p_select_object_id,
                                          p_child_ds_id  => l_child_ds_id,
                                          x_sql_stmt     => l_relation_cond);
               IF LENGTH(l_composite_relation_cond) > 0 THEN
                  l_composite_relation_cond := l_composite_relation_cond || ' AND ';
               END IF;
               l_composite_relation_cond := l_composite_relation_cond || l_relation_cond;
           END LOOP;
           CLOSE c_model_child_ds;
	 ELSE
           OPEN c_score_child_ds (p_object_id);
           LOOP
               FETCH c_score_child_ds INTO l_child_ds_id;
               EXIT WHEN c_score_child_ds%NOTFOUND;

               get_related_ds_condition ( p_master_ds_id => p_select_object_id,
                                          p_child_ds_id  => l_child_ds_id,
                                          x_sql_stmt     => l_relation_cond);
               IF LENGTH(l_composite_relation_cond) > 0 THEN
                  l_composite_relation_cond := l_composite_relation_cond || ' AND ';
               END IF;
               l_composite_relation_cond := l_composite_relation_cond || l_relation_cond;
           END LOOP;
           CLOSE c_score_child_ds;
	 END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' :: relation condition : ' || l_composite_relation_cond);
         END IF;

         get_wb_filter (
            p_workbook_owner  => p_workbook_owner,
            p_workbook_name   => p_workbook_name,
            p_worksheet_name  => p_worksheet_name,
            x_filter          => l_wb_filter,
            x_return_status   => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF l_perz_filter IS NOT NULL THEN
            IF x_where_clause IS NOT NULL THEN
               x_where_clause := x_where_clause || ' AND ' || l_perz_filter ;
            ELSE
               x_where_clause := l_perz_filter;
            END IF;
         END IF;

         IF LENGTH(l_composite_relation_cond) > 0 THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (L_API_NAME || ' :: relation condition being appended to where clause :: ' || l_composite_relation_cond);
            END IF;
            IF x_where_clause IS NOT NULL THEN
               x_where_clause := x_where_clause || ' AND ' || l_composite_relation_cond ;
            ELSE
               x_where_clause := l_composite_relation_cond;
            END IF;
         END IF;

         IF l_wb_filter IS NOT NULL THEN
            IF x_where_clause IS NOT NULL THEN
               x_where_clause := x_where_clause || ' AND ' || l_wb_filter ;
            ELSE
               x_where_clause := l_wb_filter;
            END IF;
         END IF;

         --IF l_perz_filter IS NOT NULL AND l_wb_filter IS NOT NULL THEN
         --   x_where_clause := x_where_clause || ' AND ' || l_perz_filter || ' AND ' || l_wb_filter;
         --ELSIF l_perz_filter IS NOT NULL AND l_wb_filter IS NULL THEN
         --   x_where_clause := x_where_clause || ' AND ' || l_perz_filter;
         --ELSIF l_perz_filter IS NULL AND l_wb_filter IS NOT NULL THEN
         --   x_where_clause := x_where_clause || ' AND ' || l_wb_filter;
         --END IF;
      ELSIF p_select_object_type = 'LIST' THEN
         IF p_is_b2b_custprof  THEN
            x_where_clause := 'e.list_header_id = :list_header_id ' ||
                               'AND e.enabled_flag = ''Y''';
         ELSE
            x_where_clause := 'l.list_header_id = :list_header_id ' ||
                               'AND e.list_header_id = l.list_header_id ' ||
                               'AND e.enabled_flag = ''Y''';
         END IF;
      ELSIF p_select_object_type = 'CSCH' THEN
         x_where_clause := 'l.list_used_by = ''CSCH'' ' ||
                           'AND l.list_used_by_id = :incl_object_id ' ||
                           'AND l.list_act_type = ''TARGET'' ' ||
                           'AND e.list_header_id = l.list_header_id ' ||
                           'AND e.enabled_flag = ''Y''';
      ELSIF p_select_object_type = 'CELL' THEN
         x_where_clause := 'aps.market_segment_id = :object_id';
      ELSIF p_select_object_type = 'DIWB' THEN
	 get_wb_filter (
            p_workbook_owner  => p_workbook_owner,
            p_workbook_name   => p_workbook_name,
            p_worksheet_name  => p_worksheet_name,
            x_filter          => l_from_and_where,
            x_return_status   => x_return_status
         );
	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

	 x_where_clause := l_from_and_where;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' :: where clause :: ' || x_where_clause);
      END IF;
   END get_where_clause;


   ---------------------------------------------------------------
   -- Purpose:
   --    Get filter conditions based on saved filters
   --    using the personzliation framework.
   --
   -- Note:
   --    Parameter_name in advanced filter is saved
   --    as the list source field id, so the id
   --    needs to be de-referenced to get the filter
   --    column name.
   --
   -- Parameter:
   --    p_object_type
   --    p_object_id
   --    x_filter
   --    x_return_status      OUT VARCHAR2
   ---------------------------------------------------------------
   PROCEDURE get_perz_filter (
      p_object_type     IN VARCHAR2,
      p_object_id       IN NUMBER,
      p_data_source_id  IN NUMBER,
      x_filter          OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'get_perz_filter';

      l_filters_tab        AMS_Adv_Filter_PVT.filter_rec_tbl_type;
      l_column_name        VARCHAR2(30);

      l_msg_count          NUMBER;
      l_msg_data           VARCHAR2(4000);
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      AMS_Adv_Filter_PVT.get_filter_data (
         p_objType       => p_object_type,
         p_objectId      => p_object_id,
         p_dataSourceId  => p_data_source_id,
         x_return_status => x_return_status,
         x_msg_count     => l_msg_count,
         x_msg_data      => l_msg_data,
         x_filters       => l_filters_tab
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_filters_tab.COUNT = 0 THEN
         x_filter := NULL;
         RETURN;
      END IF;

      --
      -- initialize the filter, so the result is like
      --    - filter a
      --    - in the loop
      --      AND filter b AND filter c...
      x_filter := l_filters_tab(1).parameter_name || ' ' || l_filters_tab(1).parameter_condition || ' ''' || l_filters_tab(1).parameter_value || '''';
      FOR i IN 2..l_filters_tab.COUNT LOOP
         x_filter := x_filter || ' AND ' || l_filters_tab(i).parameter_name || ' ' || l_filters_tab(i).parameter_condition || ' ''' || l_filters_tab(i).parameter_value || '''';
      END LOOP;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' :: perz filter : ' || x_filter);
      END IF;
   END get_perz_filter;


   ---------------------------------------------------------------
   -- Purpose:
   --    Get filter conditions as defined by a Discoverer
   --    worksheet.
   --
   -- NOTE
   --    Discoverer SQL statements could span across multiple
   --    ams_discoverer_sql records.  Must use combination of
   --    owner, workbook, and worksheet to query table for
   --    complete sql statement.
   --
   -- Parameter:
   --    p_workbook_owner
   --    p_workbook_name
   --    p_worksheet_name
   --    x_filter
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE get_wb_filter (
      p_workbook_owner  IN VARCHAR2,
      p_workbook_name   IN VARCHAR2,
      p_worksheet_name  IN VARCHAR2,
      x_filter          OUT NOCOPY VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'get_wb_filter';
      L_WHERE_OFFSET    CONSTANT NUMBER := 6;

      l_from_and_where  VARCHAR2(16000);
      l_found           VARCHAR2(1);
      l_where_pos       NUMBER;
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_workbook_owner IS NULL THEN
         -- no workbook filter selected
         x_filter := NULL;
         RETURN;
      END IF;

      get_from_sql (
         p_workbook_owner_name   => p_workbook_owner,
         p_workbook_name   => p_workbook_name,
         p_worksheet_name  => p_worksheet_name,
         x_from_sql        => l_from_and_where,
         x_found           => l_found,
         x_return_status   => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_where_pos := INSTR (UPPER (l_from_and_where), 'WHERE');
      -- get the filter condition only if where clause is specified
      IF l_where_pos <> 0 THEN
         x_filter := SUBSTR (l_from_and_where, l_where_pos + L_WHERE_OFFSET);
      END IF;
   END get_wb_filter;


   ---------------------------------------------------------------
   -- Purpose:
   --    Get Target Positive Values
   --
   -- Note:
   --    A Data Mining Target field may have multiple positive
   --    target values defined in AMS_DM_TARGET_VALUES_B along with
   --    value comparison conditions. For example, the target column
   --    is considered positive if it is >= 10 AND <= 20
   --    This procedure constructs the sql statement that combines all
   --    positive values defined for the target..
   --
   -- Parameter:
   --    p_target_id       IN NUMBER
   --    p_target_field    IN  VARCHAR2
   --    x_sql_stmt        OUT VARCHAR2
   ---------------------------------------------------------------
   PROCEDURE get_target_positive_values (
      p_target_id          IN NUMBER,
      p_target_field       IN VARCHAR2,
      x_sql_stmt           OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'get_target_positive_values';


      CURSOR c_target (p_target_id IN NUMBER) IS
         SELECT target_value,
                target_operator,
                range_value
         FROM ams_dm_target_values_b
         WHERE target_id = p_target_id;

      l_target_rec         c_target%ROWTYPE;

      l_str_not_equals     VARCHAR2(4000);
      l_str_filter         VARCHAR2(4000);
   BEGIN
      -- Fetch all the positive target value records for the target
      OPEN c_target(p_target_id);
      LOOP
         FETCH c_target INTO l_target_rec;
         EXIT WHEN c_target%NOTFOUND;

         -- append <> conditions as AND conditions at the end
         IF l_target_rec.target_operator = '<>' THEN
            IF l_str_not_equals IS NULL THEN
               l_str_not_equals := p_target_field || ' ' || l_target_rec.target_operator || ' ''' || l_target_rec.target_value || '''';
            ELSE
               l_str_not_equals := l_str_not_equals || ' AND ' || p_target_field || ' ' || l_target_rec.target_operator || ' ''' || l_target_rec.target_value || '''';
            END IF;
         ELSIF l_target_rec.target_operator = 'BETWEEN' THEN
         --
         -- initialize the sql statement, so the result is like
         --        target_field = x
         --    OR target_field > y
         --    OR target_field <= z
         --    OR target_field between a and b
            DECLARE
               l_low       NUMBER;
               l_high      NUMBER;
            BEGIN
               -- try to convert to numbers to do
               -- between numbers, else use chars
               -- if invalid number exception thrown
               l_low := TO_NUMBER (l_target_rec.target_value);
               l_high := TO_NUMBER (l_target_rec.range_value);

               IF l_str_filter IS NULL THEN
                  l_str_filter := p_target_field || ' ' || l_target_rec.target_operator || ' ' || l_low || ' AND ' || l_high;
               ELSE
                  l_str_filter := l_str_filter || ' OR ' || p_target_field || ' ' || l_target_rec.target_operator || ' ' || l_low || ' AND ' || l_high;
               END IF;
            EXCEPTION
               WHEN VALUE_ERROR THEN
                  IF l_str_filter IS NULL THEN
                     l_str_filter := p_target_field || ' ' || l_target_rec.target_operator || ' ''' || l_target_rec.target_value || ''' AND ''' || l_target_rec.range_value || '''';
                  ELSE
                     l_str_filter := l_str_filter || ' OR ' || p_target_field || ' ' || l_target_rec.target_operator || ' ''' || l_target_rec.target_value || ''' AND ''' || l_target_rec.range_value || '''';
                  END IF;
            END;
         ELSE
            IF l_str_filter IS NULL THEN
               l_str_filter := p_target_field || ' ' || l_target_rec.target_operator || ' ''' || l_target_rec.target_value || '''';
            ELSE
               l_str_filter := l_str_filter || ' OR ' || p_target_field || ' '  || l_target_rec.target_operator || ' ''' || l_target_rec.target_value || '''';
            END IF;
         END IF;
      END LOOP;
      CLOSE c_target;

      IF l_str_not_equals IS NOT NULL AND l_str_filter IS NOT NULL THEN
         x_sql_stmt := '(' || l_str_filter || ') AND (' || l_str_not_equals || ')';
      ELSIF l_str_not_equals IS NULL THEN
         x_sql_stmt := l_str_filter;
      ELSE
         x_sql_stmt := l_str_not_equals;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' :: target positive values: ' || x_sql_stmt);
      END IF;
   END get_target_positive_values;

   ---------------------------------------------------------------
   -- Purpose:
   --    Determine whether a data source attached to
   --    a of model is B2B or B2C.
   --
   -- Parameter:
    --      p_model_id  IN NUMBER
    --      x_is_b2b     OUT BOOLEAN
   ---------------------------------------------------------------

   PROCEDURE is_b2b_data_source (
          p_model_id     IN NUMBER,
          x_is_b2b      OUT NOCOPY BOOLEAN
       )
    IS
       L_API_NAME        VARCHAR2(30) := 'Is B2B Data Source';

       CURSOR c_data_source (p_model_id IN NUMBER) IS
     --SELECT d.SOURCE_TYPE_CODE
     SELECT d.SOURCE_CATEGORY
     FROM   ams_dm_models_all_b m,ams_dm_targets_b t,ams_list_src_types d
     WHERE  m.model_id = p_model_id
     AND    m.target_id = t.target_id
     AND    t.DATA_SOURCE_ID=d.LIST_SOURCE_TYPE_ID;

       --l_ds_code    VARCHAR2(30);
       l_ds_cat     VARCHAR2(30);

    BEGIN
   x_is_b2b := TRUE;

   OPEN c_data_source (p_model_id);
   FETCH c_data_source INTO l_ds_cat;
   CLOSE c_data_source;

   IF SUBSTR(l_ds_cat , 0 , 3) = 'B2C' then
       x_is_b2b := FALSE;
   END IF;

       IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message (L_API_NAME || ' :: '|| p_model_id || ' :: ' || l_ds_cat );
      END IF;


    END is_b2b_data_source;

   ---------------------------------------------------------------
   -- Purpose:
   --    To get the workflow URL.
   --
   -- Parameter:
      --      p_item_key     IN VARCHAR2,
      --      x_monitor_url   OUT NOCOPY VARCHAR2
   ---------------------------------------------------------------

    PROCEDURE get_wf_url (
                  p_item_key     IN VARCHAR2,
             x_monitor_url   OUT NOCOPY VARCHAR2
         )
    IS
      l_item_key   VARCHAR2(240);

    BEGIN
       l_item_key := p_item_key;
       x_monitor_url := wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), AMS_WFMOD_PVT.G_DEFAULT_ITEMTYPE, l_item_key, 'NO');

    END get_wf_url;


   ---------------------------------------------------------------
   -- Purpose:
   --    Get the relation condition between a master data source and given child data source
   --
   -- Note:
   --
   -- Parameter:
   --    p_master_ds_id       IN NUMBER
   --    p_child_ds_id        IN NUMBER
   --    x_sql_stmt           OUT VARCHAR2
   ---------------------------------------------------------------
   PROCEDURE get_related_ds_condition (
      p_master_ds_id          IN NUMBER,
      p_child_ds_id           IN NUMBER,
      x_sql_stmt              OUT NOCOPY VARCHAR2
   )
   IS
      L_API_NAME        CONSTANT VARCHAR2(30) := 'get_related_ds_condition';


      CURSOR c_cond (p_master_ds_id IN NUMBER , p_child_ds_id IN NUMBER) IS
         SELECT a.SOURCE_OBJECT_NAME as CHILD_SOURCE,
         b.SUB_SOURCE_TYPE_PK_COLUMN as CHILD_COLUMN,
         c.SOURCE_OBJECT_NAME as PARENT_SOURCE,
         NVL(b.MASTER_SOURCE_TYPE_PK_COLUMN , c.SOURCE_OBJECT_PK_FIELD) as PARENT_COLUMN
    FROM ams_list_src_types a, ams_list_src_type_assocs b, ams_list_src_types c
         where b.MASTER_SOURCE_TYPE_ID = p_master_ds_id
         and b.SUB_SOURCE_TYPE_ID = p_child_ds_id
    and b.ENABLED_FLAG = 'Y'
         and a.LIST_SOURCE_TYPE_ID=b.SUB_SOURCE_TYPE_ID
         and c.LIST_SOURCE_TYPE_ID = b.MASTER_SOURCE_TYPE_ID
	 and a.enabled_flag = 'Y'
	 and c.enabled_flag = 'Y'
         ;

      l_cond_rec         c_cond%ROWTYPE;
      l_first            VARCHAR2(1) := 'T';
      l_length           NUMBER;

   BEGIN

      -- Fetch all the positive target value records for the target
      OPEN c_cond(p_master_ds_id , p_child_ds_id);
      LOOP
         FETCH c_cond INTO l_cond_rec;
         EXIT WHEN c_cond%NOTFOUND;

    IF l_first = 'F' THEN
       x_sql_stmt := x_sql_stmt || ' AND ';
    END IF;
    x_sql_stmt := x_sql_stmt || l_cond_rec.CHILD_SOURCE || '.' || l_cond_rec.CHILD_COLUMN || ' = ' || l_cond_rec.PARENT_SOURCE || '.' || l_cond_rec.PARENT_COLUMN;

    l_first := 'F';

      END LOOP;
      CLOSE c_cond;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' :: relation condition : ' || x_sql_stmt);
      END IF;
   END get_related_ds_condition;

   ---------------------------------------------------------------
   -- Purpose:
   --    Determine whether a target is attached to
   --    a seeded DM data source
   --
   -- Parameter:
    --      p_target_id  IN NUMBER
    --      x_is_seeded  OUT BOOLEAN
   ---------------------------------------------------------------

   PROCEDURE is_target_attached_to_seeded (
          p_target_id     IN NUMBER,
          x_is_seeded     OUT NOCOPY BOOLEAN
       )
    IS
       L_API_NAME        VARCHAR2(30) := 'is_target_attached_to_seeded';

       CURSOR c_data_source (p_target_id IN NUMBER) IS
     SELECT 1
     FROM   ams_dm_targets_b t,ams_list_src_types d
     WHERE  t.target_id = p_target_id
     AND    t.DATA_SOURCE_ID=d.LIST_SOURCE_TYPE_ID
     AND    d.SOURCE_TYPE_CODE = 'AMS_DM_PARTY_ATTRIBUTES_V'
     UNION
     SELECT 1
     FROM   ams_dm_target_sources t,ams_list_src_types d
     WHERE  t.target_id = p_target_id
     AND    t.DATA_SOURCE_ID=d.LIST_SOURCE_TYPE_ID
     AND    d.SOURCE_TYPE_CODE = 'AMS_DM_PARTY_ATTRIBUTES_V'
     ;

       l_dummy   NUMBER;

    BEGIN
   x_is_seeded := FALSE;

   OPEN c_data_source (p_target_id);
   FETCH c_data_source INTO l_dummy;
   CLOSE c_data_source;

   IF l_dummy IS NOT NULL THEN
       x_is_seeded := TRUE;
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (L_API_NAME || ' :: IS SEEDED :: TRUE FOR TARGET ID : '|| to_char(p_target_id));
            END IF;
   END IF;



    END is_target_attached_to_seeded;

   ---------------------------------------------------------------
   -- Purpose:
   --    Determine whether a model is Org Product Affinity
   --
   -- Parameter:
    --      p_model_id  IN NUMBER
    --      x_is_org_prod     OUT BOOLEAN
   ---------------------------------------------------------------

   PROCEDURE is_org_prod_affn (
      p_model_id     IN NUMBER,
      x_is_org_prod      OUT NOCOPY BOOLEAN
   )
   IS
   L_API_NAME        VARCHAR2(30) := 'Is Org Prod Affinity';

   CURSOR c_data_source_type_code (p_model_id IN NUMBER) IS
      SELECT d.source_type_code
      FROM   ams_dm_models_all_b m,ams_dm_targets_b t,ams_list_src_types d
      WHERE  m.model_id = p_model_id
      AND    m.target_id = t.target_id
      AND    t.data_source_id=d.list_source_type_id;

   l_ds_type_code     VARCHAR2(30);

   BEGIN
      x_is_org_prod := FALSE;

      OPEN c_data_source_type_code(p_model_id);
      FETCH c_data_source_type_code INTO l_ds_type_code;
      CLOSE c_data_source_type_code;

      IF l_ds_type_code = 'ORGANIZATION_LIST' then
          x_is_org_prod := TRUE;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message (L_API_NAME || ' :: '|| p_model_id || ' :: ' || l_ds_type_code );
      END IF;

   END is_org_prod_affn;

   ---------------------------------------------------------------
   -- Purpose:
   --    Check the status of selections to ensure that they are
   --    still valid. Only called for seeded models.
   --
   -- NOTE:
   --
   --
   -- Parameter:
   --    p_model_id
   --    p_model_type
   --    p_select_object_type
   --    p_select_object_id
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE validate_selection_status (
         p_model_id                 IN NUMBER,
         p_model_type               IN VARCHAR2,
         p_workbook_owner           IN VARCHAR2,
         p_workbook_name            IN VARCHAR2,
         p_worksheet_name           IN VARCHAR2,
         p_select_object_type       IN VARCHAR2,
         p_select_object_id         IN NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
   )
   IS
   L_API_NAME        VARCHAR2(30) := 'Validate Selection Status';

   CURSOR c_valid_list (p_list_id IN NUMBER) IS
      SELECT list_name, status_code
      FROM   ams_list_headers_vl
      WHERE  list_header_id = p_list_id
      ;

   CURSOR c_valid_cell (p_cell_id IN NUMBER) IS
      SELECT cell_name, status_code
      FROM   ams_cells_vl
      WHERE  cell_id = p_cell_id
      ;

   CURSOR c_discoverer_sql (p_workbook_name IN VARCHAR2,
                            p_worksheet_name IN VARCHAR2,
                            p_workbook_owner_name IN VARCHAR2) IS
      SELECT sql_string, sequence_order
      FROM ams_discoverer_sql
      WHERE workbook_name = p_workbook_name
      AND worksheet_name = p_worksheet_name
      AND workbook_owner_name = p_workbook_owner_name
      ORDER BY sequence_order;

   l_discoverer_sql_rec c_discoverer_sql%ROWTYPE;
   l_sql_string     VARCHAR2(32767)    := '';
   l_list_name      VARCHAR2(300);
   l_status_code    VARCHAR2(30);
   l_cell_name      VARCHAR2(120);

   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_select_object_type = 'LIST' THEN
         OPEN c_valid_list (p_select_object_id);
	 FETCH c_valid_list INTO l_list_name, l_status_code;
	 CLOSE c_valid_list;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' :: Selected List Name : '|| l_list_name || ', Status : ' || l_status_code );
         END IF;

	 IF l_status_code NOT IN ('AVAILABLE','LOCKED') THEN
            AMS_Utility_PVT.error_message ('AMS_DM_LIST_NOT_AVAILABLE', 'LISTNAME', l_list_name);
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
	 END IF;
      ELSIF p_select_object_type = 'CELL' THEN
         OPEN c_valid_cell (p_select_object_id);
	 FETCH c_valid_cell INTO l_cell_name, l_status_code;
	 CLOSE c_valid_cell;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' :: Selected Segment Name : '|| l_cell_name || ', Status : ' || l_status_code );
         END IF;

	 IF l_status_code <> 'AVAILABLE' THEN
            AMS_Utility_PVT.error_message ('AMS_DM_CELL_NOT_AVAILABLE', 'CELLNAME', l_cell_name);
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
	 END IF;
      ELSIF p_select_object_type = 'DIWB' THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' :: Checking Workbook : '|| p_workbook_name || '::' || p_worksheet_name );
         END IF;

         OPEN c_discoverer_sql (p_workbook_name,
                                p_worksheet_name,
                                p_workbook_owner);
         FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
         WHILE c_discoverer_sql%FOUND
         LOOP
            l_sql_string := l_sql_string || l_discoverer_sql_rec.sql_string;
            FETCH c_discoverer_sql INTO l_discoverer_sql_rec;
         END LOOP;
         CLOSE c_discoverer_sql;

         l_sql_string := upper(l_sql_string);
         -- Don't support "order by" and "group by" in query
         -- Check if query has these clauses
         IF instr(l_sql_string, 'ORDER BY') > 0
         OR instr(l_sql_string, 'GROUP BY') > 0
         THEN
            AMS_Utility_PVT.error_message ('AMS_DM_COMPLEX_WORKBOOK_SQL', 'WORKBOOKNAME', p_workbook_name || '::' || p_worksheet_name);
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
         END IF;
      END IF;
   END validate_selection_status;


   ---------------------------------------------------------------
   -- Purpose:
   --    Check the status of product selections for prod affn model to ensure that they are
   --    still valid. Only called for seeded models.
   --
   -- NOTE:
   --
   --
   -- Parameter:
   --    p_model_id
   --    x_return_status
   ---------------------------------------------------------------
   PROCEDURE validate_product_selections (
         p_model_id IN NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
   )
   IS
   L_API_NAME        VARCHAR2(60) := 'Validate Product Affinity Selection Status';

   CURSOR c_cats_for_model (p_model_id IN NUMBER) IS
      SELECT a.category_id, a.inventory_item_id, a.organization_id, a.category_set_id, b.padded_concatenated_segments
      FROM   ams_act_products a, mtl_system_items_kfv b
      WHERE  a.ARC_ACT_PRODUCT_USED_BY = 'MODL'
      AND    a.ACT_PRODUCT_USED_BY_ID  = p_model_id
      AND    a.inventory_item_id = b.inventory_item_id(+)
      AND    a.organization_id = b.organization_id(+)
      AND    a.category_set_id in (select distinct category_set_id from ENI_PROD_DEN_HRCHY_PARENTS_V)
      ;

   CURSOR c_valid_cat (p_cat_id IN NUMBER) IS
      SELECT 1
      FROM   ENI_PROD_DEN_HRCHY_PARENTS_V
      WHERE  category_id = p_cat_id
      AND    (disable_date IS NULL OR disable_date > SYSDATE)
      ;

   CURSOR c_valid_prod (p_cat_id IN NUMBER, p_prod_id IN NUMBER, p_org_id IN NUMBER, p_cat_set_id IN NUMBER) IS
      SELECT 1
      FROM   mtl_system_items_kfv items, mtl_item_categories_v cats
      WHERE  cats.category_id = p_cat_id
      AND    cats.inventory_item_id = p_prod_id
      AND    items.inventory_item_id = p_prod_id
      AND    UPPER(items.INVENTORY_ITEM_STATUS_CODE) <> 'INACTIVE'
      AND    items.organization_id = p_org_id
      AND    cats.organization_id = p_org_id
      AND    cats.category_set_id = p_cat_set_id
      ;

   l_prod_name     VARCHAR2(151);
   l_cat_id        NUMBER;
   l_prod_id       NUMBER;
   l_dummy         NUMBER;
   l_org_id        NUMBER;
   l_cat_set_id    NUMBER;

   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- check for product affinity model that category belongs to the product reporting category set
      -- and product belongs to that category
      OPEN c_cats_for_model (p_model_id);
      LOOP
         FETCH c_cats_for_model INTO l_cat_id, l_prod_id, l_org_id, l_cat_set_id, l_prod_name;
         EXIT WHEN c_cats_for_model%NOTFOUND;
         l_dummy := NULL;
         --validate category stll belongs to the product reporting category set
         OPEN c_valid_cat (l_cat_id);
         FETCH c_valid_cat INTO l_dummy;
         CLOSE c_valid_cat;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' :: Checking category ID: '|| l_cat_id || ' and Product name: ' || l_prod_name);
         END IF;

         IF l_dummy IS NULL THEN
            AMS_Utility_PVT.error_message ('AMS_DM_CAT_NOT_IN_SET');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;

         --check the product still belongs to this category
         IF l_prod_id IS NOT NULL THEN
            l_dummy := NULL;
            OPEN c_valid_prod (l_cat_id, l_prod_id, l_org_id, l_cat_set_id);
            FETCH c_valid_prod INTO l_dummy;
            CLOSE c_valid_prod;

            IF l_dummy IS NULL THEN
               AMS_Utility_PVT.error_message ('AMS_DM_PROD_NOT_IN_CAT', 'PRODNAME', l_prod_name);
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
            END IF;
         END IF;
      END LOOP;
      IF c_cats_for_model%ROWCOUNT = 0 THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' :: Raising error...No categories/products selected.');
         END IF;
         AMS_Utility_PVT.error_message ('AMS_DM_PROD_SEL_EMPTY');
         x_return_status := FND_API.G_RET_STS_ERROR;
         CLOSE c_cats_for_model;
         RETURN;
      END IF;
      CLOSE c_cats_for_model;
   END validate_product_selections;
END AMS_DMSelection_PVT;

/
