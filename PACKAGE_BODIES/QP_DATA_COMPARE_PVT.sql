--------------------------------------------------------
--  DDL for Package Body QP_DATA_COMPARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DATA_COMPARE_PVT" AS
/* $Header: QPXVDATB.pls 120.0 2005/06/02 00:04:14 appldev noship $ */

PROCEDURE List_Header_Data(p_html_list_line_id NUMBER,
                           p_forms_list_line_id NUMBER,
                           p_file_dir VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2) IS

l_filename             VARCHAR2(60);
l_file                 UTL_FILE.file_type;
l_html_list_header_id  NUMBER;
l_forms_list_header_id NUMBER;
l_header_string        VARCHAR2(2000);
l_header_string1       VARCHAR2(255);
l_header_string2       VARCHAR2(255);
l_header_string3       VARCHAR2(255);
l_header_string4       VARCHAR2(255);
l_data_rec             VARCHAR2(700);
l_header_rec           LIST_HEADER_REC_TYPE;
l_reset_header_rec     LIST_HEADER_REC_TYPE;

CURSOR csr_get_list_headers(p_list_header_id NUMBER) IS
SELECT a.list_header_id,
       a.request_id,
       a.list_type_code,
       a.start_date_active,
       a.end_date_active,
       a.automatic_flag,
       a.currency_code,
       a.rounding_factor,
       a.ship_method_code,
       a.freight_terms_code,
       a.terms_id,
       a.comments,
       a.discount_lines_flag,
       a.gsa_indicator,
       a.prorate_flag,
       a.source_system_code,
       a.ask_for_flag,
       a.active_flag,
       a.parent_list_header_id,
       a.start_date_active_first,
       a.end_date_active_first,
       a.active_date_first_type,
       a.start_date_active_second,
       a.end_date_active_second,
       a.active_date_second_type,
       a.limit_exists_flag,
       a.mobile_download,
       a.currency_header_id,
       a.pte_code,
       a.list_source_code,
       a.orig_system_header_ref,
       a.orig_org_id,
       a.global_flag,
       a.sold_to_org_id,
       a.shareable_flag,
       a.locked_from_list_header_id,
       b.language,
       b.source_lang,
       b.name,
       b.description,
       b.version_no
FROM   qp_list_headers_b a ,
       qp_list_headers_tl b
WHERE  a.list_header_id = b.list_header_id
AND    a.list_header_id = p_list_header_id;

CURSOR csr_get_list_header_id(p_list_line_id NUMBER) IS
SELECT list_header_id
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id;

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'w');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.put(l_file,'LIST_HEADERS');
 utl_file.new_line(l_file);

 OPEN csr_get_list_header_id(p_html_list_line_id);
 FETCH csr_get_list_header_id INTO l_html_list_header_id;
 CLOSE csr_get_list_header_id;

 OPEN csr_get_list_header_id(p_forms_list_line_id);
 FETCH csr_get_list_header_id INTO l_forms_list_header_id;
 CLOSE csr_get_list_header_id;

 OPEN csr_get_list_headers(l_forms_list_header_id);
 FETCH csr_get_list_headers  INTO l_header_rec;
 CLOSE csr_get_list_headers;

l_header_string1 := 'DataSource,List_Header_Id,Request_Id,List_Yype_Code,Start_Date_Active,End_Date_Active,Automatic_Flag, Currency_Code,Rounding_Factor,Ship_Method_Code,Freight_Terms_Code,Terms_Id,Comments,Discount_Lines_Flag, Gsa_Indicator,';
l_header_string2 := 'Prorate_Flag,Source_System_Code,Ask_For_Flag,Active_Flag,Parent_List_Header_Id,Start_Date_Active_First, End_Date_Active_First,Active_Date_First_Type,Start_Date_Active_Second,End_Date_Active_Second,';
l_header_string3 := 'Active_Date_Second_Type, Limit_Exists_Flag,Mobile_Download,Currency_Header_Id,Pte_Code,List_Source_Code,Orig_System_Header_Ref,Orig_Org_Id, Global_Flag,Sold_To_Org_Id,Shareable_Flag,';
l_header_string4 := 'Locked_From_List_Header_Id,Language,Source_Lang,Name,Description,Version_No';
l_header_string := l_header_string1 || l_header_string2 || l_header_string3 || l_header_string4;


 utl_file.put(l_file,l_header_string);
 utl_file.new_line(l_file);

 l_data_rec := 'FORMS' || ',';
 l_data_rec := l_data_rec || l_header_rec.list_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.request_id || ',';
 l_data_rec := l_data_rec || l_header_rec.list_type_code || ',';
 l_data_rec := l_data_rec || l_header_rec.start_date_active || ',';
 l_data_rec := l_data_rec || l_header_rec.end_date_active || ',';
 l_data_rec := l_data_rec || l_header_rec.automatic_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.currency_code || ',';
 l_data_rec := l_data_rec || l_header_rec.rounding_factor || ',';
 l_data_rec := l_data_rec || l_header_rec.ship_method_code || ',';
 l_data_rec := l_data_rec || l_header_rec.freight_terms_code || ',';
 l_data_rec := l_data_rec || l_header_rec.terms_id || ',';
 l_data_rec := l_data_rec || l_header_rec.comments || ',';
 l_data_rec := l_data_rec || l_header_rec.discount_lines_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.gsa_indicator || ',';
 l_data_rec := l_data_rec || l_header_rec.prorate_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.source_system_code || ',';
 l_data_rec := l_data_rec || l_header_rec.ask_for_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.active_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.parent_list_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.start_date_active_first || ',';
 l_data_rec := l_data_rec || l_header_rec.end_date_active_first || ',';
 l_data_rec := l_data_rec || l_header_rec.active_date_first_type || ',';
 l_data_rec := l_data_rec || l_header_rec.start_date_active_second || ',';
 l_data_rec := l_data_rec || l_header_rec.end_date_active_second || ',';
 l_data_rec := l_data_rec || l_header_rec.active_date_second_type || ',';
 l_data_rec := l_data_rec || l_header_rec.limit_exists_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.mobile_download || ',';
 l_data_rec := l_data_rec || l_header_rec.currency_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.pte_code || ',';
 l_data_rec := l_data_rec || l_header_rec.list_source_code || ',';
 l_data_rec := l_data_rec || l_header_rec.orig_system_header_ref || ',';
 l_data_rec := l_data_rec || l_header_rec.orig_org_id || ',';
 l_data_rec := l_data_rec || l_header_rec.global_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.sold_to_org_id || ',';
 l_data_rec := l_data_rec || l_header_rec.shareable_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.locked_from_list_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.language || ',';
 l_data_rec := l_data_rec || l_header_rec.source_lang || ',';
 l_data_rec := l_data_rec || l_header_rec.name || ',';
 l_data_rec := l_data_rec || l_header_rec.description || ',';
 l_data_rec := l_data_rec || l_header_rec.version_no;

 utl_file.put(l_file,l_data_rec);
 utl_file.new_line(l_file);

 l_header_rec := l_reset_header_rec;

 OPEN csr_get_list_headers(l_html_list_header_id);
 FETCH csr_get_list_headers  INTO l_header_rec;
 CLOSE csr_get_list_headers;

 l_data_rec := 'HTML' || ',';
 l_data_rec := l_data_rec || l_header_rec.list_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.request_id || ',';
 l_data_rec := l_data_rec || l_header_rec.list_type_code || ',';
 l_data_rec := l_data_rec || l_header_rec.start_date_active || ',';
 l_data_rec := l_data_rec || l_header_rec.end_date_active || ',';
 l_data_rec := l_data_rec || l_header_rec.automatic_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.currency_code || ',';
 l_data_rec := l_data_rec || l_header_rec.rounding_factor || ',';
 l_data_rec := l_data_rec || l_header_rec.ship_method_code || ',';
 l_data_rec := l_data_rec || l_header_rec.freight_terms_code || ',';
 l_data_rec := l_data_rec || l_header_rec.terms_id || ',';
 l_data_rec := l_data_rec || l_header_rec.comments || ',';
 l_data_rec := l_data_rec || l_header_rec.discount_lines_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.gsa_indicator || ',';
 l_data_rec := l_data_rec || l_header_rec.prorate_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.source_system_code || ',';
 l_data_rec := l_data_rec || l_header_rec.ask_for_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.active_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.parent_list_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.start_date_active_first || ',';
 l_data_rec := l_data_rec || l_header_rec.end_date_active_first || ',';
 l_data_rec := l_data_rec || l_header_rec.active_date_first_type || ',';
 l_data_rec := l_data_rec || l_header_rec.start_date_active_second || ',';
 l_data_rec := l_data_rec || l_header_rec.end_date_active_second || ',';
 l_data_rec := l_data_rec || l_header_rec.active_date_second_type || ',';
 l_data_rec := l_data_rec || l_header_rec.limit_exists_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.mobile_download || ',';
 l_data_rec := l_data_rec || l_header_rec.currency_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.pte_code || ',';
 l_data_rec := l_data_rec || l_header_rec.list_source_code || ',';
 l_data_rec := l_data_rec || l_header_rec.orig_system_header_ref || ',';
 l_data_rec := l_data_rec || l_header_rec.orig_org_id || ',';
 l_data_rec := l_data_rec || l_header_rec.global_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.sold_to_org_id || ',';
 l_data_rec := l_data_rec || l_header_rec.shareable_flag || ',';
 l_data_rec := l_data_rec || l_header_rec.locked_from_list_header_id || ',';
 l_data_rec := l_data_rec || l_header_rec.language || ',';
 l_data_rec := l_data_rec || l_header_rec.source_lang || ',';
 l_data_rec := l_data_rec || l_header_rec.name || ',';
 l_data_rec := l_data_rec || l_header_rec.description || ',';
 l_data_rec := l_data_rec || l_header_rec.version_no;

 utl_file.put(l_file,l_data_rec);

 utl_file.fclose(l_file);

 x_return_status := 'S';

