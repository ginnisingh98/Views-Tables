--------------------------------------------------------
--  DDL for Package Body FND_DFLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DFLEX" AS
/* $Header: AFFFDDUB.pls 120.2.12010000.1 2008/07/25 14:13:42 appldev ship $ */


-- @param en_flag null or not null, null means ignore
CURSOR segment_c(context  IN context_r,
                 en_flag  IN VARCHAR2 DEFAULT NULL) IS
   SELECT /* $Header: AFFFDDUB.pls 120.2.12010000.1 2008/07/25 14:13:42 appldev ship $ */
          application_column_name,
     description,
     enabled_flag,
     required_flag,
     end_user_column_name,
     column_seq_num,
     display_flag,
     display_size,
     form_left_prompt,
     form_above_prompt,
     flex_value_set_id,
     default_type,
     default_value
     FROM fnd_descr_flex_col_usage_vl
     WHERE application_id = context.flexfield.application_id
     AND descriptive_flexfield_name = context.flexfield.flexfield_name
     AND descriptive_flex_context_code = context.context_code
     AND (en_flag IS NULL OR enabled_flag = 'Y')
     ORDER BY column_seq_num;

PROCEDURE dbms_debug(p_debug IN VARCHAR2)
  IS
     i INTEGER;
     m INTEGER;
     c INTEGER := 75;
BEGIN
   execute immediate ('begin dbms' ||
                      '_output' ||
                      '.enable(1000000); end;');
   m := Ceil(Length(p_debug)/c);
   FOR i IN 1..m LOOP
      execute immediate ('begin dbms' ||
                         '_output' ||
                         '.put_line(''' ||
                         REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''') ||
                         '''); end;');
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END dbms_debug;

FUNCTION to_boolean(value IN VARCHAR2) RETURN BOOLEAN
IS
  rv BOOLEAN;
BEGIN
   IF(value in ('Y', 'y')) THEN
      rv := TRUE;
    ELSE
      rv := FALSE;
   END IF;
   RETURN rv;
END;

/* returns information about the flexfield */
PROCEDURE get_flexfield(appl_short_name  IN  fnd_application.application_short_name%TYPE,
                        flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
                        flexfield        OUT nocopy dflex_r,
                        flexinfo         OUT nocopy dflex_dr)
  IS
     ffld dflex_r;
     dflex dflex_dr;
BEGIN
   SELECT /* $Header: AFFFDDUB.pls 120.2.12010000.1 2008/07/25 14:13:42 appldev ship $ */
          a.application_id, df.descriptive_flexfield_name
     INTO ffld
     FROM fnd_application_vl a, fnd_descriptive_flexs_vl df
     WHERE a.application_short_name = appl_short_name
     AND a.application_id = df.application_id
     AND df.descriptive_flexfield_name = flexfield_name;

   SELECT /* $Header: AFFFDDUB.pls 120.2.12010000.1 2008/07/25 14:13:42 appldev ship $ */
          df.title, df.application_table_name, a.application_short_name,
     df.description, df.concatenated_segment_delimiter,
     df.default_context_field_name, df.default_context_value,
     protected_flag,
     form_context_prompt, context_column_name
     INTO dflex
     FROM fnd_application_vl a, fnd_descriptive_flexs_vl df
     WHERE df.application_id = ffld.application_id
     AND df.descriptive_flexfield_name = ffld.flexfield_name
     AND a.application_id = df.table_application_id;
   flexfield := ffld;
   flexinfo := dflex;
END;


/* returns the contexts in a flexfield */
PROCEDURE get_contexts(flexfield         IN  dflex_r,
                       contexts          OUT nocopy contexts_dr)
  IS
     CURSOR context_c IS
        SELECT /* $Header: AFFFDDUB.pls 120.2.12010000.1 2008/07/25 14:13:42 appldev ship $ */
          descriptive_flex_context_code, descriptive_flex_context_name,
          description, global_flag, enabled_flag
          FROM fnd_descr_flex_contexts_vl
          WHERE application_id = flexfield.application_id
          AND descriptive_flexfield_name = flexfield.flexfield_name
          ORDER BY descriptive_flex_context_code;
     i BINARY_INTEGER := 0;
     rv contexts_dr;
