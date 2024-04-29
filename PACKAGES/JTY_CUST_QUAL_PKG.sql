--------------------------------------------------------
--  DDL for Package JTY_CUST_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_CUST_QUAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfcusqs.pls 120.1 2006/09/22 22:16:24 chchandr noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_CUST_QUAL_PKG
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to create custom qualifiers
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      09/08/05    ACHANDA         Created
--
--    End of Comments
--

PROCEDURE create_qual(
  p_seeded_qual_id             IN NUMBER,
  p_name                       IN VARCHAR2,
  p_description                IN VARCHAR2,
  p_language                   IN VARCHAR2,
  p_source_id                  IN NUMBER,
  p_trans_type_id              IN NUMBER,
  p_enabled_flag               IN VARCHAR2,
  p_qual_col1                  IN VARCHAR2,
  p_convert_to_id_flag         IN VARCHAR2,
  p_display_type               IN VARCHAR2,
  p_alias_rule1                IN VARCHAR2,
  p_op_eql                     IN VARCHAR2,
  p_op_like                    IN VARCHAR2,
  p_op_between                 IN VARCHAR2,
  p_op_common_where            IN VARCHAR2,
  p_qual_relation_factor       IN NUMBER,
  p_comparison_operator        IN VARCHAR2,
  p_low_value_char             IN VARCHAR2,
  p_high_value_char            IN VARCHAR2,
  p_low_value_char_id          IN VARCHAR2,
  p_low_value_number           IN VARCHAR2,
  p_high_value_number          IN VARCHAR2,
  p_interest_type_id           IN VARCHAR2,
  p_primary_interest_code_id   IN VARCHAR2,
  p_sec_interest_code_id       IN VARCHAR2,
  p_value1_id                  IN VARCHAR2,
  p_value2_id                  IN VARCHAR2,
  p_value3_id                  IN VARCHAR2,
  p_value4_id                  IN VARCHAR2,
  p_first_char                 IN VARCHAR2,
  p_currency_code              IN VARCHAR2,
  p_real_time_select           IN VARCHAR2,
  p_real_time_where            IN VARCHAR2,
  p_real_time_from             IN VARCHAR2,
  p_html_lov_sql1              IN VARCHAR2,
  p_html_lov_sql2              IN VARCHAR2,
  p_html_lov_sql3              IN VARCHAR2,
  p_display_sql1               IN VARCHAR2,
  p_display_sql2               IN VARCHAR2,
  p_display_sql3               IN VARCHAR2,
  p_hierarchy_type             IN VARCHAR2,
  p_equal_flag                 IN VARCHAR2,
  p_like_flag                  IN VARCHAR2,
  p_between_flag               IN VARCHAR2,
  retcode                      OUT NOCOPY VARCHAR2,
  errbuf                       OUT NOCOPY VARCHAR2);

END JTY_CUST_QUAL_PKG;

 

/
