--------------------------------------------------------
--  DDL for Package Body PON_AUC_DOCTYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUC_DOCTYPES_PKG" AS
/* $Header: PONDOCTB.pls 120.4 2006/10/26 22:17:40 mxfang noship $ */



PROCEDURE insert_row (
     p_doctype_id                    IN  pon_auc_doctypes.doctype_id%TYPE
    ,p_internal_name                 IN  pon_auc_doctypes.internal_name%TYPE
    ,p_scope                         IN  pon_auc_doctypes.scope%TYPE
    ,p_status                        IN  pon_auc_doctypes.status%TYPE
    ,p_transaction_type              IN  pon_auc_doctypes.transaction_type%TYPE
    ,p_message_suffix                IN  pon_auc_doctypes.message_suffix%TYPE
    ,p_created_by                    IN  pon_auc_doctypes.created_by%TYPE
    ,p_creation_date                 IN  pon_auc_doctypes.creation_date%TYPE
    ,p_last_updated_by               IN  pon_auc_doctypes.last_updated_by%TYPE
    ,p_last_update_date              IN  pon_auc_doctypes.last_update_date%TYPE
    ,p_doctype_group_name            IN  pon_auc_doctypes.doctype_group_name%TYPE
    ,p_document_type_code            IN  pon_auc_doctypes.document_type_code%TYPE
    ,p_document_subtype              IN  pon_auc_doctypes.document_subtype%TYPE
    ,p_name                          IN  pon_auc_doctypes_tl.name%TYPE) IS
BEGIN


 INSERT INTO  pon_auc_doctypes
     ( doctype_id
      ,internal_name
      ,scope
      ,status
      ,transaction_type
      ,message_suffix
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,doctype_group_name
      ,document_type_code
      ,document_subtype)
 VALUES
     ( p_doctype_id
      ,p_internal_name
      ,p_scope
      ,p_status
      ,p_transaction_type
      ,p_message_suffix
      ,p_created_by
      ,p_creation_date
      ,p_last_updated_by
      ,p_last_update_date
      ,p_doctype_group_name
      ,p_document_type_code
      ,p_document_subtype);


  INSERT INTO pon_auc_doctypes_tl doctl
      (doctype_id
      ,name
      ,language
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,source_lang)
    SELECT
       p_doctype_id
      ,p_name
      ,l.language_code
      ,p_created_by
      ,p_creation_date
      ,p_last_updated_by
      ,p_last_update_date
      ,USERENV('LANG')
     FROM
       fnd_languages l
     WHERE installed_flag  in ('I', 'B')
       AND NOT EXISTS
         (SELECT NULL
	    FROM pon_auc_doctypes_tl doctl
	   WHERE doctl.doctype_id  = p_doctype_id
	     AND doctl.language    = l.language_code);

END insert_row;

PROCEDURE update_row (
    p_internal_name                 IN  pon_auc_doctypes.internal_name%TYPE,
    p_scope                         IN  pon_auc_doctypes.scope%TYPE,
    p_status                        IN  pon_auc_doctypes.status%TYPE,
    p_transaction_type              IN  pon_auc_doctypes.transaction_type%TYPE,
    p_message_suffix                IN  pon_auc_doctypes.message_suffix%TYPE,
    p_last_updated_by               IN  pon_auc_doctypes.last_updated_by%TYPE,
    p_last_update_date              IN  pon_auc_doctypes.last_update_date%TYPE,
    p_doctype_group_name            IN  pon_auc_doctypes.doctype_group_name%TYPE,
    p_document_type_code            IN  pon_auc_doctypes.document_type_code%TYPE,
    p_document_subtype              IN  pon_auc_doctypes.document_subtype%TYPE,
    p_name                          IN  pon_auc_doctypes_tl.name%TYPE) IS

