--------------------------------------------------------
--  DDL for Package Body PAY_USER_TABLE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_TABLE_DETAILS_PKG" AS
/* $Header: pyutabdp.pkb 120.2.12010000.4 2010/01/15 09:55:34 asnell ship $ */
g_product_code  VARCHAR2(5);

PROCEDURE perform_validations
(
   X_VIEW_NAME        IN VARCHAR2,
   X_PRODUCT_CODES    IN VARCHAR2,
   X_LEGISLATION_CODE IN VARCHAR2,
   X_USER_TABLE_NAME  IN VARCHAR2
) IS
    CURSOR get_leg_view(X_VIEW_NAME VARCHAR2)
    IS
       SELECT 'Y'
         FROM user_views
        WHERE view_name = UPPER(X_VIEW_NAME);

    CURSOR chk_installation(p_start     NUMBER)
    IS
       SELECT 'Y',SUBSTR(X_PRODUCT_CODES,p_start,3)
         FROM hr_legislation_installations
        WHERE legislation_code       = X_LEGISLATION_CODE
          AND application_short_name = SUBSTR(X_PRODUCT_CODES,p_start,3);

    CURSOR chk_table_at_bg
    IS
       SELECT user_table_id
         FROM pay_user_tables
        WHERE user_table_name = X_USER_TABLE_NAME
          AND business_group_id IS NOT NULL;

    l_temp                  VARCHAR2(1);
    l_user_table_id         NUMBER;

BEGIN
    IF (x_view_name IS NOT NULL)
    THEN
     --
     -- is running in hrglobal, so run the legislation view check
     --
       OPEN  get_leg_view(X_VIEW_NAME);
       FETCH get_leg_view INTO l_temp;
       IF (get_leg_view%FOUND)
       THEN
          g_upload  := TRUE;
       ELSE
          g_upload  := FALSE;
       END IF;
       CLOSE get_leg_view;
    ELSE
    -- Not Running from hrglobal
       g_upload  := TRUE;
       l_temp    := 'Y';
       g_user_table_name := X_USER_TABLE_NAME;
       g_product_code := 'PAY';
    END IF;
    -- Now check the Products installed for this legislation
    IF (g_upload) and x_view_name IS NOT NULL
    THEN
       l_temp := 'N';
       OPEN  chk_installation(0);
       FETCH chk_installation INTO l_temp,g_product_code;
       CLOSE chk_installation;

       IF (l_temp = 'N')
       THEN
          OPEN  chk_installation(5);
          FETCH chk_installation INTO l_temp,g_product_code;
          CLOSE chk_installation;
       END IF;

       IF (l_temp = 'N')
       THEN
          OPEN  chk_installation(9);
          FETCH chk_installation INTO l_temp,g_product_code;
          CLOSE chk_installation;
       END IF;

       IF (l_temp = 'N')
       THEN
           g_upload := FALSE;
       ELSE
           OPEN  chk_table_at_bg;
           FETCH chk_table_at_bg INTO l_user_table_id;
           CLOSE chk_table_at_bg;

           IF (l_user_table_id IS NOT NULL)
           THEN
                INSERT INTO hr_stu_exceptions(TABLE_NAME,SURROGATE_ID, EXCEPTION_TEXT,TRUE_KEY)
                VALUES(X_USER_TABLE_NAME,l_user_table_id,'User Table: '|| X_USER_TABLE_NAME ||' already exists at BG level.',NULL);
                g_upload := FALSE;
           ELSE
                g_upload          := TRUE;
                g_user_table_name := X_USER_TABLE_NAME;
           END IF;
       END IF;
    END IF;

    IF (g_upload)
    THEN
          hr_startup_data_api_support.enable_startup_mode('STARTUP');
          hr_startup_data_api_support.delete_owner_definitions;
          hr_startup_data_api_support.create_owner_definition(g_product_code);
    END IF;
END perform_validations;

