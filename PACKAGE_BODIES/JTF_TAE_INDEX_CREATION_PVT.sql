--------------------------------------------------------
--  DDL for Package Body JTF_TAE_INDEX_CREATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TAE_INDEX_CREATION_PVT" AS
/*$Header: jtftaeib.pls 120.2.12010000.2 2008/11/25 12:59:05 gmarwah ship $*/
/* --  ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:  JTF_TAE_INDEX_CREATION_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package will contain package body for calculating selectivity,
--      and for creating indices on columns
--
--    PROCEDURES:
--         (see below for specification)
--
--    NOTES
--      This package is private available for use
--
--    HISTORY
--      05/02/2002    SHLI         Created
--      06/02/2002    EIHSU        Additional Indexes created when first column is CNR
--                                 with FIRST_CHAR column used.
--      08/14/2002    EIHSU        Add special static index creation logic
--      11/05/2002    JDOCHERT     FIX FOR BUG#2589890
--      06/10/2003    EIHSU        added worker_id
--      09/07/2004    ACHANDA      Fix Bug# 3872853
--      12/07/2004    ACHANDA      Fix Bug # 4048033 : remove default parameters while calling to fnd_stats
--      05/17/2005    ACHANDA      Fix Bug # 4385668 : addded a new procedure create_index_wo_worker_id for new mode
--      08/17/2006    SOLIN        Port 11.5.10 bugs to R12, bug 5470771
--
--    End of Comments
-- */

first_char_col_name varchar2(50) := 'SQUAL_FC01';

/**
 * Procedure   :  Groupstddev
 * Type        :  Private
 * Pre_reqs    :
 * Description :  standard deviation on group
 * Parameters  :
 * input parameters
 *      column_name : column name
 * output parameters
 *      standard deviation
 */
FUNCTION Groupstddev( p_table_name IN varchar2, p_column_name IN varchar2 ) return number IS
  v_statement varchar2(250);
  g_stddev    number;

                errbuf           varchar2(3000);

    l_dop            NUMBER;

BEGIN

  /* get default Degree of Parallelism */
  SELECT MIN(TO_NUMBER(v.value))
  INTO l_dop
  FROM v$parameter v
  WHERE v.name = 'parallel_max_servers'
      OR v.name = 'cpu_count';

  v_statement := 'SELECT /*+ PARALLEL(JTF_TAE_TRANS_OBJS_GROUP, ' || l_dop ||') */ stddev(x) ';
  v_statement := v_statement || ' FROM ( SELECT /*+ PARALLEL(' || p_table_name || ' ,'|| l_dop ||') */ COUNT(*) x ';
  v_statement := v_statement || ' FROM ' ||p_table_name ;
  v_statement := v_statement || ' GROUP BY ' || p_column_name;
  v_statement := v_statement || ') JTF_TAE_TRANS_OBJS_GROUP ';

  EXECUTE IMMEDIATE v_statement into g_stddev;

  return g_stddev;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.GROUPSTDDEV: [END] NO_DATA_FOUND: ' ||
                SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

     RETURN -1;

  WHEN OTHERS THEN

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.GROUPSTDDEV: [END] OTHERS: ' ||
                SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     END IF;

     RETURN -1;

END Groupstddev;




/**
 * Procedure   :  JTF_TAE_SORT
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
PROCEDURE Bubble_SORT (     v_sele IN OUT NOCOPY value_varray,
                            v_name IN OUT NOCOPY name_varray,
                            std_dev    IN OUT NOCOPY value_varray,
                            flag       IN OUT NOCOPY value_varray,
                            numcol IN     NUMBER) IS
temp number;
i integer;
k integer;
ch varchar2(25);

BEGIN
-- bubble sort
for j in 1..numcol loop
  for i in 1..numcol-1 loop
    if v_sele(i) > v_sele(i+1) then
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
    end if;
  end loop;
end loop;

END Bubble_SORT;





/**
 * Procedure   :  CAL_SELECTIVITY
 * Type        :  Private
 * Pre_reqs    :
 * Parameters  :
 * input
 *         table_name
 *        v_colname   : array of column name
 *        numcol      : number of name
 * output
 *        v_colname   : array of sorted column name by selectivity
 *        o_sel       : array of odinal selectivity
 *        std_dev     : array of standard deviation
 */
FUNCTION CAL_SELECTIVITY(   p_table_name IN            varchar2,
                            v_colname    IN OUT NOCOPY name_varray,
                            o_sel        IN OUT NOCOPY value_varray,
                            std_dev      IN OUT NOCOPY value_varray,
                            flag         IN OUT NOCOPY value_varray,
                            numcol       IN integer) return number IS

    v_cardinality   number;
    v_statement     varchar2(250);
    ch              varchar2(25);
    stddev0         integer;
    stddev1         integer;
    i               integer;
    j               integer;
    n               integer;

    errbuf           varchar2(3000);

    l_dop            NUMBER;

