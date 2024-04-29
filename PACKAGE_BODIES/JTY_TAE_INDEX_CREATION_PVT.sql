--------------------------------------------------------
--  DDL for Package Body JTY_TAE_INDEX_CREATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TAE_INDEX_CREATION_PVT" AS
/*$Header: jtfyaeib.pls 120.9.12010000.6 2009/08/11 06:42:44 vpalle ship $*/
/* --  ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:  jty_tae_index_creation_pvt
--    ---------------------------------------------------
--    PURPOSE
--      This package has public api to do the following :
--      a) return a list of column in order of selectivity
--      b) create index on interface tables
--      c) drop indexes on a table
--      d) analyze a table
--      e) truncate a table
--
--    PROCEDURES:
--         (see below for specification)
--
--    NOTES
--      This package is private available for use
--
--    HISTORY
--      06/13/2005    ACHANDA      Created
--
--    End of Comments
-- */

first_char_col_name varchar2(50) := 'SQUAL_FC01';

PROCEDURE jty_log(p_log_level IN NUMBER
			 ,p_module    IN VARCHAR2
			 ,p_message   IN VARCHAR2)
IS
pragma autonomous_transaction;
BEGIN
IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(p_log_level, p_module, p_message);
 commit;
END IF;
END;

/**
 * Procedure   :  Bubble_SORT
 * Type        :  Private
 * Pre_reqs    :
 * Description :  sort
 * Parameters  :
 * input parameters
 *      v_sele : array of data to be sort
 *      v_name : array of name associated with data
 *      numcol : number of data in array.
 * output parameters
 *      v_sele : array of sorted data
 *      v_name : array of name associated with sorted data
 */
PROCEDURE Bubble_SORT ( v_sele          IN OUT NOCOPY value_varray,
                        v_name          IN OUT NOCOPY name_varray,
                        std_dev         IN OUT NOCOPY value_varray,
                        flag            IN OUT NOCOPY value_varray,
                        numcol          IN     NUMBER,
                        x_return_status OUT    NOCOPY varchar2)
IS

  temp NUMBER;
  i    INTEGER;
  k    INTEGER;
  ch   VARCHAR2(30);

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.bubble_sort.start',
                   'Start of the procedure jty_tae_index_creation_pvt.bubble_sort ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- bubble sort
  FOR j in 1..numcol LOOP
    FOR i in 1..numcol-1 LOOP
      IF (v_sele(i) > v_sele(i+1)) THEN
        temp:= v_sele(i);
        v_sele(i) :=  v_sele(i+1);
        v_sele(i+1) := temp;
        ch:= v_name(i);
        v_name(i) :=  v_name(i+1);
        v_name(i+1) := ch;
        k:= std_dev(i);
        std_dev(i) := std_dev(i+1);
        std_dev(i+1) :=k;
        k:= flag(i);
        flag(i) := flag(i+1);
        flag(i+1) :=k;
      END IF;
    END LOOP;
  END LOOP;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.bubble_sort.end',
                   'End of the procedure jty_tae_index_creation_pvt.bubble_sort ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.bubble_sort.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END Bubble_SORT;


/**
 * Procedure   :  CAL_SELECTIVITY
 * Type        :  Private
 * Pre_reqs    :
 * Parameters  :
 * input
 *        p_table_name
 *        v_colname   : array of column name
 *        numcol      : number of name
 * output
 *        v_colname   : array of sorted column name by selectivity
 *        o_sel       : array of odinal selectivity
 *        std_dev     : array of standard deviation
 */
PROCEDURE CAL_SELECTIVITY( p_table_name    IN            varchar2,
                           v_colname       IN OUT NOCOPY name_varray,
                           o_sel           IN OUT NOCOPY value_varray,
                           std_dev         IN OUT NOCOPY value_varray,
                           flag            IN OUT NOCOPY value_varray,
                           numcol          IN            integer,
                           x_return_status OUT NOCOPY    varchar2)
IS

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  L_SCHEMA_NOTFOUND  EXCEPTION;

  v_cardinality   number;
  i               integer;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.start',
                   'Start of the procedure jty_tae_index_creation_pvt.cal_selectivity ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  /* Get the cardinality */
  SELECT NVL(dt.NUM_ROWS,1)
  INTO   v_cardinality
  FROM   dba_tables dt
  WHERE  dt.owner = l_jtf_schema
  AND    dt.table_name = p_table_name;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.cardinality',
                   'Number of rows for table ' || p_table_name || ' : ' || v_cardinality);

  IF v_cardinality = 0 THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.cardinality',
                     'API jty_tae_index_creation_pvt.cal_selectivity has failed as the number of rows in the table ' ||
                         p_table_name || ' is 0');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR i IN 1 ..numcol LOOP

    IF flag(i) = 1 THEN
      BEGIN
        SELECT 100 - (NVL(dtc.num_distinct,1)*100/v_cardinality)
        INTO   o_sel(i)
        FROM   dba_tab_columns dtc
        WHERE  dtc.owner = l_jtf_schema
        AND    dtc.table_name = UPPER(p_table_name)
        AND    dtc.column_name = UPPER(v_colname(i));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NUll;
      END;
    END IF;

  END LOOP;

  -- sort
  Bubble_SORT(o_sel, v_colname, std_dev ,flag, numcol, x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.bubble_sort',
                     'API jty_tae_index_creation_pvt.bubble_sort has failed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.end',
                   'End of the procedure jty_tae_index_creation_pvt.cal_selectivity ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.no_data_found',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.g_exc_error',
                     'jty_tae_index_creation_pvt.cal_selectivity has failed with G_EXC_ERROR exception');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.cal_selectivity.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END CAL_SELECTIVITY;

/**
 * Procedure   :  DEA_SELECTIVITY
 * Type        :  Private
 * Pre_reqs    :
 * Description :
 * Parameters  :
 * input  JTY_DEA_ATTR_FACTORS.SQUAL_ALIAS
 * outout JTY_DEA_ATTR_FACTORS.INPUT_SELECTIVITY         is populated with selectivity order
          JTY_DEA_ATTR_FACTORS.INPUT_ORDINAL_SELECTIVITY is populated with ordinal_selectivity
          JTY_DEA_ATTR_FACTORS.INPUT_DEVIATION           is populated with standard deviation
 */

PROCEDURE DEA_SELECTIVITY(p_TABLE_NAME    IN         VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)
IS

  -- SOLIN, Bug 5893926
  -- extend to 300 elements
  col_name name_varray :=   name_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  o_sel   value_varray :=  value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  std_dev value_varray :=  value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  sele    value_varray :=  value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  flag    value_varray :=  value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  i        integer;
  j        integer;

  CURSOR getColumnName IS
  SELECT DISTINCT
    A.TAE_COL_MAP                 sqname,
    A.INPUT_DEVIATION             dev,
    A.INPUT_ORDINAL_SELECTIVITY   ord_sele,
    A.INPUT_SELECTIVITY           sele,
    decode(A.UPDATE_SELECTIVITY_FLAG,'Y',1,0) flag
  FROM JTY_DEA_ATTR_FACTORS A
  WHERE A.USE_TAE_COL_IN_INDEX_FLAG = 'Y'
  AND A.TAE_COL_MAP is not null ;


BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.dea_selectivity.start',
                   'Start of the procedure jty_tae_index_creation_pvt.dea_selectivity ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  i := 1;
  j := 0;

  FOR qual_info in getColumnName LOOP
    col_name(i) := qual_info.sqname;
    o_sel(i)    := qual_info.ord_sele;
    std_dev(i)  := qual_info.dev;
    flag(i)     := qual_info.flag;
    IF flag(i) = 1 THEN j:=1; END IF;
    i := i + 1;
  END LOOP;

  -- no valid column name, or all flag = No, return 1
  IF (i=1 or j=0) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.dea_selectivity.col_name',
                     'API jty_tae_index_creation_pvt.dea_selectivity has failed as there is no valid column name, or all flag = No');

  --  RAISE FND_API.G_EXC_ERROR;
  --END IF;
  ELSE
  CAL_SELECTIVITY(
    p_table_name    => p_table_name,
    v_colname       => col_name,
    o_sel           => o_sel,
    std_dev         => std_dev,
    flag            => flag,
    numcol          => i-1,
    x_return_status => x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.dea_selectivity.cal_selectivity',
                     'API jty_tae_index_creation_pvt.cal_selectivity has failed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- update JTY_DEA_ATTR_FACTORS
  FOR i IN 1..col_name.count LOOP
    UPDATE JTY_DEA_ATTR_FACTORS
    SET INPUT_SELECTIVITY           = i,
        INPUT_ORDINAL_SELECTIVITY   = o_sel(i),
        INPUT_DEVIATION             = std_dev(i)
    WHERE  TAE_COL_MAP = col_name(i);
  END LOOP;

  COMMIT;
 END IF;
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.dea_selectivity.end',
                   'End of the procedure jty_tae_index_creation_pvt.dea_selectivity ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.dea_selectivity.g_exc_error',
                     'jty_tae_index_creation_pvt.dea_selectivity has failed with G_EXC_ERROR exception');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.dea_selectivity.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END DEA_SELECTIVITY;


/**
 * Procedure   :  SELECTIVITY
 * Type        :  Private
 * Pre_reqs    :
 * Description :
 * Parameters  :
 * input  JTF_TAE_QUAL_FACTORS.SQUAL_ALIAS
 * outout JTF_TAE_QUAL_FACTORS.INPUT_SELECTIVITY         is populated with selectivity order
          JTF_TAE_QUAL_FACTORS.INPUT_ORDINAL_SELECTIVITY is populated with ordinal_selectivity
          JTF_TAE_QUAL_FACTORS.INPUT_DEVIATION           is populated with standard deviation
 */

PROCEDURE SELECTIVITY(p_TABLE_NAME    IN         VARCHAR2,
                      p_mode          IN         VARCHAR2,
                      p_source_id     IN         NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2)