PROCEDURE user_table_upd_ins
(
   X_USER_TABLE_NAME             IN VARCHAR2,
   X_USER_ROW_TITLE              IN VARCHAR2,
   X_LEGISLATION_CODE            IN VARCHAR2,
   X_RANGE_OR_MATCH              IN VARCHAR2,
   X_USER_KEY_UNITS              IN VARCHAR2,
   X_OWNER                       IN VARCHAR2,
   X_LEG_VIEW                    IN VARCHAR2,
   X_PRODUCT_CODE                IN VARCHAR2
) IS

    l_object_version_number NUMBER;
    l_user_table_id         NUMBER;
    table_at_bg_exists      EXCEPTION;

  BEGIN
    perform_validations(X_LEG_VIEW,
                        X_PRODUCT_CODE,
                        X_LEGISLATION_CODE,
                        X_USER_TABLE_NAME
                        );
    IF (g_upload AND (g_user_table_name = X_USER_TABLE_NAME))
    THEN

    SELECT user_table_id
          ,object_version_number
      INTO l_user_table_id
          ,l_object_version_number
      FROM pay_user_tables
     WHERE user_table_name  = X_USER_TABLE_NAME
       AND (
             legislation_code = X_LEGISLATION_CODE
            OR
             legislation_code IS NULL
            )
       AND business_group_id IS NULL;

    pay_user_table_api.update_user_table
      (p_validate                      => FALSE
      ,p_user_table_id                 => l_user_table_id
      ,p_effective_date                => SYSDATE
      ,p_user_table_name               => X_USER_TABLE_NAME
      ,p_user_row_title                => X_USER_ROW_TITLE
      ,p_object_version_number         => l_object_version_number
      );
   END IF ;
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        pay_user_table_api.create_user_table
         (p_validate                     => FALSE
         ,p_effective_date               => sysdate
         ,p_business_group_id            => NULL
         ,p_legislation_code             => X_LEGISLATION_CODE
         ,p_range_or_match               => X_RANGE_OR_MATCH
         ,p_user_key_units               => X_USER_KEY_UNITS
         ,p_user_table_name              => X_USER_TABLE_NAME
         ,p_user_row_title               => X_USER_ROW_TITLE
         ,p_user_table_id                => l_user_table_id
         ,p_object_version_number        => l_object_version_number
         );
  END user_table_upd_ins;


PROCEDURE user_row_upd_ins
(
   X_USER_TABLE_NAME         IN VARCHAR2,
   X_LEGISLATION_CODE        IN VARCHAR2,
   X_ROW_LOW_RANGE_OR_NAME   IN VARCHAR2,
   X_ROW_HIGH_RANGE          IN VARCHAR2,
   X_EFFECTIVE_START_DATE    IN VARCHAR2,
   X_EFFECTIVE_END_DATE      IN VARCHAR2,
   X_DISPLAY_SEQUENCE        IN VARCHAR2,
   X_OWNER                   IN VARCHAR2,
   X_LEG_VIEW                IN VARCHAR2
) IS
    CURSOR c_table_id
    IS
       SELECT user_table_id, user_key_units
         FROM pay_user_tables
        WHERE user_table_name  = X_USER_TABLE_NAME
          AND (
                 legislation_code = X_LEGISLATION_CODE
                OR
                 legislation_code IS NULL
              )
          AND business_group_id IS NULL;


CURSOR c_get_col_instance_id (p_user_row_id NUMBER)
IS
        SELECT  val.user_column_instance_id column_instance_id,
                val.object_version_number   object_version_number
          FROM  pay_user_tables put,
                pay_user_rows_f pur,
                pay_user_columns puc,
                pay_user_column_instances_f val
         WHERE val.user_row_id    = pur.user_row_id
	   AND val.user_row_id    = p_user_row_id
           AND val.user_column_id = puc.user_column_id
           AND pur.user_table_id  = put.user_table_id
           AND puc.user_table_id  = put.user_table_id
--         bug 9234524 convert to user key units when matching
        and     decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_LOW_RANGE_OR_NAME)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_LOW_RANGE_OR_NAME)),
                 'T', upper (X_ROW_LOW_RANGE_OR_NAME),
                 null) =
                decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_low_range_or_name)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_low_range_or_name)),
                 'T', upper (pur.row_low_range_or_name),
                 null)
        and     ( NVL(pur.row_high_range,'NULL')   = NVL(X_ROW_HIGH_RANGE,'NULL')
                  OR decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_HIGH_RANGE)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_HIGH_RANGE)),
                 'T', upper (X_ROW_HIGH_RANGE),
                 null) =
                decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_high_range)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_high_range)),
                 'T', upper (pur.row_high_range),
                 null))