BEGIN

  /* get default Degree of Parallelism */
  SELECT MIN(TO_NUMBER(v.value))
  INTO l_dop
  FROM v$parameter v
  WHERE v.name = 'parallel_max_servers'
      OR v.name = 'cpu_count';

    -- cardinality
    /* JDOCHERT: 04/10/03: bug#2607186 */
    v_statement := ' SELECT NVL(dt.NUM_ROWS,1) FROM dba_tables dt ' ||
                  ' WHERE dt.owner = UPPER(:b_schema) ' ||
                  '  AND dt.table_name = UPPER(:b_table_name) ';
    EXECUTE IMMEDIATE v_statement
    INTO v_cardinality
    USING 'JTF', p_table_name;

    if v_cardinality = 0 then return 0;
    end if;

    /* JDOCHERT: 04/10/03: bug#2607186 */
    FOR i IN 1 ..numcol LOOP

      v_statement :=
        ' SELECT 100 - (NVL(dtc.num_distinct,1)*100/:b_cardinality) ' ||
        ' FROM dba_tab_columns dtc ' ||
        ' WHERE dtc.owner = UPPER(:b_schema) ' ||
        '  AND dtc.table_name = UPPER(:b_table_name) ' ||
        '  AND dtc.column_name = UPPER(:b_col_name) ';

      IF flag(i) = 1 THEN
          EXECUTE IMMEDIATE v_statement
          INTO o_sel(i)
          USING v_cardinality, 'JTF', p_table_name, v_colname(i);
      END IF;

    END LOOP;


    -- sort
    Bubble_SORT(o_sel, v_colname, std_dev ,flag, numcol);

    -- calculate standard deviation
    /* JDOCHERT: 04/10/03: bug#2607186 */
    /*for i IN 1..numcol-1 loop
      if o_sel(i)*1.02 >= o_sel(i+1) then
        -- for two similar selectivity
        -- compare and reverse
        if flag(i)=1 or std_dev(i)is null
           then   n := Groupstddev(p_table_name, v_colname(i)  );
                  if n=-1 then

                     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CAL_SELECTIVITY: [1]: Call to GROUPSTDDEV failed.';

                     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
                        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
                     end if;
                     return 0;
                  end if;
                  std_dev(i)  :=n;
        end if;
        if flag(i+1)=1 or std_dev(i+1)is null
           then   n := Groupstddev(p_table_name, v_colname(i+1)  );
                  -- -1 : error
                  if n=-1 then

                     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CAL_SELECTIVITY: [2]: Call to GROUPSTDDEV failed.';

                     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
                        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
                     end if;

                     return 0;

                  end if;
                  std_dev(i+1)  :=n;
        end if;
        if std_dev(i) > std_dev(i+1) then
              ch := v_colname(i);
              v_colname(i) := v_colname(i+1);
              v_colname(i+1) :=ch;
              j:= o_sel(i);
              o_sel(i) := o_sel(i+1);
              o_sel(i+1) :=j;
              j:= std_dev(i);
              std_dev(i) := std_dev(i+1);
              std_dev(i+1) :=j;
              j:= flag(i);
              flag(i) := flag(i+1);
              flag(i+1) :=j;
        end if;
      end if;
    end loop;
    */ /* JDOCHERT: 04/10/03: bug#2607186 */

  RETURN 1;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CAL_SELECTIVITY: [END] NO_DATA_FOUND: ' ||
                SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

     RETURN 0;

  WHEN OTHERS THEN

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CAL_SELECTIVITY: [END] OTHERS: ' ||
                SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     END IF;

     RETURN 0;


END CAL_SELECTIVITY;


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
 * return
 *      0: no data in JTF_TAE_QUAL_FACTORS
 *      1: success
 */

FUNCTION SELECTIVITY(p_TABLE_NAME IN VARCHAR2) return number IS

errbuf           varchar2(3000);

col_name name_varray :=  name_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
o_sel    value_varray:= value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
std_dev  value_varray:= value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
sele     value_varray:= value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
flag     value_varray:= value_varray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
i       integer;
j       integer;

Cursor getColumnName IS
    SELECT
    DISTINCT A.TAE_COL_MAP                 sqname,
             A.INPUT_DEVIATION             dev,
             A.INPUT_ORDINAL_SELECTIVITY   ord_sele,
             A.INPUT_SELECTIVITY           sele,
             decode(A.UPDATE_SELECTIVITY_FLAG,'Y',1,0) flag
    FROM JTF_TAE_QUAL_FACTORS A
    WHERE A.USE_TAE_COL_IN_INDEX_FLAG = 'Y'
      AND A.TAE_COL_MAP is not null ;


BEGIN

    i:=1;

    -- get all distinct column name
    j :=0;
    for qual_info in getColumnName LOOP
        col_name(i) := qual_info.sqname;
        o_sel(i)    := qual_info.ord_sele;
        std_dev(i)  := qual_info.dev;
        flag(i)     := qual_info.flag;
        if flag(i) = 1 then j:=1; end if;
        i := i + 1;
    end loop;

    -- no valid column name, or all flag = No, return 1
    if i=1 or j=0 then return 1;
    end if;


    -- calculate selectivity
    if CAL_SELECTIVITY(p_table_name, col_name, o_sel, std_dev, flag, i-1) = 0
        then return 0;
    end if;

    -- update JTF_TAE_QUAL_FACTORS
    for i IN 1..col_name.count loop
        UPDATE JTF_TAE_QUAL_FACTORS
        SET INPUT_SELECTIVITY           = i,
            INPUT_ORDINAL_SELECTIVITY   = o_sel(i),
            INPUT_DEVIATION             = std_dev(i)
        WHERE  TAE_COL_MAP = col_name(i);
    end loop;

    commit;
    RETURN 1;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.SELECTIVITY: [END] NO_DATA_FOUND: ' ||
                SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

      RETURN 0;

  WHEN OTHERS THEN

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.SELECTIVITY: [END] OTHERS: ' ||
                SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     END IF;

     RETURN 0;

END SELECTIVITY;


/**
 * Procedure   :  CREATE_INDEX_FOR_NM
 * Type        :  private
 * Pre_reqs    :
 * Description :  index creation on TRANS table for new mode
 * output      :  indices created on JTF_TAE_OBJECT_INPUT
 * return  0: failure
 *         1: success
 */