IS

  col_name name_varray :=  name_varray(
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  o_sel value_varray :=  value_varray(
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  std_dev value_varray :=  value_varray(
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  sele value_varray :=  value_varray(
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  flag value_varray :=  value_varray(
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

  i        integer;
  j        integer;

  CURSOR getColumnName IS
  SELECT DISTINCT
    A.TAE_COL_MAP                 sqname,
    A.INPUT_DEVIATION             dev,
    A.INPUT_ORDINAL_SELECTIVITY   ord_sele,
    A.INPUT_SELECTIVITY           sele,
    decode(A.UPDATE_SELECTIVITY_FLAG,'Y',1,0) flag
  FROM JTF_TAE_QUAL_FACTORS A
  WHERE A.USE_TAE_COL_IN_INDEX_FLAG = 'Y'
  AND A.TAE_COL_MAP is not null ;

  CURSOR getColumnName_dnmval(cl_source_id in number) IS
  SELECT DISTINCT
    A.VALUES_COL_MAP              sqname,
    NULL                          dev,
    A.INPUT_ORDINAL_SELECTIVITY   ord_sele,
    A.INPUT_SELECTIVITY           sele,
    1                             flag
  FROM jty_terr_values_idx_details A,
       jty_terr_values_idx_header  B
  WHERE A.VALUES_COL_MAP is not null
  AND   B.delete_flag = 'N'
  AND   A.terr_values_idx_header_id = B.terr_values_idx_header_id
  AND   B.source_id = cl_source_id;

  CURSOR getColumnName_deaval(cl_source_id in number) IS
  SELECT DISTINCT
    A.VALUES_COL_MAP              sqname,
    NULL                          dev,
    A.INPUT_ORDINAL_SELECTIVITY   ord_sele,
    A.INPUT_SELECTIVITY           sele,
    1                             flag
  FROM jty_dea_values_idx_details A,
       jty_dea_values_idx_header  B
  WHERE A.VALUES_COL_MAP is not null
  AND   A.dea_values_idx_header_id = B.dea_values_idx_header_id
  AND   B.source_id = cl_source_id;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.selectivity.start',
                   'Start of the procedure jty_tae_index_creation_pvt.selectivity ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  i := 1;
  j := 0;

  IF (p_source_id IS NULL) THEN
    FOR qual_info in getColumnName LOOP
      col_name(i) := qual_info.sqname;
      o_sel(i)    := qual_info.ord_sele;
      std_dev(i)  := qual_info.dev;
      flag(i)     := qual_info.flag;
      IF flag(i) = 1 THEN j:=1; END IF;
      i := i + 1;
    END LOOP;
  ELSE
    IF (p_mode = 'DATE EFFECTIVE') THEN
      FOR qual_info in getColumnName_deaval(p_source_id) LOOP
        col_name(i) := qual_info.sqname;
        o_sel(i)    := qual_info.ord_sele;
        std_dev(i)  := qual_info.dev;
        flag(i)     := qual_info.flag;
        IF flag(i) = 1 THEN j:=1; END IF;
        i := i + 1;
      END LOOP;
    ELSE
      FOR qual_info in getColumnName_dnmval(p_source_id) LOOP
        col_name(i) := qual_info.sqname;
        o_sel(i)    := qual_info.ord_sele;
        std_dev(i)  := qual_info.dev;
        flag(i)     := qual_info.flag;
        IF flag(i) = 1 THEN j:=1; END IF;
        i := i + 1;
      END LOOP;
    END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */
  END IF; /* end IF (p_source_id IS NULL) */

  -- no valid column name, or all flag = No, return 1
  IF (i=1 or j=0) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.selectivity.col_name',
                     'API jty_tae_index_creation_pvt.selectivity has failed as there is no valid column name, or all flag = No');

  --  RAISE FND_API.G_EXC_ERROR;
  --END IF;
  ELSE
  CAL_SELECTIVITY(
    p_table_name    => p_table_name,
    v_colname       => col_name,
    o_sel           => o_sel,
    std_dev         => std_dev,
    flag            => flag,
    numcol          => i-1,
    x_return_status => x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.selectivity.cal_selectivity',
                     'API jty_tae_index_creation_pvt.selectivity has failed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_source_id IS NULL) THEN
    -- update JTF_TAE_QUAL_FACTORS
    FOR i IN 1..col_name.count LOOP
      UPDATE JTF_TAE_QUAL_FACTORS
      SET INPUT_SELECTIVITY           = i,
          INPUT_ORDINAL_SELECTIVITY   = o_sel(i),
          INPUT_DEVIATION             = std_dev(i)
      WHERE  TAE_COL_MAP = col_name(i);
    END LOOP;
  ELSE
    IF (p_mode = 'DATE EFFECTIVE') THEN
      FOR i IN 1..col_name.count LOOP
        UPDATE jty_dea_values_idx_details
        SET INPUT_SELECTIVITY           = i,
            INPUT_ORDINAL_SELECTIVITY   = o_sel(i)
        WHERE  VALUES_COL_MAP = col_name(i);
      END LOOP;
    ELSE
      FOR i IN 1..col_name.count LOOP
        UPDATE jty_terr_values_idx_details
        SET INPUT_SELECTIVITY           = i,
            INPUT_ORDINAL_SELECTIVITY   = o_sel(i)
        WHERE  VALUES_COL_MAP = col_name(i);
      END LOOP;
    END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */
  END IF; /* end IF (p_source_id IS NULL) */

  COMMIT;
END IF;
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.selectivity.end',
                   'End of the procedure jty_tae_index_creation_pvt.selectivity ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.selectivity.g_exc_error',
                     'jty_tae_index_creation_pvt.selectivity has failed with G_EXC_ERROR exception');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.selectivity.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END SELECTIVITY;


PROCEDURE get_qual_comb_index (
      p_rel_prod         IN   NUMBER,
      p_reverse_flag     IN   VARCHAR2,
      p_qual_type_usg_id IN   NUMBER,
      p_table_name       IN   VARCHAR2,
      p_index_extn       IN   VARCHAR2,
      p_run_mode         IN   VARCHAR2,
      p_mode             IN   VARCHAR2,
      x_return_status    OUT NOCOPY  VARCHAR2,
      x_statement        OUT NOCOPY  VARCHAR2,
      alter_statement    OUT NOCOPY  VARCHAR2)
AS

  l_trans_idx_name    VARCHAR2(30);
  l_status            VARCHAR2(30);
  l_industry          VARCHAR2(30);
  l_jtf_schema        VARCHAR2(30);

  L_SCHEMA_NOTFOUND  EXCEPTION;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.get_qual_comb_index.begin',
                   'Start of the procedure jty_tae_index_creation_pvt.get_qual_comb_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  IF (p_run_mode = 'DEA_TRANS') THEN
    l_trans_idx_name := 'JTF_TAE_DE' || TO_CHAR(ABS(p_qual_type_usg_id)) || '_' || TO_CHAR(p_rel_prod) || '_' || p_index_extn;
  ELSE
    IF (p_mode = 'TOTAL') THEN
      l_trans_idx_name := 'JTF_TAE_TN' || TO_CHAR(ABS(p_qual_type_usg_id)) || '_' || TO_CHAR(p_rel_prod) || '_' || p_index_extn || 'T';
    ELSE
      l_trans_idx_name := 'JTF_TAE_TN' || TO_CHAR(ABS(p_qual_type_usg_id)) || '_' || TO_CHAR(p_rel_prod) || '_' || p_index_extn || 'I';
    END IF;
  END IF;

  IF (p_reverse_flag = 'Y') THEN
    l_trans_idx_name := l_trans_idx_name || 'X';
  END IF;

  /* Postal Code + Country Combination */
  IF ( p_rel_prod = 4841  AND p_reverse_flag = 'N' ) THEN

    x_statement := 'CREATE INDEX ' || l_jtf_schema || '.' || l_trans_idx_name || ' ON ' || p_table_name;
    x_statement := x_statement || ' ( SQUAL_CHAR07, SQUAL_CHAR06 ) ';
    IF (p_mode <> 'INCREMENTAL') THEN
      x_statement := x_statement || ' LOCAL ';
    END IF;

    alter_statement := 'ALTER INDEX ' || l_jtf_schema || '.' || l_trans_idx_name || ' NOPARALLEL';

  /* Customer Name Range + Postal Code + Country Combination */
  ELSIF ( p_rel_prod = 324347 AND p_reverse_flag = 'N' ) THEN

    x_statement := 'CREATE INDEX '|| l_jtf_schema ||'.' || l_trans_idx_name || ' ON ' || p_table_name;
    x_statement := x_statement || ' ( SQUAL_FC01, SQUAL_CHAR01, SQUAL_CHAR06, SQUAL_CHAR07 ) ';
    IF (p_mode <> 'INCREMENTAL') THEN
      x_statement := x_statement || ' LOCAL ';
    END IF;

    alter_statement := 'ALTER INDEX ' || l_jtf_schema || '.' || l_trans_idx_name || ' NOPARALLEL';

  /* REVERSE: Customer Name Range + Postal Code + Country Combination */
  ELSIF ( p_rel_prod = 324347 AND p_reverse_flag = 'Y' ) THEN

    x_statement := 'CREATE INDEX ' || l_jtf_schema || '.' || l_trans_idx_name || ' ON ' || p_table_name;
    x_statement := x_statement || ' ( SQUAL_CHAR07, SQUAL_CHAR06, SQUAL_CHAR01 ) ';
    IF (p_mode <> 'INCREMENTAL') THEN
      x_statement := x_statement || ' LOCAL ';
    END IF;

    alter_statement := 'ALTER INDEX ' || l_jtf_schema || '.' || l_trans_idx_name || ' NOPARALLEL';

  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_tae_index_creation_pvt.get_qual_comb_index.index_stmt',
                   'x_statement : ' || x_statement || ' alter_statement : ' || alter_statement);

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.get_qual_comb_index.end',
                   'End of the procedure jty_tae_index_creation_pvt.get_qual_comb_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.get_qual_comb_index.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.get_qual_comb_index.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END get_qual_comb_index;


/**
 * Procedure   :  CREATE_INDEX
 * Type        :  private
 * Pre_reqs    :
 * Description :  index creation
 * input       : table JTF_TAE_QUAL_PRODUCTS
 *             : table JTF_TAE_QUAL_FACTORS
 * output      : indices created on JTF_TAE_OBJECT_INPUT
 * return  0: failure
 *         1: success
 */
procedure CREATE_INDEX ( p_table_name    IN  VARCHAR2,
                         p_trans_id      IN  NUMBER,
                         p_source_id     IN  NUMBER,
                         p_program_name  IN  VARCHAR2,
                         p_mode          IN  VARCHAR2,
                         x_Return_Status OUT NOCOPY VARCHAR2,
                         p_run_mode      IN  VARCHAR2)
IS

  i           integer;
  j           integer;

  v_statement varchar2(2000);
  s_statement varchar2(2000);
  alter_statement varchar2(2000);

  l_table_tablespace  varchar2(100);
  l_idx_tablespace    varchar2(100);
  l_ora_username      varchar2(100);

  l_trans_idx_name    varchar2(30);
  l_matches_idx_name  varchar2(30);
  l_winners_idx_name  varchar2(30);

  lx_4841_idx_created varchar2(1);
  lx_324347_idx_created varchar2(1);
  prd_nulltae_mul_of_4841 varchar2(1);
  prd_nulltae_mul_of_324347 varchar2(1);

  lx_rev_4841_idx_created varchar2(1);
  lx_rev_324347_idx_created varchar2(1);
  prd_rev_nulltae_mul_of_4841 varchar2(1);
  prd_rev_nulltae_mul_of_324347 varchar2(1);

  l_create_index_flag varchar2(1);

  l_dop            NUMBER;
  l_index_extn     VARCHAR2(2);
  l_qual_type_usg_id  NUMBER;

  l_tae_col_map       VARCHAR2(30);
  Cursor getProductList(cl_source_id number, cl_trans_id number) IS
  SELECT  P.qual_product_id         qual_product_id,
          p.RELATION_PRODUCT        RELATION_PRODUCT,
          MAX(p.index_name)         index_name,
          MAX(p.first_char_flag)    first_char_flag,
          COUNT(r.qual_factor_id)   cartesian_terr_X_factors
  FROM  jtf_terr_denorm_rules_all d
       ,jtf_terr_qtype_usgs_all jtqu
	   ,jtf_qual_type_usgs_all jqtu
       ,JTF_TAE_QUAL_PRODUCTS P
       , JTF_TAE_QUAL_PROD_FACTORS R
  WHERE jtqu.qual_relation_product = p.relation_product
  AND   jqtu.source_id = d.source_id
  AND   jqtu.qual_type_id = p.trans_object_type_id
  AND   d.terr_id = jtqu.terr_id
  AND   jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
  AND   d.source_id = p.source_id
  AND   P.qual_product_id = R.qual_product_id
  AND   P.BUILD_INDEX_FLAG = 'Y'
  AND   p.TRANS_OBJECT_TYPE_ID = cl_trans_id
  AND   P.SOURCE_ID = cl_source_id
  GROUP BY P.qual_product_id, p.RELATION_PRODUCT
  ORDER BY cartesian_terr_X_factors DESC, first_char_flag;

  Cursor  getFactorList(c_pid number) IS
  SELECT  DISTINCT TAE_COL_MAP, J2.INPUT_SELECTIVITY
  FROM    JTF_TAE_QUAL_PRODUCTS J3,
          JTF_TAE_QUAL_FACTORS J2,
          JTF_TAE_QUAL_PROD_FACTORS J1
  WHERE J1.qual_product_id = c_pid
  AND   J1.qual_product_id = J3.qual_product_id
  AND   J1.qual_factor_id = J2.qual_factor_id
  AND   J2.USE_TAE_COL_IN_INDEX_FLAG = 'Y'
  AND   J2.TAE_COL_MAP is NOT NULL
  ORDER BY J2.INPUT_SELECTIVITY;

  Cursor extraIndexCandidates(cl_source_id number, cl_trans_id number) IS
  SELECT  P.qual_product_id         qual_product_id,
          p.RELATION_PRODUCT        RELATION_PRODUCT,
          p.index_name         index_name,
          p.first_char_flag    first_char_flag,
          rownum               index_counter
  FROM    JTF_TAE_QUAL_PRODUCTS P
  WHERE   P.BUILD_INDEX_FLAG = 'Y'
  AND     P.FIRST_CHAR_FLAG = 'Y'
  AND     p.TRANS_OBJECT_TYPE_ID = cl_trans_id
  AND     P.SOURCE_ID = cl_source_id;

  Cursor  getReverseFactorList(cl_pid number) IS
  select  f.tae_col_map, qual_usg_id, input_selectivity
  from    jtf_tae_qual_prod_factors pf,
          jtf_tae_qual_factors f
  where pf.qual_product_id = cl_pid
  and   f.qual_factor_id = pf.qual_factor_id
  and   f.tae_col_map is not null
  order by input_selectivity desc;

  Cursor verifyProdNonNullTAEColMaps(cl_source_id number, cl_trans_id number, cp_product NUMBER, cp_non_null_tae_col_maps NUMBER) IS
  select NON_NULL_TAE_COL_MAPS, RELATION_PRODUCT
  from (
         select  count(*) NON_NULL_TAE_COL_MAPS,
                 p.qual_product_id QUAL_PRODUCT_ID,
                 p.relation_product RELATION_PRODUCT
         from JTF_TAE_QUAL_products p,
              JTF_TAE_QUAL_prod_factors pf,
              JTF_TAE_QUAL_FACTORS f
         where p.qual_product_id = pf.qual_product_id
         and   pf.qual_factor_id = f.qual_factor_id
         and   p.source_id = cl_source_id
         and   p.trans_object_type_id = cl_trans_id
         and   p.relation_product > 0
         and   tae_col_map is not null
         and   p.relation_product = cp_product
         group by p.qual_product_id, p.relation_product
       )
  where NON_NULL_TAE_COL_MAPS = cp_non_null_tae_col_maps;

  Cursor dea_getProductList(cl_source_id number, cl_trans_id number) IS
  SELECT  P.dea_attr_products_id         dea_attr_products_id,
          p.attr_relation_product        attr_relation_product,
          MAX(p.index_name)              index_name,
          MAX(p.first_char_flag)         first_char_flag,
          COUNT(r.dea_attr_factors_id)   cartesian_terr_X_factors
  FROM  jty_denorm_dea_rules_all d
       ,jtf_terr_qtype_usgs_all jtqu
	   ,jtf_qual_type_usgs_all jqtu
       ,jty_dea_attr_products P
       ,jty_dea_attr_prod_factors R
  WHERE jtqu.qual_relation_product = p.attr_relation_product
  AND   jqtu.source_id = d.source_id
  AND   jqtu.qual_type_id = p.trans_type_id
  AND   d.terr_id = jtqu.terr_id
  AND   jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
  AND   d.source_id = p.source_id
  AND   P.dea_attr_products_id = R.dea_attr_products_id
  AND   P.build_index_flag = 'Y'
  AND   p.trans_type_id = cl_trans_id
  AND   P.source_id = cl_source_id
  GROUP BY P.dea_attr_products_id, p.attr_relation_product
  ORDER BY cartesian_terr_X_factors DESC, first_char_flag;

  Cursor  dea_getFactorList(c_pid number) IS
  SELECT  DISTINCT TAE_COL_MAP, J2.INPUT_SELECTIVITY
  FROM    jty_dea_attr_products J3,
          jty_dea_attr_factors J2,
          jty_dea_attr_prod_factors J1
  WHERE J1.dea_attr_products_id = c_pid
  AND   J1.dea_attr_products_id = J3.dea_attr_products_id
  AND   J1.dea_attr_factors_id = J2.dea_attr_factors_id
  AND   J2.USE_TAE_COL_IN_INDEX_FLAG = 'Y'
  AND   J2.TAE_COL_MAP is NOT NULL
  ORDER BY J2.INPUT_SELECTIVITY;

  Cursor dea_extraIndexCandidates(cl_source_id number, cl_trans_id number) IS
  SELECT  P.dea_attr_products_id    dea_attr_products_id,
          p.attr_relation_product   attr_relation_product,
          p.index_name              index_name,
          p.first_char_flag         first_char_flag,
          rownum                    index_counter
  FROM    jty_dea_attr_products P
  WHERE   P.BUILD_INDEX_FLAG = 'Y'
  AND     P.FIRST_CHAR_FLAG = 'Y'
  AND     p.trans_type_id = cl_trans_id
  AND     P.source_id = cl_source_id;

  Cursor  dea_getReverseFactorList(cl_pid number) IS
  select  f.tae_col_map, qual_usg_id, input_selectivity
  from    jty_dea_attr_prod_factors pf,
          jty_dea_attr_factors f
  where pf.dea_attr_products_id = cl_pid
  and   f.dea_attr_factors_id = pf.dea_attr_factors_id
  and   f.tae_col_map is not null
  order by input_selectivity desc;

  Cursor dea_ProdNonNullTAEColMaps(cl_source_id number, cl_trans_id number, cp_product NUMBER, cp_non_null_tae_col_maps NUMBER) IS
  select NON_NULL_TAE_COL_MAPS, attr_relation_product
  from (
         select  count(*) NON_NULL_TAE_COL_MAPS,
                 p.dea_attr_products_id dea_attr_products_id,
                 p.attr_relation_product attr_relation_product
         from jty_dea_attr_products p,
              jty_dea_attr_prod_factors pf,
              jty_dea_attr_factors f
         where p.dea_attr_products_id = pf.dea_attr_products_id
         and   pf.dea_attr_factors_id = f.dea_attr_factors_id
         and   p.source_id = cl_source_id
         and   p.trans_type_id = cl_trans_id
         and   p.attr_relation_product > 0
         and   tae_col_map is not null
         and   p.attr_relation_product = cp_product
         group by p.dea_attr_products_id, p.attr_relation_product
       )
  where NON_NULL_TAE_COL_MAPS = cp_non_null_tae_col_maps;

  Cursor c_all_indexes(cl_table_name varchar2, cl_owner varchar2) IS
  select index_name
  from all_indexes
  where table_name = cl_table_name
  and table_owner = cl_owner;


BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.create_index.begin',
                   'Start of the procedure jty_tae_index_creation_pvt.create_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Initialize the flags */
  lx_4841_idx_created           := 'N';
  lx_324347_idx_created         := 'N';
  prd_nulltae_mul_of_4841       := 'N';
  prd_nulltae_mul_of_324347     := 'N';
  lx_rev_4841_idx_created       := 'N';
  lx_rev_324347_idx_created     := 'N';
  prd_rev_nulltae_mul_of_4841   := 'N';
  prd_rev_nulltae_mul_of_324347 := 'N';
  l_create_index_flag           := 'Y';

  /* get default Degree of Parallelism */
  SELECT MIN(TO_NUMBER(v.value))
  INTO   l_dop
  FROM   v$parameter v
  WHERE v.name = 'parallel_max_servers'
  OR    v.name = 'cpu_count';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_tae_index_creation_pvt.create_index.l_dop',
                   'Default degree of parallelism : ' || l_dop);

  /* get tablespace information */
  SELECT i.tablespace, i.index_tablespace, u.oracle_username
  INTO l_table_tablespace, l_idx_tablespace, l_ora_username
  FROM fnd_product_installations i, fnd_application a, fnd_oracle_userid u
  WHERE a.application_short_name = 'JTF'
  AND a.application_id = i.application_id
  AND u.oracle_id = i.oracle_id;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_tae_index_creation_pvt.create_index.tablespace',
                   'Table tablespace : ' || l_table_tablespace || ' Index tablespace : ' || l_idx_tablespace ||
                   ' Schema Name : ' || l_ora_username);

  -- default INDEX STORAGE parameters
  s_statement := s_statement || ' TABLESPACE ' ||  l_idx_tablespace ;
  s_statement := s_statement || ' STORAGE(INITIAL 1M NEXT 1M MINEXTENTS 1 MAXEXTENTS UNLIMITED ';
  s_statement := s_statement || ' PCTINCREASE 0 FREELISTS 4 FREELIST GROUPS 4 BUFFER_POOL DEFAULT) ';
  s_statement := s_statement || ' PCTFREE 10 INITRANS 10 MAXTRANS 255 ';
  s_statement := s_statement || ' COMPUTE STATISTICS ';
  s_statement := s_statement || ' NOLOGGING PARALLEL ' || l_dop;

  BEGIN
    SELECT index_extn
    INTO   l_index_extn
    FROM   jty_trans_usg_pgm_details
    WHERE  source_id     = p_source_id
    AND    trans_type_id = p_trans_id
    AND    program_name  = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.jty_tae_index_creation_pvt.create_index.no_index_extn',
                       'No row in table jty_trans_usg_pgm_details corresponding to source : ' || p_source_id || ' transaction : ' ||
                       p_trans_id || ' program name : ' || p_program_name);
      RAISE;
  END;

  BEGIN
    SELECT qual_type_usg_id
    INTO   l_qual_type_usg_id
    FROM   jtf_qual_type_usgs_all
    WHERE  source_id = p_source_id
    AND    qual_type_id = p_trans_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.jty_tae_index_creation_pvt.create_index.no_qual_type_usg_id',
                       'No row in table jtf_qual_type_usgs_all corresponding to source : ' || p_source_id || ' and transaction : ' ||
                       p_trans_id);
      RAISE;
  END;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_tae_index_creation_pvt.create_index.l_index_extn',
                   'Index extension for the usage : ' || l_index_extn ||
                   ' qual_type-usg_id : ' || l_qual_type_usg_id);

  -- indexes for TRANS table
  IF (p_run_mode = 'TRANS') THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.existing_index',
                     'Existing Indexes');
      FOR c1 IN c_all_indexes(p_table_name, l_ora_username) LOOP
        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.jty_tae_index_creation_pvt.create_index.existing_index',
                       'Index Name : ' || c1.index_name);
      END LOOP;

    IF (p_mode = 'TOTAL') THEN
      l_trans_idx_name := 'JTF_TAE_TN' || ABS(l_qual_type_usg_id) || '_UK_' || l_index_extn || 'T';
    ELSE
      l_trans_idx_name := 'JTF_TAE_TN' || ABS(l_qual_type_usg_id) || '_UK_' || l_index_extn || 'I';
    END IF;

    v_statement := 'CREATE INDEX ' || l_ora_username ||'.' || l_trans_idx_name || ' ON ' || p_table_name;
    v_statement := v_statement || ' ( TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) ';
    IF (p_mode <> 'INCREMENTAL') THEN
      v_statement := v_statement || ' LOCAL ';
    END IF;
    v_statement := v_statement || s_statement;

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.index_creation',
                     '1Index created with the statement : ' || v_statement);

    EXECUTE IMMEDIATE v_statement;

    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';
    EXECUTE IMMEDIATE alter_statement;

    /* Create Qualifier Combination Dynamic Indexes */
    FOR prd IN getProductList(p_source_id, p_trans_id) LOOP
      l_create_index_flag := 'Y';
      -- EIHSU 08/14/02: Set flags for determining if relation_prods
      -- are NULL TAE_COL_MAP multiples of the specific QCombinations
      -- as described by JDOCHERT 08/04/02

      /* INDEX CREATION LOGIC PREPROCESSING */
      prd_nulltae_mul_of_4841 := 'N';
      prd_nulltae_mul_of_324347 := 'N';

      IF mod(prd.RELATION_PRODUCT, 324347) = 0 OR mod(prd.RELATION_PRODUCT, 353393) = 0 THEN
        for verifiedProd in verifyProdNonNullTAEColMaps(p_source_id, p_trans_id, prd.RELATION_PRODUCT, 3) loop
          prd_nulltae_mul_of_324347 := 'Y';
        end loop;
      ELSIF mod(prd.RELATION_PRODUCT, 4841) = 0 THEN
        for verifiedProd in verifyProdNonNullTAEColMaps(p_source_id, p_trans_id, prd.RELATION_PRODUCT, 2) loop
          prd_nulltae_mul_of_4841 := 'Y';
        end loop;
      END IF;

      /* INDEX CREATION METHOD LOGIC */
      IF (prd_nulltae_mul_of_4841 = 'Y') THEN
        IF (lx_4841_idx_created = 'N') THEN
          get_qual_comb_index (
            p_rel_prod         => 4841,
            p_reverse_flag     => 'N',
            p_qual_type_usg_id => l_qual_type_usg_id,
            p_table_name       => p_table_name,
            p_index_extn       => l_index_extn,
            p_run_mode         => p_run_mode,
            p_mode             => p_mode,
            x_return_status    => x_return_status,
            x_statement        => V_STATEMENT,
            alter_statement    => ALTER_STATEMENT );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- debug message
              jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.jty_tae_index_creation_pvt.create_index.4841',
                             'API jty_tae_index_creation_pvt.get_qual_comb_index has failed for qualifier comb 4841');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          lx_4841_idx_created := 'Y';
        ELSE
          l_create_index_flag := 'N';
        END IF;

      ELSIF (prd_nulltae_mul_of_324347 = 'Y') THEN
        IF (lx_324347_idx_created = 'N') THEN
          get_qual_comb_index (
            p_rel_prod         => 324347,
            p_reverse_flag     => 'N',
            p_qual_type_usg_id => l_qual_type_usg_id,
            p_table_name       => p_table_name,
            p_index_extn       => l_index_extn,
            p_run_mode         => p_run_mode,
            p_mode             => p_mode,
            x_return_status    => x_return_status,
            x_statement        => V_STATEMENT,
            alter_statement    => ALTER_STATEMENT );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- debug message
              jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.jty_tae_index_creation_pvt.create_index.324347',
                             'API jty_tae_index_creation_pvt.get_qual_comb_index has failed for qualifier comb 324347');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          lx_324347_idx_created := 'Y';
        ELSE
          l_create_index_flag := 'N';
        END IF;

      ELSE
        IF (p_mode = 'TOTAL') THEN
          l_trans_idx_name := prd.index_name || l_index_extn || 'T';
        ELSE
          l_trans_idx_name := prd.index_name || l_index_extn || 'I';
        END IF;

        v_statement := 'CREATE INDEX '|| l_ora_username ||'.' || l_trans_idx_name || ' ON ' || p_table_name || '( ';
        IF prd.first_char_flag = 'Y' THEN
          v_statement := v_statement || first_char_col_name || ',';
        END IF;

        j:=1;

        -- for each factor of product
        FOR factor IN getFactorList(prd.qual_product_id) LOOP
          IF j<>1 THEN
            v_statement := v_statement || ',' ;
          END IF;
          v_statement := v_statement || factor.TAE_COL_MAP;
          j:=j+1;
        END LOOP;

        v_statement := v_statement || ') ';
        IF (p_mode <> 'INCREMENTAL') THEN
          v_statement := v_statement || ' LOCAL ';
        END IF;

        IF (j <= 1) THEN
          l_create_index_flag := 'N';
        END IF;

      END IF;

      /* Append Storage Parameter Information to Index Definition */
      v_statement := v_statement || s_statement;

      IF l_create_index_flag = 'Y' THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_STATEMENT,
                         'jtf.plsql.jty_tae_index_creation_pvt.create_index.index_creation',
                         '2Index created with the statement : ' || prd.qual_product_id || v_statement);

        EXECUTE IMMEDIATE v_statement;

        IF prd_nulltae_mul_of_4841 = 'Y' OR prd_nulltae_mul_of_324347 = 'Y'
        THEN
          EXECUTE IMMEDIATE alter_statement;
        ELSE
          alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';
          EXECUTE IMMEDIATE alter_statement;
        END IF;
      END IF;

    END LOOP; /* end loop  FOR prd IN getProductList */

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.trans_index',
                     'Done creating index for TRANS table');

    -- Additional Indexes for TRANS table - eihsu 03/06/2002
    FOR idxCand in extraIndexCandidates(p_source_id, p_trans_id) LOOP
      l_create_index_flag := 'Y';

      /* INDEX CREATION LOGIC PREPROCESSING */
      prd_rev_nulltae_mul_of_324347 := 'N';

      IF (mod(idxCand.RELATION_PRODUCT, 324347) = 0 OR mod(idxCand.RELATION_PRODUCT, 353393) = 0) THEN
        for verifiedProd in verifyProdNonNullTAEColMaps(p_source_id, p_trans_id, idxCand.RELATION_PRODUCT, 3) loop
          prd_rev_nulltae_mul_of_324347 := 'Y';
        end loop;
      END IF;

      /* REV INDEX CREATION METHOD LOGIC */
      IF (prd_rev_nulltae_mul_of_324347 = 'Y') THEN
        IF (lx_rev_324347_idx_created = 'N') THEN
          get_qual_comb_index (
            p_rel_prod         => 324347,
            p_reverse_flag     => 'Y',
            p_qual_type_usg_id => l_qual_type_usg_id,
            p_table_name       => p_table_name,
            p_index_extn       => l_index_extn,
            p_run_mode         => p_run_mode,
            p_mode             => p_mode,
            x_return_status    => x_return_status,
            x_statement        => V_STATEMENT,
            alter_statement    => ALTER_STATEMENT );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- debug message
              jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.jty_tae_index_creation_pvt.create_index.324347_reverse',
                             'API jty_tae_index_creation_pvt.get_qual_comb_index has failed for qualifier comb 324347_reverse');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          lx_rev_324347_idx_created := 'Y';
        ELSE
          l_create_index_flag := 'N';
        END IF;

      ELSE
        IF (p_mode = 'TOTAL') THEN
          l_trans_idx_name := idxCand.index_name || l_index_extn || 'XT';
        ELSE
          l_trans_idx_name := idxCand.index_name || l_index_extn || 'XI';
        END IF;

        v_statement := 'CREATE INDEX '|| l_ora_username ||'.' || l_trans_idx_name || ' ON ' || p_table_name || '( ';

        j:=1;
        l_tae_col_map := 'ABC';

        -- for each factor of product
        for xFactor IN getReverseFactorList(idxCand.qual_product_id) loop
          IF l_tae_col_map <> xFactor.TAE_COL_MAP
          THEN
              if j<>1 then
                v_statement := v_statement || ',' ;
              end if;
              v_statement := v_statement || xFactor.TAE_COL_MAP;
              j:=j+1;
          END IF;
          l_tae_col_map := xFactor.TAE_COL_MAP;
        end loop;

        IF (j <= 1) THEN
          l_create_index_flag := 'N';
        END IF;

        v_statement := v_statement || ') ';
        IF (p_mode <> 'INCREMENTAL') THEN
          v_statement := v_statement || ' LOCAL ';
        END IF;

      END IF; /* end IF (prd_rev_nulltae_mul_of_324347 = 'Y') */

      v_statement := v_statement || s_statement;

      IF l_create_index_flag = 'Y' THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_STATEMENT,
                         'jtf.plsql.jty_tae_index_creation_pvt.create_index.index_creation',
                         '3Index created with the statement : ' || idxCand.qual_product_id || v_statement);

        EXECUTE IMMEDIATE v_statement;

        IF prd_rev_nulltae_mul_of_324347 = 'Y' THEN
          EXECUTE IMMEDIATE alter_statement;
        ELSE
          alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';
          EXECUTE IMMEDIATE alter_statement;
        END IF;

      END IF; /* end IF l_create_index_flag = 'Y' */

    END LOOP; /* end loop FOR idxCand in extraIndexCandidates */

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.trans_reverse_index',
                     'Done creating reverse index for TRANS table');

  -- indexes for DEA_TRANS table
  ELSIF (p_run_mode = 'DEA_TRANS') THEN

    l_trans_idx_name := 'JTF_TAE_DE' || ABS(l_qual_type_usg_id) || '_UK_' || l_index_extn;

    v_statement := 'CREATE INDEX ' || l_ora_username ||'.' || l_trans_idx_name || ' ON ' || p_table_name;
    v_statement := v_statement || ' ( TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) LOCAL ';
    v_statement := v_statement || s_statement;

    EXECUTE IMMEDIATE v_statement;

    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';
    EXECUTE IMMEDIATE alter_statement;

    /* Create Qualifier Combination Dynamic Indexes */
    FOR prd IN dea_getProductList(p_source_id, p_trans_id) LOOP
      l_create_index_flag := 'Y';
      -- EIHSU 08/14/02: Set flags for determining if relation_prods
      -- are NULL TAE_COL_MAP multiples of the specific QCombinations
      -- as described by JDOCHERT 08/04/02

      /* INDEX CREATION LOGIC PREPROCESSING */
      prd_nulltae_mul_of_4841 := 'N';
      prd_nulltae_mul_of_324347 := 'N';

      IF mod(prd.ATTR_RELATION_PRODUCT, 324347) = 0 OR mod(prd.ATTR_RELATION_PRODUCT, 353393) = 0 THEN
        for verifiedProd in dea_ProdNonNullTAEColMaps(p_source_id, p_trans_id, prd.ATTR_RELATION_PRODUCT, 3) loop
          prd_nulltae_mul_of_324347 := 'Y';
        end loop;
      ELSIF mod(prd.ATTR_RELATION_PRODUCT, 4841) = 0 THEN
        for verifiedProd in verifyProdNonNullTAEColMaps(p_source_id, p_trans_id, prd.ATTR_RELATION_PRODUCT, 2) loop
          prd_nulltae_mul_of_4841 := 'Y';
        end loop;
      END IF;

      /* INDEX CREATION METHOD LOGIC */
      IF (prd_nulltae_mul_of_4841 = 'Y') THEN
        IF (lx_4841_idx_created = 'N') THEN
          get_qual_comb_index (
            p_rel_prod         => 4841,
            p_reverse_flag     => 'N',
            p_qual_type_usg_id => l_qual_type_usg_id,
            p_table_name       => p_table_name,
            p_index_extn       => l_index_extn,
            p_run_mode         => p_run_mode,
            p_mode             => p_mode,
            x_return_status    => x_return_status,
            x_statement        => V_STATEMENT,
            alter_statement    => ALTER_STATEMENT );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- debug message
                 jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.jty_tae_index_creation_pvt.create_index.dea_4841',
                             'API jty_tae_index_creation_pvt.get_qual_comb_index has failed for qualifier comb dea_4841');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          lx_4841_idx_created := 'Y';
        ELSE
          l_create_index_flag := 'N';
        END IF;

      ELSIF (prd_nulltae_mul_of_324347 = 'Y') THEN
        IF (lx_324347_idx_created = 'N') THEN
          get_qual_comb_index (
            p_rel_prod         => 324347,
            p_reverse_flag     => 'N',
            p_qual_type_usg_id => l_qual_type_usg_id,
            p_table_name       => p_table_name,
            p_index_extn       => l_index_extn,
            p_run_mode         => p_run_mode,
            p_mode             => p_mode,
            x_return_status    => x_return_status,
            x_statement        => V_STATEMENT,
            alter_statement    => ALTER_STATEMENT );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- debug message
                 jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.jty_tae_index_creation_pvt.create_index.dea_324347',
                             'API jty_tae_index_creation_pvt.get_qual_comb_index has failed for qualifier comb dea_324347');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          lx_324347_idx_created := 'Y';
        ELSE
          l_create_index_flag := 'N';
        END IF;

      ELSE
        v_statement := 'CREATE INDEX '|| l_ora_username ||'.' || prd.index_name || l_index_extn || 'D ON ' || p_table_name || '( ';

        IF prd.first_char_flag = 'Y' THEN
          v_statement := v_statement || first_char_col_name || ',';
        END IF;

        j:=1;

        -- for each factor of product
        FOR factor IN dea_getFactorList(prd.dea_attr_products_id) LOOP
          IF j<>1 THEN
            v_statement := v_statement || ',' ;
          END IF;
          v_statement := v_statement || factor.TAE_COL_MAP;
          j:=j+1;
        END LOOP;

        v_statement := v_statement || ') LOCAL ';

        IF (j <= 1) THEN
          l_create_index_flag := 'N';
        END IF;

      END IF;

      /* Append Storage Parameter Information to Index Definition */
      v_statement := v_statement || s_statement;

      IF l_create_index_flag = 'Y' THEN
        EXECUTE IMMEDIATE v_statement;

        IF prd_nulltae_mul_of_4841 = 'Y' OR prd_nulltae_mul_of_324347 = 'Y'
        THEN
          EXECUTE IMMEDIATE alter_statement;
        ELSE
          alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || prd.index_name || l_index_extn || 'D NOPARALLEL';
          EXECUTE IMMEDIATE alter_statement;
        END IF;
      END IF;

    END LOOP; /* end loop  FOR prd IN getProductList */

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.dea_trans_index',
                     'Done creating index for DEA_TRANS table');

    FOR idxCand in dea_extraIndexCandidates(p_source_id, p_trans_id) LOOP
      l_create_index_flag := 'Y';

      /* INDEX CREATION LOGIC PREPROCESSING */
      prd_rev_nulltae_mul_of_324347 := 'N';

      IF (mod(idxCand.ATTR_RELATION_PRODUCT, 324347) = 0 OR mod(idxCand.ATTR_RELATION_PRODUCT, 353393) = 0) THEN
        for verifiedProd in dea_ProdNonNullTAEColMaps(p_source_id, p_trans_id, idxCand.ATTR_RELATION_PRODUCT, 3) loop
          prd_rev_nulltae_mul_of_324347 := 'Y';
        end loop;
      END IF;

      /* REV INDEX CREATION METHOD LOGIC */
      IF (prd_rev_nulltae_mul_of_324347 = 'Y') THEN
        IF (lx_rev_324347_idx_created = 'N') THEN
          get_qual_comb_index (
            p_rel_prod         => 324347,
            p_reverse_flag     => 'Y',
            p_qual_type_usg_id => l_qual_type_usg_id,
            p_table_name       => p_table_name,
            p_index_extn       => l_index_extn,
            p_run_mode         => p_run_mode,
            p_mode             => p_mode,
            x_return_status    => x_return_status,
            x_statement        => V_STATEMENT,
            alter_statement    => ALTER_STATEMENT );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- debug message
              jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.jty_tae_index_creation_pvt.create_index.dea_324347_reverse',
                             'API jty_tae_index_creation_pvt.get_qual_comb_index has failed for qualifier comb dea_324347_reverse');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          lx_rev_324347_idx_created := 'Y';
        ELSE
          l_create_index_flag := 'N';
        END IF;

      ELSE
        v_statement := 'CREATE INDEX ' || l_ora_username || '.' || idxCand.index_name || l_index_extn || 'XD' || ' ON ' ||
                           p_table_name || '( ';

        j:=1;

        -- for each factor of product
        for xFactor IN dea_getReverseFactorList(idxCand.dea_attr_products_id) loop
          if j<>1 then
            v_statement := v_statement || ',' ;
          end if;
          v_statement := v_statement || xFactor.TAE_COL_MAP;
          j:=j+1;
        end loop;

        v_statement := v_statement || ') LOCAL ';

        IF (j <= 1) THEN
          l_create_index_flag := 'N';
        END IF;

      END IF; /* end IF (prd_rev_nulltae_mul_of_324347 = 'Y') */

      v_statement := v_statement || s_statement;

      IF l_create_index_flag = 'Y' THEN
        EXECUTE IMMEDIATE v_statement;

        IF prd_rev_nulltae_mul_of_324347 = 'Y' THEN
          EXECUTE IMMEDIATE alter_statement;
        ELSE
          alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || idxCand.index_name || l_index_extn  ||'XD NOPARALLEL';
          EXECUTE IMMEDIATE alter_statement;
        END IF;

      END IF; /* end IF l_create_index_flag = 'Y' */

    END LOOP; /* end loop FOR idxCand in extraIndexCandidates */

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.dea_trans_reverse_index',
                     'Done creating reverse index for DEA_TRANS table');