--          end bug 9234524
           AND put.user_table_name  = X_USER_TABLE_NAME
           AND(
               (
                   put.legislation_code IS NULL
               AND val.legislation_code IS NULL
               AND pur.legislation_code IS NULL
               )
               OR
               (
                   put.legislation_code = X_LEGISLATION_CODE
               AND val.legislation_code = X_LEGISLATION_CODE
               AND pur.legislation_code = X_LEGISLATION_CODE
               )
              )
           AND fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE) < val.effective_end_date;



    l_user_row_id           NUMBER;
    l_display_sequence      NUMBER;
    l_user_table_id         NUMBER;
    l_user_key_units        pay_user_tables.USER_KEY_UNITS%type;
    l_start_date            DATE;
    l_end_date              DATE;
    l_effective_start_date  DATE;
    l_effective_end_date    DATE;
    l_object_version_number NUMBER;

  BEGIN
   l_display_sequence:=X_DISPLAY_SEQUENCE;

    IF (g_upload AND (g_user_table_name = X_USER_TABLE_NAME))
    THEN


           OPEN  c_table_id;
           FETCH c_table_id INTO l_user_table_id,l_user_key_units;
           CLOSE c_table_id;

            SELECT user_row_id
                  ,object_version_number
                  ,effective_start_date
                  ,effective_end_date
              INTO l_user_row_id
                  ,l_object_version_number
                  ,l_effective_start_date
                  ,l_effective_end_date
              FROM pay_user_rows_f pur
--         bug 9234524 convert to user key units when matching
              WHERE decode
                (l_user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_LOW_RANGE_OR_NAME)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_LOW_RANGE_OR_NAME)),
                 'T', upper (X_ROW_LOW_RANGE_OR_NAME),
                 null) =
                decode
                (l_user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_low_range_or_name)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_low_range_or_name)),
                 'T', upper (pur.row_low_range_or_name),
                 null)
        and     ( NVL(pur.row_high_range,'NULL')   = NVL(X_ROW_HIGH_RANGE,'NULL')
                  OR decode
                (l_user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_HIGH_RANGE)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_HIGH_RANGE)),
                 'T', upper (X_ROW_HIGH_RANGE),
                 null) =
                decode
                (l_user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_high_range)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_high_range)),
                 'T', upper (pur.row_high_range),
                 null))
