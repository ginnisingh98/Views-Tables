--------------------------------------------------------
--  DDL for Package Body IGS_CA_INS_ROLL_CI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_INS_ROLL_CI" AS
/* $Header: IGSCA03B.pls 120.1 2005/08/04 06:37:03 appldev ship $ */

/*****  Bug No :   1956374
        Task   :   Duplicated Procedures and functions
        PROCEDURE  admp_val_apcood_da is removed and reference is changed *****/
/***********************************************************************
--Enh Bug :- 2138560,Change Request for Calendar Instance
--Description to be added in IGS_CA_INST_ALL Table

Who         When                        What
mesriniv    06-DEC-2001                 A DESCRIPTION Column is ADDED in the
                                        Insert Row Procedure
                                        of the package call IGS_CA_INST_PKG
ssawhney    28dec                       GSCC standards change name of
                                        REL_SUP_CI_SEQ_NUM sequence to end in S1
npalanis    23-NOV-2002                 Bug : 2563531
                                        For calendars load , teaching and academic the alternate
                                        code is made unique . In rollover the alternate code of the
                                        previous calendar and the rolled over calendar was retained same
                                        now the alternate code is appended with sequence number
                                        (igs_ca_inst_seq_num_s1) to make it unique
asbala      9-Feb-2004                  ENCR039: New column TERM_INSTRUCTION_TIME of table IGS_CA_INST will also be rolled
                                        over when the calendar is rolled over.
 nsidnaa    9/21/2004                   New function added to rollover retention schedules for a teaching calendar.
 skpandey   4-AUG-2005                  BUG : 4356272
                                        Added parameteric values for SS_DISPLAYED, ADMIN_FLAG, PLANNING_FLAG, SCHEDULE_FLAG in IGS_CA_INST_PKG.INSERT_ROW procedure to
                                        facilitate the adding of new checkboxes to the IGS_CA_INST_ALL table for enabling load calendars for self-service
**************************************************************************/

  l_message_name  VARCHAR2(30);
  l_app           VARCHAR2(50);
  l_msg_txt varchar2(200);
  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_func_name VARCHAR2(80);
  l_roll_seq NUMBER;



    X_ROWID       VARCHAR2(25);

FUNCTION chk_and_roll_ret(p_old_ca_type IN VARCHAR2,
			  p_old_ci_seq_num IN NUMBER,
			  p_old_da_alias IN VARCHAR2,
			  p_old_dai_seq_num IN NUMBER,
			  p_new_ci_seq_num IN NUMBER)
RETURN BOOLEAN
/***********************************************************************
Created by : nsidana
Created on : 9/21/2004
Change History:
Who         When                        What
nsidnaa   9/21/2004                New function added to rollover retention
                                   schedules for a teaching calendar.
**************************************************************************/

AS
 	CURSOR chk_da_used_ret(cp_cal_type VARCHAR2,cp_seq_num NUMBER,cp_dt_alias VARCHAR2,cp_dt_alias_seq_num NUMBER)
	IS
	SELECT tpret.ret_percentage, tpret.ret_amount
	FROM IGS_FI_TP_RET_SCHD tpret
	WHERE teach_cal_type           = cp_cal_type AND
	      teach_ci_sequence_number = cp_seq_num AND
	      dt_alias                 = cp_dt_alias AND
	      dai_sequence_number      = cp_dt_alias_seq_num AND
	      fee_cal_type IS NULL;

        chk_da_used_ret_rec chk_da_used_ret%ROWTYPE;
	lv_rowid ROWID;
	l_ftci_teach_retention_id NUMBER;

BEGIN
  -- Check if the date alias is used in any retention for the calendar being rolled over.

  OPEN chk_da_used_ret(p_old_ca_type,p_old_ci_seq_num,p_old_da_alias,p_old_dai_seq_num);
  FETCH chk_da_used_ret INTO chk_da_used_ret_rec;

  IF (chk_da_used_ret%FOUND)
  THEN
     CLOSE chk_da_used_ret;
    -- Call TBH to insert a record for the retention schedule for the new calendar instance.
        IGS_FI_TP_RET_SCHD_PKG.insert_row(x_rowid                             => lv_rowid,
				         x_ftci_teach_retention_id           => l_ftci_teach_retention_id,
				         x_teach_cal_type                    => p_old_ca_type,
				         x_teach_ci_sequence_number          => p_new_ci_seq_num,
				         x_fee_cal_type                      => null,
				         x_fee_ci_sequence_number            => null,
				         x_fee_type                          => null,
				         x_dt_alias                          => p_old_da_alias,
				         x_dai_sequence_number               => p_old_dai_seq_num,
				         x_ret_percentage                    => chk_da_used_ret_rec.ret_percentage,
				         x_ret_amount                        => chk_da_used_ret_rec.ret_amount,
				         x_mode                              => 'R'
					 );
      RETURN TRUE;

  ELSE

     -- date alias not used in the retention.
     IF (chk_da_used_ret%ISOPEN)
     THEN
       CLOSE chk_da_used_ret;
     END IF;

     RETURN FALSE;

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
   IF l_func_name IS NULL THEN
    l_func_name := 'chk_and_roll_ret';
   END IF;
    App_Exception.Raise_Exception;
