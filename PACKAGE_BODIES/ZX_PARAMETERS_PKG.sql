--------------------------------------------------------
--  DDL for Package Body ZX_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PARAMETERS_PKG" as
/* $Header: zxiparameterb.pls 120.6 2005/10/05 22:11:03 vsidhart ship $ */

  g_current_runtime_level CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_level_statement       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE insert_row (
  x_tax_parameter_code IN VARCHAR2,
  x_tax_parameter_type IN VARCHAR2,
  x_format_type        IN VARCHAR2,
  x_max_size           IN NUMBER,
  x_seeded_flag        IN VARCHAR2,
  x_enabled_flag       IN VARCHAR2,
  x_generate_get_flag  IN VARCHAR2,
  x_allow_override     IN VARCHAR2,
  x_tax_parameter_name IN VARCHAR2,
  x_creation_date      IN DATE,
  x_created_by         IN NUMBER,
  x_last_update_date   IN DATE,
  x_last_updated_by    IN NUMBER,
  x_last_update_login  IN NUMBER
) IS
  CURSOR c IS SELECT rowid FROM zx_parameters_b
    WHERE tax_parameter_code = x_tax_parameter_code;
  prminfo c%ROWTYPE;
  BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG',
                     'Insert_Row (+)');
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG.Insert_Row',
                     'Insert into ZX_PARAMETERS_B (+)');
    END IF;

    INSERT INTO zx_parameters_b (
      tax_parameter_code,
      tax_parameter_type_code,
      format_type_code,
      max_size,
      seeded_flag,
      enabled_flag,
      generate_get_flag,
      allow_override_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
      ) VALUES (
      x_tax_parameter_code,
      x_tax_parameter_type,
      x_format_type,
      x_max_size,
      x_seeded_flag,
      x_enabled_flag,
      x_generate_get_flag,
      x_allow_override,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
      );

    INSERT INTO zx_parameters_tl (
      tax_parameter_code,
      tax_parameter_name,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      language,
      source_lang
      )
     SELECT
        x_tax_parameter_code,
        x_tax_parameter_name,
        x_creation_date,
        x_created_by,
        x_last_update_date,
        x_last_updated_by,
        x_last_update_login,
        l.language_code,
        userenv('LANG')
    FROM fnd_languages l
    WHERE l.installed_flag IN ('I', 'B')
    AND NOT EXISTS
      (SELECT NULL
       FROM zx_parameters_tl t
       WHERE t.tax_parameter_code = x_tax_parameter_code
         AND t.language = l.language_code);

    OPEN c;
    FETCH c INTO prminfo;
    IF (c%notfound) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
  CLOSE c;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG.Insert_Row',
                     'Insert into ZX_PARAMETERS_B (-)');
  END IF;
END INSERT_ROW;



PROCEDURE translate_row
( x_tax_parameter_code IN VARCHAR2,
  x_owner              IN VARCHAR2,
  x_tax_parameter_name IN VARCHAR2,
  x_last_update_date   IN VARCHAR2,
  x_custom_mode        IN VARCHAR2 ) IS

  f_luby number;
  f_ludate date;
  db_luby number;
  db_ludate date;

  BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG',
                     'Translate_Row (+)');
    END IF;

    --Translate owner to file_last_updated_by
    f_luby:= fnd_load_util.owner_id(x_owner);
    --Translate char last_update_date to date
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE,'DD/MM/YYYY'),sysdate);

    BEGIN
      SELECT decode (p.seeded_flag,'Y',1,0), t.last_update_date
      INTO db_luby, db_ludate
      FROM zx_parameters_tl t, zx_parameters_b p
      WHERE t.tax_parameter_code = p.tax_parameter_code
        AND t.tax_parameter_code = X_TAX_PARAMETER_CODE
        AND t.language = userenv('LANG');

      IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                     db_ludate, x_custom_mode)) THEN
          UPDATE zx_parameters_tl SET
             tax_parameter_name = x_tax_parameter_name,
             last_update_date = f_ludate,
             last_updated_by = f_luby,
             last_update_login = 0,
             source_lang = userenv ('LANG')
           WHERE  userenv('LANG') IN (language,source_lang)
           AND tax_parameter_code = x_tax_parameter_code;
         END IF;

         EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --Do not insert missing translation, skip this row
            NULL;
      END;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG',
                     'Translate_Row (-)');
      END IF;