--              end bug 9234524 changes
              AND (
                     legislation_code = X_LEGISLATION_CODE
                    OR
                     legislation_code IS NULL
                  )
              AND business_group_id IS NULL
              AND user_table_id = l_user_table_id
              AND fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE) BETWEEN effective_start_date AND effective_end_date;


             IF (l_effective_start_date <> fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE))
             THEN
                        pay_user_row_api.update_user_row
                        (p_validate                      => FALSE
                        ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
                        ,p_datetrack_update_mode         => hr_api.g_update
                        ,p_user_row_id                   => l_user_row_id
                        ,p_display_sequence              => l_display_sequence
                        ,p_object_version_number         => l_object_version_number
                        ,p_row_low_range_or_name         => X_ROW_LOW_RANGE_OR_NAME
                        ,p_base_row_low_range_or_name    => X_ROW_LOW_RANGE_OR_NAME
                        ,p_disable_range_overlap_check   => TRUE
                        ,p_disable_units_check           => FALSE
                        ,p_row_high_range                => X_ROW_HIGH_RANGE
                        ,p_effective_start_date          => l_start_date
                        ,p_effective_end_date            => l_end_date
                        );

             END IF;

             IF (l_effective_end_date <> fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE))
             THEN
                 FOR c_rec IN c_get_col_instance_id(l_user_row_id)
                      LOOP
                       pay_user_column_instance_api.delete_user_column_instance
                        (p_validate                      => FALSE
                        ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE)
                        ,p_user_column_instance_id       => c_rec.column_instance_id
                        ,p_datetrack_update_mode         => hr_api.g_delete
                        ,p_object_version_number         => c_rec.object_version_number
                        ,p_effective_start_date          => l_start_date
                        ,p_effective_end_date            => l_end_date
                       );
                   END LOOP;

                      pay_user_row_api.delete_user_row
                       (p_validate                      => FALSE
                       ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE)
                       ,p_datetrack_update_mode         => hr_api.g_delete
                       ,p_user_row_id                   => l_user_row_id
                       ,p_object_version_number         => l_object_version_number
                       ,p_disable_range_overlap_check   => FALSE
                       ,p_effective_start_date          => l_start_date
                       ,p_effective_end_date            => l_end_date
                       );
             END IF;

    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
                l_display_sequence := X_DISPLAY_SEQUENCE;

                pay_user_row_api.create_user_row
                  (p_validate                      => FALSE
                  ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
                  ,p_user_table_id                 => l_user_table_id
                  ,p_row_low_range_or_name         => X_ROW_LOW_RANGE_OR_NAME
                  ,p_display_sequence              => l_display_sequence
                  ,p_business_group_id             => NULL
                  ,p_legislation_code              => X_LEGISLATION_CODE
                  ,p_disable_range_overlap_check   => TRUE
                  ,p_disable_units_check           => FALSE
                  ,p_row_high_range                => X_ROW_HIGH_RANGE
                  ,p_user_row_id                   => l_user_row_id
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_start_date          => l_start_date
                  ,p_effective_end_date            => l_end_date
                  );

                  IF (SUBSTR(X_EFFECTIVE_END_DATE,0,4) <> '4712')
                  THEN
                      pay_user_row_api.delete_user_row
                       (p_validate                      => FALSE
                       ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE)
                       ,p_datetrack_update_mode         => hr_api.g_delete
                       ,p_user_row_id                   => l_user_row_id
                       ,p_object_version_number         => l_object_version_number
                       ,p_disable_range_overlap_check   => FALSE
                       ,p_effective_start_date          => l_start_date
                       ,p_effective_end_date            => l_end_date
                       );

                  END IF;

END user_row_upd_ins;

PROCEDURE column_row_upd_ins
(
   X_USER_TABLE_NAME             IN  VARCHAR2,
   X_LEGISLATION_CODE            IN  VARCHAR2,
   X_USER_COLUMN_NAME            IN  VARCHAR2,
   X_FORMULA_NAME                IN  VARCHAR2,
   X_FORMULA_LEG_CODE            IN  VARCHAR2,
   X_OWNER                       IN  VARCHAR2,
   X_LEG_VIEW                    IN  VARCHAR2
) IS
    CURSOR c_table_id
    IS
       SELECT user_table_id
         FROM pay_user_tables
        WHERE user_table_name  = X_USER_TABLE_NAME
          AND (
                 legislation_code = X_LEGISLATION_CODE
               OR
                 legislation_code IS NULL
              );

    CURSOR c_get_formula_id
    IS
       SELECT ff.formula_id
         FROM ff_formula_types fft
             ,ff_formulas_f ff
        WHERE fft.formula_type_name = 'User Table Validation'
          AND fft.formula_type_id   = ff.formula_type_id
          AND ff.formula_name       = X_FORMULA_NAME
          AND (
               X_FORMULA_LEG_CODE IS NULL
               OR
               ff.legislation_code = X_FORMULA_LEG_CODE
              );

    l_warning               BOOLEAN;
    l_user_column_id        NUMBER;
    l_user_table_id         NUMBER;
    l_formula_id            NUMBER := NULL;
    l_object_version_number NUMBER;

  BEGIN

    IF (g_upload AND (g_user_table_name = X_USER_TABLE_NAME))
    THEN

            OPEN  c_table_id;
            FETCH c_table_id INTO l_user_table_id;
            CLOSE c_table_id;

            IF (X_FORMULA_NAME IS NOT NULL)
            THEN
                  OPEN  c_get_formula_id;
                  FETCH c_get_formula_id INTO l_formula_id;
                  CLOSE c_get_formula_id;
            END IF;

            SELECT user_column_id
                  ,object_version_number
              INTO l_user_column_id
                  ,l_object_version_number
              FROM pay_user_columns
             WHERE user_column_name = X_USER_COLUMN_NAME
               AND (
                      legislation_code = X_LEGISLATION_CODE
                   OR
                      legislation_code IS NULL
                   )
               AND user_table_id    = l_user_table_id
               AND business_group_id IS NULL;

               pay_user_column_api.update_user_column
                 (p_validate                 => FALSE
                 ,p_user_column_id           => l_user_column_id
                 ,p_user_column_name         => X_USER_COLUMN_NAME
                 ,p_formula_id               => l_formula_id
                 ,p_object_version_number    => l_object_version_number
                 ,p_formula_warning          => l_warning
                 );

    END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN

          pay_user_column_api.create_user_column
            (p_validate                      => FALSE
            ,p_business_group_id             => NULL
            ,p_legislation_code              => X_LEGISLATION_CODE
            ,p_user_table_id                 => l_user_table_id
            ,p_formula_id                    => l_formula_id
            ,p_user_column_name              => X_USER_COLUMN_NAME
            ,p_user_column_id                => l_user_column_id
            ,p_object_version_number         => l_object_version_number
            );

