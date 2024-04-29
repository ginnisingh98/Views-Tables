--------------------------------------------------------
--  DDL for Package Body FND_XDF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_XDF_UTIL_PKG" as
/* $Header: fndpxutb.pls 120.4.12010000.2 2009/10/10 02:04:19 smadhapp ship $ */

/* The function receives the list of columns as the argument and returns an
 * array of numbers containing hash values corresopnding to each of the
 * columns.
 */
function get_hashcode_table( p_tablename in varchar2 ,
                             p_owner in varchar2,
                             p_columns_list out NOCOPY FND_XDF_TABLE_OF_VARCHAR2_30,
                             table_hash_val out NOCOPY number )
    return FND_XDF_TABLE_OF_NUMBER is
    l_hashVal number;
    l_hashCode_List FND_XDF_TABLE_OF_NUMBER := FND_XDF_TABLE_OF_NUMBER();
    l_column_List FND_XDF_TABLE_OF_VARCHAR2_30 := FND_XDF_TABLE_OF_VARCHAR2_30();
    ind integer;
    tmp_str varchar2(32000);

    begin
        tmp_str := '';
        ind := 0;
             SELECT DURATION || NVL(TEMPORARY,'N') || NVL(PCT_FREE, 0)
             || NVL(PCT_USED, 0) ||  NVL(INI_TRANS, 0) ||
             NVL(MAX_TRANS, 0) || NVL(INITIAL_EXTENT, 0) ||
             NVL(NEXT_EXTENT, 0) || NVL(MIN_EXTENTS, 0) ||
             NVL(MAX_EXTENTS, 0) || NVL(PCT_INCREASE, 0) ||
             NVL(PARTITIONED, 'NO') || NVL(FREELISTS, 0) ||
             NVL(FREELIST_GROUPS, 0) ||
             NVL(DECODE(LTRIM(DEGREE), 'DEFAULT', 65536, DEGREE) , 0) ||
             LOGGING|| CACHE|| IOT_TYPE || ROW_MOVEMENT into tmp_str
                     FROM   ALL_TABLES WHERE  TABLE_NAME=p_tablename AND OWNER=p_owner;

        for x in ( select COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE,
            DATA_PRECISION, DATA_SCALE, DATA_DEFAULT from all_tab_columns where
            table_name =p_tablename and owner = p_owner order by column_name)
        loop

            l_hashVal := dbms_utility.get_hash_value(x.COLUMN_NAME || x.DATA_TYPE || x.DATA_LENGTH || x.NULLABLE || x.DATA_PRECISION || x.DATA_SCALE || x.DATA_DEFAULT, 1, 999999999);
            ind := ind + 1;
            l_hashCode_List.EXTEND;
            l_hashCode_List(ind) := l_hashVal;

            l_column_List.EXTEND;
            l_column_List(ind) := x.COLUMN_NAME;
            tmp_str := tmp_str || l_hashVal;
        end loop;

        for x in ( SELECT PARTITION_NAME, HIGH_VALUE, SUBPARTITION_COUNT
                         FROM DBA_TAB_PARTITIONS
                         WHERE TABLE_NAME = p_tablename
                         and TABLE_OWNER = p_owner ORDER BY PARTITION_POSITION)
        loop

               l_hashVal := dbms_utility.get_hash_value(x.PARTITION_NAME || x.HIGH_VALUE || x.SUBPARTITION_COUNT,1,999999999);
               tmp_str := tmp_str || l_hashVal;
        end loop;

        for x in ( SELECT COLUMN_NAME FROM DBA_PART_KEY_COLUMNS
                       WHERE NAME = p_tablename AND OWNER =p_owner ORDER BY COLUMN_POSITION)
        loop
               l_hashVal := dbms_utility.get_hash_value(x.COLUMN_NAME,1,999999999);
               tmp_str := tmp_str || l_hashVal;
        end loop;

        table_hash_val := dbms_utility.get_hash_value(tmp_str , 1, 999999999);
        p_columns_list := l_column_List;
        return l_hashCode_List;
    exception
        WHEN NO_DATA_FOUND THEN
        table_hash_val := 0;
        return l_hashCode_List;