procedure CREATE_INDEX_WO_WORKER_ID ( p_table_name           IN  VARCHAR2,
                                      p_s_statement          IN  VARCHAR2,
                                      x_Return_Status        OUT NOCOPY VARCHAR2 ) IS

  CURSOR index_name_c (p_table_name VARCHAR2, p_owner VARCHAR2) IS
  select din.index_name, din.owner
  from dba_indexes din
  where din.table_name = p_table_name
  and din.table_owner = p_owner
  and exists (
    select 1
    from   dba_ind_columns dic
    where  din.index_name = dic.index_name
    and    dic.index_owner = p_owner
    and    dic.column_name = 'WORKER_ID'
    and    dic.column_position = 1 );

  CURSOR column_name_c (p_index_name VARCHAR2, p_owner VARCHAR2) IS
  select column_name,  column_position
  from dba_ind_columns
  where index_name = p_index_name
  and   index_owner = p_owner
  and column_position <> 1
  order by column_position;

  TYPE l_index_name_type IS TABLE OF dba_indexes.index_name%TYPE;
  TYPE l_owner_type IS TABLE OF dba_indexes.owner%TYPE;
  TYPE l_column_name_type IS TABLE OF dba_ind_columns.column_name%TYPE;
  TYPE l_column_position_type IS TABLE OF dba_ind_columns.column_position%TYPE;

  l_index_name  l_index_name_type;
  l_owner       l_owner_type;
  l_column_name l_column_name_type;
  l_column_position l_column_position_type;

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);
  l_statement      VARCHAR2(2000);
  alter_statement  VARCHAR2(2000);
  l_new_index_name VARCHAR2(30);
  errbuf           varchar2(3000);

  l_no_of_indexes  NUMBER;
  l_no_of_columns  NUMBER;

  L_SCHEMA_NOTFOUND  EXCEPTION;

BEGIN

  /* Get the JTF schema name */
  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  /* Get all the index name having worker_id as the first column */
  OPEN index_name_c(p_table_name, l_jtf_schema);

  FETCH index_name_c BULK COLLECT INTO
     l_index_name
    ,l_owner;

  CLOSE index_name_c;

  l_no_of_indexes := l_index_name.COUNT;

  if (l_no_of_indexes > 0) then
    FOR i IN l_index_name.FIRST .. l_index_name.LAST LOOP
      if (length(l_index_name(i)) >= 30) then
        jtf_tae_control_pvt.write_log(2, 'New Mode index corresponding to index ' || l_index_name(i) || ' is not created.');

      else
        /* Get all the column names for the index except worker_id */
        OPEN column_name_c(l_index_name(i), l_owner(i));

        FETCH column_name_c BULK COLLECT INTO
          l_column_name, l_column_position;

        CLOSE column_name_c;

        l_no_of_columns := l_column_name.COUNT;

        if (l_no_of_columns > 0) then
          l_new_index_name := l_index_name(i) || 'I';
          l_statement := 'CREATE INDEX ' || l_owner(i) ||'.' || l_new_index_name || ' ON ' || p_table_name || ' ( ';

          FOR j IN l_column_name.FIRST .. l_column_name.LAST LOOP
            if (l_column_name(j) = l_column_name(1)) then
              l_statement := l_statement || l_column_name(j);
            else
              l_statement := l_statement || ',' || l_column_name(j);
            end if;
          END LOOP;

          l_statement := l_statement || ' ) ' || p_s_statement;

          execute immediate l_statement;

          alter_statement := 'ALTER INDEX ' || l_owner(i) || '.' || l_new_index_name ||' NOPARALLEL';

          execute immediate alter_statement;

          l_column_name.TRIM(l_no_of_columns);
          l_column_position.TRIM(l_no_of_columns);
        end if;
      end if;
    END LOOP;
      l_index_name.TRIM(l_no_of_indexes);
      l_owner.TRIM(l_no_of_indexes);
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX_WO_WORKER_ID: [END] SCHEMA NAME FOUND CORRESPONDING TO JTF APPLICATION. ';

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

  WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX_WO_WORKER_ID: [END] OTHERS: ' ||
                p_table_name || ': ' || SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