END column_row_upd_ins;

PROCEDURE column_instance_upd_ins
(
   X_USER_TABLE_NAME            IN  VARCHAR2,
   X_USER_COLUMN_NAME           IN  VARCHAR2,
   X_ROW_LOW_RANGE_OR_NAME      IN  VARCHAR2,
   X_ROW_HIGH_RANGE             IN  VARCHAR2,
   X_LEGISLATION_CODE           IN  VARCHAR2,
   X_VALUE                      IN  VARCHAR2,
   X_EFFECTIVE_START_DATE       IN  VARCHAR2,
   X_EFFECTIVE_END_DATE         IN  VARCHAR2,
   X_OWNER                      IN  VARCHAR2,
   X_LEG_VIEW                   IN  VARCHAR2
) IS

    CURSOR c_row_col_details
    IS
        SELECT pur.user_row_id,
               puc.user_column_id,
               pur.effective_start_date
          FROM pay_user_tables put,
               pay_user_rows_f pur,
               pay_user_columns puc
         WHERE pur.user_table_id  = put.user_table_id
           AND puc.user_table_id  = put.user_table_id
--         bug 9234524 convert to user key units when matching
           AND decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_LOW_RANGE_OR_NAME)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_LOW_RANGE_OR_NAME)),
                 'T', upper (X_ROW_LOW_RANGE_OR_NAME),
                 null) =
                decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_low_range_or_name)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_low_range_or_name)),
                 'T', upper (pur.row_low_range_or_name),
                 null)
           AND     ( NVL(pur.row_high_range,'NULL')   = NVL(X_ROW_HIGH_RANGE,'NULL')
                  OR decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_HIGH_RANGE)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_HIGH_RANGE)),
                 'T', upper (X_ROW_HIGH_RANGE),
                 null) =
                decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_high_range)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_high_range)),
                 'T', upper (pur.row_high_range),
                 null))
--         bug 9234524 changes end
           AND puc.user_column_name = X_USER_COLUMN_NAME
           AND put.user_table_name  = X_USER_TABLE_NAME
           AND put.legislation_code = X_LEGISLATION_CODE
           AND pur.legislation_code = X_LEGISLATION_CODE
           AND puc.legislation_code = X_LEGISLATION_CODE
	   AND fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
           BETWEEN pur.effective_start_date AND pur.effective_end_date  ;

    l_user_table_id         NUMBER;
    l_user_row_id           NUMBER;
    l_user_column_id        NUMBER;
    l_user_col_instance_id  NUMBER;
    l_object_version_number NUMBER;
    l_effective_start_date  DATE;
    l_effective_end_date    DATE;
    l_start_date            DATE;
    l_end_date              DATE;

  BEGIN

    IF (g_upload AND (g_user_table_name = X_USER_TABLE_NAME))
    THEN

        SELECT put.user_table_id,
               pur.user_row_id,
               puc.user_column_id,
               val.user_column_instance_id,
               val.object_version_number,
               val.effective_start_date,
	       val.effective_end_date
          INTO l_user_table_id,
               l_user_row_id,
               l_user_column_id,
               l_user_col_instance_id,
               l_object_version_number,
               l_effective_start_date,
               l_effective_end_date
          FROM pay_user_tables put,
               pay_user_rows_f pur,
               pay_user_columns puc,
               pay_user_column_instances_f val
         WHERE val.user_row_id    = pur.user_row_id
           AND val.user_column_id = puc.user_column_id
           AND pur.user_table_id  = put.user_table_id
           AND puc.user_column_name = X_USER_COLUMN_NAME