end;


function get_hashcode_qtable( p_qtablename in varchar2, p_owner in varchar2)
    return number is
      l_hashstr varchar2(32000);
    begin
        SELECT  TYPE || OBJECT_TYPE || SORT_ORDER || RECIPIENTS ||
           MESSAGE_GROUPING || PRIMARY_INSTANCE || SECONDARY_INSTANCE ||
           USER_COMMENT INTO l_hashstr
        FROM   ALL_QUEUE_TABLES
        WHERE QUEUE_TABLE=p_qtablename AND OWNER= p_owner;
        return DBMS_UTILITY.GET_HASH_VALUE(l_hashstr,1,999999999);
    exception
        WHEN NO_DATA_FOUND THEN
        return 0;
    end;



function get_hashcode_queue(p_queuename in varchar2, p_owner in varchar2)
    return number is
      l_hashstr varchar2(32000);
    begin
        SELECT name ||  queue_table || max_retries ||  enqueue_enabled ||
            dequeue_enabled || retry_delay || retention || user_comment
        INTO l_hashstr
        FROM ALL_QUEUES
        WHERE OWNER=p_owner AND NAME = p_queuename;
        return DBMS_UTILITY.GET_HASH_VALUE(l_hashstr,1,999999999);
    exception
        WHEN NO_DATA_FOUND THEN
        return 0;
    end;

/*
 * Funtion to generate the hashcode for an index
 */
function get_hashcode_index(p_indexname in varchar2, p_owner in varchar2)
    return number is
      l_hashstr varchar2(32000);
      cursor col_cur is
          SELECT COLUMN_NAME
          FROM all_ind_columns
          WHERE INDEX_NAME = p_indexname AND INDEX_OWNER = p_owner
          ORDER BY COLUMN_POSITION;
    begin
        SELECT INDEX_TYPE || UNIQUENESS || NVL(INI_TRANS, 0) || NVL(MAX_TRANS, 0) ||
          NVL(INITIAL_EXTENT, 0) || NVL(NEXT_EXTENT, 0 ) || NVL(MIN_EXTENTS, 0) || NVL(MAX_EXTENTS, 0) ||
          NVL(PCT_INCREASE, 0) || NVL(FREELISTS, 0) || NVL(FREELIST_GROUPS, 0) || NVL(pct_free, 0) ||
          NVL(DECODE(LTRIM(DEGREE), 'DEFAULT', 65536, DEGREE),0) || NVL(PARTITIONED, 'NO') ||
          NVL(funcidx_status, 'DISABLED') || TABLE_NAME ||
          TABLE_TYPE || NVL(ITYP_OWNER, '-1') || NVL(ITYP_NAME,'-1') || NVL(PARAMETERS, '-1') || NVL(COMPRESSION, 'DISABLED')
        INTO l_hashstr
        FROM ALL_INDEXES
        WHERE index_name = p_indexname AND OWNER = p_owner;

        for c in col_cur loop
            l_hashstr := l_hashstr || c.column_name;
        end loop;
        return DBMS_UTILITY.GET_HASH_VALUE(l_hashstr,1,999999999);
    exception
        WHEN NO_DATA_FOUND THEN
        return 0;
    end;

/*
 *  Function that generates the hashcode for an array of indexes.
 */
