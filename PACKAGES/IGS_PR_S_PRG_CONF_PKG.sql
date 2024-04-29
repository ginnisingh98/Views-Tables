--------------------------------------------------------
--  DDL for Package IGS_PR_S_PRG_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_S_PRG_CONF_PKG" AUTHID CURRENT_USER as
/* $Header: IGSQI26S.pls 115.3 2002/11/29 03:20:58 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_ENCUMB_END_DT_ALIAS in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_ENCUMB_END_DT_ALIAS in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_ENCUMB_END_DT_ALIAS in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2,

  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_ENCUMB_END_DT_ALIAS in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_s_control_num IN NUMBER
    )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN varchar2
    );

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_effective_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_apply_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_apply_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_benefit_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_penalty_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_show_cause_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_appeal_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_show_cause_ind IN VARCHAR2 DEFAULT NULL,
    x_apply_before_show_ind IN VARCHAR2 DEFAULT NULL,
    x_appeal_ind IN VARCHAR2 DEFAULT NULL,
    x_apply_before_appeal_ind IN VARCHAR2 DEFAULT NULL,
    x_count_sus_in_time_ind IN VARCHAR2 DEFAULT NULL,
    x_count_exc_in_time_ind IN VARCHAR2 DEFAULT NULL,
    x_calculate_wam_ind IN VARCHAR2 DEFAULT NULL,
    x_calculate_gpa_ind IN VARCHAR2 DEFAULT NULL,
    X_ENCUMB_END_DT_ALIAS in VARCHAR2 DEFAULT NULL,
    X_OUTCOME_CHECK_TYPE in VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PR_S_PRG_CONF_PKG;

 

/