END CREATE_INDEX_WO_WORKER_ID;


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
procedure CREATE_INDEX ( p_table_name           IN  VARCHAR2,
                         p_trans_object_type_id IN  NUMBER,
                         p_source_id            IN  NUMBER,
                         x_Return_Status        OUT NOCOPY VARCHAR2,
                         p_run_mode             IN VARCHAR2 := 'TAP' ) IS

    errbuf           varchar2(3000);

    i           integer;
    j           integer;
    pid         number;

    v_statement varchar2(2000);
    s_statement varchar2(2000);
    /* ARPATEL Bug#3597884 05/10/2004 */
    alter_statement varchar2(2000);

    l_table_tablespace  varchar2(100);
    l_idx_tablespace    varchar2(100);
    l_ora_username      varchar2(100);
    l_app_short_name    varchar2(20) := 'JTF';

    l_trans_idx_name    varchar2(30);
    l_matches_idx_name  varchar2(30);
    l_winners_idx_name  varchar2(30);

    lx_4841_idx_created varchar2(1) := 'N';
    lx_324347_idx_created varchar2(1) := 'N';
    prd_nulltae_mul_of_4841 varchar2(1) := 'N';
    prd_nulltae_mul_of_324347 varchar2(1) := 'N';

    lx_rev_4841_idx_created varchar2(1) := 'N';
    lx_rev_324347_idx_created varchar2(1) := 'N';
    prd_rev_nulltae_mul_of_4841 varchar2(1) := 'N';
    prd_rev_nulltae_mul_of_324347 varchar2(1) := 'N';

    l_create_index_flag varchar2(1):= 'Y';

    /* JDOCHERT: 04/18/02: Modified to
    ** get count of number of territories
    ** for each qualifier combination
    *
    */
    Cursor getProductList IS
    SELECT  P.qual_product_id         qual_product_id,

            /* JDOCHERT: 08/04/02: Added RELATION_PRODUCT to Cursor */
            p.RELATION_PRODUCT        RELATION_PRODUCT,

            MAX(p.index_name)         index_name,
            MAX(p.first_char_flag)    first_char_flag,
            COUNT(r.qual_factor_id)   cartesian_terr_X_factors
    FROM      jtf_terr_denorm_rules_all d
              ,jtf_terr_qtype_usgs_all jtqu
	      ,jtf_qual_type_usgs_all jqtu
            ,JTF_TAE_QUAL_PRODUCTS P
            , JTF_TAE_QUAL_PROD_FACTORS R
    WHERE   /* ARPATEL 01/06/2004 bug#3337382: use qual_relation_factor in jtf_terr_qtype_usgs_all */
            --d.qual_relation_product = p.relation_product
	    jtqu.qual_relation_product = p.relation_product
            AND jqtu.source_id = d.source_id
	    AND jqtu.qual_type_id = p.trans_object_type_id
	    AND d.terr_id = jtqu.terr_id
	    AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
        --and     d.terr_id = d.related_terr_id
    /* ARPATEL: 12/09/2003 denorm_rules_all is no longer striped by TX id for Oracle Sales */
    --AND     d.qual_type_id = p.trans_object_type_id
    AND     d.source_id = p.source_id
    AND     P.qual_product_id = R.qual_product_id
    AND     P.BUILD_INDEX_FLAG = 'Y'
    AND     p.TRANS_OBJECT_TYPE_ID = p_trans_object_type_id
    AND     P.SOURCE_ID = p_source_id
    GROUP BY P.qual_product_id, p.RELATION_PRODUCT
    ORDER BY cartesian_terr_X_factors DESC, first_char_flag;


    Cursor  getFactorList IS
    SELECT      distinct TAE_COL_MAP, J2.INPUT_SELECTIVITY
    FROM        JTF_TAE_QUAL_PRODUCTS J3,
                JTF_TAE_QUAL_FACTORS J2,
                JTF_TAE_QUAL_PROD_FACTORS J1
    WHERE       J1.qual_product_id = pid
                and J1.qual_product_id = J3.qual_product_id
                and J1.qual_factor_id = J2.qual_factor_id
                -- and J1.qual_usg_id = J2.qual_usg_id
                and J2.USE_TAE_COL_IN_INDEX_FLAG = 'Y'
    ORDER BY    J2.INPUT_SELECTIVITY;


    Cursor extraIndexCandidates IS
        SELECT  P.qual_product_id         qual_product_id,

                /* JDOCHERT: 08/04/02: Added RELATION_PRODUCT to Cursor */
                p.RELATION_PRODUCT        RELATION_PRODUCT,

                p.index_name         index_name,
                p.first_char_flag    first_char_flag,
                rownum               index_counter
        FROM    JTF_TAE_QUAL_PRODUCTS P
        WHERE   P.BUILD_INDEX_FLAG = 'Y'
        AND     P.FIRST_CHAR_FLAG = 'Y'
        AND     p.TRANS_OBJECT_TYPE_ID = p_trans_object_type_id
        AND     P.SOURCE_ID = p_source_id;

    Cursor  getReverseFactorList IS
        select  f.tae_col_map, qual_usg_id, input_selectivity
        from    jtf_tae_qual_prod_factors pf,
                jtf_tae_qual_factors f
        where   qual_product_id = pid
            and f.qual_factor_id = pf.qual_factor_id
            and f.tae_col_map is not null
        order by input_selectivity desc;

    Cursor verifyProdNonNullTAEColMaps(cp_product NUMBER, cp_non_null_tae_col_maps NUMBER) IS
        -- this cursor should only return one row since
        -- it fetches one product and its details
        select NON_NULL_TAE_COL_MAPS, RELATION_PRODUCT
        from (
            select  count(*) NON_NULL_TAE_COL_MAPS,
                    p.qual_product_id QUAL_PRODUCT_ID,
                    p.relation_product RELATION_PRODUCT
            from JTF_TAE_QUAL_products p,
                 JTF_TAE_QUAL_prod_factors pf,
                 JTF_TAE_QUAL_FACTORS f
            where p.qual_product_id = pf.qual_product_id
                and pf.qual_factor_id = f.qual_factor_id
                and p.source_id = p_source_id
                and p.trans_object_type_id = p_trans_object_type_id
                and p.relation_product > 0
                and tae_col_map is not null
                and p.relation_product = cp_product
            group by p.qual_product_id, p.relation_product
            )
        where NON_NULL_TAE_COL_MAPS = cp_non_null_tae_col_maps;

    l_dop            NUMBER;

BEGIN

  /* get default Degree of Parallelism */
  SELECT MIN(TO_NUMBER(v.value))
  INTO l_dop
  FROM v$parameter v
  WHERE v.name = 'parallel_max_servers'
      OR v.name = 'cpu_count';

    SELECT i.tablespace, i.index_tablespace, u.oracle_username
    INTO l_table_tablespace, l_idx_tablespace, l_ora_username
    FROM fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE a.application_short_name = 'JTF'
      AND a.application_id = i.application_id
      AND u.oracle_id = i.oracle_id;

