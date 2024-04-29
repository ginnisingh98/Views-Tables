--------------------------------------------------------
--  DDL for Package Body EDW_BSC_BRIDGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_BSC_BRIDGE" AS
/* $Header: EDWBSCB.pls 115.14 2004/02/13 05:01:13 smulye noship $ */
e_DynamicSqlStmtErr  EXCEPTION;
TYPE t_FactMeasure IS RECORD (
  measure_name EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE,
  measure_id   EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE
);

TYPE FactDimColTable IS TABLE of
  EDW_FACT_DIM_RELATIONS_MD_V.FACT_FK_COL_NAME%TYPE
  INDEX BY BINARY_INTEGER;

TYPE FactMeasureTable IS TABLE of
  t_FactMeasure
  INDEX BY BINARY_INTEGER;

TYPE t_Fact IS RECORD (
  fact_id     EDW_FACTS_MD_V.FACT_ID%TYPE,
  fact_name   EDW_FACTS_MD_V.FACT_NAME%TYPE
);

TYPE FactTable IS TABLE of
  t_Fact
  INDEX BY BINARY_INTEGER;


NOTVALID       constant VARCHAR2(30) := 'NOT_VALID';
VALID          constant VARCHAR2(30) := 'VALID';
NOSYNONYM      constant VARCHAR2(30) := 'VALID_WITHOUT_SYNONYM';
STARTED        constant VARCHAR2(30) := 'Started';
FAILED         constant VARCHAR2(30) := 'Failed';
PROCESSING     constant VARCHAR2(30) := 'Processing';
PROCESSED      constant VARCHAR2(30) := 'Processed';
DONE           constant VARCHAR2(30) := 'Done';
ABORTED        constant VARCHAR2(30) := 'Aborted';
SQLERR         constant VARCHAR2(30) := 'Sql Error';
EXECUTING      constant VARCHAR2(30) := 'Executing';
EXECUTED       constant VARCHAR2(30) := 'Executed';
SCRIPTING      constant VARCHAR2(30) := 'Scripting';
SCRIPTED       constant VARCHAR2(30) := 'Scripted';
DEBUG          constant VARCHAR2(30) := 'Debug';
-- Cache the EDW_TIME_M Dimsension ID.
v_time_dimension_id EDW_DIMENSIONS_MD_V.DIM_NAME%TYPE  := NULL;
v_fact_id           EDW_FACTS_MD_V.FACT_ID%TYPE        := NULL;
v_fact_name         EDW_FACTS_MD_V.FACT_NAME%TYPE      := NULL;

CURSOR dim_id(
  p_object_name EDW_DIMENSIONS_MD_V.DIM_NAME%TYPE
) IS
SELECT DIM_ID
FROM EDW_DIMENSIONS_MD_V
WHERE DIM_NAME = p_object_name;

CURSOR c_fact IS
SELECT
     FACT_ID
   , FACT_NAME
FROM EDW_FACTS_MD_V;

CURSOR c_factid (
  p_fact_name        EDW_FACTS_MD_V.FACT_NAME%TYPE
)IS
SELECT
    FACT_ID
FROM EDW_FACTS_MD_V
WHERE FACT_NAME = p_fact_name;

CURSOR c_time_hier_id(
  p_hier_prefix       EDW_HIERARCHIES_MD_V.HIER_PREFIX%TYPE
) IS
SELECT HIER_ID
FROM EDW_HIERARCHIES_MD_V
WHERE
 DIM_ID = v_time_dimension_id
AND HIER_PREFIX = p_hier_prefix;

--excuted once per fact, no need for tuning
CURSOR c_facttimedimcol(p_fact_name EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE) IS
SELECT
  FACT_FK_COL_NAME
FROM EDW_FACT_DIM_RELATIONS_MD_V
WHERE
    DIM_ID = v_time_dimension_id
    -- use the cached id for better performance,
    -- it is instanciated at the intialization.
AND FACT_NAME = p_fact_name;


--excuted once per fact, no need for tuning
CURSOR c_factnontimedimcol(p_fact_name EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE) IS
SELECT
  FACT_FK_COL_NAME
FROM EDW_FACT_DIM_RELATIONS_MD_V
WHERE
    DIM_ID <> v_time_dimension_id
    -- use the cached id for better performance,
    -- it is instanciated at the intialization.
AND FACT_NAME = p_fact_name;

--excuted once per fact, no need for tuning
CURSOR c_factmeasure(p_fact_name EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE) IS
SELECT
  ATTRIBUTE_ID ,
  ATTRIBUTE_NAME
FROM EDW_FACT_ATTRIBUTES_MD_V
WHERE FACT_NAME = p_fact_name
AND ATTRIBUTE_TYPE = 'MEASURE';


--excuted once per fact, no need for tuning
CURSOR c_factmeasure_id(
  p_fact_name EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_measure_name EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE
) IS
SELECT
  ATTRIBUTE_ID
FROM EDW_FACT_ATTRIBUTES_MD_V
WHERE
    FACT_NAME = p_fact_name
AND ATTRIBUTE_NAME = p_measure_name
AND ATTRIBUTE_TYPE = 'MEASURE';


CURSOR c_factvalidity_t(
  p_fact_name     EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)IS
SELECT
  object_name
FROM
  user_objects
WHERE
    object_name = UPPER(p_fact_name)
AND object_type = 'TABLE';

