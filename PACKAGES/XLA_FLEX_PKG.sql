--------------------------------------------------------
--  DDL for Package XLA_FLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_FLEX_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmflx.pkh 120.12.12010000.3 2009/06/19 09:33:10 rajose ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_flex_pkg                                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Flex Package                                                   |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_value_set_name                                                    |
|                                                                       |
| Get the value set name for the value set id                           |
|                                                                       |
+======================================================================*/
FUNCTION  get_value_set_name
  (p_flex_value_set_id               IN  INTEGER)
RETURN VARCHAR2;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_chart_of_accounts_name                                            |
|                                                                       |
| Get the chart of accounts name for the chart of accounts id           |
|                                                                       |
+======================================================================*/
FUNCTION  get_chart_of_accounts_name
  (p_application_id                  IN  INTEGER
  ,p_flex_code                       IN  VARCHAR2
  ,p_chart_of_accounts_id            IN  INTEGER)
RETURN VARCHAR2;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flexfield_segment_name                                            |
|                                                                       |
| Get the segment name for the segment code                             |
|                                                                       |
+======================================================================*/
FUNCTION  get_flexfield_segment_name
  (p_application_id                  IN  INTEGER
  ,p_flex_code                       IN  VARCHAR2
  ,p_chart_of_accounts_id            IN  INTEGER
  ,p_flexfield_segment_code          IN  VARCHAR2)
RETURN VARCHAR2;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flex_value_meaning                                                |
|                                                                       |
| Get the meaning for the flex value                                    |
|                                                                       |
+======================================================================*/
FUNCTION  get_flex_value_meaning
  (p_flex_value_set_id               IN  INTEGER
  ,p_flex_value                      IN  VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flexfield_segment_info                                            |
|                                                                       |
| Get the segment info for the segment code                             |
|                                                                       |
+======================================================================*/
FUNCTION  get_flexfield_segment_info
  (p_application_id                  IN     INTEGER
  ,p_flex_code                       IN     VARCHAR2
  ,p_chart_of_accounts_id            IN     INTEGER
  ,p_flexfield_segment_code          IN     VARCHAR2
  ,p_flexfield_segment_name          IN OUT NOCOPY VARCHAR2
  ,p_flexfield_segment_num           IN OUT NOCOPY INTEGER)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_table_vset_select                                                 |
|                                                                       |
| Get the select for a table validated valueset                         |
|                                                                       |
+======================================================================*/
PROCEDURE get_table_vset_select
  (p_flex_value_set_id               IN     INTEGER
  ,p_select                          OUT NOCOPY    VARCHAR2
  ,p_mapping_code                    OUT NOCOPY    VARCHAR2
  ,p_success                         OUT NOCOPY    NUMBER);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_table_vset_return_col                                             |
|                                                                       |
| Get the select column and where column for a table validated valueset |
|                                                                       |
+======================================================================*/
PROCEDURE get_table_vset_return_col
  (p_flex_value_set_id               IN     INTEGER
  ,p_select_col                      OUT NOCOPY   VARCHAR2
  ,p_where_col                       OUT NOCOPY   VARCHAR2
  ,p_type_out                        OUT NOCOPY   INTEGER
  ) ;



/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| segment_qualifer_is_enabled                                           |
|                                                                       |
| Returns true if the segment qualifer is enabled for the coa specified |
|                                                                       |
+======================================================================*/
FUNCTION  segment_qualifier_is_enabled
  (p_application_id                  IN     INTEGER
  ,p_flex_code                       IN     VARCHAR2
  ,p_chart_of_accounts_id            IN     INTEGER
  ,p_flexfield_segment_code          IN     VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| id_column_is_null                                                     |
|                                                                       |
| Returns true if the id column is null                                 |
|                                                                       |
+======================================================================*/
FUNCTION  id_column_is_null
  (p_flex_value_set_id               IN  INTEGER)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| meaning_column_is_null                                                |
|                                                                       |
| Returns true if the meaning column is null                            |
|                                                                       |
+======================================================================*/
FUNCTION  meaning_column_is_null
  (p_flex_value_set_id               IN  INTEGER)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| chk_additional_where_clause                                            |
|                                                                       |
| Returns true if the additional where caluse has $FLEX$                |
|                                                                       |
+======================================================================*/
FUNCTION  chk_additional_where_clause
  (p_flex_value_set_id               IN  INTEGER)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_qualifier_segment                                                 |
|                                                                       |
| Returns the segment for the qualifier specified                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_qualifier_segment
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_id_flex_num                     IN     INTEGER
  ,p_qualifier_segment               IN     VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_segment_qualifier                                                 |
|                                                                       |
| Returns the qualifier for the segment specified                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_segment_qualifier
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_id_flex_num                     IN     INTEGER
  ,p_segment_code                    IN     VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_segment_valueset                                                  |
|                                                                       |
| Returns the valuset for the segment specified                         |
|                                                                       |
+======================================================================*/
FUNCTION  get_segment_valueset
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_id_flex_num                     IN     INTEGER
  ,p_segment_code                    IN     VARCHAR2)
RETURN NUMBER;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_qualifier_name                                                    |
|                                                                       |
| Returns the name for the flexfield qualifier                          |
|                                                                       |
+======================================================================*/
FUNCTION  get_qualifier_name
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_qualifier_segment               IN     VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flexfield_structure                                               |
|                                                                       |
| Returns the flexfield structure for the key flexfields that support   |
| single structure                                                      |
|                                                                       |
+======================================================================*/
FUNCTION  get_flexfield_structure
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2)
RETURN NUMBER;

END xla_flex_pkg;

/