/* JDOCHERT: 08/17/02: INTERNAL'S HARDCODED TABLESPACE FOR TAP */
--    l_idx_tablespace :='TAP';
--
    -- default INDEX STORAGE parameters
    s_statement := s_statement || ' TABLESPACE ' ||  l_idx_tablespace ;
    s_statement := s_statement || ' STORAGE(INITIAL 1M NEXT 1M MINEXTENTS 1 MAXEXTENTS UNLIMITED ';
    s_statement := s_statement || ' PCTINCREASE 0 FREELISTS 4 FREELIST GROUPS 4 BUFFER_POOL DEFAULT) ';
    s_statement := s_statement || ' PCTFREE 10 INITRANS 10 MAXTRANS 255 ';

    /* JDOCHERT: 04/10/03: bug#2896552 */
    s_statement := s_statement || ' COMPUTE STATISTICS ';

    s_statement := s_statement || ' NOLOGGING PARALLEL ' || l_dop;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- indexes for TRANS table
    IF ( UPPER(p_table_name) LIKE 'JTF_TAE%_TRANS') THEN
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Creating index for TRANS table');

        /* CREATE Static UNIQUE KEY Index */
        -- OIC processing
        IF p_run_mode = 'OIC_TAP' THEN
            l_trans_idx_name := 'JTF_TAE_TN' || ABS(p_trans_object_type_id) || '_UK_NDSC';
        -- NEW_MODE_PROCESSING
        ELSIF p_run_mode = 'NEW_MODE_TAP' THEN
            l_trans_idx_name := 'JTF_TAE_TN' || ABS(p_trans_object_type_id) || '_UK_NDW';
        ELSE
            l_trans_idx_name := 'JTF_TAE_TN' || ABS(p_trans_object_type_id) || '_UK_ND';
        END IF;

        /* ARPATEL 04/26/2004 GSCC error for hardcoded schema name */
        --v_statement := 'CREATE INDEX JTF.' || l_trans_idx_name || ' ON ' || p_table_name;
        v_statement := 'CREATE INDEX ' || l_ora_username ||'.' || l_trans_idx_name || ' ON ' || p_table_name;

        -- EIHSU: added worker_id 06/12/2003
        v_statement := v_statement || ' ( ' || 'WORKER_ID, ' ||'TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) ';
        v_statement := v_statement || s_statement;

        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Creating index on trans table with statement : ' || v_statement);
        EXECUTE IMMEDIATE v_statement;
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Done creating index');

        /* ARPATEL Bug#3597884 05/10/2004 */
        alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';
        EXECUTE IMMEDIATE alter_statement;


        /* Create Qualifier Combination Dynamic Indexes */
        FOR prd IN getProductList LOOP
            l_create_index_flag := 'Y';
            -- EIHSU 08/14/02: Set flags for determining if relation_prods
            -- are NULL TAE_COL_MAP multiples of the specific QCombinations
            -- as described by JDOCHERT 08/04/02

            /* INDEX CREATION LOGIC PREPROCESSING */
            prd_nulltae_mul_of_4841 := 'N';
            prd_nulltae_mul_of_324347 := 'N';

            /* EIHSU:
                VERY VERY VERY IMPORTANT:
                    Because some of these special products are actually
                    MULTIPLES of other special prodcuts, it is IMPERATIVE
                    THAT the special products with LARGER NUMBER OF FACTORS BE LISTED
                    FIRST IN THE FOLLOWING LOGIC.  If this is not clear, consult me
                    before modifying.
            */

            /* ARPATEL 04/15/2004
            ** Added 353393 below as this qual_relation_product uses Customer Name Range GROUP
            ** Therefore this combination needs to use the same index as 324347
            */
            IF mod(prd.RELATION_PRODUCT, 324347) = 0 OR mod(prd.RELATION_PRODUCT, 353393) = 0 THEN
                for verifiedProd in verifyProdNonNullTAEColMaps(prd.RELATION_PRODUCT, 3) loop
                    prd_nulltae_mul_of_324347 := 'Y';
                end loop;
            ELSIF mod(prd.RELATION_PRODUCT, 4841) = 0 THEN
                for verifiedProd in verifyProdNonNullTAEColMaps(prd.RELATION_PRODUCT, 2) loop
                    prd_nulltae_mul_of_4841 := 'Y';
                end loop;
            END IF;

            --dbms_output.put_line('processing ' || prd.relation_product);
            --dbms_output.put_line(' prd_nulltae_mul_of_4841 =' || prd_nulltae_mul_of_4841);
            --dbms_output.put_line(' prd_nulltae_mul_of_324347 = ' || prd_nulltae_mul_of_324347);
            /* INDEX CREATION METHOD LOGIC */
            IF (prd_nulltae_mul_of_4841 = 'Y') THEN
                /* JDOCHERT: 08/04/02:
                ** Get Static STANDARD INDEX Definition
                ** for specific Qualifier Combinations:
                ** 4841 = Postal Code + Country
                */
                --dbms_output.put_line('  rel product ' || prd.relation_product || ' special name');
                IF (lx_4841_idx_created = 'N') THEN
                    --dbms_output.put_line('    generating 4841 index ');

                    JTF_TAE_SQL_LIB_PVT.get_qual_comb_index (
                          p_rel_prod               => 4841,
                          p_reverse_flag           => 'N',
                          p_source_id              => p_source_id,
                          p_trans_object_type_id   => p_trans_object_type_id,
                          p_table_name             => p_table_name,
                          p_run_mode               => p_run_mode, --ARPATEL 09/09/2003
                          x_statement              => V_STATEMENT,
                          alter_statement          => ALTER_STATEMENT );

                    lx_4841_idx_created := 'Y';
                ELSE
                    l_create_index_flag := 'N';
                END IF;

            ELSIF (prd_nulltae_mul_of_324347 = 'Y') THEN
                --dbms_output.put_line('  rel product ' || prd.relation_product || ' special name');

                IF (lx_324347_idx_created = 'N') THEN
                    /* JDOCHERT: 08/04/02:
                    ** Get Static STANDARD INDEX Definition
                    ** for specific Qualifier Combinations:
                    ** 324347 = Customer Name Range + Postal Code + Country Combination
                    */
                    --dbms_output.put_line('    generating 324347 index N');
                    JTF_TAE_SQL_LIB_PVT.get_qual_comb_index (
                          p_rel_prod               => 324347,
                          p_reverse_flag           => 'N',
                          p_source_id              => p_source_id,
                          p_trans_object_type_id   => p_trans_object_type_id,
                          p_table_name             => p_table_name,
                          p_run_mode               => p_run_mode, --ARPATEL 09/09/2003
                          x_statement              => V_STATEMENT,
                          alter_statement          => ALTER_STATEMENT );

                    lx_324347_idx_created := 'Y';
                ELSE
                    l_create_index_flag := 'N';
                END IF;

            ELSE
                --dbms_output.put_line('  rel product ' || prd.relation_product || ' standard name');
                -- OIC processing
                IF p_run_mode = 'OIC_TAP' THEN
                    /* ARPATEL 04/26/2004 GSCC error for hardcoded schema name */
                    --v_statement := 'CREATE INDEX JTF.' || prd.index_name || 'SC' || ' ON ' || p_table_name || '( ';
                    v_statement := 'CREATE INDEX '|| l_ora_username ||'.' || prd.index_name || 'SC' || ' ON ' || p_table_name || '( ';
                -- NEW_MODE_PROCESSING (MISSING INDEX FOR N4)
                ELSIF p_run_mode = 'NEW_MODE_TAP' THEN
                    --v_statement := 'CREATE INDEX JTF.' || prd.index_name || 'W' || ' ON ' || p_table_name || '( ';
                    v_statement := 'CREATE INDEX ' || l_ora_username || '.' || prd.index_name || 'W' || ' ON ' || p_table_name || '( ';
                ELSE
                    /* ARPATEL 04/26/2004 GSCC error for hardcoded schema name */
                    --v_statement := 'CREATE INDEX JTF.' || prd.index_name ||' ON ' || p_table_name || '( ';
                    v_statement := 'CREATE INDEX ' || l_ora_username || '.' || prd.index_name ||' ON ' || p_table_name || '( ';
                END IF;

                -- EIHSU: 06/12/2003: add worker_id
                v_statement := v_statement || 'WORKER_ID, ';
                if prd.first_char_flag = 'Y'
                        then v_statement := v_statement || first_char_col_name || ',';
                end if;
                pid := prd.qual_product_id;
                j:=1;

                -- for each factor of product
                for factor IN getFactorList loop
                    if j<>1 then v_statement := v_statement || ',' ;
                    end if;
                    v_statement := v_statement || factor.TAE_COL_MAP;
                    j:=j+1;
                end loop;

                v_statement := v_statement || ') ';

            END IF;

            /* Append Storage Parameter Information to Index Definition */
            v_statement := v_statement || s_statement;

            IF l_create_index_flag = 'Y' THEN
                --dbms_output.put_line('     building index');
                JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Creating index on trans table with statement : ' || v_statement);
                EXECUTE IMMEDIATE v_statement;
                JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Done creating index');

                /* ARPATEL Bug#3597884 05/10/2004 */
                IF prd_nulltae_mul_of_4841 = 'Y' OR prd_nulltae_mul_of_324347 = 'Y'
                THEN
                  EXECUTE IMMEDIATE alter_statement;
                ELSE
                  IF p_run_mode = 'OIC_TAP' THEN
                    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || prd.index_name || 'SC' ||' NOPARALLEL';
                  ELSIF p_run_mode = 'NEW_MODE_TAP' THEN
                    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || prd.index_name || 'W' || ' NOPARALLEL';
                  ELSE
                    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || prd.index_name || ' NOPARALLEL';
                  END IF;
                  EXECUTE IMMEDIATE alter_statement;
                END IF;
            END IF;

        END LOOP;

        -- Additional Indexes for TRANS table - eihsu 03/06/2002
        FOR idxCand in extraIndexCandidates LOOP
            l_create_index_flag := 'Y';

            /* JDOCHERT: 08/04/02:
            ** Get Static REVERSE INDEX Definition
            ** for specific Qualifier Combinations:
            ** 324347 = Customer Name Range + Postal Code + Country Combination
            */
            /* NOTE: REVERSE INDEXES ARE ONLY NECCESSARY WHERE THERE ARE
            ** CUSTOMER NAME RANGE LIKE '%ABC' values defined.
            ** This is because leading '%' means that the STANDARD INDEX
            ** on SQUAL_FC01, SQUAL_CHAR01,... will never be used.
            */

            -- EIHSU 08/14/02: Set flags for determining if relation_prods
            -- are NULL TAE_COL_MAP multiples of the specific QCombinations
            -- as described by JDOCHERT 08/04/02

            /* INDEX CREATION LOGIC PREPROCESSING */
            prd_rev_nulltae_mul_of_324347 := 'N';

            /* EIHSU:
                VERY VERY VERY IMPORTANT:
                    Because some of these special products are actually
                    MULTIPLES of other special prodcuts, it is IMPERATIVE
                    THAT the special products with LARGER NUMBER OF FACTORS BE LISTED
                    FIRST IN THE FOLLOWING LOGIC.  If this is not clear, consult me
                    before modifying.
            */

            /* ARPATEL 04/15/2004
            ** Added 353393 below as this qual_relation_product uses Customer Name Range GROUP
            ** Therefore this combination needs to use the same index as 324347
            */
            IF mod(idxCand.RELATION_PRODUCT, 324347) = 0 OR mod(idxCand.RELATION_PRODUCT, 353393) = 0
            THEN
                for verifiedProd in verifyProdNonNullTAEColMaps(idxCand.RELATION_PRODUCT, 3) loop
                    prd_rev_nulltae_mul_of_324347 := 'Y';
                end loop;
            END IF;

            --dbms_output.put_line('[R]processing ' || idxCand.relation_product);
            --dbms_output.put_line(' [R]prd_nulltae_mul_of_4841 =' || prd_rev_nulltae_mul_of_4841);
            --dbms_output.put_line(' [R]prd_nulltae_mul_of_324347 = ' || prd_rev_nulltae_mul_of_324347);

            /* REV INDEX CREATION METHOD LOGIC */
            IF (prd_rev_nulltae_mul_of_324347 = 'Y') THEN
                --dbms_output.put_line('  [R]rel product ' || idxCand.relation_product || ' special name');

                IF (lx_rev_324347_idx_created = 'N') THEN
                    /* JDOCHERT: 08/04/02:
                    ** Get Static STANDARD INDEX Definition
                    ** for specific Qualifier Combinations:
                    ** 324347 = Customer Name Range + Postal Code + Country Combination
                    */
                    --dbms_output.put_line('    [R]generating 324347 index Y');
                    JTF_TAE_SQL_LIB_PVT.get_qual_comb_index (
                          p_rel_prod               => 324347,
                          p_reverse_flag           => 'Y',
                          p_source_id              => p_source_id,
                          p_trans_object_type_id   => p_trans_object_type_id,
                          p_table_name             => p_table_name,
                          p_run_mode               => p_run_mode, --ARPATEL 09/09/2003
                          x_statement              => V_STATEMENT,
                          alter_statement          => ALTER_STATEMENT );

                    lx_rev_324347_idx_created := 'Y';
                ELSE
                    l_create_index_flag := 'N';
                END IF;

            ELSE
                 -- OIC processing
		 /* ARPATEL BUG#3659444 06/15/2004 */
                IF p_run_mode = 'OIC_TAP' THEN
                    v_statement := 'CREATE INDEX ' || l_ora_username || '.' || idxCand.index_name || 'XS' ||
                                   ' ON ' || p_table_name || '( ';
                -- NEW_MODE_PROCESSING
                ELSIF p_run_mode = 'NEW_MODE_TAP' THEN
                    v_statement := 'CREATE INDEX ' || l_ora_username || '.' || idxCand.index_name || 'XW' ||
                                   ' ON ' || p_table_name || '( ';
                ELSE
                    v_statement := 'CREATE INDEX ' || l_ora_username || '.' || idxCand.index_name || 'X' ||
                                   ' ON ' || p_table_name || '( ';
                END IF;


                -- EIHSU: 06/12/2003: add worker_id
                v_statement := v_statement || 'WORKER_ID, ';

                pid := idxCand.qual_product_id;
                j:=1;

                -- for each factor of product
                for xFactor IN getReverseFactorList loop
                    if j<>1 then v_statement := v_statement || ',' ;
                    end if;
                    v_statement := v_statement || xFactor.TAE_COL_MAP;
                    j:=j+1;
                end loop;

                v_statement := v_statement || ') ';

            END IF;

            v_statement := v_statement || s_statement;

            IF l_create_index_flag = 'Y' THEN
                --dbms_output.put_line('     building rev_ index');
                JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Creating index on trans table with statement : ' || v_statement);
                EXECUTE IMMEDIATE v_statement;
                JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Done creating index');

                /* ARPATEL Bug#3597884 05/10/2004 */
                IF prd_rev_nulltae_mul_of_324347 = 'Y'
                THEN
                  EXECUTE IMMEDIATE alter_statement;
                ELSE
                  IF p_run_mode = 'OIC_TAP' THEN
                    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || idxCand.index_name || 'XS' ||' NOPARALLEL';
                  ELSIF p_run_mode = 'NEW_MODE_TAP' THEN
                    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || idxCand.index_name || 'XW' || ' NOPARALLEL';
                  ELSE
                    alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || idxCand.index_name || 'X' || ' NOPARALLEL';
                  END IF;
                  EXECUTE IMMEDIATE alter_statement;
                END IF;


            END IF;

        END LOOP;

        /* Create the indexes without worker_id column for new mode */
        IF (p_table_name IN ('JTF_TAE_1001_ACCOUNT_TRANS', 'JTF_TAE_1001_LEAD_TRANS', 'JTF_TAE_1001_OPPOR_TRANS')) THEN
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Creating index on trans table with no worker_id');
          CREATE_INDEX_WO_WORKER_ID (  p_table_name
                                      ,s_statement
                                      ,x_Return_Status);
          JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'Done creating index');
        END IF;

