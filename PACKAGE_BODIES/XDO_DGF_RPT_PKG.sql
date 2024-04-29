--------------------------------------------------------
--  DDL for Package Body XDO_DGF_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_DGF_RPT_PKG" as
/* $Header: XDODGFRPB.pls 120.0 2008/01/19 00:13:41 bgkim noship $ */


 -- global private variables to store filtered lists
 g_report_list           RPT_TABLE_TYPE;
 g_template_list         TPLT_TABLE_TYPE;
 g_parameter_list        PARAM_TABLE_TYPE;
 g_rule_list             RULE_TABLE_TYPE;
 g_tpl_rule_id_list      TPL_RULE_ID_TABLE_TYPE;

 g_current_runtime_level CONSTANT  NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
 g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
 g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
 g_error_buffer                    VARCHAR2(100);

 -- procedure get_lang_territories
 -- Description: fills attributes template_lang_territory_codes and template_lang_territory_desc
 --              for each template in the table p_template_table
 PROCEDURE get_lang_territories(
             p_template_code        IN  VARCHAR2,
             p_template_application IN  VARCHAR2,
             p_lang_terr_codes      OUT NOCOPY VARCHAR2,
             p_lang_terr_desc       OUT NOCOPY VARCHAR2
             )
 IS
    CURSOR  c_lang_terr_codes is
    SELECT  l.language     language_code,
            l.territory    territory_code
      FROM  xdo_lobs l
     WHERE  l.lob_type = 'TEMPLATE'
       AND  l.lob_code = p_template_code
       AND  l.application_short_name = p_template_application;

    CURSOR  c_default_lang  is
    SELECT  tb.default_language default_language
      FROM  xdo_templates_b tb
     WHERE  tb.application_short_name = p_template_application
       AND  tb.template_code = p_template_code;
    -- local vars
    l_default_language       VARCHAR2(10)  := '00';
    l_language_code          VARCHAR2(10);
    l_language_desc          VARCHAR2(100);
    l_territory_desc         VARCHAR2(100);
    l_lang_terr_codes        VARCHAR2(1000) := '';
    l_lang_terr_desc         VARCHAR2(2000) := '';

 BEGIN
  FOR rec IN c_default_lang
  LOOP
    l_default_language := rec.default_language;
  END LOOP;
  --
  FOR rec IN c_lang_terr_codes
  LOOP
    IF rec.language_code = '00' THEN
       l_language_code := l_default_language;
    ELSE
       l_language_code := rec.language_code;
    END IF;
    l_lang_terr_codes := l_lang_terr_codes || l_language_code || ':' || rec.territory_code || '#';

    -- get language description
    SELECT  il.name
      INTO  l_language_desc
      FROM  fnd_iso_languages_vl il
     WHERE  il.iso_language_2 = l_language_code;
    -- get territory description
    IF rec.territory_code <> '00' THEN
       SELECT tr.territory_short_name
         INTO l_territory_desc
         FROM fnd_territories_vl tr
        WHERE tr.territory_code = upper(rec.territory_code);

       l_lang_terr_desc := l_lang_terr_desc || l_language_desc || ', ' || l_territory_desc || '#';
    ELSE
      l_lang_terr_desc := l_lang_terr_desc || l_language_desc || '#';
    END IF;
  END LOOP;
  p_lang_terr_codes := l_lang_terr_codes;
  p_lang_terr_desc  := l_lang_terr_desc;
 END;

 PROCEDURE get_context_reports(
                p_form_code         IN  VARCHAR2,
                p_block_code        IN  VARCHAR2,
                p_report_table      OUT NOCOPY RPT_TABLE_TYPE,
                p_template_table    OUT NOCOPY TPLT_TABLE_TYPE,
                p_tpl_rule_id_table OUT NOCOPY TPL_RULE_ID_TABLE_TYPE,
                p_rule_table        OUT NOCOPY RULE_TABLE_TYPE)
 is
  l_report_table      RPT_TABLE_TYPE;
  l_template_table    TPLT_TABLE_TYPE;
  l_tpl_rule_id_table TPL_RULE_ID_TABLE_TYPE;
  l_rule_table        RULE_TABLE_TYPE;
  i                   INTEGER := 0;  -- counter for reports
  j                   INTEGER := 0;  -- counter for templates
  k                   INTEGER := 0;  -- counter for tpl_rules
  l_last_report_code  VARCHAR2(30) := '$';
  l_resp_id           NUMBER;

 CURSOR c_contexts(p_resp_id NUMBER) IS
 SELECT rv.report_name report_name,
        rv.report_code report_code,
        rv.report_application report_application, -- added column 19.4.2006
        rc.report_context_id rpt_context_id,
        tc.template_context_id tpl_ctx_id,
        tc.pdf_allowed pdf_format_allowed,
        tc.rtf_allowed rtf_format_allowed,
        tc.htm_allowed htm_format_allowed,
        tc.xls_allowed xls_format_allowed,
        tc.txt_allowed txt_format_allowed,
        tv.template_name template_name,
        tv.template_code template_code,
        tv.template_application template_application -- added column 19.4.2006
 FROM   xdo_dgf_block_contexts bc,
        xdo_dgf_rpt_contexts rc,
        xdo_dgf_reports_v rv,
        xdo_dgf_tpl_contexts tc,
        xdo_dgf_templates_v tv,
        fnd_request_group_units    ru,
        fnd_request_groups         rg,
        fnd_responsibility_vl      fr,
        fnd_concurrent_programs_vl fc
 WHERE  bc.form_code =  p_form_code
   AND  bc.block_code = p_block_code
   AND  bc.block_context_id = rc.block_context_id
   AND  rv.report_code = rc.report_code
   AND  rv.report_application = rc.report_application
   AND  tc.report_context_id = rc.report_context_id
   AND  tv.template_code = tc.template_code
   AND  tv.template_application = tc.template_application
   AND  rv.report_code = fc.concurrent_program_name
   AND  ru.application_id = rg.application_id
   AND  ru.request_group_id = rg.request_group_id
   AND  rg.application_id  = fr.group_application_id
   AND  rg.request_group_id = fr.request_group_id
   AND  ru.request_unit_id  = fc.concurrent_program_id
   AND  ru.unit_application_id  = fc.application_id
   AND  ru.request_unit_type = 'P'
   AND  fr.responsibility_id = p_resp_id
 ORDER BY rv.report_code;


 CURSOR c_context_tpl_rules(p_tpl_context_id IN INTEGER) is
 SELECT tr.rule_catalog_id xrg_id,
        tr.format_filter_type format_filter_type
  FROM  xdo_dgf_tpl_rules tr
 WHERE  tr.template_context_id = p_tpl_context_id;

 CURSOR c_rule_catalog(p_xrg_id IN INTEGER) is
 SELECT cat.rule_short_name rule_short_name,
        cat.rule_type rule_type,
        cat.rule_variable rule_variable,
        cat.rule_operator rule_operator,
        cat.rule_values rule_values,
        cat.rule_values_datatype rule_values_datatype,
        cat.db_function db_function,
        cat.arg_number arg_number,
        cat.arg01 arg01,
        cat.arg02 arg02,
        cat.arg03 arg03,
        cat.arg04 arg04,
        cat.arg05 arg05,
        cat.arg06 arg06,
        cat.arg07 arg07,
        cat.arg08 arg08,
        cat.arg09 arg09,
        cat.arg10 arg10,
        cat.arg01_type arg01_type,
        cat.arg02_type arg02_type,
        cat.arg03_type arg03_type,
        cat.arg04_type arg04_type,
        cat.arg05_type arg05_type,
        cat.arg06_type arg06_type,
        cat.arg07_type arg07_type,
        cat.arg08_type arg08_type,
        cat.arg09_type arg09_type,
        cat.arg10_type arg10_type
 FROM   xdo_dgf_rule_catalog_vl cat
 WHERE  cat.rule_catalog_id = p_xrg_id;


 -- cursor variables
 l_tpl_rule_rec         c_context_tpl_rules%rowtype;
 l_rule_catalog_rec     c_rule_catalog%rowtype;

 -- local procedures
  PROCEDURE write_rule(p_rule_id IN INTEGER)
  IS
  BEGIN

     IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'xdo_dgf_rpt_pkg.get_context_reports.write_rule',
                     'write_rule START: p_rule_id = ' || p_rule_id);
     END IF;

     -- find out whether the corresponding catalog rule is already recorded
     IF NOT l_rule_table.exists(p_rule_id) THEN

       IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'xdo_dgf_rpt_pkg.get_context_reports.write_rule',
                         'go to fetch new RULE record; id = ' || p_rule_id);
     END IF;

       OPEN c_rule_catalog(p_rule_id);
       FETCH c_rule_catalog INTO l_rule_catalog_rec;
       l_rule_table(l_tpl_rule_rec.xrg_id).id                   := p_rule_id;
       l_rule_table(l_tpl_rule_rec.xrg_id).rule_short_name      := l_rule_catalog_rec.rule_short_name;
       l_rule_table(l_tpl_rule_rec.xrg_id).rule_type            := l_rule_catalog_rec.rule_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).rule_variable        := l_rule_catalog_rec.rule_variable;
       l_rule_table(l_tpl_rule_rec.xrg_id).rule_operator        := l_rule_catalog_rec.rule_operator;
       l_rule_table(l_tpl_rule_rec.xrg_id).rule_values          := l_rule_catalog_rec.rule_values;
       l_rule_table(l_tpl_rule_rec.xrg_id).rule_values_datatype := l_rule_catalog_rec.rule_values_datatype;
       -- items for rule_type = 'D' (DB function call)
       l_rule_table(l_tpl_rule_rec.xrg_id).db_function          := l_rule_catalog_rec.db_function;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg_number           := l_rule_catalog_rec.arg_number;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg01                := l_rule_catalog_rec.arg01;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg02                := l_rule_catalog_rec.arg02;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg03                := l_rule_catalog_rec.arg03;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg04                := l_rule_catalog_rec.arg04;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg05                := l_rule_catalog_rec.arg05;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg06                := l_rule_catalog_rec.arg06;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg07                := l_rule_catalog_rec.arg07;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg08                := l_rule_catalog_rec.arg08;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg09                := l_rule_catalog_rec.arg09;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg10                := l_rule_catalog_rec.arg10;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg01_type           := l_rule_catalog_rec.arg01_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg02_type           := l_rule_catalog_rec.arg02_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg03_type           := l_rule_catalog_rec.arg03_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg04_type           := l_rule_catalog_rec.arg04_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg05_type           := l_rule_catalog_rec.arg05_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg06_type           := l_rule_catalog_rec.arg06_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg07_type           := l_rule_catalog_rec.arg07_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg08_type           := l_rule_catalog_rec.arg08_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg09_type           := l_rule_catalog_rec.arg09_type;
       l_rule_table(l_tpl_rule_rec.xrg_id).arg10_type           := l_rule_catalog_rec.arg10_type;
       close c_rule_catalog;
     END IF;
  END;
 -- end of local procedures

 BEGIN
   IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'xdo_dgf_rpt_pkg.get_context_reports',
                         'START: pp_form_code = ' || p_form_code
                         || ' p_block_code = ' || p_block_code);
   END IF;

   fnd_profile.get('RESP_ID',l_resp_id);

   IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'xdo_dgf_rpt_pkg.get_context_reports',
                          'RESP_ID = ' || l_resp_id);
   END IF;

   FOR rec IN c_contexts(l_resp_id)
   LOOP
     IF l_last_report_code <> rec.report_code THEN
      i                                       := i + 1;
      l_report_table(i).report_name           := rec.report_name;
      l_report_table(i).report_code           := rec.report_application || ':' || rec.report_code; -- modified 27.4.2006
      l_report_table(i).report_application    := rec.report_application; -- added attribute 19.4.2006
      l_report_table(i).rpt_context_id        := rec.rpt_context_id;
      l_last_report_code                      := rec.report_code;
     END IF;
     j:= j + 1;
     l_template_table(j).template_name        := rec.template_name;
     l_template_table(j).template_code        := rec.template_application || ':' || rec.template_code; -- modified 27.4.2006
     l_template_table(j).template_application := rec.template_application; -- added column 19.4.2006
     -- get template languages and territories -- added 28.4.2006
     get_lang_territories(rec.template_code,
                          rec.template_application,
                          l_template_table(j).template_lang_territory_codes,
                          l_template_table(j).template_lang_territory_desc);

     IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'xdo_dgf_rpt_pkg.get_context_reports',
                          'l_template_table(' || j || ').template_lang_territory_codes=' || l_template_table(j).template_lang_territory_codes || ';' ||
                          'l_template_table(' || j || ').template_lang_territory_desc=' || l_template_table(j).template_lang_territory_desc);
     END IF;

     l_template_table(j).report_code          := rec.report_application || ':' || rec.report_code; -- modified 27.4.2006
     l_template_table(j).pdf_format_allowed   := rec.pdf_format_allowed;
     l_template_table(j).rtf_format_allowed   := rec.rtf_format_allowed;
     l_template_table(j).htm_format_allowed   := rec.htm_format_allowed;
     l_template_table(j).xls_format_allowed   := rec.xls_format_allowed;
     l_template_table(j).txt_format_allowed   := rec.txt_format_allowed;

     -- loop through XDO_DGF_TPL_RULES for a given template
     -- and write id's into l_tpl_rule_id_table
   OPEN c_context_tpl_rules(rec.tpl_ctx_id);
   FETCH c_context_tpl_rules INTO l_tpl_rule_rec;
   IF c_context_tpl_rules%found THEN
     k := k + 1;
     l_template_table(j).first_r_id            := k;
     l_tpl_rule_id_table(k).rule_id            := l_tpl_rule_rec.xrg_id;
     l_tpl_rule_id_table(k).template_code      := rec.template_code;
     l_tpl_rule_id_table(k).format_filter_type := l_tpl_rule_rec.format_filter_type;

     write_rule(l_tpl_rule_rec.xrg_id);
   END IF;
   LOOP
     FETCH c_context_tpl_rules INTO l_tpl_rule_rec;
     EXIT WHEN c_context_tpl_rules%notfound;
     k:= k + 1;
     l_tpl_rule_id_table(k).rule_id            := l_tpl_rule_rec.xrg_id;
     l_tpl_rule_id_table(k).template_code      := rec.template_code;
     l_tpl_rule_id_table(k).format_filter_type := l_tpl_rule_rec.format_filter_type;

     write_rule(l_tpl_rule_rec.xrg_id);
   END LOOP;
   IF l_template_table(j).first_r_id <> -1 THEN
      l_template_table(j).last_r_id := k;
   END IF;
   CLOSE c_context_tpl_rules;

  END LOOP;
  -- fill the output variables
  p_report_table      := l_report_table;
  p_template_table    := l_template_table;
  p_tpl_rule_id_table := l_tpl_rule_id_table;
  p_rule_table        := l_rule_table;
  --xdo_dgf_logger.log('get_context_reports','p_report_table.count = ' || p_report_table.count,'D');
 END;

 PROCEDURE get_report_parameters(
                p_rpt_contexts IN  RPT_TABLE_TYPE,
                p_parameters   OUT NOCOPY PARAM_TABLE_TYPE
                )
   IS
   l_sql                  VARCHAR2(32000);
   l_rpt_context_id_list  VARCHAR2(1000) := '';

   l_report_code          VARCHAR2(30);
   l_report_application   VARCHAR2(20);
   l_parameter_type       VARCHAR2(1);
   l_parameter_value      VARCHAR2(500);
   l_parameter_name       VARCHAR2(100); -- added 29.11.2006 - new column PARAMETER_NAME
   i                      INTEGER := 0;
   TYPE ref_cursor_type is REF CURSOR;
   c_params ref_cursor_type;
  BEGIN
     IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'xdo_dgf_rpt_pkg.get_report_parameters',
                          'START');
     END IF;

     FOR i IN 1..p_rpt_contexts.count LOOP
      l_rpt_context_id_list := l_rpt_context_id_list || ''''
                        || p_rpt_contexts(i).rpt_context_id || '''';
      IF i < p_rpt_contexts.count THEN
        l_rpt_context_id_list := l_rpt_context_id_list || ',';
      END IF;
    END LOOP;
    l_sql := 'SELECT c.report_code, c.report_application, p.parameter_type, p.parameter_value, p.parameter_name ' -- modified 29.11.2006 - new column PARAMETER_NAME
          || 'FROM  XDO_DGF_RPT_CONTEXT_PARAMETERS p, XDO_DGF_RPT_CONTEXTS c '
          || 'WHERE p.xrc_id = c.id '
          || '  AND c.id in ('
          ||  l_rpt_context_id_list
          || ')'
          || ' order by c.report_code, p.parameter_sequence';

    OPEN c_params FOR l_sql;
    LOOP
      FETCH c_params INTO l_report_code, l_report_application, l_parameter_type, l_parameter_value, l_parameter_name;
      EXIT WHEN c_params%notfound;
      i := i+1;
      p_parameters(i).report_code        := l_report_application || ':' || l_report_code; -- modified 27.4.2006
      p_parameters(i).report_application := l_report_application;
      p_parameters(i).parameter_type     := l_parameter_type;
      p_parameters(i).parameter_value    := l_parameter_value;
      p_parameters(i).parameter_name     := l_parameter_name; -- added 29.11.2006 - new column PARAMETER_NAME
    END LOOP;

     IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'xdo_dgf_rpt_pkg.get_report_parameters',
                          'END: p_parameters.count = ' || p_parameters.count);
     END IF;

 END;

