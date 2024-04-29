--------------------------------------------------------
--  DDL for Package Body JE_GR_IE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_GR_IE_RULES_PKG" as
/* $Header: jegrerb.pls 120.5 2006/04/27 09:27:34 samalhot ship $ */

PROCEDURE INSERT_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN OUT NOCOPY 	NUMBER,
  p_rule_name 			IN 	VARCHAR2,
  p_enabled_flag 		IN 	VARCHAR2,
  p_description 		IN 	VARCHAR2,
  p_attribute_category		IN      VARCHAR2,
  p_attribute1			IN 	VARCHAR2,
  p_attribute2			IN 	VARCHAR2,
  p_attribute3			IN 	VARCHAR2,
  p_attribute4			IN 	VARCHAR2,
  p_attribute5			IN 	VARCHAR2,
  p_attribute6			IN 	VARCHAR2,
  p_attribute7			IN 	VARCHAR2,
  p_attribute8			IN 	VARCHAR2,
  p_attribute9			IN 	VARCHAR2,
  p_attribute10			IN 	VARCHAR2,
  p_attribute11			IN 	VARCHAR2,
  p_attribute12			IN 	VARCHAR2,
  p_attribute13			IN 	VARCHAR2,
  p_attribute14			IN 	VARCHAR2,
  p_attribute15			IN 	VARCHAR2,
  p_creation_date 		IN 	DATE,
  p_created_by 			IN 	NUMBER,
  p_last_update_date 		IN 	DATE,
  p_last_updated_by 		IN 	NUMBER,
  p_last_update_login 		IN 	NUMBER,
  p_legal_entity_id             IN      NUMBER) IS

 l_rule_id                 je_gr_trnovr_rules.trnovr_rule_id%TYPE;

 debug_info                   VARCHAR2(250);
 current_calling_sequence VARCHAR2(250);


BEGIN

   -- Update the calling sequence
   --
    current_calling_sequence :=
     'JE_GR_IE_RULES_PKG.INSERT_ROW';

  debug_info := 'Get Rule ID from the Sequence';

  SELECT je_gr_trnovr_rules_s.nextval INTO l_rule_id FROM dual;

  debug_info := 'Insert row in je_gr_trnovr_rules';

  INSERT INTO JE_GR_TRNOVR_RULES (
    application_id,
    trnovr_rule_id,
    trnovr_rule_name,
    enabled_flag,
    description,
    attribute_category  ,
    attribute1		,
    attribute2		,
    attribute3		,
    attribute4		,
    attribute5		,
    attribute6		,
    attribute7		,
    attribute8		,
    attribute9		,
    attribute10		,
    attribute11		,
    attribute12		,
    attribute13		,
    attribute14		,
    attribute15		,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    legal_entity_id
    )
    SELECT
     p_application_id,
     l_rule_id,
     p_rule_name,
     p_enabled_flag,
     p_description,
     p_attribute_category     ,
     p_attribute1		,
     p_attribute2		,
     p_attribute3		,
     p_attribute4		,
     p_attribute5		,
     p_attribute6		,
     p_attribute7		,
     p_attribute8		,
     p_attribute9		,
     p_attribute10		,
     p_attribute11		,
     p_attribute12		,
     p_attribute13		,
     p_attribute14		,
     p_attribute15		,
     p_creation_date,
     p_created_by,
     p_last_update_date,
     p_last_updated_by,
     p_last_update_login,
     p_legal_entity_id
    FROM DUAL
    WHERE NOT EXISTS ( SELECT NULL
                       FROM je_gr_trnovr_rules
		       WHERE application_id = p_application_id
		       AND   trnovr_rule_name   = p_rule_name);

  p_rule_id := l_rule_id;

  EXCEPTION

    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
            fnd_message.set_name('JE','JE_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
		  'p_application_id = '||to_char(p_application_id)
  		||'p_rule_id = '||to_char(p_rule_id)
  		||'p_rule_name = '||p_rule_name
  		||'p_enabled_flag = '||p_enabled_flag
  		||'p_description  = '||p_description
  		||'p_creation_date = '||to_char(p_creation_date)
  		||'p_created_by = '||to_char(p_created_by)
  		||'p_last_update_date = '||to_char(p_last_update_date)
  		||'p_last_updated_by = '||to_char(p_last_updated_by)
  		||'p_last_update_login = '||to_char(p_last_update_login)
                ||'p_legal_entity_id = ' || p_legal_entity_id );

            fnd_message.set_token('DEBUG_INFO',debug_info);

        END IF;
        app_exception.raise_exception;