/*
    -- index for MATCHES table
    ELSIF ( UPPER(p_table_name) LIKE 'JTF_TAE%_MATCHES') THEN

       l_matches_idx_name := REPLACE( UPPER(p_table_name),'ES',null) || '_ND';

        v_statement := 'CREATE INDEX ' || l_ora_username || '.' || l_matches_idx_name || ' ON ' || p_table_name;
        -- EIHSU: 06/12/2003: add worker_id
        v_statement := v_statement || ' ( WORKER_ID, TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) ';
        v_statement := v_statement || s_statement;

        EXECUTE IMMEDIATE v_statement;
*/
    -- index for WINNERS table
    ELSIF ( UPPER(p_table_name) LIKE 'JTF_TAE%_WINNERS') THEN

        l_winners_idx_name := REPLACE( UPPER(p_table_name),'NERS',null) || '_ND';

        v_statement := 'CREATE INDEX ' || l_ora_username ||'.' || l_winners_idx_name || ' ON ' || p_table_name;

        /* ARPATEL: 02/19/04 BUG#3447689 */
        IF p_run_mode = 'OIC_TAP' THEN
           v_statement := v_statement || ' ( TRANS_OBJECT_ID, RESOURCE_ID, GROUP_ID ) ';
        ELSE
           v_statement := v_statement || ' ( TRANS_OBJECT_ID, RESOURCE_ID, GROUP_ID ) LOCAL';
        END IF;

        v_statement := v_statement || s_statement;

        EXECUTE IMMEDIATE v_statement;