--         bug 9234524 convert to user key units when matching
           AND decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_LOW_RANGE_OR_NAME)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_LOW_RANGE_OR_NAME)),
                 'T', upper (X_ROW_LOW_RANGE_OR_NAME),
                 null) =
                decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_low_range_or_name)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_low_range_or_name)),
                 'T', upper (pur.row_low_range_or_name),
                 null)
           AND     ( NVL(pur.row_high_range,'NULL')   = NVL(X_ROW_HIGH_RANGE,'NULL')
                  OR decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(X_ROW_HIGH_RANGE)),
                 'N', to_char(fnd_number.canonical_to_number(X_ROW_HIGH_RANGE)),
                 'T', upper (X_ROW_HIGH_RANGE),
                 null) =
                decode
                (put.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(pur.row_high_range)),
                 'N', to_char(fnd_number.canonical_to_number(pur.row_high_range)),
                 'T', upper (pur.row_high_range),
                 null))
--         bug 9234524 changes end
           AND put.user_table_name  = X_USER_TABLE_NAME
           AND(
               (
                   put.legislation_code IS NULL
               AND val.legislation_code IS NULL
               AND pur.legislation_code IS NULL
               )
               OR
               (
                   put.legislation_code = X_LEGISLATION_CODE
               AND val.legislation_code = X_LEGISLATION_CODE
               AND pur.legislation_code = X_LEGISLATION_CODE
               )
              )
           AND fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
           BETWEEN val.effective_start_date AND val.effective_end_date
	   AND fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
           BETWEEN pur.effective_start_date AND pur.effective_end_date;

          IF (l_effective_start_date <> fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE))
          THEN

                 pay_user_column_instance_api.update_user_column_instance
                  (p_validate                      => FALSE
                  ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
                  ,p_user_column_instance_id       => l_user_col_instance_id
                  ,p_datetrack_update_mode         => hr_api.g_update
                  ,p_value                         => X_VALUE
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_start_date          => l_start_date
                  ,p_effective_end_date            => l_end_date
                  );

          END IF;

          IF (l_effective_end_date <> fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE))
          THEN

                   pay_user_column_instance_api.delete_user_column_instance
                     (p_validate                      => FALSE
                     ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE)
                     ,p_user_column_instance_id       => l_user_col_instance_id
                     ,p_datetrack_update_mode         => hr_api.g_delete
                     ,p_object_version_number         => l_object_version_number
                     ,p_effective_start_date          => l_start_date
                     ,p_effective_end_date            => l_end_date
                     );

          END IF;


    END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN

           OPEN  c_row_col_details;
           FETCH c_row_col_details INTO l_user_row_id, l_user_column_id,l_effective_start_date;
           CLOSE c_row_col_details;

           pay_user_column_instance_api.create_user_column_instance
             (p_validate                      => FALSE
             ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_START_DATE)
             ,p_user_row_id                   => l_user_row_id
             ,p_user_column_id                => l_user_column_id
             ,p_value                         => X_VALUE
             ,p_business_group_id             => NULL
             ,p_legislation_code              => X_LEGISLATION_CODE
             ,p_user_column_instance_id       => l_user_col_instance_id
             ,p_object_version_number         => l_object_version_number
             ,p_effective_start_date          => l_start_date
             ,p_effective_end_date            => l_end_date
             );



             IF (SUBSTR(X_EFFECTIVE_END_DATE,0,4) <> TO_CHAR(l_end_date,'YYYY'))
             THEN
                   pay_user_column_instance_api.delete_user_column_instance
                     (p_validate                      => FALSE
                     ,p_effective_date                => fnd_date.canonical_to_date(X_EFFECTIVE_END_DATE)
                     ,p_user_column_instance_id       => l_user_col_instance_id
                     ,p_datetrack_update_mode         => hr_api.g_delete
                     ,p_object_version_number         => l_object_version_number
                     ,p_effective_start_date          => l_start_date
                     ,p_effective_end_date            => l_end_date
                     );
             END IF;





END column_instance_upd_ins;


END pay_user_table_details_pkg;


/
