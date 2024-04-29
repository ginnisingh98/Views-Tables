--------------------------------------------------------
--  DDL for Package PJI_SYSTEM_SETTINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_SYSTEM_SETTINGS_PKG" AUTHID CURRENT_USER AS
/* $Header: PJISYSTS.pls 120.0.12010000.2 2009/07/23 06:30:18 rmandali ship $ */
  PROCEDURE insert_row (
        p_setting_id           IN NUMBER,
        p_pa_period_flag       IN VARCHAR2,
        p_gl_period_flag       IN VARCHAR2,
        p_planamt_alloc_method IN VARCHAR2,
        p_prj_curr_flag        IN VARCHAR2,
        p_projfunc_curr_flag   IN VARCHAR2,
        p_curr_rep_pa_period   IN VARCHAR2,
        p_curr_rep_gl_period   IN VARCHAR2,
        p_curr_rep_ent_period  IN VARCHAR2,
        p_plan_amt_conv_date   IN VARCHAR2,
        p_global_curr1_flag    IN VARCHAR2,  /* Added for Bug 8708651 */
        p_global_curr2_flag    IN VARCHAR2,
        p_txn_curr_flag        IN VARCHAR2, -- Added for bug 4167173
        p_time_phase_flag      IN VARCHAR2,  /* Added for Bug 8708651 */
        p_per_analysis_flag    IN VARCHAR2,  /* Added for Bug 8708651 */
        p_up_process_flag      IN VARCHAR2,  /* Added for Bug 8708651 */
        x_return_status  OUT NOCOPY VARCHAR2,
	x_msg_count      OUT NOCOPY NUMBER,
	x_msg_data       OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE update_row (
        p_setting_id           IN NUMBER,
        p_pa_period_flag       IN VARCHAR2,
        p_gl_period_flag       IN VARCHAR2,
        p_planamt_alloc_method IN VARCHAR2,
        p_prj_curr_flag        IN VARCHAR2,
        p_projfunc_curr_flag   IN VARCHAR2,
        p_curr_rep_pa_period   IN VARCHAR2,
        p_curr_rep_gl_period   IN VARCHAR2,
        p_curr_rep_ent_period  IN VARCHAR2,
        p_plan_amt_conv_date   IN VARCHAR2,
        p_global_curr1_flag    IN VARCHAR2,  /* Added for Bug 8708651 */
        p_global_curr2_flag    IN VARCHAR2,
        p_txn_curr_flag        IN VARCHAR2, -- Added for bug 4167173
        p_time_phase_flag      IN VARCHAR2,  /* Added for Bug 8708651 */
        p_per_analysis_flag    IN VARCHAR2,  /* Added for Bug 8708651 */
        p_up_process_flag      IN VARCHAR2,  /* Added for Bug 8708651 */
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE delete_row (
        p_setting_id   IN NUMBER,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
  ) ;

END; --end package pji_system_settings_pkg

/