END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_rule_name 			IN 	VARCHAR2,
  p_description 		IN 	VARCHAR2,
  p_enabled_flag		IN	VARCHAR2,
  p_attribute_category		IN      VARCHAR2,
  p_attribute1			IN 	VARCHAR2,
  p_attribute2			IN 	VARCHAR2,
  p_attribute3			IN 	VARCHAR2,
  p_attribute4			IN 	VARCHAR2,
  p_attribute5			IN 	VARCHAR2,
  p_attribute6			IN 	VARCHAR2,
  p_attribute7			IN 	VARCHAR2,
  p_attribute8			IN 	VARCHAR2,
  p_attribute9			IN 	VARCHAR2,
  p_attribute10			IN 	VARCHAR2,
  p_attribute11			IN 	VARCHAR2,
  p_attribute12			IN 	VARCHAR2,
  p_attribute13			IN 	VARCHAR2,
  p_attribute14			IN 	VARCHAR2,
  p_attribute15			IN 	VARCHAR2
) IS

  CURSOR c IS
  SELECT
      trnovr_rule_name,
      description,
      enabled_flag
  FROM je_gr_trnovr_rules
  WHERE trnovr_rule_id = p_rule_id
  AND application_id = p_application_id
  FOR UPDATE OF trnovr_rule_id nowait;

  recinfo c%ROWTYPE;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;

  IF ((recinfo.trnovr_rule_name = p_rule_name) AND
	(recinfo.enabled_flag = p_enabled_flag)) THEN
    null;
  ELSE

    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;

  END IF;

  return;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_rule_name 			IN 	VARCHAR2,
  p_description 		IN 	VARCHAR2,
  p_enabled_flag 		IN 	VARCHAR2,
  p_attribute_category		IN      VARCHAR2,
  p_attribute1			IN 	VARCHAR2,
  p_attribute2			IN 	VARCHAR2,
  p_attribute3			IN 	VARCHAR2,
  p_attribute4			IN 	VARCHAR2,
  p_attribute5			IN 	VARCHAR2,
  p_attribute6			IN 	VARCHAR2,
  p_attribute7			IN 	VARCHAR2,
  p_attribute8			IN 	VARCHAR2,
  p_attribute9			IN 	VARCHAR2,
  p_attribute10			IN 	VARCHAR2,
  p_attribute11			IN 	VARCHAR2,
  p_attribute12			IN 	VARCHAR2,
  p_attribute13			IN 	VARCHAR2,
  p_attribute14			IN 	VARCHAR2,
  p_attribute15			IN 	VARCHAR2,
  p_last_update_date 		IN 	DATE,
  p_last_updated_by 		IN 	NUMBER,
  p_last_update_login 		IN 	NUMBER,
  p_legal_entity_id             IN	NUMBER
) IS

 debug_info                   VARCHAR2(250);
 current_calling_sequence VARCHAR2(250);

BEGIN

   -- Update the calling sequence
   --
    current_calling_sequence :=
     'JE_GR_IE_RULES_PKG.UPDATE_ROW';


  debug_info := 'Update row in je_gr_trnovr_rules';

  UPDATE je_gr_trnovr_rules
  SET
    trnovr_rule_name 	= p_rule_name,
    description 	= p_description,
    enabled_flag 	= p_enabled_flag,
    attribute_category  = p_attribute_category,
    attribute1		= p_attribute1,
    attribute2		= p_attribute2,
    attribute3		= p_attribute3,
    attribute4		= p_attribute4,
    attribute5		= p_attribute5,
    attribute6 		= p_attribute6,
    attribute7		= p_attribute7,
    attribute8		= p_attribute8,
    attribute9		= p_attribute9,
    attribute10		= p_attribute10,
    attribute11 	= p_attribute11,
    attribute12 	= p_attribute12,
    attribute13		= p_attribute13,
    attribute14		= p_attribute14,
    attribute15		= p_attribute15,
    last_update_date 	= p_last_update_date,
    last_updated_by 	= p_last_updated_by,
    last_update_login 	= p_last_update_login,
    legal_entity_id     = p_legal_entity_id
  WHERE trnovr_rule_id 	= p_rule_id
  AND 	application_id 	= p_application_id;

  EXCEPTION

    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
            fnd_message.set_name('JE','JE_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
		  'p_application_id = '||to_char(p_application_id)
  		||'p_rule_id = '||to_char(p_rule_id)
  		||'p_rule_name = '||p_rule_name
  		||'p_enabled_flag = '||p_enabled_flag
  		||'p_description  = '||p_description
  		||'p_last_update_date = '||to_char(p_last_update_date)
  		||'p_last_updated_by = '||to_char(p_last_updated_by)
  		||'p_last_update_login = '||to_char(p_last_update_login)
		||'p_legal_entity = '||p_legal_entity_id);
            fnd_message.set_token('DEBUG_INFO',debug_info);
        END IF;
        app_exception.raise_exception;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER
) IS

 debug_info                   VARCHAR2(250);
 current_calling_sequence VARCHAR2(250);

BEGIN

   -- Update the calling sequence
   --
    current_calling_sequence :=
     'JE_GR_IE_RULES_PKG.DELETE_ROW';

  debug_info := 'delete row in je_gr_trnovr_rule_lines';

  DELETE FROM je_gr_trnovr_rule_lines
  WHERE  trnovr_rule_id = p_rule_id;

  debug_info := 'delete row in je_gr_trnovr_rules';

  DELETE FROM je_gr_trnovr_rules
  WHERE application_id = p_application_id
  AND trnovr_rule_id = p_rule_id;

  EXCEPTION

    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
            fnd_message.set_name('JE','JE_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
		  'p_application_id = '||to_char(p_application_id)
  		||'p_rule_id = '||to_char(p_rule_id));
            fnd_message.set_token('DEBUG_INFO',debug_info);
        END IF;
        app_exception.raise_exception;

END DELETE_ROW;

END JE_GR_IE_RULES_PKG;

/