END List_Header_Data;

PROCEDURE Qualifier_Data(p_html_list_line_id NUMBER,
                         p_forms_list_line_id NUMBER,
                         p_file_dir VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2) IS

l_filename             VARCHAR2(60);
l_file                 UTL_FILE.file_type;
l_html_list_header_id  NUMBER;
l_forms_list_header_id NUMBER;
l_qual_string          VARCHAR2(2000);
l_qual_string1         VARCHAR2(255);
l_qual_string2         VARCHAR2(255);
l_qual_string3         VARCHAR2(255);
l_data_rec             VARCHAR2(700);
l_qualifier_rec        QUALIFIER_REC_TYPE;
l_reset_qualifier_rec  QUALIFIER_REC_TYPE;
l_used_in_setup        VARCHAR2(1);

CURSOR csr_get_list_qualifiers(p_list_header_id NUMBER) IS
SELECT qualifier_id,
       qualifier_grouping_no,
       qualifier_context,
       qualifier_attribute,
       qualifier_attr_value,
       comparison_operator_code,
       excluder_flag,
       qualifier_rule_id,
       start_date_active,
       end_date_active,
       created_from_rule_id,
       qualifier_precedence,
       list_header_id,
       list_line_id,
       qualifier_datatype,
       qualifier_attr_value_to,
       active_flag,
       list_type_code,
       qual_attr_value_from_number,
       qual_attr_value_to_number,
       search_ind,
       qualifier_group_cnt,
       header_quals_exist_flag,
       distinct_row_count,
       others_group_cnt,
       orig_sys_qualifier_ref,
       orig_sys_header_ref,
       orig_sys_line_ref,
       segment_id
FROM   qp_qualifiers
WHERE  list_header_id = p_list_header_id
ORDER  BY qualifier_context,qualifier_attribute;

CURSOR csr_get_list_header_id(p_list_line_id NUMBER) IS
SELECT list_header_id
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id;


CURSOR csr_get_used_in_setup_flag(p_context VARCHAR2, p_attribute VARCHAR2, p_context_type VARCHAR2) IS
SELECT used_in_setup
FROM qp_pte_segments
WHERE segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=p_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type=p_context_type
   AND   b.prc_context_code=p_context);

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'QUALIFIERS');
 utl_file.new_line(l_file);

 OPEN csr_get_list_header_id(p_html_list_line_id);
 FETCH csr_get_list_header_id INTO l_html_list_header_id;
 CLOSE csr_get_list_header_id;

 OPEN csr_get_list_header_id(p_forms_list_line_id);
 FETCH csr_get_list_header_id INTO l_forms_list_header_id;
 CLOSE csr_get_list_header_id;

l_qual_string1 := 'DataSource, Qualifier_id, Qualifier_grouping_no, Qualifier_context, Qualifier_attribute, Qualifier_attr_value,Comparison_operator_code, Excluder_flag, Qualifier_rule_id, Start_date_active, End_date_active, Created_from_rule_id,';
l_qual_string2 := 'Qualifier_precedence,List_header_id, List_line_id, Qualifier_datatype, Qualifier_attr_value_to, Active_flag, List_type_code, Qual_attr_value_from_number, Qual_attr_value_to_number, Search_ind, Qualifier_group_cnt,';
l_qual_string3 := 'Header_quals_exist_flag, Distinct_row_count,Others_group_cnt, Orig_sys_qualifier_ref, Orig_sys_header_ref, Orig_sys_line_ref, Segment_id,Used_In_Setup';
l_qual_string := l_qual_string1 || l_qual_string2 || l_qual_string3;


 utl_file.put(l_file,l_qual_string);

 OPEN csr_get_list_qualifiers(l_forms_list_header_id);
 LOOP

  FETCH csr_get_list_qualifiers  INTO l_qualifier_rec;
  EXIT WHEN csr_get_list_qualifiers%NOTFOUND;

  OPEN csr_get_used_in_setup_flag(l_qualifier_rec.qualifier_context , l_qualifier_rec.qualifier_attribute,'QUALIFIER');
  FETCH csr_get_used_in_setup_flag INTO l_used_in_setup;
  CLOSE csr_get_used_in_setup_flag;

  utl_file.new_line(l_file);
  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_grouping_no||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_context||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_attribute||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_attr_value||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.comparison_operator_code||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.excluder_flag||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_rule_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.start_date_active||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.end_date_active||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.created_from_rule_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_precedence||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.list_header_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.list_line_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_datatype||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_attr_value_to||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.active_flag||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.list_type_code||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qual_attr_value_from_number||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qual_attr_value_to_number||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.search_ind||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_group_cnt||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.header_quals_exist_flag||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.distinct_row_count||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.others_group_cnt||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.orig_sys_qualifier_ref||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.orig_sys_header_ref||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.orig_sys_line_ref||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.segment_id || ',';
  l_data_rec := l_data_rec || l_used_in_setup ;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_list_qualifiers;

 l_qualifier_rec := l_reset_qualifier_rec;

 OPEN csr_get_list_qualifiers(l_html_list_header_id);
 LOOP

  FETCH csr_get_list_qualifiers  INTO l_qualifier_rec;
  EXIT WHEN csr_get_list_qualifiers%NOTFOUND;

  OPEN csr_get_used_in_setup_flag(l_qualifier_rec.qualifier_context , l_qualifier_rec.qualifier_attribute,'QUALIFIER');
  FETCH csr_get_used_in_setup_flag INTO l_used_in_setup;
  CLOSE csr_get_used_in_setup_flag;

  utl_file.new_line(l_file);
  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_grouping_no||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_context||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_attribute||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_attr_value||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.comparison_operator_code||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.excluder_flag||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_rule_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.start_date_active||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.end_date_active||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.created_from_rule_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_precedence||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.list_header_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.list_line_id||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_datatype||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_attr_value_to||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.active_flag||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.list_type_code||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qual_attr_value_from_number||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qual_attr_value_to_number||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.search_ind||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.qualifier_group_cnt||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.header_quals_exist_flag||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.distinct_row_count||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.others_group_cnt||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.orig_sys_qualifier_ref||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.orig_sys_header_ref||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.orig_sys_line_ref||',' ;
  l_data_rec := l_data_rec || l_qualifier_rec.segment_id || ',';
  l_data_rec := l_data_rec || l_used_in_setup ;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_list_qualifiers;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Qualifier_Data;

