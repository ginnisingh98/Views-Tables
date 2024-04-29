--------------------------------------------------------
--  DDL for Package Body RG_REPORT_CALCULATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_CALCULATIONS_PKG" AS
-- $Header: rgiraclb.pls 120.3 2006/03/13 19:52:39 ticheng ship $
-- Name
--   RG_REPORT_CALCULATIONS_PKG
-- Purpose
--   to include all sever side procedures and packages for table
--   RG_REPORT_CALCULATIONS
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
  FUNCTION check_existence(X_axis_set_id NUMBER,
                           X_axis_seq NUMBER) RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
    select 1 into dummy
    from rg_report_calculations
    where axis_set_id = X_axis_set_id
    and axis_seq = X_axis_seq
    and rownum < 2;
    RETURN (TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END check_existence;


  PROCEDURE delete_rows(X_axis_set_id NUMBER,
                        X_axis_seq NUMBER) IS
  BEGIN
    IF (X_axis_seq = -1) THEN
      delete from rg_report_calculations
       where axis_set_id = X_axis_set_id;
    ELSE
      delete from rg_report_calculations
      where axis_set_id = X_axis_set_id
        and axis_seq = X_axis_seq;
    END IF;
  END delete_rows;


  PROCEDURE check_unique(X_rowid VARCHAR2, X_axis_set_id NUMBER,
                         X_axis_seq NUMBER, X_calculation_seq NUMBER) IS
    Dummy NUMBER;
  BEGIN
    SELECT 1 INTO Dummy FROM dual WHERE NOT EXISTS
      (SELECT 1 FROM rg_report_calculations
         WHERE axis_set_id = X_axis_set_id
         AND   axis_seq = X_axis_seq
         AND   calculation_seq = X_calculation_seq
         AND   ((X_rowid IS NULL) OR (rowid <> X_rowid))
      );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG', 'RG_DUP_CALC_SEQ');
      APP_EXCEPTION.raise_exception;

  END check_unique;


  PROCEDURE Load_Row(X_application_id       NUMBER,
                     X_axis_set_id          NUMBER,
                     X_axis_seq             NUMBER,
                     X_calculation_seq      NUMBER,
                     X_operator             VARCHAR2,
                     X_axis_seq_low         NUMBER,
                     X_axis_seq_high        NUMBER,
                     X_axis_name_low        VARCHAR2,
                     X_axis_name_high       VARCHAR2,
                     X_constant             NUMBER,
                     X_context              VARCHAR2,
                     X_attribute1           VARCHAR2,
                     X_attribute2           VARCHAR2,
                     X_attribute3           VARCHAR2,
                     X_attribute4           VARCHAR2,
                     X_attribute5           VARCHAR2,
                     X_attribute6           VARCHAR2,
                     X_attribute7           VARCHAR2,
                     X_attribute8           VARCHAR2,
                     X_attribute9           VARCHAR2,
                     X_attribute10          VARCHAR2,
                     X_attribute11          VARCHAR2,
                     X_attribute12          VARCHAR2,
                     X_attribute13          VARCHAR2,
                     X_attribute14          VARCHAR2,
                     X_attribute15          VARCHAR2,
                     X_owner                VARCHAR2,
                     X_force_edits          VARCHAR2) IS
    v_user_id         NUMBER := 0;
    v_creation_date   DATE;
    v_last_updated_by NUMBER;
  BEGIN
    /* Make sure primary key is not null */
    IF (   X_axis_set_id IS NULL
        OR X_axis_seq IS NULL
        OR X_calculation_seq IS NULL) THEN
      FND_MESSAGE.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      APP_EXCEPTION.raise_exception;
    END IF;

    /* Set user id for seeded data */
    IF (X_owner = 'SEED') THEN
      v_user_id := 1;
    END IF;

    BEGIN
      /* Retrieve creation date from existing row */
      SELECT creation_date, last_updated_by
      INTO   v_creation_date, v_last_updated_by
      FROM   RG_REPORT_CALCULATIONS
      WHERE  axis_set_id     = X_axis_set_id
      AND    axis_seq        = X_axis_seq
      AND    calculation_seq = X_calculation_seq;

      /* Do not overwrite if it has been customized */
      IF (v_last_updated_by <> 1) THEN
        RETURN;
      END IF;

      /*
       * Update only if force_edits is 'Y' or owner = 'SEED'
       */
      IF (v_user_id = 1 or X_force_edits = 'Y') THEN
        UPDATE RG_REPORT_CALCULATIONS
        SET application_id       = X_application_id,
            last_update_date     = sysdate,
            last_updated_by      = v_user_id,
            last_update_login    = 0,
            operator             = X_operator,
            axis_seq_low         = X_axis_seq_low,
            axis_seq_high        = X_axis_seq_high,
            axis_name_low        = X_axis_name_low,
            axis_name_high       = X_axis_name_high,
            constant             = X_constant,
            context              = X_context,
            attribute1           = X_attribute1,
            attribute2           = X_attribute2,
            attribute3           = X_attribute3,
            attribute4           = X_attribute4,
            attribute5           = X_attribute5,
            attribute6           = X_attribute6,
            attribute7           = X_attribute7,
            attribute8           = X_attribute8,
            attribute9           = X_attribute9,
            attribute10          = X_attribute10,
            attribute11          = X_attribute11,
            attribute12          = X_attribute12,
            attribute13          = X_attribute13,
            attribute14          = X_attribute14,
            attribute15          = X_attribute15
        WHERE axis_set_id     = X_axis_set_id
        AND   axis_seq        = X_axis_seq
        AND   calculation_seq = X_calculation_seq;

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*
         * If the row doesn't exist yet, insert.
         */
        INSERT INTO RG_REPORT_CALCULATIONS
        (application_id,
         axis_set_id,
         axis_seq,
         calculation_seq,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         operator,
         axis_seq_low,
         axis_seq_high,
         axis_name_low,
         axis_name_high,
         constant,
         context,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15)
        VALUES
        (X_application_id,
         X_axis_set_id,
         X_axis_seq,
         X_calculation_seq,
         sysdate,
         v_user_id,
         0,
         sysdate,
         v_user_id,
         X_operator,
         X_axis_seq_low,
         X_axis_seq_high,
         X_axis_name_low,
         X_axis_name_high,
         X_constant,
         X_context,
         X_attribute1,
         X_attribute2,
         X_attribute3,
         X_attribute4,
         X_attribute5,
         X_attribute6,
         X_attribute7,
         X_attribute8,
         X_attribute9,
         X_attribute10,
         X_attribute11,
         X_attribute12,
         X_attribute13,
         X_attribute14,
         X_attribute15);
    END;
  END Load_Row;


  PROCEDURE Translate_Row(X_axis_set_id       NUMBER,
                          X_axis_seq          NUMBER,
                          X_calculation_seq   NUMBER,
                          X_axis_name_low     VARCHAR2,
                          X_axis_name_high    VARCHAR2,
                          X_owner             VARCHAR2,
                          X_force_edits       VARCHAR2) IS
    v_user_id       NUMBER := 0;
  BEGIN
    /* Set user id for seeded data */
    IF (X_owner = 'SEED') THEN
      v_user_id := 1;
    END IF;

    /*
     * Update only if force_edits is 'Y' or owner = 'SEED'
     */
    IF (v_user_id = 1 or X_force_edits = 'Y') THEN
      UPDATE RG_REPORT_CALCULATIONS
      SET axis_name_low  = X_axis_name_low,
          axis_name_high = X_axis_name_high
      WHERE axis_set_id     = X_axis_set_id
      AND   axis_seq        = X_axis_seq
      AND   calculation_seq = X_calculation_seq
      AND   userenv('LANG') = (SELECT language_code
                               FROM   FND_LANGUAGES
                               WHERE  installed_flag = 'B');
    END IF;
  END Translate_Row;

END RG_REPORT_CALCULATIONS_PKG;

/