END translate_row;


PROCEDURE load_row
( x_tax_parameter_code IN VARCHAR2,
  x_owner              IN VARCHAR2,
  x_tax_parameter_type IN VARCHAR2,
  x_format_type        IN VARCHAR2,
  x_max_size           IN VARCHAR2,
  x_enabled_flag       IN VARCHAR2,
  x_generate_get_flag  IN VARCHAR2,
  x_tax_parameter_name IN VARCHAR2,
  x_allow_override     IN VARCHAR2,
  x_last_update_date   IN VARCHAR2,
  x_custom_mode        IN VARCHAR2 ) IS

  f_luby number;
  f_ludate date;
  db_luby number;
  db_ludate date;
  l_max_size number;

  BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG',
                     'Load_Row (+)');
    END IF;
    --Translate owner to file_last_updated_by
    f_luby:= fnd_load_util.owner_id(x_owner);
    --Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date,'DD/MM/YYYY'),sysdate);

    --Analyze and set up the correct value for the nullable parameters
    IF (x_max_size = fnd_user_pkg.null_char) then
      l_max_size := fnd_user_pkg.null_number;
    ELSE
      l_max_size := to_number(x_max_size);
    END IF;

    BEGIN
      SELECT decode (seeded_flag,'Y',1,0), last_update_date
      INTO db_luby, db_ludate
      FROM zx_parameters_b
      WHERE tax_parameter_code = x_tax_parameter_code;

       -- Record should be updated only if :
       -- a. file owner is CUSTOM and db owner is SEED
       -- b. owners are the same, and file_date > db_date
       IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                     db_ludate, x_custom_mode)) THEN
         UPDATE zx_parameters_b
          SET tax_parameter_type_code = x_tax_parameter_type,
              format_type_code = x_format_type,
              allow_override_flag = x_allow_override,
              enabled_flag = x_enabled_flag,
              generate_get_flag = x_generate_get_flag,
              max_size = l_max_size,
              last_update_date = f_ludate,
              last_updated_by = f_luby,
              last_update_login = 0
           WHERE tax_parameter_code = x_tax_parameter_code;
       END IF;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            insert_row (
               x_tax_parameter_code => x_tax_parameter_code,
               x_tax_parameter_type => x_tax_parameter_type,
               x_format_type        => x_format_type,
               x_max_size           => l_max_size,
               x_seeded_flag        => 'Y',
               x_enabled_flag       => x_enabled_flag,
               x_generate_get_flag  => x_generate_get_flag,
               x_allow_override     => x_allow_override,
               x_tax_parameter_name => x_tax_parameter_name,
               x_last_update_date   => f_ludate,
               x_creation_date      => f_ludate,
               x_created_by         => f_luby,
               x_last_updated_by    => f_luby,
               x_last_update_login  => 0 );
      END;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX_PARAMETERS_PKG',
                     'Load_Row (+)');
      END IF;
  END load_row;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_PARAMETERS_TL T
  where not exists
    (select NULL
    from ZX_PARAMETERS_B B
    where B.TAX_PARAMETER_CODE = T.TAX_PARAMETER_CODE
    );

  update ZX_PARAMETERS_TL T set (
      TAX_PARAMETER_NAME
    ) = (select
      B.TAX_PARAMETER_NAME
    from ZX_PARAMETERS_TL B
    where B.TAX_PARAMETER_CODE = T.TAX_PARAMETER_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAX_PARAMETER_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TAX_PARAMETER_CODE,
      SUBT.LANGUAGE
    from ZX_PARAMETERS_TL SUBB, ZX_PARAMETERS_TL SUBT
    where SUBB.TAX_PARAMETER_CODE = SUBT.TAX_PARAMETER_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_PARAMETER_NAME <> SUBT.TAX_PARAMETER_NAME
  ));

  insert into ZX_PARAMETERS_TL (
    TAX_PARAMETER_CODE,
    TAX_PARAMETER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TAX_PARAMETER_CODE,
    B.TAX_PARAMETER_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_PARAMETERS_TL T
    where T.TAX_PARAMETER_CODE = B.TAX_PARAMETER_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
end ZX_PARAMETERS_PKG;

/