PROCEDURE List_Line_Data(p_html_list_line_id NUMBER,
                         p_forms_list_line_id NUMBER,
                         p_file_dir VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2) IS

l_filename             VARCHAR2(60);
l_file                 UTL_FILE.file_type;
l_html_list_header_id  NUMBER;
l_forms_list_header_id NUMBER;
l_list_line_string     VARCHAR2(2000);
l_list_line_string1    VARCHAR2(255);
l_list_line_string2    VARCHAR2(255);
l_list_line_string3    VARCHAR2(255);
l_list_line_string4    VARCHAR2(255);
l_list_line_string5    VARCHAR2(255);
l_data_rec             VARCHAR2(700);
l_list_line_rec        LIST_LINE_REC_TYPE;
l_reset_list_line_rec  LIST_LINE_REC_TYPE;

CURSOR csr_get_list_lines(p_list_line_id NUMBER) IS
SELECT list_line_id,
       list_header_id,
       list_line_type_code,
       start_date_active,
       end_date_active,
       automatic_flag,
       modifier_level_code,
       price_by_formula_id,
       primary_uom_flag,
       price_break_type_code,
       arithmetic_operator,
       operand,
       override_flag,
       accrual_qty,
       accrual_uom_code,
       estim_accrual_rate,
       generate_using_formula_id,
       list_line_no,
       estim_gl_value,
       benefit_price_list_line_id,
       expiration_period_start_date,
       number_expiration_periods,
       expiration_period_uom,
       expiration_date,
       accrual_flag,
       pricing_phase_id,
       pricing_group_sequence,
       incompatibility_grp_code,
       product_precedence,
       proration_type_code,
       accrual_conversion_rate,
       benefit_qty,
       benefit_uom_code,
       qualification_ind,
       limit_exists_flag,
       group_count,
       net_amount_flag,
       recurring_value,
       accum_context,
       accum_attribute,
       accum_attr_run_src_flag,
       break_uom_code,
       break_uom_context,
       break_uom_attribute,
       pattern_id,
       product_uom_code,
       pricing_attribute_count,
       hash_key,
       cache_key
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id
UNION
SELECT list_line_id,
       list_header_id,
       list_line_type_code,
       start_date_active,
       end_date_active,
       automatic_flag,
       modifier_level_code,
       price_by_formula_id,
       primary_uom_flag,
       price_break_type_code,
       arithmetic_operator,
       operand,
       override_flag,
       accrual_qty,
       accrual_uom_code,
       estim_accrual_rate,
       generate_using_formula_id,
       list_line_no,
       estim_gl_value,
       benefit_price_list_line_id,
       expiration_period_start_date,
       number_expiration_periods,
       expiration_period_uom,
       expiration_date,
       accrual_flag,
       pricing_phase_id,
       pricing_group_sequence,
       incompatibility_grp_code,
       product_precedence,
       proration_type_code,
       accrual_conversion_rate,
       benefit_qty,
       benefit_uom_code,
       qualification_ind,
       limit_exists_flag,
       group_count,
       net_amount_flag,
       recurring_value,
       accum_context,
       accum_attribute,
       accum_attr_run_src_flag,
       break_uom_code,
       break_uom_context,
       break_uom_attribute,
       pattern_id,
       product_uom_code,
       pricing_attribute_count,
       hash_key,
       cache_key
FROM   qp_list_lines
WHERE  list_line_id IN (SELECT to_rltd_modifier_id
                        FROM   qp_rltd_modifiers
                        WHERE  from_rltd_modifier_id = p_list_line_id);
BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'LIST_LINES');
 utl_file.new_line(l_file);

l_list_line_string1 := 'DataSource,List_Line_Id, List_Header_Id, List_Line_Type_Code, Start_Date_Active, End_Date_Active, Automatic_Flag, Modifier_Level_Code, Price_By_Formula_Id, Primary_Uom_Flag, Price_Break_Type_Code, Arithmetic_Operator, Operand,';
l_list_line_string2 := 'Override_Flag,Accrual_Qty, Accrual_Uom_Code, Estim_Accrual_Rate, Generate_Using_Formula_Id, List_Line_No, Estim_Gl_Value, Benefit_Price_List_Line_Id, Expiration_Period_Start_Date, Number_Expiration_Periods,';
l_list_line_string3 := 'Expiration_Period_Uom,Expiration_Date,Accrual_Flag, Pricing_Phase_Id, Pricing_Group_Sequence, Incompatibility_Grp_Code, Product_Precedence, Proration_Type_Code, Accrual_Conversion_Rate, Benefit_Qty, Benefit_Uom_Code,';
l_list_line_string4 := 'Qualification_Ind,Limit_Exists_Flag, Group_Count,Net_Amount_Flag, Recurring_Value, Accum_Context, Accum_Attribute, Accum_Attr_Run_Src_Flag, Break_Uom_Code, Break_Uom_Context, Break_Uom_Attribute, Pattern_Id,Product_Uom_Code,';
l_list_line_string5 := 'Pricing_Attribute_Count,Hash_Key, Cache_Key';
l_list_line_string := l_list_line_string1 || l_list_line_string2 || l_list_line_string3 || l_list_line_string4 || l_list_line_string5 ;

 utl_file.put(l_file,l_list_line_string);

 OPEN csr_get_list_lines(p_forms_list_line_id);
 LOOP

  FETCH csr_get_list_lines  INTO l_list_line_rec;
  EXIT WHEN csr_get_list_lines%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_list_line_rec.list_line_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.list_header_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.list_line_type_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.start_date_active|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.end_date_active|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.automatic_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.modifier_level_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.price_by_formula_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.primary_uom_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.price_break_type_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.arithmetic_operator|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.operand|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.override_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_qty|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.estim_accrual_rate|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.generate_using_formula_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.list_line_no|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.estim_gl_value|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.benefit_price_list_line_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.expiration_period_start_date|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.number_expiration_periods|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.expiration_period_uom|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.expiration_date|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pricing_group_sequence|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.incompatibility_grp_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.product_precedence|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.proration_type_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_conversion_rate|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.benefit_qty|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.benefit_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.qualification_ind|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.limit_exists_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.group_count|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.net_amount_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.recurring_value|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accum_context|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accum_attribute|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accum_attr_run_src_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.break_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.break_uom_context|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.break_uom_attribute|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pattern_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.product_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pricing_attribute_count|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.hash_key|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.cache_key;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_list_lines;

 l_list_line_rec := l_reset_list_line_rec;

 OPEN csr_get_list_lines(p_html_list_line_id);
 LOOP

  FETCH csr_get_list_lines  INTO l_list_line_rec;
  EXIT WHEN csr_get_list_lines%NOTFOUND;

  utl_file.new_line(l_file);
  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_list_line_rec.list_line_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.list_header_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.list_line_type_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.start_date_active|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.end_date_active|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.automatic_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.modifier_level_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.price_by_formula_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.primary_uom_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.price_break_type_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.arithmetic_operator|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.operand|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.override_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_qty|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.estim_accrual_rate|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.generate_using_formula_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.list_line_no|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.estim_gl_value|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.benefit_price_list_line_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.expiration_period_start_date|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.number_expiration_periods|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.expiration_period_uom|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.expiration_date|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pricing_group_sequence|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.incompatibility_grp_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.product_precedence|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.proration_type_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accrual_conversion_rate|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.benefit_qty|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.benefit_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.qualification_ind|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.limit_exists_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.group_count|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.net_amount_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.recurring_value|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accum_context|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accum_attribute|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.accum_attr_run_src_flag|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.break_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.break_uom_context|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.break_uom_attribute|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pattern_id|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.product_uom_code|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.pricing_attribute_count|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.hash_key|| ',';
  l_data_rec := l_data_rec || l_list_line_rec.cache_key;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_list_lines;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END List_Line_Data;

