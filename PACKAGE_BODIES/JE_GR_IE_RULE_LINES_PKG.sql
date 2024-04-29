--------------------------------------------------------
--  DDL for Package Body JE_GR_IE_RULE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_GR_IE_RULE_LINES_PKG" as
/* $Header: jegrerlb.pls 115.1 2002/11/12 12:02:06 arimai ship $ */

PROCEDURE INSERT_ROW (
  p_rule_line_id 		IN OUT NOCOPY NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_application_id		IN 	NUMBER,
  p_lookup_type 		IN 	VARCHAR2,
  p_lookup_code 		IN 	VARCHAR2,
  p_exclude_flag		IN 	VARCHAR2,
  p_attribute_category     	IN      VARCHAR2,
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
  p_last_update_login 		IN 	NUMBER

) IS

 l_rule_line_id                 je_gr_trnovr_rule_lines.trnovr_rule_line_id%TYPE;

 debug_info                   VARCHAR2(250);
 current_calling_sequence VARCHAR2(250);


BEGIN


  -- Update the calling sequence
  --
  current_calling_sequence :=
     'JE_GR_IE_RULE_LINES_PKG.INSERT_ROW';

  debug_info := 'Get Rule Line ID from the Sequence';

  SELECT je_gr_trnovr_rule_lines_s.nextval INTO l_rule_line_id FROM dual;

  debug_info := 'Insert row in je_gr_trnovr_rule_lines';

  INSERT INTO je_gr_trnovr_rule_lines (
    trnovr_rule_line_id,
    trnovr_rule_id,
    application_id,
    lookup_type,
    lookup_code,
    exclude_flag,
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
    last_update_login
    )
    SELECT
     l_rule_line_id,
     p_rule_id,
     p_application_id,
     p_lookup_type,
     p_lookup_code,
     p_exclude_flag,
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
     p_last_update_login
   FROM DUAL
   WHERE NOT EXISTS ( SELECT NULL
                      FROM je_gr_trnovr_rule_lines
		      WHERE trnovr_rule_id = p_rule_id
		      AND   application_id = p_application_id
		      AND   lookup_type = p_lookup_type
		      AND   lookup_code = p_lookup_code);

  p_rule_line_id := l_rule_line_id;

  EXCEPTION

    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
            fnd_message.set_name('JE','JE_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
  	       	  'p_rule_id = '||to_char(p_rule_id)
  		||'p_lookup_type = '||p_lookup_type
  		||'p_lookup_code = '||p_lookup_code
  		||'p_exclude_flag = '||p_exclude_flag
  		||'p_creation_date = '||to_char(p_creation_date)
  		||'p_created_by = '||to_char(p_created_by)
  		||'p_last_update_date = '||to_char(p_last_update_date)
  		||'p_last_updated_by = '||to_char(p_last_updated_by)
  		||'p_last_update_login = '||to_char(p_last_update_login));

            fnd_message.set_token('DEBUG_INFO',debug_info);

        END IF;
        app_exception.raise_exception;


END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_rule_line_id 		IN  	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_application_id		IN 	NUMBER,
  p_lookup_type 		IN 	VARCHAR2,
  p_lookup_code 		IN 	VARCHAR2,
  p_exclude_flag		IN 	VARCHAR2,
  p_attribute_category     	IN      VARCHAR2,
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

  CURSOR c1 IS
    SELECT
       	lookup_type ,
    	lookup_code   ,
    	exclude_flag        ,
    	attribute_category ,
    	attribute1	,
    	attribute2	,
    	attribute3	,
    	attribute4	,
    	attribute5	,
    	attribute6 	,
    	attribute7	,
    	attribute8	,
    	attribute9	,
    	attribute10,
    	attribute11,
    	attribute12,
    	attribute13,
    	attribute14,
    	attribute15
    FROM je_gr_trnovr_rule_lines
    WHERE trnovr_rule_line_id = p_rule_line_id
    AND   trnovr_rule_id = p_rule_id
    AND   application_id = p_application_id
    FOR UPDATE OF trnovr_rule_line_id nowait;
    rlinfo c1%ROWTYPE;