/* no index is created on match table as the tables is always accessed with full table scan
  -- index for MATCHES table
  ELSIF (p_run_mode = 'MATCH') THEN
    l_matches_idx_name := substr(p_table_name, 1, 27) || '_ND';

    v_statement := 'CREATE INDEX ' || l_ora_username || '.' || l_matches_idx_name || ' ON ' || p_table_name;
    v_statement := v_statement || ' ( TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) LOCAL ';
    v_statement := v_statement || s_statement;

    EXECUTE IMMEDIATE v_statement;

    -- debug message
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.match',
                     'Done creating index for MATCH table');
    END IF;
*/

  -- index for WINNERS table
  ELSIF (p_run_mode = 'WINNER') THEN
    l_winners_idx_name := substr(p_table_name, 1, 27) || '_ND';

    v_statement := 'CREATE INDEX ' || l_ora_username ||'.' || l_winners_idx_name || ' ON ' || p_table_name;
    v_statement := v_statement || ' ( TRANS_OBJECT_ID, RESOURCE_ID, GROUP_ID ) LOCAL ';
    v_statement := v_statement || s_statement;

    EXECUTE IMMEDIATE v_statement;

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.winner',
                     'Done creating index for WINNER table');

/* no index is created on l1->5 and wt tables as these tables are always accessed with full table scan
  -- index for TEMP WINNER table
  ELSIF (p_run_mode = 'TEMP_WINNER') THEN
    l_matches_idx_name := substr(p_table_name, 1, 27) || '_ND';

    v_statement := 'CREATE INDEX ' ||l_ora_username || '.' || l_matches_idx_name || ' ON ' || p_table_name;
    v_statement := v_statement || ' ( TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) LOCAL ';
    v_statement := v_statement || s_statement;

    EXECUTE IMMEDIATE v_statement;

    -- debug message
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.temp_winner',
                     'Done creating index for TEMP WINNER table');
    END IF;
*/

  END IF; /* end IF (p_run_mode = 'TRANS') */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.create_index.end',
                   'End of the procedure jty_tae_index_creation_pvt.create_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.no_data_found',
                     'API jty_tae_index_creation_pvt.create_index has failed with no_data_found');

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.g_exc_error',
                     'jty_tae_index_creation_pvt.create_index has failed with G_EXC_ERROR exception');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.create_index.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END CREATE_INDEX;

