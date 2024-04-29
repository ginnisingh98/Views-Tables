--------------------------------------------------------
--  DDL for Package Body ZX_EVENT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_EVENT_CLASSES_PKG" as
/* $Header: zxieventb.pls 120.10 2006/10/27 17:15:55 appradha ship $ */

  g_current_runtime_level CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_level_statement       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE insert_row (
  x_tax_event_class_code IN VARCHAR2,
  x_normal_sign_flag     IN VARCHAR2,
  x_intrcmp_tx_cls_code  IN VARCHAR2,
  x_creation_date        IN DATE,
  x_created_by           IN NUMBER,
  x_last_update_date     IN DATE,
  x_last_updated_by      IN NUMBER,
  x_last_update_login    IN NUMBER,
  x_tax_event_class_name IN VARCHAR2
) is

  CURSOR C IS SELECT rowid FROM zx_event_classes_b
    WHERE tax_event_class_code = x_tax_event_class_code;

  clsinfo c%rowtype;
BEGIN
   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                    'ZX_EVENT_CLASSES_PKG.',
                    'Insert_Row (+)');
   END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                    'ZX_EVENT_CLASSES_PKG.Insert_Row',
                    'Insert into ZX_EVENT_CLASSES_B (+)');
   END IF;

   INSERT INTO zx_event_classes_b  (
     tax_event_class_code ,
     normal_sign_flag ,
     asc_intrcmp_tx_evnt_cls_code,
     creation_date ,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login )
   VALUES (
     x_tax_event_class_code ,
     x_normal_sign_flag ,
     x_intrcmp_tx_cls_code,
     x_creation_date,
     x_created_by,
     x_last_update_date,
     x_last_updated_by,
     x_last_update_login
   );

   INSERT INTO zx_event_classes_tl (
     tax_event_class_code,
     tax_event_class_name,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     language,
     source_lang
    )
    SELECT
      x_tax_event_class_code,
      x_tax_event_class_name,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l.language_code,
      userenv('lang')
    FROM fnd_languages l
    WHERE l.installed_flag IN ('I', 'B')
    AND NOT EXISTS
      (SELECT null
       FROM zx_event_classes_tl cls
       WHERE cls.tax_event_class_code = x_tax_event_class_code
         AND cls.language = l.language_code);

    OPEN c;
    FETCH c INTO clsinfo;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_EVENT_CLASSES_PKG.Insert_Row',
                     'Insert into ZX_EVENT_CLASSES_B (-)');
    END IF;
END insert_row;


PROCEDURE translate_row
( x_owner                IN VARCHAR2,
  x_tax_event_class_code IN VARCHAR2,
  x_tax_event_class_name IN VARCHAR2,
  x_last_update_date     IN VARCHAR2,
  x_custom_mode          IN VARCHAR2) IS

  f_luby number;
  f_ludate date;
  db_luby number;
  db_ludate date;

  BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_EVENT_CLASSES_PKG',
                     'Translate_row (+)');
    END IF;

    --Translate owner to file_last_updated_by
    f_luby:= fnd_load_util.owner_id(x_owner);
    --Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date,'DD/MM/YYYY'),sysdate);

    BEGIN
      SELECT decode (last_updated_by,1,1,0), last_update_date
      INTO db_luby, db_ludate
      FROM  zx_event_classes_tl
      WHERE tax_event_class_code = x_tax_event_class_code
        AND language = userenv('LANG');

        IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                     db_ludate, x_custom_mode)) THEN
          UPDATE zx_event_classes_tl SET
            tax_event_class_name = x_tax_event_class_name,
            last_update_date     = f_ludate,
            last_updated_by      = f_luby,
            last_update_login    = 0,
            source_lang          = userenv ('LANG')
          WHERE userenv('LANG') IN (language,source_lang)
             AND tax_event_class_code = x_tax_event_class_code;
         END IF;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             NULL;
     END;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                     'ZX_EVENT_CLASSES_PKG.Translate_row',
                     'Insert into ZX_EVENT_CLASSES_TL (-)');
      END IF;