/*
     -- index for MATCHES table
    ELSIF ( UPPER(p_table_name) LIKE 'JTF_TAE%_L1' OR
            UPPER(p_table_name) LIKE 'JTF_TAE%_L2' OR
            UPPER(p_table_name) LIKE 'JTF_TAE%_L3' OR
            UPPER(p_table_name) LIKE 'JTF_TAE%_L4' OR
            UPPER(p_table_name) LIKE 'JTF_TAE%_L5' OR
            UPPER(p_table_name) LIKE 'JTF_TAE%_WT' ) THEN

       l_matches_idx_name := UPPER(p_table_name) || '_ND';

        v_statement := 'CREATE INDEX ' ||l_ora_username || '.' || l_matches_idx_name || ' ON ' || p_table_name;
        -- EIHSU: 06/12/2003: add worker_id
        v_statement := v_statement || ' ( WORKER_ID, TRANS_OBJECT_ID, TRANS_DETAIL_OBJECT_ID ) ';
        v_statement := v_statement || s_statement;

        EXECUTE IMMEDIATE v_statement;
*/
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_ERROR ;

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX: [END] NO_DATA_FOUND: ' ||
                p_table_name || ': ' || SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

  WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.CREATE_INDEX: [END] OTHERS: ' ||
                p_table_name || ': ' || SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