BEGIN
   rv.global_context := 0;
   FOR context_rec IN context_c LOOP
      i := i + 1;
      rv.context_code(i) := context_rec.descriptive_flex_context_code;
      rv.context_name(i) := context_rec.descriptive_flex_context_name;
      rv.context_description(i) := context_rec.description;
      rv.is_global(i) := to_boolean(context_rec.global_flag);
      rv.is_enabled(i) := to_boolean(context_rec.enabled_flag);
      IF(rv.is_global(i) AND rv.is_enabled(i)) THEN
         rv.global_context := i;
      END IF;
   END LOOP;
   rv.ncontexts := i;
   contexts := rv;
END;


/* since we don't have arrays of structures, provide a way to make a context structure */
FUNCTION make_context(flexfield          IN  dflex_r,
                      context_code       IN  fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE)
  RETURN context_r
  IS
     rv context_r;
BEGIN
   rv.flexfield := flexfield;
   rv.context_code := context_code;
   RETURN rv;
END;



/* returns information about all the segments in a particular context */
PROCEDURE get_segments(context           IN  context_r,
                       segments          OUT nocopy segments_dr,
                       enabled_only      IN BOOLEAN)
  IS
     i BINARY_INTEGER := 0;
     rv segments_dr;
     en_flag VARCHAR2(1);
BEGIN
   IF(enabled_only) THEN
      en_flag := 'Y';
   END IF;
   FOR segment_rec IN segment_c(context, en_flag) LOOP
      i := i + 1;
      rv.application_column_name(i) := segment_rec.application_column_name;
      rv.segment_name(i) := segment_rec.end_user_column_name;
      rv.sequence(i) := segment_rec.column_seq_num;
      rv.is_displayed(i) := to_boolean(segment_rec.display_flag);
      rv.display_size(i) := segment_rec.display_size;
      rv.row_prompt(i) := segment_rec.form_left_prompt;
      rv.column_prompt(i) := segment_rec.form_above_prompt;
      rv.is_required(i) := to_boolean(segment_rec.required_flag);
      rv.is_enabled(i) := to_boolean(segment_rec.enabled_flag);
      rv.description(i) := segment_rec.description;
      rv.value_set(i) := segment_rec.flex_value_set_id;
      rv.default_type(i) := segment_rec.default_type;
      rv.default_value(i) := segment_rec.default_value;
   END LOOP;
   rv.nsegments := i;
   segments := rv;
END;


PROCEDURE get_segments(context           IN  context_r,
                       segments          OUT nocopy segments_dr)
IS
BEGIN
  get_segments(context => context,
               segments => segments,
               enabled_only => FALSE);
END;


PROCEDURE test IS
   flexfield dflex_r;
   flexinfo  dflex_dr;
   contexts  contexts_dr;
   i BINARY_INTEGER;
   segments  segments_dr;
BEGIN
   get_flexfield('FND', 'FND_FLEX_TEST', flexfield, flexinfo);

   dbms_debug('=== FLEXFIELD INFO ===');
   dbms_debug('title=' || flexinfo.title);
   dbms_debug('table=' || flexinfo.table_name);
   dbms_debug('descr=' || flexinfo.description);
   dbms_debug('delim=' || flexinfo.segment_delimeter);
   dbms_debug('def_ctx_fld' || flexinfo.default_context_field);
   dbms_debug('def_ctx_val' || flexinfo.default_context_value);
   dbms_debug('protect' || flexinfo.protected_flag);
   dbms_debug('ctx_prmpt' || flexinfo.form_context_prompt);
   dbms_debug('ctx_col_name' || flexinfo.context_column_name);


   dbms_debug('=== ENABLED CONTEXT INFO ===');
   get_contexts(flexfield, contexts);
   FOR i IN 1 .. contexts.ncontexts LOOP
      IF(contexts.is_enabled(i)) THEN
         dbms_debug(contexts.context_code(i) || ' - ' ||
                    contexts.context_description(i));
      END IF;
   END LOOP;

   dbms_debug('=== SEGMENT INFO (for global context) ===');
   get_segments(make_context(flexfield,
                             contexts.context_code(contexts.global_context)),
                segments,
                TRUE);
   FOR i IN 1 .. segments.nsegments LOOP
      dbms_debug(segments.segment_name(i) || ' - ' ||
                 segments.application_column_name(i) || ' - ' ||
                 segments.description(i));
   END LOOP;

END;

END fnd_dflex;                  /* end package */

/
