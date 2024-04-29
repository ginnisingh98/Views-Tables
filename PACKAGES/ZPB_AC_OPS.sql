--------------------------------------------------------
--  DDL for Package ZPB_AC_OPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_AC_OPS" AUTHID CURRENT_USER AS
/* $Header: zpbac.pls 120.9 2007/12/05 12:45:25 mbhat ship $  */

PROCEDURE create_editable_copy (
  published_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  editable_ac_name_in      IN zpb_analysis_cycles.name%TYPE,
  last_updated_by_in       IN zpb_analysis_cycles.last_updated_by%TYPE,
  editable_ac_id_out       OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE create_duplicate_copy (
  published_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  editable_ac_name_in      IN zpb_analysis_cycles.name%TYPE,
  last_updated_by_in       IN zpb_analysis_cycles.last_updated_by%TYPE,
  ac_business_area_in      IN zpb_analysis_cycles.business_area_id%TYPE,
  is_comments_copied       IN VARCHAR2 default 'true',
  is_analy_excep_copied    IN VARCHAR2 default 'true',
  editable_ac_id_out       OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE create_new_cycle (
  ac_name_in               IN zpb_analysis_cycles.name%TYPE,
  ac_owner_id_in           IN zpb_analysis_cycles.owner_id%TYPE,
  ac_business_area_in      IN zpb_business_areas.business_area_id%TYPE,
  tmp_ac_id_out            OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE create_new_instance (
  ac_id_in                 IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
  instance_ac_id_out       OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE create_tmp_cycle (
  editable_ac_id_in        IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  tmp_ac_id_out            OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE delete_ac (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  delete_tasks             IN VARCHAR2 default FND_API.G_TRUE);

PROCEDURE delete_published_ac (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  prev_instance_options_in IN VARCHAR2,
  curr_instance_options_in IN VARCHAR2);

PROCEDURE delete_tmp_ac (
  tmp_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE get_cycle_type (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  cycle_type_out           OUT NOCOPY VARCHAR2);

PROCEDURE get_cycle_status (
  ac_id_in              IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  cycle_status_out        OUT NOCOPY VARCHAR2);

PROCEDURE get_lock_value (
  ac_id_in              IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  lock_value_out        OUT NOCOPY NUMBER);

PROCEDURE lock_cycle (
  editable_ac_id_in        IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  user_id_in               IN zpb_analysis_cycles.locked_by%TYPE,
  locked_by_id_out         OUT NOCOPY zpb_analysis_cycles.locked_by%TYPE);

PROCEDURE mark_cycle_for_delete (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  prev_instance_options_in IN VARCHAR2,
  curr_instance_options_in IN VARCHAR2);

PROCEDURE publish_cycle (
  editable_ac_id_in        IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  published_by_in          IN zpb_analysis_cycles.published_by%TYPE,
  publish_options_in       IN VARCHAR2,
  published_ac_id_out      OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

-- overloaded proc to support external publish events
PROCEDURE publish_cycle (
  editable_ac_id_in        IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  published_by_in          IN zpb_analysis_cycles.published_by%TYPE,
  publish_options_in       IN VARCHAR2,
  p_bp_name_in             IN VARCHAR2,
  p_external               IN VARCHAR2,
  p_start_mem_in           IN VARCHAR2 DEFAULT NULL,
  p_end_mem_in             IN VARCHAR2 DEFAULT NULL,
  p_send_date_in           IN DATE DEFAULT NULL,
  published_ac_id_out      OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE,
  x_item_key_out           OUT NOCOPY VARCHAR2
);

PROCEDURE save_tmp_cycle (
  tmp_ac_id_in          IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  last_updated_by_in    IN zpb_analysis_cycles.last_updated_by%TYPE,
  lock_val_in           IN zpb_analysis_cycles.locked_by%TYPE,
  lock_ac_id_in         IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2 ,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  editable_ac_id_out    OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE enable_cycle (
  ac_id_in              IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
  enable_status_in      IN  VARCHAR2);

PROCEDURE getEditableCopyID (
        published_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
        editable_ac_id_out  OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

PROCEDURE recoverCycleObjects (
        editable_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
        is_published_out   OUT NOCOPY VARCHAR2);

PROCEDURE getPubIdFromEditId (
        editable_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
        published_ac_id_out  OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE);

FUNCTION isTmpDraftOfPublishedBP(p_tmp_ac_id IN zpb_analysis_cycles.analysis_cycle_id%TYPE) RETURN NUMBER;

FUNCTION getUniqueName(
         p_bus_area_id IN zpb_analysis_cycles.business_area_id%TYPE,
         p_cycle_name  IN varchar2)RETURN VARCHAR;

-- this procedure creates a partial business cycle . It is used as a placeholder
-- for any BP that is migrated.
--
-- it returns 1 output variable
-- x_ac_id: this variable is a number and contains  the analysis_cycle_id
--          of the newly created business process. Note that before checking
--          the value of this output variable, the caller should check the
--          status output variables to ensure that the API was successful.
--          This is as per the Apps standards
--
--
procedure create_partial_cycle (
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 :=  FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER   :=  FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_apps_user_id         in number,
  p_cycle_name           in varchar2,
  p_description          in varchar2,
  p_appended             in varchar2,
  p_calendar_start_type  in varchar2,
  p_calendar_start_member in varchar2,
  p_calendar_start_periods in number,
  p_calendar_start_level in varchar2,
  p_calendar_start_pf    in varchar2,
  p_calendar_end_type    in varchar2,
  p_calendar_end_member  in varchar2,
  p_calendar_end_periods in number,
  p_calendar_end_level   in varchar2,
  p_calendar_end_pf      in varchar2,
  p_model_dimensions     in varchar2,
  p_versions in number,
  x_ac_id out nocopy number
  );

-- this procedure creates a new BP instance. It is used  by the Load process
-- to load any migrated data. It is also tied to the partial business process
-- created by the create_partial_cycle api.
--
--
-- it returns no output variable
--          The caller should  check the status output variables
--          to ensure that the API was successful. This is as per the Apps
--          standards
--
--
procedure create_migrate_inst(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_apps_user_id         in NUMBER,
  p_analysis_cycle_id    in NUMBER,
  p_view_name            in varchar2,
  p_calendar_start_member in varchar2,
  p_calendar_end_member  in varchar2,
  p_dataset              in varchar2,
  p_current_instance     in varchar2);

--
-- The procedure is called to create hierarchy order for a analysis cycle.
--
PROCEDURE Create_Hier_Order
(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN NUMBER
);

--
-- The procedure is to return the instance id based on the value of the
-- APPEND_VIEW parameter of the instance_ac_id
--
-- added for bug 5436923
PROCEDURE Get_VM_instance_id
(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_ac_id_in             IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
  x_vm_instance_id       OUT NOCOPY NUMBER
) ;

END zpb_ac_ops;

/