CURSOR c_factvalidity_s(
  p_fact_name     EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)IS
SELECT
  object_name
FROM
  user_objects
WHERE
    object_name = UPPER(p_fact_name)
AND object_type = 'SYNONYM';

/*
CHANGES FOR BUG 3431744 BY AMITGUPT
*/
CURSOR c_att_validity (
  p_tbl_name ALL_TAB_COLUMNS.TABLE_NAME%TYPE ,
  p_col_name ALL_TAB_COLUMNS.COLUMN_NAME%TYPE) IS
SELECT
  COUNT(TAB.COLUMN_NAME)
FROM
  ALL_TAB_COLUMNS TAB, USER_SYNONYMS SYN
WHERE
    TAB.TABLE_NAME = UPPER(p_tbl_name) AND
    SYN.TABLE_NAME = TAB.TABLE_NAME  AND
    SYN.TABLE_OWNER = TAB.OWNER AND
    TAB.COLUMN_NAME = UPPER(p_col_name);


v_445_id            EDW_HIERARCHIES_MD_V.HIER_ID%TYPE := NULL;
v_pa_id             EDW_HIERARCHIES_MD_V.HIER_ID%TYPE := NULL;
v_gl_id             EDW_HIERARCHIES_MD_V.HIER_ID%TYPE := NULL;
v_enterprise_id     EDW_HIERARCHIES_MD_V.HIER_ID%TYPE := NULL;
v_gregerion_id      EDW_HIERARCHIES_MD_V.HIER_ID%TYPE := NULL;



FUNCTION GET_DIM_ID(
  p_object_name EDW_DIMENSIONS_MD_V.DIM_NAME%TYPE
) RETURN EDW_DIMENSIONS_MD_V.DIM_ID%TYPE;

FUNCTION GET_TIME_ID RETURN EDW_DIMENSIONS_MD_V.DIM_ID%TYPE;

PROCEDURE INITIALIZE;

PROCEDURE FINALIZE;

PROCEDURE LOG(
    p_code              EDW_CALSUM4_BSC_LOG.CODE%TYPE
  , p_text              EDW_CALSUM4_BSC_LOG.TEXT%TYPE
  , p_info              EDW_CALSUM4_BSC_LOG.INFO%TYPE
);

FUNCTION GET_FACT_ID(
   p_fact_name IN EDW_FACTS_MD_V.FACT_NAME%TYPE
) RETURN EDW_FACTS_MD_V.FACT_ID%TYPE;

FUNCTION CHECK_VALIDILITY(
  p_tbl_name ALL_TAB_COLUMNS.TABLE_NAME%TYPE ,
  p_col_name ALL_TAB_COLUMNS.COLUMN_NAME%TYPE)
RETURN BOOLEAN;

FUNCTION CHECK_FACT_VALIDILITY(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
) RETURN VARCHAR2;

FUNCTION GET_FACT_MEASURE(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)RETURN FactMeasureTable;

FUNCTION GET_FACT_TIME_DIM_COL(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)RETURN FactDimColTable;

FUNCTION GET_FACT_NONTIME_DIM_COL(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)RETURN FactDimColTable;

FUNCTION GET_SQL_STMT(
  p_fact_id                 IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name               IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_fact_time_dim_table     IN FactDimColTable,
  p_fact_nontime_dim_table  IN FactDimColTable,
  p_fact_measure            IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE,
  p_fact_measure_id         IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE,
  p_hier                    IN VARCHAR
)RETURN VARCHAR2;


PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
);

PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_name    IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_measure_name IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE
);

PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_id   IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
);

PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_id                 IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name               IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_fact_time_dim_table     IN FactDimColTable,
  p_fact_nontime_dim_table  IN FactDimColTable,
  p_fact_measure            IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE,
  p_fact_measure_id         IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE
);


PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_id            IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name          IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_fact_measure_table IN FactMeasureTable
);

FUNCTION GET_FACT_MEASURE_ID(
  p_fact_name EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_measure_name EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE
)RETURN NUMBER;

FUNCTION GET_HIER_ID(
  p_hier_prefix          IN EDW_HIERARCHIES_MD_V.HIER_PREFIX%TYPE
) RETURN NUMBER;

FUNCTION GET_TIME_HIER_ID(
  p_hier_prefix          IN EDW_HIERARCHIES_MD_V.HIER_PREFIX%TYPE
) RETURN NUMBER;

--Kernal Entries
-- #1.1
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
   errbuf   OUT NOCOPY VARCHAR2,
   retcode  OUT NOCOPY NUMBER
) IS
  l_fact_id     EDW_FACTS_MD_V.FACT_ID%TYPE;
  l_fact        EDW_FACTS_MD_V.FACT_NAME%TYPE;
  l_fact_tbl    FactTable;
  l_fact_count  BINARY_INTEGER;
  l_fact_index  BINARY_INTEGER;
