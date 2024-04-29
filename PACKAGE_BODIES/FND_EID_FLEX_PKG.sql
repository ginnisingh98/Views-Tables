--------------------------------------------------------
--  DDL for Package Body FND_EID_FLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_FLEX_PKG" AS
-- $Header: fndeidflexb.pls 120.0.12010000.7 2013/01/17 10:22:56 varkashy noship $


/* Function : get_dff_kvp_app
   Usage:
   Input Parameter
   p_table_name	  : Name of the table for which DFF is defined
   p_application_id : application id for the data store
   p_row_id	  : Record of passed table name for which DFF information to be retrieved
   p_lang	  : Language
   p_dff_name	  : Name of the DFF to be retrievedto be retrieved. Do not
  		    pass anything if you want to retrieve for all DFF defined for the record
   p_context	  : Pass specific Context name if only information related to
  		    a specific context need to be retrieved.Do not pass anything  for all context

   Output of the function
    This function will return a string of key value pair for each DFF column for
    the record separated by a delimiter '|'. Columns are separated by '||'


 */

FUNCTION get_dff_kvp_app
     (p_table_name  IN VARCHAR2,
      p_application_id IN NUMBER,
      p_row_id	    IN ROWID,
      p_lang	    IN VARCHAR2,
      p_dff_name    IN VARCHAR2 DEFAULT NULL,
      p_context     IN VARCHAR2 DEFAULT NULL,
      p_ignore     IN VARCHAR2 DEFAULT 'N')
   RETURN VARCHAR2 IS

--variables
  l_str	                VARCHAR2(150);
  l_dff_name	        VARCHAR2(100)   := null;
  l_concatenated_return	VARCHAR2(20000) := null;
  l_stmt                VARCHAR2(1000);
  l_context             VARCHAR2(100)   := p_context;
  l_context_col         VARCHAR2(100);
  l_stmt_c              VARCHAR2(1000);

  CURSOR c_dff IS
  SELECT descriptive_flexfield_name
    INTO l_dff_name
    from FND_DESCRIPTIVE_FLEXS
   where application_table_name = p_table_name
    and  application_id= p_application_id;

  CURSOR c_segments_context IS
  SELECT  B.APPLICATION_COLUMN_NAME, T.FORM_LEFT_PROMPT END_USER_COLUMN_NAME
    from FND_DESCR_FLEX_COL_USAGE_TL T, FND_DESCR_FLEX_COLUMN_USAGES B
   WHERE B.DESCRIPTIVE_FLEXFIELD_NAME=l_dff_name
     and B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     and B.DESCRIPTIVE_FLEX_CONTEXT_CODE = T.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and B.DESCRIPTIVE_FLEX_CONTEXT_CODE = l_context
     and B.APPLICATION_COLUMN_NAME = T.APPLICATION_COLUMN_NAME
     and b.enabled_flag='Y'
     and T.LANGUAGE = p_lang
     and B.APPLICATION_ID = p_application_id;

  CURSOR c_segments IS
  SELECT B.APPLICATION_COLUMN_NAME,T.FORM_LEFT_PROMPT END_USER_COLUMN_NAME
    FROM FND_DESCR_FLEX_COL_USAGE_TL T, FND_DESCR_FLEX_COLUMN_USAGES B
   WHERE B.DESCRIPTIVE_FLEXFIELD_NAME=l_dff_name
     AND B.APPLICATION_ID = T.APPLICATION_ID
     AND B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     AND B.DESCRIPTIVE_FLEX_CONTEXT_CODE = T.DESCRIPTIVE_FLEX_CONTEXT_CODE
     AND B.DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Global Data Elements'
     AND B.APPLICATION_COLUMN_NAME = T.APPLICATION_COLUMN_NAME
     AND b.enabled_flag='Y'
     AND T.LANGUAGE = p_lang
     AND B.APPLICATION_ID = p_application_id;