PROCEDURE Pricing_Attribute_Data(p_html_list_line_id NUMBER,
                         p_forms_list_line_id NUMBER,
                         p_file_dir VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                VARCHAR2(60);
l_file                    UTL_FILE.file_type;
l_pricing_attr_string     VARCHAR2(2000);
l_pricing_attr_string1    VARCHAR2(255);
l_pricing_attr_string2    VARCHAR2(255);
l_pricing_attr_string3    VARCHAR2(255);
l_pricing_attr_string4    VARCHAR2(255);
l_data_rec                VARCHAR2(700);
l_pricing_attribute_rec   PRICING_ATTRIBUTE_REC_TYPE;
l_reset_pricing_attr_rec  PRICING_ATTRIBUTE_REC_TYPE;
l_product_used_in_setup      VARCHAR2(1);
l_pricing_attr_used_in_setup VARCHAR2(1);

CURSOR csr_get_pricing_attributes(p_list_line_id NUMBER) IS
SELECT pricing_attribute_id,
       list_line_id,
       excluder_flag,
       accumulate_flag,
       product_attribute_context,
       product_attribute,
       product_attr_value,
       product_uom_code,
       pricing_attribute_context,
       pricing_attribute,
       pricing_attr_value_from,
       pricing_attr_value_to,
       attribute_grouping_no,
       product_attribute_datatype,
       pricing_attribute_datatype,
       comparison_operator_code,
       list_header_id,
       pricing_phase_id,
       qualification_ind,
       pricing_attr_value_from_number,
       pricing_attr_value_to_number,
       distinct_row_count,
       search_ind,
       pattern_value_from_positive,
       pattern_value_to_positive,
       pattern_value_from_negative,
       pattern_value_to_negative,
       product_segment_id,
       pricing_segment_id
FROM   qp_pricing_attributes
WHERE  list_line_id = p_list_line_id
UNION
SELECT pricing_attribute_id,
       list_line_id,
       excluder_flag,
       accumulate_flag,
       product_attribute_context,
       product_attribute,
       product_attr_value,
       product_uom_code,
       pricing_attribute_context,
       pricing_attribute,
       pricing_attr_value_from,
       pricing_attr_value_to,
       attribute_grouping_no,
       product_attribute_datatype,
       pricing_attribute_datatype,
       comparison_operator_code,
       list_header_id,
       pricing_phase_id,
       qualification_ind,
       pricing_attr_value_from_number,
       pricing_attr_value_to_number,
       distinct_row_count,
       search_ind,
       pattern_value_from_positive,
       pattern_value_to_positive,
       pattern_value_from_negative,
       pattern_value_to_negative,
       product_segment_id,
       pricing_segment_id
FROM   qp_pricing_attributes
WHERE  list_line_id IN (SELECT to_rltd_modifier_id
                        FROM   qp_rltd_modifiers
                        WHERE  from_rltd_modifier_id = p_list_line_id)
ORDER  BY product_attribute_context,product_attribute;

CURSOR csr_get_used_in_setup_flag(p_context VARCHAR2, p_attribute VARCHAR2, p_context_type VARCHAR2) IS
SELECT used_in_setup
FROM qp_pte_segments
WHERE segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=p_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type=p_context_type
   AND   b.prc_context_code=p_context);

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'PRICING_ATTRIBUTES');
 utl_file.new_line(l_file);

l_pricing_attr_string1 := 'DataSource, Pricing_Attribute_Id, List_Line_Id, Excluder_Flag, Accumulate_Flag, Product_Attribute_Context, Product_Attribute, Product_Attr_Value, Product_Uom_Code, Pricing_Attribute_Context, Pricing_Attribute,';
l_pricing_attr_string2 := 'Pricing_Attr_Value_From,Pricing_Attr_Value_To, Attribute_Grouping_No, Product_Attribute_Datatype, Pricing_Attribute_Datatype, Comparison_Operator_Code, List_Header_Id, Pricing_Phase_Id, Qualification_Ind,';
l_pricing_attr_string3 := 'Pricing_Attr_Value_From_Number, Pricing_Attr_Value_To_Number,Distinct_Row_Count, Search_Ind, Pattern_Value_From_Positive, Pattern_Value_To_Positive, Pattern_Value_From_Negative, Pattern_Value_To_Negative, Product_Segment_Id,';
l_pricing_attr_string4 := 'Product_Used_In_Setup, Pricing_Segment_Id,Pricing_Attr_Used_In_Setup';
l_pricing_attr_string := l_pricing_attr_string1 || l_pricing_attr_string2 || l_pricing_attr_string3 || l_pricing_attr_string4 ;


 utl_file.put(l_file,l_pricing_attr_string);

 OPEN csr_get_pricing_attributes(p_forms_list_line_id);
 LOOP

  FETCH csr_get_pricing_attributes  INTO l_pricing_attribute_rec;
  EXIT WHEN csr_get_pricing_attributes%NOTFOUND;

  OPEN csr_get_used_in_setup_flag(l_pricing_attribute_rec.product_attribute_context , l_pricing_attribute_rec.product_attribute,'PRODUCT');
  FETCH csr_get_used_in_setup_flag INTO l_product_used_in_setup;
  CLOSE csr_get_used_in_setup_flag;

  OPEN csr_get_used_in_setup_flag(l_pricing_attribute_rec.pricing_attribute_context , l_pricing_attribute_rec.pricing_attribute,'PRICING');
  FETCH csr_get_used_in_setup_flag INTO l_pricing_attr_used_in_setup;
  CLOSE csr_get_used_in_setup_flag;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.list_line_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.excluder_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.accumulate_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attribute_context|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attribute|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attr_value|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_uom_code|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute_context|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_from|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_to|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.attribute_grouping_no|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attribute_datatype|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute_datatype|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.comparison_operator_code|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.list_header_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.qualification_ind|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_from_number|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_to_number|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.distinct_row_count|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.search_ind|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_from_positive|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_to_positive|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_from_negative|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_to_negative|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_segment_id|| ',';
  l_data_rec := l_data_rec || l_product_used_in_setup || ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_segment_id || ',';
  l_data_rec := l_data_rec || l_pricing_attr_used_in_setup ;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_pricing_attributes;

 l_pricing_attribute_rec := l_reset_pricing_attr_rec;

 OPEN csr_get_pricing_attributes(p_html_list_line_id);
 LOOP

  FETCH csr_get_pricing_attributes  INTO l_pricing_attribute_rec;
  EXIT WHEN csr_get_pricing_attributes%NOTFOUND;

  utl_file.new_line(l_file);
  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.list_line_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.excluder_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.accumulate_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attribute_context|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attribute|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attr_value|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_uom_code|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute_context|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_from|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_to|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.attribute_grouping_no|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_attribute_datatype|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attribute_datatype|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.comparison_operator_code|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.list_header_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.qualification_ind|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_from_number|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_attr_value_to_number|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.distinct_row_count|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.search_ind|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_from_positive|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_to_positive|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_from_negative|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pattern_value_to_negative|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.product_segment_id|| ',';
  l_data_rec := l_data_rec || l_pricing_attribute_rec.pricing_segment_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_pricing_attributes;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Pricing_Attribute_Data;

