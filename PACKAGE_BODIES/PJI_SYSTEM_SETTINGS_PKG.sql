--------------------------------------------------------
--  DDL for Package Body PJI_SYSTEM_SETTINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_SYSTEM_SETTINGS_PKG" AS
/* $Header: PJISYSTB.pls 120.0.12010000.2 2009/07/23 06:32:43 rmandali ship $ */
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
  ) IS
  BEGIN

  INSERT INTO pji_system_settings (
        SETTING_ID ,
        PA_PERIOD_FLAG ,
        GL_PERIOD_FLAG ,
        PLANAMT_ALLOC_METHOD ,
        PRJ_CURR_FLAG ,
        PROJFUNC_CURR_FLAG ,
        CURR_REP_PA_PERIOD ,
        CURR_REP_GL_PERIOD ,
        CURR_REP_ENT_PERIOD ,
        PLANAMT_CONV_DATE,
        GLOBAL_CURR1_FLAG,     /* Added for Bug 8708651 */
        GLOBAL_CURR2_FLAG,
        TXN_CURR_FLAG,
        TIME_PHASE_FLAG,      /* Added for Bug 8708651 */
        PER_ANALYSIS_FLAG,    /* Added for Bug 8708651 */
        UP_PROCESS_FLAG,      /* Added for Bug 8708651 */
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
  ) VALUES (
        p_SETTING_ID ,
        p_PA_PERIOD_FLAG ,
        p_GL_PERIOD_FLAG ,
        p_PLANAMT_ALLOC_METHOD ,
        p_PRJ_CURR_FLAG ,
        p_PROJFUNC_CURR_FLAG ,
        p_CURR_REP_PA_PERIOD  ,
        p_CURR_REP_GL_PERIOD  ,
        p_CURR_REP_ENT_PERIOD  ,
        p_PLAN_AMT_CONV_DATE ,
        p_global_curr1_flag,  /* Added for Bug 8708651 */
        p_global_curr2_flag,
        p_txn_curr_flag,
        p_time_phase_flag,     /* Added for Bug 8708651 */
        p_per_analysis_flag,   /* Added for Bug 8708651 */
        p_up_process_flag,     /* Added for Bug 8708651 */
        sysdate ,
        fnd_global.user_id ,
        sysdate ,
        fnd_global.user_id ,
        fnd_global.login_id
           ) ;

  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
      RAISE;
  END insert_row;

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
  ) IS
        l_return_status  VARCHAR2(15);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(30);
  BEGIN

  UPDATE pji_system_settings SET
        PA_PERIOD_FLAG = p_PA_PERIOD_FLAG,
        GL_PERIOD_FLAG = p_GL_PERIOD_FLAG,
        PLANAMT_ALLOC_METHOD = p_PLANAMT_ALLOC_METHOD,
        PRJ_CURR_FLAG = p_PRJ_CURR_FLAG,
        PROJFUNC_CURR_FLAG = p_PROJFUNC_CURR_FLAG,
        CURR_REP_PA_PERIOD = p_CURR_REP_PA_PERIOD,
        CURR_REP_GL_PERIOD = p_CURR_REP_GL_PERIOD,
        CURR_REP_ENT_PERIOD = p_CURR_REP_ENT_PERIOD,
        PLANAMT_CONV_DATE = p_PLAN_AMT_CONV_DATE,
        GLOBAL_CURR1_FLAG = p_global_curr1_flag,  /* Added for Bug 8708651 */
        GLOBAL_CURR2_FLAG = p_global_curr2_flag,
        TXN_CURR_FLAG     = p_txn_curr_flag,
        TIME_PHASE_FLAG   = p_time_phase_flag,    /* Added for Bug 8708651 */
        PER_ANALYSIS_FLAG = p_per_analysis_flag,  /* Added for Bug 8708651 */
        UP_PROCESS_FLAG = p_up_process_flag,      /* Added for Bug 8708651 */
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = fnd_global.user_id,
        LAST_UPDATE_LOGIN = fnd_global.login_id;
  IF SQL%ROWCOUNT = 0 THEN
    insert_row(
        p_SETTING_ID , --setting_id would be coming from page as 1
        p_PA_PERIOD_FLAG ,
        p_GL_PERIOD_FLAG ,
        p_PLANAMT_ALLOC_METHOD ,
        p_PRJ_CURR_FLAG ,
        p_PROJFUNC_CURR_FLAG ,
        p_CURR_REP_PA_PERIOD  ,
        p_CURR_REP_GL_PERIOD  ,
        p_CURR_REP_ENT_PERIOD  ,
        p_PLAN_AMT_CONV_DATE,
        p_global_curr1_flag,  /* Added for Bug 8708651 */
        p_global_curr2_flag,
        p_txn_curr_flag,
        p_time_phase_flag,    /* Added for Bug 8708651 */
        p_per_analysis_flag,  /* Added for Bug 8708651 */
        p_up_process_flag,    /* Added for Bug 8708651 */
        l_return_status,
        l_msg_count,
        l_msg_data
              );
  END IF;

  END update_row;

  PROCEDURE delete_row (
        p_setting_id   IN NUMBER,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
  BEGIN


  delete from PJI_SYSTEM_SETTINGS where SETTING_ID = p_SETTING_ID;

  END delete_row;

END; --end package pji_system_settings

/