begin
  for rlinfo in c1 loop
      if ( ((rlinfo.lookup_type = p_lookup_type)
               OR ((rlinfo.lookup_type is null)
                   AND (p_lookup_type is null)))
          AND ((rlinfo.lookup_code = p_lookup_code)
               OR ((rlinfo.lookup_code is null)
                   AND (p_lookup_code is null)))
          AND  rlinfo.exclude_flag = p_exclude_flag
          AND ((rlinfo.attribute_category = p_attribute_category)
               OR ((rlinfo.attribute_category is null) AND (p_attribute_category is null)))
          AND ((rlinfo.attribute1 = p_attribute1)
               OR ((rlinfo.attribute1 is null) AND (p_attribute1 is null)))
          AND ((rlinfo.attribute2 = p_attribute2)
               OR ((rlinfo.attribute2 is null) AND (p_attribute2 is null)))
          AND ((rlinfo.attribute3 = p_attribute3)
               OR ((rlinfo.attribute3 is null) AND (p_attribute3 is null)))
          AND ((rlinfo.attribute4 = p_attribute4)
               OR ((rlinfo.attribute4 is null) AND (p_attribute4 is null)))
          AND ((rlinfo.attribute5 = p_attribute5)
               OR ((rlinfo.attribute5 is null) AND (p_attribute5 is null)))
          AND ((rlinfo.attribute6 = p_attribute6)
               OR ((rlinfo.attribute6 is null) AND (p_attribute6 is null)))
          AND ((rlinfo.attribute7 = p_attribute7)
               OR ((rlinfo.attribute7 is null) AND (p_attribute7 is null)))
          AND ((rlinfo.attribute8 = p_attribute8)
               OR ((rlinfo.attribute8 is null) AND (p_attribute8 is null)))
          AND ((rlinfo.attribute9 = p_attribute9)
               OR ((rlinfo.attribute9 is null) AND (p_attribute9 is null)))
          AND ((rlinfo.attribute10 = p_attribute10)
               OR ((rlinfo.attribute10 is null) AND (p_attribute10 is null)))
          AND ((rlinfo.attribute11 = p_attribute11)
               OR ((rlinfo.attribute11 is null) AND (p_attribute11 is null)))
          AND ((rlinfo.attribute12 = p_attribute12)
               OR ((rlinfo.attribute12 is null) AND (p_attribute12 is null)))
          AND ((rlinfo.attribute13 = p_attribute13)
               OR ((rlinfo.attribute13 is null) AND (p_attribute13 is null)))
          AND ((rlinfo.attribute14 = p_attribute14)
               OR ((rlinfo.attribute14 is null) AND (p_attribute14 is null)))
          AND ((rlinfo.attribute15 = p_attribute15)
               OR ((rlinfo.attribute15 is null) AND (p_attribute15 is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

PROCEDURE UPDATE_ROW (
  p_rule_line_id 		IN  	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_application_id		IN 	NUMBER,
  p_lookup_type 		IN 	VARCHAR2,
  p_lookup_code 		IN 	VARCHAR2,
  p_exclude_flag		IN 	VARCHAR2,
  p_attribute_category     	IN      VARCHAR2,
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
  p_last_update_login 		IN 	NUMBER
) IS

 debug_info                   VARCHAR2(250);
 current_calling_sequence VARCHAR2(250);

BEGIN

   -- Update the calling sequence
   --
    current_calling_sequence :=
     'JE_GR_IE_RULE_LINES_PKG.UPDATE_ROW';

  debug_info := 'Update row in je_gr_trnovr_rule_lines';

  UPDATE je_gr_trnovr_rule_lines
  SET
    lookup_type 	= p_lookup_type,
    lookup_code   	= p_lookup_code,
    exclude_flag        = p_exclude_flag,
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
    last_update_login 	= p_last_update_login
  WHERE application_id  = p_application_id
  AND   trnovr_rule_id 	= p_rule_id
  AND 	trnovr_rule_line_id 	= p_rule_line_id;

  EXCEPTION

    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
            fnd_message.set_name('JE','JE_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
		  'p_rule_id = '||to_char(p_rule_id)
		||'p_rule_line_id = '||to_char(p_rule_line_id)
  		||'p_last_update_date = '||to_char(p_last_update_date)
  		||'p_last_updated_by = '||to_char(p_last_updated_by)
  		||'p_last_update_login = '||to_char(p_last_update_login));
            fnd_message.set_token('DEBUG_INFO',debug_info);
        END IF;
        app_exception.raise_exception;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_rule_line_id 	IN 	NUMBER,
  p_rule_id 		IN 	NUMBER
) IS

 debug_info                   VARCHAR2(250);
 current_calling_sequence VARCHAR2(250);

BEGIN

   -- Update the calling sequence
   --
  current_calling_sequence :=
     'JE_GR_IE_RULE_LINES_PKG.DELETE_ROW';

  debug_info := 'delete row in je_gr_trnovr_rule_lines';

  DELETE FROM je_gr_trnovr_rule_lines
  WHERE  trnovr_rule_id = p_rule_id
  and    trnovr_rule_line_id = p_rule_line_id;

  EXCEPTION

    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
            fnd_message.set_name('JE','JE_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
		 'p_rule_line_id = '||to_char(p_rule_line_id)
  		||'p_rule_id = '||to_char(p_rule_id));
            fnd_message.set_token('DEBUG_INFO',debug_info);
        END IF;
        app_exception.raise_exception;

END DELETE_ROW;

end JE_GR_IE_RULE_LINES_PKG;

/
