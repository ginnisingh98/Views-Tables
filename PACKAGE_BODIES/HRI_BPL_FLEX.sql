--------------------------------------------------------
--  DDL for Package Body HRI_BPL_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_FLEX" AS
/* $Header: hribflx.pkb 120.1 2005/10/05 07:51:02 jtitmas noship $ */

/******************************************************************************/
/* PRIVATE SECTION                                                            */
/******************************************************************************/

  g_rtn     VARCHAR2(5) := '
';

/******************************************************************************/
/* Returns the LOV sql for a table validated value set                        */
/******************************************************************************/
PROCEDURE get_table_value_set_sql
  (p_flex_value_set_id     IN fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_sql_stmt              OUT NOCOPY VARCHAR2
  ,p_distinct_flag         IN VARCHAR2) IS

/* Code from HR_FLEX_VALUE_SET_INFO (hrfvsinf.pkb) */
/* Returns details about table validated value sets */
  CURSOR csr_validation_tables IS
    SELECT DECODE(NVL(fvt.id_column_type,fvt.value_column_type)
                 ,'D','fnd_date.date_to_canonical('||
                         NVL(fvt.id_column_name,fvt.value_column_name)||')'
                 ,'N','fnd_number.number_to_canonical('||
                         NVL(fvt.id_column_name,fvt.value_column_name)||')'
                 ,NVL(fvt.id_column_name,fvt.value_column_name)
                 ) AS id_column_name
          ,DECODE(fvt.id_column_name,
                    NULL,  DECODE(fvt.meaning_column_type,
                                    'D','fnd_date.date_to_displaydate('||fvt.meaning_column_name||')',
                                  fvt.meaning_column_name),
                  DECODE(fvt.value_column_type,
                           'D','fnd_date.date_to_displaydate('||fvt.value_column_name||')',
                         fvt.value_column_name)
                 ) AS value_column_name
          ,fvt.application_table_name AS from_clause
          ,fvt.additional_where_clause AS where_and_order_clause
      FROM fnd_flex_validation_tables fvt
     WHERE fvt.flex_value_set_id = p_flex_value_set_id;

  l_value_column_name       VARCHAR2(240);
  l_id_column_name          VARCHAR2(240);
  l_from_clause             VARCHAR2(240);
  l_where_and_order_clause  VARCHAR2(32000);
  l_where_clause            VARCHAR2(32000);
  l_distinct_clause         VARCHAR2(30);

/* Whether there is an ORDER BY clause entered */
  l_order_clause_position   NUMBER;

BEGIN

/* Bug 3387576 - Add distinct to lov sql if required */
  IF (p_distinct_flag = 'Y') THEN
    l_distinct_clause := 'DISTINCT ';
  END IF;

/* Get the value set validation definition */
  OPEN csr_validation_tables;
  FETCH csr_validation_tables INTO
    l_id_column_name,
    l_value_column_name,
    l_from_clause,
    l_where_and_order_clause;
  CLOSE csr_validation_tables;

/* Split out the order by clause if there is one */
  l_order_clause_position := INSTR(UPPER(l_where_and_order_clause),'ORDER BY');
  IF (l_order_clause_position > 0) THEN
    l_where_clause := SUBSTR(l_where_and_order_clause, 1, l_order_clause_position - 1);
  ELSE
    l_where_clause := l_where_and_order_clause;
  END IF;

/* If the where clause has any bind variables in then discard it */
  IF (INSTR(l_where_clause, ':') > 0) THEN
    l_where_clause := NULL;
  END IF;

/* If the where clause is not empty and doesn't begins with WHERE then add it */
  IF (l_where_clause IS NOT NULL AND
      UPPER(SUBSTR(l_where_clause, 1, 5)) <> 'WHERE') THEN
    l_where_clause := g_rtn || 'WHERE ' || l_where_clause;
/* If the where clause is not empty and begins with WHERE add a line break */
  ELSIF (l_where_clause IS NOT NULL) THEN
    l_where_clause := g_rtn || l_where_clause;
  END IF;

/* Put together the SQL statement for the table validated LOV */
  p_sql_stmt :=
'SELECT ' || l_distinct_clause || '
  ' || l_id_column_name    || '     id
, ' || l_value_column_name || '     value
, hr_general.start_of_time   effective_start_date
, hr_general.end_of_time     effective_end_date
, ''1'' || ' || l_value_column_name || '     order_by
FROM ' ||
 l_from_clause ||
 l_where_clause;

END get_table_value_set_sql;

/******************************************************************************/
/* Formats the sql for a dependent/independent value set                      */
/******************************************************************************/
PROCEDURE get_flex_value_set_sql
  (p_flex_value_set_id     IN fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_sql_stmt              OUT NOCOPY VARCHAR2
  ,p_distinct_flag         IN VARCHAR2) IS

  l_distinct_clause      VARCHAR2(30);

BEGIN

/* Bug 3387576 - Add distinct to lov sql if required */
  IF (p_distinct_flag = 'Y') THEN
    l_distinct_clause := 'DISTINCT ';
  END IF;

/* Put together the SQL statement for the flex value set */
  p_sql_stmt :=
'SELECT ' || l_distinct_clause || '
 tab.flex_value          id
,tab.flex_value_meaning  value
,NVL(tab.start_date_active, hr_general.start_of_time)
                         effective_start_date
, NVL(tab.end_date_active, hr_general.end_of_time)
                         effective_end_date
,''1'' || tab.flex_value_meaning  order_by
FROM fnd_flex_values_vl tab
WHERE tab.flex_value_set_id = ' || to_char(p_flex_value_set_id) || '
AND tab.enabled_flag = ''Y''';

END get_flex_value_set_sql;

/******************************************************************************/
/* PUBLIC SECTION                                                             */
/******************************************************************************/

/******************************************************************************/
/* Returns sql to be used to create a lov based on a value set               */
/******************************************************************************/
PROCEDURE get_value_set_lov_sql
    (p_flex_value_set_id   IN  fnd_flex_value_sets.flex_value_set_id%TYPE
    ,p_sql_stmt            OUT NOCOPY VARCHAR2
    ,p_distinct_flag       IN  VARCHAR2) IS

/* Get the value set details */
  CURSOR csr_value_sets IS
  SELECT fvs.validation_type
  FROM fnd_flex_value_sets fvs
  WHERE fvs.flex_value_set_id = p_flex_value_set_id;

  l_flex_validation_type  VARCHAR2(30);
  l_sql_stmt              VARCHAR2(4000);

BEGIN

  OPEN csr_value_sets;
  FETCH csr_value_sets INTO l_flex_validation_type;
  CLOSE csr_value_sets;

/* Get details based on validation type */
  IF (l_flex_validation_type = 'F') THEN
    get_table_value_set_sql
      (p_flex_value_set_id   => p_flex_value_set_id
      ,p_sql_stmt => p_sql_stmt
      ,p_distinct_flag => p_distinct_flag);
  ELSIF (l_flex_validation_type IN ('I','X','D','Y')) THEN
    get_flex_value_set_sql
      (p_flex_value_set_id   => p_flex_value_set_id
      ,p_sql_stmt => p_sql_stmt
      ,p_distinct_flag => p_distinct_flag);
  END IF;

END get_value_set_lov_sql;

END hri_bpl_flex;

/