/* get_context_lists*/
-- stores all lists to global private variables
-- returns only lists to be resolved on the application server layer
-- i.e. parameters list and rule list
 PROCEDURE prepare_context_lists(p_form_code  IN  VARCHAR2,
                                 p_block_code IN  VARCHAR2
                                 )
 IS
 BEGIN
  get_context_reports(
                p_form_code,
                p_block_code,
                g_report_list,
                g_template_list,
                g_tpl_rule_id_list,
                g_rule_list);

   -- xdo_dgf_logger.log('prepare_context_lists','reports count = ' || g_report_list.count,'D');
  -- 20.10.2006 - fix: clear g_parameter_list
  g_parameter_list.delete;
  IF g_report_list.count > 0 THEN
    get_report_parameters(
                   g_report_list,
                   g_parameter_list
                  );
  END IF;
 END;

 -- procedure apply_tpl_rules()
 -- applies evaluated rules in g_rule_list on g_template_list
 FUNCTION apply_tpl_rules(p_template_list    XDO_DGF_RPT_PKG.TPLT_TABLE_TYPE,
                          p_rule_list        RULE_TABLE_TYPE,
                          p_tpl_rule_id_list TPL_RULE_ID_TABLE_TYPE)
 RETURN XDO_DGF_RPT_PKG.TPLT_TABLE_TYPE
 IS
     l_template_list      XDO_DGF_RPT_PKG.TPLT_TABLE_TYPE;
     l_result_value       boolean;
     -- vars for filtering allowed output formats
     l_result_value_PDF   boolean;
     l_result_value_RTF   boolean;
     l_result_value_HTM   boolean;
     l_result_value_XLS   boolean;
     l_result_value_TXT   boolean;
     k                    integer := 1;
     j                    integer;
 BEGIN
   	  IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                              'xdo_dgf_rpt_pkg.apply_tpl_rules',
                              'START ...p_template_list.count = ' || p_template_list.count);
          END IF;

          FOR i IN 1..p_template_list.count
  	  LOOP
  	  	l_result_value     := true;
  	  	l_result_value_PDF := p_template_list(i).pdf_format_allowed = 'Y';
                l_result_value_RTF := p_template_list(i).rtf_format_allowed = 'Y';
                l_result_value_HTM := p_template_list(i).htm_format_allowed = 'Y';
                l_result_value_XLS := p_template_list(i).xls_format_allowed = 'Y';
                l_result_value_TXT := p_template_list(i).txt_format_allowed = 'Y';

                IF p_template_list(i).first_r_id <> -1 THEN
  	  	   j := p_template_list(i).first_r_id;

                   IF (g_level_statement >= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement,
                                      'xdo_dgf_rpt_pkg.apply_tpl_rules',
                                      'p_template_list(i).template_code = ' || p_template_list(i).template_code
  		                      || ' p_template_list(i).first_r_id = '|| p_template_list(i).first_r_id);
                   END IF;

                   LOOP
  		    	IF p_tpl_rule_id_list(j).format_filter_type IS NULL THEN
  		    	    l_result_value := l_result_value AND p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value;
  		    	ELSIF p_tpl_rule_id_list(j).format_filter_type = 'PDF' THEN
  		    	    l_result_value_PDF := l_result_value_PDF AND p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value;
  		    	ELSIF p_tpl_rule_id_list(j).format_filter_type = 'RTF' THEN
  		    	  l_result_value_RTF := l_result_value_RTF and p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value;
  		    	ELSIF p_tpl_rule_id_list(j).format_filter_type = 'HTM' THEN
  		    	  l_result_value_HTM := l_result_value_HTM and p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value;
  		    	ELSIF p_tpl_rule_id_list(j).format_filter_type = 'XLS' THEN
  		    	  l_result_value_XLS := l_result_value_XLS and p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value;
  		    	ELSIF p_tpl_rule_id_list(j).format_filter_type = 'TXT' THEN
  		    	  l_result_value_TXT := l_result_value_TXT and p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value;
  		    	END IF;
  		      -- logging
                       IF p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value THEN

                          IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                            'xdo_dgf_rpt_pkg.apply_tpl_rules',
                                            'j=' || j ||
  		                            ' p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value = TRUE');
                          END IF;

  		       ELSE

                          IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                            'xdo_dgf_rpt_pkg.apply_tpl_rules',
                                            'j=' || j ||
  		                            ' p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value = FALSE');
                          END IF;

                       END IF; -- IF p_rule_list(p_tpl_rule_id_list(j).rule_id).return_value THEN

  		       EXIT WHEN (j=p_template_list(i).last_r_id) OR (NOT l_result_value);
  			    j := j + 1;
  		    END LOOP;
  		  END IF;  -- IF p_template_list(i).first_r_id <> -1 THEN

                  IF l_result_value THEN
  		     l_template_list(k) := p_template_list(i);

                     IF l_result_value_PDF THEN
  		        l_template_list(k).pdf_format_allowed := 'Y';
  		     ELSE
  		    	l_template_list(k).pdf_format_allowed := 'N';
  		     END IF;

                     IF l_result_value_RTF THEN
  		        l_template_list(k).rtf_format_allowed := 'Y';
  		     ELSE
  		    	l_template_list(k).rtf_format_allowed := 'N';
  		     END IF;

  		     IF l_result_value_HTM THEN
  		        l_template_list(k).htm_format_allowed := 'Y';
  		     ELSE
  		    	l_template_list(k).htm_format_allowed := 'N';
  		     END IF;

  		     IF l_result_value_XLS THEN
  		        l_template_list(k).xls_format_allowed := 'Y';
  		     ELSE
  		    	l_template_list(k).xls_format_allowed := 'N';
  		     END IF;

                     IF l_result_value_TXT THEN
  		        l_template_list(k).txt_format_allowed := 'Y';
  		     ELSE
  		    	l_template_list(k).txt_format_allowed := 'N';
  		     END IF;
  		    k := k + 1;
  		  END IF; -- IF l_result_value THEN
  	  END LOOP;
  	  return l_template_list;
  	  --log('xxobl_report_pkg.apply_tpl_rules - END ...');
          IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'xdo_dgf_rpt_pkg.apply_tpl_rules',
                             'END');
          END IF;

 end;

 PROCEDURE filter_templates(p_resolved_rule_list IN RULE_TABLE_TYPE)
 IS
   l_report_list_final XDO_DGF_RPT_PKG.RPT_TABLE_TYPE;
 BEGIN
  g_template_list := apply_tpl_rules(g_template_list,
                                     xdo_dgf_rule_pkg.evaluate_rules(p_resolved_rule_list),
                                     g_tpl_rule_id_list);

  -- remove reports with no templates
  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'xdo_dgf_rpt_pkg.filter_templates',
                    'check for reports with no templates - start');
  END IF;

  IF g_template_list.count > 0 THEN

   DECLARE
   	j                   INTEGER := 1; -- pointer do tabulky sablon
   	k                   INTEGER := 1; -- pointer na volnou bunku v l_report_list_final
   	l_no_more_templates BOOLEAN := false;
   BEGIN
     IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.filter_templates',
                       'g_report_list.count = ' || g_report_list.count);
     END IF;

     l_report_list_final.delete;
     <<OUTER>>
     FOR i IN 1..g_report_list.count
     LOOP
       IF g_report_list(i).report_code = g_template_list(j).report_code THEN
          l_report_list_final(k) := g_report_list(i);
  	  k := k + 1;
  	  LOOP -- posun j na dalsi report_code
  	    j:= j+1;
  	    IF j > g_template_list.last THEN
  	  	   l_no_more_templates := TRUE;
   	  	   EXIT OUTER;
   	    END IF;
   	    EXIT WHEN g_template_list(j).report_code <> g_template_list(j-1).report_code;
   	  END LOOP;
       END IF;
     END LOOP OUTER;
   	 -- copy the result back to the global variable
     g_report_list := l_report_list_final;

     IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.filter_templates',
                       'l_report_list_final.count = '|| l_report_list_final.count);
     END IF;
   END;
  ELSE -- IF g_template_list.count > 0 THEN
   g_report_list.delete;
  END IF;
 END;

 procedure filter_templates_o(p_resolved_rule_list_o IN XDO_DGF_RULE_TABLE_TYPE)
 IS
  l_resolved_rule_list RULE_TABLE_TYPE;
  l_rule_id            INTEGER;
 BEGIN
   FOR i IN 1..p_resolved_rule_list_o.count
   LOOP
     l_rule_id                                             := p_resolved_rule_list_o(i).id;
     l_resolved_rule_list(l_rule_id).id                    := l_rule_id;
     l_resolved_rule_list(l_rule_id).rule_short_name       := p_resolved_rule_list_o(i).rule_short_name;
     l_resolved_rule_list(l_rule_id).rule_type             := p_resolved_rule_list_o(i).rule_type;
     l_resolved_rule_list(l_rule_id).rule_variable         := p_resolved_rule_list_o(i).rule_variable;
     l_resolved_rule_list(l_rule_id).rule_operator         := p_resolved_rule_list_o(i).rule_operator;
     l_resolved_rule_list(l_rule_id).rule_values           := p_resolved_rule_list_o(i).rule_values;
     l_resolved_rule_list(l_rule_id).rule_values_datatype  := p_resolved_rule_list_o(i).rule_values_datatype;
     l_resolved_rule_list(l_rule_id).db_function           := p_resolved_rule_list_o(i).db_function;
     l_resolved_rule_list(l_rule_id).arg_number            := p_resolved_rule_list_o(i).arg_number;
     l_resolved_rule_list(l_rule_id).arg01                 := p_resolved_rule_list_o(i).arg01;
     l_resolved_rule_list(l_rule_id).arg02                 := p_resolved_rule_list_o(i).arg02;
     l_resolved_rule_list(l_rule_id).arg03                 := p_resolved_rule_list_o(i).arg03;
     l_resolved_rule_list(l_rule_id).arg04                 := p_resolved_rule_list_o(i).arg04;
     l_resolved_rule_list(l_rule_id).arg05                 := p_resolved_rule_list_o(i).arg05;
     l_resolved_rule_list(l_rule_id).arg06                 := p_resolved_rule_list_o(i).arg06;
     l_resolved_rule_list(l_rule_id).arg07                 := p_resolved_rule_list_o(i).arg07;
     l_resolved_rule_list(l_rule_id).arg08                 := p_resolved_rule_list_o(i).arg08;
     l_resolved_rule_list(l_rule_id).arg09                 := p_resolved_rule_list_o(i).arg09;
     l_resolved_rule_list(l_rule_id).arg10                 := p_resolved_rule_list_o(i).arg10;
     l_resolved_rule_list(l_rule_id).arg01_type            := p_resolved_rule_list_o(i).arg01_type;
     l_resolved_rule_list(l_rule_id).arg02_type            := p_resolved_rule_list_o(i).arg02_type;
     l_resolved_rule_list(l_rule_id).arg03_type            := p_resolved_rule_list_o(i).arg03_type;
     l_resolved_rule_list(l_rule_id).arg04_type            := p_resolved_rule_list_o(i).arg04_type;
     l_resolved_rule_list(l_rule_id).arg05_type            := p_resolved_rule_list_o(i).arg05_type;
     l_resolved_rule_list(l_rule_id).arg06_type            := p_resolved_rule_list_o(i).arg06_type;
     l_resolved_rule_list(l_rule_id).arg07_type            := p_resolved_rule_list_o(i).arg07_type;
     l_resolved_rule_list(l_rule_id).arg08_type            := p_resolved_rule_list_o(i).arg08_type;
     l_resolved_rule_list(l_rule_id).arg09_type            := p_resolved_rule_list_o(i).arg09_type;
     l_resolved_rule_list(l_rule_id).arg10_type            := p_resolved_rule_list_o(i).arg10_type;

     IF p_resolved_rule_list_o(i).return_value = 'T' THEN
        l_resolved_rule_list(l_rule_id).return_value := TRUE;
     ELSE
        l_resolved_rule_list(l_rule_id).return_value := FALSE;
     END IF;
   END LOOP;
   filter_templates(l_resolved_rule_list);
 END;

 PROCEDURE store_report_list(p_report_list IN RPT_TABLE_TYPE)
 IS
 BEGIN
   g_report_list := p_report_list;
 END;

 PROCEDURE store_template_list(p_template_list IN TPLT_TABLE_TYPE)
 IS
 BEGIN
   g_template_list := p_template_list;
 END;

 PROCEDURE store_parameter_list(p_parameter_list IN PARAM_TABLE_TYPE)
 IS
 BEGIN

    IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.store_parameter_list',
                       'START: p_parameter_list.count = ' || p_parameter_list.count);
    END IF;
    g_parameter_list := p_parameter_list;
 END;

 FUNCTION get_report_list RETURN RPT_TABLE_TYPE
 IS
 BEGIN
    IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.get_report_list',
                       'START: g_report_list.count = ' || g_report_list.count);
    END IF;

    RETURN g_report_list;
 END;

 FUNCTION get_template_list RETURN TPLT_TABLE_TYPE
 IS
 BEGIN
    RETURN g_template_list;
 END;

 FUNCTION get_parameter_list RETURN PARAM_TABLE_TYPE
 IS
 BEGIN

    IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.get_parameter_list',
                       'START2: g_parameter_list.count = ' || g_parameter_list.count);
    END IF;

    RETURN g_parameter_list;
 END;

 FUNCTION get_rule_list RETURN RULE_TABLE_TYPE
 IS
 BEGIN

   IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.get_rule_list',
                       'START2: g_rule_list.count = ' || g_rule_list.count);
   END IF;

   RETURN g_rule_list;
 END;

 FUNCTION get_rule_list_o RETURN XDO_DGF_RULE_TABLE_TYPE
 IS
  l_rule_list_o    XDO_DGF_RULE_TABLE_TYPE := XDO_DGF_RULE_TABLE_TYPE();
  l_return_value   VARCHAR2(1);
  i                NUMBER;
  j                INTEGER := 0;
 BEGIN
  IF g_rule_list.count > 0 THEN
     i := g_rule_list.first;
    LOOP
    l_rule_list_o.extend();
    j := j + 1;
    IF g_rule_list(i).return_value THEN
      l_return_value := 'T';
    ELSE
      l_return_value := 'F';
    END IF;
    l_rule_list_o(j) := XDO_DGF_RULE_RECORD_TYPE(
      g_rule_list(i).id,
      g_rule_list(i).rule_short_name,
      g_rule_list(i).rule_type,
      g_rule_list(i).rule_variable,
      g_rule_list(i).rule_operator,
      g_rule_list(i).rule_values,
      g_rule_list(i).rule_values_datatype,
      g_rule_list(i).db_function,
      g_rule_list(i).arg_number,
      g_rule_list(i).arg01,
      g_rule_list(i).arg02,
      g_rule_list(i).arg03,
      g_rule_list(i).arg04,
      g_rule_list(i).arg05,
      g_rule_list(i).arg06,
      g_rule_list(i).arg07,
      g_rule_list(i).arg08,
      g_rule_list(i).arg09,
      g_rule_list(i).arg10,
      g_rule_list(i).arg01_type,
      g_rule_list(i).arg02_type,
      g_rule_list(i).arg03_type,
      g_rule_list(i).arg04_type,
      g_rule_list(i).arg05_type,
      g_rule_list(i).arg06_type,
      g_rule_list(i).arg07_type,
      g_rule_list(i).arg08_type,
      g_rule_list(i).arg09_type,
      g_rule_list(i).arg10_type,
      l_return_value
    );
    EXIT WHEN i = g_rule_list.last;
    i := g_rule_list.next(i);
   END LOOP;
  END IF;
  RETURN l_rule_list_o;
 END;

 FUNCTION get_parameter_list_o RETURN XDO_DGF_PARAM_TABLE_TYPE
 IS
   l_parameter_list_o XDO_DGF_PARAM_TABLE_TYPE := XDO_DGF_PARAM_TABLE_TYPE();
 BEGIN
   FOR i IN 1..g_parameter_list.count
   LOOP
     l_parameter_list_o.extend;
     l_parameter_list_o(i) := XDO_DGF_PARAM_RECORD_TYPE(
                   g_parameter_list(i).report_code,
                   g_parameter_list(i).report_application,
                   g_parameter_list(i).parameter_type ,
                   g_parameter_list(i).parameter_name, -- added 29.11.2006 - new attribute
                   g_parameter_list(i).parameter_value
     );
   END LOOP;
   RETURN l_parameter_list_o;
 END;

 FUNCTION get_template_list_o RETURN XDO_DGF_TPLT_TABLE_TYPE
 IS
   l_template_list_o XDO_DGF_TPLT_TABLE_TYPE := XDO_DGF_TPLT_TABLE_TYPE();
 BEGIN
   FOR i IN 1..g_template_list.count
   LOOP
     l_template_list_o.extend;
     l_template_list_o(i) := XDO_DGF_TPLT_RECORD_TYPE(
         g_template_list(i).template_name,
         g_template_list(i).template_code,
         g_template_list(i).template_application,
         g_template_list(i).template_lang_territory_codes,
         g_template_list(i).template_lang_territory_desc,
         g_template_list(i).report_code,
         g_template_list(i).pdf_format_allowed,
         g_template_list(i).rtf_format_allowed,
         g_template_list(i).htm_format_allowed,
         g_template_list(i).xls_format_allowed,
         g_template_list(i).txt_format_allowed,
         g_template_list(i).printer_allowed,
         g_template_list(i).first_r_id,
         g_template_list(i).last_r_id
     );
   END LOOP;
   RETURN l_template_list_o;
 END;

 FUNCTION get_report_list_o RETURN XDO_DGF_RPT_TABLE_TYPE
 IS
   l_report_list_o XDO_DGF_RPT_TABLE_TYPE := XDO_DGF_RPT_TABLE_TYPE();
 BEGIN

   IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                       'xdo_dgf_rpt_pkg.get_report_list_o',
                        'g_report_list.count = '|| g_report_list.count);
   END IF;

   FOR i in 1..g_report_list.count
   LOOP
     l_report_list_o.extend;
     l_report_list_o(i) := XDO_DGF_RPT_RECORD_TYPE(
              g_report_list(i).report_name,
              g_report_list(i).report_code,
              g_report_list(i).report_application,
              g_report_list(i).rpt_context_id
     );
   END LOOP;

   RETURN l_report_list_o;
 END;

END XDO_DGF_RPT_PKG;

/