PROCEDURE DROP_TABLE_INDEXES( p_table_name     IN   VARCHAR2
                            , x_return_status  OUT NOCOPY  VARCHAR2 ) IS

  v_statement      varchar2(800);

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  Cursor getIndexList(cl_table_name varchar2, cl_jtf_schema varchar2) IS
  SELECT aidx.owner, aidx.INDEX_NAME
  FROM   DBA_INDEXES aidx
  WHERE  aidx.table_name = cl_table_name
  AND    aidx.table_owner = cl_jtf_schema
  AND aidx.index_name not in ('JTF_TAE_TN1002_CASE_N1W', 'JTF_TAE_TN1003_CASE_N1W', 'JTF_TAE_TN1004_CASE_N1W', 'JTF_TAE_TN1105_CASE_N1W', 'JTF_TAE_TN1106_CASE_N1W');

  L_SCHEMA_NOTFOUND  EXCEPTION;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.drop_table_indexes.begin',
                   'Start of the procedure jty_tae_index_creation_pvt.drop_table_indexes ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  -- for each index
  FOR idx IN getIndexList(p_table_name, l_jtf_schema) LOOP

    v_statement := 'DROP INDEX ' || idx.owner || '.' || idx.index_name;

    EXECUTE IMMEDIATE v_statement;

  END LOOP;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.drop_table_indexes.end',
                   'End of the procedure jty_tae_index_creation_pvt.drop_table_indexes ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.drop_table_indexes.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.drop_table_indexes.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END DROP_TABLE_INDEXES;