END CREATE_INDEX;

PROCEDURE DROP_TABLE_INDEXES( p_table_name     IN   VARCHAR2
                            , x_return_status  OUT NOCOPY  VARCHAR2 ) IS

    retcode          VARCHAR2(100);
    errbuf           varchar2(3000);
    v_statement      varchar2(800);

    l_status         VARCHAR2(30);
    l_industry       VARCHAR2(30);
    l_jtf_schema     VARCHAR2(30);

    /* JDOCHERT: 5/28/02: Modified to use:
    ** 1. ALL_INDEXES (instead of SYS.DBA_INDEXES)
    ** 2. aidx.table_owner (instead of aidx.owner)
    ** 3. return aidx.owner in SELECT */
    Cursor getIndexList(p_jtf_schema varchar2) IS
    SELECT aidx.owner, aidx.INDEX_NAME
    FROM DBA_INDEXES aidx
    WHERE aidx.table_name = p_table_name
    AND aidx.table_owner = p_jtf_schema
    AND aidx.index_name not in ('JTF_TAE_TN1002_CASE_N1W', 'JTF_TAE_TN1003_CASE_N1W', 'JTF_TAE_TN1004_CASE_N1W');

    L_SCHEMA_NOTFOUND  EXCEPTION;
BEGIN

    IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
      NULL;
    END IF;

    IF (l_jtf_schema IS NULL) THEN
      RAISE L_SCHEMA_NOTFOUND;
    END IF;

    -- for each index
    FOR idx IN getIndexList(l_jtf_schema) LOOP

        v_statement := 'DROP INDEX ' || idx.owner || '.' || idx.index_name;

        EXECUTE IMMEDIATE v_statement;

    END LOOP;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RETCODE := 2;
     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES: [END] SCHEMA NAME FOUND CORRESPONDING TO JTF APPLICATION. ';

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

  WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RETCODE := 2;
     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES: [END] OTHERS: ' ||
                p_table_name || ': ' || SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;


END DROP_TABLE_INDEXES;


PROCEDURE TRUNCATE_TABLE( p_TABLE_NAME     IN   VARCHAR2,
                          x_return_status  OUT NOCOPY  VARCHAR2 ) IS

    retcode          VARCHAR2(100);
    errbuf           varchar2(3000);
    v_statement      varchar2(2000);
    l_ora_username   varchar2(100);

BEGIN
    SELECT u.oracle_username
    INTO l_ora_username
    FROM fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE a.application_short_name = 'JTF'
      AND a.application_id = i.application_id
      AND u.oracle_id = i.oracle_id;

    v_statement := 'TRUNCATE TABLE ' || l_ora_username || '.' || p_TABLE_NAME || ' DROP STORAGE';
    EXECUTE IMMEDIATE v_statement;
    commit;

    --dbms_output.put_line('TAE_INDEX_CREATION .truncate_tablee: v_statement =  ' || v_statement);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RETCODE := 2;
     ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE: [END] OTHERS: ' ||
                p_table_name || ': ' || SQLERRM;

     If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
     End If;

END TRUNCATE_TABLE;


/* JDOCHERT: 11/05/02: FIX FOR BUG#2589890 */
PROCEDURE ANALYZE_TABLE_INDEX( p_TABLE_NAME      IN  VARCHAR2,
                               P_PERCENT         IN  NUMBER,
                               x_return_status  OUT NOCOPY  VARCHAR2 ) IS

    retcode          VARCHAR2(100);
    errbuf           varchar2(3000);

    l_dop            NUMBER;

BEGIN

  /* get default Degree of Parallelism */
  SELECT MIN(TO_NUMBER(v.value))
  INTO l_dop
  FROM v$parameter v
  WHERE v.name = 'parallel_max_servers'
      OR v.name = 'cpu_count';

  --dbms_output.put_line('Degree of Parallelism = '||TO_CHAR(l_dop));

  FND_STATS.GATHER_TABLE_STATS(
              ownname     => 'JTF',
              tabname     => P_TABLE_NAME,
              percent     => P_PERCENT,
              degree => null,
              partname => null,
              backup_flag => null,
              cascade => null,
              granularity =>'DEFAULT',
              hmode => 'FULL'

              );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RETCODE := 2;
    ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX: [END] OTHERS: ' ||
                p_table_name || ': ' || SQLERRM;

    If JTF_TAE_CONTROL_PVT.G_DEBUG Then
        JTF_TAE_CONTROL_PVT.WRITE_LOG(2, ERRBUF);
    End If;

END ANALYZE_TABLE_INDEX;


END JTF_TAE_INDEX_CREATION_PVT;

/