END chk_and_roll_ret;

  -- To insert a date alias instance pair as part of the rollover process
  FUNCTION calp_ins_rollvr_daip(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_val_dt_alias IN VARCHAR2 ,
  p_val_dai_sequence_number IN NUMBER ,
  p_val_cal_type IN VARCHAR2 ,
  p_val_ci_sequence_number IN NUMBER ,
  p_daip_related IN boolean ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
  lv_param_values               VARCHAR2(1080);
  BEGIN
        DECLARE
      X_ROWID                   VARCHAR2(25);

        cst_planned                     CONSTANT VARCHAR2(8) := 'PLANNED';
        cst_active                      CONSTANT VARCHAR2(8) := 'ACTIVE';
        cst_inactive                    CONSTANT VARCHAR2(8) := 'INACTIVE';
        v_other_detail                  VARCHAR2(255);
        token1_val                      VARCHAR2(255);
        token2_val                      VARCHAR2(255);
        v_cntr                          NUMBER;
        v_dai_found                     BOOLEAN;
        v_ci_found                      BOOLEAN;
        v_related_dt_alias              IGS_CA_DA_INST_PAIR.related_dt_alias%TYPE;
        v_dt_alias                      IGS_CA_DA_INST_PAIR.DT_ALIAS%TYPE;
        v_derived_cal_status            IGS_CA_STAT.s_cal_status%TYPE;
        v_val_start_dt                  IGS_CA_INST.start_dt%TYPE;
        v_val_end_dt                    IGS_CA_INST.end_dt%TYPE;
        v_dairn_start_dt                IGS_CA_INST.start_dt%TYPE;
        v_dairn_end_dt                  IGS_CA_INST.end_dt%TYPE;
        v_new_dt_alias                  IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_new_dai_sequence_number       IGS_CA_DA_INST.sequence_number%TYPE;
        v_new_cal_type                  IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_new_ci_sequence_number        IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_ins_dt_alias                  IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_ins_dai_sequence_number       IGS_CA_DA_INST.sequence_number%TYPE;
        v_ins_cal_type                  IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_ins_ci_sequence_number        IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_ins_related_dt_alias          IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_ins_related_dai_seq_num       IGS_CA_DA_INST.sequence_number%TYPE;
        v_ins_related_cal_type          IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_ins_related_ci_seq_num        IGS_CA_DA_INST.ci_sequence_number%TYPE;

        CURSOR  c_new_dt_alias_instance(
                        cp_dt_alias IGS_CA_DA_INST_V.DT_ALIAS%TYPE,
                        cp_cal_type IGS_CA_DA_INST_V.CAL_TYPE%TYPE,
                        cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST
                WHERE   DT_ALIAS = cp_dt_alias AND
                        CAL_TYPE = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number;
        CURSOR  c_cal_instance(
                        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_INST
                WHERE   CAL_TYPE = cp_cal_type AND
                        sequence_number = cp_sequence_number;
        CURSOR  c_derived_cal_instance(
                        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_start_dt IGS_CA_INST.start_dt%TYPE,
                        cp_end_dt IGS_CA_INST.end_dt%TYPE) IS
                SELECT  *
                FROM    IGS_CA_INST
                WHERE   CAL_TYPE = cp_cal_type AND
                        start_dt = cp_start_dt AND
                        end_dt   = cp_end_dt;
        CURSOR  c_derived_cal_status(
                        cp_cal_status IGS_CA_STAT.CAL_STATUS%TYPE) IS
                SELECT  *
                FROM    IGS_CA_STAT
                WHERE   CAL_STATUS = cp_cal_status;
        CURSOR  c_s_log_entry_dai(
                        cp_s_log_type IGS_GE_S_LOG_ENTRY.s_log_type%TYPE,
                        cp_creation_dt IGS_GE_S_LOG_ENTRY.creation_dt%TYPE,
                        cp_key IGS_GE_S_LOG_ENTRY.key%TYPE,
                        cp_text IGS_GE_S_LOG_ENTRY.text%TYPE) IS
                SELECT  *
                FROM    IGS_GE_S_LOG_ENTRY
                WHERE   s_log_type = cp_s_log_type
                AND     creation_dt = cp_creation_dt
                AND     key = cp_key
                AND     text = cp_text;
                v_sled_rec            IGS_GE_S_LOG_ENTRY%ROWTYPE;
      CURSOR IGS_GE_S_LOG_ENTRY_CUR is
                        SELECT ROWID
                                FROM    IGS_GE_S_LOG_ENTRY
                                WHERE   s_log_type = gv_log_type
                                AND     creation_dt = gv_log_creation_dt
                                AND     key = gv_log_key
                                AND     text = v_other_detail;
        BEGIN

	  l_prog_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip';
	  l_label      := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.start';

	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_debug_str := 'calp_ins_rollvr_daip : Starting';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,l_roll_seq);
	END IF;

                -- Determine calendar instance match by adding rollover days difference
                -- to start and end dates.
                FOR v_cal_instance_rec IN c_cal_instance(
                                p_val_cal_type,
                                p_val_ci_sequence_number) LOOP
                        IF p_diff_days = 0 THEN
                          v_val_start_dt := add_months(v_cal_instance_rec.start_dt,p_diff_months);
                          v_val_end_dt := add_months(v_cal_instance_rec.end_dt,p_diff_months);
                        ELSE
                          v_val_start_dt := v_cal_instance_rec.start_dt + p_diff_days;
                          v_val_end_dt := v_cal_instance_rec.end_dt + p_diff_days;
                        END IF;
                END LOOP;
                v_ci_found := FALSE;
                v_dai_found := FALSE;
                -- Determine if the date alias instance pair calendar instance exists,
                -- is active, and a date alias match exists.
                FOR v_derived_cal_instance_rec IN c_derived_cal_instance(
                                                p_val_cal_type,
                                                v_val_start_dt,
                                                v_val_end_dt) LOOP
                        v_ci_found := TRUE;
                        -- Obtain system calendar status of derived calendar instance.
                        FOR v_derived_cal_status_rec IN c_derived_cal_status(
                                        v_derived_cal_instance_rec.CAL_STATUS) LOOP
                                v_derived_cal_status := v_derived_cal_status_rec.s_cal_status;
                        END LOOP;
                        v_dai_found := FALSE;
                        v_cntr := 0;
                    IF(v_derived_cal_status  <> cst_inactive) THEN
                         FOR v_new_dt_alias_instance_rec IN c_new_dt_alias_instance(
                                p_val_dt_alias,
                                v_derived_cal_instance_rec.CAL_TYPE,
                                v_derived_cal_instance_rec.sequence_number) LOOP
                        IF v_new_dt_alias_instance_rec.CAL_TYPE = p_cal_type AND
                            v_new_dt_alias_instance_rec.ci_sequence_number = p_ci_sequence_number
                        THEN
                        IF ( v_new_dt_alias_instance_rec.sequence_number = p_val_dai_sequence_number)
                        THEN
                                v_cntr := 1;
                                v_dai_found := TRUE;
                                v_new_dt_alias := v_new_dt_alias_instance_rec.DT_ALIAS;
                                v_new_dai_sequence_number := v_new_dt_alias_instance_rec.sequence_number;
                                v_new_cal_type := v_new_dt_alias_instance_rec.CAL_TYPE;
                        v_new_ci_sequence_number := v_new_dt_alias_instance_rec.ci_sequence_number;
                                EXIT;
                        END IF;
                        ELSE
                                v_cntr := v_cntr + 1;
                                v_dai_found := TRUE;
                                v_new_dt_alias := v_new_dt_alias_instance_rec.DT_ALIAS;
                                v_new_dai_sequence_number := v_new_dt_alias_instance_rec.sequence_number;
                                v_new_cal_type := v_new_dt_alias_instance_rec.CAL_TYPE;
                        v_new_ci_sequence_number := v_new_dt_alias_instance_rec.ci_sequence_number;
                        END IF;
                         END LOOP;
                     END IF;
                END LOOP;
                IF(v_ci_found = FALSE) THEN

                token1_val  :=   p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                                     '|' ||     p_dai_sequence_number||'|' ;

                token2_val  :=  p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||'-'||
                                IGS_GE_DATE.IGSCHAR(v_val_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_REL_CAL_NOT_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN3',p_val_dt_alias);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.no_ci';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);


                        p_message_name := null;
                        RETURN FALSE;
                ELSIF (v_derived_cal_status = cst_inactive) THEN


                token1_val  :=   p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                                     '|' ||     p_dai_sequence_number||'|' ;

                token2_val  :=  p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||'-'||
                                IGS_GE_DATE.IGSCHAR(v_val_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_REL_CAL_INACTIVE');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN3',p_val_dt_alias);
                        v_other_detail:=FND_MESSAGE.GET;

                        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.inactive_ci';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);


                        p_message_name :=null;
                        RETURN FALSE;
                ELSIF (v_dai_found = FALSE) THEN



                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                '|' ||  p_dai_sequence_number||'|';

                token2_val := p_val_dt_alias||'('||p_val_dai_sequence_number||')'||
                ' '||p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt);


                    FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_NO_REL_DTALIAS_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
        v_other_detail:=FND_MESSAGE.GET;


			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.no_dai';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);



                        p_message_name := null;
                        RETURN FALSE;
                ELSIF (v_cntr > 1) THEN

                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                             '|' ||     p_dai_sequence_number||'|' ;

                token2_val := p_val_dt_alias||' '||p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                             '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt)||'.';

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_NON_UNIQUE_REL_DTALIAS');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.multi_dai';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);



                        p_message_name := null;
                        RETURN FALSE;
                END IF;
                IF(p_daip_related) THEN
                        v_ins_dt_alias := p_dt_alias;
                        v_ins_dai_sequence_number := p_dai_sequence_number;
                        v_ins_cal_type := p_cal_type;
                        v_ins_ci_sequence_number := p_ci_sequence_number;
                        v_ins_related_dt_alias := v_new_dt_alias;
                        v_ins_related_dai_seq_num := v_new_dai_sequence_number;
                        v_ins_related_cal_type := v_new_cal_type;
                        v_ins_related_ci_seq_num := v_new_ci_sequence_number;
                ELSE
                        v_ins_dt_alias := v_new_dt_alias;
                        v_ins_dai_sequence_number := v_new_dai_sequence_number;
                        v_ins_cal_type := v_new_cal_type;
                        v_ins_ci_sequence_number := v_new_ci_sequence_number;
                        v_ins_related_dt_alias := p_dt_alias;
                        v_ins_related_dai_seq_num := p_dai_sequence_number;
                        v_ins_related_cal_type := p_cal_type;
                        v_ins_related_ci_seq_num := p_ci_sequence_number;
                END IF;

                IGS_CA_DA_INST_PAIR_PKG.INSERT_ROW(
                        X_ROWID => X_ROWID,
                        X_DT_ALIAS=> v_ins_dt_alias,
                        X_dai_sequence_number => v_ins_dai_sequence_number,
                        X_CAL_TYPE =>v_ins_cal_type,
                        X_ci_sequence_number =>v_ins_ci_sequence_number,
                        X_related_dt_alias =>v_ins_related_dt_alias,
                      X_related_dai_sequence_number => v_ins_related_dai_seq_num,
                      X_related_cal_type => v_ins_related_cal_type,
                        X_related_ci_sequence_number => v_ins_related_ci_seq_num,
                        X_MODE => 'R');
                -- Delete pair IGS_CA_DA discrepancy notes attached to pair
                -- Firstly determine start and end dates of calendar
                FOR v_cal_instance_rec IN c_cal_instance(
                                p_cal_type,
                                p_ci_sequence_number) LOOP
                          v_dairn_start_dt := v_cal_instance_rec.start_dt;
                          v_dairn_end_dt := v_cal_instance_rec.end_dt;
                END LOOP;
                -- Delete IGS_GE_S_LOG_ENTRY for DAIP if it exists.


                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_val_dt_alias||
                '|' ||  p_val_dai_sequence_number||'|';

                token2_val := p_dt_alias||'('||p_dai_sequence_number||')'||
                        ' '||p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                        '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt);


                    FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_NO_REL_DTALIAS_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.multi_dai';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

                OPEN c_s_log_entry_dai(
                        gv_log_type,
                        gv_log_creation_dt,
                        gv_log_key,
                        v_other_detail);
                FETCH c_s_log_entry_dai INTO v_sled_rec;
                IF c_s_log_entry_dai%NOTFOUND THEN
                        CLOSE c_s_log_entry_dai;


                token1_val  :=   p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_val_dt_alias||
                                     '|' ||     p_val_dai_sequence_number||'|' ;

                token2_val  :=  p_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_dairn_start_dt)||
                                        '-'||IGS_GE_DATE.IGSCHAR(v_dairn_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_REL_CAL_NOT_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN3',p_val_dt_alias);
        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.multi_dai';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

                        OPEN c_s_log_entry_dai(
                                gv_log_type,
                                gv_log_creation_dt,
                                gv_log_key,
                                v_other_detail);
                        FETCH c_s_log_entry_dai INTO v_sled_rec;
                        IF c_s_log_entry_dai%NOTFOUND THEN
                                CLOSE c_s_log_entry_dai;
                        ELSE
                              CLOSE c_s_log_entry_dai;


                             for v_IGS_GE_S_LOG_ENTRY_CUR in IGS_GE_S_LOG_ENTRY_CUR loop
                           IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(v_IGS_GE_S_LOG_ENTRY_CUR.ROWID);
                              end loop;


                        END IF;
                ELSE
                 CLOSE c_s_log_entry_dai;


                  for v_IGS_GE_S_LOG_ENTRY_CUR in IGS_GE_S_LOG_ENTRY_CUR loop
                      IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(v_IGS_GE_S_LOG_ENTRY_CUR.ROWID);
                        end loop;


                END IF;
                p_message_name := null;
                RETURN TRUE;
        EXCEPTION
        WHEN OTHERS THEN
  	IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	  l_debug_str := 'DA ='||p_dt_alias||'Seq num ='||(to_char(p_dai_sequence_number))||
	  'Cal Type ='||p_cal_type||'CI Seq num ='||(to_char(p_ci_sequence_number))||
          'Diff Days ='||(to_char(p_diff_days))||'Diff Months ='||(to_char(p_diff_months))||
          'DAI val ='||p_val_dt_alias||'DAI seq num'||(to_char(p_val_dai_sequence_number))||
          'Validating Cal Type ='||p_val_cal_type||'Val CI seq num ='||(to_char(p_val_ci_sequence_number ))||
          'Rollover CI seq num ='||(to_char(p_ci_rollover_sequence_number));
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	END IF;
	   IF l_func_name IS NULL THEN
    	  l_func_name := 'calp_ins_rollvr_daip';
       END IF;
          App_Exception.Raise_Exception;
       END;
     END calp_ins_rollvr_daip;
  --
  -- To insert a dt alias inst offset constraint as part of the rollover.
  FUNCTION calp_ins_roll_daioc(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_offset_cal_type IN VARCHAR2 ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_new_dt_alias IN VARCHAR2 ,
  p_new_dai_sequence_number IN NUMBER ,
  p_new_cal_type IN VARCHAR2 ,
  p_new_ci_sequence_number IN NUMBER ,
  p_new_offset_dt_alias IN VARCHAR2 ,
  p_new_offset_dai_seq_number IN NUMBER ,
  p_new_offset_cal_type IN VARCHAR2 ,
  p_new_offset_ci_seq_number IN NUMBER ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
  BEGIN
        DECLARE
                 X_ROWID                        VARCHAR2(25);

        v_other_detail                  VARCHAR2(255);
        v_ins_dt_alias                  IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_ins_dai_sequence_number       IGS_CA_DA_INST.sequence_number%TYPE;
        v_ins_cal_type                  IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_ins_ci_sequence_number        IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_ins_offset_dt_alias           IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_ins_offset_dai_seq_num        IGS_CA_DA_INST.sequence_number%TYPE;
        v_ins_offset_cal_type           IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_ins_offset_ci_seq_num         IGS_CA_DA_INST.ci_sequence_number%TYPE;
        CURSOR  c_daio_cnstrt(
                        cp_dt_alias IGS_CA_DA_INST_OFCNT.DT_ALIAS%TYPE,
                        cp_dai_sequence_number IGS_CA_DA_INST_OFCNT.dai_sequence_number%TYPE,
                        cp_cal_type IGS_CA_DA_INST_OFCNT.CAL_TYPE%TYPE,
                        cp_ci_sequence_number IGS_CA_DA_INST_OFCNT.ci_sequence_number%TYPE,
                        cp_offset_dt_alias IGS_CA_DA_INST_OFCNT.offset_dt_alias%TYPE,
                        cp_offset_dai_sequence_number
                                IGS_CA_DA_INST_OFCNT.offset_dai_sequence_number%TYPE,
                        cp_offset_cal_type IGS_CA_DA_INST_OFCNT.offset_cal_type%TYPE,
                        cp_offset_ci_sequence_number
                                IGS_CA_DA_INST_OFCNT.offset_ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST_OFCNT
                WHERE   DT_ALIAS = cp_dt_alias AND
                        dai_sequence_number = cp_dai_sequence_number AND
                        CAL_TYPE = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number AND
                        offset_dt_alias = cp_offset_dt_alias AND
                        offset_dai_sequence_number = cp_offset_dai_sequence_number AND
                        offset_cal_type = cp_offset_cal_type AND
                        offset_ci_sequence_number = cp_offset_ci_sequence_number;
        BEGIN
                -- Determine existing date alias instance offset constraints and
                -- create new records based on the rolled DAIO details.
                FOR v_daio_cnstrt_rec IN c_daio_cnstrt(
                                                p_dt_alias,
                                                p_dai_sequence_number,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                p_offset_dt_alias,
                                                p_offset_dai_sequence_number,
                                                p_offset_cal_type,
                                                p_offset_ci_sequence_number) LOOP

                   IGS_CA_DA_INST_OFCNT_PKG.INSERT_ROW(
                              X_ROWID => X_ROWID,
                              X_DT_ALIAS => p_new_dt_alias,
                                X_dai_sequence_number => p_new_dai_sequence_number,
                                X_CAL_TYPE => p_new_cal_type,
                                X_ci_sequence_number => p_new_ci_sequence_number,
                                X_offset_dt_alias => p_new_offset_dt_alias,
                                X_offset_dai_sequence_number => p_new_offset_dai_seq_number,
                                X_offset_cal_type => p_new_offset_cal_type,
                                X_offset_ci_sequence_number => p_new_offset_ci_seq_number,
                                X_S_DT_OFFSET_CONSTRAINT_TYPE => v_daio_cnstrt_rec.S_DT_OFFSET_CONSTRAINT_TYPE,
                                X_constraint_condition => v_daio_cnstrt_rec.constraint_condition,
                                X_constraint_resolution => v_daio_cnstrt_rec.constraint_resolution,
                              X_MODE => 'R');


                END LOOP;
                p_message_name := null;
                RETURN TRUE;
        EXCEPTION
        WHEN OTHERS THEN
		   IF l_func_name IS NULL THEN
             l_func_name := 'calp_ins_roll_daioc';
           END IF;
           App_Exception.Raise_Exception;
        END;
      END calp_ins_roll_daioc;
  --
  -- Validate the adm period IGS_PS_COURSE off option date date alias
  --
  -- Validate adm perd date override should be included in rollover.
  FUNCTION calp_val_apcood_roll(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN --calp_val_apcood_roll
        --This module validates if a date alias instance should roll as
        --defined by IGS_AD_PECRS_OFOP_DT.rollover_inclusion_ind
  DECLARE
        v_apcood_exists         BOOLEAN := FALSE;
        v_apcood_rollover_exists        BOOLEAN := FALSE;
        v_message_name          varchar2(30);
        CURSOR c_apcood  IS
                SELECT  rollover_inclusion_ind
                FROM    IGS_AD_PECRS_OFOP_DT
                WHERE   adm_cal_type            = p_cal_type AND
                        adm_ci_sequence_number  = p_ci_sequence_number AND
                        DT_ALIAS                        = p_dt_alias AND
                        dai_sequence_number     = p_dai_sequence_number;
  BEGIN
        -- Only check dates that are valid for admission period date overrides
        IF IGS_AD_VAL_APCOOD.admp_val_apcood_da(
                p_dt_alias,
                v_message_name) = FALSE THEN
                p_message_name := null;
                RETURN TRUE;
        END IF;
        -- Check  that date is not an admission period date override OR
        -- has been defined as a override, but is not to be included in calendar
        -- rollovers
        FOR v_apcood_rec IN c_apcood LOOP
                v_apcood_exists := TRUE;
                IF v_apcood_rec.rollover_inclusion_ind = 'Y' THEN
                        v_apcood_rollover_exists := TRUE;
                        EXIT;
                END IF;
        END LOOP;
        IF v_apcood_exists THEN
                IF NOT v_apcood_rollover_exists THEN
                        -- Admission Period Date Override is not to be rolled
                        p_message_name := 'IGS_AD_POO_DATE_OVERRIDE';
                        RETURN FALSE;
                END IF;
        END IF;
        p_message_name :=null;
        RETURN TRUE;

  END;
  END calp_val_apcood_roll;
  --
  -- To insert a date alias instance offset as part of the rollover process
  FUNCTION calp_ins_rollvr_daio(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_val_dt_alias IN VARCHAR2 ,
  p_val_dai_sequence_number IN NUMBER ,
  p_val_cal_type IN VARCHAR2 ,
  p_val_ci_sequence_number IN NUMBER ,
  p_daio_offset IN boolean ,
  p_day_offset IN NUMBER ,
  p_week_offset IN NUMBER ,
  p_month_offset IN NUMBER ,
  p_year_offset IN NUMBER ,
  p_ofst_override IN VARCHAR2,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_old_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
   lv_param_values              VARCHAR2(1080);
  BEGIN

        DECLARE
            X_ROWID                     VARCHAR2(25);

        cst_planned                     CONSTANT VARCHAR2(8) := 'PLANNED';
        cst_active                      CONSTANT VARCHAR2(8) := 'ACTIVE';
        cst_inactive                    CONSTANT VARCHAR2(8) := 'INACTIVE';
        v_other_detail                  VARCHAR2(255);
        token1_val                      VARCHAR2(255);
        token2_val                      VARCHAR2(255);
        v_cntr                          NUMBER;
        v_dai_found                     BOOLEAN;
        v_ci_found                      BOOLEAN;
        v_offset_dt_alias                       IGS_CA_DA_INST_OFST.offset_dt_alias%TYPE;
        v_dt_alias                      IGS_CA_DA_INST_OFST.DT_ALIAS%TYPE;
        v_derived_cal_status            IGS_CA_STAT.s_cal_status%TYPE;
        v_val_start_dt                  IGS_CA_INST.start_dt%TYPE;
        v_val_end_dt                    IGS_CA_INST.end_dt%TYPE;
        v_dairn_start_dt                        IGS_CA_INST.start_dt%TYPE;
        v_dairn_end_dt                  IGS_CA_INST.end_dt%TYPE;
        v_new_dt_alias                  IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_new_dai_sequence_number       IGS_CA_DA_INST.sequence_number%TYPE;
        v_new_cal_type                  IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_new_ci_sequence_number        IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_ins_dt_alias                  IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_ins_dai_sequence_number       IGS_CA_DA_INST.sequence_number%TYPE;
        v_ins_cal_type                  IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_ins_ci_sequence_number                IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_ins_offset_dt_alias           IGS_CA_DA_INST.DT_ALIAS%TYPE;
        v_ins_offset_dai_seq_num                IGS_CA_DA_INST.sequence_number%TYPE;
        v_ins_offset_cal_type           IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_ins_offset_ci_seq_num         IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_sled_rec                      IGS_GE_S_LOG_ENTRY%ROWTYPE;
        CURSOR  c_new_dt_alias_instance(
                        cp_dt_alias IGS_CA_DA_INST_V.DT_ALIAS%TYPE,
                        cp_cal_type IGS_CA_DA_INST_V.CAL_TYPE%TYPE,
                        cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST
                WHERE   DT_ALIAS = cp_dt_alias AND
                        CAL_TYPE = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number;
        CURSOR  c_cal_instance(
                        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_INST
                WHERE   CAL_TYPE = cp_cal_type AND
                        sequence_number = cp_sequence_number;
        CURSOR  c_derived_cal_instance(
                        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_start_dt IGS_CA_INST.start_dt%TYPE,
                        cp_end_dt IGS_CA_INST.end_dt%TYPE) IS
                SELECT  *
                FROM    IGS_CA_INST
                WHERE   CAL_TYPE = cp_cal_type AND
                        start_dt = cp_start_dt AND
                        end_dt   = cp_end_dt;
        CURSOR  c_derived_cal_status(
                        cp_cal_status IGS_CA_STAT.CAL_STATUS%TYPE) IS
                SELECT  *
                FROM    IGS_CA_STAT
                WHERE   CAL_STATUS = cp_cal_status;
        CURSOR  c_s_log_entry_dai(
                        cp_s_log_type IGS_GE_S_LOG_ENTRY.s_log_type%TYPE,
                        cp_creation_dt IGS_GE_S_LOG_ENTRY.creation_dt%TYPE,
                        cp_key IGS_GE_S_LOG_ENTRY.key%TYPE,
                        cp_text IGS_GE_S_LOG_ENTRY.text%TYPE) IS
                SELECT  *
                FROM    IGS_GE_S_LOG_ENTRY
                WHERE   s_log_type = cp_s_log_type
                AND     creation_dt = cp_creation_dt
                AND     key = cp_key
                AND     text = cp_text;
         CURSOR IGS_GE_S_LOG_ENTRY_CUR is
                        SELECT ROWID
                                FROM    IGS_GE_S_LOG_ENTRY
                                WHERE   s_log_type = gv_log_type
                                AND     creation_dt = gv_log_creation_dt
                                AND     key = gv_log_key
                                AND     text = v_other_detail;
        BEGIN

	  l_prog_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daio';
	  l_label      := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daio.start';


                -- Determine calendar instance match by adding rollover days difference
                -- to start and end dates.
                FOR v_cal_instance_rec IN c_cal_instance(
                                p_val_cal_type,
                                p_val_ci_sequence_number) LOOP
                        IF p_diff_days = 0 THEN
                          v_val_start_dt := add_months(v_cal_instance_rec.start_dt,p_diff_months);
                          v_val_end_dt := add_months(v_cal_instance_rec.end_dt,p_diff_months);
                        ELSE
                          v_val_start_dt := v_cal_instance_rec.start_dt + p_diff_days;
                          v_val_end_dt := v_cal_instance_rec.end_dt + p_diff_days;
                        END IF;
                END LOOP;
                v_ci_found := FALSE;
                v_dai_found := FALSE;
                -- Determine if the date alias instance offset calendar instance exists,
                -- is active, and a date alias match exists.
                FOR v_derived_cal_instance_rec IN c_derived_cal_instance(
                                                p_val_cal_type,
                                                v_val_start_dt,
                                                v_val_end_dt) LOOP
                        v_ci_found := TRUE;
                        -- Obtain system calendar status of derived calendar instance.
                        FOR v_derived_cal_status_rec IN c_derived_cal_status(
                                        v_derived_cal_instance_rec.CAL_STATUS) LOOP
                                v_derived_cal_status := v_derived_cal_status_rec.s_cal_status;
                        END LOOP;
                        v_dai_found := FALSE;
                        v_cntr := 0;
                    IF(v_derived_cal_status  <> cst_inactive) THEN
                         FOR v_new_dt_alias_instance_rec IN c_new_dt_alias_instance(
                                p_val_dt_alias,
                                v_derived_cal_instance_rec.CAL_TYPE,
                                v_derived_cal_instance_rec.sequence_number) LOOP
                        IF v_new_dt_alias_instance_rec.CAL_TYPE = p_cal_type AND
                            v_new_dt_alias_instance_rec.ci_sequence_number = p_ci_sequence_number
                        THEN
                        IF ( v_new_dt_alias_instance_rec.sequence_number = p_val_dai_sequence_number)
                        THEN
                                v_cntr := 1;
                                v_dai_found := TRUE;
                                v_new_dt_alias := v_new_dt_alias_instance_rec.DT_ALIAS;
                                v_new_dai_sequence_number := v_new_dt_alias_instance_rec.sequence_number;
                                v_new_cal_type := v_new_dt_alias_instance_rec.CAL_TYPE;
                        v_new_ci_sequence_number := v_new_dt_alias_instance_rec.ci_sequence_number;
                                EXIT;
                        END IF;
                        ELSE
                                v_cntr := v_cntr + 1;
                                v_dai_found := TRUE;
                                v_new_dt_alias := v_new_dt_alias_instance_rec.DT_ALIAS;
                                v_new_dai_sequence_number := v_new_dt_alias_instance_rec.sequence_number;
                                v_new_cal_type := v_new_dt_alias_instance_rec.CAL_TYPE;
                        v_new_ci_sequence_number := v_new_dt_alias_instance_rec.ci_sequence_number;
                        END IF;
                         END LOOP;
                     END IF;
                END LOOP;
                IF(v_ci_found = FALSE) THEN

                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                        '|' ||  p_dai_sequence_number||'|';

                token2_val := p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                        '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt);


                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_OFFSET_CAL_NOT_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN3',p_val_dt_alias);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daio.no_caoff';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daio Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);


                        p_message_name := null;
                        RETURN FALSE;
                ELSIF (v_derived_cal_status = cst_inactive) THEN


                token1_val  :=   p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                                     '|' ||     p_dai_sequence_number||'|' ;

                token2_val  :=  p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||'-'||
                                IGS_GE_DATE.IGSCHAR(v_val_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_OFFSET_CAL_INACTIVE');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN3',p_val_dt_alias);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daio.inactive_caoff';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daio Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);


                        p_message_name := null;
                        RETURN FALSE;
                ELSIF (v_dai_found = FALSE) THEN

        token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                '|' ||  p_dai_sequence_number||'|';

                token2_val := p_val_dt_alias||'('||p_val_dai_sequence_number||')'||
                ' '||p_val_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt);


                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_NO_OFFSET_DTALIAS_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daio.no_offda';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daio Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);


                        p_message_name :=null;
                        RETURN FALSE;
                ELSIF (v_cntr > 1) THEN

                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                             '|' ||     p_dai_sequence_number||'|' ;

                token2_val := p_val_dt_alias||' '||p_val_cal_type||
                             ' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                             '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt)||'.';

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_DUP_OFFSET_DTALIAS');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daio.dupp_off';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daio Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

		       IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);



                        p_message_name := null;
                        RETURN FALSE;
                END IF;
                IF(p_daio_offset) THEN
                        v_ins_dt_alias := p_dt_alias;
                        v_ins_dai_sequence_number := p_dai_sequence_number;
                        v_ins_cal_type := p_cal_type;
                        v_ins_ci_sequence_number := p_ci_sequence_number;
                        v_ins_offset_dt_alias := v_new_dt_alias;
                        v_ins_offset_dai_seq_num := v_new_dai_sequence_number;
                        v_ins_offset_cal_type := v_new_cal_type;
                        v_ins_offset_ci_seq_num := v_new_ci_sequence_number;
                ELSE
                        v_ins_dt_alias := v_new_dt_alias;
                        v_ins_dai_sequence_number := v_new_dai_sequence_number;
                        v_ins_cal_type := v_new_cal_type;
                        v_ins_ci_sequence_number := v_new_ci_sequence_number;
                        v_ins_offset_dt_alias := p_dt_alias;
                        v_ins_offset_dai_seq_num := p_dai_sequence_number;
                        v_ins_offset_cal_type := p_cal_type;
                        v_ins_offset_ci_seq_num := p_ci_sequence_number;
                END IF;

              IGS_CA_DA_INST_OFST_PKG.INSERT_ROW(
                  X_ROWID => X_ROWID,
                  X_DT_ALIAS => v_ins_dt_alias,
                        X_dai_sequence_number => v_ins_dai_sequence_number,
                        X_CAL_TYPE => v_ins_cal_type,
                        X_ci_sequence_number => v_ins_ci_sequence_number,
                        X_offset_dt_alias => v_ins_offset_dt_alias,
                        X_offset_dai_sequence_number => v_ins_offset_dai_seq_num,
                        X_offset_cal_type => v_ins_offset_cal_type,
                        X_offset_ci_sequence_number => v_ins_offset_ci_seq_num,
                        X_day_offset => p_day_offset,
                        X_week_offset => p_week_offset,
                        X_month_offset => p_month_offset,
                        X_year_offset => p_year_offset,
                        X_ofst_override => p_ofst_override,
                  X_MODE => 'R');
                -- Insert new date alias instance offset constraints
                IF(p_daio_offset) THEN
                                IF(calp_ins_roll_daioc(
                                        p_dt_alias,
                                p_dai_sequence_number,
                                        p_cal_type,
                                p_old_ci_sequence_number,
                                p_val_dt_alias,
                                p_val_dai_sequence_number,
                                        p_val_cal_type,
                                        p_val_ci_sequence_number,
                                        v_ins_dt_alias,
                                        v_ins_dai_sequence_number,
                                        v_ins_cal_type,
                                        v_ins_ci_sequence_number,
                                        v_ins_offset_dt_alias,
                                        v_ins_offset_dai_seq_num,
                                        v_ins_offset_cal_type,
                                        v_ins_offset_ci_seq_num,
                                p_ci_rollover_sequence_number,
                                        p_message_name) = TRUE) THEN
                                                NULL;
                                END IF;
                ELSE
                                IF(calp_ins_roll_daioc(
                                        p_val_dt_alias,
                                        p_val_dai_sequence_number,
                                        p_val_cal_type,
                                        p_val_ci_sequence_number,
                                        p_dt_alias,
                                p_dai_sequence_number,
                                p_cal_type,
                                p_old_ci_sequence_number,
                                        v_ins_dt_alias,
                                v_ins_dai_sequence_number,
                                        v_ins_cal_type,
                                        v_ins_ci_sequence_number,
                                v_ins_offset_dt_alias,
                                        v_ins_offset_dai_seq_num,
                                        v_ins_offset_cal_type,
                                v_ins_offset_ci_seq_num,
                                p_ci_rollover_sequence_number,
                                        p_message_name) = TRUE) THEN
                                                NULL;
                                END IF;
                END IF;
                -- Delete offset IGS_CA_DA discrepancy notes attached to offset
                -- Firstly determine start and end dates of calendar
                FOR v_cal_instance_rec IN c_cal_instance(
                                p_cal_type,
                                p_ci_sequence_number) LOOP
                          v_dairn_start_dt := v_cal_instance_rec.start_dt;
                          v_dairn_end_dt := v_cal_instance_rec.end_dt;
                END LOOP;
                -- Delete IGS_GE_S_LOG_ENTRY for DAI if it exists.

                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_val_dt_alias||
                '|' || p_val_dai_sequence_number||'|';

                token2_val := p_dt_alias||'('||p_dai_sequence_number||')'||
                                ' '||p_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_val_start_dt)||
                                '-'||IGS_GE_DATE.IGSCHAR(v_val_end_dt);

                    FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_NO_OFFSET_DTALIAS_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.multi_dai';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

                OPEN c_s_log_entry_dai(
                        gv_log_type,
                        gv_log_creation_dt,
                        gv_log_key,
                        v_other_detail);
                FETCH c_s_log_entry_dai INTO v_sled_rec;
                IF c_s_log_entry_dai%NOTFOUND THEN
                        CLOSE c_s_log_entry_dai;


                token1_val := p_cal_type|| '|'||p_ci_sequence_number|| '|' ||p_dt_alias||
                        '|' ||  p_dai_sequence_number||'|';

                token2_val := p_cal_type||' '||IGS_GE_DATE.IGSCHAR(v_dairn_start_dt)||
                        '-'||IGS_GE_DATE.IGSCHAR(v_dairn_end_dt);


                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_OFFSET_CAL_NOT_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN3',p_dt_alias);
        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_daip.multi_dai';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_daip Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

                        OPEN c_s_log_entry_dai(
                                gv_log_type,
                                gv_log_creation_dt,
                                gv_log_key,
                                v_other_detail);
                        FETCH c_s_log_entry_dai INTO v_sled_rec;
                        IF c_s_log_entry_dai%NOTFOUND THEN
                                CLOSE c_s_log_entry_dai;
                        ELSE
                              CLOSE c_s_log_entry_dai;


                  for v_IGS_GE_S_LOG_ENTRY_CUR in IGS_GE_S_LOG_ENTRY_CUR loop
                      IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(v_IGS_GE_S_LOG_ENTRY_CUR.ROWID);
                        end loop;



                        END IF;
                ELSE
                  CLOSE c_s_log_entry_dai;


                  for v_IGS_GE_S_LOG_ENTRY_CUR in IGS_GE_S_LOG_ENTRY_CUR loop
                      IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(v_IGS_GE_S_LOG_ENTRY_CUR.ROWID);
                        end loop;


                END IF;
                p_message_name := null;
                RETURN TRUE;
        EXCEPTION
        WHEN OTHERS THEN
	  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	    l_debug_str := 'Date Alias ='||p_dt_alias||'DAI seq num ='||(to_char(p_dai_sequence_number))||
              		'Cal Type ='||p_cal_type||'CI seq num ='||(to_char(p_ci_sequence_number))||
			'Diff days ='||(to_char(p_diff_days))||'Diff months ='||(to_char(p_diff_months))||
			'DAI val ='||p_val_dt_alias||'DAI seq num ='||(to_char(p_val_dai_sequence_number))||
			'Val Cal Type ='||p_val_cal_type||'Val CI seq num ='||(to_char(p_val_ci_sequence_number))||
			'Day offset'||(to_char(p_day_offset))||'Week offset ='||(to_char(p_week_offset))||'Month offset ='||(to_char(p_month_offset))||
			'Year offset ='||(to_char(p_year_offset))||'Rollover CI seq num ='||(to_char(p_ci_rollover_sequence_number))||
			'Old CI seq num ='||(to_char(p_old_ci_sequence_number));
	    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	  END IF;
       IF l_func_name IS NULL THEN
           l_func_name := 'calp_ins_rollvr_daio';
       END IF;
            App_Exception.Raise_Exception;
        END;
    END calp_ins_rollvr_daio;
  --
  -- To insert a date alias instance as part of the rollover process
  FUNCTION calp_ins_rollvr_dai(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_rollover_cal_type IN VARCHAR2 ,
  p_rollover_ci_sequence_number IN NUMBER ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
   lv_param_values              VARCHAR2(1080);
   BEGIN
        DECLARE
      X_ROWID                   VARCHAR2(25);

        cst_planned                     CONSTANT VARCHAR2(8) := 'PLANNED';
        cst_active                      CONSTANT VARCHAR2(8) := 'ACTIVE';
        cst_inactive                    CONSTANT VARCHAR2(8) := 'INACTIVE';
        v_other_detail                  VARCHAR2(255);
        token1_val                      VARCHAR2(255);
        token2_val                      VARCHAR2(255);
        v_message_name                  varchar2(30);
        v_offset_dt_alias                       IGS_CA_DA_INST_OFST.offset_dt_alias%TYPE;
        v_dt_alias                      IGS_CA_DA_INST_OFST.DT_ALIAS%TYPE;
        v_related_dt_alias                      IGS_CA_DA_INST_PAIR.related_dt_alias%TYPE;
        v_new_dai_dt_alias              IGS_CA_DA_INST_V.DT_ALIAS%TYPE;
        v_new_absolute_val              IGS_CA_DA_INST_V.absolute_val%TYPE;
        v_new_sequence_number           IGS_CA_DA_INST_V.sequence_number%TYPE;
        CURSOR  c_dai_sequence_number IS
                SELECT  IGS_CA_DA_INST_SEQ_NUM_S.nextval
                FROM    DUAL;
        CURSOR  c_dt_alias_instance(
                        cp_cal_type IGS_CA_DA_INST_V.CAL_TYPE%TYPE,
                        cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST
                WHERE   CAL_TYPE = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number;
        CURSOR  c_dt_alias_instance_offset(
                        cp_dt_alias IGS_CA_DA_INST_OFST.DT_ALIAS%TYPE,
                        cp_dai_sequence_number IGS_CA_DA_INST_OFST.dai_sequence_number%TYPE,
                        cp_cal_type IGS_CA_DA_INST_OFST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number IGS_CA_DA_INST_OFST.ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST_OFST
                WHERE   DT_ALIAS = cp_dt_alias AND
                        dai_sequence_number = cp_dai_sequence_number AND
                        CAL_TYPE = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number;
        CURSOR  c_dt_alias_inst_offset_offset(
                cp_dt_alias IGS_CA_DA_INST_OFST.offset_dt_alias%TYPE,
                cp_dai_seq_num IGS_CA_DA_INST_OFST.offset_dai_sequence_number%TYPE,
                cp_cal_type IGS_CA_DA_INST_OFST.offset_cal_type%TYPE,
                cp_ci_seq IGS_CA_DA_INST_OFST.offset_ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST_OFST
                WHERE   offset_dt_alias = cp_dt_alias   AND
                        offset_dai_sequence_number = cp_dai_seq_num AND
                        offset_cal_type = cp_cal_type AND
                        offset_ci_sequence_number = cp_ci_seq;
        CURSOR  c_dt_alias_instance_pair(
                        cp_dt_alias IGS_CA_DA_INST_PAIR.DT_ALIAS%TYPE,
                        cp_dai_sequence_number IGS_CA_DA_INST_PAIR.dai_sequence_number%TYPE,
                        cp_cal_type IGS_CA_DA_INST_PAIR.CAL_TYPE%TYPE,
                        cp_ci_sequence_number IGS_CA_DA_INST_PAIR.ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST_PAIR
                WHERE   DT_ALIAS = cp_dt_alias AND
                        dai_sequence_number = cp_dai_sequence_number AND
                        CAL_TYPE = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number;
        CURSOR  c_dt_alias_inst_pair_pair(
                cp_dt_alias IGS_CA_DA_INST_PAIR.related_dt_alias%TYPE,
                cp_dai_seq_num IGS_CA_DA_INST_PAIR.related_dai_sequence_number%TYPE,
                cp_cal_type IGS_CA_DA_INST_PAIR.related_cal_type%TYPE,
                cp_ci_seq IGS_CA_DA_INST_PAIR.related_ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    IGS_CA_DA_INST_PAIR
                WHERE   related_dt_alias = cp_dt_alias AND
                        related_dai_sequence_number = cp_dai_seq_num AND
                        related_cal_type = cp_cal_type AND
                        related_ci_sequence_number = cp_ci_seq;
        BEGIN

	  l_prog_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_dai';
	  l_label      := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_dai.start';

                -- Rollover date alias instances and their offsets as part of the calendar
                -- instance rollover process. Notes are inserted into IGS_GE_S_LOG_ENTRY
                -- so that if a date alias instance cannot be inserted, it can be reported.
                -- Insert new dt_alias_instances for the calendar instance.
                FOR c_dt_alias_instance_rec IN c_dt_alias_instance(
                                p_cal_type,
                                p_ci_sequence_number) LOOP
                        -- Validate IGS_CA_DA
                     IF IGS_CA_VAL_DAI.calp_val_dai_da(
                        c_dt_alias_instance_rec.DT_ALIAS,
                        p_rollover_cal_type,
                        v_message_name) = FALSE THEN
                        IF v_message_name = 'IGS_CA_DTALIAS_CLOSED' THEN

                        token1_val := p_rollover_cal_type|| '|' ||p_rollover_ci_sequence_number|| '|' ;

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_DTALIAS_INS_CLOSED');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',c_dt_alias_instance_rec.DT_ALIAS);
                        v_other_detail:=FND_MESSAGE.GET;

			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_dai.dai_closed';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_dai Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);
                        ELSIF v_message_name = 'IGS_CA_DTALIAS_CALCAT_NOMATCH' THEN

                        token1_val := p_rollover_cal_type|| '|' ||p_rollover_ci_sequence_number|| '|' ;

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_DTALIAS_CALCAT_MISMATCH');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',c_dt_alias_instance_rec.DT_ALIAS);
                        v_other_detail:=FND_MESSAGE.GET;
			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_dai.calcat';
		           l_debug_str := 'igs_ca_ins_roll_ci.calp_ins_rollvr_dai Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);

                        END IF;
                -- NEW CODE FROM JULIE
                     ELSIF IGS_CA_INS_ROLL_CI.calp_val_apcood_roll(
                        c_dt_alias_instance_rec.DT_ALIAS,
                        c_dt_alias_instance_rec.sequence_number,
                        c_dt_alias_instance_rec.CAL_TYPE,
                        c_dt_alias_instance_rec.ci_sequence_number,
                        v_message_name) = FALSE THEN

        token1_val := p_rollover_cal_type|| '|' ||p_rollover_ci_sequence_number|| '|' ;

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_DT_ADMPRD_OVRIDE_DT');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        v_other_detail:=FND_MESSAGE.GET;

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);

		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
                     v_other_detail := 'CIR' || '|' || 'E' || '|' ||p_rollover_cal_type|| '|' ||
                                p_rollover_ci_sequence_number|| '|' ||'Date alias instance '||
                                'not created because it is an '||'Admission Period override date.';
                fnd_log.string_with_context( fnd_log.level_statement,l_label,v_other_detail, NULL,NULL,NULL,NULL,NULL,l_roll_seq);
		END IF;

                -- END NEW CODE FROM JULIE
                     ELSE -- create IGS_CA_DA_INST
                        v_new_dai_dt_alias := c_dt_alias_instance_rec.DT_ALIAS;
                        v_new_sequence_number := c_dt_alias_instance_rec.sequence_number;
                        IF(c_dt_alias_instance_rec.absolute_val IS NULL) THEN
                                v_new_absolute_val := NULL;
                        ELSE
                                IF p_diff_days = 0 THEN
                                v_new_absolute_val :=
                                    add_months(c_dt_alias_instance_rec.absolute_val,p_diff_months);
                                ELSE
                                v_new_absolute_val := c_dt_alias_instance_rec.absolute_val + p_diff_days;
                                END IF;
                        END IF;
                        -- Get next available IGS_CA_DA instance sequence number
                        /* Use old IGS_CA_DA sequence number for Student Finance functionality */


                   IGS_CA_DA_INST_PKG.INSERT_ROW(
                        X_ROWId => X_ROWID,
                        X_DT_ALIAS => v_new_dai_dt_alias,
                                X_sequence_number => v_new_sequence_number,
                                X_CAL_TYPE => p_rollover_cal_type,
                                X_ci_sequence_number => p_rollover_ci_sequence_number,
                                X_absolute_val => v_new_absolute_val,
                        X_MODE => 'R');

		       -- Call the function to rollover the retention schedules defined in the teaching calendar. Added as part of retention enhancements from SWS side.

			IF (chk_and_roll_ret(p_cal_type,                      -- Cal type being rolled over.
			                     p_ci_sequence_number,            -- Sequence number of calendar instance being rolled over.
					     v_new_dai_dt_alias,              -- Date Alias in the calendar instance being rolled over.
                                             v_new_sequence_number,           -- Sequence number of the data alias. When a DAI is rolled over, the sequence number remains unchanged.
                                             p_rollover_ci_sequence_number    -- Sequence number of the new calendar instance created.
					     ) = TRUE)
			THEN
			  null;
			END IF;


                        -- Offset processing
                        FOR v_dt_alias_instance_offset_rec IN c_dt_alias_instance_offset(
                                        c_dt_alias_instance_rec.DT_ALIAS,
                                        c_dt_alias_instance_rec.sequence_number,
                                        c_dt_alias_instance_rec.CAL_TYPE,
                                        c_dt_alias_instance_rec.ci_sequence_number) LOOP
                                v_offset_dt_alias := v_dt_alias_instance_offset_rec.offset_dt_alias;
                                IF( calp_ins_rollvr_daio(
                                        v_new_dai_dt_alias,
                                        v_new_sequence_number,
                                        p_rollover_cal_type,
                                        p_rollover_ci_sequence_number,
                                        p_diff_days,
                                        p_diff_months,
                                        v_dt_alias_instance_offset_rec.offset_dt_alias,
                                        v_dt_alias_instance_offset_rec.offset_dai_sequence_number,
                                        v_dt_alias_instance_offset_rec.offset_cal_type,
                                        v_dt_alias_instance_offset_rec.offset_ci_sequence_number,
                                        TRUE,
                                        v_dt_alias_instance_offset_rec.day_offset,
                                        v_dt_alias_instance_offset_rec.week_offset,
                                        v_dt_alias_instance_offset_rec.month_offset,
                                        v_dt_alias_instance_offset_rec.year_offset,
                                        v_dt_alias_instance_offset_rec.ofst_override,
                                        p_ci_rollover_sequence_number,
                                        p_ci_sequence_number,  -- needed for DAIOC rollover
                                        v_message_name) = FALSE) THEN
                                                -- Do nothing, since function currently always
                                                -- returns true
                                                NULL;
                                END IF;
                        END LOOP;
                        FOR v_dt_alias_instance_offset_rec IN c_dt_alias_inst_offset_offset(
                                        c_dt_alias_instance_rec.DT_ALIAS,
                                        c_dt_alias_instance_rec.sequence_number,
                                        c_dt_alias_instance_rec.CAL_TYPE,
                                        c_dt_alias_instance_rec.ci_sequence_number) LOOP
                                v_dt_alias := v_dt_alias_instance_offset_rec.DT_ALIAS;
                                IF(calp_ins_rollvr_daio(
                                        v_new_dai_dt_alias,
                                        v_new_sequence_number,
                                        p_rollover_cal_type,
                                        p_rollover_ci_sequence_number,
                                        p_diff_days,
                                        p_diff_months,
                                        v_dt_alias_instance_offset_rec.DT_ALIAS,
                                        v_dt_alias_instance_offset_rec.dai_sequence_number,
                                        v_dt_alias_instance_offset_rec.CAL_TYPE,
                                        v_dt_alias_instance_offset_rec.ci_sequence_number,
                                        FALSE,
                                        v_dt_alias_instance_offset_rec.day_offset,
                                        v_dt_alias_instance_offset_rec.week_offset,
                                        v_dt_alias_instance_offset_rec.month_offset,
                                        v_dt_alias_instance_offset_rec.year_offset,
                                        v_dt_alias_instance_offset_rec.ofst_override,
                                        p_ci_rollover_sequence_number,
                                        p_ci_sequence_number, -- needed for DAIOC rollover
                                        v_message_name) = FALSE) THEN
                                                -- Do nothing, since function currently always
                                                -- returns true
                                                NULL;
                                END IF;
                        END LOOP;
                        -- Dt Alias Instance Pair processing
                        FOR v_dt_alias_instance_pair_rec IN c_dt_alias_instance_pair(
                                        c_dt_alias_instance_rec.DT_ALIAS,
                                        c_dt_alias_instance_rec.sequence_number,
                                        c_dt_alias_instance_rec.CAL_TYPE,
                                        c_dt_alias_instance_rec.ci_sequence_number) LOOP
                                v_related_dt_alias := v_dt_alias_instance_pair_rec.related_dt_alias;
                                IF( calp_ins_rollvr_daip(
                                        v_new_dai_dt_alias,
                                        v_new_sequence_number,
                                        p_rollover_cal_type,
                                        p_rollover_ci_sequence_number,
                                        p_diff_days,
                                        p_diff_months,
                                        v_dt_alias_instance_pair_rec.related_dt_alias,
                                        v_dt_alias_instance_pair_rec.related_dai_sequence_number,
                                        v_dt_alias_instance_pair_rec.related_cal_type,
                                        v_dt_alias_instance_pair_rec.related_ci_sequence_number,
                                        TRUE,
                                        p_ci_rollover_sequence_number,
                                        v_message_name) = FALSE) THEN
                                                -- Do nothing, since function currently always
                                                -- returns true
                                                NULL;
                                END IF;
                        END LOOP;
                        FOR v_dt_alias_instance_pair_rec IN c_dt_alias_inst_pair_pair(
                                        c_dt_alias_instance_rec.DT_ALIAS,
                                        c_dt_alias_instance_rec.sequence_number,
                                        c_dt_alias_instance_rec.CAL_TYPE,
                                        c_dt_alias_instance_rec.ci_sequence_number) LOOP
                                v_dt_alias := v_dt_alias_instance_pair_rec.DT_ALIAS;
                                IF(calp_ins_rollvr_daip(
                                        v_new_dai_dt_alias,
                                        v_new_sequence_number,
                                        p_rollover_cal_type,
                                        p_rollover_ci_sequence_number,
                                        p_diff_days,
                                        p_diff_months,
                                        v_dt_alias_instance_pair_rec.DT_ALIAS,
                                        v_dt_alias_instance_pair_rec.dai_sequence_number,
                                        v_dt_alias_instance_pair_rec.CAL_TYPE,
                                        v_dt_alias_instance_pair_rec.ci_sequence_number,
                                        FALSE,
                                        p_ci_rollover_sequence_number,
                                        v_message_name) = FALSE) THEN
                                                -- Do nothing, since function currently always
                                                -- returns true
                                                NULL;
                                END IF;
                        END LOOP;
                      END IF;
                END LOOP;
                RETURN TRUE;
        EXCEPTION
        WHEN OTHERS THEN

	  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	    l_debug_str := 'Cal Type ='||p_cal_type||'CI seq num ='||(to_char(p_ci_sequence_number))||
			'Diff days ='||(to_char(p_diff_days))||'Diff months ='||(to_char(p_diff_months))||
			'Rollover cal type ='||p_rollover_cal_type||'Rollover CI seq num ='||(to_char(p_rollover_ci_sequence_number))||
			'CI rollover seq num ='||(to_char(p_ci_rollover_sequence_number));
	    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	  END IF;
	     IF l_func_name IS NULL THEN
            l_func_name := 'calp_ins_rollvr_dai';
         END IF;
            App_Exception.Raise_Exception;
        END;
    END calp_ins_rollvr_dai;
  --
  -- To insert a ci relationship as part of the rollover process..
  FUNCTION CALP_INS_ROLLVR_CIR(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_sub_cal_type IN VARCHAR2 ,
  p_sub_ci_sequence_number  NUMBER ,
  p_sup_cal_type IN VARCHAR2 ,
  p_sup_ci_sequence_number IN NUMBER ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
         lv_param_values                VARCHAR2(1080);
        gv_other_detail VARCHAR2(255);
        -------------------------- Used to test the module ------------------------
        -- gv_log_type                  VARCHAR2(8) := 'CAL-ROLL';
        -- gv_log_creation_dt           DATE;
        -- gv_log_key                   VARCHAR2(13) :=  'TEST ROLLOVER';
        ---------------------------------------------------------------------------
  BEGIN -- calp_ins_rollvr_cir
        -- Insert calendar instance relationships as part of the calendar instance
        -- rollover process. This function takes the relationships of the existing
        -- calendar instance and tries to duplicate them for the new calendar
        -- instances. Notes are inserted into IGS_GE_S_LOG_ENTRY so that
        -- relationships that cannot be inserted, can be reported.
        --Insert superior passed. This is the superior passed from CALF0320 and is
        -- validated  in the form logic.
  DECLARE
      X_ROWID                 VARCHAR2(25);

        cst_planned                     CONSTANT VARCHAR2(8) := 'PLANNED';
        cst_active                      CONSTANT VARCHAR2(8) := 'ACTIVE';
        cst_inactive                    CONSTANT VARCHAR2(8) := 'INACTIVE';
        v_derived_cal_type              IGS_CA_INST.CAL_TYPE%TYPE;
        v_derived_start_dt              IGS_CA_INST.start_dt%TYPE;
        v_derived_end_dt                IGS_CA_INST.end_dt%TYPE;
        v_sup_load_res_percentage
                IGS_CA_INST_REL.load_research_percentage%TYPE;
        v_other_detail                  VARCHAR2(255);
        token1_val                      VARCHAR2(255);
        token2_val                      VARCHAR2(255);
        v_dummy                         VARCHAR2(1);
        e_resource_busy         EXCEPTION;
        PRAGMA  EXCEPTION_INIT(e_resource_busy, -54 );
        CURSOR c_cal_inst_rltsp_sup IS
                SELECT  cir.sup_cal_type,
                        cir.sup_ci_sequence_number,
                        cir.load_research_percentage
                FROM    IGS_CA_INST_REL cir
                WHERE   cir.sub_cal_type                = p_cal_type  AND
                        cir.sub_ci_sequence_number      = p_sequence_number;
        CURSOR c_cal_instance(
                        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  ci.start_dt,
                        ci.end_dt,
                        ci.CAL_TYPE
                FROM    IGS_CA_INST ci
                WHERE   ci.CAL_TYPE             = cp_cal_type AND
                        ci.sequence_number      = cp_sequence_number;
        v_cal_inst_rec  c_cal_instance%ROWTYPE;
        CURSOR c_derived_cal_instance(
                        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_start_dt IGS_CA_INST.start_dt%TYPE,
                        cp_end_dt IGS_CA_INST.end_dt%TYPE) IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number,
                        cs.s_cal_status
                FROM    IGS_CA_INST ci,
                        IGS_CA_STAT cs
                WHERE   ci.CAL_TYPE     = cp_cal_type AND
                        ci.start_dt     = cp_start_dt AND
                        ci.end_dt       = cp_end_dt AND
                        ci.CAL_STATUS   = cs.CAL_STATUS;
        v_derived_cal_instance_rec      c_derived_cal_instance%ROWTYPE;
        CURSOR  c_cir(
                cp_sub_cal_type         IGS_CA_INST_REL.sub_cal_type%TYPE,
                cp_sub_ci_sequence_number
                                        IGS_CA_INST_REL.sub_ci_sequence_number%TYPE,
                cp_sup_cal_type         IGS_CA_INST_REL.sup_cal_type%TYPE,
                cp_sup_ci_sequence_number
                                        IGS_CA_INST_REL.sup_ci_sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_INST_REL cir
                WHERE   cir.sub_cal_type                = cp_sub_cal_type AND
                        cir.sub_ci_sequence_number      = cp_sub_ci_sequence_number AND
                        cir.sup_cal_type                = cp_sup_cal_type AND
                        cir.sup_ci_sequence_number      = cp_sup_ci_sequence_number;
      p_rowid     VARCHAR2(25);
      p_val       VARCHAR2(1);
        CURSOR  c_s_log_entry_cir(
                        cp_s_log_type IGS_GE_S_LOG_ENTRY.s_log_type%TYPE,
                        cp_creation_dt IGS_GE_S_LOG_ENTRY.creation_dt%TYPE,
                        cp_key IGS_GE_S_LOG_ENTRY.key%TYPE,
                        cp_text IGS_GE_S_LOG_ENTRY.text%TYPE) IS
                SELECT   SLE.rowid
                FROM    IGS_GE_S_LOG_ENTRY sle
                WHERE   sle.s_log_type  = cp_s_log_type AND
                        sle.creation_dt = cp_creation_dt AND
                        sle.key         = cp_key AND
                        sle.text        = cp_text
                FOR UPDATE OF
                        sle.s_log_type,
                        sle.creation_dt,
                        sle.sequence_number,
                        sle.key,
                        sle.message_name,
                        sle.text NOWAIT;
  BEGIN

	  l_prog_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir';
	  l_label      := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir.start';

	-- Default value.
        p_message_name := null;
        -------------------------- Used to test the module ------------------------
        -- IGS_GE_GEN_003.GENP_INS_LOG(gv_log_type,
        --              gv_log_key,
        --              gv_log_creation_dt);
        ---------------------------------------------------------------------------
        v_sup_load_res_percentage := NULL;
        -- Loop through calendar instance relationships of calendar instance being
        -- rolled and duplicate relationships against the new calendar instance if
        -- valid
        FOR v_cal_inst_rltsp_sup_rec IN c_cal_inst_rltsp_sup LOOP
                -- Calculate the calendar instance start and end dates of the
                -- rollover superior calendar instance.
                OPEN c_cal_instance(    v_cal_inst_rltsp_sup_rec.sup_cal_type,
                                        v_cal_inst_rltsp_sup_rec.sup_ci_sequence_number);
                FETCH c_cal_instance INTO v_cal_inst_rec;
                -- This should not happen.
                IF c_cal_instance%NOTFOUND THEN
                        CLOSE c_cal_instance;
                        RAISE NO_DATA_FOUND;
                END IF;
                CLOSE c_cal_instance;
                IF p_diff_days = 0 THEN
                        v_derived_start_dt := add_months(v_cal_inst_rec.start_dt,
                                                        p_diff_months);
                        v_derived_end_dt := add_months(v_cal_inst_rec.end_dt,
                                                        p_diff_months);
                ELSE
                        v_derived_start_dt := v_cal_inst_rec.start_dt + p_diff_days;
                        v_derived_end_dt := v_cal_inst_rec.end_dt + p_diff_days;
                END IF;
                -- Check for the existence of the new superior calendar instance.
                OPEN c_derived_cal_instance (   v_cal_inst_rltsp_sup_rec.sup_cal_type,
                                                v_derived_start_dt,
                                                v_derived_end_dt);
                FETCH c_derived_cal_instance INTO v_derived_cal_instance_rec;
                IF c_derived_cal_instance%FOUND THEN
                        CLOSE c_derived_cal_instance;
                        IF p_sup_cal_type IS NOT NULL AND
                                        (v_derived_cal_instance_rec.CAL_TYPE = p_sup_cal_type AND
                                        v_derived_cal_instance_rec.sequence_number = p_sup_ci_sequence_number)
                        THEN
                                -- Do nothing, will be processed below...
                                v_sup_load_res_percentage :=
                                         v_cal_inst_rltsp_sup_rec.load_research_percentage;
                        ELSE
                                -- Validate that superior calendar instance match is not inactive.
                                IF v_derived_cal_instance_rec.s_cal_status = cst_inactive THEN
                                        -- Insert IGS_GE_NOTE into IGS_GE_S_LOG_ENTRY
                                        -- for reporting purposes
        token1_val := p_sub_cal_type || '|' ||p_sub_ci_sequence_number || '|' ;
        token2_val := v_derived_cal_instance_rec.CAL_TYPE ||' '||IGS_GE_DATE.IGSCHAR(v_derived_start_dt) ||
                      '-'||IGS_GE_DATE.IGSCHAR(v_derived_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUP_CAL_INACTIVE');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;
			 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

			    l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir.inact_supcal';
			    l_debug_str := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir Log Message: ' || v_other_detail;
			    fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,l_roll_seq);
			 END IF;

					IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                gv_log_type,
                                                gv_log_creation_dt,
                                                gv_log_key,
                                                NULL,
                                                v_other_detail);


                                ELSIF NOT IGS_CA_VAL_CIR.calp_val_cir_ci(
                                                p_sub_cal_type,
                                                p_sub_ci_sequence_number,
                                                v_derived_cal_instance_rec.CAL_TYPE,
                                                v_derived_cal_instance_rec.sequence_number,
                                                p_message_name) THEN
                                        -- Insert IGS_GE_NOTE into IGS_GE_S_LOG_ENTRY for reporting purposes

        token1_val := p_sub_cal_type || '|' ||p_sub_ci_sequence_number || '|';
        token2_val := v_derived_cal_instance_rec.CAL_TYPE ||' '||IGS_GE_DATE.IGSCHAR(v_derived_start_dt) ||
                      '-'||IGS_GE_DATE.IGSCHAR(v_derived_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUP_CAL_INVALID_REL');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

                                IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

				    l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir.invalid_rel';
		                    l_debug_str := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir Log Message: ' || v_other_detail;
    	                            fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                                END IF;
					IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                gv_log_type,
                                                gv_log_creation_dt,
                                                gv_log_key,
                                                NULL,
                                                v_other_detail);
                                ELSE
                                        -- Insert calendar instance relationship if it doesn't exist already.
                                        OPEN c_cir(
                                                    p_sub_cal_type,
                                                    p_sub_ci_sequence_number,
                                                    v_derived_cal_instance_rec.CAL_TYPE,
                                                    v_derived_cal_instance_rec.sequence_number);
                                        FETCH c_cir INTO v_dummy;
                                        IF c_cir%NOTFOUND THEN
                                                CLOSE c_cir;

                                 IGS_CA_INST_REL_PKG.INSERT_ROW(
                                          X_ROWID => X_ROWID,
                                          X_sub_cal_type => p_sub_cal_type,
                                                        X_sub_ci_sequence_number => p_sub_ci_sequence_number,
                                                        X_sup_cal_type => v_derived_cal_instance_rec.CAL_TYPE,
                                                        X_sup_ci_sequence_number => v_derived_cal_instance_rec.sequence_number,
                                                        X_load_research_percentage => v_cal_inst_rltsp_sup_rec.load_research_percentage,
                                          X_MODE => 'R');

                                        ELSE
                                                CLOSE c_cir;
                                        END IF;
                                        -- We don't want to try to delete a log entry if it doesn't exist.
                                        IF v_other_detail IS NOT NULL THEN
                                                BEGIN
                                                        -- Remove any exception errors previously inserted.
                                                        OPEN  c_s_log_entry_cir(
                                                                                gv_log_type,
                                                                                gv_log_creation_dt,
                                                                                gv_log_key,
                                                                                v_other_detail);
                                                         LOOP

                                                                fetch c_s_log_entry_cir INTO p_rowid;
                                                                if c_s_log_entry_cir%Found Then

                                                        IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(p_rowid);

                                                                else
                                                                   close c_s_log_entry_cir;
                                                                   exit;
                                                                end if;
                                                        END LOOP;
                                                EXCEPTION

                                                        -- locking conflict exception.
                                                        WHEN e_resource_busy THEN
                                                                                     Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_LOCKED');
                                                              IGS_GE_MSG_STACK.ADD;
                                                        WHEN OTHERS THEN

                                                                        RAISE;

                                                END;
                                        END IF;
                                END IF;
                        END IF;
                ELSE    -- NOT c_derived_cal_instance%FOUND
                        CLOSE c_derived_cal_instance;
                        -- Insert IGS_GE_NOTE into IGS_GE_S_LOG_ENTRY
                        -- for reporting purposes when superior calendar instance does
                        -- not exist.

        token1_val := p_sub_cal_type || '|' ||p_sub_ci_sequence_number || '|' ;
        token2_val := v_cal_inst_rec.CAL_TYPE||' '||IGS_GE_DATE.IGSCHAR(v_derived_start_dt) ||
                      '-'||IGS_GE_DATE.IGSCHAR(v_derived_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUP_CAL_NOT_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                gv_log_type,
                                gv_log_creation_dt,
                                gv_log_key,
                                NULL,
                                v_other_detail);

		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
		     v_other_detail := 'CIR|E|' ||p_sub_cal_type || '|' ||
					p_sub_ci_sequence_number || '|' ||' Superior calendar ' || v_cal_inst_rec.CAL_TYPE ||
					' '||TO_CHAR(v_derived_start_dt,'DD/MM/YYYY') ||'-'||TO_CHAR(v_derived_end_dt,'DD/MM/YYYY') ||' does not exist.';
                fnd_log.string_with_context( fnd_log.level_statement,l_label,v_other_detail, NULL,NULL,NULL,NULL,NULL,l_roll_seq);
		END IF;

                END IF;
        END LOOP; -- c_cal_inst_rltsp_sup
        -- Calendar instance relationship is required.
        IF p_sup_cal_type IS NOT NULL THEN
                -- Check that the calendar relationship does not already exist
                OPEN c_cir(
                         p_sub_cal_type,
                         p_sub_ci_sequence_number,
                         p_sup_cal_type,
                         p_sup_ci_sequence_number);
                FETCH c_cir INTO v_dummy;
                IF c_cir%NOTFOUND THEN
                        CLOSE c_cir;
                        -- Get start and end dates of superior calendar for exception reporting.
                        OPEN c_cal_instance(
                                p_sup_cal_type,
                                p_sup_ci_sequence_number);
                        FETCH c_cal_instance INTO v_cal_inst_rec;
                        -- This should not happen.
                        IF c_cal_instance%NOTFOUND THEN
                                CLOSE c_cal_instance;
                                RAISE NO_DATA_FOUND;
                        END IF;
                        CLOSE c_cal_instance;
                        -- Validate IGS_CA_INST_REL
                        IF NOT IGS_CA_VAL_CIR.calp_val_cir_ci (
                                        p_sub_cal_type,
                                        p_sub_ci_sequence_number,
                                        p_sup_cal_type,
                                        p_sup_ci_sequence_number,
                                        p_message_name) THEN
                                -- Insert IGS_GE_NOTE into IGS_GE_S_LOG_ENTRY
                                -- for reporting purposes

                token1_val := p_sub_cal_type || '|' ||p_sub_ci_sequence_number || '|';
                token2_val := v_cal_inst_rec.CAL_TYPE ||' '||IGS_GE_DATE.IGSCHAR(v_derived_start_dt) ||
                             '-'||IGS_GE_DATE.IGSCHAR(v_derived_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUP_CAL_INVALID_REL');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;
			IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

				    l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir.inv_rel_supcal';
		                    l_debug_str := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_cir Log Message: ' || v_other_detail;
    	                            fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

				IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                gv_log_type,
                                                gv_log_creation_dt,
                                                gv_log_key,
                                                NULL,
                                                v_other_detail);
                        ELSE
                                -- Insert calendar instance relationship

                        IGS_CA_INST_REL_PKG.INSERT_ROW(
                              X_ROWID => X_ROWID,
                              X_sub_cal_type => p_sub_cal_type,
                                        X_sub_ci_sequence_number => p_sub_ci_sequence_number,
                                        X_sup_cal_type => p_sup_cal_type,
                                        X_sup_ci_sequence_number => p_sup_ci_sequence_number,
                                        X_load_research_percentage => v_sup_load_res_percentage,
                              X_MODE => 'R');

                                -- Remove calendar instance not exists exception reporting if it exists

        token1_val := p_sub_cal_type || '|' ||p_sub_ci_sequence_number || '|' ;
        token2_val := v_cal_inst_rec.CAL_TYPE ||' '||IGS_GE_DATE.IGSCHAR(v_cal_inst_rec.start_dt) ||
                      '-'||IGS_GE_DATE.IGSCHAR(v_cal_inst_rec.end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUP_CAL_NOT_EXIST');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                         v_other_detail:=FND_MESSAGE.GET;
                                BEGIN
                                        -- Remove any exception errors previously inserted.
                                        FOR v_c_dummy_rec IN c_s_log_entry_cir(
                                                        gv_log_type,
                                                        gv_log_creation_dt,
                                                        gv_log_key,
                                                        v_other_detail) LOOP

                                  IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(v_c_dummy_rec.ROWID);

                                        END LOOP;
                                        EXCEPTION
                                                -- locking conflict exception.
                                                WHEN e_resource_busy THEN
                                                    Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_LOCKED');
                                                    IGS_GE_MSG_STACK.ADD;

                                        END;

		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
                     v_other_detail := 'CIR|E|' || p_sub_cal_type || '|' ||
                                        p_sub_ci_sequence_number || '|' ||' Superior calendar ' || v_cal_inst_rec.CAL_TYPE ||
                                        ' '||TO_CHAR( v_cal_inst_rec.start_dt,'DD/MM/YYYY') ||'-'||TO_CHAR( v_cal_inst_rec.end_dt,'DD/MM/YYYY') ||' does not exist.';
                fnd_log.string_with_context( fnd_log.level_statement,l_label,v_other_detail, NULL,NULL,NULL,NULL,NULL,l_roll_seq);
		END IF;

                        END IF;
                ELSE
                        CLOSE c_cir;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_cal_inst_rltsp_sup%ISOPEN THEN
                        CLOSE c_cal_inst_rltsp_sup;
                END IF;
                IF c_cal_instance%ISOPEN THEN
                        CLOSE c_cal_instance;
                END IF;
                IF c_derived_cal_instance%ISOPEN THEN
                        CLOSE c_derived_cal_instance;
                END IF;
                IF c_cir%ISOPEN THEN
                        CLOSE c_cir;
                END IF;
                IF c_s_log_entry_cir%ISOPEN THEN
                        CLOSE c_s_log_entry_cir;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
	  IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
	    l_debug_str := 'Cal Type ='||p_cal_type||'Seq num ='||(to_char(p_sequence_number))||
			'Diff days ='||(to_char(p_diff_days))||'Diff months ='||(to_char(p_diff_months))||
			'Sub cal type ='||p_sub_cal_type||'Sub CI seq num ='||(to_char(p_sub_ci_sequence_number ))||
			'Sup cal type ='||p_sup_cal_type||'Sup CI seq num ='||(to_char(p_sup_ci_sequence_number ))||
			'Rollover CI seq num ='||(to_char( p_ci_rollover_sequence_number));
	    fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,null);
	  END IF;
	     IF l_func_name IS NULL THEN
            l_func_name := 'calp_ins_rollvr_cir';
         END IF;
            App_Exception.Raise_Exception;
  END calp_ins_rollvr_cir;
  --
  -- To insert a calendar instance as part of the rollover process
  FUNCTION calp_ins_rollvr_ci(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_rollover_cal_type IN VARCHAR2 ,
  p_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
        cst_planned             CONSTANT VARCHAR2(8) := 'PLANNED';
        cst_active              CONSTANT VARCHAR2(8) := 'ACTIVE';
        cst_inactive            CONSTANT VARCHAR2(8) := 'INACTIVE';
        FUNCTION calpl_val_rolled_ci(
                        p_cal_type              IGS_CA_INST.CAL_TYPE%TYPE,
                        p_sequence_number       IGS_CA_INST.sequence_number%TYPE,
                        p_start_dt              OUT NOCOPY IGS_CA_INST.start_dt%TYPE,
                        p_end_dt                OUT NOCOPY IGS_CA_INST.end_dt%TYPE,
                        p_message_name          OUT NOCOPY varchar2)
        RETURN BOOLEAN AS
        BEGIN
        -- Validate calendar instance exists and is not inactive.
        DECLARE
                        v_other_detail          VARCHAR2(255);
                v_cal_instance_rec      IGS_CA_INST%ROWTYPE;
                CURSOR c_cal_instance IS
                        SELECT  *
                        FROM     IGS_CA_INST
                        WHERE    CAL_TYPE = p_cal_type AND
                                sequence_number = p_sequence_number;
                CURSOR c_cal_status(
                                 cp_cal_status IGS_CA_INST.CAL_STATUS%TYPE) IS
                        SELECT  *
                        FROM    IGS_CA_STAT
                        WHERE   CAL_STATUS = cp_cal_status;
        BEGIN

                p_message_name:=null;
                 IF(c_cal_instance%ISOPEN = FALSE) THEN

                        OPEN c_cal_instance;
                 END IF;
                 LOOP
                        FETCH c_cal_instance INTO v_cal_instance_rec;
                        IF(c_cal_instance%NOTFOUND) THEN
                                CLOSE c_cal_instance;
                                -- Invalid parameters IGS_CA_INST status cannot be
                                -- determined
                                 p_message_name :='IGS_OR_LOC_TYPE_CLOSED';
                                RETURN FALSE;
                        END IF;
                        p_start_dt := v_cal_instance_rec.start_dt;
                        p_end_dt := v_cal_instance_rec.end_dt;
                        EXIT;
                END LOOP;

                IF(c_cal_instance%ISOPEN) THEN
                        CLOSE c_cal_instance;
                END IF;
                FOR v_cal_status_rec IN c_cal_status(
                                v_cal_instance_rec.CAL_STATUS)  LOOP
                        IF(v_cal_status_rec.s_cal_status = cst_inactive) THEN
                                -- Inactive IGS_CA_INST cannot be rolled
                                p_message_name :='IGS_OR_ADDR_TYPE_CLOSE';
                                RETURN FALSE;
                         END IF;
                END LOOP;

                RETURN TRUE;
        EXCEPTION
        WHEN OTHERS THEN
    	 IF l_func_name IS NULL THEN
            l_func_name := 'calpl_val_rolled_ci';
         END IF;
            App_Exception.Raise_Exception;
        END;
        END calpl_val_rolled_ci;
        FUNCTION calpl_ins_rollvr_ci(
                p_cal_type              IGS_CA_INST.CAL_TYPE%TYPE ,
                p_sequence_number       IGS_CA_INST.sequence_number%TYPE ,
                p_diff_days             NUMBER ,
                p_diff_months           NUMBER,
                p_rollover_cal_type     IGS_CA_INST.CAL_TYPE%TYPE ,
                p_rollover_sequence_number IGS_CA_INST.sequence_number%TYPE ,
                p_new_sequence_number   OUT NOCOPY IGS_CA_INST.sequence_number%TYPE,
                p_ci_rollover_sequence_number IGS_CA_INST.sequence_number%TYPE,
                p_message_name          OUT NOCOPY varchar2 )
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                X_ROWID                   VARCHAR2(25);
                v_other_detail           VARCHAR2(255);
                token1_val                      VARCHAR2(255);
                token2_val                      VARCHAR2(255);
                v_old_start_dt          IGS_CA_INST.start_dt%TYPE;
                v_old_end_dt            IGS_CA_INST.end_dt%TYPE;
                v_new_sequence_number   IGS_CA_INST.sequence_number%TYPE;
                v_new_start_dt          IGS_CA_INST.start_dt%TYPE;
                v_new_end_dt            IGS_CA_INST.end_dt%TYPE;
                v_new_cal_type          IGS_CA_INST.CAL_TYPE%TYPE;
                v_new_alternate_code    IGS_CA_INST.alternate_code%TYPE;
                l_n_org_id              IGS_CA_INST.ORG_ID%TYPE := igs_ge_gen_003.get_org_id;
                v_new_cal_status        IGS_CA_STAT.CAL_STATUS%TYPE;
                v_message_name          VARCHAR2(30);
                v_cal_instance_rec      IGS_CA_INST%ROWTYPE;
                v_new_cal_instance_rec  IGS_CA_INST%ROWTYPE;
                v_cal_type_rec          IGS_CA_TYPE%ROWTYPE;
                v_unique_sequence       IGS_CA_INST.sequence_number%TYPE; -- added for bug 2563531
                v_cal_instance_exists   BOOLEAN;
                v_new_term_instruction_time IGS_CA_INST.term_instruction_time%TYPE;

                CURSOR c_cal_instance IS
                        SELECT   *
                        FROM    IGS_CA_INST
                        WHERE    CAL_TYPE = p_cal_type  AND
                                 sequence_number = p_sequence_number;
                CURSOR c_new_cal_instance(
                        cp_cal_type     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_start_dt     IGS_CA_INST.start_dt%TYPE,
                        cp_end_dt       IGS_CA_INST.end_dt%TYPE) IS
                        SELECT *
                        FROM    IGS_CA_INST
                        WHERE   CAL_TYPE = cp_cal_type  AND
                                start_dt = cp_start_dt AND
                                end_dt = cp_end_dt;
                CURSOR c_cal_status(
                                 cp_cal_status IGS_CA_INST.CAL_STATUS%TYPE) IS
                        SELECT  *
                        FROM    IGS_CA_STAT
                        WHERE   s_cal_status = cp_cal_status;
                CURSOR c_cal_type(
                                cp_cal_type     IGS_CA_INST.CAL_TYPE%TYPE) IS
                        SELECT  *
                        FROM    IGS_CA_TYPE
                        WHERE   CAL_TYPE = cp_cal_type;
                CURSOR c_ci_sequence_number IS
                        SELECT  IGS_CA_INST_SEQ_NUM_S.nextval
                        FROM    DUAL;

--   Sequence to get unique value for alternate codes bug - 2563531
                CURSOR alt_uniq_seq IS
                SELECT igs_ca_inst_seq_num_s1.nextval from DUAL;
-- cursor to check whether the alternate code for academic calendar instance is already present.
                CURSOR alt_code_unique(p_alternate_code IGS_CA_INST.ALTERNATE_CODE%TYPE) IS
                SELECT count(*)
                FROM  IGS_CA_INST CI , IGS_CA_TYPE CAT
                WHERE   CAT.CAL_TYPE = CI.CAL_TYPE
                AND CAT.S_CAL_CAT  IN ('ACADEMIC' ,'LOAD','TEACHING')
                AND  CI.ALTERNATE_CODE = p_alternate_code;
               l_count NUMBER(3);

        BEGIN
                -- Insert rollover calendar instance, its calendar instance relationships,
                -- related date alias instances, and offsets. Any probems with the
                -- rollover are inserted into IGS_GE_S_LOG tables for reporting.
                p_message_name :=null;
                p_new_sequence_number := 0;
                v_cal_instance_exists := FALSE;
                -- Validate that the calendar instance status is not inactive
                IF(calpl_val_rolled_ci(
                        p_cal_type,
                        p_sequence_number,
                        v_old_start_dt,
                        v_old_end_dt,
                        v_message_name) = FALSE) THEN
                        -- Insert message into cal_inst_rollover_note for reporting
                        -- why the calendar instance was not rolled.
                                IF(v_message_name = 'IGS_OR_LOC_TYPE_CLOSED') THEN


                          token1_val := p_cal_type || '|' ||p_sequence_number || '|';
                       FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUB_CAL_NOT_EXISTS');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',p_cal_type);
                        v_other_detail:=FND_MESSAGE.GET;

                 ELSIF(v_message_name = 'IGS_OR_ADDR_TYPE_CLOSE') THEN

                        token1_val := p_cal_type || '|' ||p_sequence_number || '|';
                        token2_val := p_cal_type||IGS_GE_DATE.IGSCHAR(v_new_start_dt) ||
                              IGS_GE_DATE.IGSCHAR(v_new_end_dt) ;
                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUB_CAL_INACTIVE');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

                  END IF;

		  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calpl_ins_rollvr_ci.val1';
		           l_debug_str := 'igs.plsql.igs_ca_ins_roll_ci.calpl_ins_rollvr_ci Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                   END IF;
                  IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);
                  p_message_name := 'IGS_CA_CANNOT_ROLLOVER';
                  RETURN FALSE;
                END IF;
                -- Validate that the calendar instance calendar type is not closed
                IF(IGS_CA_GEN_001.CALP_GET_CAT_CLOSED(
                        p_cal_type,
                        p_message_name) = TRUE) THEN
                        -- Insert message into IGS_GE_S_LOG_ENTRY for reporting
                        -- why the calendar instance was not rolled.
                token1_val := p_cal_type || '|' ||p_sequence_number || '|';
                token2_val := p_cal_type||IGS_GE_DATE.IGSCHAR(v_new_start_dt) ||
                              IGS_GE_DATE.IGSCHAR(v_new_end_dt) ;

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUB_CAL_CLOSED');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

			 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calpl_ins_rollvr_ci.val2';
		           l_debug_str := 'igs.plsql.igs_ca_ins_roll_ci.calpl_ins_rollvr_ci Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;
	    IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);




                        p_message_name := 'IGS_CA_NOTROL_CLS_CALTYPES';
                        RETURN FALSE;
                END IF;
                -- Validate calendar category security
                 -- Check that new calendar instance does not already exist
                IF p_diff_days = 0 THEN
                        v_new_start_dt := add_months(v_old_start_dt,p_diff_months);
                        v_new_end_dt := add_months(v_old_end_dt,p_diff_months);
                ELSE
                        v_new_start_dt := v_old_start_dt + p_diff_days;
                        v_new_end_dt := v_old_end_dt + p_diff_days;
                END IF;
                OPEN c_new_cal_instance(
                        p_cal_type,
                        v_new_start_dt,
                        v_new_end_dt);
                FETCH c_new_cal_instance INTO v_new_cal_instance_rec;
                IF c_new_cal_instance%NOTFOUND THEN
                        CLOSE c_new_cal_instance;
                ELSE

                        CLOSE c_new_cal_instance;
                        -- Insert message into IGS_GE_S_LOG_ENTRY for reporting
                        -- why the calendar instance was not rolled.


                token1_val := p_cal_type || '|' ||p_sequence_number || '|';
                token2_val := p_cal_type||IGS_GE_DATE.IGSCHAR(v_new_start_dt) ||
                              IGS_GE_DATE.IGSCHAR(v_new_end_dt);

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_SUB_CAL_EXISTS');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                        v_other_detail:=FND_MESSAGE.GET;

			 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

		           l_label := 'igs.plsql.igs_ca_ins_roll_ci.calpl_ins_rollvr_ci.val3';
		           l_debug_str := 'igs.plsql.igs_ca_ins_roll_ci.calpl_ins_rollvr_ci Log Message: ' || v_other_detail;
    	                   fnd_log.string_with_context( fnd_log.level_procedure,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,l_roll_seq);
                        END IF;

			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);


                        v_cal_instance_exists := TRUE;
                        v_new_cal_type := p_cal_type;
                        v_new_sequence_number :=
                                v_new_cal_instance_rec.sequence_number;
                END IF;

                IF NOT  v_cal_instance_exists THEN

                        -- Obtain user-defined planned calendar status
                        FOR v_cal_status_rec IN c_cal_status(
                                        cst_planned) LOOP
                                v_new_cal_status := v_cal_status_rec.CAL_STATUS;
                                EXIT;
                        END LOOP;
                        -- Get calendar instance start and end dates
                        OPEN c_cal_instance;
                        FETCH c_cal_instance INTO v_cal_instance_rec;
                        IF c_cal_instance%NOTFOUND THEN
                                -- This should not occur, invalid parameters
                                CLOSE c_cal_instance;
                                p_message_name := 'IGS_CA_ROLLOVER_NOT_DONE';
                                Return FALSE;
                        ELSE
                                CLOSE c_cal_instance;
                                v_old_start_dt := v_cal_instance_rec.start_dt;
                                v_old_end_dt := v_cal_instance_rec.end_dt;
                        END IF;

                        -- Get next available calendar instance sequence number
                        OPEN c_ci_sequence_number;
                        FETCH c_ci_sequence_number  INTO v_new_sequence_number;
                        CLOSE c_ci_sequence_number;
                        v_new_cal_type := p_cal_type;
                        -- Determine dates
                        IF p_diff_days = 0 THEN
                           v_new_start_dt := add_months(v_old_start_dt,p_diff_months);
                           v_new_end_dt := add_months(v_old_end_dt,p_diff_months);
                        ELSE
                           v_new_start_dt := v_old_start_dt + p_diff_days;
                           v_new_end_dt := v_old_end_dt + p_diff_days;
                        END IF;
                        -- added for bug 2563531
                        OPEN alt_uniq_seq;
                        FETCH alt_uniq_seq INTO v_unique_sequence;
                        CLOSE alt_uniq_seq;
                        -- Determine new alternate code
                        OPEN c_cal_type(v_cal_instance_rec.CAL_TYPE);
                        FETCH c_cal_type INTO v_cal_type_rec;
                        IF c_cal_type%NOTFOUND THEN

                                CLOSE c_cal_type;
                                p_message_name := 'IGS_CA_ROLLOVER_NOT_DONE';
                                Return FALSE;
                        ELSE
                                CLOSE c_cal_type;
                                IF v_cal_type_rec.S_CAL_CAT = 'ACADEMIC' THEN

                                --
                                -- Bug ID 1951883 // IGSCA002: ROLLING OVER CALENDAR PRODUCES INCORRECT ALTERNATE CODE
                                -- Modified the substr parameter from
                                -- IGS_GE_DATE.IGSCHAR(v_new_start_dt),8,4 to IGS_GE_DATE.IGSCHAR(v_new_start_dt),1,4
                                --
                                    v_new_alternate_code :=
                                    substr(IGS_GE_DATE.IGSCHAR(v_new_start_dt),1,4);
                                    -- added for bug 2563531
                                    OPEN alt_code_unique(v_new_alternate_code);
                                    FETCH alt_code_unique INTO l_count;
                                    IF l_count > 0 THEN
                                    v_new_alternate_code := concat(substr(v_new_alternate_code,1,(10-length(v_unique_sequence))),v_unique_sequence);
                                    END IF;
                                    CLOSE alt_code_unique;
                                ELSE

                                     v_new_alternate_code :=
                                     v_cal_instance_rec.alternate_code;
                                    -- added for bug 2563531
                                    IF v_cal_type_rec.S_CAL_CAT IN ('LOAD','TEACHING') THEN
                                        v_new_alternate_code := concat(substr(v_new_alternate_code,1,(10-length(v_unique_sequence))),v_unique_sequence);
                                    END IF;
                                END IF;
                        END IF;
                        -- Insert new calendar instance
                        v_new_term_instruction_time := v_cal_instance_rec.term_instruction_time;
                        --A DESCRIPTION Column is ADDED in the Insert Row Procedure
                        --Enh Bug :- 2138560,Change Request for Calendar Instance
                        --Description to be added in IGS_CA_INST_ALL Table
                           IGS_CA_INST_PKG.INSERT_ROW(
                              X_ROWID => X_ROWID,
                              X_CAL_TYPE => v_new_cal_type,
                                X_sequence_number => v_new_sequence_number,
                                X_start_dt => v_new_start_dt,
                                X_end_dt => v_new_end_dt,
                                X_CAL_STATUS => v_new_cal_status,
                                X_SUP_CAL_STATUS_DIFFER_IND => NULL,
                                X_alternate_code => v_new_alternate_code,
                                X_prior_ci_sequence_number => p_sequence_number,
                                X_MODE => 'R',
                                X_SS_DISPLAYED => v_cal_instance_rec.ss_displayed,
                                X_ORG_ID => l_n_org_id,
                                X_DESCRIPTION  => NULL,
                                X_TERM_INSTRUCTION_TIME  => v_new_term_instruction_time,
                                X_PLANNING_FLAG => v_cal_instance_rec.planning_flag,
                                X_SCHEDULE_FLAG => v_cal_instance_rec.schedule_flag,
                                X_ADMIN_FLAG => v_cal_instance_rec.admin_flag
                              );
                        -- Write to rollover messages
                token1_val := v_new_cal_type|| '|' ||v_new_sequence_number|| '|';

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_ROLLOVER_CREATED');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        v_other_detail:=FND_MESSAGE.GET;

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        gv_log_type,
                                        gv_log_creation_dt,
                                        gv_log_key,
                                        NULL,
                                        v_other_detail);

		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
                   v_other_detail := 'CIR' || '|' || 'I' || '|' ||v_new_cal_type|| '|' ||v_new_sequence_number|| '|' ||'CREATED BY ROLLOVER';
                fnd_log.string_with_context( fnd_log.level_statement,l_label,v_other_detail, NULL,NULL,NULL,NULL,NULL,l_roll_seq);
		END IF;

                END IF;
                -- Insert new calendar instance into calendar instance relationships

                IF(calp_ins_rollvr_cir(
                        p_cal_type,
                        p_sequence_number,
                        p_diff_days,
                        p_diff_months,
                        v_new_cal_type,
                        v_new_sequence_number,
                        p_rollover_cal_type,
                        p_rollover_sequence_number,
                        p_ci_rollover_sequence_number,
                        p_message_name) = TRUE) THEN
                        NULL;
                END IF;

                IF v_cal_instance_exists THEN
                        -- Do not create related date alias instances
                        p_message_name :='IGS_CA_CAL_INSTANCE_EXISTS';
                        Return FALSE;
                END IF;
                -- Insert new calendar instance date alias instances and related offsets.

                IF(calp_ins_rollvr_dai(
                        p_cal_type,
                        p_sequence_number,
                        p_diff_days,
                        p_diff_months,
                        v_new_cal_type,
                        v_new_sequence_number,
                        p_ci_rollover_sequence_number,
                        p_message_name) = TRUE) THEN
                        NULL;
                END IF;

                p_message_name :=null;
                p_new_sequence_number := v_new_sequence_number;
                RETURN TRUE;
/*       EXCEPTION
        WHEN OTHERS THEN

     FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

	   IF l_message_name = 'IGS_PE_UNIQUE_PID' THEN
              l_error_code := 'E567';
          ELSE
              l_error_code := 'E322';
          END IF;
  fnd_message.set_name('IGS',l_message_name);
	  app_exception.raise_exception;*/
        END;
        END calpl_ins_rollvr_ci;
      BEGIN
      DECLARE
        v_other_detail          VARCHAR2(255);
        token1_val                      VARCHAR2(255);
        token2_val                      VARCHAR2(255);
        v_new_sequence_number   IGS_CA_INST.sequence_number%TYPE;
        v_message_name          VARCHAR2(30);
        v_rollover_cal_type             IGS_CA_INST.CAL_TYPE%TYPE;
        v_rollover_sequence_number IGS_CA_INST.sequence_number%TYPE;
        v_cir5_rec              IGS_CA_INST_REL%ROWTYPE;
        v_ci_rollover_sequence_number
                IGS_CA_INST.sequence_number%TYPE;
        TYPE t1_rollover_ci_rec IS RECORD(
                CAL_TYPE                IGS_CA_INST.CAL_TYPE%TYPE,
                sequence_number         IGS_CA_INST.sequence_number%TYPE,
                rollover_sequence_number IGS_CA_INST.sequence_number%TYPE);
        TYPE t1_rollover_ci_table IS TABLE OF t1_rollover_ci_rec
                INDEX BY BINARY_INTEGER;
        t1_rollover_ci          t1_rollover_ci_table;
        t1_rollover_ci_index    BINARY_INTEGER;
        v_index                 BINARY_INTEGER;
        v2_index                        BINARY_INTEGER;
        TYPE t2_rollover_ci_rec IS RECORD(
                CAL_TYPE                IGS_CA_INST.CAL_TYPE%TYPE,
                sequence_number         IGS_CA_INST.sequence_number%TYPE,
                rollover_sequence_number IGS_CA_INST.sequence_number%TYPE);
        TYPE t2_rollover_ci_table IS TABLE OF t2_rollover_ci_rec
                INDEX BY BINARY_INTEGER;
        t2_rollover_ci          t2_rollover_ci_table;
        t2_rollover_ci_index    BINARY_INTEGER;
        CURSOR  c_ci_rollover_sequence_number IS
        SELECT  IGS_CA_INST_REL_SUP_CI_SNO_S1.NEXTVAL
        FROM    dual;
        CURSOR  c_cir1 IS
        SELECT  *
        FROM    IGS_CA_INST_REL
        WHERE   sup_cal_type = p_cal_type AND
                sup_ci_sequence_number = p_sequence_number;
        CURSOR  c_cir2 IS
        SELECT  *
        FROM    IGS_CA_INST_REL cir1
        WHERE   (cir1.sup_cal_type,cir1.sup_ci_sequence_number) IN
                (SELECT DISTINCT cir2.sub_cal_type,cir2.sub_ci_sequence_number
                 FROM   IGS_CA_INST_REL cir2
                 WHERE  cir2.sup_cal_type = p_cal_type AND
                        cir2.sup_ci_sequence_number = p_sequence_number);
        CURSOR  c_cir3 IS
        SELECT  *
        FROM    IGS_CA_INST_REL cir1
        WHERE   (cir1.sup_cal_type,cir1.sup_ci_sequence_number) IN
                (SELECT DISTINCT cir2.sub_cal_type,cir2.sub_ci_sequence_number
                 FROM   IGS_CA_INST_REL cir2
                 WHERE  (cir2.sup_cal_type,cir2.sup_ci_sequence_number) IN
                        (SELECT DISTINCT cir3.sub_cal_type,cir3.sub_ci_sequence_number
                         FROM   IGS_CA_INST_REL cir3
                         WHERE  cir3.sup_cal_type = p_cal_type AND
                                cir3.sup_ci_sequence_number = p_sequence_number));
        CURSOR  c_cir4 IS
        SELECT  *
        FROM    IGS_CA_INST_REL cir1
        WHERE   (cir1.sup_cal_type,cir1.sup_ci_sequence_number) IN
                (SELECT DISTINCT cir2.sub_cal_type,cir2.sub_ci_sequence_number
                 FROM   IGS_CA_INST_REL cir2
                 WHERE  (cir2.sup_cal_type,cir2.sup_ci_sequence_number) IN
                        (SELECT DISTINCT cir3.sub_cal_type,cir3.sub_ci_sequence_number
                         FROM   IGS_CA_INST_REL cir3
                         WHERE  (cir3.sup_cal_type,cir3.sup_ci_sequence_number) IN
                        (SELECT DISTINCT cir4.sub_cal_type,cir4.sub_ci_sequence_number
                         FROM   IGS_CA_INST_REL cir4
                         WHERE  cir4.sup_cal_type = p_cal_type AND
                                cir4.sup_ci_sequence_number = p_sequence_number)));
        CURSOR  c_cir5 IS
        SELECT  *
        FROM    IGS_CA_INST_REL cir1
        WHERE   (cir1.sup_cal_type,cir1.sup_ci_sequence_number) IN
                (SELECT DISTINCT cir2.sub_cal_type,cir2.sub_ci_sequence_number
                 FROM   IGS_CA_INST_REL cir2
                 WHERE  (cir2.sup_cal_type,cir2.sup_ci_sequence_number) IN
                        (SELECT DISTINCT cir3.sub_cal_type,cir3.sub_ci_sequence_number
                         FROM   IGS_CA_INST_REL cir3
                         WHERE  (cir3.sup_cal_type,cir3.sup_ci_sequence_number) IN
                        (SELECT DISTINCT cir4.sub_cal_type,cir4.sub_ci_sequence_number
                         FROM   IGS_CA_INST_REL cir4
                         WHERE  (cir4.sup_cal_type,cir4.sup_ci_sequence_number) IN
                        (SELECT DISTINCT cir5.sub_cal_type,cir5.sub_ci_sequence_number
                         FROM   IGS_CA_INST_REL cir5
                         WHERE  cir5.sup_cal_type = p_cal_type AND
                                cir5.sup_ci_sequence_number = p_sequence_number))));
      BEGIN
        -- Insert rollover calendar instance, its calendar instance relationships
        -- related date alias instances, and offsets. Any probems with the rollover
        -- are inserted into IGS_GE_S_LOG tables for reporting.
        p_message_name :=null;
        -- Get next rollover sequence number.

        OPEN c_ci_rollover_sequence_number;
        FETCH c_ci_rollover_sequence_number INTO v_ci_rollover_sequence_number;
        CLOSE c_ci_rollover_sequence_number;
        -- initiate a session log
        gv_log_type := 'CAL-ROLL';
        gv_log_key :=   p_cal_type || '|' ||
                        p_sequence_number;
        gv_log_creation_dt := SYSDATE;
        IGS_GE_GEN_003.GENP_INS_LOG(
                gv_log_type,
                gv_log_key,
                gv_log_creation_dt);
        gv_cal_count := gv_cal_count + 1;

	l_prog_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_ci';
	l_label := 'igs.plsql.igs_ca_ins_roll_ci.calp_ins_rollvr_ci.begin';
	l_roll_seq := v_ci_rollover_sequence_number;
	IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

           l_debug_str := 'Rollover Sequence : ' || v_ci_rollover_sequence_number;

           fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                           l_debug_str, NULL,
                           NULL,NULL,NULL,NULL,l_roll_seq);
        END IF;


        -- Insert rolled calendar instance
        IF calpl_ins_rollvr_ci(
                p_cal_type,
                p_sequence_number,
                p_diff_days,
                p_diff_months,
                p_rollover_cal_type,
                p_rollover_sequence_number,
                v_new_sequence_number,
                v_ci_rollover_sequence_number,
                v_message_name) = FALSE THEN
                p_message_name := v_message_name;
                Return FALSE;
        ELSE
                v_rollover_cal_type := p_cal_type;
                v_rollover_sequence_number := v_new_sequence_number;
        END IF;

        -- Process first level calendar instance sub-ordinates
        t1_rollover_ci.DELETE;
        t1_rollover_ci_index := 0;
        FOR c_cir1_rec IN c_cir1 LOOP
                v_new_sequence_number := 0;
                IF calpl_ins_rollvr_ci(
                        c_cir1_rec.sub_cal_type,
                        c_cir1_rec.sub_ci_sequence_number,
                        p_diff_days,
                        p_diff_months,
                        v_rollover_cal_type,
                        v_rollover_sequence_number,
                        v_new_sequence_number,
                        v_ci_rollover_sequence_number,
                        v_message_name) = TRUE THEN
                -- Save rolled calendar instance
                t1_rollover_ci_index := t1_rollover_ci_index + 1;
                t1_rollover_ci(t1_rollover_ci_index).CAL_TYPE :=
                        c_cir1_rec.sub_cal_type;
                t1_rollover_ci(t1_rollover_ci_index).sequence_number:=
                        c_cir1_rec.sub_ci_sequence_number;
                t1_rollover_ci(t1_rollover_ci_index).rollover_sequence_number:=
                        v_new_sequence_number;
                END IF;

        END LOOP;
        -- Process second level calendar instance sub-ordinates
        t2_rollover_ci.DELETE;
        t2_rollover_ci_index := 0;

        IF t1_rollover_ci.COUNT <> 0 THEN -- sub-ordinates existed
        FOR c_cir2_rec IN c_cir2 LOOP
            FOR v_index IN t1_rollover_ci.FIRST..t1_rollover_ci.LAST
                 LOOP
                IF c_cir2_rec.sup_cal_type =
                        t1_rollover_ci(v_index).CAL_TYPE AND
                   c_cir2_rec.sup_ci_sequence_number =
                        t1_rollover_ci(v_index).sequence_number THEN
                        v_new_sequence_number := 0;
                        IF calpl_ins_rollvr_ci(
                                c_cir2_rec.sub_cal_type,
                                c_cir2_rec.sub_ci_sequence_number,
                                p_diff_days,
                                p_diff_months,
                                t1_rollover_ci(v_index).CAL_TYPE,
                                t1_rollover_ci(v_index).rollover_sequence_number,
                                v_new_sequence_number,
                                v_ci_rollover_sequence_number,
                                v_message_name) = TRUE THEN
                        -- Save rolled calendar instance
                        t2_rollover_ci_index := t2_rollover_ci_index + 1;
                        t2_rollover_ci(t2_rollover_ci_index).CAL_TYPE :=
                                c_cir2_rec.sub_cal_type;
                        t2_rollover_ci(t2_rollover_ci_index).sequence_number:=
                                c_cir2_rec.sub_ci_sequence_number;
                        t2_rollover_ci(t2_rollover_ci_index).rollover_sequence_number:=
                                v_new_sequence_number;
                        END IF;
                        EXIT;
                END IF;
           END LOOP;
        END LOOP;
        END IF;
        -- Process third level calendar instance sub-ordinates
        t1_rollover_ci.DELETE;
        t1_rollover_ci_index := 0;
        IF t2_rollover_ci.COUNT <> 0 THEN -- sub-ordinates existed
        FOR c_cir3_rec IN c_cir3 LOOP
            FOR v_index IN t2_rollover_ci.FIRST..t2_rollover_ci.LAST
                 LOOP
                IF c_cir3_rec.sup_cal_type =
                        t2_rollover_ci(v_index).CAL_TYPE AND
                   c_cir3_rec.sup_ci_sequence_number =
                        t2_rollover_ci(v_index).sequence_number THEN
                        v_new_sequence_number := 0;
                        IF calpl_ins_rollvr_ci(
                                c_cir3_rec.sub_cal_type,
                                c_cir3_rec.sub_ci_sequence_number,
                                p_diff_days,
                                p_diff_months,
                                t2_rollover_ci(v_index).CAL_TYPE,
                                t2_rollover_ci(v_index).rollover_sequence_number,
                                v_new_sequence_number,
                                v_ci_rollover_sequence_number,
                                v_message_name) = TRUE THEN
                        -- Save rolled calendar instance
                        t1_rollover_ci_index := t1_rollover_ci_index + 1;
                        t1_rollover_ci(t1_rollover_ci_index).CAL_TYPE :=
                                c_cir3_rec.sub_cal_type;
                        t1_rollover_ci(t1_rollover_ci_index).sequence_number:=
                                c_cir3_rec.sub_ci_sequence_number;
                        t1_rollover_ci(t1_rollover_ci_index).rollover_sequence_number:=
                                v_new_sequence_number;
                        END IF;
                        EXIT;
                END IF;
           END LOOP;
        END LOOP;
        END IF;
        -- Process fourth level calendar instance sub-ordinates
        t2_rollover_ci.DELETE;
        t2_rollover_ci_index := 0;
        IF t1_rollover_ci.COUNT <> 0 THEN -- sub-ordinates existed
        FOR c_cir4_rec IN c_cir4 LOOP
            FOR v_index IN t1_rollover_ci.FIRST..t1_rollover_ci.LAST
                 LOOP
                IF c_cir4_rec.sup_cal_type =
                        t1_rollover_ci(v_index).CAL_TYPE AND
                   c_cir4_rec.sup_ci_sequence_number =
                        t1_rollover_ci(v_index).sequence_number THEN
                        v_new_sequence_number := 0;
                        IF calpl_ins_rollvr_ci(
                                c_cir4_rec.sub_cal_type,
                                c_cir4_rec.sub_ci_sequence_number,
                                p_diff_days,
                                p_diff_months,
                                t1_rollover_ci(v_index).CAL_TYPE,
                                t1_rollover_ci(v_index).rollover_sequence_number,
                                v_new_sequence_number,
                                v_ci_rollover_sequence_number,
                                v_message_name) = TRUE THEN
                        -- Save rolled calendar instance
                        t2_rollover_ci_index := t2_rollover_ci_index + 1;
                        t2_rollover_ci(t2_rollover_ci_index).CAL_TYPE :=
                                c_cir4_rec.sub_cal_type;
                        t2_rollover_ci(t2_rollover_ci_index).sequence_number:=
                                c_cir4_rec.sub_ci_sequence_number;
                        t2_rollover_ci(t2_rollover_ci_index).rollover_sequence_number:=
                                v_new_sequence_number;
                        END IF;
                        EXIT;
                END IF;
           END LOOP;
        END LOOP;
        END IF;
        OPEN c_cir5;

        FETCH c_cir5 INTO v_cir5_rec;
        IF c_cir5%NOTFOUND THEN
                CLOSE c_cir5;
        ELSE
                CLOSE c_cir5;
                -- Write to rollover messages


                token1_val := p_rollover_cal_type|| '|' ||p_rollover_sequence_number|| '|';

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_CA_ROLLOVER_NOT_CREATED');
                        FND_MESSAGE.SET_TOKEN('TOKEN1',token1_val);
                        v_other_detail:=FND_MESSAGE.GET;

                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                gv_log_type,
                                gv_log_creation_dt,
                                gv_log_key,
                                NULL,
                                v_other_detail);

        END IF;
        -- Commit changes
        COMMIT;
        p_message_name := NULL;
        RETURN TRUE;
  EXCEPTION
      WHEN OTHERS THEN
	   l_msg_txt := fnd_message.get;
           fnd_message.set_name('IGS','IGS_CA_GENERIC_MSG');
	   IF l_func_name IS NULL THEN
	     l_func_name := 'calp_ins_rollvr_ci';
	   END IF;
  	   fnd_message.set_token('FUNC_NAME',l_func_name);
	   fnd_message.set_token('ERR_MSG',l_msg_txt);
           App_Exception.Raise_Exception;
  END;
END calp_ins_rollvr_ci;

END IGS_CA_INS_ROLL_CI;

/