PROCEDURE TRUNCATE_TABLE( p_TABLE_NAME     IN   VARCHAR2,
                          x_return_status  OUT NOCOPY  VARCHAR2 )
IS

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  v_statement      varchar2(200);

  L_SCHEMA_NOTFOUND  EXCEPTION;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.truncate_table.start',
                   'Start of the procedure jty_tae_index_creation_pvt.truncate_table ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  v_statement := 'TRUNCATE TABLE ' || l_jtf_schema || '.' || p_TABLE_NAME || ' DROP STORAGE';
  EXECUTE IMMEDIATE v_statement;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.truncate_table.end',
                   'End of the procedure jty_tae_index_creation_pvt.truncate_table ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.truncate_table.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END TRUNCATE_TABLE;


PROCEDURE ANALYZE_TABLE_INDEX( p_table_name      IN  VARCHAR2,
                               p_percent         IN  NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2 )
IS

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  L_SCHEMA_NOTFOUND  EXCEPTION;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.analyze_table_index.start',
                   'Start of the procedure jty_tae_index_creation_pvt.analyze_table_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  FND_STATS.GATHER_TABLE_STATS(
              ownname     => l_jtf_schema,
              tabname     => P_TABLE_NAME,
              percent     => P_PERCENT,
              degree => null,
              partname => null,
              backup_flag => null,
              cascade => null,
              granularity =>'DEFAULT',
              hmode => 'FULL'
              );

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_tae_index_creation_pvt.analyze_table_index.end',
                   'End of the procedure jty_tae_index_creation_pvt.analyze_table_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.analyze_table_index.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_tae_index_creation_pvt.analyze_table_index.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END ANALYZE_TABLE_INDEX;


END jty_tae_index_creation_pvt;

/