BEGIN
  INITIALIZE;
  --cache the fact information and close the cursor!
  l_fact_count := 0;
  OPEN c_fact;
  LOOP
    FETCH c_fact INTO l_fact_id, l_fact;
    EXIT WHEN c_fact%NOTFOUND;
    l_fact_tbl(l_fact_count).fact_id := l_fact_id;
    l_fact_tbl(l_fact_count).fact_name := l_fact;
    l_fact_count := l_fact_count + 1;
  END LOOP;
  CLOSE c_fact;

  --start processing fact by fact
  l_fact_index := l_fact_tbl.FIRST;
  LOOP
    POPULATE_EDW_CALSUM4_BSC(
      l_fact_tbl(l_fact_index).fact_id,
      l_fact_tbl(l_fact_index).fact_name);
    EXIT WHEN l_fact_index = l_fact_tbl.LAST;
    l_fact_index := l_fact_tbl.NEXT(l_fact_index);
  END LOOP;

  FINALIZE;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE c_fact;
      retcode := SQLCODE;
      errbuf := SQLERRM;
      LOG(retcode, SQLERR, errbuf);
      LOG(NULL, ABORTED, 'Process aborted!!');
END POPULATE_EDW_CALSUM4_BSC;

-- #1.2
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY NUMBER
) IS
BEGIN
  INITIALIZE;
  POPULATE_EDW_CALSUM4_BSC(p_fact_name);
  FINALIZE;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := SQLCODE;
      errbuf := SQLERRM;
      LOG(retcode, SQLERR, errbuf);
      LOG(NULL, ABORTED, 'Process aborted!!');
END POPULATE_EDW_CALSUM4_BSC;

-- #1.3
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_name    IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_measure_name IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE,
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY NUMBER
) IS
BEGIN
  INITIALIZE;
  POPULATE_EDW_CALSUM4_BSC(p_fact_name, p_measure_name);
  FINALIZE;
  EXCEPTION
    WHEN OTHERS THEN
      CLOSE c_fact;
      retcode := SQLCODE;
      errbuf := SQLERRM;
      LOG(retcode, SQLERR, errbuf);
      LOG(NULL, ABORTED, 'Process aborted!!');
END POPULATE_EDW_CALSUM4_BSC;
--Kernal Entries

-- Second Level Procedures
-- #2.1 : Called by Entry #1.1
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_id   IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
) IS
  l_fact_measure_table       FactMeasureTable;

BEGIN
  IF(CHECK_FACT_VALIDILITY(p_fact_name) <> VALID) THEN
    RETURN ;
  ELSE
    l_fact_measure_table:= GET_FACT_MEASURE(p_fact_name);
    POPULATE_EDW_CALSUM4_BSC(p_fact_id, p_fact_name, l_fact_measure_table);
  END IF;
END POPULATE_EDW_CALSUM4_BSC;

-- #2.2 : Called by Entry #1.2
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
) IS
  l_fact_measure_table       FactMeasureTable;
  l_fact_id                  EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE;
BEGIN
  IF(CHECK_FACT_VALIDILITY(p_fact_name) <> VALID) THEN
    RETURN ;
  ELSE
    l_fact_id := GET_FACT_ID(p_fact_name);
    l_fact_measure_table:= GET_FACT_MEASURE(p_fact_name);
    POPULATE_EDW_CALSUM4_BSC(l_fact_id, p_fact_name, l_fact_measure_table);
  END IF;
END POPULATE_EDW_CALSUM4_BSC;

-- #2.3 : Called by Entry #1.3
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_name    IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_measure_name IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE
) IS
  l_fact_id                  EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE;
  l_measure_id               EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE;
  l_fact_measure_table       FactMeasureTable;
BEGIN
  IF( CHECK_FACT_VALIDILITY(p_fact_name) <> VALID) THEN
    RETURN;
  ELSIF( CHECK_VALIDILITY( p_fact_name, p_measure_name)) THEN
    l_fact_id := GET_FACT_ID(p_fact_name);
    l_measure_id := GET_FACT_MEASURE_ID(p_fact_name, p_measure_name);

    -- create a one item measure-table
    l_fact_measure_table(0).measure_name := p_measure_name;
    l_fact_measure_table(0).measure_id := l_measure_id;
    POPULATE_EDW_CALSUM4_BSC(l_fact_id, p_fact_name, l_fact_measure_table);
  ELSE
    LOG(NULL, FAILED , '  Corrupted metadata definition, ' || p_measure_name || ', in ' || p_fact_name);
    RETURN ;
  END IF;
END POPULATE_EDW_CALSUM4_BSC;

-- Third Level Procedures
-- #3.1 : called by #2.1, #2.2 & #2.3
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_id             IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name           IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_fact_measure_table  IN FactMeasureTable
) IS
  l_fact_measure         EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE;
  l_measure_index        BINARY_INTEGER;
  l_fact_time_dim_table  FactDimColTable;
  l_fact_nontime_dim_table  FactDimColTable;
BEGIN
  l_fact_time_dim_table := GET_FACT_TIME_DIM_COL(p_fact_name);
  l_fact_nontime_dim_table := GET_FACT_NONTIME_DIM_COL(p_fact_name);
  -- Don't do anything if no time dimension or no measures
  -- Otherwise, the dynamic sql statement will be errered out
  IF (    l_fact_time_dim_table.COUNT > 0
      AND p_fact_measure_table.COUNT > 0)  THEN
    l_measure_index := p_fact_measure_table.FIRST;
    LOOP
      POPULATE_EDW_CALSUM4_BSC(
        p_fact_id,
        p_fact_name,
        l_fact_time_dim_table,
        l_fact_nontime_dim_table,
        p_fact_measure_table(l_measure_index).measure_name,
        p_fact_measure_table(l_measure_index).measure_id);
      COMMIT;
      EXIT WHEN l_measure_index = p_fact_measure_table.LAST;
      l_measure_index := p_fact_measure_table.NEXT(l_measure_index);
    END LOOP;
  ELSE
    LOG(NULL, FAILED, '  No measure or time dimension defined for the fact '|| p_fact_name);
  END IF;