BEGIN

   UPDATE pon_auc_doctypes doctl
      SET scope              = p_scope
         ,status             = p_status
         ,transaction_type   = p_transaction_type
         ,message_suffix     = p_message_suffix
         ,last_updated_by    = p_last_updated_by
         ,last_update_date   = p_last_update_date
         ,doctype_group_name = p_doctype_group_name
         ,document_type_code = p_document_type_code
         ,document_subtype   = p_document_subtype
     WHERE doctl.internal_name  = p_internal_name;

    IF SQL%NOTFOUND
    THEN
       RAISE NO_DATA_FOUND;
    END IF;


 UPDATE pon_auc_doctypes_tl doctl
    SET  doctl.name  =  p_name
       ,doctl.last_updated_by  =  p_last_updated_by
       ,doctl.last_update_date  =  p_last_update_date
       ,doctl.source_lang      = userenv('LANG')
  WHERE doctype_id  =  (
        SELECT doc.doctype_id
	  FROM pon_auc_doctypes doc
	 WHERE doc.internal_name = p_internal_name)
    AND USERENV('LANG') IN ( doctl.language, doctl.source_lang);

   IF SQL%NOTFOUND
   THEN
       RAISE NO_DATA_FOUND;
   END IF;

END update_row;

-- Translate_row is called during NLS translation during FNDLOAD

PROCEDURE translate_row (
     p_internal_name                IN  pon_auc_doctypes.internal_name%TYPE,
     p_name                         IN  pon_auc_doctypes_tl.name%TYPE,
     p_owner                        IN  VARCHAR2,
     p_custom_mode                  IN  VARCHAR2,
     p_last_update_date             IN  VARCHAR2
) IS

 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db

BEGIN

 f_luby := fnd_load_util.owner_id(p_owner);

 -- Translate char last_update_date to date
 f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

 select LAST_UPDATED_BY, LAST_UPDATE_DATE
 into db_luby, db_ludate
 from pon_auc_doctypes_tl
 where doctype_id  =  (
          SELECT doc.doctype_id
            FROM pon_auc_doctypes doc
           WHERE doc.internal_name = p_internal_name)
   and userenv('LANG') = LANGUAGE;

   UPDATE pon_auc_doctypes_tl doctl
      SET  doctl.name              =  p_name
          ,doctl.last_updated_by   =  f_luby
          ,doctl.last_update_date  =  f_ludate
          ,source_lang             =  userenv('LANG')
    WHERE doctype_id  =  (
          SELECT doc.doctype_id
  	    FROM pon_auc_doctypes doc
  	   WHERE doc.internal_name = p_internal_name)
      AND USERENV('LANG') IN ( doctl.language, doctl.source_lang);

 IF SQL%NOTFOUND THEN
     RAISE NO_DATA_FOUND;
 END IF;

END translate_row;

-- Load_row is called during normal insertion/updates during FNDLOAD
-- It UPDATEs the row if available, else INSERTs

PROCEDURE load_row (
    p_internal_name                 IN  pon_auc_doctypes.internal_name%TYPE,
    p_owner                         IN  VARCHAR2,
    p_last_update_date              IN  VARCHAR2,
    p_custom_mode                   IN  VARCHAR2, -- Custom mode can be FORCE
                                                  -- to force data to be uploaded
						  -- irrespective of current status
    p_scope                         IN  pon_auc_doctypes.scope%TYPE,
    p_status                        IN  pon_auc_doctypes.status%TYPE,
    p_transaction_type              IN  pon_auc_doctypes.transaction_type%TYPE,
    p_message_suffix                IN  pon_auc_doctypes.message_suffix%TYPE,
    p_doctype_group_name            IN  pon_auc_doctypes.doctype_group_name%TYPE,
    p_document_type_code            IN  pon_auc_doctypes.document_type_code%TYPE,
    p_document_subtype              IN  pon_auc_doctypes.document_subtype%TYPE,
    p_name                          IN  pon_auc_doctypes_tl.name%TYPE) IS


 -- Last update information from the file being uploaded
    l_f_last_updated_by                 pon_auc_doctypes.last_updated_by%TYPE;
    l_f_last_update_date                pon_auc_doctypes.last_update_date%TYPE;

 -- Last updated information for the row currently in the database
    l_db_last_updated_by                pon_auc_doctypes.last_updated_by%TYPE;
    l_db_last_update_date               pon_auc_doctypes.last_update_date%TYPE;

    l_doctype_id                        pon_auc_doctypes.doctype_id%TYPE;

