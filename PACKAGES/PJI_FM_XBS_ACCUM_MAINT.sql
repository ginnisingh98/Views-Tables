--------------------------------------------------------
--  DDL for Package PJI_FM_XBS_ACCUM_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_XBS_ACCUM_MAINT" AUTHID CURRENT_USER AS
/* $Header: PJIPMNTS.pls 120.7 2006/10/16 15:13:03 degupta noship $ */


PROCEDURE PLAN_DELETE (
    p_fp_version_ids   IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_code         OUT NOCOPY  VARCHAR2 );

PROCEDURE PLAN_DELETE_PVT (
  p_event_id           IN NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_processing_code    OUT NOCOPY  VARCHAR2 );

PROCEDURE PLAN_CREATE (
    p_fp_version_ids   IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_code         OUT NOCOPY  VARCHAR2,
    p_fp_src_version_ids  IN   SYSTEM.pa_num_tbl_type :=SYSTEM.pa_num_tbl_type(),
    p_copy_mode             in varchar2 :=NULL);

PROCEDURE PLAN_UPDATE (
      p_plan_version_id      IN  NUMBER := NULL,
 	x_msg_code             OUT NOCOPY VARCHAR2,
	x_return_status        OUT NOCOPY VARCHAR2 );

PROCEDURE PLAN_UPDATE_PVT (
      p_plan_version_id      IN  NUMBER := NULL
    , x_return_status        OUT NOCOPY VARCHAR2
    , x_processing_code      OUT NOCOPY VARCHAR2 );

PROCEDURE PLAN_UPDATE_ACT_ETC (
      p_plan_wbs_ver_id      IN  NUMBER
    , p_prev_pub_wbs_ver_id  IN  NUMBER := NULL
    ,	x_msg_code             OUT NOCOPY VARCHAR2
    , x_return_status        OUT NOCOPY VARCHAR2 );

PROCEDURE DELETE_SMART_SLICE (
      p_online_flag          IN  VARCHAR2 := 'Y'
    , x_return_status        OUT NOCOPY VARCHAR2 );

PROCEDURE PLAN_UPDATE_PVT_ACT_ETC (
      p_plan_version_id      IN  NUMBER
    , p_prev_pub_version_id IN  NUMBER := NULL
    , x_return_status      OUT NOCOPY VARCHAR2
    , x_processing_code    OUT NOCOPY VARCHAR2);

PROCEDURE FINPLAN_COPY (
    p_source_fp_version_ids   IN SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_dest_fp_version_ids     IN SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_source_fp_version_types IN SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type(),
    p_dest_fp_version_types   IN SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type(),
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_code                OUT NOCOPY  VARCHAR2 );

PROCEDURE PLAN_COPY_PVT (
    p_event_id           IN NUMBER
  , x_return_status      OUT NOCOPY  VARCHAR2
  , x_processing_code    OUT NOCOPY  VARCHAR2);

PROCEDURE PLAN_BASELINE	(
    p_baseline_version_id IN   NUMBER,
    p_new_version_id      IN   NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_code            OUT NOCOPY  VARCHAR2 );

PROCEDURE PLAN_BASELINE_PVT (
    p_event_id           IN  NUMBER
  , x_return_status      OUT NOCOPY  VARCHAR2
  , x_processing_code    OUT NOCOPY  VARCHAR2);

PROCEDURE PLAN_ORIGINAL	(
    p_original_version_id IN   NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_code            OUT NOCOPY  VARCHAR2 );

PROCEDURE PLAN_ORIGINAL_PVT (
    p_event_id IN NUMBER
  , x_return_status      OUT NOCOPY  VARCHAR2
  , x_processing_code OUT NOCOPY  VARCHAR2);

PROCEDURE WBS_MAINT (
    p_new_struct_ver_id    IN  NUMBER,
    p_old_struct_ver_id    IN  NUMBER,
    p_project_id           IN  NUMBER,
    p_publish_flag         IN  VARCHAR2 DEFAULT 'N',
    p_online_flag          IN  VARCHAR2,
    p_calling_context      IN  VARCHAR2 DEFAULT NULL,
    p_rerun_flag           IN  VARCHAR2 :=NULL,
    x_request_id           OUT NOCOPY NUMBER,
    x_processing_code      OUT NOCOPY VARCHAR2,
    x_msg_code             OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_online_flag          OUT NOCOPY VARCHAR2 );

PROCEDURE PRG_CHANGE (
    p_prg_grp_id       IN   NUMBER,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_code         OUT NOCOPY  VARCHAR2 );


PROCEDURE RBS_PUSH (
    p_old_rbs_version_id     IN NUMBER DEFAULT NULL
  , p_new_rbs_version_id     IN NUMBER
  , p_project_id             IN NUMBER DEFAULT NULL
  , p_program_flag           IN VARCHAR2 DEFAULT 'N'
  , x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_code               OUT NOCOPY  VARCHAR2 );


PROCEDURE RBS_DELETE (
    p_rbs_version_id         IN NUMBER
  , p_project_id             IN NUMBER
  , x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_code               OUT NOCOPY  VARCHAR2 );


PROCEDURE maintain_smart_slice (
		  p_rbs_version_id      IN  NUMBER :=NULL,
		  p_plan_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
		  p_wbs_element_id      IN  NUMBER,
		  p_rbs_element_id      IN  NUMBER,
		  p_prg_rollup_flag     IN  VARCHAR2,
		  p_curr_record_type_id IN  NUMBER,
		  p_calendar_type       IN  VARCHAR2,
                  p_wbs_version_id      IN  NUMBER,
                  p_commit              IN  VARCHAR2 := 'Y',
		  p_rbs_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
		  x_msg_count           OUT NOCOPY  NUMBER,
		  x_msg_data            OUT NOCOPY  VARCHAR2,
		  x_return_status       OUT NOCOPY  VARCHAR2);

PROCEDURE PROCESS_PROJ_SUM_CHANGES (
  errbuf                OUT NOCOPY VARCHAR2,
  retcode               OUT NOCOPY VARCHAR2,
  p_event_id            IN         NUMBER,
  p_calling_context     IN  VARCHAR2,
  p_rerun_flag          IN  VARCHAR2 := NULL);

PROCEDURE process_pending_events (
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2 );

PROCEDURE process_pending_plan_updates (
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2 );

PROCEDURE WBS_LOCK_PVT (
  p_event_id      IN NUMBER DEFAULT NULL,
  p_online_flag   IN VARCHAR2,
  p_request_id    IN NUMBER DEFAULT NULL,
  x_lock_mode     OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2 );

PROCEDURE process_plan_events (
  p_project_id          IN  NUMBER,
  p_plan_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
  x_processing_code     OUT NOCOPY  VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2 );

PROCEDURE PRINT_PLAN_VERSION_ID_LIST
( p_fp_version_ids   IN          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type() );

PROCEDURE PRINT_PLAN_VERSION_TYPE_LIST
( p_fp_version_types   IN         SYSTEM.pa_varchar2_30_tbl_type );

PROCEDURE debug_plan_lines; -- So it can be called from summarization also, when needed.

PROCEDURE CREATE_EVENT(p_event_rec IN OUT NOCOPY pa_pji_proj_events_log%ROWTYPE);

END PJI_FM_XBS_ACCUM_MAINT;

 

/