PROCEDURE Rltd_Modifier_Data(p_html_list_line_id NUMBER,
                             p_forms_list_line_id NUMBER,
                             p_file_dir VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                 VARCHAR2(60);
l_file                     UTL_FILE.file_type;
l_rltd_modifier_string     VARCHAR2(2000);
l_data_rec                 VARCHAR2(700);
l_rltd_modifier_rec        RLTD_MODIFIER_REC_TYPE;
l_reset_rltd_modifier_rec  RLTD_MODIFIER_REC_TYPE;

CURSOR csr_get_rltd_modifiers(p_list_line_id NUMBER) IS
SELECT rltd_modifier_id,
       rltd_modifier_grp_no,
       from_rltd_modifier_id,
       to_rltd_modifier_id,
       rltd_modifier_grp_type
FROM   qp_rltd_modifiers
WHERE  from_rltd_modifier_id = p_list_line_id;

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'RLTD_MODIFIERS');
 utl_file.new_line(l_file);

l_rltd_modifier_string := 'DataSource, Rltd_Modifier_Id, Rltd_Modifier_Grp_No, From_Rltd_Modifier_Id, To_Rltd_Modifier_Id, Rltd_Modifier_Grp_Type';

 utl_file.put(l_file,l_rltd_modifier_string);

 OPEN csr_get_rltd_modifiers(p_forms_list_line_id);
 LOOP

  FETCH csr_get_rltd_modifiers  INTO l_rltd_modifier_rec;
  EXIT WHEN csr_get_rltd_modifiers%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_rltd_modifier_rec.rltd_modifier_id|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.rltd_modifier_grp_no|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.from_rltd_modifier_id|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.to_rltd_modifier_id|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.rltd_modifier_grp_type;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_rltd_modifiers;

 l_rltd_modifier_rec := l_reset_rltd_modifier_rec;

 OPEN csr_get_rltd_modifiers(p_html_list_line_id);
 LOOP

  FETCH csr_get_rltd_modifiers  INTO l_rltd_modifier_rec;
  EXIT WHEN csr_get_rltd_modifiers%NOTFOUND;

  utl_file.new_line(l_file);
  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_rltd_modifier_rec.rltd_modifier_id|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.rltd_modifier_grp_no|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.from_rltd_modifier_id|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.to_rltd_modifier_id|| ',';
  l_data_rec := l_data_rec || l_rltd_modifier_rec.rltd_modifier_grp_type;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_rltd_modifiers;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Rltd_Modifier_Data;

PROCEDURE List_Header_Phases_Data(p_html_list_line_id NUMBER,
                                  p_forms_list_line_id NUMBER,
                                  p_file_dir VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                      VARCHAR2(60);
l_file                          UTL_FILE.file_type;
l_html_list_header_id           NUMBER;
l_forms_list_header_id          NUMBER;
l_list_header_phases_string     VARCHAR2(2000);
l_data_rec                      VARCHAR2(700);
l_list_header_phases_rec        LIST_HEADER_PHASES_REC_TYPE;
l_reset_list_header_phases_rec  LIST_HEADER_PHASES_REC_TYPE;

CURSOR csr_get_list_header_phases(p_list_header_id NUMBER) IS
SELECT list_header_id,
       pricing_phase_id,
       qualifier_flag
FROM   qp_list_header_phases
WHERE  list_header_id = p_list_header_id;

CURSOR csr_get_list_header_id(p_list_line_id NUMBER) IS
SELECT list_header_id
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id;

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'LIST_HEADER_PHASES');
 utl_file.new_line(l_file);

 l_list_header_phases_string := 'DataSource, List_Header_Id, Pricing_Phase_Id, Qualifier_Flag';

 utl_file.put(l_file,l_list_header_phases_string);

 OPEN csr_get_list_header_id(p_html_list_line_id);
 FETCH csr_get_list_header_id INTO l_html_list_header_id;
 CLOSE csr_get_list_header_id;

 OPEN csr_get_list_header_id(p_forms_list_line_id);
 FETCH csr_get_list_header_id INTO l_forms_list_header_id;
 CLOSE csr_get_list_header_id;

 OPEN csr_get_list_header_phases(l_forms_list_header_id);
 LOOP

  FETCH csr_get_list_header_phases  INTO l_list_header_phases_rec;
  EXIT WHEN csr_get_list_header_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_list_header_phases_rec.List_Header_Id || ',' ;
  l_data_rec := l_data_rec || l_list_header_phases_rec.Pricing_Phase_Id || ',' ;
  l_data_rec := l_data_rec || l_list_header_phases_rec.Qualifier_Flag ;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_list_header_phases;

 l_list_header_phases_rec := l_reset_list_header_phases_rec;

 OPEN csr_get_list_header_phases(l_html_list_header_id);
 LOOP

  FETCH csr_get_list_header_phases  INTO l_list_header_phases_rec;
  EXIT WHEN csr_get_list_header_phases%NOTFOUND;

  utl_file.new_line(l_file);
  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_list_header_phases_rec.List_Header_Id || ',' ;
  l_data_rec := l_data_rec || l_list_header_phases_rec.Pricing_Phase_Id || ',' ;
  l_data_rec := l_data_rec || l_list_header_phases_rec.Qualifier_Flag  ;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_list_header_phases;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END List_Header_Phases_Data;

