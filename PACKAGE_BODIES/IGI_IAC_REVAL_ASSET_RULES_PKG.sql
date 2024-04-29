--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_ASSET_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_ASSET_RULES_PKG" AS
-- $Header: igiiarrb.pls 120.5.12000000.1 2007/08/01 16:17:51 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiarrb.igi_iac_reval_asset_rules_pkg.';

--===========================FND_LOG.END=======================================

  PROCEDURE insert_row (
        X_rowid                         IN OUT NOCOPY  VARCHAR2,
        X_revaluation_id                IN      NUMBER,
        X_book_type_code                IN      VARCHAR2,
        X_category_id                   IN      NUMBER,
        X_asset_id                      IN      NUMBER,
        X_revaluation_factor            IN      NUMBER,
        X_revaluation_type              IN      VARCHAR2,
        X_new_cost                      IN      NUMBER,
        X_current_cost                  IN      NUMBER,
        X_selected_for_reval_flag       IN      VARCHAR2,
        X_selected_for_calc_flag        IN      VARCHAR2,
        X_allow_prof_update             IN      VARCHAR2,
        X_mode                          IN      VARCHAR2
  ) AS

    CURSOR c IS
        SELECT   rowid
        FROM     igi_iac_reval_asset_rules
        WHERE    revaluation_id = X_revaluation_id
        AND      asset_id = X_asset_id
        AND      book_type_code = X_book_type_code
        AND      category_id = X_category_id;

    X_last_update_date           DATE;
    X_last_updated_by            NUMBER;
    X_last_update_login          NUMBER;
    X_creation_date              DATE;
    X_created_by                 NUMBER;
    l_path 			 VARCHAR2(150) := g_path||'insert_row';
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
	igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
        app_exception.raise_exception;
    END IF;

    INSERT INTO igi_iac_reval_asset_rules
        (revaluation_id,
        book_type_code,
        category_id,
        asset_id,
        revaluation_factor,
        revaluation_type,
        new_cost,
        current_cost,
        selected_for_reval_flag,
        selected_for_calc_flag,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by,
        allow_prof_update)
    VALUES
        (X_revaluation_id,
        X_book_type_code,
        X_category_id,
        X_asset_id,
        X_revaluation_factor,
        X_revaluation_type,
        X_new_cost,
        X_current_cost,
        X_selected_for_reval_flag,
        X_selected_for_calc_flag,
        X_created_by,
        X_creation_date,
        X_last_update_login,
        X_last_update_date,
        X_last_updated_by,
        X_allow_prof_update);

    OPEN c;
    FETCH c INTO X_rowid;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;

  PROCEDURE delete_row (
    x_asset_id          IN      NUMBER,
    x_book_type_code    IN      VARCHAR2,
    x_revaluation_id     IN      NUMBER
  ) AS
  BEGIN

    DELETE FROM igi_iac_reval_asset_rules
    WHERE asset_id = x_asset_id
    AND book_type_code = x_book_type_code
    AND revaluation_id = x_revaluation_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

END igi_iac_reval_asset_rules_pkg;

/
