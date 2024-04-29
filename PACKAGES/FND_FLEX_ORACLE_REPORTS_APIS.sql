--------------------------------------------------------
--  DDL for Package FND_FLEX_ORACLE_REPORTS_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_ORACLE_REPORTS_APIS" AUTHID CURRENT_USER AS
/* $Header: AFFFORAS.pls 120.1.12010000.1 2008/07/25 14:14:13 appldev ship $ */

--
-- FLEXSQL user exit, MODE constants
--
mode_select                    CONSTANT VARCHAR2(30) := 'SELECT';
mode_where                     CONSTANT VARCHAR2(30) := 'WHERE';
mode_order_by                  CONSTANT VARCHAR2(30) := 'ORDER BY';
mode_having                    CONSTANT VARCHAR2(30) := 'HAVING';

--
-- FLEXSQL user exit, OPERATOR constants
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
-- Please see "Flexfields Guide", "Reporting on Flexfield Data" chapter
-- for more information about FLEXSQL and FLEXIDVAL APIs.
--
--
-- User Exit     PL/SQL API
-- -----------   -----------------------------------------
-- FND FLEXSQL   fnd_flex_oracle_reports_apis.flexsql(...);
--
-- This API returns a SQL fragment to be used in various portions of a
-- SELECT statement.
--
--    User Exit       PL/SQL API
--    parameter       parameter         Notes
--    ---------       ----------------- --------------------------
-- Input Arguments
--    APPL_SHORT_NAME p_appl_short_name e.g. 'SQLGL'
--    CODE            p_code            e.g. 'GL#'
--    MODE            p_mode            See mode_* constants
--    NUM             p_num             e.g. 101
--    MULTINUM        p_multinum        e.g. 'Y', 'N'
--    DISPLAY         p_display         e.g. 'ALL', '1', 'GL_ACCOUNT'
--    SHOWDEPSEG      p_showdepseg      e.g. 'Y', 'N'
--    TABLEALIAS      p_tablealias      e.g. 'my_table'
--    OPERATOR        p_operator        See operator_* constants
--    OPERAND1        p_operand1
--    OPERAND2        p_operand2
--
-- Output Arguments
--    OUTPUT          x_output
--
-- Exception Handling
--    This procedure raises exception if there is any error. The translated
--    error message can be retreived by calling SQLERRM, or
--    dbms_utility.format_error_stack().
--
PROCEDURE flexsql(p_appl_short_name IN VARCHAR2,
                  p_code            IN VARCHAR2,
                  p_mode            IN VARCHAR2,
                  p_num             IN NUMBER DEFAULT 101,
                  p_multinum        IN VARCHAR2 DEFAULT 'N',
                  p_display         IN VARCHAR2 DEFAULT 'ALL',
                  p_showdepseg      IN VARCHAR2 DEFAULT 'Y',
                  p_tablealias      IN VARCHAR2 DEFAULT NULL,
                  p_operator        IN VARCHAR2 DEFAULT NULL,
                  p_operand1        IN VARCHAR2 DEFAULT NULL,
                  p_operand2        IN VARCHAR2 DEFAULT NULL,
                  x_output          OUT nocopy VARCHAR2);


--
-- FLEXIDVAL user exit, Output Name Constants
--
output_value                   CONSTANT VARCHAR2(30) := 'VALUE';
output_description             CONSTANT VARCHAR2(30) := 'DESCRIPTION';
output_aprompt                 CONSTANT VARCHAR2(30) := 'APROMPT';
output_lprompt                 CONSTANT VARCHAR2(30) := 'LPROMPT';
output_padded_value            CONSTANT VARCHAR2(30) := 'PADDED_VALUE';
output_security                CONSTANT VARCHAR2(30) := 'SECURITY';
output_full_description        CONSTANT VARCHAR2(30) := 'FULL_DESCRIPTION';
output_ccid                    CONSTANT VARCHAR2(30) := 'CCID';

--
-- FLEXIDVAL user exit, Output Record Type
--
TYPE flexidval_output_rec_type IS RECORD
  (name  VARCHAR2(30),
   value VARCHAR2(32000));

--
-- FLEXIDVAL user exit, Output Array Type (1-based array)
--
TYPE flexidval_output_arr_type IS TABLE OF flexidval_output_rec_type
  INDEX BY BINARY_INTEGER;

--
-- User Exit     PL/SQL API
-- -----------   -----------------------------------------
-- FND FLEXIDVAL fnd_flex_oracle_reports_apis.flexidval(...);
--
--    User Exit        PL/SQL API
--    parameter        parameter         Notes
--    ---------        ----------------- --------------------------
-- Input Arguments
--    APPL_SHORT_NAME  p_appl_short_name
--    CODE             p_code
--    DATA             p_data
--    NUM              p_num
--    MULTINUM         p_multinum
--    DISPLAY          p_display
--    IDISPLAY         p_display
--    DINSERT          p_dinsert
--    SHOWDEPSEG       p_showdepseg
--
--                     p_output_array_size
--
-- Input/Output Arguments
--                     px_output_array   See output_* constants
--
--    To be able to get outputs from this API, put the names of the
--    output variables you are interested in the px_output_array(i).name.
--    This API will return the value of that output in the
--    px_output_array(i).value. Please note that this array's index is 1-based.
--    p_output_array_size should be passed in too, and it should indicate
--    the index of the last element.
--
-- Exception Handling
--    This procedure raises exception if there is any error. The translated
--    error message can be retreived by calling SQLERRM, or
--    dbms_utility.format_error_stack().
--
PROCEDURE flexidval(p_appl_short_name   IN VARCHAR2,
                    p_code              IN VARCHAR2,
                    p_data              IN VARCHAR2,
                    p_num               IN NUMBER DEFAULT 101,
                    p_multinum          IN VARCHAR2 DEFAULT 'N',
                    p_display           IN VARCHAR2 DEFAULT 'ALL',
                    p_idisplay          IN VARCHAR2 DEFAULT 'ALL',
                    p_showdepseg        IN VARCHAR2 DEFAULT 'Y',
                    p_dinsert           IN VARCHAR2 DEFAULT 'N',
                    p_output_array_size IN BINARY_INTEGER,
                    px_output_array     IN OUT nocopy flexidval_output_arr_type);

END fnd_flex_oracle_reports_apis;

/