END POPULATE_EDW_CALSUM4_BSC;

-- The Fourth Level Procedure
-- #4.1 : Called by #3.1
PROCEDURE POPULATE_EDW_CALSUM4_BSC(
  p_fact_id                 IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name               IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_fact_time_dim_table     IN FactDimColTable,
  p_fact_nontime_dim_table  IN FactDimColTable,
  p_fact_measure            IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE,
  p_fact_measure_id         IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE
) IS
   l_calsum_stmt     varchar2(30000) := NULL;
   l_calsum          varchar2(100);
   l_sumid           EDW_CALSUM4_BSC.CALSUM_ID%TYPE;
   l_hier            varchar2(50);
   l_hier_id         EDW_CALSUM4_BSC.HIERID%TYPE;
   l_ErrorCode       EDW_CALSUM4_BSC_LOG.CODE%TYPE;
   l_ErrorText       EDW_CALSUM4_BSC_LOG.TEXT%TYPE;
   l_fact_dim_index  BINARY_INTEGER;
   l_err_info        EDW_CALSUM4_BSC_LOG.INFO%TYPE;
BEGIN
  LOG(NULL, PROCESSING, '->Fact: ' || p_fact_name || ', ' || 'Measure: ' || p_fact_measure);

  l_calsum_stmt := GET_SQL_STMT(p_fact_id, p_fact_name, p_fact_time_dim_table, p_fact_nontime_dim_table, p_fact_measure, p_fact_measure_id, '445');
  LOG(NULL, EXECUTING, '445------------------------------------------>');
  EXECUTE IMMEDIATE l_calsum_stmt;
  LOG(NULL, EXECUTED, '445<------------------------------------------');


  l_calsum_stmt := GET_SQL_STMT(p_fact_id, p_fact_name, p_fact_time_dim_table, p_fact_nontime_dim_table, p_fact_measure, p_fact_measure_id, 'PA');
  LOG(NULL, EXECUTING, 'PA------------------------------------------>');
  EXECUTE IMMEDIATE l_calsum_stmt;
  LOG(NULL, EXECUTED, 'PA<------------------------------------------');

  l_calsum_stmt := GET_SQL_STMT(p_fact_id, p_fact_name, p_fact_time_dim_table, p_fact_nontime_dim_table, p_fact_measure, p_fact_measure_id, 'GL');
  LOG(NULL, EXECUTING, 'GL------------------------------------------>');
  EXECUTE IMMEDIATE l_calsum_stmt;
  LOG(NULL, EXECUTED, 'GL<------------------------------------------');

  l_calsum_stmt := GET_SQL_STMT(p_fact_id, p_fact_name, p_fact_time_dim_table, p_fact_nontime_dim_table, p_fact_measure, p_fact_measure_id, 'GREGERION');
  LOG(NULL, EXECUTING, 'GREGERION------------------------------------------>');
  EXECUTE IMMEDIATE l_calsum_stmt;
  LOG(NULL, EXECUTED, 'GREGERION<------------------------------------------');

  l_calsum_stmt := GET_SQL_STMT(p_fact_id, p_fact_name, p_fact_time_dim_table, p_fact_nontime_dim_table, p_fact_measure, p_fact_measure_id, 'ENTERPRISE');
  LOG(NULL, EXECUTING, 'ENTERPRISE------------------------------------------>');
  EXECUTE IMMEDIATE l_calsum_stmt;
  LOG(NULL, EXECUTED, 'ENTERPRISE<------------------------------------------');

  LOG(NULL, PROCESSED, '<-Fact: ' || p_fact_name || ', ' || 'Measure: ' || p_fact_measure);
  EXCEPTION
    WHEN e_DynamicSqlStmtErr THEN
      LOG(NULL, FAILED, '<-Fact: ' || p_fact_name || ', ' || 'Measure: ' || p_fact_measure);
    WHEN OTHERS THEN
      l_ErrorCode := SQLCODE;
      l_ErrorText := SQLERRM;
      l_err_info  := p_fact_measure;
      l_fact_dim_index := p_fact_time_dim_table.FIRST;
      LOOP
        l_err_info := l_err_info || ', '|| p_fact_time_dim_table(l_fact_dim_index);
        EXIT WHEN l_fact_dim_index = p_fact_time_dim_table.LAST;
        l_fact_dim_index := p_fact_time_dim_table.NEXT(l_fact_dim_index);
      END LOOP;
      l_err_info := l_err_info || ' might not be defined/valid in ' || p_fact_name;
      LOG(l_ErrorCode, l_ErrorText, l_err_info);
      LOG(NULL, FAILED, '<-Fact: ' || p_fact_name || ', ' || 'Measure: ' || p_fact_measure);
END POPULATE_EDW_CALSUM4_BSC;

FUNCTION GET_FACT_MEASURE_ID(
  p_fact_name EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_measure_name EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE
)RETURN NUMBER IS
  l_measure_id               EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE;
BEGIN
  OPEN c_factmeasure_id(p_fact_name, p_measure_name);
  FETCH c_factmeasure_id INTO l_measure_id;
  CLOSE c_factmeasure_id;
  RETURN l_measure_id;