PROCEDURE Pricing_Phases_Data(p_data_creation_method VARCHAR2,
                              p_file_dir VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                  VARCHAR2(60);
l_file                      UTL_FILE.file_type;
l_pricing_phases_string     VARCHAR2(2000);
l_pricing_phases_string1    VARCHAR2(255);
l_pricing_phases_string2    VARCHAR2(255);
l_data_rec                  VARCHAR2(700);
l_pricing_phases_rec        PRICING_PHASES_REC_TYPE;
l_reset_pricing_phases_rec  PRICING_PHASES_REC_TYPE;

CURSOR csr_get_pricing_phases IS
SELECT modifier_level_code,
       phase_sequence,
       pricing_phase_id,
       incompat_resolve_code,
       name,
       seeded_flag,
       freeze_override_flag,
       user_freeze_override_flag,
       user_incompat_resolve_code,
       line_group_exists,
       oid_exists,
       rltd_exists,
       freight_exists,
       manual_modifier_flag
FROM   qp_pricing_phases
ORDER  BY phase_sequence;

BEGIN

 l_filename := 'QP_' || p_data_creation_method || '_OTHERS.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'w');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'PRICING_PHASES');
 utl_file.new_line(l_file);

l_pricing_phases_string1 := 'DataSource, Modifier_Level_Code, Phase_Sequence, Pricing_Phase_Id, Incompat_Resolve_Code, Name, Seeded_Flag, Freeze_Override_Flag, User_Freeze_Override_Flag, User_Incompat_Resolve_Code, Line_Group_Exists, Oid_Exists,';
l_pricing_phases_string2 := 'Rltd_Exists, Freight_Exists,Manual_Modifier_Flag';
l_pricing_phases_string := l_pricing_phases_string1 || l_pricing_phases_string2 ;


 utl_file.put(l_file,l_pricing_phases_string);

 OPEN csr_get_pricing_phases;
 LOOP

  FETCH csr_get_pricing_phases  INTO l_pricing_phases_rec;
  EXIT WHEN csr_get_pricing_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := p_data_creation_method || ',';

  l_data_rec := l_data_rec || l_pricing_phases_rec.modifier_level_code|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.phase_sequence|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.incompat_resolve_code|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.name|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.seeded_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.freeze_override_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.user_freeze_override_flag|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.user_incompat_resolve_code|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.line_group_exists|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.oid_exists|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.rltd_exists|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.freight_exists|| ',';
  l_data_rec := l_data_rec || l_pricing_phases_rec.manual_modifier_flag ;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_pricing_phases;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Pricing_Phases_Data;

PROCEDURE Adv_Mod_Products_Data(p_list_line_id NUMBER ,
                                p_data_creation_method VARCHAR2,
                                p_file_dir VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                    VARCHAR2(60);
l_file                        UTL_FILE.file_type;
l_adv_mod_products_string     VARCHAR2(2000);
l_data_rec                    VARCHAR2(700);
l_adv_mod_product_rec         ADV_MOD_PRODUCTS_REC_TYPE;
l_reset_adv_mod_products_rec  ADV_MOD_PRODUCTS_REC_TYPE;
l_pricing_phase_id            NUMBER;

CURSOR csr_get_adv_mod_products(p_pricing_phase_id NUMBER) IS
SELECT pricing_phase_id,
       product_attribute,
       product_attr_value
FROM   qp_adv_mod_products
WHERE  pricing_phase_id = p_pricing_phase_id;

CURSOR csr_get_pricing_phase_id(p_list_line_id NUMBER) IS
SELECT pricing_phase_id
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id;


BEGIN

 l_filename := 'QP_' || p_data_creation_method || '_OTHERS.dat';

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 OPEN csr_get_pricing_phase_id(p_list_line_id);
 FETCH csr_get_pricing_phase_id INTO l_pricing_phase_id;
 CLOSE csr_get_pricing_phase_id;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'ADV_MOD_PRODUCTS ' || l_pricing_phase_id);
 utl_file.new_line(l_file);

 l_adv_mod_products_string := 'DataSource, Pricing_Phase_Id, Product_Attribute, Product_Attr_Value';

 utl_file.put(l_file,l_adv_mod_products_string);


 OPEN csr_get_adv_mod_products(l_pricing_phase_id);
 LOOP

  FETCH csr_get_adv_mod_products  INTO l_adv_mod_product_rec;
  EXIT WHEN csr_get_adv_mod_products%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := p_data_creation_method || ',';

  l_data_rec := l_data_rec || l_adv_mod_product_rec.pricing_phase_id|| ',' ;
  l_data_rec := l_data_rec || l_adv_mod_product_rec.product_attribute|| ',' ;
  l_data_rec := l_data_rec || l_adv_mod_product_rec.product_attr_value;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_adv_mod_products;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Adv_Mod_Products_Data;

PROCEDURE Attribute_Groups_Data(p_html_list_line_id NUMBER,
                                p_forms_list_line_id NUMBER,
                                p_file_dir VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                   VARCHAR2(60);
l_file                       UTL_FILE.file_type;
l_html_list_header_id        NUMBER;
l_forms_list_header_id       NUMBER;
l_attribute_group_string     VARCHAR2(2000);
l_attribute_group_string1    VARCHAR2(255);
l_attribute_group_string2    VARCHAR2(255);
l_data_rec                   VARCHAR2(700);
l_attribute_groups_rec       ATTRIBUTE_GROUPS_REC_TYPE;
l_reset_attribute_groups_rec ATTRIBUTE_GROUPS_REC_TYPE;

CURSOR csr_get_attribute_groups(p_list_header_id NUMBER) IS
SELECT list_header_id,
       list_line_id,
       active_flag,
       list_type_code,
       start_date_active_q,
       end_date_active_q,
       pattern_id,
       currency_code ,
       ask_for_flag,
       limit_exists,
       source_system_code,
       effective_precedence,
       grouping_no,
       pricing_phase_id,
       modifier_level_code,
       hash_key,
       cache_key
FROM   qp_attribute_groups
WHERE  list_header_id = p_list_header_id;

CURSOR csr_get_list_header_id(p_list_line_id NUMBER) IS
SELECT list_header_id
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id;

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'ATTRIBUTE_GROUPS');
 utl_file.new_line(l_file);

l_attribute_group_string1 := 'DataSource, List_Header_Id, List_Line_Id, Active_Flag, List_Type_Code, Start_Date_Active_Q, End_Date_Active_Q, Pattern_Id, Currency_Code , Ask_For_Flag, Limit_Exists, Source_System_Code, Effective_Precedence, Grouping_No,';
l_attribute_group_string2 := 'Pricing_Phase_Id,Modifier_Level_Code, Hash_Key, Cache_Key';
l_attribute_group_string := l_attribute_group_string1 || l_attribute_group_string2;


 OPEN csr_get_list_header_id(p_html_list_line_id);
 FETCH csr_get_list_header_id INTO l_html_list_header_id;
 CLOSE csr_get_list_header_id;

 OPEN csr_get_list_header_id(p_forms_list_line_id);
 FETCH csr_get_list_header_id INTO l_forms_list_header_id;
 CLOSE csr_get_list_header_id;

 utl_file.put(l_file,l_attribute_group_string);

 OPEN csr_get_attribute_groups(l_forms_list_header_id);
 LOOP

  FETCH csr_get_attribute_groups  INTO l_attribute_groups_rec;
  EXIT WHEN csr_get_attribute_groups%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_attribute_groups_rec.list_header_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.list_line_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.active_flag|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.list_type_code|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.start_date_active_q|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.end_date_active_q|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.pattern_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.currency_code || ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.ask_for_flag|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.limit_exists|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.source_system_code|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.effective_precedence|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.grouping_no|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.modifier_level_code|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.hash_key|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.cache_key;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_attribute_groups;

 l_attribute_groups_rec := l_reset_attribute_groups_rec;

 OPEN csr_get_attribute_groups(l_html_list_header_id);
 LOOP

  FETCH csr_get_attribute_groups  INTO l_attribute_groups_rec;
  EXIT WHEN csr_get_attribute_groups%NOTFOUND;

  utl_file.new_line(l_file);
  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_attribute_groups_rec.list_header_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.list_line_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.active_flag|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.list_type_code|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.start_date_active_q|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.end_date_active_q|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.pattern_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.currency_code || ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.ask_for_flag|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.limit_exists|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.source_system_code|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.effective_precedence|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.grouping_no|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.pricing_phase_id|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.modifier_level_code|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.hash_key|| ',';
  l_data_rec := l_data_rec || l_attribute_groups_rec.cache_key;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_attribute_groups;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Attribute_Groups_Data;

PROCEDURE Patterns_Data(p_html_list_line_id NUMBER,
                        p_forms_list_line_id NUMBER,
                        p_pattern_type VARCHAR2,
                        p_file_dir VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2) IS

l_filename            VARCHAR2(60);
l_file                UTL_FILE.file_type;
l_patterns_string     VARCHAR2(2000);
l_data_rec            VARCHAR2(700);
l_patterns_rec        PATTERNS_REC_TYPE;
l_reset_patterns_rec  PATTERNS_REC_TYPE;
i                     PLS_INTEGER;
l_pattern_id          NUMBER;

CURSOR csr_get_patterns(p_pattern_id NUMBER) IS
SELECT pattern_id,
       segment_id,
       pattern_type,
       pattern_string
FROM   qp_patterns
WHERE  pattern_id = p_pattern_id
ORDER  BY pattern_id,segment_id;

CURSOR csr_get_prod_pattern_id(p_list_line_id NUMBER) IS
SELECT pattern_id
FROM   qp_list_lines
WHERE  list_line_id = p_list_line_id;

CURSOR csr_get_qual_pattern_id(p_list_line_id NUMBER) IS
SELECT pattern_id,list_line_id,list_header_id
FROM   qp_attribute_groups
WHERE  list_header_id IN (SELECT list_header_id FROM qp_list_lines WHERE list_line_id = p_list_line_id)
AND    list_line_id IN (p_list_line_id , -1);

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

IF (p_pattern_type = 'PRODUCT') THEN

 OPEN csr_get_prod_pattern_id(p_forms_list_line_id);
 FETCH csr_get_prod_pattern_id INTO l_pattern_id;
 CLOSE csr_get_prod_pattern_id;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'PRODUCT PATTERNS');
 utl_file.new_line(l_file);

 l_patterns_string := 'DataSource, List_Line_Id, Pattern_Id, Segment_Id, Pattern_Type, Pattern_String';

 utl_file.put(l_file,l_patterns_string);

 OPEN csr_get_patterns(l_pattern_id);
 LOOP

  FETCH csr_get_patterns  INTO l_patterns_rec;
  EXIT WHEN csr_get_patterns%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || p_forms_list_line_id || ',';
  l_data_rec := l_data_rec || l_patterns_rec.pattern_id|| ',';
  l_data_rec := l_data_rec || l_patterns_rec.segment_id|| ',';
  l_data_rec := l_data_rec || l_patterns_rec.pattern_type|| ',';
  l_data_rec := l_data_rec || l_patterns_rec.pattern_string;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_patterns;

 l_patterns_rec := l_reset_patterns_rec;

 OPEN csr_get_prod_pattern_id(p_html_list_line_id);
 FETCH csr_get_prod_pattern_id INTO l_pattern_id;
 CLOSE csr_get_prod_pattern_id;

 OPEN csr_get_patterns(l_pattern_id);
 LOOP

  FETCH csr_get_patterns  INTO l_patterns_rec;
  EXIT WHEN csr_get_patterns%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || p_html_list_line_id || ',';
  l_data_rec := l_data_rec || l_patterns_rec.pattern_id|| ',';
  l_data_rec := l_data_rec || l_patterns_rec.segment_id|| ',';
  l_data_rec := l_data_rec || l_patterns_rec.pattern_type|| ',';
  l_data_rec := l_data_rec || l_patterns_rec.pattern_string;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_patterns;

