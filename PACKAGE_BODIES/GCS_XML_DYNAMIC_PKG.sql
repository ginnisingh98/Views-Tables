--------------------------------------------------------
--  DDL for Package Body GCS_XML_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_XML_DYNAMIC_PKG" AS
  /* $Header: gcsxmldynb.pls 120.24 2006/08/17 16:44:34 hakumar noship $ */
  --Global Variables
  g_api VARCHAR2(50) := 'gcs.plsql.GCS_XML_DYNAMIC_PKG';
  g_nl  VARCHAR2(1) := '''';
  PROCEDURE add_order_clause_to_list(p_dimension_required IN VARCHAR2,
                                     p_display_col_name   IN VARCHAR2,
                                     p_table_alias        IN VARCHAR2,
                                     p_rownum             IN OUT NOCOPY NUMBER,
                                     p_xml_file_type      IN VARCHAR2) IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
      IF (p_xml_file_type = 'RULES') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '1.' ||
                               p_display_col_name || ',    ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      ELSE
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || ',    ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      END IF;
    END IF;
  END add_order_clause_to_list;
  PROCEDURE build_order_clause_list(p_rownum        IN OUT NOCOPY NUMBER,
                                    p_xml_file_type IN VARCHAR2) IS
    l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN
    -- Santosh 5234796
    IF (p_xml_file_type = 'DSLOAD') THEN
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('LINE_ITEM_ID'),
                               'LINE_ITEM_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                               'CHANNEL_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                               'CUSTOMER_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                               'FINANCIAL_ELEM_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                               'NATURAL_ACCOUNT_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                               'PRODUCT_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                               'PROJECT_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                               'TASK_DISPLAY_CODE',
                               'gbit',
                               p_rownum,
                               p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                 'USER_DIM10_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                 'USER_DIM1_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                 'USER_DIM2_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                 'USER_DIM3_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                 'USER_DIM4_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                 'USER_DIM5_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                 'USER_DIM6_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                 'USER_DIM7_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                 'USER_DIM8_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                 'USER_DIM9_DISPLAY_CODE',
                                 'gbit',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
    ELSIF (p_xml_file_type = 'DS') THEN
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('LINE_ITEM_ID'),
                               'line_item_name',
                               'flib',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                               'channel_name',
                               'fchb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                               'customer_name',
                               'fcb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                               'financial_elem_name',
                               'ffeb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                               'natural_account_name',
                               'fnab',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                               'product_name',
                               'fpb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                               'project_name',
                               'fpjb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                               'task_name',
                               'ftb',
                               p_rownum,
                               p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                 'user_dim10_name',
                                 'fud10',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                 'user_dim1_name',
                                 'fud1',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                 'user_dim2_name',
                                 'fud2',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                 'user_dim3_name',
                                 'fud3',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                 'user_dim4_name',
                                 'fud4',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                 'user_dim5_name',
                                 'fud5',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                 'user_dim6_name',
                                 'fud6',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                 'user_dim7_name',
                                 'fud7',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                 'user_dim8_name',
                                 'fud8',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                 'user_dim9_name',
                                 'fud9',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
    ELSIF (p_xml_file_type = 'OGL') THEN
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                               'channel_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                               'customer_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                               'financial_elem_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                               'natural_account_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                               'product_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                               'project_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                               'task_id',
                               'fb',
                               p_rownum,
                               p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                 'user_dim10_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                 'user_dim1_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                 'user_dim2_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                 'user_dim3_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                 'user_dim4_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                 'user_dim5_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                 'user_dim6_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                 'user_dim7_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                 'user_dim8_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                 'user_dim9_id',
                                 'fb',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
    ELSE
      -- FOR 'NOT_RULES'
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                               'channel_name',
                               'fchb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                               'customer_name',
                               'fcb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                               'financial_elem_name',
                               'ffeb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                               'natural_account_name',
                               'fnab',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                               'product_name',
                               'fpb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                               'project_name',
                               'fpjb',
                               p_rownum,
                               p_xml_file_type);
      add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                               'task_name',
                               'ftb',
                               p_rownum,
                               p_xml_file_type);
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM10_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                                 'user_dim10_name',
                                 'fud10',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM1_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                                 'user_dim1_name',
                                 'fud1',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM2_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                                 'user_dim2_name',
                                 'fud2',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM3_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                                 'user_dim3_name',
                                 'fud3',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM4_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                                 'user_dim4_name',
                                 'fud4',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM5_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                                 'user_dim5_name',
                                 'fud5',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM6_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                                 'user_dim6_name',
                                 'fud6',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM7_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                                 'user_dim7_name',
                                 'fud7',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM8_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                                 'user_dim8_name',
                                 'fud8',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM9_ID') = 'Y') THEN
        add_order_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                                 'user_dim9_name',
                                 'fud9',
                                 p_rownum,
                                 p_xml_file_type);
      END IF;
    END IF;
  END build_order_clause_list;
  PROCEDURE add_select_clause_dsload_list(p_dimension_required IN VARCHAR2,
                                          p_display_col_name   IN VARCHAR2,
                                          p_display_col_alias  IN VARCHAR2,
                                          p_table_alias        IN VARCHAR2,
                                          p_rownum             IN OUT NOCOPY NUMBER,
                                          p_xml_file_type      IN VARCHAR2) IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
      ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                             p_display_col_name || ' ' ||
                             p_display_col_alias || ' , ''|| g_nl||',
                             p_rownum);
      p_rownum := p_rownum + 1;
    END IF;
  END add_select_clause_dsload_list;
  PROCEDURE add_select_clause_to_list(p_dimension_required IN VARCHAR2,
                                      p_display_col_name   IN VARCHAR2,
                                      p_table_alias        IN VARCHAR2,
                                      p_rownum             IN OUT NOCOPY NUMBER,
                                      p_xml_file_type      IN VARCHAR2) IS
    DecodeStatement varchar2(1000);
  BEGIN
    IF (p_dimension_required = 'Y') THEN
      IF (p_xml_file_type = 'ENTRY') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || ' , ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      ELSIF (p_xml_file_type = 'DSTB') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || ' , ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        -- Santosh 5234796
      ELSIF (p_xml_file_type = 'DSLOAD') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || ' , ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      ELSIF (p_xml_file_type = 'RULES') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || ' , ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		' || p_table_alias || '1.' ||
                               p_display_col_name || ', ''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      ELSIF (p_xml_file_type = 'DSTBID') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || ',		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      ELSIF (p_xml_file_type = 'CCIDHASH') THEN
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name || '||' || ' ''''.'''' ' ||
                               '||		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      ELSIF (p_xml_file_type = 'ENTRY_XML' or p_xml_file_type = 'DSTB_XML') THEN
        ad_ddl.build_statement('	''		<element name="NAME" value="' ||
                               p_display_col_name || '"/>		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      --fix 5351083
      /*ELSIF (p_xml_file_type = 'DSTB_XML_ID') THEN
        ad_ddl.build_statement('	''		<element name="' ||
                               replace(p_display_col_name, '_name', '_id') ||
                               '"  value="' ||
                               replace(p_display_col_name, '_name', '_id') ||
                               '" />		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;*/
      ELSIF (p_xml_file_type = 'VSMPID') THEN
        ad_ddl.build_statement('	''		<group name="header" source="' ||
                               p_display_col_name || '">		''||g_nl|| ',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		<element name="dimensionname" value="dimension_name"/>		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		<element name="valuesetname" value="value_set_name"/>		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		<group name="details" source="' ||
                               p_display_col_name || '">		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		<element name="name" value="dim_member_name"/>		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		<element name="description" value="description" />		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		 </group>		''|| g_nl||', p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''		 </group>       ''||g_nl||', p_rownum);
        p_rownum := p_rownum + 1;
        -- BUG 5147886
      ELSIF (p_xml_file_type = 'NONPOSTED_SELECT' OR
            p_xml_file_type = 'NONPOSTED_GROUP') THEN
        DecodeStatement := 'decode (EXTENDED_ACCOUNT_TYPE,' ||
                           '''''REVENUE'''',455,' ||
                           '''''EXPENSE'''',457,100) ';

        IF (p_display_col_name = 'financial_elem_name') THEN
          IF (p_xml_file_type = 'NONPOSTED_GROUP') THEN
            ad_ddl.build_statement('	''		' || DecodeStatement || ',' ||
                                   ' ''||g_nl||',
                                   p_rownum);
            p_rownum := p_rownum + 1;
          ELSE
            ad_ddl.build_statement('	''		' || DecodeStatement ||
                                   'financial_elem_id,' || ' ''||g_nl||',
                                   p_rownum);
            p_rownum := p_rownum + 1;
          end IF;
        ELSE
          ad_ddl.build_statement('	''		' || 'fiocm.' ||
                                 replace(p_display_col_name,
                                         '_name',
                                         '_id') || ' , ''|| g_nl||',
                                 p_rownum);
          p_rownum := p_rownum + 1;
        END IF;
      ELSE
        ad_ddl.build_statement('	''		' || p_table_alias || '.' ||
                               p_display_col_name ||
                               ' dimension_data,		''|| g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      END IF;
    END IF;
  END add_select_clause_to_list;
  PROCEDURE add_clause_to_list(p_dimension_required IN VARCHAR2,
                               p_column_id          IN VARCHAR2,
                               p_table_alias        IN VARCHAR2,
                               p_rownum             IN OUT NOCOPY NUMBER,
                               p_xml_file_type      IN VARCHAR2) IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
      IF (p_xml_file_type = 'ENTRY') THEN
        ad_ddl.build_statement('	''	AND	' || p_table_alias || '.' ||
                               p_column_id || ' = gel.' || p_column_id ||
                               '		'' || g_nl|| ',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''	AND	' || p_table_alias ||
                               '.language  = :pLanguageCode' ||
                               ''' || g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        -- Santosh 5234796
        /*ELSIF (p_xml_file_type = 'DSLOAD') THEN
           ad_ddl.build_statement('  ''  AND ' || p_table_alias || '.' || p_column_id || 'display_code = gbit.' || p_column_id  || 'display_code   '' || g_nl||', p_rownum); p_rownum := p_rownum+1;
           ad_ddl.build_statement('  ''  AND ' || p_table_alias || '.value_set_id  = :p'||p_table_alias || 'ValueSetId'' || g_nl||', p_rownum); p_rownum := p_rownum+1;
           ad_ddl.build_statement('  ''  AND ' || p_table_alias || 't.' || p_column_id || 'id = '  || p_table_alias || '.'  || p_column_id  || 'id   '' || g_nl||', p_rownum); p_rownum := p_rownum+1;
           ad_ddl.build_statement('  ''  AND ' || p_table_alias || 't.value_set_id  = '||p_table_alias || '.value_set_id   '' || g_nl||', p_rownum); p_rownum := p_rownum+1;
           ad_ddl.build_statement('  ''  AND ' || p_table_alias || 't.language  = :pLanguageCode'                 || ''' || g_nl||', p_rownum); p_rownum := p_rownum+1;
        */
      ELSIF (p_xml_file_type <> 'RULES') THEN
        ad_ddl.build_statement('	''	AND	' || p_table_alias || '.' ||
                               p_column_id || ' = fb.' || p_column_id ||
                               '		'' || g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''	AND	' || p_table_alias ||
                               '.language  = :pLanguageCode' ||
                               ''' || g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      END IF;
      IF (p_xml_file_type = 'RULES') THEN
        ad_ddl.build_statement('	''	AND	' || p_table_alias || '.' ||
                               p_column_id || ' = gel.src_' || p_column_id ||
                               '		'' || g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
        ad_ddl.build_statement('	''	AND	' || p_table_alias || '1.' ||
                               p_column_id || ' = gel.tgt_' || p_column_id ||
                               '		'' || g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      END IF;
    END IF;
  END add_clause_to_list;
  PROCEDURE build_select_clause_list(p_rownum        IN OUT NOCOPY NUMBER,
                                     p_xml_file_type IN VARCHAR2) IS
    l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN
    --BUG 5147886
    -- Santosh 5234796
    IF (p_xml_file_type = 'DSLOAD') THEN
      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                                    'CHANNEL_DISPLAY_CODE',
                                    'channel_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);
      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                                    'CUSTOMER_DISPLAY_CODE',
                                    'customer_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);

      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                                    'FINANCIAL_ELEM_DISPLAY_CODE',
                                    'financial_elem_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);

      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                                    'NATURAL_ACCOUNT_DISPLAY_CODE',
                                    'natural_account_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);
      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                                    'PRODUCT_DISPLAY_CODE',
                                    'product_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);
      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                                    'PROJECT_DISPLAY_CODE',
                                    'project_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);
      add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                                    'TASK_DISPLAY_CODE',
                                    'task_name',
                                    'gbit',
                                    p_rownum,
                                    p_xml_file_type);
       IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                      'USER_DIM1_DISPLAY_CODE',
                                      'user_dim1_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                      'USER_DIM2_DISPLAY_CODE',
                                      'user_dim2_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                      'USER_DIM3_DISPLAY_CODE',
                                      'user_dim3_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                      'USER_DIM4_DISPLAY_CODE',
                                      'user_dim4_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                      'USER_DIM5_DISPLAY_CODE',
                                      'user_dim5_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                      'USER_DIM6_DISPLAY_CODE',
                                      'user_dim6_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                      'USER_DIM7_DISPLAY_CODE',
                                      'user_dim7_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                      'USER_DIM8_DISPLAY_CODE',
                                      'user_dim8_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                      'USER_DIM9_DISPLAY_CODE',
                                      'user_dim9_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_dsload_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                      'USER_DIM10_DISPLAY_CODE',
                                      'user_dim10_name',
                                      'gbit',
                                      p_rownum,
                                      p_xml_file_type);
      END IF;
    ELSIF (p_xml_file_type = 'NONPOSTED_SELECT' OR
          p_xml_file_type = 'NONPOSTED_GROUP' OR p_xml_file_type = 'DSTB' OR
          p_xml_file_type = 'DSTB_XML' /*OR p_xml_file_type = 'DSTB_XML_ID'*/) THEN  --fix 5351083
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                                'channel_name',
                                'fchb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                                'customer_name',
                                'fcb',
                                p_rownum,
                                p_xml_file_type);

      --BUG 5147886
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                                'financial_elem_name',
                                'ffeb',
                                p_rownum,
                                p_xml_file_type);

      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                                'natural_account_name',
                                'fnab',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                                'product_name',
                                'fpb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                                'project_name',
                                'fpjb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                                'task_name',
                                'ftb',
                                p_rownum,
                                p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                  'user_dim1_name',
                                  'fud1',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                  'user_dim2_name',
                                  'fud2',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                  'user_dim3_name',
                                  'fud3',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                  'user_dim4_name',
                                  'fud4',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                  'user_dim5_name',
                                  'fud5',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                  'user_dim6_name',
                                  'fud6',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                  'user_dim7_name',
                                  'fud7',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                  'user_dim8_name',
                                  'fud8',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                  'user_dim9_name',
                                  'fud9',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                  'user_dim10_name',
                                  'fud10',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
    ELSIF (p_xml_file_type = 'DSTBID') THEN
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('LINE_ITEM_ID'),
                                'line_item_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                                'channel_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                                'customer_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);

      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                                'financial_elem_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);

      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                                'natural_account_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                                'product_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                                'project_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                                'task_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
       IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                  'user_dim1_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                  'user_dim2_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                  'user_dim3_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                  'user_dim4_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                  'user_dim5_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                  'user_dim6_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                  'user_dim7_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                  'user_dim8_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                  'user_dim9_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                  'user_dim10_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
   ELSIF (p_xml_file_type = 'VSMPID') THEN
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('LINE_ITEM_ID'),
                                'line_item_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                                'channel_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                                'customer_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('COMPANY_COST_CENTER_ORG_ID'),
                                'company_cost_center_org_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                                'natural_account_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                                'product_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                                'project_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                                'task_id',
                                'gel',
                                p_rownum,
                                p_xml_file_type);
       IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                                  'user_dim1_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                                  'user_dim2_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                                  'user_dim3_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                                  'user_dim4_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                                  'user_dim5_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                                  'user_dim6_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                                  'user_dim7_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                                  'user_dim8_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                                  'user_dim9_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                                  'user_dim10_id',
                                  'gel',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
   ELSIF (p_xml_file_type = 'CCIDHASH') THEN
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('COMPANY_COST_CENTER_ORG_ID'),
                                'company_cost_center_org_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('LINE_ITEM_ID'),
                                'line_item_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                                'channel_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                                'customer_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                                'natural_account_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                                'product_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                                'project_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                                'task_id',
                                'fb',
                                p_rownum,
                                p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                                  'user_dim1_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                                  'user_dim2_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                                  'user_dim3_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                                  'user_dim4_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                                  'user_dim5_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                                  'user_dim6_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                                  'user_dim7_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                                  'user_dim8_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                                  'user_dim9_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                                  'user_dim10_id',
                                  'fb',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
    ELSE
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                                'channel_name',
                                'fchb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                                'customer_name',
                                'fcb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                                'financial_elem_name',
                                'ffeb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                                'natural_account_name',
                                'fnab',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                                'product_name',
                                'fpb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                                'project_name',
                                'fpjb',
                                p_rownum,
                                p_xml_file_type);
      add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                                'task_name',
                                'ftb',
                                p_rownum,
                                p_xml_file_type);
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM1_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                                  'user_dim1_name',
                                  'fud1',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM2_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                                  'user_dim2_name',
                                  'fud2',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM3_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                                  'user_dim3_name',
                                  'fud3',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM4_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                                  'user_dim4_name',
                                  'fud4',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM5_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                                  'user_dim5_name',
                                  'fud5',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM6_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                                  'user_dim6_name',
                                  'fud6',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM7_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                                  'user_dim7_name',
                                  'fud7',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM8_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                                  'user_dim8_name',
                                  'fud8',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM9_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                                  'user_dim9_name',
                                  'fud9',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM10_ID') = 'Y') THEN
        add_select_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                                  'user_dim10_name',
                                  'fud10',
                                  p_rownum,
                                  p_xml_file_type);
      END IF;
    END IF;
  END build_select_clause_list;
  PROCEDURE build_where_clause_list(p_rownum        IN OUT NOCOPY NUMBER,
                                    p_xml_file_type IN VARCHAR2) IS
    l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN
    -- Santosh 5234796
    /*IF p_xml_file_type = 'DSLOAD' THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'), 'channel_',
                     'fchb', p_rownum, p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'), 'customer_',
                      'fcb', p_rownum, p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'), 'financial_elem_',
                      'ffeb', p_rownum, p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'), 'natural_account_',
                       'fnab', p_rownum, p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'), 'product_',
                     'fpb',
                     p_rownum, p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'), 'project_',
                     'fpjb', p_rownum, p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'), 'task_',
                  'ftb', p_rownum, p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),'user_dim10_',
                                                                                   'fud10', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'), 'user_dim1_',
                       'fud1', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'), 'user_dim2_',
                       'fud2', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'), 'user_dim3_',
                                                                                   'fud3', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'), 'user_dim4_',
                                                                                'fud4', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'), 'user_dim5_',
                                                                                'fud5', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'), 'user_dim6_',
                                                                                'fud6', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'), 'user_dim7_',
                                                                                'fud7', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'), 'user_dim8_',
                     'fud8', p_rownum, p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'), 'user_dim9_',
                                                                                'fud9', p_rownum, p_xml_file_type);
      END IF;
    ELS*/
    IF p_xml_file_type = 'DSTB' THEN
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                         'channel_id',
                         'fchb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                         'customer_id',
                         'fcb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                         'financial_elem_id',
                         'ffeb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                         'natural_account_id',
                         'fnab',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                         'product_id',
                         'fpb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                         'project_id',
                         'fpjb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                         'task_id',
                         'ftb',
                         p_rownum,
                         p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                           'user_dim10_id',
                           'fud10',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                           'user_dim1_id',
                           'fud1',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                           'user_dim2_id',
                           'fud2',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                           'user_dim3_id',
                           'fud3',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                           'user_dim4_id',
                           'fud4',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                           'user_dim5_id',
                           'fud5',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                           'user_dim6_id',
                           'fud6',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                           'user_dim7_id',
                           'fud7',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                           'user_dim8_id',
                           'fud8',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                           'user_dim9_id',
                           'fud9',
                           p_rownum,
                           p_xml_file_type);
      END IF;
    ELSE
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                         'channel_id',
                         'fchb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                         'customer_id',
                         'fcb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                         'financial_elem_id',
                         'ffeb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                         'natural_account_id',
                         'fnab',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                         'product_id',
                         'fpb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                         'project_id',
                         'fpjb',
                         p_rownum,
                         p_xml_file_type);
      add_clause_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                         'task_id',
                         'ftb',
                         p_rownum,
                         p_xml_file_type);
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM10_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                           l_dim_info('USER_DIM10_ID').dim_member_col,
                           'fud10',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM1_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                           l_dim_info('USER_DIM1_ID').dim_member_col,
                           'fud1',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM2_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                           l_dim_info('USER_DIM2_ID').dim_member_col,
                           'fud2',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM3_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                           l_dim_info('USER_DIM3_ID').dim_member_col,
                           'fud3',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM4_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                           l_dim_info('USER_DIM4_ID').dim_member_col,
                           'fud4',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM5_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                           l_dim_info('USER_DIM5_ID').dim_member_col,
                           'fud5',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM6_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                           l_dim_info('USER_DIM6_ID').dim_member_col,
                           'fud6',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM7_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                           l_dim_info('USER_DIM7_ID').dim_member_col,
                           'fud7',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM8_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                           l_dim_info('USER_DIM8_ID').dim_member_col,
                           'fud8',
                           p_rownum,
                           p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM9_ID') = 'Y') THEN
        add_clause_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                           l_dim_info('USER_DIM9_ID').dim_member_col,
                           'fud9',
                           p_rownum,
                           p_xml_file_type);
      END IF;
    END IF;
  END build_where_clause_list;
  PROCEDURE add_table_to_list(p_dimension_required IN VARCHAR2,
                              p_table_name         IN VARCHAR2,
                              p_table_alias        IN VARCHAR2,
                              p_rownum             IN OUT NOCOPY NUMBER,
                              p_xml_file_type      IN VARCHAR2) IS
  BEGIN
    IF (p_dimension_required = 'Y') THEN
      ad_ddl.build_statement('''                  ' || p_table_name || ' ' ||
                             p_table_alias || ',			'' ||g_nl||',
                             p_rownum);
      p_rownum := p_rownum + 1;
      IF (p_xml_file_type = 'RULES') THEN
        ad_ddl.build_statement('''                  ' || p_table_name || ' ' ||
                               p_table_alias || '1,			'' ||g_nl||',
                               p_rownum);
        p_rownum := p_rownum + 1;
      END IF;
    END IF;
  END add_table_to_list;
  PROCEDURE build_table_list(p_rownum        IN OUT NOCOPY NUMBER,
                             p_xml_file_type IN VARCHAR2) IS
    l_dim_info gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  BEGIN
    IF (p_xml_file_type = 'DSTB') THEN
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'),
                        'fem_channels_tl',
                        'fchb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'),
                        'fem_customers_tl',
                        'fcb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'),
                        'fem_fin_elems_tl',
                        'ffeb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'),
                        'fem_nat_accts_tl',
                        'fnab',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'),
                        'fem_products_tl',
                        'fpb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'),
                        'fem_projects_tl',
                        'fpjb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'),
                        'fem_tasks_tl',
                        'ftb',
                        p_rownum,
                        p_xml_file_type);
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),
                          'FEM_USER_DIM10_TL',
                          'fud10',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'),
                          'FEM_USER_DIM1_TL',
                          'fud1',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'),
                          'FEM_USER_DIM2_TL',
                          'fud2',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'),
                          'FEM_USER_DIM3_TL',
                          'fud3',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'),
                          'FEM_USER_DIM4_TL',
                          'fud4',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'),
                          'FEM_USER_DIM5_TL',
                          'fud5',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'),
                          'FEM_USER_DIM6_TL',
                          'fud6',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'),
                          'FEM_USER_DIM7_TL',
                          'fud7',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'),
                          'FEM_USER_DIM8_TL',
                          'fud8',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'),
                          'FEM_USER_DIM9_TL',
                          'fud9',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      -- Santosh 5234796
      /*ELSIF (p_xml_file_type = 'DSLOAD') THEN
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'), 'fem_channels_b', 'fchb', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID'), 'fem_channels_tl', 'fchbt', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'), 'fem_customers_b', 'fcb', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID'), 'fem_customers_tl', 'fcbt', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'), 'fem_fin_elems_b', 'ffeb', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID'), 'fem_fin_elems_tl', 'ffebt', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'), 'fem_nat_accts_b', 'fnab', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID'), 'fem_nat_accts_tl', 'fnabt', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'), 'fem_products_b', 'fpb', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID'), 'fem_products_tl', 'fpbt', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'), 'fem_projects_b', 'fpjb', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('PROJECT_ID'), 'fem_projects_tl', 'fpjbt', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'), 'fem_tasks_b', 'ftb', p_rownum, p_xml_file_type);
        add_table_to_list(gcs_utility_pkg.get_fem_dim_required('TASK_ID'), 'fem_tasks_tl', 'ftbt', p_rownum, p_xml_file_type);
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),'FEM_USER_DIM10_B',
                      'fud10', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID'),'FEM_USER_DIM10_TL',
                      'fud10T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'), 'FEM_USER_DIM1_B',
                      'fud1', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID'), 'FEM_USER_DIM1_TL',
                      'fud1T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'), 'FEM_USER_DIM2_B',
                      'fud2', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID'), 'FEM_USER_DIM2_TL',
                      'fud2T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'), 'FEM_USER_DIM3_B',
                      'fud3', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID'), 'FEM_USER_DIM3_TL',
                      'fud3T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'), 'FEM_USER_DIM4_B',
                      'fud4', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID'), 'FEM_USER_DIM4_TL',
                      'fud4T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'), 'FEM_USER_DIM5_B',
                      'fud5', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID'), 'FEM_USER_DIM5_TL',
                      'fud5T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'), 'FEM_USER_DIM6_B',
                      'fud6', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID'), 'FEM_USER_DIM6_TL',
                      'fud6T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'), 'FEM_USER_DIM7_B',
                      'fud7', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID'), 'FEM_USER_DIM7_TL',
                      'fud7T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'), 'FEM_USER_DIM8_B',
                      'fud8', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID'), 'FEM_USER_DIM8_TL',
                      'fud8T', p_rownum, p_xml_file_type);
        END IF;
        IF (gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID') = 'Y') THEN
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'), 'FEM_USER_DIM9_B',
                      'fud9', p_rownum, p_xml_file_type);
          add_table_to_list(gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID'), 'FEM_USER_DIM9_TL',
                      'fud9T', p_rownum, p_xml_file_type);
        END IF;
      */
    ELSIF (p_xml_file_type = 'ADTB') THEN
      add_table_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                        'fem_channels_tl',
                        'fchb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                        'fem_customers_tl',
                        'fcb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                        'fem_fin_elems_tl',
                        'ffeb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                        'fem_nat_accts_tl',
                        'fnab',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                        'fem_products_tl',
                        'fpb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                        'fem_projects_tl',
                        'fpjb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                        'fem_tasks_tl',
                        'ftb',
                        p_rownum,
                        p_xml_file_type);
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM10_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                          'FEM_USER_DIM10_TL',
                          'fud10',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM1_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                          'FEM_USER_DIM1_TL',
                          'fud1',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM2_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                          'FEM_USER_DIM2_TL',
                          'fud2',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM3_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                          'FEM_USER_DIM3_TL',
                          'fud3',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM4_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                          'FEM_USER_DIM4_TL',
                          'fud4',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM5_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                          'FEM_USER_DIM5_TL',
                          'fud5',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM6_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                          'FEM_USER_DIM6_TL',
                          'fud6',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM7_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                          'FEM_USER_DIM7_TL',
                          'fud7',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM8_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                          'FEM_USER_DIM8_TL',
                          'fud8',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM9_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                          'FEM_USER_DIM9_TL',
                          'fud9',
                          p_rownum,
                          p_xml_file_type);
      END IF;
    ELSE
      add_table_to_list(gcs_utility_pkg.get_dimension_required('CHANNEL_ID'),
                        'fem_channels_tl',
                        'fchb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('CUSTOMER_ID'),
                        'fem_customers_tl',
                        'fcb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID'),
                        'fem_fin_elems_tl',
                        'ffeb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID'),
                        'fem_nat_accts_tl',
                        'fnab',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('PRODUCT_ID'),
                        'fem_products_tl',
                        'fpb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('PROJECT_ID'),
                        'fem_projects_tl',
                        'fpjb',
                        p_rownum,
                        p_xml_file_type);
      add_table_to_list(gcs_utility_pkg.get_dimension_required('TASK_ID'),
                        'fem_tasks_tl',
                        'ftb',
                        p_rownum,
                        p_xml_file_type);
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM10_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM10_ID'),
                          'FEM_USER_DIM10_TL',
                          'fud10',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM1_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM1_ID'),
                          'FEM_USER_DIM1_TL',
                          'fud1',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM2_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM2_ID'),
                          'FEM_USER_DIM2_TL',
                          'fud2',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM3_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM3_ID'),
                          'FEM_USER_DIM3_TL',
                          'fud3',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM4_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM4_ID'),
                          'FEM_USER_DIM4_TL',
                          'fud4',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM5_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM5_ID'),
                          'FEM_USER_DIM5_TL',
                          'fud5',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM6_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM6_ID'),
                          'FEM_USER_DIM6_TL',
                          'fud6',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM7_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM7_ID'),
                          'FEM_USER_DIM7_TL',
                          'fud7',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM8_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM8_ID'),
                          'FEM_USER_DIM8_TL',
                          'fud8',
                          p_rownum,
                          p_xml_file_type);
      END IF;
      IF (gcs_utility_pkg.get_dimension_required('USER_DIM9_ID') = 'Y') THEN
        add_table_to_list(gcs_utility_pkg.get_dimension_required('USER_DIM9_ID'),
                          'FEM_USER_DIM9_TL',
                          'fud9',
                          p_rownum,
                          p_xml_file_type);
      END IF;
    END IF;
  END build_table_list;
  PROCEDURE create_xml_utility_PKG(p_retcode NUMBER, p_errbuf VARCHAR2) IS
    r        NUMBER(15) := 1;
    comp_err VARCHAR2(200) := NULL;
  BEGIN
    ad_ddl.build_statement('CREATE OR REPLACE PACKAGE GCS_XML_UTILITY_PKG AS',
                           r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('--API Name', r);
    r := r + 1;
    ad_ddl.build_statement('  g_api		VARCHAR2(50) :=	''gcs.plsql.GCS_XML_UTILITY_PKG'';',
                           r);
    r := r + 1;
    ad_ddl.build_statement('  g_nl		VARCHAR2(1) :=	''
'';',
                           r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  -- Action types for writing module information to the log file. Used for',
                           r);
    r := r + 1;
    ad_ddl.build_statement('  -- the procedure log_file_module_write.', r);
    r := r + 1;
    ad_ddl.build_statement('  g_module_enter    VARCHAR2(2) := ''>>'';', r);
    r := r + 1;
    ad_ddl.build_statement('  g_module_success  VARCHAR2(2) := ''<<'';', r);
    r := r + 1;
    ad_ddl.build_statement('  g_module_failure  VARCHAR2(2) := ''<x'';', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('-- Beginning of private procedures ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    -- Create select list for GCS Active Dims
    ad_ddl.build_statement('  g_gcs_dims_select_list VARCHAR2(2000) := ',
                           r);
    r := r + 1;
    build_select_clause_list(r, 'ENTRY');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_gcs_dims_table_list VARCHAR2(2000) := ', r);
    r := r + 1;
    build_table_list(r, 'ENTRY');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_gcs_dims_where_clause VARCHAR2(10000) := ',
                           r);
    r := r + 1;
    build_where_clause_list(r, 'ENTRY');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_gcs_dims_xml_elem VARCHAR2(2000) := ', r);
    r := r + 1;
    build_select_clause_list(r, 'ENTRY_XML');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_gcs_vsmp_xml_elem VARCHAR2(10000) := ', r);
    r := r + 1;
    build_select_clause_list(r, 'VSMPID');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    -- Create select list for FEM Active Dims
    ad_ddl.build_statement('  g_fem_dims_select_list_dsload VARCHAR2(2000) := ',
                           r);
    r := r + 1;
    build_select_clause_list(r, 'DSLOAD');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_fem_dims_select_list_dstb VARCHAR2(2000) := ',
                           r);
    r := r + 1;
    build_select_clause_list(r, 'DSTB');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    --fix 5351083
    --ad_ddl.build_statement('  g_fem_dims_table_list_dsload VARCHAR2(2000) := ', r);
    --r := r + 1;
    --build_table_list(r, 'DSLOAD');
    --ad_ddl.build_statement('	''  ''; ', r);
    --r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_fem_dims_table_list_dstb VARCHAR2(2000) := ',
                           r);
    r := r + 1;
    build_table_list(r, 'DSTB');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_fem_dims_dstb_where_clause VARCHAR2(2000) := ',
                           r);
    r := r + 1;
    build_where_clause_list(r, 'DSTB');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    --fix 5351083
    --ad_ddl.build_statement('  g_fem_dims_dsload_where_clause VARCHAR2(10000) := ', r);
    --r := r + 1;
    --build_where_clause_list(r, 'DSLOAD');
    --ad_ddl.build_statement('	''  ''; ', r);
    --r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;
    ad_ddl.build_statement('  g_fem_dims_xml_elem VARCHAR2(2000) := ', r);
    r := r + 1;
    build_select_clause_list(r, 'DSTB_XML');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    --fix 5351083
    --ad_ddl.build_statement('  p_element_list_dstb VARCHAR2(2000) := ', r);
    --r := r + 1;
    --build_select_clause_list(r, 'DSTB_XML_ID');
    --ad_ddl.build_statement('	''  ''; ', r);
    --r := r + 1;
    ad_ddl.build_statement('  g_group_by_stmnt VARCHAR2(1000) := ', r);
    r := r + 1;
    build_order_clause_list(r, 'OGL');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;

    --BUG 5147886
    ad_ddl.build_statement('  g_fem_nonposted_select_stmnt VARCHAR2(5000) := ',
                           r);
    r := r + 1;
    build_select_clause_list(r, 'NONPOSTED_SELECT');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;

    ad_ddl.build_statement('  g_fem_nonposted_group_stmnt VARCHAR2(5000) := ',
                           r);
    r := r + 1;
    build_select_clause_list(r, 'NONPOSTED_GROUP');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;

    --Santosh
    ad_ddl.build_statement('  g_fem_dims_dsload_order_clause VARCHAR2(1000) := ', r);
    r := r + 1;
    build_order_clause_list(r, 'DSLOAD');
    ad_ddl.build_statement('	''  ''; ', r);
    r := r + 1;
    ad_ddl.build_statement(' ', r);
    r := r + 1;

    ad_ddl.build_statement('END GCS_XML_UTILITY_PKG;', r);
    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                               'GCS',
                               'GCS_XML_UTILITY_PKG',
                               1,
                               r,
                               'TRUE',
                               comp_err);
  END create_xml_utility_PKG;
END GCS_XML_DYNAMIC_PKG;

/
