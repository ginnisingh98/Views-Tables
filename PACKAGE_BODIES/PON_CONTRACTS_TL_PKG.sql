--------------------------------------------------------
--  DDL for Package Body PON_CONTRACTS_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_CONTRACTS_TL_PKG" AS
/* $Header: PONCNTB.pls 120.0.12010000.4 2013/04/24 17:08:01 pamaniko ship $ */

PROCEDURE add_language IS

BEGIN
    INSERT INTO PON_CONTRACTS_TL (
      CONTRACT_ID,
      VERSION_NUM,
      TITLE,
      ABSTRACT,
      BODY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      source_lang
    )
    SELECT
      cont.CONTRACT_ID,
      cont.VERSION_NUM,
      cont.TITLE,
      cont.ABSTRACT,
      cont.BODY,
      cont.ATTRIBUTE1,
      cont.ATTRIBUTE2,
      cont.ATTRIBUTE3,
      cont.ATTRIBUTE4,
      cont.ATTRIBUTE5,
      lang.language_code,
      cont.created_by,
      SYSDATE,
      cont.last_updated_by,
      SYSDATE,
      cont.source_lang
    FROM pon_contracts_tl cont,
         fnd_languages lang
    WHERE cont.language = USERENV('LANG')
    AND lang.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS (SELECT NULL
                      FROM pon_contracts_tl cont2
                     WHERE cont2.contract_id = cont.contract_id
                     and cont2.version_num = cont.version_num
                       AND cont2.language   = lang.language_code);

END add_language;

procedure copy_attachments(ENTITY_NAME VARCHAR2,
		                       pk1 VARCHAR2,
		                       pk2 VARCHAR2,
                           pk3 VARCHAR2,
                           pk4 VARCHAR2)
IS

CURSOR c_lang_code is
Select language_code
from fnd_languages_vl
where installed_flag in ('I','B');

BEGIN

FOR rec IN c_lang_code LOOP

--           FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
--        ( x_entity_name             => 'entity_name',
--          x_pk1_value               => pk1,
--          x_pk2_value               => pk3,
--          x_pk3_value               => rec.language_code,
--         x_pk4_value               => pk4,
--          x_delete_document_flag    => 'Y'
--        );


           fnd_attached_documents2_pkg.
               copy_attachments(
              X_from_entity_name => entity_name,
              X_from_pk1_value => pk1,
              X_from_pk2_value => pk2,
              X_from_pk3_value => rec.language_code,
              X_from_pk4_value =>  pk4,
              X_to_entity_name => entity_name,
              X_to_pk1_value => pk1,
              X_to_pk2_value => pk3,
              X_to_pk3_value => rec.language_code,
              X_to_pk4_value => pk4,
              X_created_by => fnd_global.user_id,
              X_last_update_login => fnd_global.user_id
              );

END LOOP;


END copy_attachments;

END pon_contracts_tl_pkg;

/