END IF;

IF (p_pattern_type = 'QUALIFIER') THEN

 FOR i IN csr_get_qual_pattern_id(p_forms_list_line_id)
 LOOP

  utl_file.new_line(l_file);
  utl_file.put(l_file,'QUALIFIER PATTERNS');
  utl_file.new_line(l_file);

  l_patterns_string := 'DataSource, List_Line_Id, Pattern_Id, Segment_Id, Pattern_Type, Pattern_String';

  utl_file.put(l_file,l_patterns_string);

  OPEN csr_get_patterns(i.pattern_id);
  LOOP

   FETCH csr_get_patterns  INTO l_patterns_rec;
   EXIT WHEN csr_get_patterns%NOTFOUND;

   utl_file.new_line(l_file);

   l_data_rec := 'FORMS' || ',';

   l_data_rec := l_data_rec || p_forms_list_line_id || ',';
   l_data_rec := l_data_rec || l_patterns_rec.pattern_id|| ',';
   l_data_rec := l_data_rec || l_patterns_rec.segment_id|| ',';
   l_data_rec := l_data_rec || l_patterns_rec.pattern_type|| ',';
   l_data_rec := l_data_rec || l_patterns_rec.pattern_string;

   utl_file.put(l_file,l_data_rec);

  END LOOP;
  CLOSE csr_get_patterns;

 END LOOP;

 l_patterns_rec := l_reset_patterns_rec;

 FOR i IN csr_get_qual_pattern_id(p_html_list_line_id)
 LOOP

  OPEN csr_get_patterns(i.pattern_id);
  LOOP

   FETCH csr_get_patterns  INTO l_patterns_rec;
   EXIT WHEN csr_get_patterns%NOTFOUND;

   utl_file.new_line(l_file);

   l_data_rec := 'HTML' || ',';

   l_data_rec := l_data_rec || p_html_list_line_id || ',';
   l_data_rec := l_data_rec || l_patterns_rec.pattern_id|| ',';
   l_data_rec := l_data_rec || l_patterns_rec.segment_id|| ',';
   l_data_rec := l_data_rec || l_patterns_rec.pattern_type|| ',';
   l_data_rec := l_data_rec || l_patterns_rec.pattern_string;

   utl_file.put(l_file,l_data_rec);

  END LOOP;
  CLOSE csr_get_patterns;

 END LOOP;

END IF;
utl_file.fclose(l_file);
x_return_status := 'S';

END Patterns_Data;

