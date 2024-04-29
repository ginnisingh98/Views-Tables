--------------------------------------------------------
--  DDL for Package FND_FLEX_XML_PUBLISHER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_XML_PUBLISHER_APIS" AUTHID CURRENT_USER AS
/* $Header: AFFFXPAS.pls 120.0.12010000.2 2013/10/01 05:40:30 vgadidas ship $ */

--
-- metadata type constants
--
metadata_segments_above_prompt CONSTANT VARCHAR2(30) := 'ABOVE_PROMPT';
metadata_segments_left_prompt  CONSTANT VARCHAR2(30) := 'LEFT_PROMPT';

--
-- kff_where: operator constants
--
operator_equal                 CONSTANT VARCHAR2(30) := '=';
operator_less_than             CONSTANT VARCHAR2(30) := '<';
operator_greater_than          CONSTANT VARCHAR2(30) := '>';
operator_less_than_or_equal    CONSTANT VARCHAR2(30) := '<=';
operator_greater_than_or_equal CONSTANT VARCHAR2(30) := '>=';
operator_not_equal             CONSTANT VARCHAR2(30) := '!=';
operator_concatenate           CONSTANT VARCHAR2(30) := '||';
operator_between               CONSTANT VARCHAR2(30) := 'BETWEEN';
operator_qbe                   CONSTANT VARCHAR2(30) := 'QBE';
operator_like                  CONSTANT VARCHAR2(30) := 'LIKE';

--
-- <SEGMENTS> parser mode constants
--  Moved here from body to make them public

segments_mode_all_enabled    CONSTANT VARCHAR2(30) := 'ALL_ENABLED';
segments_mode_displayed_only CONSTANT VARCHAR2(30) := 'DISPLAYED_ONLY';

--
-- kff_select: output type constants
--
output_type_value              CONSTANT VARCHAR2(30) := 'VALUE';
output_type_padded_value       CONSTANT VARCHAR2(30) := 'PADDED_VALUE';
output_type_description        CONSTANT VARCHAR2(30) := 'DESCRIPTION';
output_type_full_description   CONSTANT VARCHAR2(30) := 'FULL_DESCRIPTION';
output_type_security           CONSTANT VARCHAR2(30) := 'SECURITY';

--
-- kff_where: bind data type constants
--
bind_data_type_varchar2        CONSTANT VARCHAR2(30) := 'VARCHAR2';
bind_data_type_number          CONSTANT VARCHAR2(30) := 'NUMBER';
bind_data_type_date            CONSTANT VARCHAR2(30) := 'DATE';

TYPE bind_variable IS RECORD
  (name            VARCHAR2(30),
   data_type       VARCHAR2(30),
   canonical_value VARCHAR2(32000),
   varchar2_value  VARCHAR2(32000),
   number_value    NUMBER,
   date_value      DATE);

TYPE bind_variables IS TABLE OF bind_variable INDEX BY BINARY_INTEGER;

--
-- Debug Modes
--
debug_mode_on                  CONSTANT VARCHAR2(30) := 'ON';
debug_mode_off                 CONSTANT VARCHAR2(30) := 'OFF';

-- ======================================================================
PROCEDURE set_debug_mode
  (p_debug_mode                   IN VARCHAR2);

-- ======================================================================
PROCEDURE get_debug
  (x_debug                        OUT nocopy VARCHAR2);

-- ======================================================================
PROCEDURE kff_flexfield_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2);

-- ======================================================================
PROCEDURE kff_structure_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2);

-- ======================================================================
PROCEDURE kff_segment_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_application_column_name      IN fnd_id_flex_segments.application_column_name%TYPE,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2);

-- ======================================================================
PROCEDURE kff_segments_metadata
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_segments                     IN VARCHAR2,
   p_show_parent_segments         IN VARCHAR2,
   p_metadata_type                IN VARCHAR2,
   x_metadata                     OUT nocopy VARCHAR2);

-- ======================================================================
PROCEDURE kff_select
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE DEFAULT 101,
   p_multiple_id_flex_num         IN VARCHAR2 DEFAULT 'N',
   p_code_combination_table_alias IN VARCHAR2 DEFAULT NULL,
   p_segments                     IN VARCHAR2 DEFAULT 'ALL',
   p_show_parent_segments         IN VARCHAR2 DEFAULT 'Y',
   p_output_type                  IN VARCHAR2,
   x_select_expression            OUT nocopy VARCHAR2);

-- ======================================================================
PROCEDURE kff_where
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_code_combination_table_alias IN VARCHAR2 DEFAULT NULL,
   p_segments                     IN VARCHAR2 DEFAULT 'ALL',
   p_operator                     IN VARCHAR2,
   p_operand1                     IN VARCHAR2,
   p_operand2                     IN VARCHAR2 DEFAULT NULL,
   x_where_expression             OUT nocopy VARCHAR2,
   x_numof_bind_variables         OUT nocopy NUMBER,
   x_bind_variables               OUT nocopy bind_variables);

-- ======================================================================
PROCEDURE kff_order_by
  (p_lexical_name                 IN VARCHAR2,
   p_application_short_name       IN fnd_application.application_short_name%TYPE,
   p_id_flex_code                 IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num                  IN fnd_id_flex_structures.id_flex_num%TYPE DEFAULT 101,
   p_multiple_id_flex_num         IN VARCHAR2 DEFAULT 'N',
   p_code_combination_table_alias IN VARCHAR2 DEFAULT NULL,
   p_segments                     IN VARCHAR2 DEFAULT 'ALL',
   p_show_parent_segments         IN VARCHAR2 DEFAULT 'Y',
   x_order_by_expression          OUT nocopy VARCHAR2);

-- ======================================================================
FUNCTION process_kff_combination_1
  (p_lexical_name           IN VARCHAR2,
   p_application_short_name IN fnd_application.application_short_name%TYPE,
   p_id_flex_code           IN fnd_id_flexs.id_flex_code%TYPE,
   p_id_flex_num            IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_data_set               IN fnd_id_flex_structures.id_flex_num%TYPE,
   p_ccid                   IN NUMBER,
   p_segments               IN VARCHAR2,
   p_show_parent_segments   IN VARCHAR2,
   p_output_type            IN VARCHAR2,
   p_segment_mode           IN VARCHAR2 DEFAULT segments_mode_displayed_only)
  RETURN VARCHAR2;

-- ======================================================================
FUNCTION get_all_segment_mode  RETURN VARCHAR2;

END fnd_flex_xml_publisher_apis;

/
