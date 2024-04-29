--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVALUATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVALUATIONS_PKG" AS
-- $Header: igiiarxb.pls 120.6.12010000.2 2008/08/04 13:02:54 sasukuma ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiarxb.igi_iac_revaluations_pkg.';

--===========================FND_LOG.END=====================================

  PROCEDURE insert_row (
    X_rowid                             IN OUT NOCOPY  VARCHAR2,
    X_revaluation_id                    IN OUT NOCOPY  NUMBER,
    X_book_type_code                    IN      VARCHAR2,
    X_revaluation_date                  IN      DATE,
    X_revaluation_period                IN      VARCHAR2,
    X_status                            IN      VARCHAR2,
    X_reval_request_id                  IN      NUMBER,
    X_create_request_id                 IN      NUMBER,
    X_calling_program                   IN      VARCHAR2,
    X_mode                              IN      VARCHAR2,
    X_event_id                          IN      NUMBER            -- for R12 SLA upgrade

  ) AS

    CURSOR c IS
        SELECT   rowid
        FROM     igi_iac_revaluations
        WHERE    revaluation_id = X_revaluation_id;

    CURSOR c1 IS
        SELECT    igi_iac_revaluations_s.NEXTVAL
        FROM      sys.dual;

    X_last_update_date           DATE;
    X_last_updated_by            NUMBER;
    X_last_update_login          NUMBER;
    X_creation_date              DATE;
    X_created_by                 NUMBER;
    l_path_name VARCHAR2(150) := g_path||'insert_row';

  BEGIN

    IF (x_mode = 'R') THEN
        x_last_update_date := SYSDATE;
        x_creation_date    := SYSDATE;
        x_created_by       := fnd_global.user_id;

        IF (x_created_by IS NULL) THEN
            x_created_by    := -1;
        END IF;

        x_last_updated_by := fnd_global.user_id;
        IF (x_last_updated_by IS NULL) THEN
            x_last_updated_by := -1;
        END IF;

        x_last_update_login := fnd_global.login_id;
        IF (x_last_update_login IS NULL) THEN
            x_last_update_login := -1;
        END IF;
    ELSE
        fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
  	igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  p_full_path => l_path_name,
		  p_remove_from_stack => FALSE);
        app_exception.raise_exception;
    END IF;

    IF X_revaluation_id is null THEN
        OPEN c1;
        FETCH c1 INTO X_revaluation_id;
        CLOSE c1;
    END IF;

    INSERT INTO igi_iac_revaluations
        (revaluation_id,
        book_type_code,
        revaluation_date,
        revaluation_period,
        status,
        reval_request_id,
        create_request_id,
        calling_program,
        last_update_date,
        created_by,
        last_update_login,
        last_updated_by,
        creation_date,
	event_id)                               -- for R12 SLA upgrade
    VALUES
        (X_revaluation_id,
        X_book_type_code,
        X_revaluation_date,
        X_revaluation_period,
        X_status,
        X_reval_request_id,
        X_create_request_id,
        X_calling_program,
        X_last_update_date,
        X_created_by,
        X_last_update_login,
        X_last_updated_by,
        X_creation_date,
	X_event_id);                            -- for R12 SLA upgrade

    OPEN c;
    FETCH c INTO X_rowid;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;

  PROCEDURE delete_row (
    x_revaluation_id     IN      NUMBER
  ) AS
  BEGIN

    DELETE FROM igi_iac_revaluations
    WHERE revaluation_id = x_revaluation_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

END igi_iac_revaluations_pkg;

/