/*
function get_hashcode_index(p_indexList in FND_XDF_TABLE_OF_VARCHAR2_30, p_owner in varchar2)
  return FND_XDF_TABLE_OF_NUMBER is
    indexHashcodes FND_XDF_TABLE_OF_NUMBER := FND_XDF_TABLE_OF_NUMBER();

    TYPE typIndxDetails IS REF CURSOR;
    selQry varchar2(32000);
	indxDet typIndxDetails;

    cursor col_cur (p_indexname varchar2) is
          SELECT COLUMN_NAME
          FROM all_ind_columns
          WHERE INDEX_NAME = p_indexname AND INDEX_OWNER = p_owner
          ORDER BY COLUMN_POSITION;

    columnNameIndx varchar2(4000);

    l_hashstr varchar2(32000);
    index_name varchar2(32000);
    i number := 1;
	l_indexListStr varchar2(32000);

  begin
  	  -- Generate the index names string from the table of index names.
	  for j in 1..p_indexList.count loop
	  	  l_indexListStr := l_indexListStr || '''' || p_indexList(j) || ''',';
	  end loop;
	  l_indexListStr := SUBSTR(l_indexListStr,1,LENGTH(l_indexListStr) - 1);
	  --DBMS_OUTPUT.PUT_LINE(l_indexListStr);

      selQry := 'SELECT INDEX_TYPE || UNIQUENESS || NVL(INI_TRANS, 0) || NVL(MAX_TRANS, 0) || '
	      ||'NVL(INITIAL_EXTENT, 0) || NVL(NEXT_EXTENT, 0 ) || NVL(MIN_EXTENTS, 0) || NVL(MAX_EXTENTS, 0) || '
          ||'NVL(PCT_INCREASE, 0) || NVL(FREELISTS, 0) || NVL(FREELIST_GROUPS, 0) || NVL(pct_free, 0) || '
          ||'NVL(DECODE(LTRIM(DEGREE), ''DEFAULT'', 65536, DEGREE),0) || NVL(PARTITIONED, ''NO'') || '
          ||'NVL(funcidx_status, ''DISABLED'') || TABLE_NAME || NVL(tablespace_name, '' '') || TABLE_OWNER || '
          ||'TABLE_TYPE || NVL(ITYP_OWNER, ''-1'') || NVL(ITYP_NAME,''-1'') || NVL(PARAMETERS, ''-1'') || NVL(COMPRESSION, ''DISABLED'') hashstr,'
          ||'index_name '
        ||'FROM ALL_INDEXES , TABLE(FND_XDF_TABLE_OF_VARCHAR2_30(' || l_indexListstr ||')) FND_TAB '
        ||'WHERE index_name = FND_TAB.COLUMN_VALUE  AND OWNER = ''' || p_owner || ''''
		||'   UNION ALL '
		||'SELECT ''NULL'', C.COLUMN_VALUE FROM TABLE(FND_XDF_TABLE_OF_VARCHAR2_30('|| l_indexListstr || ')) C '
		||'WHERE C.COLUMN_VALUE NOT IN '
		||'(SELECT B.INDEX_NAME FROM ALL_INDEXES B WHERE OWNER = '''|| p_owner || ''' AND C.COLUMN_VALUE = B.INDEX_NAME) ';

      --DBMS_OUTPUT.PUT_LINE(l_indexListStr);
      --DBMS_OUTPUT.PUT_LINE(selQry);

      open indxDet for selQry;
      loop
        fetch indxDet into l_hashstr,index_name;
        exit when indxDet%NOTFOUND;

        --DBMS_OUTPUT.PUT_LINE(i);
        --DBMS_OUTPUT.PUT_LINE(l_hashstr);

        open  col_cur(index_name);
        loop
            fetch col_cur into columnNameIndx;
            exit when col_cur%NOTFOUND;
            exit when l_hashstr = 'NULL';
            l_hashstr := l_hashstr || columnNameIndx;
        end loop;
        close col_cur;

        --DBMS_OUTPUT.PUT_LINE(l_hashstr);

        indexHashcodes.EXTEND;
        if l_hashstr <>'NULL' then
           indexHashcodes(i) := DBMS_UTILITY.GET_HASH_VALUE(l_hashstr,1,999999999);
        else
           indexHashcodes(i) := 0;
        end if;
        i := i+1;
      end loop;
      close indxDet;
      return indexHashcodes;
  end;
*/