END GET_FACT_MEASURE_ID;

FUNCTION GET_FACT_MEASURE(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)RETURN FactMeasureTable IS
  l_measure_id               EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE;
  l_measure                  EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE;
  l_fact_measure_table       FactMeasureTable;
  l_fact_measure_table_count BINARY_INTEGER;
BEGIN
  l_fact_measure_table_count := 0;
  OPEN c_factmeasure(p_fact_name);
  LOOP
    FETCH c_factmeasure INTO l_measure_id, l_measure;
    EXIT WHEN c_factmeasure%NOTFOUND;
    IF (CHECK_VALIDILITY( p_fact_name, l_measure)) THEN
      l_fact_measure_table(l_fact_measure_table_count).measure_name := l_measure;
      l_fact_measure_table(l_fact_measure_table_count).measure_id := l_measure_id;
      l_fact_measure_table_count := l_fact_measure_table_count + 1;
    ELSE
      LOG(NULL, FAILED, '  Corrupted metadata definition, ' || l_measure || ', in ' || p_fact_name);
    END IF;
  END LOOP;
  CLOSE c_factmeasure;
  RETURN l_fact_measure_table;
END GET_FACT_MEASURE;

FUNCTION GET_FACT_TIME_DIM_COL(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)RETURN FactDimColTable IS
  l_fact_time_dim              EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE;
  l_fact_time_dim_table        FactDimColTable;
  l_fact_time_dim_table_count  BINARY_INTEGER;
BEGIN
  l_fact_time_dim_table_count := 0;
  OPEN c_facttimedimcol(p_fact_name);
  LOOP
    FETCH c_facttimedimcol INTO l_fact_time_dim;
    EXIT WHEN c_facttimedimcol%NOTFOUND;
    IF (CHECK_VALIDILITY( p_fact_name, l_fact_time_dim)) THEN
      l_fact_time_dim_table(l_fact_time_dim_table_count) := l_fact_time_dim;
      l_fact_time_dim_table_count := l_fact_time_dim_table_count + 1;
    ELSE
      LOG(NULL, FAILED, '  Corrupted metadata definition, ' || l_fact_time_dim || ', in ' || p_fact_name);
    END IF;
  END LOOP;
  CLOSE c_facttimedimcol;
  RETURN l_fact_time_dim_table;
END GET_FACT_TIME_DIM_COL;


FUNCTION GET_FACT_NONTIME_DIM_COL(
  p_fact_name IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
)RETURN FactDimColTable IS
  l_fact_nontime_dim              EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE;
  l_fact_nontime_dim_table        FactDimColTable;
  l_fact_nontime_dim_table_count  BINARY_INTEGER;
BEGIN
  l_fact_nontime_dim_table_count := 0;
  OPEN c_factnontimedimcol(p_fact_name);
  LOOP
    FETCH c_factnontimedimcol INTO l_fact_nontime_dim;
    EXIT WHEN c_factnontimedimcol%NOTFOUND;
    IF (CHECK_VALIDILITY( p_fact_name, l_fact_nontime_dim)) THEN
      l_fact_nontime_dim_table(l_fact_nontime_dim_table_count) := l_fact_nontime_dim;
      l_fact_nontime_dim_table_count := l_fact_nontime_dim_table_count + 1;
    ELSE
      LOG(NULL, FAILED, '  Corrupted metadata definition, ' || l_fact_nontime_dim || ', in ' || p_fact_name);
    END IF;
  END LOOP;
  CLOSE c_factnontimedimcol;
  RETURN l_fact_nontime_dim_table;
END GET_FACT_NONTIME_DIM_COL;

/*
FUNCTION GET_USER_INFO
RETURN VARCHAR2 IS
  l_usrname   USER_USERS.USERNAME%TYPE;
  CURSOR c_userinfo IS
  SELECT
    USERNAME
   FROM USER_USERS;
BEGIN
  OPEN c_userinfo;
  FETCH c_userinfo INTO l_usrname;
  CLOSE c_userinfo;
  RETURN l_usrname;
END GET_USER_INFO;
*/

FUNCTION CHECK_FACT_VALIDILITY(
  p_fact_name          IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE
) RETURN VARCHAR2 IS
  l_object              USER_OBJECTS.OBJECT_NAME%TYPE := NULL;
BEGIN
  OPEN c_factvalidity_t(p_fact_name);
  FETCH c_factvalidity_t INTO l_object;
  CLOSE c_factvalidity_t;

  IF (l_object IS NULL) THEN
    LOG(NULL, FAILED, '  Table ' || p_fact_name || ' is not accessible or not defined');
    RETURN NOTVALID;
  ELSE
    l_object := null;
    OPEN c_factvalidity_s(p_fact_name);
    FETCH c_factvalidity_s INTO l_object;
    CLOSE c_factvalidity_s;
    IF(l_object IS NOT NULL  )THEN
      RETURN VALID;
    ELSE
      LOG(NULL, FAILED, '  No synonym defined for Table ' || p_fact_name);
      RETURN NOSYNONYM;
    END IF;
  END IF;
END;

PROCEDURE LOG(
    p_code              EDW_CALSUM4_BSC_LOG.CODE%TYPE
  , p_text              EDW_CALSUM4_BSC_LOG.TEXT%TYPE
  , p_info              EDW_CALSUM4_BSC_LOG.INFO%TYPE
) IS
BEGIN
  INSERT INTO EDW_CALSUM4_BSC_LOG(CODE, TEXT, INFO, LAST_UPDATE_DATE, CREATION_DATE)
    VALUES(p_code, p_text, p_info, SYSDATE, SYSDATE);
  COMMIT;
