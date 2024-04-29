--------------------------------------------------------
--  DDL for Package Body IGS_UC_RELEASE_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_RELEASE_TRANS_PKG" AS
/* $Header: IGSUC69B.pls 120.2 2006/05/04 20:59:02 jchakrab noship $*/

  l_debug_level NUMBER:= fnd_log.g_current_runtime_level;

  PROCEDURE release_transactions (
     errbuf                        OUT NOCOPY VARCHAR2,
     retcode                       OUT NOCOPY NUMBER,
     p_org_unit_code               IN  VARCHAR2,
     p_ucas_system_code            IN  VARCHAR2,
     p_ucas_program_code           IN  VARCHAR2,
     p_ucas_campus                 IN  VARCHAR2,
     p_ucas_entry_point            IN  NUMBER,
     p_ucas_entry_month            IN  NUMBER,
     p_ucas_entry_year             IN  NUMBER,
     p_ucas_trans_type             IN  VARCHAR2,
     p_ucas_decision_code          IN  VARCHAR2,
     p_trans_creation_dt_from      IN  VARCHAR2,
     p_trans_creation_dt_to        IN  VARCHAR2,
     p_trans_transmit_dt_from      IN  VARCHAR2,
     p_trans_transmit_dt_to        IN  VARCHAR2
    ) IS

  /*------------------------------------------------------------------
  --Created by  : jchakrab, Oracle Corporation
  --Date created: 24-Jun-2005
  --
  --Purpose: Releases UCAS transactions in bulk.The parameters entered by the user
  --         when the concurrent process is invoked are used to determine the criteria
  --         for releasing transactions.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  WHO       WHEN          WHAT
  anwest    18-JAN-2006   Bug# 4950285 R12 Disable OSS Mandate
  jchakrab  04-May-2006   Bug 5203018 - closed cursor created using DBMS_SQL
  -----------------------------------------------------------------------*/

  --variables for WHO columns
  l_last_update_date           DATE ;
  l_last_updated_by            NUMBER;
  l_last_update_login          NUMBER;

  l_cursor_id                  NUMBER;
  l_update_stmt                VARCHAR2(2500);
  l_updated_rows               NUMBER;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    fnd_file.put_line(fnd_file.log, '-------------------------------------------------------');
    fnd_file.put_line(fnd_file.log, 'P_ORG_UNIT_CODE              = ' || p_org_unit_code);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_SYSTEM_CODE           = ' || p_ucas_system_code);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_PROGRAM_CODE          = ' || p_ucas_program_code);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_CAMPUS                = ' || p_ucas_campus);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_ENTRY_POINT           = ' || p_ucas_entry_point);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_ENTRY_MONTH           = ' || p_ucas_entry_month);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_ENTRY_YEAR            = ' || p_ucas_entry_year);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_TRANS_TYPE            = ' || p_ucas_trans_type);
    fnd_file.put_line(fnd_file.log, 'P_UCAS_DECISION_CODE         = ' || p_ucas_decision_code);
    fnd_file.put_line(fnd_file.log, 'P_TRANS_CREATION_DT_FROM     = ' || p_trans_creation_dt_from);
    fnd_file.put_line(fnd_file.log, 'P_TRANS_CREATION_DT_TO       = ' || p_trans_creation_dt_to);
    fnd_file.put_line(fnd_file.log, 'P_TRANS_TRANSMIT_DT_FROM     = ' || p_trans_transmit_dt_from);
    fnd_file.put_line(fnd_file.log, 'P_TRANS_TRANSMIT_DT_TO       = ' || p_trans_transmit_dt_to);
    fnd_file.put_line(fnd_file.log, '-------------------------------------------------------');


    /* Checking whether the UK profile is enabled */
    IF NOT (igs_uc_utils.is_ucas_hesa_enabled) THEN

        fnd_message.set_name('IGS','IGS_UC_HE_NOT_ENABLED');
        fnd_file.put_line(fnd_file.log, fnd_message.get());  -- display to user also
        -- also log using the fnd logging framework
        IF (fnd_log.level_statement >= l_debug_level ) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.ucas.release_transactions.validation', fnd_message.get());
        END IF;
        errbuf  := fnd_message.get_string ('IGS', 'IGS_UC_HE_NOT_ENABLED');
        retcode := 3 ;
        RETURN ;

    END IF;

    --set values for WHO columns
    l_last_update_date := SYSDATE;
    l_last_updated_by := fnd_global.user_id;
    IF l_last_updated_by IS NULL THEN
        l_last_updated_by := -1;
    END IF;
    l_last_update_login := fnd_global.login_id;
    IF l_last_update_login IS NULL THEN
        l_last_update_login := -1;
    END IF;

    --========================================================================
    --                  START WHERE CLAUSE CONSTRUCTION
    --========================================================================
    --initialize fnd_dsql data-structures
    fnd_dsql.init;

    --set the base UPDATE statement
    fnd_dsql.add_text(' UPDATE IGS_UC_TRANSACTIONS UCTRANS SET UCTRANS.HOLD_FLAG = ''N'' ');
    fnd_dsql.add_text(' ,UCTRANS.LAST_UPDATE_DATE = ');
    fnd_dsql.add_bind(l_last_update_date);
    fnd_dsql.add_text(' ,UCTRANS.LAST_UPDATED_BY = ');
    fnd_dsql.add_bind(l_last_updated_by);
    fnd_dsql.add_text(' ,UCTRANS.LAST_UPDATE_LOGIN = ');
    fnd_dsql.add_bind(l_last_update_login);

    --system code is a required parameter and only need to release transactions which
    --are currently on hold
    fnd_dsql.add_text(' WHERE HOLD_FLAG = ''Y'' AND UCTRANS.SYSTEM_CODE = ');
    fnd_dsql.add_bind(p_ucas_system_code);

    -- org_code
    IF p_org_unit_code IS NOT NULL THEN
        fnd_dsql.add_text(' AND EXISTS (SELECT 1 FROM IGS_PS_VER PSVER, IGS_UC_APP_CHOICES APPCH WHERE APPCH.APP_NO = UCTRANS.APP_NO AND ');
        fnd_dsql.add_text(' UCTRANS.CHOICE_NO = APPCH.CHOICE_NO AND UCTRANS.UCAS_CYCLE = APPCH.UCAS_CYCLE AND PSVER.COURSE_CD = APPCH.OSS_PROGRAM_CODE AND ');
        fnd_dsql.add_text(' PSVER.VERSION_NUMBER = APPCH.OSS_PROGRAM_VERSION AND PSVER.RESPONSIBLE_ORG_UNIT_CD = ');
        fnd_dsql.add_bind(p_org_unit_code);
        fnd_dsql.add_text(' )');
    END IF;

    -- Program search
    IF p_ucas_program_code IS NOT NULL THEN
        fnd_dsql.add_text(' AND EXISTS (SELECT 1 FROM IGS_UC_APP_CHOICES APPCH WHERE UCTRANS.APP_NO = APPCH.APP_NO AND  UCTRANS.CHOICE_NO = APPCH.CHOICE_NO AND ');
        fnd_dsql.add_text(' UCTRANS.UCAS_CYCLE = APPCH.UCAS_CYCLE AND APPCH.UCAS_PROGRAM_CODE = ');
        fnd_dsql.add_bind(p_ucas_program_code);
        fnd_dsql.add_text(' )');
    END IF;

    -- Campus search
    IF p_ucas_campus IS NOT NULL THEN
        fnd_dsql.add_text(' AND EXISTS (SELECT 1 FROM IGS_UC_APP_CHOICES APPCH WHERE UCTRANS.APP_NO = APPCH.APP_NO AND  UCTRANS.CHOICE_NO = APPCH.CHOICE_NO AND ');
        fnd_dsql.add_text(' UCTRANS.UCAS_CYCLE = APPCH.UCAS_CYCLE AND APPCH.CAMPUS = ');
        fnd_dsql.add_bind(p_ucas_campus);
        fnd_dsql.add_text(' )');
    END IF;

    -- Entry Point search
    IF p_ucas_entry_point IS NOT NULL THEN
        fnd_dsql.add_text(' AND EXISTS (SELECT 1 FROM IGS_UC_APP_CHOICES APPCH WHERE UCTRANS.APP_NO = APPCH.APP_NO AND  UCTRANS.CHOICE_NO = APPCH.CHOICE_NO AND ');
        fnd_dsql.add_text(' UCTRANS.UCAS_CYCLE = APPCH.UCAS_CYCLE AND APPCH.POINT_OF_ENTRY = ');
        fnd_dsql.add_bind(p_ucas_entry_point);
        fnd_dsql.add_text(' )');
    END IF;

    -- Entry month search
    IF p_ucas_entry_month IS NOT NULL THEN
        fnd_dsql.add_text(' AND EXISTS (SELECT 1 FROM IGS_UC_APP_CHOICES APPCH WHERE UCTRANS.APP_NO = APPCH.APP_NO AND  UCTRANS.CHOICE_NO = APPCH.CHOICE_NO AND ');
        fnd_dsql.add_text(' UCTRANS.UCAS_CYCLE = APPCH.UCAS_CYCLE AND APPCH.ENTRY_MONTH = ');
        fnd_dsql.add_bind(p_ucas_entry_month);
        fnd_dsql.add_text(' )');
    END IF;

    -- Entry Year search
    IF p_ucas_entry_year IS NOT NULL THEN
        fnd_dsql.add_text(' AND EXISTS (SELECT 1 FROM IGS_UC_APP_CHOICES APPCH WHERE UCTRANS.APP_NO = APPCH.APP_NO AND  UCTRANS.CHOICE_NO = APPCH.CHOICE_NO AND ');
        fnd_dsql.add_text(' UCTRANS.UCAS_CYCLE = APPCH.UCAS_CYCLE AND APPCH.ENTRY_YEAR = ');
        fnd_dsql.add_bind(p_ucas_entry_year);
        fnd_dsql.add_text(' )');
    END IF;



    -- Transaction type
    IF p_ucas_trans_type IS NOT NULL THEN
        fnd_dsql.add_text(' AND UCTRANS.TRANSACTION_TYPE = ');
        fnd_dsql.add_bind(p_ucas_trans_type);
    END IF;

    -- Decision
    IF p_ucas_decision_code IS NOT NULL THEN
        fnd_dsql.add_text(' AND UCTRANS.DECISION = ');
        fnd_dsql.add_bind(p_ucas_decision_code);
    END IF;

    -- Creation dates search
    IF p_trans_creation_dt_from IS NOT NULL THEN
        fnd_dsql.add_text(' AND UCTRANS.CREATION_DATE >= ');
        fnd_dsql.add_bind(IGS_GE_DATE.igsdate(p_trans_creation_dt_from));
    END IF;

    IF p_trans_creation_dt_to IS NOT NULL THEN
        fnd_dsql.add_text(' AND UCTRANS.CREATION_DATE <= ');
        fnd_dsql.add_bind(IGS_GE_DATE.igsdate(p_trans_creation_dt_to));
    END IF;

    -- Transmission dates search
    IF p_trans_transmit_dt_from IS NOT NULL THEN
        fnd_dsql.add_text(' AND UCTRANS.DATETIMESTAMP >= ');
        fnd_dsql.add_bind(IGS_GE_DATE.igsdate(p_trans_transmit_dt_from));
    END IF;

    IF p_trans_transmit_dt_to IS NOT NULL THEN
        fnd_dsql.add_text(' AND UCTRANS.DATETIMESTAMP <= ');
        fnd_dsql.add_bind(IGS_GE_DATE.igsdate(p_trans_transmit_dt_to));
    END IF;


    l_update_stmt := fnd_dsql.get_text(FALSE);

    -- log the UPDATE DML statement using the fnd logging framework
    IF (fnd_log.level_statement >= l_debug_level ) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.ucas.release_transactions.update_dml', l_update_stmt);
    END IF;

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    fnd_dsql.set_cursor(l_cursor_id);

    DBMS_SQL.parse(l_cursor_id, l_update_stmt, dbms_sql.native);
    fnd_dsql.do_binds;

    l_updated_rows := dbms_sql.EXECUTE(l_cursor_id);

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    COMMIT;

    IF (l_updated_rows > 0) THEN
        --show the number of records successfully processed
        fnd_message.set_name('IGS','IGS_UC_REC_CNT_SUCCESS_PROC');
        fnd_message.set_token('REC_CNT',l_updated_rows);
        fnd_file.put_line(fnd_file.log, fnd_message.get());
    ELSE
        --report that there were no records processed
        fnd_message.set_name('IGS','IGS_UC_REC_CNT_PROC');
        fnd_message.set_token('REC_CNT',l_updated_rows);
        fnd_file.put_line(fnd_file.log, fnd_message.get());
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      IF l_cursor_id IS NOT NULL THEN
          DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
      END IF;

      ROLLBACK;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igs_uc_release_trans_on_hold_pkg.release_transactions - '||SQLERRM);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF ( fnd_log.level_unexpected >= l_debug_level ) THEN
          fnd_log.message(fnd_log.level_unexpected, 'igs.plsql.ucas.release_transactions.exception', FALSE);
      END IF;

      fnd_message.retrieve (errbuf);
      retcode := 2 ;
      igs_ge_msg_stack.conc_exception_hndl;

  END release_transactions;

END igs_uc_release_trans_pkg;

/