/*
 *  Function that generates the hashcode for an array of indexes.
 */
 function get_hashcode_index(p_indexList in FND_XDF_TABLE_OF_VARCHAR2_30, p_owner in varchar2)
 return FND_XDF_TABLE_OF_NUMBER is
    indexHashcodes FND_XDF_TABLE_OF_NUMBER := FND_XDF_TABLE_OF_NUMBER();
    selQry varchar2(32000);
    cursor col_cur (p_indexname varchar2) is
          SELECT COLUMN_NAME
          FROM all_ind_columns
          WHERE INDEX_NAME = p_indexname AND INDEX_OWNER = p_owner
          ORDER BY COLUMN_POSITION;
    columnNameIndx varchar2(4000);
    l_hashstr varchar2(32000);
    i number := 1;
  begin

    selQry := 'SELECT  INDEX_TYPE || UNIQUENESS || NVL(INI_TRANS, 0) || NVL(MAX_TRANS, 0) || '
	      ||'NVL(INITIAL_EXTENT, 0) || NVL(NEXT_EXTENT, 0 ) || NVL(MIN_EXTENTS, 0) || NVL(MAX_EXTENTS, 0) ||'
          ||'NVL(PCT_INCREASE, 0) || NVL(FREELISTS, 0) || NVL(FREELIST_GROUPS, 0) || NVL(pct_free, 0) ||'
          ||'NVL(DECODE(LTRIM(DEGREE), ''DEFAULT'', 65536, DEGREE),0) || NVL(PARTITIONED, ''NO'') ||'
          ||'NVL(funcidx_status, ''DISABLED'') || TABLE_NAME || '
          ||'TABLE_TYPE || NVL(ITYP_OWNER, ''-1'') || NVL(ITYP_NAME,''-1'') || NVL(PARAMETERS, ''-1'') || NVL(COMPRESSION, ''DISABLED'') hashstr'
	   ||' FROM ALL_INDEXES '
       ||' WHERE OWNER = '''|| p_owner ||''' AND INDEX_NAME = :p_indexname ';

    for j in 1..p_indexList.count loop
        begin
   	       execute immediate selQry into l_hashstr using p_indexList(j);
        exception
  	       when NO_DATA_FOUND then
	  	     l_hashstr := 'NULL';
        end;

	-- DBMS_OUTPUT.PUT_LINE(l_hashstr);


        open  col_cur(p_indexList(j));
        loop
            fetch col_cur into columnNameIndx;
            exit when col_cur%NOTFOUND;
            exit when l_hashstr = 'NULL';
            l_hashstr := l_hashstr || columnNameIndx;
        end loop;
        close col_cur;


        indexHashcodes.EXTEND;
        if l_hashstr <>'NULL' then
           indexHashcodes(i) := DBMS_UTILITY.GET_HASH_VALUE(l_hashstr,1,999999999);
        else
           indexHashcodes(i) := 0;
        end if;
        i := i+1;
    end loop;
    return indexHashcodes;
  end;

/* Function to determine the referenced objects of type
   'TABLE','TYPE','MATERIALIZED VIEW','VIEW','INDEX'
   Input Parameters : 1. Object Name
                      2. Object Type
                      3. Owner of the Object

*/
function depends( p_name  in varchar2,
                      p_type  in varchar2,
                      p_owner in varchar2,
                      p_lvl   in number default 1 ) return  fnd_xdf_deptype_tab_info
    as
        l_data fnd_xdf_deptype_tab_info := fnd_xdf_deptype_tab_info();

       procedure recurse( p_name  in varchar2,
                          p_type  in varchar2,
                          p_owner in varchar2,
                          p_lvl   in number )
       is
       begin
           if ( l_data.count > 1000 )
           then
               raise_application_error( -20001, 'probable connect by loop, aborting' );
           end if;

           for x in ( select /*+ first_rows */ name,
                                               owner,
                                               type
                         from dba_dependencies
                       where referenced_owner = p_owner
                           and referenced_type = p_type
                           and type in ('TABLE','TYPE','MATERIALIZED VIEW','VIEW','INDEX')
                           and referenced_name = p_name )
           loop
               l_data.extend;
               l_data(l_data.count) :=
                      fnd_xdf_deptype_info( p_lvl, x.name,
                                    x.owner, x.type );
               recurse( x.name, x.type,
                       x.owner, p_lvl+1);
           end loop;
       end;
   begin
       l_data.extend;
       l_data(l_data.count) := fnd_xdf_deptype_info( 1, p_name, p_owner, p_type );
       recurse( p_name, p_type, p_owner, 2 );
       return l_data;
   end;

end fnd_xdf_util_pkg;

/