END LOG;


FUNCTION GET_SQL_STMT(
  p_fact_id                IN EDW_FACT_ATTRIBUTES_MD_V.FACT_ID%TYPE,
  p_fact_name              IN EDW_FACT_ATTRIBUTES_MD_V.FACT_NAME%TYPE,
  p_fact_time_dim_table    IN FactDimColTable,
  p_fact_nontime_dim_table IN FactDimColTable,
  p_fact_measure           IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_NAME%TYPE,
  p_fact_measure_id        IN EDW_FACT_ATTRIBUTES_MD_V.ATTRIBUTE_ID%TYPE,
  p_hier                   IN VARCHAR
) RETURN VARCHAR2 IS
  l_calsum_stmt_psudo         VARCHAR2(1000)  := NULL;
  l_calsum_stmt               VARCHAR2(30000) := NULL;
  l_calsum_stmt_tmp           VARCHAR2(4000)  := NULL;
  l_calsum_fromwhere_clause   VARCHAR2(30000) := NULL;
  l_ErrorCode       EDW_CALSUM4_BSC_LOG.CODE%TYPE;
  l_ErrorText       EDW_CALSUM4_BSC_LOG.TEXT%TYPE;
  l_err_info        EDW_CALSUM4_BSC_LOG.INFO%TYPE;
  l_fact_dim_index  BINARY_INTEGER;
  l_start           BINARY_INTEGER;
