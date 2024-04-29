--------------------------------------------------------
--  DDL for Package AMS_DMSELECTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMSELECTION_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdsls.pls 115.12 2003/12/30 12:36:42 kbasavar ship $ */
---------------------------------------------------------------
-- History
-- 22-Feb-2001 choang   Created.
-- 23-Feb-2001 choang   Added schedule preview and aggregation.
-- 18-Apr-2001 choang   Added semicolon after exit for standards.
-- 27-Oct-2002 choang   added get_target_positive_values to spec.
-- 18-Jul-2003 kbasavar Bug # 3004437. Added is_b2b_data_source
-- 09-Dec-2003 kbasvaar Added is_org_prod_affn for Org Prod Affinity Model
---------------------------------------------------------------

   ---------------------------------------------------------------
   --
   -- Purpose
   --    Populate no_of_rows_used, no_of_rows_targeted
   --    in AMS_LIST_SELECT_ACTIONS for models and scoring
   --    runs.
   --
   -- Parameters
   --    p_object_type - types could be model or scoring run;
   --       MODL and SCOR, respectively.
   --    p_object_id - ID of the object to be previewed.
   -- Note
   --
   ---------------------------------------------------------------
   PROCEDURE Preview_Selections (
      p_arc_object      IN VARCHAR2,
      p_object_id       IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------
   --
   -- Purpose
   --    Consolidate the selections which were made for model
   --    building or scoring to generate a unique list of
   --    parties.
   --
   -- Parameters
   --    p_object_type - types could be model or scoring run;
   --       MODL and SCOR, respectively.
   --    p_object_id - ID of the object to be previewed.
   -- Note
   --
   ---------------------------------------------------------------
   PROCEDURE Aggregate_Selections (
      p_arc_object      IN VARCHAR2,
      p_object_id       IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------
   --
   -- Purpose
   --    Wrapper registered with concurrent manager for
   --    initiating the preview build of model or
   --    score selections.
   --
   -- Parameters
   --    errbuf - standard out variable for conc programs.
   --    retcode - standard out variable for conc programs.
   --    p_arc_object - types could be model or scoring run;
   --       MODL and SCOR, respectively.
   --    p_object_id - ID of the object to be previewed.
   -- Note
   --
   ---------------------------------------------------------------
   PROCEDURE schedule_preview (
      errbuf         OUT NOCOPY VARCHAR2,
      retcode        OUT NOCOPY VARCHAR2,
      p_arc_object   IN VARCHAR2,
      p_object_id    IN NUMBER
   );


   ---------------------------------------------------------------
   --
   -- Purpose
   --    Wrapper registered with concurrent manager for
   --    initiating the aggregation build of model or
   --    score selections.
   --
   -- Parameters
   --    errbuf - standard out variable for conc programs.
   --    retcode - standard out variable for conc programs.
   --    p_arc_object - types could be model or scoring run;
   --       MODL and SCOR, respectively.
   --    p_object_id - ID of the object to be previewed.
   -- Note
   --
   ---------------------------------------------------------------
   PROCEDURE schedule_aggregation (
      errbuf         OUT NOCOPY VARCHAR2,
      retcode        OUT NOCOPY VARCHAR2,
      p_arc_object   IN VARCHAR2,
      p_object_id    IN NUMBER
   );

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
   );

   ---------------------------------------------------------------
   --
   -- Purpose
   --    Checks if the data source attached to the passed
   --    model is B2B or B2C.
   --
   ---------------------------------------------------------------
   PROCEDURE is_b2b_data_source (
      p_model_id     IN NUMBER,
      x_is_b2b      OUT NOCOPY BOOLEAN
   );

   ---------------------------------------------------------------
   --
   -- Purpose
   --    To get the workflow URL
   --
   ---------------------------------------------------------------
   PROCEDURE get_wf_url (
	       p_item_key     IN VARCHAR2,
	       x_monitor_url   OUT NOCOPY VARCHAR2
	    );

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
   );

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
   );

END AMS_DMSelection_PVT;

 

/