BEGIN

-- Translate owner to file_last_updated_by
    l_f_last_updated_by := fnd_load_util.OWNER_ID(p_owner);

-- Translate char last_update_date to date
    l_f_last_update_date := NVL(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), SYSDATE);

 SELECT last_updated_by,
        last_update_date
   INTO l_db_last_updated_by,
        l_db_last_update_date
   FROM pon_auc_doctypes doc
  WHERE doc.internal_name = p_internal_name;

  update_row (
    p_internal_name         => p_internal_name,
    p_scope                 => p_scope,
    p_status                => p_status,
    p_transaction_type      => p_transaction_type,
    p_message_suffix        => p_message_suffix,
    p_last_updated_by       => l_f_last_updated_by,
    p_last_update_date      => l_f_last_update_date,
    p_doctype_group_name    => p_doctype_group_name,
    p_document_type_code    => p_document_type_code,
    p_document_subtype      => p_document_subtype,
    p_name                  => p_name);

EXCEPTION

   WHEN NO_DATA_FOUND
   THEN


  -- Need to create a new row.  Get a sequence number

  SELECT pon_auc_doctypes_s.NEXTVAL
    INTO l_doctype_id
    FROM dual;

  insert_row (
     p_doctype_id         => l_doctype_id
    ,p_internal_name      => p_internal_name
    ,p_scope              => p_scope
    ,p_status             => p_status
    ,p_transaction_type   => p_transaction_type
    ,p_message_suffix     => p_message_suffix
    ,p_created_by         => l_f_last_updated_by
    ,p_creation_date      => l_f_last_update_date
    ,p_last_updated_by    => l_f_last_updated_by
    ,p_last_update_date   => l_f_last_update_date
    ,p_doctype_group_name => p_doctype_group_name
    ,p_document_type_code => p_document_type_code
    ,p_document_subtype   => p_document_subtype
    ,p_name               => p_name);

END load_row;

PROCEDURE delete_row (
            p_internal_name   pon_auc_doctypes.internal_name%TYPE
	        ) IS

l_doctype_id  pon_auc_doctypes.doctype_id%TYPE;

BEGIN

 DELETE FROM pon_auc_doctypes doc
       WHERE doc.internal_name = p_internal_name
   RETURNING doctype_id
        INTO l_doctype_id;

 IF SQL%NOTFOUND
 THEN
   RAISE NO_DATA_FOUND;
 END IF;

 DELETE FROM pon_auc_doctypes_tl doctl
       WHERE doctl.doctype_id = l_doctype_id;

END delete_row;


PROCEDURE add_language IS

BEGIN

    INSERT INTO PON_AUC_DOCTYPES_TL (
      doctype_id,
      name,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      source_lang
    )
    SELECT
      doctl.doctype_id,
      doctl.name,
      lang.language_code,
      doctl.created_by,
      doctl.creation_date,
      doctl.last_updated_by,
      doctl.last_update_date,
      doctl.source_lang
    FROM pon_auc_doctypes_tl doctl,
         fnd_languages lang
    WHERE doctl.language = USERENV('LANG')
    AND lang.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS (SELECT NULL
                      FROM PON_AUC_DOCTYPES_TL doc2
                     WHERE doc2.doctype_id = doctl.doctype_id
                       AND doc2.language   = lang.language_code);

END add_language;

END pon_auc_doctypes_pkg;

/