BEGIN

  LOG(NULL, SCRIPTING, '-->Statement generating for ' || p_hier );
  l_calsum_fromwhere_clause :=
  ' FROM '|| p_fact_name  || ' FACT, '||
  '  EDW_TIME_M DIM '||
  'WHERE '||
  'FACT.'||p_fact_measure || ' IS NOT NULL ' ||
  'AND DIM.CDAY_CAL_DAY_PK_KEY != 0 ' ||
  'AND ( DIM.CDAY_CAL_DAY_PK_KEY = FACT.';

  l_fact_dim_index := p_fact_time_dim_table.FIRST;
  l_start := p_fact_time_dim_table.FIRST;
  LOOP
    IF(l_fact_dim_index = l_start) THEN
      l_calsum_fromwhere_clause := l_calsum_fromwhere_clause || p_fact_time_dim_table(l_fact_dim_index);
    ELSE
      l_calsum_fromwhere_clause := l_calsum_fromwhere_clause ||
      ' OR DIM.CDAY_CAL_DAY_PK_KEY = FACT.' || p_fact_time_dim_table(l_fact_dim_index);
    END IF;
    EXIT WHEN l_fact_dim_index = p_fact_time_dim_table.LAST;
    l_fact_dim_index := p_fact_time_dim_table.NEXT(l_fact_dim_index);
  END LOOP;
  l_calsum_fromwhere_clause := l_calsum_fromwhere_clause || ' )';

  IF (p_fact_nontime_dim_table.COUNT > 0 ) THEN
    l_calsum_fromwhere_clause := l_calsum_fromwhere_clause || ' AND (';
  END IF;

  l_fact_dim_index := p_fact_nontime_dim_table.FIRST;
  l_start := p_fact_nontime_dim_table.FIRST;
  LOOP
    IF(l_fact_dim_index = l_start ) THEN
      l_calsum_fromwhere_clause := l_calsum_fromwhere_clause || ' FACT. ' || p_fact_nontime_dim_table(l_fact_dim_index) || ' <> 0 ';
    ELSE
      l_calsum_fromwhere_clause := l_calsum_fromwhere_clause || ' OR FACT. ' || p_fact_nontime_dim_table(l_fact_dim_index) || ' <> 0 ';
    END IF;
    EXIT WHEN l_fact_dim_index = p_fact_nontime_dim_table.LAST;
    l_fact_dim_index := p_fact_nontime_dim_table.NEXT(l_fact_dim_index);
  END LOOP;
  l_calsum_fromwhere_clause := l_calsum_fromwhere_clause || ' )';

  l_calsum_stmt_psudo := ' ''' || p_fact_name || ''', '  || p_fact_id || ', '''|| p_fact_measure || ''', ' || p_fact_measure_id || ', ';

  l_calsum_stmt_tmp :=
    'INSERT INTO EDW_CALSUM4_BSC(FACT, FACT_ID, MEASURE, MEASURE_ID, TIMEHIER, HIERID, CALSUMMARY, CALSUM_ID, LAST_UPDATE_DATE, CREATION_DATE) ';
  l_calsum_stmt := l_calsum_stmt_tmp;

  IF(p_hier = '445') THEN
    l_calsum_stmt_tmp :=
    'SELECT DISTINCT'
    || l_calsum_stmt_psudo
    || '''445'''        || ', '
    || GET_TIME_HIER_ID('TIME45')
    || ', DIM.P445_NAME '
    || ', DIM.P445_PERIOD_445_PK_KEY, SYSDATE, SYSDATE'
    || l_calsum_fromwhere_clause
    || ' AND DIM.P445_PERIOD_445_PK_KEY IS NOT NULL'
    || ' AND DIM.P445_PERIOD_445_PK_KEY != 0 '
    || ' AND DIM.P445_PERIOD_445_PK_KEY != -1 ';
    l_calsum_stmt := l_calsum_stmt || l_calsum_stmt_tmp;
  ELSIF (p_hier = 'PA') THEN
    l_calsum_stmt_tmp :=
    'SELECT DISTINCT'
    || l_calsum_stmt_psudo
    || '''PA'''         || ', '
    || GET_TIME_HIER_ID('TIMEPA')
    || ', DIM.CNAM_CAL_NAME '
    || ', DIM.CNAM_CAL_NAME_PK_KEY  , SYSDATE, SYSDATE'
    || l_calsum_fromwhere_clause
    || ' AND DIM.PPER_PA_PERIOD_PK_KEY IS NOT NULL'
    || ' AND DIM.CNAM_CAL_NAME_PK_KEY IS NOT NULL'
    || ' AND DIM.CNAM_CAL_NAME_PK_KEY != 0 '
    || ' AND DIM.CNAM_CAL_NAME_PK_KEY != -1 ';
    l_calsum_stmt := l_calsum_stmt || l_calsum_stmt_tmp;
  ELSIF (p_hier = 'GL') THEN
    l_calsum_stmt_tmp :=
    'SELECT DISTINCT'
    || l_calsum_stmt_psudo
    || '''GL'''         || ', '
    || GET_TIME_HIER_ID('TIMEGL')
    || ', DIM.CNAM_CAL_NAME '
    || ', DIM.CNAM_CAL_NAME_PK_KEY  , SYSDATE, SYSDATE'
    || l_calsum_fromwhere_clause
    || ' AND DIM.CNAM_CAL_NAME_PK_KEY IS NOT NULL'
    || ' AND DIM.CNAM_CAL_NAME_PK_KEY != 0 '
    || ' AND DIM.CNAM_CAL_NAME_PK_KEY != -1 ';
    l_calsum_stmt := l_calsum_stmt || l_calsum_stmt_tmp;
  ELSIF (p_hier = 'GREGERION') THEN
    l_calsum_stmt_tmp :=
    'SELECT DISTINCT'
    || l_calsum_stmt_psudo
    || '''GREGERION'''  || ', '
    || GET_TIME_HIER_ID('TIMEGR')
    || ', DIM.YEAR_NAME '
    || ', DIM.YEAR_YEAR_PK_KEY , SYSDATE, SYSDATE'
    || l_calsum_fromwhere_clause
    || ' AND DIM.YEAR_YEAR_PK_KEY IS NOT NULL'
    || ' AND DIM.YEAR_YEAR_PK_KEY != 0 '
    || ' AND DIM.YEAR_YEAR_PK_KEY != -1 ';
    l_calsum_stmt := l_calsum_stmt || l_calsum_stmt_tmp;
  ELSIF (p_hier = 'ENTERPRISE') THEN
    l_calsum_stmt_tmp :=
    'SELECT DISTINCT'
    || l_calsum_stmt_psudo
    || '''ENTERPRISE''' || ', '
    || GET_TIME_HIER_ID('TIMEEP')
    || ', DIM.ECNM_CAL_NAME '
    || ', DIM.ECNM_CAL_NAME_PK_KEY  , SYSDATE, SYSDATE'
    || l_calsum_fromwhere_clause
    || ' AND DIM.ECNM_CAL_NAME_PK_KEY IS NOT NULL'
    || ' AND DIM.ECNM_CAL_NAME_PK_KEY != 0 '
    || ' AND DIM.ECNM_CAL_NAME_PK_KEY != -1 ';
    l_calsum_stmt := l_calsum_stmt || l_calsum_stmt_tmp;
  END IF;
  LOG(NULL, DEBUG, '---->' || l_calsum_stmt);
  LOG(NULL, SCRIPTED, '<--Statement generated for ' || p_hier );
  RETURN l_calsum_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      l_ErrorCode := SQLCODE;
      l_ErrorText := SQLERRM;
      l_err_info  := 'Error happened when scripting for ' || p_fact_measure || ' and ' || p_hier ;
      l_fact_dim_index := p_fact_time_dim_table.FIRST;
      LOOP
        l_err_info := l_err_info || ', '|| p_fact_time_dim_table(l_fact_dim_index);
        EXIT WHEN l_fact_dim_index = p_fact_time_dim_table.LAST;
        l_fact_dim_index := p_fact_time_dim_table.NEXT(l_fact_dim_index);
      END LOOP;
      l_err_info := l_err_info || ' in ' || p_fact_name;
      LOG(l_ErrorCode, l_ErrorText, l_err_info);
      LOG(NULL, FAILED, '<-Statement generating failed for Fact: ' || p_fact_name || ', ' || ' Measure: ' || p_fact_measure || ', Hier: ' || p_hier);
      RAISE e_DynamicSqlStmtErr;
END GET_SQL_STMT;


FUNCTION CHECK_VALIDILITY(
  p_tbl_name ALL_TAB_COLUMNS.TABLE_NAME%TYPE ,
  p_col_name ALL_TAB_COLUMNS.COLUMN_NAME%TYPE)
RETURN BOOLEAN IS
  l_count    NUMBER;
BEGIN
  OPEN c_att_validity( p_tbl_name , p_col_name);
  FETCH c_att_validity INTO l_count;
  CLOSE c_att_validity;
  IF(l_count =1 ) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END CHECK_VALIDILITY;

FUNCTION GET_DIM_ID(
  p_object_name EDW_DIMENSIONS_MD_V.DIM_NAME%TYPE
) RETURN EDW_DIMENSIONS_MD_V.DIM_ID%TYPE
IS
  l_id   EDW_DIMENSIONS_MD_V.DIM_ID%TYPE;
BEGIN
  OPEN dim_id(p_object_name);
  FETCH dim_id INTO l_id;
  CLOSE dim_id;
  RETURN l_id;
END GET_DIM_ID;

FUNCTION GET_TIME_ID
RETURN EDW_DIMENSIONS_MD_V.DIM_ID%TYPE
IS
BEGIN
  IF (v_time_dimension_id IS NULL) THEN
    v_time_dimension_id := GET_DIM_ID('EDW_TIME_M');
  END IF;
  RETURN v_time_dimension_id;
END GET_TIME_ID;

PROCEDURE INITIALIZE IS
BEGIN
  LOG(NULL, STARTED, 'Initializing, EDW_TIME_ID: ' || GET_TIME_ID);
END;

PROCEDURE FINALIZE IS
BEGIN
  LOG(NULL, DONE, 'EDW_CALSUM4_BSC table was populated successfully!');
END;

FUNCTION GET_FACT_ID(
   p_fact_name IN EDW_FACTS_MD_V.FACT_NAME%TYPE
) RETURN EDW_FACTS_MD_V.FACT_ID%TYPE IS
BEGIN
  IF(v_fact_name IS NULL OR  v_fact_name <> p_fact_name) THEN
    v_fact_name := p_fact_name;
    OPEN c_factid(p_fact_name);
    FETCH c_factid INTO v_fact_id;
    CLOSE c_factid;
  END IF;
  RETURN v_fact_id;
END GET_FACT_ID;


FUNCTION GET_TIME_HIER_ID(
  p_hier_prefix          IN EDW_HIERARCHIES_MD_V.HIER_PREFIX%TYPE
) RETURN NUMBER IS
BEGIN
  IF p_hier_prefix = 'TIME45' THEN
    IF v_445_id IS NOT NULL THEN
      RETURN v_445_id;
    ELSE
      v_445_id := GET_HIER_ID('TIME45');
      RETURN v_445_id;
    END IF;
  ELSIF p_hier_prefix = 'TIMEGL' THEN
    IF v_gl_id IS NOT NULL THEN
      RETURN v_gl_id;
    ELSE
      v_gl_id := GET_HIER_ID('TIMEGL');
      RETURN v_gl_id;
    END IF;
  ELSIF p_hier_prefix = 'TIMEPA' THEN
    IF v_pa_id IS NOT NULL THEN
      RETURN v_pa_id;
    ELSE
      v_pa_id := GET_HIER_ID('TIMEPA');
      RETURN v_pa_id;
    END IF;
  ELSIF p_hier_prefix = 'TIMEEP' THEN
    IF v_enterprise_id IS NOT NULL THEN
      RETURN v_enterprise_id;
    ELSE
      v_enterprise_id := GET_HIER_ID('TIMEEP');
      RETURN v_enterprise_id;
    END IF;
  ELSIF p_hier_prefix = 'TIMEGR' THEN
    IF v_gregerion_id IS NOT NULL THEN
      RETURN v_gregerion_id;
    ELSE
      v_gregerion_id := GET_HIER_ID('TIMEGR');
      RETURN v_gregerion_id;
    END IF;
  END IF;
END GET_TIME_HIER_ID;


FUNCTION GET_HIER_ID(
  p_hier_prefix          IN EDW_HIERARCHIES_MD_V.HIER_PREFIX%TYPE
) RETURN NUMBER IS
  l_hier_id    EDW_HIERARCHIES_MD_V.HIER_ID%TYPE;
BEGIN
  OPEN c_time_hier_id(p_hier_prefix);
  FETCH c_time_hier_id INTO l_hier_id;
  CLOSE c_time_hier_id;
  RETURN l_hier_id;
END GET_HIER_ID;

FUNCTION GET_LOWEST_LEVEL(
    p_dim  IN EDW_DIMENSIONS_MD_V.DIM_NAME%TYPE
) RETURN VARCHAR2 IS
  l_level_name EDW_DIMENSIONS_MD_V.DIM_NAME%TYPE;
BEGIN
  select level_name into l_level_name
  from edw_levels_md_v lvl
  where dim_name = p_dim
  and not exists(
  select 1 from
    edw_hierarchy_level_md_v hier
  where
       hier.dim_name = lvl.dim_name
  and  hier.parent_lvl_id = lvl.level_id);

  RETURN l_level_name;
END GET_LOWEST_LEVEL;

FUNCTION GET_LOWEST_LEVEL(
  p_dim_id IN NUMBER
) RETURN VARCHAR2 IS
  l_level_name EDW_LEVELS_MD_V.LEVEL_NAME%TYPE;
BEGIN
  select level_name into l_level_name
  from edw_levels_md_v lvl
  where dim_id = p_dim_id
  and not exists(
  select 1 from
    edw_hierarchy_level_md_v hier
  where
       hier.dim_name = lvl.dim_name
  and  hier.parent_lvl_id = lvl.level_id);

  RETURN l_level_name;
END GET_LOWEST_LEVEL;




END EDW_BSC_BRIDGE;

/
