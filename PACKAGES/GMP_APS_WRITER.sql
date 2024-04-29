--------------------------------------------------------
--  DDL for Package GMP_APS_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_APS_WRITER" AUTHID CURRENT_USER AS
/* $Header: GMPAPSWS.pls 120.2.12010000.2 2009/07/02 06:35:15 vpedarla ship $ */

  e_msg           VARCHAR2(8000) := NULL;
  orig_last_update_date DATE := NULL ;

  l_debug         VARCHAR2(1) := NVL(FND_PROFILE.VALUE('GMP_DEBUG_ENABLED'),'N');

PROCEDURE main_process(
  p_batch_id             IN NUMBER,
  p_group_id             IN NUMBER,
  p_header_id            IN NUMBER,
  p_start_date           IN DATE,
  p_end_date             IN DATE,
  p_required_completion  IN DATE,     -- For R12.0
  p_order_priority       IN NUMBER,   -- For R12.0
  p_organization_id      IN NUMBER,   -- For R12.0
  p_eff_id               IN NUMBER,
  p_action_type          IN NUMBER,
  p_creation_date        IN DATE,
  p_user_id              IN NUMBER,
  p_login_id             IN NUMBER,
  return_msg             OUT NOCOPY VARCHAR2,
  return_status          OUT NOCOPY NUMBER) ;

PROCEDURE lock_batch_details(
  pbatch_id          IN  NUMBER,
  pbatch_status      OUT NOCOPY NUMBER,
  pbatch_last_update OUT NOCOPY DATE,
  return_status      OUT NOCOPY NUMBER);

PROCEDURE update_batch_header(
  pbatch_id            IN  NUMBER,
  pstart_date          IN  DATE,
  pend_date            IN  DATE,
  preq_completion_date IN  DATE,    -- For R12.0
  pord_priority        IN  NUMBER,  -- For R12.0
  pbatch_status        IN  NUMBER,
  pfirm_flag           IN  NUMBER,   -- B5897392
  puser_id             IN  NUMBER,
  plogin_id            IN  NUMBER,
  return_status        OUT NOCOPY NUMBER);

PROCEDURE update_materails (
  pbatch_id          IN  NUMBER,
  porganization_id   IN  NUMBER,
  return_status      OUT NOCOPY NUMBER);

PROCEDURE update_batch_steps(
  pbatch_id      IN  NUMBER,
  pstep_no       IN  NUMBER,
  pstep_id       IN  NUMBER,
  pstart_date    IN  DATE,
  pend_date      IN  DATE,
  pdue_date      IN  DATE,     --  B4962912
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER);

PROCEDURE update_step_resources(
  pbatch_id              IN  NUMBER,
  porganization_id       IN  NUMBER,    -- For R12.0
  pstep_resource_id      IN  NUMBER,
  prsrc_usage            IN  NUMBER,
  psequence_dep_usage    IN  NUMBER,    -- For R12.0
  pgme_resource          IN  VARCHAR2,
  paps_resource          IN  VARCHAR2,
  pstart_date            IN  DATE,
  pend_date              IN  DATE,
  pbs_usage_uom          IN  VARCHAR2,  -- Gme UOM code
  passigned_unit         IN  NUMBER,
  paps_data_use          IN  NUMBER,
  psetup_id              IN  NUMBER,    -- For R12.0
  pgroup_sequence_id     IN  NUMBER,    -- For R12.0
  pgroup_sequence_number IN  NUMBER,    -- For R12.0
  pfirm_flag             IN  NUMBER,    -- For R12.0
  pscale_type            IN  NUMBER,    -- For R12.0
  puser_id               IN  NUMBER,
  plogin_id              IN  NUMBER,
  pnew_act_res           OUT NOCOPY NUMBER,
  return_status          OUT NOCOPY NUMBER ) ;

PROCEDURE update_resource_transactions(
  pbatch_id        IN  NUMBER,
  pbstep_rsrc_id   IN  NUMBER,
  porganization_id IN NUMBER,    -- For R12.0
  prsrc_hour       IN  NUMBER,
  paps_resource    IN  VARCHAR2,
  pstart_date      IN  DATE,
  pend_date        IN  DATE,
  puom_code        IN  VARCHAR2,
  prsrc_inst_id    IN  NUMBER,   -- For R12.0 resource_instance_id
  pseq_dep_ind     IN  NUMBER,   -- For R12.0 sequence dependent
  puser_id         IN  NUMBER,
  plogin_id        IN  NUMBER,
  return_status    OUT NOCOPY NUMBER );

PROCEDURE update_batch_activities(
  pbatch_id        IN  NUMBER,
  porganization_id IN  NUMBER,   -- For R12.0
  pstep_id         IN  NUMBER,
  pactivity_id     IN  NUMBER,
  pstart_date      IN  DATE,
  pend_date        IN  DATE,
  puom_hour        IN  VARCHAR2,
  puser_id         IN  NUMBER,
  plogin_id        IN  NUMBER,
  return_status    OUT NOCOPY NUMBER) ;

PROCEDURE validate_structure (
  pfmeff_id         IN NUMBER,
  porganization_id  IN  NUMBER,     -- For R12.0
  pgroup_id         IN NUMBER,
  pheader_id        IN NUMBER,
  struc_size        OUT NOCOPY NUMBER,
  return_status     OUT NOCOPY NUMBER);

PROCEDURE log_message(
  pbuff          IN VARCHAR2);

PROCEDURE time_stamp ;

PROCEDURE update_activity_offsets ( batch_id IN NUMBER) ;

PROCEDURE update_batches;

PROCEDURE Insert_charges (
  pbatch_id     IN NUMBER,
  pgroup_id     IN NUMBER,
  pheader_id    IN NUMBER,
  return_status OUT NOCOPY NUMBER);

PROCEDURE gmp_debug_message(pBUFF IN VARCHAR2);  -- Vpedarla

END gmp_aps_writer;

/