END translate_row;


PROCEDURE load_row
 (x_owner                in VARCHAR2,
  x_tax_event_class_code in VARCHAR2,
  x_normal_sign_flag     in VARCHAR2,
  x_intrcmp_tx_cls_code  in VARCHAR2,
  x_last_update_date     in VARCHAR2,
  x_tax_event_class_name in VARCHAR2,
  x_custom_mode          in VARCHAR2) is

  row_id varchar2(64);
  f_luby number;
  f_ludate date;
  db_luby number;
  db_ludate date;

  BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX_EVENT_CLASSES_PKG',
                     'Load_Row (+)');
    END IF;
    --Translate owner to file_last_updated_by
    f_luby:= fnd_load_util.owner_id(x_owner);
    --Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date,'DD/MM/YYYY'),sysdate);

    BEGIN
       SELECT decode (LAST_UPDATED_BY,1,1,0), LAST_UPDATE_DATE
       INTO db_luby, db_ludate
       FROM zx_event_classes_b
       WHERE tax_event_class_code = x_tax_event_class_code;

       -- Record should be updated only if :
       -- a. file owner is CUSTOM and db owner is SEED
       -- b. owners are the same, and file_date > db_date
       IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                     db_ludate, x_custom_mode)) THEN
         UPDATE zx_event_classes_b
          SET normal_sign_flag = x_normal_sign_flag ,
              asc_intrcmp_tx_evnt_cls_code = x_intrcmp_tx_cls_code,
              last_update_date = f_ludate,
              last_updated_by = f_luby,
              last_update_login = 0
          where TAX_EVENT_CLASS_CODE = x_tax_event_class_code;
       END IF;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            insert_row (
              x_tax_event_class_code => x_tax_event_class_code ,
              x_normal_sign_flag     => x_normal_sign_flag ,
              x_intrcmp_tx_cls_code  => x_intrcmp_tx_cls_code,
              x_creation_date        => f_ludate,
              x_created_by           => f_luby,
              x_last_update_date     => f_ludate,
              x_last_updated_by      => f_luby,
              x_last_update_login    => 0,
              x_tax_event_class_name => x_tax_event_class_name);
     END;
     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                     'ZX_EVENT_CLASSES_PKG.Load_Row',
                     'Load_row (-)');
     END IF;
END load_row;


PROCEDURE add_language
IS
BEGIN
  DELETE FROM zx_event_classes_tl T
  WHERE NOT EXISTS
    (SELECT null
    FROM ZX_EVENT_CLASSES_B B
    WHERE B.tax_event_class_code = T.tax_event_class_code
    );

  UPDATE ZX_EVENT_CLASSES_TL T SET (
      TAX_EVENT_CLASS_NAME
    ) = (select
      B.TAX_EVENT_CLASS_NAME
    from ZX_EVENT_CLASSES_TL B
    where B.TAX_EVENT_CLASS_CODE = T.TAX_EVENT_CLASS_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAX_EVENT_CLASS_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TAX_EVENT_CLASS_CODE,
      SUBT.LANGUAGE
    from ZX_EVENT_CLASSES_TL SUBB, ZX_EVENT_CLASSES_TL SUBT
    where SUBB.TAX_EVENT_CLASS_CODE = SUBT.TAX_EVENT_CLASS_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_EVENT_CLASS_NAME <> SUBT.TAX_EVENT_CLASS_NAME
  ));

  insert into ZX_EVENT_CLASSES_TL (
    TAX_EVENT_CLASS_CODE,
    TAX_EVENT_CLASS_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TAX_EVENT_CLASS_CODE,
    B.TAX_EVENT_CLASS_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_EVENT_CLASSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_EVENT_CLASSES_TL T
    where T.TAX_EVENT_CLASS_CODE = B.TAX_EVENT_CLASS_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end add_language;

end ZX_EVENT_CLASSES_PKG;

/