PROCEDURE Pattern_Phases_Data(p_html_list_line_id NUMBER ,
                              p_forms_list_line_id NUMBER,
                              p_pattern_type VARCHAR2,
                              p_file_dir VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                  VARCHAR2(60);
l_file                      UTL_FILE.file_type;
l_pattern_phases_string     VARCHAR2(2000);
l_data_rec                  VARCHAR2(700);
l_pattern_phases_rec        PATTERN_PHASES_REC_TYPE;
l_reset_pattern_phases_rec  PATTERN_PHASES_REC_TYPE;
l_pricing_phase_id          NUMBER;
l_pattern_id                NUMBER;
l_list_header_id            NUMBER;

CURSOR csr_get_pattern_phases(p_pricing_phase_id NUMBER,p_pattern_id NUMBER) IS
SELECT pattern_id,
       pricing_phase_id
FROM   qp_pattern_phases
WHERE  pricing_phase_id = p_pricing_phase_id
AND    pattern_id = p_pattern_id;

CURSOR csr_get_prod_pattern_phases(p_list_line_id NUMBER) IS
SELECT a.list_header_id,a.pattern_id,a.pricing_phase_id
FROM   qp_list_lines a , qp_pattern_phases b
WHERE  a.list_line_id = p_list_line_id
AND    a.pattern_id = b.pattern_id
AND    a.pricing_phase_id = b.pricing_phase_id;

CURSOR csr_get_hqual_pattern_phases(p_list_line_id NUMBER) IS
SELECT a.list_header_id,a.pattern_id,c.pricing_phase_id
FROM   qp_attribute_groups a ,
       (SELECT distinct list_header_id, pricing_phase_id
        FROM qp_list_lines WHERE list_line_id = p_list_line_id)  b ,
       qp_pattern_phases c
WHERE  a.list_header_id  = b.list_header_id
AND    a.pattern_id = c.pattern_id
AND    a.list_line_id = -1;

CURSOR csr_get_lqual_pattern_phases(p_list_line_id NUMBER) IS
SELECT a.list_header_id,a.pattern_id,a.pricing_phase_id
FROM   qp_attribute_groups a, qp_pattern_phases b
WHERE  a.list_line_id = p_list_line_id
AND    a.pattern_id = b.pattern_id
AND    a.pricing_phase_id = b.pricing_phase_id;

BEGIN

 l_filename := 'QP_HTML_' || p_html_list_line_id||'_FORMS_'||p_forms_list_line_id || '.dat' ;

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

IF (p_pattern_type = 'PRODUCT') THEN

 utl_file.new_line(l_file);
 utl_file.put(l_file,'PRODUCT PATTERN PHASES');
 utl_file.new_line(l_file);

 l_pattern_phases_string := 'DataSource, List_Header_Id, List_Line_Id, Pattern_Id, Pricing_Phase_Id';

 utl_file.put(l_file,l_pattern_phases_string);

 OPEN csr_get_prod_pattern_phases(p_forms_list_line_id);
 LOOP

  FETCH csr_get_prod_pattern_phases  INTO l_pattern_phases_rec;
  EXIT WHEN csr_get_prod_pattern_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_pattern_phases_rec.list_header_id || ',';
  l_data_rec := l_data_rec || p_forms_list_line_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pattern_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pricing_phase_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_prod_pattern_phases;

 l_pattern_phases_rec := l_reset_pattern_phases_rec;

 OPEN csr_get_prod_pattern_phases(p_html_list_line_id);
 LOOP

  FETCH csr_get_prod_pattern_phases  INTO l_pattern_phases_rec;
  EXIT WHEN csr_get_prod_pattern_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_pattern_phases_rec.list_header_id || ',';
  l_data_rec := l_data_rec || p_html_list_line_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pattern_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pricing_phase_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_prod_pattern_phases;

END IF;

IF (p_pattern_type = 'QUALIFIER') THEN

 utl_file.new_line(l_file);
 utl_file.put(l_file,'QUALIFIER HEADER PATTERN PHASES' );
 utl_file.new_line(l_file);

 l_pattern_phases_string := 'DataSource, List_Header_Id, List_Line_Id , Pattern_Id, Pricing_Phase_Id';

 utl_file.put(l_file,l_pattern_phases_string);

 OPEN csr_get_hqual_pattern_phases(p_forms_list_line_id);
 LOOP

  FETCH csr_get_hqual_pattern_phases  INTO l_pattern_phases_rec;
  EXIT WHEN csr_get_hqual_pattern_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_pattern_phases_rec.list_header_id || ',';
  l_data_rec := l_data_rec || p_forms_list_line_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pattern_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pricing_phase_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_hqual_pattern_phases;

 l_pattern_phases_rec := l_reset_pattern_phases_rec;

 OPEN csr_get_hqual_pattern_phases(p_html_list_line_id);
 LOOP

  FETCH csr_get_hqual_pattern_phases  INTO l_pattern_phases_rec;
  EXIT WHEN csr_get_hqual_pattern_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_pattern_phases_rec.list_header_id || ',';
  l_data_rec := l_data_rec || p_forms_list_line_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pattern_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pricing_phase_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_hqual_pattern_phases;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'QUALIFIER LINE PATTERN PHASES' );
 utl_file.new_line(l_file);

 l_pattern_phases_string := 'DataSource, List_Header_Id, List_Line_Id , Pattern_Id, Pricing_Phase_Id';

 utl_file.put(l_file,l_pattern_phases_string);

 OPEN csr_get_lqual_pattern_phases(p_forms_list_line_id);
 LOOP

  FETCH csr_get_lqual_pattern_phases  INTO l_pattern_phases_rec;
  EXIT WHEN csr_get_lqual_pattern_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'FORMS' || ',';

  l_data_rec := l_data_rec || l_pattern_phases_rec.list_header_id || ',';
  l_data_rec := l_data_rec || p_forms_list_line_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pattern_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pricing_phase_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_lqual_pattern_phases;

 l_pattern_phases_rec := l_reset_pattern_phases_rec;

 OPEN csr_get_lqual_pattern_phases(p_html_list_line_id);
 LOOP

  FETCH csr_get_lqual_pattern_phases  INTO l_pattern_phases_rec;
  EXIT WHEN csr_get_lqual_pattern_phases%NOTFOUND;

  utl_file.new_line(l_file);

  l_data_rec := 'HTML' || ',';

  l_data_rec := l_data_rec || l_pattern_phases_rec.list_header_id || ',';
  l_data_rec := l_data_rec || p_forms_list_line_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pattern_id || ',';
  l_data_rec := l_data_rec || l_pattern_phases_rec.pricing_phase_id;

  utl_file.put(l_file,l_data_rec);

 END LOOP;

 CLOSE csr_get_lqual_pattern_phases;

END IF;

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Pattern_Phases_Data;

PROCEDURE Profiles_Data(p_list_line_id NUMBER ,
                       p_data_creation_method VARCHAR2,
                       p_file_dir VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_filename                    VARCHAR2(60);
l_file                        UTL_FILE.file_type;
l_profiles_string             VARCHAR2(2000);
l_data_rec                    VARCHAR2(700);
l_profile_value               VARCHAR2(30);

CURSOR csr_get_profile_value(profile_name VARCHAR2) IS
SELECT fnd_profile.value(profile_name)
FROM   dual;

BEGIN

 l_filename := 'QP_' || p_data_creation_method || '_OTHERS.dat';

 BEGIN
  l_file := UTL_FILE.fopen(p_file_dir, l_filename, 'a');
 EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Log directory, '||p_file_dir||' is not accessible');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Please select a directory included in the utl_file_dir parameter for this database');
    RETURN;
 END;

 OPEN csr_get_profile_value('QP_HVOP_PRICING_SETUP');
 FETCH csr_get_profile_value INTO l_profile_value;
 CLOSE csr_get_profile_value;

 utl_file.new_line(l_file);
 utl_file.put(l_file,'PROFILE VALUES ' );
 utl_file.new_line(l_file);

 l_profiles_string := 'DataSource, List_Line_Id , Profile_Name , Profile_Value';

 utl_file.put(l_file,l_profiles_string);
 utl_file.new_line(l_file);

 l_data_rec := p_data_creation_method || ',';

 l_data_rec := l_data_rec || p_list_line_id || ',' ;
 l_data_rec := l_data_rec || 'QP_HVOP_PRICING_SETUP ' || ',' ;
 l_data_rec := l_data_rec || l_profile_value ;

 utl_file.put(l_file,l_data_rec);

 utl_file.fclose(l_file);
 x_return_status := 'S';

END Profiles_Data;

END QP_Data_Compare_PVT;

/