BEGIN
  IF p_dff_name IS NULL THEN

     FOR dff_rec in c_dff LOOP
	l_dff_name := dff_rec.descriptive_flexfield_name;

        IF l_context IS NULL THEN
          SELECT context_column_name
	    INTO l_context_col
	    FROM fnd_descriptive_flexs_vl
	   WHERE descriptive_flexfield_name = l_dff_name
	     AND application_table_name = p_table_name
       AND application_id = p_application_id;

           l_stmt_c := 'SELECT ' || l_context_col ||
                       ' FROM ' || P_table_name ||
                       ' WHERE ROWID = :1';

           EXECUTE IMMEDIATE l_stmt_c INTO l_context using p_row_id ;

	END IF;

	FOR segment_rec IN c_segments LOOP
          l_str := NULL;
          l_stmt := 'SELECT ' ||  segment_rec.application_column_name ||
                    ' FROM ' || P_table_name ||
                    ' WHERE ROWID = :1';

          EXECUTE IMMEDIATE l_stmt INTO l_str using p_row_id ;

          IF l_Str IS NOT NULL THEN
             l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|'||l_Str||'||';
          ELSE
		   if p_ignore='N' then
             	l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|  '||'||';
		   end if;
          END IF;

        END LOOP;

        IF l_context IS NOT NULL THEN

          FOR segment_rec IN c_segments_context LOOP
            l_str := NULL;
            l_stmt := 'SELECT ' ||  segment_rec.application_column_name ||
                      ' FROM ' || P_table_name ||
                      ' WHERE ROWID = :1';

            EXECUTE IMMEDIATE l_stmt INTO l_str using p_row_id  ;

            IF l_Str IS NOT NULL THEN
              l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|'||l_Str||'||';
            ELSE
		   if p_ignore='N' then
             	 l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|  '||'||';
		   end if;
            END IF;

          END LOOP;

        END IF;

     END LOOP;

   ELSE
     l_dff_name := p_dff_name;

     IF l_context IS NULL THEN

        SELECT context_column_name
          INTO l_context_col
          FROM fnd_descriptive_flexs_vl
         WHERE descriptive_flexfield_name = l_dff_name
           AND application_table_name = p_table_name
           AND application_id = p_application_id;

        l_stmt_c := 'SELECT ' || l_context_col ||
                    ' FROM ' || P_table_name ||
                    ' WHERE ROWID = :1';

        EXECUTE IMMEDIATE l_stmt_c INTO l_context using p_row_id ;
     END IF;

     FOR segment_rec IN c_segments LOOP
        l_str := NULL;
        l_stmt := 'SELECT ' ||  segment_rec.application_column_name ||
                  ' FROM ' || P_table_name ||
                  ' WHERE ROWID = :1';

        EXECUTE IMMEDIATE l_stmt INTO l_str using p_row_id ;

        IF l_Str IS NOT NULL THEN
          l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|'||l_Str||'||';
        ELSE
		   if p_ignore='N' then
          	l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|  '||'||';
		   end if;
        END IF;

     END LOOP;

     IF l_context IS NOT NULL THEN

       FOR segment_rec IN c_segments_context LOOP
          l_str := NULL;
          l_stmt := 'SELECT ' ||  segment_rec.application_column_name ||
                    ' FROM ' || P_table_name ||
                    ' WHERE rowid = :1';

          EXECUTE IMMEDIATE l_stmt INTO l_str using p_row_id  ;

          IF l_Str IS NOT NULL THEN
             l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|'||l_Str||'||';
          ELSE
		   if p_ignore='N' then
             	l_concatenated_return := l_concatenated_return || segment_rec.end_user_column_name||'|  '||'||';
		   end if;
          END IF;

       END LOOP;

     END IF;

  END IF;

  l_concatenated_return := rtrim(l_concatenated_return,'||');
  RETURN (l_concatenated_return);
END  get_dff_kvp_app;
END FND_EID_FLEX_PKG;

/
